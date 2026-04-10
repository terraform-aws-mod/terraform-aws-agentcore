# Purpose: Compute effective values used by root orchestration logic.

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  default_tags = {
    Name      = var.agent_runtime_name
    ManagedBy = "terraform"
  }

  merged_tags = merge(var.tags, local.default_tags)

  effective_ecr_repository_name = coalesce(var.ecr_repository_name, var.agent_runtime_name)
  effective_aws_account_id      = coalesce(var.aws_account_id, data.aws_caller_identity.current.account_id)

  create_security_group_effective = var.network_mode == "VPC" && var.create_security_group

  # When ECR repository is created by this module, compute the predicted ARN
  # When using external image (create_ecr_repository = false), use wildcard for IAM policy
  predicted_ecr_repository_arn = format(
    "arn:%s:ecr:%s:%s:repository/%s",
    data.aws_partition.current.partition,
    data.aws_region.current.region,
    local.effective_aws_account_id,
    local.effective_ecr_repository_name
  )

  # Use predicted ARN when creating ECR repo, otherwise use wildcard (external/public images don't need specific ARN)
  effective_ecr_repository_arn = var.create_ecr_repository ? local.predicted_ecr_repository_arn : "*"

  effective_iam_role_arn = var.create_iam_role ? module.iam[0].iam_role_arn : var.iam_role_arn

  effective_security_group_ids = var.network_mode == "VPC" ? (
    local.create_security_group_effective
    ? concat(var.security_group_ids, [module.security_group[0].security_group_id])
    : var.security_group_ids
  ) : []

  # Compute effective image scanning configuration (backward compatible)
  effective_image_scanning_configuration = var.ecr_scan_on_push != null ? {
    scan_on_push = var.ecr_scan_on_push
  } : var.ecr_image_scanning_configuration

  # Compute effective lifecycle configuration (backward compatible)
  effective_lifecycle_configuration = var.idle_session_timeout_seconds != null || var.max_session_lifetime_seconds != null ? {
    idle_runtime_session_timeout = coalesce(var.idle_session_timeout_seconds, 300)
    max_lifetime                 = coalesce(var.max_session_lifetime_seconds, 1800)
  } : var.runtime_lifecycle_configuration
}
