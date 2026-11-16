# Worldwide country-pack programme

MENA priority ka matlab baqi duniya scope se baahar nahi. [global-country-discovery.csv](global-country-discovery.csv) mein 249 country/territory code entries hain. Har entry ke saath planning priority, discovery state, required work aur availability gate hai. Yeh 249 integrated ya certified tax packs ki list nahi.

Code seed host ke public-domain IANA tzdb `iso3166.tab` se liya gaya hai, jis ka header ISO alpha-2 assignments ko 2023-04-05 baseline batata hai. Is file mein English operational names ISO official display names se differ kar sakte hain. Current naming/assignment validation aur future changes ke liye [ISO 3166 Maintenance Agency / Online Browsing Platform](https://www.iso.org/iso-3166-country-codes.html) authoritative reference hoga. Seed geography accounting jurisdictions ki final registry nahi; country, dependent territory, tax zone aur subnational authority alag entities hongi.

## Region expansion aur discovery order

| Region | Included examples | First discovery deliverable |
| --- | --- | --- |
| MENA/GCC | Saudi, UAE, Oman, Bahrain, Qatar, Kuwait, Egypt, Jordan, Maghreb and other MENA entries | Applicable fiscal/authority specs, local accountant, Arabic UX, region/data requirements |
| South Asia | Pakistan, India, Bangladesh, Sri Lanka, Nepal and other code entries | Federal/subnational registration, local language, withholding and invoice classification |
| East Asia | China, Japan, South Korea, Taiwan, Hong Kong, Macao, Mongolia | Local accounting, invoice/tax platforms, privacy/hosting, authorized provider and language support |
| Southeast Asia | Malaysia, Singapore, Indonesia, Thailand, Vietnam, Philippines and others | Current country programme eligibility, data model, provider/sandbox and tax reporting |
| Latin America | Brazil, Mexico, Argentina, Chile, Colombia, Peru, Uruguay and others | Country-specific fiscal-document models, authorization/cancellation, numbering/signature, local accountant |
| Caribbean | Dominican Republic, Jamaica, Trinidad and Tobago, Barbados and other entries | Country-specific tax/invoice/retention and payment-provider discovery |
| Europe | EU member states, UK and other jurisdictions | EU framework plus member-state laws, domestic exchange and reporting; no one-size EU pack |
| North America | US, Canada and territories | Federal/state/provincial reporting, sales/use taxes, privacy and payroll scope |
| Sub-Saharan Africa | South Africa, Kenya, Nigeria and all other listed entries | Local authority source, fiscal device/exchange where applicable, connectivity and payments |
| Oceania/Pacific | Australia, New Zealand and Pacific entries | Tax/payroll boundaries, Peppol/provider where applicable, language and remote operations |

Rows ke discovery questions obligations ke claims nahi. Unresearched country ke liye tax rate, mandatory schema ya deadline invent nahi ki gayi. Specific law only official source verification ke baad country requirements record mein aayega.

## Har country ka complete work package

1. Legal entities, tax establishments, territories, subnational authorities aur registration scope map karein.
2. Official laws, latest notifications, technical schemas, validation tools aur access prerequisites resolve karein.
3. Local accountant/tax professional accounting basis, chart, reports, currency precision, fiscal calendar aur retention verify kare.
4. Tax calculation goods/services, exemptions, withholding, imports, exports, returns aur B2B/B2C use cases cover kare.
5. Fiscal document generation, numbering/signing, transmission, buyer delivery, acceptance, correction aur archive separately specify hon.
6. Payroll/employment, privacy, sector regulation aur cross-border data requirements independent scope mein review hon.
7. Direct/qualified partner route, credentials custody, certification responsibility, transaction fees aur exit mechanism choose ho.
8. Industry-country combinations ka supported matrix aur explicit exclusions publish hon.
9. Golden fixtures, sandbox/authority evidence, production enrollment, operations runbook aur local support readiness complete ho.
10. Current source/effective dates, pending legal change, renewal/certificate expiry aur periodic change review maintain ho.

## Subnational aur non-ISO cases

USA states/localities, Canadian provinces, Pakistan service-tax jurisdictions, UAE relevant legal regimes aur other local structures code seed se represent nahi hote. `jurisdiction_id` hierarchy mein authority aur legal scope model honge; ISO code sirf geography reference hai. Non-ISO operating codes ke liye separate named namespace, provenance aur local-review rule ho; code ko legal recognition ya service eligibility ka automatic evidence na banayein.

Research-complete aur implementation-ready independent fields hain. Relevant authority ke official API tak access na ho to pack ko export/preparation-only label diya ja sakta hai; successful government filing ka claim nahi. Har new market ko local economics, legal access, support language aur maintained evidence ke saath release kiya jaayega.
