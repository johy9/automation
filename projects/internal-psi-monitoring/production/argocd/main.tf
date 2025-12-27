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
	name       = "argocd"
	repository = "https://argoproj.github.io/argo-helm"
	chart      = "argo-cd"
	version    = var.argocd_chart_version
	namespace  = var.argocd_namespace
	create_namespace = var.create_namespace

	values = [
		yamlencode({
			global = {
				domain = var.argocd_domain
			}
			controller = {
				replicas = var.controller_replicas
				resources = var.controller_resources
			}
			server = {
				replicas = var.server_replicas
				resources = var.server_resources
				ingress = {
					enabled = true
					hosts   = [var.argocd_domain]
					annotations = {
						"kubernetes.io/ingress.class" = "alb"
						"alb.ingress.kubernetes.io/scheme" = "internet-facing"
						"alb.ingress.kubernetes.io/target-type" = "ip"
						"alb.ingress.kubernetes.io/subnets" = join(",", var.private_subnet_ids)
						"alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
					}
				}
			}
			repoServer = {
				replicas = var.repo_server_replicas
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

	depends_on = [kubernetes_namespace.argocd]
}
