# ------------------------------------------------------------------------------
# ExternalDNS
# ------------------------------------------------------------------------------
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_version
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  # The IAM role is associated via Pod Identity in the EKS module, 
  # so we don't need to annotate the ServiceAccount with an ARN.

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "policy"
    value = "upsert-only" # create and update, but not delete
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_filter
  }

  set {
    name  = "zoneIdFilters[0]"
    value = var.route53_zone_id
  }

  set {
    name  = "registry"
    value = "txt"
  }

  set {
    name  = "txtOwnerId"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }
}
