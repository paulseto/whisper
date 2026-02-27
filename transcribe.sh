#!/usr/bin/env bash
set -e

REPO="paulseto/whisper"

# Load env files (lowest to highest precedence).
# Only set variables that are not already in the environment,
# so inline/exported values always win.
load_env() {
  local file="$1"
  [ -f "$file" ] || return 0
  while IFS='=' read -r key value; do
    key="${key#"${key%%[![:space:]]*}"}"
    [[ -z "$key" || "$key" == \#* ]] && continue
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    if [ -z "${!key+set}" ]; then
      export "$key=$value"
    fi
  done < "$file"
}

load_env "/etc/whisper/env"
load_env "${XDG_CONFIG_HOME:-$HOME/.config}/whisper/env"
load_env ".env"

MODEL_SIZE="${MODEL_SIZE:-turbo}"

if [ $# -eq 0 ]; then
  echo "Usage: transcribe <file> [file2 ...]"
  echo ""
  echo "Environment variables:"
  echo "  MODEL_SIZE   Model to use (default: turbo)"
  echo "               Options: tiny, base, small, medium, large-v3, turbo"
  echo "  HF_TOKEN     HuggingFace token for speaker diarization (optional)"
  echo ""
  echo "Config files (lowest to highest precedence):"
  echo "  /etc/whisper/env              system-wide"
  echo "  ~/.config/whisper/env         per-user"
  echo "  ./.env                        current directory"
  echo "  Environment variables         inline or exported (highest)"
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
