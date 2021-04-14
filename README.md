## Usage:

```hcl
module "jinad" {
   source         = "jina-ai/jinad-aws/jina"

   instances      = {
     {
       "encoder": {
         "type": "c5.4xlarge",
         "pip": [ "tensorflow>=2.0", "transformers>=2.6.0" ],
         "command": "sudo apt install jq"
       }
       "indexer": {
         "type": "i3.2xlarge",
         "pip": [ "faiss-cpu==1.6.5", "redis==3.5.3" ],
         "command": "sudo apt-get install -y redis-server && sudo redis-server --bind 0.0.0.0 --port 6379:6379 --daemonize yes"
       }
     }
   }
   vpc_cidr       = "34.121.0.0/24"
   subnet_cidr    = "34.121.0.0/28"
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
from jina.flow import Flow
f = (Flow()
     .add(uses='MyAdvancedEncoder',
          host=jinad_ips.encoder,
          port_expose=8000),
     .add(uses='MyAdvancedIndexer',
          host=jinad_ips.indexer,
          port_expose=8000))

with f:
   f.index(...)
```

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.27 |
| null | n/a |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| keypair | mitchellh/dynamic-keys/aws |  |

## Resources

| Name |
|------|
| [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) |
| [aws_eip_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tags | Additional resource tags | `map(string)` | `{}` | no |
| instances | Describe instance configuration here. | `map(any)` | <pre>{<br>  "instance1": {<br>    "command": "sudo echo \"Hello from instance1\"",<br>    "pip": [<br>      "Pillow",<br>      "transformers"<br>    ],<br>    "type": "t2.micro"<br>  },<br>  "instance2": {<br>    "command": "sudo echo \"Hello from instance2\"",<br>    "pip": [<br>      "annoy"<br>    ],<br>    "type": "t2.micro"<br>  }<br>}</pre> | no |
| region | Mention the Region where JinaD resources are going to get created | `string` | `"us-east-1"` | no |
| subnet\_cidr | Mention the CIDR of the subnet | `string` | `"10.113.0.0/16"` | no |
| vpc\_cidr | Mention the CIDR of the VPC | `string` | `"10.113.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_ips | Elastic IPs of JinaD instances created as a map |
| instance\_keys | Private key of JinaD instance for debugging |
