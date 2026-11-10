#!/usr/bin/env bash
# Shared helpers for the DeepSeek Free scripts. Source it, do not run it.
# shellcheck shell=bash

if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_INFO=$'\033[36m'
  C_OK=$'\033[32m'
  C_WARN=$'\033[33m'
  C_ERR=$'\033[31m'
else
  C_RESET=''
  C_INFO=''
  C_OK=''
  C_WARN=''
  C_ERR=''
fi

log()  { printf '%s==>%s %s\n' "$C_INFO" "$C_RESET" "$*"; }
ok()   { printf '%s ok %s %s\n' "$C_OK" "$C_RESET" "$*"; }
warn() { printf '%swarn%s %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
die()  { printf '%sfail%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

gen_secret() {
  if have openssl; then
    openssl rand -hex 32
  elif have python3; then
    python3 -c 'import secrets; print(secrets.token_hex(32))'
  elif have python; then
    python -c 'import secrets; print(secrets.token_hex(32))'
  else
    tr -dc 'a-f0-9' </dev/urandom | head -c 64
  fi
}

# load_env FILE — export every KEY=VALUE from a .env file.
load_env() {
  local file="${1:-$ROOT_DIR/.env}"
  [ -f "$file" ] || return 0
  set -a
  # Strip CR so a Windows-edited .env also works in WSL/Linux.
  # shellcheck disable=SC1090
  . <(tr -d '\r' <"$file")
  set +a
}

# set_env KEY VALUE — replace or append KEY=VALUE in .env and export it.
set_env() {
  local key="$1" value="$2" file="${3:-$ROOT_DIR/.env}" tmp
  [ -f "$file" ] || : >"$file"
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$value" '
    BEGIN { done = 0 }
    index($0, k "=") == 1 { print k "=" v; done = 1; next }
    { print }
    END { if (!done) print k "=" v }
  ' "$file" | tr -d '\r' >"$tmp"
  mv "$tmp" "$file"
  export "$key=$value"
}

# ensure_env — create .env from the example and generate a stable secret.
ensure_env() {
  if [ ! -f "$ROOT_DIR/.env" ]; then
    cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
    log "Created .env from .env.example"
  fi
  load_env
  if [ -z "${WEBUI_SECRET_KEY:-}" ]; then
    set_env WEBUI_SECRET_KEY "$(gen_secret)"
    ok "Generated WEBUI_SECRET_KEY"
  fi
}

init_docker() {
  have docker || die "docker not found"
  DOCKER=(docker)
  if docker info >/dev/null 2>&1; then
    return 0
  fi
  if [ "$(id -u)" -eq 0 ]; then
    die "Docker is installed but the daemon is not reachable."
  fi
  if have sudo; then
    if ! sudo docker info >/dev/null 2>&1; then
      warn "Starting Docker daemon with sudo…"
      sudo systemctl start docker 2>/dev/null || true
    fi
    if sudo docker info >/dev/null 2>&1; then
      DOCKER=(sudo docker)
      if [ -S /var/run/docker.sock ]; then
        warn "Using sudo for Docker. To drop it: sudo usermod -aG docker \"\$USER\" then log out/in."
      fi
      return 0
    fi
  fi
  die "Cannot talk to the Docker daemon. Start Docker and retry."
}

init_compose() {
  if "${DOCKER[@]}" compose version >/dev/null 2>&1; then
    COMPOSE=("${DOCKER[@]}" compose)
  elif have docker-compose; then
    COMPOSE=(docker-compose)
  else
    die "Docker Compose v2 not found. Install the compose plugin."
  fi
}

ram_gb() {
  if [ -r /proc/meminfo ]; then
    awk '/MemTotal/ { printf "%d", $2 / 1024 / 1024 }' /proc/meminfo
  elif have sysctl; then
    sysctl -n hw.memsize 2>/dev/null | awk '{ printf "%d", $1 / 1024 / 1024 / 1024 }'
  else
    echo 0
  fi
}

vram_gb() {
  if have nvidia-smi; then
    nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null \
      | awk '{ s += $1 } END { printf "%d", s / 1024 }'
  else
    echo 0
  fi
}

disk_free_gb() {
  df -Pk "$1" 2>/dev/null | awk 'NR == 2 { printf "%d", $4 / 1024 / 1024 }'
}

# models_dir — host path of the Ollama model store (honours OLLAMA_MODELS_DIR).
models_dir() {
  local d="${OLLAMA_MODELS_DIR:-$ROOT_DIR/ollama-models}"
  case "$d" in
    /*) printf '%s' "$d" ;;
    *) printf '%s' "$ROOT_DIR/${d#./}" ;;
  esac
}

# Approximate download size in GB for the guard rail.
model_size_gb() {
  case "$1" in
    *1.5b*)                      echo 2 ;;
    *deepseek-r1:8b*)            echo 7 ;;
    *deepseek-coder:6.7b*)       echo 5 ;;
    *iq1_m*|*IQ1_M*)             echo 275 ;;
    *q4_k_m*|*Q4_K*)             echo 440 ;;
    *)                           echo 20 ;;
  esac
}

confirm() {
  if [ "${ASSUME_YES:-0}" = "1" ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  local answer
  read -r -p "$1 [y/N] " answer
  case "$answer" in
    y | Y | yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

install_docker_linux() {
  have curl || die "curl is required to install Docker."
  log "Installing Docker Engine from get.docker.com…"
  # shellcheck disable=SC2086
  curl -fsSL https://get.docker.com | ${SUDO} sh
  # shellcheck disable=SC2086
  ${SUDO} systemctl enable --now docker 2>/dev/null || true
  if [ -n "${SUDO:-}" ] && [ -n "${USER:-}" ]; then
    # shellcheck disable=SC2086
    ${SUDO} usermod -aG docker "$USER" 2>/dev/null || true
  fi
  ok "Docker installed"
}

wait_for_ollama() {
  local tries="${1:-60}" i
  for i in $(seq 1 "$tries"); do
    if "${DOCKER[@]}" exec "${OLLAMA_CONTAINER:-deepseek-ollama}" ollama list >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

wait_for_webui() {
  local port="${1:-3000}" tries="${2:-60}" i
  for i in $(seq 1 "$tries"); do
    if curl -fsS --connect-timeout 2 --max-time 5 "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}
