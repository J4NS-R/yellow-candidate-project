resource "aws_db_instance" "pg" {
  identifier     = local.proj_name
  instance_class = "db.t3.micro"
  engine         = "postgres"
  # aws rds describe-db-engine-versions --engine postgres --output json | jq ".DBEngineVersions[] | .EngineVersion"
  engine_version           = "16.4"
  allocated_storage        = 10
  storage_type             = "gp3"
  delete_automated_backups = true
  backup_retention_period  = 1
  db_name                  = "yellow"
  username                 = local.terrasecrets["db-username"]
  password                 = local.terrasecrets["db-password"]
  apply_immediately        = true
  skip_final_snapshot      = true
  db_subnet_group_name     = aws_db_subnet_group.db.name
  vpc_security_group_ids   = [aws_security_group.db.id]
  port                     = local.pg_port
  multi_az                 = false
  publicly_accessible      = false
  tags = {
    Name = local.proj_name
  }
}
