#!/usr/bin/env bash
# DeepSeek-Coder profile (same free stack).
#   ./scripts/coder-setup.sh
#   ./scripts/coder-setup.sh --model deepseek-coder:33b
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/setup.sh" --mode coder "$@"
