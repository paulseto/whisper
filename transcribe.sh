#!/usr/bin/env bash
set -e

REPO="paulseto/whisper"
MODEL_SIZE="${MODEL_SIZE:-turbo}"

if [ $# -eq 0 ]; then
  echo "Usage: ./transcribe.sh <file> [file2 ...]"
  echo ""
  echo "Environment variables:"
  echo "  MODEL_SIZE   Model to use (default: turbo)"
  echo "               Options: tiny, base, small, medium, large-v3, turbo"
  echo "  HF_TOKEN     HuggingFace token for speaker diarization (optional)"
  exit 1
fi

DOCKER_ARGS=()
DOCKER_ARGS+=(-e "MODEL_SIZE=${MODEL_SIZE}")
[ -n "${HF_TOKEN:-}" ] && DOCKER_ARGS+=(-e "HF_TOKEN=${HF_TOKEN}")

for input_file in "$@"; do
  if [ ! -f "$input_file" ]; then
    echo "Error: file not found: $input_file"
    continue
  fi

  dir=$(cd "$(dirname "$input_file")" && pwd)
  base=$(basename "$input_file")

  echo "=== Transcribing: $base (model: ${MODEL_SIZE}) ==="
  docker run --rm \
    -v "${dir}:/app" \
    "${DOCKER_ARGS[@]}" \
    "${REPO}:latest" \
    "$base"
  echo ""
done
