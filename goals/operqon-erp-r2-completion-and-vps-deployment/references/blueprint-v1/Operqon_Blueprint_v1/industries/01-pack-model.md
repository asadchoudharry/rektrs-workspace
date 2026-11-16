# Operqon industry pack model

Tareekh: 6 November 2026. Status: product proposal; implementation aur certification ka dawa nahin.

## Product ka bunyadi faisla

Operqon mein har karobar ke liye naya ERP fork na banaya jaye. Shared accounting, inventory, purchasing, sales, CRM, identity, approvals aur reporting engines par versioned industry packs install hon. Ek bakery ko recipe, batch yield aur outlet production nazar aaye; motorcycle dealer ko chassis, engine number aur delivery checklist. Donon ke receivables, bank reconciliation aur audit ek tested accounting engine mein rahen. Customer ek primary industry chunta hai; zarurat par compatible secondary packs add karta hai. Country pack company ki legal jurisdiction ke saath bind hota hai; language ya billing currency se tax country infer nahin hota.

ERPNext ki documentation serial aur batch tracking, manufacturing BOM, warranty/AMC, projects aur timesheets ke reusable primitives dikhati hai [IND-S01–IND-S07]. Yeh sirf foundation capability ki evidence hai; Operqon ki required UX, extensions aur exact deployed-version behavior alag verify karna hoga. Odoo POS/KDS aur Microsoft rebates workflow benchmark hain [IND-S08–IND-S10]; unka code copy karne ya feature parity ka dawa nahin. GS1 ka event/data model traceability ke design ko guide karta hai [IND-S11–IND-S12].

## Pack ki layers

| Layer | Is mein kya aayega | Kis cheez ka malik |
|---|---|---|
| Shared core | GL, AR/AP, stock ledger, UOM, tax interfaces, documents, workflow | Platform team |
| Capability engine | Serial lifecycle, batch/expiry, production, route selling, booking, service jobs | Domain team |
| Industry pack | Domain entities, presets, workflows, dashboard, reports, validation | Pack maintainer |
| Country pack | Fiscal identities, tax rules, invoice transmission, statutory exports | Compliance team |
| Tenant configuration | Warehouses, role assignments, limits, approved fields, printing | Tenant admin |
| Supported extension | Versioned hook/app with contract tests | Operqon/approved partner |

Country aur industry pack ke beech contract explicit ho: stock movement tax event nahin hota; customer deposit income tabhi bane jab accounting policy aur performance obligation usay allow kare; authority acceptance aur invoice accounting states alag track hon. Food safety, pharmacy dispensing, finance licensing aur employment rules tax compliance se alag regulatory domains hain.

## Manifest contract

Har pack ke machine-readable manifest mein yeh fields lazmi hon:

- `pack_id`, `name`, `family`, `version`, `maintainer`, `license`, `support_tier`, `support_end_at`.
- `core_compatibility`, `erpnext_compatibility`, `required_capabilities`, `optional_capabilities`, `conflicts`, `country_restrictions`.
- `entities`, `custom_fields`, `indexes`, `permissions`, `workflows`, `jobs`, `reports`, `dashboards`, `translations`, `print_templates`.
- `installation_migrations`, `upgrade_migrations`, `backfill_jobs`, `data_volume_estimate`, `reversible_steps`, `forward_fix_steps`.
- `required_integrations`, `secrets_references`, `network_scopes`, `data_classification`, `retention_policy_refs`.
- `accounting_policy_refs`, `event_contract_versions`, `approval_policy_refs`, `offline_policy`, `acceptance_suite`, `certification_evidence_refs`.
- `status`: discovery, specified, implemented, integration_tested, domain_uat, controlled_pilot, ga, deprecated, retired. Catalogue presence kabhi production entitlement nahin.

Example: `industry.beverage-distribution` ko `sales`, `stock.batch`, `distribution.routes`, `pricing.schemes`, `containers.custody` aur `finance.deposits` chahiye. `country.sa` legal entity par applicable ho sakta hai; us ka ready status independently verify hoga. `industry.restaurant` ka primary food order engine aur `industry.manufacturing-process` ka production engine shared inventory ko use kar sakte hain, magar ek sale do martaba stock consume na kare.

## Compatibility aur precedence

1. Mandatory law/policy country pack mein applicable context aur effective date ke saath evaluate ho.
2. Core accounting aur security invariants kisi pack ya custom field se bypass na hon.
3. Industry policy legal boundaries ke andar business behavior define kare.
4. Tenant customization sirf allowed parameters aur extension points ko change kare.
5. Contradiction par resolver human-readable conflict report de; last-installed-pack-wins behavior mana ho.

Example: tenant ne batch expiry ignore karne ka toggle manga, lekin pharmacy pack expiry block mandatory rakhta hai. Installation preview conflicting setting ko reject kare aur owner ko sabab dikhaye. Branch-country company mapping ke baghair cross-country pack install na ho. Ek legal entity ke andar do fiscal profiles tabhi jab compliance design usay explicitly support kare.

## Installation se retirement tak

| Stage | System action | Evidence / exit gate |
|---|---|---|
| Discover | Business size, channels, country, existing apps aur use cases identify | Fit-gap worksheet, excluded flows |
| Resolve | Dependency graph aur compatibility calculate | Deterministic lockfile |
| Preview | Fields, roles, new jobs, storage, integration cost, downtime dikhaye | Tenant admin approved preview |
| Prepare | Backup checkpoint, staging clone with masked data, dry run | Restore verified, migration estimate |
| Install | Idempotent migration aur presets, limited permissions | Same request replay creates no duplicates |
| Validate | Sample business transactions aur accounting totals | Pack acceptance suite pass |
| Activate | Effective date, role workspace aur entitlements enable | Named owner, support runbook |
| Operate | Job health, exception inbox, business reconciliation | Alerts, audit, agreed SLO |
| Upgrade | Compatibility canary, migration rehearsal, rollback/forward fix | No historical document mutation |
| Suspend | New operations restrict as defined; read/export remain policy bound | No silent data deletion |
| Retire | Dependencies inspect, archive/export, remove new entry points | Retention/legal hold satisfied |

Pack uninstall stock, tax ya posted GL delete na kare. Historical documents installed pack version aur policy version retain karen. Failed upgrade default previous application release par ja sakta hai sirf jab schema backward-compatible ho; destructive schema change ke liye tested forward fix aur full restore decision ho. Database backup restore se beech ke valid transactions kho sakte hain, is liye application rollback aur data rollback ko alag plan kiya jaye.

## Shared entities aur invariants

`LegalEntity`, `Branch`, `Warehouse`, `Party`, `Item`, `UOMConversion`, `PriceAgreement`, `SerialAsset`, `Batch`, `TraceEvent`, `Order`, `Fulfilment`, `Invoice`, `PaymentAllocation`, `CreditNote`, `ServiceJob`, `Contract`, `ProductionOrder`, `QualityResult`, `ApprovalDecision` aur `IntegrationDelivery` reusable concepts hon. Existing ERPNext DocTypes ka fit map implementation se pehle banega; yeh list automatic nayi database tables ka hukm nahin.

- Posted stock/GL entry append-only correction model follow kare; reversal original se linked ho.
- Ek serial ek waqt mein ek active custody/location rakhe; warranty aur inventory ownership alag fields hon.
- UOM conversions exact approved precision ke saath hon; carton, piece aur bottle ko free-form numbers se mix na kiya jaye.
- Quantity reservation aur actual dispatch alag hon; concurrent orders last item do martaba na bechen.
- Batch transformation inputs se outputs, scrap aur rework tak genealogy preserve kare.
- Customer-owned, consignment, demo, loaner aur sale stock alag valuation/custody policies rakhen.
- Receivable balance invoice aur settlement se nikle; sales rep direct customer balance edit na kar sake.
- Business event mein tenant, legal entity, actor, source document, occurred_at, recorded_at, timezone, correlation ID aur policy version ho.
- External webhook/retry ko stable idempotency key aur deduplication window mile; unknown outcome investigate ho, blind second posting na ho.

GS1 documentation critical tracking events aur associated data elements ka framework deti hai [IND-S11]. Operqon ka proposed `TraceEvent` receiving, transforming, repacking, dispatch aur return par item/batch/serial, quantity/UOM, parties, location aur transaction references capture kare. GS1 identifiers ka support khud national compliance certification nahin [IND-S12].

## Pack UX contract

Har pack ek role-based launch workspace de: aaj ke kaam, blocked records, approvals, overdue commitments aur operational KPIs. Navigation ka order customer ke task ke mutabiq ho. Domain labels underlying accounting meanings ko na badlen. Pack switch par user permission expand na ho. Har record mein history, related documents, attachments, comments, financial impact preview aur next allowed action ka pattern same rahe.

Offline route sales/POS mein device identity, local encryption, bounded price list validity, preallocated stock/serial range ya reservation policy aur conflict resolution chahiye. Country invoice obligations ke mutabiq offline receipt/invoice mode explicitly select ho; offline ko har mulk mein legal tax invoice promise na banaya jaye. Sync UI pending, failed, duplicate, rejected aur reconciled ko wazeh dikhaye.

## Automation policy

Deterministic automation: minimum-stock requisitions, expiry alerts, scheduled AMC visits, reminder queues, matched-price proposals, stock allocation, exception routing. Har automation par trigger, conditions, action, actor, permissions, execution ID, dry run, retry policy aur undo/compensation defined ho. Financial write, controlled-drug release, bank-detail change, high discount, expired-stock override aur externally submitted tax correction ko configured human approval chahiye.

AI suggestion: demand forecasting, duplicate master detection, OCR extraction, draft quotation, unusual-margin alert, recommended reorder. Confidence, source, reason aur reviewer correction retain hon. AI ko unbounded script execution, silent tax-law interpretation, autonomous medicine substitution ya unapproved financing decision ka right na mile.

## Pack ka Definition of Ready

Ready tab jab domain interviews, exact user roles, process map, policy decisions, dependency/version map, screen inventory, data dictionary, posting examples, import template, test fixtures, privacy class, localization matrix aur support model documented hon. Discovery pack ko sales page par available production feature na bataya jaye.

## Pack ka Definition of Done

- Happy path ke saath return, partial fulfilment, cancellation, duplicate retry, concurrent change, backdated entry aur fiscal-lock tests pass.
- Opening stock + receipt + output − issue − scrap = closing stock; subledger aur GL agreed policy par reconcile.
- Tenant A ka user tenant B ka serial, patient data, customer list ya document link read nahin kar sakta.
- Role restrictions UI aur server dono par enforced; export, bulk action aur mobile API bhi covered.
- Upgrade previous supported version ke representative data par chale aur idempotent retry ho.
- Barcode, printer, scanner, scale aur offline flows representative hardware par verified hon.
- Accessible keyboard use, mobile/responsive behavior, Arabic RTL aur terminology review pass hon.
- Domain owner aur accountant named pilot evidence approve karen; regulatory workflows relevant country gate pass karen.
- Operator runbook, failed-sync playbook, reconciliation report, training task aur rollback/forward-fix evidence available ho.

## Release strategy

IW1 core trading + services ka complete vertical slice; IW2 FMCG/beverages + serial dealerships; IW3 bakery/restaurant + manufacturing; IW4 pharmacy aur regulated/high-complexity sectors after specialist validation; IW5 additional catalogue families demand-based. Yeh relative sequencing hai, fixed delivery date nahin. Har wave platform, compliance aur commercial readiness ke gates par depend karegi. 200-row catalogue ambition ko organize karta hai; simultaneously 200 packs build karna product plan nahin.

## Industry sequencing aur programme waves ka mapping

`IW` industry portfolio sequence hai; engineering roadmap ka `W` programme milestone hai. In ka same number same deadline ya scope imply nahi karta.

| Industry sequence | Portfolio scope | Programme dependency |
| --- | --- | --- |
| IW1 | Core trading/services/retail base | W1 shared core; W2 country-ready launch |
| IW2 | FMCG/beverages/serialized dealerships | W2 distribution; W3 vehicle-specific pilots |
| IW3 | Bakery/restaurant/manufacturing/rental | W3 food pilots; W4 complex manufacturing |
| IW4 | Pharmacy and regulated variants | W4 specialist and country gates |
| IW5 | Additional demand-validated families | W5 expansion and region-specific gates |
