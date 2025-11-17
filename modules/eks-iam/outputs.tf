# EKS IAM Module - outputs.tf

output "eks_role_arn" {
  description = "The ARN of the EKS IAM role."
  value       = aws_iam_role.eks.arn
}

output "eks_node_group_role_arn" {
  description = "The ARN of the EKS node group IAM role."
  value       = aws_iam_role.node_group.arn
}

output "eks_policy_attachment" {
  description = "The EKS policy attachment."
  value       = aws_iam_policy_attachment.eks_policy
}

output "node_worker_policy_attachment" {
  description = "The node worker policy attachment."
  value       = aws_iam_policy_attachment.node_worker_policy
}

output "node_cni_policy_attachment" {
  description = "The node CNI policy attachment."
  value       = aws_iam_policy_attachment.node_cni_policy
}

output "node_ecr_readonly_policy_attachment" {
  description = "The node ECR readonly policy attachment."
  value       = aws_iam_policy_attachment.node_ecr_readonly_policy
}

output "cluster_admin_policy_arn" {
  description = "The ARN of the cluster admin IAM policy."
  value       = aws_iam_policy.cluster_admin.arn
}

output "ebs_csi_driver_role_arn" {
  description = "The ARN of the IAM role for the EBS CSI driver."
  value       = aws_iam_role.ebs_csi_driver.arn
}
