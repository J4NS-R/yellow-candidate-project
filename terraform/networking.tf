resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "jans-candidate-proj"
  }
}
resource "aws_subnet" "euw1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "eu-west-1a"
}
resource "aws_subnet" "euw1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "eu-west-1b"
}
resource "aws_db_subnet_group" "db" {
  subnet_ids = [aws_subnet.euw1a.id, aws_subnet.euw1b.id]
}

# Security groups
resource "aws_security_group" "db" {
  name = "jans-candidate-proj-db"
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
}
