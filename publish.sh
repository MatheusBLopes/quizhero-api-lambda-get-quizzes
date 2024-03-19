#!/bin/bash

#
# variables
#

# AWS variables
AWS_REGION=us-east-1

PROJECT_NAME=LambdaGetQuiz

LAMBDA_LAYER_NAME=python

# the directory containing the script file
dir="$(cd "$(dirname "$0")"; pwd)"
cd "$dir"

[[ $1 != 'prod' && $1 != 'dev' ]] && { echo 'usage: publish.sh <prod | dev>'; exit 1; } ;

# root account id
echo get account id
ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

echo aws lambda delete-alias $1
aws lambda delete-alias \
    --function-name $PROJECT_NAME \
    --name $1 \
    --region $AWS_REGION \
    2>/dev/null

echo zip lambda package
rm --force lambda.zip
chmod -R 777 ./app
zip -r lambda.zip app

echo aws lambda update-function-code $PROJECT_NAME
aws lambda update-function-code \
    --function-name $PROJECT_NAME \
    --zip-file fileb://lambda.zip \
    --region $AWS_REGION

echo aws lambda update-function-code $PROJECT_NAME
VERSION=$(aws lambda publish-version \
    --function-name $PROJECT_NAME \
    --description $1 \
    --region $AWS_REGION \
    --query Version \
    --output text)
echo published version: $VERSION

echo aws lambda create-alias $1
aws lambda create-alias \
    --function-name $PROJECT_NAME \
    --name $1 \
    --function-version $VERSION \
    --region $AWS_REGION
