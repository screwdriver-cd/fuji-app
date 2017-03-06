#!/bin/bash

set -e

echo "Creating a tarball.."
tar -czf ./fuji-app.tgz ./app

echo "Provisioning a bucket.."
curl -n -X POST https://api.heroku.com/apps/${HEROKU_APP}/sources \
-H 'Accept: application/vnd.heroku+json; version=3' \
-H "Authorization: Bearer ${HEROKU_API_KEY}" > ./output.txt

PUT_URL=$(cat ./output.txt | jq -r '.source_blob.put_url')
GET_URL=$(cat ./output.txt | jq -r '.source_blob.get_url')

echo "Upload data.."
curl "${PUT_URL}" \
  -X PUT -H 'Content-Type:' --data-binary @fuji-app.tgz

echo "Create the build.."
BODY=$(jq -n --arg get_url "${GET_URL}" '{"source_blob":{"url": $get_url, "version": "cb6999d361a0244753cf89813207ad53ad906a14"}}')

curl -n -X POST https://api.heroku.com/apps/${HEROKU_APP}/builds \
-d "${BODY}" \
-H 'Accept: application/vnd.heroku+json; version=3' \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${HEROKU_API_KEY}"

echo "Done building your app!"

