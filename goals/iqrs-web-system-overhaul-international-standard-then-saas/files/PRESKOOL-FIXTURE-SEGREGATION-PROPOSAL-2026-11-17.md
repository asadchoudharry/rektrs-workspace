# Fixture Segregation Proposal — IQRS Staging (2026-11-17)

**Status: EXECUTED 2026-11-17** (owner decision ~13:56 PKT: "Jo recommended ho kro"). See the EXECUTED note at the end of this file and the lane record at `hidden_files/preskool/segregation-2026-11-17/SEGREGATION-LANE-RECORD.md`. The original proposal text follows, unchanged.

## Why

The P0 purge (2026-11-17) deleted the script/battery fixture families that were safe to delete. What remains on staging is a set of *retained* fixtures — kept deliberately because live verification work depends on them — but they still surface inside the working lists, which is what made the staging screens read as "full of test data" in the owner's own check:

- the default Students list (Class Four) is 53 enrolments, **31 of them DEMO seed students**;
- the Collections ledger's newest page is almost entirely battery deposits for one test student;
- the dashboard heroes name test records ("Best Teacher — Test Teacher M3", "Top Student — Test Fixture W0").

This proposal segregates each retained family by the lightest mechanism that keeps its dependents working.

## Family 1 — DEMO students 3758–3788 (31 students)

**Where they surface.** All 31 are enrolled in **Four / Daffodils (Girls)** in the current session — they are the tail of the default Students list (blank roll numbers, so the new roll order puts them after the 22 real students of that class-section). They hold **no fee masters** (0). **30 of the 31** are members of the single exam in DEMO exam group 29.

**Proposed mechanism — a fixture class.** Create one class **"Fixture"** with one section, and re-point the 31 enrolments' class/section to it (the `student_session` rows themselves — and therefore their ids — do not change).

**Impact.**
- Students list: the default Class Four view drops from 53 to its 22 real enrolments; DEMO students remain fully browsable under the Fixture class.
- Exam group 29 (DEMO): memberships key on `student_session_id`, which is unchanged — the group and its exam keep all 30 members.
- Exam 19 / group 27: untouched (different students).
- Mobile apps: DEMO students are not mobile fixtures; no impact.
- Dashboards: class-size and present-today figures for Four/Daffodils become the real counts.
- Reversible: re-pointing the enrolments back restores the exact current state.

## Family 2 — Student 3699 "TEST Fixture W0"

**Where it surfaces.** One enrolment (Seven / Diamond, Hifz Boys), **9 fee masters**, **1 exam membership**, a long Fee Invoices history, and the dashboard's "Top Student" hero (its 53 behaviour points top the computation). Its deposits dominate Collections page 1 because they are the newest in the ledger.

**Proposed mechanism — retain as the designated proof fixture.** This record is load-bearing: W0-era batteries, the B6 print proofs and this lane's own attendance round-trip all key on it, and the Exam Centre mobile proof cohort overlaps its exam group. Moving or deleting it breaks those baselines for no working-list gain — it is a single, plainly-named test student.

**Decision asked (optional):** whether dashboard hero computations ("Top Student" / "Best Teacher") should exclude designated fixtures. That is a product-behaviour change, not a data move; the lane recommends deciding it together with Family 3.

## Family 3 — Staff 113 / 114 / 115 (the proof trio)

**Who they are.** 113 `TEST-M3-001` (Super Admin — holds the B6-verified payslip, October 2026, net 58,000), 114 `TEST-T-001` (Teacher — the clone source for every lane's disposable proof logins, and the dashboard's "Best Teacher" hero), 115 `TEST-W1A-115` (the zero-permission "TEST Limited" login the role-visibility audit depends on). Two payslips exist across the three.

**Proposed mechanism — retain as designated fixtures.** They surface in the staff directory (3 of 113) and in the dashboard hero. Deleting any of them breaks a standing verification capability (proof-login cloning, payslip print proof, zero-permission checks). The lane recommends retention, documented here, over segregation machinery for three records.

## Family 4 — Battery fee groups (W2A / W2B / BL035 / Checker Money / W39-SEED)

**Where they surface.** The arrears picker census lists the live fee groups: alongside the real ones (AFM 2026-11 Monthly Fee, Previous Arrears, Quick Create Fees) sit **W2A Script Fees ×7, W2B Capture Group, BL035 Fixture Fees, Checker Money, W39-SEED Overdue Fine Group**. (966 fee groups exist in total; 951 are already archived — archiving is this system's own, proven mechanism.) Battery deposits under these groups are also why Collections page 1 is test-student history: the ledger is history and stays readable either way.

**Proposed mechanism — archive the battery fee groups** (all W2A/W2B/BL035/Checker Money groups), using the same archive route the 951 already-archived groups took. Pickers stop offering them for new fee work; every historical deposit, receipt and journal line remains exactly as recorded.

**Impact.** Fee assignment pickers get shorter and real-only. No balance changes (archiving a group does not move money). **Exception:** the W39-SEED Overdue Fine Group belongs to the Exam 19 seed family — the lane recommends its fate be decided with Exam 19 itself (keep while Exam 19 is the standing mobile-proof exam).

## Family 5 — Fam merge-journal "BL-141" lines

**Where they surface.** `fam_merge_journal.reason` carries **3 lines** whose text references the BL-141 battery (plus 11 mentions inside `after_json` payloads). They appear only inside the household merge-journal drill-down.

**Proposed mechanism — none. Leave them.** The journal is an audit trail; editing recorded reasons would falsify history to hide a label. The lane recommends explicitly accepting these three lines as historical record.

## Summary of asks

| # | Family | Proposal | Needs owner tap |
|---|--------|----------|-----------------|
| 1 | DEMO students (31) | Move enrolments to a new "Fixture" class/section | Yes |
| 2 | Student 3699 | Retain as designated proof fixture | No (note only) |
| 2b | Dashboard heroes | Decide whether fixtures are excluded from hero computations | Yes |
| 3 | Staff 113/114/115 | Retain as designated fixtures | No (note only) |
| 4 | Battery fee groups | Archive W2A/W2B/BL035/Checker Money; W39-SEED decided with Exam 19 | Yes |
| 5 | Fam journal BL-141 lines | Leave (audit trail) | No |

Nothing in this proposal touches production. If approved, the moves run as their own staging lane with before/after censuses, and every step is reversible from the exports the lane takes first.

---

## EXECUTED — 2026-11-17 (segregation lane)

Owner decision ~13:56 PKT: **"Jo recommended ho kro."** All items ran
on staging only; production untouched. Full record:
`hidden_files/preskool/segregation-2026-11-17/SEGREGATION-LANE-RECORD.md`.

- **Family 1 (DEMO students) — DONE.** Class "Fixture" (id 16) + section
  "Fixture" (id 85) created in the system's own tables; the 31 DEMO
  enrolments re-pointed (student_session ids 3745–3775 unchanged).
  Four/Daffodils: **53 → 22** enrolments; the rendered students list
  shows 22 real students, zero DEMO. DEMO exam group 29 keeps all 30
  members; Exam 19 / group 27 untouched (verified before/after).
- **Family 2b (dashboard heroes) — DONE as recommended.** The fixture
  set (staff 113/114/115, student 3699, DEMO 3758–3788) is excluded in
  `Pk_dashboard_widgets::performers()` only (before md5 `ab370f1b…` →
  after `d44f0a1b…`; backup outside the tree; Semgrep 0 / Gitleaks
  clean). Rendered result: **Top Student = Subhan Ali (2397), 358
  marks** — matches the DB cross-check exactly. **Best Teacher shows
  its empty state** ("No recorded ratings yet"): staff 114 was the
  only rated staff member in the staging data, so excluding fixtures
  leaves no rated teacher. That is the honest consequence of the
  exclusion, not a defect.
- **Family 4 (battery fee groups) — DONE.** Archived via the system's
  own FL-080 mechanism (`ZZ-ARCHIVED-seg-20261117-` rename): **11
  groups** — W2A Script Fees **×8** (the live table holds 8, one more
  than the picker census in this proposal), W2B, Checker Money, BL035.
  W39-SEED left, as decided. The arrears picker now offers only the 4
  real groups (AFM, W39-SEED, Previous Arrears, Quick Create). All
  historical masters/deposits unchanged and rendering (Collections
  page 1 spot-checked).
- **Families 2, 3, 5 — as proposed:** 3699 and staff 113/114/115
  retained untouched; the BL-141 journal lines left as audit trail.
- **Census after cleanup, exactly baseline:** staff 113 · students
  1714 · deposits 1555 · exam_groups 10. Proof pair (317/318) deleted;
  exports for every step sit in host `~/backups-segregation-2026-11-17/`
  and the lane's `exports/`.
- **One named residual:** the dashboard Activity Timeline still lists
  DEMO admission events — an event feed, not a hero computation, and
  outside this proposal's scope; segregating it would be a separate
  decision.
