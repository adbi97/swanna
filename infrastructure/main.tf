provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Secrets Manager
data "aws_secretsmanager_secret" "alpha_vantage_secret" {
  name = "AlphaVantageAPI_Key"
}

data "aws_secretsmanager_secret_version" "alpha_vantage_secret_version" {
  secret_id = data.aws_secretsmanager_secret.alpha_vantage_secret.id
}
