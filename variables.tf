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
        size = 50
      }
      command = "sudo echo \"Hello from instance1\""
    }
    instance2 = {
      type = "t2.micro"
      disk = {
        type = "gp2"
        size = 20
      }
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

variable "scriptpath" {
  description = <<EOT
    jinad setup script path (part of jina codebase)
    EOT
  type        = string
}

variable "debug" {
  default     = true
  description = <<EOT
    True if this is running for testing
    EOT
  type        = bool
}

variable "branch" {
  description = <<EOT
    Mention the git-branch of jina repo to be built
    EOT
  type        = string
  default     = "master"
}

variable "port" {
  description = <<EOT
    Mention the jinad port to be mapped on host
    EOT
  type        = string
  default     = "8000"
}

variable "jina_version" {
  description = <<EOT
    Mention the version of jinad to be pulled from docker hub
    This is applicable only if debug is set to false
    EOT
  type        = string
  default     = "latest"
}
