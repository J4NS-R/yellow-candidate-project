resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = local.proj_name
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.proj_name
  }
}
# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# https://nikhilpurwant.com/post/tech-vpc-helper/vpc-helper
resource "aws_subnet" "euw1a" {
  vpc_id                                      = aws_vpc.main.id
  cidr_block                                  = "10.0.0.0/27"
  availability_zone                           = "eu-west-1a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "jans-candidate-proj-euw1a"
  }
}
resource "aws_subnet" "euw1b" {
  vpc_id                                      = aws_vpc.main.id
  cidr_block                                  = "10.0.0.32/27"
  availability_zone                           = "eu-west-1b"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "jans-candidate-proj-euw1b"
  }
}
locals {
  subnet_ids = [aws_subnet.euw1a.id, aws_subnet.euw1b.id]
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = local.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "gw" {
  count         = local.az_count
  subnet_id     = element(local.subnet_ids, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}
resource "aws_route_table" "rt" {
  count  = local.az_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}
resource "aws_route_table_association" "rtassoc" {
  count          = local.az_count
  route_table_id = element(aws_route_table.rt.*.id, count.index)
  subnet_id      = element(local.subnet_ids, count.index)
}

resource "aws_db_subnet_group" "db" {
  subnet_ids = [aws_subnet.euw1a.id, aws_subnet.euw1b.id]
}

# Security groups
resource "aws_security_group" "db" {
  vpc_id = aws_vpc.main.id
  name   = "jans-candidate-proj-db"
  ingress {
    description = "Ingress from the vpc"
    cidr_blocks = [aws_subnet.euw1a.cidr_block, aws_subnet.euw1b.cidr_block]
    from_port   = local.pg_port
    to_port     = local.pg_port
    protocol    = "TCP"
  }
  egress {
    description = "Egress to the vpc"
    cidr_blocks = [aws_subnet.euw1a.cidr_block, aws_subnet.euw1b.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # which means all
  }
  tags = {
    Name = "jans-candidate-proj-db"
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
    cidr_blocks = [aws_subnet.euw1a.cidr_block, aws_subnet.euw1b.cidr_block]
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
