resource "aws_route53_record" "private" {
  count   = var.private_zone_id != "" ? var.number_of_instances : 0
  name    = "${module.label.name}-${format("%02d", count.index + 1)}.${var.environment}"
  records = [
    var.use_asg ? element(
    split(",", format("%s", join(",", flatten(aws_network_interface.zookeeper.*.private_ips)))),
    count.index,
    ) : element(aws_instance.zookeeper.*.private_ip, count.index)]
  ttl     = var.ttl
  type    = "A"
  zone_id = var.private_zone_id
}

resource "aws_route53_record" "public" {
  count   = var.public_zone_id != "" && var.associate_public_ip_address ? var.number_of_instances : 0
  name    = "${module.label.name}-${format("%02d", count.index + 1)}.${var.environment}"
  records = [
    var.use_asg ? element(aws_eip.zookeeper.*.public_ip, count.index) : element(aws_instance.zookeeper.*.public_ip, count.index)]
  ttl     = var.ttl
  type    = "A"
  zone_id = var.public_zone_id
}