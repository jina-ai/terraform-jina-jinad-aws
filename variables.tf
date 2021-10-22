variable "volume" {
  description = <<EOT
    Volume size of ec2 instance
    EOT
  type        = number
  default     = 100
}

variable "ami" {
  description = <<EOT
    Mention base image ID
    EOT
  type        = string
  default     = "ami-07de50f2504880edb"
}

variable "instance_type" {
  description = <<EOT
    Mention base image ID
    EOT
  type        = string
  default     = "g4dn.xlarge"
}

variable "additional_tags" {
  default     = {}
  description = <<EOT
    Additional resource tags
    EOT
  type        = map(string)
}
