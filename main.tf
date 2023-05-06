# VPC creation
resource "aws_vpc" "reliable_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "reliable_vpc"
  }
}

# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Subnet creation
resource "aws_subnet" "reliable_private_sub1" {
  vpc_id     = aws_vpc.reliable_vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "reliable_private_sub1"
  }
}

resource "aws_subnet" "reliable_private_sub2" {
  vpc_id     = aws_vpc.reliable_vpc.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "reliable_private_sub2"
  }
}

resource "aws_subnet" "reliable_public_sub1" {
  vpc_id     = aws_vpc.reliable_vpc.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "reliable_public_sub1"
  }
}

resource "aws_subnet" "reliable_public_sub2" {
  vpc_id     = aws_vpc.reliable_vpc.id
  cidr_block = "10.10.4.0/24"

  tags = {
    Name = "reliable_public_sub2"
  }
}

#internet gateway
resource "aws_internet_gateway" "reliable_igw" {
  vpc_id = aws_vpc.reliable_vpc.id

  tags = {
    Name = "reliable_igw"
  }
}

#elastic ip
resource "aws_eip" "reliable_eip" {

  tags = {
    Name = "reliable_eip"
  }
}

# nat gateway
resource "aws_nat_gateway" "reliable_ngw" {
  allocation_id = aws_eip.reliable_eip.id
  subnet_id     = aws_subnet.reliable_public_sub1.id

  tags = {
    Name = "reliable_ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.reliable_igw]
}

# route table
resource "aws_route_table" "reliable_public_rt" {
  vpc_id = aws_vpc.reliable_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.reliable_igw.id
  }

  tags = {
    Name = "reliable_public_rt"
  }
}

resource "aws_route_table" "reliable_private_rt" {
  vpc_id = aws_vpc.reliable_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.reliable_ngw.id
  }

  tags = {
    Name = "reliable_private_rt"
  }
}

# route associations
resource "aws_route_table_association" "reliable-pub-route-table-association-1" {
  subnet_id      = aws_subnet.reliable_public_sub1.id
  route_table_id = aws_route_table.reliable_public_rt.id
}

resource "aws_route_table_association" "reliable-pub-route-table-association-2" {
  subnet_id      = aws_subnet.reliable_public_sub2.id
  route_table_id = aws_route_table.reliable_public_rt.id
}

resource "aws_route_table_association" "reliable-priv-route-table-association-1" {
  subnet_id      = aws_subnet.reliable_private_sub1.id
  route_table_id = aws_route_table.reliable_private_rt.id
}

resource "aws_route_table_association" "reliable-priv-route-table-association-2" {
  subnet_id      = aws_subnet.reliable_private_sub2.id
  route_table_id = aws_route_table.reliable_private_rt.id
}