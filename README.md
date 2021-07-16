## Usage:

```hcl
module "jinad" {
   source         = "jina-ai/jinad-aws/jina"
   debug          = "true"
   branch         = "master"
   port           = "8000"
   script         = "setup-jinad.sh"
   instances      = {
     encoder: {
       type: "c5.4xlarge"
       disk = {
         type = "gp2"
         size = 20
       }
       command: "sudo apt install -y jq"
     }
     indexer: {
       type: "i3.2xlarge"
       disk = {
         type = "gp2"
         size = 20
       }
       command: "sudo apt-get install -y redis-server && sudo redis-server --bind 0.0.0.0 --port 6379:6379 --daemonize yes"
     }
   }
   availability_zone = "us-east-1a"
   additional_tags = {
     "my_tag_key" = "my_tag_value"
   }
}

output "jinad_ips" {
   description   = "IP of JinaD"
   value         = module.jinad.instance_ips
}
```

Store the outputs from `jinad_ips` & Use it with `jina`

```python
from jina import Flow
f = (Flow()
     .add(uses='MyAwesomeEncoder',
          host=<jinad_ips.encoder>:8000),
     .add(uses='MyAwesomeIndexer',
          host=<jinad_ips.indexer>:8000))

with f:
   f.index(...)
```

## Requirements

| Name | Version |
|------|---------|
| aws | =3.37 |

## Providers

| Name | Version |
|------|---------|
| aws | =3.37 |
| null | n/a |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| keypair | mitchellh/dynamic-keys/aws |  |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/data-sources/ami) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/eip) |
| [aws_eip_association](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/eip_association) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/instance) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/internet_gateway) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/route_table_association) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/security_group_rule) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/3.37/docs/resources/vpc) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags | Additional resource tags | `map(string)` | `{}` | no |
| availability\_zone | Mention the availability\_zone where JinaD resources are going to get created | `string` | `"us-east-1a"` | no |
| branch | Mention the git-branch of jina repo to be built | `string` | `"master"` | no |
| debug | True if this is running for testing | `bool` | `true` | no |
| instances | Describe instance configuration here. | `map(any)` | <pre>{<br>  "instance1": {<br>    "command": "sudo echo \"Hello from instance1\"",<br>    "disk": {<br>      "size": 50,<br>      "type": "gp2"<br>    },<br>    "type": "t2.micro"<br>  },<br>  "instance2": {<br>    "command": "sudo echo \"Hello from instance2\"",<br>    "disk": {<br>      "size": 20,<br>      "type": "gp2"<br>    },<br>    "type": "t2.micro"<br>  }<br>}</pre> | no |
| jina\_version | Mention the version of jinad to be pulled from docker hub<br>    This is applicable only if debug is set to false | `string` | `"latest"` | no |
| port | Mention the jinad port to be mapped on host | `string` | `"8000"` | no |
| region | Mention the Region where JinaD resources are going to get created | `string` | `"us-east-1"` | no |
| scriptpath | jinad setup script path (part of jina codebase) | `string` | n/a | yes |
| subnet\_cidr | Mention the CIDR of the subnet | `string` | `"10.113.0.0/16"` | no |
| vpc\_cidr | Mention the CIDR of the VPC | `string` | `"10.113.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_ips | Elastic IPs of JinaD instances created as a map |
| instance\_keys | Private key of JinaD instances for debugging |
