#!/bin/bash

set -e

export SOURCE_DIR=`pwd`

echo "Installing Heroku CLI.."
HEROKUCLI_DIR=/usr/local/bin

mkdir -p ${HEROKUCLI_DIR} && cd ${HEROKUCLI_DIR}
apt-get update
apt-get install software-properties-common # debian only
add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | apt-key add -
apt-get update
apt-get install heroku