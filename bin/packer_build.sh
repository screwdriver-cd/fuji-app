#!/bin/bash

set -e

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo Skipping packer build in Pull Request
  exit 0
fi

SOURCE_DIR=`pwd`

echo "Installing packer..."
PACKER_DIR=/usr/local/bin

mkdir -p ${PACKER_DIR} && cd ${PACKER_DIR}
wget https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip
apt-get update
apt-get install unzip
unzip packer_0.10.1_linux_amd64.zip

cd ${SOURCE_DIR}

echo "Run packer build..."
${PACKER_DIR}/packer build -machine-readable \
    "./packer_config/packer_config.json" \
    | tee build.log

#fetch ami id of the new bake
AMI_ID=`grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2`

if [ -z "$AMI_ID" ]; then
    echo "Error: packer build failed! no AMI_ID"
    exit 2
fi

echo ${AMI_ID}
