resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = merge(
    {
      Name = "${var.project_name}-vpc"
    },
    var.additional_tags
  )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_internet_gateway" "igw" {
    count = var.create_igw ? 1 : 0
    vpc_id = aws_vpc.this.id

    tags = merge(
      {
        Name = "${var.project_name}-igw"
      },
      var.additional_tags
    )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.project_name}-public-rt"
    },
    var.additional_tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.this.id
    cidr_block        = var.public_subnet_cidr[count.index]
    availability_zone = var.availability_zone[count.index]
    map_public_ip_on_launch = true
    tags = merge(
      {
        Name = "${var.project_name}-public-subnet-${count.index + 1}"
      },
      var.public_subnet_tags,
      var.additional_tags
    )
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && length(var.private_subnet_cidr) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidr)) : 0
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]

    tags = merge(
      {
        Name = "${var.project_name}-nat-eip-${count.index + 1}"
      },
      var.additional_tags
    )
  
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway && length(var.private_subnet_cidr) > 0 ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidr)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.project_name}-nat-gateway-${count.index + 1}"
    },
    var.additional_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  
  tags = merge(
      {
        Name = "${var.project_name}-private-subnet-${count.index + 1}"
      },
      var.private_subnet_tags,
      var.additional_tags
    )
}

resource "aws_route_table" "private_rt" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.project_name}-private-rt-${count.index + 1}"
    },
    var.additional_tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway && length(var.private_subnet_cidr) > 0 ? length(var.private_subnet_cidr) : 0
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

