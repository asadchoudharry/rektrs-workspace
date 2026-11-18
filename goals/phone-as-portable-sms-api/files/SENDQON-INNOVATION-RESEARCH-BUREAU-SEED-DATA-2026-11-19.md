# Number Trust Bureau — Seed Data Map: Where Day-One Data on Pakistani Numbers Can Lawfully Come From

**Lane question:** before Sendqon has any cross-tenant history of its own, from where on the internet can the bureau *lawfully* gather seed data about Pakistani phone numbers — and what exactly does each source give?
**Date:** 2026-11-19 · **Method:** vendor documentation, published price pages and Pakistani regulatory/service pages read 2026-11-18/19. No data was bought, downloaded, or sampled; no real person's number appears in this report.
**Grading key:** every key claim is graded **official** (the operator/regulator's own published material), **industry** (credible third-party reporting of vendor material), or **unverified** (claimed, not confirmed). Legality grades: **lawful** / **ToS-grey** / **unlawful**, with the reason.

---

## The headline finding, before the detail

**There is no lawful source — anywhere — that sells the name or CNIC behind a Pakistani mobile number.** PTA's registry (SVMS) binds every SIM to a biometric-verified CNIC, and that record is disclosed only to the holder themselves through holder-only channels (668 / cnic.sims.pk / 667). Every lawful source below yields *network and behaviour-shaped* facts — carrier, ported status, liveness, line type, business-vs-personal, public business identity — and **none** yields subscriber identity. Any seller who claims name/CNIC/address per number is, by construction, selling leaked or fabricated data; that market is mapped in §9 only so the line is drawn deliberately.

What a lawful day-one seed *can* do is therefore narrower than the end-state bureau — but real: it can say whether a number is genuine, live, on which network, whether it was ported, whether it is a business's public number, and whether it is WhatsApp-active. It cannot say whether the *person* pays on time. That layer only accrues from Sendqon's own consented operations (the sibling lane's subject). Section 10 builds the exact day-one stack and states its limits without varnish.

**Legal frame used throughout (graded):**
- **PECA 2016** (as amended 2025) is the operative criminal law — it criminalises unauthorised access to / copying of data and unauthorised use of *identity information* (s.16 is the provision Pakistani sources cite for SIM/CNIC misuse); there is **no enacted comprehensive data-protection law** — the Personal Data Protection Bill (2023 draft, cabinet-approved) has **not** passed Parliament as of late 2026 (**official/industry**, MoITT register still lists it as draft). Design rule adopted here: build to the draft PDPB's principles anyway — consent, purpose limitation, data minimisation (the same principles NADRA's 2025 data-sharing regulations impose on its channels).
- PECA's definitions treat access to data *openly available to the public* as authorised — so reading genuinely public business listings is not a PECA access offence; but platform **contracts (ToS) still bind**, and *processing* the data is what a future PDPB would regulate.
- FX for conversions: **Rs 277 / USD** (project rate).

---

## 1. Number-intelligence & HLR APIs (global)

### 1.1 SendPK HLR & MNP Lookup API — the local one ⭐
- **(a) What/who:** a lookup API sold by SendPK, a Pakistani SMS aggregator (the same SendPK already shortlisted in the aggregator track). One endpoint, two query types: `type=mnp` and `type=hlr`; single GET or bulk POST up to 100,000 numbers.
- **(b) Fields (from the vendor's own worked examples):** MNP returns `current_network` (network name + MCC/MNC), `is_ported`, `number_type` (mobile), `is_disposable`, IMSI *when the operator releases it*, timezone, format variants. HLR adds `original_network` and `reachable` ∈ {connected, absent, invalid, no-coverage, failed, inconclusive}. **No name, no CNIC, no spam data.**
- **(c) Access:** self-serve API key (same key as their SMS API); lookup service switched on by their support.
- **(d) Cost (official — vendor's own documentation, read 2026-11-18):** **MNP Rs 0.78 per lookup**; repeat MNP within 60 days served from cache at **Rs 0.25**; **HLR Rs 1.56 per lookup**; an HLR lookup that finds nothing / has no route is **free**; MNP no-answer charged only at the cache rate.
- **(e) PK coverage:** MNP works on **every** Pakistani network. HLR live reachability today has routes only to **Zong (031x, 037x) and Telenor (034x) prefixes** — coverage is chosen by prefix, so a Jazz/Ufone-prefix number returns `reachable: "no-coverage"` (free) even if it has since ported to Zong/Telenor. (Vendor's wording says "Telenor"; per the project's aggregator research, Telenor Pakistan amalgamated into PTML/Ufone in 2026 — the route table should be re-confirmed with SendPK at contracting.)
- **(f) Legality: lawful.** A licensed-route commercial API querying network data the networks themselves answer; no personal identity changes hands.
- **Fit note:** Sendqon's B4 `hlr` plugin already implements exactly this provider shape (generic HTTP + key, `valid|invalid|unknown` + skip logic) — SendPK is a plug-in counterparty, not a build.

### 1.2 Twilio Lookup
- **(a)** Twilio's per-package lookup API; each data package billed separately per request.
- **(b) Fields for PK:** format/validity; **carrier + line type** (Line Type Intelligence); **line status** (active/reachable). Caller Name is **US-only**; Identity Match is country-dependent with PK availability **not published**; SIM-swap package exists but supported-country list does not evidence PK. **No PK name, no PK spam score.**
- **(c)** Self-serve API, pay-as-you-go, no minimum.
- **(d) Cost (industry — Twilio list prices as read by multiple trackers, Oct 2026):** basic formatting/validation **free**; Line Type Intelligence **$0.008 ≈ Rs 2.22**/request; Line Status **$0.007 → $0.00385** by volume (≈ Rs 1.94 → 1.07); Caller Name $0.01 (US only); Identity Match $0.10 where offered.
- **(e) PK coverage:** carrier/line-type/status packages are global; quality on PK ranges is numbering-plan + partner-HLR grade — adequate for validity/carrier, weaker than a local route for live status.
- **(f) Legality: lawful.**

### 1.3 Telesign Phone ID (+ Intelligence)
- **(a)** Proximus-owned digital-identity vendor; Phone ID is its number-intelligence API, Intelligence its risk-score API.
- **(b) Fields:** carrier, line type, and (country-dependent) device/roaming/subscriber attributes; Intelligence returns a fraud **risk score + recommendation**. The name/address append product (**Phone ID Contact, $0.10**) is a US-centric product — **no published evidence of Pakistani subscriber-name coverage; treat as unavailable for PK** (and see the headline finding: nobody lawfully has it).
- **(c)** Self-serve trial; production is pay-as-you-go / sales-assisted.
- **(d) Cost (industry — third-party reads of Telesign's live pricing feed, Oct 2026):** Phone ID **$0.011 ≈ Rs 3.05** flat across 230+ countries; Contact $0.10; Intelligence risk score **$0.15 ≈ Rs 41.55** per transaction.
- **(e) PK coverage:** Phone ID's flat global rate includes PK for carrier/line-type; the *risk score's* PK signal depth is not published — assume thin until tested.
- **(f) Legality: lawful.**

### 1.4 Vonage Number Insight → Identity Insights
- **(a)** Vonage (Ericsson) is **sunsetting Number Insight on 4 Feb 2027** (official developer notice) and migrating customers to the **Identity Insights API**.
- **(b) Fields:** number format; **original carrier**; **current carrier** (which together yield ported status); SIM Swap and Subscriber Match priced per country (PK availability via sales — **not published**). Legacy Number Insight Advanced also offered reachability/roaming in some markets; CNAM is US-only.
- **(c)** Self-serve API.
- **(d) Cost (industry/vendor-published rates):** Identity Insights — format **free**, Original Carrier **€0.001 (≈ $0.00117 ≈ Rs 0.32)**, Current Carrier **€0.007 (≈ $0.00819 ≈ Rs 2.27)** per request; SIM Swap/Subscriber Match per-country, not published.
- **(e) PK coverage:** carrier products global; the €0.001 original-carrier dip is the cheapest published range-check anywhere, but original carrier is derivable free from the numbering plan (§2) — the paid value is only the *current* carrier.
- **(f) Legality: lawful.** (Build on Identity Insights, not the retiring API.)

### 1.5 Budget validators — Numverify · Abstract API · Veriphone
- **(a)** APILayer's Numverify; Abstract API's Phone Validation; Veriphone. All are **numbering-plan database** products, not live network queries.
- **(b) Fields:** valid yes/no, **original (range) carrier**, line type, country/region formatting. **No live liveness, no ported status** — except Veriphone's *Current Carrier Lookup* add-on (10 credits instead of 1). Abstract's higher tiers add breach/risk flags of US-centric provenance — no PK value evidenced. **No names, no spam.**
- **(c)** Self-serve API keys; free tiers exist (Numverify free = 100/month and **non-commercial only**; Abstract free 100/month; Veriphone free 1,000 credits/month).
- **(d) Cost (industry — vendor price pages as compared Oct–Nov 2026):** Numverify from **$14.99/mo for 5,000** (≈ $0.003 ≈ Rs 0.83/lookup; top tier ≈ $0.00052); Abstract from **$17–19/mo**; Veriphone **$12.99/mo for 10,000 credits** or $24/10,000 PAYG (≈ Rs 0.67 per standard check; current-carrier ≈ 10× that).
- **(e) PK coverage:** as good as their range tables — fine for validity/original carrier, **structurally blind to porting**, which is common in PK.
- **(f) Legality: lawful** (respect the non-commercial free-tier term).

### 1.6 HLR wholesalers — CEQUENS · BroadNet · Dexatel · 1Lookup
- **(a)** SS7/HLR-route wholesalers selling live dips: CEQUENS (MENA-focused, claims real-time HLR incl. Pakistan), BroadNet, Dexatel (portability check), 1Lookup (credit-based validator with HLR add-on).
- **(b) Fields:** live reachability, current operator (post-port), original operator, roaming state, IMSI prefix (BroadNet). No identity fields.
- **(c)** API; CEQUENS is sales-led, others self-serve.
- **(d) Cost:** BroadNet **$0.005 live / $0.0008 cached** (≈ Rs 1.39 / 0.22) per its own page; Dexatel portability **$0.0059** (≈ Rs 1.63) up to 1M lookups; 1Lookup ≈ **$0.0020–0.00495** per validation credit, HLR = 5 credits; CEQUENS **not published** (quote only).
- **(e) PK coverage:** all claim PK routes; depth varies by their upstream — SendPK's published Zong/Telenor-only HLR caveat is the honest benchmark to test any of them against.
- **(f) Legality: lawful.**
- **Base layer, free:** Google's open-source **libphonenumber** gives offline format/validity/carrier-by-range for every PK number at zero cost — it is what the budget validators largely resell. The bureau's layer-0 should be this, not a paid API.

## 2. Carrier & prefix data — PTA numbering plan and MNP

- **PTA National Numbering Plan (official, free):** PTA allocates all PK mobile ranges: **030x/032x Jazz · 031x/037x Zong · 033x Ufone (PTML) · 034x Telenor→PTML · 0355–0357 SCOM (AJK/GB) · 036x newer Zong allocations · 037x also ONIC (launched 2024)**. From any number, offline and free, this yields: mobile vs landline, **original (issuing) operator**, and range validity. It does **not** yield the current operator (MNP), liveness, or any identity. **Legality: lawful** — published regulatory data.
- **Ported status (MNP):** there is **no public or self-serve PTA MNP lookup**. Ported status is commercially available only as a by-product of the lookup APIs in §1 — cheapest published: **SendPK MNP Rs 0.78** (all networks), then Vonage Current Carrier ≈ Rs 2.27, Dexatel ≈ Rs 1.63. PTA's own consumer route — SMS `N <number>` to **76367** (Rs 2 + tax) — returns the *current network of any number* and is official, but it is a one-by-one consumer SMS service, not an API (see §7 for its grade).
- **Number age:** **not lawfully obtainable for third parties.** Activation dates sit in SVMS and are shown only to the CNIC holder (cnic.sims.pk shows the holder their own activation dates). Any seed design must treat "number age" as *first-seen-by-us* (our own ledger, public-listing sightings), never as true activation age.

## 3. Public identity traces — numbers businesses publish themselves

- **(a) What:** businesses publish their own numbers to be contacted — their websites, Google Business Profiles, Facebook/Instagram pages, OLX/daraz listings, WhatsApp Business profiles (§7). Indexed lawfully, this builds a **business-number identity layer**: number → business name, category, city, website — a strong *positive* trust signal ("this is a real, operating business's public number").
- **(b) Fields:** business name, trade category, locality, sometimes address/website/email the business itself posted. **Business identity only — never a private individual's identity.**
- **(c) Access reality:** there is no bulk feed. Google's licensed route is the **Places API** (per-request pricing; its terms restrict storing Maps content beyond permitted caching — design for reference/verification, not warehouse-building). Direct automated harvesting collides with platform terms: **Google Maps Platform Terms §3.2.3 prohibit scraping/exporting Maps content** and the Maps additional terms prohibit mass download and building listings databases; **Meta's terms prohibit automated collection without permission** (the US *Meta v. Bright Data* ruling turned on logged-out scraping under US law — it is not a Pakistani safe harbour and not a strategy). OLX's terms likewise prohibit scraping.
- **(d) Cost:** Places API per-request (Google-published; not re-verified in this pass); manual/first-party collection costs staff time.
- **(e) PK coverage:** GBP/Facebook penetration among PK SMBs is high in cities, thin rurally; OLX numbers skew to trade/sellers.
- **(f) Legality: split grade.** Using what a business hands Sendqon directly, or displays to its own customers in the course of trade (and a tenant's own customer records) — **lawful**. Bulk automated scraping of Google/Facebook/OLX into a stored database — **ToS-grey**: not a PECA access offence (public data), but a contract breach with account/IP enforcement, and exactly the processing a future PDPB would licence-condition. **Recommended posture:** build this layer from (i) tenant-contributed business contacts, (ii) WhatsApp Business public profiles observed through our own bridge (§7), (iii) Places API within its terms — not from scrapers.

## 4. Crowdsourced name & spam data — Truecaller, Sync.me, CallApp, "who called me" sites

- **Truecaller (the only deep PK pool):** its app is widely installed in Pakistan, so its crowdsourced name tags and spam reports on PK numbers are the richest that exist — **but they are not for sale as data.** Truecaller's business products are: **Verified Business Caller ID** (branding for *your own* outbound numbers), a **Verification SDK** (1-tap, OTP-less verification of a user logging into *your* app, with that user's consent — it verifies, it does not enrich strangers), and **Risk Intelligence** built on its 2023 acquisition of India's **TrustCheckr** — a phone-risk API returning ~12 parameters (validity, disposable flag, spam/fraud reports, DND status) at a listed **from $15 per 1,000 verifications (≈ Rs 4.16/lookup; industry/unverified, SourceForge listing)**. TrustCheckr's signals are **India-built** (DND is an Indian registry concept); **PK coverage is not evidenced anywhere** — treat as unproven for PK until a paid pilot proves otherwise. **(f) Legality:** using Truecaller's own products on their terms = lawful; **scraping the app/web directory or buying resold Truecaller lookups (bots/services that resell them exist) = ToS-grey at best, unlawful where the underlying data was harvested from users' address books without those contacts' consent** — do not build on it.
- **Sync.me / CallApp / Mr. Number etc.:** consumer caller-ID apps with meaningful PK installs but **no developer API or data product found** — honest dead end.
- **"Who called me" / reverse-lookup websites:** a mix of scraped directories, user comments and (for PK) fronts for the leaked-data market in §9. Unreliable, unlicensed, frequently themselves harvesting the searcher's data. **Grade: ToS-grey to unlawful; not usable as a bureau source.**

## 5. Licensed Pakistani data holders

### 5.1 Credit bureaus — Tasdeeq & DataCheck (ICIL is not one of them anymore)
- **(a)** Under the Credit Bureaus Act 2015, SBP has licensed **two** private bureaus: **Tasdeeq** (Aequitas Information Services) and **DataCheck Limited**. ICIL/PakBizInfo belongs to the older, pre-Act private-bureau era and is **not** an SBP-licensed bureau under the 2015 Act — correct the assumption wherever it appears.
- **(b) Fields:** their consumer credit reports are **CNIC-keyed** and do contain contact numbers — DataCheck's published report contents list personal + office addresses and **contact numbers reported by member lenders**, alongside loans, 24-month payment history and defaults. But that is data *inside a regulated credit report about a borrower*, retrievable by member institutions for credit decisions and by the consumer about themselves (Tasdeeq's app sells a consumer their own report for **Rs 399**). **There is no number-keyed lookup, no public API, and no lawful way to ask either bureau "whose number is this / is this number trustworthy."**
- **(c)** Membership/partnership only, regulated; Tasdeeq advertises APIs **to member financial institutions**.
- **(d)** Member pricing **not published**.
- **(e)** Coverage: deep on the banked/borrowing population; silent on everyone else.
- **(f) Legality: lawful only inside their regulated membership purpose.** Using bureau data for a phone-trust product outside that purpose would breach the Act's framework — this is a *strategic partnership* conversation (e.g., a future phone-verified signal inside their member products), **not a seed source**.

### 5.2 NADRA channels — Verisys / Nishan Pakistan (and why they don't seed a number bureau)
- **(a)** NADRA's institutional verification runs through **Verisys** (operated by NADRA Technologies) and, since 2026, the unified **Nishan Pakistan** gateway under the NADRA (Data Sharing) Regulations 2025 / (Identity Verification) Regulations 2026.
- **(b) Fields:** CNIC↔name match, demographic/address confirmation, biometric match, proof-of-life — **all keyed by CNIC, all consent-based** (Verisys is explicitly OTP-consent: the holder receives the code). **A phone number is an input to nothing here; no service maps number→person.**
- **(c)** Registered, regulated clients only (banks, EMIs, telcos, NBFCs) after onboarding review of legal status and use case. A messaging platform does not qualify on its own; access would come only via a licensed partner institution for a specific transactional purpose.
- **(d)** Fee-based per verification; rates **not published**.
- **(f) Legality: lawful within its consent + licence rails; unusable — and unlawful to repurpose — outside them.** Recorded here so the boundary is explicit: NADRA is the *verification* rail for a person who is present and consenting (the Gawah pattern), never a seed-data well.

### 5.3 Karandaaz & the ecosystem
Karandaaz (UK-aid-funded financial-inclusion company) funds and researches digital finance in Pakistan; it **holds no number-level data product or API**. Value: research grants and ecosystem introductions, not data. **Not a source.**

### 5.4 Bank/PSP inquiry rails (Raast title fetch)
Per the lane boundary: the sibling lane covers this. One line for completeness — Raast/IBFT title fetch returns an account title for an account you are *paying*, inside a bank-mediated transaction; it is not an open number→name API and cannot seed a bureau. (See the sibling report.)

## 6. Government & public registries

- **SECP eServices (official, free public search):** keyed by **company name / incorporation number** → registered name, status, incorporation date, registered office (director details sit behind account/paid tiers). **No phone-number field is searchable or returned.** Bureau value: once a *business name* is known (from §3/§7), SECP confirms the business legally exists — a verification overlay, not a number source. **Lawful.**
- **FBR taxpayer directory / ATL (official, free):** Taxpayer Profile Inquiry is keyed by **CNIC / NTN / passport / incorporation no.** → taxpayer name, registration date, ATL (filer) status, jurisdiction; ATL also checkable by SMS (`ATL <CNIC/NTN>` to 9966) and published as downloadable lists. **No phone numbers.** Same overlay value as SECP: "this business is a registered, filing taxpayer." **Lawful.**
- **data.gov.pk:** aggregate open datasets (statistics, budgets, demographics). **No number-level or personal data. Not a source.**
- **Court lists / cause lists:** published for case scheduling; names of litigants/counsel, not a phone-number dataset; any numbers appearing incidentally in filings are purpose-bound judicial records. **Not a source — do not mine.**
- **DIRBS (PTA device registry):** keyed by **IMEI**, answers *device* compliance status. It cannot be queried by phone number and returns nothing about a number; the number↔device binding exists only inside operator/PTA systems. **Verdict: not number-relevant at all — a dead end, recorded so nobody revisits it.**

## 7. Telecom-adjacent signals

### 7.1 WhatsApp public business-profile signals — via our own bridge
- **(a/b)** A WhatsApp account's *public-by-design* face: whether the number is **registered on WhatsApp**, whether it is a **Business account**, and for business accounts the profile the business itself publishes — **display name, description, categories, email, website(s), address, hours, Meta-verification level** — plus profile-photo presence and the account's About line. For a bureau this is gold of a specific kind: it converts an anonymous number into "a self-declared, operating business identity" — or flags its absence.
- **(c) Access — two very different routes:** (i) **Commercial checker APIs exist** (CheckNumber, MobileValidate, OpenData-API, Mindcase and others) selling exactly these fields in bulk, including activity windows and avatar signals, at per-result prices (published per-vendor; not re-verified here). They work over **unofficial protocol access — a standing violation of WhatsApp's terms**, with the account-fleet bans that implies; several also infer sensitive attributes (age/gender from photos), which a bureau must never touch. (ii) **Our own B8 Baileys bridge** sees the same public signals for numbers it *legitimately interacts with* — a customer who messages a tenant, a tenant's own contacts in a consented flow. That is incidental observation inside a real conversation, not bulk probing of strangers.
- **(d)** Route (i) per-result fees; route (ii) zero marginal cost.
- **(e) PK coverage:** WhatsApp is Pakistan's default business channel — coverage of *business* numbers is excellent; personal-number coverage exists but see the grade.
- **(f) Legality:** route (i) **ToS-grey trending unlawful** (unauthorised automated access; PECA exposure arguments; supplier risk lands on us) — **do not buy**. Route (ii) **lawful with constraints**: observe only in the course of genuine messaging, store only the business-identity fields a business publishes for customers, honour opt-outs, never probe lists of strangers through the bridge (that converts it into route (i) with our own accounts at risk).

### 7.2 PTA consumer short codes — 668 · 667 · 76367
- **668 (SIM Information System) + cnic.sims.pk:** SMS your **own CNIC** → count of SIMs registered to you, per operator; the portal adds **your own** activation dates. Charge ~Rs 2 incl. tax historically; current charge not published on PTA's portal (sources differ between "free" and Rs 2). **It cannot be queried by phone number, returns no list of numbers, and says nothing about anyone else.** Pakistani sources are explicit that using another person's CNIC/identity through such channels is a **PECA s.16 offence**. **Bureau value for scoring others: zero.** One lawful adjacent use: a *self-service* feature where a user checks their own SIM footprint with their own CNIC and consent — identity hygiene, their data about themselves.
- **667 (MNP short code):** sent **from a SIM**, returns *that SIM's own* registered owner name + network. Self-only by construction. **No third-party use exists.**
- **76367:** SMS `N <any number>` → that number's **current network**, **Rs 2 + tax** (official PTA service). This is the one consumer channel that answers a question about *someone else's* number — but the answer is only the carrier, available cleanly and cheaper via SendPK's MNP API (Rs 0.78, §1.1). **Grade: lawful for individual checks; ToS/purpose-grey if industrialised through a SIM fleet — use the API instead.**

## 8. (Reserved — Raast/bank rails are covered by the sibling lane; see §5.4.)

## 9. The grey & black market — mapped, graded, NOT usable

*Nothing in this section was bought, downloaded, or sampled. It exists so the owner sees the line drawn deliberately.*

- **Bulk "marketing databases" (openly sold, e.g. webnagar-type sellers):** city/operator/profession number lists — *"20 lac Karachi mobile numbers" Rs 2,500; "1.5 lac Pakistan corporate/business numbers" Rs 2,000* (sellers' own published prices, read 2026-11-18). Claimed contents: raw numbers by city and network, "business" numbers by trade. Provenance: scraped listings, recycled lists, and worse — undocumented by definition. **Grade: unlawful to build on.** The numbers are personal data traded without the subjects' consent; a buyer inherits PECA exposure for unauthorised use of identity information and poisons the bureau's one asset — that its data is clean. Quality is also unverifiable (dead/recycled lists are the norm in this market).
- **"SIM databases" with name + CNIC (e.g. simownership-type sellers):** downloadable .sql "complete telecom databases" claiming **subscriber name, CNIC and network** per number, sold by quote. There is exactly one way such data can exist: **leaked** from operator/PTA/NADRA-adjacent systems — or fabricated. Either way: buying it is receiving stolen identity data (**PECA ss. 13–16 territory: unauthorised access/copying and identity-information offences, with imprisonment exposure for the individuals involved**), and a large share of this market is outright fraud selling recycled junk to buyers who cannot complain. **Grade: unlawful. Never touch — including "just to check quality."**
- **CDR-for-sale services (social-media "data hub" ads):** packages of **call detail records** (3/6/12 months, all networks) advertised openly on Facebook. CDRs are lawfully obtainable only by law-enforcement through operators under court/legal process; any commercial seller is necessarily a criminal insider or a scammer. **Grade: unlawful, the most serious item on this page. Never touch; never even engage the seller.**
- **"SIM owner details" lookup sites/apps:** hundreds of sites/apps promise name/CNIC/address for any number. PTA's position, restated across Pakistani sources: **no such lawful service exists**; these run on the leaked datasets above or are scams harvesting the *searcher's* own number/CNIC. **Grade: unlawful/unusable.**

**The buyer's exposure, in one paragraph:** PECA criminalises unauthorised access to and copying of data and the unauthorised use of identity information (s.16 is the provision cited in Pakistani reporting for SIM/CNIC misuse), enforced by the NCCIA; PTA can and does act against services built on subscriber data; and the draft PDPB — when it passes — will add a regulator, consent/purpose conditions and penalties that would make a leaked-data foundation retrospectively indefensible. For a company whose entire pitch to banks and aggregators will be *"our data is lawful,"* one grey purchase ends the business. This is also why the bureau's lawful thinness (§10) is a feature to sell, not a defect to hide.

## 10. The Day-One Seed Stack — what switches on immediately, and what it honestly supports

Layered cheapest-first; every layer lawful; total marginal cost per fully-seeded number ≈ **Rs 1–4**.

| Layer | Source | Yields | Cost/number |
|---|---|---|---|
| 0 | **libphonenumber** (offline) + **PTA numbering plan** | valid format, mobile/landline, **original operator**, range sanity | free |
| 1 | **SendPK MNP API** | **current operator + is_ported** (all PK networks); repeat checks cached 60 days | Rs 0.78 (Rs 0.25 cached) |
| 2 | **SendPK HLR** (Zong/Telenor-prefix numbers) or Twilio Line Status / BroadNet as fallback | **liveness**: connected / absent / invalid — dead-number detection | Rs 1.56 (no-answer = free) |
| 3 | **WhatsApp signals via own bridge** (interaction-time only) | registered on WhatsApp? **business account? public business name/category** | zero marginal |
| 4 | **Business-identity overlay** (tenant-contributed + Places API within terms; SECP/FBR name-keyed checks) | "real operating business" flag; SECP-registered? FBR filer? | staff/API cost only |
| 5 | **First-party flywheel** (Sendqon's own DLRs, replies, opt-outs from day one) | the first *behavioural* facts, accruing from our own sends | zero |

**The composite this supports on day one — stated honestly:** a **Reachability & Identity-Shape Score**, not a trust score. It can tell a COD seller: *this number is real, live, on Zong, not ported, WhatsApp-active, and belongs to a business that publicly trades as "X Electronics, Lahore"* — or the opposite: *dead number, ported twice-removed from its range, no WhatsApp, no public trace*. That already kills the two most common COD losses (fake/dead numbers and ghost buyers) and is sellable as list-cleaning + pre-dispatch verification. **What it cannot do on day one:** predict whether a *person* will accept a parcel, pay a fee, or default — no seed source contains behaviour, and any vendor claiming otherwise is selling §9. Behaviour arrives only with Sendqon's own outcome data (sibling lane) and Gawah records; the seed stack's job is to make every number *identifiable and reachable-or-flagged* so that behaviour, once observed, attaches to a clean identity.

**Explicitly missing fields (do not promise them):** subscriber name · CNIC linkage · true number age (activation date is holder-only) · credit behaviour · lawful spam score for PK (Truecaller's pool is closed; TrustCheckr's PK depth unproven).

## 11. Partnership targets, ranked

1. **SendPK** — already an aggregator-track counterparty; its MNP/HLR API is live, published and the cheapest PK route found. Deepen: volume pricing, and press on HLR route expansion (Jazz/Ufone prefixes are today's gap).
2. **A global HLR wholesaler (CEQUENS or BroadNet)** — second route for coverage leverage and price discipline against #1; CEQUENS claims direct PK HLR depth worth a paid pilot test.
3. **Tasdeeq or DataCheck** — strategic, slow, regulated: the only lawful holders of identity-linked financial behaviour in PK. Not a data tap — a future co-product conversation inside their member framework.
4. **Truecaller for Business** — *not* a data source for us; only Verified Caller ID for Sendqon's own outbound calls (trust display). Low priority.
5. **A licensed bank/EMI partner (for NADRA Verisys/Nishan rails)** — relevant only when a consenting person must be verified inside a transaction (Gawah); useless for seeding. Last, and purpose-bound.

## 12. Never-touch list

1. Leaked "fresh SIM database" dumps and .sql subscriber databases (name + CNIC) — at any price, including free.
2. CDR sellers and "data hub" social-media accounts.
3. "SIM owner details" lookup sites/apps and any API reselling their data.
4. Resold caller-ID lookups (Truecaller/Sync.me data via bots or brokers).
5. Bulk scraping of Google / Facebook / OLX into a stored database (use Places API within terms, tenant-contributed data, and bridge-observed business profiles instead).
6. Automating 668/667 against anyone else's CNIC or SIM; industrialising 76367 through a SIM fleet (use the MNP API).
7. Third-party WhatsApp checker APIs (unofficial protocol access) — observe through our own bridge, in genuine conversations only.
8. Any dataset whose seller cannot document lawful provenance in writing.

---

### Principal sources (accessed 2026-11-18/19)
SendPK HLR & MNP Lookup API documentation (sendpk.com — fields, worked-example prices Rs 0.78 / 1.56 / 0.25, Zong+Telenor HLR-route caveat) · Twilio Lookup pricing as reported by 1Lookup/Geekflare/PilotLookup (Oct 2026 reads of Twilio's pricing page) · Telesign pricing as reported by 1Lookup/Software Finder/Rankite (Oct 2026 reads of Telesign's live pricing feed) · Vonage developer documentation (Number Insight sunset 4 Feb 2027; Identity Insights rates via 1Lookup's Vonage comparison) · BroadNet HLR Lookup page; Dexatel Portability Check page; CEQUENS Number Lookup page · Numverify/Abstract/Veriphone comparisons (Geekflare, PilotLookup, EmailChaser, Trueguard — Oct–Nov 2026) · TrustCheckr listing (SourceForge) and Truecaller company reporting (Fundraising Fox) · DataCheck services page (datacheck.com.pk); Allied Bank eCIB explainer (SBP-licensed bureaus: Tasdeeq + DataCheck); UrduPoint (Tasdeeq consumer report Rs 399) · NADRA verification reporting (PakEra; Bridge Intelligence; LCCI on Nishan Pakistan; Polynopsis PK payments stack) · PTA SIM-information reporting (PakEra, Which.pk, Atmateen, Janopk, Num.com.pk — 668/667/76367 mechanics and PECA s.16 warnings) · PDPB/PECA status (RecordingLaw PK guide; OfflistMe; Rasheed.pk; CapitalEstate — no enacted comprehensive law as of late 2026) · Google/Meta scraping terms (Google Maps Platform Terms §3.2.3 as quoted; Meta v. Bright Data summaries) · SECP/FBR verification guides (Sterling, WhiteHat, ICT — name/CNIC/NTN-keyed, no phone field) · Grey-market sellers' own pages (Webnagar price lists; SimOwnership "buy SIM database"; Facebook CDR-sale ad) — *mapped only, never engaged*.
