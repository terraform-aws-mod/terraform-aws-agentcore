module "wrapper" {
  source = "../../modules/ecr"

  for_each = var.items

  attach_execution_role_policy = try(each.value.attach_execution_role_policy, var.defaults.attach_execution_role_policy, false)
  build_image                  = try(each.value.build_image, var.defaults.build_image, false)
  build_script_args            = try(each.value.build_script_args, var.defaults.build_script_args, {})
  build_script_environment     = try(each.value.build_script_environment, var.defaults.build_script_environment, {})
  build_script_interpreter     = try(each.value.build_script_interpreter, var.defaults.build_script_interpreter, ["/bin/bash", "-c"])
  build_script_path            = try(each.value.build_script_path, var.defaults.build_script_path, null)
  build_script_working_dir     = try(each.value.build_script_working_dir, var.defaults.build_script_working_dir, null)
  build_triggers               = try(each.value.build_triggers, var.defaults.build_triggers, {})
  create                       = try(each.value.create, var.defaults.create, true)
  create_kms_key               = try(each.value.create_kms_key, var.defaults.create_kms_key, true)
  create_lifecycle_policy      = try(each.value.create_lifecycle_policy, var.defaults.create_lifecycle_policy, true)
  create_repository_policy     = try(each.value.create_repository_policy, var.defaults.create_repository_policy, false)
  encryption_configuration     = try(each.value.encryption_configuration, var.defaults.encryption_configuration, null)
  execution_role_arn           = try(each.value.execution_role_arn, var.defaults.execution_role_arn, null)
  force_delete                 = try(each.value.force_delete, var.defaults.force_delete, false)
  image_scanning_configuration = try(each.value.image_scanning_configuration, var.defaults.image_scanning_configuration, {
    scan_on_push = true
  })
  kms_key_arn                       = try(each.value.kms_key_arn, var.defaults.kms_key_arn, null)
  kms_key_deletion_window_days      = try(each.value.kms_key_deletion_window_days, var.defaults.kms_key_deletion_window_days, 7)
  kms_key_enable_rotation           = try(each.value.kms_key_enable_rotation, var.defaults.kms_key_enable_rotation, true)
  lifecycle_policy                  = try(each.value.lifecycle_policy, var.defaults.lifecycle_policy, null)
  lifecycle_policy_tagged_count     = try(each.value.lifecycle_policy_tagged_count, var.defaults.lifecycle_policy_tagged_count, 30)
  lifecycle_policy_untagged_days    = try(each.value.lifecycle_policy_untagged_days, var.defaults.lifecycle_policy_untagged_days, 14)
  repository_name                   = try(each.value.repository_name, var.defaults.repository_name)
  repository_policy_statements      = try(each.value.repository_policy_statements, var.defaults.repository_policy_statements, [])
  repository_read_access_arns       = try(each.value.repository_read_access_arns, var.defaults.repository_read_access_arns, [])
  repository_read_write_access_arns = try(each.value.repository_read_write_access_arns, var.defaults.repository_read_write_access_arns, [])
  restrict_access_to_accounts       = try(each.value.restrict_access_to_accounts, var.defaults.restrict_access_to_accounts, [])
  scan_type                         = try(each.value.scan_type, var.defaults.scan_type, "BASIC")
  tags                              = try(each.value.tags, var.defaults.tags, {})
}
