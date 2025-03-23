#!/bin/bash
# Script to create an IAM user with permissions for RHEL Graviton deployments

# Exit on error
set -e

# Variables
USER_NAME="rhel-graviton-deployer"
POLICY_NAME="RHELGravitonDeploymentPolicy"
REGION="us-east-2"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
if [ -z "$ACCOUNT_ID" ]; then
    echo "Failed to get AWS Account ID. Make sure you have configured AWS CLI."
    exit 1
fi

echo "Creating IAM policy for RHEL Graviton deployments..."

# Create the policy
POLICY_ARN=$(aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://rhel-graviton-policy.json \
    --query 'Policy.Arn' \
    --output text)

echo "Policy created with ARN: $POLICY_ARN"

# Create the user
echo "Creating IAM user: $USER_NAME"
aws iam create-user --user-name $USER_NAME

# Attach the policy to the user
echo "Attaching policy to user..."
aws iam attach-user-policy \
    --user-name $USER_NAME \
    --policy-arn $POLICY_ARN

# Create access keys
echo "Creating access keys for the user..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USER_NAME)

# Extract access key and secret access key
ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

echo "Creating AWS CLI profile configuration..."

# Create profile in AWS credentials and config files
mkdir -p ~/.aws

# Check if credentials file exists
if [ ! -f ~/.aws/credentials ]; then
    touch ~/.aws/credentials
    echo "[default]" >> ~/.aws/credentials
    echo "aws_access_key_id = YOUR_DEFAULT_ACCESS_KEY" >> ~/.aws/credentials
    echo "aws_secret_access_key = YOUR_DEFAULT_SECRET_KEY" >> ~/.aws/credentials
    echo "" >> ~/.aws/credentials
fi

# Check if config file exists
if [ ! -f ~/.aws/config ]; then
    touch ~/.aws/config
    echo "[default]" >> ~/.aws/config
    echo "region = $REGION" >> ~/.aws/config
    echo "output = json" >> ~/.aws/config
    echo "" >> ~/.aws/config
fi

# Add new profile to credentials file
echo "" >> ~/.aws/credentials
echo "[$USER_NAME]" >> ~/.aws/credentials
echo "aws_access_key_id = $ACCESS_KEY_ID" >> ~/.aws/credentials
echo "aws_secret_access_key = $SECRET_ACCESS_KEY" >> ~/.aws/credentials

# Add new profile to config file
echo "" >> ~/.aws/config
echo "[profile $USER_NAME]" >> ~/.aws/config
echo "region = $REGION" >> ~/.aws/config
echo "output = json" >> ~/.aws/config

echo "=========================="
echo "Setup completed successfully!"
echo "=========================="
echo "User Name: $USER_NAME"
echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"
echo ""
echo "The AWS profile '$USER_NAME' has been configured in your AWS credentials."
echo "You can use this profile with the AWS CLI by specifying --profile $USER_NAME"
echo "or by setting the environment variable: export AWS_PROFILE=$USER_NAME"
echo ""
echo "IMPORTANT: Store these credentials securely. This is the only time the"
echo "secret access key will be displayed."
echo "=========================="

# Save credentials to a temporary file for backup
echo "Saving credentials to $USER_NAME-credentials.txt for your reference"
echo "=========================" > $USER_NAME-credentials.txt
echo "AWS IAM User Credentials" >> $USER_NAME-credentials.txt
echo "=========================" >> $USER_NAME-credentials.txt
echo "User Name: $USER_NAME" >> $USER_NAME-credentials.txt
echo "Access Key ID: $ACCESS_KEY_ID" >> $USER_NAME-credentials.txt
echo "Secret Access Key: $SECRET_ACCESS_KEY" >> $USER_NAME-credentials.txt
echo "=========================" >> $USER_NAME-credentials.txt
echo "Keep this file secure and delete it when no longer needed." >> $USER_NAME-credentials.txt
chmod 600 $USER_NAME-credentials.txt

echo "Done!"