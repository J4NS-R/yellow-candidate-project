terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region = "eu-west-1"
    bucket = "yellow-sandbox-s3-terraform-state"
    key    = "yellow-sandbox/jans/candidate-project.json"
    # Required env vars:
    # AWS_ACCESS_KEY, AWS_SECRET_ACCESS_KEY or AWS_PROFILE
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project = "jans-candidate-proj"
    }
  }
}
