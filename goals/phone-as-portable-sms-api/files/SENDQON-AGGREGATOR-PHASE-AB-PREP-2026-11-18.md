# Sendqon Aggregator Programme — Phase A+B Preparation Pack

**Prepared for:** Assad, Founder & CEO, Rektrs (Private) Limited
**Date:** 18 November 2026
**Status:** Preparation only. No aggregator, operator or PTA has been contacted; nothing has been filed or signed up for. Every route recorded below is for the owner to act on.
**Builds on:** `SENDQON-AGGREGATOR-FEASIBILITY-REPORT-2026-11-18.md` (the full research: CVAS **Registration** — not Licence — Rs 10,000 fee, checklist item 14 = operator SLA gate).
**Grading:** ✅ = read on the provider's own official published material on 18 Nov 2026 · 📰 = published but dated, index-only, or third-party · ❓ = not published anywhere found — it is a question to ask, not a fact. Nothing below is an invented term.

---

# Part 1 — Phase A: Reseller Shortlist

**Our hard requirements for the upstream account** (from the feasibility report): (1) **SMPP bind or a documented HTTP API** that Sendqon can route through (Sendqon's SMS-provider machinery accepts both); (2) **the ability to file customer masks through them** — each Sendqon tenant's mask registered in that tenant's own NTN name, plus Rektrs' own "REKTRS" mask; (3) sane entry cost in PKR, prepaid.

## 1.1 SendPK — the compliance-heavy incumbent

*SendPK (sendpk.com / bulksms.com.pk), Lahore; operating since 2014; describes itself as a "PTA-Approved SMS Aggregator" holding direct interconnection with all operators.* ✅ (their Terms & Conditions + PTA Compliance page)

| Question | Finding | Grade |
|---|---|---|
| Reseller programme? | **Exists, approval-based.** Their T&Cs formally define a **"Reseller"** — "a Customer authorized to resell Services under a sub-account structure to their own end clients" — and prohibit resale *except* through an approved Reseller arrangement. Resellers are responsible for their end clients' compliance and indemnify SendPK. **No reseller rate card, white-label panel, or self-serve reseller signup is published** — the arrangement is granted, not clicked. | ✅ T&Cs |
| White-label panel? | Not published. The published model is sub-accounts under SendPK's own portal. For Sendqon this does not matter — our tenants live in Sendqon, not in the upstream panel. | ❓ (not published) |
| Connectivity into Sendqon | **HTTP API, fully documented** (send / bulk / unicode / dynamic sends, delivery + balance polling endpoints). **SMPP: not mentioned anywhere in their published material** — integrations in the wild are uniformly HTTP (username/password/sender). | ✅ API docs; SMPP ❓ |
| Branded/masked rates | **Rs 3.90 → 3.80/SMS** by package: Rs 10,000 (2,564 SMS) → Rs 15,000 (3.88) → Rs 30,000 (3.85) → Rs 50,000 (3.82) → Rs 100,000 (3.80); 1-year validity. Short-code OTP: **Rs 4.80 → 4.70**. Semi-branded: Rs 4.10–4.00. | ✅ pricing page, live Nov 2026 |
| Mask fees | **Rs 5,000 one-time approval + Rs 5,000/year renewal**, renewal due before 30 June each year. | ✅ |
| Mask filing for customers? | **Yes — this is their most documented process.** Stamped letterhead application + representative CNIC + company NTN, emailed to them; they submit to PTA, then register the approved mask on Jazz, Zong, Telenor and Ufone; **30–45 business days**. Sender ID accounts require NTN verification before activation. | ✅ PTA Compliance + Services pages |
| Signup requirements | Free self-serve account (name, mobile, email, PIN verification). Branded accounts additionally: signed + stamped letterhead application, representative's CNIC, company NTN. **All packages prepaid.** | ✅ T&Cs §5 |
| Enquiry route (recorded, not used) | **info@sendpk.com** · **+92 313 4126153** (phone/WhatsApp, published site-wide). Mask applications go by email per their PTA-compliance page. | ✅ |

## 1.2 Veevo Tech — the SMPP-published, cheapest-entry candidate

*Veevo Tech (veevotech.com), Islamabad / Peshawar / Karachi; technology company since 2012; SMS API + masking is a published product line.* ✅ (their SMS API page, fetched live 18 Nov 2026)

| Question | Finding | Grade |
|---|---|---|
| Reseller programme? | **No named reseller/white-label programme is published.** What is published is a platform/API account model: create an account, get **free test credits**, integrate, then recharge (self-service via their "One ID portal" or by writing to their team). Prepaid **and** postpaid billing exist; postpaid is "subjected to various business cases/approvals." Whether a platform account may carry third-party (our tenants') masks is **not stated** — question #1 for the enquiry. | ✅ page; reseller terms ❓ |
| Connectivity into Sendqon | **"HTTP & SMPP Connectivity" is an explicit headline feature**, and their FAQ confirms: "we do offer SMPP connectivity" alongside RESTful HTTP APIs, delivery-report **webhooks**, and 2-way short-code routing. **The only candidate that publicly satisfies the SMPP option today.** | ✅ |
| Branded/masked rate | **Rs 3.15/SMS flat** for Pakistan promotional/transactional traffic (their published pricing table). No volume ladder is published — tiers above starter volumes are an enquiry question. | ✅ their pricing table (site index); no ladder published |
| Mask fees | **Setup PKR 3,000 + annual renewal PKR 2,000** — the cheapest published mask fees in this shortlist (vs SendPK 5,000/5,000). | ✅ live page |
| Mask filing for customers? | Masking/registration is a published service ("For Pakistan Only" section); the filing workflow detail (documents, timeline) is thinner than SendPK's published process — confirm in the enquiry. | ✅ service exists; process detail ❓ |
| Signup requirements | Portal account → free test credits → recharge. PKR billing supported for local traffic. No published deposit or minimum top-up. | ✅ |
| Enquiry route (recorded, not used) | **UAN +92-304-1118333**; callback/enquiry form on their SMS API page; head office: G-12, Islamabad (also Peshawar, Karachi). Office emails are published on their site (obfuscated in our capture — use the UAN/form). | ✅ |

## 1.3 BSMS (BrainSoft) — the cheapest ladder, the stalest page

*BSMS (bsms.pk), BrainSoft.* 📰 — their pricing page as crawled is dated **16 March 2026 (~8 months old)**; treat every figure as "last published," to be re-confirmed before any reliance.

| Question | Finding | Grade |
|---|---|---|
| Reseller programme? | **None published.** Self-serve branded-SMS packages only; high-volume pricing is "contact us." | 📰 |
| Connectivity into Sendqon | No API or SMPP offer is published on the pricing page. | ❓ |
| Branded rates | Volume ladder: **Rs 3.20 @ 5,000 → 3.10 @ 10,000 → 3.00 @ 25,000 → 2.95 @ 50,000 → 2.90 @ 100,000 → 2.85 @ 250,000 → 2.80 @ 500,000 → 2.75 @ 1M → 2.70 @ 5M SMS**. **Caution: "+19.5% tax applicable"** on every plan — effective rates are ≈19.5% higher (top tier ≈ Rs 3.23/SMS effective; the 5,000-SMS Starter ≈ Rs 3.82 effective), which erases most of the headline advantage over SendPK/Veevo. Plan validity is short (1–12 months by tier). | 📰 dated crawl |
| Mask fees | No separate mask fee published — plans **bundle** 1–10 masks by tier. Renewal treatment after plan expiry is not published. | 📰 / ❓ |
| Signup requirements | Online signup; pay online (BPay, card) with instant activation. | 📰 |
| Enquiry route (recorded, not used) | **brainsoft@brain.net.pk** (published for high-volume pricing). | 📰 |

## 1.4 E Ocean — credible, registered, enterprise-gated

*E Ocean (Pvt.) Ltd (eocean.net), Karachi — on PTA's published CVAS Registration list as an SMS aggregator (feasibility report §1.1); enterprise CPaaS (banks/telcos), official WhatsApp BSP.* ✅ register / 📰 positioning

| Question | Finding | Grade |
|---|---|---|
| Reseller programme? | **No published reseller/wholesale programme or SMS rate card found.** Sales motion is enterprise/project onboarding with published developer documentation for SMS API and Branded SMS. | ❓ (nothing published) |
| Connectivity | SMS API documented for enterprise integrations; SMPP not published. | 📰 |
| Rates / mask fees | Not published (their published pricing is USD-denominated and WhatsApp-led). | ❓ |
| Enquiry route (recorded, not used) | **sales@eocean.net**; head office DHA Phase 2 Extension, Karachi; regional office F-8 Markaz, Islamabad. | ✅ their site |

## 1.5 Ranking and recommendation

| Rank | Candidate | Why |
|---|---|---|
| **1 — open first** | **Veevo Tech** | Only candidate publicly offering **SMPP connectivity** (plus REST + DLR webhooks) *and* mask filing, at the **lowest published entry economics**: flat **Rs 3.15/SMS** (below SendPK's 3.80–3.90 branded band) and the **cheapest mask fees (Rs 3,000 + Rs 2,000/yr)**. Free test credits and PKR prepaid mean Sendqon can be wired and tested for near-zero entry cost. |
| **2 — parallel quote** | **SendPK** | The **deepest published compliance apparatus** and the only **formal reseller arrangement** (T&Cs-defined, sub-account structure) — the natural home for tenant-mask filings at scale, with the mask process documented end-to-end. Costs more (3.80–3.90; masks 5,000/5,000) and publishes **HTTP only**. Take the reseller quote in parallel; dual-homing both is the Phase A end-state the feasibility report recommends. |
| 3 — later, volume-only | BSMS (BrainSoft) | Cheapest *headline* ladder at 500k+ volumes, but the price list is ~8 months stale, **+19.5% tax** erases the edge at realistic volumes, and no API/SMPP/reseller terms are published. Revisit only with a fresh written quote once volume justifies it. |
| 4 — not now | E Ocean | Genuinely registered and credible, but enterprise-gated with nothing published for a platform/reseller buyer. Keep for a future enterprise/OTP-grade requirement. |

**Recommendation: open the Veevo Tech account first** (SMPP/API pipe + REKTRS mask filing), **and simultaneously request SendPK's reseller terms in writing** (their approval-based reseller arrangement is the better long-term tenant-mask desk). First spend is minimal either way: Veevo test credits are free; SendPK's smallest branded package is Rs 10,000.

## 1.6 Exact questions to ask — published material does not answer these

**For Veevo Tech (the winner) — send with the first enquiry:**
1. We run a multi-tenant SaaS (Sendqon). Can one platform account carry **multiple third-party masks** — our customers' sender IDs, each registered in that customer's own NTN name — under a reseller/platform arrangement? What is the per-mask handling beyond the published Rs 3,000 setup / Rs 2,000 renewal?
2. **SMPP bind terms** for a platform account: setup cost (if any), TPS limits, transceiver vs TX/RX binds, source-IP whitelisting/VPN, DLR delivery over SMPP, and test-bind availability.
3. **Volume pricing:** the published rate is a flat Rs 3.15 — what are the rates at 100k / 500k / 1M SMS per month, and is the rate the same for promotional and informational (transactional) traffic? (SendPK charges informational-mask traffic at its short-code rate — what is yours?)
4. **Sub-account structure:** can tenants be segregated (separate balances, reports, mask ownership) under our master account, via panel or API?
5. **DNCR handling:** are C-DNCR numbers blocked network-side before sending, is a scrub feed/API available to us, and are DNCR-blocked or undelivered messages charged?
6. **MNP/ported numbers:** is delivery to ported numbers included at the flat rate or charged extra?
7. **Prepaid mechanics:** minimum top-up, balance validity/expiry, and refund/transfer of unused balance if we exit.
8. **Mask filing operations:** exact document set you require per customer mask, your realistic current timeline, and how renewal (before 30 June) is handled for masks you filed for us.
9. **Sending rules:** promotional-hours enforcement, content pre-approval requirements, and prohibited categories as you apply them.
10. **Support/SLA:** named escalation route and response times for a platform account; any uptime/delivery reporting we can consume programmatically.

**For SendPK (parallel reseller quote):**
1. The **Reseller approval process** under your T&Cs: eligibility, documents, and the reseller rate card (per-SMS by tier, and mask fees for reseller-filed customer masks).
2. Is **SMPP** available to resellers/platform accounts? (Not in your published material.) If HTTP-only, what are the API rate limits for a platform sending on behalf of many tenants?
3. Can reseller sub-accounts each hold their **own masks in their own NTN names**, with segregated balances and reporting?
4. MNP/ported delivery: the published Rs 1 / Rs 0.25 lookup model — is there a platform arrangement for high-volume ported delivery?

---

# Part 2 — Phase B: CVAS Registration Pack Checklist (Rektrs-specific)

**Filing:** PTA CVAS **Registration** — Category: Commercial · Registered Services · **SMS Aggregator Services** · Nationwide. Fee **Rs 10,000 one-time**, 5-year term. Source: PTA's official checklist (Annexures A–H) as researched in the feasibility report §1.4–1.6. ✅

**State key:** **HAVE** = in hand / exists today · **PREPARE** = we can produce it now (drafts, forms, fresh certified copies) · **GATE** = cannot exist until the operator negotiation lands.

## 2.1 The pack, item by item (official checklist order)

| # | Item (checklist / annexure) | What it is | Rektrs state |
|---|---|---|---|
| 1 | Application letter on company letterhead (Annexure-A) | Formal application addressed to the Director General (Licensing), PTA HQs, F-5/1, Islamabad | **PREPARE** |
| 2 | Fee — Rs 10,000 (Annexure-B) | Pay Order / Demand Draft in the name of **"Pakistan Telecommunication Authority"** (PTA's CVAS FAQ also lists direct deposit: NBP, Marriott Hotel Branch, Islamabad, A/C "Pakistan Telecommunication Authority") | **PREPARE** (instrument raised at filing) |
| 3 | Applicant Profile Form (Annexure-C) | Company profile in PTA's format | **PREPARE** |
| 4 | Category Selection Form (Annexure-D) | Ticks: Commercial · Registered Services · **SMS Aggregator Services** · Nationwide | **PREPARE** |
| 5 | Directors/BoD details (Annexure-E) + SECP Form-29 | Directors' CNICs, contacts, other directorships; Form-29 certified true copy **≤ 3 months old** | **PREPARE** (fresh CTC from SECP) |
| 6 | Authorization letter for the PTA correspondent (Annexure-F) | Names the person who will correspond with PTA; signed by **all directors** — flows from the board resolution (draft delivered with this pack) | **PREPARE** |
| 7 | Complete scanned soft copy of the application | Full pack as a soft copy alongside the paper filing | **PREPARE** (at filing) |
| 8 | Section 1 — Technical | Management telecom competence summary; detailed network/technical plan & architecture; equipment list reconciled with project cost; compliance with the Critical Telecom Data and Infrastructure Security Regulations, 2020. **The substance already exists: Sendqon's live architecture + the own-SMPP (Jasmin) design.** | **PREPARE** |
| 9 | SECP Certificate of Incorporation | Certified true copy **≤ 3 months old** | **HAVE** (company incorporated; pull a fresh CTC at filing) |
| 10 | Memorandum & Articles of Association | Certified true copy **≤ 3 months old** | **HAVE** (pull fresh CTC at filing) |
| 11 | Shareholders list + SECP Form-A (Annexure-G) | Certified true copy **≤ 3 months old** | **HAVE** (pull fresh CTC at filing) |
| 12 | CNIC copies of directors / authorized representatives | Plain copies for the pack | **HAVE** |
| 13 | Undertaking (Annexure-H) | On **Rs 100 judicial stamp paper, notarized** — directors never insolvent, no major convictions, no PTA defaults | **PREPARE** |
| 14 | **Copy of SLA(s) with operator(s) for SMS Aggregator Services** | Required **from Registration applicants specifically** — at least one operator interconnect agreement | **⛔ GATE** — comes from the Phase C operator negotiation |
| 15 | Report on economic viability & benefits to users (Section 4) | Short report: the Sendqon tenant base, pricing, consumer benefit | **PREPARE** |

**Counts: HAVE 4 · PREPARE 10 · GATE 1** (of 15). Registration applicants are spared the licence-only Section 2 financial pack (business plan, audited financials, projections, bank statements) — it is marked "For CVAS License Applicants Only." ✅

**Timing note on the CTCs:** items 5, 9, 10, 11 must be **≤ 3 months old at filing**. Pull them **after** the SLA is close to signature, not now — CTCs pulled today could age out while the operator negotiation runs.

## 2.2 Can the pack be lodged before the SLA lands? — what the official text actually says

**No partial-filing route is published.** The checklist lists the operator SLA copy as a required component of the Registration pack (item 14, "For CVAS Registration Applicants only"), and the checklist's own instruction is that an **"incomplete application shall be returned un-actioned."** Nothing in the published checklist or Annexures provides for lodging an incomplete pack and completing it later. Two related points remain genuinely open (feasibility report §6 Q3): whether **one** operator's SLA suffices or PTA expects broader coverage is **unstated** in the published text — confirm with the Licensing Division once the first SLA is in hand.

**So "Phase B in parallel" means:** every PREPARE item is produced and held ready *while* the operator negotiation runs (Phases A/C), and the pack is lodged complete the moment the first SLA is signed. Nothing is filed early and incomplete.

## 2.3 Filing sequence, step by step

1. **Board approval** — pass the board resolution (draft: `drafts/rektrs-board-resolution-cvas-draft.md`): approves the Registration application, authorizes the signatory/correspondent, and authorizes operator SLA + reseller negotiations.
2. **Produce the PREPARE documents** — application letter (Annexure-A format), profile form (C), category form (D), directors' details (E), authorization letter (F), technical section (from the Sendqon/Jasmin architecture), viability report (Section 4).
3. **Operator track (parallel, the long pole)** — negotiate the first operator SLA (Phase C). The Registration cannot be lodged before this lands.
4. **Fresh SECP CTCs** — once the SLA is near signature: Certificate of Incorporation, Memorandum & Articles, Form-A, Form-29 — all ≤ 3 months old at the filing date.
5. **Undertaking** — Annexure-H executed on Rs 100 judicial stamp paper and notarized.
6. **Fee instrument** — Rs 10,000 Pay Order / Demand Draft in the name of "Pakistan Telecommunication Authority" (or the NBP direct-deposit route per PTA's FAQ).
7. **Assemble + scan** — pack segregated and flagged section-by-section per the checklist, plus the complete scanned soft copy (item 7).
8. **Lodge** — paper pack to the Director General (Licensing), PTA HQs, F-5/1, Islamabad. PTA also operates an online licensing channel (OASIS / eservices.pta.gov.pk) — **confirm the live filing channel with the Licensing Division at filing time.**
9. **PTA processing** — no official timeline is published (❓). Respond to any PTA queries through the authorized correspondent.
10. **Grant** — registration number in the DIR(L)/CVAS-xxxx/PTA/yyyy series, 5-year term, listed on PTA's public CVAS Registration list. Renewal at year 5 at the same schedule (Rs 10,000); no annual fee is shown on the published schedule — confirm at filing (feasibility §6 Q5).
11. **(Optional, separate)** Short code — a distinct application to PTA's Service Division on its own form; only if Rektrs wants its own 2-way/OTP short-code identity. Not part of this pack.

## 2.4 Drafts delivered with this pack

| Draft | File | Purpose |
|---|---|---|
| Board resolution | `drafts/rektrs-board-resolution-cvas-draft.md` | Approves the CVAS Registration application; authorizes the correspondent/signatory, the fee payment, operator SLA negotiation, reseller agreements, and the REKTRS mask filing |
| Letterhead mask application — "REKTRS" | `drafts/rektrs-mask-application-letterhead-draft.md` | Rektrs' own first mask, ready to print on letterhead, sign, stamp and send to the Phase A reseller for PTA filing |

Both drafts use **only company facts already on the project record**. Anything not on record (NTN number, CNIC numbers, exact registered office address, SECP corporate identity number) is a clearly marked **[OWNER TO FILL]** placeholder — nothing has been invented.

---

# Part 3 — What remains owner-only

1. **The enquiries themselves** — contacting Veevo Tech (UAN +92-304-1118333 / their form) and SendPK (info@sendpk.com / +92 313 4126153) with the §1.6 questions, and opening the first account. (Preparation rule for this pack: no outward contact was made.)
2. **Company facts only the owner holds** — NTN number, directors' CNIC numbers/copies for the pack, the exact registered office address as per SECP/NTN records, SECP corporate identity (CIN) number — the [OWNER TO FILL] fields in both drafts.
3. **Signatures and execution** — board meeting + signed resolution, Annexure-F authorization signed by all directors, Annexure-H undertaking on stamp paper (notarized), the mask application signed + stamped.
4. **Money** — the Rs 10,000 fee instrument; the first reseller top-up/package (Veevo recharge, or SendPK's Rs 10,000 entry branded package); the mask fee for REKTRS (Rs 3,000 via Veevo or Rs 5,000 via SendPK, plus the annual renewal).
5. **The filing itself** — lodging the completed pack with PTA once the operator SLA (the GATE item) exists.

## Sources (accessed 18 November 2026)

- SendPK — Pricing (live): https://sendsms.com.pk/price.php · Terms & Conditions (Reseller definition, §5 account requirements): https://bulksms.com.pk/terms-conditions.php · PTA Compliance (mask process): https://www.sendpk.com/pta-compliance.php · Services / Branded SMS: https://sendpk.com/services.php · API Documentation: http://sendsms.pk/api.php
- Veevo Tech — SMS API Service (HTTP & SMPP, masking charges, billing, contact): https://vt-web-v1.veevotech.com/vt_sms_api
- BSMS (BrainSoft) — Pricing (crawl dated 16 Mar 2026): https://bsms.pk/pricing.php
- E Ocean — site + documentation/contact: https://eocean.net/documentation/
- Rektrs project research — *Sendqon Market Pricing, Pakistan* (16 Nov 2026): `~/workspace/research_notes/sendqon-market-pricing-pakistan-20261116-0937/report.md`
- PTA checklist, fee schedule and register — as cited in `SENDQON-AGGREGATOR-FEASIBILITY-REPORT-2026-11-18.md` §7

*Prepared by Muse (Sendqon programme) — preparation documents only. Nothing in this pack is legal advice; verify the pack against the live PTA checklist at filing time.*
