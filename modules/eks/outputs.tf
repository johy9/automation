output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = try(aws_eks_cluster.this.certificate_authority[0].data, null)
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = try(aws_eks_cluster.this.identity[0].oidc[0].issuer, null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}

output "node_group_arns" {
  description = "List of ARNs of the EKS Node Groups"
  value       = { for k, v in aws_eks_node_group.this : k => v.arn }
}

output "node_group_role_arn" {
  description = "IAM Role ARN for the Node Groups"
  value       = try(aws_iam_role.node_group.arn, null)
}

output "karpenter_controller_role_arn" {
  description = "ARN of the IAM role for Karpenter Controller"
  value       = try(aws_iam_role.karpenter_controller[0].arn, null)
}

output "karpenter_node_role_name" {
  description = "Name of the IAM role for Karpenter Nodes"
  value       = try(aws_iam_role.karpenter_node[0].name, null)
}

output "karpenter_node_instance_profile_name" {
  description = "Name of the IAM Instance Profile for Karpenter Nodes"
  value       = try(aws_iam_instance_profile.karpenter_node[0].name, null)
}

output "lb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = try(aws_iam_role.lb_controller[0].arn, null)
}

output "efs_file_system_id" {
  description = "ID of the EFS File System"
  value       = var.enable_efs_driver ? aws_efs_file_system.this[0].id : ""
}

output "vpc_id" {
  description = "The VPC ID where the cluster is deployed"
  value       = aws_eks_cluster.this.vpc_config[0].vpc_id
}

output "cluster_security_group_id" {
  description = "Security Group ID attached to the EKS Cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
