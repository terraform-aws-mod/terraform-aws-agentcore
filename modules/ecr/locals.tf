# Purpose: Compute local values for ECR settings and tagging.

locals {
  create = var.create

  default_tags = {
    Name      = var.repository_name
    ManagedBy = "terraform"
  }

  merged_tags = merge(var.tags, local.default_tags)

  # Determine effective encryption type - KMS by default for security best practices
  effective_encryption_type = var.create_kms_key || var.kms_key_arn != null || (
    var.encryption_configuration != null && var.encryption_configuration.encryption_type == "KMS"
  ) ? "KMS" : (var.encryption_configuration != null ? var.encryption_configuration.encryption_type : "KMS")

  effective_kms_key_arn = var.create_kms_key ? try(aws_kms_key.this[0].arn, null) : try(
    coalesce(var.kms_key_arn, try(var.encryption_configuration.kms_key, null)),
    null
  )

  # Computed encryption configuration for dynamic block
  encryption_configuration = local.effective_encryption_type == "KMS" ? {
    encryption_type = "KMS"
    kms_key         = local.effective_kms_key_arn
    } : var.encryption_configuration != null ? var.encryption_configuration : {
    encryption_type = "AES256"
    kms_key         = null
  }

  # Default lifecycle policy
  default_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.lifecycle_policy_untagged_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.lifecycle_policy_untagged_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last ${var.lifecycle_policy_tagged_count} tagged images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.lifecycle_policy_tagged_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  effective_lifecycle_policy = var.lifecycle_policy != null ? var.lifecycle_policy : local.default_lifecycle_policy

  # Determine if we need a repository policy based on static/known boolean values only
  # This avoids count dependency on values not known until apply
  create_repository_policy = var.create_repository_policy || (
    var.attach_execution_role_policy ||
    length(var.repository_read_access_arns) > 0 ||
    length(var.repository_read_write_access_arns) > 0 ||
    length(var.repository_policy_statements) > 0
  )

  # Combine all read access ARNs (used at apply time, not for count)
  all_read_access_arns = compact(concat(
    var.attach_execution_role_policy && var.execution_role_arn != null ? [var.execution_role_arn] : [],
    var.repository_read_access_arns
  ))

  # Build and push configuration
  build_image = var.build_image

  # Determine the effective script path (custom or built-in)
  effective_build_script = var.build_script_path != null ? var.build_script_path : "${path.module}/build_image.sh"

  # For the built-in script, inject AWS account and region automatically
  builtin_script_base_args = var.build_script_path == null ? {
    account  = try(data.aws_caller_identity.current[0].account_id, "")
    region   = try(data.aws_region.current[0].id, "")
    ecr-name = var.repository_name
  } : {}

  # Merge base args with user-provided args (user args take precedence)
  effective_build_args = merge(local.builtin_script_base_args, var.build_script_args)

  # Build final CLI string
  build_command_args = join(" ", [
    for k, v in local.effective_build_args : "--${replace(k, "_", "-")} \"${v}\""
  ])

  # Default image tag for output
  default_image_tag = lookup(var.build_script_args, "tags", "latest")
  first_image_tag   = split(",", local.default_image_tag)[0]
}
