# Deploy and operate

This deployment uses [Firecrawl's self-hosted release `v2.11.162`](https://docs.firecrawl.dev/contributing/self-host) and the official `firecrawl-mcp` npm package. The VPS is ARM64. The MCP Docker image was available only for AMD64 when this project was prepared, so the bridge uses Node.js on the VPS.

## VPS setup

The deploy script requires Git, Docker with Compose, Node.js 22 or later, npm, OpenSSL, and outbound HTTPS access. Run these commands on the VPS:

```sh
git clone https://github.com/musel25/firecrawl-mcp-selfhosted.git
cd firecrawl-mcp-selfhosted
git switch feat/private-vps-mcp
./scripts/deploy.sh prepare
./scripts/deploy.sh deploy
```

The script clones the exact Firecrawl tag into ignored `.upstream/firecrawl/`. It creates an ignored `.env` with random PostgreSQL and SearXNG secrets. It installs the exact MCP package from `package-lock.json`. It does not require a Firecrawl Cloud API key.

The API listens only on `127.0.0.1:3002` on the VPS. SearXNG runs inside the private Docker network and supplies search results. The optional FoundationDB services are disabled. PostgreSQL, Redis, and RabbitMQ use named Docker volumes. All active services restart after a VPS reboot. No automatic backup of these volumes is configured.

## Client setup

Use the existing `my-vps` SSH alias from the local computer. This alias must authenticate without an interactive password prompt. These commands add the same private MCP bridge to both local clients:

```sh
codex mcp add firecrawl-self-hosted -- ssh -T my-vps /home/ubuntu/firecrawl-mcp-selfhosted/scripts/mcp-stdio.sh
claude mcp add --scope user firecrawl-self-hosted -- ssh -T my-vps /home/ubuntu/firecrawl-mcp-selfhosted/scripts/mcp-stdio.sh
```

Use `codex mcp list` and `claude mcp list` to check the saved connections. Restart an open client session so it loads the new tools. The SSH command starts one MCP process on the VPS for each client session. It uses the private local API URL. It does not open a public MCP port.

This setup covers local Codex and Claude Code. Claude.ai web does not use this SSH connection. It would need a separate HTTPS or private-tunnel integration.

## Service checks

Run on the VPS:

```sh
curl --fail --silent --show-error http://127.0.0.1:3002/v0/health/readiness
curl --fail-with-body --silent --show-error --max-time 75 \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com","formats":["markdown"],"timeout":60000}' \
  http://127.0.0.1:3002/v2/scrape
curl --fail-with-body --silent --show-error --max-time 30 \
  -H 'Content-Type: application/json' \
  -d '{"query":"software engineer new graduate jobs","limit":3}' \
  http://127.0.0.1:3002/v2/search
ss -tln | grep ':3002'
```

A health response alone does not prove scrape or search. Check the returned URLs and page content. Search can return few or no results when public search providers block requests. This deployment uses SearXNG. It can return old links. Verify the employer page and its HTTP status before treating a result as a live job. Firecrawl can report `success: true` for a page with HTTP status 404; check `data.metadata.statusCode`.

## Updates and rollback

Keep the public repository and upstream release pinned. Check a new upstream tag and Compose file before changing the pin. Run `npm test` after changing local deployment code. Update the VPS checkout with `git pull --ff-only`, then run `./scripts/deploy.sh deploy`. Back up the named database and queue volumes before an upstream upgrade. To stop the stack, use `docker compose stop` with the Compose files and `.env` named in `scripts/deploy.sh`. Never use `down -v` unless you intend to delete its data.

## Limits

The default self-hosted stack supports the core scrape, crawl, map, and search routes. It does not include Firecrawl Cloud Agent, Browser, Interact, or enhanced anti-bot services. Some employer sites can still block scraping. The official MCP package may list tools that the self-hosted API cannot serve. Use the core tools for this deployment. The pinned MCP package is `3.24.0`. Its transitive packages use exact overrides in `package.json` to address known advisories. Search and scrape passed with these overrides; other MCP tools have not been tested. Self-hosting avoids Firecrawl Cloud credits but still uses VPS compute, disk, bandwidth, and any optional provider costs.
