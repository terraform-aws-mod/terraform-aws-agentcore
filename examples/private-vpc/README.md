# Private VPC Example

This example deploys the AgentCore runtime in VPC mode and lets the module create a dedicated security group.

## What This Example Shows

- VPC network mode (`network_mode = "VPC"`)
- Optional default VPC/subnet auto-discovery
- Module-managed security group
- Module-managed IAM role with optional Bedrock access
- Optional Secrets Manager access via `secret_arns`

## Usage

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

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `agent_runtime_name` | Runtime name | `pv_vpc_agent_name` |
| `container_image_uri` | Container image URI | `public.ecr.aws/amazonlinux/amazonlinux:2023` |
| `vpc_id` | VPC ID (uses default VPC when `null`) | `null` |
| `subnet_ids` | Subnet IDs (auto-discovers when empty) | `[]` |
| `secret_arns` | Secrets Manager ARNs to allow | `[]` |
| `tags` | Additional tags | `{}` |

## Notes

- This example consumes the published module address: `terraform-aws-mod/agentcore/aws`.
- Ensure the selected VPC has at least two usable subnets when running in VPC mode.
