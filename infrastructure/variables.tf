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
