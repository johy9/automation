variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions to grant cluster access"
  type        = string
  default     = null
}

