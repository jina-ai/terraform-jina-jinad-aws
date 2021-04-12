/**
 * ## Usage:
 *
 *
 * ```hcl
 * module "jinad" {
 *    source         = "jina-ai/jinad-aws/jina"
 *
 *    instance_type  = "m4.large"
 *    vpc_cidr       = "34.121.0.0/24"
 *    subnet_cidr    = "34.121.0.0/28"
 *    additional_tags = {
 *      "my_tag_key" = "my_tag_value"
 *    }
 * }
 *
 * output "JINAD_IP" {
 *    description   = "IP of JinaD"
 *    value         = module.jinad.elastic_ip
 * }
 * ```
 *
 * Store the output `JINAD_IP` & Use it with `jina`
 *
 * ```python
 * from jina.flow import Flow
 * f = Flow().add(uses='MyAdvancedEncoder',
 *                host=JINAD_IP,
 *                port_expose=8000)
 *
 * with f:
 *    f.index(...)
 * ```
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
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


resource "aws_instance" "jinad_instance" {
  for_each = var.jinad_ec2

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.type
  vpc_security_group_ids = [aws_security_group.jinad_sg.id]
  subnet_id              = aws_subnet.jinad_vpc_subnet.id
  key_name               = module.keypair.key_name
  tags = merge(
    var.additional_tags,
    {
      "Name" = each.key
    },
  )
}


resource "aws_eip" "jinad_ip" {
  for_each = var.jinad_ec2

  vpc  = true
  tags = var.additional_tags
}


resource "aws_eip_association" "jinad_ip_association" {
  for_each = var.jinad_ec2

  instance_id   = aws_instance.jinad_instance[each.key].id
  allocation_id = aws_eip.jinad_ip[each.key].id 
}


resource "null_resource" "setup_jinad" {
  for_each = var.jinad_ec2

  connection {
    type        = "ssh"
    host        = aws_eip.jinad_ip[each.key].public_ip
    user        = "ubuntu"
    private_key = module.keypair.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://raw.githubusercontent.com/jina-ai/cloud-ops/master/scripts/deb-systemd.sh > jinad-init.sh",
      "chmod +x jinad-init.sh",
      "sudo apt-get update",
      "sudo bash jinad-init.sh ${join(" ", each.value.pip)}"
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
  vpc_id     = aws_vpc.jinad_vpc.id
  cidr_block = var.subnet_cidr
  tags       = var.additional_tags
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
