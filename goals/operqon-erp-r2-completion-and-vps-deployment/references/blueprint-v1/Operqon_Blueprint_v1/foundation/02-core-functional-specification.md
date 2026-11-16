# Shared business core: functional specification

Status: proposed target specification. Existing ERPNext capabilities ko pehle map aur validate kiya jaayega; gap ke liye Operqon extension banega. Aik hi business event ke liye duplicate stock ya accounting posting engine nahi.

## 1. Organization, legal entity aur franchise

Tenant commercial/security boundary hai. Tenant ke andar group, legal entities aur un ke branches ho sakte hain. Independent franchisees ko independent tenants rakhna default hai; franchisor ko sirf contractually permitted aggregate/reporting feed mile. Shared login se shared ownership infer nahi hogi. Multi-company same tenant mein bhi record, bank account, tax registration aur report permissions enforce hon.

Legal entity setup mein jurisdiction, fiscal year, functional currency, accounting framework, tax registrations, document series, timezone, address, commercial registration aur responsible accountant capture hon. Business location, cost center, warehouse aur tax establishment ko aik hi field mein collapse na karein. Country pack change after posting controlled migration hai.

Franchise order allocation, retail price guidance, central procurement aur royalty rules alag extensions hain. Intercompany transfer ko internal stock move samajh kar tax aur payable/receivable skip na karein. Consolidated reporting mein source currency conversion aur elimination entries ke audit links hon.

## 2. Parties aur master data

Customer/supplier/contact records duplicate-detection suggestions ke saath banenge. Tax ID normalized form, original display aur jurisdiction preserve kare. Same party multiple roles rakh sakti hai; customer credit limit aur supplier payment terms independently version hon. Delivery address invoice legal address se alag hai. Bank account change independent verified approval maange.

Items: SKU, barcode/GTIN, variants, UOM conversion, purchase/sales units, pack hierarchy, serial/batch policy, shelf life, tax classification, valuation method, supplier mapping aur price list. Barcode scan ka result pack/UOM ke saath aaye; carton ko single piece na samjhe. Tax classification effective date aur reviewer ke saath. Deleting referenced masters ke bajaaye inactive/archive state.

## 3. CRM aur quotation-to-order

Lead source -> qualification -> account/contact -> opportunity -> site survey/requirements -> quote revisions -> approval -> acceptance -> order. Funnel customizable hoga lekin won state ko accounting revenue na samjhein. Price quote tax inclusive/exclusive treatment, currency, validity, lead time, Incoterm where needed, scope, exclusions, attachments aur version record kare.

Margin/discount threshold approver ko jaye. Approved quote ki later edits nayi revision aur customer acceptance maangein. Customer-specific agreed price aur general promotion ki precedence explicit ho. Order approval mein available stock, credit exposure, payment evidence, delivery address aur promise date validate hon. Partial delivery, backorder, substitute, cancellation aur reserved serial release supported hon.

Acceptance: two simultaneous orders same last serial/unit reserve na kar saken; accepted price version locked ho; blocked credit par unauthorized shipment fail ho.

## 4. Procure-to-pay

Purchase request -> budget/approval -> RFQ -> supplier comparison -> PO -> inbound receipt -> quality inspection -> put-away -> supplier invoice -> matching -> payment approval -> bank reconciliation. Service procurement mein goods receipt ki jagah milestone/service acceptance ho sakti hai.

PO quantity/price/receipt tolerance policy explicit ho. Partial receipts, rejected lots, landed costs, foreign exchange aur supplier returns original transaction chain se linked hon. Three-way match PO/receipt/invoice differences ko exception queue mein rakhe. Duplicate supplier invoice number legal entity/supplier scope mein detect ho. Employee/apparent supplier bank change se immediate unreviewed payment na nikle.

## 5. Inventory aur warehouses

Receipts, issues, transfers, reservations, picking, packing, delivery, cycle count aur stock adjustment event-based audit ke saath. Multi-bin locations, zones, batch/serial, FEFO/FIFO picking recommendation, quarantine, consignment, in-transit aur damaged stock explicitly represented hon. Valuation aur picking rule alag hain; FEFO ka matlab valuation FEFO hona nahi.

Negative stock policy per item/warehouse controlled ho; serial/batch consistency aur financial invariants bypass na hon. Blind counts aur recount thresholds unauthorized shrinkage adjustment rokein. Backdated changes open-period policy, recosting impact aur locked-period exceptions ke saath hon. Stock reconciliation physical aur financial quantity/valuation dono check kare.

Manufacturing aur POS same stock ledger use karein. Cached inventory mobile view final reservation authority nahi. Offline users promised availability ki freshness dekhein.

## 6. Order-to-cash aur collections

Approved order -> picking -> delivery proof -> invoice -> country validation/submission -> receivable -> collection -> settlement -> bank match. Contract ke mutabiq advance, milestone, delivery-based ya invoice-based recognition differ kar sakti hai. Invoice banne aur authority acceptance ke statuses dono visible hon.

Customer receipt multiple invoices ko allocate ho sakta hai; overpayment unapplied credit rahe. Credit note stock return se alag ho sakta hai. Cash refund, store credit aur bank reversal independently controlled hon. Returns serial/batch verification aur original price/tax references preserve karein. Discount aur write-off approver ke baghair receivable silently clear na karein.

## 7. Finance aur accounting

Double-entry ledger posting balanced ho, source document immutable reference rakhe, transaction aur base currencies preserve kare aur Decimal precision use kare. Tax rule version, exchange-rate source/date, rounding adjustment aur accounting date stored hon. Posted entries edit/delete ke bajaaye reversal/amendment policy use karein. Opening balances implementation accountant signoff ke saath.

Core: chart of accounts; AR/AP; cash/bank; expense claims; journals; accrual/prepayment; fixed assets/depreciation; inventory valuation; cost centers/projects; budgets/commitments; cash flow; P&L; balance sheet; trial balance; general ledger; ageing; reconciliation; period/year close.

Advanced pack: revenue schedules, leases, multi-book reporting, consolidation, deferred tax inputs aur complex instruments. In capabilities ko har entry plan ki implicit inclusion na samjhein. Accounting framework entity-specific hoga. IFRS for SMEs 2025 edition 1 January 2027 se beginning periods ke liye effective hai; jurisdiction adoption aur entity eligibility separately check hogi. Standard ka version upgrade schema/recognition policy aur regression fixtures maangega. [IFRS source](https://www.ifrs.org/issued-standards/ifrs-for-smes/).

Close checklist: bank/AR/AP/stock reconciliation -> depreciation/accruals -> tax check -> adjustments -> approver -> period lock -> report snapshot. Reopen role aur reason mandatory. Prior-period correction policy accountant own kare.

## 8. Tax aur statutory outputs

Country pack taxability, tax point, registrations, place-of-supply inputs, exemptions, withholding, reverse-charge/import treatment, return mapping aur submission integration define kare. VAT/GST calculation aur income-tax filing alag scope hain. Business invoices ke tax aur Operqon subscription ke tax bhi alag books hain.

Rate ya threshold app code mein global constant nahi. Effective-dated rules, approved configuration, line/document rounding, inclusive/exclusive prices, partial refund aur foreign-currency reporting fixtures hon. Country adapter ko merchant credentials aur entity identity se bind karein. Authority response aur correction reference archive hon. Tax IDs reports/logs mein least exposure ke saath.

## 9. POS aur omnichannel

Store/device/cashier session open -> float -> scan/search -> modifiers/batch/serial -> promotion -> tender -> fiscal invoice/receipt -> stock -> close -> counted cash -> variance approval. Park/resume, suspended order, split tender, exchange, no-sale drawer opening aur void reasons audit hon.

Ecommerce/marketplace channels inventory availability, orders, payment references, returns aur fulfillment ko reconcile karein. Provider retry duplicate sale na banaye. Customer marketing opt-in purchase processing se independent consent hai. Gift card/liability, loyalty balance aur promotional voucher different instruments hain. Offline fiscal issuance har country ke allowed model se gated hogi; universal offline invoice promise nahi.

## 10. Manufacturing, maintenance aur quality

BOM/routing version -> demand/MRP -> material availability -> work order -> issue/transfer to WIP -> operation time/scrap -> quality -> finished goods -> costing/variance -> traceability. Make-to-stock, make-to-order aur subcontracting policies separate. Yield/byproduct/rework actual events record hon; backflush configuration se aur exception review ke saath.

Maintenance equipment hierarchy, preventive schedule, meter-based trigger, downtime, spares aur work permits support kare. Quality incoming/in-process/final sampling, test specification revision, nonconformance, CAPA aur release authority define kare. Measurement/calibration traceability industry extension hoga.

## 11. Projects aur services

Service enquiry -> scope/contract -> estimate -> resource plan -> task/dispatch -> timesheet/materials -> customer acceptance -> milestone/T&M invoice -> warranty/AMC renewal. Technician mobile job packet mein approved instructions, equipment, parts, checklist aur offline freshness ho. Signature signer identity/context ke saath; signature image alone universal legal acceptance nahi.

AMC usage entitlements, covered assets, visit count, response SLA, excluded spares aur renewal date version hon. Unauthorized scope change separate change order maange. Employee utilization aur customer billable utilization alag KPIs hon.

## 12. HR aur workforce

Employee lifecycle, organization/position, hiring/onboarding, attendance, shifts, leave, travel/expenses, performance aur offboarding core workforce pack. Payroll country-specific employment law, statutory deductions, payslips, bank file aur employer reporting ka separate release hai. Generic salary calculation ko compliant payroll label nahi.

Biometric/location capture optional documented purpose aur retention ke saath. Manager ko full sensitive employee file access default nahi. Leaver account/session, devices, assets, approvals delegation aur payroll settlement coordinated checklist use kare.

## 13. Customer service aur collaboration

Ticket/email/chat intake -> account/order/asset linking -> triage -> assigned SLA -> investigation -> fix/return/dispatch -> resolution -> customer confirmation -> knowledge article. Internal notes aur customer-visible replies separate hon. Refund authorization support agent role se infer nahi.

Documents versioned, full-text indexed only where authorized, signed-download access, malware scanning aur retention policy ke saath. Mentions/tasks/notifications business document link preserve karein. Email/WhatsApp/SMS send ke liye channel configuration, opt-in and template policy lage; AI draft automatic external communication ka unrestricted authorization nahi.

## 14. Reports aur BI

Role home page actionable exceptions dikhaye: overdue orders, stock-outs, expiry, rejected fiscal documents, cash variance aur failed jobs. KPI ka definition, period, timezone, currency, filters aur data-freshness timestamp visible ho. Sales booked, invoiced, delivered aur collected distinct metrics hon.

Saved views user/team/company scope mein. Exports background job ho sakte hain; output current permission snapshot, expiry aur audit ke saath. BI replica row/tenant/company filtering ka same policy enforce kare. Consolidation deliberate entity mapping se; all-tenant support dashboard business data lake ka implicit access nahi.

## 15. Imports, migration aur portability

Import wizard template/version -> upload -> malware/size checks -> map -> dry run -> row-wise validation -> totals/reconciliation -> approve -> idempotent execution -> exception file -> audit. Invalid row silent drop nahi. Chunk retries duplicate balances, stock, payments ya students/customer records na banayein.

Migration scope includes master data, opening trial balance, AR/AP by invoice, stock by warehouse/lot/serial, asset balances, open orders aur historical attachments where contracted. Cutover freeze, source backup, dry-run comparison aur rollback boundary defined ho. Posted fiscal history ko fabricated reference ke saath recreate na karein.

Customer exit export machine-readable CSV/JSON, attachments manifest, document references aur tax evidence ke saath ho. Subscription cancellation legal retention ya tenant data ownership remove nahi karti; access/export/retention procedure separately contracted ho.

## 16. Shared document contract

Har document type ke liye yeh fields applicable scope ke mutabiq explicitly map hon:

| Field group | Required definition |
| --- | --- |
| Identity | Stable UUID, human reference/series, source system ID, external idempotency key |
| Scope | Tenant, legal entity, branch, location, owner/team, confidentiality |
| Version | Schema version, record version/ETag, pack/config revision |
| Dates | Created/updated UTC, business timezone, accounting/tax/due dates |
| Money | Currency, exchange rate provenance, amount precision, rounding policy |
| Workflow | Current state, transition history, assigned actor, approval evidence |
| Lines | Item/service, UOM, quantity, price, discount, classification, tax breakdown |
| Relationships | Original/amended/returned documents, stock/GL/fiscal references |
| Evidence | Attachments, external responses, hashes, actor/reason, retention class |
| Operations | Correlation ID, job ID, retry state, failure category, recovery next action |

## 17. Cross-domain acceptance scenarios

Neeche numbers synthetic test fixtures hain; kisi country ke actual tax rate ya mandated accounting treatment ka claim nahi.

| Scenario | Setup/action | Expected result |
| --- | --- | --- |
| ACC-01 cash sale | 10 units @100, synthetic tax 10%, all received | Net1000 +tax100 =1100; single balanced posting; stock -10; tender1100 |
| ACC-02 partial return | ACC-01 mein 2 units accepted return | Original rule version se net200/tax20 linked credit; stock+2 only once; refund/credit220 policy-based |
| ACC-03 duplicate webhook | Same signed event 3 retries | Aik receipt/allocation, audit duplicate, no duplicate tenant provisioning |
| ACC-04 serialized unit race | Do cashiers same VIN/serial sell karein | Sirf aik final reservation/sale; doosre ko actionable conflict |
| ACC-05 batch expiry | Expired pharmacy batch scan | Authorized legal policy ke mutabiq sale blocked; quarantine/return action; audit |
| ACC-06 credit control | Exposure limit cross; approval nahi | Order draft save ho sakta; controlled shipment/posting blocked |
| ACC-07 currency return | Rate changed after original foreign sale | Original document reference, configured refund/base-currency treatment; documented FX difference |
| ACC-08 tax service timeout | Invoice submission response lost | Pending/unknown visible; correlation reconciliation before retry; duplicate fiscal invoice nahi |
| ACC-09 recipe yield | Input100, finished90, byproduct5, waste5 | Quantity mass-balance, configured costing allocation, waste approval |
| ACC-10 empty crates | 10 delivered, 6 returned | Party-wise outstanding4; product sales aur refundable deposit separate balances |
| ACC-11 intercompany | Entity A sells B in another jurisdiction | Separate documents/ledgers/tax pack, elimination only reporting layer |
| ACC-12 period lock | Backdated adjustment into closed month | Denied or controlled reopen; immutable previous report and reason |
| ACC-13 tenant isolation | A session uses B invoice/file/search/report ID | Every route denies; no existence or object-store leakage |
| ACC-14 import restart | Half batch committed then worker stops | Resume ledger identifies rows; totals unchanged; no duplicate opening stock |
| ACC-15 plan downgrade | Usage above new quota | Clear remediation/grace; existing records preserved; approved policy enforced |
| ACC-16 deleted user | User removed with open approvals | Sessions revoked, tasks reassigned, historic audit identity retained |
| ACC-17 recall | Sold batch later recalled | Supplier-to-customer trace, quarantined balance, contact workflow, closure evidence |
| ACC-18 service change | Technician adds uncontracted spare | Draft change request; billing only approved scope, customer evidence attached |

## 18. Definition of a feature complete

Working screen + correct authorization + data contract + main/exception/cancellation path + posting/side effects + audit + reconciliation + localization + accessibility + observability + recovery + acceptance evidence. Dashboard card, stub endpoint, mocked integration ya written catalogue is definition ko satisfy nahi karta.
