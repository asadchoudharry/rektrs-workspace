# Operqon product, plans aur commercial model

Tareekh: 6 November 2026. Darja: product planning proposal; approved prices alag nishan ke saath. Is document ka koi proposed feature production mein maujood hone ka dawa nahin.

## 1. Product ki pehchan

Operqon ek multi-industry business operating platform ho: ek identity, ek company context, ek customer/vendor/item record ki governed definition, ek audit trail aur connected financial outcome. User industry choose kare aur usay us business ki zaban, screens, controls aur reports milain. Bakery mein recipe aur daily bake plan pehla workflow ho; vehicle dealership mein VIN aur booking; distributor mein route aur recovery. Har industry ko mukhtalif isolated software banane ke bajaye core engines ko versioned packs se compose kiya jaye.

Zoho One ka documented model unified apps, centralized administration aur extension ko ek suite mein rakhta hai [PRD-01]. Operqon ke liye iska product sabaq coherent navigation aur administration hai. ERP ki financial integrity aur industry depth ko independent acceptance evidence se establish karna hoga. Competitor ki app tadaad ko Operqon ki functional completion ka substitute na banaya jaye.

### Value promise

- Owner ko cash, overdue recovery, stock risk, margin aur aaj ke exceptions ka saaf jawab.
- CFO ko reconciled ledgers, tax evidence, close controls aur financial dimensions.
- Operations manager ko demand se fulfilment tak visible ownership aur bottlenecks.
- Frontline worker ko apne kaam ki chhoti queue, scan/tap actions aur clear next step.
- Implementation partner ko reusable configuration, governed extensions aur support diagnostics.

### Product outcomes aur measurement

| Outcome | Measurement definition | Proposed pilot threshold | Evidence |
|---|---|---:|---|
| Pehla real workflow jaldi chalna | Account request se first validated business transaction tak elapsed time; pending KYC/configuration ko alag report karein | Assisted pilot mein 2 working days, migration complexity alag | Lifecycle + ERP event timestamps |
| Kam duplicated work | Order se invoice tak dobara manually enter kiye fields | Common flow mein <10% business fields | Task observation |
| Data par bharosa | Trial balance, stock valuation aur source records reconciliation | 100% selected acceptance sample | Reconciliation reports |
| Adoption | Invited operational users mein weekly task completion | 70% after first month, proposed | Privacy-respecting usage events |
| Support asani | Support session se issue samajhne ka median waqt | Baseline ke baad 30% reduction | Redacted diagnostic packet |
| Pack fit | Required use cases mein accepted cases ka hissa | Launch-critical cases 100% | Signed UAT matrix |

Thresholds product targets hain, customer contract ya measured current achievement nahin.

## 2. Composition aur product boundaries

Recommended composition:

`Platform foundation + business core + industry pack(s) + country pack per legal entity + channels + approved extensions`.

Core mein identity, organizations, contacts, catalog, sales, purchasing, inventory, accounting, reporting, documents, workflow, audit aur notification services hon. Manufacturing, field service, route sales, clinical/prescription controls aur advanced consolidation apne specialist packs hon. Company ke paas ek se zyada operating models hon to compatibility resolver dependencies aur conflicts dikhaye. Bakery + cafe + distribution ki configuration legitimate hai; prescription pack ko restaurant labels mein chhupa dena acceptable nahin.

Country company/legal entity ki property ho; language, user location aur billing currency us se alag. Saudi entity Arabic UI mein aur Pakistan owner English UI mein kaam kar sakte hain. Data placement aur tax treatment UI language se infer na ho.

### Suite ke product areas

| Area | Base responsibility | Specialist expansion |
|---|---|---|
| Sales & CRM | Leads, opportunity, quotation, order, return | OEM allocations, tender costing, subscription renewal |
| Purchase | Requisition, RFQ, supplier offer, PO, receipt, bill | Import landed cost, subcontracting, blanket agreements |
| Stock & warehouse | Item, UOM, locations, movements, valuation | Bin waves, FEFO, cold chain, serial genealogy |
| Finance | AR/AP, journals, bank matching, fixed assets, close | Multi-entity consolidation, local filing, treasury |
| Commerce & POS | Counter transactions, receipt, shift | Restaurant tables/KDS, kiosks, regulated dispensing |
| Production | BOM, work order, material issue, finished receipt | Recipes, process yields, quality, capacity planning |
| Projects & service | Jobs, time, expense, customer support | AMC entitlements, technician dispatch, installed assets |
| People | Directory, roles, attendance integration | Country payroll, leave/end-of-service packs |
| Insights | Role dashboard, saved report, exports | Forecasting, consolidated semantic model |
| Platform | Workflow, custom fields, APIs, events, consent | Marketplace packs, controlled AI assistants |

## 3. Approved pricing baseline

Source: current `customer-layer-spec-r3.md`, approved 6 November 2026. Ye table commercial baseline hai; live API catalogue ki verification deployment ka alag gate hai.

| Plan | PKR monthly | PKR yearly | Tax treatment | Trial |
|---|---:|---:|---|---|
| Starter | 7,500 | 75,000 | Tax excluded | 3 days |
| Growth | 9,999 | Abhi approved nahin | Tax excluded | 3 days |
| Business | 19,999 | Abhi approved nahin | Tax excluded | 3 days |
| Enterprise / dedicated | Quote required; naam/offer proposed | Quote required | Jurisdiction dependent | Contract dependent |

Country-specific currency catalogue API se aaye. USD/SAR ko PKR exchange rate se khud convert karke published price na banaya jaye. Price approval ka record currency, tax presentation, term, validity, audience aur approver rakhe. Customer ko sale ke waqt accepted offer version persist ho. Purane contract ko catalogue edit se silently badalna mana ho.

### Proposed packaging, approval required

Price ke ilawa neeche har entitlement aur limit proposal hai. Product/finance capacity assessment ke baad approve karein.

| Capability / limit | Starter proposal | Growth proposal | Business proposal | Enterprise proposal |
|---|---|---|---|---|
| Legal entities | 1 | 1 | 2 | Contract |
| Branches | 1 | 3 | 10 | Contract |
| Named full users | 3 | 5 | 10 | Contract |
| Read-only/customer/supplier portal | Fair-use policy; identities remain unique | Same | Same | Contract |
| Storage | 5 GB | 15 GB | 50 GB | Region/retention contract |
| Core sales/purchase/stock/finance | Included within certified scope | Included | Included | Included |
| Basic industry starter configuration | 1 compatible supported pack | 1 supported pack | Up to 2 compatible packs | Contract |
| Extra vertical engine | Add-on quote | Add-on quote | Add-on quote | Contract |
| Local country base accounting | 1 supported country | 1 supported country | Per entity supported country | Contract |
| Authority transmission / accredited provider fees | Clear add-on or pass-through offer | Same | Same | Contract |
| Approval workflows | Standard templates | Configurable steps | Versioned conditions & maker-checker | Advanced governed |
| API / automation | Limited published API | Higher usage envelope | Integrations + sandbox option | Reserved capacity |
| Reporting | Standard | Saved views and schedules | Advanced dimensions/consolidation where supported | Governed BI |
| Support | Business-hours ticket | Priority ticket | Assisted admin support | Negotiated SLA |
| Data export + security basics | Proposed authorized recovery/export channel; ADR-19 | Same | Same | Same |

Mandatory security, valid financial records, auditability aur applicable compliance controls ko paid upgrade ke peeche na rakhein. Entitlement commercial access batata hai; role permission aur record scope independently authorize karein. User limit exceed ho to unauthorized user create karne ke bajaye actionable limit response aur approved upgrade path ho. Historical read/export preservation proposed policy hai (ADR-19); current baseline expiry/suspension ke baad normal access deny karta hai. Verified recovery/export service ko separately approve aur implement karna hai.

Transaction counts ko pehle cost telemetry se validate karein. Artificial hard invoice limit critical period mein business rok sakti hai. Proposed approach soft warning + sales contact + explicit contracted fair use, magar abuse/resource protection mein server-enforced rate limits zaroor hon.

## 4. Subscription aur billing ke tamam zaroori cases

Billing subscription state aur ERP provisioning state ko alag rakhe. Payment success ka matlab provisioning success nahin; ERP ready ka matlab authority-connected invoicing ready nahin.

| Trigger | Expected customer experience | Required control |
|---|---|---|
| Plan choose | Currency, term, tax, addons, renewal policy aur total ka review | Versioned price offer |
| Trial begins | ERP provision hone ke baad server-authoritative 3-day countdown | Existing approved trial start rule verify; browser clock irrelevant |
| Trial ends | Clear status, outstanding actions, upgrade path | Proposed grace/read-only policy separately approve |
| Bank transfer proof | Proof received; verification pending | Proof payment receipt ka final evidence nahin; authorized approver confirm kare |
| Gateway checkout | Hosted provider screen; return to pending/success view | Signed webhook/server verification; redirect alone payment proof nahin |
| Webhook duplicate | Ek payment/entitlement effect | Provider event deduplication |
| Payment pending / asynchronous | Pending badge + expected next step | Reconciliation job; no premature activation |
| Gateway charge succeeds, API timeout | Status query and eventual reconciliation | Idempotency reference persisted before request |
| Upgrade mid-cycle | Before/after features aur itemized amount | Proposed proration method + rounding policy approved before sales |
| Downgrade | Effective date aur incompatible features ki list | No silent deletion; storage, seats, pack dependencies validated |
| Cancel at term end | Access end date aur export option | Clear cancellation confirmation; legal retention separate |
| Immediate cancel | Refund eligibility and business impact review | Contract/jurisdiction policy, authorized action |
| Refund / chargeback | Credit/refund status with evidence | Finance approval, payment-provider linkage, subscription risk hold |
| Dunning | Notices, recovery options, grace progression | Proposed configurable grace; prior safeguards and contract apply |
| Tax registration changes | Future invoice information update | Historical invoices immutable; credit/reissue route where lawful |
| Annual renewal | Advance notice and accepted renewal price | Consent/policy/version record |
| Free extension / goodwill credit | Visible expiry and reason | Limited operator role, audit entry |
| Group customer pays centrally | Billing account mapped to multiple subscriptions | Payer permission never grants access to tenant books |

Historical instruction ke mutabiq private finance aur live payments disabled rehne ki protection tab tak rahe jab tak separately authorized activation, credentials, tests aur rollback checks complete na hon. Is planning ko un protections ki activation approval na samjha jaye. Customer-facing supported manual billing path kaam kare; missing gateway ko fake success se cover na karein.

## 5. Revenue model aur cost discipline

Subscription recurring software access cover kare. Complex migration, historical cleanup, custom integration, user training, hardware installation, dedicated region aur regulatory provider onboarding alag scoped services hon. Proposal mein har component aur ongoing maintenance owner wazeh ho.

Add-on units coherent hon: extra named user, legal entity, branch/device concurrency, storage, execution quota, supported specialist pack aur dedicated capacity. Ek hi business growth ko har field mein baar-baar charge na karein. Pack marketplace commission ko support aur incident responsibility ke saath price karein.

### Illustrative unit economics; actual budget nahin

Misaal: 100 Starter monthly tenants se gross ex-tax MRR PKR 750,000. Agar monthly variable direct cost per tenant PKR 1,500 ho to contribution PKR 600,000, ya 80%. Agar cost PKR 3,000 ho to PKR 450,000, ya 60%. Agar PKR 5,000 ho to PKR 250,000, ya 33.3%. Ye assumed numbers hain; salaries, R&D, sales, taxes, refunds aur fixed platform overhead shamil nahin.

Starter yearly PKR 75,000 ka recognized monthly revenue allocation, simplified straight-line example, PKR 6,250 banta hai; receipt ke waqt poori collection ko monthly revenue na samjhein. Actual revenue recognition accountant define kare.

| Commercial metric | Definition | Decision use |
|---|---|---|
| Gross MRR / ARR | Recurring contractual revenue; tax/pass-through exclude | Growth tracking |
| Gross revenue retention | Opening cohort recurring revenue retained, expansions exclude | Churn risk |
| Net revenue retention | Retained + expansion minus contraction/churn | Pack usefulness |
| Contribution margin | Revenue minus measured hosting/support/provider variable cost | Pricing sustainability |
| CAC payback | Acquisition cost / monthly gross profit of acquired cohort | Channel scaling |
| Onboarding effort | Setup hours by industry + migration complexity | Services scope |
| Time to recover support cost | Support burden per tenant cohort | Product friction |
| Country maintenance cost | Regulatory monitoring + provider + testing + support | Country launch viability |

No arbitrary low price promise for every deep industry pack. PKR 7,500 baseline ko maintain karte hue complex implementation professional services aur certified addons se commercially viable banayein.

## 6. Sales, onboarding aur customer success

Pakistan aur MENA ki pehli launch industry/customer pairs demand evidence se choose hon. Recommended initial discovery: FMCG distribution, services/AMC aur vehicle dealership ke 5-5 businesses interview; un mein se 2-3 design partners per selected launch pack. Interview mein daily records, approvals, exceptions, month-end sample aur real handovers observe karein. Sirf feature wish list na banayein.

Sales funnel: lead -> fit questionnaire -> supported-country/industry check -> tailored demo -> implementation scope -> written offer -> accepted subscription -> migration/onboarding -> first successful workflow -> adoption review -> renewal/expansion. Unsupported regulated workflow ka custom commitment engineering/compliance acceptance ke baghair na diya jaye.

Support catalogue mein severity, coverage hours, contact channel, response target aur escalation owner contract se tied hon. Proposed S1: business-critical outage/security incident; S2: major workflow block; S3: workaround available; S4: how-to/improvement. Response target resolution guarantee nahin. Launch se pehle on-call staffing aur telemetry validate kiye baghair 24/7 SLA publish na ho.

Training role-specific ho: cashier ko POS shift/refund; accountant ko posting/reconciliation/close; storekeeper ko scan/transfer/count; owner ko approvals/KPI; partner ko deployment/configuration. Training material country aur pack version dikhaye. Demo data resettable aur production se isolated ho.

## 7. Partner aur marketplace governance

Partner directory mein geographic scope, supported packs, language, certifications, service scope aur customer references hon. Partner ko har tenant ka access automatically na mile. Customer-issued time-bound grant, permitted tasks, sensitive-field masking, reason aur audit required hon. Revocation active sessions/jobs par asar dale.

Marketplace submission manifest mein owner, version, dependencies, data access, network destinations, supported countries, migrations, tests, accessibility, support term, pricing aur uninstall consequences hon. Automated scans ke baad independent functional/security review aur staged rollout ho. Partner app accounting posting contract ya tax connector silently override na kar sake.

Revenue share, warranty, incident liability, customer data ownership, exit/export aur maintenance term signed agreement mein ho. Pack abandon ho to freeze new installs, notify customers, assign migration route; paid customers ko orphaned financial workflow mein na chhorain.

## 8. Scope decisions jo commercialization se pehle chahiye

1. Launch ke do ya teen industry packs aur pehla country cohort.
2. Proposed quotas, add-on pricing, support hours aur annual Growth/Business offers.
3. Trial-end behavior, grace, dunning, refunds aur cancellation policy.
4. Accountant/compliance validator aur authority/provider onboarding budget.
5. Data region, tenant isolation tier aur restore objectives ki contracted offering.
6. Marketplace partner legal/support model.

In decisions ke pending hone se research ya reusable core design nahin rukta. Magar unsupported capability ki sale/published certification rukti hai.

## Sources

[PRD-01] Zoho One official overview: https://www.zoho.com/one/ (accessed 2026-11-06).
[PRD-02] Zoho One pricing FAQ: https://www.zoho.com/one/pricing/faq.html (accessed 2026-11-06). Is document mein foreign competitor prices ko pricing recommendation nahin banaya gaya.
[PRD-03] Microsoft Business Central licensing guidance: https://www.microsoft.com/licensing/guidance/Dynamics-365-Business-Central (accessed 2026-11-06).
