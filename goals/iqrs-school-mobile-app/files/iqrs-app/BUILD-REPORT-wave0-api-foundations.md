# Wave 0 API foundations — API-00 capabilities + API-01 academicCatalog

**Status: BUILT locally; staging swap still required (see "Staging" below). Production NOT touched — it still runs the 61,353-byte Staffapi.php.**

Implements §3.1 of `FEATURE-AND-DESIGN-PLAN.md` (API-00 / API-01) as additive methods on the staff extension controller. Local master: `~/workspace/iqrs-api/staff-ext/Staffapi.php`, pre-Wave-0 baseline kept alongside as `Staffapi.php.pre-wave0`.

## What was built

| Endpoint | Contract | Notes |
|---|---|---|
| `POST /api/staffapi/capabilities` | API-00 | `{record:{staff, roles:[{id,name,is_superadmin}], session_id, capabilities_source, capabilities:[{module, module_name, actions[], permissions:[{key, name, actions[]}]}], scope:{type, class_sections[]}, modules_configured:{…}}}` |
| `POST /api/staffapi/academicCatalog` | API-01 | `{record:{session_id, session, scope, classes:[{id, class, sections:[…]}], sections:[…], subjects:[{id,name,code,type,is_active}], subject_groups:[{id, name, subjects:[{subject_group_subject_id, subject_id, subject, subject_code, teachers[]}], class_sections:[{class_section_id, class_id, section_id}]}], class_teachers:[…], attendance_types:[{id, type, is_active}]}}` |
| `POST /api/staffapi/classTimetable` | API-01 companion | `{class_id, section_id}` → `{record:{…, days:[{day, periods:[{time_from, time_to, subject, subject_code, subject_group, teacher, room}]}]}}`; scope-checked with the same refusal wording as `students()` |
| `POST /api/staffapi/teacherTimetable` | API-01 companion | `{staff_id?}` → own timetable by default; another staff member's only for Super Admin / Admin, otherwise `{status:0}` |

All four follow the file's established discipline exactly: POST-only → `check_auth_client()` → `require_staff_session()` (401 JSON on any failure), `json_output(200, {status:1, message:'Successfully.', record})` on success, `{status:0, message}` refusals on HTTP 200. Identity always comes from the session — a client-sent staff id is never trusted (teacherTimetable's optional `staff_id` is gated, see above). LF line endings preserved; no existing method's behaviour changed.

Five private helpers were added: `table_exists()`, `staff_role_rows()`, `staff_capabilities()`, `modules_configured()`, `timetable_days()`.

### Two documented refinements of the plan's sketch (schema won over sketch)

1. **Subject groups carry a `class_sections` mapping list, not a flat `class_id`/`section_id`.** In this install the link is many-to-many (`subject_group_class_sections`), so one group can serve several class sections; a flat pair would have been wrong data.
2. **A group subject's teachers are a `teachers[]` list, not a single `teacher_id`.** `subject_group_subjects` has no teacher column in this install; the assignment lives in `subject_timetable` (one staff member per period row), so the catalogue summarises the distinct teachers of that group-subject in the session.

## Schema facts found (evidence: the install's own production SQL export of 2026-11-06 in `~/workspace/browser_downloads/…u238632175_KliTy.sql` — staging mirrors this schema — cross-checked against the vendor API models in `~/workspace/iqrs-api/production/api/application/models/`)

- **RBAC is real in this install**: `roles` (1 Admin, 2 Teacher, 3 Accountant, 4 Librarian, 6 Receptionist, 7 Super Admin with `is_superadmin=1`), `staff_roles(staff_id, role_id)`, `permission_group` (33 rows: `student_information`, `fees_collection`, `examination`, `academics`, … incl. add-on groups like `cbseexam`, `zoom_live_classes`), `permission_category` (`perm_group_id, name, short_code, enable_view/add/edit/delete`), `roles_permissions` (`role_id, perm_cat_id, can_view/can_add/can_edit/can_delete`).
- **Capability rule implemented**: an action is granted when ANY of the caller's roles grants it (`can_* = 1`) AND the category enables it (`enable_* = 1`). A role with `is_superadmin=1` bypasses `roles_permissions` in the web panel, so it receives every enabled action (`capabilities_source: "roles_permissions_superadmin"`; normal resolution reports `"roles_permissions"`). Every table is existence-checked before querying (the `teacher_subjects` lesson); if the structure were absent the endpoint degrades to the extension's role-name model and says so (`"role_names_fallback"`).
- **Academic catalogue tables**: `subjects(id, name, code, type, is_active)` — 2 rows (1 Computer `IQRS-CS`, 2 Computer Practical `IQRS-CS01`); `subject_groups(id, name, session_id)`; `subject_group_subjects(id, subject_group_id, session_id, subject_id)`; `subject_group_class_sections(id, subject_group_id, class_section_id, session_id)`; `class_sections(id, class_id, section_id)`; `class_teacher(session_id, class_id, section_id, staff_id)`; `attendence_type(id, type, is_active)` — 10 rows, matching the earlier staging verification. Subject-group tables are empty on production today, so an honest empty `subject_groups: []` is the expected live answer until the school configures them — the app lights up automatically once it does.
- **`modules_configured`** flags are real row counts, each existence-guarded: `subjects`, `subject_groups` (session), `homework` (= a `subject_group_subjects` row exists for the session), `exams`, `timetable` (session), `library` (`books`), `transport` (`vehicles`).

## Diff summary

- `Staffapi.php`: **61,353 → 97,285 bytes; +724 lines, 0 lines removed** (purely additive: 4 header lines, 4 public methods, 5 private helpers). Brace/paren balance verified; no PHP binary exists in this VM, so the staging smoke after the swap is the parse test (the established pattern for this codebase).
- `Staffauth.php` / `Staffsync.php`: **unchanged** — API-00/01 need nothing from them.
- New: `test-wave0-api-staging.sh` (re-runnable verification, staging-pinned, refuses any other base URL).

## Staging — what is proven, and the one step this lane cannot do

The deploy route for this extension is the **Hostinger File Manager in the signed-in browser** (per `staff-ext/DEPLOY-CHECKLIST.md`), which a background lane cannot operate. **The parent agent must swap the file into staging** (`public_html/staging/api/application/controllers/Staffapi.php`, backing the current staging file up first), then run `~/workspace/iqrs-api/staff-ext/test-wave0-api-staging.sh`.

Baseline evidence gathered today against staging as it currently runs (pre-swap):

- Logins for both fixtures work (113 Super Admin, 114 Teacher); `me`, `dashboard`, `classes`, `student(2397)` all answer `status 1`.
- The **studentUpdate regression suite is green under the current staging file: 18/18** with the teacher fixture wired in (the earlier "17/17" figure was the same suite with the role-gate step counted as manual; it is automated now) — this is the suite the Wave 0 script re-runs after the swap to prove no regression.
- All four new endpoints currently answer **CI's HTML 404 page** — direct proof they are not on staging yet, and the verification script detects exactly this state and reports "endpoint not deployed yet" instead of a confusing failure.

The verification script then proves, in order: (a) all four endpoints refuse token-less and header-less calls with clean 401 JSON; (b) staff 113 → `capabilities` (source `roles_permissions_superadmin`, `fees_collection`/`collect_fees` view granted, scope `all`, record describes staff 113 only) and `academicCatalog` (subjects 1/2 = Computer / Computer Practical, classes non-empty, attendance types incl. Present/Absent, bad session refused); (c) staff 114 → `capabilities` (source `roles_permissions`, not superadmin, record carries the teacher's own email only, payload differs from the Super Admin's), own `teacherTimetable` OK, the admin's timetable **refused**, `classTimetable` for a catalogued class section OK; (d) admin reading the teacher's timetable OK, nonexistent staff refused; (e) regression — `dashboard`/`me`/`classes`/`student` still answer and the studentUpdate suite is green under the new file.

## What remains

1. **Parent agent**: swap the built `Staffapi.php` into **staging only** (backup first), run `test-wave0-api-staging.sh`, and confirm a full green result.
2. Only after that: the Wave 1 app lane can build against API-00/API-01 on staging. The production swap of this file is a separate, later, owner-approved step — **not** part of this delivery.
