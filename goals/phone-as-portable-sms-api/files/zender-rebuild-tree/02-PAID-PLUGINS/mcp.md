# PAID PLUGIN SPEC — MCP (Extra) — **Phase 4 priority #1**

- **Vendor price:** $120. **No Extended discount.**
  **Version:** v1.0.0 (6 Nov 2026). Classed as an "Extra", not a Plugin.
- **Portal:** https://products.titansys.dev/zender/mcp/
- **Demo state:** Active/Configured (AI); tenant API Keys page has an
  **MCP Connections** tab with an active "MCP Server" connection
  (Lane 4 §§B, C).
- **Source status:** not stated (UNVERIFIED). We do not buy it — we
  build it first among all plugins (master plan Phase 4 #1).

## Purpose
An MCP (Model Context Protocol) server that lets AI apps — Claude,
ChatGPT, Claude Code, Cursor — use workspace tools and resources:
read conversations/contacts, and (only when explicitly allowed) send.

## Features
Works with Claude, ChatGPT, Claude Code, Cursor and other MCP clients
(Claude/ChatGPT show a Verified app badge when their callbacks match
the known ones). Auth: **OAuth sign-in** (the user picks Read Only or
Read and Write) or **API keys** (a key typed "AI App (MCP)" with a
matching permission level). **Sending is OFF by default** — a separate
"Allow sending messages" switch must also be on, otherwise sending
tools stay hidden and refused. **Per-connection cap: 20 messages per
hour.** Campaign creation always saves a **draft only** — scheduling/
launch inputs are removed, so an AI app can never start a campaign on
its own. Review/revoke: owners/admins review and revoke every OAuth
connection at API Keys > MCP Connections; members manage their own
under Account Settings; unverified apps carry a clear badge.
Channel-aware tools: a channel's tools appear only while its plugin
is live; sends count toward the plan like any message; workspace
permissions and API limits apply to every request.

## Workflow
Upload ZIP → activate → Configure: save "Enable MCP", resolve every
readiness check shown → turn on MCP + API Access for eligible plans →
copy the MCP Server URL from Help > MCP Docs → add it to the AI app →
start Read Only, then review the connection on API Keys.

## Logic / technology
Core already contains the plumbing: `laravel/mcp` package,
`routes/mcp.php`, `app/Services/Mcp/`, tables `mcp_oauth_grants` +
`mcp_send_receipts`, Passport for OAuth, and API-key presets
Read Only / Read+Write / Read Write Send (Lane 5 §§2, 4; Lane 2).
Channel plugins declare their MCP tools in the channel registry
(`mcpTools`) — the server aggregates tools from live channels only.

## Data it touches
`mcp_oauth_grants`, `mcp_send_receipts`, `personal_access_tokens` /
Passport tables; everything else via the tenant API services.

## Dependencies
MCP + API Access enabled on the plan; public HTTPS (AI apps must
reach the server); an MCP client.

## OUR REBUILD SPEC
- **Plugin type:** `tool` (runtime contract) on core's MCP plumbing.
- **Key interfaces:** MCP server endpoint from `routes/mcp.php`;
  OAuth grant flow (Passport) with Read Only / Read+Write scopes;
  API-key auth with the "AI App (MCP)" key type; tool registry fed by
  `ChannelPlugins` `mcpTools`; the send gate (default off) + 20/hour
  per-connection limiter writing `mcp_send_receipts`; campaign tools
  hard-limited to draft creation; connections review/revoke UI.
- **Non-negotiable safety rules (copy the vendor's):** sending off by
  default, draft-only campaigns, per-connection send cap, unverified
  app badging. These are why this plugin is safe to ship first.
- **Priority:** **Phase 4 #1** (master plan: MCP first — it is a thin
  wrapper over the REST surface and unlocks agent-driven operations).
- **Difficulty:** Medium. Plumbing is core's; the work is tool design
  + permission discipline.
