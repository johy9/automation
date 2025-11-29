module "vpc" {
  source = "git::https://github.com/oyegokeodev/automation.git//modules/vpc?ref=v1.0.0"

  vpc_cidr            = var.vpc_cidr
  project_name        = var.project_name
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}