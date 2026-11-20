# Sendqon — Audit Fixes Report — 2026-11-20

Fix lane for the defects found by the 2026-11-20 live website audit (rendered-UI audit in the
owner's Chrome) plus the completion-audit additions A–E. All work server-side on offbox-1.
A fresh backup was taken before any production change (2026-11-20 ~06:02 UTC, status=OK
push=OK; DB gzip integrity + completion footer verified, sendqon-db-2026-11-20.sql.gz =
11,829,314 B). Every plugin change went through PluginManager zip installs, was verified as
**www-data**, was baked into the host build tree (root:root, 644/755), and its source was
pushed to its `plugin-<slug>` branch (ls-remote verified, hashes at the end).

---

## Finding 1 — /channels Error 500 — FIXED

**Root cause (one defect, proven from the stack trace).** The Laravel log for 2026-11-20 held
exactly 4 errors, all `Unknown app slot [phone_bridge_windows]` (InvalidArgumentException,
AppSlots.php:102), at 05:24:28, 05:24:35, 05:40:35, 05:40:50 UTC. Stack:
`ChannelsController::index` → `ChannelRegistry->types()` → `PhoneBridgeProvider->connectAction()`
→ `AppSlots->get('phone_bridge_windows')` throws. Core's channel registry assigns the
phone_bridge channel two app slots (`phone_bridge_windows`, `bridge_firmware`) and the
gsm_modem channel three (`modem_windows`, `modem_linux_amd64`, `modem_linux_arm64`), but
neither of our shim plugins implemented the `ProvidesAppSlots` contract, so no slot was ever
registered and building the Channels page crashed. A second, identical crash was latent in
`GsmModemProvider` (its box-type dialog hard-`get()`s the modem slots) — proven live: after
the phone_bridge fix, the same code path threw `Unknown app slot [modem_windows]`.

**Fix.** Both shims now implement `ProvidesAppSlots` and declare their slots exactly as core
defines them (zip type, `UpdateManifest` source for the Windows/Linux downloads,
`FirmwarePackage` source for bridge_firmware, the channel feature key, and core's own
`TelephonyAppCompat` minimum versions). Declaring a slot creates an empty download shelf —
the admin sees "Not set" until a package is uploaded, exactly like the vendor Android
plugin's RCS shelf. It does **not** promise a Windows bridge app (the B10 research verdict —
a Windows bridge is not replicable — stands; nothing was built or advertised).

- phone_bridge 1.0.0 → **1.0.1**, gsm_modem 1.0.0 → **1.0.1**, installed via PluginManager, active.

**Evidence.** Fresh-process www-data probe of the exact crashing call:
`ChannelRegistry::types(user 1)` now builds all **11 channel types** cleanly
(android, sms-providers, waba, whatsapp, phone-bridge, gsm-modem, widget, push, email,
telegram-bot, telegram-account); all 5 telephony slots resolve with the right owners.
Log check: the last "Unknown app slot" error is timestamped 06:11:58 UTC — mid-install —
and there are **zero** since. This matches the completion audit (addition A): /channels was
500 at 11:11–11:12 PKT and rendered correctly from 11:14 PKT; the installs completed
06:11–06:13 UTC = 11:11–11:13 PKT. **Yes — this lane's fix is what repaired /channels.**

## Finding 2 — "Unknown app slot [phone_bridge_windows]" in the error log — FIXED

Same defect as Finding 1 (the log entries the audit saw at 05:24 UTC are two of the four
above). Fixed by the same two plugin upgrades; no dangling reference remains and no fake
slot was created — the slots are core-assigned download shelves that stand empty.

## Finding 3 — Master admin must be without restriction — FIXED (functionally complete)

**How gating actually resolves (from core code).** User 1 (asadchoudhary@rektrs.com) has
`role = 'admin'`. In this codebase `isOwner()` means `role === 'user'` (a tenant workspace
owner); site admins are a different axis. Consequences, all verified by probe:

- `PlanFeatures::allows()` returns **true for admins** ("Admins get every live feature for
  their own workspace") — but only after two availability checks that apply to everyone
  (see the `rcs` note below). Probe after the fix: **62 of 63 feature keys allowed**.
- `PlanLimits::rate()` / `cap()` return **null (unlimited)** for admins — probe confirms
  null for sms_per_minute, devices, contacts, campaigns.
- **Subscriptions cannot be held by an admin at all**: `SubscriptionService::assignPlan()`
  aborts 403 on `abort_unless($owner->isOwner(), 403)` — attempted in this lane; the
  transaction rolled back cleanly (verified: 0 subscriptions, no partial state). Plan
  assignment is a tenant-owner concept in this app; the admin is the operator, not a
  tenant. So no plan row was (or could be) attached through the app's own machinery, and
  none was forced by hand.
- The one place with **no admin bypass** is credits: `CreditService::debit()` charges any
  workspace (network call charges use it). At balance 0 that was a real, functional
  restriction on the master workspace.

**Change made (reversible, exact records).** One credit grant through the app's own
machinery: `CreditService::grant(user 1, 10,000,000)` → **CreditTransaction id 1**,
note "Master admin unrestricted balance - owner rule 2026-11-20";
`users.credits_balance`: 0.0000 → **10,000,000.0000** (column is decimal(12,4); the amount
sits safely inside it). Nothing else was created or changed for this finding: no plan rows
edited, no subscription created, no other user touched (only 1 user exists).

**End state.** Features: all on (62/63, see below). Limits: unlimited (null). Credits:
10,000,000 — cannot block at any realistic network-call volume. Billing: no subscription
exists for the admin, so nothing bills him. The header may still read "Plan: No Plan"
because `plan_id` is NULL — that label is cosmetic; by the app's own design an admin
account carries no plan, and every gate that consults plan/limits resolves him as
unrestricted. Reversal = delete CreditTransaction 1 and set the balance back to 0.

**The one exception — `rcs`.** `allows('rcs')` is false even for the admin, and it is not
a plan restriction: `PlanFeatures::allows()` checks `RcsAvailability::installed()` *before*
the admin bypass — RCS additionally requires the Android plugin's RCS app to be installed,
which it is not. The gate is identical for every user and lifts when an RCS-capable app is
installed; it is an availability gate, not billing.

## Finding 4 — Service health + 75,214 failed jobs — FIXED

**Telegram (id 3) + Email (id 4) "Waiting for First Call", version Not set.** Root cause:
both companions have heartbeated every 30 s all along, *with* a version payload
(`{"version":"1.0.0",...}`), and the heartbeats landed (`last_health_at` current,
`last_health='healthy'`). But both plugins' heartbeat handlers only wrote
`last_health_at`/`last_health` — they never set `status` (stuck at `pending`) or `version`
(stuck NULL), so the admin showed 0/1 healthy forever. Core never probes these kinds
(it probes WhatsApp/SMPP itself; telephony marks healthy on inbound calls), so nothing
else could promote the rows. It was not the image rebuild and not a companion outage
(email's log shows only sporadic heartbeat failures 2026-11-18 16:33 → 2026-11-19 16:27
UTC, incl. two 502s inside the rebuild window; telegram's companion logged no errors).

**Fix (plugins only).** Both heartbeat handlers now also set `status='healthy'`,
`unhealthy_since=null`, and `version` from the companion's payload (validated as X.Y.Z).
Demotion mirrors core's telephony rule (10 minutes of silence → unhealthy):
`EmailServersHealthCommand` extended accordingly; a new `TelegramServersHealthCommand`
(`telegram-servers:health`, every five minutes) added — telegram previously had no health
command at all. telegram 1.1.0 → **1.1.1**, email 1.0.7 → **1.0.8**.

**Evidence.** Within one heartbeat cycle of the reinstall both rows flipped:
id 3 and id 4 now `status=healthy, version='1.0.0'`, `last_health_at` advancing every
30 s. Both health commands run clean ("All servers are reporting").

**Failed jobs 75,214 → 0.** Identification (count + samples preserved here): all 75,214
rows are on queue `default` and belong to exactly **two job classes** —
`App\Plugins\Tools\SimFleet\Runtime\Jobs\FleetTickJob` and
`App\Plugins\Tools\WaGuard\Runtime\Jobs\GuardTickJob`. Exception (sample, latest row
id 75215, failed 2026-11-19 06:08:10 UTC): `ErrorException: … The script tried to access
a property on an incomplete object … class definition
"App\Plugins\Tools\WaGuard\Runtime\Jobs\GuardTickJob" … was loaded before unserialize()`.
Oldest row id 2, 2026-11-18 16:12:36 UTC (a FleetTickJob). **Mechanism:** the two plugins
were installed on 2026-11-18 and their self-chaining tick jobs entered the database queue
immediately, but the queue-worker container still ran the pre-rebuild image, which
contained no plugin code — every job failed at unserialize. The failure window ends at
**06:08:10 UTC on 2026-11-19, the minute the queue container was recreated onto the
plugin-baked image** — the root cause was already fixed by that rebuild (the rebuild's own
verification saw both job classes completing), and no failure of this kind has occurred
since (re-verified today: both tick jobs log RUNNING → DONE every cycle; pending queue = 2).
With the cause gone, the historical backlog was cleared with the app's own
`php artisan queue:flush`. **Before: 75,214 → after: 0.**

**Telephony 1/2.** "PBX Telephony" (id 8) is healthy (v1.0.0, heartbeating). The second
row, "Primary Telephony (Own)" (id 7, `http://sendqon-modem-daemon:8443`, pending, never
reported), is **not** a dead test row: it is the B9 GSM-modem daemon's server registration.
The production modem daemon was deliberately defined-but-not-started in B9 (only the dev
daemon runs); the row is its legitimate registration and was left exactly as found.

**Final server table (after all fixes):** WhatsApp 1 healthy · SMPP 2 healthy ·
Telegram 3 healthy v1.0.0 · Email 4 healthy v1.0.0 · WhatsApp (Own Bridge) 5 healthy ·
SMPP (Own) 6 healthy v1.0.0 · Telephony (Own, modem daemon) 7 pending (by design, above) ·
PBX Telephony 8 healthy v1.0.0. WhatsApp/SMPP companions, their `work/` dirs and licence
state were not touched.

## Finding 5 — Network — FIXED (setting on; no shared lines exist yet)

`network_enabled` was `false` in the `network` settings group. Set to **true** through the
app's own settings machinery — `SystemSetting::set('network_enabled', true, 'boolean',
'network')`, the exact call the Admin → Settings → Partner Network save path makes
(stored: value `1`, type boolean, group network). Fresh-process verification:
`NetworkSettings::enabled() === true`. Honest distinction, as briefed: the feature is now
functional and reachable, but the master workspace's /network still shows no lines because
**no partner lines exist** (`network_lines` = 0; the Reseller++ partner layer has 0
partners). That is the real state of the network, not a setting problem.

## Finding 6 — Landing ":channels" — NO DEFECT (investigated, nothing changed)

`:channels` is a designed template token, not a typo. `App\Support\Landing\PublicCapabilities`
substitutes it with the live channel list at render time. Public evidence (re-checked
today): the homepage hero renders **"Connect with customers on SMS, WABA, WhatsApp, Email,
Website Widget and Web Push."** The audit saw the raw token inside the Landing Builder's
stored Subtitle field — that is the token's storage form, by design. The stored content
(landing_contents ids 72, 126; landing_items ids 91, 95) was **not** edited: replacing the
token with fixed text would break the dynamic channel list.

## Finding 7 — Vendor example content — MOSTLY PLACEHOLDERS (one real fix applied)

- **(a) Workspace branding — FIXED.** "Acme Inc." / "123 Main St, Springfield, IL 62701,
  USA" are input *placeholders* in the settings UI; the stored values were
  `business_name = NULL`, `business_address = NULL`. Set the real identity through the
  app's own save shape (the Messenger SettingsController's trim + save on the tenant
  owner): **`business_name = 'Sendqon'`**. The address was left empty — no real address
  is on record and none was invented.
- **(b) Admin contact examples — NO STORED DATA, nothing to clear.** Stored
  `contact_phone`, `contact_whatsapp_number`, `contact_facebook_url`,
  `contact_instagram_url` are all `''`. The +1 555 numbers and facebook.com/example the
  audit saw are the settings form's placeholder texts (the same trap documented
  2026-11-16). Contact email asadchoudhary@rektrs.com is stored and correct.
- **(c) Custom code — NO STORED DATA, nothing to clear.** Stored `custom_head_code = ''`,
  `custom_footer_code = ''`, `custom_css = NULL`, `custom_code_enabled = ''` (cleared
  2026-11-16 and still clear). The analytics.example.com tag is the field's placeholder
  example, not stored code.

## Finding 8 — Audit draft flow — FIXED

The flows table held exactly one row: id 1, "Audit draft flow — do not use", user 1,
unpublished, `is_active = false`. Deleted through the app's own deletion path (the
`FlowController::destroy` internals: `FlowDependents::cancelOpenRuns()` → `$flow->delete()`
→ `revalidateParents()`; the controller's unpublish-first guard was satisfied). The model
soft-deletes: visible flows count is now **0** (the row remains in the table with
`deleted_at` set, exactly as an in-UI delete leaves it).

## Finding 9 — $0.00 transaction — INVESTIGATED, LEFT AS IS (correct behaviour)

The row is transaction **`TRX-5DO8KDYE`** (letter O; the audit misread it as a zero) —
the only transactions row: amount 0.00, **currency `USD` stored on the record itself**,
user_id NULL, created 2026-11-16 09:38:22 UTC. That is install day, *before* the
2026-11-17 switch of the billing currency to PKR (patch PR-003), and it belongs to the
deleted E2E test account. The "$" is the record's own historical currency, faithfully
displayed. Financial history was not rewritten.

---

## Completion-audit additions

**A. /channels working — CONFIRMED as this lane's fix.** See Finding 1: the error log's
last slot exception is 06:11:58 UTC (during the install sequence), the completion audit's
500 sightings are 11:11–11:12 PKT (= 06:11–06:12 UTC) and its first good render is
11:14 PKT — immediately after the phone_bridge (06:11 UTC) and gsm_modem (06:12 UTC)
1.0.1 installs landed. Root cause as in Finding 1.

**B. AI Agents 404 + missing sidebar link — ROOT-CAUSED; not a plugin defect; blocked on
the owner's AI-provider step.** The plugin is active (v1.0.1) and all 9 of its routes are
registered (`route:list` verified). The controller gates every route on core's
`AiAgentsAccess::enabledFor($tenant)`, which is `planAllows() && AiGateway::resolve() !== null`:
- `planAllows(user 1)` = **true** (plugin active; plan features `flows` + `ai_agents` both
  resolve true for the master admin — the master-admin state in Finding 3 changes nothing
  here because this was already true).
- `AiGateway::resolve(user 1)` = **null**, because the `ai_providers` table is **empty**
  (0 rows) — no AI provider exists anywhere in the system.
The sidebar link is shared by core's `HandleInertiaRequests` from the same access check,
so link and page appear together the moment a provider exists. This is core's designed
behaviour for every tenant (an agents page with no provider anywhere can do nothing), and
our plugin follows core's spec — the screens are core's frontend, gated by core's access
service. **Unblocking step (owner, already a known gate): add an AI provider under
Admin → AI Providers with a real free-tier key.** No code change is needed or was made;
bypassing core's access service in our controller would diverge from core's spec and
still would not restore the core-rendered sidebar link.

**C. HLR page unreachable — FIXED (page reachable in its configuration-required state;
provider stays owner-gated).** Diagnosis: the route path is correct and all 7 routes are
registered; the manifest is complete (same shape as the active peer integrations);
`getConfigSchema()` is declared (provider_url + api_key), so the Configure dialog exists
in the machinery. Two gates made the page a bare 404: (1) core refuses to activate any
plugin whose `isConfigured()` is false ("Configure the plugin before activating it.",
PluginManager) — HLR's provider credentials are empty, so the plugin must stay inactive
until the owner configures a real provider (no credentials were invented and the plugin
was **not** activated); (2) our own `EnsureHlrActive` middleware 404'd *every* HLR route
while inactive, including the read-only page whose own banner explains the
configuration-required state — the workspace could never discover how to configure HLR.
**Fix (hlr 1.1.0 → 1.1.1):** the page routes (index, page-check, page-bulk, page-preflight)
now pass the middleware in a `page` scope and render while inactive — the page shows
"No HLR provider is configured yet, so checks return 'unknown'. An admin can set the
provider URL and key under Admin → Plugins → HLR Number Validation → Configure." The
validator is a safe no-op while unconfigured (returns `unknown`; no provider call, nothing
cached — verified in its code). The JSON API routes (check, bulk, campaign preflight)
remain active-gated exactly as before. Verified as www-data: page-scope passes, API-scope
still aborts 404 while inactive, and the page renders with banner + panel chrome.
Owner's remaining step is unchanged: enter a real HLR provider URL + key in Configure,
then Activate — the plugin then serves its full UI. (For the record: google_sheets is in
the same inactive-unconfigured class; it was not in this lane's scope and was left as is.
The /integrations card list is core-rendered for live integrations; HLR joins it once
activated.)

**D. wa-guard + sim-fleet unstyled — FIXED.** Both pages were standalone HTML documents
with bare inline CSS — no brand, no topbar, no back link, no dark theme. Each plugin now
has a `views/layout.blade.php` in the exact pattern of the pta-mask layout (themed CSS
variables with dark-mode support, Sendqon topbar with brand + "Back to panel", flash and
validation-error blocks) and its index view `@extends` it. **All data, tables, forms,
routes and controls are byte-identical** — only the document wrapper changed (the views'
own duplicate flash blocks were dropped because the layout renders them, as in the
pta-mask pages). wa_guard 1.0.0 → **1.0.1**, sim_fleet 1.0.0 → **1.0.1**, both active.
Verified as www-data by rendering both views in their empty and owner (settings-form)
states: topbar, brand, Back-to-panel and all content markers present.

**E. Paystack "zender-" leftover — FIXED.** The string lived in the plugin **manifest
description**: "…saved-card renewals charged by Sendqon core (zender-owned renewals)…"
→ now "(Sendqon-owned renewals)". paystack 1.0.0 → **1.0.1**, reinstalled (stays inactive —
unconfigured gateway, as designed). The functional `renewal_owner = 'zender'` metadata
value in the plugin's code is a core contract literal (core resolves renewal ownership by
it) and was deliberately **not** changed — it is not display text. A scan of all plugin
manifests found this leftover in Paystack only.

**Confirmed absent (owner-decision build items, not defects).** Core has no Templates
page and no PBX extensions/queues pages; nothing was built for them in this lane, per
instructions.

---

## Final state snapshot (2026-11-20, after all fixes)

| Area | Before | After |
|---|---|---|
| /channels | Error 500 | Renders (11 types build cleanly; audit-confirmed 11:14 PKT) |
| Failed jobs | 75,214 | **0** |
| Telegram server (id 3) | pending, version NULL | **healthy, v1.0.0** |
| Email server (id 4) | pending, version NULL | **healthy, v1.0.0** |
| Telephony (id 7, modem daemon) | pending | pending — by design (B9 registration; prod daemon not started) |
| Master admin credits | 0 | **10,000,000** (CreditTransaction id 1) |
| Master admin features/limits | bypassed in code, unverified | verified: 62/63 features on (rcs = availability gate), limits null |
| Partner Network setting | OFF | **ON** (0 partner lines exist — real state) |
| Workspace business name | NULL ("Acme Inc." placeholder) | **Sendqon** |
| Flows | 1 audit draft | **0** |
| /integrations/hlr | 404 | renders configuration-required page (plugin still inactive, provider owner-gated) |
| /wa-guard, /sim-fleet | bare HTML | panel-chrome layout |
| Paystack description | "zender-owned renewals" | "Sendqon-owned renewals" |

Plugin versions on production now: phone_bridge 1.0.1 · gsm_modem 1.0.1 · telegram 1.1.1 ·
email 1.0.8 · hlr 1.1.1 · wa_guard 1.0.1 · sim_fleet 1.0.1 · paystack 1.0.1 — all also baked
into the host build tree (`~/sendqon-build/src`, root:root 644/755) for the next image build.

## Pushes (all ls-remote verified)

Plugin branches (Sendqon repo): plugin-phone_bridge `a4ee915` · plugin-gsm_modem `7c0345d` ·
plugin-telegram `2efb4fa` · plugin-email `2e76e08` · plugin-hlr `4601481` ·
plugin-wa_guard `7bed731` · plugin-sim_fleet `94777f1` · plugin-paystack `7bd62fa`.
This report: Sendqon `rebuild-tree` (planning/) and rektrs-workspace `main`
(goals/phone-as-portable-sms-api/files/) — hashes in the lane's closing summary.
