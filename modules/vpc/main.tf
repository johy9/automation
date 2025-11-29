resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "${var.project_name}-vpc" #interpolating variable for naming - variable plus static string 
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zone)
  vpc_id            = aws_vpc.this.id
    cidr_block        = var.public_subnet_cidr[count.index]
    availability_zone = var.availability_zone[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-public-subnet-${count.index + 1}"
        "kubernetes.io/role/elb" = "1"
    }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]

    tags = {
        Name = "${var.project_name}-nat-eip"
    }
  
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zone)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  
  tags = {
      Name = "${var.project_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"
    }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

data "aws_availability_zones" "available" {
    state = "available"
}

