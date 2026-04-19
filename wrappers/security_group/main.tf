module "wrapper" {
  source = "../../modules/security_group"

  for_each = var.items

  additional_egress_rules         = try(each.value.additional_egress_rules, var.defaults.additional_egress_rules, [])
  additional_ingress_rules        = try(each.value.additional_ingress_rules, var.defaults.additional_ingress_rules, [])
  create                          = try(each.value.create, var.defaults.create, true)
  description                     = try(each.value.description, var.defaults.description, "Security group for Bedrock AgentCore runtime")
  egress_cidr_blocks              = try(each.value.egress_cidr_blocks, var.defaults.egress_cidr_blocks, [])
  egress_ipv6_cidr_blocks         = try(each.value.egress_ipv6_cidr_blocks, var.defaults.egress_ipv6_cidr_blocks, [])
  egress_with_self                = try(each.value.egress_with_self, var.defaults.egress_with_self, false)
  ingress_with_self               = try(each.value.ingress_with_self, var.defaults.ingress_with_self, false)
  revoke_rules_on_delete          = try(each.value.revoke_rules_on_delete, var.defaults.revoke_rules_on_delete, true)
  security_group_name             = try(each.value.security_group_name, var.defaults.security_group_name, null)
  security_group_name_prefix      = try(each.value.security_group_name_prefix, var.defaults.security_group_name_prefix, null)
  tags                            = try(each.value.tags, var.defaults.tags, {})
  use_name_prefix                 = try(each.value.use_name_prefix, var.defaults.use_name_prefix, false)
  vpc_endpoint_security_group_ids = try(each.value.vpc_endpoint_security_group_ids, var.defaults.vpc_endpoint_security_group_ids, [])
  vpc_id                          = try(each.value.vpc_id, var.defaults.vpc_id)
}
