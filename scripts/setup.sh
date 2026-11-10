#!/usr/bin/env bash
# Universal installer — Linux / macOS.
#   ./scripts/setup.sh                 # free "lite" model, works on 8 GB RAM
#   ./scripts/setup.sh --mode coder    # code model
#   ./scripts/setup.sh --mode flagship --local --gpu
#   ./scripts/setup.sh --mode api      # remote endpoint, no local model
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

MODE="lite"
LOCAL=0
GPU=0
ASSUME_YES=0
MODEL_OVERRIDE=""
SUDO=""

usage() {
  cat <<'EOF'
Usage: ./scripts/setup.sh [options]

  --mode nano|lite|coder|flagship|api   Model profile (default: lite)
  --local                               Tune for a local high-end PC
  --gpu                                 Reserve an NVIDIA GPU (implies --local)
  --model NAME                          Override the Ollama model tag
  --yes, -y                             Non-interactive
  -h, --help

Profiles
  nano      deepseek-r1:1.5b        ~1.1 GB   4 GB RAM
  lite      deepseek-r1:8b          ~5.2 GB   8 GB RAM   (free forever)
  coder     deepseek-coder:6.7b-instruct  ~3.8 GB   code model
  flagship  DeepSeek-V4.1-Flash     ~259 GB   288 GB+ RAM/VRAM (real V4.1)
  api       no local model; Open WebUI uses a remote OpenAI-compatible endpoint
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --mode=*)
      MODE="${1#*=}"
      shift
      ;;
    --local)
      LOCAL=1
      shift
      ;;
    --gpu)
      GPU=1
      LOCAL=1
      shift
      ;;
    --model)
      MODEL_OVERRIDE="${2:-}"
      shift 2
      ;;
    --model=*)
      MODEL_OVERRIDE="${1#*=}"
      shift
      ;;
    --yes | -y)
      ASSUME_YES=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (try --help)"
      ;;
  esac
done

case "$MODE" in
  nano) MODEL_DEFAULT="deepseek-r1:1.5b" ;;
  lite) MODEL_DEFAULT="deepseek-r1:8b" ;;
  coder) MODEL_DEFAULT="deepseek-coder:6.7b-instruct" ;;
  flagship) MODEL_DEFAULT="frob/deepseek-v4.1-flash:552b-a8b-1017-ud-iq1_M" ;;
  api) MODEL_DEFAULT="deepseek-v4.1-flash" ;;
  *)
    usage
    die "Unknown mode: $MODE"
    ;;
esac
MODEL="${MODEL_OVERRIDE:-$MODEL_DEFAULT}"

case "$(uname -s)" in
  Linux | Darwin) ;;
  *)
    die "This script targets Linux and macOS. On Windows run: .\\scripts\\setup.ps1"
    ;;
esac

cd "$ROOT_DIR"

echo
log "DeepSeek Free installer"
log "Mode: $MODE   Model: $MODEL   Local tuning: $LOCAL   GPU: $GPU"
echo

if [ "$(id -u)" -ne 0 ] && have sudo; then
  SUDO="sudo"
fi

# ---------------------------------------------------------------------------
# 1. Docker
# ---------------------------------------------------------------------------
if ! have docker; then
  if [ "$(uname -s)" = "Linux" ]; then
    if confirm "Docker is not installed. Install Docker Engine now?"; then
      install_docker_linux
    else
      die "Docker is required."
    fi
  else
    die "Install Docker Desktop for macOS first: https://www.docker.com/products/docker-desktop/"
  fi
fi
init_docker
init_compose

# ---------------------------------------------------------------------------
# 2. Compose files
# ---------------------------------------------------------------------------
COMPOSE_FILES=(-f "$ROOT_DIR/docker-compose.yml")
if [ "$LOCAL" = "1" ]; then
  COMPOSE_FILES+=(-f "$ROOT_DIR/docker-compose.local.yml")
fi
if [ "$GPU" = "1" ]; then
  have nvidia-smi || die "--gpu requested, but nvidia-smi was not found."
  COMPOSE_FILES+=(-f "$ROOT_DIR/docker-compose.gpu.yml")
fi

dc() { "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" "$@"; }

# ---------------------------------------------------------------------------
# 3. .env
# ---------------------------------------------------------------------------
ensure_env
set_env MODEL "$MODEL"
set_env OLLAMA_BIND "${OLLAMA_BIND:-127.0.0.1}"
set_env WEBUI_PORT "${WEBUI_PORT:-3000}"
if [ "$LOCAL" = "1" ]; then
  set_env OLLAMA_KEEP_ALIVE "${OLLAMA_KEEP_ALIVE:-24h}"
  # .env.example ships 8192; bump that default for local, keep custom values.
  CTX="${OLLAMA_CONTEXT_LENGTH:-8192}"
  if [ "$CTX" = "8192" ]; then CTX=32768; fi
  set_env OLLAMA_CONTEXT_LENGTH "$CTX"
  # "Local" means this machine only. Set WEBUI_BIND=0.0.0.0 in .env for LAN access.
  BIND="${WEBUI_BIND:-0.0.0.0}"
  if [ "$BIND" = "0.0.0.0" ]; then BIND=127.0.0.1; fi
  set_env WEBUI_BIND "$BIND"
  if [ -z "${PUBLIC_URL:-}" ] || [ "${PUBLIC_URL}" = "http://localhost:3000" ]; then
    PUBLIC_URL="http://localhost:${WEBUI_PORT:-3000}"
  fi
  set_env PUBLIC_URL "$PUBLIC_URL"
else
  set_env OLLAMA_KEEP_ALIVE "${OLLAMA_KEEP_ALIVE:-30m}"
  set_env OLLAMA_CONTEXT_LENGTH "${OLLAMA_CONTEXT_LENGTH:-8192}"
fi

# ---------------------------------------------------------------------------
# 4. Guard rails: disk + RAM (the old repo claimed 24 GB for a 414 GB model)
# ---------------------------------------------------------------------------
if [ "$MODE" != "api" ]; then
  NEED_GB="$(model_size_gb "$MODEL")"
  FREE_GB="$(disk_free_gb "$ROOT_DIR")"
  log "Disk: ${FREE_GB} GB free, model needs ~${NEED_GB} GB"
  if [ "${FREE_GB:-0}" -lt "$NEED_GB" ]; then
    die "Not enough disk space. Free at least ${NEED_GB} GB and retry."
  fi

  if [ "$MODE" = "flagship" ]; then
    RAM_GB="$(ram_gb)"; RAM_GB="${RAM_GB:-0}"
    VRAM_GB="$(vram_gb)"; VRAM_GB="${VRAM_GB:-0}"
    TOTAL_GB=$(( RAM_GB + VRAM_GB ))
    log "RAM + VRAM: ${TOTAL_GB} GB"
    if [ "$TOTAL_GB" -lt 288 ]; then
      warn "DeepSeek-V4.1-Flash IQ1_M needs roughly 288 GB of combined RAM/VRAM."
      warn "This machine has ${TOTAL_GB} GB. Inference will be unusably slow or OOM."
      if ! confirm "Continue the ~259 GB download anyway?"; then
        die "Aborted. Use --mode lite for an 8 GB machine, or --mode api for the real model over the network."
      fi
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 5. Start
# ---------------------------------------------------------------------------
log "Starting containers…"
dc up -d

if ! wait_for_ollama 90; then
  dc logs --tail 60 ollama || true
  die "Ollama did not become healthy. See logs above."
fi
ok "Ollama is healthy"

# ---------------------------------------------------------------------------
# 6. Model
# ---------------------------------------------------------------------------
if [ "$MODE" = "api" ]; then
  [ -n "${OPENAI_API_BASE_URL:-}" ] && set_env OPENAI_API_BASE_URL "$OPENAI_API_BASE_URL"
  [ -n "${OPENAI_API_KEY:-}" ] && set_env OPENAI_API_KEY "$OPENAI_API_KEY"
  if [ -z "${OPENAI_API_BASE_URL:-}" ] || [ -z "${OPENAI_API_KEY:-}" ]; then
    cat <<'EOF'
fail  api mode needs a remote endpoint. Add these to .env:

  ENABLE_OPENAI_API=true
  OPENAI_API_BASE_URL=https://ollama.com/v1
  OPENAI_API_KEY=your_key

Then run: ./scripts/setup.sh --mode api
EOF
    exit 1
  fi
  set_env ENABLE_OPENAI_API true
  dc up -d --force-recreate open-webui
  ok "Open WebUI now uses ${OPENAI_API_BASE_URL}"
else
  INSTALLED="$("${DOCKER[@]}" exec "${OLLAMA_CONTAINER:-deepseek-ollama}" ollama list 2>/dev/null || true)"
  if grep -Fq -- "$MODEL" <<<"$INSTALLED"; then
    ok "Model already present: $MODEL"
  else
    log "Pulling $MODEL (this can take a while)…"
    dc exec -T ollama ollama pull "$MODEL"
    ok "Model ready: $MODEL"
  fi
fi

if ! wait_for_webui "${WEBUI_PORT:-3000}" 60; then
  dc logs --tail 60 open-webui || true
  warn "Open WebUI is not answering on /health yet; it may still be starting."
fi

# ---------------------------------------------------------------------------
# 7. Summary
# ---------------------------------------------------------------------------
echo
log "Done"
echo "  Open WebUI : http://localhost:${WEBUI_PORT:-3000}"
echo "  Ollama API : http://127.0.0.1:${OLLAMA_PORT:-11434}/v1"
if [ "$MODE" != "api" ]; then
  echo "  Model      : $MODEL"
fi
echo
echo "  First visit: create the admin account immediately."
echo "  Diagnostics: ./scripts/doctor.sh"
echo "  Public URL : see README → Cloudflare Tunnel"
echo
