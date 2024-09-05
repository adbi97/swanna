#!/bin/bash

# Ensure script exits on error
set -e

# Environment variables for AWS credentials
AWS_ACCESS_KEY_ID="${{ secrets.AWS_ACCESS_KEY_ID }}"
AWS_SECRET_ACCESS_KEY="${{ secrets.AWS_SECRET_ACCESS_KEY }}"
AWS_REGION="ap-southeast-2"

# Create the S3 bucket for Terraform state
echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION" --profile default

# Enable versioning on the S3 bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET_NAME" --versioning-configuration Status=Enabled --profile default

# Create DynamoDB table for state locking
echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table --table-name "$DYNAMODB_TABLE_NAME" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region "$AWS_REGION" --profile default

# Create IAM user for Terraform CI
echo "Creating IAM user for Terraform CI..."
aws iam create-user --user-name "$IAM_USER_NAME" --profile default

# Attach policy to IAM user
echo "Attaching policy to IAM user..."
aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" --profile default
aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "arn:aws:iam::aws:policy/AWSDynamoDBFullAccess" --profile default

echo "Bootstrap process complete."
