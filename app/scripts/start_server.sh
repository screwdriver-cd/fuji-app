#!/bin/bash

NAME=fuji-app-production

echo "packer: booting appserver daemon..."
sudo service $NAME start
