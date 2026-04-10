# Purpose: Define inputs for IAM execution role and policy configuration.
#
# This module provides minimal IAM permissions for AgentCore:
# - ECR pull (if repository ARN provided)
# - CloudWatch Logs (mandatory for AgentCore)
# - Bedrock model invocation (optional)
# - Secrets Manager (optional)
# - SSM Parameter Store (optional)
#
# For additional permissions (S3, DynamoDB, SQS, SNS, Lambda, X-Ray, etc.),
# use inline_policy_statements or iam_additional_policies.

################################################################################
# Role Configuration
################################################################################

variable "create" {
  description = "Whether to create IAM resources."
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name for the AgentCore execution IAM role."
  type        = string
  default     = null
}

variable "role_name_prefix" {
  description = "Prefix for the IAM role name. Mutually exclusive with role_name."
  type        = string
  default     = null
}

variable "use_role_name_prefix" {
  description = "Whether to use role_name_prefix instead of role_name."
  type        = bool
  default     = false
}

variable "role_path" {
  description = "Path for the IAM role."
  type        = string
  default     = "/"
}

variable "role_description" {
  description = "Description of the IAM role."
  type        = string
  default     = "Execution role for AWS Bedrock AgentCore runtime"
}

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy to attach to the role."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the IAM role."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "force_detach_policies" {
  description = "Whether to force detach policies before destroying the role."
  type        = bool
  default     = true
}

################################################################################
# Trust Policy Configuration
################################################################################

variable "aws_account_id" {
  description = "AWS account ID used in trust policy SourceAccount condition."
  type        = string
}

variable "trusted_role_arns" {
  description = "Additional IAM role ARNs allowed to assume this role."
  type        = list(string)
  default     = []
}

variable "trusted_services" {
  description = "Additional AWS service principals allowed to assume this role."
  type        = list(string)
  default     = []
}

################################################################################
# ECR Permissions
################################################################################

variable "ecr_repository_arn" {
  description = "ECR repository ARN to scope image pull permissions."
  type        = string
  default     = null
}

variable "ecr_repository_arns" {
  description = "List of ECR repository ARNs for image pull permissions."
  type        = list(string)
  default     = []
}

################################################################################
# Bedrock Model Access
################################################################################

variable "enable_bedrock_model_access" {
  description = <<-EOT
    Whether to include Bedrock model invocation permissions.
    
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
  description = "List of Bedrock model ARNs to allow access. If empty and enable_bedrock_model_access is true, allows all models."
  type        = list(string)
  default     = []
}

################################################################################
# Secrets Manager Permissions
################################################################################

variable "secret_arns" {
  description = "Optional Secrets Manager secret ARNs allowed for retrieval."
  type        = list(string)
  default     = []
}

################################################################################
# SSM Parameter Store Permissions
################################################################################

variable "ssm_parameter_arns" {
  description = "SSM Parameter Store ARNs to allow reading."
  type        = list(string)
  default     = []
}

################################################################################
# Custom Policies
# Use these for additional AWS service permissions (S3, DynamoDB, SQS, SNS,
# Lambda, X-Ray, etc.)
################################################################################

variable "inline_policy_statements" {
  description = <<-EOT
    Custom inline IAM policy statements to add to the role.
    Use this for any additional AWS service permissions your agent needs.
    
    Example for S3 access:
    inline_policy_statements = [
      {
        sid       = "S3Access"
        effect    = "Allow"
        actions   = ["s3:GetObject", "s3:PutObject"]
        resources = ["arn:aws:s3:::my-bucket/*"]
      }
    ]
  EOT
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

variable "iam_additional_policies" {
  description = <<-EOT
    Additional managed policy ARNs to attach to the role.
    Use this to attach AWS managed policies or your own managed policies.
    
    Example:
    iam_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      "arn:aws:iam::123456789012:policy/my-custom-policy"
    ]
  EOT
  type        = list(string)
  default     = []
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags applied to IAM role resources that support tags."
  type        = map(string)
  default     = {}
}
