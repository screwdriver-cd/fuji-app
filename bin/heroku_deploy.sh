#!/bin/bash

set -e

echo ${SOURCE_DIR}

HEROKUCLI_DIR=/usr/bin

echo "Check Heroku version.."
${HEROKUCLI_DIR}/heroku --version