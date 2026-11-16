# Wave 1A API — Fix Round Report (2026-11-07)

Final staging build: **Staffapi.php 282,897 B / Staffsync.php 97,582 B**
(Correction, checker F1: an earlier draft of this line carried Staffsync's
pre-fix size 97,572 B; the shipped file is 97,582 B — the 10-byte delta is
fix 3, the admin_scope cast.)
Full battery (`test-wave1a-api-staging.sh`, run 7): **PASS=177 FAIL=0**, incl. the
studentUpdate regression suite (18/18) inside it. First full run had been 149/24;
every failure was diagnosed to a root cause and fixed — no assertion was deleted
to reach green (two were corrected, see S5/S6, with the contract evidence recorded).

## Build fixes (8)

1. **is_admin_scope() object-pass (Staffapi)** — passed the whole staff object to
   `staff_role_names($staff_id)`, which fed it to a query-builder `where()` → PHP 8.3
   fatal, blank HTTP 500. This single defect killed dashboardWorklist, noticeList,
   homeworkList, studentLeaveList (every reader of the office-scope helper).
   Fix: `staff_role_names((int) $staff->id)`.
2. **notice_visible() object-pass (Staffapi)** — same family: `staff_role_rows($staff)`
   → `staff_role_rows((int) $staff->id)`. Would have fatalled noticeList for
   non-admin callers once fix 1 landed.
3. **admin_scope() object-pass (Staffsync)** — the duplicated helper, same fix.
   (Explains the Staffsync homeworkUpdate/homeworkDelete failures.)
4. **Staff directory column (Staffapi)** — `directory_query()` selected
   `staff.current_address`; the staff table's column is `local_address` (DB error
   1054). The API field stays `current_address`, now sourced from `local_address`.
5. **feePaymentSearch join (Staffapi)** — `fee_payment_entries()` joined
   `student_session` on `student_fees_deposite.student_session_id`, a column that
   does not exist (1054). Now joins `student_fees_master` on
   `student_fees_deposite.student_fees_master_id`, then `student_session` via the
   master's `student_session_id`.
6. **Teacher leave-scope filter (Staffapi)** — `approvable_class_sections()`
   filtered `subject_group_subjects.teacher_id`; that table has no such column.
   The teacher link lives on `subject_timetable.staff_id` — filter moved there.
7. **homework_unevaluated_count() join (Staffapi)** — the LEFT JOIN's ON clause
   embedded a raw subquery; CodeIgniter's identifier protection mangled it into
   invalid SQL (1064). Rewritten as a plain join through `student_session`,
   mirroring homeworkSubmissions' own evaluation join.
8. **Worklist attendance card (Staffapi)** — `worklist_unmarked_sections()`
   iterated `$visible['sections']`, a key `visible_class_sections()` never
   returns (its shape is scope/pairs/pair_list), so the card's `count` was
   always an empty LIST while every other card carries an integer. Helper
   rewritten on the classes() (Wave 0) pattern: class_sections source, grouped
   enrolment/marked counts, pairs filter when scope is 'assigned'. Card now
   returns `count` (int) + `sections` (the list). Live proof: count 77 ==
   sections 77 == Classes-screen derivation 77.

## Test-script fixes (6, script only — the build was not bent to fit)

- S1–S3: fixture password defaults used `${PASSWORD:...}` (substring expansion →
  empty passwords); fixed to `${PASSWORD:-...}`. Login helper read the token from
  `record.token`; it is top-level. Family login sent `email`; the vendor endpoint
  requires `username`.
- S4: feeReceipt assertion read `record.receipt.total_received`; the record IS the
  receipt view-model (flat, like every other endpoint) — assertion corrected to
  `record.total_received`.
- S5: staffDirectory/staffDetail assertions for the teacher fixture hard-assumed
  the LIMITED view. Live evidence: the staging roles_permissions grant EVERY
  seeded role human_resource/staff view (verified per role by SELECT), so the
  full view is the API behaving per the school's own permission data — the same
  rule the web applies. Assertions are now capability-derived (the API's view
  must match the capability map it issues, either way).
- S6: the limited branch is still live-proven — new staging fixture staff 115
  (testlibrarian.w1a@iqrs.edu.pk) sits on a purpose-made TEST role 8
  ("TEST Limited W1A", zero permission rows): directory full_view=false with no
  contact fields, colleague detail limited, own detail full. Permanent script
  section 4b. Plus a new worklist↔Classes reconciliation assertion.

## Diagnostics lifecycle (all reverted at closure)

db_debug was temporarily enabled on the STAGING api only (the 'prodcution'
toggle) plus a .user.ini and panel logErrors to surface the errors above;
all three reverted/removed when the battery went green. Production was never
opened or touched in any Wave 1A step. Staging backups retained:
Staffapi.php.bak-2026-11-07-wave1a / -wave1a-broken / -wave1a-fix1 / -wave1a-fix2,
Staffsync.php.bak-2026-11-07-wave1a / -wave1a-broken.

## Addendum — checker F3 closed (2026-11-07, later the same day)

The checker's S2 debt (teacher assigned-scope unproven) is closed. Staging
fixture: `class_teacher` row (session 21, class 3 Four, section 2 Daffodils
(Girls), staff 114) — the table was empty, so this is the install's first
class-teacher assignment, staging only. Live proof: capabilities(114) scope
is now `assigned` [{3,2}]; classes(114) shows only that pair;
attendanceRegister own pair → status 1, foreign pair → refused. One more
script fix fell out of this (S7): the script's assigned-scope branch read
the classes payload in an old nested shape (`classes[].id`,
`classes[].sections[].id`); the endpoint's flat shape is
`classes[].class_id` / `classes[].section_id` — extraction corrected.
Full battery after the fixture (run 9): **PASS=179 FAIL=0** — the two extra
checks over run 7 are exactly the own/foreign register assertions, now
executing instead of skipping.
