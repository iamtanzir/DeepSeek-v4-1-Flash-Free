#!/usr/bin/env bash
# Push helper for DeepSeek-4.1-Flash-Free
# Usage: ./scripts/push.sh https://github.com/your-username/DeepSeek-4.1-Flash-Free.git
set -e
if [ -z "$1" ]; then echo "Usage: $0 <github-url>"; exit 1; fi
git remote remove origin 2>/dev/null || true
git remote add origin "$1"
git branch -M main
git push -u origin main
echo "Push done!"
