# Purpose: Compute local tags and reusable ARN patterns for IAM policies.

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  create = var.create

  # Role naming
  role_name        = var.use_role_name_prefix ? null : var.role_name
  role_name_prefix = var.use_role_name_prefix ? var.role_name_prefix : null

  default_tags = {
    Name      = coalesce(var.role_name, var.role_name_prefix, "agentcore-execution")
    ManagedBy = "terraform"
  }

  merged_tags = merge(var.tags, local.default_tags)

  # CloudWatch Logs ARNs for AgentCore - scoped to specific account and region (least privilege)
  agentcore_logs_arns = [
    format("arn:%s:logs:%s:%s:log-group:/aws/bedrock-agentcore/*",
      data.aws_partition.current.partition,
      data.aws_region.current.id,
      var.aws_account_id
    ),
    format("arn:%s:logs:%s:%s:log-group:/aws/bedrock-agentcore/*:*",
      data.aws_partition.current.partition,
      data.aws_region.current.id,
      var.aws_account_id
    )
  ]

  # Combine ECR repository ARNs
  all_ecr_repository_arns = compact(concat(
    var.ecr_repository_arn != null ? [var.ecr_repository_arn] : [],
    var.ecr_repository_arns
  ))

  # Bedrock model resources - require explicit ARNs for least privilege.
  # If no ARNs are provided but access is enabled, allow both foundation models
  # and inference profiles. Cross-region inference profiles (model IDs prefixed
  # with "us.", "eu.", etc.) route to foundation models in MULTIPLE regions,
  # so we use a region wildcard for foundation models to support this.
  bedrock_model_resources = length(var.bedrock_model_arns) > 0 ? var.bedrock_model_arns : [
    # Foundation models - wildcard region to support cross-region inference profiles
    format("arn:%s:bedrock:*::foundation-model/*",
      data.aws_partition.current.partition
    ),
    # AWS-managed cross-region inference profiles (no account ID)
    format("arn:%s:bedrock:%s::inference-profile/*",
      data.aws_partition.current.partition,
      data.aws_region.current.id
    ),
    # Customer-managed inference profiles (with account ID)
    format("arn:%s:bedrock:%s:%s:inference-profile/*",
      data.aws_partition.current.partition,
      data.aws_region.current.id,
      var.aws_account_id
    )
  ]
}
