module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1"
  namespace  = var.namespace
  stage      = var.stage
  environment = var.environment
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  label_order = var.label_order
}