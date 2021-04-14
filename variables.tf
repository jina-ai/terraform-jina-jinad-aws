variable "region" {
  description = <<EOT
    Mention the Region where JinaD resources are going to get created
    EOT
  type        = string
  default     = "us-east-1"
}


variable "instances" {
  description = <<EOT
    Describe instance configuration here.
    EOT
  type        = map(any)
  default = {
    "instance1" = {
      "type" = "t2.micro"
      "pip" = [
        "Pillow",
        "transformers"
      ],
      "command" = "sudo echo \"Hello from instance1\""
    },
    "instance2" = {
      "type" = "t2.micro"
      "pip" = [
        "annoy",
      ],
      "command" = "sudo echo \"Hello from instance2\""
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
