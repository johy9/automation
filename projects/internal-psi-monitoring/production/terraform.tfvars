project_name        = "eks-monitoring-prod"
vpc_cidr            = "10.20.0.0/21" # Different CIDR for Prod to avoid confusion
availability_zone   = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Public Subnets (/26 = 64 IPs)
public_subnet_cidr  = ["10.20.0.0/26", "10.20.0.64/26", "10.20.0.128/26"]

# Private Subnets (/24 = 256 IPs)
private_subnet_cidr = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

environment = "production"