# Purpose: Create a least-privilege security group with egress-only default and optional extra rules.

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = local.create ? 1 : 0

  name                   = local.security_group_name
  name_prefix            = local.security_group_name_prefix
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = local.merged_tags

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Default Egress Rules (IPv4 and IPv6)
################################################################################

resource "aws_vpc_security_group_egress_rule" "default_ipv4" {
  for_each = local.create ? toset(var.egress_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound IPv4 traffic"
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "default_ipv6" {
  for_each = local.create ? toset(var.egress_ipv6_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound IPv6 traffic"
  cidr_ipv6         = each.value
  ip_protocol       = "-1"
}

################################################################################
# Self-referencing Egress Rule
################################################################################

resource "aws_vpc_security_group_egress_rule" "self" {
  count = local.create && var.egress_with_self ? 1 : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = "Allow all outbound traffic to self"
  referenced_security_group_id = aws_security_group.this[0].id
  ip_protocol                  = "-1"
}

################################################################################
# VPC Endpoint Egress Rules (for private/least-privilege deployments)
################################################################################

resource "aws_vpc_security_group_egress_rule" "vpc_endpoints" {
  for_each = local.create ? toset(var.vpc_endpoint_security_group_ids) : []

  security_group_id            = aws_security_group.this[0].id
  description                  = "Allow outbound traffic to VPC endpoint"
  referenced_security_group_id = each.value
  ip_protocol                  = "-1"
}

################################################################################
# Additional Egress Rules
################################################################################

resource "aws_security_group_rule" "additional_egress" {
  for_each = local.create ? local.egress_rules_by_index : {}

  type                     = "egress"
  description              = try(each.value.description, null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.cidr_blocks, [])
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, [])
  prefix_list_ids          = try(each.value.prefix_list_ids, [])
  source_security_group_id = try(each.value.destination_security_group_id, null)
  self                     = try(each.value.self, false)
  security_group_id        = aws_security_group.this[0].id
}

################################################################################
# Self-referencing Ingress Rule
################################################################################

resource "aws_vpc_security_group_ingress_rule" "self" {
  count = local.create && var.ingress_with_self ? 1 : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = "Allow all inbound traffic from self"
  referenced_security_group_id = aws_security_group.this[0].id
  ip_protocol                  = "-1"
}

################################################################################
# Additional Ingress Rules
################################################################################

resource "aws_security_group_rule" "additional_ingress" {
  for_each = local.create ? local.ingress_rules_by_index : {}

  type                     = "ingress"
  description              = try(each.value.description, null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.cidr_blocks, [])
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, [])
  prefix_list_ids          = try(each.value.prefix_list_ids, [])
  source_security_group_id = try(each.value.source_security_group_id, null)
  self                     = try(each.value.self, false)
  security_group_id        = aws_security_group.this[0].id
}
