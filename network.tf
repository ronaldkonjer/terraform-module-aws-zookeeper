resource "aws_network_interface" "zookeeper" {
  count             = var.use_asg ? var.number_of_instances : 0
  subnet_id         = element(var.subnet_ids, count.index)
  security_groups   = compact(concat([
    aws_security_group.zookeeper.id], var.extra_security_group_ids))
  source_dest_check = false
  tags              =merge(
  module.label.tags,
  {
    Name      = "${module.label.id}-${format("%02d", count.index + 1)}"
    Reference = module.label.id
    Zookeeper = "true"
    Service   = "Zookeeper"
  }
  )
}

resource "aws_eip" "zookeeper" {
  count             = var.use_asg && var.associate_public_ip_address ? var.number_of_instances : 0
  depends_on        = [aws_network_interface.zookeeper]
  network_interface = element(aws_network_interface.zookeeper.*.id, count.index)
  vpc               = true
}