#!/bin/bash

set -e

HEROKUCLI_DIR=/usr/bin

echo "Login to Heroku.."
cat >~/.netrc <<EOF
machine api.heroku.com
  login "${HEROKU_EMAIL}"
  password "${HEROKU_TOKEN}"
machine git.heroku.com
  login "${HEROKU_EMAIL}"
  password "${HEROKU_TOKEN}"
EOF

chmod 600 ~/.netrc

echo "Add the remote.."
git remote add heroku "git@heroku.com:${HEROKU_APP}.git"

echo "Adding heroku ssh fingerprint.."
mkdir -p ~/.ssh
ssh-keyscan -H heroku.com > ~/.ssh/known_hosts 

echo "Verifying with DNS.."
cat >~/.ssh/config <<EOF
Host heroku.com
 VerifyHostKeyDNS yes
EOF

echo "Deploy Heroku app.."
git push heroku heroku:master