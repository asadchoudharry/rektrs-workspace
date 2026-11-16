# Cursor Board Findings — Adoption Decision (2026-11-14)

**Branch:** `docs/adoption-decision-20261114`  
**Tip judged against:** `cfd670f` (`release`, source gate VERIFIED; alembic head `0025_country_plan_additional_seat`)  
**Live host judged:** srv1322702 (Operqon provider box) — **7.7 GiB RAM / 2 vCPU / 96 G disk (~19% used)**  
**Boundaries honored:** decision + planning only. No implementation, no deploy, no production change, no merge.  
**Not mid signup-audit:** this Cursor run was on release/seat/OS-27 work; the atomic adoption deliverable is this document.

---

## 0. Cursor board constitution (mirrors TORs)

| Seat | Role in this judgement |
|---|---|
| **Chair — Chief Architect** | Synthesises ACCEPT / MODIFY / REJECT against tip `cfd670f`, live containers, and the remaining roadmap. |
| **Security & Governance** | Veto retained on money/SoD/audit moves into panel or sidecars. |
| **Single-Server Load & Ops** | Re-issues the ledger from measured host state; holds the Postiz-fold and KVM-step vetoes. |
| **Frappe / Tenant-Tier** | Judges bench-pack sequencing against the pinned-image pipeline (no silent AGPL forks). |
| **Money & Billing** | Judges Kill Bill / gateways / owed-work against **live** seat-overage + dunning code. |
| **Future SaaS & Ecosystem** | Judges Postiz/Dokploy, School/RAG onboarding pattern, project separation. |
| **Red-Team Critic** | Argues against every boarding that collides with in-flight roadmap or burns the only box. |

**Decision rule:** evidence from tip code, live timers/containers, and HANDOVER / ops state — not the external Board's confidence. Where a Board claim cannot be verified here, it is marked **UNVERIFIED**.

**Verdict shorthand for each of the Board's 58 rows:**

- **ACCEPT** — Board decision stands; conditions/triggers stand.
- **MODIFY** — Direction stands, but scope, sequencing, or facts must change against real progress.
- **REJECT** — Cursor board does **not** endorse the Board's decision as written (rare; usually means the Board over- or under-stated readiness).

---

## 1. Executive verdict

The external Board's architecture under §0 (one server until 30 paying clients **or** $2,000/mo) is **largely sound**. Cursor **accepts the shape**: provider API remains the brain; Kill Bill stays out; SigNoz/Kestra stay out; ServerKit only inside a VM guest; Postiz fold only after KVM 4; light pack before medium pack; off-box uptime as the sole §0 exception.

Three **material corrections** change planning:

1. **Audit is already HMAC-chained in tip** (`releases/operqon-provider-r2/app/audit.py` — `append_audit` / `verify_chain`). C10 is **not** a greenfield hash-chain build; remaining work is DB-role/trigger hardening, B2/R2 Object Lock checkpoints, off-box verifier, pgaudit, and the DBA-attack simulation. Until those pass, language stays **"append-only + HMAC-chained by application design; WORM / DBA-resistant hardening incomplete"** — not "immutable".
2. **restic → object storage is already operating** (timers for provider / Keycloak / sites / Rektrs; console Backups panel; HANDOVER restore proofs to **Cloudflare R2**, bucket `erp-saas-backups`). A2's remaining adoption is **discipline**: whole-server inventory (incl. panel/Postiz when folded), a **timed restore-into-isolation drill this cycle**, and clarifying B2-vs-R2 / Object Lock. Board wording "restic → B2" is treated as **object-store offsite** unless the owner explicitly wants Backblaze B2 instead of the live R2 path.
3. **Billing owed-work is narrower than the Board priced.** Seat overage (OS-20…23) is **live on tip** (`seat_overage`, public plans, invoice lines, alembic `0025`). **Dunning policy SoD** already exists (`app/dunning.py`, ~590 LOC). Kill Bill DEFER stands harder, not softer. Remaining Money debt: gateway thin clients (credential-gated), webhook/recon, proration/coupons completion, tax-line, lifecycle edges — **not** a 25–38 day greenfield billing rewrite.

**Live load fact the Board understated as a trigger:** this host already shows **~1.4 GiB swap used** at idle (~2.8 GiB RAM used of 7.7). Under the Board's own Step-1 rule ("any swap use in 7 days"), **KVM 4 is already indicated** — but Postiz is **not** on this host yet, so the Board's ~9.5 GB *folded* peak remains a planning ESTIMATE, not today's coincident peak.

**Roadmap collision rule (Chair):** no adoption boarding that races **OS-27 release→main**, the **simple-signup journey audit**, or parked owner-gated items (OS-19 MFA, oc31 STRICT, #56, #55 full) until those atomic steps clear or the owner re-prioritises.

---

## 2. Per-decision table (all 58)

### 2.1 ADOPT (Board A1–A4)

| ID | Component | Cursor | Reason tied to real state |
|---|---|---|---|
| **A1** | Apprise (embedded) | **ACCEPT** | Zero-rent library; no tip conflict; substrate for C17. Board only as embedded — sidecar stays a separate future row. |
| **A2** | restic → offsite whole-server discipline | **MODIFY** | **Already partially live** (restic→Cloudflare R2; `operqon-backup-status.timer` hourly; DB/site/Keycloak/Rektrs backup timers; console Backups panel). Accept the *discipline* remainder as Phase 0 gate: full inventory, timed restore-into-isolation this cycle, re-drill after each KVM step. Object Lock / separate WORM credentials remain **UNVERIFIED** on the live R2 path. Prefer keep R2 unless owner mandates Backblaze B2 migration. |
| **A3** | Frappe v16 Print Format Editor | **ACCEPT** | Correct replacement for archived Print Designer (R3). Zero install. Sequence with Phase 4 tenant pack + guidance update only. |
| **A4** | External SMTP relay | **ACCEPT** | Correct vs Postal (D6). SPF/DKIM/DMARC before first production send. Sequence after OS-27 / before or with Phase 1 fold — not before survival inventory. |

### 2.2 ADOPT WITH CONDITIONS (Board C1–C19)

| ID | Component | Cursor | Reason |
|---|---|---|---|
| **C1** | ServerKit panel | **ACCEPT** | Containment design (VM guest, own dockerd, 20 GB quota, prune lockout, ProxyStack never) is the only safe one-box panel. **MODIFY sequencing only:** Phase 0 pilot **after** measured baseline + backup drill, and **must not** collide with OS-27 / signup-audit. If pilot fails VM proof → DEFER to split (Board condition stands). Red Team: guest overhead (~0.5 GB) on today's 7.7 GiB is hostile — pilot may be throwaway/off-peak; production panel waits for **KVM 4**. |
| **C2** | ServerKit agent (host) | **ACCEPT** | Monitor-only + Observed mode; explicit `--level`; Protect/Full vetoed. `inspect` secret exposure needs written acceptance before first use. |
| **C3** | ServerKit extension (face) | **ACCEPT** | Face only; provider API stays brain. W2 after JWKS + SoD test + C10 *remaining* gates. Console fallback until 90-day soak (Chair ruling stands). |
| **C4** | Beszel + Dozzle | **ACCEPT** | Needed measurement instrument. Read-only Docker posture; behind OAuth2 Proxy/Keycloak. Board early in Phase 0 — Cursor allows **Beszel alone first** if Dozzle SSO glue lags. |
| **C5** | Prometheus + VictoriaLogs + Perses | **ACCEPT** | Headroom-gated at KVM 4; never beside GlitchTip. Order after Flagsmith pilot in the medium queue; slip to KVM 8 if measured peak breaches 70%. |
| **C6** | Gotenberg (capped) | **ACCEPT** | Hard caps required (`mem_limit`≈768 MB, concurrency=1, no outbound fetch). WeasyPrint remains default. Do **not** board until after baseline — uncapped Chromium on a swap-stressed box is an OOM weapon. |
| **C7** | Uptime Kuma **off-box** | **ACCEPT** | Sole recommended §0 exception. Owner must explicitly approve off-box placement. On-box-only Kuma rejected. |
| **C8** | OAuth2 Proxy | **ACCEPT** | Cheapest SSO glue for Beszel/Dozzle-class tools. One-login test is binary. |
| **C9** | BookStack | **ACCEPT** | After Flagsmith in KVM 4 queue; own MariaDB; slips if headroom fails. Git runbooks remain interim. |
| **C10** | Hash-chained audit + Object Lock | **MODIFY** | **HMAC chain already in tip** (`audit.py`). Accept remaining build as Phase 0/2b gate: INSERT/SELECT-only role, append-only trigger, signed WORM checkpoints (R2/B2 Object Lock under separate credentials — **UNVERIFIED today**), off-box verifier, pgaudit, **DBA-attack simulation must pass**. Withdraw "immutable" until then (Board Chair rule stands). Do **not** block OS-27 or seat-stack closeout on C10 completion. |
| **C11** | ERPNext HRMS | **ACCEPT** | Phase 4; payroll-ready only after C15. |
| **C12** | Frappe Helpdesk (tenant) | **ACCEPT** | Optional per-tenant pack; AGPL vanilla-or-publish. Platform support stays Issues inbox (not R10). |
| **C13** | Frappe Payments (tenant) | **ACCEPT** | Does not close provider PK gateway gap (C16). |
| **C14** | Frappe Wiki (tenant) | **ACCEPT** | Distinct from BookStack (C9). |
| **C15** | PK payroll config pack | **ACCEPT** | Build config over vanilla HRMS; expert + parallel-run gate. |
| **C16** | PK gateway thin clients | **MODIFY** | Direction correct (build Easypaisa/PayFast thin clients; manual SoD path never removed). **Trigger includes owner credential availability** — sandbox cannot go live without merchant creds. Sequence in Phase 3 after survival + KVM 4, not before. |
| **C17** | SMS via Apprise | **ACCEPT** | SMS Gate proof exists (Board MEMORY 2026-11-13 — treat as prior evidence; re-verify credentials in vault before production). Rides A1. |
| **C18** | Dokploy retained for Postiz + P-1…P-8 | **ACCEPT** | One manager per scope. Fold **vetoed until KVM 4**. Collision rules are mandatory before any fold; the 2026-11-14 `COMPOSE_PROJECT_NAME` incident class is designed out, not remembered out. |
| **C19** | Future-product onboarding pattern | **ACCEPT** | Own API/DB per product; single staff realm; provider holds commercial link only. Spec authoring is cheap now; deployer pilot deferred. |

### 2.3 PILOT FIRST (Board P1–P9)

| ID | Component | Cursor | Reason |
|---|---|---|---|
| **P1** | Flagsmith | **ACCEPT** | Gate 0 = free-tier OIDC evidenced or automatic REJECT (V3). Gate 1 = canary config flags cannot do. First in KVM 4 medium queue after light pack. |
| **P2** | Frappe CRM | **ACCEPT** | Coexistence pilot with ERPNext CRM on v16 required. |
| **P3** | Frappe Insights | **ACCEPT** | Shared MariaDB query governance under load is the gate. |
| **P4** | Frappe Builder | **ACCEPT** | Theme/token + no per-tenant image divergence. |
| **P5** | Frappe Webshop | **ACCEPT** | v16 compatibility UNVERIFIED → pilot or DEFER. |
| **P6** | XPOS | **ACCEPT** | Pinned stable only; `develop` banned; offline/sync/hardware gates. |
| **P7** | pakistan_tax (FBR) | **ACCEPT** | Bake-off vs P8 in sandbox; maturity priced into gate, not veto. |
| **P8** | kodlyft/di (FBR) | **ACCEPT** | Pre-check Python ≥3.14 vs bench Python **before** effort. |
| **P9** | RAG (pgvector-first) | **ACCEPT** | Named consumer gate; no speculative board. |

### 2.4 DEFER (Board D1–D15)

| ID | Component | Cursor | Reason |
|---|---|---|---|
| **D1** | Kill Bill | **ACCEPT (stronger)** | Live tip already invoices **plan + seat overage** under governed pricing; dunning SoD exists. JVM + second billing truth fails need-truth *and* load on KVM 2/4. **MODIFY owed-work list:** reprice downward — dunning is not greenfield; meter nothing (no metered product). Keep: gateway webhooks/recon (with C16), narrow proration, coupons completion, tax-line, lifecycle edges. Re-entry trigger unchanged (§0 split / metered product / catalogue complexity). |
| **D2** | Apache Superset | **ACCEPT** | KVM 8 + reporting need beyond widgets; never live DB fan-out. |
| **D3** | Activepieces | **ACCEPT** | Named non-critical glue + KVM 8; never billing/provisioning paths. |
| **D4** | Novu | **ACCEPT** | Ornament at current volume; Apprise first. Measure at Phase 3 review. |
| **D5** | Chatwoot | **ACCEPT** | Platform tier only on trigger; Gate 0 = SSO/licence of exact build. Issues inbox interim. |
| **D6** | Postal | **ACCEPT** | Tenant-serving IP must not become mail IP. A4 is the path. |
| **D7** | Pluton | **ACCEPT** | Free edition is local UI; PRO is commercial. A2 discipline first. |
| **D8** | WeasyPrint as co-equal second engine | **MODIFY** | WeasyPrint is already the **incumbent default** in-process; Board correctly keeps one *escalation* engine (C6). Cursor clarifies: **do not remove WeasyPrint**; D8 means "do not run two engines as co-equals," not "defer WeasyPrint itself." |
| **D9** | pgBackRest | **ACCEPT** | After A2 drill proves RPO gap. |
| **D10** | Gatus | **ACCEPT** | Do not dual-run with C7. |
| **D11** | Tessera | **ACCEPT** | C10 remainder covers need. |
| **D12** | Frappe LMS | **ACCEPT** | School product / named tenant trigger (C19), not a casual bench add. |
| **D13** | GlitchTip | **ACCEPT** | Joins C5 shape only on proven need — never a second observability shape. |
| **D14** | SkyWalking | **ACCEPT** | SSO paper first; no named trace incident today. |
| **D15** | Postiz full migration off Dokploy | **ACCEPT** | Scope ruling (C18) already solves the one-host problem; migration waits for split. |

### 2.5 REJECT (Board R1–R11)

| ID | Component | Cursor | Reason |
|---|---|---|---|
| **R1** | SigNoz | **ACCEPT** | SSO enterprise + ClickHouse weight — either ground suffices under §0. |
| **R2** | Kestra | **ACCEPT** | JVM duplication + KEV CVE history — out under §0. |
| **R3** | Frappe Print Designer | **ACCEPT** | Archived; A3 replaces. |
| **R4** | UniVenture `fbr_digital_invoicing` as install | **ACCEPT** | Reference-only during P7/P8 bake-off. |
| **R5** | POS Awesome | **ACCEPT** | Stale vs v16; P6 is the POS path. |
| **R6** | Appsmith | **ACCEPT** | Free tier gates SSO — V3 automatic. |
| **R7** | VortexPanel | **ACCEPT** | No SSO; licence file gap; does not beat ServerKit on evidence. |
| **R8** | Trillian | **ACCEPT** | Disproportionate vs C10 remainder. |
| **R9** | procrastinate | **ACCEPT** | Noise vs existing worker / Frappe RQ. |
| **R10** | Standalone provider Helpdesk bench | **ACCEPT** | Full bench rent, no ERP context; support ruling stands. |
| **R11** | Licence/fit register (grouped) | **ACCEPT** | n8n / immudb / Graylog / Outline / Flipt / Unleash / Invoice Ninja / Lago / Flexprice / UniBee / Frappe Drive / unlicensed `FBR-Pakistan` / OneUptime — Cursor did not re-trace every LICENSE file in this pass; Board Chair traces stand as **provisionally accepted**. Any future re-proposal must attach the LICENSE file itself. |

### 2.6 Count summary (Cursor on Board rows)

| Cursor judgement | Count |
|---|---|
| ACCEPT | 52 |
| MODIFY | 6 (A2, C1 sequencing note folded into ACCEPT+seq, C10, C16, D1 owed-work, D8 clarification) — **explicit MODIFY rows: A2, C10, C16, D1, D8,** plus **C1 production timing** |
| REJECT of Board decision | **0** |

No Board row is overturned to the opposite adoption class. Corrections are fact/sequence/scope, not architecture reversals.

---

## 3. Final adoption set (owner-approvable)

### 3.1 Adopt now (planning-approved; execution waits for owner + Phase 0 gates)

| Class | Items |
|---|---|
| **Embedded / zero-rent** | A1 Apprise (library), A3 Print Format Editor (already in Frappe), incumbent WeasyPrint (not a new board) |
| **Discipline / gates (no new heavy process)** | A2 restic offsite inventory + restore drill; C10 *remaining* WORM/DBA hardening |
| **Light pack (after baseline; still on KVM 2 only if caps + swap improve)** | C4 Beszel (+ Dozzle), C8 OAuth2 Proxy, C6 Gotenberg capped, C7 Uptime Kuma **off-box**, A4 SMTP relay (Phase 1) |
| **Pilot only (throwaway / non-prod)** | C1/C2 ServerKit containment pilot (production deferred to KVM 4) |

### 3.2 Adopt on KVM 4 (Phases 1–2, headroom-gated)

- C18 Postiz fold under Dokploy + P-1…P-8  
- C1/C2 ServerKit **production in VM guest** (iff pilot passed)  
- P1 Flagsmith pilot → decision  
- C5 Apache observability stack  
- C9 BookStack  
- C3 extension read-only; **2b** write path after JWKS + SoD + C10 remainder  

### 3.3 Adopt later (Phases 3–4)

- C16 PK gateways (credential-gated), C17 SMS, Money owed-work (repriced)  
- C11–C15 + C12 optional; A3 guidance  
- P2–P8 tenant pilots / FBR bake-off; P9 only with named consumer  
- C19 School `serverkit.yaml` spec anytime (cheap); deploy pilot deferred  

### 3.4 Deferred / rejected (do not board under §0)

- **DEFER:** D1–D15 as Board wrote (with D1/D8 clarifications above)  
- **REJECT:** R1–R11 as Board wrote  
- **Never on this box under §0:** SigNoz, Kestra, Chatwoot, Novu, Postal (as co-resident)

---

## 4. CLEAR FINAL STACK (one page)

```
                    ┌──────────────── ONE SERVER (§0) — Hostinger KVM ────────────────┐
 Internet ──► Caddy (sole edge 80/443)                                                 │
                ├─ Provider API + worker ──► Provider PostgreSQL                       │
                │     BRAIN: tenants, governed pricing, SoD, seat overage (live),      │
                │            dunning policy (live), audit_events (HMAC-chained live;   │
                │            WORM/DBA hardening = C10 remainder)                       │
                │     ├─ Apprise (A1) ──► SMS (C17, Phase 3)                           │
                │     └─ Gotenberg (C6, hard-capped, concurrency=1)  [escalation PDF]  │
                ├─ Keycloak (single staff realm; per-product OIDC clients)             │
                ├─ ERPNext bench(es) — pinned images only                              │
                │     Phase 4 pack: HRMS, Payments, Wiki; optional Helpdesk            │
                │     Print: v16 built-in editor (A3)                                  │
                ├─ Postiz scope (AFTER KVM 4): Dokploy = sole Docker owner (C18)       │
                │     ServerKit Observe-only; rules P-1…P-8                            │
                ├─ VM GUEST (AFTER pilot + KVM 4): ServerKit panel (C1)                │
                │     own dockerd / socket / 20G quota; host agent Monitor-only (C2)   │
                │     extension = face only (C3); console fallback ≤90d soak           │
                └─ Light sidecars (capped, Keycloak/OAuth2 Proxy):                     │
                      Beszel+Dozzle (C4) → later Prometheus+VictoriaLogs+Perses (C5)   │
                      → BookStack (C9)                                                 │
 └─────────────────────────────────────────────────────────────────────────────────────┘

 OFF-BOX (always):
   • restic → Cloudflare R2 (live) + Object Lock / WORM checkpoints (C10 remainder; A2 drill)
   • Uptime Kuma primary (C7) — owner-approved §0 exception
   • External SMTP relay (A4)
   • Image builds: GitHub Actions → GHCR (never build on the box)

 STAYS OURS (not replaced):
   • Provider billing brain (no Kill Bill)
   • Manual bank-transfer + SoD verification (even after C16)
   • Provider Issues inbox = platform support SoR
   • Console until panel soak retires it
```

**Invariants (adopted as law):** V1 governance never leaves provider API/DB · V2 panel never shares dockerd with benches/Postiz · V3 no free-tier-gated SSO · V4 no sidecar log replaces `audit_events` · V5 no Protect/Full / socket-mount / remotely-promotable agent on tenant workloads.

**Split trigger (§0):** paying clients > 30 **or** recognised monthly revenue > $2,000 — measured from provider DB subscriptions + recognised revenue, reviewed monthly into `audit_events`.

---

## 5. Way forward — sequenced with *this* roadmap

### 5.0 Current roadmap (must not collide)

| Track | State (2026-11-14) | Rule vs adoption |
|---|---|---|
| Tip `cfd670f` / alembic 0025 / seat stack | **Done** | No further seat work required for adoption planning |
| OS-27 release→main | Branch pushed; **PR create form-blocked** | Finish/open when form works; **before** medium-pack boarding |
| Simple-signup journey audit | **Not started on this run** (owner still expects it) | Schedule as next product READY after OS-27 PR path, **before** Phase 3 channels |
| Parked: OS-19 MFA, oc31 STRICT, #56, #55 full | Owner-gated | Stay parked; not adoption blockers |
| Soft-block: PR create forms | Muse / Assad FF | Adoption docs-only on this branch until owner merges |

### 5.1 Phased plan (Cursor cut)

**Phase R — Roadmap hygiene (now → before any production boarding)**  
Effort: **1–3 eng-days** (process, not code adoption).  
- Close OS-27 PR when create-form unblocks; tip-sync discipline unchanged.  
- Run simple-signup journey audit as its own atomic track.  
- File monthly §0 trigger metrics stub (client count + recognised revenue) — can be a console/ops note until automated.  
- **No-regret:** reversible; docs and PR hygiene only.

**Phase 0 — Survival & measurement (today's KVM 2; planning-approved)**  
Effort: **5–10 eng-days** wall-clock depending on restore-drill scheduling.  
1. Beszel baseline 7 days (C4); re-issue ledger if off >25%.  
2. A2 whole-server inventory + **timed restore-into-isolation** (provider DB + one site + Keycloak + config; Postiz when in scope).  
3. C10 remainder design spike + DBA-attack simulation plan (implementation only after owner GO).  
4. Off-box Uptime Kuma (C7) — owner faisla on §0 exception.  
5. ServerKit **throwaway** pilot checklist (not production).  
6. Write KVM upgrade procedure into ops git (Board §5.2 — Cursor endorses verbatim).  

**Risks:** restore drill discovers inventory holes; swap already active → baseline may immediately fire KVM 4 trigger.  
**No-regret checks:** Beszel/Dozzle removable; Kuma off-box; pilot VM discardable; C10 remainder is additive (existing HMAC chain stays).

**Phase 1 — KVM 4 + fold (owner-funded upgrade)**  
Effort: **upgrade window + 3–6 eng-days** fold/verify.  
- Execute KVM 2→4 per written procedure (01:00–03:00 PKT).  
- Fold Postiz (C18) only after verify.  
- ServerKit production in VM guest **iff** pilot passed; else continue console+SSH.  
- SMTP relay (A4). Start Flagsmith pilot (P1).  

**Risks:** upgrade interruption; Dokploy project-name collision class; panel prune footgun if containment skipped.  
**No-regret:** snapshot rollback rule; Postiz stays on Dokploy (D15 not taken); panel can DEFER.

**Phase 2 — Face & observability (headroom-gated)**  
Effort: **8–15 eng-days** depending on extension widgets.  
- C3 read-only; C5 then C9 if peak ≤70% budget.  
- C19 School `serverkit.yaml` authored.  
- **2b** W2 only after JWKS + SoD + C10 remainder.  

**Phase 3 — Channels & money completion**  
Effort: **repriced ~15–28 eng-days** (was Board 25–38; dunning greenfield removed).  
- C16 sandbox→live when credentials exist; C17 SMS; coupons/proration/tax-line/lifecycle; gateway webhook/recon.  
- Flagsmith go/no-go; Novu trigger review (expect hold).  

**Phase 4 — Tenant pack**  
Effort: **multi-sprint**; image-pipeline only.  
- C11–C15, C12 optional, A3 guidance; P2–P8 pilots; FBR bake-off; payroll parallel-run.  

**Phase 5 — Re-judgement**  
- KVM 8 and/or §0 split: D1–D15 become *eligible*, not automatic.

### 5.2 Effort roll-up (planning bands)

| Band | Scope | Effort band |
|---|---|---|
| R | Roadmap hygiene (OS-27, signup audit scheduling) | 1–3 d |
| 0 | Survival gates + light instruments + SK pilot | 5–10 d |
| 1 | KVM 4 + Postiz fold + SMTP | 3–6 d + upgrade window |
| 2 | Extension RO + observability + BookStack | 8–15 d |
| 2b | W2 unlock (gates, not features) | 2–5 d after gates |
| 3 | Gateways + SMS + billing remainder | 15–28 d |
| 4 | Tenant pack + pilots | sprint-scale; separate estimates per pilot |

### 5.3 Top risks (Red Team)

1. **Swap already in use** — boarding Gotenberg or ServerKit guest on KVM 2 without upgrade invites OOM.  
2. **Calling audit "immutable" before C10 remainder** — governance false confidence.  
3. **Panel without VM boundary** — prune deletes rollback images (irreversible).  
4. **Postiz fold before P-1…P-8** — repeats the project-name incident class.  
5. **Adoption work racing OS-27 / signup audit** — splits the only builder attention on the only box.  
6. **Kill Bill revisit under sales pressure** — still fails load + dual-truth; owed-work is the answer.

### 5.4 No-regret checklist (owner can approve without fear)

| Check | Pass criterion |
|---|---|
| Reversibility | Every Phase 0 boarder is stoppable without data migration (except C10 additive columns/roles). |
| Exit | Provider DB remains SoR; panel/extension hold no governed truth. |
| Backup | A timed restore-into-isolation filed before KVM upgrade or Postiz fold. |
| Budget | Any boarder ships with Compose `mem_limit` / CPU / log rotation in the adoption PR. |
| SSO | No component whose free tier gates OIDC. |
| Sequence | OS-27 + signup-audit tracks stay ahead of Phase 3; parked MFA/oc31/#55/#56 stay parked. |
| Language | "Immutable" banned until DBA-attack simulation passes. |

---

## 6. Owner faislas requested (explicit)

1. **Approve or amend this Cursor cut** of the 58 decisions (especially MODIFYs on A2/C10/C16/D1/D8 and C1 production-after-KVM4).  
2. **Approve C7 off-box Uptime Kuma** as the sole §0 exception (or name an alternative off-box monitor).  
3. **Confirm offsite store:** keep live **Cloudflare R2** vs migrate to Backblaze B2 for A2/C10 Object Lock.  
4. **Fund KVM 4** when Phase 0 baseline confirms the already-visible swap trigger.  
5. **Do not merge this branch** until the way forward above is approved; execution is a separate owner GO.

---

## 7. Evidence appendix (this judgement)

| Fact | Evidence |
|---|---|
| Tip | `/opt/operqon-r2-github` @ `cfd670f` |
| Seat overage live | `app/seat_overage.py`, `main.py` invoice paths, alembic `0025_country_plan_additional_seat.py` |
| HMAC audit chain | `app/audit.py` (`append_audit`, `verify_chain`, `AuditHead`) |
| Dunning exists | `app/dunning.py` (~590 LOC), policy draft/publish SoD |
| Backup timers | `operqon-backup-status.timer`, `operqon-provider-backup.timer`, site/Keycloak/Rektrs timers |
| Console backups panel | `frontend/tenants.html` Backups panel copy; `app/ops_backups.py` |
| Offsite store | HANDOVER: restic → Cloudflare R2 `erp-saas-backups` |
| Live RAM/swap | `free`: 7.7 GiB total, ~2.8 GiB used, **~1.4 GiB swap used**; 2 vCPU; disk 18G/96G |
| Postiz not folded | `docker ps` on this host: provider r1/r2, Keycloak, MariaDB/Redis, console — **no Postiz/Dokploy** |
| Board inputs | `BRIEF-FROM-OWNER-2026-11-14.md`, `ADOPTION-BOARD-TORS-2026-11-14.md`, `ADOPTION-BOARD-REPORT-2026-11-14.md`, three consolidated reports |

---

*End of Cursor Board Findings. Decision + planning only. Awaiting owner approval before any implementation.*
