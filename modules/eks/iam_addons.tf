# ------------------------------------------------------------------------------
# AWS Load Balancer Controller Role (Pod Identity)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "lb_controller" {
  count = var.enable_lb_controller ? 1 : 0
  name  = "${var.project_name}-${var.environment}-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-lb-controller-role"
    }
  )
}

resource "aws_iam_policy" "lb_controller" {
  count       = var.enable_lb_controller ? 1 : 0
  name        = "${var.project_name}-${var.environment}-lb-controller-policy"
  description = "Policy for AWS Load Balancer Controller"

  # This policy is large, so we typically fetch it from the official URL or file.
  # For simplicity/stability, we'll use a file in the module.
  policy = file("${path.module}/policies/lb_controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = var.enable_lb_controller ? 1 : 0
  policy_arn = aws_iam_policy.lb_controller[0].arn
  role       = aws_iam_role.lb_controller[0].name
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  count           = var.enable_lb_controller ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller[0].arn
}

# ------------------------------------------------------------------------------
# Karpenter Controller Role (Pod Identity)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "karpenter_controller" {
  count = var.enable_karpenter ? 1 : 0
  name  = "${var.project_name}-${var.environment}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-karpenter-controller-role"
    }
  )
}

# Karpenter Controller Policy
# Allows Karpenter to launch instances, describe resources, etc.
resource "aws_iam_policy" "karpenter_controller" {
  count       = var.enable_karpenter ? 1 : 0
  name        = "${var.project_name}-${var.environment}-karpenter-controller-policy"
  description = "Policy for Karpenter Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = "ec2:TerminateInstances"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.karpenter_node[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:GetInstanceProfile"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = aws_eks_cluster.this.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
  role       = aws_iam_role.karpenter_controller[0].name
}

resource "aws_eks_pod_identity_association" "karpenter" {
  count           = var.enable_karpenter ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller[0].arn
}

# ------------------------------------------------------------------------------
# Karpenter Node Role (Instance Profile)
# ------------------------------------------------------------------------------
# This is the role that the EC2 instances created by Karpenter will assume.
resource "aws_iam_role" "karpenter_node" {
  count = var.enable_karpenter ? 1 : 0
  name  = "${var.project_name}-${var.environment}-karpenter-node-role"

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

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-karpenter-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node[0].name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node[0].name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_registry" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node[0].name
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  count      = var.enable_karpenter ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_node[0].name
}

# Instance Profile for Karpenter Nodes
resource "aws_iam_instance_profile" "karpenter_node" {
  count = var.enable_karpenter ? 1 : 0
  name  = "${var.project_name}-${var.environment}-karpenter-node-profile"
  role  = aws_iam_role.karpenter_node[0].name
}

# ------------------------------------------------------------------------------
# ExternalDNS Role (Pod Identity)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.project_name}-${var.environment}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-external-dns-role"
    }
  )
}

resource "aws_iam_policy" "external_dns" {
  count       = var.enable_external_dns ? 1 : 0
  name        = "${var.project_name}-${var.environment}-external-dns-policy"
  description = "Policy for ExternalDNS to manage Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  policy_arn = aws_iam_policy.external_dns[0].arn
  role       = aws_iam_role.external_dns[0].name
}

resource "aws_eks_pod_identity_association" "external_dns" {
  count           = var.enable_external_dns ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns[0].arn
}

# ------------------------------------------------------------------------------
# EFS CSI Driver Role (Pod Identity)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "efs_csi_driver" {
  count = var.enable_efs_driver ? 1 : 0
  name  = "${var.project_name}-${var.environment}-efs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-efs-csi-driver-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count      = var.enable_efs_driver ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver[0].name
}

resource "aws_eks_pod_identity_association" "efs_csi_driver" {
  count           = var.enable_efs_driver ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
  role_arn        = aws_iam_role.efs_csi_driver[0].arn
}

resource "aws_eks_access_entry" "karpenter_node" {
  count         = var.enable_karpenter ? 1 : 0
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.karpenter_node[0].arn
  type          = "EC2_LINUX"
}
