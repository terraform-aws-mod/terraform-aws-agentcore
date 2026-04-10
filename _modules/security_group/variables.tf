# Purpose: Define inputs for optional AgentCore security group creation.

################################################################################
# Security Group Configuration
################################################################################

variable "create" {
  description = "Whether to create the security group."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Name of the security group."
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = "Prefix for security group name. Mutually exclusive with security_group_name."
  type        = string
  default     = null
}

variable "use_name_prefix" {
  description = "Whether to use name_prefix instead of name."
  type        = bool
  default     = false
}

variable "description" {
  description = "Description for the security group."
  type        = string
  default     = "Security group for Bedrock AgentCore runtime"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}

variable "revoke_rules_on_delete" {
  description = "Revoke all rules before deleting the security group."
  type        = bool
  default     = true
}

################################################################################
# Egress Rules Configuration
################################################################################

variable "egress_cidr_blocks" {
  description = "IPv4 CIDR blocks for default egress rule. Empty list for most restrictive. Use VPC endpoint egress for private deployments."
  type        = list(string)
  default     = []
}

variable "egress_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks for default egress rule. Empty list for most restrictive."
  type        = list(string)
  default     = []
}

variable "egress_with_self" {
  description = "Allow egress traffic to the security group itself."
  type        = bool
  default     = false
}

variable "vpc_endpoint_security_group_ids" {
  description = "Security group IDs of VPC endpoints to allow egress to. Used for private/restricted deployments."
  type        = list(string)
  default     = []
}

variable "additional_egress_rules" {
  description = "Additional egress rule objects."
  type = list(object({
    description                   = optional(string)
    from_port                     = number
    to_port                       = number
    protocol                      = string
    cidr_blocks                   = optional(list(string), [])
    ipv6_cidr_blocks              = optional(list(string), [])
    prefix_list_ids               = optional(list(string), [])
    destination_security_group_id = optional(string)
    self                          = optional(bool, false)
  }))
  default = []
}

################################################################################
# Ingress Rules Configuration
################################################################################

variable "ingress_with_self" {
  description = "Allow ingress traffic from the security group itself."
  type        = bool
  default     = false
}

variable "additional_ingress_rules" {
  description = "Optional list of additional ingress rule objects."
  type = list(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    ipv6_cidr_blocks         = optional(list(string), [])
    prefix_list_ids          = optional(list(string), [])
    source_security_group_id = optional(string)
    self                     = optional(bool, false)
  }))
  default = []
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "Tags applied to security group resources."
  type        = map(string)
  default     = {}
}
