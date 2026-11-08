#!/usr/bin/env bash
set -euo pipefail
# Backup Ollama models + Open WebUI data to Cloudflare R2 (10GB free) - FIX: rclone check
set -a; [ -f .env ] && . ./.env; set +a

R2_REMOTE="${R2_REMOTE:-r2}"
BUCKET="${R2_BUCKET:-deepseek-backup}"

command -v rclone >/dev/null 2>&1 || { echo "ERROR: rclone not installed. curl https://rclone.org/install.sh | sudo bash"; exit 1; }
rclone lsd "$R2_REMOTE:$BUCKET" >/dev/null 2>&1 || echo "Note: R2 remote ready, first sync will create bucket paths"

echo "=== R2 Backup to $R2_REMOTE:$BUCKET ==="

if [ -d ./ollama-models ]; then
  rclone sync ./ollama-models "$R2_REMOTE:$BUCKET/models-docker" --progress
else
  echo "Skip: ./ollama-models not found"
fi

if [ -d ./open-webui ]; then
  rclone sync ./open-webui "$R2_REMOTE:$BUCKET/open-webui" --progress
else
  echo "Skip: ./open-webui not found"
fi

echo "Backup done!"
