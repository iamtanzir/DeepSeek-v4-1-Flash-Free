#!/usr/bin/env bash
# Generic Ubuntu/Debian VPS setup: firewall + Docker + free lite model.
#   ./scripts/vps-setup.sh
#   ./scripts/vps-setup.sh --mode coder
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

# Read .env first so the firewall opens the real WEBUI_PORT.
load_env

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# Only SSH and the authenticated WebUI port. NEVER open 11434: the Ollama API
# has no authentication and would let anyone on the internet use your machine.
if have ufw; then
  log "Configuring UFW (22 + ${WEBUI_PORT:-3000}/tcp, Ollama stays private)"
  # shellcheck disable=SC2086
  ${SUDO} ufw allow OpenSSH
  # shellcheck disable=SC2086
  ${SUDO} ufw allow "${WEBUI_PORT:-3000}/tcp"
  # shellcheck disable=SC2086
  ${SUDO} ufw --force enable
  # shellcheck disable=SC2086
  ${SUDO} ufw status || true
else
  warn "ufw not found. Make sure only SSH and ${WEBUI_PORT:-3000} are reachable."
fi

exec "$SCRIPT_DIR/setup.sh" --mode lite "$@"
