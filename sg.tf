
resource "aws_security_group" "zookeeper" {
  name   = module.label.id
  vpc_id = var.vpc_id
  ingress {
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
    self      = true
  }
  lifecycle {
    create_before_destroy = true
  }
  tags   = merge(
  module.label.tags,
  {
    Name      = module.label.id
    Zookeeper = "true"
    Service   = "Zookeeper"
  }
  )
}

resource "aws_security_group" "zookeeper_intra" {
  name   = "${module.label.id}-intra"
  vpc_id = var.vpc_id
  ingress {
    from_port = 2888
    to_port   = 2888
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port = 3888
    to_port   = 3888
    protocol  = "tcp"
    self      = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags   = merge(
  module.label.tags,
  {
    Name      = "${module.label.id}-intra"
    Zookeeper = "true"
    Service   = "Zookeeper"
  }
  )
}

resource "aws_security_group" "zookeeper_monit" {
  name   = "${module.label.id}-monit"
  vpc_id = var.vpc_id
  ingress {
    from_port = 7199
    to_port   = 7199
    protocol  = "tcp"
    self      = true
  }
  lifecycle {
    create_before_destroy = true
  }
  tags   = merge(
  module.label.tags,
  {
    Name      = "${module.label.id}-monit"
    Zookeeper = "true"
    Service   = "Zookeeper"
  }
  )
}

