# Purpose: Inputs for the basic public networking example.

variable "aws_region" {
  description = "AWS region for deploying the example."
  type        = string
  default     = "us-east-1"
}

variable "agent_runtime_name" {
  description = "Name for the AgentCore runtime."
  type        = string
  default     = "basic-agentcore-example"
}

variable "container_image_uri" {
  description = "Full container image URI for AgentCore runtime. Use a placeholder if testing IAM/ECR only."
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:2023"
}
