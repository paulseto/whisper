FROM python:3.11.11-bookworm

ARG MODEL_SIZE=turbo
ENV MODEL_SIZE=${MODEL_SIZE}
# So entrypoint.sh can use MODEL_SIZE at runtime

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -U pip
RUN pip install --no-cache-dir whisper-ctranslate2
# Speaker diarization (pyannote) only on amd64; torchcodec has no arm64 wheel
# PyTorch 2.6+ defaults weights_only=True; pyannote checkpoints need weights_only=False (env restores old behavior)
ENV TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then pip install --no-cache-dir "pyannote.audio==4.0"; fi

WORKDIR /app

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
