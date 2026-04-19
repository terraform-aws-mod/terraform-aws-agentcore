# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please report vulnerabilities by emailing the
maintainer directly or using GitHub's private vulnerability
reporting feature on this repository.

### What to include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response timeline

- **Acknowledgement:** Within 48 hours of receiving the report
- **Assessment:** Within 7 days, we will provide an initial assessment
- **Resolution:** We aim to release a fix within 30 days for confirmed vulnerabilities

## Security Best Practices for Users

When using this Terraform module:

1. **Use least-privilege IAM:** Keep
   `enable_bedrock_model_access = false` unless your agent
   invokes Bedrock models
2. **Encrypt ECR repositories:** Enable
   `create_ecr_kms_key = true` for production workloads
3. **Restrict network egress:** Use empty
   `security_group_egress_cidr_blocks` (default) and add
   only necessary egress rules
4. **Pin module versions:** Always specify a version
   constraint (e.g., `version = "~> 1.0"`)
5. **Review IAM policies:** Audit
   `iam_inline_policy_statements` and
   `iam_additional_policies` before applying
6. **Use immutable image tags:** The module enforces
   `IMMUTABLE` tag mutability on ECR repositories by default
7. **Rotate secrets:** Use AWS Secrets Manager with rotation
   for any secrets referenced in `secret_arns`

## Dependency Security

This module depends on:

- Terraform >= 1.3
- AWS Provider >= 5.0

Keep these dependencies up to date to ensure you receive the latest security patches.
