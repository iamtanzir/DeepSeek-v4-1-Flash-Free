#!/usr/bin/env bash
set -euo pipefail
# Restore from R2 (VM erase hole) - FIX: unconditional mkdir
set -a; [ -f .env ] && . ./.env; set +a

R2_REMOTE="${R2_REMOTE:-r2}"
BUCKET="${R2_BUCKET:-deepseek-backup}"

command -v rclone >/dev/null 2>&1 || { echo "ERROR: rclone not installed. curl https://rclone.org/install.sh | sudo bash"; exit 1; }

echo "=== Restore from $R2_REMOTE:$BUCKET ==="

# ALWAYS create target dirs first (VM erase hole eshop thakbe na)
mkdir -p ./ollama-models ./open-webui
sudo mkdir -p /usr/share/ollama/.ollama/models || true

rclone sync "$R2_REMOTE:$BUCKET/models-docker" ./ollama-models --progress
rclone sync "$R2_REMOTE:$BUCKET/open-webui" ./open-webui --progress
# Legacy host backup (optional)
rclone sync "$R2_REMOTE:$BUCKET/models" /usr/share/ollama/.ollama/models --progress || true

echo "Restore done."
echo "docker compose up -d"
