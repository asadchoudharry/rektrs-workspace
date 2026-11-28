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
| 11 | WAHA (WhatsApp HTTP API) | https://github.com/devlikeapro/waha | done | **WATCHLIST** — cleanest licence (stock Apache-2.0, no activation) + healthiest cadence of the WhatsApp engines, but NOWEB *is* Baileys (B8's own library), other engines change fingerprint not risk, and there is no Cloud API mode; triggers: fleet density (GOWS), Baileys faltering, a browser-class feature demanded | 2026-11-28 | [WAHA-STUDY-2026-11-28.md](WAHA-STUDY-2026-11-28.md) |
| 12 | Novu | https://github.com/novuhq/novu | done | **REFERENCE-ONLY** (ideas adopted: digest node, per-automation preference model, `critical` semantics — flagged as Phase 4 spec candidates); as a companion **NO-GO** (it abstracts third-party providers; Sendqon owns its channels) | 2026-11-28 | [NOVU-STUDY-2026-11-28.md](NOVU-STUDY-2026-11-28.md) |
| 13 | whatsapp-mcp | https://github.com/lharries/whatsapp-mcp | done | **REFERENCE-ONLY** — read-tool shapes (search / context-window / last-interaction) adopted into the MCP census as tenant-scoped READ tools; the software itself **NO-GO** in any Sendqon context (personal-account mirror, no tenancy/audit, lethal-trifecta exposure) | 2026-11-28 | [WHATSAPP-MCP-STUDY-2026-11-28.md](WHATSAPP-MCP-STUDY-2026-11-28.md) |
| 14 | Postal | https://github.com/postalserver/postal | done | **WATCHLIST** — complete MIT MTA, but needs a dedicated host + reputation build and we have no delivery pain today (Hostinger + Resend cover it); triggers: listmonk tenant offering shipping, sustained volume, a self-hosted-delivery contract, email channel graduating to provided sending | 2026-11-28 | [POSTAL-STUDY-2026-11-28.md](POSTAL-STUDY-2026-11-28.md) |
| 15 | playSMS | https://github.com/playSMS/playSMS | done | **REFERENCE-ONLY (idea mining)** — GPL-3.0: code never enters our tree, by rule; mined: charge-only-on-sent/delivered rule, prefix-first rating, simulation gateway, partner-as-server-row (Uplink); software itself **NO-GO permanently** | 2026-11-28 | [PLAYSMS-STUDY-2026-11-28.md](PLAYSMS-STUDY-2026-11-28.md) |
| 16 | signal-cli | https://github.com/AsamK/signal-cli | done | **NO-GO** as a Sendqon channel — zero demand on record, register mode displaces the tenant's own Signal app, no legitimate automation path exists on Signal, 3-month forced-upgrade fuse + ARM64 native-lib exception; watchlist carve-out: Rektrs-internal admin alerts only | 2026-11-28 | [SIGNAL-CLI-STUDY-2026-11-28.md](SIGNAL-CLI-STUDY-2026-11-28.md) |
| 17 | FreeSWITCH (vs Asterisk, Route B/C comparison) | https://github.com/signalwire/freeswitch | done | **NO-GO — Asterisk stands**; re-opens only on: measured per-node concurrency ceiling, a WebRTC-first (Verto) contract, a FreeSWITCH-native partner/hire, or an unpatchable Asterisk wall | 2026-11-28 | [FREESWITCH-STUDY-2026-11-28.md](FREESWITCH-STUDY-2026-11-28.md) |
| 18 | Fonoster | https://github.com/fonoster/fonoster | done | **WATCHLIST** — MIT confirmed, best open reference for a verb-level voice-app API (session protocol mined as design reference), but it terminates on its OWN stack (Routr/RTPEngine/Roomr — "No Asterisk"), so the only meeting shape inverts our decided architecture and strands B10.2; its Pipecat (`twilio`) stream strips call control and its full-control stream strips our local speech stack; pre-1.0 (v0.66.0), mid-rebuild, single-maintainer, self-declared instability | 2026-11-28 | [FONOSTER-STUDY-2026-11-28.md](FONOSTER-STUDY-2026-11-28.md) |
| 19 | Dittofeed | https://github.com/dittofeed/dittofeed | done | **REFERENCE-ONLY** — MIT core verified, but multi-tenancy/embedding/white-label are the vendor's closed-source licensed code (README's own footnote), so tenant-facing use is NO-GO by construction and internal use is unnecessary (Sendqon + listmonk cover it); mined as flagged Phase 4 candidates: one segment object as entry gate + branch condition + audience, a Wait For node (waits on the world, not the clock), performed/random-bucket segment vocabulary, journey pause semantics; cadence slowed (last commit 2026-10-12) | 2026-11-28 | [DITTOFEED-STUDY-2026-11-28.md](DITTOFEED-STUDY-2026-11-28.md) |
| 20 | Typebot | https://github.com/baptisteArno/typebot.io | done | **REFERENCE-ONLY** — licence verified verbatim as **FSL-1.1** (not OSI; README's AGPL badge is stale): tenant-facing builder/bot runtime in Sendqon is a Competing Use by the licence's own definition = **NO-GO by construction**; Rektrs internal use is a Permitted Purpose but unneeded (ai_agents covers it); the ≥2-year Apache conversion offers only a permanently stale escape hatch. Mined: four-family block taxonomy, variable surfacing discipline, and the best documented WhatsApp degradation matrix (3-button paging, numbered-list fallback, 20-char buttons, silent block skips) — which validates our channel-native Flows | 2026-11-28 | [TYPEBOT-STUDY-2026-11-28.md](TYPEBOT-STUDY-2026-11-28.md) |
| 21 | Mautic | https://github.com/mautic/mautic | done | **Three verdicts:** (a) as design reference for `automations` **GO (reference-only)** — deepest campaign model studied: Decision (async wait-for-behaviour) vs Condition (sync test) node taxonomy, the full **lead-scoring subsystem** (point rules, adjust-points action, threshold-crossing triggers, negative rules as decay, point groups), segment join/leave events, restart-policy flag — flagged as Phase 4 candidates A1–A4; (b) **Sendqon as a Mautic SMS transport — GO, small/conditional** (documented `TransportInterface` plugin point, Twilio is the built-in reference; ~1 lane GPL connector, reply-callback makes SMS replies a campaign Decision; funnel speculative — build when a lane is spare or the first Mautic user appears); (c) for Rektrs' own marketing **NO-GO** (listmonk holds that GO; journeys/scoring are what our own Phase 4 is being built to do). GPL-3.0 → design mining + API integration only, no code in our tree | 2026-11-28 | [MAUTIC-STUDY-2026-11-28.md](MAUTIC-STUDY-2026-11-28.md) |
| 22 | RapidPro | https://github.com/rapidpro/rapidpro | done | **REFERENCE-ONLY (design mining), permanently** — AGPL-3.0, UNICEF + Nyaruka, in production since 2014. Teachings flagged for Phase 4/6 specs: **T1** flow definitions as versioned documents (numbered spec, immutable revisions with diffs, forward migrations); **T2** router/wait outcomes as named, queryable results; **T3** UUID-keyed localization, contact-first language resolution (Urdu/English shape); **T4** per-type session expiry defaults (messaging 3 days, voice 5 min) with explicit expired state; **T5** per-contact date-field trigger class; **T6** save-time dependency inspection; plus the IVR refinement — structured IVR is a **per-turn callback shape** (Mailroom answers each provider callback with the next prompt), not a streaming problem, which simplifies Phase 6 alongside the Pipecat leg | 2026-11-28 | [RAPIDPRO-STUDY-2026-11-28.md](RAPIDPRO-STUDY-2026-11-28.md) |
| 23 | mautrix bridge family (architecture study) | https://github.com/mautrix/whatsapp | done | **NO-GO as Sendqon's channel architecture; WATCHLIST for one piece** — the unified-Matrix-bus model (proven at consumer scale by Beeper, Automattic $125M, Apr 2024) would replace Sendqon's centre (contacts/campaigns/MCP/audit in our own model), concentrate every network's **plaintext history in one store** (a bridge terminates the remote network's E2E — a tenant could never honestly claim end-to-end encryption), and make a homeserver a single point of failure for all channels; its real wins (cheap marginal networks, history backfill) solve pains we don't have. Watchlist item: a **Matrix channel companion** (Sendqon speaks Matrix as channel #N, no mautrix code) on a named tenant requirement. Re-open conditions: a signed requirement for ≥3 networks we lack as one inbox; a unified-inbox product pivot (Chatwoot Route 1 evaluated first); or our per-channel pattern demonstrably failing to scale. AGPL-3.0 mechanics spelled out (unmodified running permitted; patching a bridge + tenant interaction triggers §13 source offers) | 2026-11-28 | [MAUTRIX-STUDY-2026-11-28.md](MAUTRIX-STUDY-2026-11-28.md) |
| 24 | LiveKit (vs Pipecat — Phase 6 head-to-head) | https://github.com/livekit/livekit | queued | — | — | — |
| 25 | Glific | https://github.com/glific/glific | queued | — | — | — |

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
