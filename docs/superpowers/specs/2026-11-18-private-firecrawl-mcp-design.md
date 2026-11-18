# Private Firecrawl MCP design

## Intent

Run Firecrawl's open-source core on the existing ARM64 VPS. Give local Codex and Claude Code access to search and scrape tools without Firecrawl Cloud credits. Keep the job-search database and application workflow separate.

## Approach

Use the official Firecrawl `v2.11.162` source and Docker Compose. Keep deployment changes in this public repository. Pin the official `firecrawl-mcp` npm package. Launch MCP over stdio through the existing `my-vps` SSH alias for each local client session. Bind the Firecrawl API to `127.0.0.1` on the VPS. Do not publish MCP or the API on the internet.

This is preferable to a custom scraper because it keeps the Firecrawl API and tool behavior. A public HTTPS MCP endpoint would require a separate authentication and TLS design. The private SSH route works for both local clients with the access already available.

## Parts

- `scripts/deploy.sh` checks out the pinned upstream release, creates a private environment file, builds and starts the stack, and installs the pinned MCP package.
- `deploy/compose.override.yaml` binds the API to VPS loopback, adds an internal SearXNG search service, disables the optional FoundationDB services on ARM64, and adds durable volumes for PostgreSQL, Redis, and RabbitMQ.
- `scripts/mcp-stdio.sh` starts the official MCP package with `FIRECRAWL_API_URL=http://127.0.0.1:3002` on the VPS.
- Local Codex and Claude Code register an SSH stdio command that runs this script. SSH authenticates the user. The API has no public listener.
- Smoke checks cover the API health endpoint, one real scrape, search, MCP tool discovery, and one MCP tool call in each client.

## Limits

Firecrawl self-hosting includes core scrape, crawl, map, and search routes. Agent, browser interaction, some advanced anti-bot features, and specialized extraction are not in the default self-hosted stack. SearXNG search quality depends on the public engines it queries. Results can include closed job links. VPS operation has compute and storage costs. The public repository must contain no credentials, job-search database, or candidate documents.

Claude means the installed Claude Code client. Claude.ai web would need a public HTTPS endpoint or a supported private tunnel and a separate connection flow.

## Acceptance

Both local clients list the new MCP server. Each can invoke a self-hosted core tool. A server-side smoke check proves a real scrape and search. The VPS exposes neither Firecrawl nor MCP to the public network. The repository has a reviewable pull request and deployment notes.
