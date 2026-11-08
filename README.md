<div align="center">

<img src="./docs/banner.svg" alt="DeepSeek v4.1 Flash & Coder — Lifetime free cloud setup" width="100%" />

# DeepSeek v4.1 Flash & Coder

**A free lifetime cloud setup — Ollama + Oracle Always Free / VPS + Open WebUI, public URL via Cloudflare Tunnel, backup via Cloudflare R2. 2 models in one repo: DeepSeek v4.1 Flash (chat) + DeepSeek Coder (code). 
Zero investment, copy-paste only.**

[![GitHub](https://img.shields.io/badge/🚀_GITHUB-iamtanzir%2FDeepSeek--v4--1--Flash--Free-22d3ee?style=for-the-badge&logo=github&logoColor=white)](https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free)
[![Version](https://img.shields.io/badge/version-1.0.1-8b5cf6?style=for-the-badge)](https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free/releases)
[![License](https://img.shields.io/badge/license-MIT-22c55e?style=for-the-badge)](./LICENSE)
[![Setup](https://img.shields.io/badge/setup-one--click-f472b6?style=for-the-badge)](#⚡-quick-start)
[![Cost](https://img.shields.io/badge/cost-$0_lifetime-0ea5e9?style=for-the-badge)](#-cost--limits)
[![NoCard](https://img.shields.io/badge/HF_Spaces-no_card-FFDD00?style=for-the-badge&labelColor=111827)](#-hf-spaces--no-card-free)

[**📘 বাংলা সেটআপ গাইড**](./DeepSeek-V4.1-Flash_Free_Lifetime_Setup_Bangla_Guide.docx) · [**🐞 Report a bug**](https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free/issues) · [**💖 Support the developer**](https://www.supportkori.com/tanzirahmed)

</div>

---

## 🖼️ Preview

<table>
  <tr>
    <td align="center" width="34%"><img src="./docs/screenshot-chat.png" alt="Chat — Open WebUI with DeepSeek-V4.1-Flash" width="100%" /><br/><sub><b>Chat</b> — Open WebUI streaming replies</sub></td>
    <td align="center" width="34%"><img src="./docs/screenshot-docker.png" alt="Docker — Ollama + Open WebUI" width="100%" /><br/><sub><b>Docker</b> — Ollama :11434 + WebUI :3000</sub></td>
    <td align="center" width="34%"><img src="./docs/screenshot-tunnel.png" alt="Cloudflare Tunnel" width="100%" /><br/><sub><b>Tunnel</b> — stable public URL, no IP change</sub></td>
  </tr>
</table>

---

## ✨ Highlights

| | |
|---|---|
| ⚡ **Zero-setup start** — 1 copy-paste e Ollama + `deepseek-v4.1-flash` + Open WebUI ready. | 🌐 **Bengali-first guide** — সম্পূর্ণ বাংলা নির্দেশিকা (Word) included. |
| ☁️ **Oracle Always Free** — Ampere ARM 4 OCPU 24GB lifetime ফ্রি, no billing. | 🐳 **Docker-only** — host Ollama conflict nai, port 11434 safe. |
| 🔒 **Cloudflare Tunnel** — no IP change, no firewall port open, stable `https://` URL. | 💾 **Cloudflare R2 backup** — 10GB ফ্রি, VM erase hole re-pull lagbe na. |
| 🆓 **HF Spaces fallback** — card na thakle o completely free. | 🧠 **OpenAI-compatible API** — `http://localhost:11434/v1/chat/completions` + OpenCode ready. |

---

## 🎯 Choose Your Model — 2 Options

> ⚠️ **First choose one.** Flash chaile Option 1, Coder chaile Option 2. Sudhu jeta choice korba setai setup koro.

| | Option 1 — DeepSeek 4.1 Flash | Option 2 — DeepSeek Coder |
|---|---|---|
| Use case | General chat, Bangla/English, reasoning | Code লেখা, debug, completion |
| Model flag | `deepseek-v4.1-flash` | `deepseek-coder:6.7b-instruct` (33b pele boro) |
| Official | https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash | https://github.com/deepseek-ai/DeepSeek-Coder |
| Setup command | `./scripts/setup.sh` + `ollama pull deepseek-v4.1-flash` | `./scripts/coder-setup.sh` + `ollama pull deepseek-coder:6.7b-instruct` |
| Ollama link | https://ollama.com/library/deepseek-v4.1-flash | https://ollama.com/library/deepseek-coder |
| Integrations | OpenCode example, vLLM recipe | https://github.com/deepseek-ai/awesome-deepseek-integration |
| RAM | 24GB safe (Q4_K_M) | 6.7B safe / 33B VRAM দরকার |

Both use **same free stack** — Ollama + Oracle Always Free / VPS + Open WebUI + Cloudflare Tunnel + R2 backup.

## ⚡ Quick Start

SSH into your Oracle VM (Ubuntu 22.04 / 24.04, Ampere ARM) and **paste this block**:

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/setup.sh
```

Wait ~5 minutes. Then open:

```
http://YOUR_VM_IP:3000
```

Register → select model `deepseek-v4.1-flash` → chat.

> ✅ **No manual install needed.** `setup.sh` does Docker + Ollama + model pull + cloudflared arch-detect + healthcheck wait.

<details>
<summary><b>5-minute manual setup (no script)</b></summary>

```bash
curl -fsSL https://get.docker.com | sudo sh
docker compose up -d
docker exec deepseek-ollama ollama pull deepseek-v4.1-flash
```

Open WebUI: `http://localhost:3000`
Ollama API: `http://localhost:11434`
</details>

<details>
<summary><b>Change the port</b></summary>

Edit `docker-compose.yml` ports `3000:8080` → `3001:8080`, then `docker compose up -d`.

</details>

---

## 🆓 Cost & Limits

| Component | Cost | Notes |
|---|---|---|
| Oracle Cloud Always Free | $0 lifetime | Ampere 4 OCPU 24GB; idle hole VM stop hote pare, R2 backup thakle restore 10 min |
| Ollama + Open WebUI | $0 | Open-source, MIT |
| Cloudflare Tunnel | $0 | Stable public URL, no port open |
| Cloudflare R2 | $0 (10GB) | Model + WebUI data backup, no re-pull |
| **Total** | **$0** | Card only verification er jonno, charge hobe na |

> ℹ️ Flash model Q4_K_M GGUF use koro — 24GB RAM e safe. Full precision hole RAM শেষ হবে.

<details>
<summary><b>Why Ollama, not vLLM?</b></summary>

vLLM er jonno 24GB+ GPU lage — free cloud e stable na (Colab T4 max 12h). Ollama CPU te chole, lifetime free. vLLM recipe: https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4.1-Flash — GPU thakle use koro.
</details>

---

## 🧩 Services

| Service | Port | URL |
|---|---|---|
| Ollama | 11434 | `http://localhost:11434/v1/chat/completions` |
| Open WebUI | 3000 | `http://localhost:3000` |
| Cloudflare Tunnel | — | `https://ai.yourdomain.com` (stable) |
| Cloudflare R2 | — | `r2:deepseek-backup` (free 10GB) |

---

## 🔐 Cloudflare Tunnel — Public URL (Copy-Paste)

```bash
# Quick tunnel (test, 1 min)
cloudflared tunnel --url http://localhost:3000
```

Permanent (Zero Trust):

1. Cloudflare Dashboard → **Zero Trust → Networks → Tunnels → Create tunnel**
2. Name: `deepseek-tunnel` → copy **Token**
3. VM e:
```bash
sudo cloudflared service install YOUR_TUNNEL_TOKEN
sudo systemctl enable --now cloudflared
```
4. Public Hostname: `ai.yourdomain.com` → `http://localhost:3000`

Config: `configs/tunnel-ready.yml` — sudhu YOUR_VM_IP / domain replace koro.

---

## 💾 R2 Backup (Copy-Paste)

```bash
cp configs/r2-ready.env.example .env
# edit .env with R2 keys
chmod +x scripts/backup-r2.sh
./scripts/backup-r2.sh

# VM erase hole restore:
./scripts/restore-r2.sh
docker compose up -d
```

---

## 🆓 HF Spaces — No Card Free

Card na thakle:

1. https://huggingface.co/spaces → search `DeepSeek-V4.1-Flash`
2. **Duplicate** → free, card lage na
3. Sleep hoile re-run koro (20-30 sec)

---

## 📴 Offline Download Option (No Internet Use)

Cloud/internet na thakle o model cholbe — ekbare download kore backup rakho:

```bash
chmod +x scripts/offline-download.sh
./scripts/offline-download.sh deepseek-v4.1-flash ./offline-models
# optional USB copy: rsync -av ./offline-models/ /mnt/usb/
```

Offline use: `offline-models/` folder + Ollama + model files USB te rakho; no internet use e
`docker compose up -d` -> model already cached -> chat cholbe. Restore/high backup: `./scripts/restore-r2.sh`

> ℹ️ Official HF snapshot: `hf download deepseek-ai/DeepSeek-V4.1-Flash --local-dir ./offline-models/hf`

---

## 🧪 Google Colab — Demo Only (NOT Lifetime)

> ⚠️ Colab free **lifetime full-time na**: 12h max, idle disconnect, data erase. Testing er jonno valo, lifetime er jonno Oracle VM.

Quick setup notebook: `colab/colab-setup.ipynb` — T4 GPU, Ollama + Cloudflare quick tunnel, no card. Full guide: `colab/README.md`.

---

## 🖥️ VPS / Self Cloud Hosting Setup (Any VPS)

Oracle chara onno kono VPS (Hostinger, Contabo, AWS, Hetzner, DigitalOcean, nijer cloud) diye use korte chaile:

```bash
# VPS e Ubuntu 22.04/24.04, SSH koro, tarpor paste:
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/vps-setup.sh
```

UFW (22/3000/11434), Docker, model pull, Nginx reverse proxy (`configs/nginx.conf.example`) — sob auto. Public URL: `cloudflared tunnel --url http://localhost:3000`

Nijer home server/PC teo ek e vabe: Docker Desktop + `docker compose up -d` chalale offline o cholbe.

---

## 🤖 API & OpenCode

```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4.1-flash","messages":[{"role":"user","content":"Hi"}]}'
```

OpenCode config: `configs/opencode.json.example` — `baseURL: http://localhost:11434/v1`

Official links:
- https://www.deepseek.com/en/news/deepseek-v4-1-flash/
- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
- https://ollama.com/library/deepseek-v4.1-flash
- https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4.1-Flash

---

## 💻 DeepSeek-Coder — Full Free (Same Setup)

Same free stack, code-focused model. Copy-paste:

```bash
chmod +x scripts/coder-setup.sh
./scripts/coder-setup.sh deepseek-coder:6.7b-instruct
# Open WebUI http://localhost:3000 -> model deepseek-coder:6.7b-instruct
```

- Official: https://github.com/deepseek-ai/DeepSeek-Coder
- Library: https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-instruct
- Integrations (client side): https://github.com/deepseek-ai/awesome-deepseek-integration

Details: `configs/deepseek-coder.md`

---

## 🧱 Project Structure

```text
DeepSeek-v4-1-Flash-Free/
├─ docker-compose.yml          # Ollama + Open WebUI (Docker-only, fixed)
├─ .env.example                # placeholders
├─ configs/
│  ├─ tunnel-ready.yml         # Cloudflare Tunnel ready
│  ├─ r2-ready.env.example     # R2 ready
│  ├─ opencode.json.example    # OpenCode config
│  └─ openwebui.yaml.example
├─ cloudflare/
│  ├─ config.yml.example
│  └─ README.md
├─ scripts/
│  ├─ setup.sh                 # one-click, bugs-fixed
│  ├─ backup-r2.sh
│  ├─ restore-r2.sh
│  ├─ quick-test.sh
│  └─ push.sh
├─ DeepSeek-V4.1-Flash_Free_Lifetime_Setup_Bangla_Guide.docx
└─ README.md
```

---

## 🔐 Security & Privacy

- UFW only 22, 3000, 11434
- Open WebUI strong admin password + Cloudflare Access
- R2 bucket **Private** — public link share koro na
- OCI billing cap **$0**
- Tunnel use korle 3000 port public khul-te hobe na

---

## 🐞 Troubleshooting

| Symptom | Fix |
|---|---|
| `permission denied docker` | `sg docker -c "docker ps"` use koro, or re-login |
| `port 11434 already in use` | Purono host Ollama kill koro: `sudo systemctl stop ollama` (Docker-only setup) |
| Restore e model nai | `./scripts/restore-r2.sh` age `mkdir -p` kore — `.env` R2 keys check |
| WebUI te model nai | `docker exec deepseek-ollama ollama pull deepseek-v4.1-flash` |
| Tunnel 404 | Hostname `ai.yourdomain.com` → `http://localhost:3000` check |

---

## 🗓️ Changelog

<details open>
<summary><b>v1.0.1 — current</b></summary>

- 🛠️ Bugfix: host vs container Ollama port conflict marattok, restore-guard, `sg docker`, arch-detect, CRLF fix
- 🏷️ README tanzir-ai style (banner, badges, highlights, Bangla guide link)

</details>
<details>
<summary><b>v1.0.0</b></summary>

- Initial public release — Ollama + Oracle + Open WebUI + Tunnel + R2 backup

</details>

---

## 💖 Support the Developer

<div align="center">

[![Support on SupportKori](https://img.shields.io/badge/💖_SUPPORT_THE_DEVELOPER-SupportKori-FFDD00?style=for-the-badge&labelColor=111827)](https://www.supportkori.com/tanzirahmed)

**DeepSeek v4.1 Flash & Coder by Tanzir Ahmed** · *Zero Investment • Lifetime Use*

</div>

---

## 🙏 Development Credit & Legal Notice

- **Model:** @DeepSeek / @deepseek-ai — [`DeepSeek-V4.1-Flash`](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) · [DeepSeek News](https://www.deepseek.com/en/news/deepseek-v4-1-flash/) · [Ollama](https://ollama.com/library/deepseek-v4.1-flash) — weights copyright & trademark © DeepSeek. This repo is setup only, does NOT own or redistribute the model.
- **This repo (scripts/docs):** © Tanzir Ahmed — MIT (see `LICENSE`, `NOTICE.md`).
- **Others:** Ollama, Open WebUI, Cloudflare, Oracle — their own licenses/trademarks apply.
- **Copyright / ICT law:** Official source theke download, no copied source/logo beyond fair-use credit. Bangladesh ICT Act 2006 / Cyber Security Act 2023 ba DMCA violation kore na. Details: [`NOTICE.md`](./NOTICE.md).

---

## 📄 License

**MIT License** — free to use, modify, and distribute.

<div align="center">

© 2026 Tanzir Ahmed — **DeepSeek v4.1 Flash & Coder**

[Repository](https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free) · [Issues](https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free/issues) · [Support](https://www.supportkori.com/tanzirahmed)

</div>
