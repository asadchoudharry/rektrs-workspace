# Operqon: country rollout aur researched regulatory matrix

Cut-off: 6 November 2026. Sabhi Operqon implementation states **proposed / not verified built** hain. `R` ka matlab official foundational research mila; `D` ka matlab discovery target, current legal obligations abhi validate karni hain. `R` production readiness, complete legal review ya certification ka label nahi.

## 1. Priority aur coverage

P0 = Pakistan aur Saudi ke paid pilot ke liye pehle. P1 = GCC aur selected MENA expansion. P2 = regional breadth. P3 = partner-led global expansion. Yeh sequence product recommendation hai, kanooni mandate nahi. Exact tax rates/thresholds release ke waqt signed rule catalog mein jayenge; neeche ke rows engineering scope hain.

| Country / jurisdiction | Priority | Research | Pack ka planned scope | Regulatory exchange / sab se aham discovery |
|---|---|---|---|---|
| Pakistan federal | P0 | R | PKR, NTN/STRN, goods tax, withholding, returns, audit | FBR digital invoice licensed integrator route; FBR IRIS filing ko alag capability [REG-01,02,03] |
| Pakistan Punjab | P0 | R limited | Service tax, restaurant classification, province mapping | PRA E-IMS notification/API aur current rate eligibility verify; old rule ko current full spec na samjhein [REG-04] |
| Pakistan Sindh | P1 | D | SRB service tax mappings | Provincial registration, POS/API access, return rules confirm |
| Pakistan Khyber Pakhtunkhwa | P1 | R limited | KP service tax | Restaurant IMRS/RIMS scope aur current official onboarding validate [REG-05] |
| Pakistan Balochistan / ICT | P1 | D | Service tax aur federal-territory split | Relevant authority aur taxable-service place-of-supply review |
| Saudi Arabia | P0 | R | SAR, Arabic invoice, VAT, notes, fiscal archives | ZATCA phase 1/2 taxpayer wave, standard clearance vs simplified reporting [REG-06,07] |
| United Arab Emirates | P1 | R | AED, VAT/CT mappings, Arabic/English documents | MoF/FTA Peppol 5-corner through accredited provider; amended deadlines [REG-08,09,10] |
| Oman | P1 | R | OMR precision, VAT, Arabic/English | Fawtara 5-corner; latest FAQ April/October 2027 eligibility states; conflicting older wording and legal confirmation pending [REG-11] |
| Bahrain | P1 | R limited | BHD precision, VAT, inclusive pricing | NBR tax rules; e-invoice mandate/API must be separately researched [REG-12] |
| Qatar | P1 | R limited | QAR, income/withholding/excise templates | GTA currently says VAT not applied; do not charge blanket GCC VAT [REG-13,14] |
| Kuwait | P1 | D | KWD precision, local accounting, tax profiles | Ministry of Finance current taxes/e-invoicing/mandates verify; no GCC-rate assumption |
| Egypt | P1 | R | EGP, Arabic, tax codes, B2B/B2C separation | ETA eInvoice + eReceipt separate APIs, document schemas, signatures and device registration [REG-15] |
| Jordan | P1 | R foundational | JOD precision, sales tax, Arabic | ISTD national e-invoicing / JoFotara linking and latest manuals [REG-16] |
| Morocco | P2 | R limited | MAD, French/Arabic, local chart/report mappings | TGR public invoice deposit verified; broader DGI B2B mandate and current specs separate discovery [REG-19] |
| Tunisia | P2 | R historical | TND precision, French/Arabic | Official historical VAT code gives e-invoice framework; 2026 expanded scope requires current law validation [REG-20] |
| Algeria | P2 | D | DZD, French/Arabic, accounting scheme | DGI invoicing, fiscal reports and possible sector systems validate |
| Lebanon | P2 | D | LBP + transaction/reporting currency policies | FX/tax point, invoice language and local reporting require accountant review |
| Iraq federal | P2 | D | IQD precision, Arabic, withholding | Federal vs Kurdistan scope and official tax mechanisms validate |
| Iraq Kurdistan | P2 | D | Region-specific entity and reporting | Distinct administration, permitted language/currency and filings review |
| Palestine | P2 | D | Local registrations and multi-currency | Authority access and jurisdiction/transaction mapping validate |
| Libya | P2 | D | LYD precision, Arabic and local reports | Tax/invoice/payment and transfer restrictions review |
| Mauritania | P2 | D | MRU, French/Arabic | Tax registrations, statutory invoice and returns review |
| Djibouti | P2 | D | DJF precision, French/Arabic | Tax and accounting requirements review |
| Sudan | P2 | D | SDG, Arabic | Tax, operating constraints, residency and payments review |
| Yemen | P2 | D | YER, Arabic | Operational jurisdiction, authority and payment constraints review |
| Syria | P2 | D | SYP, Arabic | Current legal/operating restrictions, supplier/provider availability review |
| Iran | P3 | D | IRR/toman display distinction, Persian RTL | Fiscal and transaction restrictions plus local connector feasibility review |
| Türkiye | P2 | D | TRY, Turkish statutory reports | GIB e-Fatura/e-Arşiv/e-Defter capability and integrator review |
| United States federal | P3 | R | USD, entity tax profile, W-9/vendor reporting | IRS authority; IRS IRIS information returns A2A/TCC/ATS is a real distinct integration [REG-21,22] |
| United States states/localities | P3 | R sample | Sales/use tax, nexus, exemptions, sourcing | State/local scope; California official nexus guidance illustrates complexity [REG-23] |
| United Kingdom | P3 | R | GBP, VAT, statutory/accountant exports | HMRC MTD compatible software and scoped authority; income tax separate [REG-24] |
| European Union framework | P3 | R | EUR/other currencies, VAT/OSS/IOSS | ViDA cross-border B2B reporting from July2030; member-state packs still required [REG-25] |
| Germany | P3 | D | DE chart/reporting, VAT | EN16931 plus current domestic e-invoice and archive rules review |
| France | P3 | D | FR chart/reporting, VAT | Current approved platform/exchange and e-reporting scope validate |
| Italy | P3 | D | IT chart/reporting, VAT | SDI invoice exchange/current formats validate |
| Spain | P3 | D | ES tax/reporting | SII, VERI*FACTU and applicable regional differences validate |
| Poland | P3 | D | PLN, VAT and filings | KSeF taxpayer cohort, API/schema/security validate |
| India | P3 | R limited | INR, GST, GSTIN, HSN/SAC | IRP e-invoicing eligibility/reporting time limits and e-waybill separate [REG-26] |
| Bangladesh | P3 | D | BDT, VAT/withholding | NBR EFD/SDC/e-invoice/returns and local requirements review |
| Malaysia | P3 | D | MYR, SST | LHDN MyInvois cohort and API/current exemptions review |
| Singapore | P3 | D | SGD, GST | IRAS + InvoiceNow / provider-specific scope validate |
| Indonesia | P3 | D | IDR, VAT | DJP/Coretax/e-Faktur current integration rules validate |
| Australia | P3 | D | AUD, GST/BAS | ATO/Peppol e-invoice and payroll STP separate review |
| New Zealand | P3 | D | NZD, GST | Inland Revenue + Peppol capability and privacy review |
| Canada | P3 | D | CAD, GST/HST/provincial tax | CRA plus provincial and Quebec separate requirements |
| South Africa | P3 | D | ZAR, VAT | SARS filings/invoice/archive and payroll separate |
| Kenya | P3 | D | KES, VAT | KRA eTIMS onboarding and operating model review |
| Nigeria | P3 | D | NGN, VAT/withholding | Current tax authority/e-invoice obligations and entity scope review |

48 rows mein federal/subnational aur EU framework bhi hain; is ko 48 independent certified countries kehna ghalat hoga. 40 se zyada named countries/territories ki expansion coverage hai, lekin deep researched launch scope neeche ke markets hain. Baqi har row discovery backlog hai, ready integration nahi.

## 2. Pakistan detailed delivery pack

FBR digital invoicing FAQ licensed integrator ke zariye notified registered persons ki integration batata hai; PRAL route ka bhi zikr hai. 30 March 2026 STGO01 one-or-more licensed integrators ki ijazat aur bona fide invoice mistake ke liye Board system se 72-hour correction window batata hai; us ke baad Commissioner approval required hai. Yeh rule sirf generic credit-note button se satisfy nahi hota. [REG-01](https://fbr.gov.pk/faqs/173967/173969) [REG-02](https://download1.fbr.gov.pk/Docs/2026331133557466STGO01of2026.pdf)

Planned objects: taxpayer registrations; branch/outlet; goods/service classification; schedule/rate/exemption code; withholding profile; counterparty identifier; sale type; reference invoice; transmission attempts; FBR response; QR/verification attributes; correction request/approval; return worksheet. Raw credentials accountant ke browser automation mein store nahi honge.

Workflow: entity eligibility questionnaire → licensed integration route selection → sandbox/sample mapping → accounting/tax approval → enrollment → controlled invoice → authority receipt reconciliation → live scope switch. Correction mein original artifact retain hoga; approved change Board mechanism aur local ledger event se linked hoga. 72-hour clock timezone aur generation event se calculate hoga, local save date se nahi. Exact accepted correction API aur permission taxpayer/integrator documentation se verify honge.

FBR IRIS income-tax filing portal hai. ERP se tax computation/export banana aur IRIS mein legally authorized successful filing karna do alag capabilities hongi. [REG-03](https://fbr.gov.pk/categ/file-income-tax-return/51147/80860/71158)

Federal goods tax ko provincial services tax ka substitute na banayein. Restaurant, bakery with dine-in, distribution plus installation aur mixed-service contracts mein classification/place-of-supply review ho. PRA ka historical restaurant rule serial invoices aur registration reference cover karta hai; latest E-IMS rates/API/mandate ko current notification se independently approve karna baqi hai. KP2025 Act mein restaurant integration condition milti hai; exact operational connector separate discovery hai. [REG-04](https://reg.pra.punjab.gov.pk/ptms/SOP/Download/Rules/Restaurant%20services%20Rules%2009-10-2012.pdf) [REG-05](https://kpra.gov.pk/wp-content/uploads/2025/07/kp-finance-act-2025.pdf)

Acceptance: taxable/exempt/export sale; registered/unregistered buyer; discount; sales return; provincial service; mixed basket; withholding; delayed response; duplicate request; 72-hour boundary; post-window approval; rule change; fiscal-year close. Pakistan payroll/EOBI/social security/SECP reporting independently scoped honge.

## 3. Saudi detailed delivery pack

ZATCA generation phase 4 December2021 se aur integration phase 1 January2023 se waves mein hai. Standard tax invoice aur simplified invoice ke flows alag hain. Technical guideline EGS onboarding, CSID lifecycle, signing, QR, reporting aur clearance define karti hai. [REG-06](https://www.zatca.gov.sa/en/E-Invoicing/Introduction/Pages/What-is-e-invoicing.aspx) [REG-07](https://www.zatca.gov.sa/ar/E-Invoicing/Introduction/Guidelines/Documents/E-invoicing%20Detailed%20Technical%20Guidelines.pdf)

Planned implementation: entity/EGS register; supported XML/schema validator; country-specific signature/QR service; immutable sequence/hash artifacts; clearance queue; simplified reporting queue; credit/debit-note references; receipt reconciliation. Standard invoice ko cleared/customer-issuable aur simplified ko issued/reported states ke mutabiq UI dikhaye. Baseline technical guideline simplified documents ko 24 hours mein report aur standard documents ko buyer ko dene se pehle clear karne ka rule batati hai. Latest technical rules aur outage exceptions signed configuration mein verify hon; demo success ko phase2 production approval na kahen.

Tests: each supported invoice/note class; discounts/advance payment; bilingual seller fields; wrong VAT ID; expired/revoked CSID; certificate rotation; sequence ordering; duplicate submission; unknown timeout; cleared XML archive; VAT group/branch mapping; permission isolation; period close. Saudi VAT, withholding, Zakat/corporate tax reports, GOSI/WPS/end-of-service aur data protection independent capability cards honge.

## 4. UAE detailed delivery pack

MoF structured invoices aur accredited service-provider ecosystem ka official reference hai. Old September2025 implementation decision ko akela hardcode na karein: May2026 amendment ne relevant large-business ASP appointment deadline ko 30 October2026 tak extend kiya; 1 January2027 mandatory implementation date retained thi. October2026 MD168 ne provider accreditation framework update kiya aur prior preapproval framework replace kiya. Current eligibility/boundaries latest decisions se legal reviewer approve kare. [REG-08](https://mof.gov.ae/en/about-us/initiatives/einvoicing/) [REG-09](https://mof.gov.ae/en/news/ministry-of-finance-announces-targeted-amendments-to-einvoicing-system-decisions/) [REG-10](https://mof.gov.ae/en/news/ministry-of-finance-issues-decision-on-accreditation-of-einvoicing-service-providers-under-updated-regulatory-framework/)

Operqon ke liye pehla route accredited ASP partner integration recommend hai; khud ASP accreditation ka separate business case ho. Receiver identification, structured payload mapping, provider acknowledgment, authority reporting status, error/retry aur invoice archive maintain hon. Buyer delivery aur tax-data reporting ko one success flag na banayein. VAT returns, corporate tax computations, free-zone entity treatment aur payroll/WPS automatically same release mein certified nahi honge.

## 5. Oman detailed delivery pack

Official Fawtara FAQ updated5 November2026 annual supplies >OMR5million actual/expected tests ke mutabiq 1 April2027 aur otherwise 1 October2027 applicability batata hai; VAT groups ke liye group test aur nonresident Oman supplies ka scope diya hai. FAQ seller/provider/buyer/provider/OTA model describe karta hai. Older official FAQ abhi different phases dikhata hai; latest source ko release evidence mein record karna zaroori hai. [REG-11](https://tms.taxoman.gov.om/portal/web/taxportal/fawtara-faqs)

Pack mein supplies aggregation eligibility report, threshold explanation, OMR decimal policy, provider adapter, structured invoice/note, rejection/status queue aur required archive hon. Group membership effective dating aur expected supplies declaration owner-approved ho. Latest approved providers/schema/version agreement ke baghair launch date promise na ho.

## 6. Egypt aur Jordan delivery packs

Egypt ETA SDK ERP/POS ke liye eInvoice aur eReceipt APIs provide karta hai. Is liye B2B ERP adapter aur retail POS adapter independent contract hon. Product/service code mapping, taxpayer enrollment, device/signing route, response statuses, credit/debit correction aur return reconciliation current SDK release se qualify honge. SDK landing page ki purani update date ki wajah se subpage release notes/schema verify karna release blocker hai. [REG-15](https://sdk.invoicing.eta.gov.eg/)

Jordan official ISTD national e-invoicing page registration/linking, regulation aur manuals expose karta hai. Operqon Arabic invoice flow, taxpayer/establishment credentials, mandatory fields, note/cancellation support aur acknowledgment mapping current manual se implement karega. Public landing page akeli har taxpayer ki applicability ya full API correctness prove nahi karti. [REG-16](https://www.istd.gov.jo/EN/Pages/Billing_system)

## 7. United States detailed delivery pack

USA authority **IRS** hai aur **IRS IRIS** bhi haqeeqi system hai: Information Returns Intake System. Is ka use information returns ke liye hai; ordinary sales invoice clearance ke liye nahi. IRS A2A access TCC, API client, schema aur ATS transmission prerequisites ke saath hai. 7 October2026 ka ATS schema5.0.7 notice specifically test environment ke liye hai, production ke liye nahi. Pakistan FBR IRIS se naam milta hai lekin dono separate systems hain. [REG-21](https://www.irs.gov/filing/e-file-information-returns-with-iris) [REG-22](https://www.irs.gov/e-file-providers/iris-assurance-testing-system-ats)

US pack ko kam az kam teen tracks mein deliver karein: federal vendor/information reporting; state/local sales-use tax determination/filing; payroll/employment reporting. Nexus, product taxability, delivery sourcing, exemption certificates, marketplace-facilitator treatment aur jurisdiction effective dates tax engine/provider se aayen. California ki official district-tax guidance economic/physical nexus aur marketplace differences illustrate karti hai; ek federal tax percentage se country cover nahi hota. [REG-23](https://cdtfa.ca.gov/formspubs/pub44.pdf)

First US capability proposed: W-9/vendor data hygiene → accountant-reviewed 1099 dataset/export → qualified filing provider → later scoped IRIS A2A. Sales tax calculated/exported aur returns actually filed/accepted separate visible statuses hon. State enrollment, filing calendar, amendment aur notice handling ki ownership contract mein ho.

## 8. Global accounting aur partner strategy

IFRS reporting principle, local adoption aur entity-size eligibility same cheez nahi. IFRS Foundation jurisdiction profile aur local accounting authority se accepted basis choose ho; country dropdown har entity ko full IFRS par force na kare. IFRS for SMEs ki local applicability/version transitions verify hon. [REG-27](https://www.ifrs.org/supporting-implementation/2015-ifrs-for-smes-supporting-materials/sme-updates/2026/september-2026-ifrs-for-smes-accounting-standard-update/)

PK/SA domain knowledge Operqon ke andar rakhein; regulated exchange ke liye qualified partner route jahan required/practical ho. Country adapter interface owned ho taa-ke provider replace ho sake. Contract mein geographic scope, legal role, incident SLAs, invoice price, data location, export rights, correction ownership, exit plan aur approval validity cover hon.
