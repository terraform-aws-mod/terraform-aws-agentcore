# Purpose: Compute local tags and normalized rule maps.

locals {
  create = var.create

  # Security group naming
  security_group_name        = var.use_name_prefix ? null : var.security_group_name
  security_group_name_prefix = var.use_name_prefix ? var.security_group_name_prefix : null

  default_tags = {
    Name      = coalesce(var.security_group_name, var.security_group_name_prefix, "agentcore-sg")
    ManagedBy = "terraform"
  }

  merged_tags = merge(var.tags, local.default_tags)

  # Normalize ingress rules for iteration
  ingress_rules_by_index = {
    for index, rule in var.additional_ingress_rules :
    tostring(index) => rule
  }

  # Normalize egress rules for iteration
  egress_rules_by_index = {
    for index, rule in var.additional_egress_rules :
    tostring(index) => rule
  }
}
