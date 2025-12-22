resource "aws_iam_role" "capability" {
  for_each = { for k, v in var.capabilities : k => v if v.role_arn == null }

  name = "${var.project_name}-${var.environment}-capability-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "capabilities.eks.amazonaws.com"
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
      Name = "${var.project_name}-${var.environment}-capability-${each.key}-role"
    }
  )
}

resource "aws_eks_capability" "this" {
  for_each = var.capabilities

  cluster_name    = aws_eks_cluster.this.name
  capability_name = each.key

  # Infer type from key or make it explicit. Assuming key "argocd" maps to type "ARGOCD"
  type = upper(each.key)

  role_arn = each.value.role_arn != null ? each.value.role_arn : aws_iam_role.capability[each.key].arn

  delete_propagation_policy = each.value.delete_propagation_policy

  dynamic "configuration" {
    for_each = each.value.configuration != null ? [each.value.configuration] : []
    content {
      dynamic "argo_cd" {
        for_each = upper(each.key) == "ARGOCD" ? [1] : []
        content {
          aws_idc {
            idc_instance_arn = configuration.value.aws_idc.idc_instance_arn
            idc_region       = try(configuration.value.aws_idc.idc_region, null)
          }
        }
      }
    }
  }

  depends_on = [aws_eks_cluster.this]
}
