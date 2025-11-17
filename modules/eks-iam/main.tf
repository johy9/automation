# EKS IAM Module - main.tf

# --- EKS IAM Role ---
resource "aws_iam_role" "eks" {
  name = "${var.project_name}-${var.environment}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy_attachment" "eks_policy" {
  name       = "${var.project_name}-${var.environment}-eks-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks.name]
}

resource "aws_iam_policy_attachment" "eks_vpc_resource_controller_policy" {
  name       = "${var.project_name}-${var.environment}-eks-vpc-rc-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  roles      = [aws_iam_role.eks.name]
}

# --- EKS Node Group IAM Role ---
resource "aws_iam_role" "node_group" {
  name = "${var.project_name}-${var.environment}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy_attachment" "node_worker_policy" {
  name       = "${var.project_name}-${var.environment}-node-worker-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles      = [aws_iam_role.node_group.name]
}

resource "aws_iam_policy_attachment" "node_cni_policy" {
  name       = "${var.project_name}-${var.environment}-node-cni-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.node_group.name]
}

resource "aws_iam_policy_attachment" "node_ecr_readonly_policy" {
  name       = "${var.project_name}-${var.environment}-node-ecr-ro-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.node_group.name]
}

# --- IAM Policy for Cluster Admin ---
resource "aws_iam_policy" "cluster_admin" {
  name        = "${var.project_name}-${var.environment}-cluster-admin-policy"
  description = "Provides administrative access to the EKS cluster."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# --- IAM OIDC Provider for IRSA ---
resource "aws_iam_openid_connect_provider" "main" {
  url             = var.oidc_provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

  tags = var.tags
}

# --- IAM Role for EBS CSI Driver ---
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.project_name}-${var.environment}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_provider_url, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy_attachment" "ebs_csi_driver_policy" {
  name       = "${var.project_name}-${var.environment}-ebs-csi-driver-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles      = [aws_iam_role.ebs_csi_driver.name]
}

# --- Data Sources ---
data "tls_certificate" "eks" {
  url = var.oidc_provider_url
}

data "aws_caller_identity" "current" {}