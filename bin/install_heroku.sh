#!/bin/bash

set -e

export SOURCE_DIR=`pwd`

echo ${SOURCE_DIR}

echo "Installing Heroku CLI.."
# export HEROKUCLI_DIR=/usr/bin

# mkdir -p ${HEROKUCLI_DIR} && cd ${HEROKUCLI_DIR}
apt-get update
apt-get -y install software-properties-common # debian only
add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | apt-key add -
apt-get -y install apt-transport-https
apt-get update
apt-get -y install heroku