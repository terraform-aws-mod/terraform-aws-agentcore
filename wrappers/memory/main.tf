module "wrapper" {
  source = "../../modules/memory"

  for_each = var.items

  create                       = try(each.value.create, var.defaults.create, true)
  create_kms_key               = try(each.value.create_kms_key, var.defaults.create_kms_key, false)
  description                  = try(each.value.description, var.defaults.description, null)
  encryption_key_arn           = try(each.value.encryption_key_arn, var.defaults.encryption_key_arn, null)
  event_expiry_duration        = try(each.value.event_expiry_duration, var.defaults.event_expiry_duration)
  kms_key_deletion_window_days = try(each.value.kms_key_deletion_window_days, var.defaults.kms_key_deletion_window_days, 7)
  kms_key_enable_rotation      = try(each.value.kms_key_enable_rotation, var.defaults.kms_key_enable_rotation, true)
  memory_execution_role_arn    = try(each.value.memory_execution_role_arn, var.defaults.memory_execution_role_arn, null)
  memory_name                  = try(each.value.memory_name, var.defaults.memory_name)
  tags                         = try(each.value.tags, var.defaults.tags, {})
  timeouts                     = try(each.value.timeouts, var.defaults.timeouts, null)
}
