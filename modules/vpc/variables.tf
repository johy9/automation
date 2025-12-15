variable "vpc_cidr" {
  description = "The IP range for the VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr value must be a valid CIDR block."
  }
}

variable "project_name" {
  description = "Project name to be used for tagging resources"
  type        = string
  default     = "learning-terraform"
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "availability_zone" {
  description = "The list of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidr" {
  description = "The list of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "The list of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Controls if a NAT Gateway is created for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Controls if a single NAT Gateway is used for all private subnets (true) or one per AZ (false)"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to be applied to all resources"
  type        = map(string)
  default     = {}
  validation {
    condition     = can(var.additional_tags["psi_environment"]) && can(var.additional_tags["psi_lifecycle"]) && can(var.additional_tags["psi_cost_center"])
    error_message = "Tags must contain at least 'psi_environment', 'psi_lifecycle', and 'psi_cost_center' keys."
  }
}