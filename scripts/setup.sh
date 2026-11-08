#!/usr/bin/env bash
set -e
# One-click setup for Oracle Always Free VM (Ubuntu 22.04/24.04)
# CRITICAL FIXES:
#  - Docker-only Ollama (host Ollama na, 11434 port conflict hoy na)
#  - sudo docker + sg docker group (permission denied hoy na)
#  - cloudflared arch auto-detect (arm64/x86_64)
#  - rclone official installer (apt e nai)
# Usage: git clone <repo> && cd repo && ./scripts/setup.sh
set -u

echo "=== DeepSeek-V4.1-Flash Free Lifetime Setup ==="

# 1. System base + Docker
sudo apt update
sudo apt install -y curl git ca-certificates
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER" || true

# sg dollar usage - current shell e docker group active koro
# script sesh hole newgrp niye docker compose chalabo
SG_DOCKER="sg docker -c"

# 2. Docker Compose v2 already docker plugin, just bring up (Ollama INSIDE container)
$SG_DOCKER "docker compose up -d" || sudo docker compose up -d
sleep 3

# 3. Wait for Ollama health
echo "Waiting for Ollama..."
for i in $(seq 1 30); do
  if curl -fs http://localhost:11434/api/tags >/dev/null 2>&1; then break; fi
  echo "  Ollama not ready yet... ($i/30)"
  sleep 2
done
curl -fs http://localhost:11434/api/tags > /dev/null || { echo "ERROR: Ollama container did not start. docker logs deepseek-ollama"; exit 1; }

# 4. Pull model INSIDE container (not host)
MODEL="${MODEL:-deepseek-v4.1-flash}"
$SG_DOCKER "docker exec deepseek-ollama ollama pull $MODEL" || sudo docker exec deepseek-ollama ollama pull "$MODEL"
$SG_DOCKER "docker exec deepseek-ollama ollama list" || sudo docker exec deepseek-ollama ollama list

# 5. cloudflared - arch detect
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "Installing cloudflared..."
  ARCH="$(uname -m)"
  case "$ARCH" in
    aarch64|arm64) CF_ARCH="arm64" ;;
    x86_64|amd64)  CF_ARCH="amd64" ;;
    *) echo "Unknown arch: $ARCH"; exit 1 ;;
  esac
  curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}.deb" -o /tmp/cloudflared.deb
  sudo dpkg -i /tmp/cloudflared.deb
fi

echo "=== Setup Done ==="
echo "Open WebUI: http://localhost:3000"
echo "Ollama API: http://localhost:11434"
echo "Quick tunnel (test): cloudflared tunnel --url http://localhost:3000"
echo "For permanent tunnel + R2 backup, see README.md"
($SG_DOCKER "docker ps" || sudo docker ps)
