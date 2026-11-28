# New-Feature Studies — Batch 7: Lago · Kimai · Snipe-IT (2026-11-28)

**Owner study-queue — Batch 7, OPERQON NEW FEATURES** (presented to the
owner in the main chat, 2026-11-28 ~23:12 PKT). Three studies in the
Frappe-app KB format, same method and rigour as
`STANDALONE-APP-STUDIES-2026-11-28.md` (Documenso · Cal.diy · Formbricks).
**Read-only research — nothing was installed anywhere, nothing was sent to
Cursor.**

**Evidence method (today):** each product was shallow-cloned from its real
upstream (`~/workspace/app-census-20261128/batch7/repos/` — `lago`,
`lago-api`, `kimai`, `snipe-it`) and read directly: root LICENSE,
premium/licence-gating code, auth-method models, API controller trees,
data models. Repo health (stars, releases) was read through the GitHub API
/ release feeds on 2026-11-28. The standing scan stack ran read-only over
the trees (Semgrep `p/security-audit --metrics=off`; Gitleaks; **Bandit is
Python-only and all three stacks are Ruby/PHP — recorded N/A**, §S6). OCR
delegation review was NOT run (paid key / owner ChatGPT sign-in not
configured — standing rule); the documented substitute (manual
licence/API-surface review at source) is applied here.

**EE-folder check first (the standing standalone method):** for each
product the first question was whether SSO, branding or multi-tenancy sits
behind a commercial gate. The three answers differ sharply and drive the
verdicts: **Lago** has no EE folder — premium code ships inside the same
AGPL tree, switched by a licence key (§S2.1). **Kimai** has no EE folder —
SSO (SAML + LDAP) is core; the vendor's money is a *plugin store*, not a
licence gate on core (§S3). **Snipe-IT** has no EE folder and no licence
key anywhere — SAML/LDAP/OIDC and multi-company support are all core
(§S4). None of the three repeats the Formbricks pattern.

**Surfacing rule applied (owner, 2026-11-28):** L1 = the app's own
frontend re-themed inside our shell via Rektrs ID SSO; L2 = generic SPA
screens over its API; L3 = hand-built, exception only. Lago is
**provider-internal** — it never becomes a tenant surface at all; its
"surfacing" is classified separately in §S2.

---

## §S1 — At a glance

| App | Licence (verified at source) | Adds what Operqon lacks | Surface | Verdict |
|---|---|---|---|---|
| **Lago** v1.57.0 | AGPL-3.0, whole tree; premium features licence-key-gated *inside* the AGPL code (SSO Okta/Entra, audit logs, AI assistants) | Metering + usage billing engine: billable metrics, charge models, prepaid wallets, subscriptions, invoice generation, dunning, credit notes, payment orchestration | Provider-internal (no tenant surface) | **GO — as UNDERLAY** (provider keeps catalogue/entitlement face; Lago becomes the metering + invoicing engine). Safe minimum **v1.56.0** (CVE-2026-119420), deploy **v1.57.0** |
| **Kimai** v2.73.0 (main: 2.74.0) | AGPL-3.0 since 2023 (was MIT); SAML + LDAP + 2FA in core; paid/free *plugins* exist but gate nothing in core | Professional time tracking: timers, rates at 4 levels, budgets, month-approval, timesheet → invoice, full JSON REST API | **L1** (own UI re-themed, SAML SSO via Rektrs ID) | **GO — L1 wiring candidate** (not design-mining only). ERPNext stays the invoicing/accounting system of record |
| **Snipe-IT** v8.8.4 | AGPL-3.0, whole tree; no EE folder, no licence key; SAML/LDAP/OIDC + multi-company in core | IT asset + licence-seat operations: checkout/check-in, QR labels, licence seats, maintenance, full REST API (228 routes) | **L1** (tenant packs) / internal tool | **GO (tenant pack, L1)** with a hard custody-vs-GL boundary · **GO — immediate (Rektrs internal use)**, assessed separately in §S4.3 |

---

## §S2 — Lago — provider-side billing engine

- **Identity / health:** getlago/lago — **10,933 stars, 805 forks**;
  pushed **2026-11-28** (today); releases **v1.57.0 (2026-11-05)**,
  v1.56.0 (2026-11-02), v1.55.0 (2026-10-07), v1.54.0, v1.53.0 — a monthly
  or faster cadence, very active, vendor-funded (Lago Inc.; production
  users named in the README include Mistral AI and Groq). Architecture:
  Rails API (`lago-api`) + React front + events processor; PostgreSQL,
  Redis; ClickHouse/Kafka pieces are optional scale extras in the umbrella
  repo. Umbrella repo `getlago/lago` v1.57.0 is the deployable unit
  (docker-compose in tree).
- **What it adds:** the entire *metering half* of billing that our provider
  does not have and would otherwise have to build: **billable metrics**
  (any usage event stream, aggregated count/sum/max/weighted…),
  **charge models** (standard, graduated, volume, percentage, package,
  per-unit — i.e. per app, per integration call, per user/month are all
  native shapes), **plans + subscriptions** with trials and add-ons,
  **prepaid wallets** with credit grants, top-ups, thresholds and alerts,
  **invoice generation** (draft → finalised, taxes, credit notes, payment
  receipts), **dunning campaigns**, coupons, and **payment
  orchestration** for Stripe / Adyen / GoCardless plus recorded manual
  payments and payment requests. It also now carries a native
  **entitlement model** (`app/models/entitlement/` — features +
  privileges attached to plans/subscriptions), the same vocabulary as our
  catalogue. Webhooks: signed endpoints, a rich typed event catalogue
  (invoice, subscription, wallet, credit-note lifecycles). API: REST v1 +
  v2 + a GraphQL admin API; OpenAPI spec published (217 operations per
  the vendor docs). **PKR is a first-class currency** in the tree
  (`app/models/concerns/currencies.rb`: `PKR: "Pakistani Rupee"`).

### §S2.1 — EE-folder check (done first, per method)

There is **no EE/premium folder**. The premium code lives *inside* the
AGPL tree and is switched at runtime by a licence key:
`config/initializers/license.rb` + `lib/lago_utils/lago_utils/license.rb`
verify `ENV["LAGO_LICENSE"]` against Lago's licence server at boot;
`app/controllers/concerns/premium_feature_only.rb` 403s with
`feature_unavailable` when `License.premium?` is false. Tree-verified
premium gates:

- **Enterprise SSO: Okta and Entra ID are PREMIUM**
  (`app/models/concerns/organizations/authentication_methods.rb`:
  `FREE_AUTHENTICATION_METHODS = [EMAIL_PASSWORD, GOOGLE_OAUTH]`,
  `PREMIUM_AUTHENTICATION_METHODS = [OKTA, ENTRA_ID]`). Generic
  SAML/OIDC against our Keycloak is therefore **not** available on the
  free route.
- **Audit logs are PREMIUM** — activity logs, API logs and security logs
  controllers (REST v1 + v2 and GraphQL resolvers) all sit behind
  `PremiumFeatureOnly`. For a billing system this is the one premium gate
  that genuinely hurts (see Risks).
- **AI assistants are PREMIUM** (Finance Assistant / Billing Assistant
  conversations and exports) — irrelevant to us; our own agent layer
  exists.
- Scattered premium settings (e.g. invoice grace-period on billing
  entities, Anrok tax integration, x402) — none is on our critical path.
- **Not gated:** metering, plans, charges, wallets, subscriptions,
  invoicing, credit notes, dunning, coupons, taxes, the entitlement
  model, multi-entity (billing entities exist in core; only specific
  settings check the licence), the full REST/GraphQL API, webhooks.

Because the premium code is AGPL code in the same tree (not a separate
commercial codebase like Documenso's `packages/ee`), the licence posture
is clean: everything we would run is AGPL-3.0; the Premium licence is a
*contract* for unlocking switches, not a second codebase. We simply do
not buy it on day one: Lago's users are our own operators (a handful of
staff on email/password or Google OAuth is acceptable for an internal
tool), and the audit-log gap is mitigated by our provider's own audit
surfaces plus database-level logging — recorded as a named gap, not
discovered later.

### §S2.2 — NAMED SECURITY CHECK: CVE-2026-119420 (account takeover)

- **The CVE:** CVE-2026-119420 (GHSA-gvqv-g6vj-p22g), published
  **2026-10-30** by VulnCheck; CVSS 8.8 (v3.1) / 8.7 (v4.0), High;
  CWE-288. In Lago **≤ 1.55.0**, an organisation admin could invite a
  victim's email and call the `acceptInvite` GraphQL mutation with an
  arbitrary password, receiving a valid JWT for the victim's existing
  account — full access to their organisations, billing data, API keys
  and payment integrations. A public PoC exists (abraxaslabs research).
  A second, Low-severity CVE from the same disclosure batch,
  CVE-2026-119548 (cross-organisation webhook payable lookup), was fixed
  in the same window.
- **What the October review said:** the fix (commit `5a9d5935`,
  lago-api PR #6146, merged 2026-10-15) was on `main` only; v1.55.0
  (2026-10-07) was the latest release, so *no installable version carried
  the fix*. That was true when written.
- **Current state — VERIFIED AT SOURCE TODAY:** v1.56.0 shipped
  **2026-11-02** and v1.57.0 on 2026-11-05. Reading
  `app/services/invites/accept_service.rb` at the release tags:
  **v1.55.0** passes the invite straight to `register_from_invite` and
  issues a token — no password check on an existing account (vulnerable).
  **v1.56.0 and v1.57.0** route existing users through
  `join_as_existing_user`, which calls
  `AuthenticateUserService.call(user:, password:)` and fails unless the
  real password authenticates (fixed). The vulnerable code path is gone
  in both later tags.
- **Safe minimum version: v1.56.0. Deploy target: v1.57.0** (current).
  Never deploy ≤ v1.55.0. Standing lesson recorded: Lago merges security
  fixes to `main` promptly but *releases* roughly monthly — the October
  gap (fix merged 15 Oct, released 2 Nov) is the pattern to defend
  against: our deployment rule is "track releases, pin ≥ the first
  release containing the fix, and restrict member-invite rights on any
  version awaiting a security release." Lago publishes no security
  advisory feed of its own (no SECURITY policy in the API repo beyond
  the umbrella's SECURITY.md, no security.txt per the October review) —
  monitoring CVE feeds for `getlago` becomes an ops checklist item.

### §S2.3 — THE QUESTION: replace our billing build, sit underneath it, or no?

**Answer: UNDERLAY.** Lago becomes the metering + invoicing engine
underneath the provider; it does not replace the provider's catalogue,
entitlement or provisioning layers.

**What stays in our provider DB (must NOT move):**

- **The product catalogue and plan definitions as the commercial source
  of truth** (30 registry products, plan pricing, the Zoho-style
  per-app/per-integration/per-user price book). Lago plans are a
  *mirror* created from ours, not the master — the console edits ours.
- **Entitlement grants and the S5 entitlement JWT** (RS256, 8 platform
  features). Lago's entitlement model is subscription-scoped (features
  on a Lago subscription); ours is platform-scoped and gates tenant
  provisioning and SPA features across systems Lago knows nothing about.
  Lago entitlements may mirror ours for its own customer-portal logic,
  but the JWT our tenants verify is minted by our provider, unchanged.
- **Tenant lifecycle** (provisioning jobs, sites, Keycloak clients) —
  Lago has no concept of it.
- **PK payment rails.** Lago orchestrates Stripe/Adyen/GoCardless.
  PayFast (sandbox cycle already proven, #160/#171), JazzCash and
  Easypaisa do not exist in Lago and stay ours: a PK payment is taken by
  our gateway layer and *recorded into* Lago as a manual payment /
  payment-request settlement, so Lago's invoice ledger stays complete
  without Lago ever touching the PK gateway.

**What moves to Lago (it becomes the engine of record for money math):**

- **Metering:** the platform emits usage events to Lago (active users
  per tenant, per-integration call counts, per-app usage dimensions) —
  this is precisely the hybrid model the owner set: per app + per
  integration + per user/month *is* a metered model, and Lago's billable
  metrics + charge models express it natively instead of us building an
  aggregation engine.
- **Invoice generation:** Lago computes and issues the invoice
  (charges, taxes, credits from wallets, credit notes), replacing the
  calculation half of our billing build. The in-flight **OS-90 manual
  invoices** work is not wasted: manual/offline invoices are entered
  through our console and recorded in Lago (its manual-payment and
  invoice APIs cover this), so the console face stays ours.
- **Wallets/prepaid credits** (tenant top-ups against usage), **dunning**
  (our console has a Dunning surface today with no engine behind it —
  Lago's campaigns are that engine), coupons and trials.

**The seam (concrete):** provider API → Lago REST API (server-to-server,
scoped API key) for customer/plan/subscription mirroring and event
ingestion; Lago → provider via **signed webhooks**
(`invoice.finalized`, `invoice.payment_status_updated`,
`subscription.*`, wallet alerts) writing status back into the provider
DB so the console and customer portal keep reading *our* tables and
never call Lago at render time. The portal/console face does not change;
no tenant ever sees Lago (it has no tenant-facing role at all — its own
admin UI is for our operators only).

**The MCP server's relevance:** Lago's MCP server lives in
`getlago/lago-agent-toolkit`, **MIT-licensed**, exposing read/write tools
over invoices, usage, customers, payments, credit notes and coupons,
inheriting the permissions of its API key. For us this is a bonus, not a
dependency: it is the same shape as the Sendqon MCP direction — our
operator/agent tooling could query billing state through it later. It
plays no part in the adoption decision and needs no action now.

**Multi-currency:** first-class (currency per plan/billing entity; PKR
verified in the tree). Multi-entity (separate billing entities for
Rektrs PK vs a future KSA entity) exists in core.

### §S2.4 — AGPL posture for a provider-internal deployment (precise)

- **Unmodified Lago, internal use:** Lago's users are (a) our staff in
  its admin UI and (b) our provider API as a machine client. AGPL §13's
  source-offer duty is triggered by letting users interact with a
  **modified** version over a network. Running the stock release
  unmodified triggers no §13 offer duty beyond preserving the app's own
  licence notices — the same position as the Documenso CE analysis.
- **If we modify it** (the realistic case: e.g. a PayFast recording
  plugin, a branding touch, a patch): §13 then requires prominently
  offering the Corresponding Source of the modified version to **all
  users of that instance** — in practice: publish the fork (public repo)
  and link it from the instance. The audience is internal, but the safe
  and cheap compliance shape is a public fork repo, which also keeps our
  patches upstreamable. There is no tenant exposure: tenants never
  interact with Lago, so no tenant ever acquires a §13 claim on it —
  this is the cleanest AGPL posture of any app in the batch.
- **Premium licence** is orthogonal: a paid contract that flips runtime
  switches (SSO/audit logs/AI). Not buying it breaches nothing; the
  gated features simply stay off.

- **Effort estimate:** stand-up (compose stack, PostgreSQL, licence-free
  config, backups) **2–3 days**; catalogue mirror + event plumbing +
  webhook sync-back **2–4 weeks** as a provider-side lane series (it
  belongs to the provider track, sequenced after the in-flight wiring
  queue); a **parallel-run period** (Lago computes, our billing stays
  the ledger) before Lago invoices become the issued ones — one full
  billing cycle minimum.
- **Risks:** (1) **Ops weight** — a Rails + React + PostgreSQL + Redis
  stack (plus events processor at scale) is the heaviest addition in
  this batch; it runs beside the provider, not the bench. (2)
  **Security-release lag** (§S2.2) — mitigated by the pin rule, but it
  is a permanent monitoring duty on a system that touches revenue.
  (3) **Audit logs are premium** — a billing engine without its own
  audit trail is a real governance gap; mitigations exist (our audit
  surfaces, DB logging), and the Premium quote can be revisited if a
  compliance need hardens. (4) **Dual-ledger transition risk** — during
  parallel-run, exactly one system may be the invoice of record per
  tenant; that rule must be written into the lane, or reconciliation
  debt follows. (5) Vendor-steered (funded startup; roadmap follows its
  AI-billing market) — our exposure is bounded by the API/webhook seam,
  not a fork.
- **Scans:** §S6.
- **VERDICT: GO — as underlay, on v1.57.0.** Lago replaces the *billing
  build we have not yet done* (metering, wallets, dunning, invoice math)
  and nothing we have already built. It does not replace the catalogue,
  entitlements, provisioning or PK gateways. Conditions: pin ≥ v1.56.0
  (deploy v1.57.0); no Premium purchase assumed; parallel-run before
  cutover; CVE-feed monitoring added to ops.

---

## §S3 — Kimai — time tracking for the Services/MSP + agency pack

- **Identity / health:** kimai/kimai — **5.2k stars**; releases
  **2.73.0 (2026-11-23)** and **2.74.0 (2026-11-28, today)** — the tree
  read is main at `VERSION = '2.74.0'`; a release roughly every 1–2
  weeks through autumn 2026. Symfony/PHP (Twig + Tabler UI), MySQL/
  MariaDB or SQLite. Stewardship: Kevin Papst's project, commercially
  supported via Kimai Cloud and the plugin store — a small-vendor
  bus-factor note, offset by 20+ years of project continuity (Kimai 1.x
  lineage) and a fully open core.
- **Licence history (matters for the pack's older docs):** Kimai was
  **MIT until 2023**; current core is **AGPL-3.0** (root LICENSE read
  verbatim). Anything written about "MIT Kimai" predates the change.
- **EE-folder check (first, per method):** there is **no EE folder and
  no licence key**. The vendor's commercial layer is a **plugin store**
  (kimai.org/store: ~21 plugins, paid and free — audit trail, custom
  fields, expense management, task planning, customer portal, e-invoice
  plus…). Plugins *add*; nothing in core is gated by them. Decisively:
  **SAML is core** (`src/Configuration/SamlConfiguration.php`,
  `src/Controller/Auth/SamlController.php`), **LDAP is core**
  (`src/Configuration/LdapConfiguration.php`), **2FA is core**
  (scheb_2fa). Rektrs ID is a Keycloak realm; Keycloak speaks SAML —
  so the standing L1 pattern (app's own UI + our SSO) works **without
  buying anything**. This is the exact opposite of Documenso/Formbricks.
- **What it adds:** the time-tracking UX ERPNext Timesheet does not
  have: one-click timers, calendar/day/week views, **rates at four
  levels** (user, customer, project, activity — plus per-user project/
  activity rates), **money and time budgets** per customer/project/
  activity with team visibility, **month-level approval**
  (`WorkingTimeService::approveMonth` — a supervisor approves a user's
  month, with approver, timestamp and an approval PDF; team timesheet
  views for leads), tags, favourites, exports, and a **timesheet →
  invoice** module (invoice models, calculators, number generators,
  PDF/Word renderers). Teams and team permissions are core.
- **API completeness (tree-read, `src/API/`):** full JSON REST with
  OpenAPI annotations — controllers for **Timesheets, Customers,
  Projects, Activities, Teams, Users, Invoices, Export, Tags,
  Configuration, Dashboard**. The invoice controller exposes list/get/
  create-via-model, custom fields, download, delete. Everything the
  sync seam needs exists; nothing requires scraping its UI.
- **THE QUESTION — L1 wiring vs design mining:** **L1 wiring.** Design
  mining would mean rebuilding timers, calendar views, rate resolution
  and budget logic on ERPNext Timesheets — the expensive 20% of Kimai
  that is *not* its screens. Kimai's engine (rate precedence, budget
  accounting, approval state) is the value; its UI is Tabler/Bootstrap,
  so a DreamsERP token re-theme is CSS-level work, and SAML SSO is
  configuration. Mining only the design and discarding a complete,
  SSO-ready engine fails the app-first test the owner set today.
- **Which system invoices (the seam rule):** **ERPNext invoices.**
  Kimai is the time *capture and approval* system; approved timesheets
  sync to ERPNext (per customer/project mapping), where the Sales
  Invoice is raised on the tenant's real GL, tax and payment rails.
  Kimai's own invoice module is used as the *preview/proforma* the
  client approves against (its PDF is an excellent supporting
  document), never as the accounting record — one invoice of record,
  in ERPNext. The reverse sync (invoice number/status) writes back to
  the Kimai invoice record via its API so both views agree.
- **Multi-user/team model:** one Kimai instance = one business (the
  tenant), with its staff as users, teams for departments, and the
  tenant's clients as Kimai *customers*. There is no multi-business
  tenancy inside one instance — the pack model is **one instance per
  tenant** who buys the Services pack (same ops shape as other L1
  apps), or a single shared instance for Rektrs' own agency use as the
  pilot.
- **AGPL boundary on the L1 route (precise):** *Configuration and CSS
  are free; code changes carry the §13 duty.* Running **unmodified**
  Kimai behind our shell — SAML configuration, logo/branding settings,
  a CSS-level theme — triggers no source-offer duty beyond its own
  notices. The moment we **patch its PHP/Twig code** (a template
  re-theme that edits shipped templates counts), §13 requires offering
  the modified source to **that instance's users** (the tenant's staff)
  — satisfied by our standard pattern: the in-app source entry pointing
  at a published fork. AGPL does **not** forbid re-branding (unlike the
  Formbricks EE terms): the vendor's face may be replaced, provided
  licence notices in the source and legal/About surfaces are preserved
  and the product is not *named* Kimai in our catalogue (trademark
  hygiene, not a licence duty). Paid plugins, if ever bought, are
  separate per-plugin licences and are not assumed by this study.
- **Effort estimate:** stand-up + SAML against Rektrs ID + CSS re-theme
  **~1 week**; the ERPNext sync seam (customer/project mapping, approved
  timesheet pull, invoice write-back) **1–2 weeks** (one lane);
  per-tenant instance templating is configuration thereafter.
- **Risks:** (1) a third runtime stack (PHP/Symfony) beside the bench —
  bounded, containerised, per-tenant only for pack buyers; (2)
  small-vendor bus factor (mitigated: fully open core, self-hostable
  forever, active release cadence); (3) approval is *month-level*, not
  per-entry approval chains — packs needing per-entry multi-step
  approval must model it in ERPNext after sync, not expect it in Kimai;
  (4) rate/budget semantics differ subtly from ERPNext's — the mapping
  table is a lane deliverable, not an assumption.
- **Scans:** §S6.
- **VERDICT: GO — L1 wiring candidate** for the Services/MSP + agency
  pack, with ERPNext as the invoicing/accounting system of record and
  Kimai as capture + approval. Pilot shape: Rektrs' own agency instance
  first (we are ourselves a services business), then the tenant pack.

---

## §S4 — Snipe-IT — IT asset & licence management

- **Identity / health:** grokability/snipe-it — **15k stars**; releases
  **v8.8.4 (2026-11-20)**, v8.8.3/v8.8.2 in October — steady cadence,
  large community, vendor (Grokability) sells hosting/support, not
  licence features. Laravel/PHP, MySQL; Docker and docker-compose in
  tree. In-tree version file reads `v8.8.4 - build 26735`.
- **EE-folder check (first, per method):** **the cleanest result in all
  six standalone studies.** No EE folder, no premium folder, no licence
  key, no feature flags for sale. **SAML is core, LDAP is core**
  (`app/Models/Ldap.php`, SAML console commands and settings), **OIDC
  is core** (auth config wires Passport via `auth:oidc,api`) — OIDC is
  exactly Rektrs ID's native protocol, so L1 SSO needs no SAML bridge.
  **Full Multiple Companies Support is core**
  (`full_multiple_companies_support` setting, enforced in API
  controllers) — one instance can hold several companies with data
  separation, which matters for both questions below.
- **What it adds:** the *operations* side of assets that ERPNext does
  not do: asset checkout/check-in to users/locations/other assets with
  due dates and acceptance, **software licence seats** (per-seat
  assignment, expiry), accessories/components/consumables, **QR/barcode
  labels**, maintenance records, custom fields, audit history on every
  item, low-stock and expiry alerting — all over a **full REST API
  (228 routes in `routes/api.php`)** with controllers for Assets,
  Licenses, LicenseSeats, Depreciations, Companies, Locations,
  Maintenances, Labels, Import and more, authenticated by personal
  access tokens / OIDC.

### §S4.1 — Question (a): asset pack for Operqon SMB tenants

- **The overlap/complement boundary (the deciding design rule):**
  **ERPNext owns the money; Snipe-IT owns the custody.** ERPNext Asset
  remains the accounting record — capitalisation, depreciation
  *schedules posting to the GL*, disposal/write-off accounting.
  Snipe-IT owns the physical/operational record — who has the laptop,
  which licence seat is on it, when it is due back, its maintenance
  history. Snipe-IT *does* compute depreciation (linear and diminishing
  methods in `app/Models/Depreciable.php`) — that output is a
  **book-value report for operations only and must never feed the GL**;
  the pack design fences it exactly there, or tenants get two
  depreciation truths.
- **Sync seam (concrete, via the REST API):** asset purchased/received
  in ERPNext → created in Snipe-IT (asset tag, serial, model, company)
  by the bridge; custody events (checkout/check-in, licence seat
  assignment) live in Snipe-IT and are *readable* back into an ERPNext
  asset view (current holder, location) — custody never writes
  accounting fields. Licence purchases mirror the same way (ERPNext
  buys, Snipe-IT seats).
- **Fit:** strongest for the IT/MSP pack (pairs with Kimai's services
  pack — the MSP tracks both the engineer's time and the client's
  devices), schools (device fleets to students/staff), clinics
  (equipment custody), and any SMB whose real asset problem is "where
  is it and who has it", not depreciation policy. For a tenant whose
  only need is accounting depreciation, ERPNext alone suffices and
  Snipe-IT is not sold — the pack is custody-shaped, not
  accounting-shaped.
- **Effort estimate:** per-tenant instance stand-up + OIDC SSO +
  re-theme **2–3 days** (multi-company support may even allow a shared
  instance for small tenants — an ops decision at lane time, with the
  data-separation setting as the evidence); the ERPNext bridge **~1
  week**.
- **Risks:** (1) the two-depreciation-truths trap (above — a design
  fence, enforced in the bridge by never syncing value fields); (2)
  asset-master duplication drift — the bridge must be the only creator
  of Snipe-IT assets for synced classes; (3) a third PHP stack, shared
  with the Kimai decision (same ops skill, different apps).
- **VERDICT (a): GO — L1 candidate for the IT/MSP + device-heavy
  packs**, boundary as above.

### §S4.2 — AGPL posture (applies to both questions)

Whole tree AGPL-3.0, no commercial folder. Unmodified use (either
question) carries no §13 duty beyond the app's notices. Modifications
(e.g. a deeper re-theme in its Blade templates) trigger the standard
§13 offer to that instance's users — for tenants, our standard in-app
source entry; for internal use, see §S4.3. Re-branding is not
licence-forbidden; licence notices stay, the catalogue name is ours.

### §S4.3 — Question (b): Rektrs internal use (SEPARATE recommendation)

- **The use:** one Snipe-IT instance for Rektrs' own fleet — staff
  laptops and phones, the VPS inventory, software licences we hold —
  replacing whatever spreadsheet/memory currently carries it.
- **AGPL posture for purely internal use (precise):** the instance's
  users are Rektrs' own staff. Running it **unmodified** creates no
  §13 offer duty at all. Even if we later modified it, §13's offer runs
  to the instance's users — our own staff — and is satisfied by access
  to our own fork; no public or third-party exposure arises from
  internal use. Internal AGPL use is the lowest-risk posture in the
  licence family.
- **Effort:** docker-compose from the tree, one VPS/container, OIDC or
  local admin, **half a day to one day** including backups; data entry
  of the current fleet is the only real work, and it is clerical.
- **VERDICT (b): GO — immediate, independent of the tenant question.**
  It pays off on its own (fleet truth, licence-seat truth, checkout
  accountability), it dogfoods the exact app the tenant pack would
  ship, and the pack lane inherits a proven instance configuration.
  Sequencing note: this is an internal-ops action, not an Operqon lane;
  it should not wait for the pack decision.

---

## §S5 — What this changes in the plan

1. **Lago** enters the provider track as the billing *underlay*:
   catalogue/entitlements/provisioning stay ours; metering, wallets,
   dunning and invoice math stop being a custom build. Sequenced after
   the in-flight surface-wiring queue; parallel-run one billing cycle
   before Lago-issued invoices. Pin rule: **≥ v1.56.0, deploy
   v1.57.0**; add `getlago` to CVE-feed monitoring.
2. **Kimai** joins the L1 candidate queue for the Services/MSP + agency
   pack (with the pass-2 IT Management composition), pilot on Rektrs'
   own agency work first. ERPNext invoices; Kimai captures and
   approves.
3. **Snipe-IT** joins the L1 queue for IT/MSP + device-heavy packs
   behind the custody-vs-GL boundary rule — and is recommended for
   **immediate internal adoption** by Rektrs on its own track.
4. **Method note:** the EE-folder check again decided more than the
   feature lists — but with the opposite sign from Batch 6: all three
   products keep SSO in (or near) the open core, and Lago's premium
   gate, uniquely, is a runtime licence switch inside AGPL code rather
   than a withheld codebase.

---

## §S6 — Scan coverage record (exact) + caveats

Standing stack, run read-only over the shallow clones on 2026-11-28
(outputs in `~/workspace/app-census-20261128/batch7/scans/`). All three
stacks are Ruby/PHP — **Bandit (Python-only) is N/A for all three**, and
Semgrep ran `p/security-audit` only. Semgrep parse errors mean coverage
is a floor, not a proof of cleanliness — the same honesty standard as
the KB passes. (Process note: the first scan run was interrupted by a
runtime restart after saving Lago's Semgrep output; the missing pieces
— all Gitleaks runs, Kimai and Snipe-IT Semgrep — were completed in a
second pass against the same trees, and the Gitleaks binary was verified
working, v8.30.1, before its clean results were accepted.)

| App | Semgrep `p/security-audit` | Gitleaks | Assessment |
|---|---|---|---|
| Lago (`lago-api`) | **14 findings** (ssl-mode-no-verify ×11, unprotected-mass-assign ×2, force-ssl-false ×1); 26 parse errors | **clean — 0 findings** | SSL-verify hits break down as: 5 in specs + 1 in the test-environment config (not production paths); 3 in `lib/lago/redis_config_builder.rb` (configurable Redis SSL modes — a named review item for any deployment using TLS Redis); 1 each in the HTTP session client and a subscription queue consumer. Mass-assignment ×2 sit in a wallet recurring-transaction-rule validation service — a named review item before production use. force-ssl-false ×1 is the production environment config (Lago is designed to sit behind a TLS-terminating proxy — deployment must terminate TLS at our proxy, as with our other services). No finding blocks the underlay adoption; the Redis/HTTP-client items join the deployment checklist |
| Kimai | **103 findings** (var-in-href ×72, unquoted-attribute-var ×24, var-in-script-tag ×7 — all generic HTML-template rules); 0 parse errors | **clean — 0 findings** | All 103 are the generic template-interpolation rule class against Twig templates — the same long-standing pattern class assessed in the Cal.diy study; Twig's default escaping is the mitigating context, and no PHP-code finding was raised. Named review class only; not a blocker for an L1 adoption behind our SSO, and the re-theme lane inherits a template review pass |
| Snipe-IT | **1 finding** (dockerfile last-user-is-root ×1); 0 parse errors | **clean — 0 findings** | The cleanest scan of the batch: the single hit is the shipped Dockerfile running as root — a deployment-hardening note (run the internal instance behind our standard container hardening), not a code finding |

**Caveats (standing):** (1) OCR full review not run — no paid key /
owner ChatGPT sign-in configured; the licence/API-surface manual review
above is the documented substitute. (2) These are `main`-branch
snapshots of 2026-11-28 (Lago study facts are pinned to the v1.57.0
release where version matters — notably the CVE fix, verified at the
release tags, not on main). (3) Legal characterisations are engineering
readings of the licence texts for planning; a counsel pass is owed
before any AGPL app is activated for paying tenants — the same standing
note as the Frappe AGPL set. (4) Star counts: Lago 10,933 and release
dates are GitHub-API-verified; Kimai (5.2k) and Snipe-IT (15k) star
figures are the platforms' rounded public counts read today — the
release cadence facts for all three are feed-verified.
