# Sendqon — Deep Study Corner

**Standing register of every deep study done for Sendqon** (owner order, 2026-11-28: *"Her project main ek deep study corner bana do jo complete study kary hamary projects k liye inko"*). One place where every evaluated project/repo lives: what it is, whether we studied it, what the verdict was, and where the full study is. Studies are **read-only research** — a GO verdict is a recommendation, never an install order; building/deploying always waits for the owner's word.

## Standard study format

Every study in this corner answers the same questions, in this order:

1. **Licence** — exact licence, read from the repo's own `LICENSE` file (not from badges or blog posts), with what it permits/blocks *for us* (commercial SaaS, tenant-facing use, modification).
2. **What it adds that we don't have** — the capability delta against the live Sendqon stack, stated concretely.
3. **Stack fit** — Sendqon = Zender/Laravel core (untouched) + our own plugins + companion services; host = offbox-1 (Oracle Phoenix, ARM64 Ubuntu, 2 OCPU / 12 GB); money figures in PKR at **Rs 277/USD** where conversion matters.
4. **Integration route** — one of: plugin / companion service / API link / replace-an-existing-piece / reference-only.
5. **Effort** — in lanes (our standard build unit), including the honest "what this does *not* include".
6. **Risk** — technical, licence, operational and product risks, with mitigations.
7. **Maintenance health** — stars/forks, last release, commit cadence — **live-checked at study date**, never from memory.
8. **Verdict** — GO / NO-GO / WATCHLIST, with conditions and the triggers that would reopen the question.

## Register

| # | Project / repo | Upstream | Status | Verdict | Date | Study |
|---|---|---|---|---|---|---|
| 1 | capcom6/android-sms-gateway | https://github.com/capcom6/android-sms-gateway | done | **GO** (Private mode, for the phone-as-API goal; not a Sendqon replacement) | 2026-11-28 | [SMS-GATEWAY-CAPCOM6-EVALUATION-2026-11-28.md](../SMS-GATEWAY-CAPCOM6-EVALUATION-2026-11-28.md) |
| 2 | Voice channel + rvoip (design study) | https://github.com/eisenzopf/rvoip | done | **Asterisk chosen** as the voice stack; **rvoip WATCHLIST** (revisit at 1.0 + B2BUA benchmarks) | 2026-11-28 | [SENDQON-VOICE-CHANNEL-DESIGN-2026-11-28.md](../SENDQON-VOICE-CHANNEL-DESIGN-2026-11-28.md) |
| 3 | Chatwoot | https://github.com/chatwoot/chatwoot | done | **GO** standalone Community (MIT); **enterprise licence NO-GO** | 2026-11-28 | [CHATWOOT-STUDY-2026-11-28.md](../CHATWOOT-STUDY-2026-11-28.md) |
| 4 | listmonk | https://github.com/knadh/listmonk | done | **GO** (a) Rektrs internal; **GO with conditions** (b) tenant offering (unmodified, instance-per-tenant only — AGPL §13) | 2026-11-28 | [LISTMONK-STUDY-2026-11-28.md](../LISTMONK-STUDY-2026-11-28.md) |
| 5 | Evolution API | https://github.com/evolution-foundation/evolution-api | done | **WATCHLIST** as a provider option; **NO-GO** as B8 replacement (2.4 activation/heartbeat regime; ban risk identical to B8) | 2026-11-28 | [EVOLUTION-API-STUDY-2026-11-28.md](../EVOLUTION-API-STUDY-2026-11-28.md) |
| 6 | Jasmin SMS Gateway | https://github.com/jookies/jasmin | done | **GO, conditional** — aggregator SMPP core from our own pinned fork; existing companion KEEP frozen | 2026-11-28 | [JASMIN-STUDY-2026-11-28.md](../JASMIN-STUDY-2026-11-28.md) |
| 7 | Automation + 2-Way MCP (own-product design study) | — (our own design) | done | **Design approved — build RUNNING** (Phases 1–7) | 2026-11-28 | [SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md](../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md) |
| 8 | **Pipecat** | https://github.com/pipecat-ai/pipecat | done | **GO** — Phase 6 voice-pipeline orchestrator (companion; Asterisk keeps call control) | 2026-11-28 | [PIPECAT-STUDY-2026-11-28.md](PIPECAT-STUDY-2026-11-28.md) |
| 9 | **faster-whisper** | https://github.com/SYSTRAN/faster-whisper | done | **GO** — local STT inside the Pipecat companion (small int8 live leg, medium int8 batch; Urdu assist-grade) | 2026-11-28 | [FASTER-WHISPER-STUDY-2026-11-28.md](FASTER-WHISPER-STUDY-2026-11-28.md) |
| 10 | **Piper** | https://github.com/OHF-Voice/piper1-gpl (orig. https://github.com/rhasspy/piper) | done | **GO, with conditions** — local TTS (isolated/unmodified, GPL hygiene); Urdu voices exist but provisional until listening A/B + per-voice licence check | 2026-11-28 | [PIPER-STUDY-2026-11-28.md](PIPER-STUDY-2026-11-28.md) |
| 11 | WAHA (WhatsApp HTTP API) | https://github.com/devlikeapro/waha | queued | — | — | — |
| 12 | Novu | https://github.com/novuhq/novu | queued | — | — | — |
| 13 | whatsapp-mcp | https://github.com/lharries/whatsapp-mcp | queued | — | — | — |
| 14 | Postal | https://github.com/postalserver/postal | queued | — | — | — |
| 15 | playSMS | https://github.com/playSMS/playSMS | queued | — | — | — |
| 16 | signal-cli | https://github.com/AsamK/signal-cli | queued | — | — | — |
| 17 | FreeSWITCH (vs Asterisk, Route B/C comparison) | https://github.com/signalwire/freeswitch | queued | — | — | — |

## Combined note — the voice trio is one decision (studies 8–10)

Pipecat, faster-whisper and Piper were studied together because they form a single pipeline, and each one's verdict assumes the other two. **Recommended Phase 6 voice pipeline shape:**

```
Caller ⇄ SIM / trunk leg ⇄ Asterisk (sendqon-pbx)
         — call control, conference-merge (Route A), recording, per-minute billing stay here —
              │  AI leg: chan_websocket via community pipecat-asterisk
              │  (tracked alternative: Pipecat's native SIPTransport registering to Asterisk)
              ▼
         Pipecat companion (offbox-1, pinned version)
              VAD/turn-taking → faster-whisper small int8 (VAD-segmented, live leg)
              → LLM via AiGateway (Gemini — the same brain as the WhatsApp agent/KB),
                tools via the MCP registry only
              → Piper (pre-rendered fixed prompts; dynamic strings live)
                · English/IVR: Piper local voices
                · Urdu dynamic: cloud TTS until the two ur_PK Piper voices pass the
                  native-speaker listening A/B (+ per-voice licence check)
         Post-call: faster-whisper medium int8 batch transcript
                    (Urdu labelled assist-grade — telephonic WER ≈46.6% stands)
```

Everything in this shape waits on the same single gate as the rest of the voice build: **B10.2** (conference-merge proof on Jazz + Zong with the owner's real phone). The trio studies change nothing about that gate — they decide what sits *behind* the merged leg when it opens.

## How this corner grows

New study ordered → row added as `queued` → study file written in the standard format → row updated to `done` with verdict + date → both repos pushed. Verdicts get revisited only on their named watchlist triggers or the owner's word.
