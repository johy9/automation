project_name    = "internal-psi-monitoring"
environment     = "production"
cluster_version = "1.32"

# VPC Variables
vpc_cidr            = "10.50.0.0/16"
availability_zone   = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnet_cidr  = ["10.50.0.0/22", "10.50.4.0/22", "10.50.8.0/22"]
private_subnet_cidr = ["10.50.16.0/20", "10.50.32.0/20", "10.50.48.0/20"]
