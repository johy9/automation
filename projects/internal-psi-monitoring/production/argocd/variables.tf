variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
}
variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.3"
}


variable "controller_replicas" {
  description = "Application controller replicas"
  type        = number
  default     = 3
}

variable "server_replicas" {
  description = "Server replicas"
  type        = number
  default     = 3
}

variable "repo_server_replicas" {
  description = "Repo server replicas"
  type        = number
  default     = 3
}

variable "redis_ha_replicas" {
  description = "Redis HA replicas"
  type        = number
  default     = 3
}

variable "applicationset_replicas" {
  description = "ApplicationSet controller replicas"
  type        = number
  default     = 2
}

variable "controller_resources" {
  description = "Resource requests/limits for controller"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "500m"
      memory = "1Gi"
    }
    limits = {
      cpu    = "1000m"
      memory = "2Gi"
    }
  }
}

variable "server_resources" {
  description = "Resource requests/limits for server"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}

variable "repo_server_resources" {
  description = "Resource requests/limits for repo server"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
  }
}

variable "argocd_domain" {
  description = "Domain for ArgoCD UI"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
  default     = ""
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = false
}

variable "enable_okta_auth" {
  description = "Enable Okta OIDC authentication"
  type        = bool
  default     = true
}

variable "okta_issuer_url" {
  description = "Okta issuer URL"
  type        = string
}

variable "okta_client_id" {
  description = "Okta client ID"
  type        = string
  sensitive   = true
}

variable "okta_client_secret" {
  description = "Okta client secret"
  type        = string
  sensitive   = true
}

variable "enable_github_auth" {
  description = "Enable GitHub OAuth authentication"
  type        = bool
  default     = false
}

variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "github_client_id" {
  description = "GitHub client ID"
  type        = string
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub client secret"
  type        = string
  sensitive   = true
}

variable "admin_groups" {
  description = "Okta groups for admin access"
  type        = list(string)
  default     = ["argocd-admins"]
}

variable "developer_groups" {
  description = "Okta groups for developer access"
  type        = list(string)
  default     = ["argocd-developers"]
}

variable "readonly_groups" {
  description = "Okta groups for read-only access"
  type        = list(string)
  default     = ["argocd-readonly"]
}

variable "enable_metrics" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = true
}

variable "enable_notifications" {
  description = "Enable ArgoCD notifications"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}





