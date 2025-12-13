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
