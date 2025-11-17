# This file defines the outputs for the root module.
# Outputs from the modules will be exposed here.

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "eks_role_arn" {
  description = "The ARN of the EKS IAM role."
  value       = module.eks-iam.eks_role_arn
}

output "eks_node_group_role_arn" {
  description = "The ARN of the EKS node group IAM role."
  value       = module.eks-iam.eks_node_group_role_arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API."
  value       = module.eks-cluster.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks-cluster.cluster_name
}

# output "grafana_url" {
#   description = "The URL for the Grafana dashboard."
#   value       = module.monitoring-ingress.grafana_url
# }
