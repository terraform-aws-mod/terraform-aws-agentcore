# Security Group Module

> **Internal submodule** - This module is used internally by the root `terraform-aws-agentcore` module. For most use cases, use the root module instead.

Terraform module for creating least-privilege security groups for AWS Bedrock AgentCore.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where the security group will be created | `string` | n/a | yes |
| create | Whether to create the security group | `bool` | `true` | no |
| security_group_name | Name of the security group | `string` | `null` | no |
| security_group_name_prefix | Prefix for security group name | `string` | `null` | no |
| use_name_prefix | Use name_prefix instead of name | `bool` | `false` | no |
| description | Description for the security group | `string` | `"Security group for Bedrock AgentCore runtime"` | no |
| revoke_rules_on_delete | Revoke all rules before deleting | `bool` | `true` | no |
| egress_cidr_blocks | IPv4 CIDR blocks for default egress | `list(string)` | `[]` | no |
| egress_ipv6_cidr_blocks | IPv6 CIDR blocks for default egress | `list(string)` | `[]` | no |
| egress_with_self | Allow egress to self | `bool` | `false` | no |
| vpc_endpoint_security_group_ids | VPC endpoint security group IDs for egress | `list(string)` | `[]` | no |
| additional_egress_rules | Additional egress rule objects | `list(object)` | `[]` | no |
| ingress_with_self | Allow ingress from self | `bool` | `false` | no |
| additional_ingress_rules | Additional ingress rule objects | `list(object)` | `[]` | no |
| tags | Tags applied to security group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | ID of the created security group |
| security_group_arn | ARN of the created security group |
| security_group_name | Name of the created security group |
| security_group_vpc_id | VPC ID of the security group |

## Security

- Default: No ingress rules (most restrictive)
- Default: No egress rules (most restrictive)
- Use `egress_cidr_blocks` or `vpc_endpoint_security_group_ids` to allow outbound traffic
- Supports VPC endpoints for private deployments
