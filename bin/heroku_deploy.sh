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

echo "Adding public SSH key.."
cat >~/.ssh/id_rsa.pub <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWPgMa6idxP27UT1jrcdFbjyDEj7+AQjAsn86+F5qDw1oU7pxPMFNsC1L2cIaxRo0XKJ3sxrs3cl/Jr8oc6SQoCWaIdHKpcgf7uo2yQb9ZshrVX9FRt0lBOmVCcc/E3rzzSGZNIecY1Sg+JwzsUvs9syiv9veYCVRKljyoIA3o5p8dXpNvv1H9+xdg2XuHOehLLbqnBp79LnnKUbVgQ+Uhp5UEkAEo6Wv5jYWLlifQMKVDD06Ss18Ub0I9B3XcCc19vx4y6p0QsVuUBR4ZUxzw1/yA+xlpvZ+BHskraKclbYWaWYIVbcLv9pLRj6tRW7lDsvndWuJxmjPCm+SjdZ07 tkyi@shoulderwork-lm
EOF

echo "Verifying with DNS.."
cat >~/.ssh/config <<EOF
Host heroku.com
 VerifyHostKeyDNS yes
EOF

echo "Deploy Heroku app.."
git push heroku heroku:master