# Purpose: Expose top-level module outputs for composition by callers.

################################################################################
# AgentCore Runtime Outputs
################################################################################

output "agent_runtime_arn" {
  description = "ARN of the created Bedrock AgentCore runtime."
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "ID of the created Bedrock AgentCore runtime."
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_id
}

output "agent_runtime_name" {
  description = "Name of the AgentCore runtime."
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_name
}

output "agent_runtime_version" {
  description = "Version of the AgentCore runtime."
  value       = try(aws_bedrockagentcore_agent_runtime.this.agent_runtime_version, null)
}

output "workload_identity_arn" {
  description = "Workload identity ARN of the AgentCore runtime."
  value       = try(aws_bedrockagentcore_agent_runtime.this.workload_identity_details[0].workload_identity_arn, null)
}

################################################################################
# ECR Outputs
################################################################################

output "ecr_repository_url" {
  description = "ECR repository URL when create_ecr_repository=true, otherwise null."
  value       = var.create_ecr_repository ? module.ecr[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ECR repository ARN when created."
  value       = var.create_ecr_repository ? module.ecr[0].repository_arn : null
}

output "ecr_repository_name" {
  description = "ECR repository name when created."
  value       = var.create_ecr_repository ? module.ecr[0].repository_name : null
}

output "ecr_registry_id" {
  description = "ECR registry ID when created."
  value       = var.create_ecr_repository ? module.ecr[0].registry_id : null
}

output "ecr_kms_key_arn" {
  description = "KMS key ARN used for ECR encryption when created."
  value       = var.create_ecr_repository ? module.ecr[0].kms_key_arn : null
}

output "ecr_kms_key_id" {
  description = "KMS key ID when created by this module."
  value       = var.create_ecr_repository && var.create_ecr_kms_key ? module.ecr[0].kms_key_id : null
}

output "ecr_image_uri" {
  description = "Full image URI when ECR repository is created with build enabled."
  value       = var.create_ecr_repository ? module.ecr[0].image_uri : null
}

################################################################################
# IAM Outputs
################################################################################

output "iam_role_arn" {
  description = "Execution IAM role ARN used by AgentCore runtime."
  value       = local.effective_iam_role_arn
}

output "iam_role_name" {
  description = "Name of the execution IAM role when created."
  value       = var.create_iam_role ? module.iam[0].iam_role_name : null
}

output "iam_role_id" {
  description = "ID of the execution IAM role when created."
  value       = var.create_iam_role ? module.iam[0].iam_role_id : null
}

output "iam_role_unique_id" {
  description = "Unique ID of the execution IAM role when created."
  value       = var.create_iam_role ? module.iam[0].iam_role_unique_id : null
}

output "iam_role_path" {
  description = "Path of the execution IAM role when created."
  value       = var.create_iam_role ? module.iam[0].iam_role_path : null
}

################################################################################
# Memory Outputs
################################################################################

output "memory_arn" {
  description = "ARN of the Bedrock AgentCore memory when created."
  value       = var.create_memory ? module.memory[0].memory_arn : null
}

output "memory_id" {
  description = "ID of the Bedrock AgentCore memory when created."
  value       = var.create_memory ? module.memory[0].memory_id : null
}

output "memory_name" {
  description = "Name of the Bedrock AgentCore memory when created."
  value       = var.create_memory ? module.memory[0].memory_name : null
}

output "memory_kms_key_arn" {
  description = "KMS key ARN for memory encryption when created."
  value       = var.create_memory && var.create_memory_kms_key ? module.memory[0].kms_key_arn : null
}

################################################################################
# Security Group Outputs
################################################################################

output "security_group_id" {
  description = "Security group ID created by this module when create_security_group=true in VPC mode."
  value       = local.create_security_group_effective ? module.security_group[0].security_group_id : null
}

output "security_group_arn" {
  description = "Security group ARN when created."
  value       = local.create_security_group_effective ? module.security_group[0].security_group_arn : null
}

output "security_group_name" {
  description = "Security group name when created."
  value       = local.create_security_group_effective ? module.security_group[0].security_group_name : null
}

output "security_group_vpc_id" {
  description = "VPC ID of the security group when created."
  value       = local.create_security_group_effective ? module.security_group[0].security_group_vpc_id : null
}
