# Self-hosted Firecrawl MCP

This public project deploys Firecrawl on a private VPS. It connects local Codex and Claude Code to core web search and scraping tools through MCP. The connection uses SSH. It does not store job-search data or Firecrawl credentials in Git.

The first target is the existing ARM64 `my-vps` SSH host. Firecrawl runs at a private loopback address. Codex and Claude Code start the official MCP package on demand through SSH. The setup avoids Firecrawl Cloud credits for supported core tools. It still uses VPS resources and can need external search or proxy services for some sites.

- [Design](docs/superpowers/specs/2026-11-18-private-firecrawl-mcp-design.md)
- [Deployment and client setup](docs/DEPLOYMENT.md)
- [Verification record](docs/VERIFICATION.md)

Run `npm test` to check the deployment configuration and MCP bridge.
