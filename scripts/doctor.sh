#!/usr/bin/env bash
# Read-only diagnostics. Nothing here changes your system.
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

load_env
FAIL=0

# Read-only Docker detection: prefer the daemon we can actually talk to.
DOCKER=(docker)
if have docker && ! docker info >/dev/null 2>&1; then
  if have sudo && sudo -n docker info >/dev/null 2>&1; then
    DOCKER=(sudo docker)
  fi
fi

section() { printf '\n%s%s%s\n' "$C_INFO" "$1" "$C_RESET"; }
pass() { printf '  %s✓%s %s\n' "$C_OK" "$C_RESET" "$1"; }
bad() { printf '  %s✗%s %s\n' "$C_ERR" "$C_RESET" "$1"; FAIL=1; }
note() { printf '  %s·%s %s\n' "$C_WARN" "$C_RESET" "$1"; }

section "Host"
printf '  OS       : %s %s\n' "$(uname -s)" "$(uname -m)"
printf '  RAM      : %s GB\n' "$(ram_gb)"
printf '  VRAM     : %s GB\n' "$(vram_gb)"
printf '  Disk free: %s GB\n' "$(disk_free_gb "$ROOT_DIR")"

section "Docker"
if have docker; then
  pass "docker $(docker --version 2>/dev/null | sed 's/^Docker version //; s/,.*//')"
else
  bad "docker is not installed"
fi
if "${DOCKER[@]}" compose version >/dev/null 2>&1; then
  pass "$("${DOCKER[@]}" compose version --short 2>/dev/null | sed 's/^v//')"
elif have docker-compose; then
  note "legacy docker-compose found; v2 is recommended"
else
  bad "Docker Compose v2 is missing"
fi

section "Containers"
NAMES="$("${DOCKER[@]}" ps --format '{{.Names}}' 2>/dev/null || true)"
if [ -n "$NAMES" ]; then
  "${DOCKER[@]}" ps --format '  {{.Names}}  {{.Status}}' 2>/dev/null || true
else
  note "no running containers (start with ./scripts/setup.sh)"
fi
if grep -Fxq -- "${OLLAMA_CONTAINER:-deepseek-ollama}" <<<"$NAMES"; then
  pass "ollama container is running"
else
  bad "ollama container is not running"
fi
if grep -Fxq -- "${WEBUI_CONTAINER:-open-webui}" <<<"$NAMES"; then
  pass "open-webui container is running"
else
  bad "open-webui container is not running"
fi

section "Ollama"
MODELS="$("${DOCKER[@]}" exec "${OLLAMA_CONTAINER:-deepseek-ollama}" ollama list 2>/dev/null || true)"
if [ -n "$MODELS" ]; then
  pass "API is reachable inside the container"
  printf '%s\n' "$MODELS" | sed 's/^/  /'
  if [ -n "${MODEL:-}" ] && grep -Fq -- "$MODEL" <<<"$MODELS"; then
    pass "model present: $MODEL"
  elif [ -n "${MODEL:-}" ]; then
    bad "model missing: $MODEL (run: docker exec ${OLLAMA_CONTAINER:-deepseek-ollama} ollama pull $MODEL)"
  fi
else
  bad "cannot run 'ollama list' in the container"
fi

section "Ports"
OLLAMA_BINDING="$("${DOCKER[@]}" port "${OLLAMA_CONTAINER:-deepseek-ollama}" 11434/tcp 2>/dev/null | head -n 1 || true)"
if [ -n "$OLLAMA_BINDING" ]; then
  case "$OLLAMA_BINDING" in
    127.0.0.1:* | "[::1]:"*) pass "Ollama is private ($OLLAMA_BINDING)" ;;
    *) bad "Ollama is exposed publicly ($OLLAMA_BINDING). Set OLLAMA_BIND=127.0.0.1 in .env" ;;
  esac
else
  note "Ollama port is not published"
fi

section "HTTP"
if curl -fsS --connect-timeout 3 --max-time 5 "http://127.0.0.1:${WEBUI_PORT:-3000}/health" >/dev/null 2>&1; then
  pass "Open WebUI http://127.0.0.1:${WEBUI_PORT:-3000}/health"
else
  bad "Open WebUI /health is not answering on port ${WEBUI_PORT:-3000}"
fi
if curl -fsS --connect-timeout 3 --max-time 5 "http://127.0.0.1:${OLLAMA_PORT:-11434}/api/tags" >/dev/null 2>&1; then
  pass "Ollama http://127.0.0.1:${OLLAMA_PORT:-11434}/api/tags"
else
  note "Ollama API is not published on the host (expected with the default 127.0.0.1 bind if the container is down)"
fi

section "Config"
if [ -f "$ROOT_DIR/.env" ]; then
  pass ".env exists"
else
  bad ".env is missing (cp .env.example .env)"
fi
if [ -n "${WEBUI_SECRET_KEY:-}" ]; then
  pass "WEBUI_SECRET_KEY is set"
else
  bad "WEBUI_SECRET_KEY is empty; sessions will reset on restart"
fi

printf '\n'
if [ "$FAIL" -eq 0 ]; then
  ok "No blocking problems found."
else
  warn "Some checks failed. See the ✗ lines above."
fi
exit "$FAIL"
