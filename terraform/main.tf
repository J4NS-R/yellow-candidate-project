terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region = local.aws_region
    bucket = "yellow-sandbox-s3-terraform-state"
    key    = "yellow-sandbox/jans/candidate-project.json"
    # Required env vars:
    # AWS_ACCESS_KEY, AWS_SECRET_ACCESS_KEY or AWS_PROFILE
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = local.aws_region
  default_tags {
    tags = {
      Project = "jans-candidate-proj"
    }
  }
}

data "aws_secretsmanager_secret" "terrasecrets" {
  arn = "arn:aws:secretsmanager:eu-west-1:334550036524:secret:jans-candidate-proj-terrasecrets-3YT8rq"
}
data "aws_secretsmanager_secret_version" "terrasecrets_latest" {
  secret_id = data.aws_secretsmanager_secret.terrasecrets.id
}
locals {
  aws_region   = "eu-west-1"
  terrasecrets = jsondecode(data.aws_secretsmanager_secret_version.terrasecrets_latest.secret_string)
  pg_port      = 5432
  proj_name    = "jans-candidate-proj"
  cluster_name = local.proj_name
  az_count     = 2
}
