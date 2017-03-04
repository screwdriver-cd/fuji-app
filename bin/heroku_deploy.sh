#!/bin/bash

set -e

HEROKUCLI_DIR=/usr/bin

echo "Create Heroku app.."
${HEROKUCLI_DIR}/heroku create

echo "Deploy Heroku app.."
git push heroku heroku:master