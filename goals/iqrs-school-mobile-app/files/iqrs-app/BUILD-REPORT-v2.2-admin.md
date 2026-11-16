# IQRS Admin App v2.2 — Build Report (Milestone M3)

**Delivered:** `IQRS-Admin-App-v2.2.apk` — package `pk.edu.iqrs.admin`,
versionName **2.2** / versionCode **12**, minSdk 26, targetSdk 34,
permissions **INTERNET + CAMERA** only.
**Size:** 995,617 bytes · **SHA-256:** `e6a8ae4e10605216ddc346353102f33ab75ce8eab11eb20c4903c31d2ca6a886`
Signed with the same debug keystore as all v2 builds (installs over the
v2.0 Admin app). The v2.0 Admin APK file is untouched, as is the
delivered Family v2.2 APK; the Family variant was rebuilt from the same
tree as a regression check and compiled clean with unchanged behaviour.

M3 = staff server reads + the Admin app core: live Staff Home, Classes,
today's register, student lookup and read-only student detail.
Attendance marking, QR and fee collection remain M4, per the plan.

---

## A. Server: additive read endpoints in `Staffapi.php`

Local source of truth: `~/workspace/iqrs-api/staff-ext/Staffapi.php`
(original preserved alongside as `Staffapi.php.pre-m3`; the diff is
purely additive apart from the header endpoint list — no existing
method changed). All four endpoints use the extension's existing
guard verbatim (POST → `check_auth_client()` →
`require_staff_session()` against `api_staff_sessions`) and the
existing `{status, message, record}` envelope.

| Endpoint | Body | Returns |
|---|---|---|
| `POST /api/staffapi/classes` | `{}` | `record{session_id, scope, date, classes:[{class_id, class, section_id, section, student_count, marked_today, is_class_teacher}]}` |
| `POST /api/staffapi/students` | `{class_id, section_id}` | `record{class_id, class, section_id, section, date, students:[roster row]}` — the section's roster **with today's attendance type per student**, i.e. today's register |
| `POST /api/staffapi/studentSearch` | `{query}` (`q` accepted) | `record{query, students:[roster row]}` — same row shape, across the caller's visible classes, max 50 |
| `POST /api/staffapi/student` | `{student_id}` or `{student_session_id}` | one student's detail basics + `attendance_today` / `attendance_date` |

Roster row: `{id, student_id, student_session_id, admission_no,
roll_no, name, image, class_id, section_id, class, section,
attendance_today}`. `id` **is** the students.id (both keys carried so
the users-id/student-id mix-up of v1.x cannot recur); `attendance_today`
is the school's attendance type name or `""` when unmarked.

### Schema evidence (nothing invented)

- Enrolment/roster joins mirror `Student_model::getStudentByClassSectionID`
  and `Student_model::getByStudentSession` (`student_session` ⋈ `students`
  ⋈ `classes` ⋈ `sections`, `students.is_active='yes'`, current session
  from `setting_model->getSetting()->session_id` — the same source
  `Staffapi::dashboard` already uses).
- Class↔section link is the `class_sections` table, as joined by
  `Student_model`, `Course_model`, `Conference_model`.
- Student detail columns are exactly the ones `Student_model` selects
  from `students` (guardian/father/mother names + phones, gender, dob,
  mobileno, email, admission_date, current_address, image, roll_no…).
- Today's attendance: `student_attendences` (student_session_id, date)
  left-joined to `attendence_type.type` — the same tables
  `Staffapi::dashboard` aggregates and `Staffsync` writes.
- Class-teacher assignment: `class_teacher` (class_id, section_id,
  staff_id) per `Leave_model::getclassteacherbyclasssection`.
  Subject-teacher assignment: `teacher_subjects` (teacher_id,
  class_section_id, session_id) per `Teachersubject_model`.

### Scoping decision (documented, as briefed)

The API layer of this codebase does not model the web admin's
per-role permission table at all (no `roles_permissions` anywhere in
the API tree); the existing extension is school-wide for any active
staff session (dashboard counts the whole school; Staffsync accepts
attendance writes for any class). The reads therefore scope as:
administrative roles (**Super Admin**, **Admin**) → all class sections;
any other staff member → the union of their `class_teacher` and
current-session `teacher_subjects` assignments; **a staff member with
no assignments falls back to all sections** (restricting reads below
the write scope the same session already has would be incoherent).
The response's `scope` field reports `"all"` or `"assigned"` so the
rule that produced a list is never hidden. Out-of-scope class/student
requests answer `{status:0}` ("Class not available" / "Student not
found") rather than leaking rows.

## B. Admin app core screens

- **S2 Staff Home (live):** identity header; "Today at school" card
  fed only by `staffapi/dashboard` (students/teachers/staff/classes +
  attendance-today total and by-type breakdown); entrances to Classes,
  Students and Profile. Cache-first with skeleton and retry states.
- **S3 Classes (read side):** the caller's class sections with student
  counts, a "Class teacher" caption where applicable, and today's
  register chip (Marked / Partly marked / Not marked, from the
  endpoint's `marked_today` vs `student_count`).
- **Register (from the `students` endpoint):** summary line
  (Present · Absent · Leave · Not marked) + roster rows in register
  order (roll number numeric-aware), each with today's status chip;
  cached copies carry the "Last updated" caption. Read-only.
- **S10 Students lookup:** search field (design §3.18) with debounce +
  IME search, class filter chips over the results, honest empty
  states; results are always fetched fresh (a lookup must reflect the
  school as it is now).
- **Student detail (read-only):** identity header, today's attendance,
  details (roll, gender, DOB, admission date, phone, email, address)
  and family contacts; phone rows open the dialer.
- **S11 Profile:** renders immediately from the stored session,
  refreshed by `staffapi/me` (role, employee ID, department, email);
  My classes link, About dialog (school name + motto), sign out.

New code: models `StaffDashboard`, `StaffClasses`, `StaffClassSection`,
`RosterStudent`, `StaffRoster`, `StudentDetail`, `StaffProfile`;
mappers `StaffDashboardMapper`, `StaffClassesMapper`,
`StaffRosterMapper`, `StaffStudentMapper`, `StaffProfileMapper`
(+ shared `StaffEnvelope`); `StaffRepository` gained cache-first
staff loads in the FamilyRepository pattern (its constructor now also
takes the shared `CacheDb` — wired in `IqrsApp`; Family behaviour
unchanged). Five new activities registered in the generated Admin
manifest. Attendance marking, QR and fee collection were **not** built
(M4), and no write path of any kind was added.

## C. Verification (Gates 1 + 3, this VM)

- **Gate 1 — JVM fixture tests: 59/59 pass** (51 pre-existing,
  including all Family suites, + 8 new in `StaffM3Test`). Fixtures
  `staff_dashboard.json`, `staff_classes.json`, `staff_students.json`,
  `staff_search.json`, `staff_search_empty.json`, `staff_student.json`,
  `staff_me.json`, `staff_error.json` mirror the PHP output
  field-for-field (envelope, key names, id semantics, `""` for
  unmarked). The declined-call fixture pins `{status:0}` →
  business-failure mapping.
- **Gate 3a — banned-strings lint: PASSED** (all 12 checks; new staff
  copy and code contain no status pills, no domain text, no service
  jargon).
- **Gate 3b — metadata on the shipped APK: PASSED** (package,
  versionCode 12, versionName 2.2, minSdk 26, targetSdk 34,
  permissions ⊆ {INTERNET, CAMERA}, signature verifies).
- **Device gate — still outstanding, as always:** install over v2.0
  on the owner's phone, real staff sign-in, open a class register.
  Server deployment is a separate lane (below) and has **not** been
  performed here; until `Staffapi.php` is deployed, the new screens
  will show their error states against the live server while sign-in
  and the dashboard keep working (the dashboard endpoint already
  exists in production).

## D. Deployment (for the deployment lane — not performed here)

Exactly **one** server file changes: `api/application/controllers/Staffapi.php`
→ the M3 version in `~/workspace/iqrs-api/staff-ext/`. No new tables,
no SQL, no vendor file touched. Full steps + smoke checks:
`~/workspace/iqrs-api/staff-ext/DEPLOY-NOTE-M3.md` (staging first;
the no-token 401 check doubles as the parse check).

## E. Flagged — unverified or deliberately deferred

1. **PHP syntax was not machine-checked:** this VM has no PHP
   interpreter, so no `php -l`. The code was written in the file's own
   style, is purely additive (verified by diff), and bracket-balanced;
   the staging smoke in the deploy note is the first true parse test.
2. **Scoping fallback** (see §A): assignment-less staff see all
   sections. If the school wants strict teacher scoping, the change is
   one branch in `visible_class_sections()` — say the word.
3. **Register summary buckets** match attendance type names
   Present/Absent/Leave case-insensitively (the vendor seed names);
   any other type still counts toward "marked".
4. **Photos:** `image` is carried in the payload exactly as stored
   (the vendor convention), but v2 renders initial avatars everywhere —
   no screen in either app loads remote photos yet.
5. **Search matching** is per-field substring (first/middle/last name,
   admission number), as the endpoint implements it; a multi-word
   full-name phrase typed as one string will not match across fields.
6. **`subjects` read not built:** the plan's §3.5 list mentions it for
   the homework subject picker; this milestone's scope was the three
   roster/search/detail endpoints, and the picker itself is M4
   (also blocked on the school configuring subject groups — a known
   owner-side item, unchanged).
7. **Staff bottom navigation:** Home remains the hub, consistent with
   the shipped shell; the design's staff bottom bar centres on the
   Scan action, which is M4. Classes/Students/Profile are one tap
   from Home, and Profile links back to My classes.
8. **Classes order** follows the school's own definition order
   (`classes.id`, `sections.id`), not alphabetical.
