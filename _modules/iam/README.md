# IAM Module

> **Internal submodule** - This module is used internally by the root `terraform-aws-agentcore` module. For most use cases, use the root module instead.

Terraform module for creating IAM execution roles for AWS Bedrock AgentCore with least-privilege permissions.

## Usage

```hcl
module "iam" {
  source = "AliMassoud/agentcore/aws//_modules/iam"

  role_name       = "agentcore-execution"
  aws_account_id  = "123456789012"
  ecr_repository_arn = module.ecr.repository_arn

  # Optional: Enable Bedrock model access
  enable_bedrock_model_access = true

  # Optional: Add secrets access
  secret_arns = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret"]

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

## Features

- Trust policy for `bedrock-agentcore.amazonaws.com`
- ECR pull permissions (if ECR repository ARN provided)
- CloudWatch Logs permissions (mandatory for AgentCore)
- Bedrock model invocation permissions (optional)
- Secrets Manager permissions (optional)
- SSM Parameter Store permissions (optional)
- Custom inline policies support
- Managed policy attachments support

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_account_id | AWS account ID for trust policy | `string` | n/a | yes |
| create | Whether to create IAM resources | `bool` | `true` | no |
| role_name | Name for the IAM role | `string` | `null` | no |
| role_name_prefix | Prefix for the IAM role name | `string` | `null` | no |
| use_role_name_prefix | Use name_prefix instead of name | `bool` | `false` | no |
| role_path | Path for the IAM role | `string` | `"/"` | no |
| role_description | Description of the IAM role | `string` | `"Execution role for AWS Bedrock AgentCore runtime"` | no |
| permissions_boundary_arn | Permissions boundary policy ARN | `string` | `null` | no |
| max_session_duration | Maximum session duration in seconds | `number` | `3600` | no |
| ecr_repository_arn | ECR repository ARN for pull permissions | `string` | `null` | no |
| ecr_repository_arns | List of ECR repository ARNs | `list(string)` | `[]` | no |
| enable_bedrock_model_access | Include Bedrock model invocation permissions | `bool` | `false` | no |
| bedrock_model_arns | Bedrock model ARNs to allow access | `list(string)` | `[]` | no |
| secret_arns | Secrets Manager secret ARNs | `list(string)` | `[]` | no |
| ssm_parameter_arns | SSM Parameter Store ARNs | `list(string)` | `[]` | no |
| inline_policy_statements | Custom inline IAM policy statements | `list(object)` | `[]` | no |
| iam_additional_policies | Additional managed policy ARNs | `list(string)` | `[]` | no |
| trusted_role_arns | Additional IAM role ARNs for cross-account | `list(string)` | `[]` | no |
| trusted_services | Additional AWS service principals | `list(string)` | `[]` | no |
| tags | Tags applied to IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of the execution role |
| iam_role_name | Name of the execution role |
| iam_role_id | ID of the execution role |
| iam_role_unique_id | Unique ID of the execution role |
| iam_role_path | Path of the execution role |
