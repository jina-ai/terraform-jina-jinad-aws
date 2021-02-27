## Usage:

```hcl
module "jinad" {
   source         = "deepankarm/daemon-aws/jina"

   instance_type  = "m4.large"
   vpc_cidr       = "34.121.0.0/24"
   subnet_cidr    = "34.121.0.0/28"
}

output "JINAD_IP" {
   description   = "IP of JinaD"
   value         = module.jinad.elastic_ip
}
```

Store the output `JINAD_IP`

```python
from jina.flow import Flow
f = Flow().add(uses='MyAdvancedEncoder',
               host=JINAD_IP,
               port_expose=8000)

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
| instance\_name | Mention the name of the JinaD Instance | `string` | `"JinaD_EC2"` | no |
| instance\_type | Mention the ec2 instance type for the JinaD instance | `string` | `"t2.micro"` | no |
| region | Mention the Region where JinaD resources are going to get created | `string` | `"us-east-1"` | no |
| subnet\_cidr | Mention the CIDR of the subnet | `string` | `"10.113.0.0/16"` | no |
| vpc\_cidr | Mention the CIDR of the VPC | `string` | `"10.113.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| elastic\_ip | Elastic IP of JinaD instance created |
| private\_key\_pem | Private key of JinaD instance for debugging |
