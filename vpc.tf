# VPC creation which exposed to te internet
resource "aws_vpc" "rearc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "rearc"
  }
}

# Subnets
resource "aws_subnet" "rearc-public-1" {
  vpc_id                  = aws_vpc.rearc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "rearc-public-1"
  }
}

resource "aws_subnet" "rearc-public-2" {
  vpc_id                  = aws_vpc.rearc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "rearc-public-2"
  }
}

resource "aws_subnet" "rearc-private-1" {
  vpc_id                  = aws_vpc.rearc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "rearc-private-1"
  }
}

resource "aws_subnet" "rearc-private-2" {
  vpc_id                  = aws_vpc.rearc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "rearc-private-2"
  }
}

# Internet GW
resource "aws_internet_gateway" "rearc-gw" {
  vpc_id = aws_vpc.rearc.id

  tags = {
    Name = "rearc-IGW"
  }
}

# route tables
resource "aws_route_table" "rearc-public" {
  vpc_id = aws_vpc.rearc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rearc-gw.id
  }

  tags = {
    Name = "rearc-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "rearc-public-1-a" {
  subnet_id      = aws_subnet.rearc-public-1.id
  route_table_id = aws_route_table.rearc-public.id
}

resource "aws_route_table_association" "rearc-public-2-a" {
  subnet_id      = aws_subnet.rearc-public-2.id
  route_table_id = aws_route_table.rearc-public.id
}
