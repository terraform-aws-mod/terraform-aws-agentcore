# terraform-aws-agentcore

Production-grade Terraform module that provisions AWS Bedrock AgentCore runtime infrastructure with integrated ECR, IAM, and networking support.

## Quick Reference

<details>
<summary><strong>📋 Inputs Summary</strong> (click to expand)</summary>

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_runtime_name | Name of the Bedrock AgentCore runtime | `string` | n/a | yes |
| container_image_uri | Full container image URI for runtime artifact | `string` | n/a | yes |
| network_mode | Runtime network mode: `PUBLIC` or `VPC` | `string` | `"PUBLIC"` | no |
| vpc_id | VPC ID when network mode is `VPC` | `string` | `null` | no |
| subnet_ids | Subnet IDs when network mode is `VPC` | `list(string)` | `[]` | no |
| create_security_group | Create a security group in VPC mode | `bool` | `false` | no |
| security_group_ids | Existing security group IDs for VPC mode | `list(string)` | `[]` | no |
| create_ecr_repository | Create an ECR repository | `bool` | `true` | no |
| ecr_repository_name | ECR repository name (defaults to runtime name) | `string` | `null` | no |
| create_ecr_kms_key | Create dedicated KMS key for ECR encryption | `bool` | `false` | no |
| create_iam_role | Create AgentCore execution IAM role | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN when role creation is disabled | `string` | `null` | no |
| iam_additional_policies | Additional managed policy ARNs to attach | `list(string)` | `[]` | no |
| enable_bedrock_model_access | Grant Bedrock model invoke permissions (disabled by default) | `bool` | `false` | no |
| secret_arns | Secrets Manager ARNs runtime may read | `list(string)` | `[]` | no |
| runtime_lifecycle_configuration | Lifecycle configuration object | `object` | `{idle_runtime_session_timeout = 300, max_lifetime = 1800}` | no |
| protocol | Runtime protocol: `HTTP`, `MCP`, or `A2A` | `string` | `"HTTP"` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

</details>

<details>
<summary><strong>📤 Outputs Summary</strong> (click to expand)</summary>

| Name | Description |
|------|-------------|
| agent_runtime_arn | ARN of the created Bedrock AgentCore runtime |
| agent_runtime_id | ID of the created Bedrock AgentCore runtime |
| agent_runtime_name | Name of the AgentCore runtime |
| workload_identity_arn | Workload identity ARN of the runtime |
| ecr_repository_url | ECR repository URL when created |
| iam_role_arn | IAM execution role ARN used by runtime |
| security_group_id | Security group ID created by module (if enabled) |

</details>

---

## Features

- **Single module deployment** - One module to provision complete AgentCore infrastructure
- AWS Bedrock AgentCore runtime using native Terraform resource
- Optional ECR repository with lifecycle policy, scan-on-push, and KMS encryption
- **Minimal IAM execution role** with only essential permissions (CloudWatch Logs + ECR pull)
- Optional security group creation for VPC mode (no egress by default for security)
- **Dynamic block pattern** for flexible, composable configuration
- Public and private VPC deployment modes
- Docker image build and push capability
- CI pipeline for formatting, validation, linting, security scans, and tests
- Semantic release workflow for Terraform Registry-compatible version tags

## Architecture

```
terraform-aws-agentcore (root module)
├── main.tf              # AgentCore runtime resource + orchestrates submodules
├── variables.tf         # All user-facing inputs
├── outputs.tf           # All outputs
├── locals.tf            # Computed values
├── versions.tf          # Provider requirements
└── _modules/            # Internal submodules (NOT published separately)
    ├── ecr/             # ECR repository + KMS + lifecycle + image build
    ├── iam/             # Execution role + policies
    └── security_group/  # VPC security group
```

The root module orchestrates all internal submodules and creates the AgentCore runtime resource directly. Users only need to interact with this single module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

---

## Least-Privilege IAM Design

The module provides a **minimal IAM role** with only what AgentCore requires:

| Permission | Default | Description |
|------------|---------|-------------|
| CloudWatch Logs | Always | **Mandatory** for AgentCore runtime logging. |
| ECR Pull | When ECR ARN provided | Pull container images from ECR. |
| Bedrock Model Access | `false` | **Opt-in.** Enable only if your agent calls Bedrock models. |
| Secrets Manager | When ARNs provided | Read secrets specified in `secret_arns`. |
| SSM Parameters | When ARNs provided | Read parameters specified in `ssm_parameter_arns`. |

**For additional permissions** (S3, DynamoDB, SQS, SNS, Lambda, X-Ray, etc.), use:
- `iam_inline_policy_statements` - Add custom inline policies
- `iam_additional_policies` - Attach managed policies

### When to Enable Bedrock Model Access

Set `enable_bedrock_model_access = true` if your agent code:
- Calls `bedrock:InvokeModel`, `bedrock:Converse`, or their streaming variants
- Uses Bedrock Converse API (including SDKs like Strands, LangChain, etc.)
- Invokes Bedrock foundation models (Claude, Titan, etc.)

Set `enable_bedrock_model_access = false` (default) if:
- Your agent uses external AI providers (OpenAI, Google, Anthropic API directly)
- Your agent doesn't call any AI models
- You're providing a custom IAM role with Bedrock permissions already attached

---

## Usage

### Basic (PUBLIC network mode)

```hcl
module "agentcore" {
  source  = "AliMassoud/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my-agent"
  container_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest"

  # Network - PUBLIC mode (default)
  network_mode = "PUBLIC"

  # ECR - create repository
  create_ecr_repository = true

  # IAM - create execution role
  create_iam_role = true

  # Enable if your agent calls Bedrock models
  enable_bedrock_model_access = true

  tags = {
    Environment = "production"
  }
}
```

### Private VPC Mode

```hcl
module "agentcore" {
  source  = "AliMassoud/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my-vpc-agent"
  container_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest"

  # VPC Mode
  network_mode = "VPC"
  vpc_id       = "vpc-0123456789abcdef0"
  subnet_ids   = ["subnet-aaa", "subnet-bbb"]

  # Create security group with egress to internet
  create_security_group             = true
  security_group_egress_cidr_blocks = ["0.0.0.0/0"]

  # Or use existing security groups
  # security_group_ids = ["sg-0123456789abcdef0"]

  tags = {
    Environment = "production"
  }
}
```

### Using a Custom IAM Role

```hcl
module "agentcore" {
  source  = "AliMassoud/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my-agent"
  container_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest"

  # Use your own IAM role
  create_iam_role = false
  iam_role_arn    = "arn:aws:iam::123456789012:role/my-custom-agentcore-role"
}
```

Your custom role must include:
1. **Trust policy** allowing `bedrock-agentcore.amazonaws.com` to assume the role
2. **CloudWatch Logs** permissions for `/aws/bedrock-agentcore/*`
3. Any additional permissions your agent needs

### Adding Custom IAM Permissions

```hcl
module "agentcore" {
  source  = "AliMassoud/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my-agent"
  container_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest"

  iam_inline_policy_statements = [
    {
      sid       = "S3Access"
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject"]
      resources = ["arn:aws:s3:::my-bucket/*"]
    },
    {
      sid       = "DynamoDBAccess"
      effect    = "Allow"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"]
      resources = ["arn:aws:dynamodb:us-east-1:123456789012:table/my-table"]
    }
  ]
}
```

### ECR with Docker Image Build

> **Cross-platform builds:** AWS AgentCore runtime requires `linux/arm64` images. If you are building on an `amd64`/`x86_64` host, you must enable QEMU user-space emulation before running `terraform apply`:
>
> ```bash
> docker run --privileged --rm tonistiigi/binfmt --install all
> ```
>
> This registration is **not persistent** across Docker daemon restarts or system reboots. If you encounter `exec format error` during builds, re-run the command above.

```hcl
module "agentcore" {
  source  = "AliMassoud/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my-agent"
  container_image_uri = "placeholder:latest"  # Will use built image

  create_ecr_repository = true

  # Build and push Docker image
  ecr_build_image = true
  ecr_build_script_args = {
    dockerfile = "./Dockerfile"
    context    = "."
    tags       = "v1.0.0,latest"
    platform   = "linux/arm64"
  }

  # Rebuild when Dockerfile changes
  ecr_build_triggers = {
    dockerfile_hash = filesha256("./Dockerfile")
  }
}
```

---

## Inputs

### Required

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_runtime_name | Name of the Bedrock AgentCore runtime | `string` | n/a | yes |
| container_image_uri | Full container image URI for runtime artifact | `string` | n/a | yes |

### Network Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_mode | Runtime network mode: `PUBLIC` or `VPC` | `string` | `"PUBLIC"` | no |
| vpc_id | VPC ID when network mode is `VPC` | `string` | `null` | no |
| subnet_ids | Subnet IDs when network mode is `VPC` | `list(string)` | `[]` | no |
| create_security_group | Create a security group in VPC mode | `bool` | `false` | no |
| security_group_ids | Existing security group IDs for VPC mode | `list(string)` | `[]` | no |

### ECR Repository Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_ecr_repository | Create an ECR repository | `bool` | `true` | no |
| ecr_repository_name | ECR repository name (defaults to runtime name) | `string` | `null` | no |
| ecr_image_scanning_configuration | Configuration for image scanning | `object` | `{scan_on_push = true}` | no |
| ecr_scan_type | Image scanning type: `BASIC` or `ENHANCED` | `string` | `"BASIC"` | no |
| create_ecr_kms_key | Create dedicated KMS key for ECR encryption | `bool` | `false` | no |

### IAM Role Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_iam_role | Create AgentCore execution IAM role | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN when role creation is disabled | `string` | `null` | no |
| iam_additional_policies | Additional managed policy ARNs to attach | `list(string)` | `[]` | no |
| iam_inline_policy_statements | Custom inline policies for additional service access | `list(object)` | `[]` | no |
| enable_bedrock_model_access | Grant Bedrock model invoke permissions (disabled by default) | `bool` | `false` | no |
| secret_arns | Secrets Manager ARNs runtime may read | `list(string)` | `[]` | no |
| ssm_parameter_arns | SSM Parameter Store ARNs runtime may read | `list(string)` | `[]` | no |

### Runtime Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| runtime_lifecycle_configuration | Lifecycle configuration object | `object` | `{idle_runtime_session_timeout = 300, max_lifetime = 1800}` | no |
| protocol | Runtime protocol: `HTTP`, `MCP`, or `A2A` | `string` | `"HTTP"` | no |
| authorizer_configuration | Custom JWT authorizer configuration | `object` | `null` | no |
| runtime_environment_variables | Environment variables for the container | `map(string)` | `{}` | no |
| runtime_timeouts | Timeout configuration for operations | `object` | `null` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Resource tags | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| agent_runtime_arn | ARN of the created Bedrock AgentCore runtime |
| agent_runtime_id | ID of the created Bedrock AgentCore runtime |
| agent_runtime_name | Name of the AgentCore runtime |
| agent_runtime_version | Version of the AgentCore runtime |
| workload_identity_arn | Workload identity ARN of the runtime |
| ecr_repository_url | ECR repository URL when created |
| ecr_repository_arn | ECR repository ARN when created |
| ecr_image_uri | Full image URI when ECR repository is created |
| iam_role_arn | IAM execution role ARN used by runtime |
| iam_role_name | Name of the execution IAM role when created |
| security_group_id | Security group ID created by module (if enabled) |

---

## Internal Submodules

These submodules are used internally by the root module and are not intended for direct use:

| Submodule | Description |
|-----------|-------------|
| `_modules/ecr` | Creates ECR repository, lifecycle policy, repository policy, and optional KMS key |
| `_modules/iam` | Creates execution role, trust policy, inline policies, and managed policy attachments |
| `_modules/security_group` | Creates optional egress-only security group with extensible rules |

---

## Security Features

- **IMMUTABLE image tags** - ECR repository uses immutable tags to prevent tag overwriting
- **KMS encryption** - Optional KMS encryption for ECR repositories
- **Scan on push** - Image scanning enabled by default
- **No egress by default** - Security groups created with no egress rules by default
- **Least privilege IAM** - Minimal permissions, Bedrock access disabled by default

---

## Examples

| Example | Description |
|---------|-------------|
| `examples/basic` | Public network mode with module-managed IAM and ECR |
| `examples/private-vpc` | VPC mode with custom subnets and security groups |
| `examples/strands-agent` | Complete Strands Agent example with Docker build and deployment |

---

## CI and Release

| File | Purpose |
|------|---------|
| `.github/workflows/ci.yml` | Format, validate, lint, security scans, and tests |
| `.github/workflows/release.yml` | Semantic release on `main` |
| `.releaserc.json` | Semantic release configuration |

---
## Authors

Module is maintained by Ali MASSOUD.
contributions from the community are welcome! Please open issues or submit pull requests for improvements.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
