
resource "aws_iam_instance_profile" "zookeeper_eni" {
  name = "${module.label.id}-eni"
  role = aws_iam_role.zookeeper_eni.id
}

resource "aws_iam_role" "zookeeper_eni" {
  name               = "${module.label.id}-eni"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "zookeeper_eni" {
  name   = "${module.label.id}-eni"
  role   = aws_iam_role.zookeeper_eni.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
        "ec2:AttachNetworkInterface",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:AttachVolume",
        "ssm:GetDocument",
        "ec2:DetachVolume",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

