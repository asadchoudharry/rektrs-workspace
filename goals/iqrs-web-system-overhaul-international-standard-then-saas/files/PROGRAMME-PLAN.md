# IQRS Web System Overhaul — Programme Plan

**Programme:** Bring iqrs.edu.pk (Smart School 7.2, CodeIgniter 3 + MySQL, Hostinger shared hosting) to international standards — every flaw in the 2026-11-07 audit fixed, proven on **staging first** — then prepare it to become a multi-school SaaS.
**Owner:** Assad (REKTRS PRIVATE LIMITED). **CEO:** Muse (parent agent). **Programme Director:** programme office (this plan's author).
**Date:** 2026-11-07 · **Status:** Planning complete; Wave 0 ready to start on the CEO's go.
**Companion documents:** `FLAW-REGISTER.md` (every flaw, owned and testable) · `SECURITY-FIX-DESIGNS.md` (Wave 1 designs) · `PRINT-SYSTEM-PLAN.md` (Wave 3) · `SAAS-READINESS.md` (Phase S) · working papers in `../hidden_files/` (`DATA-CLEANUP-DESIGNS.md`, `STANDARDS-CHECKLIST.md`).
**Evidence base:** `../../iqrs-school-mobile-app/files/WEB-APP-AUDIT-AND-DESIGN.md` + Lane A code audit + live production walk (all read-only).

---

## 1. Ground rules (non-negotiable)

1. **Staging first, always.** Nothing reaches production until it is proven on staging (`staging.iqrs.edu.pk`, DB `u238632175_test123`) and Assad approves the specific rollout. Production is not a test environment and is not touched by this programme's engineering lanes at all.
2. **One change at a time, verified.** Every staging change lands alone, is smoke-tested, and is recorded in the staging change log before the next begins. No batch uploads of untested edits.
3. **Backup before every change.** The file(s) about to change are copied in-place with a dated suffix first; any data-touching change takes a DB snapshot first. Rollback is always "restore the copy", never "remember what it was".
4. **No lockouts, no money drift.** Two invariants override all schedules: the password migration must not lock a single family out, and no fee-affecting change may move any student's balance by one paisa without a reconciliation proof.
5. **The shipped mobile apps are live consumers.** The Family and Admin apps (through the vendor API and IQRS's staff extension) must keep working after every API change. Backward compatibility is an acceptance criterion, not a hope.
6. **School-content decisions belong to Assad** — prepared by the programme as one-tap proposals (subjects list, exam structure, session month), never as engineering blockers and never decided silently by engineers.
7. **No credentials in any document, ticket or chat.** Access happens through the existing secure flows only.

---

## 2. Organisation — the board and the team (25 named roles)

The CEO (parent agent) holds final authority, owns the relationship with Assad, operates the hosting/browser surface, and is the only role that may propose a production change. The Programme Director runs the plan, the flaw register, wave gates and reporting. Board members own their domains; workstream leads own delivery inside them.

### 2.1 Board

| # | Role | Owns | Key duties in this programme |
|---|---|---|---|
| 1 | **Chief Executive Officer (CEO)** | The programme, the owner relationship, all production decisions | Approves wave starts and every production proposal with Assad; operates Hostinger File Manager / browser surface; final sign-off at each gate |
| 2 | **Programme Director** | Plan, flaw register, wave gates, reporting | This plan; sequencing; the register's completeness; weekly owner summary; risk log |
| 3 | **Chief Technology Officer (CTO)** | Architecture, staging engineering, code-pipeline integrity | Owns the local code trees and diffs; rules on vendor-core edits vs extension-pattern builds; owns rollback engineering |
| 4 | **Chief Information Security Officer (CISO)** | Security workstream, Wave 1 | Owns `SECURITY-FIX-DESIGNS.md` delivery; security acceptance at every wave gate (not just Wave 1) |
| 5 | **Chief Product Officer (CPO)** | Workflows, flaw backlog, acceptance criteria | Owns the flaw register's product truth; writes acceptance tests with QA; owns the school-content proposals for Assad |
| 6 | **Chief Design Officer (CDO)** | Calm Campus Web design system, print design | Owns tokens/components; governs the Direction A system + D journey discipline + E Worklist borrowing; owns the three owner-endorsed design additions (§4, Wave 5 addendum): the navigation system, the department launchpad dashboard, and the Student Card (the card's print rendering co-owned with the Print Lead); co-owns Wave 3 print design with the Print Lead |
| 7 | **Head of QA & Standards** | International-standards gate, test discipline | Owns `STANDARDS-CHECKLIST.md`; no wave closes without their checklist pass; owns the acceptance-test library |
| 8 | **Head of Data** | Data integrity, cleanup tooling, reconciliations | Owns Wave 4; signs every money/data reconciliation; owns the discount-ledger data design (Wave 6) |
| 9 | **SaaS Architect** | Phase S readiness | Board advisor from Wave 0; owns `SAAS-READINESS.md`; reviews Waves 1–6 decisions against the "Decisions to make NOW" list so SaaS stays possible |

### 2.2 Workstreams and delivery roles

| # | Role | Workstream | Owns (deliverables) |
|---|---|---|---|
| 10 | **Security Engineering Lead** | Security Engineering | Wave 1 code: password migration, payload purge, IDOR guard, token redesign, upload validation |
| 11 | **Application Security Engineer** | Security Engineering | Login throttling, error envelope, logging, debug-surface removal; security regression tests |
| 12 | **Core Workflows Engineering Lead** | Core Workflows | Wave 2: fees report filter, dashboard counts, attendance grid, homework joins, exam guards |
| 13 | **Backend Engineer — Money & Records** | Core Workflows | Fee-model internals, audit rows + idempotency on writes, Leave/transactions, raw-SQL parameterisation |
| 14 | **API & Mobile Liaison Engineer** | Core Workflows / Platform | Guards the contract with the shipped Family/Admin apps; contract tests; owns extension-pattern builds (change-password endpoint, device-token endpoint) |
| 15 | **Print Systems Lead** | Print Systems | Wave 3 end-to-end; owns `PRINT-SYSTEM-PLAN.md` delivery and the unified print layer |
| 16 | **Print Designer** | Print Systems | Document templates: header/crest treatment, page profiles, challan copies, certificates |
| 17 | **Print QA Engineer** | Print Systems | Print QA matrix (paper sizes, browsers, Urdu text, photos, duplicates); signs the print gate |
| 18 | **Design Implementation Lead** | Design Implementation | Wave 5: token layer + component library on the CodeIgniter views; theme build |
| 19 | **UX Engineer — Journeys & Portal** | Design Implementation | Direction D journey discipline on parent/money flows; portal home; E Worklist on admin home |
| 20 | **Data Cleanup Tooling Lead** | Data Cleanup Tooling | Wave 4 tools: seeders, consolidation, review queues — all dry-run-first |
| 21 | **Data Quality Analyst** | Data Cleanup Tooling | HR/student completeness worklists; duplicate analysis; reconciliation reports |
| 22 | **Platform & Staging Engineer** | Platform & Staging | Wave 0 foundation; staging backups/snapshots; deploy mechanics; uptime/logging plumbing |
| 23 | **QA Engineer — Regression & Acceptance** | QA & Standards | Acceptance-test execution per flaw ID; staging fixture accounts and test data care |
| 24 | **Accessibility Specialist** | QA & Standards | WCAG 2.2 AA passes (Wave 5 surfaces, Wave 6 remediation); accessibility statement draft |
| 25 | **Documentation & Training Lead** | Product & Content | Staff guides (English + Urdu) per changed workflow; public-website content build; wording-debt fixes (labels, spelling) |

**Staffing note.** Roles are accountability assignments, staffed by agent lanes under the CEO/Programme Director as the programme runs; several delivery roles are already exercised by standing lanes (CISO office → security designs; Print Systems → print plan; CPO office → flaw register; SaaS Architect → readiness paper; Head of Data + Head of QA → cleanup designs + standards checklist). A role named here is a promise that someone is answerable for that outcome at every wave gate.

---

## 3. Current asset position (what we hold locally, what we lack)

**Held locally (byte-identical to production where it matters):**
- The complete vendor **API application**: `~/workspace/iqrs-api/production/api/` (controllers incl. `Webservice.php`, `Auth.php`, `Payment.php`; ~40 models; config) — md5-verified against the purchased package (`~/workspace/iqrs-legacy-source/smart_school_mobile_api_src/`).
- IQRS's own **staff API extension**: `~/workspace/iqrs-api/staff-ext/` — the proven patterns (bcrypt, `random_bytes` tokens, session-derived identity, idempotency, audit log) the overhaul reuses.
- Three **web-admin view files** from the earlier fees display fix: `~/workspace/iqrs-webfix/display/` (`studentShow.php`, `_getBalanceFee.php`, `getcollectfee.php`, orig + patched) — proof of the web view structure, not coverage of it.
- The purchased package's Flutter app source and docs (legacy mobile reference only).

**Not held — the programme's first dependency:** the **web admin application's own source** (admin + portal controllers/views, reports, print templates, payroll) exists only on the server. Most Wave 2 web-side bugs, nearly all of Wave 3 print, and Wave 5's theme work are designed against the API evidence today and must be confirmed against the real web tree. Wave 0 exists precisely to close this gap before any web-side engineering is promised.

---

## 4. Wave plan

### Wave 0 — Staging foundation (gate: engineering can begin safely)
- **Full staging tree + DB snapshot obtained and archived locally** (see §6 pipeline asks): web tree (views/controllers/models/config/assets), staging DB export; production tree copied read-only for later diffing.
- **Pipeline round-trip proven**: one harmless staging file downloaded → edited locally → uploaded → verified byte-identical intent → rolled back from its backup copy.
- **Staging fixtures created**: disposable student + parent test accounts on staging (the mobile programme's Wave B lesson: no staging family identity existed, so family writes could not be live-proven — this programme fixes that first), plus the existing staff fixtures 113/114 retained.
- **Baseline pack**: staging change log started; backup naming + snapshot convention live; flaw register baselined; print inventory (local portion) done.
- **Exit criteria:** CTO + Platform Engineer certify the tree is complete and the round-trip works; CISO confirms no production surface was touched.

### Wave 1 — Security (designs: `SECURITY-FIX-DESIGNS.md`)
- **1A quick wins (config/one-line class):** `prodcution` typo + `db_debug` forced off; JSON error envelope for the API; password removed from API payloads; offline-payment + document upload validation with randomised names; application logging on; `geeee()` debug endpoint and path-leaking `die()` removed; server path no longer rendered on General Settings; login throttling.
- **1B structural trio:** (i) password hashing migration — dual-read login, hash-on-next-successful-login, dormant accounts untouched and still able to log in, covering web login, API login (Family app keeps working with no app update) and all password-write paths incl. a redesigned forgot-password token (high-entropy, expiring); (ii) IDOR ownership guard in the API (student ⇒ self; parent ⇒ own children only) with JSON errors the apps already handle; (iii) token redesign — `random_bytes` tokens, sane absolute+idle expiry, revocation, no mass logout.
- **1C:** change-password endpoint built the extension way (the audit's feature #4, pulled forward because it is a security control); staff/admin 2FA add-on enabled and configured on staging.
- **Exit criteria:** every Wave 1 flaw's acceptance test passes on staging, including a full family-login regression with fixture accounts on web + API + both mobile apps pointed at staging.

### Wave 2 — Workflow bugs (Core Workflows)
- Fees: Search Due Fees honours Class/Section; Dashboard "Fees Awaiting Payment" tile counts the right records; fee fine logic consolidated to one implementation; raw-SQL hot spots parameterised.
- Attendance: grid renders exactly the configured statuses (the 3 unlabelled radios gone), numeric sorting, Section survives a search, default = unmarked with explicit "mark all absent".
- Homework/syllabus/lesson plan: double-filter fixed; INNER joins → LEFT-JOIN fallbacks so ungrouped data surfaces honestly.
- Exams: divide-by-zero guard; marks ≤ max-marks validation; dead `teacher_subjects` methods neutralised.
- Records & misc: profile-edit gate actually enforced; `Student_model::get()` null-guards (typed 404 JSON, never a 500); Leave_model transactions made real; library dead method removed; transport stops returning the whole student record; ratings record the true role; audit rows + idempotency keys on insert-first writes.
- **Exit criteria:** per-flaw acceptance tests green on staging; zero regressions in the Wave 1 security suite.

### Wave 3 — Print unification (plan: `PRINT-SYSTEM-PLAN.md`)
- Inventory completed from the staging tree; one print foundation (shared header/footer partials, one print stylesheet, page profiles: A4, A5 receipt, ID-card); pilot = **fee receipt** (highest volume, carries the Paid/Discount/Balance honesty rule); then document families in sequence (challans/invoices → marksheets/admit cards → ID cards → certificates → payslips → registers/reports); one preview → print/PDF workflow and one settings place everywhere. The **Student ID Card is the flagship of the identity family** (owner-endorsed, §4 Wave 5 addendum item 3): its design is produced once in this wave alongside the print foundation — see `PRINT-SYSTEM-PLAN.md` §3.6.
- **Exit criteria:** Print QA matrix signed (paper sizes, browsers, Urdu text, photos, multi-copy challans); the owner sees staging print proofs of every family.

### Wave 4 — Data cleanup tooling (designs: `hidden_files/DATA-CLEANUP-DESIGNS.md`)
- Report-first tooling, applied to staging, owner-reviewed before any production proposal: subject catalogue + subject-group seeding (un-starves homework/syllabus/timetable/My Subjects); exam-structure seeding for the session; fee-group consolidation (~951 per-student legacy-arrears groups → a small named set) with a **balances-unchanged-to-the-paisa reconciliation gate**; HR cleanup review queue (duplicates, placeholder phones, expense-items-as-staff, role/designation corrections — human-confirmed, nothing auto-deleted); student-essentials completeness worklists (DOB, guardian mobile, category).
- **Exit criteria:** staging data passes the completeness/reconciliation reports; Assad has approved the content proposals (subjects, exam structure) that the tools enact.

### Wave 5 — Calm Campus Web on staging (design: audit §3 + supplement)
- Phase 0 foundation: design-token layer (CSS variables mapped 1:1 to the approved mobile tokens; night-navy dark theme derived), component library on the existing CodeIgniter views, one SVG icon set replacing three icon fonts, one chart theme.
- Phase 1: both login screens, admin dashboard as bento + E-Worklist ("items waiting for you"), portal home/Fees/Attendance (greeting, child switcher, attendance ring, fee split-bar).
- Phase 2: module surfaces in daily-value order (Fees Collection first, then Students, Attendance, Examinations, HR, Front Office, Communicate, Library/Inventory/Transport), reports centre pattern, sidebar rationalised to role-shaped groups (unused add-ons hidden until configured), public website rebuilt on the editorial layer **with real content**.
- Phase 3 (messages): email/SMS templates on the token palette; exports inherit report typography. (Paper documents themselves are Wave 3; both waves draw on the one token system the CDO owns.)
- Journey discipline (Direction D) applied to parent-facing and money-moving flows throughout; WCAG 2.2 AA checked per surface as built.
- **Exit criteria:** staging design review with the owner; accessibility checklist pass on logins + portal; no workflow's function changed by its reskin (regression suite green).

#### Wave 5 addendum — owner design additions (Assad, endorsed 2026-11-07)

Three requirements from the owner are folded into the design scope. They answer registered flaws (FL-092 navigation, FL-037 dashboard counts, FL-090 icon-only actions, FL-043 filter-state loss, FL-072/073 print inconsistency) and are specified here so the CDO's workstream — and the CEO's parallel mockup lane (§4 note below) — build to one spec.

**1. Navigation, improved (owner requirement; answers FL-092, FL-090, FL-043).**
- **Role-shaped navigation.** The ~35-module sidebar is replaced by job groups — *Today, Students, Money, Teaching, Operations, Reports, Settings* (audit §3.4) — populated from the user's existing permission groups. A teacher, an accountant and the Super Admin each see their departments, not the module catalogue.
- **Unconfigured modules are hidden, not displayed dead.** A module whose configuration/data state is empty-by-setup (Hostel, CBSE Examination, Live Classes, Online Course, Lesson Plan until configured) does not appear in navigation. Hiding is a display rule driven by configuration state — nothing is deleted or disabled in the backend — and a Settings toggle ("show all modules") restores the full tree for the Super Admin. When a module becomes configured, it appears automatically.
- **Fast search across students and features.** One top-bar search (keyboard-summoned): students by name/admission number, staff, and features/screens by name — the office no longer navigates the tree to reach a child or a function.
- **Breadcrumbs everywhere** below the top level, so position in a 300-function system is never a guess.
- **Filter state is sacred — a navigation defect class.** Filters (class, section, date, fee group) persist across search, pagination and return-navigation; no filter control may silently reset. The audit's exemplar — the Section dropdown resetting after search (FL-043, fixed for attendance/timetable in Wave 2) — becomes a Wave 5 acceptance rule for **every** list screen in the new theme: *a filter the user set is still set when the results render.*
- **Labelled actions.** Icon-only actions gain visible labels or tooltips system-wide (FL-090); destructive actions are separated from constructive ones (the Notice Board Delete-beside-Post hazard is the pattern to retire).

**2. The dashboard becomes a department launchpad (owner requirement; answers FL-037, FL-092, FL-099).**
The admin home is a grid of **feature cards grouped by department**; each card carries live counts and, where the data supports it, an "items waiting for you" count (the Direction E Worklist borrowing, now owner-endorsed) that drills through to the filtered worklist. Cards are permission-gated (a user sees only their departments) and a department whose module is unconfigured follows the navigation rule above (hidden or shown as a single "not set up yet" card at the Super Admin's choice). **Every count on a card must reconcile with its source list** — the mislabelled-tile failure (FL-037) is the anti-pattern this spec exists to prevent; card signals are acceptance-tested against the underlying lists on staging data.

| Department card | Live signals (primary · waiting-for-you) |
|---|---|
| **Students** | Enrolled total · records incomplete (missing DOB / guardian mobile / category — the Wave 4 worklist count) · new admissions this session |
| **Academics** | Exams in the current term · homework submissions awaiting evaluation · timetable gaps (class-sections with no schedule) |
| **Fees & Accounts** | Collected today (Rs) · due this month · offline payments awaiting verification · overdue balances count — with Paid / Discount / Balance always shown separately, never merged |
| **HR** | Staff total · leave applications pending approval · staff records incomplete (Wave 4 queue count) |
| **Library** | Books in catalogue · copies currently issued · overdue returns |
| **Transport** | Active vehicles/routes · students assigned to transport (card appears when the module is configured) |
| **Communication** | Notices published this month · notices scheduled · (SMS/email delivery failures, if the send log supports it) |
| **Reports** | Shortcuts to the most-used reports (Fees Statement, Balance Fees, Attendance, Payroll) inside the reports-centre pattern; no counts unless a usage log exists — shortcuts are labelled as shortcuts, never dressed as data |
| **Settings** | Session in force · security items outstanding (links Waves 1/6 status) · last verified backup (Wave 6 signal, shown honestly as "not yet verified" until the regime exists) |

A slim **Today strip** sits above the cards (students present today, staff present today, collected today) — the three numbers the office actually opens the system for.

**3. The Student Card (owner requirement; answers FL-072/073 as Wave 3's flagship).**
One designed student ID card that lives **on screen** (the student's profile in the admin and the child's dashboard/profile in the portal — and, by the same view model, the Family app profile when the mobile programme adopts it) **and on paper** as a first-class print surface. Fields: student photo, name, class/section, roll number **and** admission number, session, **QR code and barcode** (the per-student barcode/QR assets already generated by the system — print plan finding L9), guardian contact on the reverse (print). Identity: navy/gold school identity with the **crest only as the fixed circular gold-ring badge** — the standing crest rule, no exceptions for the card. One design, two renderings: the screen card and the `CARD-CR80` print card (+ `CARD-SHEET-A4` imposition) are the same template at two outputs, governed by the unified print layer — full specification in `PRINT-SYSTEM-PLAN.md` §3.6. **Data honesty rule:** most student records currently have no photo; the card renders the approved initials placeholder where no photo exists (never a stock image, never a blank box), and the photo programme (staff-app photo capture, already live) is how real photos arrive. Design is produced once, in Wave 3 with the print foundation; the screen rendering ships with the Wave 5 profile surfaces.

**Reconciliation with the CEO's mockup lane.** A separate design lane (commissioned by the CEO) is producing a viewable mockup of the Student Card plus a dashboard/navigation spec, landing in this goal's `files/` folder. When it lands, the CDO reconciles it against this addendum and the identity/token rules: the mockup is adopted as the visual reference for items 1–3, any conflict is resolved **in favour of the token/identity rules and this spec's functional requirements** (role-gating, config-driven hiding, count reconciliation, crest rule), and the resolution is recorded as an amendment note in this section. Until it lands, nothing in Waves 0–4 waits for it.

### Wave 6 — Standards hardening (checklist: `hidden_files/STANDARDS-CHECKLIST.md`)
- Structural data fix: discount separated from payments in the fee model (discount ledger, status from paid-only) behind a full-population reconciliation proof.
- Backup & recovery regime: automated off-site backups, retention, a dated restore drill, documented RTO/RPO; operations runbook (uptime monitoring, patch cadence, incident contacts, named owner).
- Privacy programme: bilingual privacy notice, per-child photo/consent recording, retention + leaver-deletion, family export/delete path.
- Accessibility remediation across admin; accessibility statement published.
- API contract: versioned, documented endpoints; per-integration scoped keys; contract tests between apps and backend.
- HR/payroll data verification support (records reconciled against physical files by the school office, tooling by this programme); timetable data build-out on the Wave 4 foundations.
- **Exit criteria:** the standards checklist is green or carries only owner-accepted risks, each written down with his sign-off.

### Phase S — SaaS (paper: `SAAS-READINESS.md`)
- Begins only after Wave 6. Deploy-per-tenant first (per the readiness paper's recommendation), pilot with one friendly school, platform layer (provisioning, per-school theming from the token system, billing hooks, per-tenant backup) built as an extension — never by forking the school product. Vendor-licence clarity is a gating item before any commercial step.

**Sequencing logic (from the audit, adopted):** security before everything (it protects data already held) → workflow truth (reports and registers people rely on daily) → print (the school's paper face) → data (so academic modules have something true to show) → design (visible renewal on a trustworthy base) → hardening (the standards the audit measured) → SaaS (a product other schools can trust).

---

## 5. Staging protocol (how every change is made)

1. **Intake.** Work starts only from a flaw ID (or an approved feature/proposal). The register row carries the acceptance test before code exists.
2. **Backup.** Platform Engineer (via CEO's browser operations, §6) copies each target file in place: `Name.php.bak-YYYY-MM-DD-<flawid>`; data changes first export the affected tables / full staging DB.
3. **Local edit.** Changes are made in the local mirror tree (`~/workspace/iqrs-overhaul/` working copy, created in Wave 0), diffed and reviewed by the owning lead + one board reviewer for security/money touches.
4. **Upload + verify.** One flaw's files at a time; post-upload size/hash check; then the acceptance test (curl/API probes with fixture accounts; browser walk for screens) and the register row is updated with evidence.
5. **Rollback.** Any failed verification → restore the `.bak` copy immediately, record the failure mode in the register; no "fix forward" on staging without a fresh backup.
6. **Change log.** Every staging mutation is one line: date, flaw ID, files, backup names, verifier, result. The log is the programme's memory and the production-rollout manifest later.
7. **Production.** Out of scope for engineering lanes. When a wave is staging-green, the CEO prepares a rollout proposal (exact files, exact data steps, rollback) for Assad's explicit approval — the same discipline as the earlier Staffapi.php swaps, at wave scale.

---

## 6. Code pipeline — what the CEO (parent) must operate for us

File operations on Hostinger are performed by the CEO through the File Manager browser surface (the pattern already proven for the Staffapi.php swaps: verify current size → backup copy → upload → verify new size). The programme will hand the CEO exact manifests; the CEO never improvises file operations.

**Wave 0 asks (one-time):**
1. **Download the complete staging web tree** — in the File Manager for `public_html/staging/`: compress the whole folder (or in parts if size demands: `application/` first, then `assets/`, then root files) and download the ZIP(s). Critical subtrees: `application/views/**` (admin, portal, print templates), `application/controllers/**`, `application/models/**`, `application/config/**`, `assets/**`, `index.php`. Deliverable to programme: the ZIP(s) in the workspace.
2. **Export the staging database** (`u238632175_test123`) via phpMyAdmin → full SQL export, delivered to the workspace. (Schema + data: cleanup tooling is designed against real shapes.)
3. **Copy the production web tree the same way (read-only download, no changes)** — needed to diff staging vs production before any rollout proposal, and to confirm staging is a faithful mirror.
4. **Create the staging fixture accounts** per the QA Engineer's spec (one disposable student + one parent with a known test child on staging) — via the staging admin UI, values recorded in the programme's secure store, never in documents.

**Per-change asks (every wave):** for each flaw bundle, the CEO receives: exact file list with local paths, expected byte sizes + sha256 of each new file, the backup names to create first, and the post-upload verification the CEO confirms (size match). Uploads overwrite only the named files. Database steps, when a flaw needs them, arrive as a reviewed SQL script with its rollback script paired — executed on staging only, after its snapshot.

**Standing asks:** none. The programme does not need production access, credentials, or settings changes outside the above.

---

## 7. Decision points for Assad (prepared proposals, never blockers)

Each arrives as a short proposal with a recommended default; engineering proceeds on everything else meanwhile.

| # | Decision | Programme prepares | Needed by |
|---|---|---|---|
| D1 | **Subject catalogue** — the real subject list per class band (English, Urdu, Maths, Science, Islamiat, …) and subject-group structure | A default Pakistani-school proposal mapped to his classes/sections, for one-tap approval or edits | Wave 4 (seed data ready earlier) |
| D2 | **Exam structure** for the session — terms inside the 8 existing groups, dates, subjects, max marks | A proposed term calendar with per-subject max-marks defaults | Wave 4 |
| D3 | **Session start month** — December is set; intentional? | One-line question with the consequence of changing it | Wave 4 |
| D4 | **Consolidated fee-group naming** for legacy arrears (e.g. one "Legacy Arrears — AFM" group) | Naming proposal + the reconciliation report format he'll see | Wave 4 |
| D5 | **HR record truth** — which duplicate is real, real phone numbers, removing expense-items-as-staff | The review queue itself — he/the office confirms row by row | Wave 4 |
| D6 | **Print facts** — pre-printed stationery in use? office printer types? bank challan copy requirements? | Short question list from the Print Lead; design defaults proceed meanwhile | Wave 3 |
| D7 | **Public website content** — about/admissions text, photos, social links | Draft content built from school facts already known, for his edit | Wave 5 |
| D8 | **Dormant-account password policy** — optional forced-reset campaign after the hashing migration (default: none — nobody is locked out) | One-paragraph explainer with the security trade-off | Wave 1 close |
| D9 | **Privacy notice + photo-consent wording** (English/Urdu) | Drafted texts for approval | Wave 6 |
| D10 | **Online-fees merchant accounts** (JazzCash etc.) — a §5 feature, not a flaw fix | The activation checklist when he's ready; the overhaul does not wait for it | Post-Wave 6 feature track |

---

## 8. Risks (programme-level; the register carries flaw-level risk)

1. **Web-tree dependency.** Until Wave 0's download lands, all web-side designs are provisional. Mitigation: Wave 0 is first, small, and entirely within the CEO's existing browser capability.
2. **Password migration blast radius.** 1,600+ family accounts across web + API + two apps. Mitigation: dual-read design, fixture-first proof, no forced resets, rollback = restore prior auth files (the migration is additive until it isn't — see the security designs).
3. **Vendor divergence.** Every core-file edit forks from QDOCS updates. Mitigation: CTO keeps a patch registry (file, flaw, diff); extension-pattern builds preferred wherever the framework allows (the staff-API precedent).
4. **Staging data freshness.** Staging mirrors production at an unknown date; cleanup tools must re-verify shapes against the production copy before any rollout proposal. Mitigation: Wave 0 production snapshot + reconciliation gates in Wave 4/6.
5. **Shared-hosting ceiling.** File-Manager-only operations, no guaranteed cron/shell, Cloudflare bot checks on the production API. Mitigation: small verified bundles; the ops runbook (Wave 6) names what shared hosting cannot promise and what a hosting move would change — a Phase S input.

---

## 9. Reporting

- **Per wave:** a gate report (flaws closed with evidence, tests run, risks accepted) to Assad in the main chat, in Roman Urdu/English as he prefers, text by default.
- **Continuously:** the flaw register is the single source of progress truth — a flaw is "done" only when its acceptance test has passed on staging and the evidence is recorded in its row.
- **Production:** nothing is reported as live until Assad has approved that rollout and the CEO has verified it after the fact.
