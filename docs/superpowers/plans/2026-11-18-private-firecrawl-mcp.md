# Private Firecrawl MCP Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task by task.

**Goal:** Deploy self-hosted Firecrawl on `my-vps` and connect local Codex and Claude Code through private SSH MCP.

**Architecture:** The public repository pins the upstream Firecrawl release and the official npm MCP package. Docker Compose runs the backend on VPS loopback. An SSH stdio command starts MCP on demand for each local client.

**Tech Stack:** Docker Compose, Bash, Node.js 24, npm, SSH, Firecrawl `v2.11.162`, `firecrawl-mcp` `3.24.0`.

**Spec:** `docs/superpowers/specs/2026-11-18-private-firecrawl-mcp-design.md`

## Global constraints

- Keep the backend and MCP off public listeners.
- Do not store credentials or job-search data in Git.
- Use the VPS ARM64 architecture.
- Pin upstream and MCP versions.
- Test a real scrape and search before claiming service readiness.

## Review focus

- Public port exposure: inspect `docker compose config` and `ss -tln`.
- ARM64 image failure: run the actual Compose build and inspect all services.
- Search provider failure: call `/v2/search` and report the exact result.
- MCP package incompatibility: list tools and call a core tool through the MCP protocol.
- Client configuration failure: verify Codex and Claude Code connection status.

## Tasks

### Task 1: Reproducible private backend

**Files:** `scripts/deploy.sh`, `deploy/compose.override.yaml`, `tests/deploy.sh`, `.env.example`.

- [ ] Write a failing test for release pinning and loopback binding.
- [ ] Add the Compose override and deployment script.
- [ ] Run the test and `docker compose config`.
- [ ] Commit and push the backend unit.

### Task 2: MCP bridge

**Files:** `package.json`, `package-lock.json`, `scripts/mcp-stdio.sh`, `tests/mcp-stdio.sh`.

- [ ] Write a failing test for the API URL and stdio bridge.
- [ ] Install the exact official MCP package and add the bridge script.
- [ ] Run the bridge test and package checks.
- [ ] Commit and push the MCP unit.

### Task 3: VPS deployment and client connections

**Files:** `docs/DEPLOYMENT.md`, `docs/VERIFICATION.md`, `README.md`.

- [ ] Deploy to the VPS and check service ports.
- [ ] Verify health, scrape, search, and MCP tool calls.
- [ ] Register the SSH MCP command in Codex and Claude Code.
- [ ] Verify both client configurations.
- [ ] Record exact evidence and limits; commit and push documentation.

### Task 4: Final review

- [ ] Run repository checks and inspect the full diff.
- [ ] Open a pull request with test evidence and deployment limits.
