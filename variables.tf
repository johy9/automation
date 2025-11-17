# This file defines the input variables for the root module.

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "The environment must be either 'dev' or 'prod'."
  }
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "monitoring"
}

variable "grafana_domain_name" {
  description = "The domain name for the Grafana dashboard."
  type        = string
  default     = "grafana.your-domain.com" # Replace with your domain
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone."
  type        = string
  default     = "" # Replace with your Route 53 hosted zone ID
}

variable "acm_certificate_arn" {
  description = "The ARN of the existing ACM certificate."
  type        = string
  default     = "" # Replace with your certificate ARN
}
