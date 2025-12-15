# ------------------------------------------------------------------------------
# VPC Module (Test Fixture)
# ------------------------------------------------------------------------------
module "vpc" {
  source = "git::https://github.com/johy9/automation.git//modules/vpc?ref=v1.1.0-vpc"
  # source = "../../../../modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  environment         = var.environment

  # Prod: High Availability (One NAT per AZ)
  single_nat_gateway = true
  enable_nat_gateway = true
  create_igw         = true

  additional_tags = {
    psi_environment      = "production"
    psi_source_repo      = "psi-terraform"
    psi_cost_center      = "internal"
    psi_application_name = "internal_psi_monitoring"
    psi_lifecycle        = "active"
    psi_managed_by       = "terraform"
    psi_application_type = "shared_service"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = "${var.project_name}-${var.environment}-eks"
  }
}

# ------------------------------------------------------------------------------
# EKS Module
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = "${var.project_name}-${var.environment}-eks"

  cluster_version = var.cluster_version

  # Direct reference to the VPC module above, instead of remote state
  subnet_ids = module.vpc.private_subnet_ids

  # Production: Enable private access, enable public access for external visibility
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["0.0.0.0/0"]

  # Production Node Groups
  node_groups = {
    general = {
      desired_size   = 3
      max_size       = 5
      min_size       = 2
      instance_types = ["m5.large"] # Larger instances for prod
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
    }
    compute = {
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      instance_types = ["c5.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }

  addons = {
    vpc-cni                = {}
    coredns                = {}
    kube-proxy             = {}
    aws-ebs-csi-driver     = {}
    eks-pod-identity-agent = {}
  }

  # Enable IAM Roles for Add-ons
  enable_karpenter     = true
  enable_lb_controller = true
  enable_external_dns  = true

  enable_cluster_creator_admin_permissions = false

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
