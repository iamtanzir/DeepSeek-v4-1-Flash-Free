#!/usr/bin/env bash
set -euo pipefail
# DeepSeek-Coder — same free setup (Ollama + Docker + Open WebUI)
# Code model, 6.7B safe for 24GB ARM RAM. Larger 33B needs more RAM.
# Official: https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-base / -instruct
# Ollama: deepseek-coder:6.7b-instruct

MODEL="${1:-deepseek-coder:6.7b-instruct}"

docker compose up -d
sleep 5
docker exec deepseek-ollama ollama pull "$MODEL"
docker exec deepseek-ollama ollama list

echo "Coder model ready: $MODEL"
echo "WebUI: http://localhost:3000  -> select $MODEL"
echo "API: http://localhost:11434/v1/chat/completions"
