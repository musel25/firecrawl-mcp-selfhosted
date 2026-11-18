#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
upstream="$root/.upstream/firecrawl"
release="v2.11.162"
mode="${1:-deploy}"

if [[ "$mode" != prepare && "$mode" != check && "$mode" != deploy ]]; then
  printf 'Usage: %s [prepare|check|deploy]\n' "$0" >&2
  exit 2
fi

if [[ "$mode" != check ]]; then
  if [[ ! -d "$upstream/.git" ]]; then
    mkdir -p "$(dirname "$upstream")"
    git clone --depth 1 --branch "$release" https://github.com/firecrawl/firecrawl.git "$upstream"
  fi
  actual="$(git -C "$upstream" describe --tags --exact-match 2>/dev/null || true)"
  if [[ "$actual" != "$release" ]] || [[ -n "$(git -C "$upstream" status --porcelain)" ]]; then
    printf 'Upstream checkout must be clean at %s\n' "$release" >&2
    exit 1
  fi
  if [[ ! -f "$root/.env" ]]; then
    umask 077
    secret="$(openssl rand -hex 32)"
    cat > "$root/.env" <<ENV
USE_DB_AUTHENTICATION=false
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$secret
POSTGRES_DB=postgres
ENV
  fi
  npm ci --prefix "$root" --omit=dev
fi

if [[ ! -f "$root/.env" ]] || [[ ! -f "$upstream/docker-compose.yaml" ]]; then
  printf 'Run prepare before check\n' >&2
  exit 1
fi

compose=(docker compose --project-directory "$upstream" --env-file "$root/.env" -f "$upstream/docker-compose.yaml" -f "$root/deploy/compose.override.yaml")
"${compose[@]}" config --quiet

if [[ "$mode" == deploy ]]; then
  "${compose[@]}" up --build -d
  "${compose[@]}" ps --all
fi
