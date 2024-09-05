provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

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
