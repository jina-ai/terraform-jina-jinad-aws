variable "region" {
  description = <<EOT
    Mention the Region where JinaD resources are going to get created
    EOT
  type        = string
  default     = "us-east-1"
}


# variable "instance_type" {
#   description = <<EOT
#     Mention the ec2 instance type for the JinaD instance
#     EOT
#   type        = string
#   default     = "t2.micro"
# }


# variable "instance_name" {
#   description = <<EOT
#     Mention the name of the JinaD Instance
#     EOT
#   type        = string
#   default     = "JinaD_EC2"
# }

variable "jinad_ec2" {
  description = "Multiple instances(multiple pods) in one VPC.(Important to have all instances in one VPC)"
  type = map
  default = {
    foo = {
      type = "t2.large"
      pip = [
        "Pillow",
        "transformers"
      ]
    },
    bar = {
      type = "t2.micro"
      pip = [
        "annoy",
      ]
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
  description = "Additional resource tags"
  type        = map(string)
}
