# DeepSeek 4.1 Flash: Free

**Repo Name: `DeepSeek-4.1-Flash-Free`** (GitHub-safe name)

**Zero Investment • Lifetime Setup • Ollama + Oracle Always Free + Open WebUI + Cloudflare Tunnel + R2 Backup**

One-click setup / dễ setup repo.

## Quick Start — Oracle Always Free VM

SSH into your Oracle VM (Ubuntu 22.04/24.04 ARM 4 OCPU 24GB) and run:

```bash
git clone https://github.com/your-username/DeepSeek-4.1-Flash-Free.git
cd DeepSeek-4.1-Flash-Free
chmod +x scripts/setup.sh
./scripts/setup.sh
```

That installs Ollama, pulls `deepseek-v4.1-flash`, starts Docker + Open WebUI.

### 5-minute quick setup (manual)

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull deepseek-v4.1-flash
docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway --name open-webui --restart unless-stopped ghcr.io/open-webui/open-webui:main
```

Open `http://YOUR_VM_IP:3000` → register → model `deepseek-v4.1-flash`

## File Structure

```
deepseek-v4-1-flash-free-lifetime/
├── docker-compose.yml          # Ollama + Open WebUI
├── .env.example                # copy to .env
├── configs/
│   ├── opencode.json.example
│   └── openwebui.yaml.example
├── cloudflare/
│   ├── config.yml.example      # Cloudflare Tunnel
│   └── README.md
├── scripts/
│   ├── setup.sh                # one-click Oracle VM setup
│   ├── backup-r2.sh            # R2 backup (10GB free)
│   ├── restore-r2.sh           # VM erase hole restore
│   └── quick-test.sh           # API test
├── DeepSeek-V4.1-Flash_Free_Lifetime_Setup_Bangla_Guide.docx
└── README.md
```

## Services

- **Ollama** `:11434` — API: `http://localhost:11434/v1/chat/completions`
- **Open WebUI** `:3000` — Chat UI
- **Cloudflare Tunnel** — public stable URL, no IP change, no port open
- **Cloudflare R2** — model backup, VM erase hobe na re-pull

## Cloudflare Tunnel (Free Public URL)

```bash
# Quick tunnel for test
cloudflared tunnel --url http://localhost:3000

# Permanent: Cloudflare Dashboard > Zero Trust > Tunnels > Create
sudo cloudflared service install YOUR_TUNNEL_TOKEN
sudo systemctl status cloudflared
```

Config example: `cloudflare/config.yml.example`

## R2 Backup

```bash
cp .env.example .env
# edit .env with R2 keys
chmod +x scripts/backup-r2.sh
./scripts/backup-r2.sh

# Restore
./scripts/restore-r2.sh
```

## HF Spaces — No Card Free

Card na thakle: [huggingface.co/spaces](https://huggingface.co/spaces) > search `DeepSeek-V4.1-Flash` > Duplicate → free.

## API Test

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4.1-flash","messages":[{"role":"user","content":"Hi"}]}'
```

## Security Checklist

- UFW only 22, 3000, 11434
- Open WebUI password strong
- Cloudflare Access on public hostname
- R2 bucket private
- OCI billing cap $0

## Links

- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
- https://ollama.com/library/deepseek-v4.1-flash
- https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4.1-Flash
- https://www.deepseek.com/en/news/deepseek-v4-1-flash/

## License

MIT
