# Adoption Board — Terms of Reference (TORs)

**Constituted:** 2026-11-14, by order of the owner (Assad). **Mission:** judge the three consolidated adoption reports (Muse, ChatGPT, Gemini — saved verbatim in `external-reports/`) against the underlying evidence, and produce **per-component adoption decisions** for a flawless workflow: what enters the Operqon ecosystem, what is removed/deferred and why, what makes the ecosystem better and easier, and what would make it painful and complex.

## 0. The standing constraint that outranks every report (owner, 2026-11-14)

> **ONE server.** The whole stack — Operqon provider platform, ERPNext benches, the panel and every adopted service, **and Postiz** — runs on a single server (the current VPS, upgraded in place through Hostinger KVM plan upgrades) **until either paying clients exceed 30 or monthly revenue exceeds $2,000**, whichever comes first. Only past that trigger do we split/improve infrastructure.
>
> Consequences the Board must design under: (a) every adopted component pays rent in RAM/CPU/disk on that one box — a component that cannot justify its footprint does not board now; (b) the earlier "panel on a dedicated host" recommendation must be re-judged as **panel contained on the same host** (its own container/VM boundary, no destructive reach into bench containers) — the Board must produce that containment design or reject the panel; (c) Dokploy (Postiz) and any new panel are both Docker managers on one host — the Board must rule the end-state (one manager, or strictly separated scopes) with the one-owner-per-host law adapted to one-host reality; (d) whole-server backup/restore (B2/restic) and a drilled restore become first-class, because one box is also one point of failure; (e) the KVM upgrade path (when, to which plan, downtime handling) is part of the plan.

## 1. Board composition (specialist seats)

1. **Chair — Chief Architect.** Owns synthesis and the final decision table; resolves conflicts by evidence, not seniority; no vote except to break an evidence tie, with reasons recorded.
2. **Security & Governance Critic.** Guards the non-negotiables: maker–checker SoD, governed pricing, immutable audit, one-login rule, tenant-data blast radius. Holds a **veto** on any decision that moves money/approval logic or weakens audit.
3. **Single-Server Load & Ops Engineer.** Owns the resource budget: a measured RAM/CPU/disk/IO ledger for the one server (current stack + each candidate), headroom rules (≥30% free RAM at peak, disk ≤70%), and the upgrade triggers. Holds a **veto** on any adoption that breaks the budget without a funded upgrade step.
4. **Frappe / Tenant-Tier Specialist.** Judges every bench-side item: v16 compatibility evidence, image-pipeline fit, AGPL/GPL discipline, per-tenant rollout risk.
5. **Money & Billing Specialist.** Judges the billing stack end-to-end (Kill Bill vs ours), gateway reality (PK thin clients), coupons gap, dunning — against live invoicing that already works and must not regress.
6. **Future SaaS & Ecosystem Specialist.** Judges fit for School ERP+LMS, Rektrs Social/Postiz, RAG and small services joining the same home; guards project separation (products share operations, never data/governance).
7. **Red-Team Critic (devil's advocate).** Argues *against* every adoption: complexity added, failure modes, bus factor, upgrade burden, "what breaks at 2 a.m." A decision that cannot survive the Red Team's best argument does not pass.

## 2. Evidence rules (how the Board jaanchta hai)

- Every factual claim in any of the three reports is treated as **unproven until traced** to a repo file, licence text, doc, or our own platform records. The two Muse research files (adoption plan + leverage findings) are evidence logs, not verdicts; ChatGPT/Gemini claims get the same tracing, and **fabricated or untraceable features are called out by name** in the Board's report.
- Where the three reports **agree**, the Board still spot-checks the load-bearing claims. Where they **disagree**, the disagreement is resolved by evidence and the losing claim is recorded — never averaged, never voted away.
- Licence claims require the LICENSE file itself. Maintenance claims require commit/release dates. Resource claims require published footprints or measurements, marked as estimates otherwise.
- Anything that cannot be verified on paper goes to the **pilot list**, not the adoption list.

## 3. Decision criteria (every component is scored on all eight)

1. **Need truth** — does it replace real planned work, or is it a shiny extra?
2. **Licence cleanliness** — MIT/Apache/BSD clean; GPL/AGPL only under the tenant-tier discipline; source-available = out.
3. **Single-server rent** — RAM/CPU/disk at idle and at peak, against the §0 budget.
4. **Operational burden** — updates, backups, failure modes, observability of the component itself; who pages when it breaks.
5. **Integration cost** — SSO (Keycloak or it breaks the one-login rule), API shape, data ownership.
6. **Governance compatibility** — SoD, audit, role model; money never moves on a component's own say-so.
7. **Reversibility** — can we switch it off in a year without pain? Data in open formats? Exit cost stated.
8. **Ecosystem effect** — does it make the whole easier (fewer logins, fewer dashboards, fewer pipelines) or does it add a new island?

## 4. Do / Do-not

**Do:** prefer fewer moving parts; prefer what is already in the stack (Frappe apps, restic, Caddy, Keycloak) over new islands; phase everything behind pilot gates; quantify the single-server budget before adopting anything with a JVM or a ClickHouse in it; keep every product's data and governance separate while unifying *operations*; write the reason for every removal as carefully as for every addition.

**Do not:** adopt anything that requires modifying live benches beyond the Monitor-level agent and the pinned image pipeline; run two Docker-managing panels with overlapping scope on the one host; accept any component whose free tier gates SSO; modify an AGPL app without the publish discipline; let a component hold governed data (tenants, invoices, audit) outside our provider database; decide on star counts, report confidence, or vendor marketing; treat "the other two AIs also said it" as evidence.

## 5. Decision format (per component, no exceptions)

**ADOPT** / **ADOPT WITH CONDITIONS** / **PILOT FIRST** / **DEFER** (with its trigger: client count, revenue, or a named need) / **REJECT** — each with: (i) the need it serves; (ii) why it makes the ecosystem **better and easier**, or why it makes it **painful and complex**; (iii) its single-server rent; (iv) its phase; (v) the evidence trail (which report claimed it, where the Board verified it); (vi) conditions and the owner of each condition.

## 6. Chair's additional checklist (points the owner asked Muse to get cleared)

1. **Panel containment on one host** — the exact design (container boundaries, Docker socket exposure, cleanup/prune lockout, agent levels per workload: Operqon benches vs Postiz vs provider services) that lets ServerKit live on the same box without holding a loaded weapon over tenants.
2. **The resource ledger** — measured/estimated footprint of the full target stack on today's KVM plan and on the next plan; what boards now, what waits for the upgrade.
3. **Kill Bill: in or out** — fit against our subscription model (seats, overage, manual-payment recording) *and* its JVM rent on one box; if out, what our own billing build still owes.
4. **Observability weight** — SigNoz (ClickHouse) vs the lighter Apache stack (Prometheus + VictoriaLogs + Perses) under §0.
5. **Support stack ruling** — Frappe Helpdesk (tenant tier) vs Chatwoot (platform tier) vs both vs neither; who serves *our* tenants' support vs tenants' own customers.
6. **Novu: necessary or ornament** — Apprise-only vs Apprise+Novu, judged on real notification volume.
7. **Postiz end-state on one host** — Dokploy stays / ServerKit Observe / migration path, with the COMPOSE_PROJECT_NAME class of incident designed out.
8. **Whole-server survival** — backup coverage of *everything* (panel DB, provider DB, benches, Postiz, sidecars), restore drill order, and the KVM upgrade procedure (snapshot → upgrade → verify) written before it is needed.
9. **Trigger metrics defined** — "30 clients" and "$2,000/month" measured where (provider DB subscriptions + recognised revenue), reviewed when.
10. **The removals list** — everything the three reports proposed that the Board strikes, each with its reason, so the final architecture is as much defined by what is *not* in it.

## 7. Output

One Board report: (1) executive decision summary; (2) the per-component decision table (§5 format); (3) the single-server resource ledger; (4) the corrected target architecture; (5) phased plan re-cut under §0; (6) the disagreements register — where the three source reports conflicted and how evidence settled each; (7) the removals list. The Board's report goes to the owner for the final faisla; the Board recommends, the owner decides.
