# Verification record — 2026-11-18

## Versions and host

- VPS: `my-vps`, ARM64, 23 GiB memory.
- Firecrawl source: tag `v2.11.162`, commit `7666c1f9ae8720a6bba271e0f60b6a217f8a5210`.
- MCP package: `firecrawl-mcp` `3.24.0`, installed from `package-lock.json` with exact transitive overrides.
- SearXNG: `2026.11.11-248b8ffc0`, pinned image digest `sha256:71a410e383ea1c1f973a0c38e566757c1f0c5f3976a33be2c70918fcd93bdcc7`.

## Checks

| Check | Observed result |
|---|---|
| `npm test` | Passed the Compose configuration and MCP bridge tests. |
| `npm audit --omit=dev` | Zero reported vulnerabilities after the exact dependency overrides. |
| VPS API readiness | `{"status":"ok"}` after startup. |
| VPS scrape of `https://example.com` | `success: true`, HTTP 200, 958 Markdown characters. |
| VPS search for `software engineer new graduate jobs` | `success: true`, three web results through SearXNG. |
| Employer page scrape | Four returned Ashby pages had HTTP 200 and 4,150–8,893 Markdown characters. One separate Ashby result was stale and returned HTTP 404. |
| MCP tool discovery over SSH | `firecrawl_search` and `firecrawl_scrape` were listed. |
| MCP search and scrape over SSH | Both returned `isError: false` after the restart policy update. |
| Codex connection | `codex mcp get firecrawl-self-hosted` showed an enabled stdio SSH server. A new `codex exec` session called `firecrawl_search` on that server and returned a result URL. |
| Claude Code connection | `claude mcp get firecrawl-self-hosted` reported `Connected` at user scope. A new `claude -p` session called `firecrawl_search` on that server and returned a result URL. |
| VPS port | `ss -tln` showed `127.0.0.1:3002`; SearXNG had no host port. |
| Docker restart policy | All six running Firecrawl services reported `unless-stopped`. |

## Limits

The MCP package lists tools that need Firecrawl Cloud services. Only core search and scrape were checked through MCP. Core crawl and map still need separate live checks before use. Search results are leads, not proof that a role is live or eligible. The VPS volumes are persistent, but no backup schedule exists for them. Existing Codex and Claude Code sessions may need a restart to load the saved MCP connection. Claude.ai web has no connection to this private SSH server.
