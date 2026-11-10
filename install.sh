#!/usr/bin/env bash
# One-command wrapper: ./install.sh [--mode ...] [--local] [--gpu] [--yes]
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/scripts/setup.sh" "$@"
