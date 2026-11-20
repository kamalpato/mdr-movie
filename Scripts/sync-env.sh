#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
OUTPUT_FILE="${ROOT_DIR}/MandiriMovies/Generated/AppSecrets.swift"

mkdir -p "$(dirname "$OUTPUT_FILE")"

API_KEY=""
if [[ -f "$ENV_FILE" ]]; then
  API_KEY="$(grep -E '^API_KEY=' "$ENV_FILE" | tail -n 1 | cut -d '=' -f2- | tr -d '\r' || true)"
fi

cat > "$OUTPUT_FILE" <<EOF
enum AppSecrets {
    static let tmdbAPIKey = "${API_KEY}"
}
EOF
