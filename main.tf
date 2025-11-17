# This is the root module for the EKS monitoring cluster.
# It will compose the other modules (vpc, eks-iam, eks-cluster, etc.)

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "eks-iam" {
  source = "./modules/eks-iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
  # The oidc_provider_url is now correctly sourced from the eks-cluster module.
  oidc_provider_url = module.eks-cluster.oidc_provider_url
}

module "eks-cluster" {
  source = "./modules/eks-cluster"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags

  vpc_id                              = module.vpc.vpc_id
  private_subnet_ids                  = module.vpc.private_subnet_ids
  eks_role_arn                        = module.eks-iam.eks_role_arn
  eks_node_group_role_arn             = module.eks-iam.eks_node_group_role_arn
  eks_policy_attachment               = module.eks-iam.eks_policy_attachment
  node_worker_policy_attachment       = module.eks-iam.node_worker_policy_attachment
  node_cni_policy_attachment          = module.eks-iam.node_cni_policy_attachment
  node_ecr_readonly_policy_attachment = module.eks-iam.node_ecr_readonly_policy_attachment
  ebs_csi_driver_role_arn             = module.eks-iam.ebs_csi_driver_role_arn
}

# module "monitoring-ingress" {
#   source = "./modules/monitoring-ingress"

#   project_name = var.project_name
#   environment  = var.environment
#   tags = {
#     Project     = var.project_name
#     Environment = var.environment
#   }

#   vpc_id              = module.vpc.vpc_id
#   public_subnet_ids   = module.vpc.public_subnet_ids
#   grafana_domain_name = var.grafana_domain_name
#   route53_zone_id     = var.route53_zone_id
#   acm_certificate_arn = var.acm_certificate_arn
# }
