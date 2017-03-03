#!/bin/bash

set -e

sudo apt-get install heroku

echo "Check Heroku version.."
${HEROKUCLI_DIR}/heroku --version