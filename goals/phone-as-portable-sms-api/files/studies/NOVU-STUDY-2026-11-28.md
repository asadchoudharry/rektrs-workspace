# Study — Novu (novuhq/novu) as a reference for Sendqon's automation layer

**Date:** 2026-11-28 · **Studied for:** two questions only — (a) what design ideas are worth borrowing for the `automations` plugin (Phase 4 of `../SENDQON-AUTOMATION-MCP-DESIGN-2026-11-28.md`, already approved and building), and (b) whether Novu itself should ever run as a Sendqon companion. This study does **not** re-open the Phase 4 design; anything that would change it is flagged as a flagged candidate, not a recommendation to redesign.
**Sources:** GitHub repo + API (checked live 2026-11-28), repo `LICENSE` verbatim, Novu's published docs (docs.novu.co workflow/step reference, crawled 2026-11-28). READ-ONLY study — nothing was installed or deployed.

## What it is

An open-source **notification infrastructure** platform: an application triggers a named **workflow** with a payload; Novu executes the workflow's **steps** across channels (email, SMS, push, chat, in-app) through pluggable provider integrations, honouring per-subscriber preferences, and records delivery in an activity feed. It also ships an embeddable **Inbox** component (notification centre + preference centre for end users). Repo stats at study time: **40,434 stars, 4,572 forks, 114 open issues**, created 2021-08-26; latest release **v3.21.0 (2026-11-24)** and commits on the study date itself — one of the most actively maintained projects in this corner. The vendor (Novu Inc.) sells a hosted cloud; the repo is the community/self-host edition of that product, and the project's current positioning is "communication infrastructure for agents and products".

### The model, in the terms our design uses

- **Trigger** — an API call (`trigger` with workflowId + payload + recipient) or a dashboard/framework event. Payloads are schema-validated (Zod/JSON Schema in the code-first Framework).
- **Workflow** — a named, versioned sequence authored either in a dashboard builder or **as code** (`@novu/framework`: `workflow(id, handler)` with a Bridge endpoint the Novu worker calls back into). Two authoring modes coexist per environment.
- **Steps** — channel steps (`step.email`, `step.sms`, `step.push`, `step.chat`, `step.inApp`) plus two control steps that matter for §2: **`step.delay`** (wait a duration before continuing) and **`step.digest`** (collect all trigger events over a window, then continue once with the batch). Steps carry conditions and produce typed outputs later steps consume.
- **Subscribers** — first-class recipients with identity (email/phone/device tokens), locale/timezone, and **per-workflow, per-channel preferences** managed through a preference centre; a workflow can be marked `critical`, which by definition **bypasses preferences, skips digest and ignores delays** (their examples: account suspended, security alert, password reset). Topics = named subscriber sets for broadcast triggers.
- **Providers** — dozens of integrations (SendGrid/SES-class email, Twilio-class SMS, FCM/APNs push, Slack/Discord chat); a step can be served by the configured provider integration for its channel.
- **Inbox** — a drop-in React/JS notification centre (bell, list, preferences UI) fed by the in-app channel.

## 1. Licence

The repo `LICENSE` file is the **stock MIT License** (read verbatim, 2026-11-28), and the README states the same. (GitHub's detector reports NOASSERTION, apparently a monorepo-detection artefact; the operative file is unambiguous MIT.) MIT permits commercial SaaS use, modification and embedding with only a notice duty. **Licence is a non-issue in both directions** — neither for borrowing ideas (ideas are never licensed) nor, hypothetically, for running it. The constraints on Novu for us are architectural, not legal (§3, §6).

## 2. What it adds that we don't have — the borrowable ideas, honestly graded

Our Phase 4 design already specifies: triggers (inbound message, schedule, webhook-in, campaign/flow events, MCP-invoked), actions (any channel send via the MCP registry's SEND tools, MCP tool call, LLM step, KB query, webhook-out, delay, condition/branch on prior step output, human-approval step), a run viewer, and a template gallery. Against that baseline:

| Novu idea | Do we have it? | Worth borrowing? |
|---|---|---|
| **Digest step** — accumulate events over a window, continue once with the batch | **No.** Our design has delay and branch, no aggregation node | **Yes — the one genuinely new node type.** Real Sendqon-shaped uses: "SIM low-balance alerts: at most one SMS per hour, summarising all low SIMs", "campaign-failure digest to the workspace owner". Cheap to specify now (a node that buffers run inputs per key+window and releases a batch), expensive to retrofit into a run engine that assumes 1 trigger = 1 run |
| **Per-recipient, per-automation channel preferences** honoured at delivery time, with a preference-centre UI | Partially — Sendqon core has channel-level opt-outs/suppressions (email unsubscribes, suppression lists), but not *per-automation* preferences | **Yes, as a product shape** — when automations message a tenant's customers, "this customer opted out of *this* automation's WhatsApp but not its SMS" is a cleaner model than global suppression only. Borrow the model, not the code |
| **`critical` flag semantics** — one workflow-level marker that bypasses preferences + digest + delays, with a deliberately narrow definition | No equivalent named concept | **Yes, as vocabulary** — it maps onto our transactional-vs-marketing distinction and gives the safety model (§4 of the design) a crisp rule: critical automations are the only ones allowed to ignore opt-outs, and the class is small and auditable |
| **Step conditions + typed step outputs** | Mostly — our design branches on prior step output; Novu additionally gates each step on its own condition | Marginal — fold "condition" into the step config when the node schema is written; no design change |
| **Code-first authoring** (workflows as code, synced from a repo) alongside a visual builder | No — our automations are panel-authored (ai_flow_builder generates them) | **No, not for tenants.** Our users are panel users; code-first is a developer-product feature. (For Rektrs' own internal use, MCP `run-flow` already covers programmatic invocation.) |
| **Inbox component** (embeddable notification centre) | Different shape — Sendqon's widget + web push cover visitor-facing messaging; a tenant-facing *notification inbox for panel users* does not exist | Watchlist-grade idea only — a panel notification centre is a core/panel feature question, not an automations-plugin question |
| **Provider failover inside a step** (multiple integrations per channel) | Different shape — our Cascade plugin cascades *across channels*; same-channel multi-provider routing lives in core's server/provider pickers | No — already covered by existing machinery in its own layer |

**Nothing in Novu contradicts the Phase 4 architecture** (new `automations` plugin orchestrating over core Flows, action nodes calling the one MCP registry). The registry-first design is actually the thing Novu lacks: Novu's steps deliver through *its* provider integrations, so a Novu step can never natively send through a tenant's Android SIM gateway or our WhatsApp bridge — it would need a custom provider/webhook hop back into Sendqon, at which point Sendqon is doing the real work anyway.

## 3. Stack fit (as a hypothetical companion)

Poor. Self-hosted Novu is a Node monorepo of several services (API, worker, WebSocket, dashboard) backed by **MongoDB + Redis** — a second database family and a second queueing stack on offbox-1 next to Laravel/MySQL/Redis, with a community-edition upgrade treadmill that historically trails the vendor's cloud. And its centre of gravity is wrong for us: Novu exists to abstract *other people's* delivery providers, while Sendqon's entire product is that the delivery channels (SIM gateway, own WhatsApp bridge, SMPP, PBX) are **ours**. A Novu companion would either bypass those channels (pointless) or call back into them per send (a notification platform used as an expensive trigger relay in front of the platform that actually sends).

## 4. Integration route

**Reference-only.** No plugin, no companion, no API link. The borrowable items in §2 are specifications to fold into the `automations` plugin's node catalogue and safety vocabulary.

## 5. Effort

- This study: the whole cost of the ideas.
- If the owner accepts the flagged candidates: digest node + per-automation preference model + `critical` semantics are **spec additions inside Phase 4's existing 4–5 lanes**, not new lanes — *provided* they are decided before the run-engine schema freezes. Decided late, the digest node alone becomes a follow-up lane.

## 6. Risk

- **Design-creep risk (the real one):** Novu is a polished, much larger product; "borrow one more thing" can quietly re-scope Phase 4 from messaging-shaped automations into a general notification platform. The flagged list above is deliberately closed: digest, preferences model, critical semantics. Everything else is recorded here precisely so it does not need re-studying — and does not get smuggled in.
- **No licence, security or operational risk** attaches to reference-only use.

## 7. Maintenance health (live-checked 2026-11-28)

40,434 stars / 4,572 forks; v3.21.0 released 2026-11-24; commits on the study date; 114 open issues against a very large user base (a healthy ratio). Company-backed with a cloud business model — the standing caveat for that shape is that self-host/community features evolve second to cloud priorities, which matters only if you run it (we recommend not running it).

## 8. Verdict — **REFERENCE-ONLY (adopt the ideas, not the software)**; as a deployable companion: **NO-GO**

**Flagged for Phase 4 (owner-visible, design-doc §3 amendment candidates — not silent changes):**
1. Add a **digest node** to the automation action catalogue before the run-engine schema freezes.
2. Adopt the **per-automation recipient-preference model** as the delivery-time opt-out shape (layered over core suppressions, not replacing them).
3. Adopt **`critical`** as the named, narrow class of automations allowed to bypass preferences/digest/delays — recorded in the safety model alongside the existing confirmation rules.

**One-line verdict: Novu is the best public reference for how a trigger→workflow→channel engine should feel — Sendqon should borrow its digest node, its preference model and its `critical` semantics, and should never run it, because its whole purpose (abstracting third-party providers) is the inverse of Sendqon's (owning the channels).**
