resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    owner = "example"
    Environement = "dev"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "example_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.example_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true # if you want to make this a public subnet

  tags = {
    Name  = "example-subnet-${count.index}"
    owner = "example"
  }
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    owner = "example"
  }
}
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.example_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example_igw.id
} 


# Create Private Subnets with dynamic CIDR blocks
resource "aws_subnet" "private_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.example_vpc.cidr_block, 8, count.index + length(data.aws_availability_zones.available.names))
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name  = "example-private-subnet-${count.index}"
    owner = "example"
  }
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    owner = "example"
  }
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.private_subnet.*.id)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
  
  tags = {
    owner = "example"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.example_subnet[0].id

  tags = {
    owner = "example"
  }
}

# Add Route in Private Route Table to NAT Gateway
resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}