# Option 1 — Free DeepSeek Setup (any machine)

There are two different things people mean by "free DeepSeek":

| | What runs | Hardware | Cost |
|---|---|---|---|
| **Free tier** | `deepseek-r1:8b` (DeepSeek's official R1 release) | 8 GB RAM, any VPS | $0 forever |
| **Flagship** | `DeepSeek-V4.1-Flash` (552B) | 288 GB+ RAM/VRAM | hardware only |
| **API** | the real V4.1-Flash, remotely | any device | per-token |

The free tier is the one that works for everyone. The flagship model is not a
24 GB model — its smallest quant is ~259 GB.

## Free tier — copy-paste

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/setup.sh
```

What it does: installs Docker (Linux), starts Ollama + Open WebUI, pulls
`deepseek-r1:8b`, generates a stable `WEBUI_SECRET_KEY`, waits for health.

Open http://YOUR_VM_IP:3000 → register the admin account → pick
`deepseek-r1:8b`.

Test:

```bash
./scripts/quick-test.sh
./scripts/doctor.sh
```

## Weak machine (4 GB)

```bash
./scripts/setup.sh --mode nano     # deepseek-r1:1.5b, ~1.1 GB
```

## Flagship — high-end workstation only

```bash
./scripts/setup.sh --mode flagship --local --gpu
```

Requires ~288 GB of combined RAM/VRAM for IQ1_M (~259 GB download). The
installer refuses below that threshold unless you force it. See the main
README's "Local high-end PC" section.

## API — real V4.1-Flash on any device

```bash
cp .env.example .env
# edit:
#   ENABLE_OPENAI_API=true
#   OPENAI_API_BASE_URL=https://ollama.com/v1
#   OPENAI_API_KEY=...
./scripts/setup.sh --mode api
```

## Official links

- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
- https://www.deepseek.com/en/news/deepseek-v4-1-flash/
- https://ollama.com/library/deepseek-v4.1-flash
- https://ollama.com/library/deepseek-r1
