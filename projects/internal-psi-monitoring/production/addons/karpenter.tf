# ------------------------------------------------------------------------------
# Karpenter
# ------------------------------------------------------------------------------
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  namespace        = "kube-system"
  create_namespace = false

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }

  # Settings for Karpenter v1.0+
  set {
    name  = "settings.clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }

  set {
    name  = "controller.env[0].name"
    value = "AWS_REGION"
  }

  set {
    name  = "controller.env[0].value"
    value = "us-east-2"
  }

  # We do NOT set annotations for the role ARN because we are using Pod Identity.
}

# ------------------------------------------------------------------------------
# Karpenter Default NodeClass and NodePool
# ------------------------------------------------------------------------------
# We need to create a default NodeClass that references the Instance Profile or Role created in the EKS module.
# Since we are using the 'karpenter_node_role_name' output from the EKS module.

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: "${data.terraform_remote_state.eks.outputs.karpenter_node_role_name}"
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${data.terraform_remote_state.eks.outputs.cluster_name}"
        - tags:
            karpenter.sh/discovery: "${var.project_name}-${var.environment}-cluster"
      securityGroupSelectorTerms:
        - tags:
            "kubernetes.io/cluster/${data.terraform_remote_state.eks.outputs.cluster_name}": "owned"
      tags:
        Name: "${data.terraform_remote_state.eks.outputs.cluster_name}-karpenter-node"
  YAML

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        metadata:
          labels:
            workload_type: "monitoring"
        spec:
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
              values: ["on-demand"]
            - key: kubernetes.io/arch
              operator: In
              values: ["amd64"]
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["4"]
          nodeClassRef:
            name: default
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenUnderutilized
        expireAfter: 720h
  YAML

  depends_on = [kubectl_manifest.karpenter_node_class]
}
