# Study — FreeSWITCH (signalwire/freeswitch) vs our Asterisk PBX — comparison only

**Date:** 2026-11-28 · **Studied for:** one question, asked by the owner and answered on the record — the voice design (`../SENDQON-VOICE-CHANNEL-DESIGN-2026-11-28.md`, §2.1) already chose **Asterisk** (deployed, debugged, B10.0/B10.1 live). Is there any *named future condition* under which the PBX choice should be re-opened in FreeSWITCH's favour? This study does not re-run the original decision; it stress-tests its exit conditions.
**Sources:** GitHub repo + API (checked live 2026-11-28), repo `LICENSE` (Debian copyright-format file) verbatim, the voice design's own comparison table and the B10 build record for the Asterisk-side facts. READ-ONLY study — nothing was installed or deployed.

## What it is

A software-defined telecom platform (C; Sofia-SIP stack) built from the start as a **B2BUA and media server** — every call leg is a first-class threaded session — with strong conferencing (mod_conference), an event-socket control plane (ESL), XML/Lua dialplan programmability, and **Verto**, its native WebRTC stack. It was created by Anthony Minessale II, an Asterisk contributor who left to build the thing Asterisk wasn't shaped for; that origin explains both its strengths (media/concurrency architecture) and its centre of gravity (its own XML/Lua/module world). Steward: **SignalWire**, a commercial company whose cloud business sits beside the open-source core. Repo stats at study time: **5,336 stars, 1,922 forks, 1,289 open issues**, created 2018-10-24 (the GitHub mirror's age; the project itself dates to 2006); latest release **v1.11.4 (2026-11-18)**, commits 2026-11-26 — actively maintained on a steady cadence.

## 1. Licence

The repo `LICENSE` (Debian copyright-format) states the core is **MPL-1.1** — file-level copyleft: FreeSWITCH's own source files stay MPL if modified and distributed, while our separate code that merely *talks* to it (ESL clients, dialplan glue in our repos) is unaffected. Individual modules carry their own licences, which an adopter audits per module. For our use shape (unmodified core as a companion, controlled over ESL/SIP), **MPL-1.1 is a non-issue** — comparable in practical friction to Asterisk's GPL-2.0-with-exceptions posture for a companion deployment. Licence decides nothing in this comparison, in either direction.

## 2. What it adds that we don't have — FreeSWITCH on its merits

Against our live Asterisk (`sendqon-pbx:1.0.0`, telephony server id 8, `phone_bridge` shim, Pipecat pipeline planned behind it):

| Dimension | FreeSWITCH | Our Asterisk today | Material at our scale? |
|---|---|---|---|
| **Concurrent-call ceiling per node** | Higher practical ceiling on comparable hardware — per-leg threading + a media path designed for density (the voice design already conceded this) | Published ~4,500 concurrent on 48-core bare metal; practical few-hundred–low-thousand with IVR/queues per node | **No.** Our ceiling today is 2 SIMs (Route A); Route B trunk concurrency is planned in the tens. The gap between the two ceilings sits orders of magnitude above any load we can currently name |
| **WebRTC** | **Verto is genuinely first-class** — browser calling is a native citizen, not an assembly | Workable via PJSIP WebSocket + panel dialler; the voice design priced it honestly (+~2 lanes, "where FreeSWITCH's native WebRTC would have helped") | Not yet — browser dialler is a Phase-later extra behind callback-bridge; if it ever becomes the *primary* surface, this row changes weight (see §8, condition 2) |
| **Conferencing / media features** | mod_conference is a flagship feature (large, managed conferences, video) | ConfBridge covers our designed needs (the Route A merge leg is a 2–3 party bridge) | No — our conference is a merge mechanism, not a product |
| **Control plane** | ESL + XML dialplan + mod_xml_curl (dynamic config from HTTP) — powerful, and entirely its own idiom | ARI/AMI + dialplan — the idiom our B10.0/B10.1 work, DTMF battery and adapter already speak | Switching resets this to zero (see §6) |
| **AI-leg integration** | Would need its own glue (media fork/SIP) into the Pipecat companion | Pipecat study's chosen path is Asterisk `chan_websocket` via `pipecat-asterisk`, with Pipecat's native SIPTransport as the tracked alternative | Neutral-to-Asterisk: the SIPTransport alternative makes the *AI leg* PBX-agnostic over time, which weakens "we must switch for the AI future" arguments in both directions |

FreeSWITCH is, on the merits, the stronger *media platform*. The voice design said so too. That was never the deciding axis.

## 3. Stack fit

The deciding axis is fit with the team and the estate. Sendqon's working languages are **PHP (Laravel plugins), Node (bridges) and Python (Pipecat companion)**. Asterisk knowledge is already *banked and proven in production*: the B10.0 IVR crash was root-caused to Asterisk issue #566 and fixed in our own pinned image (`res_timing_timerfd.so`); the B10.1 adapter speaks to it; the DTMF battery passed 5/5 four times; core's telephony-server model already registers it as server id 8. FreeSWITCH fluency in this team is **zero** — its XML dialplan, Lua scripting and C-module ecosystem would be a new discipline bought at full price, on a component that sits in the call path of a channel that has not yet carried its first production call. A PBX is not a library you adopt; it is an operations practice you staff.

## 4. Integration route

Hypothetically: companion service replacing `sendqon-pbx` behind the same telephony-server contract (new adapter, new image, new battery). Documented here so the verdict rejects a *described* route, not a strawman.

## 5. Effort

- A like-for-like swap (companion image, adapter parity with B10.1, DTMF/IVR battery parity, Pipecat leg re-proof): **~4–6 lanes** — and it buys **zero new capability at current scale** (§2's right-hand column). Every one of those lanes would be spent re-proving things that are already proven, while the voice channel's actual gate (B10.2, the owner's phone proof) waits untouched, because B10.2 is a *carrier/phone* proof, not a PBX proof — FreeSWITCH does not move it by a single day.

## 6. Risk

- **Re-proving risk:** the swap discards a debugged production asset (pinned image, known failure modes, a written root-cause history) for an unknown-unknowns estate in the most failure-visible component we run — a ringing phone that fails is noticed in seconds.
- **Team-depth risk:** a 2 a.m. FreeSWITCH incident would be debugged by a team learning the platform during the incident. Asterisk incidents are debugged from notes we already own.
- **Steward gravity (minor, stated for symmetry):** SignalWire's commercial centre is its cloud; the open core is genuinely MPL and actively released, but — as with Evolution's foundation — the steward's incentives point at its own platform. We record this the same way we record it for others; it is not a deciding factor here.
- **The meta-risk:** re-opening settled infrastructure decisions without a load-bearing reason is how the voice channel dies of architecture. The design's discipline — Asterisk now, named triggers for change — is itself the asset this study protects.

## 7. Maintenance health (live-checked 2026-11-28)

5,336 stars / 1,922 forks / 1,289 open issues (a large queue against a large, old codebase — read as scale, not neglect); **v1.11.4 on 2026-11-18**, commits within the study week; two decades of project history. Health: **good and steady** — which is precisely why "wait for a better FreeSWITCH" is not a strategy variable: it is already good, and it still doesn't change the answer.

## 8. Verdict — **NO-GO (Asterisk stands)**, with four named re-open conditions

FreeSWITCH wins the media-platform argument and loses the only argument that matters today: it would cost 4–6 lanes and a full re-proof to acquire capacity and WebRTC polish that sit far above our named load, paid for with the team's only banked PBX expertise, while moving the voice channel's real gate (B10.2) not at all.

**The PBX question re-opens if and only if one of these named conditions occurs:**
1. **Concurrency becomes the binding constraint** — sustained load approaching Asterisk's practical per-node IVR ceiling (order: several hundred concurrent media+IVR calls on one node, or a Route B trunk business whose margin is decided by per-node density). Measure first; the trigger is a *measured* ceiling, not a benchmark article.
2. **Browser calling becomes the primary product surface** — e.g. a tenant contract for WebRTC call-centre seats in the panel, where Verto's maturity is worth a platform migration and the contract pays for it.
3. **A partner or hire brings FreeSWITCH as their stack** — a voice partner/aggregator whose platform is FreeSWITCH-based, or a team member with production FreeSWITCH depth, changing the §3 equation from outside.
4. **Asterisk hits a wall we cannot patch** — a production limitation or defect in our Asterisk estate with no acceptable workaround (the generic escape hatch; the B10.0 precedent says our first move is root-cause + pin, and it worked).

**Explicit non-triggers** (recorded so they are not mistaken for reasons later): Pipecat adoption (the AI leg is PBX-agnostic via SIP by design), rvoip's progress (its own watchlist entry), a new FreeSWITCH release (steady cadence is normal, not news), and benchmark comparisons unaccompanied by our own measured load.

**One-line verdict: FreeSWITCH is the better media platform and the wrong decision — Asterisk is live, debugged, staffed and two orders of magnitude above our load; the PBX question re-opens only on measured concurrency, a WebRTC-first contract, a FreeSWITCH-native partner, or an Asterisk wall we cannot patch.**
