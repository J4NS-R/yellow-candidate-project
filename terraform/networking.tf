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

# https://nikhilpurwant.com/post/tech-vpc-helper/vpc-helper
resource "aws_subnet" "euw1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/27"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "jans-candidate-proj-euw1a"
  }
}
resource "aws_subnet" "euw1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.32/27"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "jans-candidate-proj-euw1b"
  }
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

resource "aws_security_group" "node_app" {
  name   = "${local.proj_name}-node-app"
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
