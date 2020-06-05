output "fqdn" {
  sensitive = false
  value     = [aws_route53_record.private.*.fqdn]
}

output "hostname" {
  sensitive = false
  value     = [aws_instance.zookeeper.*.private_dns]
}

output "id" {
  sensitive = false
  value     = [aws_instance.zookeeper.*.id]
}

output "ip" {
  sensitive = false
  value     = [aws_instance.zookeeper.*.private_ip]
}

output "security_group" {
  sensitive = false
  value     = aws_security_group.zookeeper.id
}

output "security_group_monit" {
  sensitive = false
  value     = aws_security_group.zookeeper_monit.id
}

output "ssh_key" {
  sensitive = false
  value     = var.keyname
}

