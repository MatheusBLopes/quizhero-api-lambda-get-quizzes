#!/bin/bash

#
# variables
#

# AWS variables
AWS_REGION=us-east-1

LAMBDA_NAME=LambdaGetQuiz

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
    --function-name $LAMBDA_NAME \
    --name $1 \
    --region $AWS_REGION \
    2>/dev/null

echo build
cd ./app
pip install requirements.txt

echo zip lambda package
rm --force lambda.zip
chmod -R 777 ./app
zip -r lambda.zip app

STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)

while [[ "$STATE" == "InProgress" ]]
do
    echo "sleep 5sec ...."
    sleep 5s
    STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)
    echo $STATE
done

echo aws lambda update-function-code $LAMBDA_NAME
aws lambda update-function-code \
    --function-name $LAMBDA_NAME \
    --zip-file fileb://lambda.zip \
    --region $AWS_REGION

STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)

while [[ "$STATE" == "InProgress" ]]
do
    echo "sleep 5sec ...."
    sleep 5s
    STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)
    echo $STATE
done

echo aws lambda version $LAMBDA_NAME
VERSION=$(aws lambda publish-version \
    --function-name $LAMBDA_NAME \
    --description $1 \
    --region $AWS_REGION \
    --query Version \
    --output text)
echo published version: $VERSION


STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)

while [[ "$STATE" == "InProgress" ]]
do
    echo "sleep 5sec ...."
    sleep 5s
    STATE=$(aws lambda get-function --function-name "$LAMBDA_NAME" --region $AWS_REGION --query 'Configuration.LastUpdateStatus' --output text)
    echo $STATE
done

echo aws lambda create-alias $1
aws lambda create-alias \
    --function-name $LAMBDA_NAME \
    --name $1 \
    --function-version $VERSION \
    --region $AWS_REGION
