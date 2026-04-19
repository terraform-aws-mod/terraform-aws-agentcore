# Purpose: Declare all root module inputs, defaults, and validation rules.

################################################################################
# Required Variables
################################################################################

variable "agent_runtime_name" {
  description = "Name of the Bedrock AgentCore runtime. Must start with a letter and contain only letters, numbers, and underscores (max 48 chars)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.agent_runtime_name))
    error_message = "agent_runtime_name must start with a letter, contain only letters, numbers, and underscores, and be 1-48 characters long."
  }
}

variable "container_image_uri" {
  description = "Full container image URI for the runtime artifact (typically ECR URI)."
  type        = string

  validation {
    condition     = length(trim(var.container_image_uri, " ")) > 0
    error_message = "container_image_uri must not be empty."
  }
}

################################################################################
# Network Configuration
################################################################################

variable "network_mode" {
  description = "Runtime network mode: PUBLIC or VPC."
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.network_mode)
    error_message = "network_mode must be either PUBLIC or VPC."
  }
}

variable "vpc_id" {
  description = "VPC ID used when network_mode is VPC."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs used when network_mode is VPC."
  type        = list(string)
  default     = []
}

################################################################################
# Security Group Configuration
################################################################################

variable "create_security_group" {
  description = "Whether to create a security group when network_mode is VPC."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Existing security group IDs to attach when network_mode is VPC."
  type        = list(string)
  default     = []
}

variable "security_group_name" {
  description = "Name for the created security group."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for the created security group."
  type        = string
  default     = "Security group for Bedrock AgentCore runtime"
}

variable "security_group_use_name_prefix" {
  description = "Whether to use name prefix for the security group."
  type        = bool
  default     = false
}

variable "security_group_egress_cidr_blocks" {
  description = <<-EOT
    IPv4 CIDR blocks for security group egress.
    Default is empty list (no egress allowed) for least-privilege security.
    Set to ["0.0.0.0/0"] to allow all outbound traffic if needed.
    For private VPCs, consider using VPC endpoints instead of public internet egress.
  EOT
  type        = list(string)
  default     = []
}

variable "security_group_egress_ipv6_cidr_blocks" {
  description = <<-EOT
    IPv6 CIDR blocks for security group egress.
    Default is empty list (no egress allowed) for least-privilege security.
    Set to ["::/0"] to allow all outbound IPv6 traffic if needed.
  EOT
  type        = list(string)
  default     = []
}

variable "security_group_egress_with_self" {
  description = "Allow egress traffic to the security group itself."
  type        = bool
  default     = false
}

variable "security_group_ingress_with_self" {
  description = "Allow ingress traffic from the security group itself."
  type        = bool
  default     = false
}

variable "security_group_ingress_rules" {
  description = "Additional ingress rules for the security group."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    prefix_list_ids          = optional(list(string), [])
    source_security_group_id = optional(string)
    self                     = optional(bool, false)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "Additional egress rules for the security group."
  type = list(object({
    description                   = optional(string)
    from_port                     = number
    to_port                       = number
    protocol                      = string
    cidr_blocks                   = optional(list(string), [])
    ipv6_cidr_blocks              = optional(list(string), [])
    prefix_list_ids               = optional(list(string), [])
    destination_security_group_id = optional(string)
    self                          = optional(bool, false)
  }))
  default = []
}

################################################################################
# ECR Repository Configuration
################################################################################

variable "create_ecr_repository" {
  description = "Whether to create an ECR repository."
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name for the ECR repository. Defaults to agent_runtime_name when null."
  type        = string
  default     = null
}

variable "ecr_force_delete" {
  description = "Delete ECR repository even if it contains images."
  type        = bool
  default     = false
}

################################################################################
# ECR Image Scanning Configuration
################################################################################

variable "ecr_image_scanning_configuration" {
  description = "Configuration block for ECR image scanning. Set to null to disable scanning configuration."
  type = object({
    scan_on_push = optional(bool, true)
  })
  default = {
    scan_on_push = true
  }
}

variable "ecr_scan_on_push" {
  description = "Deprecated: Use ecr_image_scanning_configuration instead. Enable image scanning on push."
  type        = bool
  default     = null
}

variable "ecr_scan_type" {
  description = "ECR image scanning type: BASIC or ENHANCED."
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.ecr_scan_type)
    error_message = "ecr_scan_type must be BASIC or ENHANCED."
  }
}

variable "ecr_create_lifecycle_policy" {
  description = "Whether to create an ECR lifecycle policy."
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy" {
  description = "Custom ECR lifecycle policy JSON. Uses default policy if null."
  type        = string
  default     = null
}

variable "ecr_lifecycle_policy_untagged_days" {
  description = "Days before untagged images expire (default policy)."
  type        = number
  default     = 14
}

variable "ecr_lifecycle_policy_tagged_count" {
  description = "Number of tagged images to retain (default policy)."
  type        = number
  default     = 30
}

variable "ecr_attach_execution_role_policy" {
  description = "Whether to attach the IAM execution role to the ECR repository policy for pull access."
  type        = bool
  default     = true
}

variable "ecr_repository_read_access_arns" {
  description = "IAM ARNs granted read access to the ECR repository."
  type        = list(string)
  default     = []
}

variable "ecr_repository_read_write_access_arns" {
  description = "IAM ARNs granted read/write access to the ECR repository."
  type        = list(string)
  default     = []
}

variable "ecr_repository_policy_statements" {
  description = "Additional IAM policy statements for the ECR repository."
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

################################################################################
# ECR Encryption Configuration
################################################################################

variable "ecr_encryption_configuration" {
  description = "Configuration block for ECR repository encryption. Set to null for default AES256."
  type = object({
    encryption_type = optional(string, "AES256")
    kms_key         = optional(string)
  })
  default = null
}

variable "create_ecr_kms_key" {
  description = "Whether to create a dedicated KMS key for ECR encryption."
  type        = bool
  default     = false
}

variable "ecr_kms_key_arn" {
  description = "Existing KMS key ARN for ECR encryption when create_ecr_kms_key is false."
  type        = string
  default     = null
}

variable "ecr_kms_key_deletion_window_days" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 7
}

variable "ecr_kms_key_enable_rotation" {
  description = "Enable automatic rotation for the ECR KMS key."
  type        = bool
  default     = true
}

################################################################################
# ECR Container Image Build Configuration
################################################################################

variable "ecr_build_image" {
  description = "Whether to build and push a container image to the ECR repository."
  type        = bool
  default     = false
}

variable "ecr_build_script_path" {
  description = "Path to custom build script. If null, uses the built-in build_image.sh script."
  type        = string
  default     = null
}

variable "ecr_build_script_args" {
  description = <<-EOT
    Arguments to pass to the build script as a map. Each key-value pair becomes a CLI argument.
    For the built-in script, supported keys: dockerfile, context, tags (comma-separated),
    build_args (comma-separated KEY=VALUE), platform, use_cache, provenance.
    For custom scripts, define your own argument structure.
  EOT
  type        = map(string)
  default     = {}
}

variable "ecr_build_script_interpreter" {
  description = "Interpreter for the build script (e.g., [\"/bin/bash\", \"-c\"] or [\"python3\"])."
  type        = list(string)
  default     = ["/bin/bash", "-c"]
}

variable "ecr_build_script_environment" {
  description = "Environment variables to set when running the build script."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "ecr_build_script_working_dir" {
  description = "Working directory for the build script execution."
  type        = string
  default     = null
}

variable "ecr_build_triggers" {
  description = <<-EOT
    Map of values that trigger a rebuild when changed. Common triggers:
    - dockerfile_hash: filesha256("path/to/Dockerfile")
    - source_hash: sha256 of source files
    - version: semantic version string
  EOT
  type        = map(string)
  default     = {}
}

################################################################################
# IAM Role Configuration
################################################################################

variable "create_iam_role" {
  description = "Whether to create an IAM execution role."
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN when create_iam_role is false."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name for the IAM execution role. Defaults to {agent_runtime_name}-execution."
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the IAM execution role."
  type        = string
  default     = "/"
}

variable "iam_role_description" {
  description = "Description for the IAM execution role."
  type        = string
  default     = "Execution role for AWS Bedrock AgentCore runtime"
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary policy ARN for the IAM role."
  type        = string
  default     = null
}

variable "iam_max_session_duration" {
  description = "Maximum session duration for the IAM role (seconds)."
  type        = number
  default     = 3600
}

variable "iam_trusted_role_arns" {
  description = "Additional IAM role ARNs allowed to assume this role."
  type        = list(string)
  default     = []
}

variable "iam_trusted_services" {
  description = "Additional AWS service principals allowed to assume this role."
  type        = list(string)
  default     = []
}

variable "iam_additional_policies" {
  description = "Additional managed IAM policy ARNs to attach to the runtime execution role."
  type        = list(string)
  default     = []
}

variable "iam_inline_policy_statements" {
  description = "Custom inline IAM policy statements."
  type = list(object({
    sid       = optional(string)
    effect    = string
    actions   = list(string)
    resources = list(string)
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

variable "aws_account_id" {
  description = "AWS account ID used in IAM trust policy SourceAccount condition. Defaults to current caller account when null."
  type        = string
  default     = null
}

################################################################################
# IAM Service Access Permissions
################################################################################

variable "enable_bedrock_model_access" {
  description = <<-EOT
    Whether to allow Bedrock model invocation permissions on the execution role.

    Set to true if your agent code needs to invoke Bedrock foundation models
    (e.g., Claude, Titan) using bedrock:InvokeModel, bedrock:Converse, or their streaming variants.

    Set to false (default) if:
    - Your agent uses external AI providers (OpenAI, Google, Anthropic API directly)
    - Your agent doesn't call any AI models
    - You're providing a custom IAM role with Bedrock permissions already attached

    This is disabled by default for least-privilege security.
  EOT
  type        = bool
  default     = false
}

variable "bedrock_model_arns" {
  description = "Specific Bedrock model ARNs to allow. If empty and enable_bedrock_model_access is true, allows all models."
  type        = list(string)
  default     = []
}

variable "secret_arns" {
  description = "Optional Secrets Manager ARNs that runtime sessions are allowed to read."
  type        = list(string)
  default     = []
}

variable "ssm_parameter_arns" {
  description = "SSM Parameter Store ARNs to allow reading."
  type        = list(string)
  default     = []
}

################################################################################
# Memory Configuration
################################################################################

variable "create_memory" {
  description = "Whether to create a Bedrock AgentCore memory resource."
  type        = bool
  default     = false
}

variable "memory_name" {
  description = "Name for the AgentCore memory. Defaults to agent_runtime_name when null."
  type        = string
  default     = null
}

variable "memory_description" {
  description = "Description of the AgentCore memory."
  type        = string
  default     = null
}

variable "memory_event_expiry_duration" {
  description = "Number of days after which memory events expire. Must be between 7 and 365."
  type        = number
  default     = 30

  validation {
    condition     = var.memory_event_expiry_duration >= 7 && var.memory_event_expiry_duration <= 365
    error_message = "memory_event_expiry_duration must be between 7 and 365 days."
  }
}

variable "memory_encryption_key_arn" {
  description = "Existing KMS key ARN for memory encryption. If not provided, AWS managed encryption is used."
  type        = string
  default     = null
}

variable "memory_execution_role_arn" {
  description = "ARN of the IAM role that the memory service assumes to perform operations."
  type        = string
  default     = null
}

variable "create_memory_kms_key" {
  description = "Whether to create a dedicated KMS key for memory encryption."
  type        = bool
  default     = false
}

variable "memory_kms_key_deletion_window_days" {
  description = "KMS key deletion window in days for memory encryption key."
  type        = number
  default     = 7
}

variable "memory_kms_key_enable_rotation" {
  description = "Enable automatic rotation for the memory KMS key."
  type        = bool
  default     = true
}

variable "memory_timeouts" {
  description = "Timeout configuration for memory resource operations."
  type = object({
    create = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = null
}

################################################################################
# Runtime Lifecycle Configuration
################################################################################

variable "runtime_lifecycle_configuration" {
  description = "Lifecycle configuration for the AgentCore runtime. Set to null to omit the block."
  type = object({
    idle_runtime_session_timeout = optional(number, 300)
    max_lifetime                 = optional(number, 1800)
  })
  default = {
    idle_runtime_session_timeout = 300
    max_lifetime                 = 1800
  }
}

variable "idle_session_timeout_seconds" {
  description = "Deprecated: Use runtime_lifecycle_configuration instead. Idle runtime session timeout in seconds."
  type        = number
  default     = null
}

variable "max_session_lifetime_seconds" {
  description = "Deprecated: Use runtime_lifecycle_configuration instead. Maximum runtime session lifetime in seconds."
  type        = number
  default     = null
}

################################################################################
# Runtime Protocol Configuration
################################################################################

variable "protocol" {
  description = "Server protocol type: HTTP, MCP, or A2A."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "MCP", "A2A"], var.protocol)
    error_message = "protocol must be HTTP, MCP, or A2A."
  }
}

variable "authorizer_configuration" {
  description = "Custom JWT authorizer configuration for the runtime."
  type = object({
    discovery_url    = string
    allowed_audience = optional(list(string), [])
    allowed_clients  = optional(list(string), [])
    allowed_scopes   = optional(list(string), [])
  })
  default = null
}

variable "request_header_allowlist" {
  description = "List of HTTP request headers allowed to pass through to the runtime."
  type        = list(string)
  default     = []
}

################################################################################
# Runtime Environment
################################################################################

variable "runtime_description" {
  description = "Description for the AgentCore runtime."
  type        = string
  default     = null
}

variable "runtime_environment_variables" {
  description = "Environment variables to pass to the runtime container."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "runtime_timeouts" {
  description = "Timeout configuration for runtime resource operations."
  type = object({
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags applied to all taggable resources."
  type        = map(string)
  default     = {}
}
