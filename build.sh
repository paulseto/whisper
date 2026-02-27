#!/usr/bin/env bash
set -e

MODEL_SIZE="${1:-turbo}"
BUILD_NUMBER=$(date +"%Y%m%d-%H%M")

echo "Building whisper-ctranslate2 (model: ${MODEL_SIZE}, build ${BUILD_NUMBER}) for current platform..."
docker buildx build --no-cache \
  --build-arg MODEL_SIZE="${MODEL_SIZE}" \
  --tag whisper:latest \
  --tag "whisper:${BUILD_NUMBER}" \
  --load \
  .

echo "Done. Image whisper:latest and whisper:${BUILD_NUMBER} ready locally."
