# Cloudflare Tunnel — Public URL (Free, no IP change)

This gives you a stable public URL without opening ports / dealing with IP changes.

## Option A — Quick Tunnel (test, 1 min)

```bash
cloudflared tunnel --url http://localhost:3000
```

Gives `https://xxx.trycloudflare.com` — changes after restart. Good for testing.

## Option B — Permanent Tunnel (recommended, lifetime free)

1. Cloudflare Dashboard → Zero Trust → Networks → Tunnels → Create tunnel
2. Name: `deepseek-tunnel` → Connector → cloudflared → Copy token
3. On VM:
```bash
sudo cloudflared service install YOUR_TUNNEL_TOKEN
sudo systemctl status cloudflared
sudo systemctl enable --now cloudflared
```
4. Public Hostname:
   - Hostname: `ai.yourdomain.com`
   - Service: `http://localhost:3000`

Now `https://ai.yourdomain.com` is your Open WebUI. No UFW port 3000 needed.

Config file: `config.yml.example`
