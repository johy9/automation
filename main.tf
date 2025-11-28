resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/22"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = {
    Name = "main_vpc"
  }
}