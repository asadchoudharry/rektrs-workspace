# Sendqon — Becoming an SMS Aggregator in Pakistan: Feasibility Report

**Prepared for:** Assad, Founder & CEO, Rektrs (Private) Limited
**Date:** 18 November 2026
**Status:** Research only. No application filed, no operator contacted, no production change made.
**Question:** Can Rektrs become an SMS aggregator itself — file customers' branded-SMS masks directly with PTA, hold its own operator interconnects, keep the aggregator margin, and eventually sell wholesale — and what exactly does it take?

**How to read this report:** Every material figure is graded.
✅ **VERIFIED** = read on an official source (PTA) on 18 Nov 2026. 📰 **INDUSTRY** = published by aggregators/operators/industry guides — real, but not an official tariff. ❓ **UNVERIFIED** = could not be confirmed from any published source; listed again in §6 (Open Questions). Estimates built by Muse are labelled **ESTIMATE** with their assumptions stated — they are planning numbers, not facts.

---

## Executive Verdict

**Yes — Rektrs can become an SMS aggregator, and the regulatory door is much cheaper and more open than expected. The hard part is not PTA; it is the operators.**

The single most important finding of this research — it corrects the assumption this project started with ("aggregator = CVAS licence"):

> **"SMS Aggregator Services" is not a CVAS *Licence* category at all. It is a CVAS *Registration* category** — listed in PTA's own Category Selection Form (Annexure-D of the official CVAS checklist) under "Class Value Added Registered Services: SMS Aggregator Services · Content Services · Voice Mail Services." ✅

What that means in money and effort:

| Item | Figure | Grade |
|---|---|---|
| PTA CVAS Registration fee (SMS Aggregator Services) | **Rs 10,000 one-time** | ✅ PTA Fee Schedule |
| Registration term | **5 years**, nationwide | ✅ PTA Fee Schedule |
| Annual PTA fee on Registration | **None shown** on the published schedule (the 0.5%-of-AGR annual fee applies to CVAS *Licence* holders) | ✅ schedule; confirm at filing (§6 Q5) |
| The expensive route (Data & Voice CVAS Licence: Rs 5,500 processing + Rs 300,000 initial + 0.5% AGR/yr, 15 yrs) | **Not required for SMS aggregation — and new Data/Voice licence applications are currently SUSPENDED anyway** | ✅ PTA Class VAS public notice |
| Is the Registration window open today? | **Yes** — PTA's Class VAS notice expressly keeps "Class Registration in both Pakistan and AJ&K and GB" open while licences are suspended, and PTA's published register shows commercial aggregators (Cequens, E Ocean, One Network, Evamp & Saanga, 16 Messaging, Kalsym Systems…) holding exactly this registration | ✅ PTA Class VAS page + PTA CVAS Registration list |

**The real gate is commercial, not regulatory.** PTA's own checklist makes a **copy of the Service Level Agreement(s) with operator(s) for SMS Aggregator Services a required part of the Registration application pack** (checklist item 14, "For CVAS Registration Applicants only"). ✅ So the sequence is: win at least one operator interconnect agreement first (or in parallel), then file. Operators publish **no** onboarding terms — no minimum volumes, deposits, or wholesale tariffs are public anywhere (❓, §3). Incumbents' interconnects were built over years (SendPK: operating since 2014). A zero-volume newcomer should expect a prepaid, relationship-driven negotiation, not a sign-up form.

**Cost to stand up (detail in §5):**

- Hard external cost excluding operator money: **≈ Rs 60,000 – 200,000** (PTA fee Rs 10,000; documents/stamp paper nominal; optional professional help). ESTIMATE
- Operator prepaid traffic float / possible deposits: **unknown until negotiated** — carry a planning envelope of **Rs 1.0 – 3.0 million** of *working capital* (float is spent on traffic, not sunk). ESTIMATE / ❓
- The true ongoing cost is **compliance operations**: DNCR scrubbing, consent records, content screening, complaint handling — a standing desk, not a certificate.
- Timeline: reseller revenue can start in **days–weeks**; mask approvals run **30–45 business days** regardless of who files (PTA's own pace 📰); the Registration + first direct interconnect is a **quarter-scale** project, dominated by operator negotiation time, not PTA processing (no official PTA processing timeline is published — ❓).

**Recommended path (§5):** Phase A — resell through an incumbent now (masks start filing, revenue starts, volume proof builds) → Phase B — file the CVAS Registration in parallel → Phase C — first direct interconnect on our own SMPP switch (pull the B9 Jasmin build forward) → Phase D — migrate tenant traffic to own binds, then consider wholesale. **Do not wait for direct interconnect to start selling masks.**

**Owner decisions needed:** listed at the end of §5 (7 items). The only one that gates everything else: **GO / NO-GO on filing the CVAS Registration.**

---

## 1. PTA Licensing — the CVAS Registration route

### 1.1 Which category covers SMS aggregation

PTA's Class Value Added Services (CVAS) regime has two tiers:

- **CVAS Licence** — Data CVAS (Data Services / Internet Services / Vehicle Tracking) and Voice CVAS (Card Pay Phone / Premium Rate / Trunk Radio). Commercial nationwide Data & Voice licence: Rs 5,500 processing + Rs 300,000 initial + 0.5% of Annual Gross Revenue per year, 15-year term. ✅ (PTA Fee Schedule, row 06)
- **CVAS Registration** — a lighter tier for "Class Value Added Registered Services": **SMS Aggregator Services**, Content Services, Voice Mail Services (Category Selection Form, Annexure-D of the official checklist). ✅ **This is Rektrs' category.**

PTA's published register of CVAS Registrations confirms the category is live and commercial: it lists, among many others, Cequens Telecom, E Ocean (Pvt.) Ltd, One Network (Pvt.) Ltd, Evamp & Saanga, 16 Messaging (Pvt.) Ltd and Kalsym Systems as **"CVAS Registration — SMS Aggregator"**, with registration numbers in the series DIR(L)/CVAS-11xx/PTA/2021 and 5-year terms. ✅ (PTA, *List of CVAS Registrations*, 15-01-2026 edition)

### 1.2 Is the window open?

Yes. PTA's Class VAS public notice states that Class Licences for Voice and Data services in Pakistan and AJ&K/GB **"shall be suspended/stopped till further notice except for Class License for Internet Services at District Level in Pakistan and Class Registration in both Pakistan and AJ&K and GB"** — i.e., Registration applications continue to be received and processed. ✅ (PTA Class VAS Licenses page) PTA's complaint-management correspondence points would-be aggregators the same way: approach the Licensing Division at PTA HQs, Islamabad "for CVAS registration," and the Service Division for short-code allocation. 📰 (PTA complaint response, publicly reproduced)

### 1.3 Eligibility

- A **Pakistani company** — the checklist is built around SECP incorporation (Certificate of Incorporation, Memorandum & Articles, Form-29, Form-A). Rektrs (Private) Limited qualifies; SECP registration and NTN are already in place.
- Commercial or Not-for-Profit basis — Rektrs files as **Commercial**.
- Jurisdiction: **Nationwide** (the fee schedule's Registration row is nationwide; AJ&K & GB has a separate Rs 3,000 registration — see §6 Q12).
- Directors/shareholders must satisfy the Annexure-H undertaking: never insolvent, no major convictions, **no defaults against PTA** on any licence/transaction.
- Technical competence must be shown (Section 1 of the checklist): key management's telecom qualifications/experience, a network/technical plan, equipment details, and compliance with the **Critical Telecom Data and Infrastructure Security Regulations, 2020**.

### 1.4 Fees (all ✅ from PTA's published Fee Schedule, accessed 18 Nov 2026)

| Fee | Amount | Notes |
|---|---|---|
| CVAS Registration fee | **Rs 10,000 one-time** | Payable with the application (checklist Annexure-B: "One time Registration Fee of Rs. 10,000/-") |
| Initial licence fee | — | None for Registration |
| Annual fee | — | None shown on the schedule for Registration (contrast: CVAS Licence = 0.5% of AGR annually) |
| Term | **5 years** | Renewal at the same schedule |
| AJ&K & GB Registration (if ever needed separately) | Rs 3,000 | Separate jurisdiction row |
| Undertaking stamp paper | Rs 100 | Judicial stamp paper, notarized (Annexure-H) |

Payment mechanics per the checklist: Pay Order / Demand Draft in the name of "Pakistan Telecommunication Authority" (the PTA CVAS FAQ also lists direct deposit at NBP, Marriott Hotel Branch, Islamabad, A/C "Pakistan Telecommunication Authority").

For contrast — the route we do **not** need: a consultancy currently advertises a full CVAS *licence* package at Rs 720,000 all-in (including the Rs 300,000 licence fee and Rs 150,000 consultancy). 📰 That is licence-route pricing; a Registration filing is a fraction of it, and is realistic to file in-house.

### 1.5 Application process, step by step

1. **Assemble the application pack** per the official checklist (documents in §1.6), each section segregated and flagged — "Incomplete application shall be returned un-actioned."
2. **Secure the operator SLA(s)** — checklist item 14 requires copies of the SLA(s) with operator(s) for SMS Aggregator Services from Registration applicants. This is the gating item (§3).
3. **Address the application** to the Director General (Licensing), PTA HQs, F-5/1, Islamabad, on company letterhead (Annexure-A format), with the fee instrument.
4. **File** — paper pack to the Licensing Division; PTA also runs an online licensing portal (the Class VAS page carries "Apply Online for License (OASIS)"; PTA's January 2026 licensing press release directs applicants to eservices.pta.gov.pk). Confirm the live filing channel with the Licensing Division at filing time.
5. **PTA processing** — no official timeline is published (❓ §6 Q2). The published register shows registrations granted continuously since 2020.
6. **Grant** — registration number in the DIR(L)/CVAS-xxxx/PTA/yyyy series, 5-year term, listed on PTA's public CVAS Registration list.
7. **Short code (optional, separate)** — allocation of a short code is a Service Division matter on its own prescribed form, distinct from the Registration. Needed only if Rektrs wants its own 2-way/OTP short-code identity (§5, decision 5).

### 1.6 Required documents (official checklist, ✅)

| # | Document | Rektrs status |
|---|---|---|
| 1 | Application letter on company letterhead (Annexure-A) | Prepare |
| 2 | Fee — Rs 10,000 pay order/demand draft (Annexure-B) | Prepare |
| 3 | Applicant Profile Form (Annexure-C) | Prepare |
| 4 | Category Selection Form — Commercial / Registered Services / **SMS Aggregator Services** / Nationwide (Annexure-D) | Prepare |
| 5 | Directors/BoD details incl. CNICs, contacts, other directorships (Annexure-E) + SECP Form-29 (CTC ≤ 3 months old) | Obtain fresh CTCs |
| 6 | Authorization letter for the correspondent with PTA, signed by all directors (Annexure-F) | Prepare |
| 7 | Complete scanned soft copy of the application | Prepare |
| 8 | **Section 1 — Technical:** management competence summary; detailed network/technical plan & architecture; equipment list reconciled with project cost; CTDISR-2020 compliance | Prepare (Sendqon/Jasmin architecture is the substance) |
| 9 | SECP Certificate of Incorporation (CTC ≤ 3 months) | Obtain fresh CTC |
| 10 | Memorandum & Articles of Association (CTC ≤ 3 months) | Obtain fresh CTC |
| 11 | Shareholders list + SECP Form-A (CTC ≤ 3 months) (Annexure-G) | Obtain fresh CTC |
| 12 | CNIC copies of directors / authorized representatives | In hand |
| 13 | Undertaking on Rs 100 judicial stamp paper, notarized (Annexure-H) | Prepare |
| 14 | **Copy of SLA(s) with operator(s) for SMS Aggregator Services** (Registration applicants) | **Gating item — §3** |
| 15 | Report on economic viability & benefits to users (Section 4) | Prepare |

Note what Registration applicants are **spared**: checklist Section 2 (business plan, audited financials, 5-year projections, bank statements) is marked **"For CVAS License Applicants Only."** The Registration pack is materially lighter than a licence pack.

### 1.7 Timeline

- PTA Registration processing: **no published timeline** (❓). The register's grant pattern suggests routine, continuous processing.
- Mask approvals (a separate, per-customer process — §2.4): **30–45 business days**, published by SendPK and consistent with our own November 2026 market research; it cannot be expedited. 📰
- Operator interconnect negotiation: unbounded — the long pole (§3).

---

## 2. Regulatory Operating Duties — the Spam Regulations as they bind an aggregator

### 2.1 The rulebook

The operative law is the **Protection from Spam, Unsolicited, Fraudulent and Obnoxious Communication Regulations, 2009** (S.R.O. 713(I)/2009), as amended in 2020 and substantially rewritten by the **Second Amendment Regulations, 2022** (S.R.O. 2402(I)/2022, Gazette of Pakistan, 31 December 2022). ✅ (regulation identity/SRO numbers per PTA's regulations page as read by multiple sources, §7) The amended regulations import the definition of "spamming" from **section 25 of the Prevention of Electronic Crimes Act, 2016 (PECA)** — so spam is not merely a contract issue; it has a criminal-law hook.

**How the duties reach an aggregator:** the regulations bind the **operators** directly (each operator must run an anti-spam SOP, register telemarketers, maintain the Do-Not-Call Register, and act against offenders). Aggregators and telemarketers are bound (a) directly, where the amended text addresses them (consent, approved sender identities, SLAs), and (b) contractually, through the operator SLAs and the operators' SOPs. In practice — as the incumbent SendPK states publicly — PTA-recognized aggregator status is "not a one-time certificate, but a continuing operating standard," with the aggregator's sender-ID registrations, KYC records and traffic patterns subject to PTA/operator audit. 📰

### 2.2 The duties, one by one

| Duty | What it requires of Rektrs as aggregator | Source |
|---|---|---|
| **Approved sender identities only** | Marketing traffic may go out **only through approved short codes or alphanumeric IDs allocated by the Authority**; alphanumeric IDs are mapped against short codes. No sending from ordinary numbers or unregistered names. | Reg. 6(1)(b), 2022 amendment ✅/📰 |
| **SLA chain** | Telemarketers must contract with an SMS aggregator or operator under an SLA specifying the services provided through the allocated short codes/IDs. As aggregator, Rektrs sits in the middle of this chain: operator SLA above, customer SLAs below. PTA may call for SLAs. | Reg. 6, 2022 amendment 📰 |
| **Consent before marketing** | Individual consent must be sought **by message, in English and Urdu**, before marketing messages are sent to a subscriber. | Reg. 6(1)(a)(i) 📰 |
| **Consent records** | The sender must **keep a record of each individual consent**, producible in a dispute or audit. For Rektrs this means a per-tenant, per-recipient consent store — not just a checkbox claim. | Reg. 6(1)(a)(ii) 📰 |
| **Unsubscribe option** | Anyone engaged in direct marketing must offer an option to unsubscribe from promotional messages. | Reg. 4(3) 📰 |
| **Promotional hours** | Operators must ensure opted-in promotional messages are **received within "normal business hours."** The regulation fixes **no clock times**. Industry guides commonly apply ≈ **09:00–21:00 PKT**; some aggregator material cites 08:00–21:00. The enforceable window will be whatever our operator SLAs say — treat **08:00–21:00 PKT as the outer bound** in Sendqon defaults until an SLA says otherwise. OTP/transactional traffic is not promotional and is exempt. | Reg. 4(3) proviso ✅ (text); clock window 📰/❓ (§6 Q6) |
| **DNCR scrubbing** | Operators must maintain the consolidated **Central Do-Not-Call Register (C-DNCR)**; subscribers join/leave by SMS to **3627**; operators update the register within **two working days** of a request. Marketing sent to a person who has not consented **and** is on the C-DNCR is, by definition, unsolicited communication. The aggregator's operational duty: **suppress C-DNCR numbers from every promotional campaign** — via the access mechanism the operator SLA provides (feed, API, or list exchange; mechanics are not public — ❓ §6 Q10). | Reg. 7; Reg. 9(3) (2009) 📰 |
| **Telemarketer registration** | Operators must ensure telemarketers sending through them are registered. Our customer onboarding (KYC + SLA) is how this duty is discharged in practice. | Reg. 8(1) 📰 |
| **Content screening** | Operators must run regularly updated anti-spam filters over on-net and off-net traffic; aggregators are expected to screen content before it reaches the operator. Published prohibited-category practice includes gambling/betting, alcohol, adult/dating, political and religious content. A mask may not be used for both promotional and transactional traffic (operator rule). | Regs + operator practice 📰 |
| **Complaint handling** | Subscribers report spam by forwarding to **9000**. The enforcement ladder for obnoxious communication: **first warning → suspension of the originating subscription no later than 24 hours after a repeat complaint → blacklist → permanent blocking**; a suspended subscription is restored only with PTA approval and a written undertaking. As aggregator we must run a complaint desk that can trace any message to tenant + consent record fast enough to work this ladder. | 2022 amendment 📰 |
| **Audits & records** | Aggregator KYC files, sender-ID approvals and delivery records are auditable by PTA and operators; consent evidence for a flagged campaign can be demanded. Retention periods are set by operator/PTA expectations (incumbents publish retention schedules; no single official period was found — fold into SLA negotiation). | 📰 |

A secondary guide claims fines "up to Rs 500,000" under the 2009 regulations; that figure was **not verified from the Gazette text** in this research and is recorded as ❓ (§6 Q7). The verified exposure is the ladder above (suspension/blacklist of the sending identity — commercially fatal if it is our shared route) plus PECA criminal exposure for fraudulent/spoofed traffic.

### 2.3 Sender-ID (mask) registration workflow — who files what

This is the workflow Rektrs would own as aggregator (today an incumbent owns it for us):

1. **Customer prepares** a stamped application on its own company letterhead: requested mask (**3–11 English characters incl. spaces**), complete registered company name, business office address, authorized representative's name + designation + **CNIC**, company **NTN**, company stamp + representative's signature. ✅/📰 (SendPK's published requirements, matching PTA's process)
2. **Aggregator submits** the application to PTA for approval of the mask name.
3. **PTA approves or rejects.** Rejection rules: mask does not match the NTN-registered business name; mask is a domain name; mask is an individual/common/religious name; letterhead/NTN unverifiable. A mask is registered in **one business name only — never shared, leased or sub-let**.
4. **Operator registration:** the approved mask is then registered with each operator before it can send live traffic.
5. **Timeline: 30–45 business days** end-to-end; cannot be expedited. 📰 (SendPK)
6. **Fees at retail today:** SendPK charges the customer **Rs 5,000 one-time approval + Rs 5,000/year renewal**; Veevo Tech publishes **Rs 3,000 setup + Rs 2,000/year**. ✅ (both verified live in our November 2026 market research) Whether PTA or the operators charge the *aggregator* anything per mask is **not published** (❓ §6 Q4) — if the underlying cost is nil or nominal, this retail fee line becomes almost pure margin for Rektrs, and the 30–45-day wait stays the same because it is PTA's pace, not the aggregator's.

### 2.4 The June 2026 Corporate SMS consultation — why it matters to aggregator economics

On **4 June 2026** PTA published its *Consultation Paper on Identification of "Corporate SMS" as a Relevant Market for SMP Determination* (comments due 19 June 2026). ✅ (PTA, official PDF; Business Recorder, 4 June 2026)

- PTA's preliminary view: **Corporate SMS** (bulk alerts, transaction notifications, promotions, government messaging — sold by operators directly **or through CVAS licensees and aggregators**) is a **distinct relevant market**.
- Each operator holds **Significant Market Power** in it, because SMS termination is a monopoly: every operator controls 100% of delivery to its own subscribers, so aggregators "cannot restrain operator pricing."
- Operators were directed to file **audit-certified average rates and revenues for 1 Jan 2023 – 31 Dec 2025**, split by banking-transactional, banking-marketing and other sectors, for direct **and aggregator** traffic.
- **Status: consultation, not a determination.** No final SMP determination was found as of this research. If it lands with tariff remedies, operator wholesale pricing to aggregators could be regulated — plausibly *improving* aggregator margins, but the direction and size are unknowable today. **Budget on current rates; treat any remedy as upside.** This consultation is also the strongest public evidence that PTA sees aggregators as a permanent, named part of the market structure — the category is not a loophole that is about to close.

---

## 3. Operator Interconnect — the real entry bar

### 3.1 Who the counterparties are now

Pakistan's mobile market consolidated in 2026. There are **three operator groups** to interconnect with:

| Group | Networks | Note |
|---|---|---|
| **Jazz** (PMCL) | Jazz + Warid ranges | Market leader |
| **Zong** (CMPak) | Zong | China Mobile subsidiary |
| **PTML** | Ufone + **former Telenor Pakistan** | Telenor Pakistan was acquired by PTCL (completed 31 Dec 2025) and **amalgamated into PTML effective 1 July 2026** (Islamabad High Court approved); Telenor Pakistan no longer exists as a separate company. One PTML agreement now covers both subscriber bases. ✅/📰 |

Mask behaviour differs by network (industry-reported 📰): alphanumeric masks display on Jazz and Zong; on Ufone/ex-Telenor ranges the sender is presented via a numeric short code instead. Verify PTML's current presentation in onboarding (§6 Q11).

### 3.2 What an interconnect actually consists of

Per operator, a commercial **interconnect/aggregator agreement + SLA** (the same document PTA's checklist wants copied into our Registration pack) covering:

- **SMPP bind provisioning** — SMPP 3.4 binds (typically transceiver), throughput (TPS) windows, source-IP whitelisting / VPN, bind credentials, test window, go-live certification.
- **Sender-ID desk** — the operator-side registration of PTA-approved masks (§2.3 step 4), per-operator formatting/filter rules.
- **Billing model** — the industry norm is **prepaid credit** consumed per submitted message; post-paid invoicing exists only for established enterprise accounts under signed agreements (SendPK's published customer terms mirror exactly this structure downstream 📰). Expect Rektrs to start prepaid with every operator.
- **Delivery reporting** — SMPP delivery receipts (DLRs) plus operator-side reporting/reconciliation.
- **Compliance annexes** — content rules, DNCR suppression mechanics, complaint cooperation, audit rights (the flow-down of §2).

### 3.3 The entry bar — stated honestly

**No operator publishes aggregator onboarding terms.** Minimum volume commitments, security deposits, bank guarantees and wholesale tariffs appear in **no** public source found — not on operator sites, not in PTA publications, not in incumbent marketing (❓ §6 Q1). Anyone quoting exact figures publicly is guessing. What *is* publicly established:

- The **PTA checklist itself makes the operator SLA the gate**: without at least one operator agreement, the Registration pack is incomplete. Operators therefore decide who becomes an aggregator in practice.
- Incumbents describe "direct, PTA-recognized interconnection with all four mobile network operators" built over years (SendPK: in the market since 2014 📰). Their moat is these relationships plus traffic history — precisely what our phased plan (§5) builds.
- **International** A2P into Pakistan is intermediated by exclusive/preferred hubs (industry-reported: Jazz–Sinch for international A2P; Ufone/ex-Telenor–GMS; Zong–GMS/Acmetel/CMI 📰). That is a different channel from **domestic** aggregation, but it shows the operators' preference for a small number of vetted, volume-carrying partners.
- The realistic newcomer sequence everywhere in this industry: **start as a paying, compliant, growing customer of an incumbent → build documented volume and a clean compliance record → negotiate direct binds with that record in hand.** A zero-volume cold approach to an operator wholesale desk is the weakest possible negotiating position; the same approach at a few hundred thousand SMS/month with 6 months of clean traffic is a different conversation.

### 3.4 Rate bands — what is actually known

| Layer | Figure | Grade |
|---|---|---|
| Retail branded (masked) SMS, low volume | **Rs 3.80–3.90/SMS** (SendPK); **Rs 3.15** (Veevo); flat **Rs 4.30** (Pak Sender) | ✅ verified live, project research Nov 2026 |
| Retail branded at volume | **Rs 3.20 @ 5,000 → Rs 2.70 @ 5,000,000 SMS** (BSMS published ladder) | ✅/📰 (older crawl) |
| Retail short-code OTP | **Rs 4.70–4.80/SMS** (SendPK) | ✅ verified live |
| Mask fees at retail | Rs 5,000 + Rs 5,000/yr (SendPK); Rs 3,000 + Rs 2,000/yr (Veevo) | ✅ verified live |
| International "direct route" indication | ≈ **$0.0075/SMS (~Rs 2.1)** base claimed by international direct-route sellers for Pakistan | 📰 not an operator tariff |
| **Operator → aggregator wholesale** | **Not published anywhere.** Logical bound: it must sit at or below the ~Rs 2.70 high-volume retail floor for incumbent economics to work. The June 2026 consultation exists precisely because stakeholders say operator Corporate SMS pricing is high relative to P2P on the same infrastructure. | ❓ + inference, labelled as such |

**Margin shape (scenario math, assumptions stated):** if direct wholesale lands in a Rs 2.50–3.00 band while reseller purchase sits at Rs 3.15–3.80, moving traffic to own binds saves roughly **Rs 0.45–0.85 per SMS**. At 250k SMS/month that is ≈ Rs 1.1–2.1 lakh/month; at 1M/month ≈ Rs 4.5–8.5 lakh/month — before the cost of the ops desk that carries it. Plus mask-fee margin (§2.3) and the wholesale option (§5 Phase D). These are scenarios to negotiate against, not forecasts.

---

## 4. Platform Readiness — what Rektrs already has vs what is missing

### 4.1 Already in hand ✅

| Capability | State |
|---|---|
| Legal entity | Rektrs (Private) Limited — SECP-registered, NTN in place. The two hard prerequisites for both the Registration and mask filings. |
| Customer platform | **Sendqon is live** (sendqon.rektrs.com): tenant workspaces, plans, PKR billing, credits — the customer-facing half of an aggregator already exists and is selling. |
| Mask workflow in-panel | The **PTA Mask plugin (B2) is ACTIVE in production**: tenant applies in-panel (mask rules enforced: 3–11 chars, ≥1 letter; NTN format checked; duplicate approved mask refused), admin reviews/approves with a stamped audit trail. Today its output is a packet for an incumbent to file; as aggregator, the same screens become our own filing desk. |
| SMPP client side | The vendor SMPP companion server is **live and licensed** — Sendqon can already speak SMPP toward an aggregator/operator bind as a *client*. |
| Deliverability tooling | **HLR validation plugin** (B4, activates with a provider account), **spam-score plugin** (B4, advisory content scoring in EN/Urdu/Roman Urdu), **cascade plugin** (WhatsApp→SMS→email) — the bones of a deliverability/compliance layer. |
| Operations discipline | Nightly backups with off-site replica, uptime monitoring, a patch register, staged deploys — the operational hygiene an operator audit expects. |
| Traffic to aggregate | Sendqon's own tenant base is a built-in first customer: every tenant SMS bought through a reseller today is margin already identified. |

### 4.2 Missing — the build/buy list ❌

| Gap | What it takes |
|---|---|
| **CVAS Registration** | §1 — Rs 10,000 + the document pack. Gated on the operator SLA copy. |
| **Operator SLAs + SMPP binds** | §3 — negotiation, then per-operator bind provisioning and go-live testing. |
| **Operator-facing SMPP switch** | Sendqon is a customer platform, not an operator-grade SMSC. The plan already carries this as the **B9 own-SMPP-server item (Jasmin, open source)**: multi-bind routing, per-operator TPS shaping, DLR handling, failover between own binds and the reseller route. Recommendation: pull it forward to Phase C (§5). Until it exists, direct binds have nowhere proper to land. |
| **DNCR scrubbing integration** | A suppression pipeline wired into Sendqon's campaign preflight (the HLR preflight hook is the natural seam) fed by whatever C-DNCR mechanism the operator SLAs provide (feed/API/list — §6 Q10). **No promotional traffic moves to own binds before this is live.** |
| **Consent-record store** | Per-tenant, per-recipient consent evidence (timestamp, bilingual consent text, channel) queryable in seconds for audits/complaints. Sendqon has contacts and opt-outs; the *evidence* layer is new work. |
| **Complaint / NOC desk** | A named owner for 9000-complaint traces, operator escalations and PTA correspondence, with response inside the 24-hour ladder (§2.2). Starts as one compliance-ops hire + founder escalation; true 24/7 cover only at scale. |
| **DLR reconciliation & float management** | Per-operator delivery reconciliation and prepaid-float tracking/alerting (a bind that runs dry mid-campaign is an outage). Finance-ops tooling on top of Jasmin + Sendqon billing. |
| **Short code (optional)** | Own short code from PTA's Service Division if we want a 2-way/OTP identity of our own (fees/timeline unpublished — §6 Q8). Not required to start. |

**Readiness verdict:** Rektrs is unusually well positioned for the *customer* half (platform, mask workflow, billing, entity) and has **none** of the *operator* half yet (registration, SLAs, switch, DNCR, desk). That is exactly the normal shape of a Phase-A reseller — the gaps are buildable/negotiable in one quarter, not structural blockers.

---

## 5. Economics and the Recommended Path

### 5.1 Cost to stand up

| Item | Amount | Grade / basis |
|---|---|---|
| PTA CVAS Registration fee | **Rs 10,000** one-time (5-year term) | ✅ official schedule |
| Documents (SECP CTCs, stamp paper Rs 100, notarization) | < Rs 10,000 | ESTIMATE — nominal official charges |
| Professional help (optional; in-house filing is realistic) | Rs 0 – 150,000 | ESTIMATE — market data point: full CVAS *licence* consultancy packages advertise ≈ Rs 150,000 consultancy; Registration-only help should be at the low end |
| Platform build (Jasmin switch, DNCR scrub, consent store, reconciliation) | Internal engineering time; incremental infra ≈ Rs 0 – 25,000/mo on existing Oracle footprint | ESTIMATE |
| Compliance-ops staffing (year 1 shape: 1 hire + founder escalation) | ≈ Rs 80,000 – 150,000/mo salary band | ESTIMATE — market band for an ops/compliance officer in PK tech |
| **Operator prepaid floats / any deposits** | **Unknown until negotiated** — planning envelope **Rs 1.0 – 3.0 million** total across 3 operator groups | ❓ terms unpublished; envelope is a planning assumption, **working capital, not sunk cost** |
| **Total hard external cost (excl. floats)** | **≈ Rs 60,000 – 200,000** | ESTIMATE from the rows above |
| Annual PTA cost thereafter | Rs 0 on the published schedule (renewal Rs 10,000 at year 5) | ✅ schedule; confirm at filing (§6 Q5) |

The honest headline: **the licence is nearly free; the business is not.** Capital sits in operator floats, and cost sits in people who run compliance every day.

### 5.2 The phased path

**Phase A — Reseller now (weeks 0–6).** Sign with an incumbent aggregator (get written quotes from SendPK and Veevo: per-SMS by volume tier, mask fees, SMPP/API terms, DNCR handling). File the **REKTRS mask** and the first tenant masks through them — the 30–45-business-day PTA clock starts now, not after our registration. Connect Sendqon tenants through the incumbent's SMPP/API (fits the live SMPP provider machinery). Sell masks at retail; keep the reseller spread; log real volume + delivery data per operator.
*Exit criteria:* live tenant traffic flowing; ≥3 months of clean, documented volume building.

**Phase B — Registration in parallel (weeks 2–10).** Assemble the §1.6 pack (fresh SECP CTCs, technical plan from the Sendqon/Jasmin architecture, viability report). Approach the operators' corporate/wholesale desks during Phase A — as a CVAS-registration applicant with growing traffic, not a cold caller — and obtain the SLA(s) the checklist requires. File the Registration. Owner decision 2 (below) sets in-house vs consultant filing.
*Exit criteria:* Registration granted (DIR(L)/CVAS number) or formally in process with SLA(s) in hand.

**Phase C — First direct interconnect (quarter 2).** Pull the **B9 Jasmin SMPP server forward**; provision the first operator bind (start with whichever operator gives the best newcomer terms); land **DNCR scrubbing + consent store before any promotional traffic moves**; run dual-route (own bind primary, reseller failover) per operator.
*Exit criteria:* one operator terminating on our own bind with DLR reconciliation clean for a full month.

**Phase D — Migrate and (optionally) wholesale (quarter 3+).** Move tenant traffic route-by-route to own binds; file all masks directly (the B2 PTA plugin becomes the filing desk end-to-end); only after delivery quality is proven, decide whether to sell aggregation wholesale to other SaaS/resellers. Track the **Corporate SMS SMP determination** — a tariff remedy changes the wholesale math in our favour or against it; re-price when it lands.

**Volume logic:** direct interconnect beats reseller economics when the monthly spread saved (§3.4: ≈ Rs 0.45–0.85/SMS) covers the incremental ops cost of running binds (≈ one ops salary + infra ≈ Rs 1.0–1.75 lakh/mo) — i.e. at roughly **200k–400k SMS/month** of sustained tenant traffic, or earlier if a single anchor tenant signs. Below that, reseller margin leakage is cheaper than an ops desk. These thresholds are ESTIMATES from the stated bands, to be re-based on the actual quotes Phase A produces.

### 5.3 Decisions the owner must personally make

1. **GO / NO-GO: file the CVAS Registration** (SMS Aggregator Services) under Rektrs — trivial fee, real compliance commitment.
2. **First reseller partner:** SendPK (published Rs 3.80–3.90 branded; Rs 5,000/5,000 mask fees; deepest published compliance apparatus) vs Veevo (Rs 3.15; Rs 3,000/2,000 mask fees) — or dual-home both for route redundancy. (Quotes to be taken in Phase A; this report recommends taking both quotes before choosing.)
3. **Capital envelope:** approve a ceiling for operator prepaid floats (planning figure Rs 1.0–3.0M) — released per operator as SLAs are signed, not before.
4. **Pull Jasmin forward:** approve moving the own-SMPP-server build from B9 to Phase C of this programme.
5. **Own short code:** apply to PTA's Service Division for a short code (2-way/OTP identity) at launch, or stay mask-only until Phase D?
6. **Staffing:** hire one compliance/ops officer for the complaint/NOC desk, or run it founder-led until Phase C?
7. **Wholesale ambition:** is third-party wholesale (Phase D) an approved goal, or is aggregation to stay captive to Sendqon tenants?

---

## 6. Open Questions — what could not be verified from official sources

1. **Operator commercial terms:** minimum volume commitments, security deposits / bank guarantees, prepaid thresholds, and wholesale per-SMS tariffs for direct aggregator interconnect with Jazz, Zong and PTML are published **nowhere**. Obtainable only in negotiation. *This is the single largest unknown in the programme.*
2. **CVAS Registration processing time:** no official timeline is published. (The 30–45 business days figure is for *mask* approvals, published by SendPK — a different process.)
3. **SLA sufficiency for the Registration pack:** the checklist requires "SLA(s) with operator(s)" — whether one operator's SLA suffices, or PTA expects broader coverage, is unstated. Confirm with the Licensing Division when the first SLA is in hand.
4. **Per-mask charges to the aggregator:** incumbents charge customers Rs 5,000 + Rs 5,000/yr (SendPK) or Rs 3,000 + Rs 2,000/yr (Veevo), but whether PTA/operators levy any underlying per-mask fee on the aggregator is unpublished.
5. **Annual fee on Registration:** the published fee schedule shows none (the 0.5%-of-AGR annual fee is listed against CVAS *Licences*). Confirm at filing that no AGR-based fee attaches to Registration.
6. **Promotional-hours clock window:** the regulation says "normal business hours" without times; guides cite ≈09:00–21:00, some aggregator material 08:00–21:00. The binding window will be in each operator's SLA/SOP.
7. **Monetary penalties under the Spam Regulations:** a secondary guide claims fines up to Rs 500,000; not verified from the Gazette text in this research. The verified sanctions are the warning → suspension → blacklist ladder plus PECA exposure.
8. **Short-code allocation:** fees, timeline and eligibility for a PTA-allocated short code (Service Division) are not in the fee-schedule material reviewed.
9. **Corporate SMS SMP determination:** consultation closed 19 June 2026; no final determination found as of 18 Nov 2026. Remedies, if any, unknown.
10. **C-DNCR access mechanics for aggregators:** whether suppression works via an operator-provided feed/API, per-campaign list checks, or network-side blocking only (SendPK notes DND numbers may be blocked at network level regardless) is defined per operator SOP/SLA — not public.
11. **Mask display on PTML:** industry guides say Ufone/ex-Telenor present a numeric short-code sender rather than the alphanumeric mask, while incumbents market masks as "registered with all four operators." Verify actual handset presentation per network in Phase A testing.
12. **AJ&K & GB:** the fee schedule carries a separate AJ&K & GB CVAS Registration (Rs 3,000). Whether the Pakistan registration's "Nationwide" jurisdiction covers AJ&K/GB termination for aggregator purposes should be confirmed if that traffic matters.

---

## 7. Sources (accessed 18 November 2026)

**Official — Pakistan Telecommunication Authority (pta.gov.pk)**
1. Fee Schedule — https://www.pta.gov.pk/category/fee-schedule-1221054389-2023-05-30 (CVAS Registration Rs 10,000 / 5 years; Data & Voice CVAS Licence Rs 5,500 + Rs 300,000/100,000/50,000 + 0.5% AGR, 15 years)
2. Class VAS Licenses (public notice: licences suspended except District Internet + Class Registration) — https://www.pta.gov.pk/index.php/category/class-vas-licenses-588174-2023-05-30
3. Public Notice for CVAS Licenses — https://pta.gov.pk/index.php/category/public-notice-for-cvas-licenses-864741199-2023-06-01
4. List of CVAS Registrations (15-01-2026) — https://www.pta.gov.pk/assets/media/2026-01-19-List-of-CVAS-Registrations-dated-15-01-26.pdf (commercial SMS aggregators holding CVAS Registration)
5. Consultation Paper on Identification of "Corporate SMS" as a Relevant Market for SMP Determination (04-06-2026) — https://www.pta.gov.pk/assets/media/2026-06-04-2026-06-04-~-Consultation-Paper-Corporate-SMS-Relevant-Market-SMP-Determination-Final.pdf
6. Checklist — Application for Class Value Added Services License/Registration for Pakistan (PTA document; the same checklist PTA links from its Class VAS page — copy read at https://ptca.pk/new/wp-content/uploads/2023/12/Application-Form.pdf ): Category Form (SMS Aggregator Services = Registered Service), item 14 (operator SLA for Registration applicants), Annexure-B fees, document list
7. PTA CVAS FAQ (PTA document, copy at https://www.scribd.com/document/649133488/faq-cvas-lic-070120 ): processing Rs 5,500, Registration Rs 10,000/5 years, payment routes

**Industry / aggregator published material**
8. BroadNet — *Pakistan A2P SMS 2026: PTA Rules, DNCR & Sender IDs* (reviewed 26 Sep 2026) — https://www.broadnet.me/blog/pakistan-a2p-sms-pta-sender-id-guide-2026 (regulation-by-regulation reading of the 2009 Regulations as amended 2022; consultation summary)
9. SendPK — *PTA Compliance — SMS Aggregator Regulations* — https://www.sendpk.com/pta-compliance.php (mask workflow, KYC contents, 30–45 business days, interconnect claims)
10. SendPK — Terms & Conditions — https://bulksms.com.pk/terms-conditions.php (prepaid credits model; interconnect agreements per operator)
11. Rektrs project research — *Sendqon Market Pricing, Pakistan* (16 Nov 2026; prices verified live) — `~/workspace/research_notes/sendqon-market-pricing-pakistan-20261116-0937/report.md` (SendPK Rs 3.80–3.90 + Rs 5,000/5,000 mask; Veevo Rs 3.15 + Rs 3,000/2,000; BSMS Rs 3.20→2.70 ladder; OTP Rs 4.70–4.80)
12. Sent Resources — *Pakistan SMS Guide* — https://www.sent.dm/resources/sms-compliance/pakistan-sms-guide (international A2P hub partnerships; sending-window practice)
13. Business Recorder — *PTA moves to declare corporate SMS a separate market* (4 Jun 2026) — https://www.brecorder.com/news/40423992
14. Telenor Pakistan / PTML amalgamation (effective 1 Jul 2026) — https://en.wikipedia.org/wiki/Ufone and https://en.wikipedia.org/wiki/Telenor_Pakistan (corporate facts cross-checked against multiple news summaries)

*Prepared by Muse (Sendqon programme) — research and writing only. Nothing in this report is legal advice; the Registration filing pack should be checked against the live PTA checklist at filing time, and operator terms exist only in negotiation.*
