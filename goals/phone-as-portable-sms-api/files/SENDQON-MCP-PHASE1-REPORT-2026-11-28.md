# SENDQON MCP PHASE 1 REPORT — Conformance Shim (PRM · 401 Pointer · Resource Binding · CIMD · Cursor)

**Date:** 2026-11-28 (work window ~22:05–22:35 PKT / 17:05–17:35 UTC)
**Lane:** Automation + 2-Way MCP programme, Phase 1 build (design of record: `SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md` §1.4 + §5 Phase 1).
**Authorisation:** Owner, 2026-11-28 ~22:00 PKT: *"Build shuru karo — voice call wala hissa bhi sath rakho."* (Voice tools are Phase 5 scope in the design; nothing voice was built in this lane — no blocker, sequencing only.)
**Verdict: COMPLETE.** DEV battery **54/54 PASS**; production deployed behind a fresh verified backup and passed the full read-only acceptance walk. The Postqon connector path is unregressed (client row + its live grant intact, no-resource flow still issues audience-bound tokens).

---

## 1. The headline finding: three of the four "missing" items were already in core

The design study's gap analysis (§1.4) was written from the NF-1-era picture of the surface. Reading the live code (DEV container, md5-identical to production and to the build tree for every file involved) proved the vendor core already ships:

| Design said missing | Live reality (evidence) |
|---|---|
| RFC 9728 Protected Resource Metadata | **Present.** `routes/mcp.php` serves `GET /.well-known/oauth-protected-resource` **and** `/.well-known/oauth-protected-resource/mcp`; `McpOAuthController::resource()` returns `resource = {app.url}/mcp`, `authorization_servers = [issuer]`, scopes, bearer methods. Verified live on production (200, both paths). |
| 401 `WWW-Authenticate` pointer | **Present.** `McpBoundary::challenge()` = `Bearer resource_metadata="{app.url}/.well-known/oauth-protected-resource/mcp", scope="mcp:read mcp:write"`, emitted on unauthenticated 401s and on 403 `insufficient_scope`. Verified live (production 401 carries it). |
| `resource` / audience binding | **Present.** Authorize + token endpoints validate the RFC 8707 `resource` parameter when present (`targetsResource()` → `McpGrants::matchesResource()`, normalised comparison; wrong target → `invalid_target`). Issued JWTs always carry `aud = [client_id, resource]` (`McpAccessToken::permittedFor`), and `McpOAuthGuard` refuses any token whose `aud` lacks the resource or whose `iss` differs. Grants store the resource and `valid()` re-checks it. An omitted `resource` still defaults — exactly the back-compat existing grants (Postqon) need. |
| CIMD | **Genuinely absent** — zero hits in core. This was the real build (below). |
| Cursor callbacks | Loopback (`http://localhost:8787/callback`) already allowed by `RedirectUris::isLoopbackHttp`; the hosted callback was missing from config. Config change (below). |

Per the lane rule — *where the doc proves wrong against the live code, follow the code and record the deviation* — no duplicate PRM/challenge/binding code was written. The shim that Phase 1 actually needed is §2.

## 2. What was built — PR-008 (registered in `PATCH-REGISTER.md`)

Core owns the entire OAuth surface (routes, controller, Passport bindings); the MCP plugin supplies only the tool classes core resolves by name (its own README states this). The conformance ceremony therefore could not live "inside the plugin" as the design assumed — it is a surgical core patch, registered as **PR-008**:

1. **New `app/Services/Mcp/OAuth/McpCimd.php`** — CIMD resolution:
   - `looksLike()`: client_id is an https URL, structurally safe (core's own `RedirectUris::structurallySafe`), host not loopback / private / reserved (IP literals and DNS answers both checked — SSRF guard).
   - `resolve()`: finds the materialised client by the new `mcp_cimd_url` column (re-fetches the document at most once a day to refresh name/redirect URIs/icon; a failed refresh keeps the known client rather than killing it).
   - `fetchDocument()`: https-only GET (redirects restricted to https, max 3; 6 s timeout; 64 KB cap) and DCR-grade validation — the document's `client_id` must equal the URL exactly, every `redirect_uris` entry must pass `McpRedirects::allowed()`, `token_endpoint_auth_method` must be `none`, grant types ⊆ {authorization_code, refresh_token} incl. authorization_code, response types = [code], name/logo rules mirror `register()`.
   - Materialisation uses core's own `ClientRepository::createAuthorizationCodeGrantClient()` — the row is an ordinary public Passport client, so consent, grants, tokens, connected-apps and revocation all work unchanged.
2. **`McpOAuthController` (3 small hunks):** `consent()` and `token()` first call `McpCimd::rewriteClientId()` — a CIMD-shaped id is replaced by the internal client id before any existing logic runs (an unresolvable CIMD id answers `invalid_client`); `discovery()` now advertises `client_id_metadata_document_supported: true`.
3. **Migration** `2027_07_09_000001_add_mcp_cimd_url_to_oauth_clients`: adds nullable `mcp_cimd_url` text column (the Passport `id` column is char(36) — a URL cannot be the key, hence the mapping column). `down()` drops it.

**Plugin config change (not a patch):** MCP plugin `allowed_redirect_uris` gained `https://www.cursor.com/agents/mcp/oauth/callback` on DEV + production; the Postqon URI is preserved byte-for-byte ahead of it, `enabled`/`allowed_origins` untouched.

**Not changed:** the MCP plugin's runtime code (registry/server/catalog identical — 30 tools), plan flags, the `/mcp` dispatch path, McpBoundary, McpGrants, McpAccessToken. Plugin source branch `plugin-mcp` received only a README conformance note (no runtime change, no reinstall needed or performed).

## 3. DEV battery — 54/54 PASS (in-container HTTP, as www-data)

Driver: `phase1-battery.php` inside the DEV container (kept container-side like the mcp101 precedent), fixture admin login set in-process only, all battery clients/grants/PATs revoked and deleted in cleanup (S10). CIMD documents are real, publicly hosted fixtures in the rektrs-workspace repo (`files/cimd-fixtures/`), fetched over real HTTPS by the DEV container — no mocks in the fetch path.

- **S0–S1 Discovery walk (14 checks):** registry = 30 tools in-process as www-data; unauthenticated `POST /mcp` → 401 with the exact `resource_metadata` pointer + scope hint; PRM root + path variants 200 with matching resource/authorization_servers; AS metadata issuer/endpoints consistent with PRM, `code_challenge_methods_supported = [S256]`, CIMD advertised.
- **S2 DCR (3):** loopback redirect 201; **Cursor callback 201**; Postqon callback 201 (regression shape).
- **S3 Session + UI surfaces (5):** login page + admin login; Admin → Plugins page 200 with MCP listed; MCP readiness endpoint 200; MCP configure surface reachable 200.
- **S4 Full OAuth flow, NF-1 regression (10):** consent → approve → code to the client redirect; token exchange **with** `resource` → 200; JWT `aud = [client_id, resource]`, scopes carry `mcp:grant:`; `/mcp` initialize 200; **tools/list = 30** (cursor-paginated); `get-account` envelope 200; `send-sms` honoured, not scope-refused (envelope 422 from the DEV tenant's route fixture — the NF-1 A10 pattern; ability + send gate both passed); refresh with resource 200.
- **S5 Back-compat (3):** authorize + token **without** `resource` (the exact Postqon shape) still complete; the issued JWT is still audience-bound server-side.
- **S6 Refusals (4):** wrong `resource` at authorize → 400 `invalid_target`; wrong `resource` at token → 400 `invalid_target`; garbage bearer → 401 + challenge; token of a revoked grant → 401.
- **S7 CIMD happy path (8):** with **no DCR call at all**, authorize with `client_id` = document URL → consent → code; the client row materialised with the document's name (`Sendqon CIMD Test Client`) and `mcp_cimd_url` set; token exchange presenting the URL as `client_id` → 200, JWT audience-bound; `get-account` 200; refresh presenting the URL → 200; guest authorize → 302 to login (post-login resume path unbroken).
- **S8 CIMD negatives (7):** document whose `client_id` names a different URL → `invalid_client`, nothing materialised; document with a non-allowlisted redirect URI → `invalid_client`, nothing materialised; mismatch at the token endpoint → `invalid_client`; private-IP `client_id` (127.0.0.1) → refused, never materialised.
- **S9 PAT regression (2):** static-header PAT (the Cursor/Grok shape, `mcp_preset` abilities `*`) → tools/list = 30, `get-account` 200.

One battery fix during the run is worth recording: the first pass failed the CIMD section with 500s because `McpCimd` initially referenced `RedirectUris` unqualified (wrong namespace) — caught by the battery, fixed with the proper import, re-run 54/54. The tools/list count check also initially read only the first page (the server paginates at 15) — a battery bug, not a product bug; the final battery paginates like a real client.

## 4. Production deployment + acceptance

1. **Backup first:** `backup.sh` → `status=OK push=OK` (db 11,191,451 B · config 29,546,269 B · storage 103,728,059 B); all three artifacts gzip-verified.
2. **Pre-state snapshot:** Postqon client `01a1f9ce-b248-73df-bf07-ea7b9651596e` present (name Postqon, pinned callback, not revoked); **1 active grant**; 1 client total; plugin config = Postqon URI only.
3. **Apply:** the two PHP files + migration installed into the live container and the build tree (`~/sendqon-build/src`) with root:root 0644; `php -l` clean; md5 identical across DEV container, production container and build tree (McpCimd `d943c196…`, controller `ecbd36bc…`; pre-patch controller `825d3eb8…`). Migration ran on production (34.5 ms). Plugin config updated (Cursor URI appended, everything else preserved).
4. **Acceptance (read-only, external + www-data probes):**
   - PRM root + path variants: 200, resource `https://sendqon.rektrs.com/mcp`, authorization_servers `[https://sendqon.rektrs.com]`.
   - AS metadata: 200, now including `client_id_metadata_document_supported: true`; S256-only unchanged.
   - `POST /mcp` unauthenticated: 401 with the `resource_metadata` challenge.
   - CIMD negative against production: authorize with the mismatched fixture → 400 `invalid_client` (the real fetch + validation path ran on production), and afterwards `clients_total` still 1, `cimd_rows` 0 — nothing persisted.
   - www-data probes: `McpRedirects::allowed()` = YES for both the Cursor and Postqon callbacks; registry = 30 tools; `mcp_cimd_url` column present; `McpCimd::looksLike()` accepts the fixture URL.
   - **Postqon regression state:** client row byte-identical (name/redirects/not revoked), **active grants still 1**, clients total still 1. No consent flow was run on production (same rule as NF-1 — the first production consent is a user step); the flow itself is DEV-proven in both resource and no-resource shapes.
   - Site root 200; `docker logs` for the deploy window: 1,301 lines, zero error/exception/fatal lines.
   - Observation (pre-existing, not this lane): the web container's `storage/logs/laravel-*.log` files have not been written since 2026-11-26 in either the web or queue container — file logging appears quiet platform-wide while the app serves normally; flagged here for a future housekeeping look, not diagnosed in this lane.

## 5. Deviations from the design/brief, stated plainly

1. **Most of the shim already existed** (§1). Phase 1's build reduced to CIMD + Cursor config + the battery that proves the whole ceremony end-to-end. This is the design's own escape clause ("follow the code") applied — and it de-risks Phase 2: the registry discipline the design assumed missing is in fact core-enforced.
2. **The patch is core-side (PR-008), not plugin-side.** Core owns routes/OAuth (the plugin's provider is deliberately empty of routes); there is no plugin-side surface where PRM/CIMD/token behaviour could live. Kept surgical: 1 new file, 3 hunks, 1 migration.
3. **CIMD registration shape:** CIMD has no registration-endpoint call by design (the client_id *is* the document URL; registration = materialisation at first authorize/token). The battery therefore covers "DCR (existing) + a CIMD-shaped registration" as: DCR flows unchanged, and CIMD clients registered-by-resolution at first use — the only shape the CIMD draft defines.
4. **Four-client battery:** no live vendor client apps were driven (no browser/OAuth app seats in this lane). Each named client's documented connection shape was exercised instead: Claude/ChatGPT = PRM-first discovery → DCR → S256 (S1/S2/S4); Cursor = fixed-callback DCR + static-header PAT (S2/S9); Grok API = static-header PAT (S9); CIMD-preferring clients = S7/S8. A literal in-app connect from claude.ai/ChatGPT remains an owner-browser spot check whenever desired — the server side now advertises and answers every step of their documented flows.

## 6. Rollback

- Code: restore `McpOAuthController.php` from the pre-patch copy (md5 `825d3eb8…`, kept at `/tmp/McpOAuthController.php.pre-phase1` in the production container and reproducible from git history of the build tree), delete `McpCimd.php` (both trees), run the migration's `down()` (drops `mcp_cimd_url`; any materialised CIMD clients remain as ordinary clients and can be deleted from Connected Apps / `oauth_clients`).
- Config: remove the Cursor line from `allowed_redirect_uris` (Admin → Plugins → MCP → Configure) — new Cursor registrations stop; nothing else is affected.
- The discovery document loses the CIMD advertisement with the controller rollback; DCR/Postqon/PAT paths never depended on any of the new code (the rewrite is a no-op for non-URL client ids).

## 7. What remains / Phase 2 readiness

- **No blocker for Phase 2** (gap tools batch 1). The registry discipline Phase 2 needs — ability mapping, tier limits, plan-flag gating — is unchanged and battery-proven again here.
- Known limits of this lane's CIMD: DNS answers are checked before the fetch but not pinned (a theoretical DNS-rebinding window remains, bounded by the client_id-equality + redirect-allowlist validation of the fetched document); negative fetch results are not cached (a bogus URL client_id costs one ≤6 s fetch per authorize/token hit — the token endpoint is throttled 60/min, the authorize endpoint is session-gated).
- The owner's WhatsApp number / voice work was untouched, per this lane's scope; voice tools stay Phase 5 as designed.
