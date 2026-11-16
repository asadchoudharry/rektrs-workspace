# BUILD REPORT — Admin v2.5: student profile editing

**Deliverable:** [IQRS-Admin-App-v2.5.apk](sandbox://workspace/your_files/iqrs-app/IQRS-Admin-App-v2.5.apk)
— package `pk.edu.iqrs.admin`, versionName **2.5** / versionCode **18**,
**1,327,393 bytes**, SHA-256 `de03bc8dd3c72a62ff740e26b555e2db80b7df8daa091ffc1f4ff8bd647712ae`.
Admin-only change; Family untouched; v2.4 APK untouched (hash re-verified
`838a100d…`). Server side was already done (POST /api/staffapi/studentUpdate,
contract in DEPLOY-NOTE-STUDENT-EDIT.md); this lane is app-only.

## What shipped

**Detail screen (`StaffStudentActivity`)** — gains a full-width **Edit
profile** primary button under the family card, rendered **only** when the
signed-in session's role is Super Admin or Admin (`StudentProfileEdit.canEdit`
on the session role — the same role-name rule the endpoint enforces).
Teachers, Accountants and every other role see the read-only screen exactly
as before. The edit screen is additionally guarded: reached without an
admin role, it closes immediately. On a successful save the detail screen
reloads and shows a plain "Profile updated." confirmation.

**Edit form (`StaffStudentEditActivity`, new)** — loads the student
**fresh** from the service (never the cache: an edit must start from the
record as the school holds it now), then renders an identity card (photo/
initial disc, name, class · section, admission number) followed by one
card per group with a tinted header band in the v2.4 visual language
(Student = pale blue, Contact = pale gold, Family = soft green,
Guardian = soft amber). Fields are prefilled from the record; date fields
carry Pick (date picker, seeded from the current value) and Clear chips
plus strict YYYY-MM-DD typing; phones get the phone keypad, emails the
email keypad, addresses are multi-line.

**Save behaviour** — sends `student_id` + **only the fields actually
changed** (trimmed-value diff against the loaded record) via the new
`StaffRepository.updateStudent`, a direct online call — it never touches
the offline saved-writes sender. The button disables while saving. On
`{status:1}` the screen returns to the detail view refreshed with the
returned record (the response also warms the detail cache, so the reopen
shows the new values immediately) with the confirmation above. On
`{status:0}` the service's own message is shown in the form and **all
input is preserved**; on no-connection an honest "Editing needs a
connection to the school. Your changes are still here — please try
again." shows instead, input likewise preserved. With nothing changed,
Save simply says "Nothing has changed yet." and sends nothing. Dates
and category are validated inline before anything travels, matching
the service's rules (real calendar dates; category a positive number).

## Field groups as actually rendered

The form renders the 25-field whitelist **intersected with the fields the
loaded record carries** (verified against the `student`-endpoint record,
fixtures/staff_student.json — 31 keys). Against that record shape,
**17 of 25 fields render**:

- **Student:** First name, Middle name, Last name, Gender, Date of birth,
  Admission date
- **Contact:** Mobile number, Email, Current address
- **Family:** Father's name, Father's phone, Mother's name, Mother's phone
- **Guardian:** Guardian's name, Guardian's relation, Guardian's phone,
  Guardian email

**Whitelist fields NOT rendered (8), all for the same reason — the key is
absent from the student record the endpoint returns**, so there is no
loaded value to prefill or diff against (the form renders only what's
there, per the brief): `blood_group`, `religion`, `cast`, `category_id`
(Student group), `permanent_address` (Contact), `father_occupation`,
`mother_occupation` (Family), `guardian_address` (Guardian). The code
path is fully general: the moment a record carries any of these keys,
the field appears in its group with no app change (pinned by a test with
a record that carries religion / blood_group / category_id /
guardian_address — category then travels as a JSON number).

## Code changes

- `api/StudentProfileEdit.java` (new) — the pure logic: 25-field
  whitelist with group/kind, role gate, record intersection
  (`presentFields` / `originalValues`), the only-changed-fields payload
  builder (non-whitelist keys can never pass; category as integer or
  not at all), strict date validation mirroring the service.
- `model/StudentDetail.java` — carries `editableValues` (present
  whitelist fields → loaded values) alongside the display fields.
- `api/StaffStudentMapper.java` — populates `editableValues` from the
  raw record; the studentUpdate answer maps through this same mapper.
- `data/StaffRepository.java` — `loadStudentFresh` (online-only read for
  the form) and `updateStudent` (online-only write; warms the detail
  cache on success). No sender/outbox involvement.
- `ui/staff/StaffStudentActivity.java` — role-gated Edit profile action
  + reload-and-confirm on return.
- `ui/staff/StaffStudentEditActivity.java` (new) — the form screen;
  registered in the generated manifest (verified present in the shipped
  APK's manifest).
- Strings: one new block (action, group titles, field labels, save/
  refusal/connection copy) — all within the language lockdown.

## Gates

- **JVM tests: 117/117 pass** (104 baseline + 13 new in
  `StudentProfileEditTest`): payload sends only changed fields;
  student_id always present even with zero changes; non-whitelist keys
  (admission_no, is_active, image, roll_no, class_id) can never travel;
  whitespace-only difference is no change; a cleared field sends as
  empty; category travels as a JSON integer; date validation matches
  the service (2026-02-31 and 31-01-2020 refused, 2020-02-29 accepted);
  role rule (Super Admin/Admin — any case — see Edit; Teacher,
  Accountant, Librarian, Receptionist do not); the update response maps
  through the student shape; the editable set is exactly the 17 present
  whitelist fields of the real record shape, in form order.
- **Banned-strings lint: PASSED** (all 12 checks).
- **Metadata gate: PASSED** — package pk.edu.iqrs.admin, versionCode 18,
  versionName 2.5, minSdk 26, targetSdk 34, permissions INTERNET + CAMERA
  only, signature verifies.

## Not verified here

On-device behaviour (form rendering, picker, the live round-trip against
staging/production) — as with every lane, that is Assad's phone gate.
The endpoint itself was staging-verified by the server lane; no server
files were touched by this build.
