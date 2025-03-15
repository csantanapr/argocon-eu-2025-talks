#!/bin/bash

# Script to deploy a static website to AWS S3
# Usage: ./deploy.sh <bucket-name> <index-file-path>

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <bucket-name> <index-file-path>"
    echo "Example: $0 my-website-bucket ./index.html"
    exit 1
fi

BUCKET_NAME=$1
INDEX_FILE=$2
REGION="us-east-1"  # Change this if you want to use a different region

echo "Starting deployment to S3 bucket: $BUCKET_NAME"

# Create the S3 bucket
echo "Creating S3 bucket..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION

# Remove public access block
echo "Removing public access block..."
aws s3api delete-public-access-block --bucket $BUCKET_NAME --region $REGION

# Set bucket policy to allow public read access
echo "Setting bucket policy for public read access..."
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::$BUCKET_NAME/*\"}]}"

# Configure the bucket for static website hosting
echo "Configuring bucket for static website hosting..."
aws s3api put-bucket-website \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --website-configuration "{\"IndexDocument\":{\"Suffix\":\"index.html\"}}"

# Upload the index.html file
echo "Uploading index.html file..."
aws s3api put-object \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --key "index.html" \
    --body "$INDEX_FILE" \
    --content-type "text/html"

# Display the website URL
echo "Deployment complete!"
echo "Your website is available at: http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
