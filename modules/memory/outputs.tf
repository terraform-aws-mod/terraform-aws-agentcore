output "memory_arn" {
  description = "ARN of the Bedrock AgentCore memory."
  value       = try(aws_bedrockagentcore_memory.this[0].arn, null)
}

output "memory_id" {
  description = "ID of the Bedrock AgentCore memory."
  value       = try(aws_bedrockagentcore_memory.this[0].id, null)
}

output "memory_name" {
  description = "Name of the Bedrock AgentCore memory."
  value       = try(aws_bedrockagentcore_memory.this[0].name, null)
}

output "kms_key_arn" {
  description = "KMS key ARN when created by this module."
  value       = try(aws_kms_key.this[0].arn, null)
}

output "kms_key_id" {
  description = "KMS key ID when created by this module."
  value       = try(aws_kms_key.this[0].key_id, null)
}
