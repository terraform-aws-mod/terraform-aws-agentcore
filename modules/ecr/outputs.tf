# Purpose: Expose ECR resource attributes for parent module consumption.

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = try(aws_ecr_repository.this[0].arn, null)
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = try(aws_ecr_repository.this[0].name, null)
}

output "repository_url" {
  description = "Repository URL used for pushing and pulling images."
  value       = try(aws_ecr_repository.this[0].repository_url, null)
}

output "registry_id" {
  description = "Registry ID where the repository was created."
  value       = try(aws_ecr_repository.this[0].registry_id, null)
}

output "kms_key_arn" {
  description = "KMS key ARN used for repository encryption when applicable."
  value       = local.create && local.effective_encryption_type == "KMS" ? local.effective_kms_key_arn : null
}

output "kms_key_id" {
  description = "KMS key ID when created by this module."
  value       = try(aws_kms_key.this[0].key_id, null)
}

output "image_uri" {
  description = "Full image URI including the first tag (ready to use in container_image_uri)."
  value       = local.create ? "${aws_ecr_repository.this[0].repository_url}:${local.first_image_tag}" : null
}

output "image_pushed" {
  description = "Indicates whether the image has been built and pushed. Use this to create dependencies."
  value       = try(terraform_data.build_and_push_image[0].id, null)
}
