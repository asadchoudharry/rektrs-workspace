# Operqon priority industry workflows

6 November 2026. Tamam 14 anchor packs proposed product scope hain. In ka mukammal production implementation abhi is document se prove nahin hota. Accounting entries conceptual examples hain: actual ERPNext configuration, inventory valuation, principal/agent treatment, tax aur accountant signoff ke baad final mapping hogi. `Dr` debit aur `Cr` credit hai. Tax lines applicable country pack se aayengi.

## Sab packs par lagne wala operating contract

Har flow tenant/company/branch boundary, role permissions, document state, source reference, effective-date policy aur audit trail carry kare. Approval requester apna exceptional approval khud na de jahan segregation required ho. Cancellation dispatched goods ya settled payment ko erase na kare; return, reversal aur adjustment banaye. Supplier/customer portal ko sirf allowed records milen. Dashboard KPI ke denominator, timezone aur exclusion documented hon. Har pack ke liye sample dataset aur posted-ledger reconciliation release gate hai.

## IP-01 — EV bikes aur battery lifecycle

**Maqsad aur roles:** dealership owner, sales advisor, inventory custodian, technician, warranty reviewer, fleet customer aur accountant bike aur us ki battery ka poora lifecycle dekh saken. Bike chassis serial, motor serial, battery serial, charger, model variant, condition, ownership, installation/removal, warranty rule, service job, battery swap aur diagnostic observation entities hon. Battery state-of-health telemetry ko manufacturer ka authenticated observation samjha jaye; inferred warranty entitlement nahin.

**Mukammal flow:** lead/test ride → quotation/approved scheme → deposit → bike aur compatible battery reserve → incoming/PDI check → serial pair verify → final payment/approved finance confirmation → country-compliant invoice → signed handover → warranty activation → scheduled service. Battery replacement mein old serial remove, inspection/quarantine, replacement serial install aur claim link banayen. BMS/IoT adapter vendor-specific protocol ke saath optional ho; manual diagnostic upload available rahe.

**Exceptions:** duplicate chassis reject; wrong-voltage battery pairing block; recalled battery sell na ho; failed PDI bike ready-stock mein na jaye; finance approval pending ho to delivery hold; telemetry offline ho to unknown dikhaye. Battery lease/swap-as-a-service alag contract aur deposit accounting ke baghair activate na ho. Remote immobilization initial pack ka feature nahin; safety, consent aur vendor authority ke separate gate par evaluate ho.

**Postings aur automation:** advance Dr bank / Cr customer advances; sale par advance allocate, Dr AR/bank / Cr sales plus output tax, Dr COGS / Cr inventory. Warranty reserve sirf approved policy par; replacement stock expense/claim receivable mapping accountant approve kare. Automation PDI assignment, service reminder, recall matching aur low-stock proposal kare. AI diagnostic outcome final repair authorization na bane.

**KPIs/integrations:** lead-to-delivery, aged inventory, battery claims by cohort, repeat repairs, service turnaround; OEM catalogue/warranty API, approved payments, BMS optional.

**Acceptance:** one bike do customers ko reserve na ho; battery history install/remove ke baad traceable ho; return se correct serial aur tax credit link bane; unknown OEM response retry par second claim na banaye. Wave IW2.

## IP-02 — Car selling franchise aur multi-dealer operations

**Roles/entities:** franchise principal, branch manager, sales advisor, PDI supervisor, trade-in assessor, registration coordinator aur accountant; VIN, OEM allocation, variant/options, vehicle cost sheet, booking, customer advance, floorplan finance, registration task, accessory installation, OEM claim aur used-car appraisal.

**Flow:** OEM allocation/import shipment → VIN receive aur landed-cost allocation → showroom/demo/available status → customer booking → deposit → VIN allocation → finance/insurance/registration checklist → accessory job → PDI → final invoice aur settlement → vehicle handover → service/warranty referral. OEM allocation aur customer reservation ka versioned status ho; showroom display ko sale-ready na samjha jaye. Franchise branches ke stock transfers custody aur legal ownership dono record karen.

**Used-car/trade-in:** inspection, ownership-document check, lien/encumbrance confirmation task, approved valuation aur customer offer accept hon. Trade-in purchase aur new-car sale do linked transactions hon; simple net figure se purchase provenance na gayab ho. Consignment used car ke liye owner settlement aur commission model alag ho.

**Exceptions:** VIN mismatch, damaged transit receipt, customer cancellation, waiting-list reassignment, price-change after booking, unavailable registration documents, partial finance disbursement aur OEM claim rejection. Floorplan interest/maturity visible rahe; interest automatic post tab ho jab agreement and accountant mapping configured hon.

**Postings/automation:** inventory purchase/landed cost; customer advances liability; vehicle sale/COGS; accessories separate component revenue if required; OEM incentive accrual aur settlement distinct. Automation aging alerts, finance-expiry reminders, missing-document tasks aur delivery readiness checks.

**KPIs/integrations:** stock-days by VIN, gross margin including incentive, booking conversion, demo usage, finance aging; OEM feeds, insurer/lender and registration portals approved adapter or manual task evidence.

**Acceptance:** cancelled booking serial release audit ho; demo-to-sale condition/price approval required ho; trade-in totals GL aur owner settlement se reconcile hon; branch view permissions correct hon. Wave IW2.

## IP-03 — Motorcycles, spare parts aur workshop

**Roles/entities:** showroom sales, parts counter, technician, service advisor, warranty officer; chassis/engine serial pair, service booklet, job card, labour operation, spare compatibility, warranty claim aur workshop bay.

**Flow:** vehicle receive → chassis/engine check → PDI → booking → invoice/payment → handover → first-service due. Workshop customer complaint aur odometer capture kare, estimate approve karwaye, parts reserve kare, labour record kare, quality check ke baad vehicle release aur invoice kare. Warranty labour/parts aur customer-paid work ek job mein identifiable lines hon.

**Exceptions:** unverified engine replacement, counterfeit/unsupported parts, accident damage outside warranty, technician rework, no-show appointment, missing customer approval aur outsourced repair. Vehicle ki owner history privacy-bound ho; new owner ko previous customer ke private invoice details na dikhaye. Parts supersession original-to-replacement compatibility preserve kare.

**Postings:** vehicle aur spare sales/COGS; workshop labour revenue; customer-owned bike ko company inventory asset na banaye; warranty recovery receivable sirf approved recoverability policy par. Automation first-service reminders, parts reorder proposals, bay allocation aur unresolved approval alerts.

**KPIs/integrations:** labour utilization, first-time-fix, parts fill-rate, warranty recovery, service retention; OEM warranty and parts catalogue optional.

**Acceptance:** same chassis/engine illegal duplicate not created; estimate change approval tracked; part issue return/rework reconcile; mixed warranty/customer bill correct party ko jaye; service reminder consent honored. Wave IW2.

## IP-04 — Bakery, commissary aur outlets

**Roles/entities:** production planner, baker, quality officer, outlet manager, purchasing and accountant; recipe version, ingredient lot, allergen declaration, dough/bake batch, yield, shelf-life rule, outlet transfer, display stock, waste reason aur pre-order.

**Flow:** outlet/pre-order demand → daily bake plan → ingredient availability/expiry check → approved recipe scaling → ingredient issue/actual weigh → production timings and output → quality release → finished batch/expiry label → outlet dispatch → POS sale → closing count/waste → next-day planning. Recipe edit nayi effective version banaye; historical sale ki allergen/recipe provenance preserve ho.

**Exceptions:** substitute ingredient needs allergen review; under/over yield actual record ho; oven breakdown re-plan kare; late outlet return quality inspection ke baghair resale stock mein na aaye; unsold expiry block ho; donation aur waste distinct reason/policy rakhen. Rework only allowed recipe/quality policy par.

**Postings/automation:** Dr WIP / Cr raw ingredients; Dr finished goods and approved waste / Cr WIP; sale revenue/COGS; normal/abnormal loss treatment accountant map kare. Automation demand proposal, shift production queue, FEFO picks, expiry reminders aur variance alert. Forecast recommendation ko approved bake plan banne se pehle review mile.

**KPIs/integrations:** actual vs standard yield, waste %, sell-through by hour, ingredient price variance, on-time outlet dispatch; scale/label printer, POS and online pre-order adapters.

**Acceptance:** one flour lot se finished batches aur affected sales trace hon; recipe scaling UOM conversion correct ho; expired item cashier override policy enforced ho; production return duplicate posting na kare; outlet transfer in-transit shortage recorded ho. Wave IW3.

## IP-05 — Community pharmacy aur medical distribution

**Roles/entities:** licensed pharmacist, assistant cashier, procurement officer, compliance officer, store manager; medicine catalogue, generic/brand/strength/form, pack size, batch/serial/expiry, supplier license reference, prescription reference, dispensing record, controlled-item register, quarantine and recall case. Patient/prescriber data access minimum necessary ho.

**Flow:** approved supplier → purchase/receipt → authenticity/pack/expiry checks → temperature and quarantine where required → pharmacist release → FEFO stock → prescription validation where applicable → dispensing by approved pharmacist → compliant invoice → returns policy → recall reconciliation. OTC, prescription-only and controlled categories separate configurable legal classifications hon. Pack break/strip/unit dispensing exact UOM and traceability ke saath ho.

**Exceptions:** expired/recalled batch block, damaged seal, cold-chain excursion quarantine, prescription mismatch, unavailable medicine, suspect serialization, count discrepancy. Automatic therapeutic substitution ya dosage decision feature na ho. Substitute dispense sirf applicable professional/legal approval ke saath. Patient return stock automatically saleable na ho. Country-specific controlled-drug records aur medicine traceability integration separate legal review gates hain.

**Postings/automation:** purchase/inventory, sale/COGS, insurer receivable where contracted, expiry impairment/write-off approved; tax category country medicine classification se. Expiry/recall alerts deterministic; replenishment draft demand and shelf life consider kare. Sensitive data alerts mein medicine/patient details unnecessarily broadcast na hon.

**KPIs/integrations:** expiry loss, fill-rate, stockout duration, quarantined value, claim rejection; approved wholesaler feeds, medicine authority traceability and insurer clearing optional; GS1 parsing supports GTIN/lot/expiry/serial but certification independent [IND-S12].

**Acceptance:** recalled batch har channel par blocked; one incoming lot ke recipients authorized audit mein trace hon; cashier patient clinical record export na kar sake; partial pack quantity exact ho; controlled item approval/audit undeletable ho. IW4, specialist pilot and local regulatory signoff required.

## IP-06 — Restaurant, cafe aur cloud kitchen

**Roles/entities:** host, waiter, cashier, kitchen station, expeditor, delivery operator, outlet manager; floor/table, seat/order course, menu/modifier, recipe, ticket/station, allergen note, delivery order, tip, shift and cash drawer.

**Flow:** dine-in reservation/table ya takeaway/delivery → menu availability → order/modifiers → station tickets → preparation/ready → serve/dispatch → split/merge bill → payment/tip → fiscal document → shift reconciliation. Recipe/stock depletion policy choose ho: sale-time theoretical consumption ya kitchen actual; dono ek sale par double-consume na karen. Menu price/promotion channel aur effective date ke saath resolve ho.

**Exceptions:** item sold out, wrong modifier, allergen requirement not supported, ticket cancel after cooking, lost printer, duplicate aggregator webhook, mixed payment failure, table transfer, customer refund. Void before production aur after-production waste different approval/actions hon. Kitchen ko payment/patient/financial data zarurat se zyada na mile.

**Postings/automation:** food revenue and output tax; inventory/consumption/COGS policy; collected tips employee payable jahan applicable; aggregator fee/settlement deduction sales revenue se blindly net na kare. Automation station routing, delayed-ticket alerts, reserved-order reminders, replenishment suggestion aur cash variance escalation. External message consent and merchant channel credentials ke saath.

**KPIs/integrations:** ticket time, table turnover, average bill, theoretical vs actual food cost, waste, channel margin; KDS, receipt/kitchen printers, payment terminals, delivery aggregators and scales. Odoo KDS/POS product documentation flow benchmark hai [IND-S08–IND-S09].

**Acceptance:** bill split sum original se exact reconcile; webhook replay one order; card paid/cash failed state recover; offline queue visible; cancellation kitchen aur ledger dono reconcile; RTL kitchen display legible. Wave IW3.

## IP-07 — Beverages distribution, returnable bottles aur crates

**Roles/entities:** sales supervisor, route salesperson, loader, driver, warehouse officer, cashier; outlet, route/beat, visit, van stock, case/bottle UOM, bottle/crate type, container custody ledger, deposit agreement, cooler placement, price scheme, delivery and cash collection.

**Flow:** territory/route plan → outlet pre-orders or van-sale load → batch/expiry pick → stock handover to driver → delivery/count → empties collect → applicable deposit charge/refund → invoice/collection → undelivered stock return → route cash/stock/container reconciliation → claims approval. Company-owned returnable assets, customer deposits aur disposable packaging distinctly model hon.

**Exceptions:** broken/foreign-brand empties, outlet dispute, credit block, temperature excursion, short shipment, route diversion, truck breakdown and offline conflict. Driver ke geolocation collection ko consent/work policy ke saath minimize karein. One crate bottle conversion packaging master se aaye, free text se nahin. Missing bottles loss ho sakti hai, sale/deposit forfeiture nahin jab tak contract/policy allow na kare.

**Postings/automation:** beverage sale/COGS; customer deposit liability separate; approved deposit refund liability debit/bank credit; container asset/custody movement ka valuation policy separately mapped; driver cash clearing and shortage approval. Automation replenishment, visit reminders, expiring-stock priority, collection-due and route-close exception report.

**KPIs/integrations:** drop size, strike rate, numeric distribution, bottle recovery, route cost, cooler utilization, outstanding container custody; mobile route app, GPS optional, barcode and cold-chain data, principal claim feeds.

**Acceptance:** bottles/crates ledger customer-wise route totals reconcile; same collection offline replay duplicate na bane; deposit tax applicability country policy use kare; damaged stock saleable return na ho; route cannot close unexplained stock/cash balance silently. Wave IW2.

## IP-08 — General FMCG distribution aur principal schemes

**Roles/entities:** distributor owner, principal account manager, sales rep/DSR, warehouse picker, collection officer; principal, territory, outlet/channel, beat, SKU/UOM, price agreement, free-goods scheme, target, claim, rebate, credit limit aur proof of delivery.

**Flow:** principal purchase → receipt/expiry control → channel price/scheme publish → planned outlet visit → order with credit and inventory check → allocation/pick/dispatch → delivery proof → invoice → collections → return/claim → principal rebate reconciliation. Pre-sale aur van-sale modes separately configured hon. Scheme priority exclusive/stackable rules ke saath deterministic ho.

**Exceptions:** overlapping offers, item substitution, short shelf-life rejection, customer above credit, returned promotional free quantity, cash mismatch, invoice disputed by outlet, principal price support not paid. Supervisor discount override audit ho. Claim accrual aur claim approval/settlement distinct states hon; projected rebate ko guaranteed profit na dikhaye.

**Postings/automation:** sales/COGS, customer AR, vendor credit/claim clearing per accounting policy; rebates/discounts approved contra-revenue/expense policy; sales return original invoice/scheme quantities ko reference kare. Automation credit holds, collection task, claim deadline alert, route visit queue and promotion simulation. Microsoft rebate docs benchmark calculation/review/posting separation dikhati hain [IND-S10].

**KPIs/integrations:** productive calls, coverage, fill-rate, overdue AR, scheme ROI, principal claim aging, stock freshness; principal EDI/API, mobile DSR, payment/bank import and distributor portal.

**Acceptance:** buy-10-get-1 return proportional policy correct; case-to-piece rounding exact; overlapping scheme reproducible; paid invoice adjustment settlement link preserve; concurrent credit orders limit ko bypass na karen. Wave IW2.

## IP-09 — Discrete manufacturing aur assembly

**Roles/entities:** planner, buyer, production supervisor, operator, QA, maintenance and costing accountant; engineering revision, multi-level BOM, routing, workstation, work order, job card, WIP, component serial, finished serial, inspection and nonconformance.

**Flow:** demand/forecast → MRP proposal → procurement/work order approval → materials reserve/issue → operations/job time → in-process QA → assembly serial genealogy → final QA → finished receipt → delivery → actual cost/variance review. ERPNext multi-level BOM and operation primitives base fit assessment ka starting point hain [IND-S03].

**Exceptions:** component shortage, alternate material approval, rework, scrap, machine downtime, subcontract operation, partial completion, BOM revision mid-order and late supplier receipt. Released work order recipe snapshot retain kare; newer BOM historical consumption change na kare. Customer-owned materials separately accounted/custodied hon.

**Postings/automation:** raw stock to WIP; labour/overhead allocation configured; WIP to FG; scrap/rework and variances to approved accounts; subcontract service and material reconciliation. Automation reorder/work-order suggestions, operation dispatch queue, QA hold and maintenance due. Auto-backflush only where actual capture policy and variance controls allow.

**KPIs/integrations:** schedule attainment, first-pass yield, WIP aging, utilization, material variance, OTIF; scanners, shopfloor terminals, machine events and CAD/PLM via controlled revision integration.

**Acceptance:** one component lot se all finished serials trace hon; rejected inspection dispatch block; partial order WIP reconcile; operation replay duplicate labour/stock issue na kare; BOM change approved revision preserve. Wave IW3.

## IP-10 — Process manufacturing, food aur beverages production

**Roles/entities:** formulation technologist, batch operator, lab/QA, planner, packaging supervisor; formula version, potency/concentration, production batch, intermediate, co/by-product, tank/vessel, test specification, shelf life, packaging run and certificate of analysis.

**Flow:** demand → formula/batch size choose → raw lot/QA check → measured charge → process observations → sample/test → release/rework/reject → bulk batch receipt → packaging consumption/output → finished lots → COA/dispatch → traceability reconciliation. Mass balance aur unit conversion density/temperature assumptions explicitly store karen; volume ko weight assume na karein.

**Exceptions:** out-of-spec result, potency adjustment, cleaning not complete, contamination concern, supplier recall, overfill/underfill, evaporation yield loss and recovered rework. Retest date aur expiry alag ho sakte hain; shelf life change expert approval aur affected-stock report ke baghair na ho.

**Postings/automation:** batch WIP cost, co-product/by-product allocation approved method, finished packaging cost, normal loss vs abnormal loss treatment; QA quarantine financial ownership se alag status. Automation raw expiry prioritization, cleaning checklist, sampling tasks and variance alerts. Recipe optimization AI proposal ho; approved formulation replace na kare.

**KPIs/integrations:** batch yield, quality pass rate, conversion loss, giveaway, changeover time, recall coverage; scales, lab/LIMS, tank readings and label printers. GS1 transformation-event framing provenance model ko guide karta hai [IND-S11].

**Acceptance:** input/output/rework mass balance tolerance validated; QA-held batch cannot pack/ship except approved scope; co-product cost total equals allocable cost; packaging recall back to ingredient lot trace ho. Wave IW3, regulated variants IW4.

## IP-11 — Technical services, AMC aur field maintenance

**Roles/entities:** service coordinator, dispatcher, technician, QA reviewer, contract owner; installed asset, serial, service location, SLA, AMC entitlement, preventive schedule, work order, visit, checklist, calibration result, certificate, spare issue and customer signoff.

**Flow:** contract/asset onboarding → entitlement/SLA check → scheduled or breakdown request → assign skills and access requirements → quote approval if chargeable → visit/measure/repair → spare/labour record → QA/certificate approval → customer signoff → invoice or AMC consumption → next due date. ERPNext warranty and maintenance primitives documented hain [IND-S04–IND-S05]; specialized accreditation/certificate control is additional scope.

**Exceptions:** site access denied, asset serial mismatch, missing calibrated reference instrument, parts unavailable, service outside AMC, repeat failure, overdue certificate review and customer rejects result. Failed calibration certificate ko successful result mein overwrite na kare; amended document original reference aur reason preserve kare. Accreditation claim sirf actual organizational scope/evidence ke saath.

**Postings/automation:** service revenue, parts consumption/COGS, contract deferred revenue/recognition per policy, travel and subcontract costs to job; unbilled work visible. Automation due visits, certificate expiry, SLA escalation, route proposals and parts replenishment. Technician offline evidence sync immutable originals retain kare.

**KPIs/integrations:** response/resolve SLA, first-time-fix, technician utilization, contract margin, overdue visits, certificate turnaround; maps optional, instrument-file import, customer portal, signature and notification adapters.

**Acceptance:** technician unapproved certificate release na kare; one asset visit history complete; out-of-contract work separate authorization; midnight/timezone SLA correct; repeated sync duplicate spare consumption na kare. Wave IW1.

## IP-12 — Professional services, projects aur consulting

**Roles/entities:** partner, project manager, consultant, resource planner, finance; proposal, statement of work, milestone, task, resource allocation, timesheet, expense, change request, deliverable acceptance, retainer and billing rule.

**Flow:** opportunity → scoped estimate → contract → baseline project/budget → resource allocation → work/time/expense → manager/customer approval → milestone or time-material billing → payment → margin/closure. Retainer, capped T&M and fixed-price projects separate billing policies hon. ERPNext project/timesheet capability foundation evidence hai [IND-S06–IND-S07].

**Exceptions:** scope change, disputed hours, missed milestone, overrun, unapproved expense, overlapping time entry, subcontractor timesheet, client acceptance delayed and multi-currency contract. Employee cost rates restricted hon. Revenue recognition invoice creation ke barabar automatically assume na karein.

**Postings/automation:** time/expenses job costing; invoice AR/service revenue or contract liability policy; reimbursables, withholding and FX per country/accounting policy. Automation timesheet reminders, budget burn alerts, missing approval tasks, invoice draft and resource conflict warnings. AI project summary source records cite kare aur client-confidential cross-tenant material access na kare.

**KPIs/integrations:** utilization with available-hours denominator, realization, billable leakage, project margin, DSO, forecast completion; calendar/task tools and approved expense capture.

**Acceptance:** same time interval billed twice na ho; rate effective date changes historical approved entry na badlen; project ceiling creates approval hold; retainer drawdowns reconcile; customer portal only own deliverables/time approvals dekh sake. Wave IW1.

## IP-13 — Omnichannel retail aur branch chains

**Roles/entities:** cashier, store manager, merchandiser, warehouse staff, ecommerce operator; variant/SKU, barcode, assortment, location stock, promotion, loyalty ledger, gift card, web order, reservation, pickup and return authorization.

**Flow:** procurement/receipt → assortment/pricing publish → POS/web order → reserve → pick/ship or click-collect → payment capture → invoice → cross-channel returns → shift/settlement reconciliation. Available-to-promise global sum ke saath location commitments consider kare. Loyalty points aur gift-card liability programs separate hon.

**Exceptions:** duplicate marketplace order, failed capture after reservation, partial shipment, gift-card fraud, wrong-store return, promotion refund, lost device and offline oversell. Card data tokenized payment provider par rahe. Unknown external payment result manual reconciliation queue mein aaye.

**Postings/automation:** sale/COGS, payment clearing, gift-card liability, loyalty accrual per policy, marketplace fee and payout reconciliation; intercompany branch transfers only legal structure match par. Automation low-stock transfer proposal, abandoned reservation release, price publish validation and mismatch alerts.

**KPIs/integrations:** conversion, inventory accuracy, sell-through, basket size, return rate, channel contribution margin; ecommerce, marketplaces, terminals, scanners, printers, labels and courier services.

**Acceptance:** last item concurrent web/POS sale oversell policy enforce; gift-card refund original obligation reconcile; price list effective time consistent; cross-branch return tax/stock/settlement correct; offline receipt and sync status user-visible. Wave IW1 base, advanced channels IW2.

## IP-14 — Equipment rental, leasing aur hire operations

**Roles/entities:** rental desk, fleet controller, maintenance, delivery crew, contract manager and accountant; serialized asset, availability calendar, rate/period rule, reservation, hire contract, security deposit, dispatch inspection, usage meter, extension, return inspection and damage claim.

**Flow:** request dates → availability and maintenance check → quote/contract → deposit/payment → asset reserve → condition evidence/handover → periodic charge/usage → approved extension → return inspection → damage/late charge approval → deposit settlement → service/quarantine → available. Owned rental assets, leased-in assets and sale inventory differently classified hon.

**Exceptions:** overlapping booking, early return, asset breakdown, replacement asset, lost equipment, disputed damage, unavailable substitute and open-ended hire. Fair-use limits, calendar-day vs 24-hour billing and grace periods explicit contract data hon. Deposit refund pending final inspection ko customer clearly dekhe.

**Postings/automation:** rental asset capitalization/depreciation, rental revenue or deferred billing policy, deposit liability, repair cost and approved damage recovery; complex finance leases separate accounting specialist gate par. Automation return reminder, maintenance hold, extension conflict warning and invoice draft.

**KPIs/integrations:** time/financial utilization, turnaround, downtime, damage recovery, overdue returns; GPS/telematics optional and customer consent-bound, e-signature and delivery proof.

**Acceptance:** same asset overlapping confirmed rentals reject; maintenance-blocked unit dispatch na ho; replacement asset single contract history preserve; deposit refund exact reconciliation; billing-period boundaries timezones/DST par tested. IW3.

## Industry-level acceptance fixture pack

Har anchor ke liye minimum 30 reusable scenario fixtures banayen: 10 normal business examples, 8 exception/return examples, 4 role/privacy examples, 4 accounting/rounding examples, 2 concurrency/idempotency examples aur 2 upgrade/import examples. Yeh test-count target coverage guarantee nahin; material domain risks ke liye extra tests lagenge. Country matrix ke applicable scenarios multiply hon, lekin identical assertions bina matlab duplicate na kiye jayen.

Fixture mein inputs, expected documents/states, expected quantities, expected GL, expected authority-delivery state, permissions, notifications aur recovery action hon. Release evidence actual installed versions aur tested hardware list carry kare. IW4 regulated workflows mein qualified local expert ki named signoff aur documented limitations mandatory gate hon.

## Source boundary

IND-S01–IND-S12 ka full URL aur research status `sources.json` mein hai. Existing vendor features sirf research baseline hain. Upar ke entities, pack boundaries, automation, acceptance aur sequencing Operqon ke proposed design decisions hain. Kisi vendor ka feature Operqon mein installed ya certified hona infer na karein.
