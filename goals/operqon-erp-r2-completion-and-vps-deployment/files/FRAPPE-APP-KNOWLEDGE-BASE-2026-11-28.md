# Frappe App Knowledge Base — App-First Census (2026-11-28)

**Owner method directive (main chat, 2026-11-28 ~15:00 PKT):** "phly sab available
plugins frappe or thirdparty sab list kerty, phir unki documentation or API read
ker k knowledge base banaty, phir frontend DreamsERP ly k usky sath wire ker
dety — is terhna kam km kerna perta." — **Assemble, don't build, wherever a
proven app exists.** This KB extends the 2026-11-28 surface-wiring census
(`SURFACE-API-WIRING-CENSUS-2026-11-28.md`) and builds on the 2026-11-26
all-apps recon (`~/workspace/operqon-dreams/agpl-activation/AGPL-ACTIVATION-RECON-20261126.md`)
— recon facts are not re-derived; today's work adds fresh source-level evidence.

**Platform pin (live):** Frappe **16.55.1** / ERPNext **16.53.0**. Bench today
carries only frappe, erpnext, operqon_core, operqon_rag — every app below must
be baked into a tenant image and proof-installed before any tenant use
(recon §1/§3 path: wave bake → per-app proof install on a throwaway site →
executor allowlist/guard extension → catalogue activation → entitled tenants
only). **Nothing was installed anywhere by this lane.**

**Evidence method (today):** every candidate repo was shallow-cloned from its
real upstream (21 repos, `~/workspace/app-census-20261128/repos/`) and read
directly — LICENSE file, `hooks.py` (`required_apps`), pyproject
`frappe-dependencies` version ranges, DocType tree, whitelisted-API census, last
commit. The standing scan stack (code-review-free SKILL, Route 3) ran on every
repo that carries a USE verdict: **Semgrep** (`p/security-audit` + `p/python`,
`--metrics=off`), **Bandit**, **Gitleaks** — full-repo, results in §6. OCR
delegation review (Route 1) targets change-set diffs; for whole third-party
repos the equivalent manual API-surface review was applied instead (guest-endpoint
census, raw-SQL census, whitelisted-method census per repo — figures in each
entry) and a full `ocr review` was NOT run (it needs a paid API key or the
owner's ChatGPT sign-in, neither configured — standing rule). Assessed false
positives are recorded with the findings, per the skill.

**Headless rule applied to every verdict:** Frappe gives every DocType a REST
API by default (`/api/resource/<DocType>` + `/api/method/<app.api.fn>`), so an
app is headless-usable when its data model lives in DocTypes and its logic in
whitelisted methods — its own frontend (Desk pages / Vue SPA) is then ignored
and our DreamsERP-faced SPA wires to the same APIs. Apps whose value *is* their
frontend (POS terminals) are judged differently and say so.

---

## §1 — Feature-gap census → candidate apps

| SMB-essential gap (census source) | Candidates evaluated | Winner / route |
|---|---|---|
| **POS sale completion** — SPA POS cannot complete a sale; GAP-06 (census §3) | ERPNext built-in POS · POSNext · POS Awesome (upstream) · POS Awesome V15 fork (defendicon) · POS Prime | **Built-in POS doctypes + governed seam (custom, W-T1)**; POS Prime / fork = EVALUATE fallbacks |
| **HR & payroll** — no HR screens at all; Payroll doctypes absent (E8/D10) | Frappe HRMS · ECOSIRE GOSI/Mudad (build-to-order, paid) | **HRMS (install)**; KSA payroll pack stays custom/later |
| **CRM / leads** — no CRM screens (E9) | Frappe CRM · ERPNext built-in CRM doctypes | **Frappe CRM (install, sync OFF)**; built-ins remain the no-app default |
| **Projects / tasks** — landing cards unlinked, no screens | ERPNext built-in Projects · Frappe Gameplan | **Built-in Projects (wire SPA)**; Gameplan = discussions layer (install, Wave 1) |
| **Helpdesk / support tickets** — portal ticketing MISSING-ENDPOINT; no tenant helpdesk | Frappe Helpdesk (+ Telephony) | **Helpdesk (install)** — HD Ticket becomes the ticket store behind both surfaces |
| **WhatsApp** — portal card exists | frappe_whatsapp · Four Whats Net · all WhatsApp bridges | **AVOID — owner decision 2026-11-26**: no WhatsApp option; **Sendqon integration** (custom) is the messaging path |
| **Saudi ZATCA e-invoicing** — portal Integrations card (ZATCA) | KSA Compliance (LavaLoon) · zatca_erpgulf (ERPGulf) · Beveren KSA ZATCA (closed) · zatca_high_speed | **KSA Compliance (install)**; ERPGulf = EVALUATE second source |
| **Pakistan FBR e-invoicing** — portal Integrations card (FBR) | Pakistan-Compliance / fbr_e_invoicing (DeliveryDevs) | EVALUATE (recon evidence; scan + FBR sandbox proof owed) |
| **Advanced reporting / BI** — FR-002 custom report builder; fixed reports only | Frappe Insights · Frappe Report Builder / Query Report (core) | **Insights (install)** for BI + **core Report Builder** under the FR-002 SPA surface |
| **Payments plumbing** — LMS/Webshop prerequisites; gateway settings | Frappe Payments | **Payments (install, Wave 0)** — MIT |
| **Learning / training** — no surface | Frappe LMS | **LMS (install, after Payments)** |
| **Knowledge base / docs** | Frappe Wiki | **Wiki (install, Wave 1)** |
| **Team chat** | Frappe Raven | **Raven (install, Wave 1)** |
| **Site/landing builder** — console landing-pages/site-builder MISSING-ENDPOINTs are provider-side; tenant website pages | Frappe Builder | **Builder (install, Wave 1, pin ≥ 1.31.0)** |
| **Loans** | Frappe Lending | **Lending (install, Wave 2)** |
| **Schools** | Frappe Education | **Education (install, Wave 2)** |
| **Clinics** | Marley Healthcare (earthians) | **Healthcare (install, Wave 2)** |
| **E-commerce storefront** | Frappe Webshop (+ Payments) | **Webshop (install, Wave 3)** |
| **Marketplace sync (Shopify/Amazon…)** | Frappe Ecommerce Integrations | **Ecommerce Integrations (install, Wave 2)** — tenant's own creds |
| **Shipping aggregators** | ERPNext Shipping | **ERPNext Shipping (install, Wave 2)** — tenant's own aggregator account |
| **JazzCash / Easypaisa** — portal Integrations cards; provider webhooks NOT_LIVE | *No proven open-source Frappe app exists (S8 research, re-confirmed by today's search)* | **Custom build stays** (owner-gated merchant-live) |
| **PayFast (PK)** | No upstream app | **Custom (in flight, Cursor #160/#171 sandbox)** |

---

## §2 — Platform built-ins (already on the bench — no install, no new licence)

### 2.1 ERPNext built-in POS — **USE (GAP-06 backend)**
- **Purpose:** the POS data engine already live on every tenant: POS Profile,
  POS Opening Entry, POS Closing Entry, POS Invoice (+ merge/consolidation
  into Sales Invoice), POS Settings.
- **Key endpoints:** REST on the POS doctypes + ERPNext's POS API methods
  (`erpnext.accounts.doctype.pos_invoice.pos_invoice`, POS opening/closing
  controllers). Desk POS is today's register of record *because* these work.
- **Headless fit:** perfect — the missing piece was never an engine, it is the
  **governed seam in operqon_core** (complete sale / hold / resume) + SPA
  wiring (census W-T1). Third-party POS apps sell frontends we do not want.
- **Licence:** GPL-3.0 (ERPNext itself). **Verdict: USE** — GAP-06 stays a
  seam build, sized as a seam, not as a POS build.

### 2.2 ERPNext built-in Projects — **USE (wire only)**
- **Purpose:** Project, Task, Timesheet, Activity Type / Activity Cost,
  Project Update — complete PM data model in core, 0 SPA screens today.
- **Endpoints:** REST on those doctypes; no custom API needed.
- **Verdict: USE** — the E9 Projects lane shrinks to SPA surfaces + governed
  seams over core doctypes. No app to install.

### 2.3 ERPNext built-in CRM doctypes — **USE (default) / superseded per-tenant by Frappe CRM**
- Lead, Prospect, Opportunity, Campaign, Appointment, Contract — exist on the
  bench today (0 rows, E9 recon). Tenants without the CRM app keep these; the
  SPA CRM lane reads whichever model the tenant is entitled to.
- **Verdict: USE** as the baseline; see Frappe CRM (§3.3).

### 2.4 Frappe core Report Builder / Query Report / Script Report — **USE (FR-002 engine)**
- FR-002 (owner, 2026-11-26) wants an in-SPA custom report builder: source
  pick, field selection, filters incl. date ranges, grouping/totals, save +
  re-run, export. Frappe core already stores reports as DocTypes
  (`Report` with `report_type = Report Builder / Query Report`), enforces
  role permissions, and runs them via `/api/method/frappe.desk.query_report.run`
  + the Report Builder REST surface. Print Designer is **built into v16 core**
  (the standalone app is archived — §5).
- **Verdict: USE** — FR-002 becomes an SPA surface over core report doctypes +
  Insights for the BI tier; no reporting engine is built.

---

## §3 — Frappe-official apps (cloned + scanned today)

### 3.1 payments — frappe/payments — **USE (Wave 0)**
- **Purpose:** payment-gateway plumbing: Payment Gateway + per-gateway
  Settings doctypes (Stripe, Razorpay, PayPal, Braintree, GoCardless, Mpesa,
  Paymob, Paytm). Hard prerequisite of LMS and Webshop.
- **Key DocTypes:** Payment Gateway, Stripe Settings, Razorpay Settings, …
  (10 settings doctypes). **API:** 25 whitelisted methods in 13 files
  (checkout/webhook handlers per gateway).
- **Install notes:** `version-16` branch, v16.0.1, last commit 2026-11-17.
  No `required_apps`. Gateway credentials are per-tenant self-service.
- **Licence:** **MIT** (license.txt read today).
- **Scans:** gitleaks 3 hits — all in `test_mpesa_settings.py` (test fixture
  values, assessed **false positives**); bandit 5 (LOW ×1, MEDIUM B113 ×4 —
  requests-without-timeout in gateway calls); semgrep 4 (var-in-href ×3,
  unquoted-attribute ×1 — its own Desk UI, ignored headless).
- **Verdict: USE** — bake first; it unlocks two other apps.

### 3.2 hrms — frappe/hrms — **USE (Wave 3 sequencing; E8 map runs on it)**
- **Purpose:** the full HR + Payroll layer ERPNext v16 removed: Employee
  lifecycle, Attendance/Leave, Payroll, Recruitment, Performance, Expenses.
  This install **is** the D10 restore the owner ordered 2026-11-26.
- **Key DocTypes (verified in tree):** Employee, Attendance, Leave
  Application, **Salary Structure, Salary Slip, Payroll Entry**, Employee
  Onboarding/Separation, Job Applicant/Offer, Appraisal, Expense Claim,
  Shift Type, Employee Checkin (700+ doctypes/classes; 701 py files).
- **API:** 244 whitelisted methods in 74 files + standard REST on all
  doctypes; `hrms.api` (roster, oauth, system settings).
- **Install notes:** `version-16`, v16.60.1, last commit **2026-11-27**
  (yesterday — the most actively maintained app in this census).
  `required_apps = [frappe/erpnext]`. Largest fixture set of the set —
  proof-install scrutiny per recon §8 (payroll consequences).
- **Licence:** **GPL-3.0**.
- **Scans:** gitleaks clean; bandit 11 (LOW ×3, MEDIUM B608 ×5 — Frappe
  query-builder SQL idiom, B113 ×2, B307 ×1); semgrep 7 on 1,649 files
  (var-in-href ×4, unquoted-attribute ×3 — own UI). Nothing blocking.
- **Headless fit:** full — SPA HR screens (E8) wire to HRMS doctypes; PK
  payroll localisation (statutory components) is tenant configuration on
  Salary Structure, not code. **KSA GOSI/Mudad payroll has NO open-source
  app** (only paid build-to-order offers) — a later custom country pack,
  recorded in §5.
- **Verdict: USE.**

### 3.3 crm — frappe/crm — **USE (Wave 3, sync OFF)**
- **Purpose:** modern CRM: lead/deal pipeline, activities, call logs,
  telephony hooks, SLA, insights dashboards.
- **Key DocTypes (verified):** CRM Lead, CRM Deal, CRM Task, CRM Call Log,
  CRM Organization, CRM Lead Status / Deal Status, CRM Service Level
  Agreement, CRM Twilio/Exotel Settings, ERPNext-CRM sync doctypes.
- **API:** 160 whitelisted methods in 44 files (`crm.api`: doc, activities,
  contact, dashboard, email, …) + REST on all doctypes.
- **Install notes:** `version-16`, v16.5.0, last commit 2026-11-26. No
  `required_apps`. **Keep `enable_frappe_crm_data_synchronization = 0`**
  (recon §5) — two lead systems coexist by entitlement, never by sync.
- **Licence:** **AGPL-3.0** → activation carries the §13 in-app source-offer
  duty (operqon_core SPA About surface, recon §4).
- **Scans:** gitleaks clean; bandit 19 (HIGH B324 ×1 — weak-hash use,
  MEDIUM B608 ×3, B113 ×3, B314 ×1; rest LOW); semgrep 6 on 1,085 files
  (var-in-href ×4, defused-xml ×1, sha1 ×1). Nothing blocking; the B324/sha1
  pair is noted for the proof-install review.
- **Verdict: USE.**

### 3.4 helpdesk + telephony — frappe/helpdesk, frappe/telephony — **USE (Wave 2)**
- **Purpose:** support ticketing with SLA, agent assignment, customer portal,
  knowledge articles. **This is the ticket store the portal's missing
  ticketing endpoint (census §2) should be backed by** — HD Ticket on the
  tenant, not a new provider-side ticket store.
- **Key DocTypes (verified):** HD Ticket, HD Agent, HD Team, HD Customer,
  HD Article (+ Category/Feedback), HD Service Level Agreement, HD Ticket
  Priority/Status/Type, HD Settings, HD Saved Reply. Telephony: TP Call Log,
  TP SMS Log, Twilio/Exotel Settings.
- **API:** helpdesk 144 whitelisted methods in 43 files (`helpdesk.api`: doc,
  article, customer, dashboard, …); telephony 21 in 5 files.
- **Install notes:** helpdesk `version-16` v16.2.2, last commit 2026-11-25,
  `required_apps = [frappe/telephony]` (hard — bake telephony first, same
  wave). Telephony `develop` branch v0.0.1, last commit 2026-11-17; it is a
  companion, **not a standalone product**. Calling needs the tenant's own
  Twilio/Exotel account (service-provider principle).
- **Licence:** **AGPL-3.0** (both) → §13 duty on activation.
- **Scans:** helpdesk — gitleaks clean, bandit **2** (MEDIUM B608 ×2),
  semgrep 5 on 1,127 files (var-in-href ×5, own UI). Telephony — gitleaks
  clean, bandit 5, semgrep **0** on 71 files. Cleanest pair in the census.
- **Verdict: USE** (telephony as companion only).

### 3.5 insights — frappe/insights — **USE (Wave 1)**
- **Purpose:** BI: multi-source data connections, no-code query builder +
  SQL, charts, dashboards, alerts — the advanced tier above FR-002.
- **Key DocTypes (verified, v3 line):** Insights Data Source v3, Insights
  Query v3, Insights Chart v3, Insights Dashboard v3, Insights Workbook,
  Insights Team, Insights Alert, Insights Table v3, Insights Resource
  Permission.
- **API:** 59 whitelisted methods in 20 files (`insights.api`: dashboards,
  data_sources, data_store, authoring, alerts, search) + REST on doctypes.
- **Install notes:** `version-3` branch, v3.51.0, last commit 2026-11-26.
  No `required_apps`. BI reads across all tenant data — the proof install
  must verify Insights' resource-permission scoping on this pin (recon §4).
- **Licence:** **AGPL-3.0** → §13 duty.
- **Scans:** gitleaks 1 hit — `generic-api-key` pattern on a DocType JSON
  field definition (schema, assessed **false positive**); bandit 37 (HIGH
  B324 ×2, rest LOW/MEDIUM — the largest bandit count among official apps,
  driven by its data-store/SQL tooling); semgrep 7 on 844 files
  (**avoid-pickle ×3** in data-store internals, md5 ×2, var-in-href ×2).
  The pickle use is inside Insights' own cached-query path — recorded as a
  proof-install review item, not a blocker for an official Frappe app whose
  threat model is authenticated tenant users.
- **Verdict: USE** — with the permission-scoping proof named in the recon.

### 3.6 lms — frappe/lms — **USE (after Payments)**
- **Purpose:** courses, batches, quizzes/assignments, certificates, live
  classes, jobs board.
- **Key DocTypes (verified):** LMS Course, LMS Batch, LMS Enrollment, LMS
  Certificate (+ Request/Evaluation), LMS Quiz, LMS Assignment, LMS Live
  Class, LMS Payment, Job Opportunity, LMS Job Application (90+ doctypes).
- **API:** 191 whitelisted methods in 25 files (the largest API surface in
  the census — its SPA is fully API-driven, so headless reuse is proven by
  its own architecture).
- **Install notes:** `version-16`, v16.4.0, last commit 2026-11-20.
  `required_apps = [frappe/payments]` (hard). Paid courses take the tenant's
  own gateway via Payments.
- **Licence:** **AGPL-3.0** → §13 duty.
- **Scans:** gitleaks clean; bandit 17 (LOW-heavy; MEDIUM B608 ×3, B318/B310
  ×1 each); semgrep 32 on 1,346 files (var-in-href ×27 — its own frontend,
  which we ignore; defused-xml ×3; urllib ×1; http ×1).
- **Verdict: USE.**

### 3.7 gameplan — frappe/gameplan — **USE (Wave 1, discussions layer)**
- **Purpose:** team discussions, pages/wiki-style docs, polls, and light
  project/task collaboration (GP Project, GP Task).
- **Key DocTypes (verified):** GP Project, GP Task, GP Discussion, GP Page,
  GP Comment, GP Team, GP Poll.
- **API:** 97 whitelisted methods in 21 files (`gameplan.api`).
- **Install notes:** `develop` branch, v0.1.38, last commit 2026-11-25.
  No `required_apps`. **Scope honesty:** Gameplan does NOT replace ERPNext
  Projects (§2.2) — it is the collaboration layer; timesheets/resource
  planning stay in core Projects.
- **Licence:** **AGPL-3.0** → §13 duty.
- **Scans:** gitleaks clean; bandit 25 (MEDIUM B608 ×10 — discussion search
  SQL idiom; B314 ×2; rest LOW); semgrep 11 on 660 files (defused-xml ×6,
  var-in-href ×5).
- **Verdict: USE.**

### 3.8 lending — frappe/lending — **USE (Wave 2)**
- **Purpose:** loans end-to-end: Loan Application, Loan, disbursement,
  accrual, repayment, collection cases.
- **Key DocTypes (verified):** Loan, Loan Application, Loan Accrual Repost,
  Loan Adjustment, Collection Case, Dunning Rule, Lending Settings.
- **API:** 42 whitelisted methods + REST. `required_apps = [erpnext]`.
- **Install notes:** `version-16`, v16.8.3, last commit 2026-11-25.
- **Licence:** **GPL-3.0**.
- **Scans:** the cleanest result in the census — gitleaks clean, **bandit 0
  findings, semgrep 0 findings on 683 files**.
- **Verdict: USE.**

### 3.9 education — frappe/education — **USE (Wave 2)**
- **Purpose:** schools/institutes: students, courses, assessment, fees.
- **Key DocTypes (verified):** Student (via Education doctypes), Course,
  Course Schedule, Assessment Plan/Result, Academic Term/Year, Program.
- **API:** 67 whitelisted methods + REST. `required_apps = [erpnext]`.
- **Install notes:** `version-16`, v16.0.1, last commit **2026-10-14** — the
  slowest cadence in the official set (6 weeks at census date); acceptable
  for its scope, noted.
- **Licence:** **GPL-3.0** (licence file verified today — the recon had this
  flagged "verify before listing"; verified).
- **Scans:** gitleaks clean; bandit 8 (all MEDIUM B608); semgrep 1 on 509
  files (var-in-href).
- **Verdict: USE.**

### 3.10 healthcare — earthians/marley — **USE (Wave 2)**
- **Purpose:** clinics/hospitals: patients, encounters, appointments, lab,
  pharmacy, ABDM (India) integration.
- **Key DocTypes (verified):** Patient, Patient Encounter, Clinical
  Procedure, Appointment Type, Code System/Value sets, Healthcare Settings
  family (200+ doctypes; 499 py files).
- **API:** 203 whitelisted methods + REST. `required_apps = [frappe/erpnext]`.
- **Install notes:** `version-16`, v16.9.0, last commit **2026-11-27**.
- **Licence:** **GPL-3.0**.
- **Scans:** gitleaks 1 hit — schema-JSON field name, assessed **false
  positive**; bandit 4 (**HIGH B413 ×2 — pycrypto import**, a deprecated
  crypto library, in its encryption helpers; MEDIUM B113 ×1; LOW ×1);
  semgrep 12 on 994 files (all unquoted-attribute-var, own UI). The B413
  pair is a named proof-install review item (replace/confirm before any
  tenant handles patient data).
- **Verdict: USE** with the B413 review item.

### 3.11 webshop — frappe/webshop — **USE (Wave 3, after Payments)**
- **Purpose:** tenant e-commerce storefront: Website Item catalogue, cart,
  wishlist, reviews, offers.
- **Key DocTypes (verified):** Website Item, Webshop Settings, Wishlist /
  Wishlist Item, Item Review, Website Offer.
- **API:** 33 whitelisted methods + REST. `required_apps = [payments,
  erpnext]` (both hard).
- **Install notes:** `version-16` (package version string is upstream's
  0.0.1 placeholder), last commit 2026-11-19. Storefront adds website
  routes — the recon §5 route-survival proof (tenant login + SPA routes
  survive) is mandatory at proof install.
- **Licence:** **GPL-3.0**.
- **Scans:** gitleaks clean; bandit 3; semgrep 21 on 184 files — concentrated
  in its own storefront templates (var-in-href ×9, var-in-script-tag ×5,
  **template-unescaped-with-safe ×2**). Unlike other apps, Webshop's
  frontend *is* a tenant-facing surface, so these two unescaped-template
  hits are recorded as a proof-install review item rather than ignored.
- **Verdict: USE** with route-survival + template review items.

### 3.12 ecommerce_integrations — frappe/ecommerce_integrations — **USE (Wave 2)**
- **Purpose:** Shopify / Amazon SP-API / Unicommerce / Zenoti sync: orders,
  items, inventory, fulfilment logs.
- **Key DocTypes (verified):** Shopify Setting, Amazon SP API Settings,
  Unicommerce Channel, Zenoti Settings, Ecommerce Integration Log,
  Ecommerce Item.
- **API:** 21 whitelisted methods + REST + per-platform webhooks.
  `required_apps = [frappe/erpnext]`.
- **Install notes:** `version-16`, v1.17.0, last commit 2026-11-11. All
  platform credentials are the tenant's own (service-provider principle).
- **Licence:** **GPL-3.0**.
- **Scans:** gitleaks 10 hits — **all** in DocType schema JSON (field names)
  and test fixtures, assessed **false positives**; bandit 10 (LOW ×5,
  MEDIUM B113 ×2 / B608 ×3); semgrep **0** on 231 files.
- **Verdict: USE.**

### 3.13 erpnext_shipping — frappe/erpnext-shipping — **USE (Wave 2)**
- **Purpose:** shipping aggregators (LetMeShip, SendCloud, Packlink):
  parcels, rates, labels.
- **Key DocTypes (verified):** LetMeShip, SendCloud, Parcel Service,
  Parcel Service Type.
- **API:** 4 whitelisted methods + REST (small, focused app: 31 py files).
- **Install notes:** `version-16`, v16.1.0, last commit 2026-11-26.
  Aggregator account is the tenant's own.
- **Licence:** **MIT** (licence file verified today — the recon had this
  flagged "verify"; verified).
- **Scans:** gitleaks clean; bandit 6 (all MEDIUM B113 —
  requests-without-timeout to aggregator APIs); semgrep **0** on 64 files.
- **Verdict: USE.**

### 3.14 wiki — frappe/wiki — **USE (Wave 1, with a named review item)**
- **Purpose:** knowledge base / docs sites with GitHub sync and revision
  history.
- **Key DocTypes (verified):** Wiki Page, Wiki Document, Wiki Revision,
  Wiki GitHub Connection, Wiki Git Sync Log, Wiki Feedback.
- **API:** 77 whitelisted methods + REST.
- **Install notes:** `version-3` branch, v3.5.0, last commit 2026-11-12.
- **Licence:** **MIT** (verified today).
- **Scans:** the noisiest official app — gitleaks 2 (schema/test class,
  assessed false positives); bandit 30 (**HIGH B501 ×2 — requests with
  certificate verification disabled**, HIGH B324 ×2, MEDIUM B608 ×17);
  semgrep 27 on 604 files (**disabled-cert-validation ×2**,
  template-unescaped-with-safe ×6, sha1 ×4). The cert-validation findings
  sit in Wiki's outbound GitHub-sync path: **GitHub sync stays disabled
  until that code path is reviewed at proof install**; page authoring/
  serving is unaffected.
- **Verdict: USE** with the sync-review condition.

### 3.15 builder — frappe/builder — **USE (Wave 1, pin discipline)**
- **Purpose:** visual website/landing-page builder (the tenant-side answer
  to page building; the console's landing-pages panel is provider-side and
  stays Cursor's API build).
- **Key DocTypes (verified):** Builder Page, Builder Component, Block
  Template, Builder Client Script, Builder Plugin.
- **API:** 98 whitelisted methods + REST.
- **Install notes:** `develop` branch, last commit **2026-11-28 (today)** —
  the freshest repo in the census. **Pin ≥ v1.31.0** (earlier releases were
  AGPL; recon §6). Proof install must run the route-survival check
  (Builder can own a site's home page — recon §5).
- **Licence:** **MIT** at the current line (LICENSE read today).
- **Scans:** gitleaks clean; bandit 56 — the largest count in the census
  (HIGH B324 ×3; MEDIUM B102 ×1 — `exec` use; LOW-heavy tail). Builder
  **executes page/client scripts by design** — its risk class is inherent
  to a site builder and is governed by who gets Builder access
  (System Manager-class roles only, per-tenant), recorded here rather
  than treated as a defect. Semgrep 10 on 791 files.
- **Verdict: USE** with pin + role-gating conditions.

### 3.16 raven — frappe/raven — **USE (Wave 1, with a named review item)**
- **Purpose:** team chat (channels, DMs, threads) on Frappe realtime;
  optional AI bots.
- **Key DocTypes (verified):** Raven Workspace, Raven User, Raven Message
  family, Raven Push Token, Raven AI Bot / AI Function.
- **API:** 127 whitelisted methods + REST + realtime events.
- **Install notes:** `develop` branch, v3.2.0, last commit 2026-11-16.
- **Licence:** **AGPL-3.0** → §13 duty.
- **Scans:** gitleaks clean; bandit 8 (HIGH B324 ×1; rest LOW/MEDIUM);
  semgrep 7 on 1,336 files — **JWT class: jwt-hardcoded-secret ×2,
  jwt-none-alg ×2, unverified-jwt-decode ×1** (in Raven's bot/external
  integration helpers), md5 ×1, var-in-href ×1. Recorded as a
  proof-install review item: confirm those JWT paths are not reachable
  with tenant data before enabling bot integrations; core chat is
  session-authenticated.
- **Verdict: USE** with the JWT review item.

---

## §4 — Third-party apps (cloned + scanned today unless stated)

### 4.1 ksa_compliance — LavaLoon (lavaloon-eg/ksa_compliance) — **USE (ZATCA primary)**
- **Purpose:** Saudi ZATCA e-invoicing, Phase 1 + Phase 2: UBL XML
  generation, cryptographic signing (CSID/EGS onboarding), clearance
  (B2B) + reporting (B2C), QR codes, compliant print formats, rejection/
  resend, sandbox support. Frappe Cloud Marketplace-listed, free.
- **Key DocTypes (verified):** ZATCA Business Settings, ZATCA Phase 1
  Business Settings, ZATCA EGS, ZATCA Integration Log, ZATCA Invoice
  Counting Settings, ZATCA Precomputed Invoice, Sales Invoice Additional
  Fields, Additional Buyer/Seller IDs, Registration Type.
- **API / integration shape:** hooks-driven on Sales Invoice / POS Invoice
  submit (no tenant-facing API needed); 22 whitelisted methods in 9 files
  (onboarding wizard, compliance checks, XML generation —
  `ksa_compliance.api`-family + doctype controllers).
- **Compatibility evidence:** pyproject declares
  `frappe = ">=15.0.0,<17.0.0"` — **v16 is in the declared range**; single
  `master` line, v0.62.0, last commit 2026-11-10; multiple independent
  implementation guides (2026) document v15+v16 installs. No
  `required_apps`.
- **Licence:** **AGPL-3.0** (LICENSE read today) → §13 source-offer duty
  on activation, same as the official AGPL apps.
- **Scans:** gitleaks clean; bandit 10 (LOW ×4, MEDIUM B113/B306/B608);
  **semgrep 0 findings on 182 files** — the cleanest third-party result
  in the census. Guest endpoints: **0** (`allow_guest` census) — nothing
  public-facing.
- **Risks / conditions:** (i) live submission follows the same discipline
  as FBR: full sandbox cycle first, tenant's own ZATCA onboarding (OTP
  from the Fatoora portal is the tenant's step); (ii) ZATCA rules change
  — LavaLoon's release cadence (0.62.0, monthly-ish tags) is the
  mitigation; (iii) our ERPNext pin 16.53.0 predates the 16.54 tax-
  rounding patch that ERPGulf's README flags — irrelevant to this app's
  own code but noted for the ZATCA proof cycle.
- **Verdict: USE** — install at the compliance wave; SPA surface = invoice
  status/compliance views over its doctypes, configuration via its
  settings doctypes.

### 4.2 zatca_erpgulf — ERPGulf (ERPGulf/zatca_erpgulf) — **EVALUATE (second source)**
- **Purpose:** ZATCA Phase 2: CSR/certificate onboarding, clearance +
  reporting for Sales and POS invoices, credit/debit notes, QR, PDF/A-3,
  dashboard + comparison reports. Marketplace-listed.
- **Key DocTypes (verified):** Zatca Erpgulf Setting, Zatca Multiple
  Setting, Zatca POS Table, Zatca Erpgulf Success Log, Zatca Erpgulf
  Event Log.
- **API:** 25 whitelisted methods in 11 files; hooks on Sales/POS Invoice.
- **Compatibility:** pyproject `frappe = ">=14.0.0,<17.0.0"`; v3.0.1,
  last commit 2026-11-21; upstream announced a v16 line in Feb 2026 and
  its README tracks ERPNext v16.54.0's rounding patch (warns of ZATCA
  warnings BR-S-08/BR-CO-10/BR-CO-13 on unpatched combinations — our
  16.53.0 pin is *below* that patch, so the warning class differs;
  record for the proof cycle).
- **Licence:** **MIT**.
- **Scans:** gitleaks clean; bandit 23 (HIGH B324 ×1; MEDIUM B318 ×3 —
  XML parsing hardening class, B608 ×7, B704 ×1; LOW B405 ×7 — XML
  imports, expected in an XML app); semgrep 14 on 180 files
  (use-defused-xml ×10 — recommendations of the same class, insecure-uuid
  ×3, md5 ×1). Noisier than KSA Compliance on every axis.
- **Open questions:** upstream also ships a companion app
  (`claudion4saudi`) and a separate `zatca_erpgulf_sync` variant that
  routes through ERPGulf's Claudion cloud — **any variant that sends
  invoice data through a third-party cloud is disqualified** under the
  service-provider principle; the in-bench app itself must be confirmed
  fully self-contained at proof time.
- **Verdict: EVALUATE** — held as the fallback if KSA Compliance fails
  its proof install or sandbox cycle.

### 4.3 POS Prime — ravindu2012/pos-prime — **EVALUATE (POS fallback)**
- **Purpose:** modern POS terminal UI over **standard ERPNext POS
  doctypes only — zero custom DocTypes** (verified: no doctype tree in
  the repo), so its data model fit is perfect by construction.
- **API:** 46 whitelisted methods in 12 files (session/catalogue/checkout
  helpers over POS Invoice).
- **Compatibility:** pyproject `frappe/erpnext = ">=14.0.0,<17.0.0"`;
  README badges v14|v15|v16 and handles the v16 `/desk/` prefix.
- **Licence:** **GPL-3.0**.
- **Scans:** gitleaks clean; bandit 2 (MEDIUM B608 ×2); **semgrep 0 on
  227 files**. Guest endpoints 0.
- **Risks:** v1.1.0, **single maintainer**, last commit **2026-08-23**
  (3 months stale at census date) — bus-factor is the risk, not code.
  And per §2.1, a POS *frontend* is not what GAP-06 lacks; POS Prime
  earns a place only if the SPA POS surface wants a reference
  implementation or a stopgap terminal.
- **Verdict: EVALUATE** — proof-install decides; not on the critical path.

### 4.4 POS Awesome V15 fork — defendicon/POS-Awesome-V15 — **EVALUATE (hardening gate)**
- **Purpose:** the community-carried continuation of POS Awesome
  (offline POS, shifts, coupons, gift cards, Mpesa) after upstream
  stalled (§5).
- **Key DocTypes (verified):** POS Opening/Closing Shift, POS Coupon,
  POS Gift Card, POS Cash Movement, POS Invoice Submission Ledger,
  Scale Barcode Settings, + POS Awesome settings family (30+ doctypes —
  it brings its **own** POS data model alongside ERPNext's).
- **API:** 188 whitelisted methods in 59 files.
- **Compatibility:** pyproject declares `frappe/erpnext >=15.0.0,<17.0.0`
  and the README claims v15+v16 support; release notes show active
  v16-compat work (15.36.0, Sep 2026) **but** the version line is still
  15.x and one release note reads "pin ERPNext to v15.x" — treat v16 as
  *claimed, not proven*.
- **Licence:** **GPL-3.0**.
- **Scans — the weakest in the census:** bandit **100 findings**
  (**HIGH B602 ×1 — subprocess with shell=True**, MEDIUM B608 ×67,
  B603/B607 ×15); semgrep 11 on 1,009 files (**exec-detected ×1,
  subprocess-shell-true ×1**, unknown-value-with-script-tag ×9);
  raw-SQL census: **103 `frappe.db.sql(` call sites**. Gitleaks 1 hit
  (schema-JSON class, false positive).
- **Verdict: EVALUATE with a hardening gate** — no tenant exposure
  until the shell/exec sites are reviewed and the v16 proof install
  passes; behind POS Prime in the fallback order despite the larger
  feature set, because its data model duplicates the POS truth.

### 4.5 fbr_e_invoicing — DeliveryDevs Pakistan-Compliance — **EVALUATE**
- Not re-cloned today; verdict rests on the 2026-11-26 recon (hooks read
  on GitHub that day): `version-16` is the default branch, MIT,
  `required_apps = [erpnext]`, adds custom fields to Sales Invoice /
  POS Invoice for FBR Digital Invoicing.
- **Conditions before any USE verdict:** (i) today's scan stack run on
  the pinned commit; (ii) the standing rule — live FBR submission stays
  gated on **our own FBR sandbox proof** with the tenant's own FBR
  credentials (service-provider principle).
- **Verdict: EVALUATE** (install-wave W3 candidate per recon).

### 4.6 ury — ury-erp/ury — **EVALUATE (recon Wave 4)**
- Not re-cloned today; recon evidence stands: version unpinned upstream,
  `required_apps = [erpnext]`, restaurant POS/KDS doctypes. Proof
  install decides; never co-activate with another POS app on the same
  site without a joint proof (recon §5).
- **Verdict: EVALUATE.**

### 4.7 Beveren "KSA ZATCA E-Invoicing" — **EVALUATE (last resort)**
- Marketplace-approved commercial app (Beveren Software, Dammam);
  feature list is complete (clearance/reporting, multi-company,
  retention, audit trail) but **source is not public** — it cannot be
  scanned, forked, or source-offered, which breaks this KB's evidence
  standard. Only if both open ZATCA sources fail proof.
- **Verdict: EVALUATE (documented, unscannable).**

---

## §5 — Excluded (AVOID) and what stays custom

**AVOID — owner decision:**
- **frappe_whatsapp and every WhatsApp bridge** (incl. marketplace
  "Four Whats Net"): owner, 2026-11-26 ~20:31 PKT — *"WhatsApp Wala
  option nahi dena wo hum sendqon KO integration kerwain gy."* No
  WhatsApp option is offered to tenants, in any wave. Messaging =
  **Sendqon integration** (tenant's own Sendqon account; integration-
  class custom work, already queued). These apps were evaluated only
  to record the exclusion, per the owner's instruction.

**AVOID — evidence:**
- **POSNext (pos_next)** — v15-only stable, no v16 line (recon §4).
  Blocked-on-upstream; never force, never downgrade for it.
- **POS Awesome upstream (yrestom → ucraft-com)** — README still targets
  ERPNext **v14** (`version-14` install branch); a production user's
  pinned-versions record documents its removal in 2026 with the reason
  "upstream stopped updating in 2024-02". Superseded by the fork (§4.4).
- **zatca_high_speed (fuhaed)** — vendor's own page: built for
  **Frappe/ERPNext v15 only**. Fails our pin outright.
- **frappe/drive** — repo archived upstream ("part of Frappe Suite").
- **frappe/print_designer (app)** — archived; the capability is **in
  Frappe v16 core**. Nothing to install.
- **frappe/books, frappe/press** — not bench apps (desktop / hosting
  infrastructure).
- **biometric-attendance-sync-tool** — not a bench app; a LAN-side
  tool the tenant runs beside their device. Catalogue listing +
  delivery note only (recon §6).
- **ECOSIRE build-to-order apps** (ZATCA-for-POS, GOSI/Mudad payroll,
  Qiwa/Muqeem sync) — paid commissioned builds ($999+ indicative), not
  installable catalogue apps; out of the assemble-don't-build path
  (their existence is recorded so the gap is known-priced).

**Stays custom (no suitable app exists):**
- **JazzCash / Easypaisa** tenant integrations + the provider-side
  merchant-live wiring — no proven open-source Frappe app (S8,
  re-confirmed today). PayFast completion likewise custom (Cursor).
- **Sendqon integration** (messaging) — our own platform, by design.
- **KSA payroll localisation (GOSI / Mudad WPS / EOSB)** — no
  open-source app; a later country pack on HRMS. (PK payroll packs are
  likewise tenant configuration on HRMS Salary Structures.)
- **Governed seams in operqon_core** (census W-T1…W-T8): POS sale
  completion over built-in doctypes, lifecycle submit/cancel/amend,
  SO→SI link, governed edits, POS Devices contract, RAG Settings
  surface, list exports. Apps supply engines; the seams are ours.
- **FR-002 SPA report-builder surface** — over core Report doctypes +
  Insights (§2.4/§3.5); the surface is custom, the engine is not.
- **Provider-API missing endpoints** (census §6A, Cursor) and the
  **external invoicing API** — provider-side, unaffected by app choice,
  except: portal ticketing should be backed by **HD Ticket** (§3.4)
  rather than a new ticket store.

---

## §6 — Scan coverage record (exact)

Scanned today (full repo: Semgrep `p/security-audit` + `p/python` with
`--metrics=off`, Bandit recursive, Gitleaks dir) — **21 repos**:
payments, hrms, crm, helpdesk, telephony, insights, lms, gameplan,
ksa_compliance, zatca_erpgulf, pos_prime, pos_awesome_fork (defendicon),
lending, education, healthcare, webshop, ecommerce_integrations,
erpnext_shipping, wiki, builder, raven. Per-repo counts are in each
entry above; raw JSON in `~/workspace/app-census-20261128/scans/`.

- **Gitleaks:** every hit in every repo (17 total) was the
  `generic-api-key` rule matching **DocType schema JSON field names or
  test fixtures** — no live secret was found in any repo; all 17 are
  recorded as assessed false positives.
- **Bandit/Semgrep pattern honesty:** the dominant classes (B608
  string-built SQL, var-in-href) are Frappe-idiom patterns (query
  builder / Jinja templates) present in *every* Frappe app including
  official ones; verdicts weighed the *outliers* (POS Awesome fork's
  shell/exec, Wiki's cert-validation, Insights' pickle, Marley's
  pycrypto), not the idiom counts.
- **Not scanned today:** fbr_e_invoicing and ury (verdicts EVALUATE,
  resting on the 2026-11-26 recon's hooks-level reads — the scan is a
  named precondition of any future USE verdict); Beveren ZATCA
  (closed source — unscannable by construction); ERPNext/Frappe core
  built-ins (the platform itself, governed by the bench pin).
- **OCR:** full `ocr review` not run (needs paid key or owner ChatGPT
  sign-in — neither configured, standing rule). The manual API-surface
  review (whitelisted-method, `allow_guest`, raw-SQL censuses) was run
  on all 21 repos instead; guest-endpoint counts of note: lms 28 and
  payments 21 (public course pages / gateway webhooks — by design),
  ksa_compliance 0, zatca_erpgulf 0, pos_prime 0.
- **Nothing was installed** on any tenant, staging site, or bench by
  this lane; clones live only in the census scratch directory.
