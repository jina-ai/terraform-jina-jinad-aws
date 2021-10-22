# output "instance_ips" {
#   description = <<EOT
#     Elastic IPs of JinaD instances created as a map
#     EOT
#   value       = { for jinad in sort(keys(var.instances)) : jinad => aws_eip.jinad_ip[jinad].public_ip }
# }


output "asg_id" {
  description = <<EOT
    ID of the Autoscaling group
    EOT
  value       = aws_autoscaling_group.jinad_asg.id
}
