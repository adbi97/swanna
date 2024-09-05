# HAS TO BE HARDCODED
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
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

data "aws_secretsmanager_secret" "alpha_vantage_secret" {
  name = "AlphaVantageAPI_Key"
}

data "aws_secretsmanager_secret_version" "alpha_vantage_secret_version" {
  secret_id = data.aws_secretsmanager_secret.alpha_vantage_secret.id
}
