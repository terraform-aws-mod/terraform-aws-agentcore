# Purpose: Expose created security group identifiers.

output "security_group_id" {
  description = "ID of the created security group."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "ARN of the created security group."
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_name" {
  description = "Name of the created security group."
  value       = try(aws_security_group.this[0].name, null)
}

output "security_group_vpc_id" {
  description = "VPC ID of the security group."
  value       = try(aws_security_group.this[0].vpc_id, null)
}
