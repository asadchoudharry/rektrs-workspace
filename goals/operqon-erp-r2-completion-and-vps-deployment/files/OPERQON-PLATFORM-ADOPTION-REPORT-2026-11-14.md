# Operqon Platform Adoption Report — One Panel, Adopted Parts, Our Core

**Date:** 2026-11-14 · **Status:** Muse's consolidated report (merges `SERVERKIT-ADOPTION-PLAN-2026-11-14.md` + `OPEN-SOURCE-LEVERAGE-FINDINGS-2026-11-14.md`, with all previously pending verifications completed — see §8). **Decision pending** the three-way comparison with ChatGPT and Gemini, who received the matching consolidated prompt.

**The owner's requirements this design is built to satisfy, verbatim in substance:** adoption must not load the current working project · every needed feature must arrive · handling must be easy · future SaaS platforms must integrate with it · **management from one place.**

---

## 1. The target architecture in one view

```
                        ┌─────────────────────────────────────────────┐
   Staff (one login) ──▶│  SERVERKIT PANEL  (dedicated mgmt host)     │
   via Keycloak OIDC    │  Operqon theme · Caddy edge · the one home  │
                        │                                             │
                        │  ├─ ServerKit core: servers, Docker, proxy, │
                        │  │   backups, monitoring, fleet agents      │
                        │  ├─ OPERQON EXTENSION (our code, face only):│
                        │  │   tenants · approvals · billing views ·  │
                        │  │   pricing · provisioning · issues inbox  │
                        │  └─ Links/widgets to adopted services ↓     │
                        └──────┬──────────────────┬───────────────────┘
                               │ API (brain)      │ SSO / links / APIs
                        ┌──────▼───────────┐  ┌───▼──────────────────────┐
                        │ OUR PROVIDER API │  │ ADOPTED SERVICES (own    │
                        │ + PostgreSQL     │  │ containers, mgmt host):  │
                        │ (UNCHANGED —     │  │ Kill Bill · Flagsmith ·  │
                        │ billing, SoD     │  │ SigNoz · Apprise/Novu ·  │
                        │ approvals,       │  │ Postal · Uptime Kuma ·   │
                        │ pricing, audit)  │  │ BookStack · Superset ·   │
                        └──────┬───────────┘  │ Gotenberg · Pluton       │
                               │ provisioning   └──────────────────────────┘
                        ┌──────▼───────────────────────────────────────┐
   Tenants ────────────▶│ FRAPPE/ERPNEXT BENCHES (tenant hosts)        │
                        │ ERPNext + app pack: HRMS · Helpdesk · CRM ·  │
                        │ Insights · XPOS · pakistan_tax · Payments…   │
                        │ Agent on host = MONITOR level (telemetry     │
                        │ only, cannot be commanded)                   │
                        └──────────────────────────────────────────────┘
   Future products (School ERP+LMS, Rektrs Social, RAG, SMS) join the same
   panel as managed servers/apps + their own extensions — §5.
```

**The three-layer rule that makes everything else work:** ServerKit is the *building* (infrastructure + shell), adopted services are *furniture* (each does one job, in its own container, replaceable), and our provider API remains the *business* (money, governance, truth). Nothing adopted ever holds our governed data or rules.

## 2. The adoption register — what, why, where, and what it replaces

### 2.1 Management home

| Need | Adopt | Licence | Why this one | Runs where | Replaces |
|---|---|---|---|---|---|
| Single panel for servers + fleet | **ServerKit**, tracked upstream, **not forked** | MIT | Only candidate with OIDC SSO, multi-server agents, Docker-native model, a real extension platform, and per-server Caddy proxy stacks | Dedicated management host (never a tenant host) | Building server/scaling/VPS surfaces of our Super Admin list (~15 of the 45 features) |
| Operqon business UI inside the panel | **Our own ServerKit extension** (Shape A: face only) | Ours | Official extension system: hot-loaded backend, runtime-delivered frontend, own expendable tables; our API stays the brain | Inside the panel | The separate console frontend as staff's daily home (it stays live as fallback during migration) |
| Branding | ServerKit **themes** (server-side, incl. login) + favicon | — | Colours are real white-label; name/logo are browser-local only (verified) — accepted for a staff-only panel; thin fork patch is a later optional gate | Panel settings | Any custom shell work |

### 2.2 Business services (behind our API, never in front of it)

| Need | Adopt | Licence | Why | Integration | Replaces |
|---|---|---|---|---|---|
| Subscription billing engine | **Kill Bill** (after a fit spike, §6) | Apache-2.0 | Only permissive, production-proven engine; plans/trials/proration/dunning + records manual payments (fits bank-transfer verification) | Java sidecar, REST + webhooks; our API calls it; our SoD approvals stay in front of it | Building the billing engine (the largest single build in the blueprint) |
| Invoice/document PDFs | **Gotenberg** (+ WeasyPrint in-API) | MIT / BSD-3 | Chromium-fidelity HTML→PDF as a Docker API | Sidecar / library | All provider PDF plumbing (incl. GAP-08 portal invoice PDFs) |
| Revenue analytics | **Apache Superset** | Apache-2.0 | MRR/seat/dunning dashboards read-only on provider PostgreSQL | Sidecar, linked from panel | Building an analytics UI |
| Feature flags & rollout | **Flagsmith** | BSD-3 | Mature self-hosted flags, segments, % rollouts, Python/JS SDKs | Sidecar + SDKs in our services | The flag service, entire |
| Notification delivery | **Apprise** (library) | BSD-2 | 100+ channels (email/SMS/chat/webhooks) in one Python library | Embedded in provider API/worker | Every per-channel sender |
| Notification templates (optional, phase-later) | **Novu** | MIT (core; enterprise carve-out — §8) | Template/workflow management if hand-templating outgrows us | Sidecar | Template admin UI, if needed |
| Transactional mail server | **Postal** | MIT (§8) | Own sending MTA with delivery tracking, behind Apprise/Novu | Sidecar on mgmt host | Dependence on third-party SMTP for platform mail |
| Uptime + public status page | **Uptime Kuma** | MIT | Monitors + status pages in one tiny container | Sidecar behind Caddy; alert webhooks into our console/Apprise | Uptime/status build |
| Docs & help centre | **BookStack** | MIT | Books/shelves KB for tenants + internal runbooks; **built-in Keycloak OIDC** | Sidecar | Docs platform build |
| Backup management UI | **Pluton** | Apache-2.0 | Wraps our existing restic→B2 (imports existing repos) | Sidecar | Hand-rolled restic scheduling/restore scripts' UI |
| Workflow glue / ops pipelines | **Activepieces** (glue) + **Kestra** (pipelines) | MIT / Apache-2.0 | Webhook automations; YAML-in-git jobs incl. backup-verification runs | Sidecars | n8n-class glue (n8n itself is source-available — rejected) and cron-and-bash pipelines |
| Observability | **SigNoz** | MIT (core; ee/ carve-out) | One OTel-native metrics+logs+traces stack; avoids Grafana/Loki AGPL | Sidecar stack; agents/collectors per host | Separate metrics/logs builds |
| Immutable-audit hardening | **Hash-chained Postgres + B2 Object Lock export** (our thin design; Trillian as the scale-up option) | Apache-2.0 (Trillian) | No turnkey permissive product exists (immudb is BSL — rejected) | Inside our API + scheduled export | Nothing planned — this *adds* the tamper-evidence our audit needs |

### 2.3 Tenant tier (baked into the bench image via our existing pinned pipeline)

| App | Licence | Gives tenants | Notes |
|---|---|---|---|
| ERPNext (already) | GPL-3.0 | The ERP itself | — |
| **HRMS** | GPL-3.0 | HR, attendance, leave, payroll engine | `version-16` releases in lockstep with our ERPNext (16.53.2, 2026-11-11) |
| **Helpdesk** | AGPL-3.0 | Tenant's own support desk (portal, SLA, KB) | AGPL discipline §4 of the leverage findings: vanilla or publish patches |
| **CRM** | AGPL-3.0 | Modern CRM replacing legacy ERPNext CRM | v15/v16 supported |
| **Insights** | AGPL-3.0 | Self-serve BI dashboards | Resource governance on shared benches |
| **Print Designer** | AGPL-3.0 | Drag-and-drop print formats (invoice polish) | v16 install confirmed in pilot |
| **LMS** | AGPL-3.0 | Courses/training | On-demand per tenant |
| **Payments** | MIT | Stripe/Razorpay/PayPal-class gateways for tenants | No PK gateways (gap stays ours) |
| **Builder / Wiki** | MIT | Low-code pages / documentation | Builder v16 check in pilot |
| **XPOS** (kodlyft) | MIT | Modern offline-first POS, built *for* v16 | Single maintainer — pin branch, pilot with one retail tenant |
| **pakistan_tax** (SpotLedger) | MIT | FBR Digital Invoicing + native tax config (sales tax, further tax, 236G, WHT) | Brand-new (0 stars) — **FBR sandbox pilot before any tenant promise** |

### 2.4 What we still build ourselves (deliberately short)

1. **The Operqon extension** (face over our API) — §2.1.
2. **Thin Pakistan gateway clients** (Easypaisa/JazzCash/PayFast) in Python, ported from the MIT reference projects pk-pay/pak-pay — no production SDK exists anywhere (verified, incl. Hyperswitch having zero PK connectors).
3. **Issues inbox** — bound to our provisioning jobs; no external product fits.
4. **Coupons/promotions glue** — Kill Bill paywalls them (paid add-on); our small layer on top.
5. **Pakistan payroll configuration** (tax slabs, EOBI/SESSI) on HRMS — no maintained localisation exists.
6. **Governance layer (already built, stays):** maker–checker approvals, pricing proposals, audit — in our API, untouched by all of the above.

## 3. Feature coverage — nothing falls through

Mapping the Super Admin inventory (45 features + 18 blueprint screens + 14 workflows) and the wider blueprint onto the architecture:

- **ServerKit core covers:** Servers & Scaling (6), VPS & Services (5), Managed VPS (6), most of Benches/Backups/Domains surfaces, Command's live monitoring — roughly **20 features** we no longer build as pages.
- **The extension covers:** Tenants (6), the business half of Platform (billing views, pricing review, gateway settings *cards* — secrets stay in our API's encrypted store), Issues inbox, provisioning oversight — roughly **14 pages + dashboard widgets**.
- **Adopted services cover:** billing engine, PDFs, analytics (MRR cockpit SCR-135 via Superset), flags/canary (SCR-139), status page, docs, notifications, observability, backup UI.
- **Already ours and unchanged:** the 14 governed workflows (onboarding, payment verification SoD, provisioning failure resolution, pricing governance, subscription lifecycle, deploy/rollback discipline, backup/restore, identity ops via Keycloak) — the panel gives them a home; their enforcement never moves.
- **Named gaps (accepted, with owners):** coupons (small build), PK gateways (thin clients), PK payroll (configuration work), FBR invoicing (pilot-gated). No other blueprint item is left uncovered.

## 4. Load-protection — how adoption never burdens the current project

These are rules, not intentions:

1. **Additive only.** Every adopted component arrives as its own container/service on the management host (or its own host). The live console, portal, provider API and benches are **not modified** by any adoption step; migration of staff usage is by links and SSO first, page-by-page later, with the existing console as fallback throughout.
2. **Tenant hosts are touched exactly twice, both gated:** (a) a **Monitor-level** agent (telemetry out only; cannot receive commands; level changeable only on the box as root) — installed only after the replica pilot's 15-item checklist passes; (b) tenant apps enter only through the **existing pinned image pipeline** at build time (version-16 branches, digest-pinned, rollback images retained) — the same governed swap discipline already in force, never a panel action.
3. **One owner per host.** ServerKit never co-manages a host with Dokploy or our Caddy (its own docs call dual config-writers never-supported). Proxy stacks are never enabled on bench hosts; the panel is never hosted on a bench host (its cleanup/prune actions are host-destructive to foreign containers — code-verified).
4. **Resource budgets.** Each sidecar gets CPU/RAM limits on the management host; the panel's own disk growth (DB + update snapshots) is quota'd and alerted (authors document ~11 MB/day DB growth).
5. **Every step is reversible.** Containers + open-format data (Postgres, restic repos, git-kept `serverkit.yaml`/compose) mean any single adoption can be switched off without touching the rest; our exit from ServerKit itself is rated low–moderate (workloads keep serving with the panel stopped).
6. **Change-managed, not ad-hoc.** Panel updates pinned to reviewed release tags (the updater otherwise self-refreshes from upstream `main` — we mirror), extension installs are deploys, agent updates are governed events.

## 5. Future SaaS platforms — integration by design

- **Rektrs School ERP + LMS** (Laravel/React/PostgreSQL RLS): the cleanest fit — ServerKit git deploy + `serverkit.yaml` manifests (web/worker/postgres/redis, env wiring, backup schedules) take the deploy role Dokploy was planned for; when its own admin needs arise, they follow the **same extension pattern** (face over its own API). One staff login, same panel.
- **Rektrs Social (Postiz):** Dokploy stays owner of its shared host; a Monitor agent gives the panel fleet visibility today; migration is a later planned window, host by host, never dual-managed.
- **RAG service / SMS-phone services:** ServerKit's template catalogue is AI-heavy (vector DBs, LLM gateways) and small services fit git deploy — they onboard as managed apps with agents at Monitor.
- **IQRS:** shared hosting, no agent surface — out of scope by nature, unaffected.
- **The pattern that generalises:** every future product = (its own API/brain) + (agents at Monitor on its hosts) + (optionally its extension face in the one panel). Management stays in one place **without** merging products into each other's data or governance — the panel unifies *operations and staff experience*, not products.

## 6. Phases (gated; each gate is evidence, not time)

- **Phase 0 — Replica pilot.** Throwaway VPS + replica bench: ServerKit 15-item safety checklist (refusal battery under Monitor+Observed, bench image swap **and rollback** under observation, panel self-update with bench untouched, cleanup/prune canary, project-name collision drill, proxy tripwire, disk soak, kill-switch). Plus fit spikes: Kill Bill vs our subscription model; pakistan_tax vs FBR sandbox; XPOS with a retail dataset; Print Designer/Builder v16 installs. **Gate: all pass or the item is dropped, not forced.**
- **Phase 1 — The home stands up.** Management host: ServerKit + theme + Keycloak OIDC + mirror repo + B2 panel backup/restore drill. Small sidecars: Apprise, Uptime Kuma, BookStack, Pluton. Monitor agents on Operqon VPS + Postiz host (Observed). Existing console/portal untouched; staff reach everything by one login and links.
- **Phase 2 — Extension MVP.** Read-only Tenants + overview widgets + the single W2 payment-verification write path with its SoD acceptance test (same-user approve must fail with our API's rejection; proper pair succeeds into our `audit_events`). Prerequisite: cryptographic validation of panel JWT by our API (JWKS) verified in the pilot.
- **Phase 3 — Business depth.** Kill Bill behind our API (if the spike passed), Gotenberg PDFs (closes GAP-08), Superset analytics, Flagsmith, SigNoz, Postal, Activepieces/Kestra pipelines. Extension phase 2: Issues inbox, pricing-proposal UI, provisioning console.
- **Phase 4 — Tenant app pack rollout.** HRMS + Payments + Wiki into the standard image; Helpdesk/CRM/Insights under AGPL discipline; XPOS and pakistan_tax per-tenant after their pilots.
- **Phase 5 — Fleet & future products.** School ERP+LMS deploys onto ServerKit; RAG/SMS onboard; Postiz migration window decided; optional thin-fork branding patch decided on evidence from Phases 1–4.

## 7. Conditions and red lines (condensed from the adoption plan)

Dedicated panel host behind Caddy with staff-only reachability · tenant hosts Monitor+Observed only, Full banned there · Keycloak for all staff (panel roles are panel-local — Keycloak groups do not propagate; viewer default; admin = two named people; developer treated as sudoers-equivalent) · extensions first-party/ours only, signed, change-managed · API keys always scoped + expiring · provider audit stays in our `audit_events` (panel audit is convenience, shipped off-box) · nothing that moves money or changes pricing is ever a panel action without dual control in our layer · updates pinned/mirrored, monthly cadence.

**Red lines:** Full agents as default on tenant hosts · third-party marketplace extensions on production · panel on a tenant host or publicly open · SoD logic moved into the panel · ServerKit's audit as sole record.

## 8. Verification appendix — the previously pending items, now closed (2026-11-14)

| Item | Result |
|---|---|
| Novu licence | **MIT for the open-source core** (`LICENSE-MIT` in repo root) with an enterprise carve-out (`LICENSE-ENTERPRISE`, `enterprise/`) — same shape as Chatwoot/SigNoz. Cleared with carve-out |
| Postal licence | **MIT** (repo file `MIT-LICENCE`, Krystal Hosting). Cleared |
| Chatwoot licence (full text) | **MIT Expat for everything outside `enterprise/`** (that dir under its own licence). Cleared with carve-out |
| OneUptime licence (full text) | **Apache-2.0 outside `ee/`** (ee under OneUptime Enterprise License). Cleared with carve-out; still optional (heavy, overlaps SigNoz+Kuma) |
| Lane B activity evidence | Latest commits: Apprise **2026-11-14**, Uptime Kuma **2026-11-13**, Gatus **2026-11-12**, Chatwoot **2026-11-13**, Novu **2026-11-13**, OneUptime **2026-11-14** — all actively maintained. Postal **2026-10-01** — active, slower cadence |
| BookStack cadence | Latest commit **2026-11-02**; release-driven project — active. Cleared |
| Appsmith OIDC tier | **Resolved — against adoption as a Keycloak citizen:** free self-hosted Appsmith includes Google/GitHub sign-in only; **OIDC/SAML SSO is its paid Enterprise tier**. Appsmith is therefore **removed from the register**; internal dashboards are built as extension pages + Superset instead (both already in the architecture, both under our one login) |
| Still pilot-gated (not paper items) | Print Designer + Builder v16 installs · pakistan_tax vs FBR sandbox · extension JWT validation (JWKS) · Kill Bill fit spike |

## 9. Decisions reserved for the three-way faisla

1. Adopt this consolidated architecture (ServerKit home + extension + register above) — yes/no/amend.
2. Management host: new small dedicated VPS (recommended) vs an existing non-tenant host.
3. Kill Bill: commit after the Phase 0 spike, or keep billing fully ours?
4. AGPL discipline for tenant apps (vanilla-or-publish) — accepted as policy?
5. Dokploy end-state per host (recommended: Operqon VPS → ServerKit; Postiz host → Dokploy until its migration window).
