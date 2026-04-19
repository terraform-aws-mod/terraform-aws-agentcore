resource "aws_bedrockagentcore_memory" "this" {
  count = local.create ? 1 : 0

  name                      = var.memory_name
  description               = var.description
  event_expiry_duration     = var.event_expiry_duration
  encryption_key_arn        = var.create_kms_key ? aws_kms_key.this[0].arn : var.encryption_key_arn
  memory_execution_role_arn = var.memory_execution_role_arn

  tags = local.merged_tags

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = try(timeouts.value.create, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }
}

################################################################################
# KMS Key (optional)
################################################################################

data "aws_caller_identity" "kms" {
  count = local.create && var.create_kms_key ? 1 : 0
}

resource "aws_kms_key" "this" {
  #checkov:skip=CKV_AWS_7:Rotation enabled via variable with default true
  count = local.create && var.create_kms_key ? 1 : 0

  description             = "KMS key for Bedrock AgentCore Memory: ${var.memory_name}"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = var.kms_key_enable_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "memory-kms-key-policy"
    Statement = [
      {
        Sid    = "AllowRootAccountFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.kms_account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowBedrockServiceUse"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
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
            "kms:CallerAccount" = local.kms_account_id
          }
        }
      }
    ]
  })

  tags = local.merged_tags
}

resource "aws_kms_alias" "this" {
  count = local.create && var.create_kms_key ? 1 : 0

  name          = "alias/agentcore-memory-${var.memory_name}"
  target_key_id = aws_kms_key.this[0].key_id
}
