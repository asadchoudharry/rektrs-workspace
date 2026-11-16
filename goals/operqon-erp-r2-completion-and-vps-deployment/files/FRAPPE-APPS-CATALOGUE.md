# OPERQON — FRAPPE APPS CATALOGUE (1-Click Apply List)

**Date:** 2026-11-10 · **Owner request:** "Frappe Apps ki list banao according to our blueprints jo hamain is project main zarort hoon gi — jo Frappe ya third-party developed hoon unhin hum apni apps main add karin gy, jo user 1-click per apply ker saky ga, jesy CRM, HRM, FBR, ZATCA, ya jo jo bhi hain."

**Sources checked (not assumed):**
- Blueprint v2 `product/05-suite-architecture-and-app-catalogue.md` + `app-capability-matrix.csv` — 58 capabilities (APP-01…58), candidate engines named by the blueprint itself.
- Blueprint v2 `industries/` (200 use cases, 20 families, 14 anchor packs IP-01…14 / ENG-197…210) + `compliance/country-jurisdictions.csv` (48 jurisdictions).
- Blueprint v1 phase-wise plan + W2 Pakistan plan (ENG-061…096).
- Live web check 2026-11-10: Frappe official product list, Frappe Cloud Marketplace (391 apps), GitHub repos for ZATCA / POS / FBR candidates.

**Status of this document:** catalogue + adoption proposal. Presence in this list is **NOT** "installed / production-ready" — har app ENG-189 (licence/version spike) + ENG-133 (packaging matrix) gate se guzar kar hi 1-click list mein live hogi. Yehi blueprint v2 ki apni rule hai.

---

## 0. 1-Click asal mein kaise kaam karega (important — taake waada jhoota na ho)

Frappe app do layers mein hoti hai, aur 1-click dono ko mila kar banta hai:

1. **Provider layer (Operqon, ek dafa):** app ko pehle hamare tenant image / packaging matrix mein shamil, pin aur test karna hota hai (`bench get-app` build time par). Bina is ke koi tenant use install nahi kar sakta.
2. **Tenant layer (user, 1-click):** tenant admin Operqon frontend ke **App Catalogue** (ENG-122…125 app registry & entitlements) mein ja kar **Apply** dabata hai → system uski **apni site par hi** `install-app` + migrate chalata hai, dependency/conflict preview dikhata hai, backup checkpoint leta hai, phir activation wizard khulta hai jahan tenant **apni credentials** khud dalta hai (service-provider principle + integration standard: complete, self-service, validate-or-error). Dusre tenant par zero asar.

User ko jo nazar aayega wo sirf layer 2 hai — bilkul Odoo Apps / Zoho Marketplace style. Neeche ki list isi model se bani hai: **har row = ek catalogue card.**

Catalogue card ke fields (blueprint v2 §4): `display_name, app_id, version, compatible_core (Frappe/ERPNext v16), dependencies, conflicts, data_scopes, roles, quota, source_licence, country_restrictions, support_owner, install_state`.

---

## A. CORE — pehle se har tenant mein (1-click nahi, buniyad hai)

| # | Operqon naam | Frappe app | Developer | Licence | Blueprint |
|---|---|---|---|---|---|
| A1 | Operqon ERP Core | `erpnext` | Frappe (official) | GPLv3 | APP-13/14/15/17/21/28 — Sales, Buying, Stock, Accounts, Assets, Manufacturing, Projects, Quality |
| A2 | Platform | `frappe` | Frappe (official) | MIT | Buniyad — framework, Desk, permissions, workflow |
| A3 | Operqon Core | `operqon_core` | Apna (Rektrs) | Apna | Provider/tenant shell, governed write methods, firstrun, entitlements |

> ERPNext ke andar hi POS, Projects, Timesheets, Maintenance waghera maujood hain — un ke liye alag app nahi chahiye, sirf Operqon frontend mein surface karna hai (W1/W2 ka maujooda kaam).

---

## B. OFFICIAL FRAPPE APPS — Tier A (pehle 1-click batch ke candidates)

Ye sab Frappe Technologies ki apni apps hain, actively maintained hain, aur blueprint v2 ne inhein naam le kar candidate rakha hai.

| # | User ko nazar aayega | Frappe app | Kaam | Licence | Blueprint / Wave | Dependency | Tenant setup |
|---|---|---|---|---|---|---|---|
| B1 | **CRM** | `crm` (frappe/crm) | Leads, deals, pipeline, activities, calls/WhatsApp touchpoints | AGPLv3 | APP-04/05/06 · W2–W3 (ENG-212) | Frappe only; ERPNext se party bridge | Koi external credential nahi |
| B2 | **People / HRM** | `hrms` (frappe/hrms) | Employee, attendance, shifts, leave, expense, recruitment, performance, payroll | GPLv3 | APP-19/38–43/45 · W2–W3 (ENG-174/193–196, payroll pilot ENG-175 W3) | **ERPNext zaroori** · version-16 branch maujood | Country payroll pack alag se (Section E) |
| B3 | **Helpdesk** | `helpdesk` (frappe/helpdesk) | Tickets, SLA, customer portal, knowledge base | AGPLv3 | APP-32/33/34 · W3 (ENG-214) | Frappe + `telephony` | Koi nahi; email channel tenant ka apna |
| B4 | **Telephony** | `telephony` (frappe/telephony) | Exotel/Twilio calls, call logs (Helpdesk/CRM ke liye) | — (official) | APP-32/33 support · W3 | Frappe | **Tenant ke apne** Twilio/Exotel credentials |
| B5 | **Insights (BI)** | `insights` (frappe/insights) | Dashboards, governed reporting, data exploration | AGPLv3 | APP-53 · W4 (ENG-218) | Frappe only | Read-only scoped data source; leakage tests gate |
| B6 | **Learning (LMS)** | `lms` (frappe/lms) | Employee training, courses, certificates | AGPLv3 | APP-44 · W4 (ENG-216 ke saath) | Frappe only | Koi nahi |
| B7 | **Builder** | `builder` (frappe/builder) | Tenant ki apni website/pages, forms, webshop pages | MIT | APP-08/24/55 · W3 | Frappe only | Publication isolation gate |
| B8 | **Raven (Team Chat)** | `raven` (frappe/raven) | Team channels, document chat — Slack-style | AGPLv3 | APP-49 · W3–W4 (ENG-217) | Frappe only | Koi nahi |
| B9 | **Payments** | `payments` (frappe/payments) | Stripe, Razorpay, PayPal, Braintree, Paytm gateway base | MIT | APP-57 · W2 | Frappe | **Tenant ke apne** gateway credentials |
| B10 | **Webshop** | `webshop` (frappe/webshop) | Online store: catalogue, cart, checkout, ERPNext stock/prices live | GPLv3 (ERPNext family) | APP-24 · W3 (ENG-219) | ERPNext + `payments` | Tenant ka apna payment gateway |
| B11 | **Ecommerce Integrations** | `ecommerce_integrations` (frappe) | Shopify / Amazon waghera marketplace sync | — (official) | APP-24/57 · W3 | ERPNext | Tenant ke apne store credentials |
| B12 | **Print Designer** | `print_designer` (frappe) | Drag-drop print formats — hamare unified print kaam ko support | — (official) | Print / APP-55 support · W2 | Frappe | Koi nahi |

## C. OFFICIAL FRAPPE APPS — Tier B (baad mein / zaroorat par)

| # | User ko nazar aayega | Frappe app | Kaam | Blueprint / Wave | Note |
|---|---|---|---|---|---|
| C1 | Projects Pro / Gameplan | `gameplan` (frappe/gameplan) | Team projects, discussions, wiki-style collaboration | APP-35/36 · W4 | Pehle ERPNext Projects se muqabla (spike) — dono ek saath nahi |
| C2 | Knowledge / Wiki | `wiki` (frappe/wiki) | Knowledge base publishing | APP-34 · W3–W4 | Helpdesk KB se overlap — ek chuna jayega |
| C3 | Lending | `lending` (frappe/lending) | Loans, repayments, borrower accounts — microfinance/lending tenants ke liye | Industry: Nonprofit/finance families · W4 | Sirf us vertical ke tenants ke liye catalogue mein |
| C4 | Non-Profit | `non_profit` (frappe) | NGO members, donations, grants | Industry IP-12 family · W4 | Anchor pack ke saath bundle |
| C5 | Drive / Files | `drive` → Suite successor (frappe) | Governed files vault, sharing | APP-46 · W4–W5 | **HOLD** — purani Drive archived hai, successor abhi WIP hai (blueprint v2 ki apni warning). Pakka honay tak catalogue mein "Coming soon" bhi nahi |

---

## D. THIRD-PARTY APPS — Tier C (real apps hain, magar gate ke baghair 1-click nahi)

Ye community/commercial apps hain. Har ek par **spike lazmi** hai: v16 branch asal mein chalti hai ya nahi, licence SaaS use allow karta hai ya nahi, SSO/permissions/entitlement ka test, aur support owner kaun hai. Jo spike fail, wo catalogue se bahar.

| # | User ko nazar aayega | App / Developer | Kaam | Licence | Blueprint / Wave | Haqiqat check (2026-11-10) |
|---|---|---|---|---|---|---|
| D1 | **FBR Digital Invoicing (Pakistan)** | `fbr_e_invoicing` — **Pak Compliance**, DeliveryDevs-ERP (GitHub: DeliveryDevs-ERP/Pakistan-Compliance; Frappe Cloud Marketplace listed) | FBR setup + credentials, Sales Invoice **aur POS Invoice** payload + submission, queue/logs, FBR print formats, provincial sales-tax reports | Repo par verify karna hai (spike item) | APP-22 · **W2** (ENG-061…096, ENG-222) | **Sab se mazboot third-party candidate.** v15 **aur v16** branches maujood. PRAL token tenant khud dalta hai — hamare service-provider model se exact match. Phir bhi: pehle apne W2 plan/build se gap-check, phir adopt-vs-build faisla |
| D2 | **ZATCA E-Invoicing (Saudi)** | `zatca_erpgulf` — ERPGulf (GitHub) | ZATCA Phase 2: CSID, XML signing, clearance (B2B) / reporting (B2C), QR | MIT | APP-22 · **W3** (`sa_zatca` package ENG-222 se mint hoga) | Maintainer ne **v16 release** ka elaan kiya hai (forum, Feb 2026). Doosra candidate D3 hai — **ek** chuna jayega |
| D3 | ZATCA (alternative) | `zatca_integration` — Beveren Software Inc (GitHub) | ZATCA Phase 1+2, simulation + production, Frappe Cloud optimized | AGPL-3.0 | APP-22 · W3 | README ERPNext v14/v15 kehta hai — v16 proof spike mein chahiye. D2 ka backup option |
| D4 | **POS Pro** | `posawesome` — POS Awesome (original: yrestom; active v15/v16 fork: defendicon/POS-Awesome-V15) | Advanced POS: offline, multi-payment, discounts, Vue/Vuetify UI | GPL-3.0 | APP-23 · W2 (ENG-054/055 family) | Original repo v15 tak; fork v16 fixes ke saath active hai. **Lekin:** hamara apna POS frontend + Desk register-of-record faisla maujood hai — adoption us faislay ko reopen karega, is liye spike mein teeno ka muqabla: apna POS vs POS Awesome fork vs POSNext (D5) |
| D5 | POS (alternative) | `posnext` — POSNext (BrainWise-DEV) | Modern POS, offline, touchscreen UI — POS Awesome ka successor-style fork | — (spike) | APP-23 · W2 | D4 ke muqable mein sirf ek POS engine jayega |
| D6 | **WhatsApp** | `frappe_whatsapp` — community (Shridar Patil), Meta Cloud API direct, koi middleman nahi | WhatsApp notifications + chat, multi-account, ERPNext DocTypes se native link | — (spike) | APP-33 · W3 (ENG-172 omnichannel inbox) | Note: Frappe CRM ab apni official WhatsApp integration bhi la raha hai — spike mein official-vs-community ek faisla. Marketplace par Whatsnext / WhatsApp Automation Pro jaise paid alternatives bhi hain (per-message/subscription model — tenant cost ki wajah se pehle choice nahi) |
| D7 | PDC Management | `pdc_management` — community (awesome-frappe listed) | Post-dated cheques: receive, deposit, clear, bounce, replace + har step par sahi journal | MIT · Frappe v15/v16 claimed | APP-20 · W2 (ENG-167) | Apna own-build plan (ENG-167) maujood hai — ye app build ka waqt bacha sakti hai; accounting-invariant test lazmi |
| D8 | Microsoft 365 | `frappe_microsoft_365` — community | Outlook calendar 2-way sync, Teams meetings, mail OAuth | — (spike) | APP-48/57 · W5 | v15/v16 claimed. Mail/calendar engine unselected hai blueprint mein — ye candidate hai, waada nahi |
| D9 | WooCommerce | WooCommerce Fusion / Connector — community | Multi-store WooCommerce sync (orders, stock, prices) | — (spike) | APP-24 · W3 | B11 (official Ecommerce Integrations) ke baad dusri choice |
| D10 | Shipping | ERPNext Shipping / shipping integrations — Marketplace | Courier/shipment rates, labels, tracking | — (spike) | APP-57 · W3 | Tenant apne courier account se |
| D11 | UAE E-Invoicing | ERPGulf UAE app (beta, open source) | UAE FTA / Peppol-route e-invoicing | — | APP-22 · W3–W5 | Abhi beta — watch list, catalogue nahi. UAE mein direct submission allowed nahi, accredited provider lagta hai |
| D12 | Malaysia MyInvois | `myinvois` — ERPGulf | LHDN MyInvois e-invoicing | — | APP-22 · P3 | Sirf pattern ka saboot ke country apps isi tarah banti hain; hamare P0/P1 scope se bahar |

---

## E. OPERQON KE APNE APPS — jo ready-made nahi milenge, hum bana kar catalogue mein dalenge

Ye wo hain jin ka koi bharosemand ready Frappe app nahi hai, ya jo hamari pehchan hain. Ye bhi tenant ko **usi 1-click** se milenge — farq sirf itna ke developer hum khud hain. Har ek integration standard par: complete, self-service activation, tenant ki apni credentials, validate-or-error.

| # | Catalogue naam | Kaam | Blueprint / Wave | Credential model |
|---|---|---|---|---|
| E1 | **Pakistan Pack (Localisation)** | NTN/STRN/CNIC fields, tax templates, withholding, Annexure/reports, HS/UOM sync — D1 (FBR) ki buniyad | W2 · ENG-061…096 | Tenant ki apni tax registrations |
| E2 | **Provincial Tax Pack — PRA / SRB / KPRA / BRA** | Punjab/Sindh/KP/Balochistan service tax, POS integration jahan applicable | W2 · country rows PK-Punjab P0, baqi P1 | Tenant ki apni provincial registration |
| E3 | **FBR POS (Tier-1 Retail)** | Tier-1 retailer POS real-time FBR reporting (agar D1 ki coverage mein gap nikla to ye module us gap ko bharega) | W2 | PRAL / licensed integrator — tenant ka apna |
| E4 | **Saudi Pack (Arabic + ZATCA wrapper)** | Arabic invoice, SAR/VAT setup, CSID/EGS lifecycle ki Operqon UX — engine D2/D3 mein se jo spike jeeta, wrapper apna | W3 · `sa_zatca` (ENG-222 ka child) | Tenant ke apne ZATCA credentials/certificate |
| E5 | **Pakistan Payment Gateways** | Easypaisa, JazzCash, PayFast, NayaPay — tenant checkout / payment links (ENG-191) | W2 · APP-57 | **Tenant ke apne merchant accounts** — Operqon sirf module deta hai |
| E6 | **Biometric Attendance Bridge** | ZKTeco waghera devices → HRMS attendance sync | W3 · APP-39/57 (ENG-193–196 family) | Tenant ke apne devices, apne network par |
| E7 | **Barcode & Label Studio** | Barcode/QR labels, print templates | W2–W3 · ENG-177 | Koi nahi |
| E8 | **Dealer / Retailer Portal** | Dealer ordering, ledger, claims — scoped portal | W2 · APP-26 (ENG-170) | Portal users tenant define karta hai |
| E9 | **Supplier Portal** | RFQ, PO collaboration, bill submission | W2 · APP-27 (ENG-171) | Ditto |
| E10 | **AI Copilot** | Permission-aware document chat, draft actions (human-confirm ke baghair posting nahi) | W4 · APP-56 (ENG-164/166/180) | Provider/model abhi unselected — tenant key option ke saath design hoga |

---

## F. INDUSTRY PACKS — ye "apps" nahi, 1-click PACKS hain (catalogue ka dusra section)

Blueprint ka faisla: har industry ke liye naya ERP fork nahi — shared core par **versioned pack** (fields, workflows, dashboards, reports, presets). Tenant pehle 1 primary pack choose karta hai, compatible secondary add kar sakta hai. Catalogue mein ye **Packs** section mein aayenge, Apps se alag — taake user confuse na ho.

**14 Anchor Packs (ENG-197…210 — pehle delivery inhi ki hogi):**

| Pack | Family | Wave | Khaas extension (blueprint se) |
|---|---|---|---|
| IP-01 EV Bikes | EV & mobility | W3 | Battery/serial lifecycle, swap/warranty |
| IP-02 Car Franchise / Auto Dealership | Automotive dealership | W3 | OEM allocation, VIN reservation — ek VIN ki do allocations reject |
| IP-03 Motorcycle Workshop | Technical services (auto) | W3 | Job cards, chassis/engine tracking |
| IP-04 Bakery | Bakery & food retail | W3 | Recipe, batch yield, outlet production |
| IP-05 Pharmacy | Pharmacy & medical supply | W4 | Batch/expiry **mandatory block**, controlled items |
| IP-06 Discrete Manufacturing | Discrete manufacturing | W4 | BOM, WIP, job work |
| IP-07 Process Manufacturing | Process manufacturing | W4 | Batch genealogy, yield/scrap/rework |
| IP-08 Restaurant | Restaurant & hospitality | W3 | POS/KDS flow, table/kitchen |
| IP-09 Service / AMC | Technical services | W3 | Installed assets, AMC contracts, service jobs |
| IP-10 Professional Services | Professional services | W3 | Timesheets, retainer billing |
| IP-11 Omnichannel Retail | Retail chains | W3 | Multi-store, loyalty/promotions (APP-25) |
| IP-12 Equipment Rental | Rental & hire | W3 | Custody, deposits, return inspection |
| IP-13 Beverage Distribution | Beverages distribution | **W2** | Routes, container custody, deposits |
| IP-14 FMCG Distribution | FMCG & general distribution | **W2** | Route selling, schemes, retailer portal (E8) |

**Baaki 6 families (200 use cases ka hissa, anchor ke baad):** Logistics & Warehousing (IP-08 base), Construction & Property Projects, Agriculture & Primary Supply, Healthcare & Education Operations, Digital Commerce & Subscriptions, Property & Asset Operations, Nonprofit & Community Services. (Catalogue CSV mein kul 20 families / 200 use cases hain.)

---

## G. COUNTRY PACKS — 48 jurisdictions (catalogue ka teesra section)

Har country pack = APP-22 ka ek adapter, ENG-222 ke generic connector pattern par, per-country mint hoga (W5 doctrine: pehle se sab ka waada nahi). Priority blueprint ki apni hai:

- **P0 (pehle):** Pakistan Federal (FBR) · Saudi Arabia (ZATCA) · Pakistan Punjab (PRA)
- **P1:** UAE, Oman, Bahrain, Qatar, Kuwait, Egypt, Jordan + PK Sindh / KP / Balochistan-ICT
- **P2:** Baqi MENA (Morocco, Tunisia, Algeria, Lebanon, Iraq, Palestine, Libya, Mauritania, Djibouti, Sudan, Yemen, Syria) + Türkiye
- **P3 (baad mein):** UK, EU (DE/FR/IT/ES/PL), USA, India (GST — wahan official `india_compliance` app pattern ke taur par maujood hai), Bangladesh, Malaysia, Singapore, Indonesia, Australia, NZ, Canada, South Africa, Kenya, Nigeria

> Note: kisi country ke liye third-party app sirf wahan likha hai jahan asal mein mila (Saudi, Malaysia, UAE-beta). Baqi sab ke liye imandari se "apna adapter bane ga" hi sahi jawab hai.

---

## H. USER KO DIKHNE WALE 1-CLICK BUNDLES (packs of apps)

Tenant aam tor par akeli app nahi, bundle choose karega. Catalogue ke ready bundles (blueprint §6):

| Bundle | Us mein kya 1-click apply hoga | Wave |
|---|---|---|
| **Business Core** | A1–A3 (default — pehle se active) | W1 |
| **Sell & Serve** | B1 CRM + B3 Helpdesk + B4 Telephony + D6 WhatsApp | W3 |
| **People** | B2 HRM + B6 Learning (+ E6 Biometric jahan laagu) | W3 |
| **Commerce** | B10 Webshop + B11 Ecommerce Integrations + B9 Payments + (D4/D5 POS spike winner) | W2–W3 |
| **Workplace** | B7 Builder + B8 Raven + C2 Wiki | W3–W4 |
| **Finance Pro** | B5 Insights + D7 PDC (+ E7 Label Studio) | W2–W4 |
| **Pakistan Business** | D1 FBR (spike ke baad) + E1 Pakistan Pack + E2 Provincial + E5 PK Gateways | **W2** |
| **Saudi Business** | D2/D3 ZATCA winner + E4 Saudi Pack | W3 |

---

## I. GATE — koi bhi app 1-click live nahi hogi jab tak ye 7 checks pass na hon

1. **ENG-189 licence/version spike:** exact commit, licence SaaS-compatible, v16 branch asal bench par install + migrate pass.
2. **ENG-133 packaging:** app hamare image/packaging matrix mein pin, rollback ke saath.
3. **SSO/lifecycle:** Keycloak/OIDC user ke saath kaam, user revoke par access band.
4. **Entitlement negative test:** unsubscribed tenant direct API/URL se bhi app use na kar sake.
5. **Data isolation:** cross-tenant leakage test (khaas tor par Insights/CRM/Helpdesk par).
6. **Domain acceptance:** blueprint ke workflow contract (WF) ke mutabiq ek asal business flow end-to-end (sirf "install ho gaya" kabhi saboot nahi — §18 definition).
7. **Support runbook:** support owner, upgrade cadence, authority-spec change ka process (FBR/ZATCA ke liye khaas).

## J. NOT-ADOPT LIST (imandari ke liye)

- **Legacy Frappe Drive** — archived hai; successor WIP. (C5 HOLD)
- **Install-all image** — sab apps har tenant par thopna blueprint mein mana hai; har app entitlement-gated rahegi.
- **Paid WhatsApp resellers (per-message model)** — D6 ke official/community route ke muqable mein dusri pasand; tenant cost badhta hai.
- **Do POS engines / do ZATCA engines ek saath** — spike mein ek winner, dusra catalogue se bahar.

---

## K. Agla qadam (prepared proposal)

1. **Spike Lane 1 (W2 ke saath, sab se zyada faida):** D1 Pak Compliance (FBR) + E1 gap-check, D7 PDC, B9 Payments — ye chaar W2 Pakistan plan ko seedha accelerate karte hain.
2. **Spike Lane 2:** B1 CRM + B2 HRMS + B3 Helpdesk + B4 Telephony — v16 pairing, SSO, entitlement tests (ENG-189 format mein har app ki ek-page spike report).
3. **Catalogue UI:** App registry (ENG-122…125) ka read model + Operqon frontend mein Apps page — pehle sirf Core + "available after spike" states ke saath, koi jhoota "available" badge nahi.
4. Har spike ka faisla (adopt / fork-and-own / build-own / reject) is file mein date ke saath append hoga — ye file catalogue ka living record hai.

---

## L. SPIKE VERDICTS — 2026-11-10 (ENG-189, evidence in `hidden_files/app-spikes/`)

| App | Verdict | Pin / note |
|---|---|---|
| Frappe Payments `payments` | **ADOPT** | version-16 @ 9e842a47, MIT. PK gateways confirmed absent — E5 own-build stays, copying its pattern. |
| PDC Management | **ADOPT** | commit d618f3a7 (v1.1.1), MIT. + Operqon approved-penalty-policy layer; fork trigger recorded. ENG-167 own-build closed as adopted. |
| Frappe CRM `crm` | **ADOPT*** | version-16 v16.0.2, AGPLv3. First catalogue pilot app. *Subject to isolated-bench pairing proof. |
| Frappe HRMS `hrms` | **ADOPT*** | version-16 v16.53.1, GPLv3. Pakistan payroll pack = separate Operqon own-build (none exists upstream). |
| Helpdesk + Telephony | **ADOPT*** | Helpdesk v16.1.0; Telephony commit-pinned (develop-only, v0.0.1 — key risk). Two-telephony-stacks warning for CRM+Helpdesk sites. |
| Pak Compliance `fbr_e_invoicing` | **BUILD-OWN (keep ours)** | No status-query (ENG-090 gap survives), weaker idempotency, plain-text PRAL credentials, no STGO correction. Harvest its PRAL payload mapping + provincial reports as MIT reference only. |

Synthesis: `hidden_files/app-spikes/spike-synthesis.md`. Catalogue UI spec ready (same folder, `spec-app-catalogue-ui.md`) with open questions Q1–Q7; build after oc20, install-pipeline step gated on Q2+Q5.

---

## M. ADDENDUM — IS KE ILAWA (2026-11-10, owner ke sawal par: "Isky ilawa kon kon si apps kam ain gi according to our blueprint features requirements")

Pehli list (§A–L) ke baad blueprint ki 58 capabilities ko dobara khola gaya. Jo reh gaya tha wo chaar hisson mein hai: (M1–M2) asal apps jo pehli list mein nahi ayeen, (M3) external engines jo Frappe app nahi hain magar blueprint ko chahiye, (M4) wo features jin ke liye **koi app chahiye hi nahi** (ERPNext/Frappe mein pehle se hain — ye list paisa/waqt bachati hai), (M5) connectors jo apne hi baneinge. Har nayi entry bhi usi ENG-189 spike gate se guzregi.

### M1. Official / Marketplace-featured apps jo pehli list se reh gayeen

| # | Catalogue naam | App | Kaam / blueprint link | Note |
|---|---|---|---|---|
| M1.1 | **Education** | `education` (frappe/education — official) | Students, courses, fees, assessments — Industry family "Healthcare & Education operations" (IP-12) | ERPNext v14 se alag app hai. **Scope note:** ye Operqon ke education-sector TENANTS ke liye hai — IQRS / Rektrs School projects se is ka koi taluq nahi, projects alag rahenge |
| M1.2 | **KSA Compliance (ZATCA — teesra candidate)** | `ksa_compliance` — Frappe Cloud Marketplace par **featured**, free/open-source, Phase 1 + Phase 2 dono | APP-22 · W3 Saudi pack | §D mein ERPGulf aur Beveren thay; ye teesra aur bazaahir sab se saaf candidate hai. W3 spike mein **teenon ka muqabla** hoga, developer/licence wahan verify hoga |
| M1.3 | India Compliance (sirf reference) | `india_compliance` (official) | GST/e-invoicing — PK tenants ke kaam ki **nahi** | Sirf is liye record par hai ke ye country-pack ka sab se kamyab design hai — hamare PK/SA packs ke architecture ka proof-of-pattern |

### M2. Community apps — naye candidates

| # | Catalogue naam | App / developer | Kaam / blueprint link | Haqiqat check |
|---|---|---|---|---|
| M2.1 | **Biometric Attendance (ZKTeco)** | Do candidates: `zkteco_attendance` (v14/v15/**v16** claimed, pyzk-based) aur `zkteco_checkins_sync` (DeliveryDevs — Marketplace listed; ZKBio software ke through) + Frappe ki apni official `push-biometric-erpnext` script buniyad ke tor par | APP-39/57 · §E6 ki jagah ab **adopt-candidate** hai, khaalis own-build nahi | Tenant ki site se device LAN par hota hai — SaaS mein aksar chhota sa on-prem bridge lagega; ye design spike ka asal sawal hai |
| M2.2 | **Digital Signer** | Marketplace app | PFX/USB-token se Sales Order/Invoice/PO par visible digital signature; v14–**v16** compatibility claimed | APP-52 ka ek hissa (document signing) — lekin ye **envelope workflow** (bahar ke signer ko link bhejna) nahi hai; dono alag needs hain |
| M2.3 | DocuSign Integration | `docusign_integration` (Extension Technologies, GitHub) | DocuSign envelopes ERPNext se | v13–v15 tak documented — v16 spike lazmi; APP-52 ka commercial route, tenant ke apne DocuSign account ke saath |
| M2.4 | **Peppol E-Invoicing** | EDocument Integration (Marketplace) | Peppol network par e-document bhejna/receive — **UAE (P1) aur EU (P3)** country packs ka ready route | APP-22 · UAE mein accredited-provider model ke saath fit baithta hai |
| M2.5 | **Hotel PMS** | Kamra (Marketplace, v16, AGPL) | Hotels/short-stay: front desk, folios, restaurant POS, housekeeping — "Restaurant & hospitality" family ki extension | Sirf hospitality tenants ke liye catalogue card; spike baad mein |
| M2.6 | **Healthcare** | Marley Health (`earthians/marley`) | Patients, appointments, practitioners, prescriptions — Healthcare family | Purani official Frappe Health app ab Earthians ke paas hai; ERPNext par dependent hai. Community-maintained honay ki wajah se spike sakht hoga |

### M3. External engines — Frappe apps nahi, lekin blueprint ko chahiye (integration ke tor par aayenge)

| # | Zaroorat (blueprint) | Engine candidates | Faisla ki surat |
|---|---|---|---|
| M3.1 | Browser office editing (APP-47) | ONLYOFFICE / Collabora Online | Koi tayyar Frappe app **nahi mila** — WOPI connector apna bane ga, ya Frappe Drive ke apne Writer par inhesar hoga. W4 ka kaam hai |
| M3.2 | Meetings/calls (APP-50) | Jitsi (open source, self-host) / Teams via M365 app (§D8) | Alag service + Operqon se SSO link; app install nahi hota |
| M3.3 | E-Sign envelopes (APP-52) | Documenso / OpenSign (dono open source, self-host ho sakte hain) ya DocuSign (M2.3) | Tenant apna legal provider choose karega; hum sirf connector + audit trail denge |
| M3.4 | Marketing campaigns/social (APP-09/10) | Mautic (open source automation) connector / social platforms ke official APIs | Blueprint mein engine "unselected" hai — W4 mein selection hoga, abhi waada nahi |
| M3.5 | Automation glue (APP-54/57) | n8n / Frappe ke apne Webhooks + Server Scripts | Zyaada tar flows Frappe ke andar hi ban jayenge; n8n sirf bahar ke systems ke liye optional connector |

### M4. App NAHI chahiye — ye ERPNext/Frappe mein pehle se maujood hai (sirf Operqon frontend mein surface hoga)

Projects + Timesheets (APP-35/37) · Quality Management (APP-29) · Asset Maintenance (APP-30) · **Loyalty Program** (APP-25) · **Subscription/Recurring Billing** (APP-18 ki buniyad) · Agriculture domain (crop/livestock) · Field Service/AMC ki buniyad (APP-31) · **Google Calendar/Contacts/Drive integration** (framework mein built-in) · Email inbox/SMS framework · Workflow/Automation DocTypes (APP-54 ki buniyad) · Appointments ki buniyad (APP-07, apna module chhota sa upar bane ga).

### M5. Connectors jo kahin nahi milte — apne baneinge (APP-57 ki asal list)

Pakistan couriers (Leopards, TCS, Trax, PostEx) · Daraz marketplace · Pakistan SMS gateways (local bulk providers) · Raast / bank feeds · Industry-specific machine/IoT adapters (ENG-157 hardware registry ke saath). Ye sab §E wale integration standard par: tenant ki apni credentials, validate-or-error.

### M6. WATCH / NOT-NEEDED (taake catalogue mein ghalti se na aayein)

- **Frappe Books (nayi framework wali)** — abhi develop-branch only aur Frappe v17 ki taraf hai; hamare v16 pair par lagu nahi. Watch list.
- **Passkeys app** — passwordless login Marketplace par hai, magar hamari identity Keycloak hai; duplicate cheez nahi chahiye.
- **Frappe Drive** — §C5 HOLD barkarar, lekin note: Drive ab Writer (apna editor) ke saath active develop ho rahi hai; W4 spike mein is ki nai halat dobara dekhi jayegi, M3.1 ka faisla us se jura hai.
