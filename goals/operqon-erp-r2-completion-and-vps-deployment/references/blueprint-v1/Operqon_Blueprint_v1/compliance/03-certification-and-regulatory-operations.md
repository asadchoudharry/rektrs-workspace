# Operqon: regulatory delivery, certification aur operations

6 November 2026. Proposed operating model. Yeh document standards ko implement/verify karne ka process define karta hai; authority approval ka certificate nahi.

## 1. Accountability

Country pack owner product scope aur deadlines ka zimmedar ho; local licensed accountant/tax specialist applicability aur mappings review kare; regulatory engineer payload/transport implement kare; security owner keys/privacy verify kare; QA owner independent evidence banaye; operations owner incident/replay/reconciliation runbook sign kare. Commercial owner sirf evidence-approved capability sell kare. Ek shakhs multiple roles kar sakta hai lekin production financial release ka self-approval allowed na ho.

Market launch ke liye named representative aur local professional access ka budget zaroori hai. Website par authority logo ya 'approved' wording sirf verified permitted use aur exact approval scope mein ho. General ISO/SOC report tax authority connector approval ka substitute nahi.

## 2. Readiness ladder

| Stage | Kya maujood hoga | Kya claim allowed hai |
|---|---|---|
| C0 Discovery | Source map, gaps, applicability questions | Planned market |
| C1 Spec reviewed | Current rules, accountant opinion, contract/schema | Localization in development |
| C2 Implementation verified | Unit/integration/golden fixtures, migration | Tested internal implementation |
| C3 Sandbox accepted | Authority/provider sandbox evidence and negative cases | Sandbox-tested supported scope |
| C4 Controlled pilot | Enrollment, bounded customers, accepted production samples | Pilot for named cohort |
| C5 Production supported | Ops, SLAs, audits, partner approval where needed | Available for listed transactions/entities |
| C6 Mature monitored | Change watch, incident exercises, regular review | Sustained supported scope |

Accreditation independent field ho: `not_required`, `partner_covered`, `application_pending`, `approved`, `expired`, `revoked`, `unknown`. C5 ki label har market mein approval ko imply nahi karegi. Approval expiry par claim aur new onboarding automatically re-evaluate hon, historical evidence retain rahe.

## 3. Research se rule release tak

1. Official gazette/law/authority technical specification collect karein; secondary commentary discovery lead ke liye use ho.
2. Source registry mein exact URL, title, issuer, document identifier, published/last-updated date, fetched date, effective dates, language, jurisdiction aur supersession chain record ho.
3. Statement ko atomic requirement banayein: applicability, required field, calculation, deadline, workflow, retention, authorization. Har requirement ko source passage/page aur local reviewer interpretation se link karein.
4. Conflicts ko resolve karein: gazette vs FAQ, old manual vs updated API, translated vs original law. Pending conflict affected capability ko C1 se aage na jane de.
5. Rule diff aur sample transactions accountant review kare; engineering fixtures banaye; security schema/key changes review kare.
6. Sandbox evidence aur production pilot receipts ke baad entity-scoped activation ho; public support matrix update ho.
7. Source snapshot/hash aur evidence retention policy ke saath audit bundle seal ho. Webpage ka search snippet akela legal record na ho.

Automated daily source watch URLs/title/hash changes flag kare. System automatic tax interpretation publish na kare. New announcement → triage ticket → impact assessment → reviewed version → future activation ka route ho. High-priority deadline/endpoint/schema alerts owner ko jayein; weekly digest aur monthly pack health review ho. Source review freshness product thresholds: P0/P1 release se pehle <=30 days; breaking announcements same working day triage. Yeh internal SLOs hain, legal requirements nahi.

## 4. Required evidence bundle

Bundle identifier `country-pack/version/cohort/approved-date` ho. Is mein scope statement, unsupported transactions, source references, signed accountant review, provider agreement/approval scope, API/schema versions, calculation fixtures, sandbox responses, redacted production receipts, security review, backup/restore drill, migration/rollback results, customer instructions aur incident contact matrix hon.

Personally identifiable taxpayer information encrypted restricted evidence store mein rahe. Public GitHub mein sirf synthetic fixtures, redacted summaries aur reference hashes hon; signing private keys, tokens, taxpayer payloads aur customer invoice images kabhi nahi. CI ko dummy keys/sandbox fixtures milen. Log examples bhi anonymized hon.

## 5. Test catalog

| Dimension | Minimum cases |
|---|---|
| Identity | Missing/invalid tax ID, branch vs entity, revoked registration, wrong environment |
| Calculation | Inclusive/exclusive, multiple rates, exemption reason, zero-rated/out-of-scope, document discount, charges, fractional quantity, currency precision |
| Time | Tax point vs issue date, backdate, future-date, period lock, new rate boundary, timezone midnight, reporting deadline |
| Document | Standard/simplified, credit/debit note, partial return, advance/deposit, reference validation, cancellation permission |
| Delivery | Duplicate request, duplicate webhook, timeout after acceptance, rate limit, worker crash, reordered queue, authority outage |
| Security | Cross-tenant read/write, unauthorized approval, secrets redaction, certificate expiry/revocation, signature tamper |
| Reconciliation | Authority count/totals vs ERP, rejected/unknown docs, tax return vs GL, FX/rounding difference, replay |
| Migration | Existing open docs, old schema artifact readability, downgrade constraint, rollback and restore |
| UX | Tax error field labels, legal explanation, retry outcome, mixed-language/RTL, download exact accepted artifact |

Each test mein input, expected ledger entries, tax determination trace, payload validation, external result aur observable UI state specify ho. Snapshot-only tests accounting correctness establish nahi karte. Real authority sandbox aur provider contract validation required jahan possible ho. 'Skipped because credentials absent' ko pass na samjhein; missing evidence launch blocker mein visible ho.

## 6. Daily operations

Daily job per entity/timezone authority submission count aur amounts ko ERP fiscal documents se reconcile kare. Exceptions unsubmitted, unknown, rejected, warning, duplicate suspected, mismatched amount aur correction missing type mein queue hon. Accountant resolve kare, support raw financial totals edit na kare. Month-end return close se pehle tax subledger/GL/authority reconciliation signoff mandatory product control ho.

Dashboard: current pack/schema; next mandatory change; certificate expiry; pending oldest age; deadline exposure; rejected percentage; last successful transmission; recent reconciliation difference; authority/provider incident; last reviewed sources. Status page mein Operqon aur external authority availability alag ho.

Proposed internal targets: tax queue lag alert at 5 minutes for normally real-time paths; urgent alert jurisdiction deadline se configurable safety window pehle; P1 operational response <=30 minutes during contracted hours; daily full reconciliation. Actual SLA staffing, provider agreement aur jurisdiction model se set ho; unlimited 24/7 promise staffing ke baghair na ho.

## 7. Incident runbooks

**Authority unavailable:** exact affected endpoint/time/error classify; automatic safe retry; legal contingency policy check; deadline escalation; no duplicate issue; authorized customer message; receipt/status recovery; post-incident reconciliation.

**Certificate compromised:** signing stop for affected EGS/entity; scope isolate; revoke via authorized route; rotate; assess previously submitted docs; authority/security notification rules determine; incident record retain.

**Wrong calculation/rate:** new affected issuance pause; impacted invoice list by rule version; accountant legal correction plan; no historical overwrite; customer/authority corrections linked; ledger/returns reconcile; regression fixture add.

**Provider suspension/expiry:** new enrollment stop; valid current service rights inspect; alternative provider migration/re-enrollment plan; artifacts export; retry semantics/identifiers preserve; customer impact disclosure.

**Out-of-region data:** outbound flow stop/isolate; data map and contractual/legal impact assess; credential revoke where relevant; deletion/transfer remediation evidence; privacy incident obligations by jurisdiction.

## 8. Tax return versus invoice automation

VAT/sales-tax worksheet preparation, return export, accountant approval, authority filing, tax payment aur authority receipt six distinct events hon. 'Auto tax' switch in sab ko silently authorize nahi kare. Delegated authority aur verified API route ke baghair return data accountant ko export ho sakta hai, filed status nahi. Payment initiation bank authorization aur treasury controls ke baghair na ho. User automation goal ka matlab safe repeatable preparation, validation, routing aur monitoring hai; legally accountable approvals retain honge.

## 9. Retention and audit export

Per jurisdiction document-category matrix prepare ho: invoices, signed XML/JSON, authority receipts, journals, tax calculations, inventory valuation, payroll, approvals, customer consent aur security events. Minimum/maximum periods, legal holds, deletion exceptions, permitted location aur readable format local advice se specify ho. Backup restoration retained archive ki authenticity/signature verification aur original file readability demonstrate kare. PDF display original structured artifact ka replacement nahi.

Export customer ko human-readable report plus original machine-readable artifacts, mappings, version manifest, timestamps aur checksums de. Tenant exit par contract ke mutabiq read-only access, data extraction aur retention responsibilities documented hon. Subscription band hone se statutory archive bina policy ke delete na ho.

## 10. Country launch checklist / decision

Decision record mein geography, taxpayer cohort, entity type, supported tax registrations, business types, document classes, languages, currencies, reporting route, partner, dates aur exclusions likhein. Compliance owner, accountant, engineering, QA/security aur operations evidence approvals dein. Owner pilot commercial decision kare. Final gate outcome `launch`, `limited pilot` ya `blocked-with-owner/date` ho. Global country counter sirf active transaction scope ke saath show ho; discovery rows ko integrated markets ke counter mein na ginen.

## 11. Open decisions and estimates

PK licensed-integrator route; PK provincial scope sequence; SA direct EGS integration vs provider economics; AE ASP partner; Oman current provider/schema onboarding; Egypt signing/device route; Jordan latest integration manual; shared regulatory evidence store region; external accountant retainer; monitored-hours staffing; customer fiscal archive contract. Har item ko implementation epic aur evidence gate mile.

Planning allowances per new complex market: discovery/local review 2–6 weeks; first adapter/schema fixtures 4–10 weeks; external enrollment/approval variable; bounded pilot 2–6 weeks. In ranges ko overlapping engineering estimate samjhein, legal approval SLA ya launch guarantee nahi. Shared engine maturity aur partner route time materially badlenge.
