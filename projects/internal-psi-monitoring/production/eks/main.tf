data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "ringcentral-terraform-states"
    key    = "internal-psi-monitoring/production/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

module "eks" {
  source = "git::https://github.com/RingCentral-Pro-Services/psi-terraform.git//modules/eks?ref=v1.0.0-eks"
  # source = "../../../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = "${var.project_name}-${var.environment}-eks"

  cluster_version = var.cluster_version

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # Production: Enable private access, enable public access for external visibility
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Production Node Groups
  node_groups = {
    general = {
      desired_size   = 2
      max_size       = 4
      min_size       = 2
      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
    }
    compute = {
      desired_size   = 0
      max_size       = 4
      min_size       = 0
      instance_types = ["c5.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }

  addons = {
    vpc-cni                = {}
    coredns                = {}
    kube-proxy             = {}
    aws-ebs-csi-driver     = {}
    aws-efs-csi-driver     = {}
    eks-pod-identity-agent = {}
  }

  enable_cluster_creator_admin_permissions = false

  # Enable IAM Roles for Add-ons
  enable_karpenter     = true
  enable_lb_controller = true
  enable_external_dns  = true
  enable_efs_driver    = true

  access_entries = var.github_actions_role_arn != null ? {
    (var.github_actions_role_arn) = {
      kubernetes_groups = []
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : {}

  additional_tags = {
    psi_environment      = "production"
    psi_source_repo      = "psi-terraform"
    psi_cost_center      = "internal"
    psi_application_name = "internal_psi_monitoring"
    psi_lifecycle        = "active"
    psi_managed_by       = "terraform"
    psi_application_type = "shared_service"
  }
}
