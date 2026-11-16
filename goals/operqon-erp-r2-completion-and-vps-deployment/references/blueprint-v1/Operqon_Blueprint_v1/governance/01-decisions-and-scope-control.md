# Architecture/product decisions aur scope control

Yeh proposed decision register hai. Existing approved prices aur identity/core choices ko baseline maana gaya hai; new quotas, budget, launch markets aur new product policies ko product owner approve karega jab implementation commitment diya jaayega. Is planning task ko complete/publish karne ke liye koi additional approval pending nahi.

| ADR | Decision | Rationale | Consequence / review trigger |
| --- | --- | --- | --- |
| ADR-01 | Frappe/ERPNext foundation, Operqon-owned experience/control plane | Working core ko reuse; product value workflows aur operations mein | Pinned compatibility/license review; no ERPNext core fork by default |
| ADR-02 | Modular core plus packs | Hundreds of industries mein common engines reuse | Pack contract, dependency resolver aur upgrade matrix required |
| ADR-03 | Tenant default independent site/database | Operational isolation and export/restore boundary clear | Shared bench still shared failure/resource boundary; dedicated tier separately measured |
| ADR-04 | Legal-entity country localization | Same group multiple jurisdictions mein operate kar sakta | Branch/country errors prevent; jurisdiction change after postings migration |
| ADR-05 | Independent franchisee independent tenant | Franchisor ownership/access ko contractual scope tak rakhe | Federated aggregate exchange; no direct all-tenant SQL reporting |
| ADR-06 | Provider and ERP accounting separate domains | SaaS subscription invoice customer business invoice nahi | Separate ledger, credentials and reconciliation |
| ADR-07 | One IdP, explicit verified account binding | Password duplication aur email-only linking errors reduce | OIDC issuer/subject authoritative; recovery/break-glass governed |
| ADR-08 | Configuration first, versioned extension second | One-off tenant forks maintenance ko multiply karte hain | Customer-specific requirement documented extension contract se |
| ADR-09 | Tax calculation and authority acceptance separate | Local invoice aur government accepted invoice differ | Fiscal state machine, immutable payload and reconciliation |
| ADR-10 | Automation risk-based | High-volume routine work automatic ho sakta; consequential actions accountable hon | Payments, close, bank changes, regulated submissions role/approval policy se |
| ADR-11 | Web first; task-specific mobile/offline | Core launch aur field device needs alag | Native device spike and offline conflict policy before commitment |
| ADR-12 | Current PKR price approval preserved | Research pricing ko silently change nahi kar sakti | Quotas/addons/proposed Enterprise need independent approval |
| ADR-13 | Catalogue is discovery scope, GA is evidence state | Industry names count se quality prove nahi | Every pack needs actual workflows, tests, domain UAT and support readiness |
| ADR-14 | Docs publication separate from deployment | Product strategy source merge server activation nahi | This change touches documentation/design references only |
| ADR-15 | Effective-dated accounting policies | Law/standards and business policies evolve | Historical invoice/reports original policy reference preserve |
| ADR-16 | User data export and retention explicit | Customer ownership/subscription/legal hold differ | Closure workflow with download, retention expiry and deletion evidence |
| ADR-17 | Integration before rebuilding commodity productivity | Email/video/docs suite expensive separate product | One workspace can connect tools without claiming ownership of them |
| ADR-18 | No claimed certifications from design | Research evidence product certification nahi | Marketing support matrix and authority records must match |

## Pack state aur readiness vocabulary

**Canonical readiness lifecycle:** `discovery -> specified -> implemented -> integration_tested -> domain_uat -> controlled_pilot -> ga -> deprecated -> retired`. Is register ke identifiers manifest/API contract ke liye authoritative hain. Installation operation stages separate execution states hain.

`discovery -> specified -> implemented -> integration_tested -> domain_uat -> controlled_pilot -> ga -> deprecated -> retired` proposed product-release states hain. In ko existing Tenant/Subscription database enums mein insert nahi karna. Country support ke granular statuses compliance documents define karte hain. Aik industry pack kisi country ke saath unavailable ho sakta hai chahe dono individual catalogue mein maujood hon.

Availability service `(industry_pack, country_pack, legal_entity_profile, engine_version, plan, region)` combination ka support decision de. Unsupported combination ko sales catalogue aur onboarding dono mein reason ke saath show kare. Installer arbitrary version pick na kare.

## Change request ka process

Request mein customer problem, evidence, frequency, current workaround, financial/control impact, affected roles, expected outcome aur scope ho. Product triage reusable core/industry extension/country rule/custom connector mein classify kare. Domain owner invariants aur acceptance examples sign kare. Technical design API/data/migration/license impacts record kare. Delivery staging evidence aur support/training assets ke saath release ho.

Har change ki versioned acceptance criteria aur exclusions hon. New requirement aane par related catalogue row, backlog, screen map, permission matrix, schema, migration aur tests update hon. Sirf top-level narrative edit enough nahi. Old decision superseded date/reference ke saath preserve ho.

## Research quality aur evidence freshness

Official tax authority, standards body aur vendor documentation primary sources hain. Vendor feature page market capability ka evidence hai; product quality, local certification ya implementation time ka proof nahi. Is task mein live customer interviews, audited willingness-to-pay data aur authority sandbox tests nahi huay. In activities ke backlog items actual delivery gate hain.

Sources mein URL, title, access date, jurisdiction, supported claim aur limitation record hon. Time-sensitive rule source same jurisdiction ke newer circular/legislation se conflict kare to publish decision block ho. Planning date ke baad ka announced milestone future rule hai; current obligation nahi. Credentials-required schema unverified ho to gap explicit rahe.

## Ownership aur decision meetings

Product owner business priorities/prices; platform lead architecture/releases; domain lead workflow correctness; accountant/tax advisor localization; compliance owner evidence; security lead access/privacy; operations lead SLO/backups; support lead onboarding/incident communication own karein. Solo early team aik insan ko multiple hats de sakti hai; irreversible financial approvals mein separation ke requirements phir bhi documented hon.

Proposed cadence: weekly product/exception triage, fortnightly demonstrated workflow release, monthly SLO/support economics review, quarterly pack portfolio review. Regulatory effective dates aur severity-based incident decisions calendar ka wait nahi karte. Yeh product operating model hai; is request mein recurring tasks create nahi kiye gaye.

## ADR-19: customer recovery/export policy delta

Current baseline .16 expiry/suspension ke baad normal entitlement access deny karta hai. Proposed policy authorized owner ko verified, time-limited, read/export recovery channel de gi; normal ERP write ya financial posting restore nahi karegi. Scope, identity verification, legal hold, retention, audit aur abuse controls separately implement/approve hon. Yeh current runtime behavior ka claim nahi.
