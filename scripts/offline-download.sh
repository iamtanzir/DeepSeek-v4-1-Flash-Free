#!/usr/bin/env bash
set -euo pipefail
# Offline download — model download + local backup / USB copy
# Usage: ./scripts/offline-download.sh [model] [backup-dir]
MODEL="${1:-deepseek-v4.1-flash}"
DEST="${2:-./offline-models}"

mkdir -p "$DEST"

echo "=== Offline Download: $MODEL -> $DEST ==="

# 1. Ollama Docker container check
docker compose up -d
sleep 5

# 2. Pull model (download official registry)
docker exec deepseek-ollama ollama pull "$MODEL"

# 3. Export list + copy ollama-models volume (offline bundle)
docker exec deepseek-ollama ollama list > "$DEST/models.txt"
echo "Saved: $DEST/models.txt"
echo "Copy $DEST + $MODEL files to USB/PC for offline use."
echo "Offline restore: docker exec -i deepseek-ollama ollama cp ... ba docker load — see README Offline section"

# Optional: HuggingFace snapshot for offline (if hf cmd available)
if command -v hf >/dev/null 2>&1; then
  hf download deepseek-ai/DeepSeek-V4.1-Flash --local-dir "$DEST/hf" || true
fi

echo "Offline bundle ready at $DEST"
du -sh "$DEST" || true
