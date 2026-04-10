# Purpose: Create an ECR repository with lifecycle policy, optional KMS encryption,
# pull access policy, and optional Docker image build/push capability.

################################################################################
# Data Sources
################################################################################

data "aws_caller_identity" "current" {
  count = local.create && local.build_image ? 1 : 0
}

data "aws_region" "current" {
  count = local.create && local.build_image ? 1 : 0
}

################################################################################
# KMS Key
################################################################################

data "aws_caller_identity" "kms" {
  count = local.create && var.create_kms_key ? 1 : 0
}

resource "aws_kms_key" "this" {
  count = local.create && var.create_kms_key ? 1 : 0

  description             = "KMS key for ECR repository ${var.repository_name}"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = var.kms_key_enable_rotation

  # Least-privilege key policy
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "ecr-kms-key-policy"
    Statement = [
      {
        Sid    = "AllowRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.kms[0].account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowECRServiceUse"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = data.aws_caller_identity.kms[0].account_id
          }
        }
      },
      {
        Sid    = "AllowImagePullDecrypt"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = data.aws_caller_identity.kms[0].account_id
          }
          StringLike = {
            "kms:ViaService" = "ecr.*.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.merged_tags
}

resource "aws_kms_alias" "this" {
  count = local.create && var.create_kms_key ? 1 : 0

  name          = "alias/ecr/${var.repository_name}"
  target_key_id = aws_kms_key.this[0].key_id
}

################################################################################
# Repository
################################################################################

resource "aws_ecr_repository" "this" {
  count = local.create ? 1 : 0

  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.image_scanning_configuration != null ? var.image_scanning_configuration.scan_on_push : true
  }

  encryption_configuration {
    encryption_type = local.encryption_configuration != null ? local.encryption_configuration.encryption_type : "KMS"
    kms_key         = local.encryption_configuration != null && local.encryption_configuration.encryption_type == "KMS" ? local.encryption_configuration.kms_key : (var.create_kms_key ? aws_kms_key.this[0].arn : null)
  }

  tags = local.merged_tags
}

################################################################################
# Registry Scanning Configuration (for ENHANCED scanning)
################################################################################

resource "aws_ecr_registry_scanning_configuration" "this" {
  count = local.create && var.scan_type == "ENHANCED" && var.image_scanning_configuration != null ? 1 : 0

  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"

    repository_filter {
      filter      = var.repository_name
      filter_type = "WILDCARD"
    }
  }
}

################################################################################
# Lifecycle Policy
################################################################################

resource "aws_ecr_lifecycle_policy" "this" {
  count = local.create && var.create_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = local.effective_lifecycle_policy
}

################################################################################
# Repository Policy
################################################################################

data "aws_iam_policy_document" "repository" {
  count = local.create && local.create_repository_policy ? 1 : 0

  # Read-only access for execution role and read access ARNs (with account condition)
  dynamic "statement" {
    for_each = length(local.all_read_access_arns) > 0 ? [1] : []
    content {
      sid    = "AllowPullAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.all_read_access_arns
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]

      # Condition to restrict by caller account for defense in depth
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalAccount"
        values   = var.restrict_access_to_accounts
      }
    }
  }

  # Read-only access without account restriction when no account restriction specified
  dynamic "statement" {
    for_each = length(local.all_read_access_arns) > 0 && length(var.restrict_access_to_accounts) == 0 ? [1] : []
    content {
      sid    = "AllowPullAccessUnrestricted"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.all_read_access_arns
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  }

  # Read/write access
  dynamic "statement" {
    for_each = length(var.repository_read_write_access_arns) > 0 ? [1] : []
    content {
      sid    = "AllowPushPullAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.repository_read_write_access_arns
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }
  }

  # Additional custom statements
  dynamic "statement" {
    for_each = var.repository_policy_statements
    content {
      sid    = statement.value.sid
      effect = statement.value.effect

      dynamic "principals" {
        for_each = statement.value.principals
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      actions = statement.value.actions

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

resource "aws_ecr_repository_policy" "this" {
  count = local.create && local.create_repository_policy ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = data.aws_iam_policy_document.repository[0].json
}

################################################################################
# Container Image Build and Push
################################################################################

resource "terraform_data" "build_and_push_image" {
  count = local.create && local.build_image ? 1 : 0

  triggers_replace = var.build_triggers

  provisioner "local-exec" {
    command     = "${local.effective_build_script} ${local.build_command_args}"
    interpreter = var.build_script_interpreter
    working_dir = var.build_script_working_dir
    environment = var.build_script_environment
  }

  depends_on = [aws_ecr_repository.this]
}
