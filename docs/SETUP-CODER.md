# Option 2 — DeepSeek Coder Free Setup

**Choice koro:** code likha, debug, completion — same free stack.

## Copy-paste (Oracle/VPS)

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/coder-setup.sh deepseek-coder:6.7b-instruct
# WebUI: http://YOUR_VM_IP:3000 -> model deepseek-coder:6.7b-instruct
```

Test:
```bash
./scripts/quick-test.sh
# MODEL=deepseek-coder:6.7b-instruct
```

Official:
- https://github.com/deepseek-ai/DeepSeek-Coder
- https://huggingface.co/deepseek-ai/deepseek-coder-6.7b-instruct
- https://ollama.com/library/deepseek-coder
- Integrations: https://github.com/deepseek-ai/awesome-deepseek-integration
