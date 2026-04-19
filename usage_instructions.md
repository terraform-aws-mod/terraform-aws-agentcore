# Usage Instructions - Testing terraform-aws-agentcore Module

This guide walks you through testing the AgentCore Terraform
module on your AWS account.

---

## Prerequisites

### Required Tools

```bash
# Terraform >= 1.3
terraform version

# AWS CLI v2
aws --version
```

### AWS Account Setup

1. **AWS CLI Configuration**

   ```bash
   # Configure AWS credentials
   aws configure

   # Or use environment variables
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

2. **Verify Access**

   ```bash
   # Check your identity
   aws sts get-caller-identity
   ```

3. **Required IAM Permissions**
   Your IAM user/role needs permissions for:
   - ECR (create/delete repositories)
   - IAM (create/delete roles and policies)
   - EC2 (security groups, if using VPC mode)
   - Bedrock AgentCore (create/delete runtimes)
   - KMS (if using encryption)
   - CloudWatch Logs (for runtime logging)

---

## Quick Start - Basic Test (PUBLIC Mode)

### Step 1: Create Test Directory

```bash
mkdir -p ~/agentcore-test
cd ~/agentcore-test
```

### Step 2: Create main.tf

```hcl
# ~/agentcore-test/main.tf

provider "aws" {
  region = "us-east-1"
}

module "agentcore" {
  source = "../../"

  # Required
  agent_runtime_name  = "test-agentcore-runtime"
  container_image_uri = "public.ecr.aws/amazonlinux/amazonlinux:2023"

  # Network - PUBLIC mode (no VPC required)
  network_mode = "PUBLIC"

  # ECR - create repository
  create_ecr_repository = true
  ecr_force_delete      = true  # Allow cleanup even with images

  # IAM - create execution role
  create_iam_role             = true
  enable_bedrock_model_access = true

  # Lifecycle configuration
  runtime_lifecycle_configuration = {
    idle_runtime_session_timeout = 300
    max_lifetime                 = 1800
  }

  tags = {
    Environment = "test"
    Project     = "agentcore-module-test"
  }
}

# Outputs
output "runtime_arn" {
  value = module.agentcore.agent_runtime_arn
}

output "ecr_url" {
  value = module.agentcore.ecr_repository_url
}

output "iam_role_arn" {
  value = module.agentcore.iam_role_arn
}
```

### Step 3: Initialize and Plan

```bash
cd ~/agentcore-test

# Initialize
terraform init

# Review what will be created
terraform plan
```

### Step 4: Apply (Creates Real Resources)

```bash
# Apply - this creates AWS resources
terraform apply

# Type 'yes' when prompted
```

### Step 5: Verify Resources

```bash
# Check ECR repository
aws ecr describe-repositories --repository-names test-agentcore-runtime

# Check IAM role
aws iam get-role --role-name test-agentcore-runtime-execution

# Check AgentCore runtime
aws bedrock-agentcore list-agent-runtimes 2>/dev/null || echo "AgentCore API not available in this region"
```

### Step 6: Cleanup

```bash
# Destroy all created resources
terraform destroy

# Type 'yes' when prompted
```

---

## Advanced Test - VPC Mode

```hcl
# ~/agentcore-test-vpc/main.tf

provider "aws" {
  region = "us-east-1"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "agentcore" {
  source = "../../"

  agent_runtime_name  = "test-vpc-agentcore"
  container_image_uri = "public.ecr.aws/amazonlinux/amazonlinux:2023"

  # VPC Mode
  network_mode = "VPC"
  vpc_id       = data.aws_vpc.default.id
  subnet_ids   = slice(data.aws_subnets.default.ids, 0, 2)

  # Create security group with egress
  create_security_group             = true
  security_group_egress_cidr_blocks = ["0.0.0.0/0"]

  # ECR
  create_ecr_repository = true
  ecr_force_delete      = true

  # IAM
  create_iam_role             = true
  enable_bedrock_model_access = true

  tags = {
    Environment = "test"
    NetworkMode = "VPC"
  }
}

output "security_group_id" {
  value = module.agentcore.security_group_id
}
```

---

## Advanced Test - ECR with Docker Image Build

```hcl
module "agentcore" {
  source = "../../"

  agent_runtime_name  = "test-build-agentcore"
  container_image_uri = "placeholder:latest"  # Will be overridden by built image

  network_mode = "PUBLIC"

  # ECR - create repository and build image
  create_ecr_repository = true
  ecr_force_delete      = true

  # Enable image building
  ecr_build_image = true
  ecr_build_script_args = {
    dockerfile = "${path.module}/docker/Dockerfile"
    context    = "${path.module}/docker"
    tags       = "v1.0.0,latest"
    platform   = "linux/arm64"
  }

  # Rebuild when Dockerfile changes
  ecr_build_triggers = {
    dockerfile_hash = filesha256("${path.module}/docker/Dockerfile")
  }

  create_iam_role = true

  tags = {
    Environment = "test"
    BuildType   = "docker"
  }
}

output "ecr_image_uri" {
  value = module.agentcore.ecr_image_uri
}
```

---

## Using Internal Submodules Directly

While the root module is the recommended way to use this
module, you can also use the internal submodules directly
for specific use cases.

### ECR Only

```hcl
module "ecr_only" {
  source = "../../modules/ecr"

  repository_name = "test-ecr-standalone"
  force_delete    = true

  # No execution role - skip repository policy
  create_repository_policy = false

  tags = {
    Test = "ecr-only"
  }
}
```

### IAM Only

```hcl
data "aws_caller_identity" "current" {}

module "iam_only" {
  source = "../../modules/iam"

  role_name                   = "test-agentcore-role"
  aws_account_id              = data.aws_caller_identity.current.account_id
  enable_bedrock_model_access = true

  tags = {
    Test = "iam-only"
  }
}
```

---

## Testing Checklist

### Basic Functionality

- [ ] `terraform init` succeeds
- [ ] `terraform validate` passes
- [ ] `terraform plan` shows expected resources
- [ ] `terraform apply` creates resources without errors
- [ ] AgentCore runtime is created
- [ ] ECR repository is created with correct settings
- [ ] IAM role is created with expected policies
- [ ] `terraform destroy` removes all resources

### VPC Mode

- [ ] Security group is created when `create_security_group = true`
- [ ] Correct VPC and subnet IDs are passed to runtime
- [ ] Egress rules are applied correctly

### Image Build Features

- [ ] Built-in Docker script builds and pushes image
- [ ] Build triggers cause rebuild when source changes
- [ ] `ecr_image_uri` output contains correct image URI

---

## Troubleshooting

### Common Issues

1. **"AgentCore API not available"**
   - Bedrock AgentCore may not be GA in your region
   - Try `us-east-1` or `us-west-2`

2. **"Access Denied" errors**
   - Ensure your IAM user has required permissions
   - Check AWS credentials are configured

3. **"Resource already exists"**
   - Change `agent_runtime_name` to a unique value
   - Or delete existing resources first

4. **Terraform state issues**
   - Run `terraform init -upgrade` to refresh providers
   - Check `.terraform.lock.hcl` for version conflicts

### Debug Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# Check AWS CLI configuration
aws configure list

# Test ECR access
aws ecr get-login-password --region us-east-1

# List existing AgentCore runtimes
aws bedrock-agentcore list-agent-runtimes
```

---

## Resource Costs

**Estimated costs for testing:**

- ECR Repository: Free (storage costs ~$0.10/GB/month)
- IAM Role: Free
- Security Group: Free
- AgentCore Runtime: Varies by usage (check AWS pricing)

**Tip:** Always run `terraform destroy` after testing to avoid ongoing charges.

---

## Next Steps

After successful testing:

1. Review the `examples/` directory for more use cases
2. Customize variables for your production requirements
3. Set up CI/CD with the provided GitHub workflows
4. Consider enabling KMS encryption for production
