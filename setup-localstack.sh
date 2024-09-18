#!/bin/bash

# Variables
AWS_ENDPOINT="http://localhost:4566"
QUEUE_NAME="email-queue"
FUNCTION_NAME="emailProcessor"
LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-ex"
EMAIL_ADDRESS="your-email@example.com"

# Create SQS Queue
aws --endpoint-url=$AWS_ENDPOINT sqs create-queue --queue-name $QUEUE_NAME

# Create a Lambda Function
# Package the Lambda code
zip function.zip index.js

# Create Lambda Function
aws --endpoint-url=$AWS_ENDPOINT lambda create-function \
  --function-name $FUNCTION_NAME \
  --zip-file fileb://function.zip \
  --handler index.handler \
  --runtime nodejs14.x \
  --role $LAMBDA_ROLE

# Set up the SQS trigger for Lambda
aws --endpoint-url=$AWS_ENDPOINT lambda create-event-source-mapping \
  --function-name $FUNCTION_NAME \
  --event-source-arn arn:aws:sqs:us-east-1:000000000000:$QUEUE_NAME \
  --batch-size 10

# Verify email in SES
aws --endpoint-url=$AWS_ENDPOINT ses verify-email-identity --email-address $EMAIL_ADDRESS
