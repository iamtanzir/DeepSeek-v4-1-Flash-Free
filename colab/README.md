# Google Colab Setup — DeepSeek-V4.1-Flash

> ⚠️ **সত্য কথা:** Colab free **lifetime full-time NA**.
> - Max 12h continuous run, tarpor disconnect
> - Idle 30-90 min hole disconnect
> - No persistence — VM erase hole data gayeb
> - T4 GPU free, kintu static IP nai
>
> Tai Colab **demo/testing er jonno**, lifetime er jonno **Oracle Always Free + `scripts/setup.sh`** use koro.

## Quick Setup (copy-paste)

Open `colab-setup.ipynb` in Google Colab (T4 GPU), then run cells top to bottom:

```bash
# Cell 1
!nvidia-smi
!pip -q install transformers accelerate bitsandbytes gradio pyngrok

# Cell 2 — Ollama
!curl -fsSL https://ollama.com/install.sh | sh
!ollama serve > ollama.log 2>&1 &
!ollama pull deepseek-v4.1-flash

# Cell 3 — Public URL
!curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
!sudo dpkg -i /tmp/cloudflared.deb
!cloudflared tunnel --url http://localhost:11434 &
```

Tunnel URL pele phone/PC theke API test koro:
```bash
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4.1-flash","messages":[{"role":"user","content":"Hi"}]}'
```

## Colab vs Oracle

| | Colab Free | Oracle Always Free |
|---|---|---|
| Cost | ₹0 | ₹0 |
| Duration | 12h max, idle disconnect | Lifetime (Always Free) |
| Persistence | ❌ | ✅ (R2 backup soho) |
| GPU | T4 free | CPU ARM only |
| Use case | Test/demo | Lifetime production |

Lifetime chaile Colab er bodle Oracle VM koro — main repo er `./scripts/setup.sh` already ache.
