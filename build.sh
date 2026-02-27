#!/usr/bin/env bash
set -e

# Optional first argument: model size (default turbo). Examples: turbo, medium, large-v2
MODEL_SIZE="${1:-large}"

# Build number in format YYYYMMDD-HHMM
BUILD_NUMBER=$(date +"%Y%m%d-%H%M")

echo "Building whisper-ctranslate2 (model: ${MODEL_SIZE}, build ${BUILD_NUMBER}) for current platform..."
docker build --no-cache --build-arg MODEL_SIZE="${MODEL_SIZE}" \
  --tag whisper:latest \
  --tag "whisper:${BUILD_NUMBER}" .

echo "Done. Image whisper:latest and whisper:${BUILD_NUMBER} ready locally."
