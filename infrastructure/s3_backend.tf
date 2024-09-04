# s3_backend.tf

provider "aws" {
  region = "ap-southeast-2"  
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket 
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Development"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_table_name
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
}
