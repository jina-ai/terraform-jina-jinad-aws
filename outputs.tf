output "instance_ips" {
  description = <<EOT
    Elastic IPs of JinaD instances created as a map
    EOT
  value       = { for jinad in sort(keys(var.instances)) : jinad => aws_eip.jinad_ip[jinad].public_ip }
}


output "instance_keys" {
  description = <<EOT
    Private key of JinaD instances for debugging
    EOT
  value       = module.keypair.private_key_pem
}
