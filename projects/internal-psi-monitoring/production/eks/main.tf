data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "oyegokeodev-terraform-states"
    key    = "internal-psi-monitoring/production/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

module "eks" {
  source = "../../../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = "${var.project_name}-${var.environment}-cluster"
  
  cluster_version = var.cluster_version

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  # Production: Enable private access, disable public access for security
  endpoint_private_access = true
  endpoint_public_access  = true

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
    vpc-cni            = {}
    coredns            = {}
    kube-proxy         = {}
    aws-ebs-csi-driver = {}
  }

  enable_cluster_creator_admin_permissions = false

  additional_tags = {
    Environment = var.environment
    Owner       = "DevOps"
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
