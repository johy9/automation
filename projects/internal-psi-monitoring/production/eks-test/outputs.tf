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

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter Controller"
  value       = module.eks.karpenter_controller_role_arn
}

output "karpenter_node_role_name" {
  description = "Name of the IAM role for Karpenter Nodes"
  value       = module.eks.karpenter_node_role_name
}

output "lb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.eks.lb_controller_role_arn
}
