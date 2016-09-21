#!/bin/bash

set -e

export AWS_DEFAULT_REGION=us-west-2
SOURCE_DIR=`pwd`
AWSCLI_DIR=/usr/local/bin

cd ${SOURCE_DIR}/app

echo "Run create deployment.."
${AWSCLI_DIR}/aws deploy create-deployment \
  --application-name Fuji_App \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --deployment-group-name Fuji_DepGroup \
  --s3-location bucket=fuji-app.demo,bundleType=zip,key=FujiApp.zip > ${SOURCE_DIR}/app/deploy.txt

echo "Get deployment id.."
DEPLOYMENT_ID=`grep 'deploymentId' ${SOURCE_DIR}/app/deploy.txt | cut -d, -f6 | cut -d: -f2 | tr -d '"'`
echo $DEPLOYMENT_ID > ${SOURCE_DIR}/app/deploymentId.txt

echo "Get status.."
WAIT_TIME=0
DEPLOYMENT_STATUS="Pending"

until [ $DEPLOYMENT_STATUS == "Failed" ] || [ $DEPLOYMENT_STATUS == "Succeeded" ] || [ $WAIT_TIME -eq 120 ]; do
  DEPLOYMENT_STATUS=`${AWSCLI_DIR}/aws deploy get-deployment --deployment-id ${DEPLOYMENT_ID} --query 'deploymentInfo.status' --output text`
  echo "Deploying.. $DEPLOYMENT_STATUS"
  sleep 5
  WAIT_TIME=$(( $WAIT_TIME + 5 ))

  if [ $WAIT_TIME -eq 120 ]; then
    echo "Timeout $WAIT_TIME s"
    exit 1
  fi

  echo "(Time elapsed ${WAIT_TIME}s)"
done

echo -e "\nDeployment ${DEPLOYMENT_STATUS}."

if [ ${DEPLOYMENT_STATUS} == "Failed" ]; then
  exit 1
fi
