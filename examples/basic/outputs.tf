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
