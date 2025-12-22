data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.project_name}-${var.environment}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_id != null ? [1] : []
    content {
      provider {
        key_arn = var.kms_key_id
      }
      resources = var.encryption_resources
    }
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  # Enforce EKS API for authentication
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_amazon_eks_cluster_policy,
  ]

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks"
    }
  )
}

resource "aws_eks_access_entry" "this" {
  for_each = var.access_entries

  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.key
  kubernetes_groups = each.value.kubernetes_groups
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  for_each = {
    for association in flatten([
      for principal_arn, entry in var.access_entries : [
        for policy_key, policy in entry.policy_associations : {
          principal_arn = principal_arn
          policy_arn    = policy.policy_arn
          access_scope  = policy.access_scope
          key           = "${principal_arn}-${policy.policy_arn}"
        }
      ]
    ]) : association.key => association
  }

  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = each.value.policy_arn
  principal_arn = each.value.principal_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.namespaces
  }
}

