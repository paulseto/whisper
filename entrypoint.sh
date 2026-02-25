#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Error: Missing required parameter. Please provide a file name."
    echo "Usage: entrypoint.sh <filename>"
    exit 1
fi

# Extract filename without extension and create .txt version
input_file="$1"
filename=$(basename "$input_file" | sed 's/\.[^.]*$//')
txt_file="${filename}.txt"

echo "INPUT:  $input_file"
echo "OUTPUT: $txt_file"
echo "(Transcript is written only after transcription completes. Please wait.)"
echo ""

# Output txt, srt, vtt, tsv, json (whisper-ctranslate2 accepts one of: txt, vtt, srt, tsv, json, all).
OUTPUT_FMT="all"
EXTRA_ARGS=()
# Diarization only when HF_TOKEN is set and pyannote is installed (amd64 image; not on arm64).
USE_DIARIZATION=0
if [ -n "${HF_TOKEN:-}" ] && python -c "import pyannote.audio" 2>/dev/null; then
  EXTRA_ARGS+=(--hf_token "$HF_TOKEN")
  USE_DIARIZATION=1
fi

# Run whisper-ctranslate2 (faster-whisper): same CLI as OpenAI Whisper, ~4x faster on CPU.
# --compute_type int8 and --batched True speed up CPU transcription.
whisper-ctranslate2 "/app/$input_file" \
  --task translate \
  --language en \
  --model "${MODEL_SIZE:-turbo}" \
  --output_format "$OUTPUT_FMT" \
  --output_dir /app \
  --compute_type int8 \
  --batched True \
  "${EXTRA_ARGS[@]}"

# Display the generated transcript file
echo ""
echo "=== TRANSCRIPTION COMPLETE ==="
echo "Output saved to: /app/$txt_file"
[ "$USE_DIARIZATION" = "1" ] && echo "Speaker diarization: see ${filename}.srt for [SPEAKER_00] labels"
echo ""
echo "=== TRANSCRIPT CONTENT ==="
cat "/app/$txt_file"
