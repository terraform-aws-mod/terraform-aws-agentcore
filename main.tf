# Purpose: Orchestrate all submodules to provision AgentCore runtime infrastructure.

################################################################################
# IAM Module
################################################################################

module "iam" {
  source = "./modules/iam"
  count  = var.create_iam_role ? 1 : 0

  create                      = true
  agent_runtime_name          = var.agent_runtime_name
  role_name                   = coalesce(var.iam_role_name, "${var.agent_runtime_name}-execution")
  role_path                   = var.iam_role_path
  role_description            = var.iam_role_description
  permissions_boundary_arn    = var.iam_permissions_boundary_arn
  max_session_duration        = var.iam_max_session_duration
  aws_account_id              = local.effective_aws_account_id
  trusted_role_arns           = var.iam_trusted_role_arns
  trusted_services            = var.iam_trusted_services
  ecr_repository_arn          = local.effective_ecr_repository_arn
  enable_bedrock_model_access = var.enable_bedrock_model_access
  bedrock_model_arns          = var.bedrock_model_arns
  secret_arns                 = var.secret_arns
  ssm_parameter_arns          = var.ssm_parameter_arns
  inline_policy_statements    = var.iam_inline_policy_statements
  iam_additional_policies     = var.iam_additional_policies
  tags                        = local.merged_tags
}

################################################################################
# ECR Module
################################################################################

module "ecr" {
  source = "./modules/ecr"
  count  = var.create_ecr_repository ? 1 : 0

  create                            = true
  repository_name                   = local.effective_ecr_repository_name
  force_delete                      = var.ecr_force_delete
  image_scanning_configuration      = local.effective_image_scanning_configuration
  scan_type                         = var.ecr_scan_type
  create_lifecycle_policy           = var.ecr_create_lifecycle_policy
  lifecycle_policy                  = var.ecr_lifecycle_policy
  lifecycle_policy_untagged_days    = var.ecr_lifecycle_policy_untagged_days
  lifecycle_policy_tagged_count     = var.ecr_lifecycle_policy_tagged_count
  encryption_configuration          = var.ecr_encryption_configuration
  create_kms_key                    = var.create_ecr_kms_key
  kms_key_arn                       = var.ecr_kms_key_arn
  kms_key_deletion_window_days      = var.ecr_kms_key_deletion_window_days
  kms_key_enable_rotation           = var.ecr_kms_key_enable_rotation
  attach_execution_role_policy      = var.ecr_attach_execution_role_policy && var.create_iam_role
  execution_role_arn                = local.effective_iam_role_arn
  repository_read_access_arns       = var.ecr_repository_read_access_arns
  repository_read_write_access_arns = var.ecr_repository_read_write_access_arns
  repository_policy_statements      = var.ecr_repository_policy_statements
  build_image                       = var.ecr_build_image
  build_script_path                 = var.ecr_build_script_path
  build_script_args                 = var.ecr_build_script_args
  build_script_interpreter          = var.ecr_build_script_interpreter
  build_script_environment          = var.ecr_build_script_environment
  build_script_working_dir          = var.ecr_build_script_working_dir
  build_triggers                    = var.ecr_build_triggers
  tags                              = local.merged_tags
}

################################################################################
# Security Group Module
################################################################################

module "security_group" {
  source = "./modules/security_group"
  count  = local.create_security_group_effective ? 1 : 0

  create                   = true
  security_group_name      = coalesce(var.security_group_name, "${var.agent_runtime_name}-agentcore")
  use_name_prefix          = var.security_group_use_name_prefix
  description              = var.security_group_description
  vpc_id                   = var.vpc_id
  egress_cidr_blocks       = var.security_group_egress_cidr_blocks
  egress_ipv6_cidr_blocks  = var.security_group_egress_ipv6_cidr_blocks
  egress_with_self         = var.security_group_egress_with_self
  ingress_with_self        = var.security_group_ingress_with_self
  additional_ingress_rules = var.security_group_ingress_rules
  additional_egress_rules  = var.security_group_egress_rules
  tags                     = local.merged_tags
}

################################################################################
# Memory Module
################################################################################

module "memory" {
  source = "./modules/memory"
  count  = var.create_memory ? 1 : 0

  create                       = true
  memory_name                  = coalesce(var.memory_name, var.agent_runtime_name)
  description                  = var.memory_description
  event_expiry_duration        = var.memory_event_expiry_duration
  encryption_key_arn           = var.memory_encryption_key_arn
  memory_execution_role_arn    = var.memory_execution_role_arn
  create_kms_key               = var.create_memory_kms_key
  kms_key_deletion_window_days = var.memory_kms_key_deletion_window_days
  kms_key_enable_rotation      = var.memory_kms_key_enable_rotation
  timeouts                     = var.memory_timeouts
  tags                         = local.merged_tags
}

################################################################################
# AgentCore Runtime Resource
################################################################################

resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = var.agent_runtime_name
  description        = var.runtime_description
  role_arn           = local.effective_iam_role_arn

  lifecycle {
    precondition {
      condition     = var.create_iam_role || (var.iam_role_arn != null && length(trim(var.iam_role_arn, " ")) > 0)
      error_message = "iam_role_arn must be provided when create_iam_role is false."
    }
  }

  agent_runtime_artifact {
    container_configuration {
      container_uri = var.container_image_uri
    }
  }

  network_configuration {
    network_mode = var.network_mode

    dynamic "network_mode_config" {
      for_each = var.network_mode == "VPC" ? [1] : []
      content {
        security_groups = local.effective_security_group_ids
        subnets         = var.subnet_ids
      }
    }
  }

  dynamic "lifecycle_configuration" {
    for_each = local.effective_lifecycle_configuration != null ? [local.effective_lifecycle_configuration] : []

    content {
      idle_runtime_session_timeout = lifecycle_configuration.value.idle_runtime_session_timeout
      max_lifetime                 = lifecycle_configuration.value.max_lifetime
    }
  }

  dynamic "protocol_configuration" {
    for_each = var.protocol != null ? [var.protocol] : []

    content {
      server_protocol = protocol_configuration.value
    }
  }

  dynamic "authorizer_configuration" {
    for_each = var.authorizer_configuration != null ? [var.authorizer_configuration] : []

    content {
      custom_jwt_authorizer {
        discovery_url    = authorizer_configuration.value.discovery_url
        allowed_audience = length(authorizer_configuration.value.allowed_audience) > 0 ? authorizer_configuration.value.allowed_audience : null
        allowed_clients  = length(authorizer_configuration.value.allowed_clients) > 0 ? authorizer_configuration.value.allowed_clients : null
        allowed_scopes   = length(authorizer_configuration.value.allowed_scopes) > 0 ? authorizer_configuration.value.allowed_scopes : null
      }
    }
  }

  dynamic "request_header_configuration" {
    for_each = length(var.request_header_allowlist) > 0 ? [var.request_header_allowlist] : []

    content {
      request_header_allowlist = request_header_configuration.value
    }
  }

  environment_variables = length(var.runtime_environment_variables) > 0 ? var.runtime_environment_variables : null

  tags = local.merged_tags

  dynamic "timeouts" {
    for_each = var.runtime_timeouts != null ? [var.runtime_timeouts] : []

    content {
      create = try(timeouts.value.create, "30m")
      update = try(timeouts.value.update, "30m")
      delete = try(timeouts.value.delete, "30m")
    }
  }

  depends_on = [module.ecr]
}
