#!/usr/bin/env bash
set -euo pipefail
# VPS / Self Cloud Hosting setup — generic Ubuntu VPS (Hostinger, Contabo, Oracle, any)
# Usage: ssh ubuntu@YOUR_VPS_IP && git clone <repo> && ./scripts/vps-setup.sh

echo "=== VPS Self Hosting Setup (any Ubuntu VPS) ==="

# 1. Base
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw

# 2. Firewall (22, 3000, 11434)
sudo ufw allow OpenSSH
sudo ufw allow 3000/tcp
sudo ufw allow 11434/tcp
sudo ufw --force enable

# 3. Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER" || true
sg docker -c "docker --version" || sudo docker --version

# 4. Pull model + WebUI (Docker-only, fixed)
sudo docker compose up -d
sleep 5
for i in $(seq 1 30); do curl -fs http://localhost:11434/api/tags >/dev/null 2>&1 && break; sleep 2; done
sudo docker exec deepseek-ollama ollama pull deepseek-v4.1-flash
sudo docker exec deepseek-ollama ollama list

# 5. Nginx optional (domain + HTTPS via Cloudflare Tunnel recommended)
echo "Done! Open WebUI: http://YOUR_VPS_IP:3000"
echo "Public URL: cloudflared tunnel --url http://localhost:3000"
echo "Backup: ./scripts/backup-r2.sh"
