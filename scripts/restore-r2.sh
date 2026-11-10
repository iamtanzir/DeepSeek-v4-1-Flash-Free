#!/usr/bin/env bash
# Restore models + Open WebUI data from Cloudflare R2.
#
#   ./scripts/restore-r2.sh --yes
#
# Uses `rclone copy` (never `sync`), so a wrong/empty remote cannot wipe the
# local folders.
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --yes | -y) ASSUME_YES=1 ;;
    *) die "Unknown option: $arg" ;;
  esac
done

load_env
MODELS_DIR="$(models_dir)"
R2_REMOTE="${R2_REMOTE:-r2}"
BUCKET="${R2_BUCKET:-deepseek-backup}"

have rclone || die "rclone is not installed. https://rclone.org/install/"

if ! rclone listremotes 2>/dev/null | grep -Fxq "${R2_REMOTE}:"; then
  die "rclone remote \"${R2_REMOTE}:\" is not configured. See configs/rclone-r2.conf.example"
fi

mkdir -p "$MODELS_DIR" "$ROOT_DIR/open-webui"

if [ -n "$(ls -A "$MODELS_DIR" 2>/dev/null)" ] || [ -n "$(ls -A "$ROOT_DIR/open-webui" 2>/dev/null)" ]; then
  warn "Local model/WebUI folders are not empty."
  confirm "Overwrite matching files from R2?" || die "Aborted."
fi

if have docker && docker info >/dev/null 2>&1; then
  init_docker
  init_compose
  log "Stopping containers…"
  "${COMPOSE[@]}" -f "$ROOT_DIR/docker-compose.yml" stop >/dev/null 2>&1 || true
fi

log "Restoring from ${R2_REMOTE}:${BUCKET}"

if rclone lsf "${R2_REMOTE}:${BUCKET}/models-docker" --max-depth 1 >/dev/null 2>&1; then
  rclone copy "${R2_REMOTE}:${BUCKET}/models-docker" "$MODELS_DIR" \
    --fast-list --transfers 4 --checkers 8 --progress
  ok "Models restored"
else
  warn "No models-docker backup found; skipping"
fi

if rclone lsf "${R2_REMOTE}:${BUCKET}/open-webui" --max-depth 1 >/dev/null 2>&1; then
  rclone copy "${R2_REMOTE}:${BUCKET}/open-webui" "$ROOT_DIR/open-webui" \
    --fast-list --transfers 4 --checkers 8 --progress
  ok "Open WebUI data restored"
else
  warn "No open-webui backup found; skipping"
fi

ok "Restore finished"
echo "Start the stack with: docker compose up -d"
