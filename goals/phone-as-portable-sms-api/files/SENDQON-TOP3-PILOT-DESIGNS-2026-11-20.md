# Sendqon — Top-3 Pilot Designs + Combined Legal-Opinion Brief

**Date:** 2026-11-20 · **Project:** Sendqon (Rektrs) · **Status:** PAPER ONLY — designs and a lawyer brief. Nothing here is a build, a pilot, a spend or an external contact. Every item below runs only on the owner's separate go-ahead, at the decision points named in §5.

**Mandate:** the closing section of the second-wave innovations research (`SENDQON-INNOVATIONS-RESEARCH-2-2026-11-20.md`): *"What attention means concretely: one combined legal opinion covering #1 + #4, the #1 anchor-seller backtest, the #4 Faisalabad udhaar pilot design, and the #6 e-commerce red-team pilot design."*

**Sources (only):** `SENDQON-INNOVATIONS-RESEARCH-2-2026-11-20.md` (§4 Gawah, §6 Insaan Check, closing ranking) · `SENDQON-INNOVATION-RESEARCH-NUMBER-TRUST-BUREAU-2026-11-19.md` · `SENDQON-INNOVATION-RESEARCH-BUREAU-SEED-DATA-2026-11-19.md` · `SENDQON-INNOVATIONS-LIST-2026-11-19.md`.

**Grading discipline (inherited from the research):** figures carry the research's own grades — **[official]**, **[industry]**, **[planning assumption]**. Anything this pack derives (thresholds, envelopes) is marked **[planning assumption]** and flagged where the owner must ratify it. No fee, participant, volume or commitment has been invented; where the research gives no number, this pack says so.

**Scope discipline:** these designs stay strictly inside the research verdicts. Gawah is never a "notarisation", never touches land-sale promises, and is never marketed as court-proof. Insaan Check is a ceremony, not a voiceprint product; templates are tenant-siloed; no bank tenant in the pilot. The Bureau ingests lawful data only, per the seed-data map and its never-touch list.

---

## 1. Combined legal-opinion brief — #1 Number Trust Bureau + #4 Gawah

One engagement, one firm, two products. The research is explicit that this opinion is *"the single highest-leverage spend in this report"*: it is gate zero for Gawah (nothing — not the pilot, not a customer, not a marketing claim — precedes it) and it precedes the Bureau's first paid query. The Bureau backtest (§2) is offline and free, so it may run in parallel; nothing commercial may.

### 1.1 The firm profile to brief (from the research)

A Pakistani firm with **evidence-law and telecom practice**, briefed on the **Notaries Ordinance 1961** (not the Indian Notaries Act 1952 — the research corrects this expressly), *Ishtiaq Ahmed Mirza v. Federation of Pakistan* (PLD 2019 SC 675), and the Supreme Court's March 2026 secret-recording judgment. (Gawah research §(d), §(f) "Gate zero".)

### 1.2 Facts pack — what counsel receives

So the opinion answers the real system, not a sketch, counsel gets:

**About Sendqon.** A live multi-channel messaging SaaS (Rektrs (Private) Limited) operating its own stack: Asterisk PBX with call recording/IVR/DTMF in production, an Android SIM-gateway app on real Pakistani SIMs, its own SMPP server (Jasmin), a WhatsApp bridge, an HLR lookup plugin, and a Raast route with account-title verification. Tenants (schools, clinics, e-commerce sellers and others) communicate with their customers through it daily, under their own customer relationships.

**For #4 Gawah — the flow to be opined on.** Both parties are connected *through* the PBX on a bridged call (never recorded on a party's handset). An Urdu announcement states the call will be recorded as a *gawahi* (witness) record; each party states their name and agreement on the record; only after affirmative consent from **both** parties does the promise segment begin — no consent means the IVR aborts and logs it, and retaining pre-consent audio is designed to be technically impossible. An IVR/AI-voice prompt walks the terms (who gives what, how much, by when) and reads a summary back for both parties to confirm. On hang-up the audio plus metadata (both numbers, SIM-registered names, optional Raast account titles, timestamps, consent timestamps, read-back transcript) is SHA-256 hashed, signed with Sendqon's key, and stored write-once with a hash-chained log; daily Merkle-root anchoring into an external timestamped medium is planned. Both parties receive a certificate (short code, e.g. `GW-` + 8 characters) by SMS/WhatsApp, checkable later by SMS/IVR code. A repudiation flow exists: notice to both numbers, objection attached to the record, never silently deleted. Playback/export is controlled and logged (both-party consent or court order). The seal is self-issued: Sendqon is **not** an ECAC-accredited certification service provider and claims no statutory presumption.

**For #1 Bureau — the data model to be opined on.** A phone-number-keyed trust/fraud-prevention check for dispatch and fulfilment decisions. Data in: (i) system-generated outcome events from connected systems only (message deliverability, order confirmation behaviour, call outcomes, payment outcomes, COD delivered/refused/returned outcomes reported through integrations) — **no free-text manual blacklists in v1, no loan/facility/debtor data ever, no CNIC ever**; (ii) lawful enrichment — SendPK HLR (Rs 1.56/lookup) and MNP (Rs 0.78/lookup) [official — vendor documentation, seed-data report], and title-match only where a tenant's own transaction produced it or a bank/EMI/PSP partner is later signed. Numbers are stored HMAC-hashed in a central service; scores are sold only as decision support about a transaction the querier is already in (the querier supplies the number from their own customer relationship) — never as browsable lists or raw data. Contributing merchants disclose sharing in their own customer terms ("order outcomes may be shared with fraud-prevention services"). Negative flags decay (proposed: full weight 6 months, to zero by 12). A subject dispute/correction channel exists from day one. Contractual permissible purposes: fraud prevention and dispatch/fulfilment only; credit, lending, employment and tenancy decisions expressly prohibited. The word "Bureau" is an internal codename and never ships publicly.

### 1.3 The exact question list

**Part A — Gawah (the research's five gate questions, §(d), verbatim in substance):**

- **A1. Admissibility & weight.** On the QSO Articles 46-A, 73 and 78-A and the PLD 2019 SC 675 authorities, is a platform-recorded, all-party-consented record admissible, and what weight should a district court give it — answered **by agreement type**: (i) udhaar/loans of goods or money, (ii) wages/piece-rates, (iii) rent/tenancy, (iv) sale of goods?
- **A2. Exclusions.** Confirm the ETO 2002 s.31 exclusions as scoped in the research — s.31(1)(e) immovable-property sale/conveyance, s.31(1)(a)–(d) negotiable instruments, powers of attorney, trusts, wills — and confirm the tenancy line **province by province** (the research notes Sindh's Rented Premises Ordinance 1979 s.5 requires writing; Punjab's position must be stated expressly).
- **A3. The seal.** Confirm the self-issued seal is an **ordinary** electronic signature (ETO s.8) carrying **no** s.9 advanced-signature presumption, and specify the lawful marketing language that follows — what may and may not be claimed for the certificate.
- **A4. Consent.** Confirm the announced, affirmative, both-party consent flow (with abort logging and the repudiation flow) satisfies PECA 2016 s.19, Telecom (Re-organization) Act 1996 s.31 and Article 14 of the Constitution as read in the March 2026 judgment.
- **A5. Name & certificate.** Confirm the name *Gawah/Gawahi*, the certificate wording and the Urdu/English "what this is / is not" disclaimers avoid the Notaries Ordinance 1961 and any holding-out of public office; and fix retention periods against limitation periods and the draft Personal Data Protection Bill 2023.

**Part B — Number Trust Bureau (from the Bureau report §4 and §8 step 1):**

- **B1. Credit Bureaus Act 2015 scope.** Is a fraud-prevention/dispatch-decision score — built on communications and commerce outcomes, never used for lending, holding no debtor data — outside the licensed "credit bureau" activity, given s.2(i)(iii)'s reach over "commercial transactions… from non-financial companies… *as notified by the Federal Government*"? What facts would pull it inside the Act, and are the §4.3 boundary conditions (naming, contractual purposes, no debtor data) sufficient?
- **B2. PECA exposure.** What is the exposure under PECA 2016 s.16 (identity information) and the 2025 amendment's s.38 (unauthorised disclosure of personal data) for the contribution/query model as described — tenant-contributed outcomes in, per-query scores out — and what contractual/technical terms close it?
- **B3. PDPB readiness.** Sign off (or correct) a PDPB-readiness checklist for the design as described: lawful basis for third-party-contributed outcome data (contractual necessity + disclosed fraud-prevention purpose), consent/disclosure wording, retention and flag-decay periods, subject access/correction channel, in-Pakistan hosting, breach duties.
- **B4. Seed-data legality.** Confirm the day-one seed stack is lawful as designed: SendPK HLR/MNP lookups, tenant-imported historical outcomes under LOI, bridge-observed public business-profile signals from genuine conversations only — and confirm the seed report's never-touch list (leaked SIM databases, CDR sellers, SIM-owner lookup services, resold caller-ID data, bulk scraping, industrialised PTA short-code checks, third-party WhatsApp checker APIs, any dataset without documented lawful provenance) is correctly excluded.

**Optional annex — #6 Insaan Check (owner's choice whether to include in this engagement).** The Insaan Check research (condition 5) independently requires a formal opinion **before the first paying tenant enrols anyone**: PDPB-draft posture for biometric templates, PECA exposure, recording/*analysis* consent (a new purpose beyond call recording), breach notification, and the tenant data-processing addendum. Its pilot *design* may proceed in parallel (§4), but commercial enrolment may not precede its opinion. Asking these questions in the same engagement is cheaper than a second one **[planning assumption — engagement economics, no fee evidence]**; the decision is the owner's (§5).

### 1.4 What a usable opinion looks like

- A **go / no-go answer per question** above — not a survey of possibilities. The research's rule for Gawah generalises: an opinion answering *"it depends"* to A1 or *"no"* to A4 stops that product scope; a narrower opinion means a narrower pilot, not a reinterpretation.
- For A3, the **actual permitted and prohibited claim wording** (certificate + marketing), not just the legal reasoning.
- For A5/B3, **fixed numbers**: retention periods and the disclosure/consent texts as approved wording.
- A counsel-signed pass over the **D7 chain-of-custody checklist** (who recorded; consent on the record; integrity — hash/WORM/hash-chain/anchoring; time discipline; identity anchors and their stated limits; custody log; named producing officer + PFSA route) — for Gawah, the research calls this checklist, counsel-signed, *"the pilot's real deliverable."*

### 1.5 What it unlocks

| Answer | Unlocks |
|---|---|
| A1–A5 satisfactory | Gawah pilot (§3) may be built and run exactly as designed; certificate wording and claims are lawful |
| A2 province answers | Whether tenancy enters Gawah phase 2, and where |
| B1–B4 satisfactory | Bureau's first **paid** query becomes lawful to sell; backtest (§2) results can be commercialised; the anchor cohort converts from free to paying |
| Annex (#6) satisfactory | Insaan Check commercial enrolment may begin after its pilot (§4) |

### 1.6 The fee — owner's spend decision, no invented figure

The research contains **no fee quote for a legal opinion**, and this pack invents none. The only lawyer-fee evidence anywhere in the sources is market context for *other* services: agreement drafting **Rs 15,000–35,000**, a legal notice Rs 10,000–25,000, breach-of-contract litigation Rs 150,000–600,000 **[industry — AskWakeel guideline; TaxHouse, via Gawah research §(a)]** — none of which prices a multi-question regulatory opinion. The Gawah break-even model carries **Rs 3–5 million of combined opinion/compliance/launch fixed costs** **[planning assumption — Gawah research §(e)]**, which is a programme envelope, not an opinion fee. The owner obtains the actual fee by engaging the firm; that engagement — and its fee — is **Decision D1** in §5. No lawyer is contacted by this pack.

---

## 2. #1 Number Trust Bureau — anchor-seller backtest design

The Bureau report's own kill-gate, run before scale spend (§8 step 2): *"if the score cannot separate outcomes materially better than the sellers' current checks, stop — the network thesis is wrong and only the enrichment product (HLR + title) survives."* This design runs that test offline, on history, for the cost of enrichment lookups only.

### 2.1 Objective

Score one year of historical COD order outcomes from a small anchor cohort with the v1 rules score, on data the model never saw during rule-setting, and measure whether flagged-vs-unflagged orders separate on delivered/refused/returned outcomes materially better than the sellers' current checks (manual confirmation calls, existing flag tools). Output is a written lift report per seller and pooled — the evidence on which the owner decides build/no-build for the MVP, and later the metrics taken into the courier-partnership conversation (Bureau report §3.2(5)).

### 2.2 Anchor-seller profile

- **Count:** 5 sellers signed by LOI (Bureau report §8 step 2); the wider seeding design contemplates 5–10 mid-size COD sellers (§3.2(4)).
- **Profile:** mid-size Pakistani COD sellers with digital order records (WooCommerce/Shopify/courier sheets), ~2,000 orders/month each **[planning assumption — volumes to be validated in pilot, Bureau report §3.2(4)]** — at that volume the cohort yields ≈20,000 outcome events/month prospectively and ≈120,000 historical orders over 12 months **[planning assumption — derived from the same volume figure]**.
- **LOI terms (from the research):** the seller imports 12 months of order outcomes and contributes 6 months of live outcome feeds; in exchange, free queries for 6 months. The LOI also carries the data-processing terms the legal opinion (§1, Part B) must bless: contribution licence, purposes, retention, the one-line customer disclosure in the seller's own terms.

### 2.3 Data inputs — lawful only

| Input | Source | Legality basis |
|---|---|---|
| 12 months of order outcomes (delivered / refused / returned, per number) | Anchor sellers' own systems, imported under LOI | Seller's own customer data, contributed under contract (§1 B2/B3 to confirm) |
| System-generated outcomes only | Connected systems (orders, messages, payments) | Bureau report §7 risk 1: **no free-text manual blacklists** in v1 — poisoning defence is structural |
| HLR liveness / ported / carrier enrichment | SendPK HLR **Rs 1.56**/lookup (no-answer free) [official — vendor documentation] | Seed-data report §1.1, §10 — the best lawful seed; note HLR live routes cover Zong/Telenor prefixes today |
| Ported status / current carrier | SendPK MNP **Rs 0.78**/lookup (Rs 0.25 cached repeat) [official — vendor documentation] | Seed-data report §1.1 |
| Day-one score shape | Reachability & Identity-Shape only (live/dead, ported, carrier, business-identity flags) | Seed-data report §10: **no seed source contains behaviour**; behaviour prediction comes only from the contributed outcomes themselves |

**Never-touch (seed-data report §12, excluded absolutely):** leaked SIM databases (name+CNIC), CDR sellers, SIM-owner lookup sites/APIs, resold caller-ID data, bulk scraping of Google/Facebook/OLX, automating 668/667 or industrialising 76367, third-party WhatsApp checker APIs, any dataset without documented lawful provenance in writing. **No CNIC is ingested at any point; the key is the phone number (HMAC-hashed in the central store).**

### 2.4 Method

1. **Import & normalise.** 12 months of outcomes per seller → normalised numbers → hashed keys + outcome codes with timestamps (Bureau report §5 event-store shape).
2. **Split.** Chronological holdout: rules are set on the earlier months and **frozen**; scoring runs on the later months the model never saw (Bureau report §8 step 2). No rule may be tuned after seeing holdout results — a second, final holdout slice is kept untouched for the confirmatory run **[planning assumption — method detail, this pack]**.
3. **Score.** v1 transparent rules/points model only (no ML — the research wants explainable reason codes, §5). Enrichment (HLR/MNP) runs on holdout numbers as the "first-sight" profile would.
4. **Compare.** Flagged-vs-unflagged delivery-rate separation on the holdout, per seller and pooled, against two baselines: (i) the seller's current practice (their own confirmation/flag outcomes, as recorded), and (ii) a no-score baseline (overall RTO). Report lift with the base rates visible — RTO context: industry sources converge on 20–35% typical, fake/prank orders ~8–10% of COD orders, loss per returned order PKR 800–2,000 **[industry — Bureau report §2]**.
5. **Publish internally.** Per-tenant lift report (Bureau report §7 risk 7: merchants must believe the score predicts *their* RTO) — this document is both the kill-gate evidence and the future sales asset.

### 2.5 Success / failure thresholds

- **Research kill criterion (verbatim substance):** if the score cannot separate outcomes **materially better than the sellers' current checks** → stop; only the enrichment product survives.
- **Numeric thresholds are NOT in the research** and must be fixed with the sellers and ratified by the owner **before** the holdout is scored (fixing them afterwards would void the test). Candidates this pack proposes for that ratification **[planning assumption — all three]**: (i) flagged band's RTO at least **2×** the unflagged band's RTO on the pooled holdout; (ii) the top-risk decile captures at least **30%** of all holdout RTOs while covering no more than ~10% of orders; (iii) separation holds in at least **4 of 5** sellers individually (a pooled-only effect is a one-seller artefact, not a network).

### 2.6 Duration, cost envelope

- **Duration:** weeks 2–8, in parallel with the legal opinion (weeks 1–3) — Bureau report §8.
- **Cost envelope (from the research; no lump sum exists in the sources):** sellers pay nothing (free queries are the consideration). Cash costs are enrichment lookups at the sourced unit prices — HLR Rs 1.56, MNP Rs 0.78 (Rs 0.25 cached) **[official]** — over the unique holdout numbers actually enriched; the total is volume-dependent and is **not** estimated here because the unique-number count is only known after import **[planning assumption — envelope shape, this pack]**. Engineering is the offline scoring build (rules model + import tooling), inside the report's overall MVP effort estimate of ≈6–9 dev-weeks **[planning assumption — Bureau report §5]**, of which the backtest uses the import + scoring parts only.

### 2.7 Risks + mitigations (Bureau report §7, applied to the backtest)

| Risk | Mitigation in this design |
|---|---|
| Data poisoning (sellers flag rivals' customers) | System-generated outcomes only; no manual flags; contributor-reliability weighting designed in from the start |
| Wrong-person harm (recycled/shared numbers) | Decay (full weight 6 months → zero by 12) [report proposal]; recency weighting; HLR/porting freshness caveat on every result |
| Legal drift (score quietly used for credit) | LOI permissible purposes (dispatch/fraud only); opinion (§1 Part B) precedes any paid use |
| Cold start / thin coverage | The backtest itself is the test of this; negative-first + enrichment-on-first-sight is the launch answer if it passes |
| Trust asymmetry | Per-seller lift published to that seller before anyone pays (§2.4 step 5) |

### 2.8 Owner decisions needed before it can run

1. **D2 — Approve anchor outreach + LOI terms** (5 sellers; the outreach itself is an external contact — owner's act or his explicit go-ahead; this pack contacts nobody).
2. **D3 — Activate the HLR plugin's provider account** (SendPK) — already an existing owner step in the programme; the backtest's enrichment depends on it.
3. **Ratify the §2.5 numeric thresholds** before the holdout is scored.
4. Note the dependency, not a decision: paid/commercial use of results waits for the §1 opinion (Part B).

---

## 3. #4 Gawah — Faisalabad udhaar pilot design

Research basis: Gawah §(f) "Smallest honest pilot", §(c) feasibility, §(d) legal, §(e) economics, and the eight verdict conditions. **Gate zero stands above everything in this section: the §1 legal opinion (Part A) is obtained and acted on before any build beyond paper prototypes, any customer, or any marketing claim. An adverse answer on A1 (admissibility) or A4 (consent) is a NO-GO, not a redesign prompt.**

### 3.1 Participants

- **Segment (one, named by the research):** wholesale-to-retail **udhaar** — dry-goods/kiryana wholesalers supplying small retailers on **15–30 day spoken credit**. Repeat transactions; amounts **Rs 30,000–300,000**, where proof matters and lawyers don't; an existing documentation habit (the *parchi*) to upgrade; and a built-in outcome measure — *was the invoice paid on the promised date?*
- **Count:** **15–25 wholesalers** in **Faisalabad** (one city — a documented parchi-market trade hub, in Punjab, whose e-stamp/PFSA/court-fee facts the research verified most completely; Karachi is expressly deferred as second city). Onboarded in person via existing tenant/channel relationships.
- **Counterparties:** the wholesalers' retailers, who consent **per call** — no standing-consent fiction.

### 3.2 The deal flow (existing PBX + SIM stack only)

1. **Bridge.** Both parties are connected through Sendqon's PBX (bridged/call-me-back conference). Recording happens platform-side, in the ordinary course, never on a party's handset — custody begins here (D7 item 1).
2. **Consent ceremony** (outline in §3.3) — announcement + both parties' affirmative consent, on the record, at the head of the same audio file.
3. **Terms walk.** IVR/AI-voice prompt walks the bargain: who gives what, how much, by when. Each party states their full name on the recording (SIM-binding mitigation, §(c)(4)).
4. **Read-back.** The system reads the summary back; both parties confirm. (The read-back doubles as the transcript anchor, reducing ASR dependence — §(e).)
5. **Optional second anchor.** Each party may confirm the Raast ID on the same number; the fetched account title enters the seal as a cross-check against the SIM name — an enhancement grade, **never a gate** excluding the unbanked (§(c)(5)).
6. **Seal on hang-up.** SHA-256 of audio + metadata (both numbers, SIM names, Raast titles where used, times, consent timestamps, read-back transcript), signed with Sendqon's key, WORM storage, hash-chained log, external anchoring artefacts accumulated (SMPP receipts, CDR/HLR records, daily Merkle root) (§(c)(2)).
7. **Certificate to both parties** by SMS via own gateway/Jasmin (and WhatsApp/PDF where available): short code (`GW-` + 8) + hash fragment. Delivery to *both* numbers is itself a control — a non-participating SIM holder can repudiate immediately.
8. **Verification for life of the record, free:** SMS the code or call the IVR → date/time, both names (masked numbers), terms summary, "record intact — hash verified" (the PTA 668 pattern users already understand).
9. **Repudiation flow:** notice to both numbers; objection attached to the record; never silently deleted.
10. **Dispute path (staffed during the pilot):** the evidence-pack function — transcript, custody extract, officer statement, PFSA handling — timed and costed as it runs (retail price hypothesis Rs 4,999, §3.5).

All records are built to the **D7 chain-of-custody checklist** from the first call (§1.4).

### 3.3 Consent script outline

*Outline only — the research specifies the ceremony's legal shape, not verbatim wording; final Urdu/English wording is counsel-approved under §1 A4/A5 before the pilot.*

1. **Announcement (Urdu first, loud and unhurried):** this call is being arranged by the Gawah service; it will be recorded as a *gawahi* (witness) record of the bargain the two parties are about to make; the record will be sealed, kept by the service, and a certificate code sent to both numbers.
2. **What it is / is not (D5 discipline, in the script, not just the terms):** it is a tamper-evident record of a consented conversation between two identified numbers — **not** a notarial act, not a registered deed, not a government certificate, and not described as court-proof.
3. **Self-identification:** each party states their full name.
4. **Affirmative consent, per party:** an explicit spoken "yes" (with DTMF confirmation logged) from **each** party, captured before any promise terms are spoken.
5. **Abort rule, stated and engineered:** if either party does not consent, recording does not begin / the IVR aborts and logs it; retaining pre-consent audio is technically impossible in the build. *No consent, no recording* — no exceptions, no record-first-ask-later.
6. **Repudiation notice:** either party is told they may object afterwards; the objection will be attached to the record and both numbers notified.
7. **Terms + read-back + dual confirmation** (§3.2 steps 3–4) follow only after 1–6 complete.

### 3.4 What gets recorded and sealed

The promise segment audio with the consent ceremony at its head (same file); both phone numbers; SIM-registered names; on-record self-identifications; optional Raast account titles; timestamps (NTP-disciplined clocks, corroborated by SMS receipts/CDRs); the read-back transcript made at seal time; the hash + hash-chain entry + external anchor references; the full custody/access log. Retention as fixed by counsel under §1 A5 (research proposal for testing: 6 years metadata/transcript, shorter and extendable for raw audio **[planning assumption — Gawah §(d) D6]**).

### 3.5 Pricing test

- **During the pilot: certificates free** (price tested separately — research §(f)).
- **Anchors from the research [planning assumption — Gawah §(e), no willingness-to-pay survey exists]:** retail **Rs 499** per certificate (one party pays, both receive); tenant-bundled **Rs 299** in volume packs; verification free for the record's life; dispute evidence pack **Rs 4,999** (against the Rs 10,000–25,000 legal-notice alternative **[industry]**).
- **The test (day 60):** real-money pricing is offered to pilot wholesalers. **Success = ≥40% convert at Rs 299+ effective price. Kill = conversion <20%** (the payer thesis in §(a) was wrong). Payment is measured, not enthusiasm.

### 3.6 Success metrics — all four must pass (research §(f))

1. **Completion:** ≥60% of initiated calls reach a sealed certificate; below that, the flow — not the market — is presumed broken.
2. **Behavioural truth:** sealed deals show measurably better on-time payment than the same wholesalers' unsealed deals (**target ≥10 points**), **or** ≥3 disputes settled using the record without court.
3. **Price truth:** day-60 conversion test (§3.5) passes at ≥40%.
4. **Legal truth:** independent counsel reviews **20 sealed records** against PLD 2019 SC 675 at **day 45**, reporting gaps in writing; pass = zero launch-blocking D7 defects and no consent/repudiation incident the logs cannot explain.

**Kill criteria (any one stops scale-up):** the opinion fails gate zero; a sealed record is rejected in a live dispute *for a defect in our custody/consent engineering*; a single consent/privacy incident; price conversion <20%.

### 3.7 Hard exclusions (enforced in the product, not just the terms)

- **No immovable-property sale/conveyance promises** — ETO s.31(1)(e); the IVR itself screens out land-sale promises. Nothing styled as a negotiable instrument, power of attorney, trust or will — s.31(1)(a)–(d).
- **No "notary / notarised / notarisation" language in any language**, in product, certificate or marketing; no "court-proof", statutory-presumption or registered-deed-equivalence claims (the seal is an ordinary electronic signature, ETO s.8, with no s.9 presumption — unless/until an accredited-CSP countersignature is contractible and counsel signs off, condition 6).
- **Tenancy is phase 2 only**, after the province-wise opinion (§1 A2). **Consumer one-off lending is not tested** (no repeat economics). Land/plot deals are not "phase 2" — they are out.

### 3.8 Gate placement, duration, cost envelope

- **Gate placement:** opinion (§1 Part A) → build → day-45 counsel record review → day-60 price test → day-90 verdict against §3.6. No stage starts early.
- **Duration:** **90 days** (research §(f)).
- **Cost envelope (from the research):** marginal cost per sealed certificate **~Rs 95** (build-up Rs 64–126: bridged call ~7 min Rs 30–50; SMS ×4 Rs 6–10; Raast check Rs 0–5; storage Rs 3–6; hashing/sealing/transcription Rs 10–25; support/aborts amortised Rs 15–30 at ~25% of attempts not sealing) **[planning assumption — Gawah §(e), discounted from published anchors: SMS Rs 3.80–4.80 retail [industry], PTA prepaid voice Rs 2.68–3.60/min [official]]**. Pilot certificates are free, so the pilot's variable cost is ~Rs 95 × sealed certificates plus abort minutes — total volume depends on wholesaler activity and is not pre-estimated here. Fixed costs sit inside the research's **Rs 3–5 million opinion/compliance/launch envelope [planning assumption]**; break-even at retail pricing ≈ 8,000–13,000 certificates, which is why the repeat-buyer segment choice matters.

### 3.9 Owner decisions needed

1. **D1** — the legal opinion itself (§1) — absolute gate.
2. **D4** — after the opinion lands: approve the pilot as designed (segment, city, 90 days, free certificates, day-60 price test) and approve wholesaler onboarding (external contact — owner's act or go-ahead).
3. Ratify the certificate wording/disclaimers as counsel settles them under A5.

---

## 4. #6 Insaan Check — e-commerce red-team pilot design

Research basis: Insaan Check §(f) "Smallest honest pilot", §(c) latency budget, §(d) legal, §(e) economics, and the eight verdict conditions. **Design rule above all: build the ceremony, not the voiceprint.** Possession + code-word are gates; the voiceprint is an internal signal that may only escalate to human review — it never passes a caller who failed a gate and never blocks a caller who passed both.

### 4.1 Tenant profile + the one fraud pattern

- **One existing Sendqon e-commerce tenant** (research §(f): *"One segment, one pattern"*; condition 5's first steps: *"Sign one existing e-commerce tenant to the pilot agreement"*). Non-bank by design — SBP-supervised tenants carry outsourcing/audit weight the pilot doesn't need (§(d)); **bank tenants are out of scope**.
- **One fraud pattern: refund bank-detail change by phone** — a caller asks for a refund to be redirected to a new IBAN/wallet. High value, irreversible on Raast, low frequency (so ceremony friction is tolerable), clean ground truth.
- **Invocation is risk-triggered only** (condition 7): this pattern, plus tenant rule templates (amount thresholds, bank-detail changes, number-age/velocity triggers). Never on every call.

### 4.2 Enrolment plan (~300 customers)

- **300–500 customers over 2–3 weeks** (research §(f)); the phased first step is the **first 300** (research "First three steps").
- **Consent is a ceremony, not a settings toggle (§(d)):** explicit, **recorded**, revocable consent in the customer's language (Urdu + English), covering what is captured (voice samples/template), why (in-call verification for the named tenant/purpose), how long it is kept, and how to withdraw — withdrawal actually deletes the template, provably in logs.
- **Code-word:** customer-set at enrolment **via an already-trusted channel — never on an unverified inbound call**; stored **hashed, per relationship**; Sendqon never holds a readable list.
- **Voiceprint (optional leg):** ~20-second enrolment phrases; template (embedding) extracted, encrypted, stored in the **per-tenant silo**; raw enrolment audio deleted on a short published schedule.
- **Regulator-language discipline (condition 8):** enrolment and every ceremony explain that the service asks only for the customer's **own pre-agreed Insaan Check word** — never an OTP, PIN, password or CNIC (PTA's public advice is that no genuine organisation asks for codes on a call). If a low-literacy customer in Urdu cannot be made to understand that distinction unmistakably, the word moves to **DTMF entry** and the script is re-tested before launch.
- **Kill criterion:** enrolment completion **below 50%** → the product fails regardless of matching accuracy **[planning assumption — exact threshold to be fixed with the tenant before launch, research §(f)]**.
- **Hard architecture:** per-tenant encrypted template silos; **no cross-tenant matching function exists in code or API** (not "off by default" — not implemented); no covert enrolment from ordinary calls, ever.

### 4.3 The ceremony under test

1. **Possession:** callback to the enrolled number (SIM possession leg, over own SMPP/SIM-gateway routes).
2. **Random-phrase readback:** STT content check on the phrase; voiceprint score recorded **as a signal only**.
3. **Code-word:** the customer's pre-agreed word (speech or DTMF per §4.2), checked against the per-relationship hash.
4. **Verdict:** signed verdict object — *"insaan hai, wahi hai"* + which legs passed + timestamp + call reference — logged and webhook-delivered. **Failure routes to today's slower manual process: no genuine customer is ever worse off, only slower.**

### 4.4 The red team — five attack cases, pass criteria (research §(f), the acceptance test)

For consenting participants ("attack my account"):

| # | Attack | What it tests | Pass criterion |
|---|---|---|---|
| i | **Replay** of a genuine recorded excerpt | Liveness of the random phrase | Attack fails to obtain a pass verdict |
| ii | **Offline clone** (ElevenLabs-class, from <1 minute of consented audio) played into the call | Clone vs phrase + code-word gates | Attack fails to obtain a pass verdict |
| iii | **Real-time voice conversion** against the random phrase | The hardest case for the voiceprint leg | Attack fails to obtain a pass verdict — **if (iii) defeats the voiceprint signal but is stopped by the code-word, that is a PASS for the product** and a published internal finding about the voiceprint (the outcome §(c) predicts, designed in advance) |
| iv | **Pure social engineering** — correct name/order/address, **no code-word** | The code-word gate itself | Attack fails; **red-team false accepts on the code-word gate: 0 across the full set — any one stops the pilot** |
| v | **Enrolled-number-only** attempt (stolen unlocked phone simulation) | Possession alone must not suffice | Attack fails to obtain a pass verdict |

**Overall pass = all five fail to obtain a pass verdict, AND the logs correctly name the leg that stopped each attack.** Any code-word-gate false accept, or genuine-customer false rejects above ceiling after one remediation round, stops expansion (condition 6).

### 4.5 Measurements to capture (targets pre-registered in the pilot agreement)

| Metric | Target (research §(f)) |
|---|---|
| Genuine-customer false rejects (possession + word, first attempt) | **≤ 5%**; ≥95% complete within two attempts or human fallback in ≤3 extra minutes |
| Ceremony duration | **Median ≤ 75 s, p90 ≤ 120 s** added to the call (component budget 45–75 s **[planning assumption]**: prompt+readback ~10 s; STT ~300 ms–1 s; embedding scoring <1 s; code-word entry ~10 s; verdict assembly + webhook <2 s — the human performing the ceremony, not the computation, is the bottleneck) |
| Voiceprint on real pilot audio | **Measure and report the actual EER / score distributions on AMR call audio** — success is a measured number, whatever it is; it decides whether the leg survives into v1. (Planning expectation from §(c): budget a 5–12% EER operating region on real Pakistani mobile audio until the pilot measures otherwise; ASVspoof 5's best system errs 8.61% on modern adversarial tests.) |
| Fraud outcome | **Zero** successful phone-channel refund-redirections during the pilot, against a documented prior-period baseline |
| Customer experience | **≥80%** rate the ceremony "reassuring" rather than "annoying" in a post-call SMS survey |
| Enrolment completion | ≥50% (§4.2 kill criterion) |

### 4.6 Pricing test

- **Anchor [planning assumption — research §(e), proposal not market data]: Rs 35 per completed check** (≈$0.126); Rs 25 at >10,000 checks/month committed volume; Rs 49 for a high-assurance verdict (all three legs + human review of failures). **Billed on completed verdicts only**, never on abandoned ceremonies (Twilio's successful-verification trigger).
- **Cost side [planning assumption, built from published components]:** marginal cost **≈ Rs 8–18 per completed check** (ceremony minute Rs 3–7; SIM leg Rs 1–3; STT Rs 0.2–1.2; voiceprint + anti-spoofing scoring <Rs 2; platform/logging/verdict/support Rs 3–6). Gross margin at Rs 35 ≈ 50–75%. Anchors: Twilio Verify ≈ Rs 16 all-in per successful verification **[official]**; Pindrop $0.05–$0.30/call behind a $50,000 platform minimum **[official]**; the manual-callback alternative costs Rs 57–95 in human time with no signed record.
- **Never priced:** a cross-tenant check — §(d) forbids the product, so the price list must not imply it exists.

### 4.7 Out of scope (research §(f) + conditions)

Bank tenants · account recovery · any cross-tenant enrolment or matching · voiceprint as a sole gate · minors · any marketing using "accuracy", "99%" or "fraud-proof" · any positioning as identity proofing / KYC / a NADRA substitute (it authenticates a caller inside an existing, already-KYC'd relationship — nothing more) · family B2C launch (until the pilot reports).

### 4.8 Gate placement, duration, cost envelope

- **Gates:** pilot *design* and build may proceed in parallel with legal work; **commercial enrolment may not precede the §1-annex opinion** (condition 5: PDPB-draft posture, PECA exposure, recording/analysis consent, breach notification, tenant data-processing addendum). Targets in §4.5 are written into the pilot agreement **before enrolment begins**.
- **Duration:** **6–8 weeks including enrolment [planning assumption — research §(f)]**.
- **Cost envelope:** engineering is bounded (Asterisk IVR flow + STT + hashed-secret store + siloed embedding store + verdict API/webhook on the existing platform); running cost is the per-check marginal (Rs 8–18) over pilot volume. The research gives **no lump-sum pilot budget**, and none is invented here.

### 4.9 Owner decisions needed

1. **D5** — approve including the #6 questions in the §1 engagement (annex) or commissioning them separately; either way the opinion precedes commercial enrolment.
2. **D6** — approve the pilot tenant selection + pilot agreement with §4.5 targets written in (tenant contact is external — owner's act or go-ahead), and ratify the Rs 35 anchor as the post-pilot price test.

---

## 5. Sequencing — what runs first, the owner's decision points, the one-page summary

### 5.1 Order of operations (and why)

1. **The combined legal opinion goes first — it gates two of the three programmes.** Gawah may not be built for a customer, piloted or marketed before it (gate zero); the Bureau may not sell a paid query before it. It is also the cheapest item in the pack relative to what it unlocks, and the research names it the highest-leverage spend in the entire innovations programme. The #6 annex rides with it if the owner chooses (D5) — Insaan Check's *design* doesn't wait for it, but its commercial enrolment does.
2. **The Bureau backtest runs in parallel with the opinion (weeks 2–8).** It is offline, historical and free to sellers, so no legal gate blocks it — and its kill criterion exists precisely to be answered *before* scale spend. If the score fails to separate, the programme stops at the enrichment product and the Gawah/Insaan tracks are unaffected. Its own prerequisites are the anchor LOIs (D2) and the HLR provider account (D3).
3. **The Gawah pilot starts only after the opinion lands favourably** (D4), then runs its own internal gates: build → day-45 counsel review of 20 sealed records → day-60 real-money price test → day-90 four-criteria verdict. Its records begin feeding the Bureau's data model from day one of the pilot — the interlock the research designed (every Gawah record is the Bureau's highest-quality signal).
4. **The Insaan Check pilot designs in parallel, enrols after its opinion condition is met** (D5/D6), and runs 6–8 weeks. It shares no gate with Gawah except the (optional) combined opinion engagement, and no dependency with the Bureau — it can start whenever the owner calls it, subject to the opinion-before-commercial-enrolment rule.
5. **Nothing scales on enthusiasm.** Each track carries pre-registered kill criteria (§2.5, §3.6, §4.4–4.5). A track that fails its gate stops; the research verdicts, not this pack, define what "fail" means.

### 5.2 The owner's exact decision points

| # | Decision | When | What it commits |
|---|---|---|---|
| **D1** | Engage Pakistani counsel (evidence-law + telecom practice) on the §1 brief, and accept the fee counsel quotes | First — before everything commercial | The opinion fee (owner's spend; no figure exists in the research — §1.6) |
| **D2** | Approve anchor-seller outreach + LOI terms (5 COD sellers; 12-month history import + 6-month outcome feeds ↔ 6 months free queries) | With D1 (backtest runs parallel) | External contact with sellers — owner's act or his explicit go-ahead |
| **D3** | Activate the HLR plugin's provider account (SendPK) | With D2 | An existing programme owner step; enables backtest enrichment at Rs 1.56/HLR + Rs 0.78/MNP [official] |
| **D4** | After a favourable opinion: approve the Gawah pilot (Faisalabad udhaar, 15–25 wholesalers, 90 days, free certificates, day-60 price test) + wholesaler onboarding | On the opinion's arrival | Pilot running costs (~Rs 95 marginal per sealed certificate [planning assumption]) inside the research's fixed-cost envelope |
| **D5** | Include the #6 Insaan Check questions in the D1 engagement (annex) or commission separately | With D1 | That commercial enrolment for #6 waits for its opinion either way |
| **D6** | Approve the Insaan Check pilot: one existing e-commerce tenant, pilot agreement with §4.5 targets written in, Rs 35/check post-pilot price anchor | After D5's opinion path is set | Tenant contact (external) + bounded engineering; per-check marginal Rs 8–18 [planning assumption] |
| **D7** | Ratify the numbers the research deliberately left open: §2.5 backtest thresholds (before the holdout is scored), Gawah Rs 499/299 price anchors, Insaan Check Rs 35 anchor | Before the relevant test runs | Nothing spends on an unratified number |

### 5.3 One-page summary

| Design | Gate | First spend | First revenue signal |
|---|---|---|---|
| **Combined legal opinion (#1 + #4, optional #6 annex)** | Is itself the gate — D1 | Counsel's fee, on engagement (amount not in the research; owner's decision) | None directly — it *unlocks* the other three rows |
| **#1 Bureau anchor backtest** | D2 (LOIs) + D3 (HLR account); §2.5 thresholds ratified (D7) before scoring; paid queries wait for the opinion | Enrichment lookups at sourced unit prices (HLR Rs 1.56, MNP Rs 0.78 [official]) over imported history | Measured per-seller lift on the holdout → converts anchors from free to paying after the opinion (tiers proposed in the research: Rs 5/9/15 per query [planning assumption]) |
| **#4 Gawah Faisalabad pilot** | Opinion Part A favourable (gate zero) → D4; day-45 counsel review; day-90 four-criteria verdict | Pilot running costs: ~Rs 95 marginal per sealed certificate [planning assumption]; certificates free during the pilot | **Day-60 price test:** ≥40% of wholesalers convert at Rs 299+ (kill <20%) — the first real-money signal in the programme |
| **#6 Insaan Check red-team pilot** | Opinion (annex or separate) before commercial enrolment; pilot agreement with pre-registered targets (D6) | Bounded engineering + Rs 8–18 marginal per completed check [planning assumption] | Post-pilot billing at **Rs 35 per completed check** [planning assumption anchor] — billable only on completed verdicts, from the first tenant |

### 5.4 What this pack is not

Not a build order, not a pilot launch, not a spend approval, not an engagement of counsel, and not contact with any seller, wholesaler, tenant or lawyer. It is the paper the research mandated, so that when the owner says the word, each track starts from a design whose gates, numbers and kill criteria were fixed *before* anyone had results to protect.

---

*Prepared 2026-11-20 from the innovations research of 2026-11-19/20. All research verdicts and conditions govern over this pack where they differ; figures are graded as in the sources, and derived figures are marked [planning assumption] throughout.*
