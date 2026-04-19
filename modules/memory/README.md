# Memory Module

> **Internal submodule** - This module is used internally by the root `terraform-aws-agentcore` module. For most use cases, use the root module instead.

Terraform module for creating AWS Bedrock AgentCore Memory resources with optional KMS encryption.

## Usage

```hcl
module "memory" {
  source = "../../modules/memory"

  memory_name           = "my-agent-memory"
  event_expiry_duration = 30

  # Optional: Custom encryption
  create_kms_key = true

  # Optional: Execution role for custom memory strategies
  memory_execution_role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/my-memory-role"

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| memory_name | Name of the Bedrock AgentCore memory | `string` | n/a | yes |
| event_expiry_duration | Days after which memory events expire (7-365) | `number` | n/a | yes |
| create | Whether to create memory resources | `bool` | `true` | no |
| description | Description of the memory | `string` | `null` | no |
| encryption_key_arn | KMS key ARN for memory encryption | `string` | `null` | no |
| memory_execution_role_arn | IAM role ARN for memory operations | `string` | `null` | no |
| client_token | Unique client token for idempotent creation | `string` | `null` | no |
| create_kms_key | Create a dedicated KMS key for encryption | `bool` | `false` | no |
| kms_key_deletion_window_days | KMS key deletion window in days | `number` | `7` | no |
| kms_key_enable_rotation | Enable automatic KMS key rotation | `bool` | `true` | no |
| timeouts | Timeout configuration for operations | `object` | `null` | no |
| tags | Tags applied to memory resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| memory_arn | ARN of the Bedrock AgentCore memory |
| memory_id | ID of the Bedrock AgentCore memory |
| memory_name | Name of the Bedrock AgentCore memory |
| kms_key_arn | KMS key ARN when created by this module |
| kms_key_id | KMS key ID when created by this module |
