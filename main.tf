terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">3.37"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  create_vpc         = false
  manage_default_vpc = true
  default_vpc_name   = "default"
  public_subnets     = ["172.31.1.0/20", "172.31.2.0/20", "172.31.3.0/20"]
}

resource "aws_security_group" "jinad_sg" {
  vpc_id = module.vpc.default_vpc_id
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
}

resource "aws_security_group_rule" "jinad_sg_e_rule" {
  description       = "Allow all outbound TCP traffic from the instance"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.jinad_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_template" "jinad_template" {
  name = "jinad_template"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.volume
    }
  }

  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = "jinad-default"
  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.jinad_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "jinad-instance"
    }
  }
  user_data = filebase64("${path.module}/jinad.sh")
}

resource "aws_autoscaling_group" "jinad_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.jinad_template.id
    version = "$Latest"
  }
}
