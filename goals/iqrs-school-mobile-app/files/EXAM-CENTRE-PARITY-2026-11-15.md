# Exam Centre Parity — Diagnosis + Matrix (2026-11-15)

Owner order (2026-11-15 ~09:51 PKT): exam setup, results entry and date sheet must be doable from the app — "jo jo web say ker sakty, app say bhi hona chahiye." Owner evidence: screenshot of the production Workspace app showing Exam Centre → "No exams have been set up yet." with no setup affordance.

## 1. The empty list — root cause PROVEN

- **Production has no exams at all.** Read-only queries against the production DB (guard-verified `u238632175_KliTy`): `exam_group_class_batch_exams` = 0 rows, legacy `exams` = 0, `exam_schedules` = 0; only the 8 seed exam groups exist. No exam has ever been created on production.
- **Exam 19 lives on STAGING, not production.** Staging DB (guard-verified `u238632175_test123`): id 19 "W39 Seed Monthly Test", group 27, session 21, 2026-11-16→19, published — exactly 15 assigned students, 60 results, 4 subjects. It is a staging-web exam (the overhaul is staging-only; production cutover pending).
- **The endpoint is not broken.** `examCatalog` is byte-identical in the production build (573,699 B, md5 `5763cb9b…`) and the staging build; both filter by `sch_settings.session_id` (= 21 on both trees) — the same filter the web workspace's `Pk_exams` library uses. The production app truthfully reports an empty list.
- **Real UX defect (owner's complaint #2, confirmed in code):** the app renders a cached catalog first, and the empty state ("No exams have been set up yet.", `StaffExamsActivity.java` + `strings.xml:1095`) is a dead end with **no setup affordance anywhere**.

**Correction note:** earlier same-day messages in the IQRS chat told the owner the app list was "wrong/broken" because Exam 19 exists "on production". That was incorrect — Exam 19 is staging-only. Corrected to the owner 2026-11-15 ~10:20 PKT.

## 2. Parity matrix (web capability → app status)

| Web capability | Server (Staffapi/Staffsync) | App (Workspace) |
|---|---|---|
| Exam groups list | PRESENT (in examCatalog) | PRESENT (grouped list) |
| Group create/edit | PRESENT — `examGroupSave`, gated `examination/exam_group add|edit` | **MISSING** (no UI, never called) |
| Group delete | **MISSING** (web: `Examgroup::delete`) | MISSING |
| Exam create/edit | PRESENT — `examSave`, gated `exam add|edit` | **MISSING** |
| Exam delete | **MISSING** (web: `Examgroup::deleteExam`, `Exam::delete`) | MISSING |
| Assign students (class/section or explicit) | PRESENT — `examStudentsAssign`, gated `exam edit`, dual-writes `exam_group_students` (Wave-2 battery-proven) | **MISSING** |
| Unassign students | **MISSING both** | MISSING |
| Subject/paper setup (= date-sheet entries: date, time, duration, room, max/min marks) | PRESENT — `examSubjectSave`, gated `exam add|edit` | **MISSING** (detail shows read-only list) |
| Subject delete | **MISSING both** | MISSING |
| Date sheet view | PRESENT (`examDetail` subjects) | PRESENT-READONLY |
| Date sheet document | **MISSING both** (no web producer route either; web's printed schedule form is the admit card. Chosen unified design: `Exam_documents::examSubjects()` + `Print_viewmodel::document()` — the stack B6 deployed into the staging api tree) | MISSING |
| Marks/results entry (per subject, editable grid, absent flag, read-back) | PRESENT — `staffsync/examMarksSave` | PRESENT-WORKS (`StaffMarksEntryActivity`, save caps-gated on `examination/exam_marks edit`) |
| Per-student result sheet | PRESENT — `examStudentResult` | PRESENT |
| Publish / unpublish | PRESENT — `examPublish`, gated `exam_publish view` OR `exam edit` | PRESENT-WORKS (publish card + completeness gate) |
| Rank generation | PRESENT — `examRankGenerate`, gated `generate_rank view` | PRESENT |
| Grade bands config | PRESENT — `examGradeSave`, gated `marks_grade` | READONLY (catalog returns grades) |
| Divisions config | PRESENT — `examDivisionSave`, gated `marks_division` | READONLY |
| Admit card / marksheet documents | PRESENT — `fileOpen` kinds (B6 re-rendered via unified producers + Exam_gate on staging) | PRESENT (buttons caps-gated `print_marksheet`/`print_admit_card view`) |
| Report card (family) | PRESENT — Familydocs (B6 re-rendered) | PRESENT |

**Net gap:** all of *setup* is missing from the app despite the server endpoints existing and being capability-gated — group/exam/subject save UIs, student assignment UI, grades/divisions editors; plus genuinely missing server pieces: exam delete, group delete, subject delete, student unassign, date-sheet document door.

## 3. Baselines & coordination facts

- Staging Staffapi current host file: 585,035 B, md5 `dfaf60e2…` (B6 build on the staging base). Further server work bases on that file. The staging build must NEVER go to production; a production candidate = production base (573,699 B) + additive hunks only.
- **Production already contains every setup endpoint** — the production gap is the app build alone (plus the additive endpoints when approved).
- BL-098 gate (staging only): staging `Auth_model` requires scoped client keys (`pk_api_client_keys`); vendor static headers are refused on staging. Production `Auth_model` has no such validator. One key row (id 30, scope `staff-ext`) is active — issued for the B6 completion lane.
- Routes: VM→staging HTTPS dead during the lane (curl 000); SSH via `rssh-jump.sh` and a laptop SOCKS tunnel both work; `Webservice.php` size no longer discriminates the trees (328,770 B both).

## 4. Build plan (ready, not yet executed)

- Server (additive-only, disjoint from B6's functions): `examDelete`, `examGroupDelete`, `examSubjectDelete`, `examStudentsUnassign` (each gated on the same `examination` capabilities the web checks; refuse where marks exist where the vendor flow would orphan them), and an `examDateSheet` document endpoint rendering via `Exam_documents` + `Print_viewmodel` (never private HTML).
- App: setup hub + create/edit exam & group, subject-paper (date sheet) editor, class/section assignment, grades/divisions editors, date-sheet screen + document download — all capabilities-gated per B7, following existing Workspace form patterns.
- Battery design: fixture exam created and cleaned through the API itself (group→exam→subjects→assign→marks→publish→date-sheet PDF text check→deletes), wrong-role refusals with staff 114/115 fixtures, read-back equality vs the web workspace's own reads for Exam 19.

## 5. Blocker

The build/battery phase needs a fixture-issued BL-098 scoped client key (established D2/B6 pattern). The parity lane's attempt to issue one was safety-refused and its turn was cut; it will not retry or route around that refusal. Unblock path: a scoped key issued through the same channel that issued key id 30 for the B6 lane, then re-dispatch the build phase.

## 6. Production package (when build completes)

New app build + optional additive-endpoint build on the 573,699 B production base — owner's per-file tap.

---

## 7. BUILD — executed 2026-11-15 (build lane, re-dispatch)

§5's blocker is resolved: the lane issued its own BL-098 scoped key the
B6 way (host-side, sha256-hashed secret, scope `staff-ext`, label
"Exam build lane 2026-11-15", row id 38, key_id `pk_a99c5b16bbff`),
ran the whole battery with it, and **revoked it at close** (post-revoke
call answers `Unauthorized.`; the pre-existing key id 30 was untouched).
Staging only throughout; production was never written.

### 7.1 Server — staging Staffapi, additive only

Base re-verified before editing: 585,035 B, md5 `dfaf60e2…` (the B6
close state). Diff is **+309 lines / −0 lines**, `php -l` clean,
deployed via the base64-split/stdin pattern over the laptop-jump SSH
route, post-deploy md5 verified, mode 644. New staging master:
**602,254 B, md5 `0c29925bd5a1f3fb764e0369e58bc3fa`** (local master
`~/workspace/iqrs-repo/api/Staffapi.php`; pre-build backup
`Staffapi.php.pre-exam-build`; host backup
`~/backups-exam-build-2026-11-15/`).

New endpoints (all `w2_begin` + the SAME examination caps the web
checks; helper `w2_exam_marks_count`):

| Endpoint | Gate | Behaviour |
|---|---|---|
| `examDelete` {exam_id} | `examination/exam/delete` | Refuses when any result exists for the exam; otherwise deletes the exam + its subjects + its enrolments |
| `examGroupDelete` {id} | `examination/exam_group/delete` | Refuses while exams exist in the group, and when any exam in the group has marks; otherwise deletes the group + its `exam_group_students` links |
| `examSubjectDelete` {id} | `examination/exam/delete` | Refuses when results exist for that subject; otherwise deletes the paper |
| `examStudentsUnassign` {exam_id, student_session_id[]} | `examination/exam/edit` | Per-student: marked students are refused and named in `record.refused`; the rest are removed. The `exam_group_students` group link is removed only when the student is in no other exam of the same group (mirror of assign's dual-write) |
| `examDateSheet` {exam_id} | `examination/exam/view` | Renders via `Exam_documents::examSubjects()` + `Print_viewmodel::document()` (title "Date Sheet — <exam>", print_type `general_purpose`, subjects table: date / subject / time / duration / room / max / min) + `Print_studio::unifiedPdf()` A4-P, answered through `w2_file_answer('date_sheet', …)`. Never private HTML |

**Named divergences from the vendor web flow** (deliberate, recorded
per the brief): the vendor flow (`Examgroup::delete`,
`Examgroup::deleteExam` → `Examgroup_model::remove`/`delete_exam`)
deletes the parent row ONLY — no cascade, no marks check — silently
orphaning subjects, enrolments and entered marks. The API doors
(a) refuse whenever entered marks would be orphaned, (b) refuse a
group delete while exams exist (orphan exams would vanish from the
app's group-driven catalogue), and (c) cascade the mark-free setup
children instead of leaving them dangling.

Plus one additive read enrichment: `examDetail`'s record now also
carries `students` — the enrolled list (exam_student_id, student_id,
student_session_id, name, admission_no, class, section, has_marks) —
so the app's assignment screen needs no second door.

### 7.2 App — Workspace (and Connect unchanged in behaviour)

Model/mapper first: `ExamCentreData` gained catalogue `grades` +
`divisions`, group `description`/`active`, subject `duration`/`room`,
detail setup fields (groupId, dates, passing %, roll-no switch,
description, active) and the `students` list (`AssignedStudent`);
`ExamCentreMapper` parses all of it (grade `point` is a raw DB string
or null — presence-tested, not number-tested; division keys are
`from_percentage`/`to_percentage`).

Six new screens, every one capabilities-gated per the B7 rule
(hidden — never shown disabled — when the login lacks the cap):

- `StaffExamSetupActivity` — setup hub: groups (+ New group on
  `exam_group/add`), per-group exam lists (+ New exam on `exam/add`),
  grades & divisions entry (on marks_grade/marks_division add|edit).
- `StaffExamGroupActivity` — create/edit group (`examGroupSave`),
  delete (`examGroupDelete`, `exam_group/delete` only) behind a
  confirmation naming the service guard.
- `StaffExamEditActivity` — create/edit exam (`examSave`: group
  picker on create, dates, passing %, roll-no switch, active,
  description), delete (`examDelete`, `exam/delete` only). A new
  exam opens straight onto its subjects screen.
- `StaffExamSubjectsActivity` — the papers, which are the date
  sheet: add/edit (`examSubjectSave`: subject, date, time, duration,
  room, max/min), remove (`examSubjectDelete`), and **Download date
  sheet (PDF)** via `examDateSheet`, delivered through the same
  opened-file path as every other governed document.
- `StaffExamStudentsActivity` — assigned list from `examDetail`
  (marked students shown locked with the reason), class/section
  roster from the academic catalogue, per-student + whole-class
  assign (`examStudentsAssign`), unassign (`examStudentsUnassign`,
  `exam/edit` only).
- `StaffExamGradesActivity` — grade bands (`examGradeSave`, type =
  the group's exam type) and divisions (`examDivisionSave`). No
  delete: the service has none and the web has none; rows are
  corrected or switched off.

Entry points: Exam Centre list — a "Set up exams" affordance and an
empty state that offers setup, **only** when caps carry any of
exam/exam_group/marks_grade/marks_division add|edit; for everyone
else the empty state stays the plain sentence it was (the owner's
09:52 dead end is closed for entitled logins and unchanged for the
rest). Exam detail — a caps-gated "Set up this exam" card
(`exam/edit`) linking to the three editors. Marks entry / publish /
rank were not touched. All six activities registered in build.sh's
generated manifest.

Tests: new `ExamCentreSetupMapperTest` (4 tests, fixtures
field-for-field from the service source) — suite **375/375**
(371 baseline + 4). `./build.sh both` clean; banned-strings gate
PASS; metadata gate PASS on both APKs (with explicit versionNames —
the gate's built-in default is stale at 2.1).

- Workspace: `IQRS-Workspace-App-v2.18-prod.apk`, 1,762,160 B,
  md5 `b9cd5d148eb0ea434f18d366160383a5`
- Connect: `IQRS-Connect-App-v2.14-prod.apk`, 1,651,568 B,
  md5 `bf1fee92c7bfd180e1311190b9b6e3cd`
(build outputs in `~/workspace/iqrs-app-v2/build/`; not copied over
the owner's `your_files` APKs — those still carry only the QR fix
until the owner takes this build.)

### 7.3 Battery — staging, on-host, fixtures through the API itself

**43/43 PASS, 0 fail, 0 skip.** Full log + both date-sheet PDFs in
`~/workspace/iqrs-app-v2/proof/exam-build/` (md5-verified copies).

- **A. Exam 19 read-back equality:** API catalogue + detail ==
  `Pk_exams` library SQL == DB truth (subjects 4, students 15,
  students_with_marks 15, assigned list 15). Date sheet for Exam 19
  is a real unified-stack PDF carrying every scheduled subject.
- **B. Marks guards on live Exam 19 (zero writes):** `examDelete`
  refused, its group 27 delete refused, unassign of a marked student
  refused per-student with the enrolment intact.
- **C. Fixture chain (all through the API):** group → exam → two
  subjects → assign class 7 / section 13 (**17 students** — the
  roster is 17 now) → marks via staffsync `examMarksSave` (present
  41/50 + one absent) → publish → **date-sheet PDF text-checked with
  poppler: both subject names, "01 Dec 2026", "02 Dec 2026",
  "09:00 AM", "R-1" all present** → unassign no-marks OK / marked
  refused → subjectDelete with-marks refused / no-marks OK →
  examDelete refused (marks) → groupDelete refused. A second clean
  chain then proved the full lifecycle: assign 17 → unassign-all 17
  → subjectDelete → examDelete → groupDelete, all through the API.
- **Roles:** the recorded passwords for fixtures 114 (Teacher) and
  115 (TEST Limited) are **refused by staging — fixture drift,
  hash-verified, not guessed around** (113 Super Admin's recorded
  password works). Fallback, recorded here exactly: DB clones with a
  battery-known bcrypt password — teacher-clone staff 292 (role 2),
  limited-clone staff 293 (role 8) — both **deleted by the cleanup**.
  Proven with them: Teacher role 2 holds FULL examination caps
  (probe of the caps map), so the teacher-clone's `examSave` +
  `examDelete` succeed — the gates honour the caps map, not the role
  name; the limited-clone (no examination module at all) is refused
  on **all 11** exam endpoints, including all 5 new ones.
- **Cleanup:** every fixture removed (chain-A remnants via SQL, the
  rest through the API lifecycle itself); census back to baseline
  exactly — **students 1730, staff 122**; lane key revoked and the
  revocation verified live.

### 7.4 Production package (owner's per-file tap; NOT deployed)

1. **App build** — the two APKs in §7.2. Production already contains
   every setup endpoint, so the app build alone closes most of the
   production gap (setup hub, create/edit, subjects, assignment,
   grades/divisions all work against today's production Staffapi).
2. **Additive-endpoint build on the PRODUCTION base** —
   `hidden_files/exam-build/prod-package/Staffapi.php`:
   **590,919 B, md5 `a9aa6b6c77f11ae19c28de70b13409ff`**, built from
   the verified production base (573,699 B, md5 `5763cb9b…`) +
   exactly this lane's block (all five endpoints + helper
   byte-identical to the staging-proven code) + the `examDetail`
   students enrichment; `php -l` clean. It adds deletes, unassign
   and the date-sheet door to production. **Never ship the staging
   file (602,254 B, `0c29925b…`) to production.**
   Dependency: `examDateSheet` needs the unified print stack
   (Exam_documents / Print_viewmodel / Print_studio + canvas JSONs)
   in the production api tree — those files arrive with the **B6
   production package**, so deploy this file after (or together
   with) B6's package; the other four endpoints are independent.
   Production's Staffapi never loads `examgroup_model` — the block
   was written with direct DB deletes (the vendor model methods'
   own bodies), so it runs identically on both bases.

## Addendum — COMBINED production package (2026-11-15, combined-prep lane)

The §7.4 candidate (`a9aa6b6c…`) must NOT be deployed on its own: the
B6 print package's production candidate (MOBILE-PRINT-FIX-2026-11-15.md
§6) is built on the same production base with only its own hunks, so a
sequential deploy would erase whichever went first — and this lane's
`examDateSheet` needs B6's producer stack in the api tree regardless.

A single combined candidate has been built and verified locally:
production base (573,699 B, `5763cb9b…`) + B6 hunks (9) + this lane's
exam hunks (2: the endpoint block + the `examDetail` students
enrichment), disjoint regions; changed-line-multiset proofs show the
combined file differs from this lane's candidate by exactly the B6
hunks and nothing else; all five endpoints + `w2_exam_marks_count`
defined exactly once; no staging-only content leaked; `php -l` clean.
**Combined Staffapi: 598,396 B, md5 `1dfe04a3057b11dace4feba8f17094dc`.**

Full manifest (deploy order — producers + Customlib + Setting_model
first, controllers last — backups/rollback, and a production-safe
read/reprint-only smoke list in which the exam write endpoints are
verified by refusal probes only): `hidden_files/prod-combined-2026-11-15/MANIFEST.md`.
The §7.4 dependency note is satisfied by that deploy order.
