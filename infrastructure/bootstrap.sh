#!/bin/bash

# Variables
S3_BUCKET_NAME="tftstate"
REGION="ap-southeast-2"
DYNAMODB_TABLE_NAME="terraform-lock"
IAM_USER_NAME="terraform-ci-user"
POLICY_NAME="TerraformS3Policy"

# Create the S3 bucket for Terraform state
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" 2>/dev/null; then
  echo "S3 bucket $S3_BUCKET_NAME already exists"
else
  echo "Creating S3 bucket $S3_BUCKET_NAME"
  aws s3api create-bucket --bucket "$S3_BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
  aws s3api put-bucket-versioning --bucket "$S3_BUCKET_NAME" --versioning-configuration Status=Enabled
fi

# Create DynamoDB table for state locking
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" 2>/dev/null; then
  echo "DynamoDB table $DYNAMODB_TABLE_NAME already exists"
else
  echo "Creating DynamoDB table $DYNAMODB_TABLE_NAME"
  aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --region "$REGION"
fi

# Create IAM user for Terraform
if aws iam get-user --user-name "$IAM_USER_NAME" 2>/dev/null; then
  echo "IAM user $IAM_USER_NAME already exists"
else
  echo "Creating IAM user $IAM_USER_NAME"
  aws iam create-user --user-name "$IAM_USER_NAME"
  aws iam create-access-key --user-name "$IAM_USER_NAME"
fi

# Attach IAM policy to allow S3 and DynamoDB access for Terraform
if aws iam list-policies --query 'Policies[?PolicyName==`$POLICY_NAME`]' --output text | grep $POLICY_NAME; then
  echo "IAM policy $POLICY_NAME already exists"
else
  echo "Creating and attaching IAM policy $POLICY_NAME"
  aws iam create-policy --policy-name "$POLICY_NAME" --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:*",
          "dynamodb:*"
        ],
        "Resource": [
          "arn:aws:s3:::'"$S3_BUCKET_NAME"'/*",
          "arn:aws:dynamodb:'"$REGION"':*:table/'"$DYNAMODB_TABLE_NAME"'"
        ]
      }
    ]
  }'
  aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn arn:aws:iam::aws:policy/$POLICY_NAME
fi

echo "Bootstrap process complete."
