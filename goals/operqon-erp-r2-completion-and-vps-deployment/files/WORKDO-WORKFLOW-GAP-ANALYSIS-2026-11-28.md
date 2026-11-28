# WorkDo Workflow Gap Analysis — Two-Way (WorkDo ⇄ Operqon/Frappe-ERPNext)

**Date:** 28 November 2026 · **Owner's actual ask (clarified 2026-11-28
~17:22 PKT):** NOT buying WorkDo. Study WorkDo's features, industry packs
and their ready-made **workflows** in the live demo, then a two-way gap
analysis against our Frappe/ERPNext-based Operqon:

- **§1 — WorkDo has it, we don't → the EXTENSION list** (what to add, how,
  which surfacing level, which wave)
- **§2 — We have it, WorkDo doesn't → our advantages** (keep, and surface
  in the Store/marketing)
- **§3 — Both have it → workflow lessons** where WorkDo's SMB workflow is
  visibly simpler, adopted into our surfaces as *workflow ideas only*
- **§4 — The end-state picture:** the complete Operqon after extensions

**Licence boundary (standing):** workflow ideas and feature shapes are
competitive research; implementation is original code in our stack. No
WorkDo code, text, or design assets are copied — their product is
commercial/licenced (see the 2026-11-27 zip audit).

**Evidence base (all 28 Nov 2026):**
1. **WorkDo live-demo study** (browser, 17:22–17:32 PKT): full demo
   inventory — 332 add-ons in the add-on builder / 318 in the Plans
   matrix; industry-pack sub-menus read on screen (Hotel "Holidayz",
   School & Institutes, Gym, Hospital, Pharmacy, Restaurant, Construction,
   Property, Tour & Travel); workflow notes for Sales/Purchase invoices,
   Customers, Projects, HRM Employees, CRM Leads kanban, Hotel Rooms,
   Roles, Plans, Settings.
2. **Full module/industry map** `WORKDO-FULL-MODULE-INDUSTRY-MAP-2026-11-28.md`
   (113 modules + 48 industry rows; commit 0461717) — verdicts reused, not
   re-derived.
3. **Our inventory:** KB pass 1 + pass 2 (49 censused apps) + ERPNext/
   Frappe built-ins + census §8.6 surfacing levels.

**Evidence labels used throughout:** **OBSERVED** = the workflow was seen
running in the demo · **MENU-LEVEL** = the module/pack was present in
menus/lists but its working screens were not opened in the demo study
(POS terminal, School/Hospital/Gym/Restaurant/Construction/Property list
pages; the CRM demo workspace held 0 leads, so the kanban *structure* was
observed but no live lead flow) · **CATALOGUE** = named in WorkDo's store/
changelogs (the full map's evidence), not demo-verified.

**Level key (census §8.6):** L1 = app's own frontend re-themed in our
shell · L2 = generic SPA renderer over DocType metadata · L3 = hand-built
product face (exception only, justified). **Wave key:** W0 Payments → W1
Wiki/Raven/Gameplan/Insights/Builder → W2 Telephony→Helpdesk, Lending,
Education, Healthcare, Shipping, Ecommerce Integrations → W3 HRMS, CRM,
Webshop, FBR-eval, Sendqon integration → W4 URY proof-decides · "Wiring" =
SPA/governed-seam lanes, no install · "Later" = post-proof / on-demand.

---

## §1 WorkDo-only → the EXTENSION list

Items WorkDo has that our side does not (map verdicts GAP, plus PARTIALs
where the missing piece is a distinct product shape, not just depth).
Ordered by value to our SMB market (PK + KSA small businesses), not by
WorkDo's catalogue order.

### 1.1 Build / schedule now

| # | Extension | Their workflow (evidence) | Our gap | Method | Level | Wave | Effort |
|---|---|---|---|---|---|---|---|
| E1 | **Construction industry pack (#17)** | Construction sub-menu present in the demo's industry packs (MENU-LEVEL — list pages not opened); catalogue: project-based construction management add-on | Composition exists (Projects costing + Buying + HRMS) but was never packaged as an industry SKU | **Composition of built-ins** — package #17: BOQ/project costing over core Projects, materials over Buying/Stock, labour over HRMS; pack fixtures + wizard like the EV pack | L2 | Wiring (after EV-1 closes) | Days–1 wk (packaging only, no new engine) |
| E2 | **Industry preconfiguration expansion** — turn compositions into named SKUs the way WorkDo sells 93 | OBSERVED pattern: WorkDo's industry packs are preconfigurations of one shared core sold as separate SKUs (demo builder lists them individually; their changelogs confirm) | We field 16 packages; WorkDo fields 93 shelf items. Named-but-unpackaged compositions on our side: Catering (on Restaurant), Vehicle Trade / Car Dealership (generalise the EV serial-spine), Jewellery + Boutique (Retail preconfigs), Society Management (Real-Estate-adjacent), Childcare (School-adjacent), Radiology/Optical (Clinic-adjacent) | **Packaging/configuration** on existing packages — per-SKU fixtures, demo data, Store listing; no new engines | L2 (L3 only where the parent package is L3: Retail/EV) | Per package, riding each package's wave | Days per SKU |
| E3 | **Petty-cash book** | Finance add-on (CATALOGUE): a dedicated petty-cash book with limits per workspace | Payment Entry / Expense Claim cover the money movement; there is no named petty-cash book view with per-book limits | **Composition** — L2 view + limits over Payment Entry in operqon_core | L2 | Wiring | Days |
| E4 | **Retainer ledger** | Finance add-on (CATALOGUE): retainers tracked as their own ledger against clients | Advances against SO/Invoice exist; no retainer-specific ledger view | **Composition** — advances view + retainer balance report over built-in advances | L2 | Wiring | Days |
| E5 | **Commission payout-approval workflow** | Sales add-on (CATALOGUE): commission calculated and paid out to agents as a workflow | Sales Partner/Person commission *calculation* exists; the payout-approval flow is thinner | **Custom seam (small)** — approval workflow over built-in commission doctypes | L2 | Wiring | Days |
| E6 | **Time-tracker timer UX + team workload view** | HR add-ons (CATALOGUE): start/stop timer on tasks; a workload board per team member | Timesheet doctypes exist; no timer UX, no workload board | **SPA wiring** — timer widget + one generic workload screen over Task assignments | L2 | Wiring | Days |
| E7 | **Tenant-facing side-menu builder** | Customization add-on (CATALOGUE, $9): tenants rearrange their own sidebar menus | Menus are workspace-driven; tenants cannot customise them | **SPA wiring** — menu preferences over the SPA shell (FR-004 shell work is adjacent) | L2 | Wiring | Days |
| E8 | **Consignment as a named workflow** | Operations add-on (CATALOGUE): consignment stock tracked as its own flow | Consignment is modelled as plain stock movement, not a named workflow with consignee balances | **Composition** — named views/reports over stock transfers | L2 | Wiring | Days |
| E9 | **CMMS work-order UX** | Operations add-on (CATALOGUE): maintenance work orders as the front door | Asset Maintenance + Maintenance Schedule exist; the work-order UX is Desk-class today | **SPA wiring** over built-in maintenance doctypes (EV pack's service-desk pattern is the in-house precedent) | L2 | Wiring | 1 wk |

### 1.2 Later — real, but on demand / post-proof

| # | Extension | Their workflow (evidence) | Our gap | Method | Level | Wave | Effort |
|---|---|---|---|---|---|---|---|
| E10 | **Payment-gateway long tail** (~49 gateways beyond our ~11) | OBSERVED as a class: 60 gateway add-ons in the demo builder/Plans matrix (individual gateways MENU-LEVEL) | Gateway *breadth* is WorkDo's one real catalogue advantage | **Community framework** — each gateway is a settings-doctype addition on Frappe Payments, added **per-tenant on demand**, never in bulk. Our market's three (JazzCash/Easypaisa/PayFast-PK) are already custom-queued and outrank all 49 — WorkDo's "PayFast" is the South-African gateway, not Pakistan's | L2 | Later, per-tenant | Days per gateway |
| E11 | **WooCommerce bridge** | Integration add-on (CATALOGUE): store sync between WooCommerce and the ERP | Ecommerce Integrations covers Shopify/Amazon/Unicommerce/Zenoti — not WooCommerce, which is common in PK retail | **Evaluate/build a bridge** after Ecommerce Integrations is live | L2 | Later (after W2) | 1–2 wks |
| E12 | **Legal Case Management pack** | Industry sub-menu class (CATALOGUE; not in the demo's opened packs) | No legal app in either KB pass | **Composition + small custom** — CRM + Projects + custom matter/case doctypes; build when a legal customer appears | L2 | Later | 1–2 wks |
| E13 | **Visitor Management** | Industry add-on (CATALOGUE) | No visitor/front-desk records | **Small custom doctype set** if a tenant asks | L2 | Later | Days |
| E14 | **vCard — digital business cards** | Customization add-on (CATALOGUE): public card page + QR per staff member | No vCard product | **Small standalone build** — candidate cheap Store add-on (public page + QR), not an ERP lane | L1 (public page) | Later | Days |
| E15 | **Rental billing model** (equipment/property rental as a product) | Industry add-on (CATALOGUE) | Asset Movement covers borrow/return; rental *billing* is not modelled | **Composition + small custom** over Assets + the Real Estate lease pack | L2 | Later | 1 wk |
| E16 | **Standalone feedback-form product** | Sales add-on (CATALOGUE) | Feedback exists per-surface (Helpdesk articles, Wiki); no standalone feedback forms | **Composition** over Web Forms + Helpdesk | L2 | Later | Days |
| E17 | **Call-centre hub UX** | Communication add-on (CATALOGUE): a call hub over call logs | Telephony TP Call Log wires at W2; a hub UX does not exist | **SPA wiring** over Telephony logs after W2 | L2 | Later (after W2) | Days |

### 1.3 Deliberately NOT extended (WorkDo-only, screened out)

Recorded so the list is complete; full reasoning in the map §5. External
SaaS syncs as a class (Salesforce, HubSpot, Pipedrive, Trello, Jira,
Asana, MS To Do, QuickBooks, Google Docs/Slides, OneNote, IndiaMART,
WHMCS, Google Wallet, Google Analytics) — the REST + Webhook pattern is
the standing answer. Strategy templates (Business Plan, PESTEL,
Planning). Meeting long tail (Jitsi, Whereby, Zoho, Livestorm). Telegram
channel. In-ERP Spreadsheet. Diagram editor. Financial Goal (a small
custom doctype if ever asked). Industry niches with no demand signal in
our market: Tour & Travel, Insurance (regulated), Newspaper Distribution,
DJ/Orchestra, Grant Management, Library Management.

---

## §2 Ours-only → our advantages (keep + surface)

Each item verified against the demo evidence and the map before claiming:
where WorkDo has the *function class* (e.g. their Double Entry add-on),
only the **depth difference the evidence supports** is claimed.

| # | Advantage | Why it is ours-only (evidence) |
|---|---|---|
| V1 | **True double-entry accounting depth** — full GL, multi-currency + Exchange Rate Revaluation (live, E7 lane 7), budgets, period closing, Journal Entry Templates (live, E7 lane 8) | WorkDo's base accounting is income/expense style; double-entry arrives via a $39 add-on and stays shallower (map §6). Their demo's invoice screens are summary-card simple — good UX (see §3), not GL depth |
| V2 | **Stock ledger depth** — valuation (FIFO/moving average), serial + batch tracking, multi-warehouse trees, stock reconciliation | WorkDo's Inventory add-on is right-sized but thin next to the ledger (map §6); no serial/batch spine was visible in the demo inventory |
| V3 | **The serial-number spine for vehicle businesses** — serial allocation at booking, PDI/quality inspection, handover + warranty card prints (EV pack, live on demo2, backend-accepted) | WorkDo's nearest is a generic Car Dealership add-on (CATALOGUE); no serial-spine workflow was observed. Our EV Showroom pack has no WorkDo equivalent at this depth |
| V4 | **Manufacturing engine** — BOM, Work Orders, Production Planning, job cards | No manufacturing module appears in WorkDo's demo inventory or the map's 113 rows. (Owner's SMB frame: not a selling point for today's market — a growth ceiling our tenants never hit) |
| V5 | **The provider platform itself** — Aureus-class operator console, customer portal, provisioning pipeline, entitlement JWTs, per-app + per-integration per-user-per-month pricing | WorkDo's SaaS core covers the function class (map A9) but not our console/portal screens, pricing model, or deploy discipline. This layer is Operqon's, already live |
| V6 | **Rektrs ID (Keycloak) SSO** — one identity across console, portal and tenants; MFA (TOTP + WebAuthn/passkeys), social sign-in, Cloudflare Turnstile | WorkDo sells auth as add-ons (Google 2FA, per-provider social sign-ins — 10 SKUs for what Keycloak does as one IdP configuration, map #98) |
| V7 | **Permissions granted at provisioning, from the tenant's entitlement set** — union-only, System Manager never narrowed (owner principle, live-tested through the Stock Balance fix lanes) | WorkDo's Roles screen (OBSERVED) is a per-workspace manual permission matrix — capable, but set by hand inside each workspace, not derived from what the tenant bought |
| V8 | **Pakistan's own gateways** — JazzCash, Easypaisa, PayFast-PK (custom, in queue; sandbox-proven path via Cursor) | Absent from WorkDo's 60 gateways too — their "PayFast" add-on is South Africa's gateway (map §2.14). Neither catalogue has them; ours are already designed for our stack |
| V9 | **Sendqon messaging** — our own SMS gateway platform (SIM gateway app + panel + signed mobile app) as the tenant messaging layer, tenant's own account | WorkDo's messaging is third-party WhatsApp add-ons — exactly the tenant-facing path the owner ruled out (2026-11-26). Ours is a platform we own, not an add-on we rent |
| V10 | **API as a platform native** — every DocType of every installed app carries REST + webhooks at no extra cost; this is the seam the whole wiring plan runs on | WorkDo sells API access as an $89 add-on (map #67) |
| V11 | **BI + a custom report builder roadmap** — Frappe Insights (W1) plus FR-002: an in-SPA report builder with field selection + date ranges (owner-specified) | No report-builder surface was observed in the WorkDo demo; their reporting is per-module lists/dashboards (MENU-LEVEL for most modules — claimed as "not observed", not "proven absent") |
| V12 | **Multi-company in one site with consolidated books** | ERPNext's company model is native. WorkDo's demo is workspace-siloed (each workspace its own world, OBSERVED structure); cross-workspace consolidation was not visible (MENU-LEVEL confidence) |
| V13 | **Open-source stack, owned end to end** — 49 censused community apps + built-ins, per-app replaceable; no per-tenant licence, no vendor release train inside the product | WorkDo's add-ons only run inside WorkDo; its update/security cadence is the vendor's (the audited 2024 snapshot already needed a security pass) |
| V14 | **EV Showroom industry pack — live** | The flagship industry asset; WorkDo's 93 SKUs include no EV-specific pack in the named 47 (CATALOGUE confidence) |

**Store/marketing note:** V1, V2, V5, V6, V8, V9 are the six to surface
first — they are the answers to the questions a PK/KSA SMB actually asks
(books depth, stock truth, who runs the platform, one login, local
payments, own-number SMS). V4 and V14 are proof-of-depth items for the
industry pages.

---

## §3 Both-have → workflow lessons from WorkDo's demo

Where both sides have the capability, but WorkDo's SMB-facing workflow is
visibly simpler. Each lesson is a **workflow idea** — what the user does,
in what order, with what on screen — to be implemented originally in our
surfaces. Nothing here copies their screens, text, or assets.

| # | Lesson (what WorkDo does) | Evidence | Where it lands in our plan |
|---|---|---|---|
| L-1 | **Invoice lists carry summary cards on top** (totals / paid / outstanding at a glance) **and a "Chase payment" action** on the invoice — the follow-up is one click from the list, not a separate dunning module visit | OBSERVED (Sales/Purchase invoice workflow notes) | SPA Sales + Finance list screens (L3): summary-card strip + a chase action wired to our dunning/reminder path (Sendqon/email). Add to the W-T wiring queue as a list-screen pattern |
| L-2 | **Card-grid views for Customers and Projects** — records as visual cards, not only tables | OBSERVED (Customers, Projects workflow notes) | The L2 generic renderer gains a card/grid view mode alongside the table, defaulting per-DocType; Projects and Customers first |
| L-3 | **Plan × add-on matrix** — plans are edited as a grid: rows = add-ons, columns = plans, ticks = included | OBSERVED (Plans workflow notes; 318 add-ons in the matrix) | Console plan editor (Cursor's provider side) + portal plan-comparison page. Our entitlement model (per app + per integration) maps onto the same grid shape |
| L-4 | **CRM as a kanban board first** — Leads open as a pipeline board, list second | OBSERVED structure (board present; demo workspace held 0 leads, so the live drag flow is MENU-LEVEL confidence) | Frappe CRM is L1 (own UI re-themed) and already board-centric — the lesson is a *check*: the re-theme acceptance must confirm the board is the default landing view, not buried |
| L-5 | **Hotel Rooms as a visual status board** — rooms by status, front-desk first screen | OBSERVED (Hotel Rooms workflow notes) | Hospitality PMS is L1 — keep its board as the landing screen in the re-theme. Pattern generalised: visual status boards are the preferred landing for operational L1 apps (also noted for the EV showroom's Display-warehouse board idea, EV-2 candidate) |
| L-6 | **Roles as one permission matrix grid** — modules × actions in a single editable grid per role | OBSERVED (Roles workflow notes) | Tenant Access surface (W-T4 Admin live paths): matrix-style role editing instead of per-doctype forms. (Console-side super-admin roles already follow the Aureus pattern) |
| L-7 | **Settings as grouped cards, each saving independently** — no single giant save | OBSERVED (Settings workflow notes; matches the Aureus console pattern we already adopted) | Extend from the console to tenant admin settings surfaces (W-T4): General Settings / Period Close / Access & Branches as per-card-save settings pages |
| L-8 | **One searchable add-on catalogue inside the product** — 332 add-ons in one builder list with the tenant's plan state visible | OBSERVED (add-on builder inventory) | Tenant Store surface: category-grouped, searchable catalogue with per-item entitlement state — our Store scope already includes apps/plugins/industry solutions; the lesson is the *single searchable list* UX over separate pages per type |
| L-9 | **Industry packs ship with demo-shaped data** — the demo workspace reads as a working business, not an empty shell | OBSERVED (demo workspace state across modules) | Industry-pack apply gains an optional **sample-data seeding** step (EV pack fixtures are the precedent); demo tenants for sales use the same packs |

---

## §4 The end-state picture — "ek poora behtareen software"

After the W0–W4 install train, the W-T wiring lanes, and the §1
extensions, Operqon is:

**One platform** — Rektrs ID (Keycloak) signs a user into the operator
console, the customer portal, and every tenant. The provider side
(console + portal + provisioning + entitlement-priced Store) is ours,
live, and enterprise-shaped (Aureus wave).

**One tenant ERP face** — the DreamsERP SPA for the daily product face
(Sales, Finance, Stock, POS — L3), one generic renderer (L2) carrying
the CRUD majority, and modern community apps re-themed inside the shell
(L1) where their own UI is the experience (CRM, Helpdesk, HRMS,
Insights, LMS).

**49 censused community apps + ERPNext built-ins** underneath — Payments,
HRMS, CRM, Helpdesk, Insights, LMS, Webshop, ZATCA (KSA Compliance),
FBR path, Moyasar for Saudi payments — each wired through the API every
Frappe app carries natively, each replaceable per app.

**17+ industry packages** on the Store shelf — the 16 assembled packages
plus Construction (#17), with the E2 preconfiguration SKUs multiplying
the shelf the way WorkDo's 93 do, except every one of ours sits on a
deeper engine. EV Showroom is the flagship: a serial-spine pack no
competitor in this comparison has.

**Pakistan + Saudi completeness** — JazzCash, Easypaisa, PayFast-PK,
FBR e-invoicing, ZATCA, Moyasar; messaging through the tenant's own
Sendqon account; no WhatsApp dependency anywhere in the product.

**And the depth WorkDo cannot match** — a real GL, a real stock ledger,
manufacturing when a tenant grows into it, permissions derived from
entitlements at provisioning, and a backend-first acceptance discipline
that proves every lane as the real user before it ships.

That is the complete product the owner asked for: everything available,
nothing rented from a vendor's release train, and the remaining queue
(wiring lanes, proof installs, per-tenant gateways) measured in weeks —
the 4–6-week SMB-parity path in census §8.5, extended by §1's list
without changing its shape.

---

## Appendix — claims marked MENU-LEVEL / unverified in this analysis

1. **POS terminal workflow** (WorkDo) — menu-only in the demo study; no
   workflow claim is made for it anywhere above.
2. **School, Hospital, Gym, Restaurant, Construction, Property list
   pages** — sub-menus read on screen; working screens not opened. §1's
   E1/E2 rest on the map's CATALOGUE evidence for these packs, not on
   observed workflows.
3. **CRM lead flow** — kanban structure observed; the demo workspace held
   0 leads, so no live lead lifecycle was seen (L-4 is labelled so).
4. **Individual payment gateways** (60) — observed as a class in the
   builder/Plans matrix; individual gateway screens not opened (E10).
5. **V11 (no WorkDo report builder)** — "not observed in the demo", not
   proven absent from their catalogue.
6. **V12 (cross-workspace consolidation)** — workspace-silo structure
   observed; consolidation absence is MENU-LEVEL confidence.
7. **V14 (no EV pack among WorkDo's 93)** — rests on the 47 named
   industry SKUs; ~46 SKUs are not publicly enumerated by WorkDo (map §0).
8. **Tour & Travel pack** (named in the demo's industry sub-menus) —
   MENU-LEVEL; it sits in §1.3 (skip) per the map §5 screening.
9. **OCR full review** — not run on any repo in either KB pass (needs a
   paid key or the owner's ChatGPT sign-in; standing rule). Unchanged by
   this analysis.

*Sources: WorkDo live-demo study 2026-11-28 17:22–17:32 PKT (browser,
read-only); WORKDO-FULL-MODULE-INDUSTRY-MAP-2026-11-28.md (commit
0461717); FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md + PART2 (commits
53b7615, 4a3e3df); SURFACE-API-WIRING-CENSUS-2026-11-28.md §8/§8.6.
Nothing was bought, installed, or copied.*
