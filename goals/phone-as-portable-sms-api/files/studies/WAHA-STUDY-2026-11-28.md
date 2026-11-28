# Study — WAHA (devlikeapro/waha) as a Sendqon WhatsApp engine

**Date:** 2026-11-28 · **Studied for:** the owner's head-on comparison — WAHA vs Evolution API (study of 2026-11-28, `../EVOLUTION-API-STUDY-2026-11-28.md`) vs our own B8 Baileys bridge. Does WAHA change anything in Sendqon's WhatsApp picture?
**Sources:** GitHub repo + API (checked live 2026-11-28), repo `LICENSE` verbatim, WAHA's own docs site and blog (waha.devlike.pro, crawled 2026-11-28), DeepWiki's read of the WAHA docs repo (marked where used — some of its tier material is pre-2026.6 and is corrected below against WAHA's own announcement). READ-ONLY study — nothing was installed or deployed.

## What it is

A self-hosted REST API for WhatsApp, shipped as a single Docker image (`devlikeapro/waha`): create a **session** (one WhatsApp number), scan a QR (or use a pairing code), then send/receive over plain HTTP endpoints (`POST /api/sendText`, webhooks for inbound), with a built-in Swagger UI and a session Dashboard. Unlike Evolution, WAHA has **no official Cloud API mode** — every engine below is an unofficial linked-device connection. Repo stats at study time: **7,949 stars, 1,925 forks, 498 open issues**, created 2020-10-20, not archived; latest release **2026.10.1 (2026-10-28)**, commits the same day (GitHub, 2026-11-28).

### The four engines — two classes, and the class is what matters

| Engine | Underneath | Class | Resource cost / session (WAHA docs via DeepWiki) | Notes |
|---|---|---|---|---|
| **WEBJS** (default) | whatsapp-web.js in a real Chromium via Puppeteer | **Browser-class** | High — ~300–500 MB RAM, high CPU | Widest feature set, most battle-tested; screenshots only possible here |
| **WPP** | WPPConnect in Chromium via Puppeteer | **Browser-class** | High (same Chromium class) | Alternative browser engine; pick per-feature quirks |
| **NOWEB** | **Baileys** over direct WebSocket (Node) | **Baileys-class** | Low — ~50–100 MB | Literally the same library our B8 bridge runs |
| **GOWS** | whatsmeow over direct WebSocket (Go) | **Baileys-class** (protocol reimplementation, Go) | Very low — ~30–50 MB | Newest engine; WAHA positions it as NOWEB's successor; positioned for 50–100+ sessions/server |

Session data is **not portable between engines** (docs) — an engine choice per number is sticky without a re-pair. Payload shapes also differ between engines (WAHA's own docs warn API/webhook payloads vary by engine), so an integration is written against one engine, not "WAHA" in the abstract.

## 1. Licence

The repo `LICENSE` file is the **stock Apache License 2.0 text with no additional conditions** (read verbatim, 2026-11-28). This is the cleanest licence in our WhatsApp-engine comparison: no usage-notification clause, no logo-preservation clause, no trademark policy file, **no licence activation, no heartbeat, no telemetry requirement** in anything we could find in the repo or docs. Commercial SaaS use, modification and white-labelling are all permitted under ordinary Apache-2.0 duties (keep licence/notices, state changes). Contrast Evolution: Apache-2.0 *plus* two extra conditions *plus* (2.4 line) mandatory activation with operator email/phone and 30-minute usage heartbeats. On licence surface alone, WAHA is strictly simpler than Evolution.

**The tier story — the brief's premise is out of date, and the correction matters.** WAHA historically shipped three tiers: **Core** (free image: **1 session**, text/location/contact sends only, local-file storage), **Plus** (~$19/mo supporter subscription for a private-registry image: unlimited sessions, media sends, PostgreSQL/MongoDB/S3 session storage, API-key/Swagger security, metrics) and **PRO** (~$99/mo: same Plus image + source-code access + up to 5 team seats on the patron account). **That split no longer exists.** WAHA's own announcement (blog, 2026-06-21, for version **2026.6.1**) states every Plus feature — unlimited sessions, media, all storage backends, security, observability — now ships in the free public `devlikeapro/waha` image; the Core/Plus/PRO patron tiers were dropped and replaced by a single voluntary **Community tier at $5/mo that grants no features at all** ("We can not offer something extra in return"). The repo README says the same ("WAHA Plus is now part of the main image"). Third-party comparisons still quoting $19/$99 are quoting a dead pricing page. So: **today there is nothing paywalled** — but note the reason given in the announcement itself ("we haven't shipped anything significant in the last few months… share the work the community already paid for"), which is a funding-model fact to weigh in §7, not a pricing fact.

## 2. What it adds that we don't have

Against the live Sendqon stack (vendor server with the owner's number; our B8 bridge, server id 5; WABA as a channel concept):

- **Multi-engine choice under one API** — the one genuinely new idea. B8 is Baileys-only; Evolution offers Baileys + Cloud API. WAHA offers *browser-class* engines (WEBJS/WPP) that neither B8 nor Evolution has: a real WhatsApp Web client in Chromium, driven by automation.
- **Fleet density on the light engines** — GOWS at ~30–50 MB/session is the cheapest per-number footprint in this comparison class (Evolution publishes no figure; third-party planning says tens of sessions per modest server; B8 is one Node process per bridge by design).
- **A ready operator Dashboard + Swagger** for session management — B8 has no equivalent UI of its own (it rides Sendqon's panel by design).
- **WhatsApp Channels/Status endpoints and group administration** comparable to Evolution's surface.

What it does **not** add: an official Cloud API path (Evolution has one; WAHA has none — every WAHA number is an unofficial connection), Chatwoot/Typebot-class native integrations (Evolution's catalogue is wider; WAHA's automation story is webhooks + an n8n community node), and any anti-ban/pacing layer (none exists — engine choice is the only lever).

## 3. Stack fit

WAHA is one Docker container (Node; Chromium inside for the browser engines) — it would sit on offbox-1 as a companion in exactly the B8/Evolution slot, behind Sendqon's service-server contract via an adapter we would write (WAHA speaks plain REST + webhooks, so the adapter is simpler than B8's Reverb command bus, but WAHA knows nothing of Sendqon's bootstrap/session-token contract — that glue is ours). On offbox-1's 2 OCPU / 12 GB: WEBJS at ~300–500 MB per session caps a WAHA box at roughly 10–20 browser sessions before RAM is the binding constraint; NOWEB/GOWS sessions are cheap enough that CPU and WhatsApp-side behaviour bind first. Session persistence: local files by default, or PostgreSQL/MongoDB/S3 backends (all formerly Plus, now free) — the volume/backend must persist or every restart drops pairings, the same ops rule as B8's data directory.

## 4. Integration route

**Companion service** (if ever adopted) — same slot and pattern as B8: WAHA container + a Sendqon-side adapter mapping Sendqon's server-row/account model onto WAHA sessions, one pinned engine (NOWEB for parity with B8's risk/feature profile, or GOWS for density). Never a plugin; never tenant-exposed directly (WAHA's own auth is a single API key + dashboard — the global-key-must-never-leave-the-backend rule from the Evolution study applies identically).

## 5. Effort

- Adapter + companion packaging + dev battery to the awaiting-scan state (the B8 battery shape): **~2–3 lanes**. A real pairing/send/receive proof needs the owner's QR scan — the same physical step that gates B8 today.
- Engine evaluation done properly (NOWEB vs GOWS vs WEBJS against our send/receive/media/group checklist) is inside those lanes only for one engine; each additional engine is its own smaller lane because payloads differ.
- Not included: any migration of the owner's live number (a separate owner decision, identical in kind to the B8 cutover options), and any fleet-scale load proof.

## 6. Risk

- **Ban risk — stated with the same honesty as the Evolution study.** All four engines are unofficial; Meta's Terms prohibit this class of use and a ban is permanent loss of the number. The *category* does not change with the wrapper. Within the category there is a real gradient worth naming precisely: **NOWEB is Baileys — identical protocol risk to B8, byte for byte the same library.** GOWS (whatsmeow) is a different implementation of the same linked-device protocol — same category, different fingerprint, no published evidence it is safer or riskier. The browser engines run the genuine WhatsApp Web client, which removes the "reimplemented protocol" detection surface but adds browser-automation signals, and whatsapp-web.js/WPPConnect carry their own long history of breakage-and-ban reports; WAHA publishes **no explicit ban warning** in its docs (same silence the Evolution study noted). Net: WAHA offers a *choice* of risk fingerprints, not a reduction of risk. Behaviour (volume, cold outreach, new-number ramps) remains the dominant factor — which is what our `wa_guard` plugin already manages, engine-independently.
- **Funding/maintenance model risk:** the 2026.6 change means the project's income is now voluntary $5/mo support with no feature leverage. The maintainer states development continues; the announcement's own reasoning (a quiet few months, sharing already-paid work) is honest but is also what a project winding toward maintenance mode looks like. This cuts both ways and is recorded as an open fact, not a prediction.
- **Single-maintainer gravity:** the repo is effectively one person's project (devlikeapro) — bus-factor 1, same as many tools we run, but worth naming next to Evolution's foundation/ecosystem.
- **Engine fragmentation:** four engines × differing payloads and feature matrices means "supports WAHA" is always "supports WAHA-on-engine-X"; upstream bugs often reproduce on one engine only.
- **Security defaults:** API key auth exists and is now free-tier; the Dashboard/Swagger must never be publicly exposed (they are session-control surfaces). WAHA stores full session credentials on disk — the companion volume becomes a high-value target, as B8's data dir already is.

## 7. Maintenance health (live-checked 2026-11-28)

- **7,949 stars, 1,925 forks, 498 open issues**; created 2020 — six years of continuous project history.
- **Release cadence is the healthiest in this comparison:** calendar versioning with roughly monthly releases; latest **2026.10.1 on 2026-10-28**, code commits the same day, repo pushed 2026-11-26. No 353-day stable gaps of the Evolution 2.3-line kind.
- The GOWS engine is under active development (a connection-failure-events fix landed in the latest release commits) — the project's energy is visibly going into the light engines.
- 498 open issues is a large queue in absolute terms; the top of it is the expected Baileys/browser-engine long tail. We did not audit issue quality beyond counts — flagged as unchecked depth.

## 8. Verdict — **WATCHLIST** (do not adopt now; B8 is not replaced; named triggers below)

WAHA is a better-engineered *offer* than Evolution on two axes — a genuinely clean Apache-2.0 with no activation/phone-home, and a healthier release cadence — and it brings one capability neither B8 nor Evolution has (browser-class engines). But it does not change Sendqon's WhatsApp picture today, for the same structural reasons the Evolution study recorded, plus one more:

1. **The Baileys slot is occupied.** NOWEB *is* Baileys. Adopting WAHA-on-NOWEB swaps our own maintained bridge for the same library inside someone else's wrapper, and WAHA-on-GOWS/WEBJS changes the fingerprint without changing the risk category. There is no current tenant capability gap WAHA closes.
2. **No Cloud API mode.** The one engine upgrade that would change the risk category — Meta's official channel — is the one WAHA doesn't have and Evolution does. If the fleet question ever becomes "official + unofficial under one API", Evolution, not WAHA, is the candidate.
3. **The blocker is unchanged.** Every WAHA path still begins with the owner's QR scan — the same step B8 waits on. WAHA removes no step that is actually blocking us.
4. **Sendqon's own contract work is already done for B8** (bootstrap, session tokens, health, `wa_guard`). WAHA would need a fresh adapter before it carried a single tenant number.

**Revisit triggers (any one reopens this study):**
1. **Fleet density becomes real** — a tenant (or we) need dozens of numbers on one box; GOWS at ~30–50 MB/session is then the cheapest credible engine and WAHA becomes the front-runner for a *second* bridge line alongside B8.
2. **Baileys-the-library falters** (protocol breakage our bridge can't absorb, or the library stalls) while WAHA's GOWS/whatsmeow line stays current — engine diversity becomes insurance, not sprawl.
3. **A browser-class feature is demanded by name** (e.g. a capability only the real Web client exposes) that neither B8 nor the vendor server can serve.
4. **WAHA's funding model collapses visibly** (releases stop for 2+ quarters) — trigger in the *negative* direction: it would close this watchlist entry, not open adoption.

**One-line verdict: WAHA is the cleanest-licensed, healthiest-cadence unofficial WhatsApp engine we've studied — and it still doesn't displace B8, because its Baileys engine is B8's own library, its non-Baileys engines change the fingerprint rather than the risk, and it has no official Cloud API mode at all.**
