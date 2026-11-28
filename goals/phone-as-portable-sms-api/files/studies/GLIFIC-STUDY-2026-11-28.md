# Study — Glific (glific/glific): two-way WhatsApp automation on the OFFICIAL-API route, as a design reference

**Date:** 2026-11-28 · **Studied for:** one question — what does two-way WhatsApp automation look like when it is built on the **official WhatsApp Business API** (via a BSP) instead of on an unofficial linked-device bridge like our B8? Glific is the cleanest production specimen of the official route: an NGO platform in real use across India since 2020. This is **design mining only** (licence, §1). It pairs with [RAPIDPRO-STUDY-2026-11-28.md](RAPIDPRO-STUDY-2026-11-28.md) in this corner — deliberately: Glific's flow editor *is* the RapidPro-lineage editor, so the two studies are the same flow model seen from two different channel routes (RapidPro: aggregator SMS/USSD/IVR/WhatsApp; Glific: official WhatsApp only, plus a human desk).
**Sources:** GitHub API + repo `LICENSE` (live-checked 2026-11-28), Glific's official documentation and pricing page, the project's own year-in-review posts, and a builder-side account (ColoredCow). Vendor-published scale figures are labelled as such. READ-ONLY study — nothing was installed or deployed.

## What it is

An open-source **two-way communication platform for NGOs**, built by Project Tech4Dev (Chintu Gudiya Foundation): an Elixir/Phoenix backend with a React/GraphQL frontend, multi-tenant by organisation, whose **only** beneficiary channel is WhatsApp — reached exclusively through **BSP providers** (its provider-abstraction layer supports Gupshup, Gupshup Enterprise, and Maytapi). Around that pipe it builds the full programme-operations layer: a visual flow builder, contact **collections**, staff roles with **conversation assignment and ticketing**, scheduled sends and triggers, template (HSM) management, BigQuery analytics sync, and AI add-ons (classification, FAQ assistants, evaluations).

## 1. Licence

**AGPL-3.0** — verified verbatim from the repo `LICENSE` (GNU Affero GPL v3 text) and GitHub's detection agrees. Consequences for us, stated once and permanently: **design mining only.** Running Glific (modified or not) as a network service for tenants would trigger AGPL §13 source-offer duties for the whole work; embedding its code in Sendqon would contaminate the tree. Neither is contemplated — the study's value is its *product design on official rails*, which is not copyrightable territory and costs nothing to learn from.

## 2. What it adds that we don't have — the delta is a route, not features

Feature-by-feature, Glific holds few surprises: flows, collections (≈ our segments/groups), scheduled messages, staff inboxes — Sendqon has or is building equivalents. The real delta is **what the official route makes normal**:

- **A human-desk layer as a first-class citizen.** Contacts carry an *assigned staff member*; a flow can execute an **Open Ticket** action that routes a question to a specific team member; tickets live in their own table with assignee and status, worked by staff in the same UI as the automation. Our ai_agents handover is a *state machine* (bot yields, human replies, agent stays silent until reset — the lesson burned in on 2026-11-26); Glific's is a *desk* (work is assigned, tracked, closed). They are different answers to the same moment, and Glific's is the more complete one for a tenant whose staff actually work conversations.
- **Template operations as a product surface** — HSM template management including *bulk template uploads*, a template dashboard, and "Speed Sends" for quick template broadcasts. On official rails the template *is* the outbound unit, so the tooling grows around it; on our bridge route templates are a WABA-only corner.
- **Analytics as a shipped pipeline** — automatic BigQuery sync with a documented table-per-entity schema (contacts, flow contexts, tickets, wa_groups…) and standard report pages. Tenants don't export; the warehouse is just *there*.
- **WhatsApp Groups automation** — scheduled messages, polls and media into real WhatsApp groups, with group↔collection mapping. Note the honest wrinkle, from Glific's own pricing page: groups run through **Maytapi** ("Maytapi subscription is additional"), a third-party API provider — because the official Business API offers no group messaging, *even the official-route platform bolts on a non-official provider for groups*. The routes are purer in slide decks than in production.

## 3. The core comparison — official route (Glific) vs our bridge route (B8)

| Dimension | Official API route (Glific model) | Our bridge route (B8 / Baileys-class) | Genuine difference or plumbing? |
|---|---|---|---|
| Cold outbound | Only **pre-approved template messages** outside the 24-hour service window; category-priced per message (Meta's post-Nov-2024 per-message model: Glific's page lists marketing ≈ $0.0118/msg, utility/service ≈ $0.0014, user-initiated service free) | Free-form message to any reachable number at any time; cost ≈ SIM economics | **Genuine** — this is the deepest behavioural difference: the official route's outbound is *permissioned artefacts*, ours is *a phone sending texts* |
| In-window conversation | Free-form inside the 24h window the user's message opens | Free-form always | **Genuine** (the window discipline shapes flow design: Glific flows assume re-entry costs a template) |
| Interactive elements | Native, sanctioned: buttons, lists, WhatsApp Forms, Flows, catalogues | Protocol emulations with degradation (cf. the Typebot study's matrix: 3-button paging, silent skips) | **Genuine** |
| Groups | **Not in the official API** — Glific bolts on Maytapi | The account sits in groups natively | **Genuine**, and it cuts *against* the official route |
| Identity & trust | Verified business, display name, green-tick path, sanctioned messaging tiers (1k → 100k+ conversations/day) | An ordinary account; scale is ban roulette (the Evolution/WAHA studies' standing finding) | **Genuine** |
| Who can cut you off | Meta policy enforcement + BSP terms — visible rules, appeal paths | Meta's unofficial-client enforcement — opaque, terminal | **Genuine** |
| Dependency chain | Tenant → platform → **BSP (Gupshup)** → Meta: three parties, three bills, BSP outage = your outage | Tenant → platform → our bridge → WhatsApp: the risk is ours to engineer | **Genuine** (operational shape) |
| Flows, collections, assignment, scheduling, analytics | Built | Built / building (core Flows, ai_flow_builder, segments, ai_agents handover) | **Plumbing** — Glific proves these layers are route-independent product, which is why mining its UX is legitimate: nothing about a ticket or a collection belongs to Gupshup |

**The one-sentence summary:** the routes differ genuinely in *what a tenant may send, to whom, at what risk* — and barely at all in *the operations layer the tenant touches*. Glific is therefore the best available reference for how our own WABA (official) channel's UX should feel, while changing nothing about why B8 exists.

## 4. Specifics worth mining (flagged, not adopted)

1. **Ticket-as-a-flow-action.** "Open Ticket" is a node type in the flow builder, sitting beside "send message" and "call webhook": a flow can escalate *itself* into a human's queue with context attached. Our Flows/automations vocabulary has handover inside ai_agents but no equivalent *flow-level* escalation action — this is the cleanest version of that idea in the corner, and it belongs on the Phase 4 candidate list next to the Novu/Dittofeed/Mautic flags.
2. **Collections as the universal audience object.** Flows are triggered *to collections*; contacts enter/leave collections by flow actions and staff edits; broadcasts, schedules and group-mappings all address collections. One audience object, every surface — the same convergence the Dittofeed study flagged for segments, arrived at independently.
3. **Transparent three-line cost pass-through.** Glific's pricing page is the most honest specimen in this corner: platform fee flat (₹8,708/mo billed annually; ~₹9,500 monthly; unlimited users, *no feature tiers*), one-time setup ₹15,000, then **itemised pass-through** — Gupshup's own ₹1,500/mo + Meta's per-message fees, published on the same page. Tenants accept pass-through when it is printed next to the platform fee instead of discovered later. For our official-route (WABA) tenants, the same three-line shape (Sendqon plan + BSP if any + Meta) is the honest invoice; for bridge-route tenants our collapsed two-line version (plan + SIM economics) is a genuine pricing advantage in PK — Glific's page is what that advantage should be *explained against*.
4. **Template management UX** (bulk HSM upload, template dashboard) for our WABA surface — the official route lives and dies by template throughput, and Glific's tooling is shaped by NGOs who feel that daily.

## 5. Stack fit & integration route

**Reference-only.** The stack (Elixir/Phoenix + Postgres + Oban + React) is a third runtime family we do not staff, the licence (§1) bars the running shapes that would matter, and its single-channel BSP dependency is the inverse of Sendqon's channel-owning model. If a tenant ever demands the official route, Sendqon's answer already exists in-house — the **WABA channel** — wearing these UX patterns; it is never "deploy Glific."

## 6. Effort

This study is the whole cost. The mined items are spec-level flags for Phase 4 (ticket action) and for the WABA surface's backlog (template tooling, cost presentation) — decisions, not lanes.

## 7. Maintenance health + the ecosystem note (live-checked 2026-11-28)

- **glific/glific: 223 stars, 93 forks**, created 2020-06-01, **pushed 2026-11-27** (the day before this study), latest release **v8.19.2 (2026-11-26)** — a release cadence of days-to-weeks, sustained for years. By GitHub vanity metrics this is the smallest project in the corner; by every other measure it is one of the most alive.
- **Deployment scale (vendor-published, labelled):** Glific's site claims **110+ NGOs, over a million beneficiaries, "100 Million+ messages"**; its own 2023 review is more conservative and more credible — the 100th organisation account created that year, **1,010,221 beneficiaries reached cumulatively, 8,349,848 messages exchanged in 2023 alone** (4× its 2022). Named deployments (Digital Green, Quest Alliance, Reap Benefit, Slam Out Loud) recur across independent coverage.
- **The honest ecosystem lesson:** the footprint/scale inversion is structural. Glific's users are NGO programme staff who will never star a repo; its maintainers ship for *them*, funded as social-sector infrastructure (Tech4Dev), with support over Discord and monthly webinars. **Stars measure developer fame, not deployment truth** — for platforms whose users aren't developers, release cadence + dated usage reports are the better instrument, and by that instrument Glific is healthier than several 10k-star entries in this corner.

## 8. Verdict — **REFERENCE-ONLY** (design mining); as software, **NO-GO**

Glific changes no architecture and no roadmap. What it settles: (1) the official route's genuine differences are **sending permissions, interactivity, identity and enforcement** — not the operations layer; (2) the operations layer on official rails has a proven shape — **collections as the universal audience, ticket-as-flow-action, template tooling, three-line transparent pricing** — and those four patterns are flagged for our Phase 4 / WABA backlogs; (3) even the official route's flagship platform quietly uses a non-official provider for groups, which should temper any purity argument made against our bridge. Paired with RapidPro (same flow lineage, opposite channel philosophy), the two studies close the flow-design evidence base for Phase 4: one flow model, two routes, and Sendqon — unusually — already owns a foot on each.

*Re-open triggers: none for the software. The mined patterns live or die in the Phase 4 spec and the WABA backlog, on the owner's word.*
