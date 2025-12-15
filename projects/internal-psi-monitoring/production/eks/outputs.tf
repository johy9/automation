output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "Kubernetes Cluster ARN"
  value       = module.eks.cluster_arn
}

output "configure_kubectl" {
  description = "Configure kubectl"
  value       = "aws eks --region us-east-2 update-kubeconfig --name ${module.eks.cluster_name}"
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "karpenter_node_role_name" {
  description = "IAM Role name for Karpenter nodes"
  value       = module.eks.karpenter_node_role_name
}

output "efs_file_system_id" {
  description = "ID of the EFS File System"
  value       = module.eks.efs_file_system_id
}

output "vpc_id" {
  description = "The VPC ID where the cluster is deployed"
  value       = module.eks.vpc_id
}
