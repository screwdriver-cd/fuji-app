#!/bin/bash

set -e

export AWS_DEFAULT_REGION=us-west-2

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Skipping packer build in Pull Request"
  exit 0
fi

SOURCE_DIR=`pwd`

echo "Installing AWS CLI..."
AWSCLI_DIR=/usr/local/bin

mkdir -p ${AWSCLI_DIR} && cd ${AWSCLI_DIR}

apt-get -y update
apt-get -y install unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

cd ${SOURCE_DIR}/app

echo "Run deploy push..."
${AWSCLI_DIR}/aws deploy push \
  --application-name Fuji_App \
  --s3-location s3://fuji-app.demo/FujiApp.zip \
  --ignore-hidden-files

echo "Run create deployment..."
${AWSCLI_DIR}/aws deploy create-deployment \
  --application-name Fuji_App \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --deployment-group-name Fuji_DepGroup \
  --s3-location bucket=fuji-app.demo,bundleType=zip,key=FujiApp.zip > ${SOURCE_DIR}/app/deploy.txt

echo "Get deployment id..."
DEPLOYMENT_ID=`grep 'deploymentId' ${SOURCE_DIR}/app/deploy.txt | cut -d, -f6 | cut -d: -f2 | tr -d '"'`
echo $DEPLOYMENT_ID

echo "Get status..."
WAIT_TIME=0
DEPLOYMENT_STATUS="Pending"
until [ $DEPLOYMENT_STATUS == "Failed" ] || [ $DEPLOYMENT_STATUS == "Succeeded" ] || [ $WAIT_TIME -eq 60 ]; do
  DEPLOYMENT_STATUS=`${AWSCLI_DIR}/aws deploy get-deployment --deployment-id ${DEPLOYMENT_ID} --query 'deploymentInfo.status' --output text`
  echo $DEPLOYMENT_STATUS
  sleep 5
  WAIT_TIME=$(( $WAIT_TIME + 5 ))
  echo $WAIT_TIME
done

echo "Deployment ${DEPLOYMENT_STATUS}."

if [ ${DEPLOYMENT_STATUS} == "Failed" ]; then
  exit 0
fi

echo "Get instance id..."
INSTANCE_ID=`${AWSCLI_DIR}/aws deploy list-deployment-instances --deployment-id ${DEPLOYMENT_ID} --instance-status-filter Succeeded --query "instancesList[0]" --output text`
echo "Instance id=$INSTANCE_ID"

PUBLIC_DNS=`${AWSCLI_DIR}/aws ec2 describe-instances --instance-id ${INSTANCE_ID} --query "Reservations[0].Instances[0].PublicDnsName" --output text`
echo "Public DNS=$PUBLIC_DNS"

echo "Acceptance test..."
echo `curl ${PUBLIC_DNS}:8000`
