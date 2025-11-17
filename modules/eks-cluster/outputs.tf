# EKS Cluster Module - outputs.tf

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's Kubernetes API."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "oidc_provider_url" {
  description = "The OIDC provider URL for the EKS cluster."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "eks_security_group_id" {
  description = "The ID of the EKS security group."
  value       = aws_security_group.eks.id
}
