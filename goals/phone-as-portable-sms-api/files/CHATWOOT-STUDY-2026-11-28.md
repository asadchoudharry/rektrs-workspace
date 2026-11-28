# Study — Chatwoot (chatwoot/chatwoot)

**Date:** 2026-11-28 · **Studied for:** Sendqon family — the missing omnichannel human support-desk layer
**Sources:** GitHub repo + API (checked 2026-11-28), repo licence files and full file tree (`develop` branch), `config/installation_config.yml`, chatwoot.com pricing + self-hosted pricing pages, developers.chatwoot.com API reference, Chatwoot help-centre articles. Every claim below traces to one of these; where the docs are silent, that is stated. READ-ONLY study — nothing was installed or deployed.

## What it is

An open-source omnichannel customer-support desk — the Intercom/Zendesk alternative: website live-chat widget, email, WhatsApp, Facebook/Instagram, Telegram, LINE, SMS and an API channel all land in one agent inbox with teams, assignment, automations, canned responses, CSAT, a help-centre portal and reporting. Ruby on Rails + Vue, Postgres + Redis + Sidekiq. Repo stats at study time: **40,723 stars, 9,917 forks, 1,653 open issues, 393 contributors**, created 2019-08, not archived (GitHub API, 2026-11-28). It is a **support desk**, not a messaging gateway: it owns no sending infrastructure of its own beyond provider integrations (Meta WhatsApp Cloud, Twilio, 360dialog etc.) — which is exactly the layer Sendqon already owns.

## Licence — the split that decides everything

The root `LICENSE` is explicit: everything under **`enterprise/`** is licensed under `enterprise/LICENSE`; **everything else is MIT Expat**. GitHub therefore reports the repo licence as "NOASSERTION" — it is a dual-licence repo, not a pure-MIT one.

- **MIT core** — use, copy, modify, publish, distribute, sublicense and **sell**, in production, with no seat limit and no fee. This is the "Community Edition" when self-hosted.
- **`enterprise/LICENSE`** (source-available, **not** open source): the enterprise code "may only be used in production" under the Chatwoot Subscription Terms with **a valid Enterprise licence for the correct number of user seats**; development/testing use is free; Chatwoot retains title to any modifications you make to it; copying/selling it is forbidden. In practice the enterprise code is **feature-flag/premium-config gated** in the shipped product — the super-admin config file itself notes premium values "get overwritten unless the user is on a premium plan".

**What actually sits in `enterprise/`** (verified against the repo tree, 2026-11-28 — model/service/controller locations, not marketing copy):

| Enterprise-gated | Where it lives |
|---|---|
| **Captain AI** (Assistant, Copilot, summaries, memories, triage, scenarios) | `enterprise/app/models/captain*`, `services/captain` (168 files), `jobs/captain` (34), `builders/captain` — core keeps only dashboard UI shells/API clients |
| **SLA policies + SLA evaluation** | `enterprise/app/models/sla_policy.rb`, `sla_event.rb`, `jobs/sla`, `controllers/…/sla_policies_controller.rb` — core keeps the SLA *display* components and a `SLAPaywallEnterprise.vue` paywall screen |
| **SSO / SAML** | `enterprise/app/models/account_saml_settings.rb`, `services/saml`, `builders/saml_user_builder.rb` |
| **Custom domains** | `enterprise/app/controllers/custom_domains_controller.rb` |
| **Agent capacity policies** (max conversations per agent) | `enterprise/app/models/agent_capacity_policy.rb`, `inbox_capacity_limit.rb` |
| **Custom roles & permissions** | `enterprise/app/models/custom_role.rb` |
| **Voice/video calls** (Twilio Voice) | `enterprise/app/jobs/voice` (14), `services/voice` (29), `models/call.rb` |
| **Conversation monitors, audit-style account tooling, companies** | `enterprise/app/services/conversation_monitors`, `models/enterprise` (50) |
| **Custom branding / branding removal** | premium feature flag `disable_branding` + premium-locked installation configs (see White-label below) |

**What is MIT core** (verified in tree): all channels incl. **API channel** (`app/models/channel/api.rb`), **WhatsApp/Twilio SMS channels**, teams, **round-robin auto-assignment + assignment policies**, **automation rules** (`app/models/automation_rule.rb`), **canned responses**, **macros**, **CSAT surveys + reports**, labels, custom attributes, **help-centre portals**, **reporting**, **webhooks**, **Agent Bots** (62 core paths), **Platform API** (36 core paths — provision accounts/users programmatically), integrations hooks (Slack, Shopify, Notion, Dialogflow…).

**Self-hosted paid tiers** (chatwoot.com self-hosted pricing page, 2026-11-28): **Premium Support $19/agent/month** — Captain AI, custom branding, agent capacity, roles & permissions, priority email support. **Enterprise $99/agent/month** — adds SSO/SAML, SLA policies, audit logs, phone support. (Cloud list prices mirror these per-agent numbers; Captain credit overage $20 / 1,000 credits. At Rs 277/USD: ≈ **Rs 5,263** and **Rs 27,423 per agent per month**.)

**What this means for Rektrs**
- **(a) Internal use:** Community (MIT) self-hosted is fully legal in production, unlimited agents, zero licence cost — forever. We simply may not switch on the `enterprise/` features. The two we would actually miss are **SLA policies** and **Captain** — and Captain duplicates our own AI (below), so the real loss is SLA + SAML SSO + branding removal.
- **(b) Offering it to SaaS tenants:** MIT core may be offered commercially, even as a paid hosted service — the licence permits it. One Chatwoot installation can serve many tenants as separate **accounts**, provisioned via the core **Platform API** — no per-tenant installs needed. The trap is the enterprise tier: reselling/bundling enterprise features requires a valid per-seat subscription for the *correct number of seats* under Chatwoot's terms — i.e. a pass-through cost of $19–99/agent/month that we cannot legally absorb or hide, and branding removal (the thing a white-label SaaS most wants) is precisely one of the gated items. Tenant-facing offer = **Community feature set only**, unless a tenant's seat fees are passed through transparently.

## What it adds that Sendqon does not have

Sendqon core today is a **messaging platform with a basic conversation inbox**: channels, campaigns, contacts, a conversation list with replies, and our plugins around it. It has no support-desk discipline. Chatwoot Community adds, all in MIT core:

- **Inbox quality:** unified conversation view across channels with private notes, mentions, conversation statuses (open/resolved/pending/snoozed), priorities, labels, custom attributes, per-conversation context panels — a different class from Sendqon's message list.
- **Teams & assignment:** teams, inbox-level assignment policies, **round-robin auto-assignment**, agent availability — Sendqon has nothing equivalent for human agents.
- **Canned responses + macros:** one-keystroke replies and multi-action macros (assign + label + reply in one click).
- **CSAT:** post-resolution satisfaction surveys with reporting (112 core code paths).
- **Automation rules:** trigger/condition/action rules on conversations and messages (core model) — overlaps conceptually with Sendqon's flows but aimed at desk triage, not channel bots.
- **Reporting:** agent/inbox/label/CSAT reports and live dashboards.
- **Help centre:** public knowledge-base portals (articles, categories, locales) — note this is a *published help site*, different from our internal KB-grounding store.
- **Working hours / out-of-office, pre-chat forms, campaigns** on the widget.

What it does **not** add: sending power. Its WhatsApp = Meta Cloud API / Twilio / 360dialog; its SMS = Twilio. Our SIM-gateway SMS, our Baileys WhatsApp bridge, our Telegram/Email companions and the whole tenant/plan/credit machinery stay Sendqon-only. Chatwoot would sit **above** Sendqon, never replace it.

## Overlap analysis — Captain AI vs our `ai_agents` plugin

Our plugin is **live and proven**: on 2026-11-26 it answered real WhatsApp messages from the Rektrs KB (25 chunks, Gemini embeddings after PR-007), in Roman Urdu as well as English, passed a no-invention price trap, and goes silent when a human takes over (the conversation-11 lesson: a human reply marks the conversation human-owned until a state reset).

| | Captain AI (enterprise) | Our `ai_agents` (own, live) |
|---|---|---|
| Grounding | Help-centre articles + past conversations | Our KB plugin (any tenant KB), embeddings via our provider row |
| LLM | OpenAI GPT models (self-hosted: your own OpenAI key) | Our AiGateway — Gemini today, provider-agnostic by design |
| Where it answers | Inside Chatwoot inboxes only | Inside Sendqon conversations, on **our** channels (SIM SMS, own WA bridge, vendor WA) |
| Extras | Copilot suggestions, summaries, memories, triage, FAQ-gap detection, scenarios | Handover state machine, quiet hours, plan-flag gating, our credit model |
| Cost | $19/agent/mo licence + Captain credits ($20/1k overage) | Our own provider cost; no licence |

**Collision:** both want to be the first responder on the same conversation. Running both on one inbox guarantees double replies or split-brain handover. **Rule if they ever coexist: one brain per inbox.**
**Complement:** Captain's genuinely missing-from-us pieces are *agent-side* (Copilot drafts, summaries) — nice, not load-bearing. Our agent's genuinely missing-from-Captain pieces are the ones that matter commercially: it answers on **Pakistani SIM SMS and our own WhatsApp numbers**, inside the tenant/plan system our customers already pay for. Captain cannot do that at any price, because it only speaks to Chatwoot's own provider channels.

**Handover story (maps cleanly):** our agent already implements the exact state machine Chatwoot expects from a bot. Chatwoot core has a first-class **Agent Bot** concept: a bot attached to an inbox receives message webhooks, replies through the API, and hands over by flipping the conversation to open + assigning a human/team (bot then stops receiving the thread). Our `handed_over` state is the same transition seen from the other side. In a linked setup, our plugin would register as the Agent Bot endpoint for the bridged inboxes: it answers while in bot mode; the moment a human replies in Chatwoot (or the agent escalates), the conversation is assigned in Chatwoot and our plugin's existing human-takeover silence applies in Sendqon. One state machine, two front-ends, **Sendqon remains the source of truth for delivery**; Chatwoot is the source of truth for human assignment.

## Integration routes compared

### Route 1 — Standalone app in the Rektrs family (recommended first step)
Chatwoot Community on its own subdomain (e.g. `desk.rektrs.com`), own Docker stack, linked from the Launchpad like the other family apps; Rektrs' own support runs on it first.
- **SSO reality (docs-verified limit):** SAML SSO is **enterprise-gated** and generic OIDC/Keycloak sign-in is not a documented Community feature — Community means Chatwoot's own user database (Platform API can pre-provision the accounts so users never see a signup form; password login remains). Full Rektrs ID SSO would need either the Enterprise tier or a small auth-proxy project — **docs silent** on any supported Community OIDC path, so treat SSO as phase-2, not a launch blocker for internal use.
- **Effort:** low (see lanes). **Data flow:** none with Sendqon at first — its own channels (a support@ mailbox, the website widget) only. **Conversation owner:** Chatwoot, for the conversations that start there.

### Route 2 — Sendqon plugin (embed/link)
A Sendqon plugin adding a "Support Desk" item that links out to (or iframes) the Route-1 instance, optionally passing the tenant identity.
- **Effort:** smallest of the three (a link tile is trivial; a real iframe embed fights CSP/`X-Frame-Options` and session cookies and buys little). **Data flow:** none — it is a doorway, not an integration. **Conversation owner:** unchanged (whoever Route 1/3 decided). Verdict: do the link version as part of Route 1's polish; never sell it as "integration".

### Route 3 — API-linked coexistence (the real Sendqon integration, phase 2)
Sendqon's channels feed Chatwoot inboxes; humans work in Chatwoot; replies travel back through Sendqon for delivery.
- **Mechanism (verified in core + API reference):** Chatwoot's **API channel** — an inbox with a callback URL. Inbound: Sendqon creates contacts/conversations/messages via the Application API (`POST /api/v1/accounts/{id}/…`, `api_access_token` auth). Outbound: agent replies in Chatwoot fire a POST to the callback URL, and Sendqon delivers via the tenant's real channel (device SIM, WA bridge, Telegram companion…). Assignment/status changes return via account webhooks. Our `ai_agents` can sit in front as the Agent Bot (above) so AI-first + human-handover works across both systems.
- **Effort:** the real project (bridge plugin + identity/contact mapping + status sync + battery). **Data flow:** every bridged conversation exists in **both** systems — contact identity, message ids and status must be mapped and kept in sync; delivery truth stays in Sendqon, assignment truth in Chatwoot. **Conversation owner:** shared — which is precisely the cost. Tenants would get a genuine Zendesk-grade desk on top of the channels they already rent.

## White-label / branding position

Nuanced, and it matters for Rektrs' white-label stance:
- **In the MIT code:** `config/installation_config.yml` defines `INSTALLATION_NAME`, `LOGO`, `LOGO_DARK`, `LOGO_THUMBNAIL`, `BRAND_NAME`, `BRAND_URL`, widget colour and similar — the *fields* are core.
- **But:** the same file's header states premium config values "get overwritten unless the user is on a premium plan", `disable_branding` (removing Chatwoot branding, e.g. the widget's "Powered by") is a **premium feature flag**, and Chatwoot's own self-hosted pricing page sells **"custom branding" as a Premium Support ($19/agent/mo) feature**. Practical reading: on a free Community install you can set a name/logo in the super-admin and it will largely show, but branding *removal* and guaranteed persistence of custom branding across upgrades are **paid-tier territory** — do not promise tenants a fully white-labelled desk on Community. (Exact enforcement behaviour per version is a verify-at-install item; the licence/pricing position above is what the vendor publishes.)
- **Consequence:** for Rektrs' own internal desk, Community branding is a non-issue. For a tenant-facing white-label promise, budget the Premium pass-through or keep the desk visibly "powered by" the platform.

## Stack / ops fit

- **Footprint:** the shipped `docker-compose.production.yaml` runs **four services**: Rails (Puma, port 3000), Sidekiq, **Postgres 16 (pgvector image)**, Redis — plus S3-compatible or local storage for attachments. Vendor guidance for production is **minimum 4 GB RAM / 2 CPU** (their deployment docs, via vendor/secondary sources checked 2026-11-28). Realistic resident use at our internal volume: roughly 2.5–4 GB across the stack.
- **Fit on our estate:** offbox-1 (2 OCPU / 12 GB) already carries Sendqon + companions + ServerKit — Chatwoot Community fits for **internal** volume, but it is a second full database-backed stack to back up, upgrade monthly and watch; it should get its own ServerKit app + backup entry from day one, and tenant-scale volume would push it to the VPS or its own instance. No PHP/Laravel overlap — a separate Ruby toolchain to maintain (we have none today; Docker images make this a pull-and-pin discipline, not a Ruby-dev commitment).
- **Upgrade reality:** monthly minor releases (below) mean a standing monthly upgrade lane with the usual backup → pin → verify discipline, same as Sendqon/Postiz.

## Maintenance health

Very healthy. **Latest release v4.20.2, published 2026-11-28 (today)**; the recent line runs v4.17.0 (2026-08-20) → v4.18.0 (2026-09-18) → v4.19.0 (2026-10-20) → v4.20.0 (2026-11-18) → v4.20.2 — a steady **monthly minor + patch** cadence. **225 commits in the last 30 days**, last push 2026-11-28, 393 contributors (GitHub API). Open issues (1,653) are high in absolute terms but normal for a 40k-star consumer-facing product; the project is a company-backed open-core business (Chatwoot Inc.), not a hobby repo — the flip side being that the roadmap serves their cloud/enterprise funnel first, as the Captain/SLA gating shows.

## Effort estimate (lane-sized, our usual discipline)

- **Lane 1 — Standalone Community deploy:** ServerKit app on offbox-1 (compose pinned to a version tag, Caddy route `desk.rektrs.com`, Postgres/Redis inside the stack, backup script entry, Kuma monitor). Includes super-admin hardening + first account/team/inbox (support mailbox + website widget). *1 lane.*
- **Lane 2 — Family fit-out:** installation name/logo config, Launchpad tile, Rektrs support team onboarding (agents, canned responses, working hours), Sendqon link-tile plugin (Route 2 lite). *1 lane.*
- **Lane 3 — API-channel bridge (Route 3 core):** Sendqon plugin `support_desk_bridge` — WA + SMS conversations mirrored into Chatwoot API inboxes, Chatwoot replies delivered back through Sendqon channels, contact/message-id mapping store, DEV battery incl. two-tenant isolation. *2–3 lanes.*
- **Lane 4 — AI handover wiring:** register `ai_agents` as the Agent Bot for bridged inboxes; handover state sync both ways (human reply in either system silences the bot); battery on the real Rektrs WhatsApp number. *1–2 lanes.*
- **Later / gated:** tenant rollout via Platform API provisioning (per-tenant Chatwoot account from Sendqon signup) — only after the owner's pricing decision on whether the desk is a plan feature; SSO via Rektrs ID — only with Enterprise tier or a separate auth project (owner decision, spend involved).

## Verdict

**GO — Route 1 (standalone Community) now; WATCHLIST → phase-2 for Route 3; NO-GO on enterprise licen
...[truncated 307 chars]