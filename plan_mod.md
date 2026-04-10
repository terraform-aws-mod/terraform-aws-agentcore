# terraform-aws-agentcore Module - Implementation Plan

Production-grade Terraform module for AWS Bedrock AgentCore runtime with full submodule flexibility for Terraform Registry publication.

---

## Current State Assessment

### What Exists
- **Root module**: Orchestrates 4 submodules (iam, ecr, security_group, agentcore)
- **Submodules**: Basic implementations present but missing full parameter exposure
- **Examples**: `basic/` and `private-vpc/` scaffolded
- **CI/CD**: GitHub workflows for pre-commit and semantic-release
- **Docs**: README.md with basic usage

### Gaps for Terraform Registry Readiness
1. **Submodule parameters not fully exposed** at root level (lifecycle policies, KMS details, SG rules)
2. **Missing `create` toggle** on agentcore submodule
3. **No native provider resource** - using CLI fallback (acceptable, but needs documentation)
4. **ECR submodule** missing: force_delete, registry scanning config, replication
5. **IAM submodule** missing: role path, permissions boundary, role description, inline policy customization
6. **Security Group submodule** missing: description, name_prefix, additional egress rules
7. **No `multi-agent` example** for advanced use cases
8. **No tests** (tests/ directory empty)
9. **Missing**: CONTRIBUTING.md, LICENSE, .pre-commit-config.yaml
10. **Outputs** incomplete - missing ECR ARN, KMS key ARN, IAM role name, SG ARN

---

## Phase 1: Submodule Parameter Expansion

**Goal**: Expose all meaningful AWS resource parameters through submodule variables.

### 1.1 ECR Submodule Enhancement
- [ ] Add `create` toggle variable
- [ ] Add `force_delete` variable for repository deletion
- [ ] Add `scan_type` variable (BASIC, ENHANCED)
- [ ] Add `scan_on_push` variable (currently hardcoded true)
- [ ] Add custom lifecycle policy variable (override default)
- [ ] Add `registry_id` output
- [ ] Add replication configuration support
- [ ] Add pull-through cache support (optional)
- [ ] Add repository policy customization (merge user statements)
- [ ] Expose KMS key deletion window, rotation, policy

### 1.2 IAM Submodule Enhancement
- [ ] Add `create` toggle variable
- [ ] Add `role_path` variable (default "/")
- [ ] Add `role_description` variable
- [ ] Add `permissions_boundary_arn` variable
- [ ] Add `max_session_duration` variable
- [ ] Add `force_detach_policies` variable
- [ ] Add `role_name_prefix` variable (alternative to role_name)
- [ ] Add `inline_policy_statements` variable (list of statement objects)
- [ ] Add `trusted_role_arns` variable (cross-account assume)
- [ ] Add `trusted_role_services` variable (additional services)
- [ ] Add `role_requires_mfa` variable
- [ ] Expose role unique_id, create_date outputs
- [ ] Add SSM Parameter Store read permissions option
- [ ] Add S3 bucket access option (for agent artifacts)
- [ ] Add DynamoDB access option (for agent state)
- [ ] Add SQS/SNS access option (for agent messaging)
- [ ] Add Lambda invoke option (for tool execution)

### 1.3 Security Group Submodule Enhancement
- [ ] Add `create` toggle variable
- [ ] Add `description` variable (currently hardcoded)
- [ ] Add `name_prefix` variable (alternative to name)
- [ ] Add `use_name_prefix` toggle
- [ ] Add `additional_egress_rules` variable (match ingress structure)
- [ ] Add `egress_with_self` variable
- [ ] Add `ingress_with_self` variable
- [ ] Add `create_timeout` and `delete_timeout` variables
- [ ] Add security_group_arn output
- [ ] Add computed_ingress_rules output
- [ ] Add computed_egress_rules output

### 1.4 AgentCore Submodule Enhancement
- [ ] Add `create` toggle variable
- [ ] Add `description` variable for runtime
- [ ] Add `environment_variables` variable (map passed to runtime)
- [ ] Add `authorization_config` block variable (for OAUTH mode)
- [ ] Add `logging_config` variable (CloudWatch log group customization)
- [ ] Add `custom_runtime_endpoint` output
- [ ] Add `runtime_status` output (if retrievable)
- [ ] Add timeouts for create/update/delete operations
- [ ] Document CLI version requirements

---

## Phase 2: Root Module Full Flexibility

**Goal**: Surface all submodule parameters at root level with sensible grouping.

### 2.1 Variable Organization
Create variable groups with clear prefixes:
- `ecr_*` - All ECR-related variables
- `iam_*` - All IAM-related variables  
- `sg_*` - All Security Group variables
- `runtime_*` - All AgentCore runtime variables
- Top-level: `agent_runtime_name`, `tags`, `network_mode`

### 2.2 New Root Variables
```hcl
# ECR Variables
variable "ecr_force_delete" {}
variable "ecr_scan_type" {}
variable "ecr_scan_on_push" {}
variable "ecr_lifecycle_policy" {}
variable "ecr_repository_policy_statements" {}
variable "ecr_enable_replication" {}
variable "ecr_replication_configuration" {}

# IAM Variables
variable "iam_role_name" {}
variable "iam_role_path" {}
variable "iam_role_description" {}
variable "iam_permissions_boundary_arn" {}
variable "iam_max_session_duration" {}
variable "iam_inline_policy_statements" {}
variable "iam_trusted_role_arns" {}
variable "iam_enable_ssm_access" {}
variable "iam_ssm_parameter_arns" {}
variable "iam_enable_s3_access" {}
variable "iam_s3_bucket_arns" {}
variable "iam_enable_dynamodb_access" {}
variable "iam_dynamodb_table_arns" {}
variable "iam_enable_sqs_access" {}
variable "iam_sqs_queue_arns" {}
variable "iam_enable_lambda_invoke" {}
variable "iam_lambda_function_arns" {}

# Security Group Variables
variable "sg_description" {}
variable "sg_use_name_prefix" {}
variable "sg_name_prefix" {}
variable "sg_ingress_rules" {}
variable "sg_egress_rules" {}
variable "sg_ingress_with_self" {}
variable "sg_egress_with_self" {}

# Runtime Variables
variable "runtime_description" {}
variable "runtime_environment_variables" {}
variable "runtime_authorization_config" {}
variable "runtime_logging_config" {}
```

### 2.3 Output Expansion
```hcl
# ECR Outputs
output "ecr_repository_arn" {}
output "ecr_registry_id" {}
output "ecr_kms_key_arn" {}
output "ecr_kms_key_id" {}

# IAM Outputs
output "iam_role_name" {}
output "iam_role_unique_id" {}
output "iam_role_policy_arns" {}

# Security Group Outputs
output "security_group_arn" {}
output "security_group_name" {}
output "security_group_vpc_id" {}

# Runtime Outputs
output "agent_runtime_id" {}
output "agent_runtime_endpoint" {}
output "agent_runtime_status" {}
```

---

## Phase 3: Examples Completion

**Goal**: Provide comprehensive, copy-paste-ready examples.

### 3.1 Basic Example Enhancement
- [ ] Add all commonly used optional parameters
- [ ] Add comments explaining each parameter
- [ ] Add outputs.tf
- [ ] Add README.md with use case description

### 3.2 Private VPC Example Enhancement
- [ ] Complete VPC setup with proper subnet references
- [ ] Show security group creation vs bring-your-own
- [ ] Add VPC endpoints example (ECR, Bedrock, Secrets Manager)
- [ ] Add outputs.tf
- [ ] Add README.md

### 3.3 Multi-Agent Example (New)
- [ ] Create examples/multi-agent/
- [ ] Show multiple runtime instances
- [ ] Demonstrate shared IAM role pattern
- [ ] Demonstrate shared ECR repository pattern
- [ ] Show environment-based naming
- [ ] Add outputs.tf
- [ ] Add README.md

### 3.4 Complete Example (New)
- [ ] Create examples/complete/
- [ ] Enable ALL features: KMS, X-Ray, Secrets, S3, DynamoDB
- [ ] Show custom lifecycle policies
- [ ] Show custom IAM statements
- [ ] Show custom security group rules
- [ ] Add outputs.tf
- [ ] Add README.md

### 3.5 Standalone Submodule Examples
- [ ] Create examples/ecr-only/
- [ ] Create examples/iam-only/
- [ ] Each with README explaining standalone use

---~~~~

## Phase 4: Documentation & Community

**Goal**: Complete documentation for Terraform Registry and open-source contribution.

### 4.1 README Enhancement
- [ ] Add architecture diagram (ASCII or linked image)
- [ ] Add feature matrix table
- [ ] Add "Why this module?" section
- [ ] Add troubleshooting section
- [ ] Add FAQ section
- [ ] Add migration guide (from manual setup)
- [ ] Generate inputs/outputs tables with terraform-docs

### 4.2 Submodule Documentation
- [ ] Add README.md to _modules/ecr/
- [ ] Add README.md to _modules/iam/
- [ ] Add README.md to _modules/security_group/
- [ ] Add README.md to modules/agentcore/
- [ ] Each with standalone usage examples

### 4.3 Community Files
- [ ] Add LICENSE (Apache 2.0 recommended)
- [ ] Add CONTRIBUTING.md
- [ ] Add CODE_OF_CONDUCT.md
- [ ] Add SECURITY.md
- [ ] Add .github/ISSUE_TEMPLATE/ (bug, feature request)
- [ ] Add .github/PULL_REQUEST_TEMPLATE.md

### 4.4 Pre-commit Configuration
- [ ] Create .pre-commit-config.yaml
- [ ] Include: terraform fmt, terraform validate, tflint
- [ ] Include: terraform-docs (auto-generate README tables)
- [ ] Include: checkov, trivy (security scanning)
- [ ] Include: end-of-file-fixer, trailing-whitespace

---

## Phase 6: CI/CD Polish

**Goal**: Production-grade automation pipeline.

### 6.1 GitHub Actions Enhancement
- [ ] Add Terraform Cloud/Enterprise integration option
- [ ] Add AWS OIDC authentication (no static credentials)
- [ ] Add matrix testing (multiple TF versions)
- [ ] Add cost estimation with Infracost
- [ ] Add documentation generation step
- [ ] Add security scanning results upload to GitHub Security tab

### 6.2 Release Automation
- [ ] Verify semantic-release configuration
- [ ] Add CHANGELOG.md template
- [ ] Configure GitHub Release notes generation
- [ ] Add Terraform Registry webhook (if needed)

### 6.3 Branch Protection
- [ ] Document required branch protection rules
- [ ] Document required status checks

---

## Phase 7: Registry Publication

**Goal**: Publish to Terraform Registry with full compliance.

### 7.1 Registry Requirements Checklist
- [ ] Repository named `terraform-aws-agentcore` (terraform-<PROVIDER>-<NAME>)
- [ ] Public GitHub repository
- [ ] Valid LICENSE file
- [ ] Standard module structure verified
- [ ] versions.tf with required_providers
- [ ] All examples validate successfully

### 7.2 Publication Steps
- [ ] Connect GitHub to Terraform Registry
- [ ] Verify module appears correctly
- [ ] Test module installation from registry
- [ ] Create v1.0.0 release tag

### 7.3 Post-Publication
- [ ] Add Terraform Registry badge to README
- [ ] Add version badge
- [ ] Add license badge
- [ ] Monitor for issues and feedback

---

## Implementation Priority Order

### Sprint 1: Core Flexibility (Phases 1 & 2)
1. ECR submodule enhancement
2. IAM submodule enhancement
3. Security Group submodule enhancement
4. AgentCore submodule enhancement
5. Root module variable/output expansion

### Sprint 2: Examples & Docs (Phases 3 & 5)
1. Enhance existing examples
2. Create multi-agent example
3. Create complete example
4. Submodule READMEs
5. Root README enhancement

### Sprint 3: Testing & CI (Phases 4 & 6)
1. Unit tests (tofu test with mocks)
2. Integration tests (tofu test with real AWS)
3. Pre-commit configuration
4. CI pipeline enhancement

### Sprint 4: Publication (Phase 7)
1. Final review and cleanup
2. Registry publication
3. v1.0.0 release

---

## Success Criteria

- [ ] All submodule parameters accessible from root module
- [ ] `terraform validate` passes on all examples
- [ ] `terraform-docs` generates complete documentation
- [ ] All tests pass in CI
- [ ] No HIGH/CRITICAL findings in security scans
- [ ] Module installable from Terraform Registry
- [ ] Clear upgrade path documented

---

## Notes

- AWS Bedrock AgentCore is a new service; monitor for native Terraform provider resource availability
- CLI fallback approach is acceptable but should be replaced when provider support lands
- Keep backwards compatibility in mind for v1.x releases
