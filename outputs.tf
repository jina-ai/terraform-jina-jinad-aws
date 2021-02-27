output "elastic_ip" {
  description = "Elastic IP of JinaD instance created"
  value       = aws_eip.jinad_ip.public_ip
}


output "private_key_pem" {
  description = "Private key of JinaD instance for debugging"
  value       = module.keypair.private_key_pem
}
