# Rektrs School ERP + LMS — Gap Audit vs the PreSkool Feature List

**Date:** 2026-11-23 · **Auditor:** Muse (read-only lane) · **Subject repo:** `asadchoudharry/rektrs-school-erp-lms`, **staging branch** (tip `e46c5e22…`, last commit 2026-10-13) · **Yardstick:** `PRESKOOL-FEATURE-CENSUS-2026-11-20.md` (426 vendor pages) + `PRESKOOL-FEATURE-DISPOSITION-AND-REPLACEMENT-PLAN-2026-11-17.md` (21 REPLACE / 9 KEEP-OURS / 16 BUILD-NEW) + the census FC-1…FC-19 cards.

**Method:** the repo's own accounting (parity matrix, completion audit, phase status, all 41 acceptance docs) reconciled against code evidence (routes, OpenAPI, migrations, domain actions sampled and read, stub searches) and the live staging surface. Where docs and code conflict, code wins and the conflict is named in §4.

---

## 1. Headline

The repo is a **real, deep, single-platform rebuild** — not a scaffold and not a demo. The Laravel 13 backend source is substantially built across every school domain, with production-grade patterns (forced PostgreSQL RLS, idempotency fingerprints + advisory locks, maker-checker, exact-replay semantics) verified in sampled code. **But by the repo's own six-layer completion definition, zero modules are complete**: every module is missing the same final layers — bound providers, approved-data reconciliation, browser/device acceptance and UAT. Work stopped on **2026-10-13**; checkpoints 73–75 exist only as unmerged feature-branch candidates.

**Totals across the 34 PreSkool feature areas mapped in §2:**

| Status | Count | Meaning |
| --- | --- | --- |
| **SOURCE-COMPLETE** | **17** | DB + write API + read API + connected UI all present in source; repository runtime gate passed for the slice; acceptance (providers/data/UAT) still pending |
| **PARTIAL** | **13** | Core present but a named sub-feature, the delivery/provider layer, or UI depth is missing |
| **MISSING** | **4** | No implementation found in the backend (searched + structure-checked) |
| **ACCEPTANCE-COMPLETE** | **0** | The repo's own verdict (`FEATURE_COMPLETION_AUDIT.md`, 2026-10-04): "zero modules have passed the full completion definition; production remains NO-GO" |

**Counted code evidence (verified this audit, staging branch):**

- **406 API route methods** in `apps/platform/routes/api.php` (75 GET) — the audit's claim of "404 operations / 76 reads" is accurate to within one route. OpenAPI contract: 393 paths / 408 operations (`packages/api-contracts/openapi.yaml`, 544 KB).
- **61 Laravel migrations**, **34 domain modules** under `apps/platform/app/Domain/`, 20 API controller groups.
- **Stub ratio ≈ 0**: repo-wide search finds 1 `TODO`, 0 `FIXME`, 0 `NotImplemented`, 0 mocks in `apps/platform/app`. Sampled actions are 2–40 KB of real logic (e.g. `RecordFamilyPayment.php` 11.5 KB — Gate authorization, idempotency fingerprint + `pg_advisory_xact_lock`, transactional ledger/allocation writes; `EnrollStudent.php` 27.6 KB; `ExecuteSisPiiImport.php` 35.4 KB).
- **Tests:** 39 Laravel Feature + 6 Unit test files; 88 root Node source-test files. Repo-reported canonical gate at checkpoint 72: **126 tests / 972 assertions passed**; 553 source tests. These are repository-harness results, not staging/UAT acceptance — the repo itself says so.
- **Frontend:** the operational UI is the root Next.js shell — ~40 workspace files, several 40–90 KB, wired to the Laravel API ("connected source adapters"). The Laravel/Inertia app itself carries only 6 pages (owner claim, MFA, school application + review, day-one, initial academics) — i.e. onboarding only.
- **Mobile:** the Flutter rebuild is a **shell**: `apps/mobile/lib` = one home shell (15 KB), a journey registry and one connected-workspace file. The "89 screens" in the README are the *legacy* Flutter app audited in Phase 0, not this rebuild.
- **Live surface:** `staging.rektrs.com` (fetched 2026-11-23) presents the fresh-SaaS marketing + school-application intake ("Every newly provisioned school starts without imported student or family records"), not the ERP itself.

---

## 2. Per-module map — PreSkool → the new repo

Status key: **SC** = SOURCE-COMPLETE · **P** = PARTIAL · **M** = MISSING. Every SC row still lacks provider binding, approved-data reconciliation and UAT (see §1) — SC is a *build* verdict, not an acceptance verdict.

| # | PreSkool module | Status | Evidence in repo | What's missing |
| --- | --- | --- | --- | --- |
| 1 | Fees, Billing & Accounts core (fees-master/type/group/assign, invoices, ledger, income/expense, fine & discount rules) | **SC** | `Domain/Finance`: 10 actions (fee-plan stage/publish with publisher-bound exact replay, invoice posting 11.6 KB, payment collection 11.5 KB, adjustments, period close, reminders, exports, receipt jobs), 17 models (family account, immutable ledger, allocations, concessions, refunds), `ProcessPaymentGatewayEvent`, 5-provider adapter catalog (JazzCash, Easypaisa, Stripe, PayPal, 2Checkout); Feature tests `FinanceIntegrityTest`, `FeePlanPublishReplay…`, `FinanceReceipt…` | Provider sandbox binding; receipt/export PDF renderers; approved-data reconciliation of real fee history; role UAT |
| 2 | Examinations (exams, types, marks entry, results, grade setup, report cards) | **SC** | `Domain/AcademicOperations`: exam setup, marks recording, result transition/publication/acknowledgement, report jobs; `GradeCalculatorTest` | Report-card renderer binding; approved-data/result reconciliation; UAT |
| 3 | CBSE examinations | **P** | Add-on Compatibility Center: scholastic/co-scholastic mapping + rehearsal only (parity row LEG-ADDON-CBSE "source applied") | No CBSE engine; also decision-gated in the PreSkool plan itself (school adoption) |
| 4 | Online examinations & question bank | **P** | LMS quiz attempts (`SubmitLmsQuizAttempt`), assignment submission/grading, SCORM quarantine, xAPI/LTI ingestion | No standalone question-bank library module; quiz-engine scoring behind adapters (repo's own words); attempt integrity UAT |
| 5 | Attendance (daily, day-wise, types, reports, leave) | **SC** | `SubmitAttendanceRegister` 9.2 KB + staff register, correction maker-checker, QR/offline identity contract, role-scoped day-wise reads | Device/biometric fixtures; replay/concurrency device tests; UAT |
| 6 | Students & admissions (students, profile, admissions, promotion, parents/guardians, multi-class) | **SC** — deepest vertical | `Domain/Sis`: enrollment 27.6 KB, lifecycle transitions 24.4 KB, profile corrections, household/duplicate governance, portal identities; `Domain/Admissions`: applications, decisions, atomic admission→enrollment conversion; Academic Year Rollover Center carries promotion/rollover (`PromoteStudent.php` itself is a 757 B delegate) | Approved-data reconciliation; browser role UAT; fresh-tenant first-student journey is a 2026-10-13 *candidate*, not accepted |
| 7 | HR — staff, teachers, departments, payroll, leave, holidays | **SC** | `Domain/Operations`: employee register/lifecycle, recruitment, leave decisions, payroll prepare/decide/bank-export; master data in Configuration Center | Payroll *calculation* verification against country rules (parity matrix names this blocker itself); bank/export renderer binding; UAT |
| 8 | Academics — classes, subjects, timetable, lesson plan, homework, calendar | **SC** | Academic structure + offerings; timetable entries 10.1 KB + substitution workflow; Curriculum Quality Center (frameworks, unit/lesson plans, observations); homework via LMS assignments; annual calendar (LEG-CORE-29 "source applied") | Curriculum-authority/resource-scanning binding; approved-data import; academic UAT |
| 9 | Library (books, categories, members, issue/return, reservations, reports) | **SC** (core) | `IssueLibraryLoan` 6.8 KB, return, reservations, fine entries, custody runtime gate (checkpoint-63) | Categories as a first-class surface not evidenced; fine/stock reconciliation on approved data |
| 10 | Transport (routes, vehicles, drivers, GPS, transport fees) | **P** | Routes/vehicles/assignments, boarding events, GPS location-event ingestion, maintenance orders | **No driver register** (no driver model found); no live GPS feed/provider; capacity/privacy verification pending |
| 11 | Hostel (list, rooms, room types, fees, visitor log) | **P** | Rooms, bed allocation, hostel leave, meal events, welfare cases | Hostel *fees* not a distinct flow (would ride Finance family accounts); no hostel visitor log distinct from front-office visits |
| 12 | Inventory & assets (items, stock, issue, stores, suppliers; assets/allocation/maintenance) | **SC** (core) | `RecordInventoryMovement` 7.8 KB, procurement requisitions + decisions, fixed assets + custody events | Supplier master not evidenced as its own model; valuation/approval verification on approved data |
| 13 | Communication (notice board, email/SMS/WhatsApp, templates, parent communication) | **P** | Campaign governance is real: consent basis, quiet hours, approved template keys, maker-checker (`ScheduleCommunicationCampaign`); Family Engagement Center (requests, appointments, complaints/appeals, consent) 32 KB operations class | **No channel ever sends**: `Domain/Communication` has exactly 1 action; SMS/email/WhatsApp delivery sits behind unbound provider adapters; WhatsApp = add-on mapping + rehearsal only; no chat module (LMS discussions only) |
| 14 | Front office (visitors, gate pass, enquiries, complaints, call history) | **P** | Visitor register/transitions, service-desk tickets; enquiries via admissions intake + family requests; complaints/appeals in Family Engagement | Call-history log and gate-pass as distinct flows not evidenced |
| 15 | Alumni (alumni, add-alumni, profile, events) | **SC** (source) | Career & Alumni Center: graduation-evidenced alumni identity, expiring contact consent, mentorship safeguarding (LEG-CORE-27 "source applied") | Identity/channel providers; approved legacy data; UAT |
| 16 | Behaviour records (+ AI analysis) | **SC** (core) | Wellbeing Center: categories, bounded points, independent review, acknowledgement, interventions; checkpoint-63 runtime gate passed for the wellbeing slice | AI behaviour *analysis* is advisory-signal level only (see row 30); policy review + role UAT |
| 17 | Certificates, ID cards & print | **P** | Governed Document Center (24 KB operations: templates, generation, verification); LMS certificate issuance gated on published gradebook; thermal-print add-on mapping | **Digital ID cards: no implementation** (`id_card` appears only in the legacy audit catalog); ID-card template designer absent |
| 18 | Reports (attendance/fee/grade/financial/library reports) | **P** | Report jobs (`QueueAcademicReport`), role-scoped operational reads, staff-only analytics reads | **No custom report builder** (census FC-13); totals/parameter reconciliation on approved data pending (parity LEG-CORE-14 blocker) |
| 19 | Settings (general, academic, financial, communication, localization, security/permissions) | **SC** (core) | Configuration/Master Data/Numbering Center; Identity & Access governance (roles, permissions, MFA policy); tenant/platform settings | Country packs are "specified" only (SPEC-22); configuration precedence verification pending |
| 20 | Front CMS (pages, blog, gallery, menus, banners) | **P** | Public landing + school-application intake is live on staging; `PublicSite` controller group exists | **Blog: 0 code hits. Gallery: 0 code hits.** No page/menu/banner CMS builder |
| 21 | Annual calendar & events | **SC** (source) | Session/audience/timezone-bound calendar (LEG-CORE-29 "source applied"); events inside curriculum/calendar context | Approved calendar data + UAT |
| 22 | Fee installments & scholarships (Cards 3/4) | **SC** | Fee plans + versioned assignments; `FeeConcession` model + assignments in Finance | Scholarship *recommendation* is AI-side (row 30); zero real plans exist anywhere (no tenant data yet) |
| 23 | Online payments & receipts (Card 7 / FC-6) | **P** | Gateway-event processing with signed-event contract; receipt jobs; 5-provider catalog | No sandbox credentials bound; no webhook conformance run; receipt renderer unbound — nothing has ever been paid through it |
| 24 | Rewards & gamification (Card 16 / FC-1) | **M** | — (`reward`: 0 hits in the backend; `badge`: 1 incidental hit) | Entire module: points ledger, badge definitions, leaderboards |
| 25 | Sports (FC-4) | **M** | — (all "sport" hits are the substring in "transport") | Entire module: sports/teams/competitions registers |
| 26 | Medical / clinic (FC-5) | **P** | Wellbeing Center clinic operations: consent-bound care, clinic visits in `GovernedWellbeingOperations`, restricted safeguarding timeline | Vaccination/sickroom depth not evidenced; clinical policy review + UAT |
| 27 | Cafeteria | **M** | — (`cafeteria`/`canteen`: 0 hits; hostel *meal events* exist but are not menus/wallets/orders) | Entire module |
| 28 | Support tickets / helpdesk (FC-8) | **SC** (source) | Service-desk tickets in Operations (`RegisterServiceDeskTicket`, visit/ticket transitions); family requests with SLA in Family Engagement | Role UAT; notification delivery (row 33) |
| 29 | Automation — workflow rules & triggers (FC-9) | **SC** (source) | Unified Workflow Center: immutable versioned definitions, maker-checker activation, delegation/escalation | Runtime execution under replay/concurrency attacks (gap register item) |
| 30 | AI surfaces (FC-10/11; Cards 5/14/15) | **P** | `Domain/Intelligence`: assistant profiles, aggregate/governance reads, OpenAI Responses design with moderation, strict schemas, `store=false`, budgets/circuit breaker | Provider not bound; promotion suites (bias/drift/prompt-injection, EN/Urdu/Arabic) not run; no AI feature is live |
| 31 | Integration management — API keys, webhooks, push (FC-12) | **SC** (source) | Integration Control Center: versioned provider profiles, webhook signature/quarantine/retry contract | Official sandbox conformance for every bound provider |
| 32 | Privacy & GDPR (FC-14) | **SC** (source) | Platform Security + Tenant Data Lifecycle: rights requests, expiring exports, retention, legal holds, pseudonymisation, offboarding/destruction receipts | DLP/scanner/legal-evidence providers; privacy approvals |
| 33 | Notification operations (FC-16) | **P** | Campaigns + fee reminders + mobile push-consent reads | Delivery providers unbound (with row 13); no delivery receipts exist |
| 34 | Digital ID depth (FC-17) | **M** | — (see row 17) | Entire feature: designed ID cards with QR for students/staff |

**Beyond the PreSkool list** (the repo's own scope, for completeness): the **platform/SaaS layer** — multi-tenancy with forced RLS, provisioning, billing/entitlements, onboarding, release governance — is the repo's most complete area (fresh-school setup passed the canonical runtime gate and live Dokploy smoke at checkpoints 71–72; role/browser acceptance pending). **Student/parent portals**: portal identities + minimum-disclosure reads are implemented; portal UI depth is thin next to the staff workspaces (**P**). **Mobile**: shell only (**P**, see §1). The 9 KEEP-OURS items from the 2026-11-17 plan map as: QR attendance → contract present, device layer missing (**P**); 2FA → genuinely implemented (TOTP broker, replay counter) (**SC**); Student CV → Career Center portfolios (**SC** source); Online Course/Gmeet/Zoom → LMS + add-on mappings, providers unbound (**P**); thermal print → mapping (**P**); platform layer → above; desktop sync + exam recheck/release gates → **no counterpart found** in the new repo.

---

## 3. The repo's claims vs verified findings — discrepancies

1. **`docs/STATUS.md` and `docs/PHASE_STATUS.md` (both "Last updated: 8 August 2026") are stale and contradict the October audit.** They claim 348 API operations / 23 reads and "Finance, LMS and operations remain disconnected." Code today: 406 operations / 75 reads, with connected finance, LMS and operations workspaces. Anyone reading STATUS.md underestimates the build by ~2 months of work.
2. **`docs/ARCHITECTURE.md` claims "The Laravel runtime has not executed in the current environment because PHP/Composer/PostgreSQL are unavailable."** Contradicted by checkpoint 70–72 evidence in the completion audit (canonical Laravel/PostgreSQL/Valkey gate, 126 tests / 972 assertions, live Dokploy smoke). Stale, not false-at-writing.
3. **README's framing — "the authorized Smart School 7.2 migration" — is superseded inside the same repo.** Checkpoint 71 (recorded in `FEATURE_COMPLETION_AUDIT.md` and `FRESH_SAAS_SETUP.md`) pivoted the product to fresh SaaS: legacy import executors *reject fresh tenants, including after activation*. The README was never updated. See §5.
4. **README's "Flutter 5.0.0+1, 89 screens" describes the legacy app**, audited as a *source input* in Phase 0. The rebuild's Flutter client has 3 feature files. Read casually, the README overstates mobile by an entire app.
5. **The parity matrix is measured against Smart School, not PreSkool**, and its statuses lag the code in both directions: core rows (Fees, Exams, HR…) still sit at `discovered` — the lowest status — although their domains are the most complete in the repo; while add-on rows at `source applied` (WhatsApp, Zoom, Gmeet, thermal print) are *mapping + rehearsal* level with no provider bound — read casually, they overstate.
6. **"Zero blockers" rehearsals are not readiness evidence.** Phase/add-on rehearsals (e.g. Phase 10: 48 rows, 15 controls, zero blockers) run on deterministic sample data and self-report `ready_for_production: false`.
7. **The root Next shell mixes illustrative and connected surfaces.** The README admits the Delivery Center's school records "are illustrative and are not represented as connected Laravel production data," while the school workspaces *are* API-connected. The boundary is real but easy to misread from screenshots; the live staging homepage is the fresh-SaaS intake surface, not the ERP.
8. **Operation count verified.** Claimed 404 declared operations / 76 GET reads; counted 406 route methods / 75 GET in `routes/api.php`, 408 operations in OpenAPI. Immaterial difference (route-group counting), claim stands.
9. **Work stopped 2026-10-13.** Staging tip is the MFA hardening commit of 2026-10-13 17:19 UTC; 100+ commits landed in the final three weeks alone. Checkpoints 73–75 (owner onboarding UI, MFA broker, academic setup, single-admin activation) are described in the audit as feature-branch *candidates — not accepted, not on staging*.

---

## 4. Completion estimate

**Assumptions (explicit):** the builder is this agent loop (the same capacity that ran the IQRS overhaul lanes); staging-first discipline with per-lane proof; UAT and provider sandboxes are owner/school-gated and therefore elapsed-time risks; scope = the 34 areas in §2 plus portals + mobile; CBSE excluded unless the school adopts it; IQRS data question per §5 ruling (either path is costed in block G).

What the evidence says about the shape of the remaining work: the *build* is roughly four-fifths done (17/34 source-complete, 13 partial, 4 missing; stub ratio ≈ 0), but the *acceptance* is roughly one-tenth done (0/34 accepted; providers unbound; no real tenant data has ever run through it). Estimates below follow that shape.

| Block | Work | Range |
| --- | --- | --- |
| A. Missing modules | Rewards/gamification, sports, cafeteria, digital ID cards, CMS blog/gallery/pages, standalone question bank, custom report builder, transport driver register | **3–5 weeks** |
| B. Partial-module completion | Communication channel delivery (SMS/email/WhatsApp send + receipts), online-payment sandbox + receipt renderer, AI provider binding + promotion suites, hostel fees/visitor log, front-office call log/gate pass, library categories, portal UI depth | **3–4 weeks** |
| C. Frontend consolidation & browser acceptance | Decide Next-shell vs Inertia as the one school UI; bring staff workspaces through browser/device acceptance; parent/student portal journeys to parity | **2–3 weeks** |
| D. Mobile completion | Flutter core journeys (student/guardian/teacher) beyond the shell: device trust, push, offline sync, store readiness | **3–5 weeks** |
| E. Integrated runtime & hardening proof | The repo's own 50-step executable sequence: full RLS/concurrency attack matrix, backup/restore proof, security/load/WCAG acceptance | **2–3 weeks** |
| F. Provider & device bindings | Payments (PK-first), SMS/WhatsApp/email channels, Zoom/Meet, FCM/APNs, object storage/scanning, receipt/document renderers — sandbox conformance each | **2–3 weeks** (partly parallel with B; external-wait risk) |
| G. UAT & first-school readiness | Four UAT cohorts, owner sign-offs, first tenant stood up and operated end-to-end (fresh data entry, or governed migration if ruled — §5) | **2–4 weeks elapsed** (owner/school availability bound) |

**Total to production-accepted full scope: ~14–22 weeks of lane work, realistically 4–6 months elapsed.**

**The honest shortcut:** a *first-school pilot* on the source-complete core (platform + SIS + academics + attendance + exams + fees + communications governance, one fresh tenant, web only) needs only slices of blocks C, E and G — **~4–6 weeks**. For calibration: the earlier "5–8 weeks for a new backend" estimate assumed building from zero; this audit shows the backend source already exists, so the *pilot* lands in a similar window — but full PreSkool parity + production acceptance is a 4–6-month programme, not a 5–8-week one. The long pole is not code; it is proof.

---

## 5. ⚠️ Standing-rule tension — for the owner's ruling (flagged, not resolved)

**The product rule** (owner, recorded for this product): every tenant starts EMPTY; importing Smart School student/family data is PROHIBITED; legacy files are feature references only.

**What the repo actually contains:**

- **Migration tooling exists and is substantial.** Governed Import Center (versioned templates, maker-checker approval, dry-run validation, resumable chunk checkpoints, dual-controlled rollback, legacy-ID ledger — `GovernedImportOperations.php`, 23 KB); a SIS **academic-structure executor** (`ExecuteSisAcademicStructureImport.php`, 39.6 KB — sessions/programs/classes/sections/subjects, non-PII); a SIS **PII executor** (`ExecuteSisPiiImport.php`, 35.4 KB — students/households/guardians/enrollments, ingested from a sealed encrypted bundle bound to an approved plan checksum + source fingerprint); plus `tools/legacy-migration/` (mapping draft, plan compiler, rehearsal projector, PII bundle sealer) and per-module reconciliation tools. The PII executor tranche passed the canonical runtime gate (114 tests / 841 assertions) and checkpoint-70 live Dokploy smoke.
- **What it migrates:** academic structure + student/household/guardian/enrollment records. **Not** fee history or ledger balances — no executed legacy fee-data import is evidenced anywhere; finance reconciliation against legacy totals remains an open approved-data exercise in the repo's own gap register.
- **But the current product policy disables it.** Since checkpoint 71, tenants are created with `data_setup_mode=fresh_start`; `FRESH_SAAS_SETUP.md` states the executors "reject fresh tenants, including after activation"; the completion audit calls the tooling "historical reference"; the live staging homepage promises schools a start "without imported student or family records." The README's "Smart School 7.2 migration" framing is the pre-pivot framing.

**The ruling needed, precisely:** for IQRS as first tenant, either **(a) fresh tenant** — structure and people re-entered natively (or via the Import Center's *generic* templates for new data), fee history starts clean with governed opening balances; or **(b) a one-off "migration tenant" exception** — the SIS executors re-enabled for IQRS's structure + student/guardian records under the Import Center's approval/reconciliation discipline, with fee balances carried as opening balances only. Option (b) is technically feasible for structure + people (the tooling is built and gate-tested) but contradicts both the product's standing empty-tenant rule and the repo's current policy code; it cannot be treated as a configuration detail.

---

## 6. Decision page for the owner

**Option A — Build on this repo.** Adopt `rektrs-school-erp-lms` as the Rektrs School ERP and fund the completion programme in §4.
*For:* the expensive part (a governed, multi-tenant, RLS-safe backend across all domains) already exists and is honestly documented; it is the only asset that reaches the SaaS end-state; Sendqon already covers its SMS layer. *Against:* 4–6 months to full acceptance; mobile and 4 modules don't exist; work has been stopped since 2026-10-13 and checkpoints 73–75 are unmerged candidates; IQRS's data question needs the §5 ruling; the IQRS school still needs a working system *this* term, which this repo cannot yet give it.

**Option B — Continue the Smart School overhaul only.** Take the PreSkool-shaped Smart School build (RE-AUDIT-2 gate passed with named remainders; DEMO-SEED-1/COMPOSE-1 running) through the owner's re-check to the D-027 production deploy, and leave this repo parked.
*For:* IQRS gets its system soonest; the overhaul is weeks, not months, from its gate. *Against:* the ceiling is the legacy CodeIgniter base — every future school repeats the same overhaul; the SaaS ambition stays unbuilt; this repo's 3 months of work ages further.

**Option C — Hybrid (recommended).** Run both, sequenced: (1) finish the Smart School overhaul for IQRS now — it is the school's operating system this year; (2) in parallel, restart this repo as the SaaS product with the §4 programme, pilot-first (core scope, fresh tenant, ~4–6 weeks to a demonstrable pilot); (3) when the pilot is accepted, rule on §5 and migrate IQRS as the first real tenant — by then the migration question is answered with a running system, not on paper.
*Trade-off, honestly:* hybrid splits agent-loop capacity and delays the SaaS pilot by some weeks versus Option A; in exchange it never leaves the school without a system and never bets the school on an unaccepted platform.

---

## 7. Audit trail

Sources read in full: repo `README.md`, `docs/FEATURE_COMPLETION_AUDIT.md`, `docs/FEATURE_PARITY_MATRIX.md`, `docs/PHASE_STATUS.md`, `docs/STATUS.md`, `docs/IMPLEMENTATION_GAP_REGISTER.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/FIRST_VERTICAL_SLICE.md`, `docs/FRESH_SAAS_SETUP.md`; verdict lines of all 41 `docs/*_ACCEPTANCE.md`; code: `routes/api.php` + `routes/web.php` (counted), `packages/api-contracts/openapi.yaml` (counted), directory censuses of `app/Domain` (34), `database/migrations` (61), `tests/Feature` (39) + `tests/Unit` (6), root `tests/` (88), `apps/mobile/lib`, root `app/` workspaces, `tools/legacy-migration` + `tools/data-reconciliation`; sampled reads: `RecordFamilyPayment.php`, `SubmitAttendanceRegister.php` (head), action/model inventories for Finance, AcademicOperations, Learning, Communication, Operations, Admissions, Sis, FamilyEngagement, Documents, Imports; repo-wide code searches (TODO/FIXME/NotImplemented/mock, blog, gallery, cafeteria, reward, sport, id_card, clinic, whatsapp, homework). Live: `https://staging.rektrs.com/` fetched read-only 2026-11-23 (no login attempted). Yardstick: the two PreSkool plan/census files named in the header. Lane evidence retained in `hidden_files/gapaudit-2026-11-23/`.
