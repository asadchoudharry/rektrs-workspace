# Sendqon — Innovations List

Recorded 2026-11-19 on the owner's order: *"3no ko yaad rakhna, innovations list main dal do, or ek team inki research per dal do."*

These are **system-level inventions**, not features — each one creates a network or institution that does not exist in Pakistan today, and each grows out of Sendqon's unique asset: thousands of real phone numbers in daily, consented business contact. Research lanes for items 1–3 were launched the same night (reports land in this folder as `SENDQON-INNOVATION-RESEARCH-*.md`). Item 4 was presented to the owner the same night; his research/go decision is pending.

Status key: **RESEARCH** = research lane running · **PROPOSED** = presented, owner decision pending.

---

## 1. Number Trust Bureau — RESEARCH

**The invention:** a credit bureau for phone numbers. Banks judge a *person* by history; nobody in Pakistan judges a *number* by its history.

**How it works:** every Sendqon tenant's daily operations generate outcome signals about the numbers they deal with — COD parcel accepted or returned, school fee paid on time or not, calls answered or number dead, Raast account title matching the claimed name, number age and liveness (HLR). Aggregated and anonymised across tenants, each number accumulates a portable trust profile. Any business can ask, in one API call before dispatching a parcel or extending credit: *"Is number par bharosa karun?"*

**Why only us:** the data cannot be bought — it accrues only by operating a messaging platform at scale. Every tenant that joins deepens the moat. First buyers are obvious: e-commerce/COD sellers bleeding from fake orders and returns.

**Feeds on:** Sendqon message/call/payment outcomes, the Raast title-check route (B2 plugins), HLR plugin (B4). **Fed by:** item 4 (every notarised agreement becomes trust history).

## 2. Internet Band, Business Band Nahi — SMS Fallback Network — RESEARCH

**The invention:** a delay-tolerant transaction network that rides pure SMS. When the internet dies — shutdown, flood, dead zone — Sendqon tenants' phones keep passing the essential transactions (order confirmations, payment notices, attendance, delivery codes) phone-to-phone by store-and-forward SMS, and everything syncs when data returns.

**Why it matters here:** internet shutdowns and patchy coverage are a recurring Pakistani reality; on that day every cloud business stops and a Sendqon business would not. The principle is NASA's delay-tolerant networking, commercialised for Pakistani SMBs — no one sells this here.

**Feeds on:** the own Android gateway app (B7), sim_fleet (USP-2), the missed-call M2M signalling concept (coded rings as a zero-cost control channel when even SMS is congested).

## 3. Human by the Minute — RESEARCH

**The invention:** human attention as an API. An AI agent (B3) takes the call first; where it gets stuck, the PBX (B9) conferences in a real Pakistani human within seconds — a registered, vetted person working from home (housewives, students, retired clerks) — who is paid **per minute** via JazzCash/EasyPaisa. No call-centre building, no shifts, no payroll: a liquid human layer behind AI, rentable by any tenant by the minute.

**Why it is a system, not a feature:** it reorganises labour the way ride-hailing reorganised transport — supply (idle human time at home) meets demand (businesses that need a human voice for 3 minutes) through our switchboard, with quality scoring feeding item 1's trust data.

## 4. Gawah — SIM-Notarised Verbal Agreements — PROPOSED (2026-11-19)

**The invention:** a notary in every pocket. Pakistan's real economy runs on *zabaan* — udhaar, rent, wages, land deals are spoken promises with no proof, and in a dispute the weaker party loses. Two people on an ordinary call invoke Gawah: the system announces recording in Urdu (consent), captures the promise segment, binds it to both SIM identities + Raast account titles, timestamps and seals it, and issues both parties a verifiable **Gawahi certificate** (checkable later by SMS/IVR code). Built on our PBX call recording + SIM identity — no third-party API.

**First legal step before any build:** a formal legal opinion on evidentiary weight under the Qanoon-e-Shahadat Order 1984 / Electronic Transactions Ordinance 2002. **Interlock:** every Gawah record feeds the Number Trust Bureau (item 1).

---

---

## Research outcomes (2026-11-19, all four lanes complete — reports in this folder)

- **#1 Number Trust Bureau → GO WITH CONDITIONS.** Demand priced (COD 80–90% of PK e-commerce, RTO 20–35%, Rs 800–2,000 loss per return; sellers already pay for defence). Narrow flag-sharing exists (SafeShip, ConfirmFlow, OrderAudit) — the standalone cross-vertical trust API does not. Kill criterion built in: anchor-seller backtest before scale spend. First step: legal opinion (Credit Bureaus Act 2015 reach; the word "Bureau" never ships publicly).
- **#1b Bureau seed data → mapped.** Headline: **no lawful source anywhere sells the name or CNIC behind a PK number** — PTA's record is holder-only, so every "name database" on sale is leaked data by construction (never-touch list: 8 items). Best lawful seed: **SendPK's HLR & MNP API** (MNP Rs 0.78/lookup, HLR Rs 1.56) plugging into the existing B4 `hlr` plugin contract. Day-one stack ≈ Rs 1–4/number supports a **Reachability & Identity-Shape Score only** (dead/fake/ported + business-identity flags) — behaviour prediction must wait for tenant history.
- **#2 SMS Fallback Network → GO WITH CONDITIONS.** 22 PK shutdowns in 2024, $1.62B losses (world's highest); in data-only suspensions SMS/voice provably stay alive. One encrypted transaction fits a single SMS segment; in-bundle cost ≈ Rs 0.02–0.10/txn. Hard limit stated in the report: in a full cellular suspension SMS dies too — sell as dead-zone/flood/data-outage continuity, never "shutdown-proof". Ceiling is regulatory (~1,000 SMS/day/SIM anti-spam), capacity scales by SIM count under sim_fleet.
- **#3 Human by the Minute → GO WITH CONDITIONS.** Validated internationally in 2026 at $1/min (US); our viable point ≈ Rs 30/talk-min tenant, Rs 10/min worker, on local rails only (international termination at Rs 48.8/min kills it; local SIP rates unpublished — measure in pilot). First step is a zero-code concierge pilot (one clinic + one school, two weeks).

## 5. The Machine Exchange — Agent-to-Agent Telephony — RESEARCH COMPLETE (2026-11-19: GO WITH CONDITIONS — the web built the full agent trust stack over HTTPS in 2025–26, none of it reaches a phone call; the buildable design is "the call is the doorbell, a parallel data channel is the room" — in-band audio protocols cannot survive the AMR codec on a Pakistani mobile leg; authority/mandates are the product; first step is a two-own-agents prototype on our own Asterisk with a hostile-agent red-team battery. Full report: `SENDQON-INNOVATION-RESEARCH-MACHINE-EXCHANGE-2026-11-19.md`)

**The invention:** the first telephone exchange built for machines, not people. Until now every phone call in history was human↔human or human↔menu. With AI agents on both ends, a new thing becomes possible: **my agent calls your agent** — to book, negotiate, confirm, settle — and when both sides detect they are machines, the call abandons slow human speech and switches to a fast machine protocol (data channel / coded audio), finishing in seconds, with a signed record of what was agreed. The missing layer — and the product — is the exchange itself: agent identity (which business does this agent speak for?), authority limits (what may it commit?), and a trust record of every machine-made promise (feeding #1). A 2025 hackathon demo (two agents switching to beeps) proved the spark; no one has built the network, the identity layer, or the billing. Our PBX (B9) + AI Agents (B3) are its two halves.

## 6. Insaan Check — Proof-of-Human for the Voice-Clone Age — PROPOSED (2026-11-19)

**The invention:** STIR/SHAKEN proves a *number* is real; nothing proves the *human* is. As voice cloning explodes, any tenant can challenge any caller mid-call: SIM possession + voiceprint + a family/business code-word ceremony, returning a live verdict — "insaan hai, wahi hai". A cross-business human-authentication layer over the ordinary phone network, sold as an API; banks do voice biometrics inside their own walls, nobody sells it as shared infrastructure in Pakistan. Pairs with #5: in a world of machine callers, proof-of-human becomes a billable primitive.

## 7. The Reality Oracle — Fleet-Verified Physical Truth — PROPOSED (2026-11-19)

**The invention:** an API that answers questions about the physical world — "is this shop open, at this address, right now?" — by dispatching the nearest fleet phone/person to look, photograph and attest (GPS + time + SIM identity). Digital Pakistan runs on unverifiable claims (fake addresses, ghost shops, phantom deliveries); a verification network with a signed attestation is infrastructure none of the data-collection apps (Premise, Streetbees) sell as a real-time API here. Extends #3's human layer from voice to presence.

## 8. Rektrs Line — The Smart Number (Software Telco / MVNO) — PROPOSED (2026-11-19)

**The invention at full size:** stop building on top of the network — become a layer of it. Today a phone number is dumb: it rings, that is all. A **Rektrs Line** is a number born smart: an AI receptionist inside the line, Gawah recording on demand, Insaan Check, a trust score that travels with the number, and a cloud identity that survives losing the SIM — all properties of the line itself, working on a Rs 3,000 feature phone with no app installed. The staged path: today's overlay (our fleet and bridge riding others' networks) → the aggregator track (running) → a **PTA MVNO licence** (the framework exists; a host-operator agreement is the hard gate) on a cloud-native core. At that point every other item on this list stops being an add-on and becomes a built-in property of every number we issue. The other innovations are features; this is the ground they stand on.

---

*Programme note: these sit OUTSIDE the B0–B9 build plan. Nothing here is being built yet — research first, owner decides.*
*Standing owner directive (2026-11-19 ~00:38 PKT): the hunt continues — new finds are appended to this list as they surface, each marked PROPOSED until the owner promotes it.*
