# ECR Repository Module

> **Internal submodule** - This module is used internally by the root `terraform-aws-agentcore` module. For most use cases, use the root module instead.

Terraform module for creating AWS ECR repositories with lifecycle policies, KMS encryption, and optional Docker image build/push capability.

## Usage

```hcl
module "ecr" {
  source = "./_modules/ecr"

  repository_name = "my-agent"

  # Optional: Build and push image
  build_image = true
  build_script_args = {
    dockerfile = "./Dockerfile"
    context    = "."
    tags       = "latest,v1.0.0"
  }

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
| repository_name | Name of the ECR repository | `string` | n/a | yes |
| create | Whether to create ECR resources | `bool` | `true` | no |
| force_delete | Delete repository even if it contains images | `bool` | `false` | no |
| image_scanning_configuration | Configuration for image scanning | `object` | `{ scan_on_push = true }` | no |
| scan_type | Image scanning type: BASIC or ENHANCED | `string` | `"BASIC"` | no |
| create_lifecycle_policy | Whether to create a lifecycle policy | `bool` | `true` | no |
| lifecycle_policy | Custom lifecycle policy JSON | `string` | `null` | no |
| lifecycle_policy_untagged_days | Days before untagged images expire | `number` | `14` | no |
| lifecycle_policy_tagged_count | Number of tagged images to retain | `number` | `30` | no |
| create_kms_key | Whether to create a dedicated KMS key | `bool` | `true` | no |
| encryption_configuration | Repository encryption configuration | `object` | `null` | no |
| create_repository_policy | Whether to create a repository policy | `bool` | `false` | no |
| attach_execution_role_policy | Attach execution role read access | `bool` | `false` | no |
| execution_role_arn | Execution role ARN for pull access | `string` | `null` | no |
| repository_read_access_arns | IAM ARNs granted read access | `list(string)` | `[]` | no |
| repository_read_write_access_arns | IAM ARNs granted read/write access | `list(string)` | `[]` | no |
| build_image | Whether to build and push a container image | `bool` | `false` | no |
| build_script_args | Arguments for the build script | `map(string)` | `{}` | no |
| build_triggers | Map of values that trigger a rebuild | `map(string)` | `{}` | no |
| tags | Tags applied to ECR resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arn | ARN of the ECR repository |
| repository_name | Name of the ECR repository |
| repository_url | Repository URL for pushing/pulling images |
| registry_id | Registry ID where the repository was created |
| kms_key_arn | KMS key ARN used for encryption |
| kms_key_id | KMS key ID when created by this module |
| image_uri | Full image URI including the first tag |
| image_pushed | Indicates whether the image has been built |

## Security

- Image tag mutability is set to `IMMUTABLE` to prevent tag overwriting
- KMS encryption is enabled by default
- Scan on push is enabled by default
