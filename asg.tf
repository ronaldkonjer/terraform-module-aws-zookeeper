
resource "aws_autoscaling_group" "zookeeper" {
  count                     = var.use_asg ? 1 : 0
  desired_capacity          = var.number_of_instances
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = aws_launch_configuration.zookeeper.name
  max_size                  = var.number_of_instances
  min_size                  = var.number_of_instances
  name                      = "${module.label.id}-${var.name}"
  vpc_zone_identifier       = slice(var.subnet_ids, 0, var.number_of_instances)
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "${module.label.id}-${var.name}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Zookeeper"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "Service"
    value               = "Zookeeper"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "zookeeper" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.zookeeper_eni.arn
  image_id                    = data.aws_ami.zookeeper.id
  instance_type               = var.instance_type
  key_name                    = var.keyname
  name                        = "${module.label.id}-${var.name}"
  security_groups             = compact(concat([
    aws_security_group.zookeeper.id,
    aws_security_group.zookeeper_intra.id], var.extra_security_group_ids))
  user_data                   = data.template_file.zookeeper_asg[0].rendered
  lifecycle {
    create_before_destroy = true
  }
}
