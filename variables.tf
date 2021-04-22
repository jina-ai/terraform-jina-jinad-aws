variable "region" {
  description = <<EOT
    Mention the Region where JinaD resources are going to get created
    EOT
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = <<EOT
    Mention the availability_zone where JinaD resources are going to get created
    EOT
  type        = string
  default     = "us-east-1a"
}

variable "disk" {
  description = <<EOT
    Mention the settings of EBS which is attached to instance
    EOT
  type = map(any)
  default = {
    device_name = "/dev/sdh"
    device_name_renamed = "/dev/xvdh"
    mount_location = "/mnt/data"
    jina_home = "/usr/local/jina"
  }
}

variable "instances" {
  description = <<EOT
    Describe instance configuration here.
    EOT
  type        = map(any)
  default = {
    instance1 = {
      type = "t2.micro"
      disk = {
        type = "gp2"
        size = "20"
      }
      pip = [
        "Pillow",
        "transformers"
      ]
      command = "sudo echo \"Hello from instance1\""
    }
    instance2 = {
      type = "t2.micro"
      disk = {
        type = "gp2"
        size = "20"
      }
      pip = [
        "annoy",
      ]
      command = "sudo echo \"Hello from instance2\""
    },
  }
}

variable "vpc_cidr" {
  description = <<EOT
    Mention the CIDR of the VPC
    EOT
  type        = string
  default     = "10.113.0.0/16"
}

variable "subnet_cidr" {
  description = <<EOT
    Mention the CIDR of the subnet
    EOT
  type        = string
  default     = "10.113.0.0/16"
}

variable "additional_tags" {
  default     = {}
  description = <<EOT
    Additional resource tags
    EOT
  type        = map(string)
}
