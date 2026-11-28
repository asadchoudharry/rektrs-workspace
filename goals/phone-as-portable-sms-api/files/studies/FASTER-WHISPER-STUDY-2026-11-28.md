# Study — faster-whisper (SYSTRAN/faster-whisper) as Sendqon's local STT engine

**Date:** 2026-11-28 · **Studied for:** the speech-to-text leg of the Phase 6 voice front-end (Automation + 2-Way MCP programme), inside the [Pipecat](PIPECAT-STUDY-2026-11-28.md) companion, on offbox-1. Sibling: [PIPER-STUDY-2026-11-28.md](PIPER-STUDY-2026-11-28.md) (TTS). Urdu evidence baseline: our own B10 research (`../SENDQON-PHONE-BRIDGE-RESEARCH-2026-11-19.md` §6).
**Sources:** GitHub repo + README benchmarks (checked live 2026-11-28), repo `LICENSE`, PyPI. READ-ONLY study — nothing installed; every performance figure below is either the project's published benchmark or an engineering estimate explicitly labelled as such.

## What it is

faster-whisper is a reimplementation of OpenAI's Whisper speech-recognition models on **CTranslate2**, a fast Transformer inference engine. Same models, same accuracy class as the reference implementation, up to **4× faster with less memory**, with 8-bit (int8) quantization on CPU and GPU. It is a transcription *engine/library*, not a server and not a streaming system. Repo stats: **27,086 stars, 2,312 forks, 21 releases, created 2023-02-11** (GitHub, 2026-11-28).

## Licence

**MIT** — verified from the repo `LICENSE` (Copyright (c) 2023 SYSTRAN). The Whisper model weights it downloads are OpenAI's, also MIT. No copyleft, no usage conditions. Clean for commercial/SaaS use in any position, including inside a tenant-facing pipeline.

## What it adds that we don't have

A **local, zero-per-minute STT engine** that runs entirely on our own host: no API key, no per-minute bill, no audio leaving the box. Today Sendqon has no STT at all; the B10 design assumed API STT first for Urdu and local Whisper only as a batch afterthought. This study prices the local option properly (below) and finds it earns *two* jobs — neither of them "verbatim Urdu".

## CPU reality on offbox-1 (2 OCPU / 12 GB, Ampere A1, no GPU)

Published anchor (project README, "Small model on CPU", transcribing 13 minutes of audio on an 8-thread Intel i7-12700K): fp32 2m37s → **RTF 0.20**; **int8 1m42s → RTF 0.13**; int8 batched 51s → RTF 0.065. (RTF < 1 = faster than real time.)

offbox-1 has 2 Ampere cores — roughly a quarter to a third of that benchmark's aggregate throughput. Scaling the anchor (engineering estimate, to be replaced by a Phase 6 on-box measurement before any tenant promise):

| Model (int8, CPU) | Est. RTF on offbox-1 | Fit |
|---|---|---|
| tiny / base | ~0.1–0.3 | Live-leg capable, but Urdu quality drops sharply at this size — English/short-command use only |
| **small** | **~0.4–0.8** | **The live-leg candidate**: near-real-time on VAD segments for one call at a time |
| medium | ~1.5–3 | Not real-time — post-call batch transcripts |
| large-v3 | ~3–6 (≈3 GB RAM int8) | Batch only, and competes for the shared 12 GB — not the default |

CTranslate2 supports aarch64 (NEON kernels; ARM is a first-class target for the engine), so the engine runs natively on the A1 — no emulation caveat. Concurrency honesty: with 2 cores, **one** live call transcribing leaves little headroom; two simultaneous Route A calls (our launch fleet maximum) would queue segments. Acceptable at launch scale; a GPU or a bigger shape is the growth answer, not a different engine.

## Urdu accuracy — B10's numbers confirmed, and refined by model size

B10's peer-reviewed figures stand as the ceiling for the Whisper family: **Urdu broadcast WER ≈ 27.97%, telephonic ≈ 46.64%** (large-v3 class, GPU). This study adds the size gradient the B10 note implied but did not state:

- Those numbers are the **large** model's. Whisper's published per-language results degrade steeply down the size ladder for low-resource languages; **small/base on Urdu will be materially worse than 46.6% telephonic** — expect intent-spotting and keyword-grade output, not transcripts.
- The fine-tuned results in B10 (large-v3-Turbo 25.33% on YouTube Urdu, 21.75% after LoRA) are a *GPU fine-tune path* — a possible future lane, not something this CPU box changes.
- The **script trap** (from B10) applies locally too: spoken Urdu can come back in Devanagari script. Mitigation is configuration, not hope: pin `language="ur"` and script-check output before it reaches the LLM/log.

**Conclusion:** local faster-whisper Urdu = **assist-grade** (call-log transcripts labelled as such, intent/keyword extraction for the bridge, English and mixed short commands on the live leg). Verbatim Urdu remains an API-STT question — that is exactly the B10.5 A/B decision (AssemblyAI vs Deepgram-class providers on our own recorded Urdu calls), unchanged by this study.

## Streaming vs batch fit for a live call leg

faster-whisper is **not a streaming engine**: it transcribes audio segments. In a call, the working pattern is **VAD-segmented near-live** — Silero VAD closes a speech segment, the segment is transcribed whole, the text enters the conversation. This is precisely how Pipecat integrates it (`WhisperSTTService` is a `SegmentedSTTService` — verified in Pipecat's source/docs), so adopting Pipecat gives us this integration for free, including the segment plumbing. Cost of the pattern: turn latency includes VAD close time (~0.2–0.5 s) plus segment transcription (~0.4–0.8× segment length at small/int8) — already reflected in the Pipecat study's ~1.5–3 s reply-latency expectation. True-streaming wrappers (WhisperLive, Whisper-Streaming) exist as community projects; they add a second moving dependency to shave latency we do not yet need to shave. **Not recommended for v1.**

## Integration shape

- **Primary: inside the Pipecat companion** via `WhisperSTTService` — zero extra services, model loaded in-process. Default live-leg model: **small int8**; batch job (post-call transcript) runs **medium int8** in the same companion off the call path.
- Alternative if other consumers ever need STT directly: `speaches` (an OpenAI-compatible server wrapping faster-whisper) as its own companion. Not needed for Phase 6; noted so the option is on record.
- Model files download from Hugging Face on first use (~0.5 GB small, ~1.5 GB medium int8 class) — a build-time fetch in the companion image, not a runtime surprise.

## Maintenance health

Strong and boring, in the good way: SYSTRAN-backed, MIT, latest release **1.2.1 (PyPI 2025-10-31)**; commit cadence is slow (279 commits total) because the engine is *finished* more than it is *growing* — the underlying CTranslate2 carries the active development. 27k stars and a wide ecosystem (WhisperX, speaches, WhisperLive all build on it) mean the "what if it stalls" answer is: the artefact keeps working and forks exist. Low maintenance risk.

## Risk

- Urdu over-promising is the only real risk, and it is a *product-copy* risk, not an engineering one: every surface that shows a local Urdu transcript must carry the assist-grade label (the voice design already requires this honesty pattern).
- CPU contention with the rest of offbox-1 (Sendqon itself, PBX) during a live transcription — mitigate with process priority/cgroup limits on the companion at build time.
- Model-download supply chain (HF) — pin model revisions in the companion build.

## Effort

≈0 extra lanes standalone: it lands *inside* the Pipecat companion lane (model choice + language pinning + script check). A standalone batch-transcript lane (recordings → medium int8 → call log) is ~1 lane if ordered separately.

## Verdict — **GO**

Adopt as the local STT engine inside the Pipecat companion: **small int8, VAD-segmented, for the live leg; medium int8 for post-call batch transcripts.** Conditions: (1) on-box RTF measurement in the Phase 6 battery replaces this study's estimates before any capacity claim is made to a tenant; (2) Urdu output is assist-grade everywhere it appears, `language="ur"` pinned + script-checked; (3) the B10.5 API-STT A/B for verbatim Urdu proceeds independently — this adoption does not close that question.

*Watchlist triggers: a streaming-native open STT with materially better Urdu at CPU cost (revisit the live leg); offbox shape change to a GPU instance (revisit model sizes upward).*
