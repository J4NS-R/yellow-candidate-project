resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "jans-candidate-proj"
  }
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}
resource "aws_db_subnet_group" "db" {
  subnet_ids = [aws_subnet.main.id]
}

# Security groups
resource "aws_security_group" "db" {
  name = "jans-candidate-proj-db"
  ingress {
    description = "Ingress from the subnet"
    cidr_blocks = [aws_subnet.main.cidr_block]
    from_port   = local.pg_port
    to_port     = local.pg_port
    protocol    = "TCP"
  }
  egress {
    description = "Egress to the subnet"
    cidr_blocks = [aws_subnet.main.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # which means all
  }
}
