resource "aws_lambda_function" "aapl_ingestion" {
  s3_bucket        = aws_s3_bucket.lambda-bucket.bucket  
  s3_key           = "lambda_function.zip"
  function_name    = "AlphaVantageIngestion_AAPL"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "aapl_ingestion.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30  # Optional: Adjust the timeout as needed

  source_code_hash = filebase64sha256("${path.module}/../application/lambda_function.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.lambda-bucket.bucket
    }
  }
}
