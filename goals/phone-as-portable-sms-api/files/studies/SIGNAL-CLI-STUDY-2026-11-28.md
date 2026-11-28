# Study — signal-cli (AsamK/signal-cli) as a Sendqon Signal channel

**Date:** 2026-11-28 · **Studied for:** whether a Signal channel belongs anywhere in Sendqon's roadmap, using signal-cli (the only credible open-source Signal client) as the candidate engine.
**Sources:** GitHub repo page + README (read live 2026-11-28; the account-model and upkeep quotes below are the project's own words), repo `LICENSE` verbatim. The REST wrapper ecosystem is described from the project's known landscape without live-verified statistics — flagged where that matters. READ-ONLY study — nothing was installed or deployed.

## What it is

An **unofficial** command-line/daemon client for the Signal messenger (Java, built on a patched libsignal-service-java extracted from Signal-Android): register or link an account, send and receive messages and attachments, manage groups — via CLI, a **daemon mode with JSON-RPC** (or D-Bus), and an HTTP/SSE surface in current builds. Its own README states the intended use plainly: *"signal-cli is primarily intended to be used on servers to notify admins of important events."* Repo stats at study time: **5,077 stars, 477 forks, 120 releases, 2,391 commits**, created 2015-05-11, actively committed (November 2026 commits touch the SSE/daemon surface).

### The account model — the section this study turns on

A Signal identity is anchored to **one primary registration per phone number**. signal-cli offers two doors, and both collide with Sendqon's reality:

- **`register`** — signal-cli becomes the number's Signal client. The README's own warning: *"this will unregister any existing client associated with the same number."* Registering a tenant's number on our server **kills Signal on the tenant's phone for that number** — the exact inverse of our SIM-gateway model, where the number stays in the customer's phone and we borrow its SMS capability. Registration can also demand solving a **CAPTCHA** (Signal's anti-automation gate), plus SMS/voice verification to the number.
- **`link`** — signal-cli joins as a **linked device** to an account whose primary is the mobile app (the WhatsApp-linked-device shape). This preserves the phone app, but the tenant must perform the link from their Signal app, linked devices inherit the account's full message access (a heavy trust ask for a messaging *channel*), and the deployment still inherits every upkeep property below.

### The upkeep contract (README, verbatim substance)

*"signal-cli needs to be kept up-to-date to keep up with Signal-Server changes. The official Signal clients expire after three months and then the Signal-Server can make incompatible changes. So signal-cli releases older than three months may not work correctly."* And: incoming messages must be **regularly received** (daemon running) for the encryption session state and group updates to stay healthy. In channel terms: every Signal deployment is a daemon that breaks if you ignore it for a quarter.

### The wrapper ecosystem

Because raw signal-cli is a CLI/JSON-RPC daemon, the ecosystem's standard integration shape is a wrapper — principally **signal-cli-rest-api** (a community Docker project exposing REST + WebSocket endpoints over the daemon, with normal/native/json-rpc modes). (Named from ecosystem knowledge; its statistics were not live-verified in this study.) A Sendqon integration would mean running *both*: wrapper → daemon → Signal — two community layers between our panel and the network, each with its own release treadmill.

## 1. Licence

**GPL-3.0** (repo `LICENSE` is the stock GPLv3 text, read verbatim; the README's licence section says the same). Running signal-cli as a separate daemon process is ordinary GPL use (no distribution of derivatives), so the licence does not block a companion deployment — the same aggregate posture as other GPL companions. It does bar embedding/linking its code into our own binaries, which nobody proposes. **Licence: not the deciding factor.**

## 2. What it adds that we don't have

Exactly one thing: **a Signal channel** — the ability to send/receive Signal messages from a Sendqon workspace. Sendqon today has SMS, WhatsApp (vendor + own bridge), Telegram, email, website chat, web push, SMPP, and voice in design. Signal is the only major consumer messenger absent. Whether that absence is a gap is a demand question, answered in §8: **there is no tenant demand for a Signal channel anywhere on record** — no tenant request, no prospect requirement, no lost deal names it — and in Sendqon's home market WhatsApp is the overwhelmingly dominant messenger while Signal's footprint is a privacy-conscious niche. An absent channel with no demand is not a gap; it is a correct omission.

## 3. Stack fit

Poor, on three concrete points:

- **ARM64 friction:** signal-cli needs the native libsignal library; the bundled native libs cover **x86_64** Linux/Windows/macOS — the README directs other architectures to provide their own native lib, and the GraalVM native build is labelled experimental. offbox-1 is **ARM64**. This is solvable (build/provide the native lib) but it is exactly the class of friction that turns a "small companion" into a standing maintenance exception.
- **A JVM daemon per account** (JRE 25), plus the REST wrapper if integrated — heavier per-number than a Baileys session, for a channel with no queue of customers.
- **The 3-month expiry treadmill** (§What it is) multiplied by however many tenant deployments exist: a channel whose engine *by design* breaks if unpatched for a quarter is an operational promise we would make to every tenant who enables it.

## 4. Integration route

The only conceivable route — **companion service** (wrapper + daemon) behind a channel plugin, linked-device mode only, one tenant number per daemon — is documented here so the verdict can reject it knowingly rather than by default.

## 5. Effort

- Companion + wrapper packaging (incl. the ARM64 native-lib problem) + channel plugin + battery to the linked state: **~3–4 lanes**, before any real send/receive proof (which needs a volunteer Signal number and a link approval from its owner's phone app).
- Standing cost thereafter: a forced upgrade cadence of **at least quarterly per deployment**, forever, plus daemon health monitoring — for zero current demand.

## 6. Risk

- **Account-model risk (the structural one):** in register mode we would be asking tenants to surrender their number's Signal identity to our server — commercially and ethically a non-starter. In link mode we ask for a linked device with full-history access to their personal Signal account — a trust ask wildly disproportionate to a notification channel, and the same personal-account posture the whatsapp-mcp study drew a line against.
- **Platform posture:** Signal offers **no official bot, business or API programme at all**. Its terms contemplate use through its own clients; signal-cli is explicitly *unofficial*, registration is CAPTCHA-gated precisely to resist automation, and there is no one to appeal to if an account is throttled or disabled. Unlike WhatsApp (where an official Cloud API exists as the legitimate destination), on Signal the unofficial route is the *only* route — the risk can never be engineered away, only accepted.
- **Reliability risk:** protocol churn on a 3-month fuse (§3), daemon-must-poll receiving semantics, group/encryption state that degrades when the daemon sleeps — a channel that fails quietly is worse than no channel for OTP/alert-shaped traffic.
- **Privacy-brand risk:** Sendqon selling access into the Signal network cuts against what Signal's users chose it for; a single public complaint writes itself. (Recorded as a product judgement, not a technical fact.)

## 7. Maintenance health (live-checked 2026-11-28)

5,077 stars / 477 forks; 120 releases over ten years; commits in November 2026 — **the project itself is healthy and well-kept** (arguably the best-maintained unofficial messenger client in this corner). The maintenance problem is not the project's health; it is the *platform's* expiry model, which converts Signal's own anti-staleness policy into our upgrade treadmill.

## 8. Verdict — **NO-GO** as a Sendqon channel (with one narrow watchlist carve-out)

The verdict is earned on facts, not taste: (1) **zero demand on record** — no tenant, prospect or deal names Signal; (2) the account model forces a choice between displacing the tenant's own Signal app (register) and holding a full-access linked device on their personal account (link) — both disproportionate for a channel; (3) Signal provides **no legitimate automation path at all** — no bot API, no business platform, CAPTCHA-gated registration — so the channel would rest permanently on an unofficial client the platform actively resists; (4) the engine carries a **3-month forced-upgrade fuse** and an ARM64 native-lib exception on our host. Any one of (1)–(3) would suffice; together they are conclusive for a tenant-facing channel.

**Watchlist carve-out (the only door left open):** signal-cli's *own* intended use — a single linked account sending **Rektrs-internal admin notifications** (server alerts to the owner's Signal) — is legitimate, tiny and entirely in our control. It needs no channel, no plugin and no tenant story; if the owner ever wants alerts on Signal, it is a ~1-lane internal utility, recorded here so it is never confused with a product channel. Separately: **a paying tenant naming Signal in a signed requirement** reopens this study — as a linked-device-only companion for that tenant's own number, with §6 read aloud to them first.

**One-line verdict: signal-cli is an excellent tool being asked the wrong question — Signal has no demand in our market, no legitimate automation path, and an account model that punishes exactly what a channel needs; NO-GO, with only an internal-alerts carve-out left on the watchlist.**
