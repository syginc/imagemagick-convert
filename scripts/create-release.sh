#!/bin/bash

set -eo pipefail

if [ -z "$5" ] ; then
  echo "$0" owner repo version asset-name path
  echo "Be sure to set a GITHUB_TOKEN variable"
  exit 0
fi

OWNER="$1"
REPO="$2"
VERSION="$3"
ASSET_NAME="$4"
UPLOAD_FILE="$5"
API_JSON="
{
    \"tag_name\": \"${VERSION}\",
    \"target_commitish\": \"master\",
    \"draft\": false,
    \"prerelease\": false
}"

RELEASE_RESPONSE=$(
    curl -s --fail -X POST https://api.github.com/repos/${OWNER}/${REPO}/releases \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${API_JSON}")

RELEASE_ID=`echo ${RELEASE_RESPONSE} | python -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

CONTENT_TYPE=$(file --mime-type -b "$UPLOAD_FILE")

curl --fail -X POST https://uploads.github.com/repos/${OWNER}/${REPO}/releases/${RELEASE_ID}/assets?name=${ASSET_NAME} \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: ${CONTENT_TYPE}" \
    --data-binary @"${UPLOAD_FILE}"
