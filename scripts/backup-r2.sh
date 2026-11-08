#!/usr/bin/env bash
set -e
# Backup Ollama models + Open WebUI data to Cloudflare R2 (10GB free)
# Prereq: rclone configured as 'r2' remote, or set .env

set -a
[ -f .env ] && source .env
set +a

R2_REMOTE=${R2_REMOTE:-r2}
BUCKET=${R2_BUCKET:-deepseek-backup}

echo "=== R2 Backup to $R2_REMOTE:$BUCKET ==="

# Ollama models (host path)
if [ -d /usr/share/ollama/.ollama/models ]; then
  rclone sync /usr/share/ollama/.ollama/models "$R2_REMOTE:$BUCKET/models" --progress
fi

# Local docker ollama models
if [ -d ./ollama-models ]; then
  rclone sync ./ollama-models "$R2_REMOTE:$BUCKET/models-docker" --progress
fi

# Open WebUI data
if [ -d ./open-webui ]; then
  rclone sync ./open-webui "$R2_REMOTE:$BUCKET/open-webui" --progress
fi

echo "Backup done!"
