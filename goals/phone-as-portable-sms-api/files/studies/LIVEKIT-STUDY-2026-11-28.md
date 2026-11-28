# Study — LiveKit (livekit/livekit + livekit/agents) vs Pipecat: the Phase 6 media/agent layer decision

**Date:** 2026-11-28 · **Studied for:** one decision — Phase 6 of the Automation + 2-Way MCP build (2-way MCP voice front-end) needs a media/agent layer behind the Asterisk conference-merge leg. The corner's [PIPECAT-STUDY-2026-11-28.md](PIPECAT-STUDY-2026-11-28.md) already returned **GO for Pipecat**; the [FONOSTER-STUDY-2026-11-28.md](FONOSTER-STUDY-2026-11-28.md) returned WATCHLIST for the third candidate for the same seat. This study is the head-to-head that completes the three-way comparison of **one layer**: Pipecat vs LiveKit Agents vs Fonoster.
**Sources:** GitHub API + repo `LICENSE` files (live-checked 2026-11-28), PyPI, LiveKit docs and third-party deployment guides (flagged where used), HuggingFace model card for the turn detector, press coverage of the Series C. READ-ONLY study — nothing was installed or deployed.
**Hard constraint carried in from the voice design:** Asterisk (`sendqon-pbx`) keeps call control — the SIM/trunk legs, the Route A conference-merge, recording and per-minute billing. **B10.2** proves that merge on Jazz + Zong with the owner's real phone. Whichever framework wins sits *behind* the merged leg; a candidate that needs to own the call edge is disqualified by construction (that is what eliminated Fonoster).

## What LiveKit is

Two open-source pieces plus a family of satellite services, all from LiveKit Inc:

- **`livekit/livekit`** — a WebRTC **media server (SFU)** in Go, built on Pion. Everything is a *room* of *participants* publishing/subscribing media tracks. **22,435 stars, 2,613 forks** (GitHub API, 2026-11-28), latest release **v1.13.11 (2026-10-25)**, created 2020-09.
- **`livekit/agents`** — the **Agents framework** (Python; a JS sibling exists): server-side workers that join rooms as participants and run voice pipelines (VAD → STT → LLM → TTS) with turn detection, interruption handling and telephony control. ~15k stars (badge count, rounded), Python package **`livekit-agents` 1.9.0** on PyPI at study date, plugins versioned in lockstep.
- **`livekit/sip`** — the **SIP service**: a separate Go service that bridges SIP calls into rooms as participants (inbound trunk + dispatch rules; outbound via `CreateSIPParticipant`; transfers via SIP REFER). ~500 stars. It talks to the media server **through Redis only** — there is no SIP without Redis in this architecture.
- Egress (recording), Ingress (RTMP/WHIP) — sibling services we would not need for Phase 6.

The company's health is the strongest in this corner: **$100M Series C in January 2026 at a $1B valuation**, led by Index Ventures with Salesforce Ventures, Altimeter, Redpoint and Hanabi (company announcement 2026-01-22; Wikipedia and trade press agree; total raised ~$183M). A further $40M "Series C-1" at a $1.45B valuation is reported by secondary trackers (Forge/Tracxn) — **labelled secondary-source, not needed for the verdict**. LiveKit powers ChatGPT's voice mode (widely reported) — the framework is load-tested at a scale our fleet will never approach.

## 1. Licence

**Apache-2.0 across the stack** — verified from the `LICENSE` files of `livekit/livekit` and `livekit/agents` (stock Apache-2.0 text, read 2026-11-28); the SIP service is likewise published under Apache-2.0 (its container-image metadata states Apache-2.0; a root `LICENSE` file could not be re-read verbatim at study time — labelled, low risk). No activation, no heartbeat, no brand conditions, no usage notice — as clean as Pipecat's BSD-2 for our purposes.

Two honest footnotes, neither disqualifying:

- **The turn-detector model weights are not Apache.** The plugin code is Apache-2.0, but the open-weights EOU model is distributed under the **LiveKit Model License** (PyPI package page, verbatim). Self-hosting the model is the documented path, but its licence is a separate instrument from the framework's — a pre-adoption lane would read it in full.
- **Cloud-only withholdings exist, and they are the company's business model.** What LiveKit Cloud sells and the OSS stack does *not* include: managed agent hosting/deployment, the Agent Builder, built-in **Inference** (their hosted STT/LLM/TTS gateway), the observability stack, **Krisp noise cancellation** (the plugin package is public; the noise-cancellation models are a Cloud/licensed feature), LiveKit-issued phone numbers and managed SIP trunking, and token revocation. The OSS framework itself is not feature-gated — an `AgentSession` self-hosted is the same class as one on Cloud — but the gravity of the ecosystem (docs, examples, new features) points at Cloud first. Pipecat's vendor (Daily) has the same shape of incentive, with a smaller cloud to sell.

## 2. What it adds that we don't have

Against the decided stack, LiveKit's genuine deltas over Pipecat are:

| LiveKit piece | Pipecat equivalent | Delta for us |
|---|---|---|
| **A real SFU** — multi-party rooms, WebRTC participants (browsers, mobile SDKs), track subscription | Pipecat has transports (incl. a LiveKit transport — Pipecat can itself ride on LiveKit) but is not a media server | **Real but currently unaddressed to a need**: Phase 6 calls are 1 caller + 1 AI leg. No browser/video/multi-party surface exists in the design |
| **Worker/dispatch scaling model** — agent servers register, the server dispatches jobs, drain/scale semantics are trodden | One pipeline process; scaling is our problem | Real at volume; our launch volume is 2 concurrent calls |
| **SIP as a first-party service** with trunk objects, dispatch rules, REFER transfers, DTMF | Community `pipecat-asterisk` package or Pipecat's young native `SIPTransport` | LiveKit's SIP is more productised — but shaped as a **trunk peer into rooms**, not as a PBX leg (see §3) |
| **Cloud plugin catalogue** (~30 official STT/TTS/LLM plugins: Deepgram, ElevenLabs, Cartesia, OpenAI, Google…) | Pipecat's catalogue is comparably broad (~25 STT / ~30 TTS) | A wash — and our speech is deliberately *local*, where the comparison inverts (§4) |
| **Semantic turn detector** as a maintained, open-weights model with a dedicated plugin | Pipecat's Smart Turn (audio-prosody model) | Different mechanism, not a clear win — and for Urdu specifically, a loss (§4) |

## 3. The deciding axis — SIP/PSTN path through OUR Asterisk

**LiveKit's shape:** the SIP service is a **trunk peer**, not a PBX extension and not a media-stream consumer. The documented Asterisk integration (LiveKit docs + multiple deployment guides) is a mutual trunk: Asterisk treats the LiveKit SIP endpoint like any SIP trunk (PJSIP peer, IP/digest auth, `allowed_addresses` locked to the PBX), and either (a) Asterisk sends the AI leg as an INVITE into an *inbound trunk*, whose dispatch rule drops it into a room where the agent worker is waiting, or (b) the agent side creates an *outbound* SIP participant that calls into Asterisk. **No PBX replacement is required** — this is the standard "add AI agents to an existing PBX" pattern, and it is honest to say it works.

**Does B10.2 survive? Yes — structurally unchanged.** The conference-merge is Asterisk's act; under LiveKit the merged AI leg simply arrives as a SIP call from the SIP service instead of a WebSocket channel or a registered SIP endpoint. Asterisk still owns the SIM leg, the merge, the recording and the billing. The gate proves the same thing either way.

**But the media path is longer, and the joint is different in kind:**

```
Pipecat:   Asterisk ⇄ (chan_websocket | SIP registration) ⇄ pipeline process
LiveKit:   Asterisk ⇄ SIP trunk ⇄ SIP service ⇄ (Redis) ⇄ SFU room ⇄ (WebRTC) ⇄ agent worker
```

- Two extra network/component hops (SIP service, SFU) sit between the PBX and the conversation code, each a process that can fail, be upgraded, or mis-route — on a host where the whole Sendqon fleet already shares 2 OCPUs.
- The relationship is a **trunk** (stateless, IP/digest-auth) rather than Pipecat `SIPTransport`'s **registration as an extension** or `chan_websocket`'s purpose-built channel. A trunk is operationally respectable — it is how carriers interconnect — but the AI leg becomes "a call from a peer," and per-leg control from the agent side runs through LiveKit's room/SIP APIs (mute, DTMF via the SIP participant, REFER transfer) rather than through the PBX-native channel the voice plugin already speaks to.
- DTMF and transfers are supported (RFC 4733 DTMF both ways; `TransferSIPParticipant` via SIP REFER) — parity with our needs, no gap. The gap is not capability; it is indirection.

## 4. Conversation machinery + provider surface — where the comparison actually turns

**Turn detection.** LiveKit's detector is a *text-semantic* model: a Qwen2.5-0.5B fine-tune (INT8 ONNX, ~25 ms inference, <500 MB RAM) that reads the **transcript** and predicts end-of-utterance, with **per-language thresholds for 13 named languages** (HF model card + plugin docs: English, French, Spanish, German, Italian, Portuguese, Dutch, Chinese, Japanese, Korean, Indonesian, Russian, Turkish). **Urdu is not among them.** Pipecat's Smart Turn reads **audio prosody**, not transcript text — it has no transcript language list to fall off. For our weakest link — Urdu, where the faster-whisper study puts telephonic WER at ≈46.6% (assist-grade transcripts) — a transcript-semantic turn detector is a second consumer of exactly the signal we trust least, with no Urdu threshold at all; a prosody model is indifferent to transcript quality. This is a small axis that points the wrong way for LiveKit *in our market specifically*.

**Interruption/barge-in.** Both frameworks treat it as a headline feature (LiveKit 1.x advertises adaptive interruption handling; Pipecat's pipeline is built around interruption frames). No independent head-to-head measurement was found at study time — **any latency or quality ranking between the two on this axis is unverified**, and both are component-dominated in our shape: the Pipecat study's budget (~1.5–3 s stop-talking → first reply audio with local CPU STT; ~1 s class with cloud streaming STT) is a property of faster-whisper + Gemini + Piper, and the same components under LiveKit Agents would land in the same class. Vendor latency claims from either camp assume cloud streaming providers we are not using.

**Local STT/TTS — the inversion.** Our speech stack is local by design (cost: Route A's ~Rs 0.25/min bundle economics die if every call pays cloud speech rates).

- **Pipecat ships both engines as maintained services**: `WhisperSTTService` built on faster-whisper, `PiperTTSService`/`PiperHttpTTSService` — verified in the Pipecat study from Pipecat's own source.
- **LiveKit Agents has no official faster-whisper or Piper plugin.** Every plausible package name 404s on PyPI (`livekit-plugins-whisper`, `-faster-whisper`, `-piper`, `-local`). Custom providers are supported *by design* — the framework exposes `stt.STT` / `tts.TTS` base classes precisely so you can implement your own, and community examples exist — but the adapters for our two engines would be **ours to write and maintain**, one per engine, tracking a fast-moving framework API.
- **LLM is a wash**: both take an OpenAI-compatible `base_url` (LiveKit via its OpenAI plugin; it also has a first-party Google plugin), so AiGateway/Gemini — the same brain as the WhatsApp agent — plugs into either unchanged.

Net: the layer where LiveKit's catalogue is bigger (cloud speech) is the layer we refuse to buy; the layer we insist on (local speech) is the layer where Pipecat is batteries-included and LiveKit is BYO-adapter.

## 5. Self-host weight on offbox-1 (ARM64, 2 OCPU / 12 GB, shared fleet)

| | Pipecat route | LiveKit route |
|---|---|---|
| New running components | **1** Python companion process | **4**: media server (Go binary) + **Redis** (mandatory — the SIP service reaches the server only through it) + SIP service + agent worker process |
| Extra network estate | One WebSocket/SIP leg to the PBX (host-local) | SIP 5060 + an RTP range (default 10000–20000/UDP) for the SIP service, server RTC/UDP ports, Redis — a second public-UDP estate on the box, next to the already-open B10.4 (coturn/public-UDP) question |
| ARM64 | Pure Python; ARM64 wheels for its heavy deps (per Pipecat study) | Official linux/arm64 builds + images exist for server and SIP (verified in distribution listings) — not a blocker |
| Fit at launch volume (≤2 concurrent calls) | Comfortable | Also fits — the objection is operational surface, not capacity |

Neither route is capacity-blocked. The difference is that LiveKit asks a shared 2-OCPU box to host a small *platform* (with a Redis and an SFU that exist to serve rooms we don't have), while Pipecat asks it to host a *process*.

## 6. Maturity, churn, company health

- **LiveKit**: server v1.13.11 (2026-10-25); agents Python at **1.9.0** — the 1.0 line began April 2025, so roughly nine minor releases in ~19 months: a fast cadence with the same pinning discipline Pipecat demands (the Pipecat study's condition — pin exact versions, upgrade deliberately — applies identically). Company health is the best in this corner (§ header: $100M Series C, $1B valuation, ChatGPT voice as a reference deployment). The realistic risk is not abandonment; it is **cloud-first drift** — telephony docs lead with LiveKit Cloud + trunk providers, and the withheld pieces (§1) are exactly the operational comforts (hosting, inference, observability) a small self-hosting team feels most.
- **Pipecat**: 1.17.0 six days before its study; backed by Daily; BSD-2; the churn caveat is identical in kind.
- **Fonoster**: pre-1.0 (v0.66.0), mid-rebuild, single-maintainer release line, self-declared instability (per its study).

## 7. The three-way table

| Axis | **Pipecat** | **LiveKit Agents** | **Fonoster** |
|---|---|---|---|
| Licence | BSD-2 (cleanest) | Apache-2.0 (+ model-licence footnote on turn detector; cloud-only comforts withheld) | MIT |
| Shape | Pipeline framework, no media server | SFU + agent framework + SIP service | Full voice platform on its **own** stack (Routr/RTPEngine) |
| Meets our Asterisk how | `chan_websocket` (purpose-built) or registers as a SIP extension (`SIPTransport`) | **SIP trunk peer** → room → agent (works, more hops) | Cannot sit above Asterisk; only as trunk owner — **inverts the design** |
| B10.2 merge survives | Yes | Yes | **No** (strands the proof) |
| Call control from agent | Via Asterisk leg (PBX keeps control by design) | Via room/SIP APIs (REFER, DTMF) — capable, indirect | Full — but only inside its own stack |
| Local faster-whisper + Piper | **Built-in services** | **No official plugins** — custom adapters are ours | No (its catalogue is cloud speech) |
| AiGateway/Gemini as LLM | OpenAI-compatible service → yes | OpenAI plugin `base_url` → yes | Catalogued LLMs only (as verified in its study) |
| Turn detection for Urdu | Smart Turn = audio prosody, transcript-independent | Semantic model over transcripts; **Urdu not in its 13 languages** | Fonoster-side speech stack (cloud) |
| Self-host weight (offbox-1) | 1 process | 4 components + Redis + UDP estate | A second PBX-class fleet |
| Maturity signal | 1.17.0, weekly-ish, Daily-backed | 1.9.0 agents / v1.13.11 server, $100M Series C, $1B valuation | v0.66.0 pre-1.0, mid-rebuild, bus-factor 1 |
| WebRTC/multi-party future | Rides transports (incl. LiveKit's) | **Its home turf** — SFU rooms, browser/mobile SDKs | Partial (its own rooms/app model) |

## 8. Verdict — **KEEP Pipecat for Phase 6** (LiveKit: **WATCHLIST**, the named successor)

The Pipecat study's GO stands, and this head-to-head strengthens rather than dents it. Ranked reasons:

1. **Local speech is built into Pipecat and hand-built under LiveKit.** Our two chosen engines are maintained Pipecat services; under LiveKit they are two adapters we write and maintain against a fast-moving API. This is the axis our cost model (local speech, SIM-bundle minutes) actually stands on.
2. **Operational weight.** One companion process vs a four-component platform (server + Redis + SIP + worker) plus a second public-UDP estate, on a shared 2-OCPU host, to serve two concurrent phone legs.
3. **The Asterisk joint is more direct in Pipecat** — a purpose-built WebSocket channel, or a SIP registration as an extension — vs LiveKit's trunk-into-a-room indirection. Both preserve B10.2; Pipecat's version of the leg is the one the voice plugin's call-control model already assumes.
4. **Urdu turn detection.** Prosody-based Smart Turn vs a transcript-semantic detector whose published language list omits Urdu, fed by our least-trusted signal (46.6%-WER Urdu transcripts).

LiveKit's wins are real and recorded: the strongest company health in the corner, a genuinely productised SIP service, the trodden worker-scaling model, and the only real SFU. They are wins on axes Phase 6 does not load. **Effort honesty:** switching to LiveKit would cost roughly **+2–3 lanes over the Pipecat plan** (fleet stand-up + trunk wiring + two provider adapters), buying capability the phase doesn't use — labelled an estimate, as all lane figures are.

**Conditions that would flip this verdict:**
- **(F1) A WebRTC participant surface becomes a product requirement** — browser click-to-call *inside* the call, video, multi-party rooms. That is LiveKit's home turf; Pipecat itself would ride on LiveKit as its transport, and running both stops making sense.
- **(F2) The Pipecat–Asterisk joint fails its Phase 6 battery** — `chan_websocket`/`pipecat-asterisk` proves unreliable *and* `SIPTransport` disappoints — while a LiveKit SIP trunk leg into Asterisk proves clean in a spike.
- **(F3) Concurrency outgrows a single-process pipeline** — sustained call volume where LiveKit's dispatch/drain worker model is the trodden path and Pipecat scaling becomes bespoke.

**The tie-breaker prototype, if the owner wants empirical proof anyway:** one spike lane — stand up server + Redis + SIP on offbox-1, trunk it to the *dev* PBX, run the same scripted English + Urdu call through both stacks, and measure time-to-first-audio, interruption behaviour and turn behaviour on Urdu. Cost ≈ **1 lane**. My recommendation does not need it — the deciding axes above are structural (adapter ownership, component count, joint shape, detector mechanism), not performance margins a spike would move — but it is the honest empirical option, and it doubles as the F2 test if the Pipecat joint ever wobbles.

*Watchlist triggers: F1–F3 above; LiveKit shipping official local-inference plugins (faster-whisper/Piper-class) would soften reason 1 and earn a re-read; the LiveKit Model License's full text gets read before any adoption, not after.*
