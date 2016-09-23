#!/bin/sh

echo "Install nginx"
sudo apt-get -y update
sudo apt-get -y install nginx

echo "Install nodejs"
curl -sL https://deb.nodesource.com/setup_4.x — Node.js v4 LTS "Argon" | sudo bash -
sudo apt-get -y install nodejs
