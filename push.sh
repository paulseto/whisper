#!/usr/bin/env bash
set -e

REPO="paulseto/whisper"
MODEL_SIZE="${1:-turbo}"
BUILD_NUMBER=$(date +"%Y%m%d-%H%M")
PLATFORMS="linux/amd64,linux/arm64"

BUILDER_NAME="whisper-multiarch"
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
  echo "Creating buildx builder: ${BUILDER_NAME}"
  docker buildx create --name "${BUILDER_NAME}" --use
else
  docker buildx use "${BUILDER_NAME}"
fi

echo "Building and pushing ${REPO} (model: ${MODEL_SIZE}, build: ${BUILD_NUMBER})"
echo "Platforms: ${PLATFORMS}"

docker buildx build --no-cache \
  --platform "${PLATFORMS}" \
  --build-arg MODEL_SIZE="${MODEL_SIZE}" \
  --tag "${REPO}:latest" \
  --tag "${REPO}:${BUILD_NUMBER}" \
  --provenance=true \
  --sbom=true \
  --push \
  .

echo "Done. Pushed ${REPO}:latest and ${REPO}:${BUILD_NUMBER} for ${PLATFORMS}."
