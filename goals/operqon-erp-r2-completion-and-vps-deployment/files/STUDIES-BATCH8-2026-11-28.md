# Studies Batch 8 — Traccar · Plane · InvenTree (2026-11-28)

**Owner study-queue — Batch 8 (presented in the main chat, 2026-11-28
~23:16 PKT).** Three standalone-app studies in the Frappe-app KB format,
same method as `FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md`,
`...-PART2-2026-11-28.md` and `STANDALONE-APP-STUDIES-2026-11-28.md`.
**Read-only research — nothing was installed anywhere, and nothing was
sent to Cursor.**

**Evidence method (today):** each repo was shallow-cloned from its real
upstream (`~/workspace/app-census-20261128/batch8/`) and read directly —
root licences, EE/commercial folders and feature gating, auth provider
trees, API surfaces, config keys, model trees. Repo health (stars,
forks, last push) was read through the GitHub API on 2026-11-28. The
standing scan stack ran read-only over all three trees (Semgrep
`p/security-audit --metrics=off`, + `p/python` where Python exists;
Bandit where Python exists; Gitleaks) — §B6. OCR delegation review was
NOT run (paid key / owner ChatGPT sign-in not configured — standing
rule); the documented substitute (manual licence/API-surface review) is
applied. Per the standalone-studies method amendment, the
**EE/commercial-folder check ran FIRST for each app** (SSO? branding?
multi-tenancy?) — in this batch it clears two apps outright and decides
the third.

**Surfacing rule applied (owner, 2026-11-28):** L1 = the app's own
frontend re-themed inside our shell via Rektrs ID SSO; L2 = generic SPA
screens over its API; L3 = hand-built, exception only. The DreamsERP
design condition and the no-third-party-face rule apply at every level.

---

## §B1 — At a glance

| App | Licence (verified at source) | Adds what Operqon lacks | Level | Verdict |
|---|---|---|---|---|
| **Traccar** (tree HEAD 2026-11-27; release line v6.17.0) | Apache-2.0, whole tree — **no EE folder, no commercial carve-out** | Live GPS fleet tracking for the Logistics pack: 200+ protocols, geofencing, alarms, events | **L1** (own web UI + OIDC SSO in core) | **GO** — closes the Logistics pack's one named gap |
| **Plane** v1.5.1 | AGPL-3.0 Community; commercial code absent from the repo entirely; **SSO/SAML/generic-OIDC not in CE** | (a) Projects design patterns; (b) a possible internal PM tool | (a) n/a — mining only; (b) standalone internal | **(a) NO-GO adopt / GO design-mine · (b) WATCHLIST (CE is honestly sufficient)** |
| **InvenTree** (tree 1.8.0-dev; release line v1.7.4) | MIT, whole tree — no commercial edition; **SAML + OIDC SSO + SCIM in the open core** | Parts-desk stock UX: barcode-first flows, label printing, light build orders | Design reference (Stock SPA); niche companion would be L1 | **NO-GO as ERPNext Stock replacement; WATCHLIST niche companion; GO as design reference** (costing caveat verified — §B4) |

**The batch pattern:** the EE-folder gate that decided Documenso,
Formbricks and Medusa simply does not bite on Traccar or InvenTree —
both carry SSO in their free cores (Traccar: OIDC client; InvenTree:
SAML + OIDC + SCIM) under permissive licences (Apache-2.0 / MIT, no
copyleft duty at all). Plane is the batch's paywall case, and its
verdict is decided by absence: the SSO code is not gated in a folder,
it is not in the repo.

---

## §B2 — Traccar — GPS tracking server (Logistics pack, live fleet tracking)

- **Identity / health:** traccar/traccar — **8,204 stars, 3,510 forks**;
  last push **2026-11-27** (tree HEAD the same day); running since 2012.
  Java server (this repo) + the modern web UI in a **separate repo**
  (`traccar-web`, a git submodule here — release packaging combines
  them). Vendor shape: a single-maintainer-centred project (Anton
  Tananaev) with a very large community protocol corpus; the paid
  offering is managed hosting/support — **no feature gating anywhere in
  the tree**.
- **EE-folder check (first, per method):** root `LICENSE.txt` is plain
  **Apache-2.0**; there is no EE folder, no enterprise licence file, no
  licence-check code. Everything below is the free product.
- **What it adds:** the live-tracking engine the Logistics pack lacks —
  the README (read in tree) states **200+ GPS protocols and 2,000+
  tracker models** out of the box; the protocol package holds **682
  source files**. Geofences (enter/exit/crossed + proximity events),
  alarms, overspeed/fuel/ignition event detection, device commands,
  drivers, maintenance schedules, and a reports surface
  (`ReportResource`). The in-tree event catalogue counts **23 event
  types** (`Event.java`): `geofenceEnter/Exit/Crossed`,
  `proximityEnter/Exit`, `deviceOverspeed`, `deviceFuelDrop/Increase`,
  `ignitionOn/Off`, `deviceMoving/Stopped/Online/Offline/Inactive`,
  `alarm`, `maintenance`, `driverChanged`, `media`, `commandResult`, …
- **API + event surface (read in tree):** a versioned REST API with an
  in-tree `openapi.yaml` (**84 paths**); resource classes for devices,
  positions, events, geofences, groups, users, permissions, reports,
  commands, drivers, notifications, server and statistics, plus a
  WebSocket live stream (`AsyncSocket`). The decisive seam is the
  **forwarder family**: `PositionForwarderJson` / `PositionForwarderUrl`
  and **`EventForwarderJson`** POST positions and events as JSON to an
  arbitrary URL (MQTT/Kafka/AMQP/Redis forwarders also in tree). Events
  can therefore land on an ERPNext webhook endpoint and be stamped onto
  the delivery record — geofence arrival/departure onto **Delivery
  Trip / Vehicle Log**, ignition/stop events onto trip timelines,
  overspeed/alarm events raised as ERPNext notifications. Positions
  themselves stay in Traccar (high-volume time-series); ERPNext keeps
  trip-level facts — exactly the split the brief specifies.
- **DECIDING QUESTION 1 — auth / SSO:** **OIDC client SSO is in the
  core.** Config keys in `Keys.java`: `openid.issuerUrl`,
  `openid.clientId`, `openid.clientSecret`, `openid.force`,
  `openid.allowRegistration`; `LoginService` implements the flow. A
  Keycloak realm (Rektrs ID) is a configuration entry, not a purchase —
  Traccar is the first standalone in this study series whose L1
  defining mechanism is fully free (LDAP auth is also in core, and
  Traccar can additionally act as an OIDC *provider* —
  `OidcResource` — for API clients). Tenant staff sign in with Rektrs
  ID; no separate credentials, no interstitial surface of ours to
  build.
- **DECIDING QUESTION 2 — multi-tenant shape:** one instance, no
  tenant concept — separation is by **Groups** (device groups) plus a
  generic **Permission link table** (user ↔ device / group / geofence /
  driver / notification / calendar / …), and **manager users** with
  `userLimit` / `deviceLimit` who administer their own sub-users
  (the `ManagedUser` permission class). This is the vendor's intended
  reseller shape — the README addresses, verbatim, *"GPS tracking
  resellers running their own white-label platform"*. Practical read:
  one shared instance with a per-tenant group + manager user created at
  provisioning is the designed model; isolation is permission-layer,
  not database-layer, so provisioning discipline + a per-tenant
  as-user acceptance check is the mitigation (the same backend-first
  pattern as the tenant permission lanes). Instance-per-tenant remains
  available for a contract that demands it, at one Java service each.
- **DECIDING QUESTION 3 — can notifications ride Sendqon? YES, by
  configuration alone.** The SMS notificator (`NotificatorSms` →
  `SmsManager`) ships two clients: AWS SNS, and **`HttpSmsClient` — a
  fully generic HTTP SMS client**: `sms.http.url`, an authorization
  header (or Basic user/password), and `sms.http.template` with
  `{phone}` / `{message}` placeholders, auto-detecting JSON / XML /
  form encoding. Sendqon exposes an HTTP send API, so Traccar's SMS
  notifications (geofence, alarm, overspeed alerts to drivers/owners)
  point at Sendqon with config only — **zero code, and it honours the
  standing rule that all EV messaging goes through Sendqon** (a
  WhatsApp notificator also exists in tree; it is not used, per the
  owner's no-WhatsApp decision). Mail, Telegram, Firebase push,
  Pushover and a generic web notificator are also in core.
- **White-label position:** Apache-2.0 permits modification and
  rebranding with **no copyleft/source-offer duty at all**; the
  vendor's own README markets white-label reseller use. The web UI is
  a separate Apache-2.0 repo, so a DreamsERP re-theme is a normal fork,
  not a licence event.
- **Device-side reality:** hardware trackers speak their protocols
  directly (Teltonika/Queclink-class devices; a tracker + SIM/data
  plan is a tenant onboarding cost, not software). Phones work as
  trackers today: the **OsmAnd protocol is in tree**
  (`OsmAndProtocol`), which is what the Traccar Client phone apps
  (separate Apache-2.0 repos) report over — a tenant can start with
  drivers' phones and graduate to hardware without changing the
  server side.
- **Integration route (concrete):** one provider-operated instance →
  at tenant provisioning, create the tenant's Group + manager user via
  the REST API and point OIDC at the tenant's Keycloak client →
  devices registered by uniqueId/IMEI from the SPA Logistics surface →
  `EventForwarderJson` → an ERPNext webhook/whitelisted method that
  stamps Delivery Trip / Vehicle Log and raises alarm notifications →
  position forwarding stays **off** (the SPA map view queries
  Traccar's API live; forwarding positions into the bench would drown
  it) → SMS notificator pointed at the tenant's Sendqon HTTP API.
  Classification in pass-2 vocabulary: **WIRES-CLEAN** (events are a
  designed outbound surface, not a scrape).
- **Effort estimate:** instance stand-up (single Java service + SQL
  database) **1–2 days**; provisioning + OIDC + group automation
  **2–3 days**; event-webhook bridge + SPA trip/map integration
  **1–2 weeks** (the tracking UI itself is Traccar's — L1 — so the SPA
  work is trip integration, not a tracking rebuild).
- **Risks:** (1) permission-layer isolation is soft — a mis-scoped
  manager user could see another tenant's devices; mitigated by
  provisioning-time scoping + as-user acceptance, the standing pattern;
  (2) single-maintainer bus factor — weighed against 13 years of
  continuity and the protocol corpus being the asset, not a roadmap
  promise; (3) one more runtime (Java) beside the bench — a single
  self-contained service, the lightest ops shape a standalone can
  have; (4) tracker hardware/SIM costs sit with the tenant — an
  onboarding conversation, not a platform cost.
- **Scans:** §B6.
- **VERDICT: GO.** Adopt Traccar as the Logistics pack's live-tracking
  engine at **L1**. This closes the gap KB Part 2 recorded verbatim —
  *"custom gap: GPS tracking (Traccar-class external)"* — with the
  cleanest result of any standalone studied: permissive licence, SSO
  in the free core, a designed event seam into ERPNext, and SMS that
  rides Sendqon by configuration. A lane can be cut into the rotation
  when the Logistics pack is assembled; nothing about the verdict
  waits on a vendor, a price, or a licence interpretation.

---

## §B3 — Plane — project management (dual question)

- **Identity / health:** makeplane/plane — **63,315 stars, 6,561
  forks**; last push **2026-11-27**; tree version **1.5.1**
  (`package.json`). Monorepo: `apps/web` (Next.js), `apps/api`
  (Django/DRF), `apps/live` (collaboration server), `apps/space`
  (public pages), `apps/admin`; `deployments/` carries aio / cli /
  kubernetes / swarm self-host shapes. Data model (tree-verified in
  `apps/api/plane/db/models/`): work items (`issue.py`), **cycles**,
  **modules**, **intake** (triage), **pages** (wiki), analytics,
  estimates, deploy boards, views, webhooks.
- **EE-folder check (first, per method):** root `LICENSE.txt` is
  **AGPL-3.0**, and there is **no EE/commercial folder in this repo at
  all** — the commercial edition's code lives in a separate private
  codebase. The deciding evidence is therefore an absence, verified by
  reading the auth tree: `apps/api/plane/authentication/provider/`
  contains exactly **credentials** (`email.py` — email/password;
  `magic_code.py` — email magic-code sign-in) and **oauth**
  (`google.py`, `github.py`, `gitlab.py`, `gitea.py`). **No SAML
  anywhere in the API tree; no generic OIDC provider.** SSO is a
  commercial-edition feature, and unlike Documenso there is not even
  an in-repo EE folder to license — it is a different subscription
  codebase.

### §B3(a) — For Operqon's Projects surface

- **Design mining — the real yield (patterns, named):** Plane is
  worth studying screen by screen for the Projects SPA / L2 work:
  (1) **Cycles view** — a time-boxed iteration with progress/burndown
  and a right-rail stats panel; maps to project phases/sprints on our
  Projects surface. (2) **Intake (triage inbox)** — incoming items
  land in a queue to accept / decline / route before they become work;
  the same pattern serves Helpdesk triage and CRM lead intake.
  (3) **Work-item detail layout** — main column for description/
  sub-items/activity, a persistent right rail for properties (state,
  assignees, dates, estimates, links); a direct template for the L2
  renderer's detail screens. (4) **Modules** — feature-grouping with
  progress rollups. (5) **Pages** — project-native docs beside the
  work. (6) **Analytics** — workspace/project dashboards with
  distribution and trend charts. (7) **Saved Views** — named filtered
  views as first-class objects (aligns with the FR-002 report-builder
  direction). These are ideas implemented originally in our SPA — no
  Plane code is lifted (AGPL code reuse would import §13 duties into
  our own frontend for no benefit).
- **Can L1 wiring even be considered? No — three independent
  reasons.** (1) **No SSO in CE** (above): tenant staff would hold
  separate Plane credentials, breaking the one-identity rule; the
  commercial route is an unpriced separate codebase — the
  Documenso/Formbricks paywall class, one step worse. (2) **AGPL
  §13**: re-theming Plane's UI is a modification; the modified source
  would be owed to every user of the instance — a manageable duty
  that buys nothing given (1). (3) **The overlap conflict — three
  project tools is a smell, said plainly:** ERPNext **built-in
  Projects** already holds tasks, timesheets and project costing —
  the financial truth; **Gameplan** (AGPL, W1 wave, live on oc73)
  already covers the discussion/docs layer bench-natively. Plane
  would add a third, disconnected data model (workspaces / projects /
  work items) that syncs to neither. Whatever Plane does better is
  presentation, and presentation is minable without adoption.
- **VERDICT (a): NO-GO for adoption at any surfacing level; GO for
  design mining.** The mining list above goes to the Projects SPA/L2
  design pass as named patterns. Gameplan + built-in Projects remain
  the Projects stack.

### §B3(b) — For Rektrs' OWN internal project tracking

- **CE auth, honestly (source-verified above):** email/password,
  email magic-code sign-in, and Google / GitHub / GitLab / Gitea
  OAuth — all in the Community tree. **SSO (SAML/OIDC) is commercial
  only.** For an internal team this is not the handicap it is for
  tenants: Rektrs runs Google Workspace, so **Google OAuth sign-in is
  arguably the most convenient option available**, and magic codes
  cover everyone else. No Rektrs ID integration is possible — for an
  internal tool, that is an acceptable, named exception rather than a
  rule breach (the one-identity rule governs tenant-facing surfaces).
- **Is CE enough for a small internal team? Yes.** Workspaces,
  projects, work items, cycles, modules, pages, intake and analytics
  are all CE; the commercial deltas (SSO, advanced roles/audit-class
  features) are not what a small internal team is missing. Nothing in
  the tree caps CE workspaces/projects at a level a Rektrs-sized team
  would hit.
- **Self-host effort:** the `deployments/aio` shape stands the stack
  up (Django API + Next.js web + live server + PostgreSQL + Redis +
  object storage) in **about half a day**; the honest cost is the
  tail — one more production service to patch, back up and upgrade,
  for a 1–2-person core team.
- **The counterweight:** Rektrs' internal tracking today is scattered
  across chats, memory and LOOP-STATE, and Plane CE would genuinely
  consolidate it. Against that, Operqon's own Projects surface
  (Gameplan + built-ins) is being built anyway — running internal
  tracking on it is dogfooding that tests exactly what tenants get,
  at zero additional stack. Plane wins on polish today; our own stack
  wins on ops and on feedback value.
- **VERDICT (b): WATCHLIST — CE is sufficient, adoption is an
  ops-cost choice, not a capability gap.** Trigger to adopt: internal
  project volume visibly outgrows chat/memory tracking *and* the
  team would rather buy polish with maintenance time than dogfood.
  If adopted: Google OAuth + magic codes, aio deployment, internal
  only — never tenant-facing (that is verdict (a)'s NO-GO).

---

## §B4 — InvenTree — parts & stock inventory (vs ERPNext Stock)

- **Identity / health:** inventree/InvenTree — **7,923 stars, 1,645
  forks**; tree HEAD **2026-11-28** (the day of this study); tree
  version **1.8.0-dev** on master, latest release line **v1.7.4** —
  very active. Django/DRF backend + React frontend, a first-class
  **plugin architecture**, and a barcode-first mobile app (separate
  repo).
- **EE-folder check (first, per method):** root `LICENSE` is **MIT**;
  there is **no commercial edition and no EE folder**. And the batch's
  second SSO surprise: `InvenTree/settings.py` sets
  `DEFAULT_SOCIAL = ['saml', 'openid_connect']` — **SAML and OIDC SSO
  are in the open core** via django-allauth (with MFA), and a **SCIM
  provisioning app sits in tree** (`scim/`). If InvenTree is ever
  deployed for anyone, the identity gate is already clean — its
  blocker is elsewhere (below).
- **What it adds:** a parts-desk-shaped inventory: nested stock
  locations, part categories with parameters, supplier/manufacturer
  part cross-references (MPN/SKU mapping), BOMs, purchase/sales
  orders, stocktake, per-stock-item test templates/results — and the
  barcode/label machinery detailed below.
- **DECIDING CHECK — the costing caveat: VERIFIED at source, in
  full.** `pricing/models.py` computes a part's cost from exactly:
  BOM cost (component min/max), **purchase cost (based on purchase
  history)**, internal cost (user-specified internal price breaks),
  variant price, and sale cost. `stock/models.py` updates a stock
  item's unit price as a **weighted average of available pricing
  data**. "FIFO" appears in the tree only as a stock **issue sort
  order** — *"Oldest stock first (FIFO)"*, i.e. which physical item
  to pick — **not as a valuation method**. There is **no landed-cost
  model** (no freight/duty allocation onto item cost) and **no
  accounting/GL app anywhere in the backend tree** (the app list is:
  build, company, order, part, plugin, pricing, report, stock, users,
  machine, importer, data_exporter, scim, audit). **Conclusion:
  InvenTree carries no financial stock truth and can never post one.
  It is not, and cannot be configured into, an ERPNext Stock
  replacement** — ERPNext's stock ledger (FIFO/moving-average
  valuation, landed cost vouchers, GL integration) has no counterpart
  here at all.
- **Where it is genuinely ahead (UX and flows, not accounting):**
  (1) **Barcode flows** — a barcode *plugin architecture*
  (`plugin/base/barcodes/` + builtin `inventree_barcode`: parts,
  stock items and locations carry scannable codes; `manufacturer_
  barcode` parses vendor barcodes; scan-to-move / allocate / count
  is the primary interaction in UI and mobile app). ERPNext treats
  barcodes as fields; InvenTree treats scanning as the workflow.
  (2) **Label printing** — a `LabelTemplate` model, a **label-printer
  machine type** (`machine/machine_types/label_printer.py`) and
  builtin label plugins (`inventree_label`, `label_sheet`): designed
  labels printed straight to label printers from part/stock screens.
  ERPNext print formats are page documents; there is no equivalent
  label-printer pipeline. (3) **Build orders for light assembly** —
  BOM-driven build/allocate/complete with component allocation and
  serial assignment on output; ERPNext Manufacturing does this
  heavier (work orders, job cards, multi-level explosion) — for a
  parts desk assembling kits, InvenTree's shape is the lighter one.
  (4) **Parts metadata depth** for electronics: parameters, MPN
  mapping, test results recorded against individual stock items.
- **Serial / batch / expiry parity:** trackable (serialised) parts,
  batch codes on stock items, and `expiry_date` on StockItem with
  expiry ordering/alerting — operational parity with ERPNext's Serial
  No / Batch / expiry handling. The difference is only the one above:
  ERPNext additionally *values* those units in the ledger; InvenTree
  does not value at all.
- **Plugin system + API depth:** the plugin framework is the deepest
  of the three studies — mixin families for barcodes, labels,
  machines, events, reports, schedules and API integration, with
  builtin and sample plugins in tree. The REST API is broad (in-tree
  top-level route counts: `order/api.py` 81, `part/api.py` 51,
  `stock/api.py` 35, `build/api.py` 25, plus a versioned API with its
  own published version text). Technically, wiring is easy. That is
  not the question — the next point is.
- **Multi-tenancy:** none — one organisation per instance (the
  `company` app models suppliers/customers/manufacturers, not
  tenants). Any tenant use is instance-per-tenant.
- **The sync seam — the stock-truth problem, named:** if a niche
  tenant ran InvenTree beside ERPNext, every stock movement would
  have to exist twice — InvenTree as the operational record at the
  parts desk, the ERPNext Stock Ledger as the financial record. The
  first movement recorded in only one system starts a drift that
  neither side has a primitive to self-heal; the seam becomes a
  permanent integration with a named owner — the Medusa double-truth
  class (§S7 of the standalone studies), except here the two systems
  track *the same physical units*, which makes drift a certainty,
  not a risk. The only defensible pattern is ring-fencing: InvenTree
  as the **sole** stock system for a parts operation whose financial
  stock stays out of ERPNext entirely (period-end manual journal) —
  acceptable for a tiny electronics/parts niche, not a general offer.
- **Correct classification: BOTH of the brief's candidates, in this
  order** — (i) **design reference for our Stock SPA** (primary):
  barcode-first interaction, label printing, and the light build
  order are minable patterns for the L3 Stock/POS surfaces, to be
  implemented originally over ERPNext's ledger (the stacks differ —
  Django/React vs our SPA over Frappe APIs — so patterns, not code,
  even though MIT would permit code reuse); (ii) **niche companion**
  (secondary, watchlist): electronics/parts tenants whose operation
  is genuinely parts-desk-shaped and financially ring-fenced.
- **Effort (for the record):** design-mining pass **days**; a niche
  companion deployment would be instance stand-up 1–2 days + SSO
  config + the ring-fence process design — the software is easy, the
  accounting boundary is the work.
- **Scans:** §B6.
- **VERDICT: NO-GO as an ERPNext Stock replacement or a general
  tenant surface** (the verified costing/GL absence is disqualifying
  for that role, permanently — it is an architectural property, not a
  missing feature); **WATCHLIST as a niche companion** (trigger: a
  signed electronics/parts tenant whose stock operation fits the
  ring-fence pattern); **GO as a design reference** for the Stock SPA,
  effective immediately.

---

## §B5 — What this changes in the plan

1. **Traccar → the Logistics pack is now fully assemblable.** KB
   Part 2's package #11 (Logistics/Cargo) had exactly one custom gap
   — GPS tracking. It is now an L1 wiring item (Traccar) beside Cargo
   Management + ERPNext Shipping, with events flowing into Delivery
   Trip / Vehicle Log and SMS riding Sendqon. The bench-uplift gate
   for Cargo Management (≥16.60) is unaffected. A Traccar lane can be
   cut when the Logistics pack is assembled; no vendor, price or
   licence step precedes it.
2. **Plane → a design-mining note, not a lane.** The seven named
   patterns (§B3a) go to the Projects SPA/L2 design pass. No Plane
   instance is stood up for tenants (NO-GO) or internally
   (WATCHLIST, trigger named).
3. **InvenTree → a design-mining note for the Stock SPA** (barcode
   flows, label printing, light build order) and a watchlist entry
   for the electronics/parts niche. ERPNext Stock remains the only
   stock truth on the platform — this study is the evidence record
   for why that does not change.
4. **Method note:** the EE-folder check now has a positive control —
   two of three apps passed it cleanly (SSO in core, permissive
   licence), which is what a GO looks like for a standalone. The gate
   is not a formality that always fails; it is the fastest route to
   the verdict in both directions.

---

## §B6 — Scan coverage record (exact) + caveats

Standing stack, run read-only over the shallow clones on 2026-11-28
(outputs in `~/workspace/app-census-20261128/batch8/scans/`). Traccar
is Java — **Bandit N/A**; Semgrep ran `p/security-audit` only. Plane
and InvenTree are Python (Django) + TypeScript — Semgrep ran
`p/security-audit` + `p/python`, Bandit ran over the Python backend
(excluding tests/migrations). Semgrep parse errors mean coverage is a
floor, not a proof of cleanliness — the standing honesty standard.

| App | Semgrep | Bandit | Gitleaks | Assessment |
|---|---|---|---|---|
| Traccar | **3 findings** (ldap-injection ×2, tainted-session-from-http-request ×1); 2 parse errors | N/A (Java) | 6 findings | LDAP-injection hits are both in `LdapProvider.java` — engaged only if LDAP auth is enabled; the planned route is OIDC, so this is a named review item, not a blocker. The session hit is in `SessionHelper.java` (session handling — review item for the L1 hardening pass). Gitleaks: 6× generic-api-key — 4 protocol-decoder **test fixtures**, a geocoder config-key constant, a Windows-service constant — **no live secret** |
| Plane | **17 findings** (unvalidated-password ×8, var-in-href ×7, directly-returned-format-string ×1, extends-custom-expression ×1); 0 parse errors | **80 findings, 0 HIGH** (LOW: pseudo-random ×37, hardcoded-password-string ×29 — settings/test class; MEDIUM: requests-without-timeout ×7) | 2 findings | The unvalidated-password cluster sits in the auth flows (Django password-set patterns) — review items if the code were ever adopted internally; they do not change either verdict. Gitleaks: a GitLab OAuth **form-field label** in the admin UI source and a README example — **both false positives; no live secret** |
| InvenTree | **51 findings** (var-in-href ×16, avoid-mark-safe ×10, insecure-md5 ×7, template-escape ×7, logger-credential-leak ×5, unvalidated-password ×3, open-redirect ×2, use-defused-xml ×1); 5 parse errors | **101 findings** (HIGH ×7: MD5 ×6 — checksum/cache paths in conversion, helpers, machine registry, part and plugin registries; os.system ×1 in `script/update_icons.py`, a build tool; MEDIUM: mark_safe class ×21, requests-without-timeout ×1; rest LOW) | 4 findings | The MD5 cluster is checksum/caching use, not credential hashing — a review item, consistent across both scanners. Gitleaks: README example, two test fixtures, frontend test defaults — **no live secret** |

**Caveats (standing):** (1) OCR full review not run — no paid key /
owner ChatGPT sign-in configured; the licence/API-surface manual
review above is the documented substitute. (2) These are
`main`/`master`-branch snapshots of 2026-11-28 (InvenTree's tree is
already 1.8.0-dev; Traccar's web UI lives in its own repo and was
assessed at the server/API level plus its licence, not cloned);
version-specific facts expire — the licence and architecture facts
(EE absence, OIDC/SAML in core, InvenTree's pricing model, Plane's
auth provider list) are the durable part of this study. (3) Legal
characterisations are engineering readings of the licence texts for
planning; a counsel pass is owed before any AGPL app is activated for
paying tenants — the same standing note as the Frappe AGPL set.
Traccar (Apache-2.0) and InvenTree (MIT) carry no copyleft duty in
any case.
