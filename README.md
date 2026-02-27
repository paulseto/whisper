# Whisper meeting transcription

Transcribe or translate meeting audio/video to English using [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2) in Docker. Outputs `.txt`, `.srt`, `.vtt`, `.tsv`, and `.json`. Optional speaker diarization on amd64 with a Hugging Face token.

**Docker image:** [paulseto/whisper](https://hub.docker.com/r/paulseto/whisper) on Docker Hub (linux/amd64 + linux/arm64).

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)
- For speaker diarization on amd64: [Hugging Face account](https://huggingface.co/join) and acceptance of [pyannote/speaker-diarization-community-1](https://huggingface.co/pyannote/speaker-diarization-community-1) terms

## Quick start

```bash
docker run --rm -v "/path/to/your/files:/app" paulseto/whisper:latest meeting.mp4
```

Output files (e.g. `meeting.txt`, `meeting.srt`) are written next to the source file.

## Setup on Linux

### Install the transcribe command

```bash
sudo cp transcribe.sh /usr/local/bin/transcribe
sudo chmod +x /usr/local/bin/transcribe
```

### Usage

```bash
transcribe meeting.mp4
transcribe recording1.m4v recording2.mp3
MODEL_SIZE=medium transcribe interview.wav
```

### Configuration files

The `transcribe` command loads env files in this order (lowest to highest precedence):

| Source | Location |
|---|---|
| System-wide | `/etc/whisper/env` |
| Per-user | `~/.config/whisper/env` |
| Per-directory | `./.env` |
| Environment variables | Inline or exported (highest) |

Environment variables always win. Example `~/.config/whisper/env`:

```
MODEL_SIZE=medium
HF_TOKEN=hf_your_token_here
```

## Setup on Windows

### Install the transcribe command

Copy `transcribe.bat` to a permanent location, for example:

```
C:\Tools\transcribe.bat
```

Usage from the command line:

```bat
transcribe.bat meeting.mp4
transcribe.bat meeting.mp4 large-v3
```

### Configuration files

The `transcribe.bat` script loads env files in this order (lowest to highest precedence):

| Source | Location |
|---|---|
| Per-user | `%APPDATA%\whisper\env` |
| Per-directory | `.\.env` |
| Environment variables | System/user env vars or inline (highest) |

Environment variables always win. Example `%APPDATA%\whisper\env`:

```
MODEL_SIZE=medium
HF_TOKEN=hf_your_token_here
```

### Right-click context menu

Add **"Transcribe with Whisper"** to the Explorer right-click menu for media files:

1. Run `add-context-menu.bat` to register the menu entry (per-user, no admin required).
2. Right-click any `.mp4` or `.m4v` file and select **"Transcribe with Whisper"**.
3. To remove it, run `remove-context-menu.bat`.

## Speaker diarization (amd64 only)

Set your Hugging Face token, then run as above:

**Linux:**
```bash
HF_TOKEN=hf_your_token transcribe meeting.mp4
```

**Windows (PowerShell):**
```powershell
$env:HF_TOKEN = "hf_your_token"
.\transcribe.bat meeting.mp4
```

Or add `HF_TOKEN` to your env file. Speaker labels appear in the `.srt` file as `[SPEAKER_00]`, `[SPEAKER_01]`, etc.

To get a token:
1. Sign up at [huggingface.co](https://huggingface.co/join).
2. Accept the terms for [pyannote/speaker-diarization-community-1](https://huggingface.co/pyannote/speaker-diarization-community-1).
3. Create a Read token at [Settings → Access Tokens](https://huggingface.co/settings/tokens).

Diarization is only available on **amd64** images (pyannote is not installed on arm64).

## Available models

| Model | Parameters | RAM | Relative Speed | Notes |
|-------|-----------|-----|---------------|-------|
| `tiny` / `tiny.en` | 39M | ~1 GB | ~10x | Fastest, lowest quality |
| `base` / `base.en` | 74M | ~1 GB | ~7x | Slightly better than tiny |
| `small` / `small.en` | 244M | ~2 GB | ~4x | Good for simple audio |
| `medium` / `medium.en` | 769M | ~5 GB | ~2x | Strong English accuracy |
| `large-v1` | 1550M | ~10 GB | 1x | First large model |
| `large-v2` | 1550M | ~10 GB | 1x | Improved training |
| `large-v3` | 1550M | ~10 GB | 1x | Most accurate |
| **`turbo`** | 809M | ~6 GB | ~8x | **Default. Near large-v3 accuracy, 8x faster** |

The `.en` variants are English-only and slightly more accurate for English. `turbo` and `large-v3-turbo` are the same model.

### Distilled models

| Model | Based On | Relative Speed | Notes |
|-------|----------|---------------|-------|
| `distil-small.en` | small | ~6x | English only, compressed |
| `distil-medium.en` | medium | ~4x | English only, compressed |
| `distil-large-v2` | large-v2 | ~4x | English only, compressed |
| `distil-large-v3` | large-v3 | ~4x | English only, compressed |
| `distil-large-v3.5` | large-v3 | ~4x | Best distilled model |

### Recommendations

- **Best quality:** `large-v3` — most accurate but slowest on CPU.
- **Best balance:** `turbo` (default) — ~95% of large-v3 quality at 8x the speed.
- **Low memory:** `small` — runs well on machines with 2-4 GB available.

## Running with Docker directly

```bash
docker run --rm -v "/path/to/files:/app" paulseto/whisper:latest meeting.mp4
```

With a different model:

```bash
docker run --rm -e MODEL_SIZE=medium -v "/path/to/files:/app" paulseto/whisper:latest meeting.mp4
```

With diarization (amd64 image):

```bash
docker run --rm -e HF_TOKEN=your_token -v "/path/to/files:/app" paulseto/whisper:latest meeting.mp4
```

## Project scripts

| Script | Purpose |
|--------|---------|
| `transcribe.sh` | Linux/macOS wrapper — transcribe one or more files via Docker. Loads env files from `/etc/whisper/env`, `~/.config/whisper/env`, and `./.env`. |
| `transcribe.bat` | Windows wrapper — transcribe one file via Docker. Auto-pulls the image if not found locally. Loads env from `%APPDATA%\whisper\env` and `.\.env`. |
| `build.sh` | Build the Docker image for the current platform. Optional arg: model size (default: `turbo`). |
| `push.sh` | Multi-platform build (linux/amd64 + linux/arm64) and push to Docker Hub. Optional arg: model size. |
| `add-context-menu.bat` | Add "Transcribe with Whisper" to the Windows right-click menu for `.mp4` and `.m4v`. |
| `remove-context-menu.bat` | Remove that context menu entry. |

## Repository layout

| File | Description |
|------|-------------|
| `Dockerfile` | Multi-stage build: Python 3.12, whisper-ctranslate2, ffmpeg; pyannote (diarization) on amd64 only. |
| `entrypoint.sh` | Container entrypoint: runs whisper-ctranslate2, outputs all formats; enables diarization when `HF_TOKEN` is set. Detects OOM kills. |
| `overview.md` | Markdown description for the Docker Hub repository page. |
| `.gitignore` | Ignores media and transcript files. |

## License

See [LICENSE](LICENSE).
