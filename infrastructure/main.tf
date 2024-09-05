provider "aws" {
  region  = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

data "aws_caller_identity" "current" {}

# Secrets Manager
data "aws_secretsmanager_secret" "alpha_vantage_secret" {
  name = "AlphaVantageAPI_Key"
}

data "aws_secretsmanager_secret_version" "alpha_vantage_secret_version" {
  secret_id = data.aws_secretsmanager_secret.alpha_vantage_secret.id
}

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

resource "aws_s3_bucket" "lambda-bucket" {
  bucket = "${var.bucket_prefix}-lambda-bucket"

  tags = {
    Name        = "Lambda Artifacts"
    Environment = "Development"
  }
}

# Lambdas 

resource "aws_lambda_function" "aapl_ingestion" {
  s3_bucket        = "${var.bucket_prefix}-lambda-bucket"
  s3_key           = "lambda_function.zip"  
  function_name    = "AlphaVantageIngestion_AAPL"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "aapl_ingestion.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30  # Optional: Adjust the timeout as needed

  source_code_hash = filebase64sha256("${path.module}/../application/lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.lambda_bucket.bucket
    }
  }
}

