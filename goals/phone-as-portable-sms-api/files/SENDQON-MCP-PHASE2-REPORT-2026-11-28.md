# Sendqon MCP Phase 2 — Gap Tools Batch 1 — Report (2026-11-28)

**Status: COMPLETE + LIVE on production.** MCP plugin **v1.0.1 → v1.0.2**;
registry **30 → 45 tools** (READ 19→33, WRITE 6, SEND 5→6). DEV battery
**83/83 PASS**; production acceptance all green (details below). No core
files were patched in this phase — the whole batch lives in the MCP
plugin. Design of record: `SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`
§5 Phase 2; the batch built is exactly the batch-1 set it names.

## Tools landed (15)

### Registry tools (8) — plain definitions over existing `/api/v1` endpoints

| Tool | Class | Endpoint | Ability |
|---|---|---|---|
| `list-templates` | READ | `GET /api/v1/waba/templates` (`$page`, optional `status`) | `waba.templates.view` |
| `get-template` | READ | `GET /api/v1/waba/templates/{template}` | `waba.templates.view` |
| `list-segments` | READ | `GET /api/v1/contacts/segments` | `contacts.view` |
| `list-sender-ids` | READ | `GET /api/v1/sender-ids` | `sms-providers.view` |
| `list-sims` | READ | `GET /api/v1/sims` | `devices.view` |
| `list-waba-phones` | READ | `GET /api/v1/waba/phone-numbers` | `waba.phones.view` |
| `list-flows` | READ | `GET /api/v1/flows` | `flows.view` |
| `get-flow` | READ | `GET /api/v1/flows/{flow}` | `flows.view` |

Ability resolutions where the design had guessed (verified in code):
sender-ids = `sms-providers.view`; WABA phones = **`waba.phones.view`**
(design guessed `waba.accounts.view`); segments = `contacts.view`;
flows = `flows.view`. "Templates" means **WABA templates** — the
campaign API's `template_id` resolves against `WabaTemplate`; no other
API-consumed template model exists (DLT templates are panel-only).

### Direct tools (7) — new in-plugin mechanism

Seven surfaces have no dispatchable REST shape (panel-only, plugin-web,
or multipart-only), so v1.0.2 adds a direct-tool mechanism: a definition
carries `'handler' => 'direct'` + an executor class; `McpServer` builds
`Tools\DirectTool` for those. DirectTool holds exact parity with the
dispatched path — same ability check (`AbilityPermissions::tokenAllows`)
and byte-identical `missing_ability` envelope, SEND tier wrapped in
core's `McpSendLimit`, throwables rendered via `ApiError`, output via
`McpOutput` (redaction + truncation). Definitions keep plausible
method/path keys naming the sibling surface, so core's help/availability
consumers (`McpDocsController`, `HelpAvailability`) keep working —
verified: 45/45 definitions carry path+method on production.

| Tool | Class | Executor | Gate / notes |
|---|---|---|---|
| `upload-whatsapp-media` | SEND | `Tools\Direct\UploadWhatsappMedia` | `wa.send`. Accepts `content_base64` + `filename` (the MCP JSON dispatch cannot carry the endpoint's multipart upload), then replicates `Wa\MediaController@upload` exactly: same validation (≤51200 KB, same mime list), same `FileStore::put` arguments, same 201 body (`media_url`/`media_path`/`expires_at`/`mime_type`/`size_bytes`). |
| `get-sim-balance` | READ | `Tools\Direct\GetSimBalance` | `devices.view`. Latest sim_fleet report for one SIM; SIM scoping mirrors `SimController` (explicitly through the owning device's `user_id`). `balance` is the stored row exactly as reported, or **null when the SIM has never reported** — never invented. 404 when the plugin is inactive or the SIM is another tenant's. |
| `list-email-accounts` | READ | `Tools\Direct\ListConnections` | `account.view`. Mirrors `ConnectionController@index` (registry-availability filter + channel limits + `ConnectionResource` shape) narrowed to type `email`. |
| `list-telegram-accounts` | READ | `Tools\Direct\ListConnections` | `account.view`. Same, types `telegram_bot` + `telegram_account`. |
| `search-knowledge` | READ | `Tools\Direct\SearchKnowledge` | Calls core's `KnowledgeSearch` service with origin **`api`** (an origin the service already allowed). The service itself enforces plugin-active, the `knowledge_base` plan flag, tenant scoping, query quota and AiGateway credit pricing; unavailable reasons pass through unchanged. `knowledge_base_id` optional only when the workspace has exactly one base; with several, a 422 names the candidates. Ability is `account.view` as registry plumbing — no KB ability exists in core's ability map; the real gate is the service's own enforcement (battery-proven). |
| `list-agents` | READ | `Tools\Direct\ListAgents` | Mirrors the ai_agents panel index (tenant-scoped, search, status filter, 7-day conversation counts) with a **trimmed** projection of `AiAgent::present()`: `instructions`, `routing_description` and `actions` are NOT exposed over MCP. Gates mirror the API's own idiom: plugin files missing → 404 `not_found`; plan without the feature → 403 `feature_not_in_plan` (same envelope `api.feature` produces for flows). |
| `lookup-number` | READ | `Tools\Direct\LookupNumber` | The HLR plugin's validator. 404 when the plugin is inactive (its own middleware's behaviour). Tenant id passed is the actor's workspace id (the panel controller passes the user id; the validator's contract is the workspace — cache is shared per workspace accordingly). |

### HLR cost model — corrected against the design

The design called HLR "READ-with-cost — metered like a send". The code
says otherwise, and the tool follows the code: `HlrValidator::check`
charges **no workspace credits**. An uncached lookup spends the
**platform's** HLR provider quota (plugin-level config), results are
cached per workspace for **30 days**, and with no provider configured
the validator answers `unknown` without calling out. Observed deployed
behaviour: `unknown` results are cached too (a second identical lookup
returns `cached: true`). The tool is therefore NOT wrapped in the send
limiter, and the ToolCatalog description states this cost model plainly.

## DEV battery — 83/83 PASS (sendqon-dev, as www-data, real HTTP to /mcp)

Per tool: happy path as the real tenant class · tenant isolation
(B cannot see/reach A's templates, flows, SIMs, balances, KB bases,
agents, segments) · missing-ability refusal **byte-equal** to the
sibling tool's (`get-sim-balance` vs `get-device`, same `devices.view`
error object) · plan-flag OFF behaviour identical to existing tools
(Free-plan context: whole-surface 404 `not_found` for new and old
tools alike; `ai_agents` flag off → 403 `feature_not_in_plan`;
`knowledge_base` flag off → service-level `not_in_plan`) · REST
regression on every mirrored endpoint (200s + unauthenticated 401) ·
tools/list = 45 (admin), 33 (read-tier PAT), SEND visibility parity
for a `wa.send`-only token (media tool listed exactly like
`send-wa-message`, `send-sms` hidden) · one full OAuth grant walk
(DCR → consent as tenant 28 → token → direct tools called; a grant
without sending is refused `insufficient_scope` on the media tool) ·
UI surfaces (admin plugins page shows v1.0.2, MCP readiness 200,
`/help/mcp` 200 and mentions the new tools) · registry = 45 in-process
as www-data · cleanup verified (plan features + provider config
restored, battery tokens deleted).

Media end-to-end (DEV): 1×1 PNG uploaded through the tool → 201 +
`media_path` → `send-wa-message` with that media was **not**
scope/ability-refused; it stopped at a business validation (422,
the tenant's WhatsApp account is `pending_pair`) — the brief's
acceptance shape. Bad mime and missing filename → 422
`validation_failed`, identical to the REST endpoint's rules.

KB search (DEV): the DEV stub AI provider's upstream no longer exists
(search answered `provider_misconfigured` before the fix), so the
battery served deterministic embeddings from a local stub — a
dequantized copy of the seeded chunk's own vector — pointed to via
provider **config** `base_url` only (credentials untouched, config
restored after). The full service path (gating, quota, ranking, hit
shaping) ran for real; the production acceptance below ran against
the **real** Rektrs KB with the real Gemini embedding path.

### DEV environment repairs made on the way (recorded honestly)

- DEV was missing plugin **files** for knowledge_base, ai_agents, hlr
  (DB rows active, files absent) and for email, telegram, push, widget
  — installed from the local zips (knowledge-base-1.0.0,
  ai-agents-1.0.1, hlr-1.1.1, email-1.0.8, telegram-1.1.1,
  web-push-1.0.0, website-chat-1.0.0). After this, DEV's channel
  registry matches production's 12 types exactly; before it, the
  email/telegram pickers returned empty in DEV **in parity with
  core's own `/api/v1/connections`** (which returned only
  phone_bridge rows) — the tool was never the divergent side.
- An early battery run double-encoded two DEV plan rows' `features`
  JSON (assigning a JSON string into an array-cast attribute). Both
  rows were repaired by double-decode + array assignment and verified
  (`mcp` toggle removed, all original flags intact). No production
  data was ever involved; the production deploy used the zip route
  only.
- DEV fixture accounts' passwords (users 1 and 28) were set in-process
  by the battery for the consent/login flows, as in earlier lanes;
  their prior fixture values were not known and are not recoverable —
  future DEV lanes should set them in-process the same way.

## Production deploy + acceptance

- Fresh backup first: `backup.sh` → status=OK, push=OK; all three
  2026-11-28 artifacts gzip-verified.
- Install: `mcp-1.0.2.zip` (installed zip md5 `c7a958f4…`; the repo
  zip differs only in README.md, rebuilt after the Phase 2 note was
  added — docs-only, no reinstall) via `PluginManager::installFromZip`
  as root. **Plugin config md5 identical before/after**
  (`3ef65782…`, Postqon + Cursor redirect URIs preserved). Plugin
  source baked into the host build tree mode-normalised; build-tree
  md5s == live-container md5s for the changed files.
- Acceptance (temporary master-admin PAT, minted → used → deleted in
  one script; admin PAT count 3 before and after):
  - tools/list = **45**, all 15 new tools present; `get-account`
    regression 200.
  - `list-sims` → 4 rows (both devices). `get-sim-balance` sim 3 →
    stored row (status `failed`, checked 2026-11-28 16:29 UTC — the
    carrier-deferral saga's current state, reported as stored);
    sim 4 → stored row (status `failed`, checked 2026-11-28 04:29 UTC).
  - **`search-knowledge` against the real Rektrs KB (id 1): available,
    5 hits** (first hit = the company-profile FAQ chunk), query
    recorded with origin `api`.
  - **`list-agents`: 200, 1 row** — Rektrs Assistant; the master-admin
    workspace passes the plan gate (bila-qayd behaviour confirmed
    empirically through the tool).
  - Pickers `list-templates` / `list-segments` / `list-sender-ids` /
    `list-waba-phones` / `list-flows` / `list-email-accounts` /
    `list-telegram-accounts`: all 200 with honest empty rows (the
    admin workspace has no such objects in production).
  - Restraint per brief: **no production HLR spend** (admin tenant has
    no cache rows; the call was made only with a token lacking
    `account.view` → 403 `missing_ability`, executor never ran) and
    **no production media upload** (sms-only sending token →
    `insufficient_scope` at the boundary, nothing stored).
  - Postqon unregressed: OAuth client row byte-identical (md5
    `c7bd6b39…` before/after), its 1 live grant still active.
  - Site 200; no errors in the deploy-window container logs.

## Deferred (with reasons)

- `get-agent-activity` → batch 2 (design §5 names only `list-agents`
  for batch 1).
- `run-flow` → Phase 4 (design §3.1: MCP-invoked runs fall out of the
  automations layer once flows are addressable there).
- `run-ussd` → Phase 3+ (owner-console scopes first, per design).
- `update-contact`, group/tag membership writes, `get-balance` /
  `list-invoices`, `list-webhooks` → not in the §5 batch-1 list.
- Voice tools (`place-call`, `get-call`, `list-calls`,
  `get-call-recording`) → Phase 5, gated on the `voice` plugin + B10.2.

## Pushes

- Plugin source (v1.0.2) → Sendqon branch `plugin-mcp`, and this
  report → Sendqon `rebuild-tree` planning/: **NOT COMPLETED** — the
  local Sendqon clone (`~/workspace/sendqon-push`) failed an
  execution-risk check when its status was read; git operations
  inside it are blocked pending the owner's go-ahead. The v1.0.2
  source is live on production, baked into the host build tree, and
  present locally at `~/workspace/sendqon-plugins/mcp/` (+
  `mcp-1.0.2.zip`), so nothing is at risk of loss; the push is a
  records step that remains owed.
- This report → rektrs-workspace `main`: see the hash recorded in the
  lane summary (pushed via `~/workspace/rektrs-workspace-push`).

## Phase 3 blockers

None from Phase 2. The bridge (Phase 3) consumes this same registry;
the direct-tool mechanism is the pattern its in-kernel calls will
reuse. Known standing items unchanged: plan flags for
`ai_agents`/`knowledge_base` on tenant plans remain the owner's
pricing decision (the tools enforce whatever the flags say).
