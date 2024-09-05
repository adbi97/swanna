#!/bin/bash

# Ensure script exits on error
set -e

# Environment variables for AWS credentials and other configurations
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
AWS_REGION="${AWS_REGION}"
TF_STATE_BUCKET_NAME="${TF_STATE_BUCKET_NAME}"
DYNAMODB_TABLE_NAME="${DYNAMODB_TABLE_NAME}"
IAM_USER_NAME="${IAM_USER_NAME}"

# Export AWS credentials to be used by AWS CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION

# Create IAM user for Terraform CI
echo "Creating IAM user for Terraform CI..."
if aws iam get-user --user-name "$IAM_USER_NAME" >/dev/null 2>&1; then
  echo "IAM user $IAM_USER_NAME already exists."
else
  aws iam create-user --user-name "$IAM_USER_NAME" || { echo "Failed to create IAM user $IAM_USER_NAME"; exit 1; }
  echo "IAM user $IAM_USER_NAME created."
fi

# Attach policies to IAM user
echo "Attaching policies to IAM user..."
if aws iam list-attached-user-policies --user-name "$IAM_USER_NAME" --query "AttachedPolicies[?PolicyArn=='arn:aws:iam::aws:policy/AmazonS3FullAccess']" --output text | grep 'AmazonS3FullAccess' >/dev/null; then
  echo "IAM user $IAM_USER_NAME already has the AmazonS3FullAccess policy attached."
else
  aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" || { echo "Failed to attach AmazonS3FullAccess policy to $IAM_USER_NAME"; exit 1; }
  echo "AmazonS3FullAccess policy attached to $IAM_USER_NAME."
fi

if aws iam list-attached-user-policies --user-name "$IAM_USER_NAME" --query "AttachedPolicies[?PolicyArn=='arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess']" --output text | grep 'AmazonDynamoDBFullAccess' >/dev/null; then
  echo "IAM user $IAM_USER_NAME already has the AmazonDynamoDBFullAccess policy attached."
else
  aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess" || { echo "Failed to attach AmazonDynamoDBFullAccess policy to $IAM_USER_NAME"; exit 1; }
  echo "AmazonDynamoDBFullAccess policy attached to $IAM_USER_NAME."
fi

# Create the S3 bucket for Terraform state
echo "Creating S3 bucket for Terraform state..."
if aws s3api head-bucket --bucket "$TF_STATE_BUCKET_NAME" 2>/dev/null; then
  echo "S3 bucket $TF_STATE_BUCKET_NAME already exists and is owned by you."
else
  aws s3api create-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION" || { echo "Failed to create S3 bucket $TF_STATE_BUCKET_NAME"; exit 1; }
  echo "S3 bucket $TF_STATE_BUCKET_NAME created."
fi

# Enable versioning on the S3 bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET_NAME" --versioning-configuration Status=Enabled || { echo "Failed to enable versioning on S3 bucket $TF_STATE_BUCKET_NAME"; exit 1; }

# Create DynamoDB table for state locking
echo "Creating DynamoDB table for state locking..."
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" >/dev/null 2>&1; then
  echo "DynamoDB table $DYNAMODB_TABLE_NAME already exists."
else
  aws dynamodb create-table --table-name "$DYNAMODB_TABLE_NAME" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region "$AWS_REGION" || { echo "Failed to create DynamoDB table $DYNAMODB_TABLE_NAME"; exit 1; }
  echo "DynamoDB table $DYNAMODB_TABLE_NAME created."
fi

echo "Bootstrap process complete."
