# Sendqon B0 + B1 Build Report — Tyariyan + MCP Plugin

**Date:** 2026-11-17 (evening, PKT) · **Plan:** `SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md` (B0 + §4 MCP build card)
**Outcome:** B0 complete. MCP plugin built, dev battery **all 9 points green**, installed on production, live-safe subset green. **No core files touched. No plan flags flipped.**

---

## 1. B0 — Tyariyan (complete)

| Item | Result |
|---|---|
| B0.1 Patch register | `files/PATCH-REGISTER.md` — PR-001 (entrypoint `TRUSTED_PROXIES=*`), PR-002 (entrypoint storage:link recreation + .env materialisation), PR-003 (PKR currency, 3-line diff) consolidated with register rules. |
| B0.2 Plugin skeleton | `files/plugin-skeleton/` — plugin.json template, main-class + provider stubs, routes stub, migration stub, `scripts/package-plugin.sh` (validates manifest fields + `App\Plugins\` namespace + main-class existence + ≤20 MB, then zips). All PHP stubs lint clean. The MCP plugin itself was packaged with this script. |
| B0.3 Containerised dev copy | `~/sendqon-dev/` on offbox-1: own compose project (`sendqon-dev` app on 127.0.0.1:18081, `sendqon-dev-db` MySQL with a **fresh dev-only DB + fresh dev APP_KEY** — the live APP_KEY was NOT copied), queue worker, own volumes. Installed via the app's own `InstallerService::createAdmin` (518 migrations, 300 tables, 4 plans seeded, 1 dev admin). Boot proven: `/login` 200, SPA login → `/overview`, `/admin/plugins` 200, `/admin/settings` 200. |
| B0.4 Type-wise harness | Exercised for the `ai_integration` type end-to-end (install → activate → configure → battery → uninstall → reinstall). Rollback rehearsed in dev (see §3). |

Dev-copy notes for future lanes: the login is an SPA XHR POST (CSRF token from the `csrf-token` meta tag); files created by root-run CLI scripts inside the container must be chowned to `www-data` afterwards (storage, bootstrap/cache) or the web process 500s on log/key access.

---

## 2. The resolved plugin-type convention (build card correction)

The build card assumed the MCP plugin would be type **`tool`**. Live code says otherwise:

- The MCP surface is type **`ai_integration`** → directory **`app/Plugins/AiIntegrations/Mcp/`**, slug **`mcp`**.
- Proof: `App\Services\Mcp\McpAccess::installed()` checks `is_file(PluginManager::path('AiIntegrations/Mcp/plugin.json'))`; `PluginManager::TYPE_DIRECTORIES` maps `ai_integration => AiIntegrations`; the manifest must carry `runtime_contract: 1` and its main class must extend `App\Contracts\AiRuntimePlugin` (adds `provider(): string`).
- Core hard-references three classes in namespace `App\Plugins\AiIntegrations\Mcp\`: **`McpServer`** (started by `McpController`), **`ToolRegistry`** (tool definitions, `READ`/`WRITE`/`SEND` consts, `CAMPAIGN_SEND_INPUTS`, `abilities()`), **`ToolCatalog`** (per-tool `label`). The plugin supplies exactly these plus the main class, a minimal provider, and a generic tool class.
- (For reference, the `tool`-type convention from the Legacy Importer: dir `app/Plugins/Tools/LegacyImporter/`, slug `legacy_importer`, main class implements `ToolRuntimePlugin` — as the card expected for a tool, just not for MCP.)

Core already implements everything else: routes, OAuth (Passport + DCR + consent), `McpBoundary`, `McpSendLimit` (20/hour, receipts only on 2xx sends), `ApiDispatcher` (in-kernel dispatch, draft-only campaign enforcement), readiness, grants/revoke, API-key MCP presets. **Expected core touch: NONE — actual core touch: NONE.** No new patch-register entries; no proposed entries either.

### What the plugin adds (source: Sendqon repo branch `plugin-mcp`)

- `McpPlugin` — manifest main class; install-level config core reads from the plugin row: `enabled` (master toggle, **default OFF**), `allowed_origins` (McpAccess), `allowed_redirect_uris` (McpRedirects — extra OAuth redirect URIs beyond the always-allowed loopback + built-in Claude/ChatGPT callbacks). `isConfigured()` returns true by design: the vendor workflow is install → activate → Configure, and `McpAccess` keeps the endpoint dark until `enabled` is on.
- `ToolRegistry` — **29 tools** mapped 1:1 onto existing `/api/v1` endpoints with argument maps, JSON input schemas and required Sanctum abilities: 18 READ, 6 WRITE, 5 SEND. `CAMPAIGN_SEND_INPUTS` lists the 12 scheduling/launch fields core strips so MCP campaigns are always drafts.
- `McpServer` — lists tools per connection: READ always; WRITE only for write-capable connections; SEND only when the connection's send gate is open (OAuth grant `allow_sending` + write access, or API key `mcp_allow_sending`); plus **channel-awareness** via core's `ChannelPlugins::liveTool()` — a tool whose owning channel plugin is inactive is not listed.
- `Tools\ApiTool` — dispatches through core's `ApiDispatcher`, so plan gating, tenant scoping, abilities, idempotency, the send cap and audit logging apply exactly as for direct API calls.
- ZIP: 11,958 bytes (limit 20 MB), packaged with the B0 skeleton script.

---

## 3. Dev battery — plan §4.6, all 9 points

Environment: dev copy above; dev-only scaffolding (dev admin put on the Enterprise plan with `mcp=true` in the **dev DB only**; a Custom HTTP SMS provider pointing at a public test endpoint + a default SenderId so sends can succeed without any real channel; a dummy device row as campaign source; a restricted workspace member without `contacts.view`).

1. **Readiness** — install-level checks green in dev: `plugin_active` ✓, `mcp_enabled` ✓, `oauth_keys` ✓. The five public/https checks (https, public_host, public_ipv4, protected_resource, authorization_server) are bound to the real public domain and can only pass on production — see §4, where all 8 are green.
2. **Connect + read-only** — full OAuth flow exercised like a real client: discovery 200 → DCR registration 201 → consent page (consent token + workspace pick) → approve → authorization code → PKCE token exchange 200 → MCP initialize 200. Read-scope grant lists exactly the 18 read tools — **no write tools, no send tools** — and `get-account` succeeds. API-key Read Only preset: same listing.
3. **Send gate** — Read+Write key: send tools not listed; a direct `send-sms` call is refused by the boundary (**403 `insufficient_scope`**). Send-enabled key: send tools listed; a real send returns **202 queued** (message row created via the provider route).
4. **20/hour cap** — 20 sends pass; the **21st is refused** (`mcp_send_limit`); `mcp_send_receipts` holds **exactly 20** rows for the connection (core writes receipts only for successful sends — failed sends do not consume the cap).
5. **Draft-only campaigns** — `create-campaign` called **with** `launch_now=true`, `schedule_at=2030-01-01`, `send_window_enabled=true` → created campaign is **`status: draft`, `scheduled_at: null`, `sent_count: 0`**. Scheduling inputs are stripped by core's dispatcher; the tool can never launch.
6. **Workspace permissions** — the restricted member's read key (token carries `contacts.view`) calling `list-contacts` is refused: **403 `missing_ability` (contacts.view)** — effective abilities are the intersection of token and workspace role.
7. **Revoke** — both forms proven: deleting the API key → next call **401**; revoking the OAuth grant via the app's own `McpGrants::revoke()` (the MCP Connections admin action) → next call **401**.
8. **Channel-awareness** — Android Gateway plugin deactivated → `list-devices`, `get-device`, `list-network-lines`, `get-network-quote` vanish from tools/list (18 → 14); reactivated → all return.
9. **Production** — see §4. Rollback rehearsed in dev first: deactivate → uninstall → plugin row + directory gone, `/mcp` back to **404** → reinstall from the same ZIP → active, `/mcp` 200.

Also verified en route: the plugin installs/activates/configures purely through `PluginManager::installFromZip()` + `activate()` + `configure()` (the admin UI's own path); pre-config state has `installEnabled = false` (endpoint dark until an admin enables it).

---

## 4. Production install (2026-11-17 ~19:31–19:40 PKT)

- **Backup first:** nightly script run on demand — `2026-11-17T19:31:35Z status=OK` (DB 8.5 MB, config 30 MB, storage 51.7 MB) in `/var/backups/sendqon/`, replica pushed to micro-2 (`push=OK`). Targeted snapshot: `~/sendqon-backups/pre-mcp-install-20261117/plugins-settings-plans.sql`.
- **Install:** same ZIP via PluginManager in the `sendqon` container → row `mcp`, **active**, v1.0.0, config `{enabled: true, allowed_origins: "", allowed_redirect_uris: ""}`. `McpAccess::installEnabled()` = yes. (Side effect, expected vendor behaviour: the queue worker restarted gracefully during activate/configure — back Up immediately; all 7 containers Up.)
- **Durability:** plugin source baked into the host build tree at `~/sendqon-build/src/app/Plugins/AiIntegrations/Mcp/` (8 files), so a future image rebuild keeps it.
- **Live-safe subset (all green):**
  - Readiness on production: **all 8 checks true** — plugin_active, mcp_enabled, oauth_keys, https, public_host, public_ipv4, protected_resource, authorization_server.
  - `POST /mcp` as guest: **401** (was 404 before install — endpoint live, auth-gated). Discovery `/.well-known/oauth-authorization-server` → 200 with the correct endpoints; `/.well-known/oauth-protected-resource` → 200. Site root + `/login` → 200.
  - **Plan flags untouched:** `mcp=false` on all 7 plans (Free, Starter, Pro, Enterprise + 3 Managed); `api` flags unchanged.
  - **Send gate OFF, structurally:** 0 MCP OAuth grants, 0 MCP preset tokens, 0 send receipts, users still 1. No connection can exist until the owner flips a plan's `mcp` flag (pricing decision) and a user connects. A full authorised-connection test on production is therefore impossible *by design* until that decision; the identical flow is proven end-to-end in dev (§3).
  - The admin config screen (Admin → Plugins → MCP → Configure) renders from the same PluginManager path exercised in dev; a visual check in the owner's signed-in session remains a nice-to-have, not a blocker.

### Rollback note (production)

If ever needed: Admin → Plugins → MCP → Deactivate → Uninstall (or the same via PluginManager in the container). Effect, rehearsed in dev: plugin row + `app/Plugins/AiIntegrations/Mcp/` removed, `/mcp` and the OAuth endpoints return 404, all other surfaces untouched (core MCP code simply goes dark without the plugin). Pre-install state is restorable from `/var/backups/sendqon/` (2026-11-17 19:31Z set) or the targeted snapshot above. The build-tree copy stays in `~/sendqon-build/src/` — remove that directory too if a rebuild must not resurrect the plugin files (files alone, without the DB row, are inert: `McpAccess::installed()` would see the manifest, so remove both together).

---

## 5. What remains (unchanged owner decisions)

- **Tenant access:** flipping `mcp` on any plan = owner's pricing decision (§4.5 of the plan). Until then the plugin is live but unreachable for tenants — the intended safe state.
- Everything else on the plan's owner-only list (§5) is untouched by this lane.
- Next build phase per plan: **B2 — Payments + USP-1** (needs owner's merchant/bank steps for live activation; plugins can still be built ahead).
