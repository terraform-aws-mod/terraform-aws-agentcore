# Purpose: Inputs for the VPC networking example.

variable "aws_region" {
  description = "AWS region for deploying the example."
  type        = string
  default     = "us-east-1"
}

variable "agent_runtime_name" {
  description = "Name for the AgentCore runtime."
  type        = string
  default     = "pv_vpc_agent_name"
}

variable "container_image_uri" {
  description = "Full container image URI for AgentCore runtime."
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:2023"
}

variable "vpc_id" {
  description = "VPC ID where the runtime executes. Uses default VPC if null."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for runtime VPC mode. Auto-discovers if empty."
  type        = list(string)
  default     = []
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the runtime can access."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
