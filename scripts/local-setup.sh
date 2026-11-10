#!/usr/bin/env bash
# Local high-end PC / workstation profile.
#
#   ./scripts/local-setup.sh                 # lite model, local tuning
#   ./scripts/local-setup.sh --gpu           # + NVIDIA GPU reservation
#   ./scripts/local-setup.sh --mode flagship # real DeepSeek-V4.1-Flash (288 GB+)
#
# The flagship model is ~259 GB. On a normal desktop this script will refuse
# and suggest --mode lite or --mode api.
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/setup.sh" --mode lite --local "$@"
