# Study — RapidPro (rapidpro/rapidpro): a decade of production flows as a design teacher for Sendqon's Flows, automations and voice channel

**Date:** 2026-11-28 · **Studied for:** what ten-plus years of NGO/government production flows teach our own flow machinery — core Flows, the Phase 4 `automations` plugin (`../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`), and the voice channel's Phase 6 front-end (`../SENDQON-VOICE-CHANNEL-DESIGN-2026-11-28.md`).

> **Licence line, first, as required: RapidPro is AGPL-3.0. This study is design mining only — no RapidPro code, in any of its repos, ever enters our tree. Ideas, models and behaviours are what we take.**

**Sources:** GitHub repos (rapidpro + nyaruka/goflow, checked live 2026-11-28), repo `LICENSE` read directly, RapidPro's own component docs (rapidpro.github.io), DeepWiki's code-level documentation of the temba models and the goflow spec, UNICEF/Nyaruka's published history. READ-ONLY study — nothing was installed or deployed.

## What it is

A visual flow-builder messaging platform built by **Nyaruka** (Kigali, Rwanda): launched as the hosted **TextIt** service in 2013, then **open-sourced in late 2014 in partnership with UNICEF** as RapidPro — dual copyright UNICEF + Nyaruka, held to this day (the `LICENSE` names both). It runs national-scale programmes: health campaigns, surveys, U-Report polling, feedback lines — over SMS, voice IVR, USSD and social channels, in the languages of the people receiving them. A third-party 2024 landscape survey credits the UNICEF deployment with 284 workspaces across 130 country offices and billions of messages (third-party figure, labelled as such — the shape, planet-scale NGO production, is not in dispute).

The architecture is a small fleet, not a monolith-with-plugins:
- **RapidPro proper (Django, the `temba` packages)** — UI, flow editor hosting, contacts, orgs, APIs.
- **Mailroom (Go)** — the execution engine: starts and advances flows, sends broadcasts, **handles incoming IVR callbacks**, ingests survey submissions.
- **Courier (Go)** — the channel layer: one handler per channel type/aggregator; exposes the endpoints aggregators and voice providers call back into.
- **GoFlow (Go library)** — the flow **specification and reference engine**: validates, migrates and executes flow definitions; embedded in Mailroom.
- **Flow Editor (React)** — the visual authoring app, shared with TextIt.

## 1. Licence

**AGPL-3.0** (read from the repo `LICENSE`: GNU Affero GPL v3, © 2012–2023 Nyaruka, Inc. + UNICEF; the goflow repo's licence file is the same family — GitHub reports NOASSERTION there due to file formatting, the text is AGPL). For us: design mining is unaffected; *running* RapidPro for tenants would carry the full §13 analysis this corner did for listmonk, and there is no product reason to ever get there — RapidPro is a whole platform competing for the same centre Sendqon occupies, not a component. **Reference-only by construction.**

## 2. What it adds that we don't have — the teachings, graded

### 2.1 Flow definitions are versioned documents with a living spec — the strongest lesson
A RapidPro flow's definition is JSON conforming to a **numbered GoFlow spec** (current line: spec 14.x). Definitions are stored as **FlowRevisions** — every save is a new revision; the system computes a structured diff (nodes added/modified/deleted, metadata, dependency changes) between revisions. GoFlow **migrates older definitions forward** automatically when the spec evolves, and validates a flow against the session's assets before it runs. Our Flows and the coming automations both store definitions; neither has (on record) a spec version, a revision history with diffs, or a migration path. **Teaching T1: treat every flow/automation definition as a versioned document from day one — spec version field, immutable revisions, forward migrations. Retrofitting versioning onto a library of tenant-authored flows is the expensive version of this decision.**

### 2.2 Node = actions + optional router + exits; router outcomes are *named results*
A goflow node carries a list of **actions** (send message, set contact field, add to group, call webhook/resthook, enter another flow, …), an optional **router**, and **exits**. The router (switch on an expression, random, or a **wait**) sorts the contact into **categories**, each wired to an exit — and the category is stored as a **named result** (`@results.<name>`) that later nodes, and afterwards reporting, can read. Waits are router-attached: *wait for response*, *wait for digits*, each with a timeout and a "no response" route. The discipline worth copying: **every branching point produces a named, typed, queryable result** — flow results are RapidPro's analytics substrate (programme dashboards are built from them). Our automations design has step outputs; **Teaching T2: make router/wait outcomes first-class named results with the same status in the run record, not just transient branch inputs — that is what makes runs reportable rather than merely inspectable.**

### 2.3 Multi-language: one flow, base language + a localization table keyed by stable UUIDs
A flow is authored in a **base language** (ISO-639-3). Every localizable item (message text, router category names, prompts) carries a **stable UUID**; translations live in a separate **Localization** object — per language, per item-UUID, per key. At runtime the session resolves language in order: the contact's preferred language → the channel's → the flow's base. Nothing is duplicated structurally: one graph, N text layers. For a platform whose home market runs Urdu/English side by side (and whose voice design already worries about Urdu strings), this is the correct shape and it is cheap only if designed in early — retrofitting stable UUIDs onto every string in an existing builder is miserable. **Teaching T3: Flows and automations should store localizable strings as (item-UUID → language → text) from the start, with session language resolved contact-first. Applies verbatim to Phase 6 voice prompts (recorded/TTS strings are just another localization of the same item).**

### 2.4 Expiry is a first-class, per-flow-type default — sessions are not allowed to linger
Every flow type carries a default **session expiration**: messaging flows **3 days**, **voice flows 5 minutes**, background/survey flows none. A session parked at a wait past its expiry ends in an explicit *expired* state; a new trigger can interrupt and replace a waiting session. The numbers encode a decade of operational scar tissue: a voice caller who hangs up mid-menu must not hold state; an SMS respondent who answers tomorrow is normal. **Teaching T4: adopt explicit per-type expiry defaults (conversational waits, automation waits — Dittofeed's/Mautic's decision deadlines are the same idea at node level — and bridge sessions) with an expired end-state in the run record. Our §4 session timeouts already think this way for the bridge; generalise it.**

### 2.5 Contacts are sets of URNs; fields are typed; "campaigns" are date-field triggers
- **Identity:** a contact is a set of **URNs** — `tel:`, `whatsapp:`, `telegram:`, … — one identity per scheme, with a preferred URN chosen per channel. This is the cleanest public model of the thing our own contacts approximate (and of the bridge's whitelist: a whitelisted number is one URN of one contact).
- **Fields:** custom contact fields are **typed** (text / number / datetime / location), settable by flow actions, readable as `@contact.fields.*`; flow outputs land in `@results.*`; workspace-wide values in `@globals.*`. A small, strict variable grammar — worth comparing against our template variables when the automations expression surface is specified.
- **Campaigns (RapidPro sense):** recurring messages scheduled **relative to a contact datetime field** ("3 days before `@fields.appointment_date`") — a per-contact date trigger, which our Phase 4 trigger catalogue (cron-shaped schedules, inbound events, webhooks) does **not** have by name. **Teaching T5: a per-contact date-field trigger is a distinct, high-value trigger class for a messaging platform (appointments, expiries, renewals) — flag it for the Phase 4 trigger catalogue.**

### 2.6 Dependency tracking and inspection
On save, a flow is *inspected*: every asset it references (channels, groups, fields, other flows, classifiers) is extracted and stored as a dependency; the editor can warn before a referenced asset is deleted or broken. **Teaching T6: cheap, high-value builder hygiene — record asset dependencies for flows/automations at save time.** (Subflows — an "enter flow" action with parent/child session semantics — come free in the same model and are already implicit in our design via `run-flow`.)

## 3. The IVR teaching — how a production engine drives voice calls (for Phase 6)

RapidPro voice flows are a distinct flow type (`V`) executed by the same engine, and the mechanics are the opposite end of the spectrum from our Pipecat streaming plan:
- The voice **channel** (a Courier handler for a telephony provider — Twilio-class) receives the provider's **callback** when a call is answered; **Mailroom advances the session one turn and answers with the next instruction** (play this audio / say this text / collect digits), the provider calls back again on each keypress or timeout, and so on. The engine holds **no media stream** — it is stateless per HTTP turn, with session state keyed by the call and a **5-minute default expiry**.
- Flow-side, an IVR node is the same node as everywhere else: actions (play/say) + a **wait-for-digits router** with digit count, timeout, and categories (matched input / no response / timeout) wired to exits.

**What this teaches our voice design:** there are *two* legitimate IVR shapes, and RapidPro proves the simpler one at national scale —
1. **Deterministic menu/survey IVR** (press-1-for-X, collect a reading, confirm an order status): a **per-turn callback contract** — prompt → collect → callback — which maps naturally onto our Asterisk leg (ARI/AGI can drive exactly this loop) and needs no streaming pipeline, no STT, no LLM. Prompts are localizations (§2.3) rendered as recorded audio or TTS.
2. **Free-form AI conversation**: the streaming Pipecat shape from the voice-trio studies.

Phase 6 should not force shape 2 onto shape-1 problems. The voice plugin's flow surface should offer the callback-style IVR as the default for structured interactions (it is also the shape the owner's named B10.5 acceptance case — an IVR order-status lookup — actually is), reserving the Pipecat leg for genuinely conversational calls. **This refines, and does not contradict, the voice design: Asterisk keeps call control either way; the difference is only what answers each turn.**

## 4. Stack fit & integration route

**Reference-only.** RapidPro is a Django + Go-services platform that *is* a centre, not a component — there is no embedding shape, and its channel layer (Courier) solves the problem our companions already solve in our own model. Nothing in its stack (Python/Go/Postgres) is adoptable piecemeal without adopting the platform. Its Android channel and offline Surveyor app are noted as category validation (an Android handset as a channel is a decade-old proven pattern — the same ground our gateway app stands on), not as candidates.

## 5. Effort

This study is the whole cost. Teachings T1–T6 are spec-level decisions: T1/T3 are **free only if taken before** the automations run-engine and builder schemas freeze (afterwards each is a migration project); T2/T4/T5/T6 fold into Phase 4's existing lanes as catalogue and run-record decisions. The §3 IVR refinement is a Phase 6 design note — it *removes* work (structured IVR no longer waits for the streaming pipeline) rather than adding any.

## 6. Risk

- **Scope gravity:** RapidPro is a complete platform with a humanitarian feature set (surveys, case management patterns) far outside Sendqon's commercial messaging scope. The teaching list is closed at T1–T6 + the IVR shape; the rest is recorded as *not* applicable so it is not re-mined later.
- **Maintenance signal (below)** counsels against any dependency even if a use appeared — the GitHub monolith is no longer where the ecosystem's energy is.
- No risk attaches to reference-only use.

## 7. Maintenance reality (live-checked 2026-11-28)

- **rapidpro/rapidpro: 911 stars, 410 forks**; last push **2026-04-21** — a security-updates merge; the Django monolith is in slow, security-focused maintenance and carries **no tagged releases** (deployments track branches/tags in the component repos).
- **nyaruka/goflow: pushed 2026-11-26** — the engine/spec layer is alive and current. (Mailroom/Courier repo stats could not be retrieved at study time — GitHub API rate limits; labelled unverified rather than guessed.)
- **Funding/maintenance model:** Nyaruka maintains the code and sells **TextIt**, the hosted SaaS the platform was born as; UNICEF has been the anchor partner since 2014 (the platform is a recognised Digital Public Good, and UNICEF country-office deployments are its largest installed base). The honest summary: *institutionally durable, commercially quiet* — it will not disappear (UNICEF/TextIt depend on it), and it will not sprint (its funders buy stability, not features). For a design reference, that is the ideal health profile: the models have been stable long enough to be proven, which is exactly what we're mining.

## 8. Verdict — **REFERENCE-ONLY (design mining), permanently**

RapidPro is the most experienced flow engine in this corner — the only one whose design decisions have been load-tested by a decade of national programmes in dozens of languages. What Sendqon takes: **T1** versioned flow definitions with spec migrations and revision diffs; **T2** named results as the run record's first-class output; **T3** UUID-keyed localization with contact-first language resolution; **T4** per-type expiry defaults with an explicit expired state; **T5** the per-contact date-field trigger for Phase 4; **T6** save-time dependency inspection — plus the §3 refinement that **structured IVR is a per-turn callback shape, not a streaming problem**, which simplifies Phase 6. Nothing is adopted, nothing is run, and the AGPL line in this file's header is permanent.

*Re-open triggers: none for the software. The teachings live or die inside the Phase 4 and Phase 6 specs, on the owner's word.*
