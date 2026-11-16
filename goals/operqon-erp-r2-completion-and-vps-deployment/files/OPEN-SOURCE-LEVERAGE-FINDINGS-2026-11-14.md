# Open-Source Leverage Findings — Operqon Blueprint

**Date:** 2026-11-14 · **Status:** Muse's research (4 parallel lanes). Companion to `SERVERKIT-ADOPTION-PLAN-2026-11-14.md`; the final decision combines these findings with the ChatGPT and Gemini reports from the shared prompts.
**Method:** every licence below was read from the project's own LICENSE file in its repo on 2026-11-14; activity = latest default-branch commit unless noted. **One caveat:** the GitHub connector hit a rate limit (HTTP 429) during the support/comms lane — maintenance evidence for that lane's candidates and the licence/activity checks for Novu, Postal and Chatwoot could not be completed and are marked UNVERIFIED. They are a named re-verification list in §6, not silent gaps.

---

## 1. The headline: what adopting instead of building saves us

Ranked by work removed from our blueprint:

| # | Adopt | Licence | What it cancels or shrinks in our build plan |
|---|---|---|---|
| 1 | **Frappe app pack for tenants** — HRMS, Helpdesk, CRM, Insights, LMS, Print Designer (official) + Payments, Builder, Wiki (MIT) + **XPOS** (MIT POS) + **pakistan_tax** (MIT, FBR) | GPL / AGPL / MIT (see §4) | Months of tenant-side feature work: HR+payroll suite, support desk, modern CRM, BI, print polish, a v16-native POS, and Pakistan FBR digital invoicing. All exist, all maintained, most with `version-16` branches in lockstep with our ERPNext |
| 2 | **Kill Bill** (sidecar) | Apache-2.0 | The subscription billing engine: plan catalog, trials, proration, invoicing, payment retries, dunning/overdue states, multi-tenancy — and it records external/manual payments, which fits our bank-transfer verification flow exactly |
| 3 | **Flagsmith** | BSD-3 | Our feature-flag service + rollout tooling, entire |
| 4 | **SigNoz** (or Prometheus + Perses + VictoriaLogs) | MIT (Apache for the alt stack) | Separate metrics/logs/traces builds; also dissolves the Grafana/Loki AGPL question |
| 5 | **Appsmith** | Apache-2.0 | Hand-built internal admin dashboards over the provider DB/APIs — the biggest internal-tooling saver (one UNVERIFIED: whether Keycloak OIDC is in the free self-hosted tier) |
| 6 | **Apprise** (library) | BSD-2 | Every per-channel notification sender (email/SMS/chat/webhooks, 100+ endpoints) — embeds in our Python services |
| 7 | **Uptime Kuma** | MIT | Uptime monitoring **and** the public status page, one container |
| 8 | **Gotenberg + WeasyPrint** | MIT / BSD-3 | All provider-side PDF generation (portal invoices, receipts, statements) |
| 9 | **Apache Superset** | Apache-2.0 | Revenue/MRR/seat/dunning dashboards — read-only against provider PostgreSQL |
| 10 | **BookStack** | MIT | Tenant help centre + internal runbooks, with built-in Keycloak OIDC |
| 11 | **Activepieces / Kestra** | MIT / Apache-2.0 | Webhook glue automations (Activepieces) and cron-grade ops pipelines incl. backup-verification runs (Kestra) |
| 12 | **Pluton** | Apache-2.0 | A management UI over our existing restic→B2 backups (imports existing repos) |

## 2. Per-area findings (condensed)

**Billing & money (Lane A).** Kill Bill is the only permissively-licensed, production-proven billing engine (operating since 2010, commit 2026-11-12); it is Java — a REST sidecar, never embedded — and coupons/prepaid credits are **not** in its open-source core (paid "Aviate" add-ons), so promotions stay a small build of ours or ERPNext's tenant-facing coupon doctypes. **Pakistan gateways: no production-grade maintained SDK exists.** pk-pay (MIT, JazzCash+Easypaisa, author states it was never run against live merchant credentials) and pak-pay (MIT, Laravel; its PayFast driver is a stub that throws) are **reference implementations only** — they encode the fiddly signing/callback logic (JazzCash HMAC-SHA256 `pp_SecureHash`, Easypaisa hosted flow) that we port into our own thin Python clients. Hyperswitch was checked directly: **zero** Easypaisa/JazzCash connectors. Rejected: Invoice Ninja (Elastic License 2.0 — source-available), Lago and Flexprice (AGPL-3.0), Metabase (AGPL/commercial dual — Superset covers it), UniBee (AGPL + stale).

**Support & communications (Lane B).** Licence-clean wins: **Apprise** (delivery) and **Uptime Kuma or Gatus** (monitoring + status — pick one). The helpdesk shelf is uniformly AGPL — **Frappe Helpdesk, FreeScout, Zammad all verified AGPL-3.0** — so tenant helpdesk becomes the §4 discipline question (for Frappe Helpdesk the answer is favourable: it's a tenant-side app). listmonk is AGPL and campaign-oriented anyway. Our in-console **Issues inbox has no external replacement** — it is bound to our provisioning jobs; it stays a small custom build. Notification *templating/orchestration* is the open slot: **Novu** is the candidate but its licence + activity are UNVERIFIED (rate limit); Postal (mail server) and Chatwoot (live chat; split licence, full text unread) are likewise pending — §6.

**Platform infrastructure (Lane C).** Flags: **Flagsmith (BSD)** first, GrowthBook (MIT) if experimentation is ever needed, flagd (Apache) for git-driven infra flags. Observability: **SigNoz (MIT)** as one OTel-native stack, or the Apache stack (Prometheus + Perses dashboards + VictoriaMetrics/VictoriaLogs). Workflow: **Activepieces (MIT)** for glue, **Kestra (Apache)** for YAML-in-git ops pipelines, Node-RED for ad-hoc fan-out. Docs: **BookStack (MIT, OIDC built in)**. Backups: **Pluton (Apache)** over restic; Backrest is the more mature restic UI but GPL-3.0 with a cooling cadence — a conscious either/or. Immutable audit: **no turnkey permissive product exists** — the credible paths are Trillian (Apache substrate) or our own thin design (append-only hash-chained Postgres + scheduled export to B2 with Object Lock). Rejected on licence despite popularity: **n8n** (Sustainable Use License — not open source), **immudb** (BSL), **Graylog** (SSPL), **Outline** (BSL), **Flipt** (Fair Core), Unleash (relicensed to AGPL — Flagsmith makes it unnecessary), ToolJet/Wiki.js (AGPL with permissive alternatives above).

**Frappe ecosystem (Lane D).** Detailed table in the lane report; the load-bearing rows: **HRMS** (GPL-3.0; `version-16` release 16.53.2 on 2026-11-11 — lockstep with our ERPNext), **Helpdesk** (AGPL; maintained v16 branch), **CRM** (AGPL; v15/v16), **Insights** (AGPL), **Print Designer** (AGPL; v16 install to confirm in pilot), **LMS** (AGPL), **Webshop** (GPL; slower cadence), **Payments / Builder / Wiki** (MIT), **XPOS by kodlyft** (MIT; *requires* Frappe/ERPNext v16; release 2.13.4 on 2026-11-10; single maintainer — pin the branch, pilot with one retail tenant), **pakistan_tax by SpotLedger** (MIT; FBR Digital Invoicing + native sales-tax/further-tax/236G/withholding config that deliberately doesn't override ERPNext's tax engine; hard-requires v16; **brand-new, 0 stars, single vendor — FBR sandbox pilot before any tenant promise**). Rejected: POS Awesome (famous, but last push 2024-08 — a v14/v15 codebase), ParaLogicTech erpnext_pk (stale 2022), FBR-Pakistan repo (**no licence at all** — legally unusable), Frappe Drive (archived).

## 3. Honest gaps — where nothing adoptable exists

- **Pakistan payment gateway SDKs** (provider-side): reference code only; we write thin Python clients for Easypaisa/JazzCash/PayFast ourselves. This was already our assumption for BL-EP-013; now it is evidence-based.
- **Pakistan payroll localisation** (income-tax slabs, EOBI/SESSI): nothing maintained exists in the Frappe ecosystem. HRMS gives the payroll engine; PK specifics remain per-tenant configuration/build work.
- **Coupons/promotions** in a permissive billing engine: Kill Bill paywalls them. Small build on our side.
- **Production-grade permissive form builder:** none found. Use Frappe's built-in Web Forms; Formbricks only under an explicit AGPL sign-off if survey-grade forms become a product need.
- **Turnkey immutable audit:** none permissive. Trillian substrate or hash-chained Postgres + B2 Object Lock (both cheap; the design is ours either way).

## 4. The GPL/AGPL question, settled for our architecture

Our provider platform (billing, provisioning, console, pricing) is a **separate codebase on separate infrastructure** talking to tenant ERPNext instances over HTTPS APIs. No GPL/AGPL code is linked into it, imported by it, or shares a process with it — copyleft obligations attach inside the tenant tier, where we hold no IP to protect.

- **GPL apps (ERPNext, HRMS, Webshop):** obligations trigger on *distribution*, not network use; tenants using hosted software in a browser is not distribution, and we run our image on our own servers. Adoptable outright. (If on-prem/self-hosted tenants are ever offered, that *is* distribution: ship licence texts + source links with the image — a checklist item, easily satisfied.)
- **AGPL apps (Helpdesk, CRM, Insights, LMS, Print Designer):** §13 adds: modify one and offer it over a network → offer the modified source. Manageable discipline, not a prohibition: **run AGPL apps vanilla; tenant tailoring via configuration/fixtures in our own separate app; if we ever patch one, publish the patched fork.** Adoptable with that discipline.
- **MIT apps (Payments, Builder, Wiki, XPOS, pakistan_tax):** no copyleft friction at all.
- **Rule for our own code:** tenant-side glue lives in our own app via the framework's public extension points (the framework itself is MIT); the crown jewels never enter the tenant tier, so even the industry's grey-zone readings cost us nothing material. (Engineering analysis, not legal advice.)

## 5. Sequencing (what to adopt first, and what each adoption cancels)

1. **Tenant app pack into the bench image pipeline** (HRMS + Payments + Wiki first — zero licence friction or lockstep-official; then Helpdesk/CRM/Insights under the AGPL discipline; XPOS + pakistan_tax behind pilots). Cancels: tenant-side HR/helpdesk/CRM/POS/FBR build items.
2. **Apprise + Uptime Kuma + BookStack** — three small containers/libraries, immediate. Cancels: notification senders, uptime/status build, docs platform.
3. **Flagsmith.** Cancels the flag service before we build it.
4. **Kill Bill evaluation spike** against our subscription model (seats, overage, manual-payment recording, dunning) before committing the billing build to it. Shrinks: billing engine to Kill Bill + our governance layer (approvals/pricing stay ours regardless).
5. **SigNoz + Superset** when observability/analytics demand lands. **Appsmith** after its OIDC tier check.
6. **Our own thin PK gateway clients** (from pk-pay/pak-pay references) — unchanged from plan, now evidence-backed.

## 6. Pending verification (rate-limit casualties — re-check before deciding on these)

- **Novu** — licence + activity (notification templating candidate).
- **Postal** — licence + activity (transactional mail server candidate).
- **Chatwoot** — full licence text incl. enterprise carve-out (live-chat candidate); **OneUptime** — full licence text.
- **Lane B maintenance evidence** generally (last-release/commit dates for Apprise, Uptime Kuma, Gatus) — licences are verified; activity is not.
- **Appsmith** — Keycloak OIDC availability in the free self-hosted tier. **BookStack** — release cadence.
- **Print Designer / Builder** — v16 install confirmation (pilot item). **pakistan_tax** — FBR sandbox behaviour (pilot item).
