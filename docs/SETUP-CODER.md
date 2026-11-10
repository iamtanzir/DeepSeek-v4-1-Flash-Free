# Option 2 — DeepSeek Coder Free Setup

Same stack, code-focused model. Runs on 8 GB RAM and on the Oracle Always Free
24 GB ARM VM.

## Copy-paste

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/coder-setup.sh
```

Or:

```bash
./scripts/setup.sh --mode coder
```

Open http://YOUR_VM_IP:3000 and pick `deepseek-coder:6.7b-instruct`.

## Test

```bash
MODEL=deepseek-coder:6.7b-instruct ./scripts/quick-test.sh
```

## Sizes

| Tag | Download | RAM |
|---|---|---|
| `deepseek-coder:1.3b` | ~0.8 GB | 2 GB |
| `deepseek-coder:6.7b-instruct` | ~3.8 GB | 8 GB |
| `deepseek-coder:33b` | ~19 GB | 32 GB+ |

## Official links

- https://github.com/deepseek-ai/DeepSeek-Coder
- https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-instruct
- https://ollama.com/library/deepseek-coder
- https://github.com/deepseek-ai/awesome-deepseek-integration
