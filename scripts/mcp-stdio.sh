#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export FIRECRAWL_API_URL="http://127.0.0.1:3002"
unset FIRECRAWL_API_KEY FIRECRAWL_OAUTH_TOKEN
binary="${FIRECRAWL_MCP_BIN:-$root/node_modules/.bin/firecrawl-mcp}"
if [[ ! -x "$binary" ]]; then
  printf 'Firecrawl MCP package is missing. Run npm ci.\n' >&2
  exit 1
fi
exec "$binary"
