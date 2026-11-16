# Operqon 200-use-case industry catalogue

6 November 2026. Yeh demand/discovery catalogue hai; 200 installed, complete ya certified packs ki list nahin. Har use case shared anchor engine se shuru hota hai. Distinct extension aur acceptance requirement us use case ka asli farq dikhate hain. Full machine-readable mapping `03-industry-catalogue.csv` mein hai.

IW1–IW5 relative industry sequencing hai. Country certification, privacy, accounting aur specialist readiness har wave par separate gates hain. `base_pack` reuse ka starting point hai; fit-gap mein additional engines/packs required ho sakte hain. Healthcare, finance, medicine, education, charitable funds aur regulated sectors qualified domain review ke baghair production claim na banen.

## Automotive dealership

Base: IP-02; risk: High; proposed wave: IW2. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-001 | New car franchise | OEM allocation and VIN reservations | Ek VIN ki do confirmed allocations reject hon |
| UC-002 | Used car dealership | Appraisal, ownership documents and reconditioning cost | Trade-in purchase aur resale margin reconcile hon |
| UC-003 | Vehicle consignment | Owner custody and commission settlement | Consignor liability customer sale se reconcile ho |
| UC-004 | Commercial truck dealer | Body configuration and payload specification | Approved chassis-body combination delivery checklist mein aaye |
| UC-005 | Bus and coach dealer | Seat/layout configuration and staged delivery | Final configuration signed delivery record se match ho |
| UC-006 | Auto parts wholesale | Vehicle fitment and OEM supersession | Unsupported fitment substitution approval mangay |
| UC-007 | Tyre distributor | Size/load rating and production-age tracking | Wrong rating sale warning policy apply ho |
| UC-008 | Automotive lubricants dealer | Grade/pack compatibility and batch control | Pack-to-litre conversion exact reconcile ho |
| UC-009 | Vehicle import brokerage | Shipment landed cost and customs documents | Landed cost each VIN par allocated total se match ho |
| UC-010 | Dealer service network | Franchise service history and OEM claims | Branch-specific access aur claim retry deduplicate hon |

## EV and mobility

Base: IP-01; risk: High; proposed wave: IW2. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-011 | EV bike showroom | Chassis-motor-battery pairing | Incompatible voltage battery handover block ho |
| UC-012 | Electric scooter fleet sales | Fleet batch handover and serial assignment | Fleet customer ko sirf own serials nazar aayen |
| UC-013 | Battery swap operator | Battery custody, subscription and deposits | Swap mein returned aur issued battery links preserve hon |
| UC-014 | Battery repair centre | Cell/module diagnosis and safe quarantine | Rejected battery repair se saleable stock na bane |
| UC-015 | EV charging installer | Site survey, installation and commissioning | Acceptance ke baghair installation complete na ho |
| UC-016 | EV charger reseller | Charger serial and warranty entitlement | Warranty start invoice/handover policy se derive ho |
| UC-017 | E-rickshaw assembler | Kit assembly and battery genealogy | Every finished chassis input kit se trace ho |
| UC-018 | Micromobility rental | Short booking, damage and return inspection | Overlapping confirmed asset booking reject ho |
| UC-019 | EV battery leasing | Asset ownership and usage billing | Customer deposit revenue mein auto-post na ho |
| UC-020 | EV fleet service | Periodic battery/vehicle maintenance | Due service fleet serial cohort ke mutabiq schedule ho |

## Bakery and food retail

Base: IP-04; risk: High; proposed wave: IW3. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-021 | Retail bakery | Daily bake, batch expiry and closing waste | Expired display batch POS se block ho |
| UC-022 | Bakery commissary | Central production and outlet transfer | In-transit shortage outlet reconciliation mein aaye |
| UC-023 | Custom cake studio | Design approvals, deposits and production slots | Unapproved design version production ko na jaye |
| UC-024 | Bread wholesaler | Delivery routes and unsold returns | Returned bread quality decision ke baghair restock na ho |
| UC-025 | Frozen bakery supplier | Frozen lots and cold-chain exceptions | Temperature-excursion lot quarantine ho |
| UC-026 | Confectionery shop | Assorted boxes and allergen labels | Assortment constituent traceability retain ho |
| UC-027 | Dessert kitchen | Recipe yield and chilled shelf life | Actual output recipe yield variance report kare |
| UC-028 | Sandwich commissary | Daily ingredient lots and short shelf life | Recall affected finished sandwiches identify kare |
| UC-029 | Meat retail and butchery | Cut yield and variable-weight sale | Input carcass aur cuts/scrap weight balance ho |
| UC-030 | Fresh produce retail | Grade, shrink and variable weight | Scale weight aur billed UOM reconcile hon |

## Restaurant and hospitality food

Base: IP-06; risk: High; proposed wave: IW3. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-031 | Dine-in restaurant | Tables, courses and split bills | Split bills original amount se exact match hon |
| UC-032 | Quick-service restaurant | Combo modifiers and rapid kitchen queue | Unavailable component combo order block kare |
| UC-033 | Cafe chain | Drink modifiers and branch recipes | Recipe version branch effective date follow kare |
| UC-034 | Cloud kitchen | Brand/channel menus and aggregator orders | Webhook repeat ek hi order create kare |
| UC-035 | Food truck | Limited stock and intermittent connectivity | Offline sold stock sync par reconcile ho |
| UC-036 | Catering company | Event covers, deposit and dispatch kit | Event leftovers aur rental returns reconcile hon |
| UC-037 | Institutional canteen | Meal entitlement and employee subsidy | Same entitlement double redeem na ho |
| UC-038 | Meal subscription kitchen | Calendar pauses and dietary preferences | Paused date ko meal dispatch na bane |
| UC-039 | Hotel restaurant outlet | Room charge interface and outlet settlement | Failed room-charge retry duplicate posting na kare |
| UC-040 | Banquet operation | Venue slot, package and event billing | Overlapping confirmed hall booking block ho |

## Beverages distribution

Base: IP-07; risk: High; proposed wave: IW2. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-041 | Carbonated drink distributor | Bottles, crates and deposits | Outlet-wise bottle balance route total se mile |
| UC-042 | Bottled water distributor | Container returns and recurring routes | Returned jar condition custody ledger mein aaye |
| UC-043 | Juice distributor | Batch freshness and channel shelf-life minimum | Insufficient remaining shelf life pick block ho |
| UC-044 | Dairy drinks distributor | Chilled delivery and excursion quarantine | Excursion case approved release tak blocked rahe |
| UC-045 | Energy drink distributor | Channel promotions and principal rebates | Free goods return original scheme policy follow kare |
| UC-046 | Tea wholesale | Grade/pack conversion and principal prices | Approved grade price customer channel se resolve ho |
| UC-047 | Coffee wholesale | Roast batch and equipment placement | Placed machine customer custody mein trace ho |
| UC-048 | Fountain syrup supplier | Bag-in-box packs and dispenser service | Syrup UOM aur dispenser service separately bill hon |
| UC-049 | Returnable glass beverage network | Container pool and breakage claims | Foreign-brand empties automatic refund na banen |
| UC-050 | Beverage van sales | Load-sale-return-cash route closing | Unexplained cash/stock variance route close na kare |

## FMCG and general distribution

Base: IP-08; risk: Medium; proposed wave: IW2. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-051 | Multi-principal FMCG distributor | Principal-specific claims and schemes | Claim principal ledger sahi counterparty se link ho |
| UC-052 | Household cleaning distributor | Pack variants and trade promotions | Case-to-piece promotion rounding exact ho |
| UC-053 | Personal care distributor | Expiry, assortment and retailer targets | Expiry lot channel eligibility enforce ho |
| UC-054 | Baby care distributor | Size assortment and outlet replenishment | Replacement size customer approval ke saath ho |
| UC-055 | Pet food distributor | Batch expiry and channel allocation | Recalled batch all routes par blocked ho |
| UC-056 | Stationery distributor | School-season bundles and institutional credit | Bundle constituent stock correctly consume ho |
| UC-057 | Packaging materials distributor | Dimensions, roll UOM and customer specs | Roll-to-length conversion approved precision rakhe |
| UC-058 | Electrical goods wholesaler | Brand/part equivalence and dealer credit | Unapproved equivalent automatic substitute na ho |
| UC-059 | Building materials distributor | Bulk UOM and delivered freight | Dispatch quantity weighbridge/source se reconcile ho |
| UC-060 | Cash-and-carry wholesaler | Tiered quantity pricing and counter collection | Quantity threshold price reproducible ho |

## Pharmacy and medical supply

Base: IP-05; risk: Very high; proposed wave: IW4. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-061 | Community pharmacy | Prescription, expiry and pharmacist release | Restricted item unapproved cashier release na kare |
| UC-062 | Pharmacy chain | Branch transfers and patient-data boundaries | Patient record cross-branch access policy enforce ho |
| UC-063 | Medicine wholesaler | Batch provenance and licensed-customer eligibility | Blocked customer order dispatch na ho |
| UC-064 | Hospital pharmacy | Ward issues and patient-linked dispensing | Authorized ward issue audit retain ho |
| UC-065 | Cold-chain medicine distributor | Temperature evidence and quarantine | Excursion lot release expert approval mangay |
| UC-066 | Medical devices distributor | UDI/serial and installed asset warranty | Serial recall recipient list trace ho |
| UC-067 | Surgical consumables distributor | Sterile lot and expiry control | Damaged sterile pack saleable return na ho |
| UC-068 | Veterinary pharmacy | Species-specific catalogue and prescriber rules | Configured restricted category authorized approval mangay |
| UC-069 | Compounding pharmacy | Formula, ingredient genealogy and pharmacist review | Released compound approved formula version rakhe |
| UC-070 | Home medical equipment provider | Rental, consumables and service visits | Rental asset ownership sale invoice se na badle |

## Discrete manufacturing

Base: IP-09; risk: High; proposed wave: IW3. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-071 | Metal fabrication | Drawing revision and job routing | Released job drawing revision immutable ho |
| UC-072 | Machine assembly | Multi-level BOM and finished serial | Finished machine all component serials trace kare |
| UC-073 | Electrical panel manufacturing | Circuit BOM and FAT checklist | Failed FAT final dispatch block kare |
| UC-074 | Furniture manufacturing | Cut lists, upholstery variants and job cost | Approved fabric variant production order se match ho |
| UC-075 | Apparel manufacturing | Size-colour matrix and cutting yield | Cut input output/remnant balance reconcile ho |
| UC-076 | Footwear manufacturing | Size pairs and component BOM | Unpaired output finished sale stock na bane |
| UC-077 | Electronics assembly | Component lots and test results | Failed test unit quarantine ho |
| UC-078 | Plastic injection moulding | Mould cycle, cavity and regrind | Regrind approved recipe limit exceed na kare |
| UC-079 | Packaging carton manufacturing | Die, artwork and sheet yield | Artwork approval ke baghair production release na ho |
| UC-080 | Jewellery workshop | Metal purity, weight and customer-owned material | Fine-metal weight custody ledger se reconcile ho |

## Process manufacturing

Base: IP-10; risk: High; proposed wave: IW3. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-081 | Food sauce manufacturing | Formula batches, pH tests and packaging runs | QA-held bulk lot pack/ship na ho |
| UC-082 | Spice blending | Ingredient lots and allergen cross-contact | Blend all input lots se trace ho |
| UC-083 | Dairy processing | Milk solids, yield and chilled batches | Mass balance tolerance exception raise kare |
| UC-084 | Beverage bottling | Syrup/water formulation and filling loss | Bulk-to-bottle output/variance reconcile ho |
| UC-085 | Edible oil packing | Bulk tank receipt and packaging yield | Tank issue and packed litres reconcile hon |
| UC-086 | Cosmetics manufacturing | Formula revision and batch quality | Unapproved formula change release na ho |
| UC-087 | Detergent manufacturing | Concentration and variable batch size | Scaled ingredients approved precision follow karen |
| UC-088 | Paint manufacturing | Colour formula and tint adjustments | Adjustment retained batch cost/genealogy preserve kare |
| UC-089 | Chemical blending | Hazard classifications and COA | COA approval ke baghair restricted dispatch na ho |
| UC-090 | Pharmaceutical manufacturing | Validated batch record and release controls | Qualified-person/local gate ke baghair production-ready label na mile |

## Technical services

Base: IP-11; risk: High; proposed wave: IW1. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-091 | Instrumentation calibration | Reference standard, results and certificate revision | Expired reference instrument job release block kare |
| UC-092 | Industrial automation integrator | PLC project, commissioning and acceptance | Unaccepted commissioning milestone bill policy follow kare |
| UC-093 | HVAC service | Installed asset and preventive maintenance | Missed visit exception owner ko assign ho |
| UC-094 | Fire safety maintenance | Asset inspections and defect closure | Critical defect unapproved close na ho |
| UC-095 | Elevator maintenance | Unit history and periodic service | Out-of-service asset alert workflow preserve ho |
| UC-096 | Solar installation and AMC | Site design, commissioning and generation evidence | Approved design installed equipment se reconcile ho |
| UC-097 | Water treatment service | Plant asset, consumables and lab readings | Out-of-range result escalation create kare |
| UC-098 | Generator service | Runtime meter and parts consumption | Meter rollback exception flag ho |
| UC-099 | IT managed service provider | Contracts, tickets and service entitlement | Unauthorized customer asset access reject ho |
| UC-100 | Appliance repair network | Pickup serial, estimate and repair warranty | Customer-owned device inventory sale stock na bane |

## Professional services

Base: IP-12; risk: Medium; proposed wave: IW1. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-101 | Management consultancy | SOW, milestones and approved timesheets | Unapproved hours invoice mein na aayen |
| UC-102 | Engineering consultancy | Deliverable revisions and design review | Superseded drawing delivery clearly mark ho |
| UC-103 | Accounting practice | Engagements, client periods and workpapers | Client A workpaper client B se inaccessible ho |
| UC-104 | Legal practice | Matter budgets and restricted document access | Confidential matter role check server par enforce ho |
| UC-105 | Marketing agency | Retainers, campaigns and reimbursable spend | Retainer drawdown amount reconcile ho |
| UC-106 | Software development agency | Sprints, change requests and project billing | Out-of-scope work approval evidence rakhe |
| UC-107 | Recruitment agency | Vacancies, placements and guarantee claims | Replacement guarantee duplicate fee na banaye |
| UC-108 | Training company | Sessions, attendance and trainer costs | Cancelled session revenue policy correct ho |
| UC-109 | Architectural studio | Design stages and client acceptance | Stage invoice accepted deliverable se linked ho |
| UC-110 | Translation agency | Word counts, language pair and freelancer cost | Approved word-count version billing derive kare |

## Retail chains

Base: IP-13; risk: Medium; proposed wave: IW1. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-111 | Grocery store | Expiry, scales and high-volume POS | Weighted barcode quantity correct decode ho |
| UC-112 | Fashion retail | Size-colour variants and exchanges | Exchange stock and price difference reconcile ho |
| UC-113 | Electronics retail | Serial warranty and bundles | Serial sale customer warranty se link ho |
| UC-114 | Mobile phone retail | IMEI tracking and trade-ins | Duplicate active IMEI sale reject ho |
| UC-115 | Hardware retail | Piece/box/length UOM and contractor credit | Fractional length stock precision retain ho |
| UC-116 | Bookshop | ISBN, editions and publisher returns | Edition-specific return stock correct ho |
| UC-117 | Beauty and cosmetics retail | Shade variants and hygiene return policy | Opened-return stock saleable na ho |
| UC-118 | Sports goods retail | Size assortment and equipment serials | Variant reservation exact SKU consume kare |
| UC-119 | Optical store | Prescription order and lens workshop | Prescription data cashier export se protected ho |
| UC-120 | Gift and toy retail | Kits, seasonal promotions and gift cards | Gift-card liability redemption se reconcile ho |

## Rental and hire

Base: IP-14; risk: High; proposed wave: IW3. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-121 | Construction equipment hire | Meter hours, breakdown and site delivery | Off-hire date billing stop policy follow kare |
| UC-122 | Vehicle rental | Booking, inspection and fuel adjustment | Pre/post condition evidence linked ho |
| UC-123 | Event equipment hire | Kit availability and missing returns | Kit component shortage final settlement mein aaye |
| UC-124 | Medical equipment rental | Sanitization, maintenance and patient delivery | Unsanitized returned unit available na ho |
| UC-125 | IT equipment rental | Serial custody and data-wipe checklist | Data-wipe incomplete device dispatch block ho |
| UC-126 | Tool hire | Short-duration booking and deposits | Late-return charge approved tariff use kare |
| UC-127 | Uniform and linen hire | Laundry cycles and loss ledger | Customer custody count stock se reconcile ho |
| UC-128 | Scaffolding hire | Component quantities and staged return | Partial return rental quantity correctly reduce kare |
| UC-129 | Storage unit rental | Unit allocation and recurring billing | Same unit overlapping confirmed contract reject ho |
| UC-130 | Portable cabin hire | Site dispatch, installation and return | Site commissioning and hire start linked hon |

## Construction and property projects

Base: IP-12; risk: High; proposed wave: IW4. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-131 | General contractor | BOQ, work certificates and retention | Certified quantity ceiling exceed na ho |
| UC-132 | MEP contractor | Material take-off and site progress | Issued material project budget se trace ho |
| UC-133 | Civil subcontractor | Measured work and variation orders | Unapproved variation certified bill mein na aaye |
| UC-134 | Interior fit-out company | Room/zone BOQ and snag closure | Unclosed critical snag handover block kare |
| UC-135 | Road works contractor | Chainage progress and equipment cost | Measured progress location evidence retain kare |
| UC-136 | Real estate developer | Unit booking and staged collections | Same unit dual confirmed sale reject ho |
| UC-137 | Facilities management company | Site SLA and multi-trade jobs | Job site entitlement sahi contract use kare |
| UC-138 | Property maintenance contractor | Tenant requests and landlord approvals | Expense approval payer mapping preserve ho |
| UC-139 | Landscaping contractor | Plant stock and recurring site work | Replacement plant job cost record kare |
| UC-140 | Specialist commissioning contractor | Test packs and system handover | Failed test closure authorized retest mangay |

## Logistics and warehousing

Base: IP-08; risk: High; proposed wave: IW4. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-141 | Third-party warehouse | Customer-owned stock and storage charges | Client stock ownership valuation se segregate ho |
| UC-142 | Cold storage warehouse | Temperature zones and pallet billing | Excursion stock quarantine owner ko visible ho |
| UC-143 | Freight forwarder | Shipment milestones and agent costs | House/master shipment charges reconcile hon |
| UC-144 | Courier operator | Parcel scans and cash-on-delivery | COD collected cash customer payable se reconcile ho |
| UC-145 | Trucking fleet | Trip cost, dispatch and driver advances | Trip advance settlement balance explicit ho |
| UC-146 | Last-mile delivery | Routes, failed attempts and proof of delivery | Duplicate POD webhook second delivery na banaye |
| UC-147 | Container depot | Container condition and detention dates | Gate-in/out chronology validated ho |
| UC-148 | Customs clearance agency | Declaration tasks and client disbursements | Client funds service revenue se separately track hon |
| UC-149 | Cross-dock operator | Inbound-to-outbound allocation | Unreceived quantity outbound available na ho |
| UC-150 | Spare-parts fulfilment hub | SLA pick/pack and serial dispatch | Scan mismatch shipment close block kare |

## Agriculture and primary supply

Base: IP-10; risk: High; proposed wave: IW5. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-151 | Crop farm | Season fields, inputs and harvest cost | Field input issues season cost se link hon |
| UC-152 | Seed processor | Germination tests and certified lots | Failed-quality lot commercial release na ho |
| UC-153 | Fertilizer distributor | Grade, lot and seasonal credit | Grade substitution approval required ho |
| UC-154 | Agrochemical distributor | Restricted products and license checks | Ineligible buyer sale block ho |
| UC-155 | Dairy farm | Animal cohort and milk collection | Milk volume quality and payment reconcile hon |
| UC-156 | Poultry operation | Flock feed, mortality and output | Flock input/output variance visible ho |
| UC-157 | Livestock trading | Animal identity, weight and health documents | Animal identity transfer audit retain ho |
| UC-158 | Fish processing | Catch lot, weight yield and cold chain | Processed output source catch se trace ho |
| UC-159 | Fruit packhouse | Grower intake, grade and pack-out | Grower settlement graded output se reconcile ho |
| UC-160 | Agricultural equipment dealer | Machine serial, seasonal service and spares | Warranty entitlement serial history se derive ho |

## Healthcare and education operations

Base: IP-12; risk: Very high; proposed wave: IW5. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-161 | Outpatient clinic operations | Appointments, billing and consent-bound records | Clinical data role boundary enforce ho |
| UC-162 | Diagnostic lab operations | Sample chain and result approval | Unapproved result customer portal par na jaye |
| UC-163 | Dental clinic operations | Treatment estimates and staged billing | Consent/version treatment estimate se linked ho |
| UC-164 | Physiotherapy practice | Session packages and appointment entitlement | Same session double redeem na ho |
| UC-165 | Private school operations | Admission, term fees and guardian accounts | Guardian sirf authorized child records dekhe |
| UC-166 | Vocational institute | Course batches, lab assets and assessments | Batch fee entitlement correctly apply ho |
| UC-167 | University continuing education | Course enrolments and sponsored billing | Sponsor/learner payer allocations reconcile hon |
| UC-168 | Coaching centre | Class scheduling and fee arrears | Cancelled class make-up entitlement preserve ho |
| UC-169 | Childcare centre | Attendance, pickup authorization and billing | Unauthorized pickup actor blocked/audited ho |
| UC-170 | Home care agency | Care visits, clinician roster and service billing | Clinician credential/assignment gate enforce ho |

## Digital commerce and subscriptions

Base: IP-13; risk: High; proposed wave: IW4. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-171 | Direct-to-consumer ecommerce | Web catalogue and distributed stock reservation | Duplicate checkout request one order create kare |
| UC-172 | Marketplace seller | Channel fees, returns and payout settlement | Gross order fees and net payout reconcile hon |
| UC-173 | B2B wholesale portal | Account-specific prices and credit approval | Anonymous user contracted price na dekhe |
| UC-174 | Subscription box merchant | Recurring assortment and skipped cycles | Paused cycle stock dispatch na kare |
| UC-175 | Digital goods seller | License entitlement and delivery evidence | Refund policy entitlement state update kare |
| UC-176 | SaaS subscription operator | Seats, metered usage and billing adjustments | Meter replay double usage charge na kare |
| UC-177 | Online course seller | Course access and refund entitlement | Refunded purchase access policy reflect kare |
| UC-178 | Membership association | Renewal, dues and member categories | Lapsed member entitlement policy apply ho |
| UC-179 | Equipment-as-a-service provider | Usage meter and minimum commitment | Counter reset billing exception raise kare |
| UC-180 | B2B procurement marketplace | Principal/agent order and settlement roles | Commission and supplier payable reconcile hon |

## Property and asset operations

Base: IP-14; risk: High; proposed wave: IW5. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-181 | Commercial property leasing | Unit leases, escalations and service charges | Escalation effective date contracted schedule follow kare |
| UC-182 | Residential property management | Rent, deposits and repair approvals | Tenant deposit liability per lease reconcile ho |
| UC-183 | Shopping mall management | Unit rent and turnover-linked charges | Reported sales basis audited charge se link ho |
| UC-184 | Coworking operator | Desk/room booking and memberships | Room reservation overlap reject ho |
| UC-185 | Parking operator | Permit allocation and recurring billing | One permit entitlement configured vehicle policy follow kare |
| UC-186 | Self-storage operator | Unit occupancy, access and overdue accounts | Occupied unit double allocate na ho |
| UC-187 | Asset management company | Fixed assets, custody and verification | Physical count exception custodian ko assign ho |
| UC-188 | Industrial estate management | Unit services and shared-utility allocation | Shared expense allocation totals equal source hon |
| UC-189 | HOA/community management | Owner dues and common-area spending | Owner statement approved ledger se reconcile ho |
| UC-190 | Serviced apartment operator | Stay booking, deposits and housekeeping | Dirty/unavailable unit check-in block kare |

## Nonprofit and community services

Base: IP-12; risk: High; proposed wave: IW5. Status: discovery.

| ID | Use case | Distinct extension | Acceptance requirement |
|---|---|---|---|
| UC-191 | Charitable foundation | Restricted grants and programme budgets | Restricted funds unrelated project par spend na hon |
| UC-192 | Relief distribution NGO | Beneficiary entitlements and stock kits | Same entitlement duplicate distribution reject ho |
| UC-193 | Donor-funded project office | Grant milestones and expenditure claims | Claim expense evidence fund restriction follow kare |
| UC-194 | Community welfare trust | Member assistance approvals and audit | Applicant apni payment approval khud na de |
| UC-195 | Religious institution administration | Donations, funds and facility expenses | Restricted donation purpose ledger retain ho |
| UC-196 | Sports club | Membership, facilities and event fees | Member facility entitlement schedule respect kare |
| UC-197 | Professional association | Dues, events and continuing education | Event certificate attendance evidence se issue ho |
| UC-198 | Arts and cultural organisation | Production budgets and ticket settlement | Ticket provider payout gross/fee reconcile ho |
| UC-199 | Research foundation | Grant cost centres and asset custody | Shared asset allocation approved basis use kare |
| UC-200 | Volunteer service network | Volunteer skills, shifts and programme costs | Sensitive beneficiary data minimum role ko mile |

