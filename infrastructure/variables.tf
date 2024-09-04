variable "aws_region" {
  description = "The AWS region to deploy resources."
  default     = "ap-southeast-2"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names."
  default     = "swanna"
}

variable "aws_access_key_id" {
  description = "AWS access key ID."
}

variable "aws_secret_access_key" {
  description = "AWS secret access key."
}

variable "terraform_state_bucket" {
  description = "Name of bucket where Terraform state files are stored"
  default     = "state-bucket"
}

variable "dynamodb_table_name" {
  description = "Name of Dynamodb table"
  default     = "terraform-lock"
}
