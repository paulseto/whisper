# Whisper meeting transcription

Transcribe or translate meeting audio/video to English using [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2) in Docker. Outputs `.txt`, `.srt`, `.vtt`, `.tsv`, and `.json`. Optional speaker diarization on amd64 with a Hugging Face token.

**Docker image:** [paulseto/whisper](https://hub.docker.com/r/paulseto/whisper) on Docker Hub.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)
- For speaker diarization on amd64: [Hugging Face account](https://huggingface.co/join) and acceptance of [pyannote/speaker-diarization-community-1](https://huggingface.co/pyannote/speaker-diarization-community-1) terms

## Quick start

1. **Transcribe a file**:

   ```bat
   .\transcribe.bat meeting.mp4
   .\transcribe.bat "C:\Videos\recording.m4v"
   ```

   Output files (e.g. `meeting.txt`, `meeting.srt`) are written next to the source file. If the Docker image is not found locally, it is pulled from Docker Hub automatically.

2. **Optional -- choose a model**

   Pass the model as the second argument, or set it via environment variable or `.env` file:

   ```bat
   .\transcribe.bat meeting.mp4 large-v3
   ```

   Or create a `.env` file next to `transcribe.bat`:

   ```
   MODEL_SIZE=turbo
   HF_TOKEN=hf_your_token_here
   ```

   See [Available models](#available-models) for all options.

3. **Optional -- build the image locally**

   ```bat
   .\build.bat
   ```

4. **Optional -- speaker diarization (amd64 only)**

   Set your Hugging Face token (via environment, `.env` file, or shell), then run as above:

   ```powershell
   $env:HF_TOKEN = "hf_your_token_here"
   .\transcribe.bat meeting.mp4
   ```

   Speaker labels appear in the `.srt` file. Diarization is skipped on arm64 (no pyannote in that image).

## Available models

The model can be set via the `MODEL_SIZE` environment variable, a `.env` file, or as the second argument to `transcribe.bat`:

```bat
.\transcribe.bat meeting.mp4 large-v3
```

### Standard models (OpenAI)

| Model | Parameters | VRAM | Relative Speed | Notes |
|-------|-----------|------|---------------|-------|
| `tiny` / `tiny.en` | 39M | ~1 GB | ~10x | Fastest, lowest quality |
| `base` / `base.en` | 74M | ~1 GB | ~7x | Slightly better than tiny |
| `small` / `small.en` | 244M | ~2 GB | ~4x | Good for simple audio |
| `medium` / `medium.en` | 769M | ~5 GB | ~2x | Strong English accuracy |
| `large-v1` | 1550M | ~10 GB | 1x | First large model |
| `large-v2` | 1550M | ~10 GB | 1x | Improved training |
| `large-v3` | 1550M | ~10 GB | 1x | Most accurate |
| **`turbo`** | 809M | ~6 GB | ~8x | **Default. Near large-v3 accuracy, 8x faster** |

The `.en` variants are English-only and slightly more accurate for English (mainly noticeable on `tiny` and `base`). `turbo` and `large-v3-turbo` are the same model.

### Distilled models (Hugging Face)

| Model | Based On | Relative Speed | Notes |
|-------|----------|---------------|-------|
| `distil-small.en` | small | ~6x | English only, compressed |
| `distil-medium.en` | medium | ~4x | English only, compressed |
| `distil-large-v2` | large-v2 | ~4x | English only, compressed |
| `distil-large-v3` | large-v3 | ~4x | English only, compressed |
| `distil-large-v3.5` | large-v3 | ~4x | Best distilled model |

Distilled models are smaller "student" models trained to approximate the larger model. Faster but less accurate on accented speech, overlapping speakers, and domain-specific terms.

### Recommendations

- **Best quality:** `large-v3` — most accurate but slowest on CPU.
- **Best balance:** `turbo` (default) — ~95% of large-v3 quality at 8x the speed.
- **Fast + decent:** `distil-large-v3.5` — faster than turbo, English-only.

## Windows right-click integration

Add **"Transcribe with Whisper"** to the right-click menu for `.mp4` and `.m4v` files:

1. Copy `transcribe.bat` to your home folder (`%USERPROFILE%`, e.g. `C:\Users\yourname\transcribe.bat`).
2. Run `add-context-menu.bat` to register the menu entry (per-user, no admin required).
3. Right-click any `.mp4` or `.m4v` file and select **"Transcribe with Whisper"**.

To remove it, run `remove-context-menu.bat`.

## Project scripts

| Script | Purpose |
|--------|---------|
| `transcribe.bat` | Run the container to transcribe one file; auto-pulls the image from Docker Hub if not built locally. Transcript and subtitles go beside the source file. |
| `build.bat` | Build the Docker image for the current platform. Optional arg: model size (e.g. `medium`). Tags as `whisper:latest` and `whisper:YYYYMMDD-HHMM`. |
| `push.bat` | Build for amd64 and arm64 and push to Docker Hub as `paulseto/whisper:YYYYMMDD-HHMM`. Optional arg: model size. |
| `push.sh` | Push the locally built image to Docker Hub (bash; for use in Git Bash or WSL). Optional arg: build number tag. |
| `add-context-menu.bat` | Add "Transcribe with Whisper" to the Windows right-click menu for `.mp4` and `.m4v` (per-user, uses `%USERPROFILE%\transcribe.bat`). |
| `remove-context-menu.bat` | Remove that context menu entry. |

## Running with Docker directly

Mount the folder that contains your file and pass the filename:

```bash
docker run --rm -v "C:\path\to\folder:/app" whisper:latest meeting.mp4
```

With diarization (amd64 image):

```bash
docker run --rm -e HF_TOKEN=your_token -v "C:\path\to\folder:/app" whisper:latest meeting.mp4
```

## Repository layout

| File | Description |
|------|-------------|
| `Dockerfile` | Python 3.11, whisper-ctranslate2, ffmpeg; pyannote (diarization) on amd64 only. |
| `entrypoint.sh` | Container entrypoint: runs whisper-ctranslate2, outputs all formats; enables diarization when `HF_TOKEN` is set and pyannote is installed. |
| `overview.md` | Markdown copy for the Docker Hub repository description. |
| `.gitignore` | Ignores media and transcript files (`.m4v`, `.mp4`, `.txt`, `.srt`, `.vtt`, `.tsv`, `.json`). |

## License

See [LICENSE](LICENSE).
