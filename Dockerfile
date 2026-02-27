# Stage 1: Install Python packages in full image (has build tools if needed)
FROM python:3.12-bookworm AS builder

RUN pip install --no-cache-dir "pip>=26.0"
RUN pip install --no-cache-dir whisper-ctranslate2

ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then pip install --no-cache-dir "pyannote.audio==4.0"; fi

# Stage 2: Slim runtime image
FROM python:3.12-slim-bookworm

ARG MODEL_SIZE=turbo
ENV MODEL_SIZE=${MODEL_SIZE}
ENV TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD=1

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN useradd --create-home --shell /bin/bash whisper

WORKDIR /app
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER whisper
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
