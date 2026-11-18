# Sendqon B5 Build Report — Integrations (14 items)

**Date:** 2026-11-18 (PKT) · **Plan:** `SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md` §3 Phase B5
**Pattern:** B1–B4 discipline + the 2026-11-18 owner directive — dev copy first
(`~/sendqon-dev/` on offbox-1, own DB + dev-only APP_KEY), per-item battery
**including a rendered UI-surface check** (authenticated dev session, lane-created
dev users only), production backup → `PluginManager` install → live-safe
verification → bake into host build tree → push per item (source branch
`plugin-<slug>`, every push `ls-remote`-verified).

**Architecture finding (verified against live core code before building):**
core ships dormant contracts for most of this family — Access gates
(`GoogleSheetsAccess`, `BookingAccess`), site tables for the seven branded
connectors (`SiteRouting::TABLES`), the Connect approval flow
(`ConnectController`), `IntegrationRegistry` contracts, and the Google Sheets
tables/models/poller command. Each plugin supplies exactly the classes core
resolves by name. No core files are edited in this phase; anything that would
need one is recorded as a proposed patch-register entry instead.

**Credential rule:** no real credentials exist for any B5 item (Google Cloud
app, Shopify app, third-party accounts). All are operator/tenant-entered
sensitive config. Dev batteries use `Http::fake()` / stubbed provider
responses; live verification is **PENDING-ACCOUNT** per item.

**Evidence-first dispositions (plan-prescribed):**
- **GoHighLevel — NOT BUILT.** Evidence assessment: the only evidence is a
  v1.0.0 plugin entry in the vendor demo's admin list, inactive
  "Configuration required"; no portal page, no docs catalogue entry, no
  feature/workflow evidence anywhere (rebuild-tree spec
  `02-PAID-PLUGINS/gohighlevel.md` records exactly this). The plan's rule —
  "docs milein tab spec bane", build only on tenant demand — is not met.
  Building a feature list would mean inventing it. Disposition recorded;
  revisit when vendor docs or a tenant demand appears.
- **monday.com — NOT BUILT.** Identical evidence state (demo-only v1.0.0,
  inactive; no portal page, no docs). Same disposition, same reasoning.

Per-item sections are appended as each item completes.

## 1. Google Sheets — COMPLETE (installed, INACTIVE pending operator Google app)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed against live core. Core ships the dormant half (tables/models, tenant connect dialog + routes, `flows:google-sheets-poll` command, `GoogleSheetsAccess` gate: CONFIG_KEYS client_id/client_secret/project_number/api_key, NODE_TYPES trigger/action×2). The plugin supplies the classes core resolves by name: `GoogleSheetsClient`, `GoogleSheetsNodes`, `SheetPoller` (no core edits, no patch-register entry).

**What was built** (slug `google_sheets`, v1.0.0): OAuth client (authorization URL with drive.file-only scope, code exchange, refresh + credential persistence, revoke; failure reasons mapped to core's message keys: sheets_not_connected / sheets_reconnect_required / sheets_rate_limited / sheets_file_unavailable / sheets_range_invalid / sheets_request_failed); the 3 flow nodes with catalogue entries, validator errors/warnings (incl. picked-file warning); SheetPoller — syncs subscriptions from published New Row flows, baselines existing rows on (re)publish or config change (epoch+1), then launches the flow exactly once per new unique-ID value (dedupe in `google_sheet_row_occurrences`, payloads encrypted); Add Row writes RAW text ordered by header name, one `google_sheet_operations` idempotency row per (run, node), and an append with an uncertain outcome is verified against the sheet tail before any retry (never blind-repeated); Find Row branches found / not_found / error. Limits honoured: 100 columns, 10,000 rows.

**Battery (dev, Http::fake Google wire): 31/31 PASS** — access gates, catalogue + executor registry resolution, OAuth URL/exchange/refresh-persist, Drive 404 → reason mapping, node errors/warnings, add-row append-once + header ordering + operation record + idempotent re-run, find-row 3 branches, poller baseline (3 rows) → new row launched exactly once → no duplicate on re-poll. **UI-surface check PASS:** tenant `/integrations` 200, `/integrations/google-sheets` JSON shows connection `connected` + picked file "Leads"; admin `/admin/plugins` lists Google Sheets, configure drawer for `google_sheets` renders. (One in-plugin bug found + fixed during the battery: missing `GoogleSheetsAccess` import in SheetPoller.)

**Production:** fresh backup (status=OK push=OK) → installed v1.0.0 **INACTIVE**; activation attempt refused by the app itself — "Configure the plugin before activating it" (correct: no Google Cloud app exists yet). Baked into the build tree. **Push:** `plugin-google_sheets` **dde88af** (ls-remote verified).

**PENDING-ACCOUNT:** operator creates a Google Cloud OAuth app (client id/secret, project number, Picker API key) → Admin → Plugins → Google Sheets → Configure → Activate; tenants then connect + pick files (plan gate `flows` + `google_sheets` is core's; no plan currently carries `google_sheets` — owner pricing decision, untouched by this lane).
