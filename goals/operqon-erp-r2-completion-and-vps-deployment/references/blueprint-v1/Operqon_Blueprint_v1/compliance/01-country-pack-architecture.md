# Operqon: country pack aur compliance architecture

Research cut-off: 6 November 2026, Asia/Karachi. Yeh product specification hai; neeche diye gaye packs proposed hain. Is research se kisi Operqon connector ki deployment, registration, accreditation ya production acceptance sabit nahi hoti.

## 1. Product ka wada

Operqon ka global model `shared ERP + industry pack + country pack + entity configuration` hoga. Country select karne se har tax automatically applicable nahi hoga. Legal entity, establishment, tax registrations, transaction, customer, product, place of supply aur effective date mil kar applicable policy tay karenge. Ek tenant ki Saudi entity Saudi rules aur Pakistani entity apne federal/provincial rules use karegi. Group consolidation source ledgers ko badle baghair reporting currency mein hogi.

Country support ko chaar alag labels milenge:

| Layer | Product deliverable | Acceptance evidence |
|---|---|---|
| Accounting localization | Chart of accounts template, fiscal calendar, document language, currency, statutory report mappings | Local accountant ki reviewed fixture aur reconciliation |
| Tax determination | Registration, product classification, exemption, withholding, place-of-supply, calculation aur return mapping | Date-specific golden transaction tests |
| Regulatory exchange | Prescribed structured invoice, digital signatures, transmission, status, correction | Sandbox aur controlled production evidence |
| Approval/recognition | Jahan zaroori ho integrator/provider/filing authorization | Named authority/provider approval, valid dates aur scope |

Marketing mein `supports bookkeeping`, `tax calculation available`, `sandbox tested`, `production enabled` aur `approved provider` ko aik label mein jama nahi kiya jayega. Kisi incumbent ERP ki localization install hona Operqon ki certification nahi.

## 2. Pack composition

Pack registry mein unique `country_code`, `jurisdiction_code`, `pack_id`, `semantic_version`, `compatible_core_range`, `dependency_packs`, `effective_from`, `effective_to`, `supported_entity_types`, `supported_transactions`, `authority_endpoints`, `schema_versions`, `locale`, `default_currency`, `owner`, `reviewer`, `evidence_bundle`, `release_status` honge. Registry coverage transaction aur taxpayer cohort tak visible karegi. `PK` parent pack ke andar provincial service tax adapters independent versions honge; `US` parent ke andar state/local rules aur federal filings independent capabilities honge.

Industry pack tax rates own nahi karega. Pharmacy item apni licensed product classification country resolver ko dega; restaurant dine-in transaction service classification aur payment context dega; beverage distribution sugar-content/volume/excise attributes dega. Resolver jurisdiction-specific rule select karega. Missing mandatory classification par invoice submission blocked hogi aur operational draft ki ijazat hogi.

## 3. Canonical financial document

Invoice canonical model mein seller/buyer legal identity, registrations, establishment/branch, country/subdivision, supply aur issue dates, document currency, reporting currency, exchange-rate source/time, item/service classification, quantity, units, unit price, discounts, charges, tax bases, categories/rates, exemptions/reasons, withholding, deposits, totals, payment terms, document references aur attachments shaamil honge.

Regulatory extension namespaced hogi: `pk_fbr`, `sa_zatca`, `ae_peppol`, `eg_eta`, `us_irs_iris`. Extension ko canonical ledger par arbitrary write access nahi milegi. Acknowledgment aur signed payload append-only artifacts honge; rendering aur reporting original payload se link hongi.

Har monetary field decimal type use karegi. Currency precision ko tax computation precision se alag rakhen. Adapter line-level vs document-level rounding, inclusive/exclusive calculation, allowance allocation aur permitted tolerance declare kare. Minor difference ko chupke price ya tax badal kar absorb na kare. Rounding journal sirf configured account aur approved policy ke saath bane.

## 4. Rules engine aur temporal correctness

Rules `country → subdivision → registration → transaction type → product/service → exemption → effective date` ki explicit precedence use karein. New rule overlapping date ranges, absent evidence aur conflicting precedence ke saath activate na ho. Historical invoice apni original rule version, schema version, tax determination inputs aur calculation trace retain kare.

Tax change future-date se publish ho sakta hai; backdated transaction par relevant supply/tax point policy apply hogi. Rule rollback historical accepted invoice ko recalculate nahi karega. Recalculation ke liye visible correction workflow aur reconciliation chahiye. Exchange-rate override reason aur authorized approver ke saath ho. DST/timezone conversion boundary tests hon; UTC audit time aur jurisdiction local issue time dono preserve hon.

## 5. Submission state machine

Generic internal states: `draft → validated → sealed → queued → submitted → accepted/rejected/unknown`. Regulatory country statuses separately preserve honge. `unknown` ka matlab timeout ke baad authority outcome maloom nahi; is ko `rejected` samajh kar naya invoice number issue nahi karna. Status lookup/reconciliation pehle, idempotent retry baad mein. `accepted_with_warning`, `clearance_pending`, `reporting_overdue` aur `correction_pending` mapped substates ho sakte hain.

Business document lifecycle aur external transmission lifecycle alag entities hon. Authority se invoice accept hone ka matlab customer payment receive hona nahi. Payment refund, commercial credit note, stock return aur authority credit/debit document alag events hain aur references se jure honge.

Immutable transactional outbox invoice commit ke saath likhi jaye. Worker at-least-once delivery use kare; local uniqueness aur authority-supported idempotency se duplicate effect roke. Queue per entity/EGS signing sequence preserve kare jahan required ho. Exponential backoff, jitter, rate-limit budget, circuit breaker, poison-message dead-letter queue aur authorized replay ho. Worker restart test mein signed payload change na ho.

## 6. Offline aur outage rules

`Offline POS available` ko har country mein legal invoice capability na samjhein. Har document type ke liye offline policy declare ho: draft only, signed local issue then time-bound reporting, ya clearance required. Allowed deadline authority rules se aayegi. Connectivity lost UI authority status, local sync status aur customer delivery status alag dikhaye. Local device clock tampering, secure key access, certificate expiry aur duplicated terminal sequences test hon.

Outage par operator ko deadline risk, pending count, oldest invoice, affected entities aur allowed next step mile. Retry button new invoice create na kare. Manual portal submission sirf documented supported route mein ho; receipt upload, reviewer matching aur duplicate suppression zaroori. Paper fallback ki blanket permission na dein. Authority outage evidence, notification requirement aur permitted contingency route country runbook se aayega.

## 7. Credentials aur trust boundary

Authority taxpayer credentials, signing keys aur provider credentials har entity/device boundary par isolate hon. Secret vault references database mein, plain secrets logs/support exports mein nahi. Secret issue/rotate/revoke audit ho; production aur sandbox ka visual aur technical separation ho. Expiry alerts 60/30/14/7/1 din proposed defaults hain, legal deadlines nahi. Revoked/expired key se submission block ho aur recovery route visible ho.

Signer preferably isolated signing service aur supported hardware/managed key storage use kare. Private keys browser storage, generic tenant settings export ya AI context mein na jayen. Role matrix: preparer drafts; accountant classifications/reconciliation; tax approver releases; authorized representative onboarding; support redacted diagnostics. Har signed action mein actor, delegated authority, timestamp aur trace ID ho.

## 8. Accounting invariants

Every posted transaction balanced ho; tax subledger, AR/AP, stock valuation aur GL reconcile karein. Accepted fiscal payload aur posted financial meaning mein conflict na ho. Invoice reversal stock movement khud assume na kare; return inspection aur quantity disposition independently controlled ho. Recoverable input tax, nonrecoverable tax, deferred/accrual tax accounting aur withholding receivable/payable alag accounts hon. Tax return drill-down individual document, mapping aur adjustment tak jaye.

Cross-border sale mein export evidence, customer location, shipping, incoterms, customs/import tax, reverse charge aur transaction currency supported fields hon. Zero-rated, exempt aur out-of-scope ko ek zero-tax code na banayein. Tax grouping aur corporate consolidation alag memberships hon. VAT group entity coverage signer/onboarding policy ke mutabiq confirm ho.

## 9. Privacy, retention aur residency

Accounting country pack, privacy policy, residency region aur payroll pack alag dimensions hon. Saudi cross-border personal data transfer regulated hai; is se har type ka tamam data hamesha Saudi mein rehne ka universal result nahi nikalta. Sector, contract aur transfer basis assess hon. [REG-17](https://sdaia.gov.sa/en/SDAIA/about/ArchivesRegulationsAndPolicies/RegulationonPersonalDataTransferoutsideKingdomEN.pdf)

UAE ka federal personal-data framework bhi processing aur cross-border sharing ko govern karta hai; free-zone/health/finance sector checks separate hon. [REG-18](https://u.ae/en/about-the-uae/digital-uae/data/data-protection-laws)

Region profile primary DB, backups, disaster recovery, logs, analytics, support access, third-party processor aur AI routing sab cover kare. Residency select karke overseas logs bhejna acceptable completion nahi. Retention matrix document category/jurisdiction/legal hold ke mutabiq ho; universal 7 ya 10 saal hardcode na ho. Tax/financial retention aur data-subject deletion request ke conflict ko reviewed legal basis se resolve karein. Backup expiry aur restore mein deleted data reintroduction controls hon.

## 10. HR aur sector compliance boundaries

Payroll calculations, labour rules, social insurance, end-of-service, WPS/bank file, leave accrual aur statutory employment forms separate certified capabilities hon. General HR attendance install karne se payroll compliant claim na ho. Pharmacy mein controlled medicines, dispensing permissions, serialization/traceability aur recalls ka country-specific overlay chahiye; restaurant/food mein food-safety records aur excise/stamp workflows; EV mein battery serials/extended producer responsibility; automobile mein vehicle registration/import/consumer-finance documentation. In sab ka discovery owner aur release gate country tax connector se alag hoga.

## 11. Pack install/upgrade contract

Install se pehle eligibility questionnaire, dependency check, incompatible customization scan, dry-run mappings, backup aur reversible migration plan ho. Activation ek entity par canary ho; existing docs ka schema downgrade na ho. Mandatory rule change ki opt-out policy legal deadline ke andar constrained ho. Upgrade report mein new fields, changed calculations, affected open docs, tests aur action owner ho. Customer ke bespoke fields core pack ko fork na karein; supported extension hooks aur versioned migration use hon.

## 12. Ready hone ki minimum definition

Source register current; local accountant signoff; mandatory legal interpretation unresolved na ho; full transaction fixtures pass; rejection/correction/timeout tests pass; entity enrollment complete; provider authorization jahan required ho verified; privacy/residency approved; production acceptance evidence stored; operations/on-call owner assigned; user training aur audit export verified. Coverage page supported aur unsupported scenarios dono saaf dikhaye.
