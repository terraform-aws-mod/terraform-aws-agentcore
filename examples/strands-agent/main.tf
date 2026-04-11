# Terraform configuration for deploying Strands Agent to AWS AgentCore

provider "aws" {
  region = var.aws_region
}

locals {
  dockerfile_path = "${path.module}/Dockerfile"
  context_path    = path.module
}

module "agentcore" {
  source = "../../"

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
  idle_session_timeout_seconds = var.idle_session_timeout
  max_session_lifetime_seconds = var.max_session_lifetime

  tags = merge(var.tags, {
    Application = "strands-agent-example"
    ManagedBy   = "terraform"
  })
}
