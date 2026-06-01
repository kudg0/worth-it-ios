#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENAPI_URL="${OPENAPI_URL:-http://localhost:3000/docs/json}"
TARGET_FILE="$ROOT_DIR/Sources/WorthItAPI/openapi.json"
TMP_FILE="$TARGET_FILE.tmp"

curl -fsS "$OPENAPI_URL" -o "$TMP_FILE"
python3 -m json.tool "$TMP_FILE" > "$TARGET_FILE"
rm -f "$TMP_FILE"

echo "Updated OpenAPI contract from $OPENAPI_URL"
