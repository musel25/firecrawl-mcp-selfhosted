# Self-hosted Firecrawl MCP

This public project deploys Firecrawl on a private VPS and connects Codex and Claude Code to its core web retrieval tools through MCP. It uses SSH for client access. It does not store job-search data or Firecrawl credentials in Git.

The first target is the existing `my-vps` SSH host. The deployed service will support job posting discovery and page retrieval without Firecrawl Cloud credits. Self-hosting still uses VPS resources and may need external search or proxy services for some sites.

See `docs/` for the design, deployment steps, and verification record.
