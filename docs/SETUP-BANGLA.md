# বাংলা সেটআপ গাইড — DeepSeek Free

> এই গাইডটি রিপোর নতুন ভার্সনের (v1.1.0) সাথে মিলে। পুরোনো `.docx` গাইডে
> "২৪ GB র‍্যামে V4.1-Flash চলবে" লেখা ছিল — সেটি ভুল ছিল, এখন ঠিক করা হয়েছে।

---

## ⚠️ আগে এটা পড়ো

**DeepSeek-V4.1-Flash** একটি ৫৫২B প্যারামিটারের MoE মডেল (মোট ৭৬৩B ওজন)।
এটি ২৪ GB র‍্যামের মডেল **না**।

| বিল্ড | ডাউনলোড | কমপক্ষে RAM/VRAM |
|---|---|---|
| IQ1_M | **~২৫৯ GB** | **২৮৮ GB** |
| Q4_K_M | **~৪১৪ GB** | ৪৪৮ GB |
| MXFP4 | **~৭০৮ GB** | ৭৬৮ GB |

তাই সাধারণ ল্যাপটপ বা Oracle Free VM-এ আসল V4.1-Flash চলবে না। ফ্রি টিয়ারে
**`deepseek-r1:8b`** চলে — DeepSeek-এর অফিসিয়াল R1 রিলিজ, ~৫.২ GB, ৮ GB র‍্যামে চলে।

---

## 🎯 তিনটি পথ

| | পথ A — চিরকাল ফ্রি | পথ B — হাই-এন্ড লোকাল | পথ C — API |
|---|---|---|---|
| মডেল | `deepseek-r1:8b` / coder | আসল V4.1-Flash | আসল V4.1-Flash |
| হার্ডওয়্যার | ৮ GB র‍্যাম / যেকোনো VPS | ২৮৮ GB+ RAM/VRAM | যেকোনো ফোন/পিসি |
| খরচ | $0 | শুধু হার্ডওয়্যার | প্রতি টোকেনে |

---

## 🚀 পথ A — চিরকাল ফ্রি (সবার জন্য)

Oracle Always Free VM (Ubuntu 22.04/24.04, Ampere ARM) বা যেকোনো VPS-এ SSH
করে পেস্ট করো:

```bash
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
chmod +x scripts/*.sh
./scripts/setup.sh
```

স্ক্রিপ্ট যা করে:

1. Docker ইনস্টল করে (Linux-এ),
2. Ollama + Open WebUI চালু করে,
3. `deepseek-r1:8b` নামায়,
4. স্থায়ী `WEBUI_SECRET_KEY` বানায়,
5. হেলথ চেক করে,
6. URL দেখায়।

তারপর ব্রাউজারে খোলো:

```
http://YOUR_VM_IP:3000
```

প্রথমেই **admin account** বানাও। মডেল হিসেবে `deepseek-r1:8b` বেছে নাও।

**কম র‍্যাম (৪ GB):**

```bash
./scripts/setup.sh --mode nano     # deepseek-r1:1.5b, ~১.১ GB
```

**টেস্ট:**

```bash
./scripts/quick-test.sh
./scripts/doctor.sh
```

---

## 💻 পথ B — হাই-এন্ড লোকাল পিসি

শুধু যাদের ২৮৮ GB+ RAM/VRAM আছে (Mac Studio 512 GB, Threadripper + 256 GB +
GPU, ৬× H100 ইত্যাদি)।

Windows (Docker Desktop + WSL2):

```powershell
git clone https://github.com/iamtanzir/DeepSeek-v4-1-Flash-Free.git
cd DeepSeek-v4-1-Flash-Free
.\scripts\local-setup.ps1                 # ফ্রি ৮B মডেল
.\scripts\local-setup.ps1 -Gpu            # NVIDIA GPU সহ
.\scripts\local-setup.ps1 -Mode flagship -Gpu   # আসল V4.1-Flash
```

Linux / macOS:

```bash
chmod +x scripts/*.sh
./scripts/local-setup.sh
./scripts/local-setup.sh --gpu
./scripts/local-setup.sh --mode flagship --gpu
```

> ⚠️ ১৬–২৪ GB VRAM ল্যাপটপে flagship **চলবে না**। ইন্সটলার নিজেই আটকে দেবে
> এবং `--mode lite` বা `--mode api` suggest করবে।
>
> macOS-এ Docker নয়, **native Ollama app** ব্যবহার করো (Metal GPU)।
>
> লোকাল মোডে Open WebUI শুধু `127.0.0.1`-এ বাঁধা থাকে (শুধু এই পিসি)।
> একই Wi-Fi-তে অন্য ডিভাইস থেকে খুলতে চাইলে `.env`-এ `WEBUI_BIND=0.0.0.0` দাও।

---

## ☁️ পথ C — আসল মডেল, হার্ডওয়্যার ছাড়া (API)

```bash
cp .env.example .env
# .env এ লেখো:
#   ENABLE_OPENAI_API=true
#   OPENAI_API_BASE_URL=https://ollama.com/v1
#   OPENAI_API_KEY=তোমার_কি
./scripts/setup.sh --mode api
```

Ollama Cloud, DeepSeek API, OpenRouter — যেকোনো OpenAI-compatible endpoint
চলবে। এটাই ২৮৮ GB হার্ডওয়্যার ছাড়া আসল V4.1-Flash ব্যবহারের একমাত্র উপায়।

---

## 🌐 পাবলিক URL (Cloudflare Tunnel)

```bash
# টেস্ট (URL বদলাবে)
cloudflared tunnel --url http://localhost:3000

# স্থায়ী
sudo cloudflared service install YOUR_TUNNEL_TOKEN
sudo systemctl enable --now cloudflared
```

Cloudflare Dashboard → Zero Trust → Tunnels → Public Hostname:
`ai.yourdomain.com` → `http://localhost:3000`।

**কখনোই 11434 পাবলিক করো না।** Ollama API-তে কোনো authentication নেই।

---

## 💾 R2 ব্যাকআপ

```bash
rclone config create r2 s3 provider=Cloudflare \
  access_key_id=... secret_access_key=... \
  endpoint=https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com acl=private

./scripts/backup-r2.sh --dry-run
./scripts/backup-r2.sh
./scripts/restore-r2.sh --yes
```

R2 ফ্রি ১০ GB — শুধু ৮B/coder মডেলের জন্য। আসল V4.1-Flash (২৫৯–৪১৪ GB)
R2-তে ধরবে না; external HDD/NAS ব্যবহার করো।

---

## 🔐 সিকিউরিটি

- `OLLAMA_BIND=127.0.0.1` রাখো (ডিফল্ট)।
- প্রথমেই admin account বানাও।
- `DEFAULT_USER_ROLE=pending` — নতুন ইউজারকে admin approve করবে।
- `.env` কখনো git-এ commit করো না।
- Oracle ব্যবহার করলে billing cap $0 দাও।

---

## 🐞 সমস্যা ও সমাধান

| সমস্যা | সমাধান |
|---|---|
| Docker permission denied | `sudo usermod -aG docker $USER` তারপর log out/in |
| `port 11434 already in use` | `sudo systemctl stop ollama` |
| WebUI-তে মডেল নেই | `docker exec deepseek-ollama ollama pull deepseek-r1:8b` |
| বারবার logout | `.env`-এ `WEBUI_SECRET_KEY` সেট করো |
| Tunnel 404 | hostname → `http://localhost:3000` |
| সব কিছু অদ্ভুত | `./scripts/doctor.sh` |

---

## 📌 নোট

- এই রিপো মডেলের ওজন (weights) বিতরণ করে না; অফিসিয়াল Ollama/HuggingFace
  থেকেই ডাউনলোড হয়।
- মডেল © DeepSeek (deepseek-ai)। স্ক্রিপ্ট/ডকস © Tanzir Ahmed, MIT।
- বিস্তারিত: `NOTICE.md`, `README.md`, `docs/SETUP-FLASH.md`।
