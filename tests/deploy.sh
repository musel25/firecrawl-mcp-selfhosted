#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
config="$(FIRECRAWL_DEPLOY_ROOT="$root" docker compose -f "$root/tests/fixtures/base-compose.yaml" -f "$root/deploy/compose.override.yaml" config --format json)"
node -e '
const assert = require("node:assert/strict");
const fs = require("node:fs");
const data = JSON.parse(fs.readFileSync(0, "utf8"));
assert.equal(data.services.api.ports.length, 1);
assert.equal(data.services.api.ports[0].host_ip, "127.0.0.1");
assert.equal(data.services.api.environment.SEARXNG_ENDPOINT, "http://searxng:8080");
assert.ok(data.services.searxng);
assert.equal(data.services.searxng.ports, undefined);
for (const name of ["api", "redis", "rabbitmq", "nuq-postgres", "playwright-service", "searxng"]) {
  assert.equal(data.services[name].restart, "unless-stopped", name);
}
assert.equal(data.services.foundationdb, undefined);
assert.equal(data.services["foundationdb-init"], undefined);
assert.ok(data.services.redis.volumes.some(v => v.target === "/data"));
assert.ok(data.services.rabbitmq.volumes.some(v => v.target === "/var/lib/rabbitmq"));
assert.ok(data.services["nuq-postgres"].volumes.some(v => v.target === "/var/lib/postgresql/data"));
' <<< "$config"
profiled="$(FIRECRAWL_DEPLOY_ROOT="$root" docker compose --profile fdb -f "$root/tests/fixtures/base-compose.yaml" -f "$root/deploy/compose.override.yaml" config --format json)"
node -e '
const assert = require("node:assert/strict");
const fs = require("node:fs");
const data = JSON.parse(fs.readFileSync(0, "utf8"));
assert.deepEqual(data.services.foundationdb.profiles, ["fdb"]);
assert.deepEqual(data.services["foundationdb-init"].profiles, ["fdb"]);
' <<< "$profiled"
grep -q -- "- json" "$root/deploy/searxng-settings.yml"
bash -n "$root/scripts/deploy.sh"
