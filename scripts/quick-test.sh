#!/usr/bin/env bash
# End-to-end smoke test. Exit code 0 means the stack answered correctly.
set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

load_env
MODEL="${MODEL:-deepseek-r1:8b}"
WEBUI="http://127.0.0.1:${WEBUI_PORT:-3000}"
API_MODE="${ENABLE_OPENAI_API:-false}"
FAIL=0

if [ "$API_MODE" = "true" ] && [ -n "${OPENAI_API_BASE_URL:-}" ]; then
  BASE="${OPENAI_API_BASE_URL%/}"
  TAGS_URL="$BASE/models"
  CHAT_URL="$BASE/chat/completions"
  AUTH=(-H "Authorization: Bearer ${OPENAI_API_KEY:-}")
  echo "Mode  : remote API ($BASE)"
else
  OLLAMA="http://127.0.0.1:${OLLAMA_PORT:-11434}"
  TAGS_URL="$OLLAMA/api/tags"
  CHAT_URL="$OLLAMA/v1/chat/completions"
  AUTH=()
  echo "Mode  : local Ollama ($OLLAMA)"
fi

echo "Model : $MODEL"
echo "WebUI : $WEBUI"
echo

echo "1) Model list"
TAGS="$(curl -sS --max-time 10 ${AUTH[@]+"${AUTH[@]}"} "$TAGS_URL" 2>/dev/null)" || TAGS=""
if [ -z "$TAGS" ]; then
  echo "   FAIL: no response from $TAGS_URL"
  FAIL=1
elif grep -Fq -- "$MODEL" <<<"$TAGS"; then
  echo "   OK: model is listed"
else
  echo "   WARN: API answered but '$MODEL' is not in the list"
  echo "   $(head -c 300 <<<"$TAGS")"
fi
echo

echo "2) Chat completion"
BODY_FILE="$(mktemp)"
CODE="$(curl -sS --max-time 180 -o "$BODY_FILE" -w '%{http_code}' \
  ${AUTH[@]+"${AUTH[@]}"} "$CHAT_URL" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with the single word: ok\"}],\"max_tokens\":16}" 2>/dev/null)" || CODE="000"
if [ "$CODE" = "200" ]; then
  echo "   OK: HTTP 200"
  head -c 400 "$BODY_FILE"
  echo
else
  echo "   FAIL: HTTP $CODE"
  head -c 800 "$BODY_FILE"
  echo
  FAIL=1
fi
rm -f "$BODY_FILE"
echo

echo "3) Open WebUI /health"
CODE="$(curl -sS --max-time 10 -o /dev/null -w '%{http_code}' "$WEBUI/health" 2>/dev/null)" || CODE="000"
if [ "$CODE" = "200" ]; then
  echo "   OK: HTTP 200"
else
  echo "   FAIL: HTTP $CODE"
  FAIL=1
fi

echo
if [ "$FAIL" -eq 0 ]; then
  ok "All checks passed"
else
  warn "One or more checks failed. Run ./scripts/doctor.sh"
fi
exit "$FAIL"
