data "tls_certificate" "this" {
  count = length(try(aws_eks_cluster.this.identity[0].oidc[0].issuer, "")) > 0 ? 1 : 0
  url   = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count           = length(try(aws_eks_cluster.this.identity[0].oidc[0].issuer, "")) > 0 ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-eks-irsa"
    }
  )
}
