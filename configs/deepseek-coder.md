# DeepSeek-Coder — Full Free (Same Setup)

Code-focused, Ollama + Oracle Always Free + Open WebUI — $0 lifetime.

## Official links
- https://github.com/deepseek-ai/DeepSeek-Coder
- https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-instruct
- https://ollama.com/library/deepseek-coder

## Setup (copy-paste)

```bash
# Inside same repo, same VM:
docker compose up -d
docker exec deepseek-ollama ollama pull deepseek-coder:6.7b-instruct
# miss budget: 33B use pele:
# docker exec deepseek-ollama ollama pull deepseek-coder:33b
```

Or script:
```bash
chmod +x scripts/coder-setup.sh
./scripts/coder-setup.sh
```

Open WebUI -> model `deepseek-coder:6.7b-instruct` -> code chat.

## Awesome DeepSeek Integration

Community integrations list:
- https://github.com/deepseek-ai/awesome-deepseek-integration

Useful for IDE / VSCode / API client — this repo only does server side, integration link above for client.

## Credits
Model © DeepSeek (deepseek-ai) — this repo does NOT own or redistribute weights. NOTICE.md দেখো।
