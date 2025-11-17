# Monitoring Ingress Module - variables.tf

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., staging, production)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  type        = list(string)
}

variable "grafana_domain_name" {
  description = "The domain name for the Grafana dashboard."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone."
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the existing ACM certificate."
  type        = string
}
