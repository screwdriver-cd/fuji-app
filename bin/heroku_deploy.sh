#!/bin/bash

set -e

HEROKUCLI_DIR=/usr/local/bin

echo "Check Heroku version.."
${HEROKUCLI_DIR}/heroku --version