data "aws_ami" "zookeeper" {
  most_recent = true
  //  name_regex  = "^${var.prefix}${var.name}-.*-(\\d{14})$"
  owners      = ["self"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["${var.ami_prefix}${var.ami_name}-*"]
  }
  filter {
    name   = "virtualization-type"
    values = [
      "hvm"]
  }
}
