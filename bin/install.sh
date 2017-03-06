#!/bin/bash

set -e

echo "Install npm modules.."
cd ./app
npm install

echo "Install jq.."
apt-get update
apt-get -y install jq