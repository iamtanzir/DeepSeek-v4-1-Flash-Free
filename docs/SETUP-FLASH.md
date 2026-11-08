# Option 1 — DeepSeek 4.1 Flash Free Setup

**Choice koro:** general chat, Bangla/English, reasoning — all free.

## Copy-paste (Oracle/VPS)

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/setup.sh
# model pull inside container done: deepseek-v4.1-flash
```

Test:
```bash
./scripts/quick-test.sh
# WebUI: http://YOUR_VM_IP:3000 -> model deepseek-v4.1-flash
```

Official:
- https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash
- https://www.deepseek.com/en/news/deepseek-v4-1-flash/
- https://ollama.com/library/deepseek-v4.1-flash
- https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4.1-Flash
