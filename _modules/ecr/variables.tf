# Purpose: Define inputs for ECR repository provisioning.

################################################################################
# Repository Configuration
################################################################################

variable "create" {
  description = "Whether to create ECR resources."
  type        = bool
  default     = true
}

variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "force_delete" {
  description = "Delete repository even if it contains images."
  type        = bool
  default     = false
}

################################################################################
# Image Scanning Configuration
################################################################################

variable "image_scanning_configuration" {
  description = "Configuration block for image scanning. Set to null to disable scanning configuration block entirely."
  type = object({
    scan_on_push = optional(bool, true)
  })
  default = {
    scan_on_push = true
  }
}

variable "scan_type" {
  description = "Image scanning type: BASIC or ENHANCED. Only applies when image_scanning_configuration is set."
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.scan_type)
    error_message = "scan_type must be BASIC or ENHANCED."
  }
}

################################################################################
# Lifecycle Policy Configuration
################################################################################

variable "create_lifecycle_policy" {
  description = "Whether to create a lifecycle policy."
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "Custom lifecycle policy JSON. If null, uses default policy."
  type        = string
  default     = null
}

variable "lifecycle_policy_untagged_days" {
  description = "Days before untagged images expire (used in default policy)."
  type        = number
  default     = 14
}

variable "lifecycle_policy_tagged_count" {
  description = "Number of tagged images to retain (used in default policy)."
  type        = number
  default     = 30
}

################################################################################
# Encryption Configuration
################################################################################

variable "encryption_configuration" {
  description = "Configuration block for repository encryption. Set to null to use default AES256. Supports KMS encryption with optional key creation."
  type = object({
    encryption_type = optional(string, "AES256")
    kms_key         = optional(string)
  })
  default = null
}

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for repository encryption. Defaults to true for security best practices."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN to use when create_kms_key is false. Deprecated: use encryption_configuration.kms_key instead."
  type        = string
  default     = null
}

variable "kms_key_deletion_window_days" {
  description = "Duration in days before KMS key is deleted after destruction."
  type        = number
  default     = 7

  validation {
    condition     = var.kms_key_deletion_window_days >= 7 && var.kms_key_deletion_window_days <= 30
    error_message = "kms_key_deletion_window_days must be between 7 and 30."
  }
}

variable "kms_key_enable_rotation" {
  description = "Enable automatic rotation for the KMS key."
  type        = bool
  default     = true
}

################################################################################
# Repository Policy Configuration
################################################################################

variable "create_repository_policy" {
  description = "Whether to create a repository policy. Set to true and provide access ARNs, or set to false to skip policy creation."
  type        = bool
  default     = false
}

variable "attach_execution_role_policy" {
  description = "Whether to attach execution role read access to the repository policy. When true, execution_role_arn must be provided."
  type        = bool
  default     = false
}

variable "execution_role_arn" {
  description = "Execution role ARN allowed to pull images from this repository."
  type        = string
  default     = null
}

variable "repository_policy_statements" {
  description = "Additional IAM policy statements for the repository policy."
  type = list(object({
    sid    = optional(string)
    effect = string
    principals = list(object({
      type        = string
      identifiers = list(string)
    }))
    actions = list(string)
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "repository_read_access_arns" {
  description = "List of IAM ARNs granted read access to the repository."
  type        = list(string)
  default     = []
}

variable "repository_read_write_access_arns" {
  description = "List of IAM ARNs granted read/write access to the repository."
  type        = list(string)
  default     = []
}

variable "restrict_access_to_accounts" {
  description = "List of AWS account IDs to restrict repository access to. Used as a condition for pull access."
  type        = list(string)
  default     = []
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags applied to ECR resources."
  type        = map(string)
  default     = {}
}

################################################################################
# Container Image Build Configuration
################################################################################

variable "build_image" {
  description = "Whether to build and push a container image to the repository."
  type        = bool
  default     = false
}

variable "build_script_path" {
  description = "Path to custom build script. If null, uses the built-in build_image.sh script."
  type        = string
  default     = null
}

variable "build_script_args" {
  description = <<-EOT
    Arguments to pass to the build script as a map. Each key-value pair becomes a CLI argument.
    For the built-in script, supported keys: dockerfile, context, tags (comma-separated), 
    build_args (comma-separated KEY=VALUE), platform, use_cache, provenance.
    For custom scripts, define your own argument structure.
  EOT
  type        = map(string)
  default     = {}
}

variable "build_script_interpreter" {
  description = "Interpreter for the build script (e.g., [\"/bin/bash\", \"-c\"] or [\"python3\"])."
  type        = list(string)
  default     = ["/bin/bash", "-c"]
}

variable "build_script_environment" {
  description = "Environment variables to set when running the build script."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "build_script_working_dir" {
  description = "Working directory for the build script execution."
  type        = string
  default     = null
}

variable "build_triggers" {
  description = <<-EOT
    Map of values that trigger a rebuild when changed. Common triggers:
    - dockerfile_hash: filesha256("path/to/Dockerfile")
    - source_hash: sha256 of source files
    - version: semantic version string
    - custom: any string value
  EOT
  type        = map(string)
  default     = {}
}
