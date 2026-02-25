# Whisper meeting transcription

Transcribe or translate meeting audio/video to English using [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2) in Docker. Outputs `.txt`, `.srt`, `.vtt`, `.tsv`, and `.json`. Optional speaker diarization on amd64 with a Hugging Face token.

**Docker image:** [paulseto/whisper](https://hub.docker.com/r/paulseto/whisper) on Docker Hub.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Docker Compose as needed)
- For speaker diarization on amd64: [Hugging Face account](https://huggingface.co/join) and acceptance of [pyannote/speaker-diarization-community-1](https://huggingface.co/pyannote/speaker-diarization-community-1) terms

## Quick start

1. **Build the image** (once):

   ```bat
   .\build.bat
   ```

   Optional: `.\build.bat medium` to use the `medium` model instead of `turbo`.

2. **Transcribe a file** (path or filename in current directory):

   ```bat
   .\transcribe.bat meeting.mp4
   .\transcribe.bat "C:\Videos\recording.m4v"
   ```

   Output files (e.g. `meeting.txt`, `meeting.srt`) are written next to the source file.

3. **Optional – speaker diarization (amd64 only)**  
   Set your Hugging Face token, then run as above:

   ```bat
   set HF_TOKEN=hf_your_token_here
   .\transcribe.bat meeting.mp4
   ```

   Speaker labels appear in the `.srt` file. Diarization is skipped on arm64 (no pyannote in that image).

## Project scripts

| Script | Purpose |
|--------|--------|
| `transcribe.bat` | Run the container to transcribe one file; transcript and subtitles go beside the source file. |
| `build.bat` | Build the Docker image for the current platform. Optional first arg: model size (e.g. `medium`). |
| `push.bat` | Build for amd64 and arm64 and push to Docker Hub as `paulseto/whisper:YYYYMMDD-HHMM`. Optional first arg: model size. |
| `add-context-menu.reg` | Add “Transcribe with Whisper” to the right‑click menu for `.mp4` and `.m4v` (uses `%USERPROFILE%\projects\whisper\transcribe.bat`). |
| `remove-context-menu.reg` | Remove that context menu entry. |

## Running with Docker only

Mount the folder that contains your file and pass the filename:

```bash
docker run --rm -v "C:\path\to\folder:/app" whisper:latest meeting.mp4
```

With diarization (amd64 image):

```bash
docker run --rm -e HF_TOKEN=your_token -v "C:\path\to\folder:/app" whisper:latest meeting.mp4
```

## Repository layout

- `Dockerfile` – Python 3.11, whisper-ctranslate2, ffmpeg; pyannote (diarization) on amd64 only.
- `entrypoint.sh` – Container entrypoint: runs whisper-ctranslate2, outputs all formats; enables diarization when `HF_TOKEN` is set and pyannote is installed.
- `overview.md` – Copy for the Docker Hub repository description.

## License

See [LICENSE](LICENSE).
