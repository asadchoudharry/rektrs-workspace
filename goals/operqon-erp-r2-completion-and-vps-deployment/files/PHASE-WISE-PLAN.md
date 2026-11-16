# OPERQON — PHASE-WISE PLAN (complete blueprint, one document)

**Built:** 2026-11-09 · **Nature:** research + writing only — no code, no server changes, no deploys.
**Owner:** Assad · **Programme:** Operqon multi-tenant ERP SaaS.
**Primary sources:** blueprint v1 at `references/blueprint-v1/Operqon_Blueprint_v1/` — citations give the blueprint file + section; live-state citations give the memory date or lane report. Where a status is claimed, a source is named next to it; anything without a source is marked **UNVERIFIED** or **not started**.

**The owner's overall figure, as recorded:** the whole Operqon blueprint (W0–W5) was estimated at **~35–40%**, with W0 fully closed and W1 in its final stage (status snapshot given to Assad, 2026-11-08; `memory/2026-11-08.md`). This is a recorded estimate, reproduced here — it is **not** a figure computed by this document.

---

## 1. ONE-PAGE SUMMARY TABLE

| Phase / track | Status (2026-11-09) | Items | Gate that closes it |
|---|---|---|---|
| **W0** — Baseline audit, evidence, ADRs, working customer layer (`engineering/04-delivery-backlog.md` §1) | **Complete** (wave-level; see §3 caveat on per-item audit) | 12 ENG items (ENG-001–012) | "Reproducible release and restored staging" (§1 table) — closed per the 2026-11-08 programme snapshot ("W0 mukammal band") + W0 backup closure 2026-11-07 (`MEMORY.md`) |
| **W1** — Shared finance/supply/commerce + controlled pilots | **In-progress — final stage** | 48 ENG items (ENG-013–060) | "3 real end-to-end businesses; reconciled ledgers" (§1) — met in practice via controlled pilots per §7 of the same doc (see §3); outstanding: demo2 run + Slice 10 (ENG-060) |
| **W2** — Pakistan trading/distribution/services launch packs | **Planned** (detailed plan delivered 2026-11-07; build not started as a wave) | 36 ENG items (ENG-061–096) | "FBR/country applicable evidence; supported scope published" (§1) |
| **W3** — Industry pilots (CSV scope) + Saudi pack (per §1 text — see contradiction note in §2.1) | **Planned / not started** | 12 ENG items (ENG-097–108), all industry items; **zero** Saudi/ZATCA items exist in the CSV | §1 gate: "ZATCA path and domain acceptance; no unsupported claim" — the ZATCA half has no backlog items to close it with (finding F2, §2.1) |
| **W4** — Enterprise controls / launch hardening (CSV scope) | **Planned, with significant pre-builds already live** (mapped item-by-item in §2.2) | 12 ENG items (ENG-109–120), all SRE/QA launch items; **zero** GCC/pharmacy/manufacturing items exist in the CSV | §1 gate: "Specialist/authority evidence per pack" — the CSV items close instead on ENG-120 "Operational launch" evidence (finding F3, §2.2) |
| **W5** — Wider MENA + selected global markets | **Planned — defined only as a wave row + country programme; NO item-level definition exists** | **0 ENG items** (the CSV ends at ENG-120 / W4) | "Country-by-country commercial readiness" (§1) — per-country, no single wave gate |
| **Phase C — own-product track** *(programme addition, owner decision 2026-11-08)* | **In-progress** — C1 ✅, C3 ✅, C6 ✅ live; own-frontend build awaits the owner's design pick | Not ENG-numbered (C1–C6 programme) | Owner's end-state: no tenant-visible surface reveals ERPNext/Frappe (2026-11-08 13:41 PKT, `MEMORY.md`) |
| **Console + login/signup redesign v2** *(programme addition, owner redirect 2026-11-09)* | **In-progress** — design directions rendered, owner pick pending; build after the pick | Not ENG-numbered | Owner pick of a direction from `files/design-directions-v2/` (16 renders + index), then build |
| **R4.2 gateways** (Easypaisa + PayFast) *(programme addition / handover Q4)* | **Blocked-on-owner-or-bank** — adapters built credential-free; merchant onboarding outstanding | Not ENG-numbered | Merchant accounts/credentials obtained (bank side) + entered via the console settings page (owner decision 2026-11-07 10:26 PKT) + sandbox E2E + live verification |
| Fixture cleanup *(programme addition)* | Planned — queued after the pilot; post-pilot fixtures pp1–pp3 joined the queue 2026-11-08 | — | All test tenants/payments/notices deleted, audit chain preserved (owner-endorsed 2026-11-07, `memory/2026-11-07.md`) |
| Billing shadow POC — Lago vs Kill Bill *(programme addition)* | Planned — explicitly **after W1 closes** | — | Shadow POC verdict vs the current billing flow on recurring payments, proration, dunning, reconciliation (Kill Bill decision 2026-11-08, `MEMORY.md`) |
| `/tenant-queue` billing-gate backend follow-up *(programme addition)* | Planned — named backend follow-up, out of the frontend lanes' scope | — | Backend release widens the `/tenant-queue` read gate for billing, or adds a billing-readable tenant directory (`hidden_files/team-console-f8-forms-picker.md`; validation item B-01 in `hidden_files/team-console-validation.md`) |

**Reading note on counts:** 12 + 48 + 36 + 12 + 12 = **120** — the full CSV (`engineering/delivery-backlog.csv`, every row `status = proposed` in the blueprint itself). W5 contributes **0** rows. Any count of "the blueprint" that includes W5 items is counting something the blueprint does not contain (see §2.3).

---

## 2. PER-WAVE SECTIONS — W3, W4, W5

### 2.1 W3 — Industry pilots (and the Saudi question)

**Objective (3–4 lines).** On top of the released W1 core and the W2 pack platform, prove the industry packs with real operators: distribution/beverages/FMCG, services, vehicle (EV, dealership, motorcycle), food (bakery, restaurant) and a manufacturing pilot plus a pharmacy pilot, closing on an industry certification gate where a real operator completes normal, exception and close scenarios (`engineering/04-delivery-backlog.md` §1: "Saudi pack plus vehicle/food pilots", 12–20 additional weeks; `engineering/delivery-backlog.csv` W3 rows). The industry sequencing behind these items is IW2 (FMCG/beverages/serialized dealerships) and the IW3 food entry in `industries/01-pack-model.md` (crosswalk: IW2 → "W2 distribution; W3 vehicle-specific pilots"; IW3 → "W3 food pilots; W4 complex manufacturing").

**⚠️ Finding F2 — the Saudi pack has no backlog items.** `engineering/04-delivery-backlog.md` §1 defines W3 as "Saudi pack **plus** vehicle/food pilots" with the gate "ZATCA path and domain acceptance", and the W2 plan's non-goals table repeats "Saudi pack end-to-end … (ENG-097–108)". The CSV itself contains **no Saudi, ZATCA, EGS or CSID item**: ENG-097–108 are twelve industry items (below). The Saudi pack is fully *specified* — `compliance/02-country-matrix.md` §3 (ZATCA generation/integration phases, EGS onboarding, CSID lifecycle, clearance vs reporting, plus its test list) and the jurisdictions CSV row "Saudi Arabia, P0, R" — but it has **zero ENG items, zero acceptance-evidence rows, and no owner role assigned in the backlog**. The same applies to the Saudi golden journey in `governance/02-coverage-and-acceptance-model.md` (journey 2). **Consequence:** as written, W3's §1 gate cannot be closed from the backlog — the ZATCA half must either be given ENG items (a blueprint amendment) or be tracked as a separate country track like W2's ENG-085–096 pattern. This plan does not invent those items.

**Full item table** (source: `engineering/delivery-backlog.csv`, W3 rows; acceptance evidence compressed, never reworded in substance; the CSV `risk` column carries only the level shown):

| ENG | Title | Depends on (CSV) | Acceptance evidence (CSV, compressed) | Risk |
|---|---|---|---|---|
| ENG-097 | Distribution route sales | Released core and pack platform | Route load, delivery, return, cash and vehicle stock reconcile | high |
| ENG-098 | Beverage containers | Released core and pack platform | Issue, return, lost bottle/crate and deposit ledger reconcile | high |
| ENG-099 | FMCG claims | Released core and pack platform | Scheme accrual, return rebate and supplier claim traceable | high |
| ENG-100 | Service jobs | Released core and pack platform | Quote, parts, time, report, invoice and AMC renewal end-to-end | high |
| ENG-101 | EV battery records | Released core and pack platform | Vehicle/battery serial, ownership, warranty and swap history linked | high |
| ENG-102 | Dealership allocation | Released core and pack platform | VIN booking, deposit, cancellation, handover and OEM claim audited | high |
| ENG-103 | Motorcycle service | Released core and pack platform | Job card, parts, warranty and customer approval demonstrated | high |
| ENG-104 | Bakery batch | Released core and pack platform | Recipe yield, allergens, expiry, waste and batch traceability verified | high |
| ENG-105 | Restaurant KDS | Released core and pack platform | Table split, modifiers, cancellation, kitchen delivery and shift close work | high |
| ENG-106 | Manufacturing pilot | Released core and pack platform | BOM, MRP, issue, WIP, completion, variance and QA reconcile | high |
| ENG-107 | Pharmacy pilot | Released core and pack platform | Prescription scope, batch FEFO, recall, privacy and controlled exception validated | high |
| ENG-108 | Industry certification gate | Released core and pack platform | Real operator completes normal, exception and close scenarios | high |

Owner role for all twelve: **Industry product engineer** (CSV).

**Sequencing inside the wave.** The CSV gives every W3 item the *same* dependency ("Released core and pack platform") — there are **no item-to-item dependencies in the CSV**, so any internal order is a planning derivation, labelled as such here: (1) **distribution family first** (ENG-097 → 098 → 099) — it continues W2's distribution launch scope and the IW2 crosswalk, and ENG-098's deposit ledger and ENG-099's claims both presuppose route-sale documents existing; (2) **services** (ENG-100) — it reuses the W1 services pilot chain shape (`engineering/04` §3); (3) **vehicle family** (ENG-101/102/103) per the IW2→W3 "vehicle-specific pilots" crosswalk; (4) **food** (ENG-104/105) per IW3's W3 food-pilot entry; (5) **manufacturing pilot** (ENG-106) — pilot depth only; complex manufacturing is W4 per the same crosswalk; (6) **pharmacy pilot** (ENG-107) last — it is the only W3 item touching a regulated domain, and `industries/01-pack-model.md` places pharmacy's *regulated depth* in IW4/W4, so ENG-107 must be read as a bounded pilot, not a pharmacy launch; (7) **ENG-108 closes the wave** — by its own acceptance text it requires the pilots to exist. This order is this plan's derivation from the crosswalk + acceptance texts, **not** a CSV statement.

**Entry gate:** W1 core released **and** W2 pack platform released (the CSV dependency, verbatim) — in programme terms: W1 closed (Slice 10) and W2 Slices 1–2 (pack platform + integration layer) landed.
**Exit gate:** ENG-108's evidence (real operator, normal + exception + close scenarios) per pack, under the §1 rule "no unsupported claim" and the capability-registry discipline (ENG-072). The §1 gate's ZATCA half is **unclosable as written** — see Finding F2.

**Known risks.** The CSV risk column gives only the level (`high` ×12) — no narrative. Narrative risks that bear on W3, from `engineering/04-delivery-backlog.md` §5: **scope explosion** (new industry without sponsor/pilot → catalogue record, defer); **pilot hardware overload** (queue/latency/memory breach → quotas, add cell capacity); **wrong compliance claim** (marketing status exceeds evidence → capability registry gates publication — sharpest for ENG-107 pharmacy); **country dependency delay** (sandbox/provider unavailable — the F2 Saudi gap makes this a *planning* risk today, not just an execution risk).

**What we already have that this wave builds on (no item planned twice):**
- ENG-100 (service jobs): the W1 plan's services pilot chain (quotation → PO → job → technician work → parts/time → service report → invoice → receipt → AMC renewal, `engineering/04` §3) is the pilot shape W1 Slice 10 exercises; W3 productises it as a pack. Overlap is *shape*, not delivery — ENG-100 is **not started** as a pack.
- ENG-097/098/099: W1 Slices 7–8 built the shared supply/commerce core these ride on (local phases complete 2026-11-07; `hidden_files/team-slice7-supply.md`, `team-slice8-commerce.md`) and W2 Slice 8 assembles the PK distribution launch pack. The route/container/claims workflows themselves are **not started**.
- ENG-104/105/106/107: only blueprint specifications exist (`industries/02-priority-industry-workflows.md` anchor workflows; `industries/03-industry-catalogue.csv`). Upstream ERPNext manufacturing exists in tenant sites but is unvalidated for ENG-106. ENG-107 builds on W1's *generic* batch/expiry policy (Slice 7) — the blueprint itself forbids reading that as pharmacy rules (W1 plan §3, Slice 7).
- ENG-108: the W1 QA acceptance-catalogue pattern (ACC scenarios + per-slice checklists, `memory/2026-11-07.md`) is the working template for the certification gate; the gate itself is **not started**.
- All other W3 items: **not started**; no lane report or memory entry evidences any W3 build as of 2026-11-09.

---

### 2.2 W4 — Enterprise controls / launch hardening

**Objective (3–4 lines).** Take working pilots to a defensible commercial launch: observability, representative load and noisy-neighbour isolation, automated backup + measured disaster restore, a regional cell, release canary, accessibility/RTL, AI-safety evaluation, security-review closure, customer exit, and the operational-launch proof (support ownership, SLO terms, incident drills, renewal/upgrade) (`engineering/04-delivery-backlog.md` §1: "GCC expansion, pharmacy/manufacturing, enterprise controls", 4–9 additional months; CSV W4 rows ENG-109–120, all `critical`, owner role **SRE and QA lead**).

**⚠️ Finding F3 — §1's W4 text and the CSV's W4 rows describe different waves.** §1 promises three things: GCC expansion, pharmacy/manufacturing depth, enterprise controls. The CSV delivers **only the third**: ENG-109–120 are twelve SRE/QA launch items. There is **no ENG item** for UAE Peppol, Oman Fawtara, Bahrain, Qatar or Kuwait (all specified as jurisdictions in `compliance/country-jurisdictions.csv`, P1), none for pharmacy depth (IW4) and none for discrete/process manufacturing depth (IW3's W4 half). As with F2, this plan records the gap instead of inventing items: GCC country packs and regulated-industry depth currently exist as *specifications without a backlog*.

**Full item table** (source: `engineering/delivery-backlog.csv`, W4 rows; acceptance compressed):

| ENG | Title | Depends on (CSV) | Acceptance evidence (CSV, compressed) | Risk |
|---|---|---|---|---|
| ENG-109 | Observability | Working pilots | Correlated safe traces, metrics, logs and runbook-backed alerts active | critical |
| ENG-110 | Representative load | Working pilots | Target workload SLO measured; capacity limits published | critical |
| ENG-111 | Noisy neighbor | Working pilots | Large tenant report cannot starve another tenant's critical queue | critical |
| ENG-112 | Automated backup | Working pilots | Failed or stale backup triggers accountable alert | critical |
| ENG-113 | Disaster restore | Working pilots | Full service recovery meets measured target; external events reconcile | critical |
| ENG-114 | Regional cell | Working pilots | Compute, backup, logs, keys and subprocessors match region commitment | critical |
| ENG-115 | Release canary | Working pilots | Pilot acceptance blocks a failing wave before wider rollout | critical |
| ENG-116 | Accessibility and RTL | Working pilots | Keyboard, focus, target size, RTL and error states pass agreed WCAG scope | critical |
| ENG-117 | AI safety evaluation | Working pilots | Tenant leakage, prompt injection and false fiscal actions blocked | critical |
| ENG-118 | Security review closure | Working pilots | Critical/high exploitable issues closed or formally accepted before release | critical |
| ENG-119 | Customer exit | Working pilots | Authorized full export with attachments; retained fiscal records verified | critical |
| ENG-120 | Operational launch | Working pilots | Support ownership, SLO terms, incident drills, renewal and upgrade proven | critical |

**Sequencing inside the wave.** Again the CSV gives one flat dependency ("Working pilots") for all twelve — no item-to-item order exists in the source. Derived order (labelled as derivation, following the acceptance texts): (1) **ENG-112 + ENG-113 first** — backup alerting and a *measured* restore are prerequisites for every later claim, and §governance's OPS gate ("restore drill, alert owner, incident procedure before paid SLA", `governance/02`) puts them before any paid launch; (2) **ENG-109** observability — load and noisy-neighbour proofs (ENG-110/111) are unmeasurable without it; (3) **ENG-110 → ENG-111** (capacity limits published, then isolation under that load); (4) **ENG-115** canary formalisation once metrics exist; (5) **ENG-116/117/118** quality gates in parallel; (6) **ENG-114** regional cell when a second region is commercially committed (the scaling roadmap's Stage 4 trigger, `files/SCALING-ROADMAP.md`); (7) **ENG-119** customer exit before production data onboarding scales (governance EXIT gate); (8) **ENG-120 last** — its evidence (drills, SLO, renewal/upgrade proven) presupposes all the others.

**Entry gate:** "Working pilots" (CSV) — in programme terms, W1's pilot gate + at least the W2/W3 pilot cohorts running.
**Exit gate:** ENG-120's evidence, plus governance's OPS + EXIT gates (`governance/02-coverage-and-acceptance-model.md`). §1's stated W4 gate ("Specialist/authority evidence per pack") belongs to the pack scope that has no items (F3) and cannot be evidenced from ENG-109–120.

**Known risks.** CSV: `critical` ×12, no narrative. From `engineering/04` §5: **pilot hardware overload** (the live VPS already shows swap pressure — `files/SCALING-ROADMAP.md` measured 2026-11-07); **upgrade drift** (tenants on unsupported combinations → release train + compatibility lock — the ENG-115 concern); **financial defect** (ledger/stock discrepancy → stop affected posting, incident, supported correction); **support cost** (repeated manual corrections → product fix + runbook — the ENG-120 concern).

**What we already have — the overlap map (read this before planning any W4 item):**

| ENG | Already live / built (sourced) | What genuinely remains for W4 |
|---|---|---|
| ENG-112 Automated backup | **Substantially pre-built.** restic → Cloudflare R2 off-VPS backups are LIVE: provider DB leg daily 02:50 UTC with restore-from-off-VPS proven (W0 closure, 2026-11-07, `MEMORY.md`); tenant-site backups; **Keycloak daily leg live 2026-11-08** with restore-read PASS (`memory/2026-11-08.md`); provider retention live (Sun 05:15 UTC) | The acceptance's second half: a **failed/stale backup triggering an accountable alert**. The provider-leg healthchecks ping is an owner-held open micro-item (handover Q1b) and the alert webhook URL is owner-entered — until those land, the alert leg is unproven. Do **not** re-plan backup itself |
| ENG-113 Disaster restore | **Partially proven.** Restores restore-*read* verified repeatedly: W0 off-VPS restore into a throwaway PG (2026-11-06/07); 2026-11-08 full-backup order — Rektrs site + Keycloak dumps restore-read verified from R2 (`memory/2026-11-08.md`) | A **full-service recovery against a measured target** (RTO) with external-event reconciliation — never performed as one drill |
| ENG-109 Observability | **Partially live.** `operqon-r2-watch` (2 min: disk/inode/RAM/cert legs), `operqon-r2-provision-watch` (5 min) + OnFailure alerts (`files/SCALING-ROADMAP.md` §5); observability audit G1–G10 + Phase-2 G2/G3 fixes delivered 2026-11-06/07 (`hidden_files/team-observability.md`, `team-observability-phase2.md`) | Correlated **traces/metrics/logs** as one system + runbook-backed alerts; alert *delivery* itself waits on the owner-entered webhook URL (console Notifications card) |
| ENG-110 Representative load | **Plan only.** `files/SCALING-ROADMAP.md` is a measured capacity plan (2 vCPU / 7.7 GiB, bench density ~15–25 sites/node, trigger bands) — it is a roadmap, not a load test | The actual representative-load run + published capacity limits |
| ENG-111 Noisy neighbor | **Not started** (site-per-tenant isolation exists architecturally; no starvation proof) | The proof itself |
| ENG-114 Regional cell | **Not started.** Single region (Jakarta) is a named known limit in `files/SCALING-ROADMAP.md` §4; Stage 4 there is trigger-based (100+ tenants / second-region customers) | Everything — deliberately trigger-gated, not date-gated |
| ENG-115 Release canary | **Practice exists, formal gate does not.** Releases already run a real container image gate, disposable-fixture tenants, per-file backups + rollback points (S5–S9, post-pilot, console releases, `memory/2026-11-07.md` + `2026-11-08.md`) | Formalising "pilot acceptance blocks a failing wave" as a named, repeatable canary stage |
| ENG-116 Accessibility and RTL | **Partially proven, console-side.** Console modernization deploy 2026-11-09: axe L3 re-run at the real origin, 24 runs, **zero violations** (`memory/2026-11-09.md`); design system carries AA fixes (`MEMORY.md`, design audit 2026-11-07) | The **agreed WCAG scope for tenant surfaces + RTL** — unproven; tenant Desk RTL has no evidence |
| ENG-117 AI safety evaluation | **Not started.** No tenant-facing AI feature is live to evaluate | Evaluation harness + the blocked-action proofs, when/if AI features ship |
| ENG-118 Security review closure | **Partially built.** W1 Slice 2 delivered the adversarial OIDC test pack locally (ENG-013 leg); five GSTACK-derived audit skills installed 2026-11-07 (`MEMORY.md`) | A wave-level closure pass: every critical/high exploitable issue closed or formally accepted, as one gate record |
| ENG-119 Customer exit | **Foundation built in W1.** Slice 4 built the export-authorization layer locally (queued export, permission re-check at download — ENG-022's delivery, `hidden_files/team-slice4-support.md`) + Slice 4 integration candidate (`team-slice4-integration.md`) | The **full exit drill**: authorized complete export incl. attachments with retained fiscal records verified end-to-end (governance EXIT gate) |
| ENG-120 Operational launch | **Partially evidenced by the pilot.** Rektrs pilot ran the real lifecycle end-to-end (settlement → publication → Stage 8 sign-in, closed 2026-11-08, `MEMORY.md`) | SLO terms published, incident **drills**, renewal/upgrade proven as operations — not yet done |

---

### 2.3 W5 — as found

**The finding, plainly: W5 is defined as a wave and as a country programme, and nowhere as work items.**

- **Defined — as a wave row:** `engineering/04-delivery-backlog.md` §1: W5 = "Wider MENA and selected global markets", **6–18 additional months, overlapping teams**, gate "Country-by-country commercial readiness". Repeated in `README.md` ("Pehla actual delivery sequence": "…W4 GCC, pharmacy/manufacturing and enterprise controls -> W5 wider MENA and selected global markets").
- **Defined — as a country programme:** `compliance/02-country-matrix.md` §§5–7 and `compliance/country-jurisdictions.csv` carry the W5-candidate jurisdictions at P2/P3 (Egypt ETA, Jordan JoFotara, Morocco, Tunisia, Türkiye, US federal + states, UK MTD, EU ViDA framework + member states, India GST, and the wider discovery set), all `implementation_status = proposed_not_verified_built`. `compliance/05-worldwide-expansion-registry.md` defines the machinery: 249 country/territory code entries (explicitly **not** 249 packs), a region-by-region discovery order, and a **10-step complete work package per country** (entity/registration mapping → official sources → local accountant verification → tax calculation coverage → fiscal document lifecycle → payroll/privacy/sector review → partner route + credentials custody → supported-matrix publication → golden fixtures + sandbox evidence + runbook → source/effective-date maintenance).
- **Absent — as backlog:** `engineering/delivery-backlog.csv` ends at ENG-120 (W4). There are **no W5 ENG ids, no owner roles, no dependencies and no acceptance-evidence rows for W5 anywhere in the blueprint.** `governance/requirements-traceability.csv` parks three requirements at W5 — REQ-012 (hundreds of use-case expansion packs), REQ-017 (USA IRS/IRIS/state-local taxes), REQ-019 (worldwide countries/territories programme) — each marked "Specified at blueprint/anchor/catalogue depth" and "Not claimed; evidence gates and backlog apply"; none of the three is itemised into ENG work anywhere.
- **Objective (from the sources above, 3 lines):** extend the proven pack machinery country-by-country beyond MENA — each country climbs the same ladder W2 defines for Pakistan (profile → rules → sandbox → controlled pilot → published supported scope) before any commercial claim is made for it.
- **Entry gate (derived from §1 + `compliance/05`):** a country enters build only when its 10-step work package's discovery steps (1–3) are evidenced; **exit is per-country** ("commercial readiness"), so W5 as a wave never "closes" — countries close one at a time. This per-country reading is the sources' own ("World coverage aik finite launch milestone nahin", `engineering/04` §1 note).
- **Sequencing/risks:** no CSV order or risk levels exist to reproduce. The §5 programme risks apply unchanged (scope explosion, country dependency delay, wrong compliance claim). Any W5 itemisation would be a **blueprint amendment**, and this plan deliberately does not write one.

---

## 3. W0 / W1 / W2 — CONDENSED

### 3.1 W0 — Baseline (ENG-001–012) — COMPLETE at wave level

Detailed basis: handover Q1 + `hidden_files/w0-backup-closure-2026-11-06.md`. Wave closed per the 2026-11-08 programme snapshot ("W0 fully closed", `memory/2026-11-08.md`) and `MEMORY.md` ("W0 off-VPS backup CLOSED, 2026-11-07: restic → R2 bucket `erp-saas-backups`, provider DB leg daily 02:50 UTC, restore from the off-VPS copy proven; provider retention live").

**Honesty caveat:** this pack did **not** re-audit ENG-001–012 item by item. The evidenced centre of W0's closure is the backup/restore leg (ENG-003-adjacent) and the R4.1 baseline acceptance; per-item status for the ADR/inventory items (ENG-001, 002, 004–012) is **UNVERIFIED at item level** and is claimed only at wave level, on the snapshot's authority. Two owner-held micro-items remain open **by design** (handover Q1): (a) the owner stores the restic password + R1 backup key in his own secure store (they exist only on the VPS); (b) the owner creates one healthchecks.io check for the provider backup leg.

Compact roster (CSV titles): ENG-001 Source baseline · ENG-002 Environment inventory · ENG-003 Restore rehearsal · ENG-004 R3 lifecycle contract · ENG-005 Deployment regression · ENG-006 License inventory · ENG-007 Tenant topology ADR · ENG-008 API contract capture · ENG-009 State-policy ADR · ENG-010 Release artifact lock · ENG-011 Pilot protection · ENG-012 Baseline acceptance.

**Closed vs total: 12 / 12 at wave level** (per the recorded snapshot; item-level audit not re-performed — see caveat).

### 3.2 W1 — Shared operational core (ENG-013–060) — IN-PROGRESS, final stage

Detailed plan: `hidden_files/w1-implementation-plan.md` (10 slices; do not duplicate it here). At plan date (2026-11-07) its gap map read: **1 live** (ENG-017 Operator MFA), **9 partially live** (all in the Platform block ENG-013–024), **38 not started**. Since then, per lane reports + memory: Slice 1 foundation + **Slice 1b provisioning path COMPLETE and proven live on the staging pairing** (`hidden_files/team-slice1b-provisioning-path.md`); Slices 2, 3, 5, 6, 7, 8, 9 **local phases complete** (`hidden_files/team-slice2-platform.md`, `team-slice3-membership.md`, `team-slice5-finance.md`, `team-slice6-assets-fx.md`, `team-slice7-supply.md`, `team-slice8-commerce.md`, `team-slice9-pos-portal.md`); Slice 4 built locally + integrated as a release candidate (`team-slice4-support.md`, `team-slice4-integration.md`); bench waves ran against the staging pairing (`team-bench-wave-a…d.md`, `team-slice6-bench.md`); the **Rektrs pilot completed end-to-end** 2026-11-08 (settlement → daemon-claimed publication → Stage 8 SSO sign-in → Stage 9 close-out, `MEMORY.md`).

**What remains — the wave gate:** (1) the **demo2 run** (demo2 remains `requested`/untouched: plan Business, pricing approved, email verified; no site, no invoices — `MEMORY.md`); (2) **Slice 10** = ENG-060 Commerce UAT + the pilot gate + accountant sign-off + ACC-18 (`memory/2026-11-08.md` forward queue). Until both land, W1 is **not closed** and no ENG-level closure count beyond the plan-date gap map is claimed here — slice-local completions are build evidence, not wave-gate evidence.

Compact roster (CSV titles): **Platform** ENG-013 OIDC session security · ENG-014 Identity linking · ENG-015 Tenant membership · ENG-016 Role and branch policy · ENG-017 Operator MFA · ENG-018 Support access · ENG-019 Private attachment · ENG-020 Job tenant context · ENG-021 Search isolation · ENG-022 Export authorization · ENG-023 Security audit trail · ENG-024 Secret vault references. **Finance** ENG-025 Company and fiscal setup · ENG-026 Chart of accounts · ENG-027 Decimal and rounding · ENG-028 Sales posting · ENG-029 Purchase matching · ENG-030 Payments allocation · ENG-031 Credit and return · ENG-032 Bank reconciliation · ENG-033 Period close · ENG-034 Fixed assets · ENG-035 Multi-currency · ENG-036 Financial close report. **Supply** ENG-037 Item and unit model · ENG-038 Warehouse scoping · ENG-039 Serial reservation · ENG-040 Batch expiry · ENG-041 Stock valuation · ENG-042 Replenishment draft · ENG-043 Landed costs · ENG-044 Picking and delivery · ENG-045 Stock count · ENG-046 Supplier returns · ENG-047 Transfer in transit · ENG-048 Inventory reporting. **Commerce** ENG-049 CRM qualification · ENG-050 Quotation revision · ENG-051 Pricing engine · ENG-052 Promotion conflicts · ENG-053 Credit limits · ENG-054 POS shift · ENG-055 POS device pairing · ENG-056 Sales return policy · ENG-057 Customer portal · ENG-058 Sales approvals · ENG-059 Commission calculation · ENG-060 Commerce UAT.

### 3.3 W2 — Pakistan country pack (ENG-061–096) — PLANNED

Detailed plan: `hidden_files/w2-pakistan-plan.md` (8 slices + standing operation; do not duplicate it here). Binding owner rules that reshape the blueprint's W2: FBR digital invoicing only through a **licensed integrator**; the STGO 01/2026 correction window is **72 hours**; and per the **service-provider principle** (Assad, 2026-11-07 14:39 PKT) + **integration standard** (2026-11-07 14:47 PKT), every W2 pack is a credential-per-tenant, self-service, validate-or-error module — the tenant brings their own credentials and owns compliance (`MEMORY.md`).

**36-item compressed table** (id + title from the CSV; status from the W2 plan's gap map, §2 of `hidden_files/w2-pakistan-plan.md` — assessed against the state after W1 completes):

| ENG | Title | Status | ENG | Title | Status |
|---|---|---|---|---|---|
| ENG-061 | Pack manifest schema | Not started | ENG-079 | Backfill checkpoint | Not started |
| ENG-062 | Dependency resolver | Not started | ENG-080 | Gateway settlement | Partially live |
| ENG-063 | Pack artifact trust | Not started | ENG-081 | Manual bank approval | **Live** |
| ENG-064 | Entitlement contract | Not started | ENG-082 | Messaging delivery | Partially live |
| ENG-065 | Configuration precedence | Not started | ENG-083 | Hardware adapter | Not started |
| ENG-066 | Workflow versions | Not started | ENG-084 | Integration health | Not started |
| ENG-067 | Installation checkpoint | Not started | ENG-085 | Country profile schema | Not started |
| ENG-068 | Pack compatibility matrix | Not started | ENG-086 | Pakistan sandbox | Not started |
| ENG-069 | Pack migration rehearsal | Not started | ENG-087 | Pakistan invoice cases | Not started |
| ENG-070 | Pack retirement | Not started | ENG-088 | Pakistan service scope | Not started |
| ENG-071 | Tenant extension review | Not started | ENG-089 | Country tax rule version | Not started |
| ENG-072 | Capability status registry | Not started | ENG-090 | Authority transport | Not started |
| ENG-073 | Transactional outbox | Not started | ENG-091 | Fiscal correction | Not started |
| ENG-074 | Consumer inbox | Not started | ENG-092 | Certificate rotation | Partially live (pattern only) |
| ENG-075 | API idempotency | Partially live | ENG-093 | Regulatory source review | Not started |
| ENG-076 | Webhook security | Partially live | ENG-094 | Compliance reporting | Not started |
| ENG-077 | Connector installation | Not started | ENG-095 | Regulatory outage | Not started |
| ENG-078 | Sync ownership | Not started | ENG-096 | Country release gate | Not started |

**Counts as written:** 36 total — **1 live** (ENG-081, shipped in R4.1: notices stay `pending_verification` until `operqon:billing_approver` verifies/rejects with a recorded reason), **5 partially live per-item** (ENG-075, 076, 080, 082, 092 — the W2 plan's own summary groups these as 4, counting 075/076 as a pair, and gives the remainder as **~31 of 36 not started**, including the entire country-compliance block ENG-085–096).

---

## 4. THE ADDED TRACKS (not in the blueprint CSV)

*Labelled as programme additions. Each carries its decision date and source; none of these appear in `engineering/delivery-backlog.csv`.*

### 4.1 Phase C — own-product track (Zoho-style end-state)
- **Decision:** owner end-state set 2026-11-08 13:41 PKT ("complete Zoho style… no surface anywhere reveals ERPNext/Frappe"); sequencing approved on the coordinator's recommendation 2026-11-08 14:39 PKT; bounded fork authorised 2026-11-08 13:37 PKT (`MEMORY.md`). Route: Phase A census (24 surfaces, done) → Phase B bounded fork (register: 8 patches) → Phase C own frontend progressively replacing the Desk.
- **C1 own workspace set — ✅ DONE + LIVE:** 11 Operqon workspaces built 2026-11-08; after the oc11 bench failure (workspace write defect) the oc12 cycle fixed it via the document API, passed the full §5 bench checklist, swapped the pairing oc10 → oc12, and the Rektrs site update made C1 live on the pilot tenant 2026-11-08 ~23:17 PKT (`memory/2026-11-08.md`, `hidden_files/team-oc12-cycle.md`, `team-rektrs-c1c3-update.md`).
- **C3 own first-run — ✅ DONE + LIVE:** 5-step first-run (Company → Customer → Item → Invoice → Payment) built with C1 and proven behaviourally in the oc12 checklist (steps flip as real documents are created); live on Rektrs with C1 (same sources).
- **C6 /attribution patch — ✅ DONE, with a follow-up owed:** fork patch `08-attribution-operqon-only.patch` (+7/−0) rendered PASS per user class in oc12 — **follow-up:** Frappe's website page cache for that page is not per-user, so the patch must be extended with `no_cache` in the **next** image cycle (recorded in the oc12 report; not an oc12-scope item).
- **C4 Operqon POS — planned next** in the Phase C sequence (M effort per the branding report roadmap). **C2 own admin/settings surface — planned last, phased** (XL). **C5 URL/asset-path de-branding — deferred** with periodic review (XL, high regression risk).
- **2026-11-09 acceleration:** the owner's verdict (below, §4.2) promotes the own-frontend end-state from "phased later" to the headline programme — the own ERP frontend on the engine's APIs, Desk progressively removed from tenant view (`memory/2026-11-09.md`).

### 4.2 Console + login/signup redesign v2
- **Background:** console modernization Phase 1 (design-system refinement, F-0…F-9 + P0 + validation) **deployed + verified live 2026-11-09 ~00:10 PKT** (marker `6bd1cbe1…`; `memory/2026-11-09.md`). The owner then **rejected the claim that this is a new design** (2026-11-09 ~00:20 PKT): the direction changed zero token values, login/signup were never in scope (console login = Keycloak's page; signup = portal/public flow, both untouched), and the tenant ERP still reads as ERPNext. Standing correction recorded: never present a refinement as a redesign; a design change counts only if visible at first glance, approved via screenshots **before** building.
- **v2 state:** the corrective lane **Design Directions v2** has delivered its artefacts — two genuinely distinct directions (AURORA dark / MONOLITH light), each covering the tenant ERP own-frontend vision (home, invoice list, invoice form), the provider console, and the never-designed **login page**; 16 PNG renders (1440 + 390) + index in `files/design-directions-v2/`, report `hidden_files/team-design-directions-v2.md`. **Build starts only after the owner's pick.** demo2 is parked behind this decision (§5). *(Amendment, 2026-11-09 ~00:40 PKT: Directions v2 was REJECTED by the owner at 00:32 PKT as not matching his given designs ("basic html CSS") and is superseded by **Design Directions v3** — reference-mirrored rich renders (Direction A "Obsidian Gold" ← Behance AI CFO/Orven + the owner's #5 language; Direction B "Nova Clarity" ← Behance Nova Analytics) in `files/design-directions-v3/`, report `hidden_files/team-design-directions-v3.md`. The pick is now on v3.)*

### 4.3 R4.2 gateways — Easypaisa + PayFast
- **Built:** credential-free preparation complete 2026-11-07 — adapters, endpoints wiring, config spec, 32 tests passed; no schema change; catalogue strings stay `merchant_contract_required` until sandbox E2E + live verification (`hidden_files/team-gateways-r42.md`).
- **Entry mechanism (owner decision 2026-11-07 10:26 PKT):** merchant credentials are entered via a **console settings page** (write-only fields → encrypted at rest → masked read-back → audit-logged), not env files; the gateway-settings build followed (`hidden_files/team-gateway-settings.md`).
- **Status: blocked-on-owner-or-bank** — the only missing inputs are the merchant accounts/credentials themselves (bank-side onboarding). Phase-2 gateways (NayaPay Business, Xstack) remain catalogue-only per the handover's decided facts.

### 4.4 Fixture cleanup
Owner-endorsed 2026-11-07 22:59 PKT: **all** testing tenants/payments/notices are deleted after the pilot, audit trail preserved (`memory/2026-11-07.md`). The post-pilot release's fixtures (pp1 suspended, pp2 pending-notice, pp3 published) joined the queue 2026-11-08. **Status: planned/queued** — it appears in the 2026-11-09 programme queue ("demo2 → Slice 10 → W2 / C4 / fixture cleanup", `memory/2026-11-09.md`).

### 4.5 Billing shadow POC — Lago vs Kill Bill (after W1)
Kill Bill decision (Assad, 2026-11-08, `MEMORY.md`): do **not** adopt Kill Bill now; after W1 closes, run a **shadow POC** (headless, behind the Operqon console/portal; Operqon remains pricing-approval/audit/provisioning authority) and adopt only if it beats the current billing flow on recurring/automated payments, proration, dunning and reconciliation. Lago was assessed 2026-11-08 as the stronger UI/flexibility candidate (AGPLv3; not a payment processor) — the coordinator's recommendation, recorded in `memory/2026-11-08.md`, is to test **Lago vs Kill Bill in the same POC**. **Status: planned, gated on W1 closure. No adoption decision exists.**

### 4.6 `/tenant-queue` billing-gate backend follow-up
Found during console F-8 (forms/picker): in production, `GET /tenant-queue` is gated to operator/approver/auditor — **billing receives 403**, so the invoice-create tenant picker degrades to the typed input for its primary user. Named backend follow-up (frontend must not widen an API gate on its own): widen the queue read gate for billing **or** add a billing-readable minimal tenant directory (`hidden_files/team-console-f8-forms-picker.md` §Role gate; carried as item **B-01** in `hidden_files/team-console-validation.md`). **Status: planned — needs a backend release slot.** Note the frozen 7-key tenant-queue contract (handover hard rule 1) constrains any fix: the response shape must not change.

---

## 5. CURRENT SEQUENCE (as of 2026-11-09)

Per the owner's redirect of 2026-11-09 ~00:20 PKT (`memory/2026-11-09.md`):

1. **Design / own-product first** — owner picks a direction from Design Directions v3 (v2 rejected by the owner 2026-11-09 00:32 PKT — see the §4 amendment; screenshots before build); then the own tenant frontend on APIs becomes the headline build, with the console visual redesign v2 + login/signup surfaces in the same programme.
2. **demo2 run + Slice 10** — closing W1 (the pilot gate: 3rd pilot business leg, accountant sign-off, ACC-18).
3. **W2 build** — Pakistan pack per `hidden_files/w2-pakistan-plan.md` (Slices 0–8), under the service-provider + integration-standard rules.
4. **W3 industry pilots** — per §2.1 (with the F2 Saudi gap resolved by amendment or a separate track before W3 can be called closable).
5. **W4 launch hardening** — per §2.2, consuming the pre-builds mapped there instead of rebuilding them.

**Which blueprint dependencies this respects:**
- W2 still starts only after the W1 core exists (CSV: every W2 item depends on "Core modules" / "Finance and integration") — respected; only W1's *final gate* (Slice 10) is sequenced after the design step, not W2's dependency.
- W3 still waits for "Released core and pack platform" and W4 for "Working pilots" (CSV) — respected.
- The governance rule that real paid operations run only where country/fiscal gates pass (`engineering/04` §7) — respected; nothing in the re-sequence sells W2/W3 scope early.

**Which it deliberately reorders, and why:**
- **Design/own-frontend before W1's close.** The blueprint contains no design/own-frontend wave at all; Phase C was already an owner-added track (2026-11-08). The 2026-11-09 redirect parks demo2 behind the design pick because the owner judged the shipped surfaces "the same design" and the tenant ERP recognisably ERPNext, and demanded the own API-driven product as the headline. Reason recorded verbatim in `memory/2026-11-09.md`; the standing correction (screenshots approved before building) governs the lane.
- **Phase C pieces already jumped the queue once:** C1/C3/C6 shipped live (oc12, 2026-11-08) *before* Slice 10 closed W1 — a deliberate reorder executed under the owner's 2026-11-08 Zoho end-state decision, not an accident.
- **Console modernization Phase 1 vs its v2:** Phase 1's deploy (2026-11-09 00:10) preceded the owner's verdict by minutes; v2 now re-opens a surface the programme had marked closed. Recorded honestly rather than smoothed over.

---

## 6. INTEGRITY RULES (how this document was kept honest)

1. **Every ENG item appears exactly once, under its CSV wave.** ENG-001–012 in §3.1, ENG-013–060 in §3.2, ENG-061–096 in §3.3, ENG-097–108 in §2.1, ENG-109–120 in §2.2. Total = 120 = the CSV's row count. Added tracks (§4) carry **no** ENG numbers, so nothing is double-counted.
2. **Statuses are claimed only where a source evidences them** — a lane report, a memory entry, or the handover. Everything else is written as "not started" or "UNVERIFIED". In particular: W0 is claimed complete at *wave level* on the recorded snapshot's authority, with its per-item caveat stated in §3.1; W1 slice completions are reported as build evidence, not as ENG closures; W3 items are all "not started" because no source evidences otherwise.
3. **The W5 finding is stated as found** (§2.3): defined as a wave row (`engineering/04` §1) and as a country programme (`compliance/02`, `compliance/05`); **absent** from the delivery-backlog CSV; traceability parks three requirements at W5 (REQ-012/017/019, all "Not claimed") with no ENG itemisation. No W5 items, dates or percentages were invented for it.
4. **Blueprint-vs-reality overlaps are mapped, not double-planned** — §2.2's table for W4 (backup, restore, observability, canary practice, exit foundation) and §2.1's notes for W3.
5. **Blueprint-internal contradictions are flagged, not resolved silently:** F2 (W3's §1 Saudi scope has no CSV items) and F3 (W4's §1 GCC/pharmacy/manufacturing scope has no CSV items). Two lesser ones ride along: the W2 plan's non-goals table repeats F2's wrong ENG range for Saudi; and `MEMORY.md`'s blueprint-contents line says "waves W0–W5" for a 120-item backlog that in fact spans W0–W4 only.
6. **No invented scope, dates or percentages.** Effort ranges are the blueprint's own planning assumptions (`engineering/04` §§1–2, which themselves assume a 5–7-person team — calendar expectations must be re-based, per the W1 plan's Risk R6). The only programme-wide percentage in this document is the owner's recorded **~35–40%** estimate (§header), reproduced as a recorded estimate, not computed here.
7. **CSV risk column honesty:** the CSV carries only a level per item (W3 `high`, W4 `critical`); narrative risks in §2 are sourced from `engineering/04` §5 and labelled as such. Sequencing *inside* W3/W4 is labelled as derivation wherever the CSV gives only a flat dependency.

*End of plan. Companion lane report: `hidden_files/team-phase-wise-plan.md`.*
