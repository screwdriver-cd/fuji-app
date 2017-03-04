#!/bin/bash

set -e

HEROKUCLI_DIR=/usr/bin

echo `User is ${USER}`

echo "Put public ssh key in /Users/${USER}/.ssh/id_rsa.pub.."
mkdir -p /Users/${USER}/.ssh
echo `${PUBLIC_SSH_KEY}` >> /Users/${USER}/.ssh/id_rsa.pub
cat /Users/${USER}/.ssh/id_rsa.pub

echo "Add key to Heroku.."
${HEROKUCLI_DIR}/heroku keys:add

echo "Create Heroku app.."
${HEROKUCLI_DIR}/heroku create

echo "Deploy Heroku app.."
git push heroku heroku:master