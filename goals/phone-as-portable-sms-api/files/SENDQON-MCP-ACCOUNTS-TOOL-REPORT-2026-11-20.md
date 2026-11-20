# Sendqon — MCP WhatsApp-Accounts Tool (list-whatsapp-accounts)

**Date:** 2026-11-20 (evening, PKT) · **Authorisation:** owner "Teeno bana do" (chat, 2026-11-20 23:56 PKT) — item 2 of three approved builds.
**Outcome:** MCP plugin **v1.0.1** live on production. The MCP surface now has **30 tools** (was 29): the new read-only **`list-whatsapp-accounts`** closes the gap the NF-1 lane flagged — Postqon's future one-click (OAuth) connector can now offer a WhatsApp **number picker over the MCP channel**, not only via a pasted REST key. **No core files touched. No plan flags flipped. No config changed.**

---

## 1. What was built

One new READ tool in our own MCP plugin, mirroring the nearest siblings (`list-groups`, `list-tags`, `send-wa-message`) exactly:

| Aspect | Contract |
|---|---|
| Name | `list-whatsapp-accounts` (house kebab-case style) |
| Maps to | `GET /api/v1/whatsapp/accounts` (core endpoint, proven by NF-1) |
| Ability | `wa.accounts.view` — added to the read-tier ability set by the registry's own `abilities()` |
| Inputs | No required inputs. Optional `limit` (integer) + `cursor` (string) — the registry's shared `$page` args, because the endpoint is cursor-paginated (limit 1–100, default 25). **No status filter**: the endpoint accepts none, so the tool invents none. |
| Tenant scoping | From the authenticated context only — the controller scopes `where('user_id', tenant)`; there is no tenant/account input to abuse. |
| Output | The endpoint's own body via the standard ApiTool envelope: rows carry the picker fields `id, user_id, wa_server_id, jid, phone, display_name, label, status` (+ `is_enabled`, timestamps), cursor `links`/`meta` alongside. |
| Channel-awareness | No `owners` pin (same as `send-wa-message`): no channel plugin claims this tool, so `ChannelPlugins::liveTool()` lists it whenever MCP itself is live. |
| Catalog | Label "List WhatsApp accounts" + a picker-oriented description in `ToolCatalog` (30/30 tools labelled). |

Files changed (4): `src/ToolRegistry.php` (READ const + definition), `src/ToolCatalog.php` (label/description), `src/McpServer.php` (server version 1.0.1), `plugin.json` (version 1.0.1). Source: Sendqon repo branch **`plugin-mcp` → `bf46551`** (ls-remote verified). Install ZIP: `mcp-1.0.1.zip`, 12,041 B, md5 `7dd2817b1a5cb513e1507a0b1d1d565f`. Local pre-flight: PHP lint clean; standalone registry harness — 30 definitions (19 READ / 6 WRITE / 5 SEND), every tier name has a definition, read-tier abilities now include `wa.accounts.view`.

**UI surfaces:** the MCP plugin has no admin/tenant pages of its own (its only panel surface is the plugin Configure screen, whose config this lane preserved byte-for-byte — §3), so there is no plugin UI to check; the surface that changed is the MCP protocol surface, battery-covered below.

## 2. DEV battery (dev copy, 127.0.0.1:18081, DB zender_dev)

Update installed first via `PluginManager::installFromZip` (update-in-place): v1.0.0 → v1.0.1, config preserved verbatim incl. the Postqon `allowed_redirect_uris`. Fixtures: tenant 38 owns the only DEV WhatsApp account (id 1, `pending_pair`); tenant 32 and the dev-admin workspace own none. Five battery contexts were minted as product API keys (`mcp_preset=1`): tenant-38 read-tier, tenant-38 restricted (`account.view` only), tenant-32 read-tier, admin read-tier, admin full (`*` + sending allowed). The Pro plan's `mcp` feature was snapshotted, toggled for the phases, and **restored from snapshot and re-verified** afterwards.

**Phase A — flag ON (15 checks, all pass in substance):**
- Full admin connection: `tools/list` (paginated) = **30 tools**, new tool present; tenant read connection lists it among its 19 read tools.
- Tenant 38 call → envelope 200, **exactly 1 row — its own** (id 1, user_id 38) with all picker fields.
- Tenant 32 call → `data: []`; admin-workspace call → `data: []` (REST-identical empty state).
- Ability denied: token without `wa.accounts.view` → envelope 403, `missing_ability`. A dedicated probe compared the refusal bodies for the new tool vs sibling `list-groups`: **structurally identical** (`code` + `message` + `details.ability`), each naming its own ability (`wa.accounts.view` / `groups.view`). (One battery sub-assertion first guessed the key `detail` instead of `details`; the probe settled it — the tool was never at fault.)
- REST unchanged: same PAT → `GET /api/v1/whatsapp/accounts` 200 with the same row; unauthenticated → 401.
- `limit=1` argument plumbs through.

**Phase B — Pro `mcp` flag OFF (4 checks, all pass in substance):**
- Tenant 38 calls to the new tool **and** to sibling `get-account` are refused **identically**: envelope 404 `{"error":{"code":"not_found"}}` — the surface's standard flag-off refusal, byte-for-byte the same for both. (The parity assertion as first written looked for the code under the wrong envelope key; the printed bodies show the parity directly.)
- Admin context (Enterprise, `mcp=true` + admin bypass) still calls the new tool successfully.
- Plans restored from snapshot; re-read matches the originals (Free/ Starter/Pro `mcp=false`, Enterprise `mcp=true` — DEV-only values).

**Hygiene:** www-data probe — registry loads as www-data with 30 definitions and the new tool present. DEV log for the battery window: zero new ERROR lines (the day's 5 errors are other lanes', hours earlier). All five battery tokens deleted afterwards; the token file was removed.

## 3. Production (offbox-1, image sendqon:5.0.4-20261119)

- **Backup first:** on-demand run of the nightly script — `status=OK`, `push=OK` (db 9,009,454 B · config 29,993,530 B · storage 72,856,584 B).
- **Pre-snapshot:** plugin v1.0.0 active; all 7 plans `mcp=false`; users=1; MCP grants=0; admin PATs=0; admin workspace holds exactly 1 WhatsApp account.
- **Update:** same ZIP via `PluginManager::installFromZip` run as root (the stack's zip-update route), config read first and re-applied verbatim. Result: **v1.0.1 active, config preserved exactly** — `enabled: true`, `allowed_origins: ""`, `allowed_redirect_uris: "https://social.rektrs.com/developers/sendqon/callback"` (the NF-1 Postqon registration is untouched). Installed files root:root 0644. Updated source also baked into the host build tree (`~/sendqon-build/src/app/Plugins/AiIntegrations/Mcp/`, root:root 0644) so an image rebuild keeps v1.0.1.
- **www-data verification:** plugin row v1.0.1/active; registry resolves as www-data with 30 definitions; new tool → `/api/v1/whatsapp/accounts` + `wa.accounts.view`; `McpAccess::installed` + `installEnabled` = yes; model-level config read-back confirms enabled + the Postqon redirect URI.
- **Live checks:** site root 200 · OAuth discovery 200 · `POST /mcp` as guest 401.
- **Admin-context proof (owner's own workspace only):** a temporary full-access token was minted for the master admin, used over the real `/mcp` HTTP surface, and deleted in the same script — `initialize` answered server **"Sendqon MCP" version 1.0.1**; `tools/list` = **30 tools** with `list-whatsapp-accounts` present; the call returned envelope 200 with **exactly 1 row: the owner's own WhatsApp account (id 1, status `connected`)** with picker fields present. Token deleted immediately; admin PAT count back to **0**.
- **Post-checks:** all 7 plans still `mcp=false` (tenant access unchanged — the owner's pricing decision still governs); users=1; grants=0; production log shows **zero ERROR lines** in the lane's window (last errors are the known 06:11 UTC `phone_bridge_windows` slot entries from the morning audit).

## 4. What this unlocks / what remains

- Postqon's one-click connector (Postqon-side lane, separate chat) can now build its number picker entirely over the OAuth/MCP channel: connect → `list-whatsapp-accounts` → user picks a number → `send-wa-message` with `wa_account_id`. No pasted key needed for the picker.
- Tenant reachability is unchanged by design: production plans keep `mcp=false` until the owner's pricing decision; the master admin can use all 30 tools today.

**Rollback:** Admin → Plugins → MCP → install the previous `mcp-1.0.0.zip` (or deactivate/uninstall — rehearsed in the B1 lane: `/mcp` goes 404, everything else untouched). The pre-update backup set above restores the exact prior state; the build-tree copy would need its 4 files reverted from branch `plugin-mcp` parent commit `7136027`.
