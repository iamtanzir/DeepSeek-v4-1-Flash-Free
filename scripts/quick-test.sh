#!/usr/bin/env bash
set -euo pipefail
# Test Ollama API + Open WebUI - FIX: source .env + OLLAMA_URL fallback
set -a; [ -f .env ] && . ./.env; set +a

MODEL="${MODEL:-deepseek-v4.1-flash}"
OLLAMA="${OLLAMA_BASE_URL:-${OLLAMA_URL:-http://localhost:11434}}"

echo "Models:"
curl -sf "$OLLAMA/api/tags" | head -c 500; echo

echo "Chat test:"
curl -sf "$OLLAMA/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi from DeepSeek-V4.1-Flash\"}]}" | head -c 1000; echo

echo "Open WebUI status:"
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000 || true
