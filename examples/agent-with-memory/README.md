# Memory Agent Example for AWS AgentCore

A Strands AI agent with persistent memory, deployed on AWS
AgentCore runtime using `BedrockAgentCoreApp` and the
`aws_bedrockagentcore_memory` resource.

## Features

- **AgentCore Memory** - Persistent memory resource for
  retaining context across sessions
- **AgentCore Native** - Uses `bedrock-agentcore` SDK for runtime compatibility
- **Strands Agent** - Powered by Strands Agents framework with Bedrock models
- **Custom Tools** - Calculator, current time, and echo tools
- **Terraform Ready** - Deploy with the terraform-aws-agentcore module
- **Optional KMS Encryption** - Encrypt memory with a dedicated KMS key

## Project Structure

```text
examples/agent-with-memory/
├── src/
│   └── memory_agent_example/
│       ├── __init__.py
│       ├── agent.py      # Strands agent with memory-aware prompt
│       ├── server.py     # BedrockAgentCoreApp handler
│       └── tools.py      # Custom agent tools
├── terraform/
│   ├── main.tf           # AgentCore module with memory enabled
│   ├── variables.tf      # Configuration variables
│   ├── outputs.tf        # Output values (includes memory ARN/ID)
│   └── versions.tf       # Provider versions
├── Dockerfile            # Container image definition
├── pyproject.toml        # Dependencies (uv managed)
├── invoke_agent.py       # Agent invocation script
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
python -m memory_agent_example.server
```

## Deploy to AWS AgentCore

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.0
- Docker (for image builds)
- **QEMU** (for cross-platform builds) - AWS AgentCore
  runtime requires `linux/arm64` images:

  ```bash
  docker run --privileged --rm tonistiigi/binfmt --install all
  ```

### Deploy

```bash
cd terraform

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
agent_name       = "my_memory_agent"
aws_region       = "us-east-1"
image_tag        = "v1.0.0"
bedrock_model_id = "us.anthropic.claude-sonnet-4-20250514-v1:0"

# Memory configuration
memory_event_expiry_duration = 60   # Keep memory events for 60 days
create_memory_kms_key        = true  # Encrypt memory with a dedicated KMS key

# Optional: VPC mode
network_mode = "VPC"
vpc_id       = "vpc-12345678"
subnet_ids   = ["subnet-111", "subnet-222"]
```

### Key Differences from strands-agent Example

This example adds:

| Feature | strands-agent | agent-with-memory |
|---------|---------------|--------------|
| `create_memory` | No | Yes |
| `memory_event_expiry_duration` | N/A | Configurable (default 30 days) |
| `create_memory_kms_key` | N/A | Optional KMS encryption |
| Memory outputs | N/A | `memory_arn`, `memory_id` |

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

## Authors

Module is maintained by Ali MASSOUD.

## License

This project is licensed under the Apache License 2.0 -
see the [LICENSE](../../LICENSE) file for details.
