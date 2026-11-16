# OPERQON — PHASE-WISE PLAN v2 (complete blueprint v2, one document)

**Built:** 2026-11-10 · **Nature:** documentation only — no code, no server changes, no deploys.
**Owner:** Assad · **Programme:** Operqon multi-tenant ERP SaaS.
**Primary sources:** blueprint v2 at `hidden_files/blueprint-v2-extract/operqon-blueprint-v2/` (backlog: `engineering/delivery-backlog.csv`, 222 rows); the v2 review `hidden_files/team-blueprint-v2-review.md`; the v1 plan `files/PHASE-WISE-PLAN.md`; the W2 Pakistan plan `hidden_files/w2-pakistan-plan.md`; live-state evidence from lane reports + memory, cited per claim. Where a status is claimed, its evidence is named in the same cell or section; anything without evidence is written as **Not started**.

**Relationship to the v1 plan:** this document **supersedes** `files/PHASE-WISE-PLAN.md` as the working plan. The v1 plan is retained, unedited, as the historical record of the 120-item blueprint v1. Nothing in it was wrong for its scope; blueprint v2 expands the scope (120 → 222 ENG items, 134 → 240 screens) and this plan re-bases every status onto live evidence as of 2026-11-10.

**On percentages:** the owner's recorded ~35–40% figure (2026-11-08) described the **v1** scope. It is **not** carried over to v2's enlarged 222-item scope, and no new percentage is computed here — v2 itself warns that backlog row counts are not completion percentages.

**Acceptance standard adopted:** blueprint v2's core specification §18 — a feature counts as complete only with *working screen + authorization + data contract + main/exception/cancellation path + posting/side-effects + audit + reconciliation + acceptance evidence*. A dashboard card, stub endpoint or mocked integration does not satisfy it. This is the standard the M3 milestone (§5) is judged against, and it is why "reads live" (oc19) is not claimed anywhere in this plan as a working ERP.

---

## 1. ONE-PAGE SUMMARY TABLE

| Wave / track | Items | Status (2026-11-10) | Gate that closes it |
|---|---|---|---|
| **W0** — Baseline | 14 (ENG-001–012 + ENG-121 + ENG-181) | **Closed at wave level** for the original twelve (v1-plan authority, §6.1 caveat); the two v2 additions are partially evidenced by existing practice | "Reproducible release and restored staging" — closed |
| **W1** — Shared operational core + suite shell | 62 (ENG-013–060 + 14 v2 additions) | **In progress — final stage.** Platform substantially live; engine posting bench-proven; frontend **reads live** (oc19, owner-confirmed); frontend **writes built** 2026-11-10, at their bench-proof gate, shipping in oc20 (milestones M1–M3) | "3 controlled end-to-end businesses; reconciled ledgers; accountant/UAT evidence" — outstanding: **demo2 run + ENG-060 Commerce UAT** (milestone M4; demo2 blocked on the owner's word) |
| **W2** — Pakistan launch + integration platform | 75 (ENG-061–096 + 39 v2 additions) | **In progress — early.** FBR module + transactional outbox built (oc14): ENG-073 built, ENG-074/077/090/144 partial, ENG-081 live, ENG-080/082/092 partially live. Pack platform (ENG-061–072) and the country-compliance block (ENG-085–096) not started; ENG-086 owner-gated | "FBR/country applicable evidence; supported scope published" (milestone M5) |
| **W3** — Industry pilots + suite breadth I | 49 (ENG-097–108 + 37 v2 additions) | **Not started.** v2 adds specification depth (journeys, workflow contracts, anchor packages ENG-197–210) but no build has run; the Saudi package is to be minted at wave start (finding F2, §3) | "ZATCA path and domain acceptance; no unsupported claim" + ENG-108 certification |
| **W4** — Enterprise controls, anchors, suite breadth II | 22 (ENG-109–120 + 10 v2 additions) | **Planned, with significant pre-builds** in the original twelve (backup substantially built, restore partially proven, observability partially live — mapped row by row in §6.5); the ten v2 additions not started | Enterprise controls + per-pack specialist/authority evidence (finding F3 re-scored, §3) |
| **W5** — Wider MENA + global | **0** | **By-design programme, not a package list** (v2 doctrine; finding F1 re-scored, §3). Four W5 screens exist; per-country packages are minted when a country enters scope | Country-by-country commercial readiness — per country, never a single wave gate |
| **Milestones M0–M7** (§5) | — | The execution sequence that cuts across the waves: M0 substantially done · M1–M3 built, at the proof gate · M4 blocked on the owner's word · M5 early substance built · M6/M7 not started | M3's exit is the **active working ERP** (§5) |

**Companion inventories (v2):** 240 screens (237 active contracts + 3 retired KYC IDs — SCR-010/011/123, deliberately not reused), 73 workflow contracts (WF-001…073, each with states, failure/compensation and an accounting invariant), 58 suite capability contracts (APP-01…58), 200 industry use cases (IDs identical to v1), 48 selected jurisdictions + 249 discovery entries. Counts check: 14 + 62 + 75 + 49 + 22 = **222** = the v2 CSV's row count; W5 contributes **0** rows (machine-verified, §7).

---

## 2. STATUS VOCABULARY (used in every table cell)

- **Closed (wave-level)** — the wave was closed on the recorded programme snapshot's authority; per-item audit was not re-performed (W0 only; caveat at §6.1).
- **Live** — shipped and proven in real operation.
- **Substantially live / substantially evidenced / substantially pre-built** — the substance operates or is proven; the blueprint package's own named acceptance evidence has not been formally mapped/run, and the cell names the remainder.
- **Partially live / built / evidenced / proven / practised** — a real, evidenced part exists; a named remainder is open (named in the same cell).
- **Built — not shipped** — code complete and locally proven (unit/harness/bench), not yet in a live image.
- **In flight** — an active lane is building or proving it now.
- **Not started** — no lane report or memory entry evidences work on it.
- **Owner-gated** — cannot proceed without an owner-only input (his decision, credentials, or physical action).

---

## 3. THE THREE v1 DEFECTS — RE-SCORED AGAINST BLUEPRINT v2

The v1 plan recorded three findings (its §2.1 F2, §2.2 F3, §2.3 W5). Blueprint v2 changes each one's standing. Full evidence: `hidden_files/team-blueprint-v2-review.md` §5.

**F1 — "W5 has zero ENG items" → RE-SCORED: not a defect; a v2-confirmed design stance.**
The v2 CSV still contains zero W5 rows (machine count, §7) — but v2 now states the doctrine explicitly: world coverage is a per-country supported-version programme, not a finite launch milestone. W5 has 4 screens (SCR-142/143 warm-pool/migration, SCR-222/223 mail/calendar), wave-level elapsed envelopes and X-Regulatory track coverage. **Plan treatment:** the finding is re-worded from "defect" to "design stance". W5 is planned as *per-country minting* — when a country enters scope, its package is minted from the 10-step country work package (`compliance/05`) + the country-pack production checklist, on the ENG-222 pattern. Nobody should promise a W5 item list, and this plan contains none.

**F2 — "Saudi/ZATCA in W3's definition but no backlog items" → HALF-FIXED: specification gap closed, backlog gap open.**
Still true in v2: no ENG row's acceptance is "ZATCA sandbox/clearance proven" — there is no `sa_zatca` package among the 222. What v2 adds around the gap: `compliance/02` §3 is a full Saudi delivery pack (Phase 1/2, standard clearance vs simplified 24-hour reporting, EGS/CSID lifecycle, signing/QR, hash chain, named test list); the architecture names the `sa_zatca` extension namespace; REQ-016 traces to W3; WF-072 + ENG-222 (W2) define the generic country-connector delivery pattern; the production checklist carries a Saudi-specific gate. **Plan treatment:** at W3 start (milestone M7), mint a dedicated `sa_zatca` package as a child of ENG-222 + the `compliance/02` §3 spec — or formally adopt ENG-222 + checklist as the Saudi delivery vehicle. The decision is due when W3 is scheduled, not now. Until then, W3's §1 gate ("ZATCA path and domain acceptance") remains unclosable as written, exactly as the v1 plan found — but now for one missing row, not a missing specification.

**F3 — "W4's text promises GCC expansion + pharmacy/manufacturing; its rows are enterprise controls only" → FIXED in substance for industry; GCC-as-countries remains programme-level.**
v2's W4 carries 22 rows: the original 12 controls **plus** ENG-201 (pharmacy anchor — ENG-107's regulated depth), ENG-205/206 (discrete + process manufacturing anchors), ENG-142/143 (sanitised warm pool, regional tenant migration) and the value-stream packages ENG-213/216/217/218/221. The industry half of §1's promise now has rows. The GCC *country-pack* half is still not itemised as GCC-specific rows; it rides the generic country machinery (the ENG-085–096 pattern, ENG-222, the production checklist) plus regional items ENG-142/143/221. **Plan treatment:** F3 is marked *resolved for industry scope*; GCC country packs are handled by the same per-country minting doctrine as W5 (F1).

---

## 4. DEVIATIONS REGISTER — every deliberate owner-directed deviation, named

*These are the places where the programme deliberately does not follow the blueprint's letter. Each carries its decision date and source. None is smoothed over; §5's sequence is written around them.*

- **D1 — Own-product / design track pulled before W2.** The blueprint contains no design or own-frontend wave. On the owner's Zoho-style end-state decision (2026-11-08: no tenant-visible surface reveals ERPNext/Frappe) and his 2026-11-09 redirect ("design first" — the shipped surfaces read as "the same design" and the tenant ERP as ERPNext), the own-frontend track became the headline programme: pairing cycles oc13–oc20 are this track. v2 absorbs it (X-Experience track, ENG-163/126/211). The blueprint dependency is respected — W2 still waits on the W1 core; only W1's *final gate* (Slice 10) was sequenced after the design step.
- **D2 — Identity-review gate removed.** Per the service-provider principle + integration standard (Assad, 2026-11-07): Operqon is a service provider like Odoo/ERPNext/Zoho — onboarding is signup → email verify → payment → setup, fully automatic; the only human approval anywhere is offline-payment verification by `operqon:billing_approver`, which concerns Operqon's own money, not the customer's identity. Compliance belongs to the client; packs and gateways are tenant-activated modules carrying the tenant's own credentials. Blueprint v2 now encodes the same baseline (ENG-185; KYC screens SCR-010/011/123 retired) — the deviation has become the blueprint's own position.
- **D3 — Gateway configuration lives in the console frontend** (Assad, 2026-11-07): merchant credentials are entered via the console settings page (write-only → encrypted at rest → masked read-back → audit-logged), never server env files. General principle recorded the same day: project-completion configuration items go on the frontend; only what genuinely belongs in the backend stays there. ENG-220 (W2) is v2's tenant-side analogue.
- **D4 — Pricing authority stays outside the backlog.** Plan prices (PK v1: Starter Rs 7,500/mo, Growth Rs 9,999/mo, Business Rs 19,999/mo + seat prices) are live **only** because they passed the billing → approver flow (approved proposal `c4ed372c…`); later changes require a whole new proposal through the same ritual. No ENG item may hardcode prices. v2 preserves the same constraint.
- **D5 — demo2 is parked on the owner's word.** The demo2 run pack is ready (9 steps; the owner's part is exactly 6 steps in two sittings, incl. the real Rs 19,999 Business-monthly transfer, which only he can make). This is a process gate the blueprint does not know about; its consequence is recorded plainly: **W1 cannot be called closed until demo2 + Slice 10 run** (milestone M4).
- **D6 — Writes ship as governed whitelisted methods; the raw REST save path is rejected.** Coordinator decision under the owner's full-approval mandate (2026-11-10), taken on the write-gap audit's evidence: the SPA's live REST save path had five named defects (drafts vanishing from submitted-only lists; exists-check reading the fixture store in live mode; new documents hard-coding company "Al-Noor Traders"; a non-field `tax_rate` sent while the taxes child was never built; save rejections silently swallowed). Consequence: milestones M1–M3 build a governed command layer (`writekit` + `operqon_core.api.writes`) in the pattern of ENG-126 + ENG-073/075, instead of repairing REST saves.
- **D7 — Transactional writes are create-only this cycle** (coordinator decision, 2026-11-10): the write methods create (+submit); re-saving an existing live document refuses visibly — never a silent duplicate. Update-by-name exists only on the three masters (Customer/Supplier/Item). An edit/update path for transactional documents is a named next-cycle item.
- **D8 — POS sale is excluded from the working-ERP minimum.** Standing posture (GAP-06): Desk POS remains register of record; the Operqon POS surface is read/catalogue-only, and completion/holds refuse in live mode with a typed error rather than pretending. ENG-054/055 are therefore not on M3's critical path; a register switch is a separate product decision, not an assumption.
- **D9 — Design authority sits with owner-supplied designs.** The ERP frontend design is the owner-supplied DreamsPOS (light, #FE9F43 + #092C4C, Nunito Sans), locked 2026-11-09 after the coordinator's generated directions (v2, v3) were rejected; console modernization Phase 1 (deployed 2026-11-09) is visually superseded by that lock. Designs are supplied as Figma files, never coded HTML/CSS mocks (standing rule after the v2/v3 rejections). Console + portal designs are owner-supplied separately and have **not yet been received** — no lane may invent them.
- **D10 — FBR only through a licensed integrator** (owner rule, carried from the W2 plan): ENG-086 is owner-gated on the licensed-route decision, the integrator agreement and sandbox credentials. This constrains M5's critical path — the FBR module is built to the documented API pattern, but field-level reconciliation and any sandbox contact wait for the chosen integrator.
- **D11 — W2 integration slices were built ahead of W1 closure.** The FBR module + transactional outbox (ENG-073/074-half/075-surface/077-part/090-machine) were built and composed into oc14 (2026-11-09) while W1's final gate was still open, because the integration framework is wave-independent plumbing that the tenant app needed regardless. The country-compliance block (ENG-085–096) was **not** pulled forward — it still waits for its own gates (M5).
- **D12 — Execution model: full-approval mandate + CEO model.** Assad (2026-11-06 23:58 PKT) mandated completing the programme end-to-end without per-step approvals (GitHub pushes included), and (2026-11-07) made Muse CEO across the portfolio: direction, sequencing and delivery are the coordinator's; decisions arrive to the owner as prepared proposals. Recorded here because it changes how every gate in this plan is operated. The physical limits stand: the owner's personal role-account passwords/TOTP, his design supply, his direct DreamsTech purchase (the vendor full kit, which carries dark mode — S8's blocker) and the actual bank transfer are his alone.

---

## 5. MILESTONE SEQUENCE M0–M7 (the execution order across the waves)

*From the v2 review (§9), re-based onto live state. Sizes are relative (S/M/L/XL) against this programme's demonstrated lane throughput — this plan invents no dates, per the same rule the v1 plan kept.*

**M0 — Close the present. Status: substantially done; one leg open. Size S–M.**
Done: the firstrun live-mapping lane (mapping built in canonical `admin.js`, harness §20, bench re-proof passed; the flip verdict was **NOT YET** — the flip itself is an oc20 packaging step, see M2); the write-gap audit (2026-11-10 — the verified write-gap list that M1–M3 are built from); the blueprint v2 review; this plan amendment. **Open:** the full on-page audit (every screen/link/feature classified LIVE-REAL / SAMPLE / BROKEN) has not yet run — it remains an M0 exit item. Anchors: ENG-182/183/184 evidence mapping (their W1 rows carry the detail).

**M1 — Write foundation. Status: built; at its proof gate. Size M.**
The governed command layer v2 specifies (ENG-126/128-pattern + ENG-073/075 discipline): `writekit` (company/scope resolution, governed permission gate, typed errors, idempotency receipts) + the `operqon_core.api.writes` method set, with the api posture amendment fenced before code shipped, per D6. Unit position at last census: per-suite green (incl. `test_write_methods` 28 OK; harness on the frontend side 493/0). Remainder: the server lane's **final clean bench pass** (real posting reconciliation) + its final report — in flight at the time of writing — then oc20 packaging.

**M2 — Master-data writes. Status: built; ships in oc20. Size M.**
Tenant can set up their business from the Operqon frontend: Customer + Supplier create (new UI built), Item create/update incl. reorder rows, opening stock via Stock Entry. The firstrun card's admin flip rides this milestone's vehicle (oc20): blockers 1 (fields quoting) and 2 (Users) fixed by the frontend lane, blocker 3 (Employees 403) cleared server-side by the role_matrix addition, blocker 4 (POS Devices field contract) still open — the POS Devices surface stays honestly fixture-gated until it is re-based. Anchors: ENG-037/038, ENG-211, WF-061.

**M3 — Transactional core writes — THE ACTIVE WORKING ERP MILESTONE. Status: built; at its proof gate (the same bench pass as M1). Size L–XL (executed split as one server lane + one frontend lane rather than sequential M3a/b/c builds; the exits still apply in order at proof time).**
Wired screen-by-screen to the v2 action contracts: Sales Invoice create+submit (after-submit print kept), Sales Return (from the submitted original), Purchase Order, Purchase Invoice, Payment Entry (allocation built server-side), Journal Entry, Stock Entry incl. **Material Transfer** (purpose added in-lane 2026-11-10, bench-proven). Create-only contract per D7; POS excluded per D8. **Exit = the owner's definition:** a tenant signs in, creates items/customers, trades, receives payment and manages stock — entirely in the Operqon frontend — proven first on a proof site (per-role known-answer battery, ACC-01…18 fixtures as the acceptance frame), then on Rektrs. Anchors: ENG-028…048, ENG-050…060 (UAT itself is M4), WF-014…019, SCR-063…089.

**M4 — W1 closure on the working product. Status: not started; blocked on the owner's word (D5). Size M (mostly evidence, not build).**
demo2 run (owner's 6 steps) + Slice 10 / ENG-060 Commerce UAT with accountant evidence on the now-write-capable frontend + the v2 §3 first-vertical-slice acceptance (signup → setup → purchase → stock → order → delivery → invoice → fiscal handling → receipt → return/credit → bank reconciliation → trial balance — explicitly not closeable on "dashboard login ya invoice PDF"). **Exit: W1 closed.**

**M5 — W2 Pakistan completion on the working core. Status: early substance built (D11); the wave's build blocks not started. Size L.**
Remaining per the W2 plan: pack platform ENG-061–072; country block ENG-085–096 (incl. ENG-090's unknown → status-query step + replay UI, ENG-091 STGO correction, ENG-095 offline/POS policy, ENG-096 release gate); ENG-185 formalisation; ENG-191 payment links; ENG-222 contract formalisation; anchor packs ENG-203/204 if a pilot sponsor exists. Critical path runs through owner-gated ENG-086 (D10) and bank-side merchant onboarding for gateway settlement (ENG-080's remainder; R4.2 adapters stand built since 2026-11-07).

**M6 — Suite breadth (only after a working core is selling). Status: not started. Size L in aggregate, S–M per app.**
In v2's order of value: ESS/HR depth (ENG-174/193–196 → country payroll pilot ENG-175, W3), portals (ENG-170/171), PDC/treasury/petty-cash (ENG-167/168/169), helpdesk/CRM value streams (ENG-212/214/219), collaboration/signing/BI (W4 block: ENG-213/216/217/218). Every engine adoption is gated by ENG-189 (licence/version spike) **before** build.

**M7 — W3/W4 waves as itemised. Status: not started.**
Mint the `sa_zatca` package at W3 start (§3/F2); anchor packs ENG-197–210 with domain UAT; W4 hardening consumes the pre-builds mapped in the W4 table (ENG-112/113/109/115/116/119) instead of rebuilding them. **W5: per-country minting only (F1) — no milestone is promised for it.**

**Parallel / standing tracks (unchanged; none conflicts with v2):** S8 dark theme finalisation (blocked on the owner's direct DreamsTech purchase — the full kit carries Dark & Light modes); console + portal designs (owner-supplied per D9, not received); fixture cleanup (owner-endorsed 2026-11-07: purge all test tenants/payments/notices, audit chain preserved — queued); billing `/tenant-queue` 403 follow-up (backend slot; the frozen 7-key queue contract constrains the fix); billing shadow POC — Lago vs Kill Bill (after W1 closes, per the 2026-11-08 decision: Kill Bill not adopted now); bench RQ-worker / default-queue hygiene (the staging bench has no RQ worker by design; the queue crossed the pin's limit in the oc18 cycle and needed a purge); the oc18 shell-comment reword (cosmetic, rides a future cycle under image==snapshot discipline).

---

## 6. PER-WAVE SECTIONS

*Reading note: in every table, ENG / Title / Depends on / Risk are verbatim from `engineering/delivery-backlog.csv` (v2). Only the Status column is this plan's writing. Within-wave sequencing notes are labelled as derivations wherever the CSV gives only a flat dependency — the same discipline the v1 plan kept.*

### 6.1 W0 — Baseline (ENG-001–012 + ENG-121 + ENG-181)

**Status: closed at wave level** for the original twelve, on the 2026-11-08 programme snapshot's authority ("W0 mukammal band") + the W0 backup closure of 2026-11-07 (restic → Cloudflare R2, provider DB leg daily 02:50 UTC, restore from the off-VPS copy proven, provider retention live). **Honesty caveat (carried from the v1 plan, unsoftened):** ENG-001–012 were **not** re-audited item by item for this plan; the evidenced centre of closure is the backup/restore leg and the R4.1 baseline acceptance. Two owner-held micro-items remain open **by design**: (a) the restic password file + R1 backup key exist only on the VPS — the owner stores them in his own secure store; (b) the owner creates one healthchecks.io check for the provider backup leg (its alerting half is also ENG-112/186's remainder). v2 adds two W0 items — ENG-121 and ENG-181 — both of which describe discipline this programme already practises; their rows say exactly how far that goes. ENG-004 carries v2's corrected title (v1: "R3 lifecycle contract").

#### W0 — Baseline (14 items) — item table

| ENG | Title | Depends on (CSV) | Status today (evidence-mapped) | Risk |
|---|---|---|---|---|
| ENG-001 | Source baseline | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-002 | Environment inventory | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-003 | Restore rehearsal | baseline | Closed (wave-level) — restore from the off-VPS copy proven 2026-11-07 | high |
| ENG-004 | Provider lifecycle contract on current source | baseline | Closed (wave-level; §5.1 caveat) — v2 retitles this item (was “R3 lifecycle contract”) | high |
| ENG-005 | Deployment regression | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-006 | License inventory | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-007 | Tenant topology ADR | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-008 | API contract capture | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-009 | State-policy ADR | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-010 | Release artifact lock | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-011 | Pilot protection | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-012 | Baseline acceptance | baseline | Closed (wave-level; §5.1 caveat) | high |
| ENG-121 | App capability source map | ENG-001; ENG-006 | Partially evidenced — new in v2. The programme's capability source exists in practice (S9 workspace/catalogue governance in the app-pack); no formal source-map deliverable has been audited against this package. | high |
| ENG-181 | Source and release lineage reconciler | ENG-001; ENG-121 | Partially live — new in v2. Lineage discipline is practised (GitHub source-of-truth gate, approved-commit marker, snapshot sync records, per-milestone handover commits — latest 2026-11-10); a reconciler tool as specified is not built. | critical |

*W0 count check: 14 items.*

### 6.2 W1 — Shared operational core + suite shell (ENG-013–060 + 14 v2 additions)

**Status: in progress — final stage.** The wave's shape today, in four layers: (1) the **platform block** (ENG-013–024) is substantially live — SSO, identity linking, membership, the role/branch governance matrix and the hash-chained audit trail all operate on real tenants, proven by the Rektrs pilot and by the login chapter that closed 2026-11-10 on the owner's own phone; (2) the **engine layer** (finance/supply posting, ENG-025–048) is ERPNext-native and bench-proven to the rupee against known answers, but was reachable only through Desk until now; (3) the **Operqon frontend reads** went live progressively (oc13 GAP methods → oc15 TB/BS + sales/buying lists → oc19 truth-in-labelling, owner-confirmed); (4) the **frontend writes** — the layer that makes this an *active working ERP* under v2 §18 — were built on 2026-11-10 by the two write lanes and ship in oc20 (milestones M1–M3). The fourteen v2 additions mostly formalise what the programme already does (ENG-150 seven-role mapping, ENG-163 the shell, ENG-182 the browser gate, ENG-184 subscription-start) or name the layer just built (ENG-126 the API boundary, ENG-211 master-data governance). **What remains for the wave gate is unchanged since the v1 plan: demo2 + ENG-060 (M4).** Slice-level completions in the rows below are build evidence, not ENG closures — the same restraint the v1 plan applied.

#### W1 — Shared operational core + suite shell (62 items) — item table

| ENG | Title | Depends on (CSV) | Status today (evidence-mapped) | Risk |
|---|---|---|---|---|
| ENG-013 | OIDC session security | W0 | Substantially live — OIDC SSO live for provider + tenant; F-1 (response_type=code) fixed; adversarial session pack built (W1 Slice 2); tenant login chapter closed 2026-11-10. Formal package acceptance mapping owed. | critical |
| ENG-014 | Identity linking | W0 | Substantially live — SSO provisioning links the tenant admin (Pass C; F-3: System Manager + Operqon Tenant Admin); live on the pilot tenant. | critical |
| ENG-015 | Tenant membership | W0 | Substantially live — membership/roster live (Slice 3 + pilot). Recorded limitation F-6: role changes flow via roster/membership, not permission-checked User saves. | critical |
| ENG-016 | Role and branch policy | W0 | Substantially live — role_matrix governance live (210 DocPerm rows / 36 DocTypes after the 2026-11-10 write-lane additions); branch scoping bench-proven with known-answer legs (2026-11-09/10). | critical |
| ENG-017 | Operator MFA | W0 | Live — operator MFA live; six role logins + TOTP verified 2026-11-06 (the one fully live W1 item at v1-plan date; unchanged). | critical |
| ENG-018 | Support access | W0 | Partially live — support-access seam shipped (S6) and Slice 4 built/integrated as a release candidate; package acceptance not formally closed. | critical |
| ENG-019 | Private attachment | W0 | Partially live — private-attachment work built in Slice 4 (local); not formally closed. | critical |
| ENG-020 | Job tenant context | W0 | Partially live — provisioning jobs run with tenant context live (daemon auto-publish proven in the pilot); package acceptance not mapped. | critical |
| ENG-021 | Search isolation | W0 | Partially live — isolation proven for governed reads in bench scoping legs; search-specific acceptance not mapped. | critical |
| ENG-022 | Export authorization | W0 | Partially live — export-authorization layer built (Slice 4); the full exit drill belongs to ENG-119 (W4). | critical |
| ENG-023 | Security audit trail | W0 | Substantially live — hash-chained audit trail live in the provider, re-verified at every release. | critical |
| ENG-024 | Secret vault references | W0 | Partially live — vault/secret discipline live in operation (Secure Vault, 600-perm key files, secrets never in chat); formal package mapping owed. | critical |
| ENG-025 | Company and fiscal setup | W0 | Substantially live — apply_setup_masters seeds company masters + PK Fiscal Year 2026-2027 (finding F-5); its acceptance package is ENG-183. | critical |
| ENG-026 | Chart of accounts | W0 | Substantially live — chart seeded by setup masters; GL reads live and reconciled to the rupee against the GL report on the bench (re-proof B1). | critical |
| ENG-027 | Decimal and rounding | W0 | Partially live — engine-native decimal/rounding; known-answer proofs exact; no package-specific evidence run. | critical |
| ENG-028 | Sales posting | W0 | Partially live — posting engine bench-proven (known answers exact); Operqon-frontend create+submit built on both sides 2026-11-10 (save_sales_invoice; bench: SI submit → grand/outstanding Rs 10,500); ships in oc20 — not yet live from the frontend. | critical |
| ENG-029 | Purchase matching | W0 | Partially live — PO/PI write methods + frontend wiring built 2026-11-10 (ships oc20); three-way-match depth per the blueprint not separately evidenced. | critical |
| ENG-030 | Payments allocation | W0 | Partially live — Payment Entry write built; bench proof banked (Receive → invoice outstanding 0); allocation edge cases per the ACC fixtures not all run. | critical |
| ENG-031 | Credit and return | W0 | Partially live — Sales Return write built + wired 2026-11-10 (ships oc20); credit-policy depth not fully evidenced. | critical |
| ENG-032 | Bank reconciliation | W0 | Partially live — engine/slice finance build exists (W1 Slice 5); no Operqon-frontend bank-reconciliation surface; the v2 §3 vertical slice's bank-rec leg is still owed at UAT (milestone M4). | critical |
| ENG-033 | Period close | W0 | Partially live — close is Desk-native; the Operqon Period Close surface refuses by design with a typed error (write-gap audit 2026-11-10); package acceptance not run. | critical |
| ENG-034 | Fixed assets | W0 | Partially live — Assets workspace governed (S9: Asset + Asset Category in the matrix); depreciation engine-native; no dedicated acceptance. | critical |
| ENG-035 | Multi-currency | W0 | Partially live — engine-native multi-currency; frontend money formatting currency-aware since oc19; FX-specific acceptance not run. | critical |
| ENG-036 | Financial close report | W0 | Partially live — Trial Balance + Balance Sheet reads live (GAP-14, oc15, bench-exact); the close report as specified is not formalised. | critical |
| ENG-037 | Item and unit model | Finance setup | Partially live — Item/UOM reads live; Item write (incl. the reorder child row) built 2026-11-10, ships oc20. | high |
| ENG-038 | Warehouse scoping | Finance setup | Substantially live — warehouse scoping proven in stock reads (bench known answers). Recorded caveat: Bin carries no company column on this pin, so Bin itself is not company-scoped. | high |
| ENG-039 | Serial reservation | Finance setup | Not started (package level) — serial handling is engine-native; the reservation acceptance (serial-race / ACC fixtures) has not been run. | high |
| ENG-040 | Batch expiry | Finance setup | Partially live — generic batch/expiry policy built in W1 Slice 7 (local); package acceptance not run. (Not to be read as pharmacy rules — that depth is ENG-201.) | high |
| ENG-041 | Stock valuation | Finance setup | Substantially live — stock balance + valuation reads live (GAP-02) with bench-exact known answers. | high |
| ENG-042 | Replenishment draft | Finance setup | Partially live — reorder levels surface live in stock reads (reorder_level proven on the bench); replenishment draft generation as specified is not built. | high |
| ENG-043 | Landed costs | Finance setup | Not started — landed-cost depth is picked up by ENG-178 (W3); no W1 package evidence. | high |
| ENG-044 | Picking and delivery | Finance setup | Partially live — Delivery Note read/list paths live; pick/pack/deliver write actions are not wired (outside the oc20 minimum write set). | high |
| ENG-045 | Stock count | Finance setup | Partially live — Stock Entry writes built incl. the Material Transfer purpose (2026-11-10, bench-proven); the blind-count workflow (separate adjustment approval) is not built. | high |
| ENG-046 | Supplier returns | Finance setup | Partially live — purchase-return reads live (GAP-13); a dedicated supplier-return write is not in the oc20 set. | high |
| ENG-047 | Transfer in transit | Finance setup | Partially live — Material Transfer moves stock warehouse-to-warehouse (bench-proven 2026-11-10); in-transit two-step semantics as specified are not built. | high |
| ENG-048 | Inventory reporting | Finance setup | Substantially live — inventory reporting reads live (stock balance, GAP-02) with bench-exact totals. | high |
| ENG-049 | CRM qualification | Finance and supply | Not started — no CRM surface in the Operqon frontend; v2 routes CRM depth via ENG-212 (W3) behind the ENG-189 engine gate. | high |
| ENG-050 | Quotation revision | Finance and supply | Partially live — quotation read/list paths live; the revision write path is outside the oc20 minimum write set (stays on existing paths). | high |
| ENG-051 | Pricing engine | Finance and supply | Partially live — pricing is engine-native; Item Price permissions were added for the Item-writing roles during the 2026-11-10 bench proof; an Operqon pricing-engine surface as specified is not built. | high |
| ENG-052 | Promotion conflicts | Finance and supply | Not started. | high |
| ENG-053 | Credit limits | Finance and supply | Not started (package level) — credit-limit fields are engine-native; the credit-control acceptance (ACC fixtures) has not been run. | high |
| ENG-054 | POS shift | Finance and supply | Not started in the Operqon frontend — standing decision: Desk POS remains register of record (GAP-06); POS completion/holds refuse with a typed error in live mode. | high |
| ENG-055 | POS device pairing | Finance and supply | Partially built — the GAP-06 pairing-registry DocType exists with install-only posture (kept by the 2026-11-10 adjudication); the SPA's assumed field contract mismatches the real DocType (firstrun blocker 4); device pairing is not live from the frontend. | high |
| ENG-056 | Sales return policy | Finance and supply | Partially live — the Sales Return write is wired (2026-11-10); return-policy configuration as specified is not built. | high |
| ENG-057 | Customer portal | Finance and supply | Substantially live — customer portal live (operqon.cloud/customer) with the S8 redesign + S9 self-service subscription-offer/start; v2's portal screen contracts are not formally mapped. | high |
| ENG-058 | Sales approvals | Finance and supply | Not started — approval workflows are engine-native; no Operqon approvals surface is evidenced. | high |
| ENG-059 | Commission calculation | Finance and supply | Not started. | high |
| ENG-060 | Commerce UAT | Finance and supply | Not started — THE W1 GATE. demo2 run + Slice 10 Commerce UAT outstanding; demo2 is blocked on the owner's word (his 6 steps incl. the Rs 19,999 transfer). | high |
| ENG-122 | Versioned app registry | ENG-121; ENG-008 | Not started — new in v2. (The app-pack carries workspace fixtures/catalogue, not a versioned app registry.) | high |
| ENG-123 | Per-app entitlement contract | ENG-122; ENG-008; ENG-009 | Partially live — plan-level entitlements are live in the provider (tenant plan_code, subscription states); a per-app entitlement contract as specified is not built. | critical |
| ENG-124 | App assignment lifecycle | ENG-015; ENG-122 | Partially live — tenant membership/roster lifecycle is live (Slice 3, provisioning); per-app assignment as specified is not built. | critical |
| ENG-125 | Focused app launcher | ENG-123; ENG-124 | Partially live — the own-frontend workspace switcher + module catalogue serve as the launcher in practice; the focused per-app launcher as specified is not separately built. | high |
| ENG-126 | Unified suite API boundary | ENG-008; ENG-014 | Partially live — the governed method façade (GAP reads + the 2026-11-10 writes API) is the working unified boundary; formal adoption of the ENG-126 contract as the acceptance frame is M1 bookkeeping that remains. | critical |
| ENG-127 | Cross-app master ownership | ENG-025; ENG-126 | Not started — new in v2; cross-app master ownership as specified is not built (masters are engine-owned today). | critical |
| ENG-135 | Provider MRR and unit economics | ENG-036; ENG-123 | Not started — new in v2; provider billing data exists, but the MRR/unit-economics package is not built. | high |
| ENG-150 | Provider seven-role capability mapping | ENG-017; ENG-023; ENG-181 | Substantially live — the seven-role model + exactly-one-role verifier are live and were verified 2026-11-06 (six role logins + operator). v2's named mapping deliverable maps onto this evidence — re-base, don't rebuild. | critical |
| ENG-163 | Unified company app and task shell | ENG-125; ENG-126 | Substantially live — the own-frontend /operqon shell IS the unified company app shell, live on tenants (oc19; owner-confirmed 2026-11-10). Formal acceptance mapping owed. | high |
| ENG-182 | Asset guest-login and setup browser gate | ENG-013; ENG-181; ENG-008 | Substantially evidenced — the gate it demands has run every cycle since oc16 (guest login 200, all assets 200, no wizard redirect) and the login chapter closed on the owner's own phone proof 2026-11-10; a named regression suite as the package deliverable is not formalised. | critical |
| ENG-183 | Idempotent company setup acceptance | ENG-025; ENG-020; ENG-010 | Partially evidenced — idempotent provisioning/setup proven in pilot legs (Pass C idempotency; apply_setup_masters convergence); the named acceptance suite has not been run as such. | critical |
| ENG-184 | Self-service subscription-start regression | ENG-014; ENG-004; ENG-008 | Substantially live — subscription-offer/start shipped in S9 (2026-11-08), incl. double-start → 409; the named regression package is not formalised. | critical |
| ENG-186 | Per-component backup coverage closure | ENG-002; ENG-003; ENG-010 | Partially live — provider DB + Keycloak backup legs + retention live, restore from off-VPS proven; the alerting half awaits the owner's webhook URL; per-component coverage closure not audited. | critical |
| ENG-211 | Master data company and price-policy governance | ENG-014; ENG-127 | In flight — master writes built 2026-11-10 (server methods + frontend wiring, harness 493/0); ships oc20; the price-policy governance remainder is not started. | high |

*W1 count check: 62 items.*

### 6.3 W2 — Pakistan launch + integration platform (ENG-061–096 + 39 v2 additions)

**Status: in progress — early, and in three distinct halves.** (1) **Live from the provider side:** ENG-081 (manual bank approval) shipped in R4.1 and carried the Rektrs pilot; ENG-080 (settlement) and ENG-082 (messaging) are partially live; ENG-092 is live as pattern only. (2) **Built ahead of the wave (deviation D11):** the FBR module foundation + framework (registry, credential-test activation, Sales Invoice `on_submit` stamping) and the transactional outbox slice gave ENG-073 (built, tenant-side), ENG-074 (receipt half), ENG-075 (submission surface — plus, since 2026-11-10, the write methods' idempotency receipts), ENG-077 (partial) and ENG-090 (submission machine; unknown → status-query step and replay UI remain) real substance, composed into oc14. ENG-076 is honestly **not built** — no inbound webhooks exist yet. (3) **Not started:** the pack platform ENG-061–072 (M5's first build block) and the entire country-compliance block ENG-085–096, except the FBR module's interim NTN/STRN fields standing in for ENG-085. ENG-086 is **owner-gated** (D10). The 39 v2 additions (suite/platform scope: ENG-128–132, 134, 136–139, 141, 144, 146, 148, 149, 151, 153, 154, 157, 159–162, 167–171, 177, 179, 185, 187, 190–192, 203, 204, 220, 222) are not started except where their rows say otherwise — ENG-185 is substantially live because the *policy* is in force (D2), and ENG-222 is partially evidenced because the FBR module is its first working instance. Detailed wave plan: `hidden_files/w2-pakistan-plan.md` (8 slices + standing operation) — this section maps status onto it; it does not duplicate it.

#### W2 — Pakistan launch + integration platform (75 items) — item table

| ENG | Title | Depends on (CSV) | Status today (evidence-mapped) | Risk |
|---|---|---|---|---|
| ENG-061 | Pack manifest schema | Core modules | Not started. | high |
| ENG-062 | Dependency resolver | Core modules | Not started. | high |
| ENG-063 | Pack artifact trust | Core modules | Not started. | high |
| ENG-064 | Entitlement contract | Core modules | Not started — pack-level entitlement; the plan-level entitlement that is live belongs to ENG-123's scope. | high |
| ENG-065 | Configuration precedence | Core modules | Not started. | high |
| ENG-066 | Workflow versions | Core modules | Not started. | high |
| ENG-067 | Installation checkpoint | Core modules | Not started. | high |
| ENG-068 | Pack compatibility matrix | Core modules | Not started. | high |
| ENG-069 | Pack migration rehearsal | Core modules | Not started. | high |
| ENG-070 | Pack retirement | Core modules | Not started. | high |
| ENG-071 | Tenant extension review | Core modules | Not started. | high |
| ENG-072 | Capability status registry | Core modules | Not started — capability-publication discipline is practised in programme reporting; the registry deliverable is not built. | high |
| ENG-073 | Transactional outbox | API and pack contracts | Built — tenant-side transactional outbox (pure core + DocType shell), composed and drain-scheduled in oc14; crash-after-commit delivery is durable (at-least-once, idempotent effect). Not yet exercised against a live integrator (ENG-086-gated). | high |
| ENG-074 | Consumer inbox | API and pack contracts | Partially built — receipt-application half only (consult-before-send applies an integrator receipt exactly once); a generic consumer inbox is not built (no inbound consumers exist yet). | high |
| ENG-075 | API idempotency | API and pack contracts | Partially live — built for the FBR submission surface (document-identity keys + Idempotency-Key header) and, since 2026-11-10, for the governed write methods (Operqon Write Receipt); a general API-wide idempotency middleware is not built. | high |
| ENG-076 | Webhook security | API and pack contracts | Not built — no inbound webhooks exist in the tenant app yet, so there is no surface to secure (stated plainly by the outbox lane). | high |
| ENG-077 | Connector installation | API and pack contracts | Partially built — the FBR module ships credential-test activation + audited deactivate via the integration registry (oc14); OAuth scope declaration/test and the formal revoke flow remain (W2 plan Slices 2/4). | high |
| ENG-078 | Sync ownership | API and pack contracts | Not started. | high |
| ENG-079 | Backfill checkpoint | API and pack contracts | Not started. | high |
| ENG-080 | Gateway settlement | API and pack contracts | Partially live — settlement path live in the provider (offline settlement → activation, pilot-proven); gateway settlement is blocked on merchant onboarding (bank-side). | high |
| ENG-081 | Manual bank approval | API and pack contracts | Live — manual bank approval shipped in R4.1 (offline_payment_approvals; billing_approver verifies/rejects with a recorded reason) and exercised end-to-end in the Rektrs pilot. | high |
| ENG-082 | Messaging delivery | API and pack contracts | Partially live — Brevo SMTP configured in both Keycloak realms; tenant messaging delivery discipline as specified is not complete. | high |
| ENG-083 | Hardware adapter | API and pack contracts | Not started. | high |
| ENG-084 | Integration health | API and pack contracts | Not started — the FBR lane supplies its data foundation only (integration state + audit trail); the health surface is not built. | high |
| ENG-085 | Country profile schema | Finance and integration | Not started — seller NTN/STRN interim fields on the integration record stand until this lands (W2 plan Slice 0). | critical |
| ENG-086 | Pakistan sandbox | Finance and integration | Owner-gated — licensed-route decision (licensed integrator only, owner rule), integrator agreement, sandbox credentials. No sandbox contact made or attempted. | critical |
| ENG-087 | Pakistan invoice cases | Finance and integration | Not started — the FBR module's field-level mapping must be reconciled with the chosen integrator's docs (W2 plan Slice 4); golden invoice-case fixtures not built. | critical |
| ENG-088 | Pakistan service scope | Finance and integration | Not started. | critical |
| ENG-089 | Country tax rule version | Finance and integration | Not started — no tax determination exists in the FBR lane; rates pass through from the invoice as-is. | critical |
| ENG-090 | Authority transport | Finance and integration | Partially built — submission state machine built on the outbox (queued → sent → confirmed / failed-retryable / failed-permanent; backoff, circuit breaker, dead-letter + replay driver). Remainder: the unknown → status-query-before-retry step and a replay UI. | critical |
| ENG-091 | Fiscal correction | Finance and integration | Not started — explicitly not built (STGO 01/2026 72-hour correction; W2 plan Slice 5). | critical |
| ENG-092 | Certificate rotation | Finance and integration | Partially live (pattern only) — Password credential fields + deactivate are the foundation; per-entity vault references, expiry ladder and rehearsed rotation remain (Slice 5). | critical |
| ENG-093 | Regulatory source review | Finance and integration | Not started (standing operation; W2 plan Slice 0). | critical |
| ENG-094 | Compliance reporting | Finance and integration | Not started. | critical |
| ENG-095 | Regulatory outage | Finance and integration | Not started — explicitly not built (offline/POS policy; Slice 5). The outbox circuit/dead-letter machinery is its transport foundation only. | critical |
| ENG-096 | Country release gate | Finance and integration | Not started — country release gate (W2 plan Slice 8). | critical |
| ENG-128 | Cross-app saga and event schema | ENG-073; ENG-074; ENG-127 | Not started — new in v2. (The outbox, ENG-073, is its transport predecessor, not the saga/event schema.) | critical |
| ENG-129 | Permission-aware cross-app search | ENG-021; ENG-128 | Not started — new in v2. | critical |
| ENG-130 | Unified audit projection | ENG-023; ENG-128 | Not started — new in v2. (The provider audit trail is ENG-023; a unified cross-app projection is not built.) | critical |
| ENG-131 | Atomic seat and storage reservations | ENG-064; ENG-123 | Not started — new in v2. (Atomicity exists inside single subscription-start; the reservation package is not built.) | high |
| ENG-132 | Multi-app recovery manifest | ENG-003; ENG-122; ENG-128 | Not started — new in v2. | critical |
| ENG-134 | App trial and downgrade rules | ENG-064; ENG-131 | Not started — new in v2. | high |
| ENG-136 | Privacy-bounded tenant health | ENG-129; ENG-130 | Not started — new in v2. | high |
| ENG-137 | Provider dunning studio | ENG-075; ENG-135 | Not started — new in v2. (Subscription-billing dunning behaviour in the provider is not this studio package.) | critical |
| ENG-138 | Cost-to-serve metering | ENG-131; ENG-135 | Not started — new in v2. | high |
| ENG-139 | Feature flags and canary controls | ENG-069; ENG-123 | Partially practised — canary discipline exists as release practice (real image gate, disposable fixtures, rollback points); feature-flag/canary controls as a package are not built. Cross-ref ENG-115 (W4). | critical |
| ENG-141 | Support session audit and revocation | ENG-018; ENG-130 | Not started — new in v2. (Support access itself is ENG-018, W1.) | critical |
| ENG-144 | Domain-safe DLQ replay | ENG-073; ENG-074; ENG-083 | Partially built — dead-letter + replay exists for the FBR outbox (driver + entry state); the domain-safe DLQ replay package across integrations is not built. | critical |
| ENG-146 | Enterprise deal desk | ENG-135; ENG-080 | Not started — new in v2. | critical |
| ENG-148 | Abuse and bot response | ENG-013; ENG-024 | Not started — new in v2. | high |
| ENG-149 | Signed rule and template studio | ENG-085; ENG-093 | Not started — new in v2 (depends on ENG-085/093, both not started). | critical |
| ENG-151 | Safe no-code custom fields and forms | ENG-065; ENG-066 | Not started — new in v2. | high |
| ENG-153 | Conditional access policy | ENG-013; ENG-014 | Not started — new in v2. | high |
| ENG-154 | Sensitive field masking and export policy | ENG-022; ENG-129 | Not started — new in v2. | critical |
| ENG-157 | Hardware and IoT registry | ENG-083; ENG-067 | Not started — new in v2. | high |
| ENG-159 | Approval matrix simulator | ENG-054; ENG-066 | Not started — new in v2. | critical |
| ENG-160 | Session revocation and device cache policy | ENG-055; ENG-013 | Not started — new in v2. | critical |
| ENG-161 | Scoped external accountant access | ENG-014; ENG-022 | Not started — new in v2. | high |
| ENG-162 | Storage cleanup and quota explorer | ENG-131; ENG-153 | Not started — new in v2. | high |
| ENG-167 | Post-dated cheque custody and bounce | ENG-031; ENG-032 | Not started — new in v2. | critical |
| ENG-168 | Treasury forecast scenarios | ENG-032; ENG-167 | Not started — new in v2. | high |
| ENG-169 | Petty cash and mobile expense capture | ENG-031; ENG-160 | Not started — new in v2. | high |
| ENG-170 | Retailer self-service order portal | ENG-057; ENG-053 | Not started — new in v2 (its portal base, ENG-057, is substantially live). | high |
| ENG-171 | Supplier bidding and invoice portal | ENG-029; ENG-045 | Not started — new in v2. | critical |
| ENG-177 | Barcode and price label studio | ENG-037; ENG-157 | Not started — new in v2. | high |
| ENG-179 | TV and kiosk scoped mode | ENG-125; ENG-129 | Not started — new in v2. | high |
| ENG-185 | No-KYC paid and trial policy contract | ENG-004; ENG-150; ENG-184 | Substantially live — the no-KYC policy is the owner-decided baseline (2026-11-07, service-provider principle) and is live in the shipped onboarding (identity-review gate removed). v2's named policy-contract deliverable is a formalisation of a decision already in force. | critical |
| ENG-187 | MRR movement and FX oracle | ENG-135; ENG-138 | Not started — new in v2. | high |
| ENG-190 | Operator segregation negative suite | ENG-150; ENG-141; ENG-144 | Not started — new in v2. (Segregation is enforced by the exactly-one-role verifier + settlement SoD; the named negative suite is not built.) | critical |
| ENG-191 | Tenant invoice payment links | ENG-081; ENG-086; ENG-126 | Not started — depends on ENG-086 (owner-gated sandbox); tenant invoice payment links are not built. | critical |
| ENG-192 | Tenant customer dunning rules | ENG-082; ENG-137; ENG-170 | Not started — new in v2. | high |
| ENG-203 | Anchor pack: Beverage route empties deposit and cooler | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — anchor pack; awaits the W2 pack platform (ENG-061–072) and a pilot sponsor (milestone M5). | high |
| ENG-204 | Anchor pack: FMCG scheme freegoods claims and collections | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — anchor pack; same gate as ENG-203. | high |
| ENG-220 | Tenant administration access and configuration lifecycle | ENG-131; ENG-153; ENG-159; ENG-160 | Partially live — tenant-admin configuration lifecycle exists in practice (operator console Settings; tenant Company Settings surface in the frontend, fixture-gated until the oc20 admin flip); the lifecycle package as specified is not built. | critical |
| ENG-222 | Optional country connector setup and fiscal delivery | ENG-149; ENG-082; ENG-094 | Partially evidenced — the FBR module (pk_fbr, oc14) is the pattern's first working instance (tenant credentials, validate-or-error activation, outbox-backed delivery); the generic connector contract + acceptance are not formalised. This is also the vehicle from which the W3 sa_zatca package gets minted. | critical |

*W2 count check: 75 items.*

### 6.4 W3 — Industry pilots + suite breadth I (ENG-097–108 + 37 v2 additions)

**Status: not started.** The v1 plan's W3 position stands unchanged for the original twelve: the distribution family (ENG-097–099) rides on W1's supply/commerce core and W2's pack platform; services (ENG-100) reuses the W1 services pilot chain shape; vehicle (ENG-101–103), food (ENG-104/105), the manufacturing pilot (ENG-106 — pilot depth only) and the bounded pharmacy pilot (ENG-107 — regulated depth is ENG-201 in W4) follow; ENG-108 closes the wave. That internal order is a derivation from the industry crosswalk + acceptance texts (the CSV gives every W3 original the same flat dependency, "Released core and pack platform"), labelled as such here exactly as in the v1 plan. v2's 37 additions bring the anchor-pack forms of the same industries (ENG-197–200, 202, 207–210), HR/ESS depth (ENG-174–176, 193–196), collaboration and suite value streams (ENG-164–166, 172, 212, 214, 215, 219) and platform items (ENG-133, 140, 145, 147, 152, 155, 156, 158, 173, 178, 180, 188, 189) — all not started; ENG-189 gates the value streams, and ENG-175 (payroll pilot) is doubly gated on ENG-096 + ENG-174. **The Saudi question** is re-scored at §3/F2: the specification is complete in v2; the dedicated `sa_zatca` row is minted at wave start (M7). **Entry gate (unchanged):** W1 core released **and** W2 pack platform released. **Exit gate:** ENG-108's evidence per pack under the "no unsupported claim" rule — plus, for the wave as §1 defines it, the ZATCA half, which is closable only via the minted package (F2).

#### W3 — Industry pilots + suite breadth I (49 items) — item table

| ENG | Title | Depends on (CSV) | Status today (evidence-mapped) | Risk |
|---|---|---|---|---|
| ENG-097 | Distribution route sales | Released core and pack platform | Not started — W1 Slices 7–8 built the shared supply/commerce core it rides on; the route-sales workflow itself is not started. | high |
| ENG-098 | Beverage containers | Released core and pack platform | Not started — deposit-ledger workflow not started (its anchor-pack form is ENG-203, W2). | high |
| ENG-099 | FMCG claims | Released core and pack platform | Not started — claims workflow not started (anchor form ENG-204, W2). | high |
| ENG-100 | Service jobs | Released core and pack platform | Not started — the W1 services pilot chain is its shape (exercised at Slice 10); the pack itself is not started. | high |
| ENG-101 | EV battery records | Released core and pack platform | Not started. (Anchor form: ENG-197.) | high |
| ENG-102 | Dealership allocation | Released core and pack platform | Not started. (Anchor form: ENG-198.) | high |
| ENG-103 | Motorcycle service | Released core and pack platform | Not started. (Anchor form: ENG-199.) | high |
| ENG-104 | Bakery batch | Released core and pack platform | Not started. (Anchor form: ENG-200.) | high |
| ENG-105 | Restaurant KDS | Released core and pack platform | Not started. (Anchor form: ENG-202.) | high |
| ENG-106 | Manufacturing pilot | Released core and pack platform | Not started — engine manufacturing exists on tenant sites but is unvalidated for this pilot. (Depth forms: ENG-205/206, W4.) | high |
| ENG-107 | Pharmacy pilot | Released core and pack platform | Not started — bounded pilot only; regulated depth is ENG-201 (W4). | high |
| ENG-108 | Industry certification gate | Released core and pack platform | Not started — closes the wave; presupposes the pilots above. | high |
| ENG-133 | App dependency and packaging matrix | ENG-062; ENG-069; ENG-132 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-140 | Partner commission ledger | ENG-135; ENG-146 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-145 | Broadcast and changelog publishing | ENG-139; ENG-150; ENG-023 | Not started — new in v2; no lane evidence as of 2026-11-10. (The backlog's only medium-risk row.) | medium |
| ENG-147 | Masked staging clone | ENG-003; ENG-141 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-152 | Tenant sandbox and config promotion | ENG-147; ENG-069 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-155 | Custom portal domain and sender identity | ENG-122; ENG-082 | Not started — new in v2; no lane evidence as of 2026-11-10. (Its portal base, ENG-057, is substantially live.) | high |
| ENG-156 | Tenant messaging connection and credits | ENG-082; ENG-131 | Not started — new in v2; no lane evidence as of 2026-11-10. (Messaging transport is ENG-082, partially live.) | high |
| ENG-158 | Customer-owned encrypted backup delivery | ENG-186; ENG-132; ENG-014 | Not started — new in v2; no lane evidence as of 2026-11-10. (Depends on ENG-186's coverage closure.) | critical |
| ENG-164 | Document chat and mentions | ENG-129; ENG-130 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-165 | Signing envelope and evidence | ENG-130; ENG-133 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-166 | Scoped multilingual copilot drawer | ENG-139; ENG-129; ENG-154 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-172 | Omnichannel inbox | ENG-082; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-173 | Privacy-bounded route and technician map | ENG-097; ENG-100 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-174 | Employee self-service workflows | ENG-014; ENG-133 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-175 | Country payroll and salary file pilot | ENG-096; ENG-174 | Not started — new in v2; no lane evidence as of 2026-11-10. Doubly gated: depends on ENG-096 (country release gate, not started) and ENG-174. | critical |
| ENG-176 | Company document vault | ENG-022; ENG-130 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-178 | Import landed cost and LC tracking | ENG-043; ENG-029 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-180 | Voice-to-transaction draft | ENG-166; ENG-075 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-188 | Staging clone leak test | ENG-147; ENG-152 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-189 | Licence and embedded engine gate | ENG-006; ENG-133 | Not started — new in v2; no lane evidence as of 2026-11-10. Gate package: the suite value streams (ENG-212/214/215 in W3; 213/216/217/218 in W4) depend on its licence/engine verdicts. | high |
| ENG-193 | Employee profile and asset onboarding | ENG-174; ENG-176 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-194 | Attendance biometric and shift rules | ENG-157; ENG-174 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-195 | Leave loan and advance workflow | ENG-174; ENG-175 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-196 | Payslip and tax certificate access | ENG-174; ENG-175 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-197 | Anchor pack: EV bike battery pairing sale and warranty | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-198 | Anchor pack: Car franchise VIN trade-in and delivery | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-199 | Anchor pack: Motorcycle workshop estimate old-part and release | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-200 | Anchor pack: Bakery recipe batch gram-sale and waste | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-202 | Anchor pack: Restaurant modifier KDS split-bill and shift | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-207 | Anchor pack: Technical service AMC calibration and certificate | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-208 | Anchor pack: Professional project scope time retainer and billing | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-209 | Anchor pack: Omnichannel retail giftcards loyalty and exchange | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-210 | Anchor pack: Equipment rental booking inspection and deposit | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-212 | CRM engagement territory and appointment conversion | ENG-125; ENG-128; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-214 | Helpdesk knowledge and consented assistance | ENG-141; ENG-172; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-215 | Project agile delivery and billable-time release | ENG-164; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-219 | Web commerce catalog checkout and customer recovery | ENG-170; ENG-191; ENG-177 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |

*W3 count check: 49 items.*

### 6.5 W4 — Enterprise controls, anchors, suite breadth II (ENG-109–120 + 10 v2 additions)

**Status: planned, with significant pre-builds in the original twelve** — the v1 plan's overlap map, updated in the rows below: ENG-112 is substantially pre-built (only its alerting half is open, on an owner-held input), ENG-113 partially proven, ENG-109/115 partially live, ENG-116 partially proven console-side, ENG-118 partially built, ENG-119's foundation built, ENG-120 partially evidenced by the pilot. **Read the rows before planning any W4 item — nothing already live is to be re-planned.** The derived internal order from the v1 plan stands (ENG-112/113 first → ENG-109 → ENG-110 → ENG-111 → ENG-115 → ENG-116/117/118 → ENG-114 when a second region is commercially committed → ENG-119 → ENG-120 last); it is a derivation from the acceptance texts, the CSV giving one flat dependency ("Working pilots"). v2's ten additions answer F3's industry half (ENG-201/205/206), add the regional pair (ENG-142/143) and the W4 value streams (ENG-213/216/217/218/221) — all not started. **Entry gate:** working pilots. **Exit gate:** ENG-120's evidence plus the governance OPS + EXIT gates; per-pack specialist/authority evidence for the anchor rows.

#### W4 — Enterprise controls, anchors + suite breadth II (22 items) — item table

| ENG | Title | Depends on (CSV) | Status today (evidence-mapped) | Risk |
|---|---|---|---|---|
| ENG-109 | Observability | Working pilots | Partially live — watch jobs (2-min/5-min legs + OnFailure alerts) and observability audits/fixes are live; correlated traces/metrics/logs as one system are not built, and alert delivery waits on the owner's webhook URL. | critical |
| ENG-110 | Representative load | Working pilots | Plan only — files/SCALING-ROADMAP.md is a measured capacity plan, not a load test; no representative-load run has been performed. | critical |
| ENG-111 | Noisy neighbor | Working pilots | Not started — tenant isolation exists architecturally; no starvation proof. | critical |
| ENG-112 | Automated backup | Working pilots | Substantially pre-built — restic → Cloudflare R2 backups live (provider DB daily 02:50 UTC, Keycloak daily, provider retention), restore from the off-VPS copy proven. Open half: failed/stale backup → accountable alert, awaiting the owner's webhook URL + healthchecks check. | critical |
| ENG-113 | Disaster restore | Working pilots | Partially proven — restores are restore-read verified repeatedly (incl. the 2026-11-08 full-backup order); a full-service recovery against a measured RTO target has never been run as one drill. | critical |
| ENG-114 | Regional cell | Working pilots | Not started — single region (Jakarta) is a named known limit; deliberately trigger-gated (SCALING-ROADMAP Stage 4). | critical |
| ENG-115 | Release canary | Working pilots | Partially live — release practice is canary-like (real image gate, disposable fixtures, per-file backups, rollback points); a formal canary stage that blocks a failing wave is not named/built. | critical |
| ENG-116 | Accessibility and RTL | Working pilots | Partially proven — console-side: axe L3 re-run at the real origin, zero violations (2026-11-09); tenant-surface WCAG scope + RTL are unproven. | critical |
| ENG-117 | AI safety evaluation | Working pilots | Not started — no tenant-facing AI feature is live to evaluate. | critical |
| ENG-118 | Security review closure | Working pilots | Partially built — adversarial OIDC test pack (W1 Slice 2) + audit skills installed; the wave-level closure pass (every critical/high closed or formally accepted, one gate record) has not been run. | critical |
| ENG-119 | Customer exit | Working pilots | Foundation built — export-authorization layer (Slice 4: queued export, permission re-check at download); the full exit drill (complete export incl. attachments, retained fiscal records verified) has not been run. | critical |
| ENG-120 | Operational launch | Working pilots | Partially evidenced — the Rektrs pilot ran the real lifecycle end-to-end (2026-11-08); SLO terms, incident drills and renewal/upgrade as operations are not proven. | critical |
| ENG-142 | Sanitized warm pool pilot | ENG-132; ENG-133 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-143 | Regional tenant migration | ENG-112; ENG-132 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |
| ENG-201 | Anchor pack: Pharmacy licensed dispensing cold-chain and recall | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. This is ENG-107's regulated depth — it answers the industry half of re-scored finding F3. | critical |
| ENG-205 | Anchor pack: Discrete manufacturing revision WIP and serial genealogy | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. Answers the manufacturing half of re-scored finding F3 (with ENG-206). | critical |
| ENG-206 | Anchor pack: Process batch potency co-products and packaging | ENG-061; ENG-064; ENG-066; ENG-128 | Not started — new in v2; no lane evidence as of 2026-11-10. See ENG-205. | critical |
| ENG-213 | Campaign social form and survey publication | ENG-156; ENG-172; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-216 | Recruitment performance learning and qualification | ENG-174; ENG-193; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-217 | Workplace collaboration mail meeting and office revision | ENG-164; ENG-176; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-218 | Governed BI dataset forecast and executive publication | ENG-129; ENG-187; ENG-189 | Not started — new in v2; no lane evidence as of 2026-11-10. | high |
| ENG-221 | Provider fleet release recovery and customer service operation | ENG-132; ENG-139; ENG-143; ENG-144 | Not started — new in v2; no lane evidence as of 2026-11-10. | critical |

*W4 count check: 22 items.*

### 6.6 W5 — Wider MENA + selected global markets (0 items, by design)

**There is no W5 item table, because blueprint v2 contains no W5 items** — the CSV's waves are W0–W4 only (machine-verified, §7), exactly as in v1. What changed between v1 and v2 is the framing, re-scored at §3/F1: v2 defines W5 as a **per-country programme**. The machinery is specified — `compliance/05`'s 10-step complete work package per country (entity/registration mapping → official sources → local accountant verification → tax calculation coverage → fiscal document lifecycle → payroll/privacy/sector review → partner route + credentials custody → supported-matrix publication → golden fixtures + sandbox evidence + runbook → source/effective-date maintenance), the 249-entry discovery registry, and the country-pack production checklist. Four screens carry W5 phase tags (SCR-142/143, SCR-222/223). Three requirements remain parked at W5 in v2's traceability (REQ-012/017/019), each "specified at blueprint depth; not claimed". **Plan treatment:** a country enters build only when its work package's discovery steps are evidenced; its delivery package is minted then, on the ENG-222 pattern — the same treatment §3/F3 applies to GCC country packs. Exit is per-country ("commercial readiness"); W5 as a wave never "closes", and no milestone in §5 promises one.

---

## 7. INTEGRITY RULES (how this document was kept honest)

1. **Every ENG item appears exactly once, as a table row under its CSV wave.** Machine check run at build time (2026-11-10): item rows (lines beginning `| ENG-`) were extracted from this document and compared against `engineering/delivery-backlog.csv` — **222 rows extracted; the ID set is identical to the CSV's; every ID occurs exactly once; every item sits under its CSV wave** (per-wave counts 14 / 62 / 75 / 49 / 22, W5 = 0). The check script's output is recorded in the companion report `hidden_files/team-plan-v2-amendment.md`.
2. **Titles, dependencies and risk levels are the CSV's own words.** Only the Status column (and the section prose) is this plan's writing. ENG-004's title is v2's corrected one; the v1 plan's roster remains readable via §6.1's note.
3. **Statuses are claimed only where a source evidences them** — a lane report, a memory entry, or the handover — and the evidence is named in the cell. In particular: W0 is claimed closed at *wave level* on the recorded snapshot's authority, with its per-item caveat stated at §6.1 and **not** softened; W1 slice completions are reported as build evidence, not ENG closures; the write programme is reported as *built, at its proof gate* — not live — because oc20 has not been packaged and the server lane's final bench pass was still in flight at the last census; W3/W4 additions are "not started" because no source evidences otherwise.
4. **Blueprint-vs-reality overlaps are mapped, not double-planned** — the W4 table (backup, restore, observability, canary practice, exit foundation), the W2 table (FBR/outbox substance ahead of the wave), and the W1 rows for ENG-150/163/182/184 (v2 packages whose substance the programme already operates).
5. **Blueprint-internal gaps are re-scored, not silently resolved** (§3): F1 reframed as v2's design stance; F2 narrowed to one missing row with a minting instruction at M7; F3 resolved for industry, programme-level for GCC countries. The lesser v1-plan observation also stands corrected by events: its §2.1 note that the W2 plan's non-goals table repeated the wrong ENG range for Saudi is moot under v2 — Saudi has no range at all until the package is minted.
6. **No invented scope, dates or percentages.** Milestone sizes are relative (S/M/L/XL) against demonstrated lane throughput; v2's own elapsed envelopes assume a 5–7-contributor team and are not re-based into promises here. The owner's ~35–40% figure is recorded as a v1-scope estimate (§header) and deliberately not carried over.
7. **v2's baseline is stale by ~a day, and this plan says so.** Blueprint v2's factual baseline (`foundation/03`) has a source cut-off of 2026-11-09: it predates oc15–oc20, the login-chapter closure and the write programme. Where v2 and live evidence disagree about *current state*, live evidence governs in this plan, and the difference is visible in the affected rows (ENG-182/183/184/186). Per v2's own instruction, existing work is not re-estimated from zero — remaining acceptance is re-based onto existing evidence.
8. **Deviations are named, not smoothed over** (§4, D1–D12) — including the two that change how gates operate (D5: W1's closure waits on the owner's demo2 steps; D12: the full-approval/CEO execution model).

*End of plan. Companion lane report: `hidden_files/team-plan-v2-amendment.md`. The v1 plan (`files/PHASE-WISE-PLAN.md`) is retained unedited as the historical record.*
