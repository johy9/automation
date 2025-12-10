module "vpc" {
  source = "../../../modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr

  # Staging: Save money with Single NAT Gateway
  single_nat_gateway = true
  enable_nat_gateway = true
  create_igw         = true

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
