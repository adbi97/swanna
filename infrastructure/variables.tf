variable "aws_region" {
  description = "The AWS region to deploy resources."
  default     = "ap-southeast-2"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names."
  default     = "main-swanna"
}
