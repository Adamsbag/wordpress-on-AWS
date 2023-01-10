# Create a Data Source to obtain all the AZs of the region
data "aws_availability_zones" "available_zones" {}

# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.main_var}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.main_var}-igw"
  }
}

# Create 2 Public Subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "${var.main_var}-Public-${count.index}"
  }
}

# Create 2 Private Subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_cidr)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.available_zones.names[2]

  tags = {
    Name = "${var.main_var}-Private-${count.index}"
  }
}

# Create 2 Elastic IPs for the Nat Gateways
resource "aws_eip" "elastic_ip" {
  count = length(var.public_cidr)

  vpc = true

  tags = {
    Name = "${var.main_var}-EIP-${count.index}"
  }
}

# Create 2 Nat Gateway in each Public Subnet
resource "aws_nat_gateway" "nat_gtw" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.main_var}-Nat-${count.index}"
  }
}

# Create a Route Table to allow access to the Internet
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.main_var}-Public-rtb"
  }
}

# Create 2 Route Tables to route traffic from the Private Subnet via Nat Gateway
resource "aws_route_table" "private_rtb" {
  count = length(var.private_cidr)

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gtw[count.index].id
  }

  tags = {
    Name = "${var.main_var}-Private-rtb ${count.index}"
  }
}

# Create 2  RTB Association to associate them with the Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

# Create 2  RTB Association to associate them with the Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rtb[count.index].id
}
