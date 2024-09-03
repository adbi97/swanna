provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# S3 Buckets
resource "aws_s3_bucket" "bronze_bucket" {
  bucket = "${var.bucket_prefix}-bronze"

  tags = {
    Name        = "Swanna Bronze Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket" "silver_bucket" {
  bucket = "${var.bucket_prefix}-silver"

  tags = {
    Name        = "Swanna Silver Bucket"
    Environment = "Development"
  }
}

resource "aws_s3_bucket" "gold_bucket" {
  bucket = "${var.bucket_prefix}-gold"

  tags = {
    Name        = "Swanna Gold Bucket"
    Environment = "Development"
  }
}

# Secrets Manager
data "aws_secretsmanager_secret" "alpha_vantage_secret" {
  name = "AlphaVantageAPI_Key"
}

data "aws_secretsmanager_secret_version" "alpha_vantage_secret_version" {
  secret_id = data.aws_secretsmanager_secret.alpha_vantage_secret.id
}

resource "aws_lambda_function" "aapl_ingestion" {
  filename         = "lambda_function.zip"
  function_name    = "AlphaVantageIngestion"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "aapl_ingestion.lambda_handler"
  runtime          = "python3.9"

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.bronze_bucket.bucket
    }
  }
}
