#!/bin/bash -e

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo Skipping ansible playbook in Pull Request
  exit 0
fi

SOURCE_DIR=`pwd`

echo "Installing ansible..."
# ANSIBLE_DIR=/usr/local/bin
#
# mkdir -p ${ANSIBLE_DIR} && cd ${ANSIBLE_DIR}

# apt-get update
# apt-get install -y python3
# apt-get install -y python-pip python-dev build-essential
# pip install --upgrade pip
# pip install --upgrade virtualenv
#
# pip install ansible boto
# ansible --version
# echo "python version"
# python -V
# apt-get update
# apt-get install -y python-dev
# apt-get install -y python-pip
# apt-get install -y build-essential
#
# pip install --upgrade cffi
# pip install --upgrade pip
# pip install ansible

# installs ansible but cannot find hosts file
apt-get update
apt-get install -y software-properties-common
apt-get install -y python-boto
apt-add-repository ppa:ansible/ansible
apt-get install -y ansible

# # install using pip; doesn't work
# apt-get update
# apt-get install -y python-pip python-boto python-dev libffi-dev
# pip install ansible

cd ${SOURCE_DIR}

REGION="us-west-1"

echo "Run ansible playbook..."
# ${ANSIBLE_DIR}/ansible-playbook ${SOURCE_DIR}/ansible/vpc_create.yml --extra-vars "region=$REGION envName=dev"
# ansible-playbook ${SOURCE_DIR}/ansible/vpc_create.yml --extra-vars "region=$REGION envName=dev"

ansible-playbook -i ${SOURCE_DIR}/ansible/hosts ${SOURCE_DIR}/ansible/ec2_launch.yml
