resource "aws_db_instance" "pg" {
  instance_class = "db.t3.micro"
  engine         = "postgres"
  # aws rds describe-db-engine-versions --engine postgres --output json | jq ".DBEngineVersions[] | .EngineVersion"
  engine_version         = "16.4"
  allocated_storage      = 10
  db_name                = "yellow"
  username               = local.terrasecrets["db-username"]
  password               = local.terrasecrets["db-password"]
  apply_immediately      = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  tags = {
    Name = "jans-candidate-proj"
  }
}
