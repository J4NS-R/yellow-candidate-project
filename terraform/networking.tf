# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = local.proj_name
  }
}
# Create local.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = local.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
}

# Create local.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = local.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, local.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = local.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  count         = local.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_db_subnet_group" "db" {
  subnet_ids = aws_subnet.private.*.id
}

# Security groups
resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id
  name   = "jans-candidate-proj-db"
  ingress {
    description = "Ingress from the vpc"
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = local.pg_port
    to_port     = local.pg_port
    protocol    = "TCP"
  }
  egress {
    description = "Egress to the vpc"
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # which means all
  }
  tags = {
    Name = "${local.proj_name}-db"
  }
}

resource "aws_security_group" "node_app_ingress" {
  name   = "${local.proj_name}-node-app-ingress"
  vpc_id = aws_vpc.main.id
  ingress {
    description = "WWW"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80 # TODO 443
    to_port     = 80
    protocol    = "TCP"
  }
  egress {
    description = "Out to the world"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all
  }
}

resource "aws_security_group" "vpc" {
  vpc_id = aws_vpc.main.id
  name   = "${local.proj_name}-vpc-friendly"
  ingress {
    description = "Ingress from the vpc"
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all
  }
  egress {
    description = "Egress to the world"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # which means all
  }
  tags = {
    Name = "${local.proj_name}-vpc-friendly"
  }
}
