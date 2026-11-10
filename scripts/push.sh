#!/usr/bin/env bash
# Push this repo to GitHub.
#   ./scripts/push.sh                       # push to the existing origin
#   ./scripts/push.sh https://github.com/you/repo.git
set -euo pipefail

if [ -n "${1:-}" ]; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "$1"
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No origin remote. Usage: $0 <github-url>" >&2
  exit 1
fi

git branch -M main
git push -u origin main
echo "Push done."
