#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/fake-mcp" <<'BIN'
#!/usr/bin/env bash
printf '%s\n' "$FIRECRAWL_API_URL"
BIN
chmod +x "$tmp/fake-mcp"
actual="$(FIRECRAWL_MCP_BIN="$tmp/fake-mcp" "$root/scripts/mcp-stdio.sh")"
[[ "$actual" == 'http://127.0.0.1:3002' ]]
actual="$(FIRECRAWL_MCP_BIN="$tmp/fake-mcp" FIRECRAWL_API_URL='http://127.0.0.1:39002' "$root/scripts/mcp-stdio.sh")"
[[ "$actual" == 'http://127.0.0.1:39002' ]]
node -e '
const assert = require("node:assert/strict");
const p = require(process.argv[1]);
const l = require(process.argv[2]);
assert.equal(p.dependencies["firecrawl-mcp"], "3.40.0");
assert.equal(l.packages["node_modules/firecrawl-mcp"].version, "3.40.0");
' "$root/package.json" "$root/package-lock.json"
