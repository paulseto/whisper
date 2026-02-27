# Whisper meeting transcription (whisper-ctranslate2)

Transcribe or translate meeting audio/video to English using **whisper-ctranslate2** (CTranslate2 / faster-whisper). Optimized for CPU with int8 and batched inference. Optional **speaker diarization** on amd64 with a Hugging Face token.

## Features

- **Fast CPU transcription** – ~4× faster than stock OpenAI Whisper on CPU
- **Translate to English** – `--task translate` for non-English meetings
- **Multiple outputs** – `.txt`, `.srt`, `.vtt`, `.tsv`, `.json` (all formats)
- **Speaker diarization (amd64 only)** – `[SPEAKER_00]` labels in SRT when `HF_TOKEN` is set and terms are accepted
- **Multi-platform** – amd64 (with diarization) and arm64 (transcription only)
- **FFmpeg included** – Supports mp4, m4v, mp3, wav, and other common formats

## Quick start

Mount the folder that contains your file and pass the filename:

```bash
docker run --rm -v "/path/to/your/files:/app" paulseto/whisper:latest meeting.mp4
```

Transcript and subtitles are written in the same folder (e.g. `meeting.txt`, `meeting.srt`).

**With speaker diarization (amd64 image, requires Hugging Face access):**

```bash
docker run --rm -e HF_TOKEN=your_hf_token -v "/path/to/files:/app" paulseto/whisper:latest meeting.mp4
```

## Setup (Linux & Windows)

See the [GitHub repository](https://github.com/paulseto/whisper) for installation instructions, including:

- **Linux** — install `transcribe` to `/usr/local/bin` with env file support
- **Windows** — add a right-click "Transcribe with Whisper" context menu option

## Configuration

| Environment variable | Description | Default |
|---|---|---|
| `MODEL_SIZE` | Whisper model (`tiny`, `base`, `small`, `medium`, `large-v3`, `turbo`) | `turbo` |
| `HF_TOKEN` | Hugging Face token for speaker diarization (amd64 only) | — |

## Hugging Face token (for diarization on amd64)

1. Sign up or log in at [huggingface.co](https://huggingface.co/join).
2. Accept the user conditions for [pyannote/speaker-diarization-community-1](https://huggingface.co/pyannote/speaker-diarization-community-1).
3. Create a token at [Settings → Access Tokens](https://huggingface.co/settings/tokens) (Read access).
4. Pass it as `-e HF_TOKEN=your_token`. Never commit or share the token.

Diarization runs only on **amd64** images (pyannote is not installed on arm64). On arm64, transcription runs without diarization even if `HF_TOKEN` is set.
