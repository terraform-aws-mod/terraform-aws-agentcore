# Strands Agent Example for AWS AgentCore

A simple AI agent built with [Strands Agents](https://github.com/strands-agents/strands-agents)
framework, ready to deploy on AWS AgentCore runtime using `BedrockAgentCoreApp`.

## Features

- **AgentCore Native** - Uses `bedrock-agentcore` SDK for runtime compatibility
- **Strands Agent** - Powered by Strands Agents framework with Bedrock models
- **Custom Tools** - Calculator, current time, and echo tools
- **Terraform Ready** - Deploy with the terraform-aws-agentcore module
- **Object Variable Configuration** - Uses recommended dynamic block patterns

## Project Structure

```
examples/strands-agent/
├── src/
│   └── strands_agent_example/
│       ├── __init__.py
│       ├── agent.py      # Strands agent with Bedrock model
│       ├── server.py     # BedrockAgentCoreApp handler
│       └── tools.py      # Custom agent tools
├── terraform/
│   ├── main.tf           # AgentCore module usage
│   ├── variables.tf      # Configuration variables
│   ├── outputs.tf        # Output values
│   └── versions.tf       # Provider versions
├── Dockerfile            # Container image definition
├── pyproject.toml        # Dependencies (uv managed)
└── README.md
```

## Local Development

### Setup

```bash
# Create virtual environment with uv
uv venv .venv --python 3.12

# Activate virtual environment
source .venv/bin/activate

# Install dependencies
uv sync
```

### Run Locally

```bash
# Set AWS credentials
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret

# Run the AgentCore server
python -m strands_agent_example.server
```

## Deploy to AWS AgentCore

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- Docker (for image builds)
- **QEMU** (for cross-platform builds) - AWS AgentCore runtime requires `linux/arm64` images. If you are building on an `amd64`/`x86_64` host, you must enable QEMU user-space emulation:

  ```bash
  docker run --privileged --rm tonistiigi/binfmt --install all
  ```

  > **Note:** QEMU binfmt registrations are **not persistent** across Docker daemon restarts or system reboots. If you encounter `exec format error` during builds, re-run the command above.

### Module Usage Example

The example includes a complete Terraform configuration that deploys the Strands Agent using the `terraform-aws-agentcore` module. Here's the main configuration:

**main.tf:**
```hcl
provider "aws" {
  region = var.aws_region
}

locals {
  dockerfile_path = "${path.module}/../Dockerfile"
  context_path    = "${path.module}/.."
}

module "agentcore" {
  source = "AliMassoud/agentcore/aws"

  # Runtime identification
  agent_runtime_name  = var.agent_name
  container_image_uri = "${module.agentcore.ecr_repository_url}:${var.image_tag}"

  # Network mode
  network_mode = var.network_mode

  # VPC configuration (only used when network_mode = "VPC")
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  create_security_group = var.network_mode == "VPC"

  # ECR Repository - create and build image
  create_ecr_repository = true
  ecr_force_delete      = var.ecr_force_delete

  # Build the Docker image
  ecr_build_image = true
  ecr_build_script_args = {
    dockerfile = local.dockerfile_path
    context    = local.context_path
    tags       = var.image_tag
    platform   = "linux/arm64"
    use_cache  = "true"
    provenance = "false"
  }

  ecr_build_triggers = {
    dockerfile_hash = filesha256(local.dockerfile_path)
    pyproject_hash  = filesha256("${local.context_path}/pyproject.toml")
    source_hash     = sha256(join("", [for f in fileset("${local.context_path}/src", "**/*.py") : filesha256("${local.context_path}/src/${f}")]))
    image_tag       = var.image_tag
    platform        = "linux/arm64"
  }

  # IAM Role with Bedrock access (required for this agent that uses Bedrock)
  create_iam_role             = true
  enable_bedrock_model_access = true
  bedrock_model_arns          = var.bedrock_model_arns

  # Runtime environment variables
  runtime_environment_variables = {
    BEDROCK_MODEL_ID = var.bedrock_model_id
    AWS_REGION       = var.aws_region
    LOG_LEVEL        = var.log_level
  }

  # Lifecycle settings
  idle_session_timeout_seconds = var.idle_session_timeout_seconds
  max_session_lifetime_seconds = var.max_session_lifetime_seconds

  tags = merge(var.tags, {
    Application = "strands-agent-example"
    ManagedBy   = "terraform"
  })
}
```

### Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
```

### Configuration

Create a `terraform.tfvars` file:

```hcl
agent_name       = "my_strands_agent"
aws_region       = "us-east-1"
image_tag        = "v1.0.0"
bedrock_model_id = "us.anthropic.claude-sonnet-4-20250514-v1:0"

# Optional: VPC mode
network_mode = "VPC"
vpc_id       = "vpc-12345678"
subnet_ids   = ["subnet-111", "subnet-222"]
```

### Advanced Configuration with Object Variables

The terraform-aws-agentcore module supports **object variables** for flexible configuration:

```hcl
module "agentcore" {
  source = "AliMassoud/agentcore/aws"

  # ... required variables ...

  # ECR image scanning (set to null to disable)
  ecr_image_scanning_configuration = {
    scan_on_push = true
  }

  # ECR encryption (null = default AES256, or specify KMS)
  ecr_encryption_configuration = {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:123456789012:key/..."
  }

  # Runtime lifecycle (set to null to omit block)
  runtime_lifecycle_configuration = {
    idle_runtime_session_timeout = 600   # 10 minutes
    max_lifetime                 = 7200  # 2 hours
  }
}
```

### Cleanup

```bash
terraform destroy
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_REGION` | AWS region | `us-east-1` |
| `BEDROCK_MODEL_ID` | Bedrock model to use | `us.anthropic.claude-sonnet-4-20250514-v1:0` |
| `LOG_LEVEL` | Logging level | `INFO` |

## Agent Tools

| Tool | Description |
|------|-------------|
| `get_current_time` | Returns current UTC time in ISO format |
| `calculate` | Evaluates mathematical expressions safely |
| `echo` | Echoes back messages (for testing) |

## Configuration Reference

### Object Variables

| Variable | Description | Type |
|----------|-------------|------|
| `ecr_image_scanning_configuration` | Image scanning config object | `object({scan_on_push = bool})` |
| `ecr_encryption_configuration` | Encryption config object | `object({encryption_type = string, kms_key = optional(string)})` |
| `runtime_lifecycle_configuration` | Runtime lifecycle object | `object({idle_runtime_session_timeout = number, max_lifetime = number})` |

Set any of these to `null` to omit the corresponding configuration block entirely.

## Authors

Module is maintained by Ali MASSOUD.
contributions from the community are welcome! Please open issues or submit pull requests for improvements.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
