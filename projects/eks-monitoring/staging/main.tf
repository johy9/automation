module "vpc" {
  source = "../../../modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  
  # Staging: Save money with Single NAT Gateway
  single_nat_gateway  = true
  enable_nat_gateway  = true
  create_igw          = true

  additional_tags = {
    Environment = "staging"
    Owner       = "DevOps"
    Project     = "eks-monitoring"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # Allow public access to API server (so you can run kubectl from your laptop)
  cluster_endpoint_public_access = true
  
  tags = {
    Environment = "staging"
    Owner       = "DevOps"
    Project     = "eks-monitoring"
  }
}
