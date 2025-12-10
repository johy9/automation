module "vpc" {
  source = "git::https://github.com/johy9/automation.git//modules/vpc?ref=v1.0.0-vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  
  # Prod: High Availability (One NAT per AZ)
  single_nat_gateway  = false 
  enable_nat_gateway  = true
  create_igw          = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "Environment"            = "prod"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "Environment"                     = "prod"
  }
}
