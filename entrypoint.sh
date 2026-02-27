#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Missing required parameter. Please provide a file name."
    echo "Usage: entrypoint.sh <filename>"
    exit 1
fi

input_file="$1"
filename=$(basename "$input_file" | sed 's/\.[^.]*$//')
txt_file="${filename}.txt"

echo "INPUT:  $input_file"
echo "OUTPUT: $filename.{txt,srt,vtt,tsv,json}"
echo "(Transcript is written only after transcription completes. Please wait.)"
echo ""

EXTRA_ARGS=()
USE_DIARIZATION=0
if [ -n "${HF_TOKEN:-}" ] && python -c "import pyannote.audio" 2>/dev/null; then
  EXTRA_ARGS+=(--hf_token "$HF_TOKEN")
  USE_DIARIZATION=1
fi

whisper-ctranslate2 "/app/$input_file" \
  --task transcribe \
  --language en \
  --model "${MODEL_SIZE:-turbo}" \
  --output_format all \
  --output_dir /app \
  --compute_type int8 \
  --batched True \
  --vad_filter True \
  --repetition_penalty 1.2 \
  "${EXTRA_ARGS[@]}"

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo ""
  echo "=== TRANSCRIPTION FAILED (exit code $EXIT_CODE) ==="
  if [ $EXIT_CODE -eq 137 ]; then
    echo "Process was killed (OOM). Try:"
    echo "  - A smaller model: -e MODEL_SIZE=small"
    echo "  - More memory:     docker run -m 8g ..."
  fi
  exit $EXIT_CODE
fi

echo ""
echo "=== TRANSCRIPTION COMPLETE ==="
echo "Output: /app/$filename.{txt,srt,vtt,tsv,json}"
[ "$USE_DIARIZATION" = "1" ] && echo "Speaker diarization: see ${filename}.srt for [SPEAKER_00] labels"
echo ""
echo "=== TRANSCRIPT CONTENT ==="
cat "/app/$txt_file"
