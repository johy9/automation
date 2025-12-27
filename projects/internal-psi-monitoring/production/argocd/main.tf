# -----------------------------------------------------------------------------
# IAM Policy for ArgoCD Controller
# -----------------------------------------------------------------------------
resource "kubernetes_service_account" "argocd_controller" {
  metadata {
    name      = "argocd-application-controller"
    namespace = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name" = "argocd-application-controller"
    }
  }
}

resource "aws_iam_policy" "argocd_controller" {
  name        = "argocd-controller-policy"
  description = "Policy for ArgoCD controller to access Secrets Manager, SSM, and ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Role for ArgoCD Controller (Pod Identity)
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "argocd_controller" {
  name = "argocd-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
  tags = var.additional_tags
}

resource "aws_iam_role_policy_attachment" "argocd_controller" {
  role       = aws_iam_role.argocd_controller.name
  policy_arn = aws_iam_policy.argocd_controller.arn
}

# -----------------------------------------------------------------------------
# Pod Identity Association (EKS)
# -----------------------------------------------------------------------------

resource "aws_eks_pod_identity_association" "argocd_controller" {
  cluster_name    = var.cluster_name
  namespace       = var.argocd_namespace
  service_account = "argocd-application-controller"
  role_arn        = aws_iam_role.argocd_controller.arn
}
# -----------------------------------------------------------------------------
# Providers
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
      command     = "aws"
    }
  }
}

# -----------------------------------------------------------------------------
# ArgoCD Namespace (optional)
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.argocd_namespace
  }
}

# -----------------------------------------------------------------------------
# ArgoCD Helm Chart Deployment
# -----------------------------------------------------------------------------

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = var.create_namespace

  values = [
    yamlencode({
      global = {
        domain = "games.oyegokeodev.com"
      }
      controller = {
        replicas  = var.controller_replicas
        resources = var.controller_resources
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.argocd_controller.metadata[0].name
        }
      }
      server = {
        replicas  = var.server_replicas
        resources = var.server_resources
        ingress = {
          enabled = true
          hosts   = ["games.oyegokeodev.com"]
          annotations = {
            "kubernetes.io/ingress.class"                = "alb"
            "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
            "alb.ingress.kubernetes.io/target-type"      = "ip"
            "alb.ingress.kubernetes.io/group.name"       = "central-eks-alb"
            "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
            "alb.ingress.kubernetes.io/success-codes"    = "200"
            "alb.ingress.kubernetes.io/subnets"          = join(",", var.private_subnet_ids)
            "alb.ingress.kubernetes.io/certificate-arn"  = var.certificate_arn
            "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
              Type = "redirect"
              RedirectConfig = {
                Protocol   = "HTTPS"
                Port       = "443"
                StatusCode = "HTTP_301"
              }
            })
          }
        }
      }
      repoServer = {
        replicas  = var.repo_server_replicas
        resources = var.repo_server_resources
      }
      redis = {
        replicas = var.redis_ha_replicas
      }
      applicationSet = {
        replicas = var.applicationset_replicas
      }
      metrics = {
        enabled = var.enable_metrics
      }
      notifications = {
        enabled = var.enable_notifications
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_service_account.argocd_controller
  ]
}