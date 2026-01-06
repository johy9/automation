project_name      = "internal-ps-monitoring"
vpc_cidr          = "10.50.0.0/16" # Different CIDR for Prod to avoid confusion
availability_zone = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Public Subnets (/26 = 64 IPs)
public_subnet_cidr = ["10.50.0.0/22", "10.50.4.0/22", "10.50.8.0/22"]

# Private Subnets (/24 = 256 IPs)
private_subnet_cidr = ["10.50.16.0/20", "10.50.32.0/20", "10.50.48.0/20"]

environment = "production"
