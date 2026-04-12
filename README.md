# terraform-aws-agentcore

Production-grade Terraform module that provisions AWS Bedrock AgentCore runtime infrastructure with integrated ECR, IAM, and networking support.

## Quick Reference

<details>
<summary><strong>📋 Inputs Summary</strong> (click to expand)</summary>

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_runtime_name | Name of the Bedrock AgentCore runtime | `string` | `"agentcore_runtime"` | no |
| container_image_uri | Full container image URI for runtime artifact | `string` | `"public.ecr.aws/bedrock-agentcore/runtime:latest"` | no |
| network_mode | Runtime network mode: `PUBLIC` or `VPC` | `string` | `"PUBLIC"` | no |
| vpc_id | VPC ID when network mode is `VPC` | `string` | `null` | no |
| subnet_ids | Subnet IDs when network mode is `VPC` | `list(string)` | `[]` | no |
| create_security_group | Create a security group in VPC mode | `bool` | `false` | no |
| security_group_ids | Existing security group IDs for VPC mode | `list(string)` | `[]` | no |
| security_group_name | Name for the created security group | `string` | `null` | no |
| security_group_description | Description for the created security group | `string` | `"Security group for Bedrock AgentCore runtime"` | no |
| security_group_use_name_prefix | Use name prefix for the security group | `bool` | `false` | no |
| security_group_egress_cidr_blocks | IPv4 CIDR blocks for security group egress | `list(string)` | `[]` | no |
| security_group_egress_ipv6_cidr_blocks | IPv6 CIDR blocks for security group egress | `list(string)` | `[]` | no |
| security_group_egress_with_self | Allow egress to the security group itself | `bool` | `false` | no |
| security_group_ingress_with_self | Allow ingress from the security group itself | `bool` | `false` | no |
| security_group_ingress_rules | Additional ingress rules | `list(object)` | `[]` | no |
| security_group_egress_rules | Additional egress rules | `list(object)` | `[]` | no |
| create_ecr_repository | Create an ECR repository | `bool` | `true` | no |
| ecr_repository_name | ECR repository name (defaults to runtime name) | `string` | `null` | no |
| ecr_force_delete | Delete ECR repo even if it contains images | `bool` | `false` | no |
| ecr_image_scanning_configuration | Configuration for image scanning | `object` | `{scan_on_push = true}` | no |
| ecr_scan_type | Image scanning type: `BASIC` or `ENHANCED` | `string` | `"BASIC"` | no |
| ecr_create_lifecycle_policy | Create an ECR lifecycle policy | `bool` | `true` | no |
| ecr_lifecycle_policy | Custom ECR lifecycle policy JSON | `string` | `null` | no |
| ecr_lifecycle_policy_untagged_days | Days before untagged images expire | `number` | `14` | no |
| ecr_lifecycle_policy_tagged_count | Number of tagged images to retain | `number` | `30` | no |
| ecr_attach_execution_role_policy | Attach IAM execution role to ECR repo policy | `bool` | `true` | no |
| ecr_repository_read_access_arns | IAM ARNs granted read access to ECR | `list(string)` | `[]` | no |
| ecr_repository_read_write_access_arns | IAM ARNs granted read/write access to ECR | `list(string)` | `[]` | no |
| ecr_repository_policy_statements | Additional IAM policy statements for ECR | `list(object)` | `[]` | no |
| ecr_encryption_configuration | ECR repository encryption configuration | `object` | `null` | no |
| create_ecr_kms_key | Create dedicated KMS key for ECR encryption | `bool` | `false` | no |
| ecr_kms_key_arn | Existing KMS key ARN for ECR encryption | `string` | `null` | no |
| ecr_kms_key_deletion_window_days | KMS key deletion window in days | `number` | `7` | no |
| ecr_kms_key_enable_rotation | Enable automatic KMS key rotation | `bool` | `true` | no |
| ecr_build_image | Build and push a container image to ECR | `bool` | `false` | no |
| ecr_build_script_path | Path to custom build script | `string` | `null` | no |
| ecr_build_script_args | Arguments to pass to the build script | `map(string)` | `{}` | no |
| ecr_build_script_interpreter | Interpreter for the build script | `list(string)` | `["/bin/bash", "-c"]` | no |
| ecr_build_script_environment | Environment variables for the build script | `map(string)` | `{}` | no |
| ecr_build_script_working_dir | Working directory for the build script | `string` | `null` | no |
| ecr_build_triggers | Map of values that trigger a rebuild | `map(string)` | `{}` | no |
| create_iam_role | Create AgentCore execution IAM role | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN when role creation is disabled | `string` | `null` | no |
| iam_role_name | Name for the IAM execution role | `string` | `null` | no |
| iam_role_path | Path for the IAM execution role | `string` | `"/"` | no |
| iam_role_description | Description for the IAM execution role | `string` | `"Execution role for AWS Bedrock AgentCore runtime"` | no |
| iam_permissions_boundary_arn | Permissions boundary policy ARN | `string` | `null` | no |
| iam_max_session_duration | Maximum session duration in seconds | `number` | `3600` | no |
| iam_trusted_role_arns | Additional IAM role ARNs allowed to assume this role | `list(string)` | `[]` | no |
| iam_trusted_services | Additional AWS service principals allowed to assume this role | `list(string)` | `[]` | no |
| iam_additional_policies | Additional managed policy ARNs to attach | `list(string)` | `[]` | no |
| iam_inline_policy_statements | Custom inline IAM policy statements | `list(object)` | `[]` | no |
| aws_account_id | AWS account ID for IAM trust policy SourceAccount condition | `string` | `null` | no |
| enable_bedrock_model_access | Grant Bedrock model invoke permissions | `bool` | `false` | no |
| bedrock_model_arns | Specific Bedrock model ARNs to allow | `list(string)` | `[]` | no |
| secret_arns | Secrets Manager ARNs runtime may read | `list(string)` | `[]` | no |
| ssm_parameter_arns | SSM Parameter Store ARNs runtime may read | `list(string)` | `[]` | no |
| runtime_lifecycle_configuration | Lifecycle configuration object | `object` | `{idle_runtime_session_timeout = 300, max_lifetime = 1800}` | no |
| protocol | Runtime protocol: `HTTP`, `MCP`, or `A2A` | `string` | `"HTTP"` | no |
| authorizer_configuration | Custom JWT authorizer configuration | `object` | `null` | no |
| request_header_allowlist | HTTP request headers allowed to pass through | `list(string)` | `[]` | no |
| runtime_description | Description for the AgentCore runtime | `string` | `null` | no |
| runtime_environment_variables | Environment variables for the container | `map(string)` | `{}` | no |
| runtime_timeouts | Timeout configuration for operations | `object` | `null` | no |
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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

For architecture and least-privilege IAM guidance, see [AGENTS.md](AGENTS.md).

---

## Usage

### Minimal (Zero Required Inputs)

```hcl
module "agentcore" {
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"
}
```

### Basic (PUBLIC network mode)

```hcl
module "agentcore" {
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my_agent"
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

### Comprehensive Example (Many Variables)

```hcl
module "agentcore" {
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  # ── Core ─────────────────────────────────────────────────────────────────
  agent_runtime_name  = "my_production_agent"
  container_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:v1.2.0"
  runtime_description = "Production agent runtime for order processing"

  # ── Network ──────────────────────────────────────────────────────────────
  network_mode = "VPC"
  vpc_id       = "vpc-0123456789abcdef0"
  subnet_ids   = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

  # ── Security Group ──────────────────────────────────────────────────────
  create_security_group             = true
  security_group_name               = "my-agent-sg"
  security_group_description        = "AgentCore runtime security group"
  security_group_egress_cidr_blocks = ["0.0.0.0/0"]
  security_group_ingress_with_self  = true
  security_group_egress_with_self   = true

  security_group_ingress_rules = [
    {
      description = "Allow HTTPS from internal"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  # ── ECR Repository ─────────────────────────────────────────────────────
  create_ecr_repository            = true
  ecr_repository_name              = "my-agent-repo"
  ecr_force_delete                 = false
  ecr_scan_type                    = "ENHANCED"
  ecr_create_lifecycle_policy      = true
  ecr_lifecycle_policy_untagged_days = 7
  ecr_lifecycle_policy_tagged_count  = 50
  ecr_repository_read_access_arns   = ["arn:aws:iam::123456789012:role/ci-reader"]

  ecr_image_scanning_configuration = {
    scan_on_push = true
  }

  # ── ECR Encryption ─────────────────────────────────────────────────────
  create_ecr_kms_key             = true
  ecr_kms_key_deletion_window_days = 14
  ecr_kms_key_enable_rotation    = true

  # ── ECR Image Build ────────────────────────────────────────────────────
  ecr_build_image = true
  ecr_build_script_args = {
    dockerfile = "./Dockerfile"
    context    = "."
    tags       = "v1.2.0,latest"
    platform   = "linux/arm64"
  }
  ecr_build_triggers = {
    dockerfile_hash = filesha256("./Dockerfile")
    source_hash     = filesha256("./src/main.py")
  }

  # ── IAM Role ───────────────────────────────────────────────────────────
  create_iam_role          = true
  iam_role_name            = "my-agent-execution-role"
  iam_role_path            = "/agentcore/"
  iam_role_description     = "Execution role for production agent"
  iam_max_session_duration = 7200
  iam_trusted_services     = ["lambda.amazonaws.com"]

  iam_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  iam_inline_policy_statements = [
    {
      sid       = "DynamoDBAccess"
      effect    = "Allow"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"]
      resources = ["arn:aws:dynamodb:us-east-1:123456789012:table/orders"]
    },
    {
      sid       = "SQSAccess"
      effect    = "Allow"
      actions   = ["sqs:SendMessage", "sqs:ReceiveMessage"]
      resources = ["arn:aws:sqs:us-east-1:123456789012:agent-queue"]
    }
  ]

  # ── Service Access Permissions ─────────────────────────────────────────
  enable_bedrock_model_access = true
  bedrock_model_arns = [
    "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-sonnet-4-20250514-v1:0"
  ]
  secret_arns        = ["arn:aws:secretsmanager:us-east-1:123456789012:secret:api-key-*"]
  ssm_parameter_arns = ["arn:aws:ssm:us-east-1:123456789012:parameter/agent/*"]

  # ── Runtime Configuration ──────────────────────────────────────────────
  protocol = "HTTP"

  runtime_lifecycle_configuration = {
    idle_runtime_session_timeout = 600
    max_lifetime                 = 3600
  }

  authorizer_configuration = {
    discovery_url    = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_EXAMPLE/.well-known/openid-configuration"
    allowed_audience = ["my-app-client-id"]
    allowed_clients  = ["my-app-client-id"]
  }

  request_header_allowlist = ["X-Request-Id", "X-Correlation-Id"]

  runtime_environment_variables = {
    LOG_LEVEL = "INFO"
    REGION    = "us-east-1"
  }

  runtime_timeouts = {
    create = "45m"
    update = "45m"
    delete = "30m"
  }

  # ── Tags ───────────────────────────────────────────────────────────────
  tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "eng-123"
  }
}
```

### Private VPC Mode

```hcl
module "agentcore" {
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my_vpc_agent"
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
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my_agent"
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
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my_agent"
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
  source  = "terraform-aws-mod/agentcore/aws"
  version = "~> 1.0"

  agent_runtime_name  = "my_agent"
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

### Core Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent_runtime_name | Name of the Bedrock AgentCore runtime | `string` | `"agentcore_runtime"` | no |
| container_image_uri | Full container image URI for runtime artifact | `string` | `"public.ecr.aws/bedrock-agentcore/runtime:latest"` | no |

### Network Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_mode | Runtime network mode: `PUBLIC` or `VPC` | `string` | `"PUBLIC"` | no |
| vpc_id | VPC ID when network mode is `VPC` | `string` | `null` | no |
| subnet_ids | Subnet IDs when network mode is `VPC` | `list(string)` | `[]` | no |

### Security Group Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_security_group | Create a security group in VPC mode | `bool` | `false` | no |
| security_group_ids | Existing security group IDs for VPC mode | `list(string)` | `[]` | no |
| security_group_name | Name for the created security group | `string` | `null` | no |
| security_group_description | Description for the created security group | `string` | `"Security group for Bedrock AgentCore runtime"` | no |
| security_group_use_name_prefix | Use name prefix for the security group | `bool` | `false` | no |
| security_group_egress_cidr_blocks | IPv4 CIDR blocks for security group egress | `list(string)` | `[]` | no |
| security_group_egress_ipv6_cidr_blocks | IPv6 CIDR blocks for security group egress | `list(string)` | `[]` | no |
| security_group_egress_with_self | Allow egress to the security group itself | `bool` | `false` | no |
| security_group_ingress_with_self | Allow ingress from the security group itself | `bool` | `false` | no |
| security_group_ingress_rules | Additional ingress rules for the security group | `list(object)` | `[]` | no |
| security_group_egress_rules | Additional egress rules for the security group | `list(object)` | `[]` | no |

### ECR Repository Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_ecr_repository | Create an ECR repository | `bool` | `true` | no |
| ecr_repository_name | ECR repository name (defaults to runtime name) | `string` | `null` | no |
| ecr_force_delete | Delete ECR repository even if it contains images | `bool` | `false` | no |
| ecr_image_scanning_configuration | Configuration for image scanning | `object` | `{scan_on_push = true}` | no |
| ecr_scan_type | Image scanning type: `BASIC` or `ENHANCED` | `string` | `"BASIC"` | no |
| ecr_create_lifecycle_policy | Create an ECR lifecycle policy | `bool` | `true` | no |
| ecr_lifecycle_policy | Custom ECR lifecycle policy JSON | `string` | `null` | no |
| ecr_lifecycle_policy_untagged_days | Days before untagged images expire | `number` | `14` | no |
| ecr_lifecycle_policy_tagged_count | Number of tagged images to retain | `number` | `30` | no |
| ecr_attach_execution_role_policy | Attach IAM execution role to ECR repo policy | `bool` | `true` | no |
| ecr_repository_read_access_arns | IAM ARNs granted read access to ECR | `list(string)` | `[]` | no |
| ecr_repository_read_write_access_arns | IAM ARNs granted read/write access to ECR | `list(string)` | `[]` | no |
| ecr_repository_policy_statements | Additional IAM policy statements for ECR | `list(object)` | `[]` | no |

### ECR Encryption Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecr_encryption_configuration | ECR repository encryption configuration | `object` | `null` | no |
| create_ecr_kms_key | Create dedicated KMS key for ECR encryption | `bool` | `false` | no |
| ecr_kms_key_arn | Existing KMS key ARN for ECR encryption | `string` | `null` | no |
| ecr_kms_key_deletion_window_days | KMS key deletion window in days | `number` | `7` | no |
| ecr_kms_key_enable_rotation | Enable automatic KMS key rotation | `bool` | `true` | no |

### ECR Container Image Build Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecr_build_image | Build and push a container image to ECR | `bool` | `false` | no |
| ecr_build_script_path | Path to custom build script | `string` | `null` | no |
| ecr_build_script_args | Arguments to pass to the build script | `map(string)` | `{}` | no |
| ecr_build_script_interpreter | Interpreter for the build script | `list(string)` | `["/bin/bash", "-c"]` | no |
| ecr_build_script_environment | Environment variables for the build script | `map(string)` | `{}` | no |
| ecr_build_script_working_dir | Working directory for the build script | `string` | `null` | no |
| ecr_build_triggers | Map of values that trigger a rebuild | `map(string)` | `{}` | no |

### IAM Role Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_iam_role | Create AgentCore execution IAM role | `bool` | `true` | no |
| iam_role_arn | Existing IAM role ARN when role creation is disabled | `string` | `null` | no |
| iam_role_name | Name for the IAM execution role | `string` | `null` | no |
| iam_role_path | Path for the IAM execution role | `string` | `"/"` | no |
| iam_role_description | Description for the IAM execution role | `string` | `"Execution role for AWS Bedrock AgentCore runtime"` | no |
| iam_permissions_boundary_arn | Permissions boundary policy ARN | `string` | `null` | no |
| iam_max_session_duration | Maximum session duration in seconds | `number` | `3600` | no |
| iam_trusted_role_arns | Additional IAM role ARNs allowed to assume this role | `list(string)` | `[]` | no |
| iam_trusted_services | Additional AWS service principals allowed to assume this role | `list(string)` | `[]` | no |
| iam_additional_policies | Additional managed policy ARNs to attach | `list(string)` | `[]` | no |
| iam_inline_policy_statements | Custom inline IAM policy statements | `list(object)` | `[]` | no |
| aws_account_id | AWS account ID for IAM trust policy SourceAccount condition | `string` | `null` | no |

### IAM Service Access Permissions

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_bedrock_model_access | Grant Bedrock model invoke permissions | `bool` | `false` | no |
| bedrock_model_arns | Specific Bedrock model ARNs to allow | `list(string)` | `[]` | no |
| secret_arns | Secrets Manager ARNs runtime may read | `list(string)` | `[]` | no |
| ssm_parameter_arns | SSM Parameter Store ARNs runtime may read | `list(string)` | `[]` | no |

### Runtime Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| runtime_description | Description for the AgentCore runtime | `string` | `null` | no |
| runtime_lifecycle_configuration | Lifecycle configuration object | `object` | `{idle_runtime_session_timeout = 300, max_lifetime = 1800}` | no |
| protocol | Runtime protocol: `HTTP`, `MCP`, or `A2A` | `string` | `"HTTP"` | no |
| authorizer_configuration | Custom JWT authorizer configuration | `object` | `null` | no |
| request_header_allowlist | HTTP request headers allowed to pass through | `list(string)` | `[]` | no |
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

## Examples

| Example | Description |
|---------|-------------|
| `examples/basic` | Public network mode with module-managed IAM and ECR |
| `examples/private-vpc` | VPC mode with custom subnets and security groups |
| `examples/strands-agent` | Complete Strands Agent example with Docker build and deployment |

---

## Security Features/Considerations

- **IMMUTABLE image tags** - ECR repository uses immutable tags to prevent tag overwriting
- **KMS encryption** - Optional KMS encryption for ECR repositories
- **Scan on push** - Image scanning enabled by default
- **No egress by default** - Security groups created with no egress rules by default
- **Least privilege IAM** - Minimal permissions, Bedrock access disabled by default

---
## Contributing
contributions from the community are welcome! Please open issues or submit pull requests for improvements.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
