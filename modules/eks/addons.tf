# IAM Role for EBS CSI Driver (IRSA)
data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
  count = contains(keys(var.addons), "aws-ebs-csi-driver") ? 1 : 0
  
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider[0].arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  count = contains(keys(var.addons), "aws-ebs-csi-driver") ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ebs-csi-driver-role"

  assume_role_policy = try(data.aws_iam_policy_document.ebs_csi_driver_assume_role[0].json, jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.oidc_provider[0].arn }
      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  }))

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-ebs-csi-driver-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  count      = contains(keys(var.addons), "aws-ebs-csi-driver") ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver[count.index].name
}

resource "aws_eks_addon" "this" {
  # Only create add-ons if node groups are defined to avoid hanging in "Creating" state
  for_each = length(var.node_groups) > 0 ? var.addons : {}

  cluster_name      = aws_eks_cluster.this.name
  addon_name        = each.key
  addon_version     = each.value.version
  resolve_conflicts_on_create = try(each.value.resolve_conflicts, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts, "OVERWRITE")

  # If the addon is EBS CSI Driver, attach the IRSA role
  service_account_role_arn = each.key == "aws-ebs-csi-driver" ? try(aws_iam_role.ebs_csi_driver[0].arn, null) : null

  depends_on = concat(
    [aws_eks_node_group.this],
    contains(keys(var.addons), "aws-ebs-csi-driver") && each.key == "aws-ebs-csi-driver" ? [aws_iam_role_policy_attachment.ebs_csi_driver_policy[0]] : []
  )

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-addon-${each.key}"
    }
  )
}
