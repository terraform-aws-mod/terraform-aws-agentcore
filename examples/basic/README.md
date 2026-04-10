# Basic Example - Public Network Mode

This example demonstrates the minimal configuration for deploying an AWS Bedrock AgentCore runtime in PUBLIC network mode.

## Features Demonstrated

- AgentCore runtime in PUBLIC network mode (no VPC required)
- Module-managed ECR repository with lifecycle policies
- Module-managed IAM execution role with Bedrock model access
- **Object-based configuration** for image scanning and runtime lifecycle (recommended pattern)
- Default runtime lifecycle settings

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (creates real AWS resources)
terraform apply

# Cleanup
terraform destroy
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aws_region | AWS region for deployment | string | us-east-1 |
| agent_runtime_name | Name for the AgentCore runtime | string | basic-agentcore-example |
| container_image_uri | Container image URI | string | public.ecr.aws/amazonlinux/amazonlinux:2023 |

## Outputs

| Name | Description |
|------|-------------|
| agent_runtime_arn | ARN of the created AgentCore runtime |
| agent_runtime_endpoint | Endpoint URL for the runtime |
| ecr_repository_url | ECR repository URL for pushing images |
| iam_role_arn | IAM execution role ARN |

## Configuration Patterns

This example uses **object variables** for configuration (the recommended pattern):

### Image Scanning Configuration

```hcl
# Using object variable (recommended)
ecr_image_scanning_configuration = {
  scan_on_push = true
}

# To disable scanning entirely
# ecr_image_scanning_configuration = null
```

### Runtime Lifecycle Configuration

```hcl
# Using object variable (recommended)
runtime_lifecycle_configuration = {
  idle_runtime_session_timeout = 300
  max_lifetime                 = 1800
}

# To omit lifecycle block
# runtime_lifecycle_configuration = null
```

### Legacy Variables (Deprecated)

The following variables still work but are deprecated:

```hcl
# Deprecated - use ecr_image_scanning_configuration instead
ecr_scan_on_push = true

# Deprecated - use runtime_lifecycle_configuration instead
idle_session_timeout_seconds = 300
max_session_lifetime_seconds = 1800
```

## Notes

- The default container image is a placeholder. Replace with your actual agent container image.
- PUBLIC mode means the runtime has internet access without VPC configuration.
- ECR repository is created with IMMUTABLE tags and scan-on-push enabled.
- Object variables allow setting configuration to `null` to completely omit optional blocks.
