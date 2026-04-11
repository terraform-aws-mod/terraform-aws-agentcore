# Strands Agent Terraform Example

Terraform configuration for deploying the Strands Agent example with the published AgentCore module.

## Module Source

This example uses:

- `AliMassoud/agentcore/aws`

## Usage

From this directory:

```bash
terraform init
terraform plan
terraform apply
```

To destroy:

```bash
terraform destroy
```

## Inputs

See [variables.tf](variables.tf) for the full set of options. Common variables:

- `agent_name`
- `aws_region`
- `image_tag`
- `network_mode`
- `bedrock_model_id`

## Outputs

See [outputs.tf](outputs.tf) for emitted values including runtime and ECR details.
