# Operqon: automation, AI aur integrations

Version 1.0 | 6 November 2026 | Har capability proposed hai jab tak release evidence alag se na diya jaye.

## 1. Automation ka operating model

Customer se industry, country, legal entity, branches aur business priorities pooch kar setup assistant recommended configuration banaye. Assistant required data aur expected result explain kare; business ko arbitrary unexplained defaults par operate na karwaye. Automation ka matlab routine kaam reliable banana hai; responsibility aur legally required approvals ko chhupana nahin.

| Level | Misal | Control |
|---|---|---|
| A: automatic reversible | Reminder, report refresh, draft recommendation | Owner-configured rule, audit, undo where applicable |
| B: bounded operational | Approved min/max se replenishment draft; assigned route reminder | Limits, exceptions, approver fallback |
| C: controlled financial | Credit-limit override, journal submit, refund | Role authorization, policy, approval threshold |
| D: regulated/external | Tax return filing, bank payout, prescription exception | Mandated controls, explicit authorized signoff |

Rule automation aur AI ko alag dikhayein. Deterministic tax calculation approved rules se ho. AI customer ko explanation, matching suggestions aur exception summaries de sakta hai, lekin model output ko fiscal truth na banayein.

## 2. Signup se go-live tak

Latest inspected R3 artifact ke canonical tenant statuses: requested, approved, provisioning, active, failed, suspended, rejected. Subscription statuses: draft, trialing, pending_payment, active, past_due, cancelled, expired. Provisioning jobs: requested, approved, queued, provisioning, completed, failed, cancelled, rollback_queued, rolled_back, published. Email verification, identity review aur payment evidence ko nayi tenant enum values na banayein. User tracker labels canonical records se derive hon.

| Step | System action | Failure / exception | Evidence |
|---|---|---|---|
| Business discovery | Country, industry, company size aur required operations capture | Unsupported pack transparent enquiry queue | Versioned answers |
| Identity | Keycloak account/OIDC link, email verification | Duplicate subject/email conflict safe resolution | Subject mapping and verification |
| Tenant request | Existing intake contract se exactly one request | Idempotent retry; duplicate 409 mapping | Tenant ID and request receipt |
| Review | Country/industry risk checklist aur ownership review | Request info/reject reason | Authorized decision audit |
| Commercial | Approved pricebook, tax-excluded/included label, term and 3-day trial | Unavailable currency/plan ko operator quote | Pricebook version |
| Payment | Hosted gateway or manual-bank instructions | Screenshot means pending; settlement approver validates | Payment event and approval |
| Provisioning | Reserved tenant/site ID, pack resolve, DB/site create | Durable resume and bounded retries | Job step log with secret redaction |
| Setup | Company, fiscal settings, opening balances and roles | Invalid mapping dry-run error | Import/reconciliation report |
| SSO launch | OIDC session mapped to authorized site membership | No membership or revoked role denial | Access audit |
| Readiness | End-to-end role workflow, fiscal checks, backup | Block only affected capability with clear task | Signed readiness record |
| Activation | Tenant active when required evidence complete | Compensation/review if provisioning partial | Lifecycle transition audit |

Identity, payment aur provisioning separate state machines hon. Example: payment verified lekin provisioning failed ho to subscription/tenant ko false live na dikhayein. Retry provisioning safe ho; refund ya cancellation authorized commercial action ho. R3 team roster ka source absent ho to empty state show ho, fabricated team count nahin.

## 3. Rule engine contract

Rule fields: rule_id, version, scope, effective dates, event trigger, conditions, action type, owner, authority level, maximum impact, schedule timezone, retry policy, dedupe window, approval policy, expiry, simulation report aur audit retention category.

Workflow lifecycle draft → simulate → review → approved → active → paused → retired. Har active change nayi version ho. Simulation historical/synthetic data par proposed impact dikhaye; live execution ke baghair email recipients, invoice impact aur financial amount preview kare. Rule overlap detector conflicting pricing, repeated reminders aur circular triggers identify kare. Trigger depth aur per-tenant quotas se loops rokein.

Timer event UTC mein store ho; business schedule company timezone aur local holiday calendar se calculate ho. Daylight-saving transition, month-end, leap day aur weekends fixtures se test hon. Bulk action background job ho, progress plus succeeded/failed/skipped counts aur row-level reasons milein.

### Sample rules

| Trigger | Conditions | Action | Exception |
|---|---|---|---|
| Stock threshold | Available below reorder point, no pending approved order | Purchase requisition draft | Supplier inactive or budget exhausted |
| Near expiry | Batch within configured shelf-life horizon | FEFO suggestion and transfer task | Controlled drug disposal requires authorization |
| Credit overdue | Invoice exceeds approved ageing band | Internal collection task; customer reminder if enabled | Disputed invoice held from automation |
| Beverage delivery | Empties short compared with signed receipt | Deposit reconciliation queue | Deposit rate effective date mismatch |
| Warranty request | Serial sold, warranty active, no duplicate claim | Service case and checklist | OEM approval required |
| Manufacturing variance | Actual yield outside approved tolerance | QA hold and supervisor task | No automatic release of unsafe batch |
| Bank feed imported | Exact reference, amount and currency unique | Reconciliation suggestion/approved rule | Ambiguous match review |
| Fiscal rejection | Permanent schema/business error | Exception task and safe correction workflow | Do not generate new duplicate invoice |
| Subscription expiry | Approved contract grace reached | Defined commercial state transition | Existing policy ADR; no silent policy replacement |
| Support anomaly | Repeated provisioning failures | Operator incident with correlated diagnostics | No secret-bearing log attachment |

## 4. Integration platform

Integration catalogue capability-based ho. Har connector card supported countries, directions, objects, sync interval, prerequisites, fees, rate limits, data residency aur support owner bataye. Logo show karna working integration ka saboot nahin. Status planned, sandbox-verified, pilot, production-supported aur retired alag ho.

| Class | Examples | Minimum contract |
|---|---|---|
| Accounting/fiscal | Country authority adapter, licensed access provider | Schema, signature, ack, status reconciliation |
| Banking/payment | Bank statements, hosted gateways | Signed events, settlement reconciliation, refund linkage |
| Messaging | Email, SMS, approved business messaging | Consent, template, delivery/bounce, unsubscribe where applicable |
| Commerce | Storefront, marketplace, B2B ordering | Stock ownership, order dedupe, refunds and tax mapping |
| Logistics | Courier, route planning, proof of delivery | Address privacy, shipment events, exception handling |
| Hardware | Barcode, scale, receipt printer, cash drawer | Device compatibility, calibrated input, driver ownership |
| EV/OEM | VIN/battery registry, BMS/telematics, warranty | Customer consent, device identity, offline validity |
| Food/pharma | Traceability, recalls, temperature sensing | Lot mapping, timestamp quality, excursion escalation |
| HR | Attendance device, payroll bank file | Employee scope, approved payroll, sensitive data controls |
| Productivity | Calendar, document signing, office suites | Minimal scopes, revocation, audit |
| Data/BI | Scheduled export, warehouse, embedded reporting | Tenant policy, semantic definitions, freshness |

Connector installation OAuth/code exchange ya secure credential input se ho. Secret vault reference database mein rakha jaye; browser local storage ya plaintext exported setup file mein nahin. Connection test read-only ho; sandbox aur production visibly separate hon. Token refresh failure user ko task de; expired credentials par endless retry na chale.

### Sync mechanics

Cursor/checkpoint per tenant and connector ho. Object external IDs unique mapping table mein hon. Webhook ke baad periodic reconciliation missing events catch kare. Aik system field ka owner defined ho; bidirectional last-write-wins business data loss kar sakta hai. Conflict mein field-level provenance aur human resolution ho. Backfill live transactions ko duplicate na kare; import batch/source reference idempotency mein include ho.

Deletions tombstone/retention policy se handle hon. External customer deletion fiscal source records erase na kare. Connector uninstallation credential revoke kare, queued sends pause kare aur business records retain kare. Outage dashboard last success, age, failed count, next retry aur responsible owner dikhaye.

## 5. Offline POS aur field sales

Offline support workflow aur country-specific ho. Product local cache, approved price snapshots, device-scoped transactions aur delivery proof permit kar sakta hai. Jahan authority clearance required ho, offline transaction ko final compliant invoice dikhana justified policy ke baghair allowed na ho. Country pack exact legal behavior define kare; offline convenience ko compliance se upar na rakhein.

Minimum design: encrypted local store where platform supports; device registration/revocation; local UUID; bounded offline credit/discount/refund; last verified price/tax version; stock as estimate; shift close; sync manifest; conflict queue; signed device events where appropriate. Device clock ko authoritative fiscal time na banayein. Lost device ka token revoke ho aur cache exposure response defined ho.

Examples: reserved bike serial already another outlet sold ho to queued sale conflict; new replacement serial silently assign na ho. Expired pharmacy batch offline cache mein available lage to dispensing restriction conservatively enforce ho. Cash sale sync payment event aur stock posting exactly once business effect de; multiple transport retries safe hon.

## 6. AI capability plan

| Capability | Input | Output | Validation |
|---|---|---|---|
| Setup copilot | Approved catalogue and discovery answers | Suggested packs/settings | Schema and compatibility validator |
| Document capture | Supplier document image | Draft fields with confidence/source positions | Duplicate, amount and tax checks; user review |
| Business assistant | Scoped semantic model | Answers with report links/as-of time | Tenant and role filters before retrieval |
| Exception triage | Safe logs and domain events | Suggested cause/action | Human executes privileged fix |
| Demand forecast | Sales, stock-outs, seasonality | Forecast plus uncertainty | Backtesting and bias comparison |
| Reconciliation help | Unmatched records | Ranked matches | Bounded matching policy; ambiguity review |
| Workflow builder | Owner's natural-language intent | Draft typed rule | Simulation, approval, deployment gate |
| Support drafting | Authorized knowledge and ticket | Draft response | No external send without scoped policy |

AI ko arbitrary database SQL, shell, payment or credential tool access default se na mile. Tool allowlist, per-action authorization, amount limits aur separate approval tokens hon. Retrieved document instructions untrusted data hain; prompt injection tests karein. Model ko tenant switch karne, policy override karne ya hidden staff data dene ka haq nahin.

Training consent aur provider data-use terms explicit hon; sensitive documents ka external model transfer region/DPA review ke baad ho. Tenant data ko cross-customer retrieval index mein mix na karein. Prompt/output logs redacted aur limited retention ke saath hon. Customer private finance, bank secrets aur credentials ko assistant context mein needless include na kare.

Evaluation suite: known-answer finance questions, tenant leakage attempts, hallucinated tax rates, adversarial invoice, wrong currency, mixed Arabic/English item, scanned low-quality document, malicious attachment instructions aur refusal on unavailable evidence. User-facing confidence exact certainty ka substitute nahin. AI-generated action hamesha source records aur proposed impact dikhaye.

## 7. Notifications aur human work queue

Aik central task inbox manual exceptions ko track kare: owner, due time, priority, blocked reason, affected records, expected action aur escalation. Approval request same user ko apna high-risk action approve na karwaye where segregation required. Delegate/time-off mapping audit ho. Reminder storm suppress ho; severity aur recipient preferences apply hon. Failed external delivery task state ko falsely completed na kare.

## 8. Acceptance scenarios

1. Signup request timeout ke baad retry se aik account aur aik tenant hi bane.
2. Payment webhook 10 baar replay ho; aik settlement aur aik commercial effect ho.
3. Manual-bank proof uploaded ho lekin approval tak paid/active na bane.
4. Approved provisioning job worker restart ke baad correct checkpoint se resume ho.
5. Rule publishes new version; old in-flight request apni version preserve kare.
6. Country adapter rejects invoice; dashboard user ko next action de aur original reference retain kare.
7. Storefront order aur POS same stock reserve karein; oversell control verified ho.
8. AI user B ka data user A ko na dikha sake, chahe prompt mein explicit tenant ID ho.
9. Offline device sync ko replay kare; duplicate stock/GL effect zero ho.
10. Credential revoke hone par connector stopped state aur actionable notification de.
