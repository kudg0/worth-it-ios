#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENAPI_FILE="${OPENAPI_FILE:-}"
BACKEND_REPOSITORY="${BACKEND_REPOSITORY:-}"
BACKEND_COMMIT="${BACKEND_COMMIT:-}"

if [[ -z "$OPENAPI_FILE" || -z "$BACKEND_REPOSITORY" || -z "$BACKEND_COMMIT" ]]; then
  echo "OPENAPI_FILE, BACKEND_REPOSITORY, and BACKEND_COMMIT are required for provenance-safe sync" >&2
  exit 2
fi

python3 "$ROOT_DIR/Scripts/openapi_sync.py" sync \
  --backend-file "$OPENAPI_FILE" \
  --backend-repository "$BACKEND_REPOSITORY" \
  --backend-commit "$BACKEND_COMMIT"
