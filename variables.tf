#
# Variables for the Apache Zookeeper terraform module.
#
# Copyright 2016-2020, Frederico Martins
#   Author: Frederico Martins <http://github.com/fscm>
#
# SPDX-License-Identifier: MIT
#
# This program is free software. You can use it and/or modify it under the
# terms of the MIT License.
#

variable "ami_name" {
  description = "The name of the AMI to use for the instance(s)."
  default     = "zookeeper"
  type        = string
}

variable "ami_prefix" {
  description = "The prefix of the AMI to use for the instance(s)."
  default     = ""
  type        = string
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address to the Apache Zookeeper instance(s)."
  default     = false
  type        = string
}

variable "domain" {
  description = "The domain name to use for the Apache Zookeeper instance(s)."
  type        = string
}

variable "extra_security_group_ids" {
  description = "Extra security groups to assign to the Apache Zookeeper instance(s) (e.g.: ['sg-3f983f98'])."
  default     = []
  type        = list(string)
}

variable "heap_size" {
  description = "The heap size for the Apache Zookeeper instance(s) (e.g.: '1G')."
  default     = ""
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use for the Apache Zookeeper instance(s)."
  default     = "t2.small"
  type        = string
}

variable "keyname" {
  description = "The SSH key name to use for the Apache Zookeeper instance(s)."
  type        = string
}

variable "name" {
  description = "The main name that will be used for the Apache Zookeeper instance(s)."
  default     = "zookeeper"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster that will be used for the Apache Zookeeper instance(s)."
  default     = ""
  type        = string
}

variable "environment" {
  description = "The environment name that will be used in the dns and "
  default     = ""
  type        = string
}

variable "number_of_instances" {
  description = "Number of Apache Zookeeper instances."
  default     = "1"
  type        = string
}

variable "private_zone_id" {
  description = "The ID of the hosted zone for the private DNS record(s)."
  default     = ""
  type        = string
}

variable "public_zone_id" {
  description = "The ID of the hosted zone for the public DNS record(s)."
  default     = ""
  type        = string
}

variable "root_volume_iops" {
  description = "The amount of provisioned IOPS (for 'io1' type only)."
  default     = 0
  type        = string
}

variable "root_volume_size" {
  description = "The volume size in gigabytes."
  default     = "8"
  type        = string
}

variable "root_volume_type" {
  description = "The volume type. Must be one of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)."
  default     = "gp2"
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs to launch the instance(s) in (e.g.: ['subnet-0zfg04s2','subnet-6jm2z54q'])."
  type        = list(string)
}

variable "ttl" {
  description = "The TTL (in seconds) for the DNS record(s)."
  default     = "600"
  type        = string
}

variable "use_asg" {
  description = "Set to true to use an Auto Scaling Group for the cluster."
  default     = false
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for the security group(s)."
  type        = string
}

variable "namespace" {
  description = "Namespace (e.g. `eg` or `cp`)"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
  default     = ""
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "label_order" {
  type        = list(string)
  default     = []
  description = "The naming order of the id output and Name tag"
}




