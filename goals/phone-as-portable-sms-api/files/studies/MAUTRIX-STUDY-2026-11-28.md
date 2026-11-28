# Study — the mautrix bridge family: Matrix-as-unified-bus vs Sendqon's per-channel plugin/companion model (ARCHITECTURE study)

**Date:** 2026-11-28 · **Studied for:** an architecture position, not an adoption. One bridge per network translates that network into the **Matrix** protocol; a Matrix homeserver becomes the single bus every chat flows through. The question: is that a better channel-expansion architecture for Sendqon than the per-channel plugin + companion model we have built B0–B10 on — and if not, what piece of it, if any, still fits?
**Sources:** GitHub repos for the whole family (checked live 2026-11-28), repo `LICENSE` files, Matrix homeserver comparisons (matrixdocs, checked Oct 2026), TechCrunch/Thurrott reporting on Beeper's acquisition, bridge-security explainers. READ-ONLY study — nothing was installed or deployed.

## What it is

**mautrix** is a family of Go bridges, one per network, all built on a shared framework (`mautrix-go`, the "bridgev2" generation), each running as a Matrix **appservice** attached to a homeserver. A bridge logs into its network as the account owner (usually as a **linked device**), mirrors every chat into a Matrix **portal room**, represents each remote contact as a puppet ("ghost") user on the homeserver, and translates messages, media, reactions, receipts and edits in both directions. The family at study date (all AGPL-3.0, all actively maintained):

| Bridge | Network(s) | Stars | Last push |
|---|---|---|---|
| mautrix-whatsapp | WhatsApp (on **whatsmeow** — the same library as WAHA's GOWS engine) | 1,943 | 2026-11-28 |
| mautrix-telegram | Telegram | 1,771 | 2026-11-27 |
| mautrix-meta | Messenger + Instagram | 488 | 2026-11-28 |
| mautrix-discord | Discord | 518 | 2026-11-28 |
| mautrix-signal | Signal (own `signalmeow` library) | 684 | 2026-11-27 |
| mautrix-gmessages | Google Messages (SMS/RCS) | 208 | 2026-11-28 |
| mautrix-slack | Slack | 109 | 2026-11-27 |

(The old standalone mautrix-instagram repo has been untouched since 2024-03 — Instagram was folded into mautrix-meta; the family consolidates as it matures.) Release cadence on the flagship: monthly calendar-versioned releases (v0.2611.0, 2026-11-16). Maintenance is concentrated in a small team around the original author, with **Beeper/Automattic as the commercial centre of gravity** — see §7.

**The scale proof is real and public:** Beeper, the consumer "every network in one inbox" app, is built on exactly this architecture (Matrix + mautrix bridges, hosted server-side). Automattic acquired Beeper in **April 2024 for $125M** (TechCrunch, from sources; the acquisition itself was announced by Automattic) after buying Texts.com in 2023, and folded both teams into one messaging product spanning ~14 networks. What is *not* public: Beeper's internals beyond the architecture (its client is closed-source; the bridges it uses are the open mautrix ones), and any reliability numbers. The verified claim is narrow but sufficient: **this architecture carries a venture-scale consumer product; it is not a hobby pattern.**

## 1. Licence — AGPL-3.0, and what adopting any piece would actually trigger

Every bridge, and the shared framework, is **AGPL-3.0** (read from the repos; GitHub detects AGPL-3.0 cleanly). The homeserver side adds a second AGPL: **Synapse is AGPL-3.0** (or Element's commercial licence); the lightweight Rust servers (Conduit/Tuwunel/Continuwuity) are Apache-2.0 but are not the bridge-tested path (§3c). The mechanics, using this corner's listmonk analysis as the template:

- **Running an unmodified bridge** that users interact with over a network: AGPL §13's source-offer duty is triggered by **modification**, not by running — unmodified use is permitted, no fee.
- **The moment we patch a bridge** (a Sendqon-specific fix, branding, a behaviour change) *and* tenants interact with the modified bridge remotely, §13 obliges us to **prominently offer those users the complete Corresponding Source of our modified version, free, over the network** — and §10 bars contracting around it. Given the bridges' breakage cadence (§6), "we would never need to patch one" is not a credible operating assumption; a patched-bridge fix upstreamed publicly is the only clean posture, which means our fixes become everyone's.
- **Aggregation keeps Sendqon clean:** the bridges and homeserver are separate programs; Sendqon talking to them over the Matrix client-server/appservice APIs is the §5 aggregate shape — Sendqon's own code stays outside AGPL. The licence is therefore a *manageable* constraint, not the deciding one. The deciding constraints are architectural (§2) and security-shaped (§2b).

## 2. The comparison — per-channel plugins/companions (ours) vs unified Matrix bus

Our model today: each channel is an own plugin + (where needed) a companion service — B8 WhatsApp bridge companion, Telegram companion, Email companion, PBX, Jasmin — each speaking Sendqon's internal channel contract into core's uniform message model. Contacts, history, media, billing and audit live in **our** tables, in **our** shapes.

| Dimension | Per-channel model (Sendqon today) | Unified-bus model (mautrix/Matrix) |
|---|---|---|
| **Adding channel #9** | New companion + plugin shim against our channel contract — the B4/B9 pattern, proven repeatedly, ~1–3 lanes per channel including battery | If a mautrix bridge exists: deploy it + configure the appservice — the *edge* is nearly free. But the centre must already speak Matrix: every consumer (campaigns, flows, agents, MCP tools, inbox UI) reads/writes rooms and events, not our message model. The cost isn't channel #9; it's channels #1–8 having been built on the bus from the start. For us it is a **re-platforming**, not an addition |
| **Identity / contact mapping** | Contacts are ours; a channel references a contact by number/URN; one contact, many channels, resolved in our tables | The bridge owns identity: remote contacts become puppet users (`@whatsapp_<id>:server`), chats become rooms, the account owner gets a Matrix identity. Mapping puppets ↔ Sendqon contacts is a **permanent synchronisation problem** (renames, number changes, LID migrations — the WhatsApp bridge shipped LID-migration fixes *this week*), and tenant customers would exist as identities on infrastructure shaped like a chat server, not as rows in the tenant's contact list |
| **History / backfill** | Starts at link time (B8's known limit); history is whatever core recorded | **Genuinely better:** bridges backfill — the WhatsApp bridge pulls history sync from the linked device, portals can be created with recent history attached. The one dimension where the bus model wins outright; noted honestly |
| **Media handling** | Our pipeline: uploads land in our store with our `media_path` semantics (the Phase 2 MCP media tool speaks exactly this) | Media is converted into the homeserver's media repo (`mxc://`), with format/size transcoding per network (voice notes, stickers, documents). Competent — but every media consumer we have would need an mxc translation layer, and the bytes live under the homeserver's retention, not ours |
| **Failure isolation** | Per-companion: B8 down ≠ Telegram down; core has no single channel throat | Per-bridge isolation is equally good — but the **homeserver is a single central dependency**: Synapse down (or its Postgres, or a botched upgrade) takes *every* channel down at once. Our model has no equivalent single point short of core's own DB, which is already ours to run |
| **Per-network fragility** | Each companion rides its network's breakage (Baileys updates, session drops) | **Identical, relocated:** the WhatsApp bridge rides whatsmeow breakage on the same cadence (commits this week include exactly the protocol-chase fixes B8's world knows). The bus does not reduce fragility; it standardises where you stand when it breaks |
| **Product shape** | A messaging *platform*: campaigns, flows, agents, APIs — conversations are data inside a larger machine | A messaging *bus*: superb at "one inbox, every network, human reading" (that is Beeper's whole product). Campaigns/flows/agents would all have to be built *on top of* Matrix semantics — rooms as the unit of everything — which fights our data model at every step |

**Net:** the bus model's real advantages are (i) marginal cost of the *next* network once you're on the bus, and (ii) backfill. Its costs for us are total: our centre (contacts, campaigns, MCP registry, audit, billing) is the product, and the bus insists on being the centre instead. An architecture whose first move is replacing your data model is not an integration route; it's a different company.

## 2b. The security note, stated plainly

A bridge is a **linked device on the remote network, and it terminates that network's end-to-end encryption**. Mechanically: a WhatsApp or Signal message arrives encrypted *to the bridge's device keys*; the bridge decrypts it, holds it in **plaintext** (memory, and at rest in the bridge/homeserver databases and media repo), and re-encrypts it into Matrix — optionally with *end-to-bridge* encryption, where the bridge itself is the far endpoint of the "end-to-end" leg. Consequences, without varnish:

- **"End-to-end encrypted" stops being true.** The ends become *the bridge* and *the far party*. Whoever controls or compromises the server running the bridge can read every message on every bridged network. Message content at rest exists wherever the homeserver stores room history and media — which, for a bus deployment, is *all of it, indefinitely, by design* (the inbox is the history).
- **For a tenant offering, the marketing claim breaks:** a tenant telling its customers "our chats are end-to-end encrypted" while a bridge sits in the middle would be making a false statement. The honest description is "encrypted in transit; decrypted on our server to deliver and automate."
- **Calibration against our own house:** B8 already decrypts the tenant's *own business WhatsApp* on our server — automation inherently requires server-side plaintext, and the tenant chose to automate that account. The bus model's difference is one of **scope and default**: it normalises plaintext exposure across *personal* accounts on *many* networks (that is Beeper's consumer bargain, made knowingly by each user for their own accounts). A B2B platform importing that bargain on behalf of tenants' customers — who never consented to it — is a different ethical and legal shape entirely. This, more than the AGPL, is why the bus is wrong for tenant traffic.

## 3. Operational weight (the homeserver question, 2026 state)

- **Synapse** (Python, Element-maintained) is the reference server and the only one the bridges are routinely tested against: active, ~fortnightly releases (v1.163, Oct 2026), needs PostgreSQL, and wants **~1–2 GB RAM before bridges** at small scale (its docs ask for 1 GB free just to join large rooms; small-server guidance starts at 2 GB/2 cores). AGPL-3.0 or commercial.
- **Dendrite** (Go, Element) is in **maintenance mode — security fixes only**; not a starting point.
- **Conduit** (Rust, Apache-2.0) is active but self-described **beta**; its conduwuit fork was archived in 2025 and lives on as **Tuwunel** and **Continuwuity** (both active, Apache-2.0, single-binary, ~512 MB–1 GB class). Light and attractive — but appservice/bridge behaviour is the least battle-tested exactly where we'd depend on it.
- Plus the standing burdens: the **server name is immutable once chosen**; signing keys and state DBs become crown-jewel backups; media repo grows monotonically; and each bridge adds its own database and upgrade cadence (monthly, on the flagship) to the fleet. On offbox-1 (2 OCPU / 12 GB, already carrying Sendqon + five companions) a Synapse + 3–4 bridges *fits* — the objection is not capacity, it's a second platform to patch, back up and monitor in exchange for a centre we don't want.

## 4. Does any piece fit short of the full model?

One shape does, and it is deliberately small: **a "Matrix channel" as one more companion.** If a tenant ever lives in Matrix/Element (or wants a Matrix-native support inbox), Sendqon can speak the open Matrix client-server API directly from a channel companion — post into rooms, read replies, map room ↔ conversation — *without* adopting any mautrix code or running bridges at all. That is channel #N in our existing model (an API-shaped channel, like our email companion), not a bus migration. Demand on record today: **none** — no tenant, prospect or deal names Matrix. It is recorded here as the pre-studied answer if that ever changes (~2–3 lanes, comparable to other companions). The family's *protocol libraries* (whatsmeow et al.) are a separate question, already governed by the WAHA study's watchlist triggers — nothing in this study changes them.

## 5. Effort

- Full bus adoption: not lane-estimable — it is a re-platforming of the message centre plus migration of every channel, and is rejected on architecture, not on price.
- The §4 Matrix-channel companion, if ever ordered: ~2–3 lanes (companion + channel plugin shim + battery), in line with the B4/B9 companions.
- This study: the whole cost of the position.

## 6. Risk (of the bus model, for the record)

- **Concentrated maintenance:** the family is effectively one small team; Beeper/Automattic's priorities (a consumer inbox) are not a B2B platform's priorities, and the bridges' cadence follows the networks' breakage, which is relentless (three of the family's repos were pushed *today*).
- **Account-risk inheritance:** linked-device bridges on WhatsApp/Signal carry the same unofficial-automation exposure this corner documented for B8 and signal-cli — per network, forever.
- **Plaintext-at-rest concentration** (§2b): one breach = every network's history. For a multi-tenant platform this is the single largest blast radius available in messaging architecture.
- No risk attaches to not adopting it.

## 7. Maintenance health (live-checked 2026-11-28)

The family's flagship repos were pushed **today and yesterday**; monthly calendar releases on mautrix-whatsapp; the family is consolidating sensibly (Instagram folded into meta). Commercially anchored by Automattic (Beeper, $125M acquisition, Apr 2024) — the strongest funding signal of any project in this batch — while remaining a small-team codebase at its core. Health verdict: *excellent for what it is; irrelevant to the decision, which is architectural.*

## 8. Verdict — architecture position for Sendqon

**NO-GO: the unified-bus (Matrix) model is not adopted as Sendqon's channel architecture.** Our per-channel plugin/companion model keeps the product's centre — contacts, campaigns, flows, agents, MCP registry, billing, audit — in our own data model, isolates failures per channel, and confines server-side plaintext to the accounts a tenant explicitly chose to automate. The bus model would replace that centre, concentrate every network's plaintext history in one store, and make a homeserver a single point of failure for all channels — in exchange for cheaper marginal networks and better backfill, neither of which is a pain we have.

**WATCHLIST, one named item:** a Matrix *channel* companion (Sendqon speaks Matrix as one more channel, §4) — to be built only on a named tenant requirement.

**Conditions that would reopen the architecture question itself:** (1) a signed tenant requirement for **three or more networks we don't have** (e.g. Discord + Slack + Google Messages) delivered as one unified inbox — at which point the bus's marginal-cost advantage becomes real money; (2) a deliberate product pivot to a **unified-inbox product** (the Chatwoot-shaped desk) where an internal bus earns its keep — and even then, this corner's Chatwoot Route 1 is evaluated first, since it reaches the same product without re-platforming Sendqon; (3) B8's per-channel pattern demonstrably failing to scale operationally (companion count or breakage load beyond what the team can run) — the failure the bus is actually designed to solve, which we do not currently have.

*One-line summary: Beeper proves the bus works — for Beeper's product. Sendqon's product is the centre the bus would replace, so we keep our channels plural, our contacts ours, and Matrix on the watchlist as a channel, not a foundation.*
