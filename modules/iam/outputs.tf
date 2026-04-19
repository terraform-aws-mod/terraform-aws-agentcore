# Purpose: Expose IAM role identifiers to parent modules.

output "iam_role_arn" {
  description = "ARN of the execution role."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of the execution role."
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_id" {
  description = "ID of the execution role."
  value       = try(aws_iam_role.this[0].id, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of the execution role."
  value       = try(aws_iam_role.this[0].unique_id, null)
}

output "iam_role_path" {
  description = "Path of the execution role."
  value       = try(aws_iam_role.this[0].path, null)
}
