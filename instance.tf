resource "aws_instance" "zookeeper" {
  count                       = var.use_asg ? 0 : var.number_of_instances
  ami                         = data.aws_ami.zookeeper.id
  associate_public_ip_address = var.associate_public_ip_address
  instance_type               = var.instance_type
  key_name                    = var.keyname
  subnet_id                   = element(var.subnet_ids, count.index)
  user_data                   = element(data.template_file.zookeeper.*.rendered, count.index)

  vpc_security_group_ids = compact(concat([
    aws_security_group.zookeeper.id,
    aws_security_group.zookeeper_intra.id], var.extra_security_group_ids))

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops
  }
  tags = merge(
  module.label.tags,
  {
    Name      = "${module.label.id}-${var.name}-${format("%02d", count.index + 1)}"
    Zookeeper = "true"
    Service   = "Zookeeper"
  }
  )
}
