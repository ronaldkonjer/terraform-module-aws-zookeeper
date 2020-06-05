data "template_file" "zookeeper" {
  count    = var.use_asg ? 0 : var.number_of_instances
  template = file("${path.module}/templates/cloud-config/init.tpl")
  vars     = {
    domain         = var.domain
    environment    = var.environment
    hostname       = "${module.label.name}-${format("%02d", count.index + 1)}"
    zookeeper_args = "-i ${count.index + 1} -n ${join(",", data.template_file.zookeeper_id.*.rendered)} ${var.heap_size == "" ? var.heap_size : format("-m %s", var.heap_size)}"
  }
}

data "template_file" "zookeeper_id" {
  count    = var.number_of_instances
  template = "$${index}:$${hostname}.$${environment}.$${domain}"
  vars     = {
    domain      = var.domain
    environment = var.environment
    hostname    = "${module.label.name}-${format("%02d", count.index + 1)}"
    index       = count.index + 1
  }
}


data "template_file" "zookeeper_asg" {
  count    = var.use_asg ? 1 : 0
  template = file("${path.module}/templates/cloud-config/init_asg.tpl")
  vars     = {
    domain         = var.domain
    environment    = var.environment
    eni_reference  = module.label.id
    hostname       = module.label.name
    service        = "zookeeper"
    metric         = "ZookeeperStatus"
    zookeeper_addr = join(",", data.template_file.zookeeper_asg_addr.*.rendered)
    zookeeper_args = "-n ${join(",", data.template_file.zookeeper_id.*.rendered)} ${var.heap_size == "" ? var.heap_size : format("-m %s", var.heap_size)}"
  }
}

data "template_file" "zookeeper_asg_addr" {
  count    = var.use_asg ? var.number_of_instances : 0
  template = "$${index}:$${address}"
  vars     = {
    address = element(
    split(",", format("%s", join(",", flatten(aws_network_interface.zookeeper.*.private_ips)))),
    count.index,
    )
    index   = count.index + 1
  }
}
