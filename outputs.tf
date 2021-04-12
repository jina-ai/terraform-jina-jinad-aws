output "elastic_ip" {
  description = "Elastic IP of JinaD instance created"
  value       = { for jinad in sort(keys(var.jinad_ec2)) : jinad => aws_eip.jinad_ip[jinad].public_ip}
}


output "private_key_pem" {
  description = "Private key of JinaD instance for debugging"
  value       = module.keypair.private_key_pem
}
