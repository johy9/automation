# EKS Cluster Module - variables.tf

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

variable "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  type        = list(string)
}

variable "eks_role_arn" {
  description = "The ARN of the EKS IAM role."
  type        = string
}

variable "eks_node_group_role_arn" {
  description = "The ARN of the EKS node group IAM role."
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}

variable "node_group_instance_types" {
  description = "The instance types for the EKS node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "The desired number of worker nodes."
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "The minimum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "The maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_group_disk_size" {
  description = "The disk size in GiB for the worker nodes."
  type        = number
  default     = 20
}

variable "eks_policy_attachment" {
  description = "The EKS policy attachment."
  type        = any
}

variable "node_worker_policy_attachment" {
  description = "The node worker policy attachment."
  type        = any
}

variable "node_cni_policy_attachment" {
  description = "The node CNI policy attachment."
  type        = any
}

variable "node_ecr_readonly_policy_attachment" {
  description = "The node ECR readonly policy attachment."
  type        = any
}

variable "ebs_csi_driver_role_arn" {
  description = "The ARN of the IAM role for the EBS CSI driver."
  type        = string
}
