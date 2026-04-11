# Variables for Strands Agent deployment

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "agent_name" {
  description = "Name for the AgentCore runtime."
  type        = string
  default     = "strands_agent_example"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.agent_name))
    error_message = "agent_name must start with a letter, contain only letters, numbers, and underscores, max 48 chars."
  }
}

variable "image_tag" {
  description = "Docker image tag."
  type        = string
  default     = "latest"
}

variable "network_mode" {
  description = "Network mode: PUBLIC or VPC."
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.network_mode)
    error_message = "network_mode must be PUBLIC or VPC."
  }
}

variable "vpc_id" {
  description = "VPC ID (required when network_mode is VPC)."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs (required when network_mode is VPC)."
  type        = list(string)
  default     = []
}

variable "bedrock_model_id" {
  description = "Bedrock model ID for the agent."
  type        = string
  default     = "us.anthropic.claude-sonnet-4-20250514-v1:0"
}

variable "bedrock_model_arns" {
  description = "Specific Bedrock model ARNs to allow. Empty allows all models."
  type        = list(string)
  default     = []
}

variable "idle_session_timeout" {
  description = "Idle session timeout in seconds."
  type        = number
  default     = 300
}

variable "max_session_lifetime" {
  description = "Maximum session lifetime in seconds."
  type        = number
  default     = 1800
}

variable "log_level" {
  description = "Application log level."
  type        = string
  default     = "INFO"
}

variable "ecr_force_delete" {
  description = "Allow ECR repository deletion with images."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources."
  type        = map(string)
  default     = {}
}
