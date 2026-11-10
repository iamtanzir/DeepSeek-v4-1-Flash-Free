#!/usr/bin/env bash
# Download a model once and keep a portable offline bundle.
#
#   ./scripts/offline-download.sh
#   ./scripts/offline-download.sh deepseek-coder:6.7b-instruct ./offline-models
#
# Restore on another machine:
#   tar -xzf offline-models/ollama-models-MODEL-YYYY-MM-DD.tar.gz
#   docker compose up -d
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

load_env
MODELS_DIR="$(models_dir)"
MODEL="${1:-${MODEL:-deepseek-r1:8b}}"
DEST="${2:-$ROOT_DIR/offline-models}"
mkdir -p "$DEST"

log "Offline bundle: $MODEL -> $DEST"

init_docker
init_compose
COMPOSE_FILES=(-f "$ROOT_DIR/docker-compose.yml")
dc() { "${COMPOSE[@]}" "${COMPOSE_FILES[@]}" "$@"; }

STARTED=0
cleanup() {
  if [ "$STARTED" = "1" ]; then
    log "Restarting containers…"
    dc start >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

dc up -d
wait_for_ollama 90 || die "Ollama did not become healthy."

INSTALLED="$(dc exec -T ollama ollama list 2>/dev/null || true)"
if grep -Fq -- "$MODEL" <<<"$INSTALLED"; then
  ok "Model already present"
else
  log "Pulling $MODEL…"
  dc exec -T ollama ollama pull "$MODEL"
fi

SAFE_NAME="$(printf '%s' "$MODEL" | tr '/:' '__')"
STAMP="$(date +%Y-%m-%d)"
ARCHIVE="$DEST/ollama-models-${SAFE_NAME}-${STAMP}.tar.gz"

log "Stopping containers for a clean copy…"
STARTED=1
dc stop

log "Archiving $MODELS_DIR (this can take a while)…"
tar -C "$(dirname "$MODELS_DIR")" -czf "$ARCHIVE" "$(basename "$MODELS_DIR")"
ok "Archive: $ARCHIVE"

{
  echo "DeepSeek Free offline bundle"
  echo "Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Model:   $MODEL"
  echo
  echo "Restore:"
  echo "  tar -xzf $(basename "$ARCHIVE")   # extracts $(basename "$MODELS_DIR")/"
  echo "  docker compose up -d"
  echo "  docker exec deepseek-ollama ollama list"
} >"$DEST/README.txt"

dc start
STARTED=0
ok "Containers restarted"
du -sh "$DEST" 2>/dev/null || true
echo
echo "Copy the whole '$DEST' folder to a USB drive if you want a physical backup."
echo "For the real DeepSeek-V4.1-Flash the archive is ~259-414 GB; a 10 GB R2 bucket cannot hold it."
