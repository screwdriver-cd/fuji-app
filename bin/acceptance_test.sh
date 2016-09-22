#!/bin/bash -e

export AWS_DEFAULT_REGION=us-west-2

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Skipping ansible playbook in Pull Request"
  exit 0
fi

SOURCE_DIR=`pwd`

echo "Installing AWS CLI"
AWSCLI_DIR=/usr/local/bin

mkdir -p ${AWSCLI_DIR} && cd ${AWSCLI_DIR}
# apt-get -y update
apt-get -y install unzip
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

echo "Getting public DNS"
${AWSCLI_DIR}/aws ec2 describe-instances --filters "Name=instance.group-name,Values=fuji-app.demo" > ${SOURCE_DIR}/instance_info.txt
PUBLIC_DNS=`grep 'PublicDnsName' ${SOURCE_DIR}/instance_info.txt | head -1 | cut -d: -f2 | tr -d '", '`
echo "Public DNS=$PUBLIC_DNS"

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
