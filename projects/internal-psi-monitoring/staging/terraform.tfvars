project_name      = "psi-internal-monitoring"
vpc_cidr          = "10.10.0.0/21"
availability_zone = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Public Subnets (/26 = 64 IPs)
public_subnet_cidr = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]

# Private Subnets (/24 = 256 IPs)
private_subnet_cidr = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
environment         = "staging"