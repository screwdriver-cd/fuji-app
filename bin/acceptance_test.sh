#!/bin/bash

set -e

export AWS_DEFAULT_REGION=us-west-2
SOURCE_DIR=`pwd`
AWSCLI_DIR=/usr/local/bin
DEPLOYMENT_ID=`grep 'd-' ${SOURCE_DIR}/app/deploymentId.txt`


echo "Get instance id.."
INSTANCE_ID=`${AWSCLI_DIR}/aws deploy list-deployment-instances --deployment-id ${DEPLOYMENT_ID} --instance-status-filter Succeeded --query "instancesList[0]" --output text`

echo "Get public DNS.."
PUBLIC_DNS=`${AWSCLI_DIR}/aws ec2 describe-instances --instance-id ${INSTANCE_ID} --query "Reservations[0].Instances[0].PublicDnsName" --output text`

echo "Getting status of $PUBLIC_DNS.."
WAIT_TIME=0
STATUS=$(curl -I -s "$PUBLIC_DNS:8000" -o /dev/null -w "%{http_code}\n")

until [ $STATUS == "200" ] || [ $WAIT_TIME -eq 120 ]; do
  STATUS=$(curl -I -s "$PUBLIC_DNS:8000" -o /dev/null -w "%{http_code}\n")
  echo "Status is $STATUS"
  sleep 5
  WAIT_TIME=$(( $WAIT_TIME + 5 ))

  if [ $WAIT_TIME -eq 120 ]; then
    echo "Timeout $WAIT_TIME s"
    exit 1
  fi

  echo "Time elapsed: $WAIT_TIME s"
done

if [ ${STATUS} -ne 200 ]; then
  echo -e "\nAcceptance test failed. Status code: $STATUS"
  exit 1
fi

echo -e "\nAcceptance test successful! Status code: $STATUS"
