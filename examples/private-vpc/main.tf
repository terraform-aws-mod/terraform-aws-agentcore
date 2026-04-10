# Purpose: Demonstrate VPC mode with module-created security group.

################################################################################
# Provider Configuration
################################################################################

provider "aws" {
  region = var.aws_region
}

################################################################################
# Data Sources - Existing VPC Infrastructure
################################################################################

# Use default VPC if no VPC ID provided
data "aws_vpc" "selected" {
  id = var.vpc_id != null ? var.vpc_id : null

  dynamic "filter" {
    for_each = var.vpc_id == null ? [1] : []
    content {
      name   = "is-default"
      values = ["true"]
    }
  }
}

# Get private subnets if not provided
data "aws_subnets" "private" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

locals {
  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : try(data.aws_subnets.private[0].ids, [])
}

################################################################################
# AgentCore Module - VPC Mode with Created Security Group
################################################################################

module "agentcore" {
  source = "../../"

  # Required - Runtime identification
  agent_runtime_name  = var.agent_runtime_name
  container_image_uri = var.container_image_uri

  # Network mode - VPC with module-managed security group
  network_mode = "VPC"
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  # Security Group - let the module create one
  # Note: Using empty list (default) for least-privilege. 
  # Add specific egress rules if your agent needs outbound access.
  create_security_group      = true
  security_group_description = "AgentCore runtime security group for ${var.agent_runtime_name}"
  # security_group_egress_cidr_blocks = ["0.0.0.0/0"]  # Uncomment for unrestricted egress (not recommended)

  # ECR Repository - skip creation, use existing or external
  create_ecr_repository = false

  # IAM Role - create with Bedrock model access
  create_iam_role             = true
  enable_bedrock_model_access = true

  # Optional: Secrets Manager access
  secret_arns = var.secret_arns

  # Runtime lifecycle settings using object variable (recommended)
  runtime_lifecycle_configuration = {
    idle_runtime_session_timeout = 600
    max_lifetime                 = 3600
  }

  # Tags for resource identification
  tags = merge(var.tags, {
    Environment = "example"
    Example     = "private-vpc"
  })
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

output "iam_role_arn" {
  description = "IAM execution role ARN."
  value       = module.agentcore.iam_role_arn
}

output "security_group_id" {
  description = "Security group ID created for the runtime."
  value       = module.agentcore.security_group_id
}

output "vpc_id" {
  description = "VPC ID where the runtime is deployed."
  value       = local.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs used by the runtime."
  value       = local.subnet_ids
}
