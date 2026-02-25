#!/usr/bin/env bash
set -e

REPO="paulseto/whisper"

echo "Tagging whisper:latest as ${REPO}:latest"
docker tag whisper:latest "${REPO}:latest"

echo "Pushing ${REPO}:latest"
docker push "${REPO}:latest"

# If a tag is passed (e.g. build number 20260224-1530), also push that
if [ -n "$1" ]; then
  echo "Tagging whisper:$1 as ${REPO}:$1"
  docker tag "whisper:$1" "${REPO}:$1"
  echo "Pushing ${REPO}:$1"
  docker push "${REPO}:$1"
fi

echo "Done."
