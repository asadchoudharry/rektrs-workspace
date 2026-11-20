# SENDQON NF-1 REPORT — Postqon One-Click OAuth Connect (Sendqon Side)

**Date:** 2026-11-20 (work window ~21:25–21:35 PKT / 16:25–16:35 UTC)
**Lane:** NF-1 build, Sendqon side only. Postqon / social.rektrs.com was NOT touched.
**Authorisation:** Owner, 2026-11-20 21:21 PKT: *"Baki new features per bhi Kam Ker"* — the build word NF-1's registration required.
**Scope source:** `SENDQON-NEW-FEATURES-LIST.md`, NF-1 section.
**Verdict: COMPLETE.** OAuth client registered on DEV + production, full token flow proven on DEV (34/34 battery checks PASS), media endpoint verified + already documented, accounts endpoint found already present in core and battery-proven. **Zero core code changes, zero plugin changes, zero PR-register entries** — everything below was done with core's existing machinery (plugin config + public DCR + batteries).

---

## 1. What core's OAuth actually is (discovered from live source, not assumed)

Core does **not** expose stock Passport routes. Its OAuth surface is a custom MCP OAuth implementation (routes in `routes/mcp.php`, controller `McpOAuthController`):

- Discovery: `GET /.well-known/oauth-authorization-server`
- Dynamic Client Registration: `POST /oauth/mcp/register` (public, per RFC 7591; redirect URIs must pass the `McpRedirects` allowlist)
- Authorize/consent: `GET|POST /oauth/mcp/authorize` (signed-in session; consent offers only workspaces where OAuth is enabled; the user picks read/write access and may allow sending)
- Token: `POST /oauth/mcp/token` (authorization_code + refresh_token grants; **PKCE S256 is mandatory**)
- Clients are **public clients** (`token_endpoint_auth_method: none`) — **there is no client secret**, by design. Nothing secret exists to store or leak for this client.
- The issued access token is a Passport JWT (scopes `mcp:read` / `mcp:write` / `mcp:grant:{id}`) bound to an `McpOAuthGrant`. Calls enter through `POST /mcp` (JSON-RPC); core's dispatcher runs the real `/api/v1` routes in-kernel under the grant, enforcing the same ability names Postqon asked about — the MCP tools map 1:1 onto them: `get-account` → `GET /api/v1/me` (`account.view`), `send-sms` → `POST /api/v1/messages/sms` (`sms.send`), `send-wa-message` → `POST /api/v1/messages/whatsapp` (`wa.send`). 29 tools total. Send tools additionally require the grant's `allow_sending` consent and are rate-limited (20/hour per connection, `McpSendLimit`).
- Redirect allowlist: an https redirect URI is accepted only if listed in the MCP plugin config key `allowed_redirect_uris` (besides loopback/Claude/ChatGPT callbacks). Registering Postqon = adding its callback URI there + DCR. That is the entire "first-party registration" mechanism core provides.

## 2. The one design truth Postqon's lane must design against

**An OAuth-issued token is NOT a plain REST Bearer token.** The plain `/api/v1` surface is guarded by `auth:sanctum`, which accepts Sanctum personal access tokens only; presenting the OAuth JWT to `GET /api/v1/me` returns **401** (battery check A11 — this is by design in core's source, not a defect). The OAuth token's abilities are exercised through the MCP dispatch channel described above, where the same `/api/v1` controllers, ability checks, workspace RBAC and send limits run. For plain REST, a tenant mints their own Sanctum PAT (API Tokens screen) — that is exactly what Postqon's v1 paste-a-key connector already uses, and the DEV battery re-proved it (A12: PAT → `GET /api/v1/me` 200).

**Consequence for the Postqon-side lane:** the one-click connect should complete the OAuth flow (authorize → code at `https://social.rektrs.com/developers/sendqon/callback` → PKCE token exchange → refresh as needed) and then call Sendqon via `POST /mcp` JSON-RPC tools (`send-sms`, `send-wa-message`, `get-account`, …) with the OAuth JWT as Bearer. No Sendqon change is needed for that design; it is live today.

## 3. DEV battery — full flow proof (34/34 PASS, 2026-11-20 16:31–16:32 UTC)

Battery driver ran inside the DEV app (in-kernel HTTP against `sendqon-dev`, as www-data). DEV only: a random throwaway login was set for the DEV tenant fixture (user 32) and stored only inside the dev container; plan features were changed under snapshot and restored (check B9 asserts byte-equality of the restored state).

**Phase A — Postqon client + admin flow (tenant 1, DEV):**

| # | Check | Result |
|---|-------|--------|
| A0 | Admin SPA login | PASS (302) |
| A1 | Discovery document | PASS (200) |
| A2 | DCR registration of client "Postqon" with the real Postqon callback URI | PASS (201) — DEV client_id `01a1f9cd-2086-71c2-8070-ed3981e8ed71` |
| A3 | Consent page offers workspace 1 with sending allowed (`canSend=true`) | PASS |
| A4 | Approve (write + allow_sending) issues a code **to the Postqon callback** | PASS — `302 → https://social.rektrs.com/developers/sendqon/callback?code=…` |
| A5 | PKCE S256 token exchange | PASS (200, refresh token issued) |
| A6 | MCP `initialize` with the OAuth token | PASS (200) |
| A7 | `tools/list` under a write+send grant exposes the send tools (29 tools) | PASS |
| A8 | `get-account` (`account.view`) | PASS (API 200) |
| A9 | `send-sms` (`sms.send`) to the owner's SIM2 (+92 332 877 6333) via the DEV provider fixture | PASS (API 202; `channel_messages` for tenant 1 grew 192 → 193) |
| A10 | `send-wa-message` (`wa.send`) to the owner's WhatsApp number (+92 347 4162393) | PASS as scoped: ability honoured, NOT scope-refused; controller answered 422 `no_wa_account` because DEV tenant 1 has no connected WhatsApp account. (A real WA delivery through this same REST path was already proven in the 2026-11-20 live channel battery on production's vendor server.) |
| A11 | OAuth JWT presented directly to `GET /api/v1/me` | PASS — 401, by design (see §2) |
| A12 | Control: Sanctum PAT on `GET /api/v1/me` | PASS (200) |

**Phase B — `mcp` plan-flag gating (DEV plan surgery, snapshot-restored):**

| # | Check | Result |
|---|-------|--------|
| B0–B3 | Pro plan `mcp` set **true** → plain tenant (user 32) completes the whole flow: consent offers workspace 32, code, token, `get-account` | PASS (API 200) |
| B4–B5 | Pro plan `mcp` set **false** → the tenant's existing OAuth token on `/mcp` | PASS — refused, 401 (grant auto-revoked by core's validity check) |
| B6 | Refresh-token exchange after flag off | PASS — 400 `invalid_grant` |
| B7 | Fresh consent attempt while flag off | PASS — no workspace offered |
| B8 | Enterprise plan `mcp` set **false** → master-admin flow | PASS — consent still offers workspace 1; token + `get-account` 200 (**admin bypass proven**) |
| B9 | Both plans restored from snapshot (Pro `mcp` unset, Enterprise `mcp` true — the DEV originals) | PASS |

**Phase C — REST battery for the accounts + media endpoints (Sanctum PATs, DEV):**

| # | Check | Result |
|---|-------|--------|
| C1 | `GET /api/v1/whatsapp/accounts` without token | PASS — 401 |
| C2 | Tenant 1 (no WA accounts): empty-state shape | PASS — 200, `data: []` |
| C3 | Tenant 38 lists exactly its own account (id 1, DEV own-bridge server) | PASS |
| C3b | Row shape carries the picker fields | PASS — `id, user_id, wa_server_id, jid, phone, display_name, label, status` (+ `is_enabled`, timestamps) |
| C4 | Tenant isolation: tenant 1 reading tenant 38's account id | PASS — 404 (no leak; `show()` also has an explicit cross-tenant 403 guard) |
| C5 | `POST /api/v1/whatsapp/media` without token | PASS — 401 |
| C6 | Media with a PAT lacking `wa.send` | PASS — 403 |
| C7 | Media upload (1×1 PNG, field `file`) with `wa.send` PAT | PASS — **201 with top-level `media_path`** (+ signed `media_url`, `expires_at`, `mime_type`, `size_bytes`) |
| C8 | Media upload with a disallowed mimetype (text/plain) | PASS — 422 (validation live; limit is `max:51200` KB with a jpeg/png/gif/webp/mp4/mp3/aac/ogg/pdf allowlist) |

Cleanup inside the battery revoked every NF-1 grant and deleted every NF-1 PAT. A duplicate client + grant left by a first aborted battery run were also revoked/deleted afterwards; DEV now holds exactly one Postqon client and zero active NF-1 grants.

**DEV housekeeping note:** the DEV container had lost the MCP plugin's files in a partial recreation (its DB row said active but the routes 404'd; production was verified unaffected — its plugin files and discovery are intact). The plugin was restored on DEV from the lane's own B1 install zip (`mcp-1.0.0.zip`, md5-verified inside the container, standard reinstall route) before the battery. No production impact.

## 4. Gating — the policy, stated plainly (coordinator decision, implemented as-is)

- **OAuth-issued tokens follow the existing `mcp` plan flag.** A tenant can connect Postqon (and any OAuth client) only while their plan has `mcp` on; turning it off revokes access immediately (existing tokens die, refresh dies, consent stops offering the workspace). The same flag already gates core's MCP surface, so OAuth behaviour and MCP behaviour stay one policy.
- **No new pricing was invented in this lane.** Which plans get `mcp` remains the owner's pending pricing decision. On production today all 7 plans have `mcp=false` (verified, untouched by this lane) — so on production, tenant OAuth connects stay off until the owner turns the flag on for a plan; the registration below is inert groundwork.
- **Master admin is bila qayd:** core bypasses plan feature checks for the admin's own workspace (`PlanFeatures` admin rule), and the battery proved the full OAuth flow works for the admin even with the plan flag off (B8). The admin's production workspace can therefore use the connect the moment Postqon ships its side, regardless of the pricing decision.

## 5. Media endpoint docs — state

**No documentation change was needed.** `POST /api/v1/whatsapp/media` is already documented in core's published OpenAPI contract (`resources/contracts/public-v1.yaml`, ~line 6789): multipart field `file`, "up to 50 MB", 201 response requiring `media_url, media_path, expires_at, mime_type, size_bytes`, `x-ability: wa.send`, `x-feature: api + whatsapp`. The same contract documents `GET /api/v1/whatsapp/accounts` (~line 6239). Core serves this contract to customers through the in-dashboard API docs (`/api-docs`, with an OpenAPI download) and the public docs page (`https://sendqon.rektrs.com/api`, verified 200). The DEV battery (C5–C8) proves the live behaviour matches the pinned contract exactly (field name, ≤51200 KB, top-level `media_path`). Production spot-check: the production container's contract contains both endpoints and both routes answer 401 unauthenticated.

## 6. Accounts endpoint — state

**Already in core; nothing to build, no patch prepared, PR-register untouched.** `GET /api/v1/whatsapp/accounts` → `Api\V1\Wa\AccountController::index`, ability `wa.accounts.view`, tenant-scoped, cursor-paginated (`limit` 1–100, default 25), picker-ready fields (§3 C3b). `GET /api/v1/whatsapp/accounts/{id}` exists with a cross-tenant guard. Proven on DEV (C1–C4) and present on production (401 unauth; route + contract verified). Postqon's number picker can be built against it today — via a tenant PAT for plain REST, noting the accounts list is not one of the MCP tools (the 29-tool MCP surface has no accounts-list tool; if Postqon later wants the picker over the OAuth channel specifically, that is a small future addition, not part of NF-1's pinned scope).

## 7. Production registration (2026-11-20, after fresh backup)

1. **Fresh verified backup first:** 2026-11-20T16:33:34Z `status=OK`, push=OK (db 8,897,742 B, gzip-verified; config 30,003,572 B; storage 50,328,173 B).
2. **Config change (only change):** MCP plugin config `allowed_redirect_uris`: `""` → `https://social.rektrs.com/developers/sendqon/callback`. Other keys preserved (`enabled: true`, `allowed_origins: ""`). Read back + fresh-process www-data probe: `McpRedirects::allowed(<postqon callback>)` = ALLOWED.
3. **Client registered via production DCR** (`POST https://sendqon.rektrs.com/oauth/mcp/register`, 201):
   - **Production client_id: `01a1f9ce-b248-73df-bf07-ea7b9651596e`**
   - client_name "Postqon", redirect_uris exactly the pinned callback, grants authorization_code + refresh_token, `token_endpoint_auth_method: none` (**public PKCE client — no client secret exists**; the client_id is a public identifier and is recorded here by design).
4. **Post-checks (all read-only):** discovery 200 · site root 200 · `GET /api/v1/whatsapp/accounts` unauth 401 · `POST /api/v1/whatsapp/media` unauth 401 · client row read back (correct URI, not revoked) · **grants on production: 0** · users still 1 · all 7 plan `mcp` flags still false (untouched).
5. **No consent flow was run on production** — the first production grant will be created when Postqon's side ships the connect button and a user (the owner, for his workspace) signs in and consents in their own browser. That is an owner/user step by design.

## 8. Rollback

- Remove the redirect URI: Admin → Plugins → MCP → Configure, clear `allowed_redirect_uris` (or set the plugin config back to `{"enabled":true,"allowed_origins":"","allowed_redirect_uris":""}`) — new DCR registrations and new consents for the Postqon callback stop immediately.
- Revoke the client: delete the `oauth_clients` row `01a1f9ce-b248-73df-bf07-ea7b9651596e` and revoke any `mcp_oauth_grants` rows for it (Admin → connected apps / grants screen, or `McpGrants::revoke`). Existing tokens die with the grant.
- Nothing else changed on production: no code, no plans, no users, no other config.

## 9. What remains (not this lane)

1. **Postqon-side implementation** (separate lane, Postqon chat): connect button → authorize URL (client_id above, PKCE S256, scope `mcp:write`) → callback handler at the pinned URI → token exchange/refresh → calls via the MCP channel (§2). Production client_id is ready for them.
2. **Owner pricing decision:** which plans get the `mcp` flag (tenant OAuth connects stay off on production until then; admin unaffected).
3. Optional future nicety: an MCP accounts-list tool if Postqon wants the number picker over OAuth instead of a PAT (§6).
