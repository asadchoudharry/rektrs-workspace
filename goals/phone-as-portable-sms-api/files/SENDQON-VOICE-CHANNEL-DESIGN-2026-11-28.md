# Sendqon — Voice Call Channel: Design + Route Evaluation

**Prepared for:** Assad, Founder & CEO, Rektrs (Private) Limited
**Date:** 28 November 2026
**Status:** Design + evaluation only. No code written, no provider contacted, no trunk bought, nothing filed.
**Owner decision (2026-11-28 ~21:36 PKT):** "Phone call wala channel bhi dalna hy hum ny — as an API bhi or direct bhi." The voice channel ships with **both** surfaces: (1) **API** — programmatic calls (voice OTP, TTS/recorded announcements, status webhooks, recordings), SMS-API style; (2) **DIRECT** — click-to-call from the panel itself.

**How to read this doc:** Prices are dated and sourced inline. ✅ = read on the provider's/regulator's own page on 28 Nov 2026. 📰 = credible secondary/industry source. ❓ = could not be verified publicly — stated as such, never filled in. FX **Rs 277/USD** (project standard).

---

## 0. What we already own (the starting line is not zero)

- **Asterisk PBX companion is LIVE** (`sendqon-pbx`, image `sendqon-pbx:1.0.0`), telephony server **id 8 "PBX Telephony"**, `phone_bridge` shim plugin ACTIVE in dev + production, IVR crash root-caused and fixed in B10.0 (Asterisk issue #566; `res_timing_timerfd.so`), DTMF battery 5/5 ×4. **0 paired lines** — the B10.2 owner phone proof (pair phone → conference-merge battery on Jazz + Zong) is still pending and becomes this channel's gating proof.
- **B10 research verdicts that bind this design** (SENDQON-PHONE-BRIDGE-RESEARCH-2026-11-19.md):
  - Android gives apps **no SIM-call audio path** — an app can place/observe a GSM call but can never hear or speak into it.
  - The **conference-merge bridge** is the primary software route: our gateway phone dials the customer on its SIM, dials our PBX on a second leg, and the **carrier merges** them. Recording, IVR prompts and TTS then live on the PBX leg (the PBX is a conference participant and hears both sides).
  - **Merge is the carrier's decision, not ours** — no source documents Jazz/Zong/Ufone merge behaviour; caller DTMF reaching the PBX leg through a carrier conference is **unproven for PK carriers** (battery items, both gated on B10.2).
  - IVR prompts: **recorded human audio is primary**; cloud TTS for dynamic content only. Urdu STT WER ≈46.6% → transcripts assist-grade only.
- **Gateway fleet today:** owner's phone (device 2, our app v5.5.0) with SIM1 Zong +92 318 073 5877 / SIM2 Ufone +92 332 877 6333; vendor device 1 paused. One SIM = one call at a time → the current fleet ceiling is **2 concurrent calls**.
- **Architecture rule (B-series precedent):** every channel lands as **our own plugin + companion container, core untouched** (Telegram, Email, PBX companions). The voice channel follows the same pattern: a `voice` plugin in the panel/API layer + telephony in the existing PBX companion.

---

## 1. Route A — Via the existing Android gateway phones (GSM/SIM)

The phone-as-API thesis extended to voice: calls leave on the tenant-visible SIM numbers already in the fleet.

### 1.1 What the audio reality does to the feature list (stated plainly)

| API feature | On Route A | Why |
|---|---|---|
| Place an outbound call from a SIM | ✅ Yes | App places GSM calls programmatically; call state (ringing/answered/ended, duration) is observable |
| Call-status webhooks (initiated/ringing/answered/completed/failed) | ✅ Yes | Derived from app telephony callbacks + PBX leg events |
| Caller ID = the SIM's real number | ✅ Yes — best in class | It *is* a real subscriber call |
| Click-to-call with a human talking | ✅ Yes, via conference merge | Panel user is bridged in on the PBX leg (B10 pattern) |
| Play TTS / recorded announcement **into** the call | ⚠️ Only via the PBX merge leg | The app cannot inject audio into a GSM call. The PBX leg *can* play audio into the merged conference — **if the carrier merges** (unproven per carrier until B10.2) |
| Voice OTP (speak digits) | ⚠️ Same condition | PBX leg speaks digits into the conference; without merge, Route A cannot do automated voice OTP at all |
| DTMF gather from the callee | ❓ Unproven | Caller DTMF through a carrier conference to the PBX leg is a B10 battery item; if it fails, IVR on this route degrades to speak-only + voice-recognition fallback |
| Call recording | ✅ Of the merged conference | Recording happens on the PBX leg, which hears both parties once merged |
| Concurrency | ❌ 1 call per SIM | Today's fleet: 2. Scaling = more gateway phones (sim_fleet model) or ESP32/GSM-modem lines (B10.3) |

**Honest summary of Route A:** call placement, status, real caller ID, human click-to-call and recording survive fully. *Programmable* voice (TTS/OTP/IVR) survives **only through the PBX merge leg**, and the merge itself is per-carrier unproven until B10.2 runs. Anyone selling "full programmable voice over a phone SIM" without the merge bridge is selling something Android cannot do.

### 1.2 Cost model

- **Fixed: ≈ Rs 0.** Fleet, app, PBX and plugin pattern already exist. Marginal fixed cost is the SIMs' own bundle renewals.
- **Per minute (PTA prepaid tariff file, 30 Sep 2026 ✅ via PTA data reporting):** Zong standard voice **Rs 2.68–2.97/min + tax**, Ufone **Rs 3.50/min**, + Rs 0.15 call setup. With bundles the effective rate collapses: e.g. Zong's 3,000 all-network-minutes monthly bundle at Rs 750 → **≈ Rs 0.25/min effective** 📰 (bundle listings, Nov 2026); Ufone UWon flat Rs 2.99/min all-network 📰.
- **Planning figure:** **Rs 0.25–3.50 per minute** depending on bundle discipline — the cheapest per-minute cost of the three routes by a wide margin, paid in PKR to the carrier the owner already uses.

### 1.3 Caller ID
The callee sees the **actual SIM number** (+92 318… / +92 332…) — a real, callable-back Pakistani mobile number. Highest trust and answer rate of any route; also the tenant's own number if tenants later run their own gateway phones.

### 1.4 Quality / reliability
Native GSM voice — the same quality as any mobile call; no internet dependency on the call path. Reliability risks are operational, not acoustic: merge may be missing/delayed on a given carrier, SIM balance/bundle exhaustion (the fleet already has balance tracking — sim_fleet v1.1.0), and carrier anti-spam behaviour on high-volume automated calling from consumer SIMs (see §4).

### 1.5 Zender fit
Extends what exists: `phone_bridge` shim + PBX companion already registered as telephony server id 8. New work = a `voice` plugin (panel surface + REST API + webhooks + call logs + per-minute credit metering on the existing billing rails) and a dial/merge command set in the gateway app (it already runs USSD/SMS engines behind toggles — voice becomes a third engine toggle). Core untouched.

### 1.6 Both surfaces
- **API:** `POST /api/v1/voice/calls` {line/SIM, to, mode: `announce` (audio file/TTS via PBX leg) | `otp` | `bridge` (connect to a human number)}, status webhooks per call, recording URL on completion, CDR in the call log. OTP/announce modes are merge-dependent (above).
- **DIRECT:** panel click-to-call = **callback-merge**: user clicks Call next to a contact → PBX rings the *user's own phone number* and the gateway SIM dials the customer → user answers, phone merges, user talks. Audio lives on the two phones, never in the browser. (Browser-audio direct calling is a Route B feature.)

### 1.7 Effort
- **V1 (placement + status + click-to-call):** ~2–3 lanes on top of B10.1 — *after* the B10.2 merge battery passes on at least one carrier.
- **V2 (OTP/announce via PBX leg + recording):** +1–2 lanes, merge- and DTMF-battery-dependent.

---

## 2. Route B — SIP/VoIP stack + SIP trunk (own infrastructure)

Our PBX originates/terminates over IP through a wholesale trunk provider. This is the "real" programmable-voice route.

### 2.1 The stack decision: Asterisk vs FreeSWITCH vs rvoip (the activated comparison)

| | **Asterisk** (already running) | **FreeSWITCH** | **rvoip** |
|---|---|---|---|
| Maturity | 20+ years, enormous ecosystem; our B9/B10 stack, ARI pattern and IVR fix already proven in production ✅ | Production-grade since 2006; media engine inside major CPaaS products 📰 | Created Apr 2025; **v0.5.1**, 47 releases, ~3,165 commits ✅ (GitHub, 28 Nov 2026) |
| Capacity evidence | ~4,500 concurrent calls on 48-core bare metal (published load test); practical few-hundred–low-thousand with IVR/queues per node 📰 | Higher practical ceiling than Asterisk on comparable hardware (per-leg threading); bottleneck usually the RTP path 📰 | RFC 7502 benchmark on 0.5.0: ~8,300 CPS signalling-only; ~1,124 CPS with SRTP+G.711 media ≈ 11–12k concurrent **10-second** calls — **as a terminating echo endpoint** ✅ (project's own published benchmark) |
| The catch | Monolithic process; threading ceiling at multi-thousand concurrency — far above Sendqon's near-term need | New stack for us: verbose XML config, thinner ready-made ecosystem for our use, team learning curve | **B2BUA/relay mode (two legs per call — exactly what a voice channel does), long-call concurrency, transcoding, WebRTC and failover are explicitly NOT yet measured** ✅ (project's own notes). It is a *library*, not a server: we would build the server, the ops, and the edge cases |
| Fit for Sendqon | **Already deployed** (`sendqon-pbx`), team knowledge in-house, ARI lets IVR logic live in our own process (B10 design) | Would replace/parallel the PBX for scale we do not yet have | Wrong layer today: impressive trajectory, wrong risk profile for a paid channel's foundation |

**Verdict: Asterisk.** Not because it wins every benchmark — FreeSWITCH scales higher and rvoip's numbers are remarkable for a 19-month-old project — but because it is *already running, already debugged, already ours*, and its ceiling (hundreds–low thousands concurrent) is orders above a first voice channel's load. **rvoip stays on the watchlist with a named revisit trigger: its 1.0 release + published B2BUA/long-call measurements.** Rebuilding on FreeSWITCH is a scale decision to revisit only if concurrency ever becomes the binding constraint.

### 2.2 What the trunk adds
Origination (we place calls to any PK/world number), termination (inbound calls to our numbers), and — provider-dependent — **DID numbers**. Note the hard fact: **Twilio and Plivo sell NO Pakistan voice numbers** ✅ (both state this on their PK pricing pages). PK DID availability is provider-specific and must be confirmed at contracting ❓; without a PK DID, inbound is limited and outbound caller ID is a foreign or provider number (see 2.4).

### 2.3 Cost model
- **Fixed:** ≈ $0–30 to open (e.g. DIDWW: no monthly minimum, $30 minimum starting balance ✅). Trunk itself is pay-as-you-go at every provider checked.
- **Per minute — termination to Pakistan mobile, published 28 Nov 2026:**
  - Wholesale marketplace (PacketExchange, 16 live routes, hourly-refreshed ✅): mobile **from $0.0138/min** (Telenor) to **$0.0358** (Jazz/Zong/Ufone), country-wide from $0.0408 → **≈ Rs 3.8–11.3/min**, mostly 1/1 per-second billing, routes state "Full CLI"
  - 6X Wholesale live deck ✅: mobile CLI **$0.0215/min ≈ Rs 6.0**
  - DIDWW international termination ✅: **$0.0476/min ≈ Rs 13.2**
  - Retail-ish SIP (AstralSIP ✅): $0.0957–0.1368/min ≈ Rs 26.5–37.9 — the price of not shopping wholesale
  - **Planning figure: Rs 6–13/min** for quality CLI routes from a screened provider; the sub-Rs 4 headline routes exist but carry the grey-route risk in §4 and must be screened, not grabbed.
- TTS/recording/transcription are ours (Asterisk + our process): recorded prompts free; cloud Urdu TTS ≈ $4/1M chars (Google standard 📰, from B10 research); Azure TTS is the B10.5 BYOK candidate.

### 2.4 Caller ID
What the trunk passes: on screened CLI routes, a number we are entitled to present. In practice, without a PK DID or a PK-licensed upstream, the presented ID is a **foreign/provider number** — measurably lower answer rates in Pakistan, and presenting a *Pakistani mobile number we don't own* on an internationally-originated call is the grey-traffic pattern itself (§4) — **we will not do that, on any route, at any price.**

### 2.5 Quality / reliability
VoIP quality is route-quality: screened CLI routes over LDI-partnered upstreams are near-GSM; the cheapest marketplace routes are cheap for reasons (clipping, FAS, dropped CLI) that only show up in production. Per-second billing on most wholesale routes softens OTP economics (a 20-second OTP call costs ~⅓ of a rounded minute — the CPaaS/retail decks mostly bill 30s–60s minimums).

### 2.6 Zender fit
The PBX companion gains a trunk (config, not code in core); the same `voice` plugin as Route A fronts it — **the plugin is route-agnostic**: a call is placed "via line X", where a line is a SIM (Route A), a trunk (Route B), or later a CPaaS account (Route C). This is the one-line-registry design B10 already specified ("one line registry, every line type").

### 2.7 Both surfaces
- **API:** full programmable voice — originate via ARI, play recorded/TTS audio, gather DTMF (real DTMF this time — the callee's keypresses arrive on our own media path), record both legs, stream events to tenant webhooks, per-second CDRs. Voice OTP is a first-class citizen here, no merge dependency.
- **DIRECT:** two options — (a) **callback-bridge** (same UX as Route A: system rings the user's phone, then the destination, bridges), zero browser work; (b) **browser WebRTC softphone** (Asterisk PJSIP WebSocket + a panel dialler — the user talks in the browser tab). (a) first; (b) is +~2 lanes and is where FreeSWITCH's native WebRTC would have helped — Asterisk does it via PJSIP with more configuration, which is acceptable at our scale.

### 2.8 Effort
Trunk contracting is commercial elapsed time (days–weeks; owner/KYC side) running parallel to ~**4–6 lanes** of build (trunk config + ARI call-control service + plugin API/webhooks/billing + callback-bridge direct surface). WebRTC browser calling **+2 lanes** later.

---

## 3. Route C — CPaaS voice API (Twilio / Plivo / Vonage class)

Rent the whole thing: their numbers (foreign), their media, their uptime. Fastest first call, highest per-minute price, USD billing.

### 3.1 Verified Pakistan pricing (28 Nov 2026, providers' own PK pages ✅)

| | Outbound to PK | Inbound on PK number | Recording | Notes |
|---|---|---|---|---|
| **Twilio** | **$0.1550/min** local; **$0.1760/min** mobile (Elastic SIP deck) ≈ **Rs 43–49/min** | ❌ **No voice-enabled numbers in PK** (their words) | $0.0025/min + storage | Browser/app leg $0.0040/min; calls rounded up to the minute 📰 |
| **Plivo** | **$0.1410/min** ≈ **Rs 39/min** (mobile = local, same rate) | ❌ **Not supported**; no PK number types | **Free**; transcription $0.0095/min | SIP trunking variant $0.1380/min |
| **Vonage** | ❓ **PK rate not published** — dashboard/quote only ("voice from $0.01538/min" is a global starting figure, not PK) | ❓ | — | Per-second billing claimed globally |

### 3.2 Caller ID
No PK numbers exist on these platforms → outbound calls to Pakistan present a **foreign number**. For OTP that is survivable (users increasingly ignore foreign numbers, and some PK carriers flag them); for sales/support calling it is a real answer-rate handicap versus Route A's real SIM number. Presenting a PK mobile CLI through a CPaaS on PK termination is not offered — and if it were, it would be the grey pattern (§4).

### 3.3 Quality / reliability
Best-in-class media and uptime; the call still terminates into Pakistan through *their* LDI-partnered routes, which is precisely why it costs 3–8× the wholesale deck. Reliability risk is commercial instead: USD card billing for a Pakistani company (Rektrs has no foreign entity; top-ups ride on a card the owner controls), account verification/business KYC at signup, and per-minute rounding on short OTP calls.

### 3.4 Zender fit — and the right shape for it
As a **Sendqon-operated** channel it contradicts the platform's economics (we would resell Rs 43/min minutes against our own Rs 6–13 Route B cost). As a **tenant-BYOK integration** it fits perfectly — the B5 integrations pattern: the tenant pastes *their* Twilio/Plivo credentials, activates the module, and their calls ride their own account (the Operqon service-provider principle: integrations are self-service, validate-or-error, tenant's own credentials). Zero cost, zero billing risk, zero grey exposure for Rektrs.

### 3.5 Both surfaces (BYOK shape)
- **API:** our `voice` plugin proxies the tenant's CPaaS account (same Sendqon API shape as Routes A/B — the line registry abstracts it), webhooks normalised into Sendqon's event format, recordings linked from the provider.
- **DIRECT:** click-to-call via callback-bridge on the tenant's account, or the provider's browser SDK leg ($0.004/min on Twilio) behind the same panel dialler planned for Route B WebRTC.

### 3.6 Effort
~**2–3 lanes** (one provider first — Plivo for price/simplicity or Twilio for ecosystem; the second provider is a follow-on lane). No infrastructure. This is the fastest route to *a* working voice API call — and the most expensive one to actually use.

---

## 4. Regulatory — what adding VOICE changes (named section)

*This section informs the owner's decision; it makes none. Nothing has been filed or contacted for voice. The pending CVAS question below joins the same counsel opinion already queued with the SMS aggregator work (2026-11-18 feasibility report + drafts/).*

### 4.1 What is documented ✅
1. **SMS ≠ voice in PTA's CVAS scheme.** The 2026-11-18 feasibility work established SMS aggregation as a **CVAS Registration** category (Rs 10,000 one-time, 5 years). The Registration list also includes *Voice Mail Services* — but **outbound voice calling / call termination is not a Registration category**. Voice CVAS exists on the *Licence* side (e.g. Premium Rate, Card Pay Phone classes) — and **new Data & Voice CVAS Licence applications are currently SUSPENDED** (PTA Class VAS notice; Registration remains open). The pending Rs 10,000 Registration, if filed, covers the SMS business. **It does not by itself authorise a voice-calling service.**
2. **International termination is LDI-only.** Under the Pakistan Telecommunication (Re-organization) Act 1996 and the Telecom Deregulation Policy 2003, only PTA-licensed **LDI operators** may terminate international voice traffic into Pakistan. Traffic routed around them is **grey traffic** — actively enforced: PTA's Web Management Solution blocks grey channels, ~4.4 million SIMs were blocked in 2020–22 alone, and the public is asked to report foreign calls showing local numbers (SMS 8866). **Consequence for design:** any route whose economics depend on foreign-originated calls landing on PK phones with PK-looking caller ID — SIM boxes, unscreened bottom-of-market "termination" — is prohibited territory, full stop. It is excluded from every route above.
3. **Commercial VoIP use has its own paperwork.** Businesses using VoIP/SIP for commercial purposes register through PTA's **IP whitelisting** regime (ipregistration.pta.gov.pk); call-centre operations additionally sit under **PSEB** call-centre registration. This is the documented, routine compliance path for a PK company running a SIP trunk for its own/its customers' calls — free-to-cheap, portal-based.
4. **Domestic calls from ordinary SIMs are ordinary subscriber traffic.** Route A places normal domestic mobile calls from biometrically-verified SIMs. Nothing in the documented framework treats a subscriber's own domestic calls as "termination". The exposure on Route A is different in kind: **carrier anti-spam/fair-use enforcement and telemarketing rules** (bulk automated calling from consumer SIMs can get SIMs blocked by the CMO; marketing calls sit under PTA's spam/DNCR regime that already governs our SMS side).

### 4.2 What needs the counsel opinion (same engagement as the pending items)
- Whether **reselling voice minutes/API access to tenants** (the SaaS shape) is "providing a telecommunication service" requiring a Voice CVAS Licence — given new licences are suspended, the answer shapes whether Route B can be sold to tenants at all, or only used for Rektrs' own traffic until the window reopens.
- Whether tenant-originated calls over our PBX + a screened trunk stay inside the IP-whitelisting/PSEB-style compliance path, and whose name the trunk contract must sit in.
- Voice-specific obligations that have no SMS analogue: **call-recording consent**, telemarketing calling hours / DNCR scrubbing for voice, and CLI-presentation rules for outbound trunk calls.
- Whether the CVAS Registration (when filed for SMS) should simultaneously add **Content Services / Voice Mail Services** categories to widen the documented footprint cheaply.

### 4.3 Bottom line (regulatory)
Domestic-first design keeps us clean: Route A is subscriber traffic, Route B is lawful *if* the trunk's upstream is licensed and the resale question is answered by counsel **before** tenant selling starts, and Route C-BYOK puts the regulated activity in the tenant's own account. The one absolute: **no grey termination, no SIM-box economics, no borrowed caller ID — ever.**

---

## 5. Side-by-side

| | **A — Gateway SIMs** | **B — Own PBX + SIP trunk** | **C — CPaaS (BYOK)** |
|---|---|---|---|
| Fixed cost | ≈ Rs 0 (exists) | ≈ $0–30 open | Rs 0 (tenant's account) |
| Per minute (PK mobile) | **Rs 0.25–3.50** | **Rs 6–13** (quality CLI) | **Rs 39–49** |
| Caller ID | **Real SIM number** ✅ | Foreign/provider no. (no PK DID by default) | Foreign number |
| Programmable voice (TTS/OTP/DTMF) | ⚠️ Merge-dependent, DTMF unproven | ✅ Full, on our media path | ✅ Full |
| Recording | ✅ Merged conference (PBX leg) | ✅ Both legs | ✅ Provider-side |
| Concurrency today | 2 (fleet) | Trunk-limited (10s–100s) | Account-limited |
| Direct panel calling | Callback-merge (phones) | Callback-bridge; WebRTC later | Callback / browser SDK |
| Time to first call | After B10.2 battery | Contracting + 4–6 lanes | 2–3 lanes |
| Regulatory posture | Subscriber traffic; anti-spam care | Counsel question on resale | Tenant's own account |
| Main risk | Carrier merge variance | Trunk route quality screening | Cost; USD billing; answer rates |

## 6. Recommendation

**Route A first, Route B second, Route C as tenant-BYOK only — one `voice` plugin, one line registry, three line types.**

1. **Route A first** because it is the owner's founding thesis (the phone *is* the API), it is ~80% built (B10.0/B10.1 live; the app, fleet, balance tracking and PBX all exist), its per-minute cost is 2–40× lower than every alternative, and it is the only route whose caller ID is a real Pakistani number. Its one unproven link — carrier conference merge — is *already* the pending B10.2 battery; this channel simply promotes that battery to gating priority.
2. **Route B second** because it is the same PBX and the same plugin with a trunk added: it removes Route A's two ceilings (concurrency, merge-dependent programmability) and gives full TTS/OTP/DTMF/recording on our own media path, at wholesale cost. Counsel's resale answer (§4.2) is needed before *tenant* selling on this route, not before building or using it for Rektrs' own traffic.
3. **Route C never as our resale, yes as BYOK**: a tenant who already pays Twilio/Plivo should be able to plug their account in as a line type — B5-pattern integration, our margin is the platform, not their minutes.
4. **rvoip: not now.** The comparison was run for real (§2.1): its published numbers are signalling/echo-endpoint numbers; the B2BUA + long-call evidence a production voice channel needs does not exist yet. Watchlist with a revisit trigger (1.0 + B2BUA benchmarks), alongside the standing Asterisk base.

## 7. Phased build sketch (end state fixed by the owner: **both surfaces**)

- **Phase V0 — Proof gate (no new build):** run the pending **B10.2 battery** — pair the owner's phone to telephony server 8, prove conference merge + DTMF pass-through per carrier (Jazz, Zong first; Ufone slot is in the same phone). Output decides which Route A modes (announce/OTP) are sellable per carrier. *Owner phone step required — already on his list.*
- **Phase V1 — API first (Route A):** `voice` plugin v1: line registry (SIM lines), `POST /api/v1/voice/calls` (bridge + announce modes), status webhooks, call log + per-minute credit metering in panel, gateway-app voice engine toggle (dial/merge commands). **DIRECT ships in the same phase** as panel click-to-call (callback-merge) — the owner's "dono" is the acceptance criterion, not a later phase.
- **Phase V2 — Programmable voice on Route A:** voice OTP + announcement playback via the PBX leg (recorded prompts primary; cloud Urdu TTS for dynamic strings), conference recording retrieval, per-carrier capability matrix published in-panel (honest "OTP supported on Zong, not yet on X" instead of silent failure).
- **Phase V3 — Route B:** trunk contract (screened CLI provider; DID if obtainable), trunk as a line type, full IVR/DTMF on our media path, per-second billing, **browser WebRTC dialler** for direct calling. *Tenant selling on this route waits for the §4.2 counsel answer; Rektrs' own use does not.*
- **Phase V4 — Route C BYOK (optional, demand-led):** Twilio/Plivo as tenant-activated line types under the same plugin.

**Pricing sketch for the owner (decision, not design):** Route A minutes can retail at SMS-like margins even at Rs 8–15/min against a Rs 0.25–3.50 cost; Route B at Rs 15–25/min against Rs 6–13. Final numbers sit with the plan-pricing decisions already pending (`phone_bridge` flag pricing is one of them).

---

## Sources (all accessed 28 Nov 2026)
- Twilio Programmable Voice pricing — Pakistan; Twilio Elastic SIP Trunking pricing — Pakistan (PK $0.1510 landline / $0.1760 mobile per min; "no voice-enabled numbers in this locale")
- Plivo Voice pricing — Pakistan ($0.1410/min; inbound not supported); Plivo SIP Trunking pricing/coverage — Pakistan ($0.1380/min; no inbound number types)
- PacketExchange — Pakistan voice termination (16 routes, mobile from $0.0138/min, operator breakouts, refreshed 28 Nov 2026); 6X Wholesale live rates — Pakistan (mobile CLI $0.0215/min); DIDWW SIP trunking pricing — Pakistan ($0.0476/min, $30 minimum start); AstralSIP rates — Pakistan ($0.0957–0.1368/min)
- PTA prepaid tariff data as reported 30 Sep 2026 (Zong Rs 2.68–2.97/min, Ufone Rs 3.50/min, setup Rs 0.15); Zong/Ufone bundle listings Nov 2026
- rvoip GitHub repository + published RFC 7501/7502 benchmark (0.5.0) — incl. its own "not yet measured" list (B2BUA, long calls, transcoding, WebRTC, failover)
- FreeSWITCH vs Asterisk comparisons (TelcoBridges; SheerBit; PBXScience) — Asterisk ~4,500 concurrent published load test; FreeSWITCH higher per-node ceiling
- PTA framework: LDI-only international termination + grey-traffic enforcement (PTA Act 1996 / Deregulation Policy 2003; ~4.4M SIMs blocked 2020–22; report line 8866); PTA IP whitelisting portal for commercial VoIP; PSEB call-centre registration; CVAS scheme per SENDQON-AGGREGATOR-FEASIBILITY-REPORT-2026-11-18.md (Registration categories; Voice/Data licence suspension)
- Internal: SENDQON-PHONE-BRIDGE-RESEARCH-2026-11-19.md; SENDQON-B10-PHONE-BRIDGE-BUILD-REPORT-2026-11-19.md; SENDQON-B9-TELEPHONY-FINAL-BUILD-REPORT-2026-11-18.md
