#!/usr/bin/env bash
set -e
# One-click setup for Oracle Always Free VM (Ubuntu 22.04/24.04)
# Usage: git clone <repo> && cd repo && ./scripts/setup.sh

echo "=== DeepSeek-V4.1-Flash Free Lifetime Setup ==="

# 1. System update
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git docker.io docker-compose-plugin rclone cloudflare-warp || true

# 2. Docker enable
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# 3. Install Ollama (host)
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &
sleep 2
ollama pull deepseek-v4.1-flash
ollama list

# 4. Open WebUI via Docker
docker compose up -d

# 5. cloudflared install (if not present)
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "Installing cloudflared..."
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb -o /tmp/cloudflared.deb 2>/dev/null || \
  curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
  sudo dpkg -i /tmp/cloudflared.deb || true
fi

# 6. Quick tunnel test
echo "=== Setup Done ==="
echo "Open WebUI: http://localhost:3000"
echo "Ollama API: http://localhost:11434"
echo "Quick tunnel (test): cloudflared tunnel --url http://localhost:3000"
echo "For permanent tunnel + R2 backup, see README.md"
ollama ps || true
docker ps
