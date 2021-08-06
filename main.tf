/**
 * ## Usage:
 *
 *
 * ```hcl
 * module "jinad" {
 *    source         = "jina-ai/jinad-aws/jina"
 *    debug          = "true"
 *    branch         = "master"
 *    port           = "8000"
 *    script         = "setup-jinad.sh"
 *    instances      = {
 *      encoder: {
 *        type: "c5.4xlarge"
 *        disk = {
 *          type = "gp2"
 *          size = 20
 *        }
 *        command: "sudo apt install -y jq"
 *      }
 *      indexer: {
 *        type: "i3.2xlarge"
 *        disk = {
 *          type = "gp2"
 *          size = 20
 *        }
 *        command: "sudo apt-get install -y redis-server && sudo redis-server --bind 0.0.0.0 --port 6379:6379 --daemonize yes"
 *      }
 *    }
 *    availability_zone = "us-east-1a"
 *    additional_tags = {
 *      "my_tag_key" = "my_tag_value"
 *    }
 * }
 *
 * output "jinad_ips" {
 *    description   = "IP of JinaD"
 *    value         = module.jinad.instance_ips
 * }
 * ```
 *
 * Store the outputs from `jinad_ips` & Use it with `jina`
 *
 * ```python
 * from jina import Flow
 * f = (Flow()
 *      .add(uses='MyAwesomeEncoder',
 *           host=<jinad_ips.encoder>:8000),
 *      .add(uses='MyAwesomeIndexer',
 *           host=<jinad_ips.indexer>:8000))
 *
 * with f:
 *    f.index(...)
 * ```
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=3.37"
    }
  }
}


provider "aws" {
  profile = "default"
  region  = var.region
}


module "keypair" {
  source = "mitchellh/dynamic-keys/aws"
  name   = random_string.random_key_name.result
}


resource "random_string" "random_key_name" {
  length           = 8
  special          = true
  override_special = "_"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  debug        = (var.debug ? "--debug" : " ")
  branch       = (var.branch != "" ? var.branch : "master")
  port         = (var.port != "" ? var.port : "8000")
  jina_version = (var.jina_version != "" ? var.jina_version : "latest")
}

resource "aws_instance" "jinad_instance" {
  for_each = var.instances

  ami                    = "ami-0747d73950dfc9ba3" # jinad-base image with docker setup for ubuntu user
  instance_type          = each.value.type
  vpc_security_group_ids = [aws_security_group.jinad_sg.id]
  subnet_id              = aws_subnet.jinad_vpc_subnet.id
  key_name               = module.keypair.key_name
  root_block_device {
    volume_size = lookup(each.value.disk, "size", 20)
    volume_type = lookup(each.value.disk, "type", "gp2")
    tags = merge(
      var.additional_tags,
      {
        "Name" = each.key
      },
    )
  }
  tags = merge(
    var.additional_tags,
    {
      "Name" = each.key
    },
  )
}


resource "aws_eip" "jinad_ip" {
  for_each = var.instances

  vpc  = true
  tags = var.additional_tags
}


resource "aws_eip_association" "jinad_ip_association" {
  for_each = var.instances

  instance_id   = aws_instance.jinad_instance[each.key].id
  allocation_id = aws_eip.jinad_ip[each.key].id
}

resource "null_resource" "setup_jinad" {
  for_each = var.instances

  connection {
    type        = "ssh"
    host        = aws_eip.jinad_ip[each.key].public_ip
    user        = "ubuntu"
    private_key = module.keypair.private_key_pem
  }

  provisioner "file" {
    source      = var.scriptpath
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # "sudo apt-get update",
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh ${local.debug} --branch ${local.branch} --port ${local.port} --version ${local.jina_version}",
    ]
  }
}


resource "aws_vpc" "jinad_vpc" {
  cidr_block = var.vpc_cidr
  tags       = var.additional_tags
}


resource "aws_internet_gateway" "jinad_ig" {
  vpc_id = aws_vpc.jinad_vpc.id
  tags   = var.additional_tags
}

resource "aws_subnet" "jinad_vpc_subnet" {
  availability_zone = var.availability_zone
  vpc_id            = aws_vpc.jinad_vpc.id
  cidr_block        = var.subnet_cidr
  tags              = var.additional_tags
}

resource "aws_security_group" "jinad_sg" {
  vpc_id = aws_vpc.jinad_vpc.id
  tags   = var.additional_tags
}

resource "aws_security_group_rule" "jinad_sg_i_rule" {
  description       = "Allow all inbound TCP traffic into the instance"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.jinad_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  self              = false
}

resource "aws_security_group_rule" "jinad_sg_e_rule" {
  description       = "Allow all outbound TCP traffic from the instance"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.jinad_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  self              = false
}

resource "aws_route_table" "jinad_route_table" {
  vpc_id = aws_vpc.jinad_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jinad_ig.id
  }
  tags = var.additional_tags
}

resource "aws_route_table_association" "jinad_route_association" {
  subnet_id      = aws_subnet.jinad_vpc_subnet.id
  route_table_id = aws_route_table.jinad_route_table.id
}
