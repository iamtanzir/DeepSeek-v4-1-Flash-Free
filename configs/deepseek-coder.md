# DeepSeek-Coder — Free, Same Stack

Code-focused model on the same Ollama + Open WebUI stack. Runs on 8 GB RAM.

## Official links
- https://github.com/deepseek-ai/DeepSeek-Coder
- https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-instruct
- https://ollama.com/library/deepseek-coder

## Setup

```bash
chmod +x scripts/*.sh
./scripts/coder-setup.sh
```

Or directly:

```bash
./scripts/setup.sh --mode coder
```

Manual equivalent:

```bash
docker compose up -d
docker exec deepseek-ollama ollama pull deepseek-coder:6.7b-instruct
docker exec deepseek-ollama ollama list
```

Then open http://localhost:3000 and pick `deepseek-coder:6.7b-instruct`.

## Sizes

| Tag | Download | RAM |
|---|---|---|
| `deepseek-coder:1.3b` | ~0.8 GB | 2 GB |
| `deepseek-coder:6.7b-instruct` | ~3.8 GB | 8 GB |
| `deepseek-coder:33b` | ~19 GB | 32 GB+ |

`33b` does not fit the Oracle Always Free 24 GB tier comfortably. Use `6.7b`
there.

## Client integrations

- https://github.com/deepseek-ai/awesome-deepseek-integration
- OpenCode config: `configs/opencode.json.example` (change the model id)

## Credits

Model © DeepSeek (deepseek-ai). This repo does not own or redistribute weights.
See `NOTICE.md`.
