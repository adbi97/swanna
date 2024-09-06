terraform {
  backend "s3" {
    bucket         = "swanna-state-bucket"
    key            = "terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_secretsmanager_secret" "alpha_vantage_secret" {
  name = "AlphaVantageAPI_Key"
}

data "aws_secretsmanager_secret_version" "alpha_vantage_secret_version" {
  secret_id = data.aws_secretsmanager_secret.alpha_vantage_secret.id
}

data "aws_caller_identity" "current" {}
