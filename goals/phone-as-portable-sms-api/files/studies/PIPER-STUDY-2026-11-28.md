# Study — Piper (rhasspy/piper → OHF-Voice/piper1-gpl) as Sendqon's local TTS engine

**Date:** 2026-11-28 · **Studied for:** the text-to-speech leg of the Phase 6 voice front-end (Automation + 2-Way MCP programme), inside the [Pipecat](PIPECAT-STUDY-2026-11-28.md) companion, on offbox-1. Sibling: [FASTER-WHISPER-STUDY-2026-11-28.md](FASTER-WHISPER-STUDY-2026-11-28.md) (STT). TTS landscape baseline: our B10 research (`../SENDQON-PHONE-BRIDGE-RESEARCH-2026-11-19.md` §6).
**Sources:** both GitHub repos (checked live 2026-11-28), the official voice catalogue `voices.json` from the `rhasspy/piper-voices` Hugging Face repo (fetched and parsed live for this study), PyPI (`piper-tts`). READ-ONLY study — nothing installed, no audio generated; quality statements about specific voices are labelled as unverified where no published evaluation exists.

## What it is

Piper is a **fast, local neural text-to-speech system**: VITS-family ONNX models (one file per voice, ~60 MB at medium quality) plus espeak-ng phonemization, designed from the start to run in real time on Raspberry Pi-class ARM hardware. It is the TTS engine inside Home Assistant's voice stack, which is why its maintenance story has two chapters (below).

## The two repos, and the licence split that matters

| | `rhasspy/piper` (original) | `OHF-Voice/piper1-gpl` (successor) |
|---|---|---|
| Status | **Archived** — README: "Development has moved" | Active home of development |
| Licence | **MIT** (verified from repo) | **GPL-3.0** (verified from repo; the move to OHF deliberately "Change[d] license to GPLv3") |
| Stars / forks | 11,335 / 1,120 | 6,438 / 651 |
| Created | 2023-01-10 | 2025-03-28 |
| Latest | frozen (5 releases) | `piper-tts` **1.8.0 on PyPI, 2026-09-04**; 9 releases |

Two consequences, stated plainly:

1. **GPL-3.0 hygiene.** GPL (unlike AGPL) has no network-use clause: running *unmodified* Piper as a separate companion process and selling access to the *service* triggers no source-offer duty. What we must not do is link Piper's code into our own distributed binaries or ship a modified Piper without honouring GPL source obligations. The integration shape below (isolated process boundary, unmodified package) keeps us clean by construction. The archived MIT original exists as a fallback artefact but is frozen — adopting a frozen engine when an active successor exists is not the recommendation; GPL hygiene is manageable, staleness is not.
2. **Maintenance flag, honestly recorded:** piper1-gpl's README carries a **"Looking for Maintainers"** notice — the Open Home Foundation is actively seeking maintainers for Piper. Development is continuing (releases through Sep 2026, active phonemizer work), but stewardship is thinner than Pipecat's or faster-whisper's. For an IVR-grade TTS component this risk is acceptable: TTS engines do not rot quickly, the voice files are static artefacts, and worst case the last release keeps running for years. It is still a named watchlist item, not a footnote.

## The Urdu question — the assumed gap is wrong; the real gap is proof

The brief for this study assumed Urdu was Piper's known gap. **Checked live against the official catalogue, that assumption is false.** The catalogue (`voices.json`, parsed 2026-11-28: **188 voices, 62 languages**) contains two Urdu voices:

| Voice | Speaker | Quality tier | Model size |
|---|---|---|---|
| `ur_PK-aegis_female-medium` | female, single speaker | medium | 63.5 MB |
| `ur_PK-fasih-medium` | male, single speaker | medium | 64.8 MB |

So Urdu exists locally, at zero per-character cost — something none of B10's cloud options (Azure ur-PK Uzma/Asad Neural at $15/1M chars, Google ur-PK Standard at $4/1M) can match on price, and with no audio leaving the box.

**The real gap is proof, not existence:** both voices are community contributions with **no published intelligibility or quality evaluation** anywhere we could find, single-speaker, medium tier only (no high-quality tier exists for Urdu). Piper's medium tier generally = clearly intelligible, noticeably synthetic. Whether *these* voices pronounce Pakistani Urdu well enough for a customer-facing IVR is an empirical question only a listening test on our own prompts can answer. Therefore:

- Phase 6 battery includes an **Urdu listening A/B**: the two local voices vs Azure ur-PK on the same fixed prompt set (greeting, OTP readback, order-status sentence), judged by a native speaker (the owner) before any tenant hears a local Urdu voice.
- Until that A/B passes, the routing stays as the voice design already specifies: **recorded human prompts for fixed Urdu strings** (best quality, zero risk), **cloud TTS for dynamic Urdu**, Piper for English/IVR and — if the A/B passes — dynamic Urdu too.
- **Voice-model licensing caveat:** each Piper voice carries its own licence terms (the project maintains a dedicated voice-licensing page for this reason). Before either Urdu voice is used tenant-facing, its individual licence must be checked and recorded — catalogue presence is not a commercial-use grant.

## Performance on offbox-1 (ARM64, CPU-only)

Piper's design point is a Raspberry Pi: medium voices synthesize **faster than real time on a single Pi-class ARM core** (commonly reported RTF ≈ 0.1–0.3). On offbox-1's Ampere cores the expectation is the same class: an IVR-length sentence in roughly **50–200 ms**, worst case a few hundred ms — comfortably inside the voice pipeline's latency budget (see the Pipecat study), and cheap enough that **pre-rendering every fixed prompt at deploy time** costs nothing and removes runtime TTS from the critical path for menus/greetings entirely. Labelled as expectation from the engine's published Pi-class behaviour; the Phase 6 battery measures it on-box. RAM is trivial (~65 MB model + runtime). The `piper-tts` wheel is published for Linux ARM64 (single stable-ABI wheel per platform), and Pipecat consumes it in-process via `PiperTTSService` (plus an HTTP variant, `PiperHttpTTSService`, if a separate Wyoming-style server is ever wanted).

## Quality class

Medium tier = intelligible, somewhat robotic — the right grade for IVR prompts, OTP/number readback, and status announcements. It is **not** a brand-voice or marketing grade, and no tenant should be sold "natural AI voice" on Piper. English catalogue depth is genuinely good (many en_US/en_GB speakers and tiers) for tenants whose IVR is English-first. Numbers/dates/currency readback quality depends on text normalization in *our* layer (Piper exposes speed/variability controls — Pipecat's service already surfaces `length_scale`/`noise_scale`) — a Phase 6 prompt-engineering detail, noted here so it isn't discovered live.

## Integration shape

- **Inside the Pipecat companion**, in-process via `PiperTTSService`, unmodified `piper-tts` package — process boundary = the companion itself; nothing of Piper's is linked into Sendqon code.
- **Pre-render fixed prompts at build/deploy** (per language/voice), synthesize only dynamic strings at runtime.
- **Router rule** (in our voice layer, not Piper): fixed string → recording/pre-render; dynamic English → Piper; dynamic Urdu → cloud TTS until the local voices pass the A/B, then Piper with cloud fallback on failure.

## Maintenance health

Mixed — the weakest of the trio, and the verdict prices that in: active successor repo (6,438★, releases to Sep 2026) **but** an explicit maintainer search, and a licence that changed from MIT to GPL-3.0 in the move (any future re-licensing is out of our control). Counterweights: Home Assistant's installed base keeps the artefact relevant; voices are static files; the component is small and replaceable behind Pipecat's TTS interface (Kokoro, cloud TTS, or a future engine slot in without touching the pipeline).

## Risk

- Urdu voice quality unproven (mitigation: the A/B gate above; fallback already designed).
- Per-voice licence terms unchecked for the two Urdu voices (mitigation: check + record before tenant use; internal testing is unaffected).
- GPL scope creep if a future developer links instead of isolates (mitigation: the isolation rule is written here and belongs in the companion's build notes).
- Maintainer thinning at OHF (watchlist, below).

## Effort

≈0 extra lanes standalone: lands inside the Pipecat companion lane (voice files + prompt pre-render + router rule). The Urdu A/B is a listening session inside the Phase 6 battery, not a lane.

## Verdict — **GO, with conditions**

Adopt Piper (piper1-gpl line) as the local TTS engine inside the Pipecat companion. Conditions: (1) **isolated, unmodified** — GPL hygiene by architecture; (2) **Urdu is provisional** — the two ur_PK voices exist (this study corrects the assumed gap) but ship to tenants only after passing the native-speaker listening A/B, with per-voice licence checks recorded; cloud Urdu TTS + recorded prompts remain the default until then; (3) fixed prompts pre-rendered; Piper's job at runtime is dynamic strings.

*Watchlist triggers: OHF stewardship visibly stalling (no release for 12+ months) → evaluate Kokoro/cloud-first TTS behind the same Pipecat interface; a high-quality-tier Urdu voice appearing in the catalogue → re-run the A/B.*
