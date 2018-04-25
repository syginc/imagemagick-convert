#!/bin/bash

set -eo pipefail

if [ -z "$4" ] ; then
  echo "$0" owner repo version path...
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ] ; then
  echo GITHUB_TOKEN is not set
  exit 1
fi

OWNER="$1" ; shift
REPO="$1" ; shift
VERSION="$1" ; shift

echo "Get a release..."
RELEASE_RESPONSE=$(
    curl --fail https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${VERSION} \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Content-Type: application/json")

RELEASE_ID=`echo ${RELEASE_RESPONSE} | python -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

for UPLOAD_FILE in "$@"; do
  BASENAME=$(basename "$UPLOAD_FILE")
  CONTENT_TYPE=$(file --mime-type -b "$UPLOAD_FILE")

  echo "Uploading $UPLOAD_FILE"
  curl --fail -X POST https://uploads.github.com/repos/${OWNER}/${REPO}/releases/${RELEASE_ID}/assets?name=${BASENAME} \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      -H "Content-Type: ${CONTENT_TYPE}" \
      --data-binary @"${UPLOAD_FILE}"
done
