# Purpose: Provision execution IAM role, trust policy, inline policies, and managed policy attachments.
# 
# This module provides the minimal IAM permissions required for AgentCore:
# - Trust policy for bedrock-agentcore.amazonaws.com
# - ECR pull permissions (if ECR repository ARN provided)
# - CloudWatch Logs permissions (mandatory for AgentCore)
# - Bedrock model invocation permissions (optional, for agents calling Bedrock models)
# - Secrets Manager permissions (optional, for agents needing secrets)
# - SSM Parameter Store permissions (optional, for agents needing parameters)
#
# For additional service permissions (S3, DynamoDB, SQS, SNS, Lambda, X-Ray, etc.),
# use inline_policy_statements or iam_additional_policies to add custom policies.

################################################################################
# Trust Policy
################################################################################

data "aws_iam_policy_document" "assume_role" {
  count = local.create ? 1 : 0

  # Bedrock AgentCore service principal
  statement {
    sid     = "AllowBedrockAgentCoreAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account_id]
    }
  }

  # Additional service principals
  dynamic "statement" {
    for_each = length(var.trusted_services) > 0 ? [1] : []
    content {
      sid     = "AllowAdditionalServicesAssumeRole"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = var.trusted_services
      }
    }
  }

  # Cross-account role assumption
  dynamic "statement" {
    for_each = length(var.trusted_role_arns) > 0 ? [1] : []
    content {
      sid     = "AllowCrossAccountAssumeRole"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = var.trusted_role_arns
      }
    }
  }
}

################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "this" {
  count = local.create ? 1 : 0

  name                  = local.role_name
  name_prefix           = local.role_name_prefix
  path                  = var.role_path
  description           = var.role_description
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = local.merged_tags
}

################################################################################
# ECR Pull Policy
################################################################################

resource "aws_iam_role_policy" "ecr_pull" {
  count = local.create && length(local.all_ecr_repository_arns) > 0 ? 1 : 0

  name = "${aws_iam_role.this[0].name}-ecr-pull"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GetAuthorizationToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "PullRepositoryImage"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = local.all_ecr_repository_arns
      }
    ]
  })
}

################################################################################
# CloudWatch Logs Policy (Mandatory for AgentCore)
################################################################################

resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = local.create ? 1 : 0

  name = "${aws_iam_role.this[0].name}-agentcore-logs"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AgentCoreLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = local.agentcore_logs_arns
      }
    ]
  })
}

################################################################################
# Bedrock Model Access Policy
# Only attached when enable_bedrock_model_access is true.
# Enable this if your agent invokes Bedrock foundation models (Claude, Titan, etc.)
# Disable (default) if using external AI providers (OpenAI, Google, Anthropic API)
################################################################################

resource "aws_iam_role_policy" "bedrock_invoke" {
  count = local.create && var.enable_bedrock_model_access ? 1 : 0

  name = "${aws_iam_role.this[0].name}-bedrock-invoke"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeBedrockModels"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Converse",
          "bedrock:ConverseStream"
        ]
        Resource = local.bedrock_model_resources
      }
    ]
  })
}

################################################################################
# Secrets Manager Policy
################################################################################

resource "aws_iam_role_policy" "secrets" {
  count = local.create && length(var.secret_arns) > 0 ? 1 : 0

  name = "${aws_iam_role.this[0].name}-secrets"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadRuntimeSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secret_arns
      }
    ]
  })
}

################################################################################
# SSM Parameter Store Policy
################################################################################

resource "aws_iam_role_policy" "ssm" {
  count = local.create && length(var.ssm_parameter_arns) > 0 ? 1 : 0

  name = "${aws_iam_role.this[0].name}-ssm"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSSMParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = var.ssm_parameter_arns
      }
    ]
  })
}

################################################################################
# Custom Inline Policy
# Use this for any additional AWS service permissions (S3, DynamoDB, SQS, SNS,
# Lambda, X-Ray, etc.)
################################################################################

data "aws_iam_policy_document" "custom" {
  count = local.create && length(var.inline_policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.inline_policy_statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "custom" {
  count = local.create && length(var.inline_policy_statements) > 0 ? 1 : 0

  name   = "${aws_iam_role.this[0].name}-custom"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.custom[0].json
}

################################################################################
# Managed Policy Attachments
# Use this to attach AWS managed policies or your own managed policies
################################################################################

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = local.create ? toset(var.iam_additional_policies) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
