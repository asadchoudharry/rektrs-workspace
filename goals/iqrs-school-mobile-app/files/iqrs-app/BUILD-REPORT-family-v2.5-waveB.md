# IQRS Family App v2.5 — Wave B build report

**Build:** IQRS Family v2.5 · versionCode **16** · package `pk.edu.iqrs.family`
**APK:** `IQRS-Family-App-v2.5.apk` — 1,184,178 bytes · sha256 `8cc8988eda2978cd692a3db5ddfe85ca68f051d4da262db1ee5435aa07fa1dc8` (debug-signed, as every wave so far; production signing stays the M5 step)
**Scope:** Wave B of the family parity programme — the write/completion half: homework hand-in + daily assignments, leave, bank payments, profile documents + edit, syllabus status + lesson plan + forum, online exams, teachers + rating, student timeline. Evidence base: `LEGACY-SOURCE-FINDINGS.md` + the production `Webservice.php`, which is md5-identical to the mined package's API source, so every shape below is settled by the one shared backend copy.

## Gates — all green

| Gate | Result |
|---|---|
| JVM suite (`tools/run_tests.sh`) | **OK — 175 tests** (153 v2.4 baseline + 22 new Wave B tests) |
| Banned-strings lint | **PASSED** (language lockdown intact; the bank-payment feature is worded "Bank Payments" on screen — the banned word never appears) |
| Metadata (`tools/metadata_check.sh`) | **PASSED** — package `pk.edu.iqrs.family`, versionCode 16, versionName 2.5, minSdk 26, targetSdk 34, **INTERNET only** (no new permission was needed by any feature) |
| apksigner verify | Verifies (debug cert, as previous waves) |
| Admin regression (`./build.sh admin`) | Builds clean; metadata PASSED — `pk.edu.iqrs.admin`, **versionCode 19**, v2.6, INTERNET + CAMERA unchanged |

## What was built, per feature

All writes are **online-only** (the family app has no outbox and none was added): a write either lands now or the screen keeps the family's input and shows the service's own refusal text (BUSINESS answers surface verbatim; `WriteResult.refusal` now unwraps the service's array-shaped field errors so parents read "The Reason field is required", not raw JSON). All new screens are Activities registered in the family manifest list in `build.sh`, sharing `WaveBActivity` chrome (back bar, date picker, document picker via `ACTION_OPEN_DOCUMENT` — no storage permission — and the one error path) and `FilePick` for reading picked files.

### 1. Homework submit + teacher's check + Daily Assignments
- **Hand-in** from the homework detail screen: `POST webservice/addhomework`, **multipart**, exactly the legacy client's shape (findings §2; backend `Webservice.php:1049`): fields `homework_id` + `id` alias, `student_id`, `message` + `student_message` alias, `student_session_id`, and the file under **both** parts `file` and `userfile`. The service requires a message (form_validation), so the form does too.
- **Teacher's check**: the detail screen now renders the evaluation fields the mapper previously ignored — `evaluation_marks`/`marks`, `evaluation_date`, `evaluated_by`, `note` — pinned by the existing `homework_evaluated.json` fixture lineage.
- **Daily Assignments** (More tile): list from `getdailyassignment` → `{dailyassignment:[…]}`; add via **`addeditdailyassignment`** (multipart; backend :4399 — this is the endpoint the legacy app uses and the one that works; the findings' correction of the plan's `adddailyassignment` guess stands: that endpoint only inserts when a file is present). The subject picker is fed by `getstudentsubject`, whose rows carry `subject_group_subjects_id` (backend `Syllabus_model::getmysubjects`); `SubjectEntry`/`SubjectsMapper` were extended additively to carry it, since the add call stores the subject under exactly that id. Delete via `deletedailyassignment` JSON `{id}`.

### 2. Apply for Leave
- List: `getApplyLeave {student_id}` → `result_array` (statuses "0" pending / "1" approved / "2" disapproved; approver name from the staff join). Create: **`addLeave` multipart** (:73) with `student_id`, `studentId` alias, `student_session_id`, `from_date`, `to_date`, `apply_date`, `reason`, optional document in part `file` → `uploads/student_leavedocuments/`. Update: `updateLeave` multipart (:246). Delete: `deleteLeave` JSON `{leave_id}` → `{result:'Success'}`. Edit/delete are offered **only on pending applications** (the legacy rule); dates are picker-driven; a refusal leaves the form untouched.

### 3. Bank payments (the legacy "offline" payments)
- Report: `addofflinepayment` multipart (:5096) — `payment_type` (`fees`|`transport_fees`), `payment_date`, `student_session_id`, `bank_account_transferred`, `amount`, optional `reference` and slip in part `file`; fees rows add `fee_groups_feetype_id` + `student_fees_master_id`, transport rows `student_transport_fee_id`. The fee picker is fed by the real fees statement (unpaid lines only; the line/master/transport ids now mapped in `FeesMapper`), and `student_session_id` comes from the child record, falling back to a profile fetch when empty.
- Follow-up: `getOfflineBankPayments` → `result_array`, newest first, with the office's reply and status (Approved / Rejected / with the office). Instructions: `getOfflineBankPaymentInstruction` shown when the school has written some.
- **Gating:** the whole section (More tile + Fees-screen entry) appears only when `getOfflineBankPaymentStatus` answers yes — checked live each time the More tab shows.

### 4. Profile documents + edit
- Documents (Profile → Documents): `getDocument` (bare top-level array) with files resolved under `uploads/student_documents/<student_id>/<doc>`; upload via `uploadDocument` multipart (:3517) — `student_id` + `title` + compulsory part `file` (the endpoint reads no description, so none is asked for).
- Edit profile (Profile → Edit profile, shown only when `checkProfileUpdate` says the school allows it): fields come from `profileUpdateFields` — a field renders **iff** the school marks it editable (`student_details` status 1) **and** `editprofile` actually applies it (the endpoint's isset chain, codified in `ProfileFields`). Gender/blood-group/category are pickers fed by the payload's own lists; dates are pickers; save is **changed-fields-only** multipart to `editprofile` (:3128) and refreshes by dropping the cached profile. Two backend quirks honoured: the endpoint reads `measure_date` while rows store `measurement_date` (mapper bridges), and `house` is never sent (no house list exists in the payload).

### 5. Syllabus Status + Lesson Plan + forum
- Syllabus (More tile): `getsyllabussubjects` (per-subject totals → percent bar) → `getSubjectsLessons` (bare array of lessons with nested topics, `topic.status` 1 = done) → lesson detail available via `getsyllabus` mapping.
- Lesson Plan (More tile): `getlessonplan {student_id, date_from, date_to}` for the current week, grouped by weekday as the service groups it.
- Forum: each planned lesson opens its discussion — `getforummessage` / `addforummessage` / `deleteforummessage`. **Correction to the findings doc, from the backend copy:** the save endpoint is `addforummessage` (~:2251) and `getforummessage` keys on **`subject_syllabus_id`**, not `student_id`. Own comments (type `student` + matching admission number) can be deleted; teacher comments carry a Teacher chip.
- **Data caveat honoured:** production has no subject groups configured, so all three screens render their honest empty states (no errors, no fake data) until the school sets them up.

### 6. Online Exams
- Lists: `getOnlineExam {student_id, exam_type}` — open tab sends `" "`, finished tab sends `"closed"` (the legacy/backend convention).
- Attempt: `getOnlineExamQuestion` fetched fresh, exactly once per opening, **never cached** — fetching it records an attempt server-side, and the screen says so before the family starts. Per-question state (single/true-false radio, multichoice checkboxes, descriptive text) is held in the screen; the countdown runs from the service's `remaining_duration` (an HH:MM:SS string) and hands in automatically at zero. The payload's `correct` keys are **never read by the UI**, let alone shown. An already-submitted paper, or one the service marks attempt-closed, shows the plain state instead of a paper.
- Hand-in: `saveOnlineExam` — the encoding finding that matters: the backend reads `$this->input->post('rows')`, and CI3's `Input::post` reads `$_POST` only (verified in `system/core/Input.php`; no `MY_Input` override exists), so the legacy app's JSON body and JSON-string-rows variants **cannot** populate it. Answers therefore travel as real bracket-named multipart fields `rows[i][onlineexam_student_id|question_type|onlineexam_question_id|select_option]`; multichoice selections travel as a JSON array string of option keys (the backend `json_decode`s both sides when marking). **Descriptive-answer file attachments (`attachment_<qid>`) are not sent in this build** — text answers are; the skip is deliberate and recorded here.
- Result: `getOnlineExamResult` — service-computed totals, counts, rank, and the per-question review (the service's own correct answers are shown here, after the fact, as it returns them). Before publication the service answers without a result body, which the mapper refuses as a contract shape; the screen turns exactly that into "The result has not been published yet."

### 7. Teachers + rating
- List: `getTeachersList {user_id, class_id, section_id}` → `result_list` as an **object keyed by staff id** (the mapper also tolerates an array); class/section are resolved through the profile chain exactly like the timetable does. Subjects render as "Name (CODE)" lines; the class teacher is badged.
- Rating: `addStaffRating {user_id, staff_id, rate, comment}` as a 1–5 star form. The service keeps **one rating per teacher per family** (its model refuses a second insert with "something wrong or already submitted"), so a rated teacher shows the stars given and the form steps aside.

### 8. Student Timeline
- Profile → Timeline, shown only when `getStudentTimelineStatus` says the school has it on. Entries from `getTimeline` — the service reads the camelCase key **`studentId`** — a bare array, oldest first, documents under `uploads/student_timeline/`. Add via `addedittimeline` multipart with the document in the part named **`timeline_doc`** (the name the service actually reads); delete via `deletetimeline` JSON `{id}`.

## Shared-code changes (additive only)
- `CacheDb.remove(endpoint, key)` added (write paths drop stale cached payloads).
- `SubjectEntry` gained `subjectGroupSubjectId` (delegating constructor; existing callers untouched) and `SubjectsMapper` maps it.
- `WriteResult.refusal` unwraps array-shaped field errors.
- `FeeStatement.Line` carries the three payment ids; homework items carry the evaluation fields (both from the pre-wave data layer, exercised end-to-end by this build's UI).

## Staging verification — stated honestly
- **Unauthenticated behaviour verified:** all 19 Wave B endpoints were probed with curl against `https://staging.iqrs.edu.pk/api/webservice/…` with the standard client headers and no token — **every one answered HTTP 401 with the clean JSON `{"status":401,"message":"Unauthorized."}`** (reads and writes alike; nothing was written anywhere).
- **Live-write verification is PENDING.** No staging-only family (student/parent) test identity exists in the staging data or the project records — the only staging fixtures are staff-extension logins (113/114), which cannot sign in to the family API, and using a real family's production credentials against staging was not done. Every request shape and mapper is instead pinned by the 22 new JVM tests against fixtures copied from the backend source (the production backend copy is md5-identical to the mined package source). The first on-device family login with v2.5 (Assad's phone gate) is the live-write proof; the natural checks are one homework hand-in and one leave application, both read back in the app.
- **Nothing was written to production.** The shipped APK keeps the production base URL, as every wave.

## Dropped or deferred, with reasons
- **Descriptive-exam attachments** (`attachment_<qid>` parts): not built — text answers only this wave (see §6).
- **Daily-assignment edit**: the endpoint supports it (`addeditdailyassignment` with an id), but the build ships add + delete; edit was not in the parity scope rows.
- **Homework re-submit after evaluation**: the form is offered until the work is checked; after that the teacher's check replaces it (the service accepts repeat submissions, but the honest end-state is the marked work).
- **Change password**: still absent — the legacy item is a `// TODO` façade (findings §3); forgot-password (Wave A) remains the real flow.
- **Chat**: not parity — it does not exist in the legacy app or backend routes (findings §3); it would be net-new extension work, not part of this wave.
