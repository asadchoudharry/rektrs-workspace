# WorkDo Dash SaaS — FULL Module & Industry-Pack Map vs Operqon (Kya · Kab · Kesy)

**Date:** 28 November 2026 · **Owner order (2026-11-28 ~16:51 PKT):** "Ab workdo k
DashSaaS ki sary modules or Industry Packs Ka mawazna kro kya, kab or kesy
banana hy sab" — every WorkDo module/addon and industry pack, mapped against
our Operqon build: **KYA** (what covers it on our side), **KAB** (when — which
wave), **KESY** (how — community app / built-in / custom / WorkDo-if-purchased).

**Companion documents:** `WORKDO-DASH-VS-OPERQON-COMPARISON-2026-11-28.md`
(prices + licence + kul qeemat — not re-derived here), KB pass 1
`FRAPPE-APP-KNOWLEDGE-BASE-2026-11-28.md`, KB pass 2
`FRAPPE-APP-KNOWLEDGE-BASE-PART2-2026-11-28.md`, census §8/§8.6
`SURFACE-API-WIRING-CENSUS-2026-11-28.md`, zip audit
`~/workspace/your_files/WorkDo-Dash-Zip-Audit-2026-11-27.md`.

**Market frame (owner, standing):** small businesses only — shops, traders,
small services, PK + KSA. No factories. Manufacturing depth is therefore
never a WorkDo advantage that matters here, and never a gap that hurts us.

---

## 0. Coverage note — what "every" means here (honest limits)

WorkDo's own store sidebar (workdo.io, crawled 28 Nov 2026) counts its
catalogue as **323–329 SKUs** (the count moved between crawls the same day),
split by WorkDo's own categories: Industrial Solutions **93**, Payment
Gateways **60**, Integration **29**, Social Media **24**, HR **20**, Finance
**18–20**, Content Management **14**, Security **12**, Communication **9**,
Operation **8**, Sales **7**, Calendar **6**, Customization **6**, e-Commerces
**5**, Dash Mobile Apps **5**, AI **3–4**, Support **1**.

This map names **individually** every functional business module/addon that
could be verified by name from at least one WorkDo source (store category
listings, the product page, WorkDo's own changelogs, or our zip audit of the
shipped product): **110 individual rows**. The pure long tail — individual
payment gateways, individual SMS providers, individual social sign-ins — is
carried in **3 class rows covering 81 SKUs**, because each member of those
classes is the same one-purpose integration shape. The industry table names
**47** of the 93 industry SKUs individually; the remaining ~46 are
micro-verticals whose full list WorkDo does not publish in any page we could
fetch (the bundle page markets "90+" without enumerating them) — they are
carried as one class row in §3 and assessed there.

**Verdict key:** COVERED = our side has the capability (live, built-in, or a
KB-verdict app on the wave train) · PARTIAL = the core exists but a named
piece is missing/thinner · GAP = nothing on our side · N/A = excluded by an
owner decision (not a gap — a choice). **Level** = surfacing level per census
§8.6 (L1 own-UI re-theme · L2 generic renderer · L3 hand-built product face).
**Kab** uses the recon wave train: W0 Payments → W1 Wiki/Raven/Gameplan/
Insights/Builder → W2 Telephony→Helpdesk, Lending, Education, Healthcare,
Shipping, Ecommerce Integrations → W3 HRMS, CRM, Webshop, FBR-eval, Sendqon
integration → W4 URY/POSNext proof-decides · "Later" = pass-2 EVALUATE apps
(post-proof) · "Wiring" = no install, SPA/governed-seam lanes only · "Live" =
already on tenants (oc71) · "Platform" = provider/Keycloak layer, already
built.

---

## 1. Module table A — WorkDo base / core modules (in the $49/$499 product)

| # | WorkDo module (Kya) | Our covering source | Verdict | Level | Kesy (how) | Kab (when) |
|---|---|---|---|---|---|---|
| A1 | Accounting (base — income/expense, invoices, bills) | ERPNext Accounts (built-in) | COVERED | L3 | Already our product face; deeper than WorkDo base | Live |
| A2 | HRM + Payroll (base — employees, attendance, leave, payroll) | Frappe HRMS (KB1 §3.2) | COVERED | L1 | Install + re-theme; PK payroll = tenant Salary-Structure config | W3 |
| A3 | CRM / Lead (base — leads, deals, pipelines) | Frappe CRM (KB1 §3.3, sync OFF); fallback built-in CRM doctypes | COVERED | L1 | Install + re-theme inside shell | W3 |
| A4 | POS (base — counter sales, barcode) | ERPNext built-in POS doctypes (KB1 §2.1) | COVERED | L3 | Governed seam only (W-T1 complete-sale/hold/resume) + SPA wiring | Wiring |
| A5 | Product & Service (base catalogue) | ERPNext Item / service items (built-in) | COVERED | L3 | Already wired in Selling/Buying/Stock lanes | Live |
| A6 | Taskly — Projects & Tasks (base) | ERPNext built-in Projects (KB1 §2.2) | COVERED | L2 | Wire SPA over core Project/Task/Timesheet — no install | Wiring |
| A7 | Landing Page / CMS (base) | Frappe Builder (KB1 §3.15, tenant pages); provider landing pages = console build (Cursor) | PARTIAL | L1 | Install Builder (tenant side); provider side stays our own build | W1 |
| A8 | Messenger (base, Chatify in-app chat) | Frappe Raven (KB1 §3.16) | COVERED | L1 | Install + embed/re-theme | W1 |
| A9 | SaaS core — workspaces, plans, subscriptions, super-admin, addon-to-plan assignment | **Our own provider platform** (console + portal + provisioning + entitlements, Aureus wave live) | COVERED | — | Custom — already built, and stronger (Keycloak SSO, per-app/per-integration pricing) | Live |
| A10 | Stripe + PayPal (core payment modules) | Frappe Payments (KB1 §3.1) | COVERED | L2 | Install; tenant's own gateway creds | W0 |

**Table A totals: 10 rows — COVERED 9 · PARTIAL 1 · GAP 0.**

---

## 2. Module table B — WorkDo premium add-ons (named individually)

### 2.1 HR & people (WorkDo category: HR, 20)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 1 | Recruitment ($49/$24) | HRMS (Job Applicant/Offer/Onboarding) | COVERED | L1 | Rides the HRMS install | W3 |
| 2 | Performance ($39/$19) | HRMS Appraisal | COVERED | L1 | Rides HRMS | W3 |
| 3 | Training ($29/$14) | HRMS Training + LMS | COVERED | L1 | Rides HRMS/LMS | W3 |
| 4 | LMS ($39/$19) | Frappe LMS (KB1 §3.6) | COVERED | L1 | Install after Payments | W3 (after W0) |
| 5 | Rotas ($29) | HRMS Shift Type / Shift Assignment | COVERED | L2 | Rides HRMS; roster screens generic | W3 |
| 6 | Biometric Attendance ($49/$24) | HRMS Employee Checkin + frappe biometric-sync tool (LAN-side, KB1 §5) | PARTIAL | L2 | Checkin doctypes wire clean; the device-sync tool is a tenant-LAN utility, not a bench install | W3 |
| 7 | Timesheet ($49) | ERPNext Timesheet (built-in) | COVERED | L2 | Wire over core | Wiring |
| 8 | Time Tracker ($29/$14) | Built-in Timesheet / Activity Cost | PARTIAL | L2 | Timer UX is a thin SPA piece over the same doctypes | Wiring |
| 9 | Team Workload ($29/$14) | Built-in Projects (task assignment views) | PARTIAL | L2 | Workload view = one generic screen over Task assignments | Wiring |
| 10 | Job Search | LMS jobs board + HRMS Job Opening portal | PARTIAL | L1 | Both halves exist in two apps; no single merged board | W3 |
| 11 | Business Plan | — | GAP | — | Strategic-planning document tool; no Frappe counterpart found | — (see §5) |
| 12 | PESTEL Analysis Model | — | GAP | — | Strategy-template tool; no counterpart | — (§5) |
| 13 | Planning | — | GAP | — | Planning templates; no counterpart named in either KB pass | — (§5) |

### 2.2 Finance & accounting (WorkDo category: Finance, 18–20)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 14 | Double Entry ($39/$19) | ERPNext GL / Journal Entry (built-in, true double-entry) | COVERED | L3 | Already the Finance face — deeper than the add-on | Live |
| 15 | Recurring Invoice/Bill ($39/$19) | ERPNext Auto Repeat / Subscription (built-in) | COVERED | L2 | Wire over core | Wiring |
| 16 | Financial Goal ($39/$19) | — | GAP | — | Goal/target tracking has no doctype home; Budget is not goal tracking | — (§5) |
| 17 | Budget Planner ($39) | ERPNext Budget (built-in) | COVERED | L2 | Wire over core | Wiring |
| 18 | Petty Cash Management | Payment Entry / Expense Claim (built-in) | PARTIAL | L2 | Petty-cash book = a view + limits over Payment Entry | Wiring |
| 19 | Retainer | Advance payments against Sales Order/Invoice (built-in) | PARTIAL | L2 | Retainer ledger = advances view; no dedicated retainer doctype | Wiring |
| 20 | Quotation ($39) | ERPNext Quotation (built-in) | COVERED | L3 | Already in the Sales face | Live |
| 21 | Contract ($39/$19) | ERPNext Contract (built-in) | COVERED | L2 | Wire over core; e-sign via Nesscale (pass 2) later | Wiring |
| 22 | ZATCA ($29) | KSA Compliance — LavaLoon (KB1 §4.1, USE) | COVERED | L2 | Install; sandbox cycle first, tenant's own Fatoora onboarding | W3 |
| 23 | QuickBooks (sync) | — | GAP | — | External-accounting sync; our GL is the system of record — migration tool only | — (§5) |

### 2.3 Sales, CRM & marketing (WorkDo categories: Sales 7 · Social/Comms spread)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 24 | Sales ($39/$19) | ERPNext Selling (built-in) | COVERED | L3 | Already the Sales face | Live |
| 25 | Commission ($49/$24) | Sales Partner / Sales Person commission (built-in) | PARTIAL | L2 | Commission rules exist; payout-approval workflow is thinner | Wiring |
| 26 | Sales Agent ($39/$19) | Sales Person + Territory (built-in) | PARTIAL | L2 | Agent tiers = config on Sales Person tree | Wiring |
| 27 | Newsletter ($19/$9) | Frappe core Newsletter / Email Campaign (built-in) | COVERED | L2 | Wire over core | Wiring |
| 28 | Feedback ($39/$19) | Helpdesk article feedback + Wiki feedback | PARTIAL | L1 | Feedback collection exists per-surface; no standalone feedback-form product | W2 |
| 29 | Mailchimp ($49/$24) | Core Email Campaign (no Mailchimp sync) | PARTIAL | L2 | Campaigns native; the Mailchimp bridge itself is absent | Wiring |
| 30 | SalesForce (sync) | — | GAP | — | Sync to an external CRM makes no sense when our CRM is in-tenant | — (§5) |
| 31 | Find Google Leads ($69/$34) | — | GAP | — | Lead-scraping tool; no community counterpart | — (§5) |
| 32 | HubSpot (sync) | — | GAP | — | Same class as #30 | — (§5) |
| 33 | Pipedrive (sync) | — | GAP | — | Same class as #30 | — (§5) |

### 2.4 Support (WorkDo category: Support, 1)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 34 | Support Ticket ($39/$19) | Frappe Helpdesk + Telephony (KB1 §3.4) | COVERED | L1 | Install; HD Ticket also backs the portal ticketing bridge | W2 |
| 35 | Hubspot Support Ticket | Helpdesk (ticket store exists; HubSpot as a *source* does not) | PARTIAL | L1 | Tickets covered; HubSpot ingestion is not | W2 |

### 2.5 Operations, inventory & logistics (WorkDo category: Operation, 8)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 36 | Inventory ($39) | ERPNext Stock (built-in — ledger, warehouses, valuation) | COVERED | L3 | Already the Stock face; far deeper than the add-on | Live |
| 37 | Assets ($49/$24) | ERPNext Asset (built-in) | COVERED | L2 | Wire over core | Wiring |
| 38 | Asset Borrow & Rent ($39) | Asset Movement (built-in) | PARTIAL | L2 | Borrow/return exists as movements; rental billing is not modelled | Wiring |
| 39 | CMMS ($39/$19) | ERPNext Asset Maintenance + Maintenance Schedule (built-in) | PARTIAL | L2 | Maintenance core exists; work-order UX is Desk-class today | Wiring |
| 40 | Fix Equipment ($69/$34) | Asset + spare-parts stock (built-in) | PARTIAL | L2 | Parts/kits = BOM-lite over stock; no dedicated repair-kit product | Wiring |
| 41 | Fleet ($39) | Vehicle / Driver / Delivery Trip (built-in) | PARTIAL | L2 | Core fleet records exist; cargo depth = Cargo Management (pass 2, needs bench ≥16.60) | Wiring / Later |
| 42 | Consignment Management System | Stock transfers + consignment stock entries (built-in) | PARTIAL | L2 | Consignment is modelled as stock movement, not a named workflow | Wiring |
| 43 | Procurement | ERPNext Buying (built-in) | COVERED | L3 | Already the Buying face | Live |

### 2.6 Projects & productivity (spread across Integration/Operation)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 44 | Project Template ($29) | Project Template (built-in in core Projects) | COVERED | L2 | Wire over core | Wiring |
| 45 | Diagram ($39) | — | GAP | — | In-app diagram editor; Builder/Gameplan pages are not diagrams | — (§5) |
| 46 | Trello (sync) | — | GAP | — | External board sync; our Projects/Gameplan are in-tenant | — (§5) |
| 47 | Jira (sync) | — | GAP | — | Same class | — (§5) |
| 48 | Asana (sync) | — | GAP | — | Same class | — (§5) |
| 49 | Microsoft To Do (sync) | — | GAP | — | MS 365 app (pass 2) covers Outlook/Teams/SharePoint, not To Do | — (§5) |

### 2.7 AI (WorkDo category: AI, 3–4)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 50 | AI Assistant ($39/$19) | **operqon_rag (our own app, live)** + FAC (pass 2, EVALUATE) | PARTIAL | L1 | RAG Q&A is live today; FAC adds tool-use operation of the ERP — proof pending | Live / Later |
| 51 | AI Document ($39) | FAC / changAI (pass 2, EVALUATE) | PARTIAL | L1 | Document AI routes to the FAC class; no maintained OCR app exists (pass 2) | Later |
| 52 | AI Business Advisor | FAC + Insights (dashboards) | PARTIAL | L1 | Advisory = assistant + BI; neither is a finished advisor product yet | Later |

### 2.8 Content & documents (WorkDo category: Content Management, 14)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 53 | Spreadsheet ($29/$14) | — | GAP | — | No in-ERP spreadsheet in the Frappe stack (Insights tables are not a spreadsheet) | — (§5) |
| 54 | Form Builder ($49) | Frappe Web Form + Builder (built-in/app) | COVERED | L2 | Web Forms are core; visual building = Builder | W1 |
| 55 | File Sharing | Core File + S3 Attachments (pass 2, USE-candidate) | PARTIAL | L2 | Drive is archived upstream; sharing = File permissions + links, no Drive-class product | Later |
| 56 | Video Hub ($29) | LMS course media | PARTIAL | L1 | Video lives inside LMS; no standalone video hub | W3 |
| 57 | Internal Knowledge (KB) ($19) | Frappe Wiki (KB1 §3.14) | COVERED | L1 | Install (GitHub sync stays disabled until cert path reviewed) | W1 |
| 58 | EMail Box ($29) | Frappe core Email Account / Email Inbox (built-in IMAP) | COVERED | L2 | Wire over core | Wiring |
| 59 | Calendar ($29) | Core Event / Calendar (built-in) | COVERED | L2 | Wire over core | Wiring |
| 60 | Notes ($19) | Core Note (built-in) | COVERED | L2 | Wire over core | Wiring |
| 61 | Activity Log | Core Activity Log / Version (built-in) | COVERED | L2 | Wire over core | Wiring |
| 62 | Google Docs (integration) | — | GAP | — | Per-tenant Google-doc embedding; no app | — (§5) |
| 63 | Google Slides (integration) | — | GAP | — | Same class | — (§5) |
| 64 | OneNote (integration) | — | GAP | — | MS 365 app covers SharePoint files, not OneNote sync | — (§5) |

### 2.9 Customization & platform add-ons (WorkDo category: Customization, 6)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 65 | Custom Field ($29) | Customize Form / Custom Field (built-in platform feature) | COVERED | L2 | Platform-native in Frappe — stronger than the add-on | Platform |
| 66 | Side Menu Builder ($9) | Workspace + SPA shell configuration | PARTIAL | L2 | Menus are workspace-driven; no tenant-facing menu *builder* UI | Wiring |
| 67 | API ($89) | Frappe REST API + Webhooks (built-in, every DocType) | COVERED | — | Platform-native; this is the seam the whole wiring plan runs on | Platform |
| 68 | vCard (digital business cards) | — | GAP | — | No vCard product in either KB pass | — (§5) |

### 2.10 Communication & meetings (WorkDo categories: Communication 9 · Social Media 24 · Integration 29)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 69 | WhatsApp API ($49/$24) | **Excluded by owner decision 2026-11-26** — messaging = Sendqon integration | N/A | — | Not a gap: a deliberate product choice; Sendqon covers tenant messaging with the tenant's own account | W3 (Sendqon) |
| 70 | WhatsApp Chat ($49/$24) | Same owner decision | N/A | — | Same as #69 | W3 (Sendqon) |
| 71 | WhatsApp (Twilio) ($39/$19) | Same owner decision | N/A | — | Same as #69 | W3 (Sendqon) |
| 72 | Telegram ($39/$19) | — | GAP | — | Notifications ride email/Raven/Sendqon-SMS; no Telegram channel | — (§5) |
| 73 | Slack ($39/$19) | Webhook pattern (core Webhooks can post out) | PARTIAL | L2 | Outbound posts possible via Webhook; no Slack product surface | Wiring |
| 74 | SMS ($39/$19) | **Sendqon integration (custom, ours)** | COVERED | L2 | Our own SMS platform is the messaging layer — by design, not by purchase | W3 |
| 75 | Call Hub ($39) | Frappe Telephony (TP Call Log) | PARTIAL | L2 | Call logs wire; a call-centre hub UX does not exist | W2 |
| 76 | WizzChat Messenger | Raven (in-app team chat) | COVERED | L1 | Raven replaces the in-app messenger class | W1 |
| 77 | Zulip Chat | Raven (own chat yes; Zulip bridge no) | PARTIAL | L1 | Same as #76 for chat itself | W1 |
| 78 | Zoom Meeting ($39) | LMS Live Class (Zoom) | PARTIAL | L1 | Live classes cover the meeting-inside-ERP case; standalone meeting scheduling is thinner | W3 |
| 79 | Google Meet ($29) | LMS Live Class | PARTIAL | L1 | Same class as #78 | W3 |
| 80 | Jitsi Meet | — | GAP | — | No Jitsi integration found | — (§5) |
| 81 | Whereby Meeting | — | GAP | — | No integration found | — (§5) |
| 82 | Zoho Meeting | — | GAP | — | No integration found | — (§5) |
| 83 | Livestorm Meeting | — | GAP | — | No integration found | — (§5) |

### 2.11 Automation, API & external syncs (WorkDo category: Integration, 29)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 84 | Webhook ($69/$34) | Core Webhooks (built-in) | COVERED | — | Platform-native | Platform |
| 85 | Zapier ($49/$24) | REST API + Webhooks pattern (KB2 §P2.3) | COVERED | — | No app needed — Zapier connects to the standard API | Platform |
| 86 | n8n ($39/$19) | REST API + Webhooks pattern | COVERED | — | Tenant connects their own n8n via API keys | Platform |
| 87 | Pabbly Connect ($49/$24) | Webhook pattern only | PARTIAL | — | No official node; generic webhook triggers work | Platform |
| 88 | Make (integration) | Webhook pattern only | PARTIAL | — | Same as #87 | Platform |
| 89 | Workflow Automation ($29) | Frappe Workflow + Assignment Rules (built-in) | COVERED | L2 | Wire over core | Wiring |
| 90 | Google Analytics ($49/$24) | — | GAP | — | Internal BI = Insights; GA traffic embed is not a product on our side | — (§5) |
| 91 | WHMCS ($39) | — | GAP | — | Hosting-billing niche sync; our provider billing is our own platform | — (§5) |
| 92 | WordPress / WooCommerce ($39) | Ecommerce Integrations (Shopify/Amazon/Unicommerce/Zenoti — **not** WooCommerce) | PARTIAL | L2 | Storefront sync exists for other platforms; WooCommerce specifically is missing | W2 |
| 93 | IndiaMART | — | GAP | — | India-only B2B marketplace; no counterpart | — (§5) |
| 94 | Google Wallet ($39) | — | GAP | — | Pass/loyalty wallet; no counterpart | — (§5) |

### 2.12 Security & identity (WorkDo category: Security, 12)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 95 | Google Captcha ($39) | Cloudflare Turnstile at Keycloak (platform, live) | COVERED | — | Platform layer — already stronger than a captcha add-on | Platform |
| 96 | Google Authentication / 2FA ($39) | Keycloak TOTP + WebAuthn (platform, live) | COVERED | — | Platform layer | Platform |
| 97 | Backup & Restore ($69) | Core scheduled backups + S3 target (built-in) | COVERED | — | Platform ops; S3 Attachments adds attachment offload | Platform |
| 98 | Sign-In With… — class row: Google, Facebook, LinkedIn, Twitter, Microsoft, Outlook, Slack, GitHub, Bitbucket + 1 (10 SKUs) | Keycloak social identity providers (platform) | COVERED | — | One IdP configuration replaces ten add-ons | Platform |

### 2.13 E-commerce & mobility (WorkDo categories: e-Commerces 5 · Mobility/Dash Mobile Apps 5)

| # | WorkDo add-on | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 99 | Dash Mobile Apps (5 SKUs — HRM/field/ POS companion apps) | Responsive SPA + L1 apps' own mobile-ready UIs | PARTIAL | L1/L2 | No native apps on our side; the SPA is mobile-web (FR-004 mobile-nav lane is open) | Wiring |
| 100 | Shopify / Amazon / marketplace sync | Ecommerce Integrations (KB1 §3.12) | COVERED | L2 | Install; tenant's own platform creds | W2 |
| 101 | Online store / storefront | Frappe Webshop (KB1 §3.11) | COVERED | L1 | Install after Payments; route-survival proof owed | W3 |

### 2.14 Class rows — the integration long tail (81 SKUs in 3 classes)

| # | WorkDo class | Our covering source | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| 102 | **Payment Gateways — 60 add-on SKUs.** Named on WorkDo pages: Stripe, PayPal, Razorpay, Mollie, Paystack, Flutterwave, PayTabs, Tap, Mercado Pago, Xendit, YooKassa, Midtrans, Ozow, PayTR, AamarPay, Authorize.Net, Benefit, CinetPay, FedaPay, Khalti, Iyzipay, senangPay, CyberSource, Easebuzz, 2Checkout, Esewa, Instamojo, Square, Paynow, Braintree, PayU, Fatora, NMI, Moyasar, PowerTranz, DPO Pay, MyFatoorah, Monnify, UddoktaPay, Adyen, Yoco, Moneris, Pesapal, PayPay, Checkout, PayFort, CoinPayments, BTCPay, BlueSnap, SSPay, PayHere, BitPay, Paiement Pro, ToyyibPay, SSLCommerz, LinePay, Peach Payments (+ core Paytm, Skrill, Paddle, CoinGate) | Frappe Payments (Stripe, Razorpay, PayPal, Braintree, GoCardless, Mpesa, Paymob, Paytm) + pass-2 EVALUATE: Moyasar (KSA), Paymob (deeper), Paystack + **custom: JazzCash, Easypaisa, PayFast (PK)** | PARTIAL | L2 | Gateway *breadth* is WorkDo's one real catalogue advantage: ~11 gateways reachable on our side vs their 60 — but gateways are per-tenant, one at a time, added as settings doctypes; the three gateways our market actually uses (JazzCash/Easypaisa/PayFast-PK) exist in **neither** catalogue off the shelf — WorkDo's "PayFast" add-on is the South-African gateway, not Pakistan's | W0 + Later + Custom queue |
| 103 | **SMS provider add-ons — ~11 SKUs** (Twilio, Vonage, Sinch, Plivo, MSG91, Telesign, Zita, ClickSend, Fast2SMS, Africa's Talking, Bulk SMS) | **Sendqon (owner decision)** — our own SMS gateway platform; Telephony TP SMS Log for call/SMS records | N/A | — | Deliberate substitution, not a gap: tenants message through their own Sendqon account | W3 (Sendqon) |

**Table B totals: 103 rows — COVERED 39 · PARTIAL 32 · GAP 28 · N/A 4.**
(WhatsApp ×3 + SMS-providers class = the 4 N/A rows, all owner-decision substitutions.)

---

## 3. Industry-pack table — WorkDo industry solutions (93 claimed; 47 named)

Our packages are KB pass 2 §P2.4's 16 assembled packages. Level = the
package's dominant surfacing level (KB2 §P2.4). Kab = the wave of the
package's main engine app.

| # | WorkDo industry solution | Our assembled package (KB2 §P2.4) | Verdict | Level | Kesy | Kab |
|---|---|---|---|---|---|---|
| I1 | Hospital Management | #3 Clinic/Hospital (Healthcare + HRMS + Payments) | COVERED | L2 | Install + generic screens | W2 |
| I2 | School / Institute Management | #2 School ERP (Education + LMS + HRMS + Payments) | COVERED | L2 (L1 LMS portal) | Install + wire; PK fee fixtures are config-class | W2–W3 |
| I3 | Hotel & Room Management | #5 Hotel (Hospitality PMS *or* Core + core + Payments) | COVERED | L1 | Proof-install picks the candidate; re-brand its front desk | Later |
| I4 | Property Management | #10 Real Estate (OmoroJr + CRM + core) | PARTIAL | L2 | Candidate repo has **no LICENSE file** — fallback is CRM + a small custom lease pack | Later |
| I5 | Gym Management | #9 Gym (GymStack + Payments + HRMS) | COVERED | L2 | GymStack v16 proof owed | Later |
| I6 | Spa Management | #8 Salon/Spa (built-ins + Payments) | PARTIAL | L2 | Named custom gap: staff-resource scheduling + commissions (small extension) | Wiring + custom |
| I7 | Beauty Spa Management | #8 Salon/Spa | PARTIAL | L2 | Same package as I6 | Wiring + custom |
| I8 | Construction Management | *No KB2 package* — composition exists (built-in Projects + Buying + HRMS) but was never packaged | PARTIAL | L2 | Add as assembled package #17: project costing/BOQ over core Projects; no new engine | Wiring |
| I9 | Legal Case Management | *None* | GAP | — | No legal app in either KB pass; composition would need custom case/matter doctypes | — (§5) |
| I10 | Courier Management | #11 Logistics/Cargo (Cargo Mgmt + Shipping + core) | COVERED | L2 | Cargo needs bench ≥16.60 first | Later |
| I11 | Freight Management System | #11 Logistics/Cargo | COVERED | L2 | Same package as I10 | Later |
| I12 | Tour & Travel Management | *None* | GAP | — | No travel app found; bookings/itineraries unmodelled | — (§5) |
| I13 | Catering Management | #6 Restaurant-adjacent (URY + POS + Payments) | PARTIAL | L1 | Catering = restaurant engine + event orders; no catering-specific surface | Later (W4 class) |
| I14 | Cleaning Management | #12 Services/Agency (Projects + Helpdesk + HRMS) | PARTIAL | L2 | Recurring service jobs = Projects + schedules; no cleaning-specific pack | Wiring |
| I15 | Mobile Service Management | #12 Services (Helpdesk field tickets) | PARTIAL | L2 | Field-service = HD Ticket + mobile SPA; no dedicated FSM app | W2 |
| I16 | Machine Repair Management | #12 Services + built-in Asset Maintenance | PARTIAL | L2 | Repair jobs over Maintenance/Issue doctypes | Wiring |
| I17 | Repair Management System | #12 Services | PARTIAL | L2 | Same class as I16 | Wiring |
| I18 | Garage Workshop Management | #12 Services + EV-adjacent job cards | PARTIAL | L2 | Workshop job cards = Issue/Maintenance Visit pattern (EV pack proves it for bikes) | Wiring |
| I19 | Insurance Management | *None* (Lending is loans, not insurance) | GAP | — | No insurance app in either pass; regulated domain | — (§5) |
| I20 | Rental Management | #10 Real Estate + built-in Assets | PARTIAL | L2 | Equipment/property rental = lease + asset movements; no rental product | Later |
| I21 | Exam | Inside #2 School ERP (Education Assessment Plan/Result) | COVERED | L2 | Rides the Education install | W2 |
| I22 | Visitor Management | *None dedicated* | GAP | — | No visitor/front-desk app found | — (§5) |
| I23 | Events Management | Core Event/Calendar + Gameplan | PARTIAL | L1/L2 | Events exist as calendar objects; no event-business (ticketing/venues) product | W1 |
| I24 | Fleet (industry) | #11 Logistics-adjacent + built-in Vehicle | PARTIAL | L2 | Fleet records in core; GPS tracking is an external-system gap (KB2) | Later |
| I25 | Radiology Management | Inside #3 Clinic (Marley lab/imaging class) | PARTIAL | L2 | Lab tests exist in Healthcare; radiology-specific workflow is thinner | W2 |
| I26 | Childcare Management | #2 School-adjacent (Education) | PARTIAL | L2 | Student/guardian model fits; childcare-specific (pickup, meals) unmodelled | W2 |
| I27 | Music Institute | #2 School + LMS | PARTIAL | L2 | Courses/lessons fit Education+LMS; no institute-specific pack | W2–W3 |
| I28 | Newspaper Distribution Management | *None* | GAP | — | No distribution-rounds app; niche | — (§5) |
| I29 | Vehicle Inspection Management | Built-in Quality Inspection + custom checklist | PARTIAL | L2 | Inspection doctypes exist; vehicle-inspection pack does not | Wiring |
| I30 | Vehicle Wash | #12 Services | PARTIAL | L2 | Wash jobs = service tickets + POS | Wiring |
| I31 | DJ & Orchestra Management | *None* (Events-adjacent only) | GAP | — | Entertainment-booking niche | — (§5) |
| I32 | Library Management | *None dedicated* | GAP | — | No library app in either pass (Wiki is knowledge pages, not circulation) | — (§5) |
| I33 | Grant Management | *None* | GAP | — | Nonprofit grants; no app found | — (§5) |
| I34 | Boutique & Designer Studio | #7 Retail/POS Shop | PARTIAL | L3 | Retail engine covers it; studio-specific (orders/alterations) unmodelled | Wiring |
| I35 | Jewellery Store Management | #7 Retail (batch/serial stock) | PARTIAL | L3 | Serial/batch stock fits jewellery; no jewellery-specific pack | Wiring |
| I36 | Society Management (housing) | #10 Real-Estate-adjacent | PARTIAL | L2 | Units/dues fit the lease model; society governance unmodelled | Later |
| I37 | Office Equipment Management | Built-in Assets + IT Management (pass 2) | PARTIAL | L2 | CMDB covers equipment depth | Later |
| I38 | Optical & Eye Care Center | Inside #3 Clinic (Healthcare) | PARTIAL | L2 | Patient/encounter model fits; optical prescriptions/frames unmodelled | W2 |
| I39 | Elderly Care Management | Inside #3 Clinic-adjacent | PARTIAL | L2 | Care plans unmodelled; patient core fits | W2 |
| I40 | Diet & Nutrition Consultant | #3 Clinic / #9 Gym-adjacent | PARTIAL | L2 | No diet-plan product on our side | W2 / Later |
| I41 | Quiz Management | Inside Frappe LMS (LMS Quiz) | COVERED | L1 | Rides the LMS install | W3 |
| I42 | Garden Management | #14 Agriculture / #12 Services-adjacent | PARTIAL | L2 | Farm/service composition fits loosely; no garden pack | Later |
| I43 | Vehicle Trade | #1 EV Showroom-adjacent (vehicle sales spine) | PARTIAL | L3 | The EV pack's serial-spine sales flow generalises; a general vehicle-trade pack is not built | Wiring |
| I44 | Tailoring & Fashion Design | #13 Garment Manufacturing (Apparelo + ERPNext Mfg) | COVERED | L2 | Apparelo freshness risk noted in KB2 | Later |
| I45 | Car Dealership | #1 EV Showroom-adjacent | PARTIAL | L3 | Same sales spine as I43; car-specific pack not built | Wiring |
| I46 | Bookings | Built-in Appointment + packages' booking surfaces | PARTIAL | L2 | Booking exists per-domain; no standalone bookings product | Wiring |
| I47 | Restaurant Menu (QR table ordering) | Inside #6 Restaurant (URY) | PARTIAL | L1 | URY covers restaurant POS/KDS; the QR-menu surface specifically is a proof item | Later (W4 class) |
| I48 | *Class row — the remaining ~46 industry SKUs* (micro-verticals WorkDo markets inside the bundle but does not enumerate publicly: trade-specific variants of the retail/services/healthcare classes above) | Our 16 packages + compositions | PARTIAL (as a class) | L2 | Every micro-vertical we could name from WorkDo's changelogs/store mapped to an existing package or a PARTIAL above; the unnamed remainder are, by WorkDo's own category descriptions, preconfigured bundles of the same base modules — the same composition logic applies, per-vertical proof owed before any is sold | Per package |

**Industry totals: 48 rows (47 named + 1 class) — COVERED 9 · PARTIAL 31 · GAP 8.**
Our side fields **16 assembled industry packages**; WorkDo's 93 are mostly
*preconfigurations of the same base modules* (their changelog shows them
arriving as add-ons on one shared core), which is exactly why 40 of 48 rows
land on a package or a composition we already have.

---

## 4. Totals — the whole map in one place

**Modules (Tables A + B = 113 rows):**

| Verdict | Count | Reading |
|---|---|---|
| COVERED | **48** | 9 base + 39 add-ons |
| PARTIAL | **33** | 1 base + 32 add-ons — core exists, a named piece is thinner |
| GAP | **28** | All in Table B; itemised in §5 |
| N/A (owner decision) | **4** | WhatsApp ×3 + SMS-provider class — Sendqon substitution, deliberate |
| **Total** | **113** | = 110 individually named + 3 class rows (81 SKUs inside the classes) |

**Covered/Partial rows by primary covering source (81 rows):**

| Source | Rows | What it means |
|---|---|---|
| ERPNext/Frappe **built-ins** + platform (Keycloak/core) | **46** | Nearly half the map costs no install at all — wiring and surfacing only |
| **Community apps** (KB pass 1 USE + pass 2 candidates) | **31** | The app-first train: Payments, HRMS, CRM, Helpdesk, LMS, Wiki, Raven, Builder, Webshop, Ecommerce Integrations, KSA Compliance, Telephony, FAC class… |
| **Custom (ours)** | **4** | Provider platform (A9), operqon_rag (50), Sendqon integration (74), SPA/mobile shell (99) |

**Industry packs (48 rows):** COVERED 9 · PARTIAL 31 · GAP 8 — against our
**16 assembled packages**, of which 14 compose with zero or configuration-class
gaps (KB2 §P2.4).

**The honest one-liner:** of everything WorkDo sells that an SMB would
recognise as a business feature, **81 of 113 mapped rows already exist on our
side** (48 fully, 33 in core form), 28 are absent — and §5 shows most of the
28 are external-sync add-ons and strategy templates an SMB tenant would
rarely ask for, not missing ERP engines. WorkDo's genuine catalogue
advantages are exactly two: **payment-gateway breadth (60 vs ~11 reachable)**
and **industry preconfigurations sold as SKUs (93 vs our 16)** — breadth of
packaging, not depth of engine. Our accounting, stock and manufacturing
engines are deeper than theirs at every point where the two overlap.

---

## 5. Genuine gaps — WorkDo items with NO counterpart, SMB-plausibility judged

From the 28 module GAPs + 8 industry GAPs. Recommendation per item:
**BUILD** (worth having), **SKIP** (no SMB demand case), or **LATER** (real
but not on the SMB-essential path).

| Gap | SMB-plausible? | Recommendation |
|---|---|---|
| Payment-gateway long tail (~49 gateways we can't reach) | One at a time, when a tenant's market needs it | **LATER, per-tenant** — gateways are settings-doctype work on the Payments framework; add on demand, never in bulk. The PK three (JazzCash/Easypaisa/PayFast) are already custom-queued and matter more than all 49 |
| Spreadsheet (in-ERP) | Moderate — SMB users live in spreadsheets | **SKIP for now** — export-to-Excel + FR-002/Insights covers reporting; revisit only if tenants ask |
| vCard (digital business cards) | Moderate — popular with PK SMB owners/sales staff | **LATER** — small standalone product shape (public page + QR); not an ERP lane; candidate for a cheap Store add-on later |
| Financial Goal | Low–moderate | **SKIP** — a small custom doctype if ever asked; not worth a lane |
| Business Plan / PESTEL / Planning templates | Low | **SKIP** — strategy-document templates, not operations |
| Diagram editor | Low | **SKIP** — Gameplan/Builder pages cover documentation needs |
| External SaaS syncs (Salesforce, HubSpot, Pipedrive, Trello, Jira, Asana, MS To Do, QuickBooks, Google Docs/Slides, OneNote, IndiaMART, WHMCS, Google Wallet, Google Analytics) | Low for our tenants — these sync *away* from the ERP the tenant is paying us for | **SKIP as a class** — the REST+Webhook pattern (#84–88) is the standing answer for any tenant who truly needs one |
| Meeting long tail (Jitsi, Whereby, Zoho, Livestorm) | Low | **SKIP** — Zoom/Meet via LMS Live Class covers the plausible case |
| Telegram channel | Low | **SKIP** — email/Raven/Sendqon-SMS notification set is sufficient |
| Legal Case Management (industry) | Moderate — law firms are real SMBs in PK | **LATER** — composition candidate (CRM + Projects + custom matter doctypes); add as assembled package when a legal customer appears, not before |
| Construction packaging (industry — PARTIAL, not GAP) | **High** — contractors/builders are core PK SMB | **BUILD (packaging only)** — promote to assembled package #17: core Projects costing + Buying + HRMS, no new engine; cheapest industry win on this list |
| Visitor Management | Low–moderate | **LATER** — tiny custom doctype set if a tenant asks |
| Library Management | Low | **SKIP** — schools use Education/LMS; standalone libraries are rare tenants |
| Tour & Travel, Insurance, Newspaper Distribution, DJ/Orchestra, Grant Management (industries) | Low / regulated (insurance) | **SKIP** — no demand signal in our market; insurance is a regulated domain, not a packaging exercise |
| WooCommerce sync (PARTIAL #92) | Moderate — WooCommerce is common in PK retail | **LATER** — the one external-sync worth an exception: evaluate a WooCommerce bridge after Ecommerce Integrations is live (W2) |

**Net:** of 36 total gaps, exactly **one packaging action** (Construction
#17) and **two later candidates** (Legal composition, WooCommerce bridge)
survive SMB-plausibility screening. Nothing in WorkDo's catalogue is a
missing engine we would have to build.

---

## 6. The decision page — what $793 actually buys, in light of the full map

*(Prices/licence from the companion comparison, verified 28 Nov 2026:
Extended License $499 — the only SaaS-usable basis — + SMB-essential add-ons
≈ $294 at that day's sale = **≈ $793 one-time, $0 recurring**. The $3,999
Complete Bundle and $938 list-price scenario are in the companion doc.)*

### What buying WorkDo buys
- **This-week breadth:** base + add-ons install into a working SMB ERP —
  POS, HRM, CRM, projects, helpdesk, WhatsApp notifications, ZATCA — in
  days, against our **4–6 week** app-first assembly for equivalent SMB
  parity (census §8.5).
- **Packaging breadth we don't have:** 93 industry SKUs and 60 payment
  gateways as shelf items — sales-catalogue surface, even where the
  underlying modules are the same shared core.
- **A finished tenant UI on day one** — no SPA wiring lanes between
  purchase and a sellable screen.

### What buying WorkDo does NOT give (each would still be ours to build)
- **Our provider platform** — the Aureus console, customer portal,
  provisioning pipeline and entitlement system are Operqon's, already
  built and live; WorkDo's super-admin covers the *function class* but
  not our screens, pricing model (per app + per integration, per user
  per month) or deploy discipline. Switching bases means re-platforming
  the tenant side onto Laravel while the provider side stays ours.
- **Rektrs ID / Keycloak SSO** — live across console, portal and tenants;
  WorkDo has its own auth + social-login add-ons; OIDC/Keycloak into
  Laravel is a medium custom build (companion doc §3).
- **Tenant provisioning & billing as we run it** — ocXX image train,
  per-tenant sites, entitlement-derived permissions at provisioning.
- **The DreamsERP face** — our SPA, our design system, the product's
  identity. WorkDo's UI is WorkDo's.
- **JazzCash / Easypaisa** — no PK-local gateway in WorkDo's 60 either.
  Custom on both routes.
- **Sendqon messaging** — our platform, by owner decision; WorkDo's
  WhatsApp add-ons are precisely what the owner ruled out as the
  tenant-facing path.
- **Depth where it counts:** WorkDo's base accounting is single-entry
  style until the Double Entry add-on, and still shallower than
  ERPNext's GL; its stock is right-sized but thin next to ERPNext's
  ledger. For an SMB that outgrows the simple books, the ceiling arrives
  sooner.
- **Ownership of the roadmap** — full source + white-label, yes; but the
  IP, update cadence and security-patch pace are WorkDo's (the audited
  2024 snapshot already needed a security pass).

### What assembling (our route) gives that WorkDo cannot
- One stack, owned end to end: provider platform + identity + tenant ERP
  + messaging (Sendqon) + social (Postqon) under Rektrs ID — no second
  vendor's release train inside the product.
- The app-first inventory itself: 49 censused community apps + built-ins
  composing 16 industry packages, each replaceable per-app — WorkDo's
  add-ons only run inside WorkDo.
- Accounting/stock depth that survives the tenant's growth, and the
  EV Showroom pack — an industry asset WorkDo has no equivalent of
  (their nearest is a generic Car Dealership add-on).

### Timelines side by side

| | WorkDo route | Operqon app-first route |
|---|---|---|
| Cost to start | **≈ $793 one-time** (Extended + essential add-ons, sale prices) | $0 licence (open-source apps) |
| First sellable SMB tenant | **Days** (install + brand + plans) | **~4–6 weeks** to SMB-essential parity (census §8.5) |
| Then still to build | Keycloak SSO into Laravel (medium) · console/portal re-pointing (medium–large) · JazzCash/Easypaisa (custom, same as ours) · Urdu translation pass | Nothing structural — the queue is wiring, seams and proof-installs on our own platform |
| Ongoing | Vendor updates + fork maintenance of someone else's Laravel codebase | Our own codebase; per-app replaceability |
| Data/tenants today | Only demo tenants exist — switching has never been cheaper than now (companion doc §3) | Same fact cuts the other way: nothing forces a switch this week either |

### Recommendation (the purchase remains the owner's act)
**Do not buy WorkDo as the Operqon base.** The full map removes the reason
the purchase was attractive: the breadth it seemed to offer is already
81/113 present on our side, its two real advantages (gateway count,
industry SKU count) are packaging rather than engines, and everything
that makes Operqon a platform — provider console, Keycloak SSO,
provisioning, DreamsERP face, Sendqon, JazzCash/Easypaisa — would still
be ours to build or rebuild on top of it. **The one scenario that flips
this:** if a paying SMB customer must be live *this week* and cannot wait
4–6 weeks, buy **Extended + essential add-ons only (≈ $793, never the
$3,999 bundle)** as a *stopgap product line beside* Operqon — not as its
replacement — and migrate the tenant when the app-first parity lands.
Absent that customer, the $793 buys speed we no longer need at a
platform cost we would pay for years.

---

*Sources: WorkDo catalogue facts from workdo.io store/product/bundle pages
and WorkDo changelogs, crawled 28 Nov 2026, plus our 27 Nov 2026 zip audit
of the shipped product; our-side facts from KB pass 1 + pass 2 and census
§8/§8.6 (all 28 Nov 2026). Prices are time-limited sale prices where marked
in the companion doc and may differ at checkout. Buying is Assad's act;
this document researches, maps and recommends — it does not purchase.*
