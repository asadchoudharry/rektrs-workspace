# Study — Pipecat (pipecat-ai/pipecat) as the Phase 6 voice-pipeline orchestrator

**Date:** 2026-11-28 · **Studied for:** Sendqon's voice build — the Phase 6 voice front-end of the Automation + 2-Way MCP programme (design: `../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`), which sits on the voice channel design (`../SENDQON-VOICE-CHANNEL-DESIGN-2026-11-28.md`) and is gated on the B10.2 conference-merge proof (Jazz + Zong, owner's real phone).
**Sources:** GitHub repo + README (checked live 2026-11-28), repo `LICENSE`, PyPI (`pipecat-ai`), Pipecat docs (services/transports), the latest release notes, and third-party integration write-ups for the Asterisk paths (flagged as such where used). READ-ONLY study — nothing was installed or deployed.
**Pipeline siblings:** [FASTER-WHISPER-STUDY-2026-11-28.md](FASTER-WHISPER-STUDY-2026-11-28.md) (its local STT) · [PIPER-STUDY-2026-11-28.md](PIPER-STUDY-2026-11-28.md) (its local TTS). The three are one pipeline decision; the combined recommendation is in the corner [INDEX.md](INDEX.md).

## What it is

Pipecat is an open-source **Python framework for building real-time voice (and multimodal) agents**, maintained by Daily. A bot is a *pipeline* of frame processors: transport → VAD/turn-taking → STT → LLM context → LLM → TTS → transport, with interruption (barge-in), metrics/observers, function/tool calling, and structured conversation state (Pipecat Flows) built in. It is a framework you host yourself — not a service and not a telephony stack. Repo stats at study date: **17,495 stars, 3,197 forks, 16,074 commits, 127 releases, created 2023-12-27** (GitHub, 2026-11-28).

## Licence

**BSD 2-Clause** — verified from the repo `LICENSE` file ("BSD 2-Clause License, Copyright (c) 2024–2026, Daily") and GitHub's licence detection. Permissive: commercial/SaaS use, modification and redistribution all fine with notice retention. **No copyleft, no usage notice, no activation — the cleanest licence in this corner so far.**

## What it adds that we don't have

Everything between "audio arrives" and "audio leaves" that our current stack does *not* contain:

- **Turn-taking machinery** — VAD, end-of-turn detection, barge-in/interruption handling. This is the part of a voice agent that is hardest to hand-roll correctly in Asterisk dialplan/ARI.
- **Streaming service abstractions** — ~25 STT, ~30 LLM and ~30 TTS providers behind one interface each (full catalogue in the repo README), including the two local engines studied alongside this file: its `WhisperSTTService` is built on **faster-whisper** (verified in Pipecat's source: `WhisperSTTService(SegmentedSTTService)` importing `faster_whisper.WhisperModel`), and it ships `PiperTTSService` + `PiperHttpTTSService`.
- **LLM tool calling in the voice loop** — the mechanism Direction 2 of the MCP design needs (the caller's LLM session calling the Sendqon tool registry). Its OpenAI-compatible LLM service can point at any OpenAI-style `base_url` — which is exactly the shape of our live AiGateway provider row (OpenAI-type, Gemini behind it), so the voice brain can be the *same* brain as the WhatsApp agent/KB.
- **Conversation structure** — Pipecat Flows for scripted/guided flows (IVR-style state machines with LLM freedom inside nodes), plus multi-agent composition we do not need on day one.

## Telephony — the honest part: how does a phone call actually reach it?

Pipecat core does **not** terminate PSTN calls and does not ship an Asterisk channel. Its transports are Daily (WebRTC), LiveKit, SmallWebRTC, FastAPI/WebSocket server, and WhatsApp; telephony in the vendor sense arrives via **media-stream serializers** (Twilio, Telnyx, Plivo, Exotel, Vonage, Genesys — the CPaaS streams call audio over a WebSocket and Pipecat consumes it). For **our own Asterisk** (the B10 PBX, `sendqon-pbx`), three real paths exist, ranked:

1. **`chan_websocket` + the community `pipecat-asterisk` package** — Asterisk's native WebSocket channel driver carries bidirectional audio + lifecycle events; the community package provides `AsteriskWebsocketTransport` + serializer for signed-linear audio (`Dial(WebSocket/pipecat/c(slin16))`). This is the path Pipecat's own maintainers steered Asterisk users to (a core Asterisk-transport request/PR was closed in favour of the community package). Purpose-built for exactly our shape; the dependency is a small community package (forkable, single-purpose). Requires a `chan_websocket`-capable Asterisk (20.16+/21.11+/22.6+/23 lines) — our PBX image's Asterisk version must be confirmed at build time.
2. **Pipecat's new native `SIPTransport`** (landed in the current release line, built on `baresip-python`, installable as `pipecat-ai[sip]`) — Pipecat registers as a SIP endpoint in its own right: dial-in/dial-out, DTMF both ways, REFER transfers (its docs name Asterisk/FreeSWITCH-class peers explicitly). In our design Asterisk would simply *dial the Pipecat extension into the conference* — the fewest moving parts and pure standard SIP, no CPaaS and no Daily anywhere in the path. But it is the youngest code in this study (first release weeks old) — treat as the promising second option, not the day-one bet.
3. **AudioSocket + custom glue** — Asterisk's minimal TCP PCM protocol works (third-party builds prove it), but there is no maintained Pipecat transport for it; we would write and own the bridge. Skip unless 1 and 2 both fail.

**What Pipecat must never own in our design:** call control. Asterisk + the `voice` plugin keep routing, the conference-merge (Route A), recording and per-minute billing; Pipecat owns only the conversation pipeline on the AI leg. That separation is what keeps the B10.2 gate meaningful: B10.2 proves Asterisk can merge a SIM call with a second leg; whether that leg is a Pipecat SIP registration or a WebSocket channel is a Phase 6 implementation choice *behind* the merge, not a change to it.

## Stack fit

- **Companion service on offbox-1**, same host as `sendqon-pbx` (2 OCPU / 12 GB Ampere A1, ARM64 Ubuntu): Pipecat is pure Python; its heavy optional deps (onnxruntime for VAD/local models) publish ARM64 wheels. One Python process per small fleet of concurrent calls is fine at our scale (launch fleet = 2 SIMs = max 2 concurrent Route A calls).
- **LLM**: OpenAI-compatible service → our AiGateway Gemini endpoint (already live for the KB/agent). **STT/TTS**: local services inside the same process (see sibling studies) with cloud fallbacks behind the same interfaces.
- **Sendqon integration surface**: the pipeline's tool calls go to the MCP tool registry (in-kernel, per the MCP design §Direction 2); session/audit/kill-switch live in Sendqon, not in Pipecat.

## Latency profile (engineering estimates, labelled)

The pipeline is streaming end-to-end; nothing in Pipecat itself forces store-and-forward. In *our* shape the budget is dominated by components, not the framework: 8 kHz phone audio upsampled to 16 kHz (negligible) → **segmented local STT** (VAD close ~0.2–0.5 s + faster-whisper segment transcription on CPU — the single biggest term, see the faster-whisper study) → Gemini round trip (~0.3–1 s) → TTS first audio chunk (Piper: ~50–200 ms class). **Realistic expectation: ~1.5–3 s user-stops-talking → first reply audio with local CPU STT; ~1 s class if a cloud streaming STT is used for the live leg.** Acceptable for an IVR/assistant leg; not a "natural conversation" claim, and the design never made one.

## Maintenance health

Excellent — the strongest in this corner. Latest release **`pipecat-ai` 1.17.0 on PyPI, 2026-11-22** (six days before this study); 127 releases since Dec 2023, a release every one-to-two weeks; backed by Daily (a company whose own product runs on it) plus a large community. The one real cost of that velocity: **API churn** — the 1.x line renames and deprecates as it goes (e.g. pipeline-task class renames, settings-object migrations). Mitigation is boring and sufficient: **pin the exact version** in the companion and upgrade deliberately, never floating.

## Risk

- Community `pipecat-asterisk` package is a single-maintainer-class dependency — small and forkable, but it is *the* critical joint in path 1; budget a fork-and-own fallback.
- `SIPTransport`/baresip is brand-new — do not bet the launch on it; let it mature or prove it in the Phase 6 battery.
- Python service beside a PHP stack — one more runtime to patch/monitor (accepted pattern already: our companions are a mixed fleet).
- If the pipeline process dies mid-call, the call must degrade, not drop: Asterisk-side fallback (recorded prompt + DTMF menu / bridge to human) is a Phase 6 acceptance item, not a Pipecat feature.

## Effort

~1–2 lanes to stand up the companion + Asterisk leg + AiGateway wiring for the Phase 6 proof (after B10.2 passes), reusing the sibling engines. Tenant productisation (per-tenant pipelines, voice selection UI) is later work, not counted here.

## Does it earn its place vs hand-rolled Asterisk dialplan + AiGateway wiring?

**Yes — and the comparison is not close.** Dialplan/ARI gives us call control, which we keep. What it does not give us is the conversation layer: VAD/turn-taking, barge-in, streaming frame plumbing across three model families, tool calling mid-call, and conversation state. Hand-building that layer is several lanes of the *hardest-to-test* code in the whole voice programme, and it is precisely Pipecat's entire job, BSD-licensed, with our two chosen local engines already integrated as services. The honest cost is one Python companion + version pinning + owning the Asterisk joint. That trade is clearly worth it.

## Verdict — **GO** (Phase 6 voice front-end orchestrator), with conditions

1. Companion service beside `sendqon-pbx`; Asterisk keeps call control, merge, recording, billing. Pipecat never becomes the PBX.
2. Asterisk leg: `chan_websocket` + `pipecat-asterisk` first (confirm PBX Asterisk version at build time); `SIPTransport` as the tracked second option once it has a few releases behind it.
3. Pin the exact `pipecat-ai` version; upgrades are deliberate mini-lanes.
4. LLM via AiGateway (same Gemini brain as the WhatsApp agent); tools via the MCP registry only — no side channels.
5. Degraded-mode fallback (recorded prompts + DTMF) is part of Phase 6 acceptance.

*Watchlist triggers: pipecat-asterisk going unmaintained AND chan_websocket breaking under a pinned upgrade (→ move to SIPTransport or own the fork); Pipecat changing licence (no signal of this; BSD + company backing makes it unlikely).*
