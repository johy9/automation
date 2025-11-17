# EKS IAM Module - variables.tf

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

variable "oidc_provider_url" {
  description = "The OIDC provider URL of the EKS cluster."
  type        = string
}
