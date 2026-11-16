# Operqon onboarding, organization aur customer journeys

Darja: target planning. R3 customer-layer spec existing lifecycle aur API ko authoritative rakhta hai. Neeche friendly UX stages mapping hain; in se parallel production state machine create na ki jaye.

## 1. Identity, customer, tenant aur business structure

| Concept | Meaning | Access rule |
|---|---|---|
| Person / identity | Ek insaan ki authenticated identity | Stable identity key; email change ownership transfer nahin |
| Customer account | Operqon ka commercial customer | Billing/contact responsibility; ERP records access independently granted |
| Tenant/site | Isolated business workspace | Tenant membership mandatory |
| Organization/group | Related businesses ka governance group | Group relationship alone data access nahin |
| Legal entity/company | Registration, books, tax identity aur reporting unit | Local fiscal pack per entity |
| Branch/outlet | Ek entity ka operational unit | Cross-country separate legal/tax requirement evaluate |
| Warehouse/bin | Physical/logical stock location | Stock authority and valuation scope |
| Franchise relationship | Brand/franchisor aur independent franchisee contract | Separate owner/data permissions; consented aggregate only |
| Billing account | Subscription payer | Payment ability never universal books permission |

Odoo documented model mein multi-country entity ke liye company aur parent-localization-following branch ka distinction relevant example hai [PRD-06]. Operqon implementation apne data/ledger invariants se this distinction enforce kare. Ek tax country badalne par existing company ke posted records ko overwrite na karein; migration/reorganization workflow with accountant review chahiye.

## 2. Account request se first business task tak

### Step 1: Fit discovery

User country of business, industry, organization size, legal entities, branches, desired pack aur required features select kare. Supported, pilot aur planned pack status alag dikhaye. Supported-country list ke bahar lead register ho sakta hai, lekin certified-live invoicing promise na ho. Optional questionnaire skip karne par conservative defaults aur later setup task ho.

Input minimization: pehle name, verified contact aur business basics; tax certificates, bank details aur sensitive files only relevant stage par. Privacy notice aur terms version recorded. Marketing opt-in transactional notices se alag.

### Step 2: Identity aur account creation

Existing Keycloak par branded signup/signin/forgot-password; password ka parallel custom store nahin. OIDC subject verified issuer/client/audience ke saath map ho. Email verification aur account existence states explicit hon. Signup partial failure par one account/one request invariant, safe retry aur operator reconciliation ho. Public errors account enumeration na karein.

Customer sign in karke application status dekh sake. Unverified email user ko verify/resend/change-contact safe path mile; privileged access ya automatic financial authority na mile. SMTP absent ho to operator verification controlled audited workflow ho; fake email-sent notification na ho.

### Step 3: Customer dashboard aur request review

Friendly progress: Requested -> Email verified -> Identity review -> Approval/payment steps -> Provisioning -> Live. Actual API states and ordering baseline audit se map hon; payment and approval are not assumed universally interchangeable. Rejection reason safe customer summary ho; internal fraud notes expose na hon. Resubmission clear requested evidence ke saath ho.

Manual bank payment ke liye bank instructions configured source se aaye. Proof uploader allows safe file types, size, checksum, malware validation and review status. Payment sent action tenant pending rakhe jab tak authorized approver bank evidence verify na kare. Reused transfer proof/amount mismatch/partial payment separately review hon.

### Step 4: Provisioning aur pack resolution

Provisioning screen resolved versions dikhaye: core, business modules, industry pack, country pack, optional channel. Dependency conflict ya capacity error par pending queue, next action aur safe retry ho. Background job timeout customer ko naya tenant request banane ko force na kare. Failed provisioning partial site/dependencies cleanup engineering runbook follow kare; customer-visible status support reference de.

User ko quoted plan aur installed entitlement version match ho. Trial timer provisioned-ready milestone se approved rule ke mutabiq start ho. Failed setup mein trial consume karne ki policy explicit ho; approved 3-day duration silently alter na karein.

### Step 5: Business setup wizard

| Step | Inputs | Validation | Output |
|---|---|---|---|
| Company | Legal name, registration, business country, base currency, timezone | Required identifiers by selected country | Legal entity record |
| Books | Fiscal year, chart template, dimensions, opening date | Accountant review; currency/fiscal constraints | Accounting configuration |
| Tax | Registration, branches/devices, applicable regimes | Verified source + credentials environment | Country readiness tasks |
| Locations | Branches, warehouses, bins, routes | Ownership and stock movement rules | Operational geography |
| Catalog | Items/services, UOM, serial/batch/expiry policies | Pack-specific mandatory fields | Clean item master |
| Parties | Customers/vendors, terms, addresses | Duplicate detection + tax identifiers | Scoped party records |
| People | Invite roles, company/branch access, approver limits | Privilege preview, segregation checks | Memberships |
| Documents | Number series, print brand, legal fields | Country format and immutable sequence policy | Templates |
| Opening data | Balances, stock, outstanding documents | Dry-run, reconciliation, approval | Signed migration batch |
| Connections | Bank, authority, commerce, printer, messaging | Test environment, secrets, callback readiness | Connector status |
| First workflow | Guided real or isolated sample transaction | Clear environment and irreversible step | Verified task evidence |

Wizard resumable ho, role collaboration permit kare, aur incomplete compliance ko green completed badge na de. Accounting-ready, operational-ready aur authority-ready checklist alag hon. Sample/demo data real books mein mix na ho.

## 3. Data import aur migration journey

Source system, export date, owner, data sensitivity, mapping version aur excluded records inventory banayein. Customer data ownership confirm ho. CSV/XLSX upload -> file validation -> column mapping -> duplicate/missing reference resolution -> dry run -> row preview -> approvals -> execution -> reconciliation -> go-live freeze -> rollback/remediation window.

Master data pehle; references next; opening balances/stock/outstanding next; historical full transaction migration optional separate scope. Opening stock valuation and GL opening reconciled hon. Disputed rows quarantine hon, silently skip na hon. Per row stable source key aur migration batch id ho. Retry duplicate records create na kare. File-level success row-level success ka substitute nahin.

Audit exports line-level error codes aur authorized details dein. Actual credentials, PAN/full payment card data, secrets aur unrelated personal information import na ho. Temporary source files ka retention/deletion agreed policy follow kare.

## 4. Daily user journeys

### Owner / manager

Sign in -> company summary -> due approval -> review changes/exposure -> approve/reject -> downstream task visibility. Parallel owner flows: overdue recovery drill-down; stock-at-risk batch drill-down; cash forecast; exception queue assignment. Owner role business default admin nahin; payroll or sensitive prescription visibility explicitly decide ho.

### Accountant

Due invoices -> source evidence -> validate tax treatment -> post -> authority status -> bank matching -> reconcile -> period close. Corrections authorized credit/reversal/amendment path se. Locked period reopening time-bound, reason aur independent approval ke saath. Tax connector rejected ho to books aur submission statuses separately maintained.

### Storekeeper

Inbound queue -> scan goods -> count/quality -> serial/batch/expiry -> discrepancy -> receive accepted stock -> labels/bin putaway. Outbound: pick -> scan validation -> pack -> dispatch -> proof of delivery/return. Warehouse staff price margin dekh sakein ya nahin role-level decision ho.

### Sales / distributor representative

Today route -> customer stop -> overdue/credit visibility -> catalog and schemes -> order -> supervisor credit exception where needed -> planned fulfilment -> collection -> receipt -> reconciliation. Offline customer balance stale ho to visible freshness aur configured credit policy apply kare. Recovery entry final bank settlement nahin.

### Cashier / restaurant

Start shift -> opening cash -> sale/table order -> modifiers -> kitchen status -> payment -> legally valid receipt/invoice -> return/void with reason -> cash count -> close discrepancy approval. Supervisor PIN alone must not become shared identity; accountable supervisor approval logs required.

### Technician / service team

Assigned job -> customer/site/asset -> safety prerequisite -> diagnosis -> parts request -> work/time evidence -> customer acknowledgment -> warranty/AMC coverage check -> completion -> billable exception review -> invoice. Customer signature ko payment confirmation na samjhein.

### Franchise / group finance

Group view -> permitted entity comparison -> intercompany order/settlement -> matched counterpart documents -> consolidation/elimination review. Independent franchisee ki payroll, supplier rates aur customer list franchisor ko automatically na mile. Contracted aggregate data pipeline scope and consent track kare.

## 5. Team, role aur delegated administration

Invitation identity, tenant, company scope, role proposal, expiry aur inviter record rakhe. Existing identity ko duplicate account na banaye. Invite acceptance tax/finance authority automatically grant na kare. High privilege role change step-up authentication aur approval risk ke mutabiq ho.

Joiner/mover/leaver workflow: invite -> confirm scope -> activate -> review role changes -> transfer task ownership -> revoke sessions/tokens -> audit retained. Last active owner remove karne se pehle verified successor ho. Owner transfer dual confirmation, identity verification aur cooling/risk review policy se. Billing contact change aur tenant ownership transfer distinct flows hon.

Support delegation customer-initiated, least privilege, time-bound aur revocable ho. Screen clearly show support session actor aur impersonation scope. Sensitive exports, payment approval aur credential retrieval prohibited unless specific separately granted role exists. Shared support credentials use na hon.

## 6. Notifications aur communication

Notification event payload tenant/entity scoped ho. Business critical rejection/failed job in-app durable item banaye; email/SMS/WhatsApp supplementary channels hon. Channel connected na ho to in-app path works and delivery state visible. Outgoing message enqueue/sent/delivered/failed alag record hon. Quiet hours optional marketing/task reminders par; security/legally required notices policy-aware.

Customer communication template version, locale, allowed placeholders, consent basis, sender configuration aur audit reference carry kare. Data minimization: email subject mein payroll/medical/sensitive information na ho. Repeated reminder throttling; dismissed notice actual outstanding obligation ko delete na kare.

## 7. Renewal, expansion aur exit

Expansion discovery user behavior se helpful prompts de sakti hai, magar intrusive paywalls core financial records block na karein. New pack installation dependency preview, price review, backup, test data workflow aur customer acceptance ke baad. Removal historical data/posted references retain kare; uninstall physical deletion default na ho.

Exit flow: cancel request -> effective date confirmation -> authorized full export schema/files -> integration/key revocation -> final bills/credits -> contracted retention archive -> scheduled deletion of eligible data -> completion record. Financial statutory retention aur personal-data deletion conflict country pack/legal policy resolves; support cannot promise immediate deletion of legally required evidence.

Export data ownership meaningful ho: party/item, transactional line detail, attachments index, audit trail within permitted scope, GL/stock ledgers, configuration version and schema documentation. Proprietary code ya other tenant records export ka hissa nahin.

## 8. Lifecycle acceptance criteria

- Duplicate signup exactly one identity/request binding de; partial failure recoverable ho.
- Customer A request/site/invoice/team endpoint se customer B data read/change na kar sake.
- Manual payment proof alone live activation na kare.
- Live plan display API-approved version se match; missing price quote-required show ho.
- Trial approved 3 days, server-controlled and provision readiness rule verified.
- Team membership and ERP SSO use same intended identity; stale invitation cannot add forbidden scope.
- Migration dry run financial totals aur row errors produce kare; execution idempotent and reconciled ho.
- Wrong country/pack combination review block de before real regulated transaction.
- Tenant ownership transfer, last-owner removal, support delegation aur export permission negative tests pass hon.
- Cancellation historical statements accessible per contract; no silent record deletion.

## Sources

[PRD-06] Odoo multi-company documentation: https://www.odoo.com/documentation/19.0/applications/general/multi_company.html (accessed 2026-11-06).
[PRD-07] Odoo fiscal localization documentation: https://www.odoo.com/documentation/19.0/applications/finance/fiscal_localizations.html (accessed 2026-11-06).
Existing approved baseline: `customer-layer-spec-r3.md`, read by lead agent 6 November 2026; runtime/live status requires separate verification.
