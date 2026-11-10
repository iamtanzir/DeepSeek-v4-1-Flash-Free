# Google Colab — Demo Only

> **Truth first:** Colab free is **not** a lifetime host.
> - ~12 h continuous runtime, then disconnect
> - Disconnects after 30–90 min idle
> - The VM is wiped; models must be downloaded again
> - Free T4 has 16 GB VRAM

**DeepSeek-V4.1-Flash is a 552B-parameter model.** Its smallest quantised build
is ~259 GB (IQ1_M) and the normal Q4 build is ~414 GB. A 16 GB T4 cannot load
it. Anyone who tells you otherwise is wrong.

So this notebook runs **`deepseek-r1:8b`** — a real DeepSeek model that fits.

## Quick start

Open `colab-setup.ipynb` in Colab (T4 GPU) and run the cells top to bottom:

1. Install Ollama + start the server in the background
2. `ollama pull deepseek-r1:8b`
3. Test the OpenAI-compatible API
4. Optional temporary Cloudflare quick tunnel

## Test from your phone/PC

```bash
curl http://127.0.0.1:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-r1:8b","messages":[{"role":"user","content":"Hi"}]}'
```

If you used the quick tunnel, replace `127.0.0.1:11434` with the
`https://….trycloudflare.com` URL.

## Colab vs Oracle Always Free

| | Colab Free | Oracle Always Free |
|---|---|---|
| Cost | $0 | $0 |
| Duration | 12 h max, idle disconnect | 24/7 while the VM is up |
| Persistence | ❌ | ✅ (with R2/external backup) |
| GPU | T4 16 GB | CPU ARM, 24 GB RAM |
| Runs `deepseek-r1:8b` | ✅ | ✅ |
| Runs V4.1-Flash | ❌ | ❌ (needs 288 GB+) |

For lifetime hosting use the Oracle VM path in the main README:

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/setup.sh
```
