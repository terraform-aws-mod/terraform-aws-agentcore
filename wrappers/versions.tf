# Purpose: Define Terraform and provider version constraints for the module.
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.34"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.79.0"
    }
  }

  # provider_meta "aws" {
  #   user_agent = [
  #     "github.com/"
  #   ]
  # }
}
