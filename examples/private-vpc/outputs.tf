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
