# Innovation Research #1 — "Number Trust Bureau"
### A credit-bureau-style trust score for Pakistani phone numbers, built from Sendqon's cross-tenant outcome data

**Date:** 2026-11-19 · **Project:** Sendqon (Rektrs) · **Status:** Feasibility research — no build authorised yet
**Grading key:** every key figure is graded **[official]** (regulator/vendor primary source), **[industry]** (published by market participants/analysts), or **[unverified]** (claimed but not independently confirmed). Where a price or statistic is not published anywhere, this report says so instead of estimating silently. Internal cost/effort figures are labelled **[planning assumption]**.

---

## Executive verdict

**GO — WITH CONDITIONS.** The pain is real, large and priced (sellers already pay to fight COD fraud). The specific product — a standalone, API-first, cross-vertical phone-number trust score for Pakistan, fed by communications + commerce + payment outcomes — **does not exist in Pakistan today**. But two honest qualifications shape the whole plan:

1. The narrow COD slice ("has this number been flagged by another store?") **already exists in primitive form** (SafeShip, ConfirmFlow, OrderAudit — §1.3). We would not be first to the flag list; we would be first to the *bureau*: positive + negative history, telco/payment enrichment, one API, all verticals.
2. The legal boundary with the **Credit Bureaus Act 2015 is genuinely contestable** (§4.3). Launch scope, naming and contracts must be engineered around it, with a written legal opinion before the first paid query.

---

## 1. Prior art — who already does this, and how close are they?

### 1.1 Global phone-number reputation / identity-graph APIs

| Player | What it actually is | How close to this concept |
|---|---|---|
| **Telesign Intelligence** (Proximus) | Per-query phone risk score (0–1000 scale, allow/flag/block recommendation) built on telecom metadata + traffic patterns across its messaging network. Pricing **not published** (sales-led). | **Closest in shape** — a number-keyed risk API. But its signals are telecom/account-fraud signals for online signups and messaging, not local commerce outcomes; it has no Pakistani COD/delivery ground truth. |
| **Ekata** (Mastercard) | Identity graph: phone/email/IP/address linkages and risk signals, enterprise contracts, pricing **not published** (opaque, no self-serve). | Adjacent. Strong identity *linkage*, weak on Pakistani commerce outcomes; enterprise-only motion is the opposite of the SMB seller market here. |
| **Twilio Lookup** | Published per-signal pricing **[official]**: Line Status $0.007 → $0.00385 at volume; Line Type $0.008; Identity Match $0.10; SMS Pumping Risk $0.025 (outside N. America). | A *component supplier*, not a competitor: it sells the raw telco signals (alive? carrier? line type?) that a bureau would consume as inputs. No outcome history, no score for commerce trust. |
| **SEON / IPQS / Sift et al.** | Multi-signal fraud APIs (email, IP, device, phone add-ons). | Adjacent; phone is one signal among many, data is global-web, not Pakistani ground-level outcomes. |
| **Signifyd / Forter / Riskified** | Cross-merchant commerce networks that approve/decline e-commerce orders and (Signifyd/Forter) guarantee chargebacks. Forter cites a 2B+ identity graph **[industry]**. | **Closest in network logic** — one merchant's outcome protects all others. But they are card-world, keyed on email/device/payment instrument, priced as % of order value, and absent from Pakistan's COD market. They prove the model works; they do not occupy this niche. |
| **Truecaller for Business** | Verified business caller ID, call-reason display, brand/anti-spoof protection, call analytics. | **Not a competitor.** It certifies the *caller's* identity to consumers; it does not sell a consumer-number trust score to businesses. Its consumer-side spam scores stay inside its app. |

### 1.2 Pakistan's licensed credit bureaus

- **Tasdeeq** (Aequitas Information Services Ltd) — SBP-licensed Nov 2018 under the Credit Bureaus Act 2015; ~174 member institutions, ~41.5M unique borrower records; CY2025 revenue PKR 318.4M **[industry — IPO prospectus coverage, 2026]**. **DataCheck Limited** — the second licensed bureau **[official — SBP listings]**.
- Both bureaus score **credit facilities reported by financial institutions**. Their known weakness is the one this concept exploits: telecom, utility, retail and informal-commerce data do **not** systematically feed them, so most citizens have thin or no files (a gap noted in Pakistani financial press **[industry]**). Neither offers a phone-number trust API for merchants, and the Act bars licensed bureaus from non-bureau business lines — they cannot simply pivot into this.
- **Karandaaz Pakistan** is a financial-inclusion promoter/investor, **not** an operator of a number-score product; no Karandaaz-run phone-trust product was found in published sources. *(Negative finding — stated as such.)*

### 1.3 Pakistan COD-fraud tools — the part that already exists

This is where honesty matters most. The *flag-sharing* idea is already live in Pakistan, in early form:

| Product | What it does | Gap vs this concept |
|---|---|---|
| **SafeShip Pakistan** (Dango) | Shared flag database: member WooCommerce stores flag bad customers (phone/name/address, Pakistan-aware fuzzy matching); other members get High/Medium/Low alerts before dispatch. Negative-only by design ("only stores data members explicitly flag"); manual membership approval; **pricing not published**. | Flag list, not a bureau: no positive history, no telco/payment signals, no API product, WooCommerce-only, no scoring model. |
| **ConfirmFlow** | COD operations platform (12+ couriers) with a "Community Fraud Shield" — merchants report scammers to the network; claims a "10k+ scammer database" **[unverified — vendor claim]**. | Same flag-list shape, bundled inside an ops ERP; not a standalone score/API. |
| **OrderAudit** | Parcel tracking across couriers + a per-number risk score from delivery history — but computed across **the seller's own stores only**. | Single-merchant history; no cross-merchant network. |
| **OrderWitness** | Per-order fraud score 0–100 (repeat rejections on the number, blacklists, velocity, value outliers) + WhatsApp confirmation + evidence PDFs. Free ≤50 orders/mo; Starter **PKR 7,999/mo for 500 orders (≈ PKR 16/order)** **[industry — vendor's published pricing]**. | Scores orders inside its own order-management product using its own checks; not a cross-tenant number bureau sold as an API. It is, however, the clearest proof sellers pay. |
| **Couriers (Trax, PostEx, Leopards, TCS)** | Couriers hold the richest RTO ground truth in the country and maintain internal fraud controls; one seller guide advises screening against "shared Pakistani courier fraud databases (Trax, PostEx, Leopard)" **[unverified]**. No courier publishes or sells a number-score API. PostEx publicly claims ~92% delivery success **[industry]**. | Their data is a walled asset, not a product. A courier is a potential data *partner* (or future competitor), not a current one. |

### 1.4 What does NOT exist in Pakistan (stated plainly)

- No standalone, per-query-priced **phone-number trust API** that any business can integrate.
- No score that combines **positive and negative** cross-business history for a number (all local tools are negative-flag lists or single-store history).
- No product combining **telco signals (HLR liveness/porting) + payment-identity signals (Raast/IBFT title match) + communications behaviour (answers calls, confirms on WhatsApp) + commerce outcomes** into one number profile.
- No trust product for the **non-e-commerce verticals** Sendqon already serves (schools' fee collection, clinics, services) — where "will this number pay / respond?" is the same question in different clothes.

**Prior-art conclusion:** the concept is validated by neighbours on every side (Telesign's shape, Signifyd's network logic, SafeShip's local demand) and occupied by none of them in this form, in this market.

---

## 2. Demand evidence — the COD wound, in numbers

- **COD share:** ~80–90% of Pakistani e-commerce orders are cash-on-delivery **[industry — multiple seller-guide sources converge]**.
- **Return-to-origin (RTO) rate:** industry sources converge on **20–35%** for typical stores; ranges quoted run 15–40% by category (fashion worst) **[industry]**. Outright fake/prank orders alone are estimated at **~8–10%** of COD orders **[industry]**.
- **Loss per returned order:** **PKR 800–2,000** all-in (forward + return freight, handling, packaging) **[industry — OrderWitness]**; a narrower direct-cost estimate is PKR 400–900 **[industry — DigiMap]**. A 500-order/month seller at 30% fake/refused loses ≈ **PKR 180,000/month** **[industry — worked example, OrderWitness]**.
- **Market size:** published 2025 estimates for Pakistani e-commerce range widely, **~$3.5B to ~$14.1B** depending on definition **[industry/unverified — sources disagree by 4×; the commonly cited Statista-derived figure is ~$5.77B]**. Even the low end implies tens of millions of COD parcels a year; no official parcel-volume statistic is published. *(Stated as a range because no single authoritative figure exists.)*
- **Who pays today, and how much:**
  - OrderWitness: **PKR 7,999/month** per store (500 orders, scoring + WhatsApp confirmation bundled) — proof of willingness to pay at SMB level **[industry — vendor pricing]**.
  - Standalone confirmation/verification tools: **PKR 1,000–3,000/month** price band cited for basic tools **[industry]**; Shopify fraud apps globally run $20–30/month **[industry]**.
  - Sellers also pay in labour: manual confirmation-call teams are a standard COD cost centre **[industry]**.
  - Couriers price the risk back into COD tariffs and return fees — the seller pays either way.

**Demand conclusion:** the buyer, the budget line and the price sensitivity are all proven. The open question is not "will sellers pay to know?" but "will they pay *us, per query, for a score* instead of a bundled dashboard?" — answered by pricing the query well under the PKR 16/order bundle benchmark (§6).

---

## 3. Data model — what Sendqon can actually feed it

### 3.1 Signals available from the built stack (B1–B9), honestly mapped

| Signal | Source in the built system | Value | Available |
|---|---|---|---|
| Message deliverability per number (delivered/failed, by channel) | Core messaging across WhatsApp/SMS/email/Telegram | Medium — proves the number is live and reachable | Day one |
| Confirmation behaviour (YES/NO/no-response to order/fee confirmations) | Core flows; B6 E-commerce pack's COD confirmation flow already tags confirm/cancel/unconfirmed outcomes | **High** — direct intent signal | Day one (per tenant using the flow) |
| Call outcomes (answered, duration, missed) | B9 PBX (in progress) + gateway call logs | Medium-high — "answers unknown calls" is a known RTO predictor | On B9 completion |
| HLR liveness / ported / current carrier | B4 HLR plugin (built; inactive pending a provider account — owner step) | Medium — kills dead/recycled-number risk; 30-day cache already in the plugin design | Day one of bureau, once provider account exists |
| Payment-identity match (account title vs claimed name) | B2 gateway inquiry APIs (EasyPaisa inquiry is already the settlement trust-path; JazzCash inquiry); Raast plugin | **High** — name↔number binding is the strongest anti-fraud signal available locally | Where the tenant takes digital payments; see §3.3 for standalone title fetch |
| Payment outcomes (paid on time / defaulted) | B2 gateways + Bank Transfer plugin records | High for credit-adjacent trust (fee payment behaviour from Schools pack tenants) | Day one (per transacting tenant) |
| **COD delivery outcome (delivered / refused / returned)** | **Not generated natively by Sendqon.** Must be *contributed*: outcome-reporting API + the B5 WordPress/WooCommerce and Shopify plugins reporting order outcomes; courier webhooks where tenants use them | **Highest** — this is the ground truth the whole product prices | Requires the contribution layer (§5) — the one real build dependency |
| Opt-outs / spam reports against a number | Core opt-out handling | Low-medium (negative only) | Day one |

Explicitly **excluded**: wa_guard risk data (that's about tenants' own WhatsApp accounts, a different subject) and SIM-fleet data (about our/tenants' sending numbers, not customers).

### 3.2 The cold-start problem — and the five-part answer

A bureau with no history answers "unknown" to everything, which is worth ~PKR 0. Cold start is the single biggest feasibility risk. Mitigations, in order of deployment:

1. **Negative-first launch.** A flag network is useful at tiny scale — one verified refusal flag on a number is actionable (SafeShip's entire product proves this). Launch scoring as: *known-bad / known-good / unknown*, and let "unknown" shrink over time.
2. **Enrichment on first sight.** The first query on an unknown number triggers live HLR (+ title fetch where a partner exists, §3.3) and stores the baseline profile. Even with zero history, the answer is never empty: alive/dead, ported, carrier, name-match. The HLR plugin's existing 30-day cache design maps directly onto this.
3. **Tenant history import.** Sellers sit on 6–24 months of order outcomes in WooCommerce/Shopify/courier sheets. A one-time import (the B5 connectors are the natural pipe) instantly gives each joining tenant a private history layer and seeds the shared network (in hashed, aggregated form) from day one.
4. **Anchor-tenant seeding.** 5–10 mid-size COD sellers given free queries for 6 months in exchange for complete outcome feeds + history import. Ten sellers × ~2,000 orders/month ≈ 20k outcome events/month — enough for the shared layer to start discriminating within a quarter. **[planning assumption — volumes to be validated in pilot]**
5. **Courier partnership (phase 2, not day one).** Couriers hold the deepest RTO data. A revenue-share or white-label conversation with one mid-tier courier (Trax/PostEx class) is the single largest data unlock available — and the reason to have a working product first: partnerships are negotiated from traction, not from a pitch deck.

### 3.3 The Raast/title-fetch seed — what it really costs and who can call it

- There is **no public Raast API**. Title fetch is a **1LINK** product consumed by banks/EMIs/PSPs. Wholesale price **[official — 1LINK Schedule of Charges, Jul–Dec 2026]**: **PKR 1.55** per title fetch not followed by a payment (split PKR 0.775/0.775), PKR 2.50 for sending-entity-only arrangements. Bank schedules of charges pass it to customers at **PKR 0–5** (e.g., "Rs 5 or at actual" for non-banking entities; some EMIs list Rs 0–1.25) **[official — published bank SOCs]**.
- Consequence: Sendqon cannot call title fetch directly. It needs **one partner** — a bank, EMI or PSP willing to resell inquiry access (the same class of partner the aggregator track already contemplates), or it consumes title data only where a tenant's own gateway transaction already produced it. Title match is therefore a **phase-1.5 enrichment**, priced into the premium tier, never promised in v1 marketing until a partner is signed. Landed cost assumption: **PKR 3–6 per fetch** after partner margin **[planning assumption]**.

---

## 4. Legal & privacy — PECA, the draft PDPB, and the credit-bureau question

*This section is a research assessment, not legal advice; §7 makes a written legal opinion step one.*

### 4.1 PECA 2016 (as amended 2025) — the law that exists today

- Pakistan has **no enacted comprehensive data-protection law**; the Personal Data Protection Bill remains a draft (cabinet-approved 2023 version; the Senate-tracked 2023 bill was withdrawn in committee; still unenacted as of late 2026) **[industry — multiple legal guides concur]**.
- PECA is a criminal statute, but it bites commercially: **s.16** penalises obtaining/selling/using another person's *identity information* without authorisation (up to 3 years and/or PKR 5M fine) **[official — statute summaries]**; the 2025 amendment added an offence of **unauthorised disclosure of personal data (s.38)** **[industry — legal-guide reporting of the amendment]**. A phone number plus a behavioural score is personal data in any sensible reading; *selling* scores about identifiable people, built from data those people never gave us, is exactly the fact pattern to keep away from.
- Design consequences: (a) **no CNIC, ever** — the bureau keys on the phone number only; (b) scores are sold as *decision support about a transaction the querier is already in* (the querier supplies the number from their own customer relationship), never as browsable lists or raw data; (c) every contribution and query is contract-bound to a stated purpose.

### 4.2 Draft PDPB — design for the law that is coming

The draft bill (2023 text) follows the GDPR pattern: consent and purpose limitation, data-subject rights (access, correction), a National Commission for Personal Data Protection, breach duties, and meaningful penalties **[industry]**. A bureau designed today to PDPB standards — consent records, purpose binding, correction/deletion channel, retention limits — converts a future compliance shock into a marketing asset ("the only PDPB-ready trust network"). Two draft-specific cautions: drafts have contemplated **restrictions on processing "critical personal data" outside Pakistan** (host the bureau in-region / on existing Rektrs infrastructure) and **consent as the default lawful basis**, which for third-party-contributed outcome data is genuinely hard — the defensible basis is *contractual necessity + legitimate fraud-prevention purpose, disclosed to the customer by the contributing merchant at checkout* (a one-line disclosure in the merchant's terms: "order outcomes may be shared with fraud-prevention services"). This mirrors how SafeShip already positions its flag sharing.

### 4.3 The Credit Bureaus Act 2015 — the real boundary question

- A "credit bureau" under the Act is a **public limited company licensed by SBP** (s.2(h)); Rektrs is a *private* limited company, so Rektrs could not hold a bureau licence in its current form even if it wanted one **[official — Act text]**.
- "Credit information" (s.2(i)) covers (i) loans/credit facilities from credit institutions, (ii) guarantees, and — critically — **(iii) "the amounts and nature of commercial transactions, facilities and services entered into or availed of credit from non-financial companies… including retailers, insurance companies, utility providers and landlords *as notified by the Federal Government*"** **[official — Act text, sbp.org.pk]**.
- Assessment: a **fraud-prevention score for dispatch decisions**, built on communications and commerce outcomes and never used for lending, has a respectable argument for sitting *outside* the licensed activity — it is not a credit report, its subjects are not "debtors" of credit institutions, and its buyers are not making credit decisions. **But the boundary is contestable in both directions:** COD outcome data is arguably "commercial transaction" data under (iii); and the moment any buyer uses the score for **BNPL, device financing, or any credit decision** — or the product is *marketed* as a credit score — the activity drifts toward the Act, with unlicensed-bureau exposure. Tasdeeq's own prospectus notes the Act bars even licensed bureaus from side businesses, showing how jealously the perimeter is drawn **[industry]**.
- Engineering the boundary (conditions of the GO):
  1. **Name:** never launch under the word "Bureau" or "credit score". ("Number Trust Bureau" stays an internal codename. Public name: a *trust/fraud-prevention check*.)
  2. **Contractual permissible purposes:** fraud prevention and dispatch/fulfilment decisions only; express prohibition on credit, lending, employment and tenancy decisions; audit + termination rights.
  3. **No debtor data:** no loan/facility information is ever ingested — the data model in §3 contains none.
  4. **Written legal opinion** on CBA scope + PECA/PDPB design *before* the first paid query, and a standing option: if lender demand materialises, serve it only via partnership/white-label with a licensed bureau (Tasdeeq/DataCheck), never directly.

### 4.4 What the bureau may / may not sell (design rules)

**May:** a score + band + reason codes about a number the querier already transacts with; aggregate/anonymised statistics; the subject's own record to the subject (correction channel). **May not:** raw outcome histories; which tenant contributed what; lists of "bad numbers" for marketing; scores for credit/employment/tenancy decisions; anything keyed to CNIC. Negative flags must **decay** (proposed: full weight 6 months, decaying to zero by 12) — both for fairness and because operators recycle numbers, so an old flag may describe a different human today. A **dispute/correction route** (mirror bureau practice) is not optional garnish; it is the product's licence to operate socially.

---

## 5. Build path on the existing Sendqon stack

**Shape:** one new Sendqon plugin + one Rektrs-operated central service. The bureau database is inherently cross-tenant, so it cannot live inside any tenant's workspace: the plugin is the *client* (consent, contribution, query UI), the central service is the bureau.

- **Plugin `number_trust`** (type `tool`, following the B7 sim_fleet pattern): workspace settings (opt-in tier: *contribute + query* vs *query-only*), customer-disclosure text block for the tenant's checkout/terms, outcome-reporting endpoints, query screen + API keys page, dispute inbox. Plan-flag gated like the other B-series plugins (owner pricing decision untouched until launch).
- **Central scoring service:** normalised number → HMAC-hashed key (per-network salt); raw numbers never leave the contributing tenant's boundary except as the hash + outcome code. Event store (outcome events with source-class, evidence link, timestamps), aggregation job (rolling windows, decay), scoring v1 = transparent rules/points model (no ML until outcome volume justifies it — rules are explainable, which the legal design wants: every score ships with reason codes).
- **Contribution pipes (reuse, don't rebuild):** B5 WordPress/WooCommerce + Shopify plugins gain an "order outcome" webhook (delivered/returned/refused); core flows already produce confirmation outcomes; gateways already produce payment outcomes; HLR plugin is the enrichment client. A generic `POST /trust/report` covers everything else (Daraz sellers' CSV import included).
- **Query API:** `POST /api/v1/trust/check {number, purpose}` → `{score 0–100, band, reason_codes[], signals:{hlr_status, title_match, network_events, last_event_age}, cached:bool}`; sub-second from cache; first-sight enrichment synchronous where the provider allows, else score-now + enrich-async.
- **Tenant consent flow:** (1) workspace owner opts in and accepts the data-processing addendum (contribution licence, purposes, retention); (2) tenant publishes the one-line customer disclosure; (3) contribution starts with *system-generated* outcomes only (no free-text manual blacklists in v1 — see poisoning risk, §7); (4) query-only tenants pay a higher per-query price — contribution is the currency that discounts.
- **Effort [planning assumption]:** MVP (plugin + central service + rules scoring + HLR enrichment + Woo/Shopify outcome hooks + import tool + dispute inbox) ≈ **6–9 dev-weeks** for one engineer on the existing stack, excluding legal/partnership timelines. Title-fetch enrichment adds ~1 week once a partner API exists. ML scoring, courier feeds: phase 2.

---

## 6. Unit economics

**Benchmarks [official/industry]:** live HLR at global wholesale = $0.00385–$0.01/query (Twilio Line Status tiers; dedicated HLR providers ≈ €0.01) → **≈ PKR 1–3** at PKR ~277/USD. Title fetch wholesale PKR 1.55–2.50 **[official — 1LINK SOC]** → landed PKR 3–6 via a partner **[planning assumption]**. Buyers already pay ≈ PKR 16/order for a bundled score+confirmation product **[industry]**.

**Proposed price points [planning assumption, for owner decision]:**

| Tier | Price | What's inside |
|---|---|---|
| Network check (cached score + reason codes) | **PKR 5 / query** | Bureau history only; marginal cost ≈ PKR 0.5 (compute) |
| Fresh check (score + live HLR) | **PKR 9 / query** | Adds PKR 1–3 HLR cost |
| Verified check (score + HLR + title match) | **PKR 15 / query** | Adds PKR 3–6 title cost; phase 1.5, partner-dependent |
| Contributor discount | −40% on all tiers | Rewards the outcome feeds the network lives on |

Every tier is priced against the avoided loss: one prevented RTO saves PKR 800–2,000, so even the top tier costs ~1–2% of the loss it exists to prevent — the easiest ROI sentence in Pakistani e-commerce.

**Break-even [planning assumption]:** fixed run cost for the bureau at MVP scale (amortised build, infra on existing hosts, support, legal upkeep) ≈ **PKR 500k/month**. At a blended contribution of ≈ PKR 5/query (mix of cached/fresh, contributor-weighted), break-even ≈ **100,000 queries/month** — i.e., roughly **150–250 active sellers** checking most orders, or ~25 anchor-scale sellers plus a long tail. For calibration: a single 500-order/month seller on OrderWitness already spends PKR 7,999/month; the same seller spends ≈ PKR 2,500–4,500/month here at contributor pricing. The model does not need heroic adoption; it needs the anchor cohort of §3.2 plus organic attach inside Sendqon's existing tenant base.

---

## 7. Risks

1. **Data poisoning.** COD guides openly describe competitor fake-order attacks; a flag network is a weaponisable asset — a seller could flag a rival's best customers. *Mitigation (structural, not policy):* v1 accepts **only system-generated outcomes** tied to real orders/messages/payments in connected systems; manual flags excluded or weighted near-zero; per-contributor rate limits; contributor-reliability weighting (a contributor whose flags don't predict outcomes loses influence); evidence hash retained per event.
2. **Wrong-person harm.** Shared family numbers and operator number recycling mean a score can attach to the wrong human. *Mitigation:* decay (§4.4), recency-weighted scoring, "history may predate current owner" caveat via HLR/porting freshness, and a working correction channel from day one.
3. **Legal drift.** A buyer quietly using scores for BNPL decisions pulls the product toward the Credit Bureaus Act (§4.3). *Mitigation:* contractual purposes, marketing discipline, buyer audits, legal opinion first.
4. **Cold start / thin coverage.** Covered in §3.2; the pilot backtest (step 2 below) exists precisely to kill this risk with evidence before scale.
5. **Incumbent response.** SafeShip/ConfirmFlow add an API + telco signals; a courier productises its RTO data; Telesign enters via a local aggregator. *Mitigation:* speed + the two assets none of them hold — communications outcomes (only a messaging platform sees who answers/confirms) and payment-title signals.
6. **PDPB enactment mid-flight.** Draft-to-law changes (consent standard, localisation, registration) could force rework. *Mitigation:* PDPB-ready design from day one (§4.2) turns this into an advantage over every incumbent listed in §1.3, none of which publicly claims any such readiness.
7. **Trust asymmetry.** Merchants must believe the score predicts *their* RTO, not just describe the past. *Mitigation:* the pilot publishes per-tenant backtest lift (flagged-vs-unflagged delivery rates) before anyone pays.

---

## 8. Recommendation & first steps

**GO — WITH CONDITIONS.** Conditions: (i) launch scope is fraud-prevention/dispatch only, with the §4.3 naming and contract discipline; (ii) no manual-flag ingestion in v1; (iii) written legal opinion precedes the first paid query; (iv) title-fetch is sold only after a bank/EMI/PSP partner is signed.

**First 3 concrete steps:**

1. **Legal opinion (weeks 1–3).** External counsel opinion on three questions: Credit Bureaus Act scope for a dispatch-decision score; PECA ss.16/38 exposure of the contribution/query model; PDPB-readiness checklist sign-off. Deliverable gates everything below.
2. **Anchor pilot + offline backtest (weeks 2–8, parallel).** Sign 5 COD sellers (LOI: history import + 6 months of outcome feeds ↔ free queries). Import 12 months of their order outcomes, build the v1 rules score *offline*, and measure flagged-vs-unflagged delivery-rate separation on data the model never saw. **Kill criterion:** if the score cannot separate outcomes materially better than the sellers' current checks, stop — the network thesis is wrong and only the enrichment product (HLR + title) survives, which is a smaller but still sellable fallback.
3. **MVP build behind a feature flag (weeks 6–14).** `number_trust` plugin + central service per §5, pilot tenants only; activate the already-built HLR plugin's provider account (existing owner step) as the enrichment source; open the courier-partnership conversation with pilot metrics in hand.

---

## Sources (accessed 2026-11-19)

- Credit Bureaus Act 2015 — full text incl. s.2 definitions (sbp.org.pk; pakistanlawyer.com mirror).
- 1LINK Schedule of Charges, Jul–Dec 2026 — Title Fetch §1.6 (PKR 1.55 / 2.50); bank SOCs (Bank Makramah; OneZapp) for retail pass-through.
- Twilio Lookup pricing page (official) — Line Status/Line Type/Identity Match per-request prices; HLR-lookups.com ≈ €0.01/lookup (industry listings).
- Telesign Intelligence product + developer docs (score model; pricing not published). Ekata via Mastercard (pricing not published). Truecaller for Business (Exotel/Knowlarity partner pages).
- Tasdeeq IPO prospectus coverage (PSX prospectus; Mettis; PSX Updates) — licence date, 174 members, 41.5M records, CY2025 revenue PKR 318.4M. SBP/ABL bureau explainers — two licensed bureaus (Tasdeeq, DataCheck).
- OrderWitness (orderwitness.com + app.orderwitness.com) — published pricing PKR 7,999/mo/500 orders; RTO and loss-per-return figures. SafeShip Pakistan (safeship.dango.pk) — shared flag network mechanics. ConfirmFlow (confirmflow.pk) — Community Fraud Shield, 10k+ claim. OrderAudit (orderaudit.pk) — own-store risk score.
- COD economics guides (Muhammad Asad; DigiMap; TrackMyOrder) — RTO bands 15–40%, fake-order share ~8–10%, COD share 80–90%.
- PDPB status — legal guides (Recording Law; Offlist; Capital Estate; Chambers/DLA summaries): bill still draft, unenacted as of late 2026; PECA 2016 as amended Jan 2025.
- E-commerce market size — Statista-derived ~$5.77B (2025) via industry coverage; competing estimates $3.5B–$14.1B noted as unreliable spread.
