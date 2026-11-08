#!/usr/bin/env bash
set -e
# Test Ollama API + Open WebUI
MODEL=${MODEL:-deepseek-v4.1-flash}
OLLAMA=${OLLAMA_BASE_URL:-http://localhost:11434}

echo "Models:"
curl -s "$OLLAMA/api/tags" | head -c 500; echo

echo "Chat test:"
curl -s "$OLLAMA/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi from DeepSeek-V4.1-Flash\"}]}" | head -c 1000; echo

echo "Open WebUI status:"
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000 || true
