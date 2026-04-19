module "wrapper" {
  source = "../../modules/iam"

  for_each = var.items

  agent_runtime_name          = try(each.value.agent_runtime_name, var.defaults.agent_runtime_name)
  aws_account_id              = try(each.value.aws_account_id, var.defaults.aws_account_id)
  bedrock_model_arns          = try(each.value.bedrock_model_arns, var.defaults.bedrock_model_arns, [])
  create                      = try(each.value.create, var.defaults.create, true)
  ecr_repository_arn          = try(each.value.ecr_repository_arn, var.defaults.ecr_repository_arn, null)
  ecr_repository_arns         = try(each.value.ecr_repository_arns, var.defaults.ecr_repository_arns, [])
  enable_bedrock_model_access = try(each.value.enable_bedrock_model_access, var.defaults.enable_bedrock_model_access, false)
  force_detach_policies       = try(each.value.force_detach_policies, var.defaults.force_detach_policies, true)
  iam_additional_policies     = try(each.value.iam_additional_policies, var.defaults.iam_additional_policies, [])
  inline_policy_statements    = try(each.value.inline_policy_statements, var.defaults.inline_policy_statements, [])
  max_session_duration        = try(each.value.max_session_duration, var.defaults.max_session_duration, 3600)
  permissions_boundary_arn    = try(each.value.permissions_boundary_arn, var.defaults.permissions_boundary_arn, null)
  role_description            = try(each.value.role_description, var.defaults.role_description, "Execution role for AWS Bedrock AgentCore runtime")
  role_name                   = try(each.value.role_name, var.defaults.role_name, null)
  role_name_prefix            = try(each.value.role_name_prefix, var.defaults.role_name_prefix, null)
  role_path                   = try(each.value.role_path, var.defaults.role_path, "/")
  secret_arns                 = try(each.value.secret_arns, var.defaults.secret_arns, [])
  ssm_parameter_arns          = try(each.value.ssm_parameter_arns, var.defaults.ssm_parameter_arns, [])
  tags                        = try(each.value.tags, var.defaults.tags, {})
  trusted_role_arns           = try(each.value.trusted_role_arns, var.defaults.trusted_role_arns, [])
  trusted_services            = try(each.value.trusted_services, var.defaults.trusted_services, [])
  use_role_name_prefix        = try(each.value.use_role_name_prefix, var.defaults.use_role_name_prefix, false)
}
