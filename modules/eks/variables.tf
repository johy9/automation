variable "project_name" {
  description = "Project name to be used for tagging resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "cluster_version must follow the format 'major.minor' (e.g., '1.28', '1.29')."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones. Cross-account elastic network interfaces will be created in these subnets."
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs must be provided in different availability zones."
  }
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = []
  validation {
    condition     = !var.endpoint_public_access || length(var.public_access_cidrs) > 0
    error_message = "public_access_cidrs must not be empty when endpoint_public_access is true."
  }
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = optional(string, "ON_DEMAND")
    disk_size      = optional(number, 20)
  }))
  default = {}
}

variable "addons" {
  description = "Map of EKS add-ons to enable. Keys are add-on names (e.g., vpc-cni, coredns), values are versions or empty for default."
  type = map(object({
    version           = optional(string)
    resolve_conflicts = optional(string, "OVERWRITE")
  }))
  default = {
    vpc-cni            = {}
    coredns            = {}
    kube-proxy         = {}
    aws-ebs-csi-driver = {}
  }
}

variable "kms_key_id" {
  description = "KMS key ID for EKS cluster encryption. If not provided, a default AWS managed key will be used."
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
}

variable "encryption_resources" {
  description = "List of resources to encrypt with KMS"
  type        = list(string)
  default     = ["secrets"]
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to grant the cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
variable "enable_karpenter" {
  description = "Whether to create IAM roles and policies for Karpenter"
  type        = bool
  default     = false
}

variable "enable_lb_controller" {
  description = "Whether to create IAM roles and policies for AWS Load Balancer Controller"
  type        = bool
  default     = false
}
variable "enable_external_dns" {
  description = "Enable ExternalDNS IAM role and Pod Identity association"
  type        = bool
  default     = false
}

variable "enable_efs_driver" {
  description = "Enable EFS CSI Driver IAM role and Pod Identity association"
  type        = bool
  default     = false
}

variable "access_entries" {
  description = "Map of access entries. Key is the principal ARN."
  type = map(object({
    kubernetes_groups = optional(list(string), [])
    policy_associations = map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    }))
  }))
  default = {}
}
