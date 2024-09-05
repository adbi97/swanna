
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
