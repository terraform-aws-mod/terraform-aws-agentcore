# Outputs for Memory Agent deployment

output "agent_runtime_arn" {
  description = "ARN of the AgentCore runtime."
  value       = module.agentcore.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "ID of the AgentCore runtime."
  value       = module.agentcore.agent_runtime_id
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.agentcore.ecr_repository_url
}

output "ecr_image_uri" {
  description = "Full image URI with tag."
  value       = module.agentcore.ecr_image_uri
}

output "iam_role_arn" {
  description = "IAM execution role ARN."
  value       = module.agentcore.iam_role_arn
}

output "memory_arn" {
  description = "ARN of the AgentCore memory."
  value       = module.agentcore.memory_arn
}

output "memory_id" {
  description = "ID of the AgentCore memory."
  value       = module.agentcore.memory_id
}

output "security_group_id" {
  description = "Security group ID (when using VPC mode)."
  value       = module.agentcore.security_group_id
}
