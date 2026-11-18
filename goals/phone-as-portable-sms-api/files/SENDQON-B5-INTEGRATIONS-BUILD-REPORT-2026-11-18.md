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

## 2. Browser Extension — COMPLETE + LIVE (ACTIVE v1.0.1)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed. Slug `browser_extension`, namespace `App\Plugins\Integrations\BrowserExtension`. Per-site branded MV3 extension zips (site URL + name baked in at download), Blade dashboard `/browser-extension`, API `/api/v1/browser-extension/*`; 10-minute single-use connect codes → 90-day tokens stored SHA-256-hashed, revocable from the dashboard; sends route only through core's `MessageSender`.

**Open defect from the first lane — root cause found (read-only diagnosis) + fixed plugin-side:** over HTTP, `POST /api/v1/browser-extension/send` returned core's `validation_failed` envelope while the identical direct controller call returned the designed `422 {"message":"Send refused: no_sms_provider"}`. Evidence: `bootstrap/app.php` appends `NormalizeCustomerApiErrors` **globally**; `CustomerApi::matches()` covers all `api/v1/*`; `ApiError::normalize()` replaces any ≥400 body whose code is not a valid snake_case token with the status fallback — for 422, `validation_failed`. The plugin's bare `{"message": ...}` body has no code, so the real refusal reason was being rewritten. (The battery's other error checks only asserted status codes, which is why exchange-422 / me-401 appeared to pass.) **Fix (v1.0.1, plugin-side only, no core edit, no patch-register entry):** all plugin error responses now use core's envelope `{error:{code,message,details}}` with stable codes — `send_refused` (with `details.reason`), `invalid_connect_code`, `contact_identity_required`, `sending_unavailable` — which normalization passes through untouched; the extension's `popup.js` reads `data.error?.message`. One further battery-found fix: `storeContact` crashed with an unhandled 500 on the `contacts_user_id_phone_unique` key when the same phone was added twice — it now returns the existing contact (200, `existing: true`), so contact creation is idempotent.

**Battery (dev, full HTTP click-path): 16/16 PASS** — page renders + download link, code issued, exchange 201 + token, code single-use 422, me 200/401, inbox + templates, contact create (201 fresh / 200 existing), **send → `{"error":{"code":"send_refused","message":"Send refused: no_sms_provider","details":{"reason":"no_sms_provider"}}}`** (correct for a tenant with no SMS provider), branded zip verified (URL + name baked, manifest/popup/background present), revoke → token 401, integrations card + manage_url present. **UI-surface PASS** (first lane): dashboard page renders in an authenticated dev session; admin configure surface via the integrations card.

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.1 ACTIVE** (activatable unconfigured by design); guest probe `GET /api/v1/browser-extension/me` → 401 `unauthenticated` envelope; site + /login 200; all containers Up. Baked into the build tree. **Push:** `plugin-browser_extension` **e97edd7** (ls-remote verified).

**PENDING-ACCOUNT:** none for activation. Tenant use needs the plan flag `browser_extension` (owner pricing decision — untouched) and a tenant SMS/WhatsApp route for sends to succeed.

## 3. osTicket — COMPLETE + LIVE (ACTIVE v1.0.0)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed against live core. Core ships the dormant half for all seven branded connectors: `SiteRouting::TABLES` site tables (plugin-supplied migrations), the Connect approval flow (`ConnectController`: consent page + `client_type` param + session consent token; callback POST `{state, api_key, url, site_id, brand}` must answer `{"ok": true}`), `ConnectedSites` lifecycle, `IntegrationRegistry`, `ConnectorArtifacts` branded downloads (signed route `<type>.download`; `ConnectorArchive::assertSelfhosted` forbids fixed service URLs anywhere in the zip except `brand.php`), and the integration send + OTP endpoints. The plugin supplies the client core resolves through the registry plus `Runtime\Services\BrandedDownload`, which core resolves by name. No core edits.

**What was built** (slug `osticket`, namespace `App\Plugins\Integrations\Osticket`): `OsticketClient` (IntegrationClient + IntegrationLifecycle; abilities `account.view, sms.send, waba.send, wa.send, email.send, otp.send`; version column `plugin_version` via the `X-Integration-Version` header; callback path `/include/plugins/sendqon/callback.php`), `osticket_sites` migration, branded-download prepare + signed serve routes, brand logo SVG. **Connector half** (`connector/sendqon/`, an osTicket 1.18.x plugin): event templates with variables for ticket created / staff reply / resolved / staff alert / agent assigned (HTML stripped; internal notes — thread type N — never send; agent texts only to the staff-profile mobile), staff alert numbers per line, department scoping, reply-by-text webhook (optional HMAC secret; latest-open-ticket match by phone; "create tickets from unknown numbers" OFF by default), and text-message 2FA riding osTicket's native enrolment through core OTP (codes created/checked by Sendqon, never stored by the connector). Events are observed through osTicket's ORM signals (`model.created` / `model.updated`), the mechanism the core audit plugin uses. One battery-found fix: the Connect approval parameter is `client_type`, not `type` (connector's connect URL corrected before first ship).

**Battery (dev): 44/44 PASS** — in-process 21/21 (plugin active, table + columns, registry client + live plan key, abilities, card shape, brand logo served, versions resolver, branded build zip contents, brand.php baked with the site URL, `ConnectorArchive::assertSelfhosted` pass) and HTTP 23/23 (tenant login, integrations hub card, detail + help pages 200, consent page + token, **full Connect approval against a protocol stub site** — callback delivered with api_key + site_id, approval redirect `?connected=1`; integration send → the designed routing refusal `site_routing_unavailable` / `no_sms_provider` for a tenant with no SMS provider; site summary 200; wrong-site header → 403; download prepare → signed URL → 200 zip with baked brand; guest download blocked; **UI surface: admin `/admin/plugins` lists osTicket, tenant hub + detail + help render**). One dev-rig artifact documented, not a defect: the signed download URL 403s when fetched bare from the dev rig because the 18081→80 port map makes Laravel reconstruct a different URL than the signed one; with the forwarded headers a production proxy sends, it returns 200 (proven). Dev-only battery affordances: `INTEGRATIONS_ALLOW_LOCAL_CALLBACKS=true` in the dev compose and the dev Pro plan's `osticket`/`otp` flags on (production plans untouched).

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.0 ACTIVE** (activatable unconfigured by design; tenants connect their own installs). Site + /login 200; guest download probe → 302 to login. Baked into the build tree. **Push:** `plugin-osticket` **8b19972** (ls-remote verified).

**PENDING-ACCOUNT:** a real osTicket 1.18.x install to extract the connector into and approve the first connection (connector half is protocol-identical to the battery-proven stub and PHP-syntax verified; live osTicket verification waits for an instance). Tenant use also needs the plan flag `osticket` (owner pricing decision — untouched).

## 4. Flarum — COMPLETE + LIVE (ACTIVE v1.0.0)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed; same core dormant half as osTicket (§3). The plugin supplies the registry client plus `Runtime\Services\BrandedDownload`. No core edits.

**What was built** (slug `flarum`, namespace `App\Plugins\Integrations\Flarum`): `FlarumClient` (same ability set; version column `plugin_version`; callback path `/api/sendqon/connect`), `flarum_sites` migration, branded-download routes, brand logo SVG. **Connector half** (`connector/`, a Flarum 2.x extension, Composer package `sendqon/flarum-messaging`, PHP 8.3+): Connect callback as an API route (state verified against the settings store; key stored in settings, never rendered; deliberately **no server-address or API-key field** — the address is fixed in the branded `brand.php`), an admin settings page as a session-authenticated forum route (connection status, Connect, moderator numbers, offered notification types — no JavaScript build needed), a "Text Message" notification driver for the native grid (admin-offered blueprints only; preferences start OFF; privacy-safe texts — actor + shortened title, never post/PM bodies, ≤320 chars; the verified phone is reloaded before every send; queued delivery with bounded retries), phone verification through core OTP (forum stores only the reference + verified phone), moderator alerts (≤10 numbers; registered only when the optional Flags/Approval event classes exist), and GDPR erase/export of the phone record.

**Battery (dev): 44/44 PASS** — in-process 21/21 (same shape as §3: registry, table, card, brand, versions, branded zip with root-level extension layout, archive guard) and HTTP 23/23 (hub card, detail + help, full Connect approval against the stub, integration send → `site_routing_unavailable`/`no_sms_provider`, site summary, wrong-site 403, signed download 200 with baked brand, guest blocked, admin plugins UI lists Flarum). Two battery-rig lessons recorded: the stub callback server must be verified from inside the container (host-side port checks are meaningless), and a stale stub bound to the port silently 404s other connectors' callbacks — the generic stub now serves any POST path on its own port.

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.0 ACTIVE** (activatable unconfigured by design). Site + /login 200. Baked into the build tree. **Push:** `plugin-flarum` **fdd3ba3** (ls-remote verified).

**PENDING-ACCOUNT:** a real Flarum 2.x install to place the extension into and approve the first connection (connector half is protocol-identical to the battery-proven stub and PHP-syntax verified). Tenant use also needs the plan flag `flarum` (owner pricing decision — untouched).

## 5. Appointment Booking — COMPLETE + LIVE (ACTIVE v1.0.0)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed. The deep item of B5: core ships the dormant half (11 tables, models, the staff Bookings controllers, the public `/b/...` routes in `routes/bookings.php`, `bookings:tick` + `bookings:calendar-poll` commands) and the plugin supplies the whole `BookingAccess`-resolved surface. No core edits.

**What was built** (slug `appointment_booking`, namespace `App\Plugins\Integrations\AppointmentBooking`): `BookingNodes` (the five node types — Appointment Event trigger, Send Booking Link, Wait for Booking, Offer Times, Appointment Action — with executors, validator errors, dry-run outputs and the editor's `booking_services`/`booking_members` option lists), `AvailabilityEngine` (free slots from weekly hours, time off, buffer-expanded appointment blocks and Google busy blocks), `BookingWriter` (the single write path: member-row locking, round-robin assignment, Google mirroring, customer notifications via core MessageSender), `PublicBooking` (page, slot feed, manage page, ICS download, member ICS feeds), `AppointmentTriggers` (every-minute engine; booked/rescheduled/canceled observed in a 15-minute window, reminders in their minute window; deduped by `appointment_trigger_fires`), `BookingWake` (completes parked waits — Booked / Timed Out), and the Google trio (`GoogleCalendarClient`, `CalendarPoller`, `DeleteCalendarEventsJob`) behind the operator's optional Google Cloud app.

**Battery-found design facts, handled in-plugin:** core's public booking routes are **session-free by design** (no cookie, no CSRF — throttled, honeypot expected) — the first manage-page build used session flash and 500'd; messages now travel as query parameters and both forms carry a honeypot field that silently drops bot submissions. Core's bookings rate limiter (10/hour per IP) is anti-abuse by design; the battery's final run was made after a dev cache clear.

**Battery (dev): 48/48 PASS** — in-process 34/34 (Access gates, catalogue carries all five types, executors, field options, engine slots, book → slot_taken on double-book → reschedule revision/previous → cancel → no-show, link/feed tokens, lock-failure mapping, poller, trigger tick launches once and dedupes, wake completes Booked + null on node mismatch) and HTTP 14/14 (staff `/bookings` UI renders, public page + slots feed, form booking → confirmation reference, manage page, ICS download, member feed 200 + wrong-token 404, manage cancel lands, admin plugins UI lists the slug).

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.0 ACTIVE** (activatable unconfigured by design — calendar credentials are optional config). Site + /login 200. Baked into the build tree. **Push:** `plugin-appointment_booking` **7a0b360** (ls-remote verified).

**PENDING-ACCOUNT:** the operator's Google Cloud OAuth app (Client ID/Secret in Admin → Plugins → Appointment Booking → Configure) to light up member Google Calendar connections, busy sync and Meet links; booking itself is fully live without it. Tenant use also needs the plan flag `appointment_booking` (owner pricing decision — untouched).

## 6. WordPress + WooCommerce — COMPLETE + LIVE (ACTIVE v1.0.0)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed. WordPress is both a branded connector and a commerce provider: core's `WooCommerceIntegrationController` resolves the registry client for `wordpress` and requires it to implement `StoreEventIntake` (no implementation existed anywhere in core or the B4 plugins — this plugin is the first). No core edits.

**What was built** (slug `wordpress`, namespace `App\Plugins\Integrations\WordPress` — the capital-P segment is load-bearing: core's `IntegrationVersions` resolves `WordPress\Runtime\Services\BrandedDownload` by that exact name, a battery-found fact): the ConnectedSites client (abilities include `flows.trigger`, which core's WooCommerce endpoints require), `wordpress_sites` migration, branded download, plus the intake — `connect()` registers/refreshes the site's store through core's `CommerceStores` (quota enforced there, command secret stored as an encrypted store credential) and `events()` maps WooCommerce's payload onto core's commerce DTOs into `CommerceIngest` (decimal strings → minor units; WooCommerce statuses mapped to core's `pending/paid/fulfilled/cancelled/refunded/expired` enum with the raw status kept as provider status; the request's `order.customer` block honoured for identity + consent). **Connector half** (`connector/sendqon/`, a WordPress plugin): state-validated Connect callback as a WP REST route (`/wp-json/sendqon/v1/connect`), notification rules with merge tags and WP-Cron delays, form-plugin actions for CF7/WPForms/Gravity/Fluent/Ninja/Elementor (guarded hooks, one generic submission event), WooCommerce order events + store handshake, consent-based abandoned-checkout capture with signed single-use cart-recovery links, member contact sync with role tags, and registration phone verification via core OTP (sign-in blocked until the texted code is entered on the plugin's verification page).

**Battery (dev): 46/46 PASS** — in-process 21/21 (registry, card, versions, branded zip with the WP layout, archive guard, StoreEventIntake conformance) and HTTP 25/25 (hub/detail/help, Connect approval, send → `site_routing_unavailable`, wrong-site 403, signed download, admin UI, **WooCommerce handshake → `{store_id}` and order event → `{recorded: 1}`** against core's real endpoints). Two dev-fixture notes: the Connected Stores quota reads plan limits (dev Pro plan limit raised on the dev copy only), and repeated battery stores accumulate against that quota — both dev-only.

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.0 ACTIVE**. Site + /login 200. Baked into the build tree. **Push:** `plugin-wordpress` **fe849d8** (ls-remote verified).

**PENDING-ACCOUNT:** a real WordPress (+WooCommerce) install to place the connector into and approve the first connection (connector half is protocol-identical to the battery-proven stub and PHP-syntax verified; the WooCommerce intake was proven against core's real endpoints with a protocol payload). Tenant use also needs the plan flag `wordpress` (owner pricing decision — untouched).

## 7. WHMCS — COMPLETE + LIVE (ACTIVE v1.0.0)

**Plan-card check:** type `integration`, runtime contract 1 — confirmed; version column is `module_version` (core's ConnectedSites header map for WHMCS). No core edits.

**What was built** (slug `whmcs`, namespace `App\Plugins\Integrations\Whmcs`): the ConnectedSites client, `whmcs_sites` migration, branded download. **Connector half** (`connector/sendqon/`, a WHMCS addon module for `modules/addons/`): state-validated Connect callback storing the key in the addon's settings rows, an admin output page with per-event rules — invoice created/paid/reminder, ticket opened/user reply/admin reply/closed, client registered, service suspended/unsuspended — **all starting disabled** per the spec, staff copy numbers, reply-by-text via `webhook.php` (latest open ticket matched by phone, `localAPI('AddTicketReply')`, optional shared secret), phone verification + a sign-in code challenge via core OTP (client-area verify page), and a cron-drained retry queue (`mod_sendqon_queue`, exponential backoff, max 5 attempts).

**Battery (dev): 44/44 PASS** — in-process 21/21 + HTTP 23/23 (hub/detail/help, Connect approval against the stub at the module callback path, send → `site_routing_unavailable`, site summary, wrong-site 403, signed download with baked brand, guest blocked, admin plugins UI lists WHMCS).

**Production:** fresh backup (status=OK push=OK) → installed **v1.0.0 ACTIVE**. Site + /login 200. Baked into the build tree. **Push:** `plugin-whmcs` **ba80291** (ls-remote verified).

**PENDING-ACCOUNT:** a real WHMCS 9.0+ install to place the addon module into and approve the first connection (connector half is protocol-identical to the battery-proven stub and PHP-syntax verified). Tenant use also needs the plan flag `whmcs` (owner pricing decision — untouched).
