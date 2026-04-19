variable "create" {
  description = "Whether to create the memory resource."
  type        = bool
  default     = true
}

variable "memory_name" {
  description = "Name of the Bedrock AgentCore memory."
  type        = string
}

variable "description" {
  description = "Description of the memory."
  type        = string
  default     = null
}

variable "event_expiry_duration" {
  description = "Number of days after which memory events expire. Must be between 7 and 365."
  type        = number

  validation {
    condition     = var.event_expiry_duration >= 7 && var.event_expiry_duration <= 365
    error_message = "event_expiry_duration must be between 7 and 365 days."
  }
}

variable "encryption_key_arn" {
  description = "ARN of the KMS key used to encrypt the memory. If not provided, AWS managed encryption is used."
  type        = string
  default     = null
}

variable "memory_execution_role_arn" {
  description = "ARN of the IAM role that the memory service assumes to perform operations."
  type        = string
  default     = null
}

################################################################################
# KMS Key Configuration
################################################################################

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for memory encryption."
  type        = bool
  default     = false
}

variable "kms_key_deletion_window_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 7
}

variable "kms_key_enable_rotation" {
  description = "Enable automatic rotation for the KMS key."
  type        = bool
  default     = true
}

################################################################################
# Timeouts
################################################################################

variable "timeouts" {
  description = "Timeout configuration for memory resource operations."
  type = object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags applied to memory resources."
  type        = map(string)
  default     = {}
}
