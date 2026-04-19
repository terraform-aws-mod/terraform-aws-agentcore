locals {
  create = var.create

  default_tags = {
    Name      = var.memory_name
    ManagedBy = "terraform"
  }

  merged_tags = merge(var.tags, local.default_tags)

  kms_account_id = local.create && var.create_kms_key ? data.aws_caller_identity.kms[0].account_id : ""
}
