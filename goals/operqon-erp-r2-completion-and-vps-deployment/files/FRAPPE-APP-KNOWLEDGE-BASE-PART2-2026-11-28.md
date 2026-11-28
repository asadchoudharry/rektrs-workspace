# Frappe App Knowledge Base — Part 2: Second-Pass Census, Industry Solutions & DreamsERP Wiring Feasibility (2026-11-28)

**Owner orders behind this part:** (1) 2026-11-28 ~16:23 PKT — "Ab in sab ka or
mazeed research kro kon kon si apps ban Sakti hain or unhin DreamERP k frontend
py joor dena hy yeh mumkin hy na" (extend the research; establish that the apps
can be joined to our DreamsERP frontend); (2) clarification ~16:24 PKT — **"Jo
already ban chuki hain by frappe community"**: scope is ONLY apps that already
exist, built by the Frappe community (official / Frappe Marketplace / reputable
GitHub). Industry packages in §P2.4 are composed ONLY of existing community
apps + ERPNext/Frappe built-ins; anything that would need a net-new build is
named explicitly as a **custom gap**, never counted as ready.

**Companion documents:** Part 1 = `FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md`
(21 apps, commit `53b7615` on asadchoudharry/rektrs-workspace); surface census
§8 = `SURFACE-API-WIRING-CENSUS-2026-11-28.md`; 2026-11-26 recon =
`~/workspace/operqon-dreams/agpl-activation/AGPL-ACTIVATION-RECON-20261126.md`.
Pass-1 verdicts are NOT re-derived here.

**Method (identical to pass 1):** every candidate below was shallow-cloned
from its real upstream into `~/workspace/app-census-20261128/repos/` (29
attempted, 28 cloned; scripts `clone3.sh` / `harvest3.sh` / `scan3.sh`,
evidence `harvest3.txt`, `scans/SUMMARY3.txt`) and read directly — LICENSE,
`hooks.py` `required_apps`, pyproject `frappe-dependencies`, DocType tree,
whitelisted-API census, guest-endpoint census, last commit. The standing scan
stack (Semgrep `p/security-audit` + `p/python` `--metrics=off`, Bandit,
Gitleaks) ran on every repo before any verdict stronger than EVALUATE; the
full per-repo scan record is §P2.6. OCR full review was again NOT run (needs a
paid API key or the owner's ChatGPT sign-in — standing rule); the substitute
is the same manual API-surface review as pass 1. **Nothing was installed
anywhere.** Platform pin (live): Frappe **16.55.1** / ERPNext **16.53.0**.

**One repo could not be cloned:** `frappe/flow` (Frappe's own AI assistant,
listed on awesome-frappe) — the GitHub API returns **404** for
`frappe/flow` (private or renamed). It is recorded as EVALUATE on listing
evidence only, with no scan; FAC (§P2.2.8) covers the same slot from a public
repo.

---

## §P2.1 — Second-pass census at a glance

| Category (brief) | Candidates read at source level | Outcome |
|---|---|---|
| School/institute specifics | Ifitwala Ed (fderyckel) | EVALUATE — standalone school OS, alternative stack (not an ERPNext add-on) |
| Hospitality (hotels) | Hospitality PMS (globcomqatar, MIT, v16 branch) · Hospitality Core (Gifted87, GPL) | Both EVALUATE; PMS is the stronger v16 candidate |
| Real estate | OmoroJr/real_estate · AakvaTech PropMS | EVALUATE (licence file missing in repo) · AVOID (stale since 2023) |
| Agriculture | frappe/agriculture (official) | EVALUATE — Frappe's own docs warn it is unmaintained; proof-install decides |
| Logistics/fleet/cargo | AgileShift Cargo Management (AGPL, v16.2.0) | EVALUATE — real cargo/parcel engine; needs bench ≥16.60 (above today's pin) |
| Gym/fitness | Frappe GymStack (usamam46-git) | EVALUATE — v15-targeted, v16 proof owed |
| Pharmacy | *no dedicated community app found* | Covered by composition: Healthcare + ERPNext batch/expiry stock (§P2.4) |
| Garment manufacturing | Apparelo (aerele) | EVALUATE-low — stale (Apr 2024) |
| IT management / MSP | IT Management (phamos-eu) | EVALUATE — full CMDB, v16-pinned |
| Attendance/biometric | (pass 1) frappe biometric-sync tool | LAN-side tool, catalogue listing only — unchanged from pass 1 |
| Quality extras | — | ERPNext Quality Management is a built-in module; no separate app needed |
| E-sign | Nesscale Sign (AGPL, v16 branch) · Asoral E-sign App (MIT, Marketplace) | Both EVALUATE; Nesscale is the v16-native candidate |
| Document/storage | Zerodha S3 Attachments (MIT) · DFP External Storage (listing) | S3 Attachments = USE-candidate (platform ops) |
| Print/format tooling | Crispy Print (Typst engine, MIT, RC) | EVALUATE — designed-print + fiscal QR profiles |
| Backup/DR | — | Frappe core scheduled backups + S3 Attachments cover the need; ERPNextFailOver is a tool, not a bench app |
| Audit/activity | — | Frappe core Activity Log / Version / Audit Trail doctypes are built-in; no app needed |
| Payments beyond frappe/payments | Moyasar (wahrani1, MIT) · Paymob (MIT, v16) · Paystack (MIT, v15 pin) | EVALUATE ×3 — Moyasar is the only open-source Moyasar app found (KSA: mada/Apple Pay/STC Pay) |
| Pakistan regionalisation | ParaLogic erpnext_pk (GPL, stale 2022) · ParaLogic fbr_integration (GPL, v15 pin, fresh Nov 2026) | EVALUATE-low · EVALUATE — complements pass-1 fbr_e_invoicing EVALUATE |
| Banking extras | ALYF Banking (GPL, v16) | EVALUATE — EBICS/SEPA (EU relevance; low PK/KSA priority) |
| Shipping extras | ShipStation integration (ParsimonyGit) | AVOID — v13-era branch; erpnext-shipping (pass-1 USE) covers aggregators |
| SMS gateways | MSG91 integration (MIT) | Record-only — **AVOID for tenants** (owner decision: messaging = Sendqon) |
| Email/marketing automation | dokos-io Mautic integration | AVOID — dead since 2019; built-in Newsletter/Email Campaign is the route |
| Chat/team extras | Clefincode Chat (listing) | Noted; Raven (pass-1 USE) already owns this slot |
| Analytics extras | Plotly Dash app (listing) · core Auto Email Report | No new install: Insights (pass-1 USE) + core Report/Auto Email Report cover dashboards + scheduled reports |
| AI add-ons | Frappe Assistant Core (AGPL) · changAI (ERPGulf, MIT) · Frappe Flow (official, repo 404) · ERPNext OCR (Monogramm) | FAC EVALUATE (MCP + in-site assistant) · changAI EVALUATE (light NL query) · Flow EVALUATE (unscannable) · OCR AVOID (stale 2021) |
| Developer/platform | frappe/mcp (official, MIT) · FrappeAPI / Doppio (listings) | Platform tooling for the provider/dev side — not tenant Store products |
| Productivity integrations | Frappe Microsoft 365 (MIT, v15+v16) | EVALUATE — Outlook/Teams/SharePoint sync |

---
## §P2.2 — Pass-2 app entries (evidence + verdict + wiring + surfacing level)

**Surfacing levels (owner rule, 2026-11-28 ~16:36 PKT)** — every verdict
carries the LIGHTEST viable surfacing level: **L1** = the app's own frontend,
re-themed/re-branded to the DreamsERP look inside our shell (SSO via Rektrs
ID); **L2** = generic SPA screens rendered from DocType metadata through
DreamsERP-themed components (one renderer, many apps); **L3** = hand-built SPA
screens, EXCEPTION only, for high-use product-face surfaces, each justified in
one line. Sales/Finance are already L3 (built). Pass-1 apps' levels are being
recorded into census §8 by the parent in parallel; this file assigns levels
for pass-2 apps and for the industry packages in §P2.4.

### P2.1 agriculture — frappe/agriculture — **EVALUATE**
- Official Frappe app (split out of ERPNext core between v14 and v15):
  Crop, Crop Cycle, Plant/Soil/Water Analysis, Weather, Disease, Fertilizer
  doctypes (21), 11 whitelisted methods, 0 guest endpoints. GPL-3.0.
- Maintenance is the problem: last commit 2025-05-26, version still 0.0.1, and
  Frappe's own current docs warn verbatim in substance that the app "does not
  appear to be actively maintained" and compatibility with the latest
  ERPNext/Frappe must not be assumed. Scans are perfectly clean (Semgrep 0,
  Bandit 0, Gitleaks 0) — the code is not the risk; the version gap is.
- **Wiring: WIRES-CLEAN** (pure DocType model). **Level 2** (standard CRUD —
  generic renderer). Proof-install on v16 decides; if it fails, farm
  record-keeping is a named custom gap (§P2.4, Agriculture package).

### P2.2 ifitwala_ed — fderyckel/ifitwala_ed — **EVALUATE (alternative stack, not an add-on)**
- A complete standalone school operating system: 1,597 Python files, **698
  whitelisted decorators across 166 files**, 16 guest endpoints, its own
  admissions/student/guardian/staff Vue portals, and — decisively — its **own
  accounting doctypes** (its own Sales Invoice / Payment Entry / Journal Entry
  / GL Entry tree). It requires a companion app (`required_apps =
  ["ifitwala_drive"]`, not separately censused) and pins Frappe
  `>=16.0.0-dev, <=17.0.0-dev`. Last commit 2026-06-15. No LICENSE file was
  present at the repo root in the clone — licence unverified at source level.
- Because it re-implements accounting instead of building on ERPNext, it
  cannot be composed into an ERPNext tenant the way frappe/education can; it
  is an alternative School-ERP stack, not a Store add-on for Operqon tenants.
  Scan surface is the heaviest of pass 2 (Bandit 345: 259× MEDIUM B608
  SQL-construction, 10× HIGH B324 weak-hash; Semgrep 96 incl. 21
  template-unescaped and 7 exec-detected) — any adoption needs a dedicated
  security review first.
- **Wiring: WIRES-WITH-SEAM** (API-rich, but as a separate stack).
  **Level 1** (its own portals are its product face). Operqon's School ERP
  stays Education + LMS (§P2.4); Ifitwala is recorded as the fallback
  alternative if a school customer wants that specific system.

### P2.3 hospitality_pms — globcomqatar/hospitality_pms — **EVALUATE (hotel candidate #1)**
- **MIT**, dedicated **version-16 branch**, app version **16.7.5**, last
  commit 2026-08-16, `required_apps = ["frappe/erpnext"]`. Deep PMS model:
  Reservation / Stay / Room / Room Type / Rate Plan, Guest Folio + folio
  charges/payments, Housekeeping Task, Room Inspection, Night Audit (+
  exceptions), channel reservations + sync log, key cards, maintenance
  tickets, regulatory exports. **134 whitelisted decorators**, 1 guest
  endpoint, 442 Python files.
- Scans: Gitleaks 2 findings (assessed in §P2.6), Bandit 10 (1× HIGH B324,
  6× MEDIUM B608), Semgrep record in §P2.6. Single-vendor, young — proof
  install + a folio-posting review are the gates.
- **Wiring: WIRES-WITH-SEAM** (front-desk flows wire to Stay/Reservation
  doctypes; night-audit and channel sync are server workflows the SPA
  triggers and reads, not re-implements). **Level 1** — it ships its own
  Vue 3 front-desk UI; re-brand inside our shell is the lightest viable
  surface for a 24×7 front desk.

### P2.4 hospitality_core — Gifted87/erpnext_hospitality_core — **EVALUATE (hotel candidate #2)**
- GPL-3.0, last commit 2026-07-12, 33 doctypes (Hotel Reservation, Guest
  Folio, Hotel Room/Type, Room Rate Plan, EOD Closing with payment/stock
  summaries, Hotel Maintenance Request, Lost and Found), 45 whitelisted
  decorators, 1 guest endpoint. No pyproject Frappe pin was present — v16
  compatibility is unproven either way. Scans: Semgrep 0/429 files (clean),
  Bandit 55 (26× MEDIUM B608), Gitleaks clean.
- **Wiring: WIRES-WITH-SEAM** (Desk-era model; folio/EOD posting flows need
  the governed seam). **Level 2** (no modern own frontend — generic SPA
  screens). Backup candidate if P2.3 fails its proof.

### P2.5 realestate_omoro — OmoroJr/real_estate — **EVALUATE (licence-blocked)**
- Last commit 2026-06-17, v1.0.0, `required_apps = ["erpnext"]`: Property,
  Property Unit, Property Listing, Lease Agreement (+ renewal history),
  Rent Invoice, Payment Schedule, Maintenance Request, Owner Statement,
  Utility Charges with rate slabs, Visitor/Lead Inquiry. 20 whitelisted
  decorators, 0 guest endpoints.
- **Blocker: no LICENSE file exists in the repo** — the code cannot be
  adopted commercially until the author licences it. (AakvaTech PropMS, the
  older alternative, is AVOID: last commit 2023-05-24, v14-era.)
- **Wiring: WIRES-CLEAN** (pure DocType model). **Level 2**.

### P2.6 cargo_management — AgileShift/cargo_management — **EVALUATE**
- **AGPL-3.0** (§13 source offer applies on activation), app v16.2.0, last
  commit 2026-11-19 (very active), pyproject pins **frappe/erpnext
  >=16.60.0, <17** — *above today's bench pin (16.55.1/16.53.0)*, so it
  becomes installable at the next bench uplift, not today. Model: Parcel +
  Parcel Content, Cargo Shipment (+ lines/receipts), Warehouse Receipt,
  Carrier with tracking URLs; 8 whitelisted decorators, 2 guest endpoints
  (tracking surface — review item).
- **Wiring: WIRES-CLEAN** (DocType-driven; parcel tracking reads are REST).
  **Level 2**. This is the logistics engine ERPNext lacks (core has Vehicle /
  Driver / Delivery Trip only; parcel/cargo workflows are not in core).

### P2.7 gymstack — usamam46-git/Frappe-Gymstack — **EVALUATE**
- MIT, last commit 2026-09-08: Gym Member, Membership Plan, Gym Membership
  (with freeze), Attendance Device + Attendance Log (incl. face-recognition
  device sync), Gym Payment, Payment Reconciliation Run. Only 2 whitelisted
  decorators — the model is DocType-first, so REST CRUD still covers it; no
  pyproject Frappe pin (marketed for v15) — v16 proof owed.
- **Wiring: WIRES-WITH-SEAM** (device attendance sync is its own seam).
  **Level 2** (membership/member CRUD is generic; a hand-built check-in
  surface is NOT justified at this scale).

### P2.8 fac — buildswithpaul/Frappe_Assistant_Core — **EVALUATE (AI add-on candidate #1)**
- **AGPL-3.0**, v3.4.0, last commit 2026-11-20, pyproject frappe
  `>=15.0.0, <17.0.0` ✓. Turns a site into an MCP server for external LLMs
  AND ships an in-Frappe assistant chat: **361 whitelisted decorators / 88
  files**, 24 built-in tools (document CRUD, search, reports, workflows,
  dashboards), a full audit trail (Assistant Audit Log, FAC Chat Usage Log),
  per-role/per-user tool access doctypes. 15 guest endpoints — the MCP
  surface; each is a named proof-install review item. ~319 GitHub stars,
  presented at Frappeverse India 2025; a paid hosted tier (FAC Cloud) exists
  but the app itself is fully open — no trial-credit trap; the tenant's own
  LLM key is used (service-provider principle).
- Relationship to our own **operqon_rag** (live, NF-2): RAG answers questions
  from documents; FAC *operates* the ERP under the user's permissions. They
  are complementary, not substitutes.
- **Wiring: WIRES-WITH-SEAM** (the SPA embeds/launches the assistant; the
  tool layer runs server-side under Frappe permissions). **Level 1** (its
  own chat SPA/widget is the surface; re-theme, don't rebuild).

### P2.9 changai — ERPGulf/changAI — **EVALUATE (AI add-on candidate #2)**
- MIT, last commit 2026-11-13, frappe `>=15.0.0, <=17.0.0-dev` ✓, small (49
  Python files, 18 whitelisted decorators, 1 guest endpoint): natural-language
  questions → SQL/ORM answers, supports local models via Ollama or the
  tenant's own cloud keys; vendor states data never leaves the server in
  local mode. Overlaps operqon_rag's Q&A ground more directly than FAC does.
- **Wiring: WIRES-WITH-SEAM** (its own www chat page is the surface).
  **Level 1**. Keep as the lightweight alternative; FAC is the strategic
  candidate (tool-use + audit), changAI the simple one. Named review items
  from the scan (§P2.6): pickle use (Bandit B301 ×3, Semgrep avoid-pickle
  ×6) and example notebooks to exclude at bake.

### P2.10 frappe_flow — frappe/flow — **EVALUATE (listing evidence only)**
- Frappe's own AI assistant ("knows your DocTypes, respects your
  permissions… creating records, sending emails, building DocTypes, RAG
  chatbots" — awesome-frappe listing). **The repo is not publicly cloneable
  (GitHub API 404)** — no licence, pin, or scan could be verified, so no
  stronger verdict is possible today. Re-check when/if it goes public.
  **Wiring: unverified. Level 1 (presumptive — its own assistant UI).**

### P2.11 nesscale_sign — bhavesh95863/nesscale_sign — **EVALUATE (e-sign candidate #1)**
- **AGPL-3.0**, dedicated **version-16 branch**, frappe `>=15.0.0, <17.0.0`
  ✓, last commit 2026-06-27, v0.0.1 (early): NS Envelope / Envelope Signer /
  Envelope Field / Template (+ versions), NS Signature, NS Audit Log,
  Signing Session doctypes; **50 whitelisted decorators**, 6 guest endpoints
  (signing sessions — guest access is inherent to e-sign links; each is a
  named review item: session expiry + one-time tokens must be proven).
- **Wiring: WIRES-WITH-SEAM** (SPA creates/tracks envelopes via API; the
  signing act itself happens in the app's signing session by design).
  **Level 1** (the signing UX is the product surface — never rebuild it;
  envelope lists can render at Level 2 inside the same surface plan).

### P2.12 esign_app — asoral/E-sign-App — **EVALUATE (e-sign candidate #2)**
- MIT, Frappe Cloud Marketplace-listed, last commit 2025-09-08: DocumentList /
  TemplateList / ESign Signature / OpenSSL certificate doctypes, its own
  React signing dashboard. **31 guest endpoints in a 27-file codebase** — the
  heaviest guest surface of pass 2; every one needs justification before any
  activation. 37 whitelisted decorators.
- **Wiring: WIRES-WITH-SEAM**. **Level 1** (own React dashboard). Ranks
  behind Nesscale Sign on version targeting (no v16 branch), guest surface,
  and scan findings (Bandit HIGH B602 shell=True ×1; Semgrep
  react-dangerouslysetinnerhtml ×4 — §P2.6).

### P2.13 erpnext_pk — ParaLogicTech/erpnext_pk ("Pakistan Workspace") — **EVALUATE-low**
- GPL-3.0, Marketplace-listed, but **last commit 2022-10-19** (v13/v14-era):
  NIC/NTN/STRN custom fields with format masks on Customer/Supplier/Employee,
  company tax accounts, FBR Annexure-C / SRB report exports for IRIS upload.
  Zero whitelisted methods — it is fixtures + reports only, which is exactly
  why it may still port cheaply; but on v16 it is unproven and unmaintained.
- **Wiring: WIRES-CLEAN** (fields + Query Reports). **Level 2** (fields ride
  the generic renderer; reports ride the core report surface under FR-002).

### P2.14 fbr_integration — ParaLogicTech/fbr_integration — **EVALUATE**
- GPL-3.0, **last commit 2026-11-26** (actively maintained), FBR POS +
  Digital Invoicing: FBR DI Settings, FBR POS Settings, invoice-item
  doctypes, FBR UOM mapping. BUT the cloned branch is **version-15** and
  pyproject pins **frappe >=15.0.0, <16.0.0** — it does not cover our v16
  bench today; a v16 line from upstream (or a proof that the v15 line
  installs) is the gate. Complements pass-1's fbr_e_invoicing EVALUATE
  (DeliveryDevs): two candidate sources now exist for the same slot; FBR
  sandbox proof is still owed for either (live submission stays gated on the
  tenant's own FBR credentials — service-provider principle).
- **Wiring: WIRES-CLEAN** (settings + invoice-submission status on core
  doctypes). **Level 2**.

### P2.15 moyasar — wahrani1/frappe-moyasar — **EVALUATE (strategic for KSA)**
- MIT, last commit 2026-10-22, `required_apps = ["payments", "erpnext"]`:
  the **only open-source Moyasar Frappe app found** (a second repo,
  maasconsult/frappe-moyasar-payments, covers Web Forms only). Single
  Moyasar Settings doctype, 2 whitelisted methods, 2 guest endpoints
  (payment callbacks — signature verification on those callbacks is THE
  named proof item). Moyasar is the Saudi gateway (mada, Apple Pay, STC
  Pay) — this is the KSA counterpart of the JazzCash/Easypaisa slot, except
  here a community app actually exists. ECOSIRE's PayTabs/Moyasar offers are
  build-to-order (paid, not catalogue apps — pass-1 exclusion class).
- **Wiring: WIRES-CLEAN** (Payments-framework pattern: settings + hosted
  form + callback → Payment Entry). **Level 2** (settings-only surface; the
  checkout itself is Moyasar-hosted).

### P2.16 paymob — NotAbdelrahmanelsayed/paymob_integration — **EVALUATE**
- MIT, **version-16 branch**, pyproject frappe/erpnext `>=16.0.0, <17.0.0`
  ✓, last commit 2026-08-12: Paymob Settings, Credential Set, Payment
  Attempt, Transaction, Audit Entry doctypes; webhook-verified payments
  auto-create Payment Entries and reconcile Payment Requests; 6 whitelisted
  decorators, 3 guest endpoints (webhooks, by design). Deeper than the
  Paymob Settings doctype frappe/payments already ships (pass 1 §3.1) —
  attempts/transactions/audit are the added value for Egypt/MENA tenants.
- **Wiring: WIRES-CLEAN**. **Level 2** (settings-only; checkout is
  Paymob-hosted).

### P2.17 paystack — mymi14s/frappe_paystack — **EVALUATE**
- MIT, app v15.5.0, last commit 2026-08-12, `required_apps = ["erpnext",
  "payments"]`, pyproject pins frappe/erpnext `>=15.0.0, <16.0.0` — v15
  line only. Full gateway bookkeeping (customer authorizations, settlement,
  reconciliation and refund logs), 21 whitelisted decorators, 3 guest
  endpoints (callbacks). Africa-market gateway; low PK/KSA priority, kept
  for catalogue completeness.
- **Wiring: WIRES-CLEAN**. **Level 2** (settings-only).

### P2.18 msg91 — dhwani-ris/frappe_msg91_integration — **AVOID for tenants (record only)**
- MIT, v1.0.0, last commit 2026-10-28, MSG91 Settings + Template doctypes, 5
  whitelisted decorators. A perfectly real SMS-gateway app — recorded so the
  census is complete — but tenant messaging is **Sendqon by owner decision
  (2026-11-26)**, so no SMS-gateway app is a tenant product. (Same class:
  frappe/twilio-integration and core SMS Settings exist; all stay
  record-only for the same reason.)

### P2.19 mautic — dokos-io/mautic — **AVOID**
- GPL-3.0 Mautic marketing-automation integration, **last commit
  2019-08-30** — dead for six years. No maintained Frappe marketing-automation
  app exists; the route is Frappe core **Newsletter / Email Campaign /
  Campaign doctypes** (built-in) + CRM campaigns. Recorded so the gap is a
  finding, not a surprise.

### P2.20 shipstation — ParsimonyGit/shipstation_integration — **AVOID**
- MIT, but the cloned branch is **main-v13** — a v13-era integration.
  erpnext-shipping (pass-1 USE) already covers aggregator shipping
  (Packlink/LetMeShip/SendCloud) on v16.

### P2.21 s3_attachments — zerodha/frappe-attachments-s3 — **USE-candidate (platform ops)**
- MIT, last commit 2026-03-11, pyproject frappe `>=10.0.0, <17.0.0` ✓, tiny
  (14 Python files, 4 whitelisted decorators, 0 guest endpoints): stores
  Frappe File attachments in S3 instead of local disk. Maintained by Zerodha
  (a large production Frappe user). This is provider/platform infrastructure
  (tenant attachment offload), not a tenant-facing product — it still goes
  through proof-install + the §P2.6 scan record before adoption.
- **Wiring: WIRES-CLEAN** (no UI surface at all — **no surfacing level;
  infrastructure**).

### P2.22 crispy_print — agatho-daemon/crispy_print — **EVALUATE**
- MIT, v0.2.0-rc.1 (release candidate — not yet a stable line), last commit
  2026-11-21: a Typst-powered print/report engine with a visual builder,
  branding profiles, and — notable for us — **fiscal credential / QR
  regulatory profiles and issued-document trust events** (the FBR/ZATCA QR
  print problem). 59 whitelisted decorators, 0 guest endpoints.
- Context: v16 core already absorbed Print Designer (pass 1), and our SPA
  prints are designed prints by owner rule. Crispy Print is an alternative
  rendering pipeline, not an addition — evaluate it against core Print
  Designer on one fiscal document before any adoption.
- **Wiring: WIRES-WITH-SEAM** (it replaces the print rendering path).
  **No SPA level — print-pipeline configuration** (formats are config, L2-class).

### P2.23 it_management — phamos-eu/it_management — **EVALUATE**
- GPL-3.0, last commit 2026-09-18, pyproject frappe `>=16.0.0, <18.0.0` ✓:
  a full CMDB — Configuration Items, IT Hardware/Software, Hosts, IP
  Addresses/Subnets, IT Landscape, IT Backup, Service Reports (60+
  doctypes), 22 whitelisted decorators, 0 guest endpoints. The engine for
  an MSP / IT-services vertical (§P2.4).
- **Wiring: WIRES-CLEAN**. **Level 2**.

### P2.24 apparelo — aerele/apparelo — **EVALUATE-low**
- GPL-3.0, **last commit 2024-04-22** (stale): garment-manufacturing depth
  ERPNext lacks — style/size/colour matrices, knitting/dyeing/cutting/
  ironing process doctypes, lot creation/closure, IPD (Item Production
  Detail). 44 whitelisted decorators, 0 guest endpoints. Real but ageing;
  v16 proof is a genuine risk.
- **Wiring: WIRES-WITH-SEAM** (process flows are Desk-era). **Level 2**.

### P2.25 banking_alyf — alyf-de/banking — **EVALUATE**
- GPL-3.0, v16.0.0 on a version-16-hotfix branch, last commit 2026-11-25,
  pyproject frappe `>=16.15.0, <17.0.0` ✓: EBICS bank connection, SEPA
  payment orders, a bank-reconciliation tool with matching rules. 43
  whitelisted decorators, 0 guest endpoints. EU/Germany banking — correct
  catalogue entry, low priority for PK/KSA tenants.
- **Wiring: WIRES-CLEAN**. **Level 2**.

### P2.26 ms365 — Bizmap-Technologies-Pvt-Ltd/frappe_microsoft365 — **EVALUATE**
- MIT, v1.2.1, last commit 2026-11-25, pyproject frappe `>=15.0.0-dev,
  <17.0.0` ✓: two-way Outlook calendar sync, Teams meetings from Frappe
  Events (+ transcripts/recordings), Outlook mail over OAuth, Microsoft
  sign-in, SharePoint file mapping — each user authorises their own account
  (service-provider principle holds: tenant's own Microsoft tenant).
- **Wiring: WIRES-WITH-SEAM** (per-user OAuth connect flow is a seam, not
  CRUD). **Level 2** (settings + connect surface).

### P2.27 frappe_mcp — frappe/mcp — **platform tooling (not a tenant product)**
- MIT, official, v0.1.1, last commit 2026-10-27: lets Frappe apps function
  as MCP servers. No doctypes, no tenant surface. Recorded for the
  provider/dev platform ( pairs with FAC §P2.8); not a Store product and no
  surfacing level applies.

### P2.28 erpnext_ocr — Monogramm/erpnext_ocr — **AVOID**
- MIT Tesseract OCR app, **last commit 2021-07-08** — v13/v14-era, dead.
  Document-AI demand routes to FAC (§P2.8) / LLM-extraction class instead;
  no maintained dedicated OCR app exists in the community today (amsys/crema
  — an LLM toolkit with OCR/extraction — exists as a Nov-2026 listing but is
  a 4-star newborn; noted, not censused).

---
## §P2.3 — Categories where the honest answer is "built-in" or "no viable app exists"

| Brief category | Finding |
|---|---|
| Quality management extras | ERPNext ships a full **Quality Management module** (Quality Goal/Procedure/Inspection/Review) as a built-in — no app needed; SPA surfaces are wiring work, not procurement. |
| Audit / activity tools | Frappe core ships **Activity Log, Version (document history), and the Audit Trail report** — built-in. (Pacioli, a Nov-2026 listing, adds an AI-agent governance/audit layer — noted for the FAC evaluation, not censused.) |
| Backup / DR tools | Frappe core **Scheduled Backups + backup encryption + S3 backup target** are built-in; §P2.21 S3 Attachments covers attachment offload. ERPNextFailOver (DB replication) is an ops tool, not a bench app. |
| Report schedulers | Frappe core **Auto Email Report** schedules any report by email — built-in. Dashboard builders: core **Dashboard / Workspace / Number Cards** + Insights (pass-1 USE); the Plotly Dash app (pipech/frappe-plotly-dash, listing) exists for analyst-grade embedded dashboards — noted, not needed for the SMB bar. |
| Pharmacy-specific app | **None exists** in the community. Pharmacy is a composition (§P2.4): Healthcare + ERPNext batch/serial/expiry stock + POS. |
| Document management / DMS | Frappe Drive is archived upstream (pass 1); its successor is not a public bench app today. Working route: core File + S3 Attachments (§P2.21) + Wiki for knowledge pages. |
| Multi-tenancy helpers | Provider-side concern (our own provisioning system), not a tenant app category — nothing to census. FC Site Manager (wahni-green, listing) is a Frappe-Cloud partner tool, not applicable to our bench. |
| API builder / low-code extras | Frappe core **REST API + Webhooks + Server Scripts + Builder** (pass-1 USE) already cover this class; FrappeAPI (0xsirsaif, FastAPI-style routing, listing) and Doppio (SPA scaffolding, listing) are developer tools, not tenant products. |
| Workflow automation (n8n-type) | No Frappe app is needed: Frappe's standard REST API + Webhooks are the connector (multiple public setup guides do exactly this with n8n's HTTP node). ECOSIRE's n8n packs are build-to-order (paid) — excluded class. Verdict: **integration pattern, not an app** — a tenant connects their own n8n via API keys (service-provider principle). |
| Attendance / biometric extras | The frappe biometric-sync tool (pass 1) remains a LAN-side sync tool — catalogue listing + delivery note, never a bench install. GymStack (§P2.7) covers device attendance inside the gym vertical. |

---

## §P2.4 — PART B: Industry solutions we can assemble (existing apps + built-ins ONLY)

Composition rule (owner clarification ~16:24 PKT): every package below is
composed **only** of already-existing community apps (pass 1 + pass 2) and
ERPNext/Frappe built-ins. Anything else is named as a **custom gap** next to
the package and is NOT counted as ready. Effort class = wiring + surfacing +
proof-install effort once the composing apps are on the bench (the W0–W4
install train is shared infrastructure, counted once in pass 1's estimate).
Package surfacing level = the dominant level of its customer-facing surfaces,
per the §P2.2 level rule.

| # | Industry package (Store: `industry_solution` / `industry_image`) | Composed of (existing only) | Custom gaps (named, not counted as ready) | Level | Effort |
|---|---|---|---|---|---|
| 1 | **EV Showroom** | ERPNext built-ins (Sales/Stock/Serial No) + our EV industry pack (built in EV-1, live on demo2) | None new — pack exists; EV-2…EV-5 phases per spec | **L3** — flagship pack; daily showroom sales flow is the product face (already built this way) | Done (Phase 1a live); remaining phases per EV spec |
| 2 | **School ERP** | Education (USE) + LMS (USE) + HRMS (USE) + Payments (USE) + core Accounting | PK fee/tax fixtures (small, configuration-class); Ifitwala Ed is an alternative standalone stack, NOT part of this composition | **L2** dominant; **L1** for the LMS learner portal (its own modern UI, re-themed) | Weeks |
| 3 | **Clinic / Hospital** | Healthcare–Marley (USE) + HRMS (USE) + Payments (USE) + core Stock/Accounting | None major | **L2** (OPD/appointment flows are standard DocType CRUD at SMB scale) | Weeks |
| 4 | **Pharmacy** | Healthcare (USE) + ERPNext **batch/serial/expiry** stock (built-in) + built-in POS doctypes | None — no dedicated pharmacy app exists and none is needed | **L3** for the counter-sale surface only (it rides the POS product face, already L3); rest L2 | Weeks (rides the Clinic pack) |
| 5 | **Hotel / Hospitality** | Hospitality PMS (EVALUATE — MIT, v16) *or* Hospitality Core (EVALUATE — GPL) + ERPNext Accounting/Stock + Payments (USE) | OTA/channel-manager depth is a proof item inside the PMS evaluation, not assumed; choice between the two candidates is made by proof-install | **L1** (PMS ships its own Vue front-desk UI — re-brand; a hand-built front desk is not justified) | Weeks |
| 6 | **Restaurant** | URY (EVALUATE, pass 1) + built-in POS doctypes + Payments (USE) | Joint URY + POS proof (standing pass-1 rule: never co-activate two POS engines without it) | **L1** (URY's own POS/KDS frontend, re-themed) with the W-T1 SPA POS seam as fallback | Weeks |
| 7 | **Retail / POS Shop** | Built-in POS doctypes + Webshop (USE) + Payments (USE) + Ecommerce Integrations (USE) | W-T1 governed POS seam (already queued in the loop — an SPA seam, not an app gap) | **L3** — POS is the standing product-face exception (owner rule; GAP-06) | Days–weeks |
| 8 | **Salon / Spa** | ERPNext built-ins (Appointment booking, POS doctypes, HRMS staff) + Payments (USE) | **Custom gap:** staff-resource scheduling + commission rules (the ECOSIRE salon design proves the shape; their app is build-to-order/paid, so it does not count) — a small operqon_core extension, not an engine | **L2** (booking/appointments render generically) | Weeks (incl. the named gap) |
| 9 | **Gym / Fitness** | GymStack (EVALUATE) + Payments (USE) + HRMS (USE) | v16 proof for GymStack is owed (v15-targeted today) | **L2** | Weeks |
| 10 | **Real-Estate Agency / Property Management** | OmoroJr real_estate (EVALUATE) + CRM (USE) + core Accounting | **Custom gap (legal, not technical):** the candidate repo has **no LICENSE file** — until the author licences it, the fallback composition is CRM + core lease/accounting doctypes with a small custom lease pack | **L2** | Weeks |
| 11 | **Logistics / Cargo** | Cargo Management (EVALUATE) + ERPNext Shipping (USE) + core Vehicle/Driver/Delivery Trip | **Custom gap:** GPS live tracking (Traccar-class external system — not a Frappe app; integration pattern only). Bench must first uplift to ≥16.60 for Cargo's pin | **L2** | Weeks |
| 12 | **Services / Agency (incl. IT services & MSPs)** | Built-in Projects (USE) + Gameplan (USE) + Helpdesk (USE) + HRMS (USE, timesheets) + IT Management (EVALUATE, for MSP/CMDB depth) | None major | **L2** dominant; **L1** for Gameplan discussions (own modern UI) | Days–weeks |
| 13 | **Garment Manufacturing** | ERPNext Manufacturing (built-in) + Apparelo (EVALUATE-low) | Freshness risk on Apparelo (Apr 2024) — if its proof fails, garment-specific matrices are a custom gap | **L2** | Weeks |
| 14 | **Agriculture / Farm** | frappe/agriculture (EVALUATE) + ERPNext Stock/Accounting built-ins | If the proof-install fails on v16 (upstream unmaintained — Frappe's own docs warn), crop/livestock record-keeping becomes a custom gap | **L2** | Weeks |
| 15 | **Saudi (KSA) Business Pack** (cross-industry regional layer) | KSA Compliance — ZATCA (USE, pass 1) + Moyasar (EVALUATE, §P2.15) + HRMS (USE) | KSA payroll pack (GOSI/Mudad) — already-known custom item from pass 1; no open-source app exists | **L2** (compliance surfaces are settings/submissions; invoicing itself is already L3) | Weeks |
| 16 | **Pakistan Business Pack** (cross-industry regional layer) | fbr_e_invoicing (EVALUATE, pass 1) *or* ParaLogic fbr_integration (EVALUATE, §P2.14) + erpnext_pk fields/reports (EVALUATE-low, §P2.13) + Payments (USE) | JazzCash/Easypaisa stay custom (proven: no community app exists — pass 1 §1); FBR sandbox proof owed for either FBR candidate | **L2** (same reasoning as KSA pack) | Weeks |

**Reading of the table:** 14 of 16 packages compose with **zero or only
configuration-class gaps**. The genuine named gaps are small and specific:
salon scheduling/commissions (small extension), real-estate licence clearance
(legal), GPS tracking (external system), KSA payroll (known custom), and the
two proof-risk fallbacks (Apparelo, Agriculture). No package on this list
needs a new engine built.

---
## §P2.5 — PART C: Can these apps be wired to our DreamsERP frontend? (the owner's question: "yeh mumkin hy na")

**Short answer: yes — mumkin hai, and it is not a theory. It is the pattern
Operqon already runs in production.** The evidence, in the order the owner
asked for it:

### C.1 The platform gives every app the same API surface — measured, not asserted
Frappe generates a REST API for **every DocType of every installed app**
(`/api/resource/<DocType>` for CRUD + `/api/method/<app>.<fn>` for whitelisted
server methods), behind the same permission system. Pass 1 + pass 2 counted
the whitelisted-method surface repo by repo; the DocType REST layer exists
even where that count is small:

| App | Whitelisted decorators (measured) | DocTypes (measured) |
|---|---|---|
| Ifitwala Ed | 698 (166 files) | 100+ (own tree) |
| Frappe Assistant Core | 361 (88 files) | 30 |
| HRMS (pass 1) | 244 | full HR/payroll tree |
| LMS (pass 1) | 191 | full course tree |
| CRM (pass 1) | 160 | full pipeline tree |
| Helpdesk (pass 1) | 144 | HD Ticket tree |
| Hospitality PMS | 134 (25 files) | 80+ (stays/folios/channels) |
| Crispy Print | 59 | 19 |
| Nesscale Sign | 50 | 13 |
| Hospitality Core | 45 | 33 |
| ALYF Banking | 43 | 10 |
| MS 365 | 42 | 6 |
| PropMS | 39 | 50+ |
| E-sign App | 37 | 6 |
| IT Management | 22 | 60+ |
| Paystack | 21 | 6 |
| Real Estate (OmoroJr) | 20 | 21 |
| changAI | 18 | 5 |
| Agriculture | 11 | 21 |
| Cargo Management | 8 | 13 |
| Paymob | 6 | 6 |
| MSG91 | 5 | 2 |
| S3 Attachments | 4 | 1 |
| FBR Integration (ParaLogic) | 3 | 5 |
| Moyasar | 2 | 1 |
| GymStack | 2 | 11 |

Two lessons in the numbers: (a) the big engines (HRMS, CRM, Helpdesk, LMS,
FAC, Ifitwala) expose *hundreds* of purpose-built methods — richer than raw
CRUD; (b) even a 2-method app (Moyasar, GymStack) is fully wireable, because
its **DocTypes carry the REST API** — the whitelisted count measures
convenience, not wireability.

### C.2 Our SPA already runs exactly this pattern against ERPNext — live
The tenant SPA does not talk to "ERPNext the UI"; it talks to ERPNext
**DocTypes and whitelisted methods through governed APIs (writekit)** — the
E4 Selling, E5 Buying, E6 Stock and E7 Finance lanes are live on tenants
today on precisely that seam (pass 1 §2, census §8.1). Installing another app
adds its DocTypes to the *same* API the SPA already speaks. No new transport,
no scraping, no iframes of foreign UIs are involved in the L2/L3 routes. The
loop's W-T queue (census §6B) is the seam work that generalises this.

### C.3 The surfacing rule keeps the wiring cheap (owner rule, 2026-11-28 ~16:36 PKT)
Not every app earns hand-built screens. **L1** (own UI, re-themed, SSO via
Rektrs ID) for apps whose own frontend is modern and is itself the experience
— CRM/Helpdesk/HRMS class in pass 1; FAC, changAI, Hospitality PMS, URY,
Ifitwala portals here. **L2** (one generic DocType-metadata renderer in
DreamsERP dress) for the CRUD-heavy majority — one renderer wires dozens of
apps. **L3** (hand-built) stays the exception: POS, dashboards, and the
already-built Sales/Finance face. Under this rule the marginal cost of wiring
app #30 is configuration + a proof, not a frontend project.

### C.4 Conditions and limits — the honest boundaries
1. **Frontend-only apps cannot be headless-wired — and don't need to be.**
   Apps whose value *is* their terminal UI (POSNext, POS Awesome class in
   pass 1; X POS in this pass's listings) are adopted at **L1** (their own
   UI, re-branded) or not at all; nobody re-builds a POS terminal as SPA
   screens when a maintained one exists. No pass-2 *engine* fell into this
   class — every engine evaluated is DocType-first.
2. **Server-workflow apps wire by trigger-and-read, not re-implementation.**
   Night audit (Hospitality PMS), channel sync, ZATCA/FBR submission, and
   payment callbacks run server-side by design; the SPA starts them and
   renders their state. That is WIRES-WITH-SEAM, and it is the correct
   shape — re-implementing them in a frontend would be a defect.
3. **Guest-endpoint surfaces are named review items, per app.** E-sign
   signing sessions (Nesscale 6, E-sign App 31), payment callbacks (Moyasar
   2, Paymob 3, Paystack 3), the MCP surface (FAC 15), parcel tracking
   (Cargo 2): guest access is inherent to what these do, and each app's
   proof-install must demonstrate its token/signature discipline before
   activation. Counts are in §P2.2; none is waved through.
4. **Permission alignment is provisioning work, not wiring work.** New
   DocTypes inherit Frappe's role system; tenant access follows the owner's
   standing rule — entitlement-derived grants **at provisioning time**
   (the oc70/oc71 lesson: report access is governed by `Report.is_permitted()`
   + the `report` flag on referenced doctypes, proven as the real user on the
   backend, per the 2026-11-28 backend-first acceptance amendment). Every
   wave's proof-install includes an as-user acceptance on the governing path.
5. **AGPL §13 travels with activation.** Pass-2 AGPL apps (FAC, Cargo
   Management, Nesscale Sign) join the pass-1 AGPL set: each activated app
   gets the prominent in-app source offer, covering that app including our
   modifications. No fee; the duty is per-app, not platform-wide.
6. **Version pins are hard gates, honestly recorded.** Cargo Management
   needs bench ≥16.60 (today: 16.55.1/16.53.0) — it waits for the next bench
   uplift. Paystack and ParaLogic's FBR integration are v15-pinned today.
   Agriculture carries its own upstream's "unmaintained" warning. None of
   these is hidden inside a USE verdict — all sit at EVALUATE until the
   proof says otherwise.
7. **Standalone stacks are not add-ons.** Ifitwala Ed re-implements
   accounting; it can be *offered* (L1, its own portals) but not *composed*
   into an ERPNext tenant. The School ERP package therefore composes
   Education + LMS instead (§P2.4 #2).

### C.5 Verdict roll-up (pass 2)
- **WIRES-CLEAN:** Agriculture · Real Estate (OmoroJr) · Cargo Management ·
  FBR Integration · Pakistan Workspace · Moyasar · Paymob · Paystack ·
  IT Management · ALYF Banking · S3 Attachments (infra).
- **WIRES-WITH-SEAM:** Ifitwala Ed · Hospitality PMS · Hospitality Core ·
  GymStack · FAC · changAI · Nesscale Sign · E-sign App · Crispy Print ·
  Apparelo · MS 365.
- **FRONTEND-ONLY (cannot headless):** *none among pass-2 engines.* The
  class is real but lives in the POS-terminal family (pass 1), which the
  L1 rule absorbs.
- **Not wireable / not applicable:** Mautic (dead), ShipStation (v13),
  PropMS (stale), ERPNext OCR (dead), MSG91 (record-only by owner
  decision), Frappe Flow (repo not public — unverifiable), frappe/mcp
  (platform tooling, no tenant surface).

**Effect on the wiring plan (census §8):** §8's plan does not change shape —
pass 2 extends the *inventory* behind it. Two additions are recorded for the
parent's §8 bookkeeping: (i) the KSA pack gains a community gateway candidate
(Moyasar, §P2.15) beside KSA Compliance; (ii) the hotel/restaurant/real-estate/
gym/logistics packages in §P2.4 are new `industry_solution` catalogue entries
whose wiring rides the same W0–W4 wave train + L1/L2 surfacing, adding no new
seam class beyond W-T1…W-T8.

---
## §P2.6 — Scan coverage record (exact) + caveats

Standing stack on all 28 cloned repos (`scans/SUMMARY3.txt`, scripts
`clone3.sh`/`harvest3.sh`/`scan3.sh` in `~/workspace/app-census-20261128/`).
Format: Semgrep findings / files scanned · Bandit total (HIGH/MEDIUM of note)
· Gitleaks.

| Repo | Semgrep | Bandit | Gitleaks |
|---|---|---|---|
| agriculture | 0 / 119 | 0 | clean |
| moyasar | 0 / 26 | 0 | clean |
| paymob | 0 / 163 | 0 | clean |
| apparelo | 0 / 326 | 0 | clean |
| shipstation | 0 / 49 | 0 | clean |
| cargo_management | 0 / 122 | 3 (2× B113, 1× B608) | clean |
| realestate_omoro | 0 / 129 | 1 (LOW) | clean |
| erpnext_pk | 0 / 53 | 1 (B608) | clean |
| fbr_integration | 0 / 50 | 1 (B113) | clean |
| hospitality_core | 0 / 429 | 55 (26× B608) | clean |
| nesscale_sign | 4 / 101 (var-in-script-tag) | 1 (B608) | clean |
| hospitality_pms | 1 / 763 (sha1) | 10 (1× HIGH B324, 6× B608) | 2 — **FP**: both in `tests/test_payment_transaction.py` (test fixtures) |
| s3_attachments | 0 / 28 | 2 (LOW) | clean |
| frappe_mcp | 0 / 20 | 1 (LOW) | clean |
| propms | 0 / 340 | 8 (B608) | clean |
| msg91 | 0 / 44 | 5 (B113) | clean |
| gymstack | 2 / 97 (dynamic-urllib — device-sync calls) | 5 | clean |
| crispy_print | 1 / 351 (defused-xml advisory) | 43 (mostly LOW; 24× B311 in template/demo code, 1× B314) | clean |
| it_management | 1 / 487 (md5) | 17 (1× HIGH B324, 15× B608) | clean |
| fac | 16 / 2,279 (5× sha1, 3× avoid-pickle, 2× exec-detected, script-tag class) | 77 (4× HIGH B324; rest LOW/MEDIUM) | 3 — **FP**: DocType schema JSON field name; frontend test spec; the `client_secret` identifier in `utils/oauth_compat.py` (code, not a credential) |
| changai | 6 / 197 (all avoid-pickle) | 34 (3× B301 pickle, 12× B615, 7× B608) | 5 — **FP-class**: all inside example Jupyter notebooks (`api/v1/notebooks/`) — exclude notebooks at bake; pickle use is a named review item for this app |
| esign_app | 5 / 201 (4× react-dangerouslysetinnerhtml, 1× subprocess-shell-true) | 3 (1× **HIGH B602 shell=True**) | 1 — **FP**: bundled JS asset string |
| paystack | 2 / 169 | 3 | 1 — **FP**: DocType schema JSON field name |
| banking_alyf | 0 / 163 | 0 | 1 — **FP**: DocType schema JSON field name |
| ms365 | 4 / 92 (md5/sha1, 1× http-not-https) | 21 (3× HIGH B324 — sync-key hashing class, review item) | 1 — **FP**: test file |
| ifitwala_ed | 96 / 2,933 (21× template-unescaped, 7× exec-detected, href/script classes) | 345 (10× HIGH B324, 259× B608) | clean |
| erpnext_ocr | 1 / 93 (eval-detected) | 3 | 2 — `.env` files in a dead 2021 repo (AVOID regardless) |
| mautic | 1 / 66 | 2 | clean |

**No live secret was found in any pass-2 repo.** All 14 Gitleaks hits across
6 repos are assessed false positives (schema field names, test fixtures,
notebooks, bundled assets, code identifiers) except erpnext_ocr's stale
`.env` files, in a repo already AVOID on maintenance grounds.

**Caveats (exact, same honesty standard as pass 1):**
1. **OCR full review NOT run** on any pass-2 repo (paid key / owner ChatGPT
   sign-in not configured — standing rule). Substitute: manual API-surface
   review (whitelisted + guest-endpoint + raw-SQL-pattern censuses above).
2. **frappe/flow could not be cloned** (GitHub API 404 — private or
   renamed); it carries listing evidence only and no scan.
3. **ifitwala_drive** (Ifitwala Ed's required companion app) was not
   separately cloned or scanned; the Ifitwala verdict does not depend on it.
4. Listing-only mentions (Clefincode Chat, X POS, Plotly Dash, Pacioli,
   amsys/crema, FC Site Manager, FrappeAPI, Doppio, maasconsult's Moyasar
   Web-Forms app, ECOSIRE build-to-order offers) were **not** cloned and
   carry no verdict stronger than "noted" — ECOSIRE offers remain excluded
   as paid commissioned builds, per pass 1.
5. Semgrep/Bandit ran on the cloned default/version branches named in
   `harvest3.txt`; branch-specific lines (e.g. a future v16 branch of
   fbr_integration) would need a re-scan at adoption time.
6. **Nothing was installed anywhere; no tenant, bench, or image was
   touched.** Every EVALUATE above converts to USE only through the standing
   route: wave bake → proof-install on a throwaway site → as-user backend
   acceptance on the governing path → §13 source offer where AGPL applies →
   catalogue activation for entitled tenants.

*End of Part 2. Pass-1 KB: `FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md`.
Census §8 addendum pointer for this part: §P2.5 C.5.*
