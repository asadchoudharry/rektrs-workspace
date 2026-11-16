# Operqon Adoption Board — Report & Decisions

**Date:** 2026-11-14 · **Board:** Chair (Chief Architect) + six specialist seats (Security & Governance; Single-Server Load & Ops; Frappe/Tenant-Tier; Money & Billing; Future SaaS & Ecosystem; Red-Team Critic)
**Charter:** `ADOPTION-BOARD-TORS-2026-11-14.md` · **Sources judged:** Muse consolidated report (`OPERQON-PLATFORM-ADOPTION-REPORT-2026-11-14.md`), Gemini report, ChatGPT report (both verbatim in `external-reports/`), evidence logs `SERVERKIT-ADOPTION-PLAN-2026-11-14.md` + `OPEN-SOURCE-LEVERAGE-FINDINGS-2026-11-14.md`.
**Status:** Board recommendations to the owner. The Board recommends; the owner decides. Advisory only — nothing in this report authorises a deploy, purchase, or server change.
**Estimates:** every resource figure in this report is an **ESTIMATE** (labelled EST) based on vendor-published minimums, typical self-hosted footprints for the stack class, or analogues already running in our stack — no live measurement was available to the Board. Phase 0 replaces estimates with a 7-day measured baseline before any money moves.

---

## 1. Executive decision summary

**The single-server constraint (§0) changes the verdict on almost everything.** All three source reports were written assuming the panel and sidecars could live somewhere else. Under §0 they cannot. The Board's Load seat established the fact the whole report turns on:

> **The folded current stack — provider platform + benches + Postiz, counted as §0 requires — already peaks at ≈9.5 GB EST against a 5.6 GB peak budget (70% rule) on today's KVM 2-class plan (~8 GB RAM).** Idle alone (≈5.7 GB EST) consumes the entire peak budget. Folding Postiz onto today's plan without first executing the KVM 4 step is a scheduled out-of-memory incident, and the Load seat has **vetoed** it.

Everything else follows from that arithmetic plus the governance non-negotiables (maker–checker SoD, governed pricing, provider `audit_events` as the only authoritative audit, the one-login rule — no component whose free tier gates SSO).

### Decision counts (58 decision rows, §2)

| Decision | Count |
|---|---|
| ADOPT | 4 |
| ADOPT WITH CONDITIONS | 19 |
| PILOT FIRST | 9 |
| DEFER (named trigger) | 15 |
| REJECT | 11 (one row groups 12 licence/fit rejects, enumerated in §7) |

### The five decisions that matter most

1. **KVM 4 upgrade is a precondition, not an optimisation.** Step 1 (KVM 2-class → KVM 4-class, ~16 GB) fires on the §0 decision itself, executed only through the written snapshot → upgrade → verify procedure (§5), after the Phase 0 survival gates pass. Nothing except the zero-rent light pack boards before it.
2. **ServerKit is adopted — contained, pilot-gated, and demoted.** Pilot in Phase 0 (throwaway, sacrificial project, 15-item checklist). Production only from Phase 1, **inside a VM guest (Incus/KVM) on the one host with its own dockerd, socket and disk quota** — the Security seat vetoed the panel sharing a Docker daemon/socket with benches and Postiz, and that veto stands over the lighter compose-only containment. The host agent runs **Monitor-only**, the panel in **Observed mode**, Docker Cleanup/prune is locked out on this host, and ProxyStack is never enabled (host Caddy stays sole owner of ports 80/443). If the pilot cannot prove the VM containment design, the panel is automatically DEFERRED to the §0 split trigger. The extension is a **face only**: read-only + widgets in Phase 2; its single write path unlocks only in Phase 2b after JWKS validation of panel JWTs, the SoD acceptance test, and the audit-hardening gate all pass.
3. **Kill Bill is OUT — deferred, no spike.** Three seats argued DEFER / PILOT-shadow / KILL. The Chair rules **DEFER with trigger** on the Money seat's evidence: judged against live invoicing that already works, Kill Bill answers no live question (its fit is not in doubt; its blockers are), it charges the **second-largest continuous rent in the folded stack (≈1.5 GB idle / 2.6 GB peak EST, a second JVM) for the least frequent workload on the box**, and it does not close the coupon gap (coupon codes are Aviate, USD $9,999/mo paid annually — §6, settlement c). What our own billing still owes is priced at **~25–38 dev-days at zero new rent** (§2, row D1). Re-entry is PILOT FIRST, shadow-only, only at the §0 split trigger OR a metered product OR catalogue complexity (annual + multi-currency + self-serve volume), under the Security seat's conditions.
4. **Observability: SigNoz is REJECTED on two independent grounds** — vendor-verified SSO gating (SAML/OIDC are Enterprise Self-Hosted only; §6, settlement g) and ClickHouse weight (2.5–4.0 GB idle / 4.0–6.5 GB peak EST, 20–80 GB disk at 7-day retention). The adopted shape is the light one: **Beszel + Dozzle now** (combined ≈0.06–0.10 GB EST; doubles as the Phase 0 measurement tool), the **Apache stack (Prometheus + VictoriaLogs + Perses) at KVM 4** if measured headroom allows. Traces are an accepted gap. Two observability shapes never run at once.
5. **Whole-server survival precedes every adoption (Phase 0 gates).** One box is one point of failure, so before any production adoption: (i) whole-server restic → B2 inventory with a **timed restore drill into isolation** (including one Frappe site + the provider DB); (ii) the **audit-hardening build** (hash-chained Postgres audit + B2 Object Lock) **and a passed DBA-attack simulation** — until that simulation passes, no Board document may call our audit "immutable"; the correct words are "append-only by application design; tamper-evidence hardening in build" (ChatGPT's challenge on this point was fair — §6); (iii) the KVM upgrade + rollback procedure written; (iv) the §0 trigger metrics defined and reporting (§5.3).

### What the Board struck hardest

The three reports' combined register **as a package is dead**: the candidate sidecars' minimums sum to roughly 20–30 GB before benches, Postiz, or the provider platform — on a box whose folded current peak is already ≈9.5 GB EST. The surviving architecture is deliberately boring: the provider API + PostgreSQL stays the brain, the panel becomes a contained face, and almost every "platform" the reports proposed is replaced by a library, an in-bench Frappe app, or work inside processes we already pay for. §7 lists everything removed, with reasons.

### One recommended exception to §0, flagged for the owner's faisla

**Uptime Kuma is adopted hosted OFF the one server** (external free-tier instance or B2-hosted static fallback). A status page on the box it monitors reports nothing during the only outage that matters — including the KVM upgrade window itself. This is the Board's single deliberate exception to the one-server rule; an on-box, degraded Kuma is the alternative if the owner declines it.

---

## 2. Per-component decision table (TOR §5 format)

Rent = idle / peak RAM EST unless stated. "Owner" = owner of the condition, not of the component.

### 2.1 ADOPT

| # | Component | Need & reasoning (better-and-easier / painful-and-complex) | Rent (EST) | Phase | Evidence trail | Conditions (owner) |
|---|---|---|---|---|---|---|
| A1 | **Apprise** (notification library, embedded) | Need: one notification fan-out for provider events (payment verified, provisioning done/failed, alerts). Better-and-easier: a library inside processes we already run — replaces hand-rolled per-channel senders; the substrate the SMS adoption (C17) and all alerting build on. | 0.03 / 0.08 GB | 0 | All three reports converge; Load seat: "the single cheapest adoption in the register." | Embedded library only; the optional standalone sidecar needs its own row before use (Load). |
| A2 | **restic → B2 whole-server backup discipline** | Need: §0(d) — one box is one point of failure; panel DB, provider DB, benches, Postiz, Keycloak, all config. Better-and-easier: already our tool; what's adopted is the *discipline* — full inventory, schedule, and a timed restore drill into isolation as a Phase 0 gate. | ~0 runtime; B2 storage cost only | 0 (gate) | Red-Team Condition 0; Load Condition 4; TOR §6.8. | Restore drill timed and filed before any production adoption; re-drilled after each KVM step (Red Team / Load). Pluton (D7) is a UI over this, never a substitute. |
| A3 | **Frappe v16 built-in Print Format Editor** | Need: tenant print formats. Better-and-easier: it is already in the stack — it is what replaces the archived Print Designer (R3). Zero install, zero rent, no AGPL question. | 0 (in-bench) | 0; used by tenant pack in Phase 4 | Print Designer README banner (Chair-verified, §6-b): "use the Print Format Editor built into Frappe from version 16." | Tenant-facing guidance updated so nobody goes looking for Print Designer (Frappe seat). |
| A4 | **External SMTP relay** as the transactional-mail target | Need: reliable transactional email (invoices, OTP-adjacent notices, alerts) without making the tenant-serving IP a mail-sending IP. Better-and-easier: ~zero rent, no mail server to run; the convergent end-state of all three reports once Postal's placement is judged under §0. | ~0 | 1 | Gemini's position; Load §2 (Postal); Security (Postal DEFER). | SPF/DKIM/DMARC configured and verified before first production send (Load). Self-hosted Postal is D6, not this row. |

### 2.2 ADOPT WITH CONDITIONS

| # | Component | Need & reasoning | Rent (EST) | Phase | Evidence trail | Conditions (owner) |
|---|---|---|---|---|---|---|
| C1 | **ServerKit panel** | Need: one staff operations home — host, containers, benches, Postiz — instead of SSH + Dokploy + ad-hoc checks. Painful-and-complex risks are real and priced: its Docker Cleanup deletes foreign stopped containers and `prune -a` would delete retained bench/Postiz rollback images; its DB grows ~11 MB/day and update snapshots can reach ~9.6 GB. Adopted *because* containment (below) removes the destructive reach, not because the risk was small. | 0.5 / 0.8 GB + **hard 20 GB disk quota, snapshots pruned to last 2**; VM guest adds ~0.5 GB guest-OS overhead | Pilot 0; production 1 | Claude ServerKit plan (5 lanes, code-verified) + Load ledger + Security vetoes V2/V5 + Red Team 4 gates. | (1) Production **only inside a VM guest (Incus/KVM) with own dockerd/socket/disk quota**; if the Phase 0 pilot cannot prove this, panel DEFERs to split trigger automatically (Security). (2) Pilot first: 15-item replica checklist incl. **prune canary** on a sacrificial project, JWKS proof, written containment design, panel restore drill (Red Team). (3) Pinned/mirrored update tags; updater never free-runs from upstream main (Security). (4) Staff realm + MFA; panel admin = two named people; API keys scoped + expiring, runbook filed (Security). (5) ProxyStack **never** enabled; mem cap 1 GB / CPU cap 1.0 (Load). (6) Audit shipping off-box; panel logs never replace `audit_events` (Security V4). |
| C2 | **ServerKit agent** (host) | Need: the panel's eyes on the host. Painful if mis-levelled: agent permission levels are enforced agent-side, and an install omitting `--level` defaults to Full — a standing footgun the Board designs out. | Included in C1 | 1 | Claude ServerKit plan (levels enforced agent-side); Security V5. | **Monitor level only + panel Observed mode** on every workload — benches, Postiz, provider. Protect/Full vetoed; installs must pass `--level` explicitly; any remotely-promotable agent vetoed (Security V5). `inspect` can expose bench env secrets: named accounts only + written acceptance before first use (Security). |
| C3 | **ServerKit extension** (Operqon face) | Need: staff work (tenants, billing, approvals) presented in the panel home instead of a separate console. Better-and-easier **only** as a face: extension permissions are consent-not-enforcement and purge-on-uninstall drops extension tables, so tenants/billing/approvals/pricing/audit truth **never** move into it — the provider API stays the brain. | ~0 (static React served by the panel) | 2 read-only; 2b write path | Claude ServerKit plan (Shape A: face only); Security V1 + conditions; Red Team shrink argument. | Read-only + widgets in Phase 2. The single write path (W2) unlocks in Phase 2b only after: **JWKS validation of panel JWT proven**, the **SoD acceptance test passed verbatim**, and the **audit-hardening gate (C10) passed** (Security). The old console remains the fallback until 90 days of clean panel operation — the soak governs retiring the console, not enabling W2 (Chair ruling, §6). |
| C4 | **Beszel + Dozzle** | Need: host/container health and container logs from day 1 — and the measurement instrument for the Phase 0 baseline. Better-and-easier: two small Go binaries; genuinely negligible rent. | 0.06 / 0.10 GB | 0 | Load observability ruling (lightest shape by an order of magnitude); Gemini trio's two light members. | Read posture only — no Docker-socket mutation rights (Load). Behind OAuth2 Proxy / Keycloak like every staff surface (Security). |
| C5 | **Apache observability stack** — Prometheus + VictoriaLogs + Perses | Need: durable metrics + searchable log retention + dashboards once KVM 4 headroom exists. Better-and-easier than SigNoz at ~⅓–⅕ the rent and all-Apache licencing; VictoriaLogs avoids a second heavy log database. | 0.65 / 1.30 GB; disk 8–18 GB at set retentions | 2 (KVM 4, headroom-gated; slips to KVM 8 step if measurement says so) | Load §3 ruling; ChatGPT's Apache-stack proposal. | Retention hard-set in Compose (metrics 15 d, logs 7–14 d) — retention is a disk-budget decision made in the file, not later (Load). **Never run alongside GlitchTip as a second shape** (Load veto 7). |
| C6 | **Gotenberg** (document rendering) | Need: Chromium-grade PDF rendering for invoices/documents beyond WeasyPrint's ceiling. Painful if uncapped: each conversion spikes ~0.9 GB — an uncapped renderer is a tenant-OOM weapon. | 0.25 / 0.90 GB transient | 0 | Leverage findings (Gotenberg/WeasyPrint); Load §2. | Boards **only** hard-capped: `mem_limit` ≈768 MB, CPU limit, **concurrency = 1** queued by the provider API; no outbound fetch (Load / Security). WeasyPrint stays the default engine; Gotenberg is the escalation path (D8). |
| C7 | **Uptime Kuma — hosted OFF the one server** | Need: external uptime truth + the status page that must survive the box, including during the KVM upgrade window. The Board's single recommended exception to §0 (§1). | 0.15 / 0.25 GB (off-box) | 0 | Load §2 (placement caveat decisive); ChatGPT also required an independent location. | Primary instance off-box (external free tier or B2-hosted static fallback carries maintenance notices + all-clear). On-box-only Kuma is not acceptable (Load). Owner faisla flags this exception explicitly. |
| C8 | **OAuth2 Proxy** | Need: Keycloak in front of light sidecars that lack native OIDC (Beszel/Dozzle-class tools) so the one-login rule holds without per-tool passwords. Better-and-easier: a 0.02 GB Go binary is the cheapest SSO glue in the register. | 0.02 / 0.04 GB | 0 | Security conditions; Load §1.2. | Upstream reachable **only** via the proxy; identity headers stripped at Caddy; the protected app's own login disabled — if any leg fails, the pair fails the one-login test and does not board (Security). |
| C9 | **BookStack** (runbooks / internal KB) | Need: a real home for ops runbooks (this report's procedures included) that non-technical staff can edit. Better-and-easier: the cleanest SSO citizen in the register (built-in Keycloak OIDC) and MIT. Until it boards, runbooks live in git. | 0.55 / 0.90 GB incl. its own MariaDB | 2 (after Flagsmith in the KVM 4 queue; slips to KVM 8 if measured headroom says so) | Leverage findings (MIT, active 2026-11-02); Security ADOPT; Load ordering. | Own MariaDB (cannot share the bench MariaDB); capped like every boarder (Load). Tenant-facing docs do **not** live here — tenant Wiki is C14 (Frappe seat). |
| C10 | **Hash-chained audit + B2 Object Lock** (build, not buy) | Need: `audit_events` is the authoritative record for SoD and payment verification; it must become tamper-evident against a DBA-level attacker, not merely append-only by convention. Better-and-easier as a build inside the provider DB we already govern. | ~0 marginal (in provider PG) + B2 storage | 0 (gate) | Security Ruling 1.5; ChatGPT's UNVERIFIED challenge upheld (§6). | Build = INSERT/SELECT-only app role, append-only trigger, per-event hash chain, signed WORM checkpoints to B2 Object Lock under separate credentials, off-box verifier, pgaudit (Security). **Phase 0 gate: a DBA-attack simulation must pass**; until then the word "immutable" is withdrawn from all documents (Chair). Trillian REJECTED, Tessera DEFERRED (R8/D11). |
| C11 | **ERPNext HRMS** (tenant tier) | Need: HR/payroll is core school/business demand. Better-and-easier: official Frappe app, enters via the existing pinned image pipeline, no new platform. | In-bench marginal | 4 | Frappe seat; leverage findings (lockstep v16). | Base image inclusion; **payroll gated on the PK localisation pack (C15)** — HRMS without PK slabs does not ship as "payroll ready" (Frappe seat). |
| C12 | **Frappe Helpdesk** (tenant tier) | Need: tenants serving *their own* customers. Better-and-easier in-bench at marginal rent vs Chatwoot's 10× (see D5 and the §6.5 support ruling). | In-bench marginal ≈0.15–0.30 GB | 4 | Frappe seat; Load §2 (Chatwoot comparison). | Optional per-tenant pack, not base image. AGPL **vanilla-or-publish** discipline — no silent modifications (Frappe seat / TOR §4). |
| C13 | **Frappe Payments** (tenant tier) | Need: tenants' own payment collection plumbing. Better-and-easier: official app in the pinned pipeline. Does **not** close the PK gateway gap — that is C16 (Money seat). | In-bench marginal | 4 | Frappe seat. | Per-gateway sandbox → live gates per tenant; tenant credentials stay the tenant's (service-provider principle) (Frappe seat). |
| C14 | **Frappe Wiki** (tenant tier) | Need: tenant-facing docs/help inside the tenant's own bench. | In-bench marginal | 4 | Frappe seat; leverage findings (MIT). | Base image. Explicitly distinct from provider KB (C9) — a tenant's wiki is the tenant's data (Frappe seat). |
| C15 | **PK payroll config pack** (build our own, over vanilla HRMS) | Need: Pakistani payroll (effective-dated slabs, WHT) — no verified off-the-shelf PK payroll exists in any report. Better-and-easier as configuration over vanilla HRMS rather than a fork. | 0 | 4 | Frappe seat ruling. | Effective-dated slab config; validated by a PK payroll expert; **one full parallel-run cycle** against manual payroll before any tenant relies on it (Frappe seat). |
| C16 | **PK payment-gateway thin clients** (build: Easypaisa / PayFast) | Need: card/wallet payment collection — today the only missing automation in an otherwise working billing flow (manual bank transfer + SoD verification works and stays as fallback). No production PK gateway SDK exists (pk-pay/pak-pay are reference-only; Hyperswitch has zero PK connectors) — own thin clients are confirmed as the only route. | 0 new rent (inside provider worker) | 3 | Leverage findings; Money seat (reference-only confirmed); gateway webhooks + reconciliation priced inside the owed-work list, row D1. | Merchant credentials are the tenants'/ours entered via governed config — never in code; sandbox → live gate per gateway (Money). Manual verification path is **not** removed when gateways land (Money). |
| C17 | **SMS gateway integration via Apprise** | Need: SMS is a real channel for PK schools/businesses (fee reminders, OTP-adjacent notices); our phone-as-API proof already passed end-to-end on SMS Gate. Better-and-easier: rides A1's substrate — no new platform (Novu is D4). | ~0 (via C16/A1 processes) | 3 | Future seat ADOPT WITH CONDITIONS; MEMORY (SMS Gate proof 2026-11-13). | Credentials in Secure Vault only; sends to tenants' own recipient lists under tenant credentials/pricing (Future seat). |
| C18 | **Dokploy retained for Postiz scope + collision rules P-1…P-8** | Need: the Postiz end-state ruling (TOR §6.7). Dokploy stays **sole Docker owner for the Postiz scope**; ServerKit observes Postiz, never reconciles it — one manager per scope, adapted to one host. The 2026-11-14 incident (staging `.env` carrying production's `COMPOSE_PROJECT_NAME`, recreating the prod container) is designed out, not remembered out. | Already counted in the folded ledger | 1 (at fold-in) | Future seat (P-1…P-8); Postiz incident record 2026-11-14. | Rules P-1…P-8 adopted verbatim: central project-name registry (prefixes `postiz-`/`operqon-`/`bench-`/`ops-`/`school-`/`rag-`/`sms-`); explicit `COMPOSE_PROJECT_NAME` mandatory everywhere; **no flagless `docker compose up`**; pre-flight project filter; pinned immutable tags (Future seat). Full migration of Postiz off Dokploy is D15. |
| C19 | **Future-product onboarding pattern** | Need: School ERP+LMS, RAG, and later products join *operations* without joining *governance*. Better-and-easier: one pattern — own API/DB per product, one host Monitor agent, optional extension face — instead of a bespoke integration per product. | 0 (pattern) | 2 (School spec authored as portable `serverkit.yaml` now; deployer pilot deferred to split) | Future seat ADOPT WITH CONDITIONS; ChatGPT's registration contract adopted **with amendments**. | Per-product OIDC **client in the single staff realm** — Gemini's per-product realm is rejected (§6). Provider DB holds only an optional commercial link per product; product data and governance never enter provider tables (Future seat). Dokploy for the School product is rejected; plain compose is its deploy truth (Future seat). |

---

### 2.3 PILOT FIRST

Per TOR §2, anything unverified on paper pilots — it is never adopted. Every pilot below is time-boxed, on synthetic or volunteer-tenant data, with its pass gate named in advance.

| # | Component | Need & reasoning | Rent (EST) | Phase | Evidence trail | Pilot gate / conditions (owner) |
|---|---|---|---|---|---|---|
| P1 | **Flagsmith** (feature flags) | Need: canary rollouts for provider + extension changes. Promising but its free-tier OIDC/SSO position is **UNVERIFIED** — and TOR §4 forbids adopting a component whose free tier gates SSO. | 0.6 / 1.0 GB (own PG) | Pilot 2 → decision 3 | Leverage findings (BSD); Security ADOPT-with-flag; Red Team DEFER (first canary must prove config flags insufficient). | Gate 0: free-tier OIDC **evidenced in the pilot build** or automatic REJECT under Security veto V3. Gate 1: a real canary that plain config flags demonstrably cannot do (Red Team). First in the KVM 4 queue after the light pack (Load). |
| P2 | **Frappe CRM** | Need: tenant CRM demand. Blocker is evidence, not desire: coexistence with ERPNext's built-in CRM on v16 is unproven. | In-bench marginal | 4 | Frappe seat PILOT FIRST. | Pilot on one bench: ERPNext-CRM coexistence test passes with no data-model collision (Frappe seat). |
| P3 | **Frappe Insights** | Need: tenant-side analytics. The gate is shared-host safety: ad-hoc queries run against the bench MariaDB that serves every tenant on the box. | In-bench marginal | 4 | Frappe seat PILOT FIRST. | Query governance proven under load on the shared MariaDB (timeouts, concurrency caps) before any tenant enablement (Frappe seat / Load). |
| P4 | **Frappe Builder** | Need: tenant page building. Unproven fit with our pinned-image + theme discipline. | In-bench marginal | 4 | Frappe seat PILOT FIRST. | Pilot tenant build reviewed against theme/token discipline; no per-tenant image divergence (Frappe seat). |
| P5 | **Frappe Webshop** | Need: tenant storefronts. v16 compatibility is **UNVERIFIED**. | In-bench marginal | 4 | Frappe seat PILOT FIRST. | Version-16 compatibility evidenced in the pilot, or it drops to DEFER (Frappe seat). |
| P6 | **XPOS** (tenant POS) | Need: a v16-native POS option in the tenant pack. Real but fragile: MIT-verified, stable version-16 release line exists (2.13.4), **but the `develop` branch is explicitly pre-v3 and "not a stable release"** (§6-e). | In-bench marginal | 4 | Chair verification (kodlyft/xpos, MIT © 2026 Ali Raza); Frappe seat PILOT FIRST; ChatGPT's caution accurate re `develop`. | Pinned stable release only — **`develop` branch banned**. Pass gates: offline → sync integrity, kill-recovery mid-transaction, ESC/POS hardware proof, one volunteer retail tenant (Frappe seat). |
| P7 | **pakistan_tax** (FBR invoicing) — bake-off candidate 1 | Need: FBR Digital Invoicing for PK tenants — a genuine differentiator. The repo **exists** (Chair-verified: `ehsen/pakistan_tax`, MIT © 2026 SpotLedger, hard-requires Frappe/ERPNext v16) but is young (created 2026-07-22, 0 stars) — existence is settled, maturity is not. | In-bench marginal | 4 | Chair GitHub read (§6-a); Muse lane's substance right, org path wrong; Gemini/ChatGPT searched the wrong path. | One FBR bake-off against P8 in the FBR **sandbox**; no production tenant until sandbox → production evidence + one volunteer tenant (Frappe seat). Zero stars is a bus-factor fact, priced into the gate — not a veto (TOR §4: no decisions on star counts; the gate is evidence, not popularity). |
| P8 | **kodlyft/di** (FBR invoicing) — bake-off candidate 2 | Need: same FBR need as P7; a second, independent implementation (FBR PRAL DI API v1.12 + POS fiscal). MIT-verified (© 2026 Kodlyft). | In-bench marginal | 4 | Chair GitHub read (§6-f); ChatGPT's claim verified in full. | Pre-check first: it **requires Python ≥3.14** + Frappe ≥16, install branch `version-16` — bench Python version decides eligibility before any pilot effort (Frappe seat). Same bake-off gates as P7. |
| P9 | **RAG service** (pgvector-first) | Need: retrieval over product docs/support corpora for future AI features. No named consumer exists today — so it pilots behind a consumer gate, not on spec. | 0.3–0.5 GB | 3 | Future seat PILOT FIRST. | Gate: a **named consumer** (a specific product feature) must exist before the pilot starts; pgvector inside an existing PostgreSQL before any new vector store (Future seat). |

### 2.4 DEFER (with trigger)

A DEFER names its re-entry trigger and terms. Nothing here is "maybe later" — each row says exactly what re-opens it.

| # | Component | Need & reasoning (why not now) | Rent (EST) | Trigger & re-entry terms (owner) |
|---|---|---|---|---|
| D1 | **Kill Bill** (billing engine) | Need claimed: subscription state, proration, dunning, coupons. Judged against live facts it fails on need-truth *today*: our Python billing already invoices seats + overage under governed pricing and SoD; Kill Bill's remaining deltas are buildable in-process. Painful-and-complex: second JVM (GC CPU on a box with no spare core), OSGi/plugin surface for a Python team, a second billing truth to reconcile forever — and it does **not** close the coupon gap (coupons = Aviate, $9,999/mo; §6-c). Load veto: never on this box at KVM 2/4. | 1.5 / 2.6 GB + own DB | **Trigger:** §0 split trigger OR a metered product OR catalogue complexity (annual + multi-currency + self-serve volume). **Re-entry:** PILOT FIRST, shadow-only, heap-capped on KVM 8-class headroom, under Security conditions (a)–(d): no governed data held, no payment truth, provider API remains system of record, exit = data export proven. **Owed-if-ours (priced by Money seat, zero new rent):** dunning automation 5–8 d; narrow proration 3–5 d; coupons/promotions 4–6 d (**build-it-yourself on either path**); gateway webhooks + reconciliation 8–12 d (owed on every path — Kill Bill has no PK connectors); lifecycle hardening 3–4 d; invoice tax-line 2–3 d. **Total ≈25–38 dev-days.** Metering is **not** owed — no metered product exists. (Money seat owns this row.) |
| D2 | **Apache Superset** (BI) | Need: provider-level analytics. Not now: its dashboards run real queries against provider PostgreSQL — on KVM 4 its peak plus a dashboard fan-out lands directly on tenant-serving CPU. Interim substitute exists: SQL views + extension widgets. | 1.0–1.5 / 2.0–2.5 GB | **Trigger:** KVM 8 step executed **and** reporting need beyond extension widgets demonstrated. Re-entry under Security's conditions: bounded exported reporting dataset or read replica only, query timeout + concurrency limits, **never live DB fan-out** (Load / Security; Money seat's stricter split-trigger position recorded in §6). |
| D3 | **Activepieces** (automation glue) | Need: none named today. All three reports agree it must never touch billing/provisioning/approval paths — which removes most of its plausible work. Its own PG + Redis make it a second data tier, not a sidecar. | 0.8 / 1.5–2.0 GB | **Trigger:** a named, non-critical glue need **and** KVM 8 headroom. Re-entry under Security's conditions: allowlist enforced by scoped service identities; correlation IDs written into `audit_events` (Security / Load). Kestra is not the fallback — it is R2. |
| D4 | **Novu** (notification platform) | **TOR §6.6 ruling: ornament at current volume.** Three Node services + MongoDB (whose cache must be actively capped) to add template management on top of Apprise (A1), which boards for ~0.05 GB. Hand-templating is not today's bottleneck. | 1.4 / 2.4 GB + Mongo growth | **Trigger:** template count / notification volume threshold set at the Phase 3 review, measured — not felt. Revisit post-split if the threshold is never hit (Load veto 5 concurs). |
| D5 | **Chatwoot** (platform support) | Need: provider-tier support conversations for *our* tenants. The two-tier ruling (§4.4) keeps tenant-customer support in-bench (C12). For the platform tier, Chatwoot is the heaviest "sidecar" in the register — 10× the in-bench rent — with an **UNVERIFIED** SSO position (if OIDC sits in its enterprise tier, Security V3 makes it an automatic REJECT). Load veto: never co-resident under §0. | 1.2–1.8 / 2.5–3.5 GB | **Trigger:** KVM 8 measured headroom **and** platform support volume that the provider Issues inbox demonstrably cannot serve. **Re-entry:** PILOT FIRST with Gate 0 = SSO/licence trace of the exact build; synthetic tickets only; conversations only — governance actions hand off to the provider API (Security / Frappe seat conditions preserved as re-entry terms; Red Team's KILL recorded in §6). Interim: provider Issues inbox is the system of record. |
| D6 | **Postal** (self-hosted mail) | Need claimed: own mail server. Decisive beyond RAM: it makes the **tenant-serving IP a mail-sending IP** — one spam complaint, bounce storm, or blocklist event degrades the same IP that serves paying tenants; its spool is unbounded under failure; Hostinger's port-25 reality applies. Transactional mail is A4 (external relay). | 0.8–1.3 / 1.8 GB + MariaDB + RabbitMQ | **Trigger:** §0 split **and** a dedicated sending IP on a separate host. No re-entry on the tenant box at any plan step (Load veto 5). |
| D7 | **Pluton** (backup UI) | Two corrections killed the original claim: the free OSS edition is a **local backup UI only** — remote/agent backups are **PRO edition, commercial ($59/yr incl. 5 machines + $12/yr per extra)**, closed source (§6-d). What we need now is the restic discipline (A2), not a UI over it. | 0.15 / 0.30 GB (restore bursts 1.0+) | **Trigger:** KVM 4 headroom + a demonstrated freshness-dashboard need. Re-entry: free edition as a **local, read-only** freshness dashboard under Security's conditions; fleet authority is never Pluton's (Security / Red Team). The PRO pricing is noted so a future board doesn't re-discover it as "free". |
| D8 | **WeasyPrint** (second PDF engine) | One rendering engine is adopted (C6 as escalation; WeasyPrint remains the incumbent default in-process). Running two engines as co-equals doubles the surface for a problem not yet observed. | ~0.1–0.3 (in-worker library) | **Trigger:** Gotenberg demonstrably insufficient for a named document class (Load: pick one engine). |
| D9 | **pgBackRest** | Need: Postgres PITR. Not yet: restic + pg_dump discipline (A2) covers today's recovery objectives; a second backup system before the first is drilled is how neither works at 2 a.m. | ~0.05 GB | **Trigger:** a named PITR requirement (recovery-point objective the current drill cannot meet, measured in the drill) (Load). |
| D10 | **Gatus** (status pages) | A second uptime tool alongside C7 buys nothing; running both is how status pages disagree during an incident. | ~0.05–0.1 GB | **Trigger:** Uptime Kuma demonstrably insufficient for a named monitoring need (Load: don't run alongside Kuma). |
| D11 | **Tessera** (transparency log) | The audit need is met by C10's hash chain + B2 Object Lock. Tessera answers an external-witness scale question we do not have. | n/a (external witness class) | **Trigger:** a named external-verifiability requirement (e.g. a client/government audit demanding third-party witness) (Security). Trillian is R8 — not the fallback. |
| D12 | **Frappe LMS** | Need: tenant LMS demand is prospective (the School ERP+LMS is a separate product with its own stack decision, C19 — not a bench app rollout). | In-bench marginal | **Trigger:** a named tenant (or the School product's own board decision) requesting LMS on a bench (Frappe seat). |
| D13 | **GlitchTip** (error tracking) | The Gemini trio's heavy member (~90% of the trio's weight is GlitchTip: Django + worker + own PG + Redis). Error aggregation is a real future need; incident history does not prove it yet, and it must never arrive as a *second observability shape* beside C5. | ~0.5 / 1.05 GB marginal over C4 | **Trigger:** incident history proving error-tracking need. Re-entry: joins the Apache shape (C5) as a single addition, not a rival stack (Load §3). |
| D14 | **SkyWalking** (APM/traces) | Proposed as a SigNoz substitute; it is also JVM-class weight, and its SSO position is **UNVERIFIED**. Traces are an accepted gap (§3 ruling) — no named incident exists that metrics + logs could not diagnose. | JVM-class, ≈1.5+ GB | **Trigger:** paper SSO evidence produced **first**, plus KVM 8 / split headroom, plus a named diagnostic need. A re-proposal without the SSO paper does not reach the table (Security / Red Team / Load converge). |
| D15 | **Postiz full migration off Dokploy** | The end-state is C18 (Dokploy owns Postiz scope; ServerKit observes). A migration now would spend the scarcest resource — change windows on the one box — to solve a problem the scope ruling already solves. | n/a | **Trigger:** §0 split trigger, when Postiz gets its own host decision anyway (Future seat). |

### 2.5 REJECT

| # | Component | Why rejected (painful-and-complex / fails a rule) | Evidence trail |
|---|---|---|---|
| R1 | **SigNoz** | Two independent grounds, either sufficient. (1) **One-login rule:** SAML/OIDC are Enterprise Self-Hosted only; Community Edition offers Google Workspace OAuth only — vendor docs + Keycloak guide requiring licensed self-hosted (§6-g). A proxy + app password is not one login (Security V3). (2) **Weight:** ClickHouse stack 2.5–4.0 / 4.0–6.5 GB + 20–80 GB disk — its idle floor alone exceeds the entire KVM 4 adoption headroom; merges consume CPU/IO *between* incidents, exactly when tenants need the box (Load veto 2). | Chair vendor-doc verification; Load §3; ChatGPT's rejection reason confirmed. |
| R2 | **Kestra** | Third JVM (1.5–2.5 / 3.0+ GB) duplicating a capability our worker/cron already provides at zero marginal rent — and carrying **CVE-2026-49869, a CVSS 10.0 unauthenticated RCE on the CISA KEV list** (added 2026-09-02; fixed in 1.0.45/1.3.21). Duplication + rent + that CVE history ends the discussion under §0. | Chair verification (KEV); Gemini accurate; Load veto 4 (unconditional under §0). Fixed versions are recorded here so any *future* board starts from fact. |
| R3 | **Frappe Print Designer** | Archived by its own maintainers: README banner states the repo is archived and unmaintained and directs users to the v16 built-in Print Format Editor (A3). Adopting archived software into the tenant image pipeline is how benches rot. | Chair verification (§6-b). Gemini/ChatGPT right in substance. |
| R4 | **UniVenture `fbr_digital_invoicing`** (as an installable app) | Superseded predecessor lineage of pakistan_tax (P7's README names it among the apps pakistan_tax was rebuilt from). Installing the predecessor alongside its successor in one bake-off is noise. | Chair verification (§6-a bonus). **Reference-only**: its code may be read during the bake-off; it is not installed. |
| R5 | **POS Awesome** | Stale (2024) against a v16 bench; the POS need is served by the P6 pilot on a maintained, pinned release instead. | Leverage findings; Frappe seat concurs. |
| R6 | **Appsmith** | Its OIDC/SAML SSO is a **paid Enterprise tier** feature — free self-hosted offers Google/GitHub only. Fails TOR §4's rule directly. Internal dashboards are served by extension pages (C3) + the observability stack. | Leverage-findings re-verification (downgrade confirmed 2026-11-14). |
| R7 | **VortexPanel** | ChatGPT's correction is accepted — a plugin system **does** exist (§6-h) — and it changes nothing: no SSO (fails one-login), single-server design assumptions, and its MIT licence rests on README/description only with **no LICENSE file in the repo root** (Chair-verified). A panel candidate must beat ServerKit on evidence, not on a feature list. | Chair verification (§6-h). |
| R8 | **Trillian** (transparency log) | A full transparency-log platform to witness one Postgres audit table is disproportionate; C10's hash chain + B2 Object Lock + off-box verifier meets the need at ~zero rent. | Security ruling (Tessera D11 is the proportionate future option). |
| R9 | **procrastinate** (job queue) | Noise: a new queue library where the provider worker and Frappe RQ already exist. Every additional moving part must replace real planned work (TOR §3.1); this replaces nothing. | Money seat REJECT. |
| R10 | **Standalone provider-tier Frappe Helpdesk bench** | A second bench to serve *our* support would pay full bench rent for zero ERP context. The support ruling (§4.4) is **both, never swapped**: Helpdesk in-bench (C12) for tenants' customers; provider tier = Issues inbox (system of record) + Chatwoot only if D5's trigger ever fires. | Frappe seat ruling. |
| R11 | **Licence/fit register rejects (grouped)** | Each fails TOR §3.2 (licence cleanliness) or §3.1 (need truth) on the leverage findings' file-level evidence: **n8n** (SUL), **immudb** (BSL), **Graylog** (SSPL), **Outline** (BSL), **Flipt** (Fair Core), **Unleash** (AGPL relicense), **Invoice Ninja** (Elastic Licence; also fails Money's billing review), **Lago** (AGPL), **Flexprice** (AGPL), **UniBee** (AGPL), **Frappe Drive** (archived), **`FBR-Pakistan` repo** (no licence file = no right to use), **OneUptime** (heavy; overlaps C4/C5/C7 for no named gain). | Leverage findings licence trace; Money seat confirms the billing-side rejects. Full per-item reasons in §7. |

---

## 3. Single-server resource ledger (TOR §6.2)

**All figures ESTIMATE** (bases: vendor-published minimums, typical self-hosted Docker footprints, analogues in our stack). **Headroom rules (binding): peak budget = 70% of total RAM (≥30% free at peak); disk ≤70% used.** Verdicts are **cumulative** — judged against the folded baseline plus what already boarded, never against an empty box. Phase 0 replaces these estimates with a 7-day measured baseline (Beszel, C4); if measurement contradicts this ledger by >25% either way, the ledger is re-issued before money moves (Load Condition 1).

### 3.1 The box (ESTIMATE — confirm exact plan specs in hPanel before the owner signs any upgrade)

| Plan step | vCPU | RAM | Disk | Peak RAM budget (70%) | Disk budget (70%) |
|---|---|---|---|---|---|
| **Today — KVM 2-class** | 2 | ~8 GB | ~100 GB | **5.6 GB** | **70 GB** |
| Step 1 — KVM 4-class | 4 | ~16 GB | ~200 GB | **11.2 GB** | **140 GB** |
| Step 2 — KVM 8-class | 8 | ~32 GB | ~400 GB | **22.4 GB** | **280 GB** |

### 3.2 Folded current workload — the ledger as §0 requires it to be counted

Postiz today sits on a separate shared host (srv1322702). §0 abolishes that separation, so the honest baseline is the **folded** one:

| Workload | Idle (GB) | Peak (GB) | Disk (GB) |
|---|---|---|---|
| OS + Docker daemon + host services | 0.50 | 0.70 | 8–12 |
| Caddy (sole edge) | 0.04 | 0.06 | <0.1 |
| Provider API + worker | 0.35 | 0.65 | 1 |
| Provider PostgreSQL | 0.30 | 0.60 | 2–5, growing |
| Keycloak (JVM #1) | 0.90 | 1.40 | 1 |
| Console + portal (static) | ~0 | 0.02 | <0.5 |
| Bench — MariaDB | 0.70 | 1.10 | 8–15 (3 sites) |
| Bench — Redis (×3 roles) | 0.15 | 0.25 | <0.5 |
| Bench — web/frontend | 0.45 | 0.75 | in images |
| Bench — workers + scheduler | 0.85 | 1.40 | in images |
| Bench — socketio | 0.18 | 0.30 | in images |
| Docker images retained (incl. rollback digests) | — | — | 12–20 |
| Dokploy (Postiz manager) | 0.35 | 0.55 | 2–4 |
| Postiz app (Next.js) — runtime only; **on-host builds banned** (a build peaked ~3.5 GB and downed the Postiz host on 2026-11-13; builds stay on GitHub Actions → GHCR) | 0.60 | 1.10 | in images |
| Postiz PostgreSQL | 0.25 | 0.45 | 2–6, growing |
| Postiz Redis | 0.08 | 0.15 | <0.5 |
| **FOLDED CURRENT TOTAL** | **≈5.7** | **≈9.5** | **≈45–75** |

**Reading:** on today's plan the folded stack is **already over budget** — peak ≈9.5 GB vs 5.6 GB budget and vs ~8 GB physical (swap/OOM territory at coincident peak). On KVM 4-class it fits with only **≈1.7 GB peak headroom for all adoptions combined**. On KVM 8-class it fits comfortably (≈12.9 GB headroom). vCPU: the folded stack is already ~3.5× oversubscribed at coincident peak on 2 vCPU — normal for bursty web work, but it means any always-on CPU consumer (ClickHouse merges, JVM GC, Celery, Sidekiq) directly steals tenant latency. Postiz's own fold-in estimate is ~1.5–2.5 GB of the totals above; the Load seat must measure it during Phase 0.

### 3.3 What boards when (cumulative)

| Boards | Contents | Added peak (EST) | Cumulative peak vs budget |
|---|---|---|---|
| **Today's plan (Phase 0)** — Operqon host as it stands, Postiz **not** yet folded | Light zero-rent set: Apprise (A1), OAuth2 Proxy (C8), Beszel + Dozzle (C4), Gotenberg hard-capped (C6), Pluton-class restic discipline (A2); Uptime Kuma off-box (C7) costs the box nothing | Light pack total ≈1.2 idle / ≈2.3 peak unmanaged, **≈1.6 peak managed** (caps + Gotenberg concurrency = 1) | Fits only because Postiz is not yet folded; the fold is vetoed until Step 1 (Load veto 1) |
| **After Step 1 — KVM 4 (Phases 1–2)** | Postiz fold-in (C18) + ServerKit in VM guest (C1/C2, +~0.5 GB guest overhead) + Flagsmith pilot (P1) → Apache stack (C5) → BookStack (C9), **in that order, each re-checked against measured headroom** | Folded 9.5 + light ≈1.6–2.3 = **≈11.1–11.8 vs 11.2 budget — at the line** | The medium pack (Flagsmith + BookStack + Apache stack, ≈3.2 peak) **cannot all board on KVM 4** on top of the light pack. Order is binding (Load Condition 5): if measurement puts the cumulative peak over budget, the next item in the queue slips to the KVM 8 step automatically — it does not squeeze in |
| **After Step 2 — KVM 8 (Phase 5 re-judgement)** | Deferred items become *eligible for re-judgement* (Superset D2, Activepieces D3, Kill Bill re-entry pilot D1) — eligibility is not adoption | — | ≈12.9 GB headroom at fold-in baseline |
| **Never on this box under §0** | SigNoz (R1), Kestra (R2), Chatwoot (D5), Novu (D4), Postal (D6) — combined peak ≈5.5–8.3 GB for functions served in-bench (≈0.3 GB), in-library (≈0.05 GB), or by external relay (≈0 GB) | — | Load vetoes 2–5 |

**Boarding requirements for every component (Load Conditions 2–3):** resource caps in the Compose file itself (`mem_limit`, CPU limit, log rotation, disk quota + retention where applicable) — reviewed in the adoption PR, not added after the first incident; **prebuilt images only, nothing builds on this server, ever**.

---

## 4. Corrected target architecture under one server

### 4.1 Shape

```
                        ┌──────────────────── ONE SERVER (§0) ────────────────────┐
   Internet ──► Caddy (sole edge, 80/443)                                        │
                    ├─► Provider API + worker ──► Provider PostgreSQL            │
                    │        │  (BRAIN: tenants, billing, governed pricing,      │
                    │        │   maker–checker SoD, audit_events → C10 chain)    │
                    │        ├─► Apprise (A1) ──► SMS gateway (C17), channels    │
                    │        └─► Gotenberg (C6, capped, concurrency=1)           │
                    ├─► Keycloak (single staff realm; per-product OIDC clients)  │
                    ├─► ERPNext bench(es) — pinned image pipeline only           │
                    │        └─ tenant pack: HRMS, Helpdesk, Payments, Wiki (Ph 4) │
                    ├─► Postiz scope — Dokploy is SOLE Docker owner (C18)        │
                    │        ServerKit: Observe only. P-1…P-8 collision rules.   │
                    ├─► VM GUEST (Incus/KVM): ServerKit panel (C1)               │
                    │        own dockerd / socket / 20 GB disk quota             │
                    │        host agent: Monitor-only, panel Observed (C2)       │
                    │        extension: face only (C3)                           │
                    └─► Light sidecars, all capped, all behind Keycloak/OAuth2   │
                         Proxy (C8): Beszel+Dozzle (C4) → Prometheus+            │
                         VictoriaLogs+Perses (C5) → BookStack (C9)               │
                        └────────────────────────────────────────────────────────┘
   OFF-BOX: restic → B2 + Object Lock checkpoints (A2/C10) · Uptime Kuma (C7)
            · external SMTP relay (A4) · image builds (GitHub Actions → GHCR)
```

**Invariants (Security vetoes V1–V5, adopted as architecture law):** (V1) no governance — SoD, pricing, payment verification, entitlement truth, gateway secrets, authoritative audit — ever moves into the panel, extension, or any sidecar; (V2) the panel never shares a Docker daemon/socket with benches or Postiz; (V3) no staff surface whose free tier gates SSO; (V4) no sidecar or panel log replaces provider `audit_events`; (V5) no Protect/Full agent, no socket mount (including read-only), no remotely-promotable agent on tenant workloads.

### 4.2 Panel containment design (TOR §6.1 — the exact design)

1. **Boundary:** the panel runs inside a **VM guest (Incus/KVM)** on the host — its own kernel, its own dockerd, its own Docker socket, its own disk (hard **20 GB quota**). Nothing the panel or its Docker daemon can do reaches a bench or Postiz container; the guest is the blast-radius wall the Security seat required, and it is architectural, not procedural.
2. **Eyes, not hands:** the host-side agent runs at **Monitor** level with the panel in **Observed mode** for every workload class — Operqon benches, Postiz scope, provider services. Agent permission levels are enforced agent-side and cannot be raised from the panel. Installs must pass `--level` explicitly (an omitted flag defaults to Full — banned by runbook and by install-script review).
3. **Cleanup lockout:** ServerKit's Docker Cleanup / prune is **procedurally locked out on this host** and proven safe before production by the pilot's **prune canary** (a sacrificial Compose project must survive a cleanup run untouched). Rationale: cleanup deletes foreign stopped containers and `prune -a` would delete the retained bench/Postiz rollback images our deploy discipline depends on.
4. **Network/edge:** ProxyStack is **never** enabled — host Caddy remains the sole owner of ports 80/443. The panel is reached through Caddy + Keycloak like every staff surface.
5. **Disk behaviour:** panel DB growth is documented at ~11 MB/day and update snapshots can reach ~9.6 GB against an 800 MB DB — hence the 20 GB quota, **snapshots pruned to the last 2**, growth above the documented rate is an alert trigger (§5.2).
6. **Updates:** pinned/mirrored tags only. ServerKit's updater is fork-aware but self-refreshes its update script from upstream main and **silently discards core edits** — so updates are pinned to reviewed tags/mirror, never free-run (this is also why the Board tracks upstream rather than hard-forking: a fork is a permanent merge tax against a one-developer upstream shipping daily).
7. **Access:** staff realm + MFA; panel admin limited to **two named people**; API keys scoped with expiry, runbook filed; panel audit shipped off-box (and never mistaken for `audit_events`).
8. **Failure rule:** if the Phase 0 pilot cannot demonstrate items 1–3 on the replica checklist, the panel does not board — it DEFERs to the §0 split trigger automatically, and operations continue on the existing console + SSH discipline. The panel is a convenience; tenant safety is not negotiable for it.
9. **Known gap, accepted:** panel branding (White Label name/logo) is browser-local localStorage only — it does not brand the login screen. The panel is staff-only, so the gap is small; real login branding would need a thin-fork patch and is **not** authorised by this report.

### 4.3 Dokploy / Postiz end-state ruling (TOR §6.7)

**One manager per scope.** Dokploy remains the **sole Docker owner for the Postiz scope**; ServerKit's relationship to Postiz is **Observe-only — zero Docker write scope**. There is no second manager for the same containers, and no shared scope. The `COMPOSE_PROJECT_NAME` incident class is designed out by rules **P-1…P-8** (C18): central project-name registry with product prefixes; explicit `COMPOSE_PROJECT_NAME` mandatory in every project; no flagless `docker compose up` anywhere; pre-flight project filter before any compose action; pinned immutable image tags on every train (a 1–2 second "deploy" that pulls nothing is a known failure mode, already lived). A full migration of Postiz off Dokploy is DEFERRED to the split trigger (D15), when Postiz gets a host decision of its own.

**Scope note for the owner:** srv1322702 (the current Postiz host) also carries non-Postiz Dokploy workloads (website/Odoo-class). This Board's mandate covers Postiz only; retiring that host needs a separate owner ruling on the remaining workloads. The fold-in in Phase 1 moves the **Postiz stack only**.

### 4.4 Support ruling (TOR §6.5): both tiers, never swapped

- **Tenants' own customers** are served by **Frappe Helpdesk inside the tenant's bench** (C12) — it has the tenant's ERP context and costs marginal rent.
- **Our tenants (platform support)** are served by the **provider Issues inbox as system of record** today; Chatwoot may only ever join as a *conversations* layer if D5's trigger fires, and it hands every governance action (refunds, plan changes, verification) to the provider API.
- A standalone provider Helpdesk bench is REJECTED (R10): full bench rent, no ERP context.

### 4.5 Billing architecture (unchanged brain, owed work scheduled)

The provider API + PostgreSQL remains the billing system of record — seats, overage at the governed extra-seat rates (Starter/Growth Rs 500, Business Rs 1,000 per seat/month), whole-proposal pricing under SoD, manual bank-transfer verification as the human approval. Kill Bill's deferral (D1) comes **with the priced owed-work list (~25–38 dev-days)** so "build it ourselves" is a plan, not a slogan: dunning automation, narrow proration, coupons/promotions, gateway webhooks + reconciliation, lifecycle hardening, invoice tax-line. Gateway thin clients (C16) plug into this architecture; the manual path is never removed.

### 4.6 Audit architecture

`audit_events` stays in the provider PostgreSQL and becomes tamper-evident via C10: INSERT/SELECT-only application role, append-only trigger, per-event hash chain, signed checkpoints to B2 Object Lock under separate credentials, an off-box verifier, and pgaudit. Until the DBA-attack simulation passes (Phase 0 gate), the approved description is **"append-only by application design; tamper-evidence hardening in build"** — the word "immutable" is not used.

---

## 5. Phased plan re-cut under §0

### 5.1 Phases

**Phase 0 — Survival & measurement gates (today's plan; nothing production-adopts until the gates pass)**
- 7-day **measured baseline** via Beszel (C4) on both current hosts: peak RAM per container, coincident peak, disk growth/day. Ledger re-issued if off by >25%.
- **Whole-server backup inventory + timed restore drill into isolation** (A2): provider DB + one bench site + Postiz DB + Keycloak + config. A backup not restored this cycle does not count.
- **Audit-hardening build (C10) + DBA-attack simulation** — pass is a gate for Phase 2b and for the word "immutable".
- Zero-rent light pack boards: Apprise (A1), OAuth2 Proxy (C8), Beszel + Dozzle (C4), Gotenberg hard-capped (C6), Uptime Kuma **off-box** (C7).
- **ServerKit throwaway pilot**: replica environment, 15-item checklist, prune canary, JWKS proof attempt, written containment design (§4.2), panel restore drill (Red Team gates).
- Trigger-metrics reporting (§5.3) goes live: monthly count + revenue filed to `audit_events`.
- KVM upgrade + rollback procedure written (§5.2) before it is needed.

**Phase 1 — The KVM 4 step + panel home**
- Execute **Step 1 (KVM 2-class → KVM 4-class)** per §5.2, in the 01:00–03:00 PKT window.
- **Fold Postiz in** under Dokploy scope + rules P-1…P-8 (C18) — only after the upgrade verifies (Load veto 1).
- ServerKit **production inside the VM guest** (C1/C2) if — and only if — the Phase 0 pilot proved containment; otherwise the panel DEFERs to the split trigger and Phase 1 ends here.
- External SMTP relay live (A4). Flagsmith pilot begins (P1).

**Phase 2 — Face & knowledge (KVM 4, headroom-gated, order binding)**
- Extension read-only + widgets (C3). Apache observability stack (C5), then BookStack (C9) — each boards only if the measured cumulative peak stays inside the 70% budget; otherwise it slips to the KVM 8 step automatically.
- School ERP+LMS `serverkit.yaml` authored as portable spec under the onboarding pattern (C19).
- **Phase 2b — extension write path (W2):** unlocks only after JWKS proof + SoD acceptance test + C10 gate. The old console retires only after 90 days of clean panel operation.

**Phase 3 — Channels & money completion**
- SMS via Apprise live (C17). PK gateway thin clients (C16) sandbox → live; billing owed-work sprint from D1's list (dunning, proration, coupons — in our own billing).
- Flagsmith adoption decision from its pilot. Novu trigger review (D4) on measured template/volume numbers. RAG pilot if a named consumer exists (P9).

**Phase 4 — Tenant pack (pinned image pipeline only)**
- Base image: HRMS (C11), Payments (C13), Wiki (C14); optional per-tenant pack: Helpdesk (C12). Print via the v16 built-in editor (A3).
- Pilots: CRM (P2), Insights (P3), Builder (P4), Webshop (P5), XPOS pinned-release (P6).
- **FBR bake-off:** pakistan_tax (P7) vs kodlyft/di (P8) in the FBR sandbox after the Python ≥3.14 bench check; winner earns one volunteer tenant, then general availability.
- PK payroll pack (C15): expert validation + one parallel-run cycle; only then does HRMS ship as payroll-ready.

**Phase 5 — Re-judgement at the KVM 8 step and/or the §0 split trigger**
- Deferred items become eligible for re-judgement — not automatic adoption: Kill Bill shadow pilot (D1), Superset (D2), Activepieces (D3), Chatwoot (D5), Novu (D4), Pluton (D7).
- At the **split trigger specifically**: Postal on a separate host with dedicated IP (D6), Postiz host decision incl. migration off Dokploy (D15), panel-on-dedicated-host re-judgement if the VM containment was never proven, traces re-proposal (D14) with SSO paper in hand.

### 5.2 KVM upgrade procedure (TOR §6.8 — written before it is needed)

1. **T-7d:** confirm target plan specs + price in hPanel (the §3.1 figures are ESTIMATE until this moment); confirm the upgrade is **in-place** (same IP, same disk) — if not confirmed, this procedure is void and a migration plan replaces it.
2. **T-3d:** full restic → B2 backup of everything **and a tested restore** of at least the provider DB + one bench site into isolation.
3. **T-1d:** tenant + Postiz notices (72 h / 24 h / 1 h / completion). Freeze: no deploys, image swaps, panel updates, or migrations until verification passes. Record the pre-upgrade manifest: image digests, Compose project names, container list, Caddy config hash, resource baseline.
4. **T-0:** pause provisioning + provider workers gracefully; drain in-flight jobs (Postiz posts in the window are **held, not fired**). Final incremental backup + DB dumps.
5. **Snapshot:** Hostinger VPS snapshot taken; ID + timestamp in the run log. (Rollback mechanism for this procedure only — **not** a backup.)
6. **Upgrade** in the window **01:00–03:00 PKT** (planned window 60 min EST; expected interruption likely 10–30 min EST — tenants are promised the window, not the hope). If the disk grows, verify the filesystem actually expanded (`lsblk`/`df`, resize if needed).
7. **Verify, in order, all must pass:** OS + Docker → Caddy + TLS → provider API + PG → Keycloak (staff + one customer login) → all tenant sites + one bench background job → Postiz app + one non-public publish path → Dokploy scope + project names unchanged → boarded sidecars within caps → resource snapshot vs baseline (new headroom must be visible).
8. **Soak 24 h** heightened monitoring; new adoptions stay frozen; ordinary tenant work resumes after step 7.
9. **Rollback rule:** if step 7 fails and cannot be fixed forward inside the window, restore the snapshot and declare the upgrade failed — no improvised partial state. Snapshot retained until the soak passes.
10. No payment-verification or pricing action is taken during the window; maker–checker queues simply wait. If verification suggests governed data changed, that is a rollback trigger, not a fix-forward.

**Step triggers (within §0):** Step 1 fires on the §0 decision itself (the fold requires it); also on 7-day peak RAM >70%, any swap use in 7 days, or disk >60%. Step 2 fires on 7-day peak >70% of 16 GB, disk >60% of ~200 GB, sustained CPU queueing in tenant hours, Board approval of any KVM 8 item, or live bench tenants exceeding ~8–10 (EST planning figure, re-derived from the Phase 0 measurement). Warning thresholds (alert, don't upgrade): peak >60% for 3 consecutive days; disk >55%; any container repeatedly hitting its cap.

### 5.3 Trigger metrics defined (TOR §6.9)

The §0 regime ends when **either** trigger fires, whichever first. Both are measured from the provider database — the same system of record as billing — never from panel dashboards or estimates.

| Metric | Definition |
|---|---|
| **Paying client** | A distinct billing account in the provider DB holding ≥1 subscription in status **active**, or **past_due within its grace period**, on a paid plan. **Excluded:** trials, internal accounts, demo tenants, complimentary plans, cancelled subscriptions, and accounts suspended >14 days. |
| **"Exceed 30"** | The paying-client counter reaches **≥31**, confirmed at a 14-day snapshot (a one-day spike does not end the regime; a sustained count does). |
| **Monthly revenue** | **Recognised revenue in the provider DB from verified payments**, net of refunds and credits, for the calendar month. PKR amounts convert to USD at the **SBP interbank closing rate on the last business day** of the month. |
| **"Exceed $2,000"** | **Two consecutive months >$2,000**, OR **any single month >$2,500** (spike guard, so one anomalous month can trigger early planning without ending the regime on noise — the two-month rule ends it; the spike rule starts the split design). |
| **Review** | Computed monthly on the **1st**; the count, the revenue figure, the FX rate used, and the resulting regime status are filed as a hashed entry in `audit_events`. Owners: **Money seat** (revenue figure), **Load seat** (host/commitments view), **Chair** (review + declaration). |

---

## 6. Disagreements register

Settled by direct evidence (Chair's GitHub-connector reads and vendor-doc checks, 2026-11-14), never by vote. "Losing claim" is recorded per TOR §2.

### 6.1 The eight mandated settlements

| # | Disagreement | Evidence | Settlement |
|---|---|---|---|
| a | **pakistan_tax existence/licence** — Muse: verified, MIT. Gemini + ChatGPT: UNVERIFIED / could not locate. | Direct repo read: the repo lives at **`ehsen/pakistan_tax`** (owner "ehsen" is the SpotLedger vendor — his other repos are spotledger, spotledger_hr, spotledger_website). `license.txt` = **MIT, © 2026 SpotLedger**. README: FBR Digital Invoicing (sandbox + production), native tax engine (sales tax, further tax, 236G, WHT), **hard-requires v16** (before_install blocks v15). Created 2026-07-22, branch `develop`, 0 stars. The path `SpotLedger/pakistan_tax` returns **404**. | **Muse right in substance, wrong in path; Gemini/ChatGPT's non-existence implication wrong** — they searched the wrong org path. Repo exists and is MIT. Board outcome: PILOT FIRST (P7) — existence settled, maturity (0 stars, 4 months old) is what the pilot prices. |
| b | **Print Designer archived?** — Muse's register listed it as a candidate; Gemini/ChatGPT: archived. | README banner in `frappe/print_designer`: "This repository is archived and no longer maintained… use the Print Format Editor built into Frappe from version 16." (GitHub's `archived` flag reads false and cosmetic commits landed 2026-11-12, but the maintainers' own banner is the operative fact.) AGPL-3.0. | **Gemini/ChatGPT right in substance.** Gemini's exact archive date (Oct 13, 2026) is unverified but immaterial. Board outcome: REJECT (R3); replacement A3. Muse's listing is struck (§7). |
| c | **Kill Bill coupons** — Muse: gap, paywalled (unspecified). Gemini: paid tier (exact figure). ChatGPT: OSS has a demo entitlement plugin + custom-extension mechanism. | killbill.io pricing/SaaS pages: OSS promotions = catalog **discount phases** only; **coupon codes are an Aviate feature at USD $9,999/mo paid annually**; full Wallet/prepaid and raw-event metering likewise Aviate; pre-aggregated usage in OSS. | **Gemini's figure exact; ChatGPT's plugin point technically fair but does not change the product conclusion.** Coupons are effectively paywalled at a price that ends the discussion at our scale. Board outcome: coupon gap = build-it-yourself on either path (priced in D1). |
| d | **Pluton remote management** — Muse: implied free fleet UI. ChatGPT: PRO is commercial. | Vendor pricing: **PRO = $59/yr incl. 5 remote machines + $12/yr per extra**; remote/agent backups are PRO-only and closed-source. Free OSS (Apache-2.0) = local backup UI only; v0.22.0 (2026-11-02), 0.x line. | **ChatGPT right.** Muse's fleet-UI implication is struck (§7). Board outcome: DEFER (D7) as a possible local read-only dashboard; the adopted item is the restic discipline (A2). |
| e | **XPOS stability** — Muse: v16 line usable. ChatGPT: "`develop` explicitly unstable." | README of `kodlyft/xpos` (MIT, © 2026 Ali Raza): `develop` branch = v3 preparation, **"not a stable release"**; a stable version-16 release line exists (2.13.4); `version-16-hotfix` unpublished. | **Both partly right; ChatGPT's caution is the operative one.** Board outcome: PILOT FIRST on the **pinned stable release only**, `develop` banned (P6). |
| f | **kodlyft/di as FBR candidate** — ChatGPT-only claim. | Direct repo read: exists, **MIT (© 2026 Kodlyft)**; FBR Digital Invoicing (PRAL DI API v1.12) + POS fiscal; requires **Python ≥3.14**, Frappe ≥16, install branch `version-16`. | **ChatGPT verified in full.** Board outcome: PILOT FIRST as bake-off candidate 2 (P8), gated on the bench Python check. |
| g | **SigNoz SSO** — ChatGPT: rejection because native OIDC/SAML is enterprise-only. | SigNoz vendor docs: SAML/OIDC available on SigNoz Cloud and **Enterprise Self-Hosted only**; Community Edition = Google Workspace OAuth only; the Keycloak integration guide itself requires licensed self-hosted. | **ChatGPT's rejection reason CONFIRMED.** Combined with Load's weight veto, two independent grounds → REJECT (R1). |
| h | **VortexPanel plugins** — Muse: no extensibility. ChatGPT: plugin system exists. | README: plugins live at `/opt/vortexpanel/plugins`; a paid "Hosting Module" add-on exists. **But:** no LICENSE file in the repo root (root listing Chair-verified) — the MIT claim rests on README/description only. | **ChatGPT's correction stands; Muse's claim corrected (§7).** It does not rescue the candidate: REJECT stands on SSO absence + licence-on-paper weakness (R7). |

**Bonus settlements:** **Kestra CVE-2026-49869 is REAL** — CISA KEV, added 2026-09-02, CVSS 10.0 unauthenticated RCE, fixed in 1.0.45/1.3.21 (Gemini accurate; weighed in R2). **`UniVenture-Solutions/fbr_digital_invoicing` exists** (4 stars) and is pakistan_tax's superseded predecessor lineage (R4). The Red Team's web search found zero hits for pakistan_tax and kodlyft/di and called the former untraceable — **superseded by the Chair's direct connector reads**: search engines do not index these repos; absence from search results is not absence from GitHub. Recorded so no future lane repeats that inference.

### 6.2 Seat conflicts settled by the Chair (with dissents recorded)

| Conflict | Positions | Chair ruling & reason |
|---|---|---|
| Kill Bill | Money: DEFER, no spike. Security: PILOT FIRST shadow. Red Team: KILL. | **DEFER with trigger; re-entry = PILOT FIRST shadow-only.** Money owns TOR §6.3 and judged against live invoicing: a POC answers no live question — fit is not in doubt; the blockers (JVM rent, duplicated truth, paywalled coupons) are facts a POC cannot cure. Security's conditions (a)–(d) are adopted verbatim as re-entry terms, so its governance concerns survive the deferral. Red Team's KILL is recorded as dissent; DEFER preserves the option if a metered product ever makes the need real. Load's veto independently bars boarding at KVM 2/4 regardless. |
| Panel containment | Security: VM guest or nothing (V2). Load: compose caps + quota + procedural lockout suffice at KVM 4. | **Security's VM boundary is a hard gate.** A procedural lockout is a promise; a VM boundary is a fact — and the failure it guards against (cleanup deleting tenant rollback images) is destructive and irreversible. Load's caps/quota/prune-to-2 conditions are adopted *inside* the guest as well. If the pilot cannot prove the VM design, the panel DEFERs to the split trigger (Security's fallback). Load's position recorded as superseded on this point, with its cost note (≈0.5 GB guest overhead) carried into the ledger. |
| Extension write path | Security: JWKS proof + SoD test unlock W2. Red Team: read-only until 90 days' clean panel operation. | **Both, sequenced.** W2 (Phase 2b) unlocks on Security's three gates (JWKS, SoD acceptance test, C10 simulation). The Red Team's 90-day soak governs **retiring the old console as fallback**, not enabling W2 — otherwise the console could never be proven redundant. |
| Observability shape | Gemini: Beszel+Dozzle+GlitchTip trio. ChatGPT: Prometheus+VictoriaLogs+Perses. Muse: SigNoz. | **Load's weight ruling decides:** Beszel+Dozzle now; Apache stack at KVM 4; GlitchTip DEFERRED (joins the Apache shape later only on proven need); SigNoz REJECTED on SSO + weight. Never two shapes at once (Load veto 7). |
| Chatwoot | Security + Frappe: PILOT FIRST. Red Team: KILL. Load: NEVER co-resident under §0. | **DEFER with trigger.** Load's rent evidence is decisive for placement (heaviest sidecar; 10× the in-bench alternative), and its SSO position is unverified — TOR §2 sends it to pilot-or-defer, and the veto removes pilot-on-this-box. Security/Frappe pilot conditions are preserved verbatim as re-entry terms; Red Team's KILL recorded. |
| Superset timing | Money: DEFER to split trigger. Security: ADOPT WITH CONDITIONS, Phase 3. Load: boards at KVM 8 with replica/bounded export. | **DEFER, trigger = KVM 8 step + demonstrated need** — earlier than Money's split trigger (Load's rent evidence shows KVM 8 cures the resource objection, and need, not rent, is then the honest gate), with Security's bounded-export conditions attached at re-entry. Money's stricter position recorded. |
| Activepieces | Security: ADOPT WITH CONDITIONS (narrow). Load: KVM 8. Red Team: KILL. | **DEFER with trigger** (named glue need + KVM 8). No seat identified a live glue need today; adopting an automation platform in search of a problem fails TOR §3.1. Security's allowlist/credential conditions attach at re-entry. |
| Pluton | Load: boards today (scheduled). Security + Red Team: DEFER. | **DEFER.** Its rent fits — the deferral is need/governance, not arithmetic: what Phase 0 needs is the restic discipline drilled (A2), and a UI adopted before the drill exists would decorate an unproven process. Load's dissent (rent fits today) recorded. |
| Flagsmith | Security: ADOPT WITH CONDITIONS + SSO flag. Red Team: DEFER. | **PILOT FIRST.** The SSO flag is dispositive under TOR §2: an unverified SSO claim cannot be adopted. The pilot's Gate 0 *is* the evidence production Security's condition demanded; Red Team's need-test becomes Gate 1. |
| Postal end-state | Gemini: external relay. Security: DEFER self-host. Red Team: KILL self-host (port-25/reputation traced). Load: NEVER on tenant box. | **Convergence, recorded as such:** external SMTP relay ADOPTED (A4); self-hosted Postal DEFERRED to post-split + dedicated IP (D6). No seat defended self-hosting on this box. |
| Audit "immutable" | ChatGPT: our audit's DBA-tamper resistance is UNVERIFIED. (Muse's report had implied stronger.) | **ChatGPT is FAIR — upheld by Security (Ruling 3).** The word "immutable" is withdrawn until C10 is built **and** the DBA-attack simulation passes; the simulation + off-box verifier are Phase 0 gates. |
| Future-product identity | Gemini: per-product Keycloak realm. ChatGPT: registration contract (adopted). Future seat: single staff realm, per-product client. | **Single staff realm with per-product OIDC clients (C19).** Per-product realms multiply exactly the login fragmentation the one-login rule exists to prevent. ChatGPT's contract adopted with that amendment. |

---

## 7. Removals list (TOR §6.10)

Everything the three reports proposed that the Board strikes — the architecture is defined as much by this list as by §2.

**Rejected components** (full reasoning in §2.5): SigNoz (R1) · Kestra (R2) · Print Designer (R3) · UniVenture `fbr_digital_invoicing` as an installable app (R4) · POS Awesome (R5) · Appsmith (R6) · VortexPanel (R7) · Trillian (R8) · procrastinate (R9) · standalone provider Helpdesk bench (R10) · licence/fit group: n8n (SUL — source-available, not open), immudb (BSL), Graylog (SSPL), Outline (BSL), Flipt (Fair Core), Unleash (AGPL relicense), Invoice Ninja (Elastic Licence), Lago / Flexprice / UniBee (AGPL billing engines — also unnecessary per D1), Frappe Drive (archived), `FBR-Pakistan` repo (no licence file), OneUptime (heavy overlap, no named gain) (R11).

**Struck claims** (proposals or assertions removed from the record so they cannot quietly re-enter later documents):
1. **"Adopt the register as a package"** — the combined sidecar set sums to ~20–30 GB of minimums before the current stack; dead on arithmetic (Red Team, confirmed by Load's ledger).
2. **Muse's Pluton fleet-UI implication** — remote/agent backup is paid PRO, closed source (§6-d).
3. **Muse's `SpotLedger/pakistan_tax` path** — the org path 404s; the repo is `ehsen/pakistan_tax` (§6-a). Any document citing the old path must be corrected.
4. **Muse's Print Designer listing** as a live candidate — archived by its maintainers (§6-b).
5. **Muse's VortexPanel "no extensibility" claim** — plugins exist (§6-h). Corrected without rescuing the candidate.
6. **Gemini/ChatGPT's pakistan_tax non-existence implication** — a wrong-path search result, not a fact (§6-a).
7. **The word "immutable" for our current audit** — withdrawn until C10 + the DBA-attack simulation pass (§6.2).
8. **Gemini's per-product Keycloak realm** — replaced by per-product clients in the single staff realm (C19).
9. **"Panel on a dedicated host"** (all three reports' placement assumption) — superseded by §0; replaced by the VM-guest containment design (§4.2).
10. **Kill Bill coupon/metering expectations from OSS** — coupons and raw-event metering are Aviate-paid (§6-c); no plan may assume them from the open-source edition.
11. **SkyWalking as a drop-in SigNoz substitute** — JVM-class weight with UNVERIFIED SSO; not a target architecture (D14).
12. **Registering Postiz's remaining srv1322702 workloads as part of this adoption** — out of mandate; needs its own owner ruling (§4.3 scope note).

---

## 8. Chair's checklist clearance (TOR §6, items 1–10)

| # | Item | Cleared at |
|---|---|---|
| 1 | Panel containment on one host — exact design, socket exposure, prune lockout, agent levels per workload | §4.2 (VM guest; Monitor + Observed for benches, Postiz, provider alike; prune canary + lockout) |
| 2 | Resource ledger — today's plan vs next plan; what boards now vs after upgrade | §3 (folded ledger; boards-today / KVM 4 / KVM 8 / never table) |
| 3 | Kill Bill: in or out — fit + JVM rent; owed work if out | **Out** — D1 (fit judged on live model; 1.5/2.6 GB rent for the least frequent workload; owed work priced ≈25–38 dev-days at zero rent) |
| 4 | Observability weight — SigNoz vs Apache stack | §3.3 + R1/D13: SigNoz rejected (SSO + 4.0–6.5 GB peak); Beszel+Dozzle now, Apache stack at KVM 4 |
| 5 | Support stack ruling — who serves our tenants vs tenants' customers | §4.4: both tiers, never swapped (C12 in-bench; Issues inbox → Chatwoot only on D5 trigger; R10) |
| 6 | Novu: necessary or ornament | **Ornament at current volume** — D4 (Apprise-only; measured trigger set at Phase 3 review) |
| 7 | Postiz end-state — Dokploy / Observe / migration, COMPOSE_PROJECT_NAME class designed out | §4.3 + C18/D15: Dokploy owns Postiz scope; ServerKit Observe-only; P-1…P-8; migration deferred to split |
| 8 | Whole-server survival — backup coverage, restore drill, KVM procedure | Phase 0 gates (§5.1) + §5.2 (snapshot → upgrade → verify, rollback rule, 01:00–03:00 PKT window) |
| 9 | Trigger metrics defined — measured where, reviewed when | §5.3 (provider DB definitions; ≥31 at 14-day snapshot; two-months >$2,000 or single >$2,500; monthly on the 1st, hashed into `audit_events`) |
| 10 | Removals list | §7 (12 rejected components/groups + 12 struck claims) |

---

**Board sign-off:** Chair (Chief Architect), synthesising the signed positions of the Security & Governance seat (5 vetoes recorded and upheld), the Single-Server Load & Ops seat (7 vetoes recorded; 6 upheld in full, 1 — panel containment method — superseded by the Security boundary with reasons in §6.2), the Frappe/Tenant-Tier seat, the Money & Billing seat, the Future SaaS & Ecosystem seat, and the Red-Team Critic (Condition 0 adopted as the Phase 0 gates; dissents recorded in §6.2 where the Chair ruled otherwise).

**For the owner's faisla, three items are flagged:** (1) the Uptime Kuma off-box exception to §0 (§1); (2) the KVM 4 upgrade spend, which Phase 1 requires before the Postiz fold-in (§3/§5); (3) the srv1322702 non-Postiz workloads, which sit outside this Board's mandate (§4.3).

*Advisory only — the Board recommends, the owner decides.*
