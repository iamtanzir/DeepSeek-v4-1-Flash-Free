#!/usr/bin/env bash
set -e
# Restore from R2 (VM erase hole)
set -a
[ -f .env ] && source .env
set +a

R2_REMOTE=${R2_REMOTE:-r2}
BUCKET=${R2_BUCKET:-deepseek-backup}

echo "=== Restore from $R2_REMOTE:$BUCKET ==="

if [ -d /usr/share/ollama/.ollama/models ]; then
  sudo mkdir -p /usr/share/ollama/.ollama/models
  rclone sync "$R2_REMOTE:$BUCKET/models" /usr/share/ollama/.ollama/models --progress
fi

if [ -d ./ollama-models ]; then
  rclone sync "$R2_REMOTE:$BUCKET/models-docker" ./ollama-models --progress
fi

if [ -d ./open-webui ]; then
  rclone sync "$R2_REMOTE:$BUCKET/open-webui" ./open-webui --progress
fi

echo "Restore done - restart ollama + docker compose"
echo "ollama serve &"
echo "docker compose up -d"
