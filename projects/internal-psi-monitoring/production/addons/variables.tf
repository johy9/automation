variable "project_name" {
  description = "Project name"
  type        = string
  default     = "internal-psi-monitoring"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "1.0.6" # Using a recent stable version (post-v1.0)
}

variable "lb_controller_version" {
  description = "Version of AWS Load Balancer Controller to install"
  type        = string
  default     = "1.9.1"
}

variable "external_dns_version" {
  description = "Version of ExternalDNS to install"
  type        = string
  default     = "1.14.5"
}

variable "domain_filter" {
  description = "Route53 domain filter (e.g., example.com)"
  type        = string
  default     = "" # User must supply this
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID to manage (optional, but recommended for precision)"
  type        = string
  default     = ""
}
