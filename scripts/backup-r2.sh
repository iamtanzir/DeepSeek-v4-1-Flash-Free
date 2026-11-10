#!/usr/bin/env bash
# Consistent backup of models + Open WebUI data to Cloudflare R2 (rclone).
#
#   ./scripts/backup-r2.sh
#   ./scripts/backup-r2.sh --dry-run
#
# R2's free tier is 10 GB. That is fine for the lite/coder models and WebUI
# data, but NOT for the ~259-414 GB flagship model. Use an external disk/NAS
# for the flagship.
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
fi

COMPOSE=()
load_env
MODELS_DIR="$(models_dir)"
R2_REMOTE="${R2_REMOTE:-r2}"
BUCKET="${R2_BUCKET:-deepseek-backup}"

have rclone || die "rclone is not installed. https://rclone.org/install/"

if ! rclone listremotes 2>/dev/null | grep -Fxq "${R2_REMOTE}:"; then
  cat <<EOF
fail  rclone remote "${R2_REMOTE}:" is not configured.

Create it once (Cloudflare dashboard → R2 → Manage API tokens):

  rclone config create ${R2_REMOTE} s3 \\
    provider=Cloudflare \\
    access_key_id=YOUR_ACCESS_KEY \\
    secret_access_key=YOUR_SECRET_KEY \\
    endpoint=https://YOUR_ACCOUNT_ID.r2.cloudflarestorage.com \\
    acl=private

See configs/rclone-r2.conf.example for the full file.
EOF
  exit 1
fi

rclone mkdir "${R2_REMOTE}:${BUCKET}" 2>/dev/null || true

# Warn before filling the free tier.
if [ -d "$MODELS_DIR" ]; then
  MODEL_MB="$(du -sm "$MODELS_DIR" 2>/dev/null | awk '{print $1}')"
  if [ "${MODEL_MB:-0}" -gt 9000 ]; then
    warn "ollama-models is ${MODEL_MB} MB; the R2 free tier is 10 GB."
    warn "This backup will likely fail or cost money. Use an external disk instead."
    if ! confirm "Continue anyway?"; then
      exit 1
    fi
  fi
fi

STARTED=0
cleanup() {
  if [ "$STARTED" = "1" ]; then
    log "Restarting containers…"
    "${COMPOSE[@]}" -f "$ROOT_DIR/docker-compose.yml" start >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if [ "$DRY_RUN" = "0" ]; then
  if have docker && docker info >/dev/null 2>&1; then
    init_docker
    init_compose
    log "Stopping containers for a consistent copy…"
    "${COMPOSE[@]}" -f "$ROOT_DIR/docker-compose.yml" stop >/dev/null 2>&1 || true
    STARTED=1
  else
    warn "Docker is not running; copying files as-is (SQLite may be inconsistent)."
  fi
fi

RCLONE_FLAGS=(--fast-list --transfers 4 --checkers 8 --progress)
if [ "$DRY_RUN" = "1" ]; then
  RCLONE_FLAGS+=(--dry-run)
  log "Dry run: nothing will be written"
fi

log "Backing up to ${R2_REMOTE}:${BUCKET}"

if [ -d "$MODELS_DIR" ]; then
  rclone sync "$MODELS_DIR" "${R2_REMOTE}:${BUCKET}/models-docker" "${RCLONE_FLAGS[@]}"
  ok "Models copied"
else
  warn "Skip: $MODELS_DIR not found"
fi

if [ -d "$ROOT_DIR/open-webui" ]; then
  rclone sync "$ROOT_DIR/open-webui" "${R2_REMOTE}:${BUCKET}/open-webui" \
    --exclude "cache/**" "${RCLONE_FLAGS[@]}"
  ok "Open WebUI data copied"
else
  warn "Skip: ./open-webui not found"
fi

ok "Backup finished"
