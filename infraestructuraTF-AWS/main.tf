#Proveedor de nube
provider "aws" {
  region = "us-east-1"
}

#VPC Proyecto Final
resource "aws_vpc" "vpc_virginia" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC - Proyecto"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw-virginia" {
  vpc_id = aws_vpc.vpc_virginia.id
  tags = {
    Name = "IGW - Proyecto"
  }
}

#Elastic IP para NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "Elastic IP para NAT Gateway"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subred_publica_virginia_Web.id
  tags = {
    Name = "NAT Gateway - Proyecto"
  }
}