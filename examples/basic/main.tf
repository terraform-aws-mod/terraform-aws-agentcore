# Purpose: Demonstrate minimal module usage in PUBLIC network mode.

################################################################################
# Provider Configuration
################################################################################

provider "aws" {
  region = var.aws_region
}

################################################################################
# AgentCore Module - Basic Public Mode
################################################################################

module "agentcore" {
  source = "../../"

  # Required - Runtime identification
  agent_runtime_name  = var.agent_runtime_name
  container_image_uri = var.container_image_uri

  # Network mode - PUBLIC means no VPC configuration needed
  network_mode = "PUBLIC"

  # ECR Repository - create a new repository for container images
  create_ecr_repository              = true
  ecr_lifecycle_policy_untagged_days = 7
  ecr_lifecycle_policy_tagged_count  = 10

  # Image scanning configuration using object variable (recommended)
  ecr_image_scanning_configuration = {
    scan_on_push = true
  }

  # IAM Role - create with default Bedrock model access
  create_iam_role             = true
  enable_bedrock_model_access = true

  # Runtime lifecycle settings using object variable (recommended)
  runtime_lifecycle_configuration = {
    idle_runtime_session_timeout = 300
    max_lifetime                 = 1800
  }

  # Tags for resource identification
  tags = {
    Environment = "example"
    Example     = "basic"
    ManagedBy   = "terraform"
  }
}

################################################################################
# Outputs
################################################################################

output "agent_runtime_arn" {
  description = "ARN of the created AgentCore runtime."
  value       = module.agentcore.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "ID of the created AgentCore runtime."
  value       = module.agentcore.agent_runtime_id
}

output "agent_runtime_version" {
  description = "Version of the AgentCore runtime."
  value       = module.agentcore.agent_runtime_version
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing container images."
  value       = module.agentcore.ecr_repository_url
}

output "iam_role_arn" {
  description = "IAM execution role ARN."
  value       = module.agentcore.iam_role_arn
}
