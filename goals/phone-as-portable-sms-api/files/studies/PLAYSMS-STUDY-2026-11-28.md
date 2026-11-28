# Study — playSMS (playSMS/playSMS) — feature & architecture mining ONLY

> **LICENCE LINE, FIRST, AS REQUIRED: playSMS is GPL-3.0. No playSMS code — not a file, not a function, not a snippet — may ever enter the Sendqon tree, in original or "rewritten-from-memory-of-the-source" form. This study mines *ideas, feature shapes and hard-won product rules* only. Ideas are free; code is not. Anyone implementing from this study works from this document and from Sendqon's own codebase, never from the playSMS source.**

**Date:** 2026-11-28 · **Studied for:** what two decades of running an open-source SMS gateway panel teach a young platform — at the idea level only.
**Sources:** GitHub repo + API (checked live 2026-11-28 — note: the upstream repo is `playSMS/playSMS`; the `playsms/plsSMS` pointer in the study order resolves to it), repo README feature list (master/1.5-dev line), playSMS project documentation summaries (playsms.org via dated secondary reads, marked as such). No source code was read for this study beyond the README's own feature enumeration. READ-ONLY study — nothing was installed or deployed.

## What it is

A free, open-source **SMS management panel**: a PHP web application that sits in front of separate gateway software/services and gives users accounts, phonebooks, bulk sending, an inbox, and interactive SMS features. playSMS itself sends nothing — it drives gateways (its own words: it "cannot send or receive messages without a separate gateway application or service"). The project began in the mid-2000s (Anton Raharja; the GitHub repo dates to 2010-10-08) and was for years the default open-source front-end for Kannel/Gammu-class gateways — the same architectural slot Sendqon's panel occupies, arrived at twenty years earlier. Repo stats at study time: **895 stars, 471 forks, 83 open issues**; last tagged release **1.4.7 (2023-12-27)**; maintenance commits on the 1.4.x branch into 2026, plus a 1.5-dev line.

### The architecture, at idea level

- **Four plugin families** — *gateway* modules (Kannel, Gammu, SMS Server Tools, Jasmin, Twilio, Nexmo, Infobip, Clickatell, BulkSMS, and more), *feature* modules, *tools*, and *themes* — all behind narrow contracts, so the panel survives any one gateway.
- **Multiple simultaneously active gateways (SMSCs)**, with outbound **routing by destination prefix or by user**, and routing-layer failover between gateways.
- **A credit economy:** administrators set **rates by destination prefix** (with a default rate), users hold credit balances, and — the detail worth underlining — **only sent and delivered messages are rated and deducted**, not failed submissions.
- **A webservices surface** (a single token-authenticated endpoint): send SMS, retrieve delivery reports, check credit, read inbox, administrative operations. An Android client exists that is purely a client of this API.
- **A keyword-feature family** for inbound SMS: autoreply, board (keyword → public web page), poll, quiz, subscribe, custom (forward the message to an external HTTP app), command — small inbound-triggered applications, each a plugin.
- **A simulation gateway** — a fake gateway module for testing inbound/outbound flows without a real route.
- **Uplink** — a gateway module whose "gateway" is *another playSMS instance*: panels federating, one instance's users sending through another's routes.

## 1. Licence

**GPL-3.0** (repo `LICENSE.md` is the stock GPLv3 text, read verbatim; GitHub detects GPL-3.0). For completeness: GPL would permit running playSMS itself, even commercially, but copyleft governs distribution of derivative code — and Sendqon's rule is stricter than the law requires and is stated at the top of this study: **no code reuse, ever; ideas only.** This study was deliberately written from documentation and feature lists, not from reading the implementation.

## 2. What it adds that we don't have — the mined ideas, graded

Sendqon already has the panel, the plugins, the companions, the credits and the API. What twenty years of playSMS adds is *rules and shapes learned the hard way*:

| Mined idea | Sendqon's current shape | Value |
|---|---|---|
| **Charge only on sent/delivered, never on failed submissions** (rating rule) | Our metering charges per accepted send through the credit model; the aggregator design (Jasmin study) meters per submit PDU at the wholesale layer | **High — as a deliberate decision to make, not an oversight to discover.** When the aggregator/CVAS track prices real routes, "the customer never pays for a message we failed to hand off" is a trust rule competitors advertise. Record as an explicit pricing-policy question for the aggregator phase, with playSMS's two decades as the precedent |
| **Rate-by-destination-prefix as the primary pricing primitive** | Our plans price per credit with channel-level rates | Medium-high for the aggregator future specifically: prefix rating is how the entire wholesale SMS world thinks; Jasmin's per-route rates already give us the mechanism — playSMS confirms the *panel* should present it prefix-first when that day comes |
| **Simulation gateway as a first-class module** | Our dev batteries use fixtures and the dev copy; there is no named "test gateway" product object | Medium — naming a simulation companion as a permanent, shippable test double (for tenant API testing and our own batteries) is a small, clean idea worth adopting when the aggregator work starts |
| **Keyword-feature family** (board/poll/quiz/subscribe as inbound mini-apps) | Generalised by core Flows + the coming `automations` plugin (inbound trigger → actions) | Low as features, **high as validation**: the category "inbound keyword triggers a small application" survived twenty years of real use — evidence the automation layer's trigger model is aimed at a durable need, not a fashion |
| **Uplink / instance federation** | Sendqon has the partner-network concept (`network_enabled`, set live 2026-11-20) with 0 partner lines | Medium — playSMS proves a simple shape for it: *another instance is just a gateway with credentials*. When partner lines are designed, "a partner is a server row whose other end is another Sendqon" is the simplest model that could work |
| **One-endpoint webservices with token auth** (send/DLR/credit/inbox in one surface) | Our REST API + MCP registry are richer and better shaped | Low — historical interest only; validates that a *credit-check* operation belongs in the API surface (ours exposes balances via account views; fine as is) |

Explicitly **not** mined: its security posture lessons are generic (a long public history of advisories against old versions — the project's own docs warn that some published articles describe old vulnerable versions), and its UI/feature breadth (boards, quizzes) belongs to a portal era Sendqon is not recreating.

## 3. Stack fit

Not applicable as software — nothing will be integrated. As a *reference*, its stack (PHP panel + gateway daemons + plugin contracts) is the closest historical analogue to Sendqon's own (Laravel panel + companions + plugin contracts), which is precisely why its product rules transfer better than its contemporaries'.

## 4. Integration route

**Reference-only — ideas into design documents, nothing into the tree.** The two actionable outputs are (a) the charge-on-delivered question, recorded for the aggregator pricing design, and (b) the simulation-gateway and partner-as-server-row shapes, recorded for the aggregator/partner design work. Both belong to future design lanes, not to any current build phase.

## 5. Effort

This study only. Each mined idea, if the owner adopts it, lands inside lanes that already exist on the roadmap (aggregator phases, partner-network design) — none justifies a lane of its own.

## 6. Risk

- **Licence contamination is the only real risk, and it is procedural:** an implementer who "just looks at how playSMS did it" in source form and then writes similar code has created exactly the derivative-work question this study exists to prevent. The rule for any future lane touching these ideas: implement from this document + Sendqon's own code; do not open the playSMS source. (Reading its *documentation* and feature lists, as this study did, is ordinary competitive research.)
- No operational, security or product risk attaches to reference-only mining.

## 7. Maintenance health (live-checked 2026-11-28)

895 stars / 471 forks / 83 open issues. Last release 1.4.7 in December 2023 — nearly two years without a tagged release — but the 1.4.x branch still receives maintenance commits (latest July 2026) and a 1.5-dev line exists. Characterisation: **a mature project in slow maintenance**, kept alive by its maintainer and a hosting/community ecosystem (playsms.org), neither abandoned nor actively evolving. For an idea mine, health barely matters — the ideas have already survived their twenty years.

## 8. Verdict — **REFERENCE-ONLY (idea mining complete; software: NO-GO, permanently, on licence-hygiene grounds)**

Not a watchlist entry: there is no future condition under which playSMS-the-software enters our stack — Sendqon *is* the modern occupant of playSMS's slot. The study's value is the short list of product rules in §2, which now live in this corner where the aggregator and partner-network designs can cite them.

**One-line verdict: playSMS is Sendqon's twenty-year-old mirror — worth studying for its billing rule (never charge for a failed hand-off), its prefix-first rating, and its proof that keyword-triggered mini-apps endure; its GPL code stays outside our tree forever, by rule, not by accident.**
