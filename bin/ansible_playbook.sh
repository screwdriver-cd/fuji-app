#!/bin/bash -e

export AWS_DEFAULT_REGION=us-west-2

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo Skipping ansible playbook in Pull Request
  exit 0
fi

SOURCE_DIR=`pwd`

echo "Installing ansible..."
apt-get update
apt-get install -y software-properties-common
apt-get install -y python-boto
apt-add-repository ppa:ansible/ansible
apt-get install -y ansible

cd ${SOURCE_DIR}

echo "Run ansible playbook..."
ansible-playbook -i ${SOURCE_DIR}/ansible/hosts ${SOURCE_DIR}/ansible/ec2_launch.yml
