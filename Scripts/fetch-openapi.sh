#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENAPI_URL="${OPENAPI_URL:-http://localhost:3000/docs/json}"
OPENAPI_FILE="${OPENAPI_FILE:-}"
TARGET_FILE="$ROOT_DIR/Sources/WorthItAPI/openapi.json"
TMP_FILE="$TARGET_FILE.tmp"

if [[ -n "$OPENAPI_FILE" ]]; then
  cp "$OPENAPI_FILE" "$TMP_FILE"
else
  curl -fsS "$OPENAPI_URL" -o "$TMP_FILE"
fi
python3 -m json.tool "$TMP_FILE" > "$TARGET_FILE"
rm -f "$TMP_FILE"

echo "Updated OpenAPI contract from ${OPENAPI_FILE:-$OPENAPI_URL}"
