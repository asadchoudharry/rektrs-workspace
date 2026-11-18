# Sendqon Innovation Research — Innovation #2
## "Internet Band, Business Band Nahi" — SMS-Native Delay-Tolerant Fallback Network

**Date:** 2026-11-19 · **Lane:** Innovation research (Innovations List, owner order 2026-11-19 ~00:30 PKT)
**Subject:** A store-and-forward transaction network that rides plain SMS between Sendqon gateway phones when the internet dies — shutdowns, floods, dead zones — and syncs to the Sendqon cloud when data returns. Includes the sub-concept of coded missed calls as a zero-cost machine-to-machine control channel.
**Verdict up front: GO-WITH-CONDITIONS** (conditions and first steps in §8).

**Grading used throughout:** **[Official]** = government/regulator/standards-body source · **[Industry]** = published tracker, operator listing, academic or trade source · **[Unverified]** = circulating claim we could not tie to a primary source. Where nothing is published, this report says so rather than inventing a figure.

---

## 1. Prior art — what already exists, and what does not

### 1.1 Delay-Tolerant Networking (DTN) — the science is settled, the product is not
- DTN was formalised by the IETF/IRTF for networks with no end-to-end path: **RFC 4838** (architecture, 2007), **RFC 5050** (Bundle Protocol v6, 2007), and the current standard **RFC 9171 — Bundle Protocol Version 7 (Jan 2022)**, with security in **RFC 9172 (BPSec)** and default security contexts in **RFC 9173**. [Official — IETF]
- The core paradigm is **store-carry-forward**: a bundle (payload + source/destination endpoint IDs + creation timestamp + lifetime) is held persistently by each node and forwarded whenever a contact opportunity appears; custody transfer makes a node responsible for retransmission. NASA uses the same family of protocols for deep-space links. [Official — IETF RFC 9171 text]
- **Design lesson for us:** we do not need BPv7 itself (it assumes IP-ish convergence layers and is heavy for 140-byte SMS), but its semantics — persistent bundles, lifetime/TTL, custody acknowledgement, endpoint IDs independent of transport — are exactly the semantics this product needs, in miniature.

### 1.2 DakNet / KioskNet — store-and-forward as rural infrastructure
- **DakNet** (India, later Cambodia) carried email/e-governance data between village kiosks and an internet hub on buses/motorbikes fitted with Wi-Fi — physical store-carry-forward, latency in hours, near-zero infrastructure cost. **KioskNet** did similar DTN over rural kiosks using the cellular network where present. [Industry — DTN literature reviews, MDPI 2024]
- **Design lesson:** delay measured in hours is acceptable when the alternative is *never*. Our case is far easier: the "mule" (SMS) already moves at network speed; only the last sync hop waits.

### 1.3 SMS-based field systems — the closest ancestors
- **FrontlineSMS** (2005–, NGO sector): a laptop + a phone/GSM modem runs two-way SMS workflows **with no internet connection at all**; **FrontlineForms** encoded structured forms, **compressed them into SMS**, sent them to Java phones in the field, and — critically — **held data in "offline" mode on the handset until signal returned**. This is the nearest historical ancestor of our design, including the compression-by-schema trick in §4.3. [Industry — kiwanja.net / FrontlineSMS project records]
- **Ushahidi**: crisis/incident intake by SMS into a mapping platform (usually paired with FrontlineSMS as the local hub). Proves structured data over consumer SMS at event scale; does not do multi-hop relay or tenant commerce. [Industry]
- **CommCare (Dimagi) / ODK / KoboToolbox**: offline-first data collection — forms queue on the device and sync over **data** when connectivity returns; SMS is at most a side channel. They solve "my device is offline," not "my whole district's internet is off but SMS works." [Industry — Salanga/CRISISNET tool handouts]
- **RapidPro/TextIt**: two-way SMS workflow platforms for NGOs — cloud-dependent; dead in a data shutdown on the server side for field devices without data.

### 1.4 Mesh messengers (Bridgefy / Briar / BitChat / FireChat) — different layer, real warning
- Bluetooth/Wi-Fi-Direct mesh apps relay phone-to-phone at ~100 m per hop and spike during shutdowns: FireChat ~500,000 downloads in a day (Hong Kong 2014); Bridgefy downloads jumped ~4,000% / 60,000+ in a week (Hong Kong 2019) and surged again after Myanmar's 2021 coup. [Industry — multiple reports]
- They are **human chat tools for crowds**, not business transaction networks: no store-and-forward to a cloud of record, no tenant data model, no delivery accounting. They also carry two warnings we must heed:
  1. **Security:** Bridgefy's encryption was broken by Royal Holloway/ETH Zurich researchers in 2020 (users unmasked, messages intercepted/spoofed) — a bespoke-crypto failure. Our design uses standard AEAD only (§4.5). [Industry]
  2. **Regulatory mood:** in July 2026 India's I4C issued takedown notices against BitChat/Briar/Bridgefy precisely because they "keep working when the internet doesn't." A product *marketed* as shutdown circumvention invites the same attention in Pakistan. Positioning is a legal control, not a slogan (§6.3). [Industry — Internet Society Pulse, CyberPeace]

### 1.5 Commercial "SMS fallback" business products — the gap
- Globally, "SMS fallback" exists only as a **feature inside CPaaS** (e.g., an OTP provider falling back from data push to SMS) — the reverse direction from ours, and still cloud-dependent.
- **Pakistan:** the aggregator market (Veevo, SendPK, BSMS, E Ocean, etc. — mapped in our 2026-11-18 aggregator feasibility report) sells ordinary A2P bulk SMS over HTTP/SMPP. **No published product — in Pakistan or found elsewhere — sells a multi-tenant, store-and-forward, SMS-borne transaction fallback network for businesses.** Searched 2026-11-19 across shutdown trackers, CPaaS catalogues and PK aggregator sites: **not published / not offered** is the honest finding. The white space is real; so is the reason nobody has filled it (see §5 — the ceiling is regulatory physics, not imagination).

---

## 2. Demand evidence — Pakistan's internet dies often, and SMS usually survives it

### 2.1 Shutdown frequency
- **Access Now #KeepItOn** (the standard global tracker): Pakistan recorded **21–22 shutdowns in 2024** (first counted 21, revised to 22) and **20 in 2025** — among the worst-affected countries in the world (2025: Myanmar 95, India 65, Pakistan 20). Pakistan has imposed shutdowns **every year since 2016**, with spikes in 2024–2025. [Industry — Access Now annual reports 2024/2025]
- The long tail is worse than the headlines: Access Now tracked a shutdown covering ~4.5 million people in ex-FATA running **nearly four years (2016–2021)**. [Industry — via Business Recorder]
- Internet Society Pulse's Pakistan page lists recurring **regional mobile-internet suspensions**, most classified **"Mobile Internet Services"** — i.e., data-only. That classification is the single most important demand fact for this product (§2.3). [Industry — ISOC Pulse]

### 2.2 The money
- **Top10VPN's Cost of Internet Shutdowns**: Pakistan suffered the **world's highest economic losses from internet shutdowns in 2024 — $1.62 billion**, across **9,735 hours** of disruption affecting **82.9 million users**. ITIF's independent range for Pakistan 2024 is **$892M–$1.6B**. [Industry estimates — Top10VPN; ITIF via Asian Dispatch]
- Micro-level corroboration: **PIDE** found online food-delivery orders fell **~75%** and online cab rides **~97%** during shutdown days — the exact small-transaction economy this product targets. [Industry — PIDE via Business Recorder]
- May 2023 episode alone: telecom-sector revenue loss reported at **≥ Rs 820 million** for the suspension period (~$2.85M/day sector loss). [Industry — The Nation / The National, citing sector figures]

### 2.3 The decisive pattern — three kinds of "internet band," and SMS's fate in each
| Type | What the state/nature does | Voice | SMS | Our network |
|---|---|---|---|---|
| **A — Data-only suspension** (the common case) | Mobile broadband (3G/4G data) suspended; platforms blocked | ✅ works | ✅ **works** | **Fully operational** |
| **B — Full cellular suspension** | Entire mobile service suspended in an area | ❌ | ❌ **dies too** | Store-only mode: queue on device, forward when service returns |
| **C — Infrastructure loss** (floods, fibre cuts) | Sites/power/backhaul physically down, patchy by operator & geography | ⚠️ patchy | ⚠️ patchy | Operational wherever *any* operator's SMS path lives; multi-operator SIMs per phone are the mitigation |

Evidence:
- **Type A archetype — May 9–13, 2023:** mobile broadband suspended nationwide ~4 days after the 9 May protests; fixed broadband stayed up. AAJ News recorded it plainly: *"While the internet was disrupted, consumers still had access to voice calls and SMS messages."* [Industry/press — AAJ, PTA statements]
- **Type B archetype — 8 Feb 2024, general election day:** the Interior Ministry **suspended mobile services nationwide** (~13 hours per ISOC Pulse); even the Election Commission's own **8300 SMS service became inaccessible** — proof that in Type-B events SMS and missed calls die together. Muharram-period city suspensions are the recurring smaller version. [Official statements + press — Geo/ARY/Freedom House]
- **Type C archetype — 2022 floods:** PTA reported **3,386 cell sites inactive at peak (28 Aug 2022, 6.6% of all sites)** and **120+ optical-fibre cuts**; in the worst-hit districts **both call and data failed**, and as of Dec 2022 ~100 sites in Balochistan/Sindh were still down — restoration took weeks in places. [Official — PTA via Dawn/Geo; Tabadlab analysis]

**Demand conclusion:** the addressable pain is Type A (frequent, nationwide, multi-day, SMS alive) + Type C edges (regional, weeks-long, SMS patchy) + ordinary dead zones and data outages year-round. Type B is real but rarer and shorter — and no SMS product can survive it; the honest product promise is *"business band nahi"* for data deaths, and *"nothing is lost — everything queues and lands later"* for total deaths.

---

## 3. What the network carries (scope discipline)

**Fits (small, structured, delay-tolerant, high value per byte):**
- Order confirmations & status changes (placed → confirmed → dispatched → delivered)
- Payment-received notices (Raast/JazzCash/EasyPaisa *notices* — the money moves on banking rails; we carry the record)
- Attendance marks (school staff/students, field staff check-in)
- Delivery codes / OTP-style handover codes, rider status ticks
- Stock/price ticks, meter/usage readings, machine status pings

**Never fits (by design, stated in the product):**
- Chat/inbox sync, media, catalogues, browsing — anything bulky or conversational
- Interactive flows needing <1-minute round trips
- Bulk marketing (illegal over this channel in practice — §6 — and cap-suicidal, §5)
- Financial settlement itself; health/emergency alerting where minutes matter

---

## 4. Technical design on our stack

Assets already in hand: our own Android gateway app (v5.2.0 — SMS send/receive, dual-SIM sync, pairing with server-issued tokens, USSD companion), the **sim_fleet** plugin (per-SIM caps, warm-up, health, rest — USP-2), the **Jasmin SMPP server** (B9, in progress), the WhatsApp bridge, and the Sendqon cloud as system of record. The fallback network is a new module in the app + a reconciliation service beside Jasmin — not a new platform.

### 4.1 The bearer: SMS, byte-honest
- One SMS carries **140 octets** of user data. As GSM-7 text that is **160 characters**; with a concatenation header (6-octet UDH) it is **153 characters / 134 octets per segment**. [Official — GSM 03.40/23.040]
- Two encodings, both implemented, chosen per operator after battery tests:
  - **Binary data SMS** (Android `sendDataMessage`, port-addressed to our app): full **140 B/segment**, invisible to the user's inbox. Risk: some operator/device paths mishandle data SMS → must be proven per operator (Jazz, Zong, PTML) in the battery, not assumed.
  - **Text SMS with 6-bit packing** over the GSM-7 safe subset (characters that never trigger the extension table): 160 chars × 6 bits = **120 B/segment** (153 chars concatenated ≈ 114 B). Slightly smaller, maximally compatible — this is the default; binary is the optimisation where proven.
- **Design rule: one transaction = one segment.** Concatenation is allowed (max 3 segments) only for batch payloads (e.g., an attendance register page), never for interactive items.

### 4.2 Frame format (fits the 120 B text-packed budget)
| Field | Bytes | Notes |
|---|---|---|
| Magic + version/type | 2 | `SQ` + frame type (DATA / ACK / HELLO / SYNC) |
| Src node ID | 2 | Fleet-unique per tenant (65k nodes/tenant) |
| Dst node ID | 2 | `0xFFFF` = cloud hub |
| Sequence | 2 | Per-node monotonic counter (also the AEAD nonce component) |
| TTL / hops-left | 1 | Default TTL 48 h; hop cap 3 |
| Key ID | 1 | Which fleet key generation encrypted this |
| Salt | 4 | Random, completes the nonce |
| **Ciphertext** | **≤ 98** | AES-256-GCM over the transaction payload |
| GCM tag (truncated) | 8 | 64-bit tag — accepted trade-off at this message value; full 16 B tag profile available for payment notices (payload ≤ 90 B) |
| **Total** | **≤ 120** | **= exactly one text-packed segment** (binary path: 140 B budget → payload ≤ 118 B) |

### 4.3 Payloads — schema coding, not general compression
General compressors lose at this size (a gzip header alone is ~18–20 B). Like FrontlineForms, we use **fixed per-type binary schemas** with varints, delta timestamps (seconds since a day-epoch), and 8-byte hashes instead of full IDs:

| Transaction | Fields | Plaintext size |
|---|---|---|
| Order status | order hash 8 + status 1 + amount 4 + ts-delta 3 | **~16–34 B** |
| Payment notice | txn hash 8 + amount 4 + rail 1 + ts 3 + payer hash 8 | **~24–40 B** |
| Delivery code event | order hash 8 + code 4 + status 1 + ts 3 | **~16–30 B** |
| Attendance batch | header 6 + per mark (student hash 4 + status 1 + period 1) | **6 B/mark → ~15 marks/segment** |
| Stock/price tick | item hash 6 + value 4 + ts 3 | **~13–25 B** |

Every pilot transaction type fits one segment with ≥ 50% headroom — headroom that buys the full-tag profile and future fields.

### 4.4 Routing, store-and-forward, dedupe, ordering
- **Star first:** any node that regains *any* data path (its own, or Wi-Fi) syncs straight to the cloud over HTTPS; the cloud is always the merge point and system of record.
- **SMS paths, in preference order:** (1) node → **cloud hub number** (a hosted SIM/SMPP-reachable number terminated on our Jasmin stack) when the destination is the cloud or another tenant site; (2) node → node **direct SMS** when both endpoints are offline (the phone number *is* the address — the fleet directory maps node ID → MSISDNs per operator, preferring on-net pairs for bundle economics); (3) **epidemic relay** within one tenant's fleet only, hop cap 3, when a peer has a live path the origin lacks (e.g., a rider's phone on Zong relays for a shop phone on a dead Jazz cell).
- **Custody & ACK:** a bundle is deleted from a node's outbox only on ACK — an ACK frame by SMS, a **missed-call ACK** (§4.6) for low-value classes, or implicit ACK via the next cloud sync. Un-ACKed bundles retransmit with backoff (5 min → 30 min → 2 h) until TTL expiry.
- **Dedupe:** identity = (src node, seq) + a 4-byte content hash in the payload header; every node and the cloud keep a seen-set for the TTL window; duplicates are ACKed again (the ACK may be what was lost) but never re-applied.
- **Ordering:** transactions are **append-only events** carrying (node ID, node seq, Lamport clock). Schemas are written as *full new state* ("order #A = DELIVERED"), never deltas, so application is idempotent and order-tolerant; the cloud merges per entity by Lamport clock with node-ID tiebreak. Conflicts surface in the tenant inbox as exceptions, never silent overwrites.
- **Sync protocol (cloud):** on data return, the node uploads its outbox + event log delta (HTTPS, resumable, hash-chained per node so gaps are detectable), downloads pending inbound bundles and the ACK sweep, then purges. A node that was a relay uploads carried bundles identically — custody ends at cloud acceptance.

### 4.5 Encryption — assume the operator (and anyone with SS7 access) reads SMS
SMS is plaintext in the operator core and over the air interface's weak legacy ciphers; sender MSISDN is network-asserted. Design:
- **End-to-end AEAD inside the payload:** AES-256-GCM; keys are **per-tenant fleet keys**, generated server-side, wrapped per node and provisioned during the app's existing pairing flow (the same ceremony that already issues device tokens). Key generations rotate via the Key ID byte; a lost phone is revoked by key + MSISDN denylist.
- **Authenticity:** frames are accepted only from **registered fleet MSISDNs** *and* must decrypt under the tenant key — either check alone is insufficient (SIM swap defeats the first; a leaked key without a fleet SIM defeats the second).
- **Honest metadata limit:** encryption hides content, not metadata — the operator can still see which numbers text which, when, and how much. For tenant business transactions this is the same exposure as ordinary SMS today, but the report states it plainly because "encrypted SMS" must never be oversold. (This is also why BPSec-style designs, RFC 9172/9173, inform but do not directly fit: they secure bundles between DTN nodes, not 140-byte SMS frames.)

### 4.6 The missed-call channel — a real alphabet, honestly sized
A missed (unanswered) call is free on Pakistani networks and carries exactly three signals: **who called** (network-asserted MSISDN = node identity), **the ring pattern**, and **when**. Engineering the alphabet:
- **Ring-pattern codebook (per node pair, pre-agreed):** 1 short ring (<3 s, hang up before answer) = **ACK / received** · 2 rings = **"bundle waiting — open an SMS/data window"** · long ring (>10 s) = **alert / escalate** · answered-then-instant-hangup = **"sync now."**
- **Real capacity:** ~2 bits per event beyond identity (4 reliably distinguishable patterns; more patterns collapse into human/carrier ambiguity). With a fleet directory of N nodes, one event conveys ≈ log₂(N) + 2 bits of *addressed* signal — plenty for control, useless for data. That is the correct use: **ACKs, heartbeats (one scheduled ring/day proves a node alive at zero cost), wake-ups, and escalation — never payloads.**
- **Cadence discipline:** call setup takes ~5–8 s; keep missed-call signalling ≤ ~6–10 events/hour/pair. Beyond that it resembles wangiri/robocall patterns to carrier fraud systems, burns goodwill, and — if a pattern ever lands on a non-fleet number — becomes harassment. **Fleet-internal numbers only, hard-coded.**
- **Failure mode:** dies in Type-B suspensions (voice is off) and Type-C holes, exactly like SMS. It is an optimisation (free ACKs), never a dependency.

### 4.7 Cost per transaction (the arithmetic that makes this viable)
[Industry — operator bundle listings checked in-app by third-party trackers, Q2 2026; verify in the Jazz/Zong apps before purchase — bundles change quarterly]
- Monthly SMS bundles: **Jazz ≈ Rs 50 / 7,000 SMS** and **Rs 180 / 12,000 SMS**; **Zong ≈ Rs 150 / 10,000 SMS** → effective **Rs 0.007–0.025 per SMS**, all-network.
- One transaction = 1 segment × 1 hop + 1 ACK ≈ **Rs 0.02–0.05 all-in** inside bundles. A worst-case 3-hop relay with ACK ≈ **Rs 0.10**. A school day of 300 attendance marks = ~20 segments ≈ **under Rs 1**.
- Out-of-bundle pay-as-you-go is **Rs 1.20–3.60/SMS + tax** [Industry listings] — the network must therefore *live inside bundles by design*: sim_fleet already tracks per-SIM caps and bundle state (USP-2); the fallback engine consumes the same budget ledger. (Sendqon's own aggregator-route over-quota price is Rs 4.25/SMS — irrelevant here; this network deliberately never touches the aggregator route.)

---

## 5. Hard limits — the physics that no roadmap removes

1. **Operator anti-spam ceilings are the true capacity limit — not price.** PTA's complaint-handling procedure records the operators' automatic filter: outgoing SMS is **blocked automatically beyond ~150 SMS/15 min, 250 SMS/hour, 1,000 SMS/24 h per subscription**, with at most two restorations; a third strike suspends the subscription pending an undertaking. [Industry reproduction of PTA procedure — PTA Complaints guides] PTA's own stated rule: high-frequency same-content traffic from one MSISDN to many numbers **is bulk activity and is filtered/blocked by operator systems**. [Official — PTA Chairman, Business Recorder] → A hub SIM safely relays **≤ ~600 segments/day** (we design to 60% of the ceiling). Scale comes from *more SIMs*, each on the sim_fleet cap machinery — and every added SIM sharpens limit #2.
2. **The SIM-box silhouette.** A fleet of consumer SIMs exchanging machine-pattern traffic (regular intervals, coded payloads, high counterparty concentration) resembles the traffic signature operators hunt for spam/SIM-box abuse — the known dual-use risk of our whole SIM-gateway model. Mitigations are behavioural, not cosmetic: transactional-only content, human-plausible cadence with jitter, per-SIM daily budgets far under ceilings, no marketing ever, and full tenant attribution. This risk caps how *loud* the network may be; it cannot be engineered to zero.
3. **SIM supply is identity-bound.** PTA rules cap a CNIC at **5 voice SIMs + 3 data SIMs** (Subscribers Antecedents Verification Regulations), each biometrically verified. [Official — PTA SAV Regulations, via PTA SIM Information System] Fleet growth therefore runs on consenting individuals' CNICs or operator **corporate connections** — a procurement/legal workstream, not a settings toggle.
4. **Latency is minutes-to-hours, and sometimes "tomorrow."** SMS delivery is normally seconds, but store-and-forward under outage conditions means the *sync* leg waits for any live path. Product copy must promise "minutes when a path exists, landed by the time service returns" — never real-time.
5. **Throughput ceiling per tenant site:** ~600 segments/day/hub SIM ≈ 300–500 transactions/day with ACKs and relays. A busy courier branch fits; a marketplace does not. This is a **small-transaction lifeline**, not a shadow internet.
6. **Type-B events are unsurvivable by design of the state, not by our failure** (8 Feb 2024: even the ECP's SMS service died). The product must say so before a customer learns it during an election.
7. **What never fits:** anything in §3's never-list; plus multi-party coordination needing consensus, and any tenant whose regulator requires real-time delivery proof (banking settlement, emergency dispatch).

---

## 6. Legal / regulatory

### 6.1 What governs machine-generated SMS at fleet scale
- **Protection from Spam, Unsolicited, Fraudulent and Obnoxious Communication Regulations, 2009**, as amended (Second Amendment, Gazette 31 Dec 2022): marketing requires **individual consent (sought in English + Urdu, records kept)**, an unsubscribe path, delivery within normal business hours, sending via **approved short codes / alphanumeric IDs under agreement with an operator or licensed aggregator**, and respect for the **Central Do-Not-Call Register (3627)**. [Official — PTA Regulations S.R.O. 713(I)/2009 + S.R.O. 2402(I)/2022]
- **PECA 2016, s.25** supplies the definition of spamming the 2022 amendment imports; unsolicited-spam penalties are reported at up to **Rs 50,000 (first) / Rs 1,000,000 (repeat)**. PECA s.16 separately criminalises SIMs held on another's CNIC without consent — directly relevant to how fleet SIMs are procured (§5.3). [Official law; penalty figures as summarised in Industry legal guides]
- **Application to this design:** the fallback network's traffic is (a) **fleet-internal** machine traffic between Rektrs'/tenant-owned devices — not communication to the public; and (b) **transactional notices to a tenant's own customers inside an existing business relationship** (order, payment, attendance), which is the same legal character as the SMS Sendqon already sends for those tenants. It must **never** carry promotional content: the moment it does, the full telemarketing regime (consent records, DNCR scrub, approved sender ID via aggregator) applies and the consumer-SIM channel becomes indefensible. Tenant-facing fallback SMS should inherit the tenant's existing consent/DNCR posture from the core platform.
- Nothing in PECA or the Spam Regulations specifically addresses *store-and-forward relaying* or *encrypted machine payloads* between a business's own devices — **not published / not addressed** is the accurate statement. The exposure is the general anti-spam/bulk-filter regime (§5.1), enforced by operators technically rather than by PTA case-by-case.

### 6.2 Shutdown-period legality — the question that decides the marketing
- Shutdowns are ordered by the Ministry of Interior and executed by PTA under **s.54(3) of the Pakistan Telecommunication (Re-organization) Act, 1996**; commentary (including PTA's own remarks reported in the press) notes the legal footing is contested. [Industry — Asian Dispatch/TNN analysis]
- **Does the state also restrict SMS in shutdowns?** Evidence from §2.3: in the *common* data-only suspensions, no — SMS is deliberately left running (May 2023). In *full* cellular suspensions (8 Feb 2024; periodic city-level Muharram suspensions), yes — SMS is switched off with everything else, and no product feature may attempt to defeat that (e.g., no radio-mesh add-on sold as a shutdown workaround; cf. India's July 2026 move against mesh apps, §1.4).
- **Our position is therefore defensible:** the network uses SMS **only while the state itself keeps SMS on**, carries a business's own transactional records, and degrades to silent queueing when all service is suspended. It is continuity engineering, not circumvention. All public copy must be vetted against this line: sell **"flood, dead-zone and data-outage continuity"**; never sell **"shutdown-proof"** as a promise, both because it is legally provocative and because §5.6 makes it factually false in Type-B events.

### 6.3 Adjacent watch item
PTA's June 2026 consultation proposes treating **Corporate SMS as a separate relevant market** (each operator holding significant market power over termination on its own network). If PTA moves to regulate corporate-SMS pricing/terms, fleet-SMS economics could shift in our favour (cheaper legitimate bulk) or against (stricter A2P definitions). [Industry — Broadnet summary of PTA consultation, 4 Jun 2026] Flagged for the aggregator track, which already owns PTA watching.

---

## 7. Build path on the existing stack + pilot design

### 7.1 What gets built (nothing new bought; everything extends B7/B9 assets)
| Piece | Where | Content | Rough effort |
|---|---|---|---|
| **Fallback engine (app)** | New module in our Android gateway app (v5.2.x base) | Room-backed outbox/inbox event store; frame codec (text-packed + binary data-SMS); AES-256-GCM with pairing-provisioned fleet keys; connectivity watcher (data → HTTPS sync; none → SMS paths); relay logic with custody/backoff/TTL; missed-call listener + caller for the §4.6 alphabet; budget ledger shared with sim_fleet caps | **3–4 dev-weeks** incl. unit tests |
| **Reconciliation service (server)** | Beside Jasmin on the companions host | SMPP/HTTP termination for the hub number; event-log merge (Lamport ordering, dedupe seen-sets); ACK sweeps; per-tenant enablement + transaction-type registry; exception queue surfacing into the tenant inbox | **2–3 dev-weeks** |
| **Admin/tenant surface** | sim_fleet plugin extension | Fallback status per node (queued, last sync, bundle balance), drill-mode toggle ("simulate data outage"), delivery evidence per transaction — **with a rendered UI-surface battery, per the owner's standing directive** | **~1 dev-week** |
| **Battery** | Dev rig, B7-harness pattern | Two phones + hub on DEV; per-operator proof of data-SMS *and* text-packed delivery (Jazz/Zong/PTML); airplane-mode + data-off drills; duplicate/loss injection; cap-respect test (engine must refuse to exceed 60% of §5.1 ceilings); crypto negative tests (wrong key, replayed frame, non-fleet sender) | **~1–2 weeks**, overlapping |

**Total: ~6–9 weeks to a pilot-ready build**, sequenced after B9 lands (Jasmin hub termination is a dependency; the app module is not and can start first).

### 7.2 Minimal pilot (one tenant, one district, four weeks)
- **Tenant choice:** a **courier/delivery operation in Rahim Yar Khan district** (owner's home district; delivery codes + payment notices are the highest-value, best-fitting transaction types; riders already cross dead zones daily). Fallback candidate: **one school** (attendance + fee notices) if a courier tenant is not ready — controlled population, forgiving latency.
- **Kit:** 8–10 gateway phones (dual-SIM, two operators), 2 hub SIMs on different operators, monthly SMS bundles on every SIM (§4.7 economics: total pilot SMS spend < Rs 2,000).
- **Drills, not hopes:** one scheduled **data-off drill day per week** (tenant phones' data disabled by policy) + natural outages logged as they occur. The pilot sells the drill evidence, not a shutdown lottery ticket.
- **Success metrics (pre-registered):** ≥ 95% of pilot transactions delivered ≤ 15 min during drill windows where SMS service exists; 100% eventually delivered after sync (zero loss); measured cost/transaction ≤ Rs 0.10; **zero** operator spam-filter trips or SIM blocks; zero promotional messages carried.
- **Kill criteria:** any operator suspension of a pilot SIM for machine traffic, or delivery < 85% in drills, stops the pilot and triggers redesign before any second tenant.

---

## 8. Risks + recommendation

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | Operator anti-spam filters suspend fleet SIMs (SIM-box silhouette, §5.1–5.2) | **High** | 60%-of-ceiling budgets in code, jittered cadence, transactional-only, pilot kill criteria; long-term: migrate hub volume to the aggregator/CVAS route as it matures |
| R2 | A Type-B full suspension during a customer's critical day makes "business band nahi" look like a broken promise | Medium | Contract + copy honesty (§6.2): promise *no data loss*, delivery *when any path lives*; Type-B = store-only, stated up front |
| R3 | Regulatory/political framing as "shutdown circumvention" (India mesh-app precedent) | Medium | Positioning discipline (§6.2); no mesh-radio features; disaster/dead-zone framing; legal review of public copy before launch |
| R4 | Data-SMS (binary) silently dropped by an operator path | Medium | Text-packed encoding is the default; binary only where battery-proven per operator |
| R5 | Key compromise via a lost/stolen gateway phone | Medium | Per-node wrapped keys, server-side revocation, MSISDN + key dual check (§4.5); payloads are low-sensitivity records, never credentials or settlement instructions |
| R6 | Tenants misuse the channel for marketing | Medium | Transaction-type registry is allow-listed in code; no free-text customer payloads on the fallback path |
| R7 | Bundle prices/ceilings change (operators refresh quarterly) | Low | Economics re-verified per quarter; even 10× bundle prices keep cost/txn ≤ Rs 1 |

### Recommendation: **GO-WITH-CONDITIONS**
The demand is documented and recurring (20+ shutdowns a year, the world's highest shutdown losses in 2024, and a proven pattern that **SMS survives the common case**); the prior art proves every ingredient (DTN semantics, FrontlineForms' SMS encoding, store-and-forward discipline) while leaving the **commercial, multi-tenant, cloud-synced product** unbuilt; and the build rides assets we already own. The conditions:

1. **Positioning condition** — disaster / dead-zone / data-outage continuity only; the Type-B limit (§5.6) printed in the product, not the footnotes.
2. **Pilot condition** — §7.2's pre-registered metrics and kill criteria gate any second tenant or public claim.
3. **Discipline condition** — hard in-code budgets at 60% of operator anti-spam ceilings, transactional allow-list only, DNCR/consent posture inherited from core. No exceptions for "just one campaign."

### First 3 concrete steps
1. **Battery before code:** two-phone DEV rig proving text-packed + binary data-SMS delivery and the missed-call alphabet on Jazz, Zong and PTML, with loss/duplication injected — one week, produces the per-operator bearer matrix the codec defaults from.
2. **Freeze the spec:** frame format (§4.2), the four pilot transaction schemas (§4.3), key provisioning inside the existing pairing ceremony, and the merge rules (§4.4) — written into the rebuild tree as the fallback-network spec before the app module starts.
3. **Recruit the pilot tenant and run a one-day data-off drill on paper-and-phones** (manual SMS relay, no new code) to measure real transaction volumes and latency expectations — validates §7.2's metrics before the 6–9-week build is committed.

---

## Sources (accessed 2026-11-19)
- IETF RFC 9171 (Bundle Protocol v7), RFC 9172/9173 (BPSec) — datatracker.ietf.org / rfc-editor.
- Access Now / #KeepItOn, *Internet Shutdowns in 2024* and *…in 2025* annual reports (Pakistan: 22 revised for 2024; 20 for 2025) — accessnow.org.
- Internet Society Pulse, Shutdowns — Pakistan country page — pulse.internetsociety.org.
- Top10VPN, *Cost of Internet Shutdowns* (Pakistan 2024: $1.62B, 9,735 hrs, 82.9M users); ITIF range via Asian Dispatch/TNN.
- PIDE shutdown-impact figures; May 2023 losses — Business Recorder (brecorder.com/news/40425995); The Nation, 13 May 2023; AAJ News, 15 May 2023 ("consumers still had access to voice calls and SMS").
- Election-day suspension, 8 Feb 2024 — Geo News; ARY News; Freedom House, *Pakistan at the Polls* (ECP 8300 SMS inaccessible).
- Floods 2022 — PTA statements via Dawn (4 Sep 2022) and Geo (3,386 sites, 28 Aug 2022 peak); Tabadlab, *Pakistan Disconnected* (Oct 2022).
- PTA Spam Regulations 2009 + Second Amendment 2022; DNCR 3627; anti-spam thresholds (150/15 min, 250/hr, 1,000/day) — PTA complaint-procedure guides; Broadnet, *Pakistan A2P SMS 2026* (incl. PTA Corporate-SMS SMP consultation, 4 Jun 2026).
- PTA SAV Regulations — 5 voice + 3 data SIMs per CNIC — PTA SIM Information System (668 / cnic.sims.pk).
- FrontlineSMS / FrontlineForms — kiwanja.net; Ushahidi/CommCare — Salanga data-collection handouts; CRISISNET tools catalogue.
- Mesh apps & India takedowns — Internet Society Pulse (Aug 2026); CyberPeace Foundation; Royal Holloway/ETH Bridgefy audit reporting.
- Operator bundle prices — Jazz/Zong bundle listings (Daily Capital, gem.net.pk, allpackagespk), Q2 2026 checks; standard per-SMS Rs 1.20–3.60 + tax. **Verify in-app before any purchase.**
