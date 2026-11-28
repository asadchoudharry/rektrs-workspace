# Surface → Provider API Wiring Census — 2026-11-28

**Owner order (main chat, 2026-11-28 ~14:23 PKT):** "sab features ki surface wired kro to provider API" — wire EVERY feature surface to the provider API. No surface may stay on mock data, dead buttons, placeholder content, or local-only state.

**Method:** four parallel read-only censuses of the LIVE trees (not the repo alone):
- Console: live tree `/opt/operqon-private-control/provider_control/operator_console/` on the VPS, cross-checked against the live provider service source `/opt/operqon-provider-r2/app/`.
- Portal: live apex `/srv/operqon-public-portal/current/customer/` (→ release `v-os69-no-interstitial-20261126-141542`) diffed against the git repo copy `/opt/operqon-r2-github/releases/operqon-provider-r2/frontend/customer/` and the non-git VPS working copy `/opt/operqon-provider-r2/frontend/customer/`.
- Tenant SPA: source tree `~/workspace/operqon-dreams/e2/frontend/` (31 files, 43,560 lines; packaged builds are byte-identical copies).
- Provider API: route enumeration from the release ref `e356f275` (PR #200) in the VPS clone — one PR behind the live tip `8ba96881` (PR #201, OS-89, recorded as console-frontend work). 198 route decorators. NOTE: the clone's checkout sits on branch `cursor/erp-e7-finance-budget-6431`, not the release branch — hygiene item, inventory was read from the ref without switching (one-writer rule).

**Status key:** WIRED = real API read + write as the feature implies · PARTIAL = only part of the feature wired · MOCK = renders fixture/sample data · DEAD = visible control does nothing · MISSING-ENDPOINT = the API capability the surface needs does not exist · IN-FLIGHT = fix already assigned and running (not a new gap).

## Summary — counts per status per surface

| Surface | Rows | WIRED | PARTIAL | MOCK | DEAD | MISSING-ENDPOINT | IN-FLIGHT |
|---|---|---|---|---|---|---|---|
| Provider console (control.operqon.cloud) | 28 | 14 | 3 | 0 | 0 (+2 shell extras) | 9 | 2 |
| Customer portal (operqon.cloud/customer/) | 28 | 16 | 3 | 4 | 2 | 3 | 0 |
| Tenant SPA | 84 | 47 | 21 | 1 | 7 | 8 | 0 |
| **Total** | **140** | **77** | **27** | **5** | **9** | **20** | **2** |

**61 rows are not fully wired** (27 PARTIAL + 5 MOCK + 9 DEAD + 20 MISSING-ENDPOINT). Every one of them is assigned in §6 — none is parked.

## Corrections to the standing record (evidence-backed)

1. **There is NO missing "Operqon invoicing API" for the portal.** Portal billing is fully wired: `GET /api/v1/customer/invoices`, `…/invoices/{id}/pdf`, `GET /api/v1/customer/statements/pdf`, `POST /api/v1/customer/payment-notices`, `GET /api/v1/customer/subscription-offer`, `POST /api/v1/customer/subscription-start`. Provider-side invoice creation exists too (`POST /api/v1/provider/billing/invoices`, issue, Stripe/JazzCash checkout, payment links).
2. **What IS missing is an EXTERNAL-client invoicing surface**: invoicing exists only behind a provider principal (console) or as customer-read-only. No public / API-key / third-party-client invoicing endpoint exists anywhere. This is exactly what the Postqon UD-1 phase (b) item ("invoice + payment link" for commerce orders) waits on — an Operqon-side decision on the invoice API route for external products (record in `memory/2026-11-20.md` / `memory/2026-11-21.md`; it is a Postqon item and does not appear in this goal's LOOP-STATE or FEATURE-REQUESTS-LOG). Under the owner's order, the missing endpoint IS the work: it is in the Cursor assignment below as a build, not a parked blocker.
3. **Easypaisa / PayFast payment-link webhooks exist but are NOT_LIVE** — `main.py` mount comment: webhook shapes sit behind the merchant-live gate (`merchant_live_verified` false); live settlement stays owner-gated. The console Payments panel likewise only shows a notice for non-Stripe/JazzCash hosted checkout ("Awaiting merchant checkout contract and signed callback configuration").
4. **No DC-1…DC-5 "registered mock" list exists in this goal's files** (grep-proven: 0 hits for "registered mock"; no DC-* files; `frappe-surface-census-20261116.md` contains no mock records; FEATURE-REQUESTS-LOG holds only FR-001…FR-004). The mocks are in the live trees themselves and are captured by this census.
5. **The portal git gap is 5 files, not 2** (details in §5): auth.js, complete-signup.js, customer.css, dashboard.html, callback.html on the apex differ from git; plus the repo MANIFEST has 24 stale entries vs its own tree and lacks the 7 `frontend/src/ui/*.mjs` paths (from the 2026-11-28 deploy record).
6. **The console is honest about its own gaps** — every unwired console surface is labelled in its own markup ("surface not wired to a provider API", disabled controls with explanatory titles). No console sidebar screen renders fixture data as real (MOCK 0, DEAD 0 in the sidebar); the 9 console gaps are all declared missing endpoints. Two shell extras ARE dead (global search, notifications drawer) and are counted separately.
7. **The tenant SPA ships with all source switches set to "live"** (`src/config.js:28-105`). Its gaps are not mock-mode accidents: they are (i) governed writes that are CREATE-only (existing-doc edits throw typed refusals), (ii) a complete absence of a governed lifecycle seam (Submit/Cancel/Amend is Desk-only everywhere), (iii) ~20 dead list-screen Export buttons, (iv) four admin/people surfaces whose live data functions throw "no documented live path", (v) unbuilt workspaces (Manufacturing / Projects / Assets landings are unlinked placeholder cards; HR and CRM have no screens at all).

## Master list — endpoints that do not exist yet (the build list)

**Provider API (console-driven):** landing-pages API · mail-templates API · site-texts API (site builder) · exchange-rates API · gateway-events read/list API (webhook receivers exist; no read surface) · manual-invoices list API for that screen (invoice creation exists via Payments) · super-admins API · database-servers API · provider health-checks API for the Health panel (only unauthenticated `/healthz` exists) · settings sub-APIs: billing-settings, lifecycle-settings, mail-settings, brand-settings · standalone plan-entity create/update API (only the pricebook `commercial/pricing-proposal` exists) · sign-in-as-owner API (tenant workspace button) · refunds/disputes read for the Dashboard revenue pane.

**Provider API (portal-driven):** `POST/GET /api/v1/customer/tickets` (ticketing) · `GET /api/v1/customer/notifications` + preferences write · `/api/v1/customer/api-keys` · customer subscription change/cancel endpoints (portal Change plan / Upgrade / Renew / Cancel buttons are all disabled; provider-side subscription lifecycle exists) · customer health/insight endpoint (ERP activity, site health, storage, installed modules widgets) · contracts/documents library endpoint · customer activity-timeline endpoint · session-preferences endpoint (security & sessions panel) · export byte-download serving (exports create/list/token are wired; the file bytes are not served yet) · forgot-password must send a reset action (currently re-runs plain login).

**External:** API-key-authenticated external invoicing API (create invoice + payment link) for products like Postqon — UD-1 phase (b).

**Tenant-side (operqon_core governed seams):** GAP-06 POS sale-completion seam (complete sale / hold / resume) · governed lifecycle seam (submit/cancel/amend) · SO→SI link-carrying server extension · governed existing-doc edit seams · Item Price governed save · Access & Branches matrix live path · General Settings live path · Period Close live path + close action · POS Device doctype contract matching the screen (or screen rebuilt on the real `Operqon POS Device` fields) · RAG Settings SPA surface · list Export wiring (~20 buttons) · Custom Report Builder surface (FR-002) · EV industry-pack surfaces (EV lane) · Manufacturing / Projects / Assets / HR / CRM screens (module lanes E-module/E8/E9 — already in the loop queue; listed here for completeness of the census).

---

## §1 — Provider console (control.operqon.cloud) — 28 rows

Tree: `/opt/operqon-private-control/provider_control/operator_console/` (`tenants.html` + `src/*.mjs`, ~10,990 lines). All API traffic goes through `src/api.mjs` (`ProviderAPI`, prefix `/api/v1/provider`, Bearer OIDC). **Endpoint-existence check: every path the console calls was matched to a live server route — zero phantom calls.**

| Feature | Module/file | API endpoint(s) called today | Status | Evidence |
|---|---|---|---|---|
| Sign-in (unauthenticated open → Keycloak redirect) | `src/session.mjs`, `src/oidc-browser.mjs`, `src/app.mjs` | `GET /auth/oidc-config.json`; Keycloak `login.rektrs.com/realms/operqon-provider` | IN-FLIGHT | Cursor fix in flight since 2026-11-28 ~14:17 PKT (owner-reported defect 1) — not a new gap |
| Session persistence across refresh | `src/oidc-browser.mjs`, `src/api.mjs` | Keycloak token endpoint | IN-FLIGHT | Cursor fix in flight since 2026-11-28 ~14:17 PKT (owner-reported defect 2) — not a new gap |
| Dashboard | `src/home.mjs`, `src/ui/dashboard.mjs` | `GET /tenant-queue`, `/identity/review-queue`, `/provisioning`, `/billing/payment-notices`, `/billing/invoices`, `/metrics/mrr`, `/subscriptions` | PARTIAL | Ops pane wired; Revenue pane "Recent refunds and disputes" is static HTML never populated ("Refund and dispute rows appear when the billing ledger exposes them"); health card is only a link |
| Tenants | `src/app.mjs`, `src/ui/tenant-actions.mjs`, `src/ui/identity-actions.mjs` | `GET /tenant-queue`, `GET /tenants/{id}`, `POST /tenants`, `POST /tenants/{id}/approve\|reject\|suspend\|suspend-approve\|reactivate\|reactivate-approve\|customer-unlink\|verify-email` | WIRED | Sub-gap: workspace "Sign in as owner" button `disabled title="No sign-in-as-owner API in this release"` (tenants.html:177) |
| Dumps | `src/backups.mjs` | `GET /ops/backups` | WIRED | Read-only by design; missing/stale exporter shown as such |
| Identity | `src/identity-panel.mjs`, `src/ui/identity-actions.mjs` | `GET /identity/review-queue`, `POST /tenants/{id}/identity-review\|verify-email\|customer-unlink` | WIRED | Queue read + attestation writes wired |
| Provisioning | `src/app.mjs`, `src/ui/provision-actions.mjs`, `job-detail.mjs`, `provision-cancel.mjs` | `GET /provisioning`, `/{id}`, `/{id}/review`; `POST /provisioning`, `/{id}/approve\|execute\|cancel\|publish\|retry\|retry-approve\|rollback-request\|rollback-approve\|review-steps\|resolve-manual-review` | WIRED | Full maker→approver→execute→publish/rollback chain, both sides |
| Subscriptions | `src/app.mjs`, `src/ui/subscription-actions.mjs` | `GET /subscriptions`, `POST /subscriptions`, `POST /subscriptions/{id}/activate-trial\|cancel\|downgrade`, `/downgrade/cancel` | WIRED | All lifecycle writes present both sides |
| Payments | `src/app.mjs`, `src/ui/bank-verify.mjs` | `GET /billing/invoices\|tenant-directory\|gateways\|payment-notices`; `POST /billing/invoices`, `/{id}/issue\|stripe-checkout\|jazzcash-checkout\|offline-approve`, `POST /billing/payment-notices/{id}/reject` | WIRED | Sub-gap: hosted checkout for gateways other than Stripe/JazzCash shows a notice only ("Awaiting merchant checkout contract and signed callback configuration" — Easypaisa/PayFast NOT_LIVE gate) |
| Manual invoices | `tenants.html` only (`#panel-manual-invoices`) — no JS module, no loader | — none — | MISSING-ENDPOINT | tenants.html:560 "No manual invoices yet — surface not wired to a provider API"; Refresh disabled. (Invoice creation exists via Payments; this screen never loads data) |
| Gateway events | `tenants.html` only (`#panel-gateway-events`) — no JS module | — none — | MISSING-ENDPOINT | "No gateway events yet — surface not wired to a provider API"; webhook receivers exist server-side but no events read/list endpoint |
| Exchange rates | `tenants.html` only (`#panel-exchange-rates`) — no JS module | — none — | MISSING-ENDPOINT | "Update rates" / "+ Add rate" disabled `title="Needs exchange-rates API"`; "Set when an exchange-rates API exists" |
| Dunning | `src/dunning.mjs` | `GET /dunning/policy\|policy/versions\|cases\|cases/{id}\|eligible`; `PUT /dunning/policy/draft`; `POST /dunning/policy/{v}/publish\|reject`, `/dunning/run`, `/cases/{id}/suppress\|unsuppress` | WIRED | Full policy-versioning + case workflow; routes in `dunning_api.py` |
| MRR | `src/mrr.mjs` | `GET /metrics/mrr`, `GET/PUT /settings/metric-definitions` | WIRED | Read + metric-definition write wired |
| Plans | `src/app.mjs`, `src/ui/deal-desk.mjs`, `pricing-decisions.mjs`, `content-chrome.mjs` | `GET/POST /commercial/pricing-proposal`, `PUT …/{id}`, `POST …/{id}/approve\|reject`; deal-desk quotes/coupons/proration; `GET/PUT /settings/deal-desk`; `GET /plans` | PARTIAL | Pricebook + deal desk fully wired, but the plan catalogue table is hard-coded static HTML (Starter/Growth/Business, "—" prices, never re-rendered) and Create/Edit-plan is dead chrome: inputs disabled "Not wired", "Save stays disabled — not a standalone plan entity API" |
| Plugins | `src/store.mjs` | `GET/POST /store/products`, `PUT /store/products/{code}`, `GET/PUT /store/plans/{plan}/products\|features`, `GET/POST /store/tenants/{id}/entitlements`, `POST …/revoke`, `GET /store/orders`, `POST /store/orders/{id}/approve\|reject`, `GET /store/audit` | WIRED | Catalogue, plan inclusions, tenant grants/revokes, order approval, audit — all wired |
| Landing pages | `tenants.html` (`#panel-landing-pages`), `src/ui/content-chrome.mjs` (stage toggle only) | — none — | MISSING-ENDPOINT | "Fields are not persisted — no landing-pages API in this release"; Save disabled; list body "create opens form chrome only (no API)" |
| Mail templates | `tenants.html` (`#panel-mail-templates`), `src/ui/content-chrome.mjs` | — none — | MISSING-ENDPOINT | 10 hard-coded static rows; edit form disabled "Not wired"; "Subject and body are not persisted — no mail-templates API in this release" |
| Site builder | `tenants.html` (`#panel-site-builder`), `src/ui/content-chrome.mjs` | — none — | MISSING-ENDPOINT | Every field `<input disabled placeholder="Not wired">`; "Values are not persisted until a site-texts API exists"; preview is a "Structure slot only" placeholder |
| Super admins | `tenants.html` only (`#panel-super-admins`) — no JS module | — none — | MISSING-ENDPOINT | "No super admins listed — surface not wired to a provider API"; "+ New admin" disabled `title="Needs super-admins API"` |
| Database servers | `tenants.html` only (`#panel-database-servers`) — no JS module | — none — | MISSING-ENDPOINT | "No database servers listed — surface not wired to a provider API"; "+ Add server" disabled `title="Needs database-servers API"` |
| Health | `tenants.html` only (`#panel-health`) — no JS module, not in PANEL_REFRESH | — none — | MISSING-ENDPOINT | All 7 check rows hard-coded "Unknown" badges; "Status pills bind to live probes when a health API is wired" |
| Settings | `src/settings.mjs` (gateway pane) + static panes in `tenants.html` | Gateway pane: `GET/PUT /settings/gateways…`, `POST …/test`, `GET/PUT /settings/bank-transfer`, `GET/PUT /settings/notifications`, `POST /settings/notifications/test`, `GET/PUT /settings/metric-definitions` | PARTIAL | Gateway pane fully wired; 4 of 5 sub-panes are disabled chrome: Billing ("No billing-settings API in this release"), Lifecycle ("No lifecycle-settings API"), Mail ("No mail-settings API"), Brand ("No Brand settings API yet") — all inputs/Save disabled "Not wired" |
| Issues | `src/issues.mjs` | `GET /issues`, `GET /me`, `POST /issues/{cls}/{type}/{id}/acknowledge\|resolve\|reopen`, `POST /incidents` | WIRED | Triage writes wired; strict envelope validation |
| Incidents | `src/incidents.mjs` | `GET /incidents`, `/incidents/escalation-queue`, `POST /incidents`, `/{id}/acknowledge\|mitigate\|resolve\|close\|reopen` | WIRED | All routes in `incidents_api.py` |
| Alert rules | `src/alert-rules.mjs` | `GET/POST /alert-rules`, `PATCH/DELETE /alert-rules/{id}`, `GET /alert-rules/preview`, `POST /alert-rules/evaluate` | WIRED | Full CRUD + preview/evaluate (evaluate records intents only — no send is faked) |
| Audit | `src/audit-panel.mjs` | `GET /audit?limit=100`, `GET /audit/integrity` | WIRED | Read-only by nature; both reads wired |
| Support | `src/ui/support-panel.mjs` | `GET /support-sessions`, `POST /support-sessions`, `POST /support-sessions/{id}/close\|withdraw`, `GET /support-sessions/{id}/tenant-overview` | WIRED | Request/end/overview wired; actions match `support_api.py` routes exactly |

**Shell extras (not sidebar items, not in the counts):** topbar **global search is DEAD** — `id="global-search"` exists in tenants.html but `grep "global-search" src/` returns zero hits (no handler at all). **Notifications drawer is static** — only ever shows "No notifications / Please check again later"; the toggle opens/closes it but no notifications API is called. Promo banner "View plans →" is wired.

## §2 — Customer portal (operqon.cloud/customer/) — 28 rows

Trees: apex = git for all files except the 5 git-gap files in §5; the non-git VPS working copy `/opt/operqon-provider-r2/frontend/customer/` is identical to the apex (excluding runtime `config.js` and `*.bak-*`).

| Feature | File(s) | API endpoint(s) called today | Status | Evidence |
|---|---|---|---|---|
| Sign-in | `index.html`, `assets/auth.js` | `GET {issuer}/protocol/openid-connect/auth` (PKCE S256), `GET /api/v1/customer/session` | WIRED | `#signin` → `begin('login')`; session state routes onward |
| Create account / signup | `index.html`, `assets/auth.js` | OIDC auth URL with `kc_action=register` | WIRED | `#signup` → `begin('register')`; auto-fires on `?signup=1` |
| Forgot password | `index.html`, `assets/auth.js` | — (re-runs plain login) | PARTIAL | `#forgot` handler is only `begin('login')` — no reset action is ever sent |
| OIDC callback / token exchange | `callback.html`, `assets/auth.js` | `POST {issuer}/protocol/openid-connect/token`, `GET /api/v1/customer/session` | WIRED | State validated; tokens in sessionStorage; error states render exits |
| Email verification | `verify.html`, `assets/verify.js`, `assets/auth.js` | `POST /api/v1/customer/resend-verification` | WIRED | 202/200/429/502 handled explicitly |
| Complete-signup | `complete-signup.html`, `assets/complete-signup.js`, `assets/money.js` | `GET /api/v1/public/plans?country_code=`, `POST /api/v1/customer/signup`, `GET /api/v1/customer/session` | WIRED | Real form; submit disabled until plans load; email from verified id_token claim |
| Dashboard / home | `dashboard.html`, `assets/dashboard.js` | `GET /api/v1/customer/dashboard`, `GET /api/v1/customer/invoices` | WIRED | Company, plan, seats, trial, stage, outstanding/next-charge from payload |
| Onboarding status | `dashboard.html`, `assets/dashboard.js` | `GET /api/v1/customer/dashboard`, `GET /api/v1/customer/sites`, `POST /api/v1/customer/provisioning/retry` | WIRED | 5-step progress from `status.stage`; manager-only confirmed retry |
| SSO handoff to ERP workspace | `assets/dashboard.js` | `GET /api/v1/customer/dashboard` / `…/sites` (`site.url`, `sso_configured`) | WIRED | "Open ERP" navigates to the site's own "Log in with Operqon"; no portal-side token exchange |
| Home/ERP insight widgets (ERP activity, Site health, Storage, Installed modules) | `dashboard.html` (`.mock-widget` cards) | None | MOCK | Hardcoded "99.9%", "4.2 GB", module list; copy admits "Sample data… not exposed to the portal yet" / "No customer health endpoint exists yet" |
| Plans list (Subscription page) | `dashboard.html`, `assets/dashboard.js` | `GET /api/v1/customer/plans` | WIRED | Real plan cards; billing-cycle toggle is local re-paint only |
| Subscription start (self-service) | `assets/dashboard.js` | `GET /api/v1/customer/subscription-offer`, `POST /api/v1/customer/subscription-start` | WIRED | Renders only in the eligible state; ineligible states show reason, no button |
| Subscription management (Change plan / Upgrade / Renew / Cancel) | `dashboard.html`, `assets/dashboard.js` | None | DEAD | All four buttons + plan-card CTA `disabled` — "Coming soon — plan changes are operator-assisted today" |
| Plans & Store / purchase flow | `dashboard.html` (`#/store`), `assets/dashboard.js` | `GET /api/v1/customer/store/products`, `GET/POST /api/v1/customer/store/orders`, `POST …/orders/{id}/payment-notice`, `POST …/orders/{id}/cancel` | WIRED | Full bank-transfer order lifecycle incl. cancel in both states |
| Billing & invoices | `dashboard.html` (`#/billing`, `#/invoice/{id}`), `assets/dashboard.js` | `GET /api/v1/customer/invoices`, `…/invoices/{id}/pdf`, `GET /api/v1/customer/statements/pdf`, `POST /api/v1/customer/payment-notices`, invoice `checkout_url` | WIRED | Four-quadrant billing home, invoice detail, PDF + statement downloads, offline payment-notice form |
| Team / users + company switcher | `dashboard.html` (`#/team`), `assets/dashboard.js`, `tenant-switcher.js` | `GET /api/v1/customer/team`, `GET/POST /api/v1/customer/memberships`, `POST …/memberships/accept`, `POST …/memberships/{id}/status`, `POST /api/v1/customer/scope` | WIRED | Roster + invite (manager-only), accept, status changes, scoped switcher |
| Support access (consent) | `dashboard.html` (`#/support`), `assets/dashboard.js` | `GET /api/v1/customer/support-sessions`, `POST …/{id}/consent\|deny\|revoke` | WIRED | All behind confirm modals naming capabilities/expiry |
| Support ticketing ("Raise a ticket") | `dashboard.html` (`#/support`) | None — needs e.g. `POST/GET /api/v1/customer/tickets` | MISSING-ENDPOINT | Disabled form + 2 sample tickets; "Coming soon — customer ticketing is not available yet" |
| Notifications + preferences | `dashboard.html` (`#/notifications`) | None — needs e.g. `GET /api/v1/customer/notifications` + preferences write | MISSING-ENDPOINT | Sample notifications, disabled toggles; "no customer notification endpoint exists yet, so these controls are inert" |
| Documents — data exports | `dashboard.html` (`#/documents`), `assets/dashboard.js` | `POST/GET /api/v1/customer/exports`, `POST …/exports/{id}/download-token`, `POST …/exports/{id}/download` | PARTIAL | Create/list/token wired; byte download falls back to a descriptor record — "File download is not available on this server yet" |
| Documents — document library / contracts | `dashboard.html` (`#/documents`) | None | MOCK | "Sample: Master services agreement (PDF)", "Sample: Data processing addendum (PDF)"; "contracts are not served to the portal yet" |
| Integrations (Easypaisa, PayFast, FBR, ZATCA) | `dashboard.html` (`#/integrations`) | None | DEAD | Four `.mock-widget` cards, every "Connect …" button disabled, "Coming soon — merchant inputs pending" (tenant-credential integrations per the service-provider principle) |
| Activity timeline | `dashboard.html` (`#/activity`) | None | MOCK | Sample entries; banner admits "No live customer timeline exists yet" |
| Settings — company profile summary | `dashboard.html` (`#/settings`), `assets/dashboard.js` | `GET /api/v1/customer/dashboard` (+ memberships for role) | PARTIAL | Real read-only summary; no save path |
| Settings — organisation / billing contact | `dashboard.html`, `assets/dashboard.js` | `GET /api/v1/customer/billing-contact`, `PUT /api/v1/customer/billing-contact` | WIRED | JS replaces the shipped disabled mock panel with a real form; save manager-only |
| Settings — security & sessions | `dashboard.html` (`#/settings`) | None | MOCK | One disabled pre-checked toggle; "Sample controls — session preferences are not editable from the portal yet" |
| Settings — API keys | `dashboard.html` (`#/settings`) | None — needs e.g. `/api/v1/customer/api-keys` | MISSING-ENDPOINT | Disabled "Create API key"; "Key management will live here when the customer API ships" |
| Help / FAQ | `dashboard.html` (`#/help`) | None (none required) | WIRED | Static explanations/FAQ shipped in HTML |

---

## §3 — Tenant SPA — 84 rows

Tree: `~/workspace/operqon-dreams/e2/frontend/` — `src/app.js` (router + render/wiring, 17,605 lines) + per-domain data modules + `api-client.js` (central `api()`; "Every screen goes through here; no fetch() elsewhere") + paired `*-fixtures.js`. All source switches ship as `"live"` (`src/config.js:28-105`). Call types: `listDocs` = raw Frappe REST `/api/resource/<DocType>`; `callMethod` = `/api/method/…`; governed seams `callWrite/callReceipt/callSourcing/callMasters/callCount/callQuality/callReservation/callSubcontracting/callRefund` → `operqon_core.api.*`.

**Cross-cutting patterns (apply to many rows):** (i) governed writes are mostly CREATE-only — editing an existing live doc throws a typed refusal; (ii) NO governed lifecycle seam exists anywhere — Submit/Cancel/Amend of submitted docs is Desk-only (`app.js:9809`, `app.js:10167-10170`); (iii) ~20 list-screen Export buttons are plain `<button class="btn-ghost">Export</button>` with no handler (only Accounts *report* screens have wired `data-export-csv`).

| Screen / Feature | Source file(s) | Endpoint(s) / call type today | Status | Evidence |
|---|---|---|---|---|
| Home / Dashboard `#/` | app.js `renderHome`; api-client `getHomeSummary` | Governed `operqon_core.api.home.get_home_summary` | WIRED | Live branch unwraps method envelope; fixture only if source flipped |
| Login / SSO landing `#/login`, `#/auth/callback` | app.js; auth.js; config.js | Live: POST `operqon_core.api.session.get_session_bridge` (site cookie); stub: PKCE `buildAuthorizeUrl` | PARTIAL | config.js authorizeUrl/clientId/redirectUri are literal `*.operqon.example` PLACEHOLDERs — no SPA-side IdP round-trip; sign-in must start at site `/login?redirect-to=/operqon` |
| First-run / setup checklist (Home card) | admin.js; app.js | Governed `operqon_core.firstrun.api.get_first_run_state / dismiss_first_run / reopen_checklist` | WIRED | Server payload mapped to SPA routes; the only "setup wizard" surface in the tree |
| Guided tour (NF-1) | tour.js; admin.js; app.js | Governed `firstrun.api.get_tour_state/mark_tour_step/complete_tour/dismiss_tour/reopen_tour` | PARTIAL | Auto-starts on EVERY `renderHome()` when `state.show`; X-close persists nothing (tour.js) — FR-003 fix queued |
| RAG / Knowledge Search `#/rag` | rag.js; app.js `renderRag` | Governed `operqon_rag.api.search` + `get_status` | WIRED | Retrieval-only by design (`generated_answer: null`, cited passages) |
| RAG Settings `#/admin/rag-settings` | — (no segment) | None | DEAD | Not in `ADMIN_SEGMENTS` → SPA's own 404; rag.js:62 directs users to "RAG Settings" (Desk only) |
| Quotations `#/sales/quotations` | sales.js; app.js | Raw REST on Quotation; Declare Lost + Create SO wired | PARTIAL | sales.js header: Quotations/SO/DN "keep their REST save" — not governed writes |
| Sales Orders `#/sales/sales-orders` | sales.js; app.js | Raw REST on Sales Order; Create Delivery Note only | PARTIAL | SO→SI deliberately NOT offered (app.js:1860-1863): governed `save_sales_invoice` drops the sales_order link — hidden until the server method carries the link |
| Sales Invoices `#/sales/sales-invoices` | sales.js | Governed GAP-12 reads `operqon_core.api.sales.get_sales_invoices/…`; governed write `save_sales_invoice` (create+submit) | WIRED | Create path fully governed; existing-doc edit refused by design (pattern i) |
| Delivery Notes `#/sales/delivery-notes` | sales.js; app.js | Raw REST on Delivery Note | PARTIAL | Same REST-save class as Quotations/SO |
| Sales Returns `#/sales/sales-returns` | sales.js | Governed GAP-12 read; `save_sales_return`; `operqon_core.api.refunds` | WIRED | Refund renders only on live submitted credit note with negative outstanding |
| Customers `#/sales/customers` | sales.js | REST list; governed `save_customer` | PARTIAL | Router blocks the edit form: customers carries CREATE route only, `parts[1]!=="new"` → 404 |
| Purchase Orders `#/buying/purchase-orders` | buying.js | Governed GAP-13 reads; `save_purchase_order` | WIRED | Governed read+create/submit |
| Purchase Receipts `#/buying/purchase-receipts` | buying.js | Governed form read; writes via `buying_receipts.save_purchase_receipt/save_purchase_return` | PARTIAL | Receipts LIST stays on raw-REST read (drafts visible there), unlike governed lists elsewhere |
| Purchase Invoices `#/buying/purchase-invoices` | buying.js | Governed GAP-13 reads; `save_purchase_invoice`; debit note via `save_purchase_debit_note` | WIRED | Governed read+create |
| Suppliers `#/buying/suppliers` | buying.js | Governed GAP-13 reads; `save_supplier` | WIRED | Depth fields + contact/address governed saves |
| Vendors `#/buying/vendors` | buying.js | Same governed Supplier read/form | PARTIAL | Deliberate dedup alias of Suppliers, not a separate master |
| Supplier Groups `#/buying/supplier-groups` | buying.js | Governed `buying.get_supplier_groups`; `save_supplier_group` | WIRED | Tree read + governed create |
| Supplier Scorecards `#/buying/supplier-scorecards` | buying.js | Governed reads; `save_supplier_scorecard/evaluate_supplier_scorecard` | WIRED | Evaluate runs server-side scoring |
| Scorecard Periods `#/buying/supplier-scorecard-periods` | buying.js | Governed `buying.get_supplier_scorecard_periods` | WIRED | Read-only by design (periods created by Evaluate) |
| RFQ `#/buying/request-for-quotations` (+comparison) | buying.js | Governed GAP-13 reads + comparison; `save_request_for_quotation/send_request_for_quotation` | WIRED | Send + comparison both governed |
| Supplier Quotations `#/buying/supplier-quotations` | buying.js | Governed GAP-13 reads; `save_supplier_quotation`; governed Create-PO | WIRED | SQ→PO governed path present (unlike SO→SI) |
| Material Requests `#/buying/material-requests` | buying.js | Governed GAP-13 reads; `save/stop/unstop_material_request`; `create_stock_entry_from_material_request` | WIRED | Stop/Unstop governed |
| Procurement Dashboard `#/buying/dashboard` | buying.js | Governed `buying.get_procurement_dashboard` | WIRED | Aggregate envelope, read-only by design |
| Procurement Analytics `#/buying/analytics` | buying.js | Governed `buying.get_procurement_analytics` | WIRED | Standing from live evaluated periods only |
| Products / Items `#/stock/products` | stock.js | REST list/get Item; governed `save_item` | PARTIAL | Item Prices block read-only ("the governed price save is a later lane", app.js:6118); Variants block read-only |
| Stock Balance `#/stock/stock-balance` | stock.js | Governed GAP-02 `operqon_core.api.stock.get_stock_balance` | WIRED | No client-side Bin aggregation in live mode |
| Stock Adjustments `#/stock/stock-adjustments` | stock.js | REST list; governed `save_stock_entry` (10 purposes) | WIRED | Governed create; existing-doc edit refused (pattern i) |
| Stock Transfers `#/stock/stock-transfers` | stock.js | Same `save_stock_entry` path | WIRED | As Adjustments |
| Stock Reconciliations `#/stock/stock-reconciliations` | stock.js | Governed `stock.get_reconciliation_items`; `stock_count.save_stock_reconciliation` | WIRED | Own governed seam, never raw REST |
| Categories / Item Group `#/stock/categories` | stock.js | Raw REST POST/PUT on Item Group | PARTIAL | Generic master path — raw REST, not governed write |
| Brands `#/stock/brands` | stock.js | Raw REST on Brand | PARTIAL | Same generic master REST path |
| Units / UOM `#/stock/units` | stock.js | Raw REST on UOM | PARTIAL | Same generic master REST path |
| Variants `#/stock/variants` | stock.js | Raw REST GET Item Attribute (+1 GET per attribute) | PARTIAL | Panel kind; in STOCK_READONLY_SCREENS; no form route, no write |
| Low Stock `#/stock/low-stock` | stock.js | Derived from governed Stock Balance | WIRED | Read-only by design |
| Warehouses `#/stock/warehouses` | stock.js | REST list; governed `save_warehouse` | WIRED | Governed save enforced ("generic master path must never carry a warehouse save") |
| Subcontracting Orders `#/stock/subcontracting-orders` | subcontracting.js | Governed reads + pickers; `save_subcontracting_order` | PARTIAL | Picker-only creation; submitted = view-only, no Cancel/Amend seam (pattern ii) |
| Subcontracting Receipts `#/stock/subcontracting-receipts` | subcontracting.js | Governed reads; `save_subcontracting_receipt/create_subcontracting_return` | PARTIAL | Same lifecycle limitation |
| Subcontracting Inward Orders `#/stock/subcontracting-inward-orders` | subcontracting.js | Governed reads + settings; `save_subcontracting_inward_order` | PARTIAL | Same lifecycle limitation |
| Quality Inspections `#/quality/quality-inspections` | quality.js | Governed reads; `stock_quality.save_quality_inspection` | WIRED | Governed reads + save (E6 lane 5) |
| QI Templates `#/quality/templates` | quality.js | Governed reads; `save_quality_inspection_template` | WIRED | Template-driven form fill wired |
| QI Parameters `#/quality/parameters` | quality.js | Governed reads; `save_quality_inspection_parameter` | WIRED | Governed read+save |
| Landed Cost Vouchers `#/quality/landed-cost-vouchers` | quality.js | Governed reads; `save_landed_cost_voucher` | WIRED | Governed read+save |
| Reservations `#/trace/reservations` | trace.js | Governed reads + availability; `save_stock_reservation_entry` | WIRED | Availability check wired into form |
| Batches `#/trace/batches` | trace.js | Governed reads; `save_batch` | WIRED | Governed read+save |
| Serial Nos `#/trace/serials` | trace.js | Governed reads; `save_serial_no` | WIRED | Governed read+save |
| Bundles `#/trace/bundles` | trace.js | Governed `stock.get_serial_and_batch_bundles/…` | WIRED | Read-only by design |
| Trace detail `#/trace/trace/<item>` | trace.js | Governed `operqon_core.api.stock_trace.get_stock_trace` | WIRED | From Stock Balance Trace column; read-only |
| Payments `#/accounts/payments` | accounts.js | REST list + governed pickers; `save_payment_entry` | WIRED | Governed create with outstanding-reference picker (E7 lane 1) |
| Journal Entries `#/accounts/journal-entries` | accounts.js | REST list/get + governed helpers; `save_journal_entry/create_inter_company_journal_entry/reverse_journal_entry` | WIRED | Template apply + reverse + inter-company wired |
| Modes of Payment `#/accounts/modes-of-payment` | accounts.js | Governed reads; `save_mode_of_payment` | WIRED | Governed master read+create |
| Tax masters (6) `#/accounts/tax-*` etc. | accounts.js | REST lists + governed reads; CREATE-only governed saves (TAX_MASTER_SAVES) | WIRED | E7 lane 3: six tax masters save through their own governed methods (create-only) |
| Tax Register `#/accounts/tax-registers` | accounts.js | Governed `accounts.get_tax_register` | WIRED | Read-only report |
| Chart of Accounts `#/accounts/chart-of-accounts` | accounts.js | Governed `accounts.get_chart_of_accounts`; create via `save_account` | PARTIAL | Read fully governed; existing-account edit is create-only (pattern i) |
| General Ledger `#/accounts/general-ledger` | accounts.js | Governed GAP-03 `accounts.get_general_ledger` + CSV export | WIRED | Desk query_report path bench-proven BLOCKED — this method is THE path |
| Trial Balance `#/accounts/trial-balance` | accounts.js | Governed GAP-14 `accounts.get_trial_balance` + CSV | WIRED | — |
| Balance Sheet `#/accounts/balance-sheet` | accounts.js | Governed GAP-14 `accounts.get_balance_sheet` + CSV | WIRED | — |
| Profit & Loss `#/accounts/profit-and-loss` | accounts.js | Governed `accounts.get_profit_and_loss` + CSV | WIRED | Pure GL builder |
| Cash Flow `#/accounts/cash-flow` | accounts.js | Governed `accounts.get_cash_flow` + CSV | WIRED | Indirect method |
| Receivable Aging `#/accounts/receivable-aging` | accounts.js | Governed GAP-04 `accounts.get_aging` (Customer) + CSV | WIRED | Bench-proven buckets |
| Payable Aging `#/accounts/payable-aging` | accounts.js | Governed `get_aging` (Supplier) | WIRED | SPA-only reuse of the same method |
| Invoice Print `#/accounts/invoice-print` | accounts.js | REST GET Sales Invoice; PDF via governed GAP-05 `operqon_core.api.print.get_invoice_pdf` | WIRED | Live action downloads server PDF |
| Budgets `#/accounts/budgets` | accounts.js | Governed `get_budgets/get_budget/get_budget_variance`; `save_budget` | WIRED | E7 lane 6 |
| Exchange Rate Revaluations `#/accounts/exchange-rate-revaluation` | accounts.js | Governed reads + preview; `save_exchange_rate_revaluation/create_revaluation_journals/reverse_revaluation_journals` | WIRED | JE creation is an explicit post-submit action by design |
| JE Templates `#/accounts/journal-entry-templates` | accounts.js | Governed reads; `save_journal_entry_template` | WIRED | Template picker applies rows the Desk way (E7 lane 8) |
| People: Users `#/people/users` | admin.js | **Raw REST** GET/POST/PUT `/api/resource/User` | PARTIAL | Roles child stripped for tenant personae (rows carry `roles: []` + note); no governed user write |
| People: Access & Branches `#/people/access-branches` | admin.js | Branches: REST Cost Center; Matrix: **none** | MISSING-ENDPOINT | Live branch throws `noLivePath("the Access & Branches matrix")` (admin.js:242) — screen errors in live mode |
| People: Employees `#/people/employees` | admin.js | Raw REST `listDocs Employee` (readonly) | PARTIAL | List only — no form route, no HR write |
| Admin: Company Settings `#/admin/company-settings` | admin.js | **Raw REST** GET/PUT `/api/resource/Company/<name>` | PARTIAL | Works live but raw REST, not governed; NTN validation client-side only |
| Admin: General Settings `#/admin/general-settings` | admin.js | None | MISSING-ENDPOINT | get and save both throw `noLivePath("General Settings")` (admin.js:382,386) |
| Admin: POS Devices `#/admin/pos-devices` | admin.js | **None — fixture store in BOTH modes** | MOCK | "FIXTURE-GATED BY DESIGN… getters serve the fixture store regardless of adminSource"; real `Operqon POS Device` fields (device_id/pos_profile/pairing_code_hash) don't match the screen contract (device_name/terminal_id/last_sync) — live query would 417 |
| Admin: Period Close `#/admin/period-close` | admin.js | None | MISSING-ENDPOINT | Live throws `noLivePath("the Period Close checklist")` (admin.js:427); Close enablement is a pure fixture-checklist function; no close action wired |
| POS main `#/pos` | pos.js; app.js | Governed read-only GAP-15 `operqon_core.api.pos.get_pos_catalogue/get_pos_customers` | PARTIAL | **Cannot complete a sale:** `completeSale/holdCart/getPosSales` call `assertFixtureMode()` which throws live — "Desk POS remains the register of record until GAP-06 closes" |
| POS Held Orders `#/pos/held` | pos.js | None live | MISSING-ENDPOINT | All three functions throw the GAP-06 no-live-path error; held carts exist only in the in-memory fixture store |
| Manufacturing `#/manufacturing` | app.js S9 landing only — no data module | None | DEAD | Landing cards (Work Order/Job Card/BOM) are unlinked divs — "its screen builds in a later slice"; any `#/manufacturing/*` → SPA 404 |
| Projects `#/projects` | app.js S9 landing only | None | DEAD | Project/Task/Timesheet cards unlinked; sub-paths 404 |
| Assets `#/assets` | app.js S9 landing only | None | DEAD | Asset/Asset Category cards unlinked; sub-paths 404 |
| Quality Goal (on `#/quality` landing) | app.js S9 landing | None | DEAD | Card unlinked; no segment in QUALITY_SEGMENTS |
| HR (beyond Employees list) | — | None | MISSING-ENDPOINT | No HR module/file/segment at all: no Leave, Attendance, Payroll, Expense, Recruitment screens |
| CRM | — | None | MISSING-ENDPOINT | No Lead/Opportunity/CRM screen, segment or data module anywhere |
| Custom / ad-hoc Reports | — | None | MISSING-ENDPOINT | No custom-report / Report Builder / query-report surface (FR-002); only the fixed governed reports above |
| EV industry pack surfaces | — | None | MISSING-ENDPOINT | Zero EV/industry-pack hits in the frontend tree; no EV screen or wizard step (EV lane scope) |

**Navigation entries leading to unbuilt/404 surfaces (SPA):** `#/admin/rag-settings` (404, yet rag.js directs users there) · `#/manufacturing/*`, `#/projects/*`, `#/assets/*` (explicit 404 branch) · `#/sales/customers/<name>` edit shape (404) · `#/pos/<anything except held>`, `#/rag/<anything>`, `#/quality/<quality-goal>` (404) · Manufacturing/Projects/Assets landing cards (unlinked divs) · Quality Goal card (unlinked) · Sales nav "POS" entry is a placeholder span ("Desk route · GAP-06") · Admin Settings nav "Notifications" and "Security" chips are placeholders ("Not built in S7") · General Settings / Period Close / Access & Branches route and render in fixture mode but throw "no documented live path" in the shipped live mode · POS Devices always renders the fixture registry.

**Known-items verification (all confirmed in-tree):** no Manufacturing screens ✅ · SPA POS cannot complete a sale, Desk POS is register of record ✅ (`assertFixtureMode`) · `#/admin/rag-settings` → SPA 404 ✅ · guided tour re-auto-starts, X-close persists nothing ✅ (FR-003) · no mobile menu — below 720px `.sidebar{display:none}` with no replacement nav ✅ (FR-004) · SO→SI button hidden because the governed write drops the SO link ✅ (app.js:1860-1863).

---

## §4 — Provider API inventory (summary)

Full enumeration: 198 route decorators in `releases/operqon-provider-r2/app/` @ ref `e356f275` (`main.py` + 12 router modules: alert_rules, dealdesk, dunning, incidents, membership, mrr, ops, payment_links, settings, store, storefront, support). Namespaces:

- **Public:** `GET /healthz`, `/readyz`, `GET /api/v1/public/plans`.
- **Customer** (`/api/v1/customer`): session, resend-verification, signup (201), dashboard, invoices (list, PDF), statements PDF, payment-notices (202), plans, subscription-offer, subscription-start (201), trial-start (201), team, provisioning/retry, sites, billing-contact (GET/PUT), memberships (+accept, status, scope), store (products, orders + payment-notice/cancel, my-apps), support-sessions (+consent/deny/revoke), attachments, exports (create/list/download-token/download).
- **Provider** (`/api/v1/provider`): me, tenant-queue, tenants CRUD + lifecycle (verify-email, identity-review, customer-unlink, approve/reject, suspend/reactivate + approvals), identity/review-queue, plans, subscriptions (+activate-trial, cancel, downgrade), provisioning jobs (full review/approve/execute/publish/rollback/retry chain), issues (+acknowledge/resolve/reopen), audit (+integrity), commercial pricing-proposals + deal-desk (quotes, coupons, proration, settings), billing (tenant-directory, invoices create/list, issue, stripe-checkout, jazzcash-checkout, offline-approve, webhooks stripe/jazzcash, gateways, payment-notices + reject, payment-links + Easypaisa/PayFast webhooks), alert-rules CRUD + preview/evaluate, dunning (policy versions, cases, run), incidents (+escalation-queue, lifecycle), metrics/mrr + metric-definitions, ops/backups, settings (gateways + test, bank-transfer, notifications + test, deal-desk), store (products, plan products/features, tenant entitlements, orders, audit), support-sessions (+tenant-overview/invoices).
- **Internal provisioner** (`/internal/v1/provisioner`): publish-pending, publish-site, claim, heartbeat, complete, fail, diagnose, roster-pending, roster-update, support-deliveries, support-delivery-report.

**Invoicing shape (the UD-1 fact):** invoice creation/issue/checkout exists ONLY under the provider namespace behind a provider principal; the customer namespace is read-only for invoices. There is no public, API-key, or third-party-client invoicing endpoint anywhere in the app — nothing an external product (e.g. Postqon) could call. The missing build is an API-key-authenticated external invoicing surface (create invoice + payment link), precedent: the Sendqon-connector pattern.

**Gated, not missing:** Easypaisa/PayFast payment-link webhooks are NOT_LIVE while `merchant_live_verified` is false — live settlement stays owner-gated (merchant verification is the owner's step, unchanged by this lane).

## §5 — Repo git gap (curation items, from the portal census + the 2026-11-28 deploy record)

Live apex bytes that are NOT in git (repo copy = `/opt/operqon-r2-github/releases/operqon-provider-r2/frontend/customer/`; the same hotfix content exists in the non-git VPS working copy `/opt/operqon-provider-r2/frontend/customer/`, identical to apex):

| File | Apex (live) | Git | Δ / nature |
|---|---|---|---|
| `assets/auth.js` | 7,189 B — sha256 `c1b2ddb1…` | 7,118 B — sha256 `b0ff8be3…` | localStorage/PKCE hotfix: PKCE verifier + state in localStorage (repo: sessionStorage), logout also removes both localStorage keys |
| `assets/complete-signup.js` | 6,619 B — sha256 `add19d4b…` | 6,556 B — sha256 `22912713…` | one added line: prefill company from id_token claim (`if (claims.company) companyInput.value = claims.company;`) |
| `assets/customer.css` | 26,906 B — sha256 `ccf30e03…` | 25,977 B — sha256 `0830aeb3…` | adds the OS-67 `.locked-card` pattern |
| `dashboard.html` | 104,193 B — sha256 `5e557c32…` | 104,150 B — sha256 `f253f046…` | +43 B uncommitted change |
| `callback.html` | 943 B — sha256 `17b1fd46…` | 1,188 B — sha256 `b1bb050b…` | apex is the 2026-11-26 "blank OIDC callback" owner-order variant (smaller) |

Proof of in-place editing: the apex `.bak-2026-11-27-flow29-pre` files are byte-identical to the git versions. All other portal JS/CSS/HTML files are hash-identical between apex and git (incl. `dashboard.js`, 114,239 B). Runtime-only: apex `config.js` (268 B, issuer `https://login.rektrs.com/realms/operqon-customers`) exists only at the apex; git ships only `config.js.example` (issuer still the old `login.operqon.cloud`).

**MANIFEST (from the 2026-11-28 OS-89 deploy record):** the release branch's MANIFEST has 24 entries that mismatch its own tip tree (incl. app.mjs / tenants.html / console.css) and lacks the 7 `frontend/src/ui/*.mjs` paths entirely (content-chrome, dashboard, filter-bar, nav-drawer, panel-filters, workspace-chrome, workspace-domains-dumps) — the manifest-exact deploy had to install them separately. Curation = commit the 5 live files' bytes, regenerate the MANIFEST from the tree incl. the 7 ui modules, and fix `config.js.example`'s issuer.

## §6 — Wiring plan (who does what)

### 6A — Cursor assignment (provider API + console + portal) — sent 2026-11-28 via the Cursor-monitoring chat

One consolidated assignment covering:
1. **Console missing endpoints + wiring (9):** manual-invoices list, gateway-events read, exchange-rates, landing-pages, mail-templates, site-texts (site builder), super-admins, database-servers, provider health-checks — build each endpoint and wire its panel (no panel may stay on its "not wired" placeholder).
2. **Console partials (3 + 2 shell + 2 sub-gaps):** Dashboard refunds/disputes read from the billing ledger; Plans — standalone plan-entity API + catalogue rendered from API + working Create/Edit; Settings — billing/lifecycle/mail/brand settings APIs + wired panes; global search handler; notifications drawer wired to a real notifications read; tenant workspace sign-in-as-owner API + button.
3. **Portal endpoints to build (3):** customer tickets, customer notifications + preferences, customer API keys.
4. **Portal wiring (7):** subscription management (Change plan/Upgrade/Renew/Cancel) against customer subscription endpoints (build the customer-side change/cancel endpoints on the existing provider subscription lifecycle); insight widgets against a new customer health/insight endpoint (real ERP activity, site health, storage, installed modules); contracts/document library endpoint + wiring; activity timeline endpoint + wiring; security/session preferences endpoint + wiring; exports byte-download serving; forgot-password reset action.
5. **Portal integrations page:** Easypaisa/PayFast/FBR/ZATCA cards are tenant-credential integrations (service-provider principle) — wire the Connect flow to real per-tenant credential storage/endpoints where the integration exists; where the integration itself is owner-gated (merchant-live), the card must say exactly that instead of a generic "Coming soon".
6. **External invoicing API (the UD-1 phase (b) build):** API-key-authenticated external invoicing surface — create invoice + payment link for an external product (Postqon first consumer), Sendqon-connector pattern for credentials. This replaces the "decision" the item waited on: the endpoint is the work.
7. **Repo curation (§5):** commit the 5 live portal files' bytes to the release branch; regenerate the MANIFEST from the tree including the 7 `frontend/src/ui/*.mjs` paths and clear the 24 stale entries; fix `config.js.example` issuer to login.rektrs.com.
8. **Explicitly separate:** the in-flight console auth fixes (direct-to-Keycloak sign-in + refresh session persistence, with Cursor since ~14:17 PKT today) are NOT part of this assignment — do not duplicate or collide with them.

Acceptance per item (binding): fresh-browser proof — the surface loads real API data and an action on it persists across refresh. No mock/fixture data on any live surface.

### 6B — Loop queue (tenant SPA + operqon_core governed seams) — recorded in LOOP-STATE, in order

These run as normal loop lanes (branch → gate → security pass → PR → merge → ocXX train with full pairing rules) in the loop's rotation, after the currently-gated EV-1 close (the loop's standing sequencing is unchanged; this queue slots into the NF/feature rotation):

- **W-T1 — POS sale completion (GAP-06):** governed POS seam in operqon_core (complete sale, hold cart, resume/list held) + SPA wiring of `#/pos` and `#/pos/held`. Desk POS stops being the register of record only when this lane's acceptance passes.
- **W-T2 — Governed lifecycle seam:** submit/cancel/amend for submitted docs, applied first to Sales/Buying/Stock docs that today are Desk-only for lifecycle.
- **W-T3 — SO→SI server extension:** `save_sales_invoice` carries the sales_order/so_detail link; unhide the SO → Sales Invoice action.
- **W-T4 — Admin live paths:** General Settings settings doctype + governed get/save; Period Close checklist read + real close action; Access & Branches matrix live read.
- **W-T5 — POS Devices:** reconcile the screen contract with the real `Operqon POS Device` doctype (or rebuild the screen on the real fields) and wire it live — fixture store removed.
- **W-T6 — RAG Settings SPA surface:** add the `rag-settings` admin segment + settings screen wired to operqon_rag settings (kills the `#/admin/rag-settings` 404 that rag.js points users to).
- **W-T7 — List Export wiring:** give every list screen the wired `data-export-csv` treatment the Accounts reports already have (~20 dead buttons).
- **W-T8 — Governed edit seams + raw-REST holdouts:** existing-doc edit saves for the create-only governed writes; Item Price governed save; Variants write; Customers edit route; masters still on raw REST (Item Group, Brand, UOM) and Company Settings + People Users moved to governed writes; Purchase Receipts list onto the governed read.
- **Cross-references (already queued module/feature lanes — not duplicated here):** Manufacturing / Projects / Assets screens (module lanes), HR screens (E8), CRM screens (E9), Custom Report Builder (FR-002), EV industry-pack surfaces (EV-2+), guided-tour once-per-account (FR-003), mobile navigation (FR-004), SPA login IdP placeholders (config.js `*.operqon.example` — fold into the next SPA lane touching auth).

## §7 — Acceptance status

- This run wired **no surface directly** — the census is the deliverable; provider/console/portal wiring is assigned to Cursor (§6A) and tenant wiring is queued as loop lanes (§6B), per the standing work split and the one-writer rule on the VPS clone (whose checkout currently sits on a Cursor branch). No lane was started out-of-band in this run for exactly that reason; the queue in LOOP-STATE is the mechanism that puts W-T1 next in the loop's rotation.
- **Browser proof owed:** every row Cursor or the loop lands needs the binding fresh-browser proof (real data loads; an action persists across refresh). None of the 61 non-WIRED rows carries a proof yet — each is owed at its own lane's acceptance, and EV-1's still-pending demo2 Desk Stock Balance PASS remains the owner's separate gate, untouched by this lane.
- **Genuinely blocked items (exact reasons):** (1) Easypaisa/PayFast live settlement — merchant-live verification is the owner's step; the webhook shapes exist and stay NOT_LIVE until then (the wiring of everything around the gate is NOT blocked). (2) Nothing else: every other non-WIRED row has a named owner (Cursor or the loop) and a defined build.

---

## §8 — App-first addendum (2026-11-28, owner method directive ~15:00 PKT)

**Directive:** list all available Frappe + third-party apps first, read their
docs/APIs into a knowledge base, then wire the DreamsERP frontend to them —
assemble, don't build. Full evidence: **`FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md`**
(same directory; 21 repos cloned + scanned today — Semgrep/Bandit/Gitleaks —
licences read from source, version ranges from pyproject, last commits
verified). This section adds the **source-app column** the original census
lacked: every surface below now names the app whose API it wires to. Custom
build remains ONLY where the KB found no suitable app.

### 8.1 Source-app mapping — tenant SPA (§3 surfaces)

| Census surface / gap | Source app (KB §) | Wired to (API) | What remains custom |
|---|---|---|---|
| POS main `#/pos`, POS Held `#/pos/held` (GAP-06) | **ERPNext built-in POS** (KB §2.1) | REST on POS Invoice / POS Opening / Closing Entry + ERPNext POS methods | **Only the governed seam** (W-T1: complete sale / hold / resume in operqon_core) + SPA wiring. No POS engine, no third-party POS app on the path (POS Prime / POS Awesome fork = EVALUATE fallbacks, KB §4.3/§4.4) |
| HR — no screens at all (MISSING-ENDPOINT) | **Frappe HRMS** (KB §3.2) | REST on Employee/Attendance/Leave/Salary doctypes + `hrms.api` (244 whitelisted methods) | SPA screens only (E8 becomes wiring lanes over an installed app; the D10 layer restore is the HRMS install itself) |
| People: Employees (PARTIAL, read-only) | **HRMS** Employee | REST Employee + HRMS API | Governed user/employee write seams (W-T8 class) |
| CRM — no screens (MISSING-ENDPOINT) | **Frappe CRM** (KB §3.3); fallback: ERPNext built-in CRM doctypes (KB §2.3) | `crm.api` (160 methods) + REST on CRM Lead/Deal; sync flag stays **OFF** | SPA screens (E9 CRM shrinks to wiring); entitlement decides which model a tenant sees |
| Projects `#/projects` (DEAD landing) | **ERPNext built-in Projects** (KB §2.2) | REST on Project/Task/Timesheet | SPA screens only — no install, no engine |
| Discussions / collaboration (new capability) | **Frappe Gameplan** (KB §3.7) | `gameplan.api` (97 methods) | None — Wave 1 install; complements, never replaces, built-in Projects |
| Custom / ad-hoc reports (FR-002, MISSING-ENDPOINT) | **Frappe core Report Builder / Query Report** (KB §2.4) + **Insights** (KB §3.5) for BI tier | `/api/method/frappe.desk.query_report.run`, Report doctypes REST; `insights.api` (59 methods) | The SPA builder *surface* only (field picker, date filters, save/re-run, designed print) — no reporting engine |
| Manufacturing / Assets landings (DEAD) | ERPNext core doctypes (already on bench) | REST on Work Order/BOM/Asset family | SPA screens (module lanes, unchanged) |
| RAG Settings `#/admin/rag-settings` (DEAD) | operqon_rag (own app) | Existing governed methods | W-T6 surface (unchanged) |
| EV industry-pack surfaces | Own EV pack | Own governed methods | EV lanes (unchanged) |

### 8.2 Source-app mapping — portal (§2 surfaces)

| Census surface / gap | Source app (KB §) | Note |
|---|---|---|
| Support ticketing (MISSING-ENDPOINT) | **Frappe Helpdesk** (KB §3.4) — HD Ticket on the tenant site | §6A item 3 changes shape: the customer tickets endpoint becomes a **bridge to HD Ticket** (create/list via the tenant's Helpdesk), not a new provider-side ticket store. Telephony rides as companion; tenant's own Twilio/Exotel if calling is used |
| Integrations card — ZATCA (DEAD) | **KSA Compliance** (KB §4.1) | Connect flow = per-tenant ZATCA onboarding state (wizard in the app; OTP step is the tenant's own Fatoora action). ERPGulf = EVALUATE fallback (KB §4.2) |
| Integrations card — FBR (DEAD) | **Pakistan-Compliance / fbr_e_invoicing** (KB §4.5, EVALUATE) | Scan + our FBR sandbox proof are preconditions; live submission stays sandbox-gated with tenant creds |
| Integrations cards — Easypaisa / PayFast (DEAD) | **No app exists** (KB §5) | Custom build stays (provider-side, merchant-live owner-gated) — unchanged |
| Home/ERP insight widgets (MOCK) | — (not the Insights app) | Portal health/insight endpoint stays a §6A Cursor build; tenant-side BI is Insights' job inside the tenant, a different layer — do not conflate |

### 8.3 Source-app mapping — console (§1 surfaces)

Provider console/API gaps are **provider-side and unchanged** by the app
census (§6A stands, incl. the external invoicing API). Two interactions only:
(i) catalogue/activation work for the KB's USE apps rides the recon's wave
train (W0 Payments → W1 Wiki/Raven/Gameplan/Insights/Builder → W2
Telephony→Helpdesk, Lending, Education, Healthcare, Shipping, Ecommerce
Integrations → W3 HRMS, CRM, Webshop, FBR-eval, Sendqon integration → W4
URY/POSNext proof-decides) with the executor allowlist/guard extension in
the same release train; (ii) every AGPL app activated (CRM, Helpdesk,
Telephony, LMS, Gameplan, Raven, Insights, KSA Compliance) carries the
**§13 in-app source-offer** in operqon_core's SPA About surface (recon §4).

### 8.4 What this does to the loop queue (§6B)

- **Disappears into installs:** the HR engine build inside E8 (all 8 lanes
  were written against a missing layer — the layer is now an install);
  the CRM engine inside E9; any helpdesk/ticketing engine; the BI engine
  behind FR-002; the ZATCA XML/signing engine (never specced, would have
  been next); LMS/Webshop/Wiki/Raven/Builder/Lending/Education/Healthcare/
  Shipping/Ecommerce engines (catalogue value with zero engine builds).
- **Shrinks to wiring/seams:** E8 → SPA screens + governed seams over HRMS;
  E9 CRM → SPA wiring over Frappe CRM; E9 Projects → SPA wiring over core;
  FR-002 → SPA surface over core Report + Insights; W-T1 POS → seam only.
- **Unchanged custom:** W-T2…W-T8 seams, §6A provider endpoints + external
  invoicing API (Cursor), JazzCash/Easypaisa/PayFast, Sendqon integration,
  EV pack, FR-003/FR-004, reconciliation, S5 decision, KSA payroll pack
  (later, on HRMS).

### 8.5 Revised SMB-essential parity estimate

**Earlier estimate (main chat): ~2–3 months** building everything ourselves.
**Revised: ~4–6 weeks** for SMB-essential parity — POS sale completion,
HR & payroll, CRM/leads, projects/tasks, helpdesk/tickets, ZATCA
e-invoicing, advanced reporting/BI — live behind the SPA/provider
surfaces. **Compression ≈ 50–60%.**

Basis:
1. Five engine builds (HR/payroll, CRM, helpdesk, BI, ZATCA) collapse into
   **install + proof + wire** lanes. Installs batch by wave into single
   tenant-image cycles (recon §8), so engine acquisition costs days per
   wave, not weeks per module.
2. The critical path becomes what was always ours: SPA surfaces
   (DreamsERP face) + governed seams (W-T lanes) + proof installs. These
   parallelise across the loop's rotation instead of serialising behind
   engine builds.
3. POS and Projects needed no engine at all (core doctypes) — their
   timelines were wiring timelines already; the census just proves it.

Assumptions / honesty bounds: official apps pass proof install on the
first or second attempt (the posnext/ury class can still bounce an item
back to custom — neither is on the parity path); parity for ZATCA/FBR
means *installed + sandbox-proven* — live submission is per-tenant
onboarding with the tenant's own credentials, not a lane deliverable;
the §13 source-offer surface ships with the first AGPL activation;
provider-side §6A work (Cursor) runs in parallel and is not on this
estimate's critical path except portal ticketing's HD-Ticket bridge.
