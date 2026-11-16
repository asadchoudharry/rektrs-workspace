# IQRS Connect + IQRS Workspace — Complete Feature & Design Plan

**Prepared for owner approval:** 7 November 2026  
**Planner's status:** Planning only. No app code or server code was changed for this plan.  
**Current baselines:** IQRS Connect v2.7 (code 18) and IQRS Workspace v2.8 (code 21), shared native tree `~/workspace/iqrs-app-v2/`.  
**Product names:** **IQRS Connect** — for students and parents. **IQRS Workspace** — for teachers, administrators and staff.

---

# Owner summary — one page

## The honest position

The owner's complaint is correct. **Workspace is a useful daily-work core, not yet a mobile version of the school system.** It can sign staff in, show school totals, list classes and students, view/edit a student, change photos, mark class attendance, scan QR attendance, compose homework and notices, collect fees against existing fee lines, and hold work safely on the phone until it can be sent. That is valuable — but it touches only parts of **8 of the web system's 30 core permission groups**. Examinations, HR, front office, income/expenses, library, inventory, transport, behaviour, most fee administration, most reports, lesson planning, certificates and settings have no meaningful Workspace surface today. Some of those should remain web-only for safety or practicality; this plan says which, and why, instead of hiding them.

**Connect is much closer to the old family app.** After v2.5 it has the main student/parent journeys, and v2.6 added the Student Card. Its remaining gaps are narrower but real: behaviour records, visitor records, video tutorials, task writing, the CBSE result variant, descriptive-exam attachments, push notifications, online fee checkout, live classes, online courses and a proper Urdu/RTL experience. Several of those are not coding gaps first — they depend on the school switching on or buying/configuring something in the web system.

The second problem is visual quality control. The owner's phone caught two defects our JVM tests could not: **a Student Card preview on Connect Home rendered as a giant, mostly empty navy surface**, and **the bottom-navigation label “Attendance” wrapped mid-word (“Attendanc / e”)**. A build with green unit tests is therefore **not** automatically fit to send to the owner. This plan makes a separate **Checker** role and a visual acceptance gate mandatory for every wave.

## What we will build first

**Wave 0 — stop the visual regressions and build the safety rails (before any new feature wave):**
1. Fix the bottom-navigation layout rule: labels are always one line, fully visible, never shrunk into a wrap.
2. Replace the Home Student Card preview with a bounded wallet strip; the full card lives only on the card screen, at true card proportions.
3. Add the Checker's layout-budget and screenshot harness at **360dp** first, plus 320dp, 411dp, font scale 1.3, light/dark.
4. Build the server foundation the rest of Workspace needs: a **capability map** (what this signed-in staff member is actually allowed to see/do), an **academic catalogue** (classes, sections, subjects, subject groups, attendance types), staging test accounts for every staff role, and a family test account on staging.

**Wave 1 — daily operations (the first feature wave):**
- **Workspace:** role-shaped Home worklist (“waiting for you”), complete attendance register (all attendance types, history/edit), student leave approvals, due-fees search, full student fee statement, fee-payment search, offline-bank-payment review, server notice list/edit, staff directory, my leave + leave approvals, my timetable/class timetable, front-desk essentials (enquiries + follow-ups, visitor check-in/out, open complaints).
- **Connect:** only the visual repair and verification of the already-built Wave B writes on a staging family account — no new Connect feature wave until those writes have live proof.

**Wave 2 — professional depth:** examinations and marks entry, homework submissions/evaluation, lesson plan/syllabus, library, income/expenses, fee setup, reports, behaviour, certificates/ID printing, downloads management, transport and inventory operations, HR depth, online-exam authoring.

**Wave 3 — conditional and specialist:** online courses, live-class creation, CBSE suite, hostel (only if the school uses it), alumni, online-admission processing, multi-branch, advanced settings/status, two-factor setup, quick-fees and thermal printing.

## What it takes

- **New staff API work is unavoidable.** The vendor family API does not accept staff logins. Almost every missing Workspace feature needs a new, authenticated endpoint in our own `Staffapi.php` / `Staffsync.php` extension. Section 3 names each endpoint and its shape.
- **Staging first, always.** New endpoints are proved on staging with role fixtures before any app screen is built on them.
- **Production server changes need the owner's approval one change at a time** — exact file, exact version, staging evidence attached. App-only builds do not change the server.
- **School setup is a dependency, not an excuse.** Production currently has only 2 subjects and **no subject groups**, **0 exams**, no configured timetable, an empty library/transport/inventory, no active payment gateway and no FCM setup (live audit, 2026-11-07). Apps must show an honest “not set up yet” state for these — never a broken-looking blank — and the plan's waves do not pretend the data exists.

## Decisions asked from the owner now

1. **Approve this plan and Wave 0 + Wave 1 scope** (one approval).
2. Later, approve each **production** `Staffapi.php` / `Staffsync.php` swap separately as it arrives with staging proof.
3. Decide school-setup items only when their wave arrives: subject catalogue/exam structure (Wave 1/2 data), payment gateway and Firebase (Connect Wave C), Zoom/Gmeet/Online Course add-ons (Wave 3).

**Non-negotiable:** no wave reaches the owner without the Checker's signed report. Green unit tests alone are no longer a delivery.

---

# 1. How to read this plan

## 1.1 Status words

| Status | Meaning |
|---|---|
| **Have** | The app has the feature today against the current data path. “Have” does not mean the owner has device-verified every newest write — verification state is stated where it matters. |
| **Partial** | A real, useful subset exists; the missing delta is named. |
| **Missing** | No app feature exists. |
| **Web-only** | Deliberately not planned for the mobile app; the reason is stated (security, template/spreadsheet work, rare setup, or server administration). A read-only mobile status may still be planned. |
| **Conditional** | Feasible only if the relevant module/add-on/data is configured at IQRS. |

## 1.2 Data-path words

- **Family API** — the vendor `Webservice.php` API used by Connect. It accepts student/parent logins only.
- **Staffapi / Staffsync (existing)** — our additive staff extension. Existing reads: `schoolDetails`, `dashboard`, `me`, `classes`, `students`, `studentSearch`, `student`, `studentUpdate`, `studentPhoto`, `myPhoto`. Existing offline-capable writes in Staffsync: `attendance`, `qrAttendance`, `homework`, `notice`, `feeCollect`, plus the `feeInvoice` read.
- **NEW API-nn** — a new endpoint specified in §3. Unless §3 says otherwise: `POST` JSON to `/api/staffapi/<name>` with the existing staff session headers; success envelope `{status:1, message, record}` or `{status:1, message, records, summary, page}` for lists; refusal `{status:0, message}` in plain words. Writes that must work with no signal go to `/api/staffsync/<name>` and carry a client transaction id so a retry can never create a duplicate — the pattern the current attendance/fee writes already prove.
- **Online-only write** — money-state approvals, setup changes, publishing and destructive actions are never queued offline; the app must say a connection is needed and preserve the entered work.

## 1.3 Role abbreviations and the permission rule

**SA** Super Admin · **A** Admin · **T** Teacher · **AC** Accountant · **L** Librarian · **R** Receptionist · **ALL** any signed-in staff member (own-data only where stated).

The role column is the **default audience**, not the security mechanism. Smart School has 234 permission items and unlimited custom roles, so the real rule is:

> The server returns a **capability map** for the session (API-00). The app shows only what the map allows, and **every endpoint checks the same capability itself**. Hiding a button is never the protection. A teacher's scope is additionally limited to assigned classes/students; an approver cannot approve their own request; a fee void cannot be done by the person who collected it without a supervisor capability.

## 1.4 “Feature complete” — the definition every wave is judged by

A feature is complete only when all seven are true: (1) it is discoverable from the role's Home/worklist and the grouped More catalogue; (2) its data path is staging-proved; (3) loading, populated, empty, not-configured, offline-cached and permission-denied states are designed; (4) money/attendance figures reconcile with their source list; (5) writes are idempotent or online-only by design; (6) it passes the Checker protocol in §6; (7) the build report states plainly what was **not** verified.

## 1.5 IQRS data-readiness facts that shape the plan (live audit, 2026-11-07)

| Fact | Consequence for the apps |
|---|---|
| Only 2 subjects system-wide; `subject_group_*` tables empty | Homework is blocked at the subject step; syllabus/lesson-plan screens must show a setup state until the school configures the catalogue (decision D1 in the web-overhaul programme). API-01 makes the app light up automatically once configured. |
| 0 exams in all 8 exam groups; no timetable scheduled | Exam and timetable screens are built against staging fixtures first; on production they show “not set up yet”, not an error. |
| Library 0 books, Transport 0 vehicles, Inventory 0 items, Hostel not evidenced | These modules start with catalogue/import/setup states; they are Wave 2/3, not Wave 1. |
| ~951 per-student “AFM Legacy Arrears” fee groups; web Search Due Fees ignores the Class/Section filter (1,643 rows returned for a one-class search) | The new due-fees endpoint must implement filters server-side and the Checker must prove a one-class search returns only that class. Legacy arrears groups are grouped honestly in the statement, never hidden. |
| Dashboard tile “Fees Awaiting Payment” appears to count paid records | Every Workspace worklist count must reconcile with the list behind it (Checker rule). |
| No payment gateway active; JazzCash fields blank; “None” selected | Connect online checkout and Workspace fee links cannot work until the school activates a gateway. Offline bank-payment review is therefore Wave 1; checkout is Wave C. |
| No FCM project/key wired; the vendor token re-registration endpoint does not exist | Push is a school-setup project (Wave C), not an app toggle. |
| Vendor family API has known security flaws (ownership checks absent; password field returned in payloads — web-overhaul FL-010/FL-011) | Connect adds **no new sensitive data class** until the overhaul's Wave 1 ownership fix is staging-proved; Workspace keeps using the session-scoped extension pattern, which already derives identity from the session, not from a client-sent id. |

---

# 2. WORKSPACE FEATURE MATRIX — every web module, row by row

Waves: **W1** daily operations · **W2** professional depth · **W3** specialist/conditional. “API-nn” refers to §3.

## 2.0 Home, dashboard and navigation

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Dashboard widgets (20): session change, fee/expense charts, monthly fee & expense, student count, staff role count, fees awaiting, converted leads, fees/enquiry/library overviews, student & staff present today, income/expense donuts, head count, approved leaves | Role-shaped Home: identity, today's classes, **“Waiting for you” worklist** (unmarked classes, leave approvals, bank payments to review, enquiries due, complaints open, homework to check), then role cards | **Partial** — today's `dashboard` returns only total students/staff/teachers/classes + today's attendance counts | Existing `staffapi/dashboard`; NEW API-02 `dashboardWorklist` for counts that open the exact list behind them | ALL (cards by capability) | W1 |
| Quick Session Change | Session context label on Home; session switching for office roles | Missing | NEW API-00 capability/session context; switching is online-only and re-scopes every screen | SA/A | W3 |
| Student count / head count / present-today widgets | Home stat cards with drill-through to the reconciled list | Partial (totals only) | `dashboard` + API-02 | ALL by capability | W1 |
| Fees awaiting / fees overview widgets | Due-fees card whose number equals the due list's total balance count | Missing | API-20 | SA/A/AC | W1 |
| Staff present today / approved-leave widgets | Staff attendance + approvals cards | Missing | API-81/API-82 | SA/A | W1–W2 |

## 2.1 Student Information (web: 7 functions + timeline + ID card)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Student (View) — browse/search/detail | Student search (name/admission), class browse, full detail incl. Student Card view | **Have** | `studentSearch`, `students`, `student`, `classes` | ALL scoped (T: assigned) | — |
| Student (Edit) | Edit profile — 25-field office whitelist | **Have** (SA/A only, as the web intends) | `studentUpdate` | SA/A | — |
| Student photo | Change student photo from the edit screen | **Have** | `studentPhoto` | SA/A | — |
| Student (Add) | New admission form (student + guardian + class/section), duplicate-admission warning before save | Missing | NEW API-10 `studentCreate`, online-only | SA/A/R (with Add capability) | W2 |
| Disable Student + Disable Reason | Disable/enable with reason picker and note; disabled students leave registers but keep history | Missing | NEW API-11 `studentStatusSave`, online-only; reasons via API-05 | SA/A | W2 |
| Student Categories / Houses | Pickers in forms come from server lists; small reference editor | Missing | NEW API-05 `referenceData`/`referenceSave` | SA/A (edit); ALL (pick) | W3 |
| Import Student | **Web-only** — spreadsheet mapping/error reconciliation is desktop work. App shows the last import job's result if opened from office status | Web-only | — | SA/A | — |
| Student Timeline | Timeline tab on student detail: office-visible entries, add note/document with visibility choice | Missing (Connect has the family side) | NEW API-12 `studentTimeline` + save/delete | SA/A/T (assigned) | W2 |
| Multi Class Student | Enrolments tab: all class enrolments for the student; add/remove enrolment | Missing | NEW API-13 `studentMultiClass` + save, online-only | SA/A | W2 |
| Student ID Card (Certificate module) | Card screen exists on student detail; add **share/print-ready card file** | Partial | Existing card view; NEW API-14 `studentIdCard` returns the authorised card file | ALL scoped (view); SA/A/R (issue) | W2 |
| Student CV (Build/Download/Setting) | **Web-only** for building (template work); app may open a generated CV file from student detail | Web-only | API-04 authorised file open if a CV exists | SA/A | W3 |

## 2.2 Fees Collection (web: 12 functions) — the office's money desk

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Collect Fees | Collect against an existing fee line; amount/discount/method; review sheet before save; receipt after the school confirms; works with no signal | **Have** | `staffsync/feeInvoice` + `staffsync/feeCollect` (idempotent) | AC/SA/A (+ Fee Clerk custom role) | — |
| Collect Fees — receipt | Receipt screen + share for a collection **made earlier** (not only just-collected) | Partial (only the just-collected receipt exists) | NEW API-23 `feeReceipt` | Collector + SA/A/AC | W1 |
| Collect Fees — correction | Void/reverse a collection with a reason; the original stays in the audit trail; never queued offline, never self-approved | Missing | NEW API-28 `feeCollectVoid`, online-only | SA/AC supervisor | W2 |
| Search Due Fees | Due list with class/section/group/date filters, student search, balance totals that reconcile | Missing | NEW API-20 `feeDueSearch` | SA/A/AC/R (view) | W1 |
| Student fee statement | One student's full ledger: groups, deposits, discounts shown **as discounts — never as payments**, fines, balance, receipts | Partial (due lines only) | NEW API-21 `feeStatement` (extends the `feeInvoice` read) | SA/A/AC/R (view) | W1 |
| Search Fees Payment | Payment history search by date/student/invoice/mode/collector | Missing | NEW API-22 `feePaymentSearch` | SA/A/AC | W1 |
| Offline Bank Payments (review) | Review queue: see the family's submitted payment + slip, approve (posts the fee) or reject with a reason the family can read | Missing | NEW API-24 `offlinePayments` + `offlinePaymentReview`, online-only | AC/SA/A | W1 |
| Fees Reminder | Send due-fee reminders to a class/group/student set via configured channels; shows channel availability honestly | Missing | NEW API-29 `feeReminderSend` + API-61 logs | SA/A/AC | W2 |
| Fees Master / Group / Type / Discount (setup) | Setup studio: list + create/edit masters, groups, types, discounts with impact preview (“this affects N students”) | Missing | NEW API-25 `feeSetup` + save endpoints, online-only | SA/A/AC | W2 |
| Fees Group Assign / Discount Assign | Assign a group/discount to class, section or picked students with a count confirmation | Missing | NEW API-26 `feeAssignmentSave`, online-only | SA/A/AC | W2 |
| Fees Carry Forward | Year-end carry-forward wizard: preview balances → confirm → apply with audit record | Missing | NEW API-27 `feeCarryForwardPreview/Apply`, online-only | SA/AC | W3 |
| Quick Fees Create (add-on) | Guided one-pass fee creation for a class | Missing | NEW API-25 extension `quickFeeCreate` | SA/A/AC | W3 |
| Thermal Print (add-on) | Print the receipt on the office thermal printer | Missing | API-23 with `format:thermal` + Android print path; printer model must be checker-verified | AC/SA/A | W3 |

## 2.3 Student Attendance (web: 3 functions) + QR add-on

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Student Attendance (class register) | Mark a class for a date: mark-all-present, per-student control, sticky summary + save, safe with no signal | **Have** | `classes`/`students` + `staffsync/attendance` | T (assigned)/SA/A | — |
| Register completeness | Register shows **all** of the school's attendance types (Present, Late, Absent, Leave, Half Day, Holiday…) as labelled choices, existing marks and remarks, for **any** date — not only Present/Absent/Late and not “everyone starts Present” on past days | Partial | NEW API-30 `attendanceRegister`; Staffsync `attendance` payload gains per-record type + remark (versioned) | T (assigned)/SA/A | W1 |
| Attendance By Date | Day view across my classes: which registers are done, missing, edited | Missing | API-30 with `scope:mine` + API-02 | T/SA/A | W1 |
| Period Attendance | Mark by timetable period/subject when the school uses period attendance | Missing — **Conditional** on timetable + subject groups | API-30 with `period` + Staffsync `attendance` period fields | T (assigned) | W2 |
| QR Code Attendance (add-on) | Scan student card/QR → marked present; duplicate-scan state; manual code fallback; works with no signal | **Have** | `staffsync/qrAttendance` | T/SA/A/R (with capability) | — |
| QR staff attendance (add-on) | Staff member's own check-in by scanning the office code | Missing | NEW API-81 `staffQrCheckIn` in Staffsync | ALL | W2 |
| Approve Leave (student leave) | Approval list: family leave applications for my classes/school, approve/reject with remark; decision reaches the family's app | Missing | NEW API-31 `studentLeaveList` + `studentLeaveReview`, online-only | SA/A + T (class-teacher capability) | W1 |

## 2.4 Homework (web: 3 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Homework (Add) | Compose homework for class + subject with due date | **Partial** — compose exists but is **blocked in practice**: no subject read exists and production has no subject groups | `staffsync/homework` (existing) + API-01 subject catalogue | T/SA/A | W1 (unblock) |
| Homework (View/Edit/Delete) | My homework list from the server (not only “created on this phone”), detail, edit, delete | Missing | NEW API-51 `homeworkList`/`homeworkDetail`; updates via Staffsync with the same transaction discipline | T (own)/SA/A | W1 |
| Homework Evaluation | Submissions list per homework (who handed in, file, time), mark + note per student | Missing | NEW API-52 `homeworkSubmissions` + Staffsync `homeworkEvaluate` | T (own classes)/SA/A | W1 |
| Daily Assignment (View) | Staff view of daily assignments for a class; add/delete for my class | Missing (families create theirs in Connect) | NEW API-53 `dailyAssignments` + save/delete | T/SA/A | W2 |

## 2.5 Communicate (web: 8 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Notice Board (Add) | Compose notice with audience + publish date, confirm-before-post | **Have** | `staffsync/notice` | SA/A/T/R (with capability) | — |
| Notice Board (View/Edit/Delete) | School notice list from the server, my notices, edit/withdraw with version check | Partial (only this phone's notices are listed) | NEW API-60 `noticeList`/`noticeDetail` + update/delete | SA/A/T/R | W1 |
| Email / SMS (send) | Compose to a class/section/staff group/individual set; segment count + channel status shown before sending | Missing — **Conditional** on mail/SMS settings being configured | NEW API-61 `messageSend`, online-only | SA/A/R | W2 |
| Email/SMS Log + Schedule Log | Delivery log with per-recipient status; scheduled messages list + cancel | Missing | NEW API-61 `messageLog` + `scheduledMessages` | SA/A/R | W2 |
| Email/SMS Templates | Template picker inside compose; template editor | Missing | NEW API-62 `messageTemplates` + save | SA/A | W3 |
| Login Credentials Send | Send a login/reset link to a family or staff member. **The app never displays anyone's password** — the server sends it | Missing | NEW API-63 `credentialSend`, online-only, audit-logged | SA/A | W3 |
| Push notification to app users | Targeted push from a notice/message | Missing — **Conditional** on the Connect Wave C Firebase setup | API-61 with `channel:push` after FCM exists | SA/A | W3 |
| Chat (web permission exists) | **Not planned as parity.** The vendor backend exposes no messaging endpoints (proven from source); chat would be a new product with safeguarding/logging decisions | Missing (net-new decision) | Would need a new extension family + owner decision | — | W3 decision only |

## 2.6 Academics (web: 8 functions) + Lesson Plan (6) + Annual Calendar (2)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Class Timetable (View) | Any class/section timetable, day view | Missing (Connect has the student's) | NEW API-01/API-30 family: `classTimetable` in API-01 catalogue payload | ALL scoped | W1 |
| Teachers Timetable | **My timetable** (today + week) on Home; any teacher's timetable for office roles | Missing | NEW `teacherTimetable` (API-01 family) | ALL (own); SA/A (any) | W1 |
| Subject / Subject Group / Class / Section (View) | Academic catalogue used by homework, period attendance, syllabus, exams | Missing — this is the key that unlocks four modules | NEW API-01 `academicCatalog` | ALL scoped | W1 |
| Subject / Subject Group / Class / Section (setup) | Reference setup studio (create/edit) | Missing | API-01 save endpoints, online-only | SA/A | W3 |
| Assign Class Teacher | Assign/change class teacher with effective date | Missing | NEW `classTeacherAssign` (API-01 family), online-only | SA/A | W2 |
| Promote Student | Promotion wizard: pick class → preview moves → confirm → audit | Missing | NEW `promotionPreview`/`promotionApply`, online-only | SA/A | W3 |
| Manage Lesson Plan | My lesson plans by week/subject; create/edit | Missing — **Conditional** on subject groups | NEW API-54 `lessonPlans` + save | T (own)/SA/A | W2 |
| Manage Syllabus Status | Class/subject syllabus progress; mark topics complete | Missing — **Conditional** on syllabus data | NEW API-54 `syllabusStatus` + update via Staffsync | T/SA/A | W2 |
| Lesson / Topic (setup) | Syllabus structure editor | Missing | API-54 save endpoints, online-only | SA/A/T (assigned) | W2 |
| Comments (lesson forum moderation) | Read/moderate lesson comments for my subjects | Missing | NEW API-54 `syllabusComments` | T/SA/A | W2 |
| Copy Old Lessons | Copy last session's lessons into this session | Missing | API-54 `lessonCopy` job, online-only | SA/A | W3 |
| Annual Calendar / Holiday Type | School calendar + holidays inside the staff calendar; type setup stays web | Partial via Connect-side events only | NEW API-66 `calendarEvents`; setup Web-only | ALL (view) | W1 view / W3 setup |
| Calendar To Do List | My tasks: personal + assigned, with due dates and done state | Missing | NEW API-66 `myTasks` CRUD (staff extension — staff identity cannot use the family task endpoints) | ALL | W1 |

---

## 2.7 Examinations (web: 17 functions) + Online Examination (5) + CBSE add-on

**Standing condition:** production has **0 exams configured**. Every row below is built and proved on staging fixtures; on production the module shows “Examinations are not set up for this session yet” until the school creates the structure (web-overhaul decision D2).

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Exam Group / Exam (View) + Exam Schedule | Exam centre: groups, exams, subject schedule with dates, times, rooms, max/passing marks | Missing | NEW API-40 `examCatalog` | SA/A/T (assigned)/AC (view) | W2 |
| Exam Marks (entry) | Marks entry by exam + subject + class: roster with max-marks guard, absent flag, remark; one batch save; entry progress per subject | Missing | NEW API-41 `examMarksRoster` + Staffsync `examMarksSave` (idempotent batch) | T (assigned subject)/SA/A | W2 |
| Exam Result (View) | Student/class result view with subject marks, total, grade, division, rank — only after publication | Missing | NEW API-42 `examResult` | SA/A/T | W2 |
| Exam Publish | Publish/unpublish an exam's results with a confirmation that states how many students are affected | Missing | NEW API-43 `examPublish`, online-only | SA/A | W2 |
| Generate Rank | Run ranking for an exam group and view the ranked list | Missing | API-43 `examRankGenerate` job + API-42 | SA/A | W2 |
| Assign/View Student + Link Exam + Exam Subject | Exam enrolment checks, link two exams, subject list per exam | Missing | API-43 save family, online-only | SA/A | W3 |
| Exam / Exam Group (setup), Marks Grade, Marks Division | Setup studio for groups, exams, subjects, grade bands, divisions | Missing | API-43 `examSave` family, online-only | SA/A (+ Exams custom role) | W3 |
| Design/Print Admit Card & Marksheet | **Design = Web-only** (print-template work, owned by the web print programme). **Generate = app:** pick exam/class → authorised PDF to view/share/print | Partial (generate only) | NEW API-44 `examDocument` + API-04 file open | SA/A/R | W3 |
| Marks Import | **Web-only** — spreadsheet reconciliation; app shows import job status | Web-only | — | SA/A | — |
| Online Examination (View) + results | List online exams for my classes; results and attempt summary per exam | Missing | NEW API-90 `onlineExamList`/`onlineExamResults` | T/SA/A | W2 |
| Online Examination (Add/Edit) + Question Bank + Add Questions + Assign Students | Exam builder (settings, questions from bank or new, assign classes/students) | Missing | NEW API-90 `onlineExamSave`/`questionBank`/`onlineExamAssign`, online-only | T (creator)/SA/A | W2 |
| Import Question | **Web-only** (file parsing/review); bank is fully usable in-app once imported | Web-only | — | SA/A/T | — |
| CBSE Examination add-on (20 functions: exams, schedule, subjects, marks, attendance, observations, remarks, grades, assessments, terms, templates, rank, print) | CBSE exam centre mirroring the add-on's own model — **not** folded into the generic exam endpoints | Missing — **Conditional** on the CBSE add-on being active and configured | NEW API-45 `cbseCatalog`, `cbseMarksRoster`, Staffsync `cbseMarksSave`, `cbseObservations`, `cbseDocument` | SA/A/T (assigned) | W3 |

## 2.8 Human Resource (web: 12 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Staff (View) — directory | Staff directory: search, filter by department/designation/role, staff detail (contact, role, department, designation, joining date) | Missing (Home shows counts only) | NEW API-80 `staffDirectory`/`staffDetail` | ALL (limited view); SA/A (full record) | W1 |
| My profile | Own record, own photo change | **Have** | `me` + `myPhoto` | ALL | — |
| Staff (Add/Edit) | Staff form incl. role, department, designation; admin photo upload | Missing | NEW API-80 `staffSave` + `staffPhoto`, online-only | SA/A (+ HR custom role) | W2 |
| Disable Staff | Disable/enable with reason; disabled staff cannot sign in | Missing | API-80 `staffStatusSave`, online-only | SA | W2 |
| Staff Attendance | Mark staff attendance by date/department (Present/Late/Absent/Leave/Half Day) + **my attendance** calendar | Missing | NEW API-81 `staffAttendance` read + Staffsync save; `myAttendance` | SA/A/R (mark); ALL (own view) | W1 (own view) / W2 (marking) |
| Apply Leave (staff) | **My leave:** balances/types, apply with dates + reason + optional document, my applications and their decisions | Missing | NEW API-82 `myLeaves` + Staffsync `myLeaveApply` | ALL | W1 |
| Approve Leave Request | Approval queue with applicant, dates, type, balance; approve/reject with remark; **no self-approval** | Missing | NEW API-82 `staffLeaveApprovals` + `staffLeaveReview`, online-only | SA/A (+ manager custom role) | W1 |
| Leave Types / Department / Designation | Reference pickers from server; small setup editor | Missing | API-05 reference family | SA/A (edit); ALL (pick) | W3 |
| Staff Payroll | Payroll list per month, staff payslip detail; **my payslips** for every staff member | Missing | NEW API-83 `payrollList`/`payrollDetail`/`myPayslips` | AC/SA/A (all staff); ALL (own payslips) | W2 |
| Payroll generation | **Web-only initially** — payroll arithmetic was never deep-verified (web-overhaul FL-004); the app displays generated payroll only, until staging reconciliation passes | Web-only | — | SA/AC | W3 decision |
| Staff Timeline | Timeline tab on staff detail (office entries, visibility) | Missing | NEW API-84 `staffTimeline` + save | SA/A (+ HR) | W2 |
| Teachers Rating | Ratings received from families: per-teacher average + comments, moderation | Missing (families rate in Connect) | NEW API-84 `teacherRatings` | SA/A; T sees own summary | W2 |
| Staff ID Card | Own ID card view; issue/print file for any staff member | Missing | API-14 family: `staffIdCard` | ALL (own); SA/A/R (issue) | W2 |

## 2.9 Front Office (web: 8 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Admission Enquiry | Enquiry list with status/source filters; new enquiry form (student, guardian, contact, source, class sought) | Missing | NEW API-70 `enquiryList`/`enquirySave` (Staffsync create so the desk works offline) | R/SA/A | W1 |
| Follow Up Admission Enquiry | Follow-up timeline per enquiry; add follow-up with next date; **today's follow-ups** on the Home worklist | Missing | NEW API-70 `enquiryFollowUps` + save | R/SA/A | W1 |
| Visitor Book | Visitor check-in (name, purpose, whom to meet, phone) + check-out; today's visitors list; visitor pass file | Missing | NEW API-71 `visitorCheckIn`/`visitorCheckOut` in Staffsync + `visitorList` | R/SA/A (+ Security custom role) | W1 |
| Complain | Complaint list with status; log a complaint; assign + resolve with note | Missing | NEW API-72 `complaintList`/`complaintSave`/`complaintStatusSave` | R/SA/A | W1 (log + list) / W2 (assign) |
| Phone Call Log | Call log list + add (incoming/outgoing, duration, next follow-up) | Missing | NEW API-72 `callLogList`/`callLogSave` | R/SA/A | W2 |
| Postal Dispatch / Receive | Postal register list + add with document photo | Missing | NEW API-72 `postalList`/`postalSave` | R/SA/A | W2 |
| Setup Front Office (reference types) | Pickers from server; setup stays web | Partial | API-05 (read) | R (use); SA (setup, web) | W3 |

## 2.10 Income & Expenses (web: 3 + 3 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Income (View/Search) | Income list with date/head search and totals | Missing | NEW API-95 `incomeList` | AC/SA/A | W2 |
| Income (Add/Edit/Delete) | Record income with head, amount, date, note, receipt photo; edit/delete with audit | Missing | NEW API-95 Staffsync `incomeSave` + online delete | AC/SA/A | W2 |
| Expense (View/Search) | Expense list with date/head search and totals | Missing | NEW API-95 `expenseList` | AC/SA/A | W2 |
| Expense (Add/Edit/Delete) | Record expense with head, amount, date, note, bill photo; edit/delete with audit | Missing | NEW API-95 Staffsync `expenseSave` + online delete | AC/SA/A | W2 |
| Income/Expense Heads | Reference pickers; setup editor | Missing | API-05 reference family | SA/AC (edit) | W3 |
| Monthly finance summary | Fees collected + income − expense for the month on the finance card | Missing | NEW API-95 `financeSummary` + API-02 | SA/A/AC | W2 |

## 2.11 Library (web: 5 functions)

**Standing condition:** the live library holds **0 books**. The module ships with an honest “no books yet — add or import books to begin” state; bulk import stays web.

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Books List | Catalogue search (title/author/book no.), availability per book | Missing | NEW API-100 `libraryCatalog` | L/SA/A; T/ALL (search) | W2 |
| Issue Return | Issue/return desk: scan or search book + member (student/staff), due date, fine shown on late return | Missing | NEW API-100 Staffsync `libraryIssue`/`libraryReturn` + `libraryCirculation` | L/SA/A | W2 |
| Books (Add/Edit) | Add/edit a book with copies count | Missing | API-100 `bookSave`, online-only | L/SA/A | W2 |
| Import Book | **Web-only** (spreadsheet import) | Web-only | — | L/SA | — |
| Add Student / Add Staff Member (library members) | Activate a student/staff member for the library from their existing record | Missing | API-100 `libraryMemberSave` | L/SA/A | W2 |

## 2.12 Inventory (web: 6 functions)

**Standing condition:** live inventory holds **0 items**; setup/import first, operations second.

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Item stock (View) | Stock list/search by store/category/supplier with quantities | Missing | NEW API-110 `inventoryStock` | SA/A/AC (+ Storekeeper custom role) | W2 |
| Add Item Stock | Receive stock (quantity, rate, date, supplier) | Missing | API-110 Staffsync `stockAdd` | Storekeeper/SA/A | W2 |
| Issue Item | Issue to student/staff/department; return flow | Missing | API-110 Staffsync `inventoryIssue`/`inventoryReturn` | Storekeeper/SA/A | W2 |
| Add Item / Category / Store / Supplier (setup) | Setup editor | Missing | API-110 save family, online-only | SA/A | W3 |

## 2.13 Transport (web: 7 functions)

**Standing condition:** live transport holds **0 vehicles/routes**. No GPS/live-tracking is promised — the web system has no vehicle-location data.

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Routes / Vehicle (View) | Transport overview: routes, vehicles, drivers, student counts per route | Missing | NEW API-120 `transportOverview` | SA/A/R (+ Transport custom role) | W2 |
| Student Transport Fees / assignment | Per-student transport assignment + transport fee view; change route/pickup point | Missing | NEW API-120 `studentTransport` + save | SA/A/AC/Transport | W2 |
| Routes / Vehicle / Pickup Point / Assign Vehicle (setup) | Setup editor (routes, vehicles, pickup points, assignments) | Missing | API-120 save family, online-only | SA/A/Transport | W3 |

## 2.14 Hostel (web: 3 functions)

**Standing condition:** no evidence IQRS uses hostel. The module stays **hidden until configured**; building it before the school confirms hostel use would be wasted work.

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Hostel / Room Type / Hostel Rooms | Setup + room list with occupancy | Missing — Conditional | NEW API-130 `hostelOverview` + save family | SA/A (+ Warden custom role) | W3 |
| Room assignment | Assign a student to a room/bed; vacate | Missing — Conditional | API-130 `hostelAssign`, online-only | Warden/SA/A | W3 |

## 2.15 Download Center (web: 4 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Upload Content | Share a file with classes/students/staff: upload with title, type, audience, validity | Missing (staff side; Connect reads shared content) | NEW API-140 `contentUpload` (multipart) + `contentList` | SA/A/T | W2 |
| Content Share List | See and change who a file is shared with | Missing | API-140 `contentShares` + save | SA/A/T (own) | W2 |
| Content (Delete) | Remove own shared content | Missing | API-140 `contentDelete`, online-only | SA/A/T (own) | W2 |
| Video Tutorial | Tutorial list for staff; add a video link/entry for a class | Missing | NEW API-140 `videoTutorials` + save (link/metadata; large video uploads are not assumed — hosting limits must be verified first) | SA/A/T | W2 |
| Content Type (setup) | Reference list; setup stays web | Partial | API-05 (read) | SA (setup, web) | W3 |

## 2.16 Certificates (web: 6 functions)

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Student Certificate / Generate Certificate | Pick student + certificate → generate → authorised PDF to view/share/print. **Design of templates = Web-only** (print programme) | Missing (generate only) | NEW API-150 `certificateList`/`certificateGenerate` + API-04 | SA/A/R | W3 |
| Student ID Card / Generate ID Card | Card view **Have**; generate print file | Partial | API-14 | ALL scoped / SA/A/R | W2 |
| Staff ID Card / Generate Staff ID Card | Staff card view + print file | Missing | API-14 `staffIdCard` | ALL (own) / SA/A/R | W2 |

> Security rule for every generated file (certificates, admit cards, marksheets, receipts): files are delivered through the authenticated extension (API-04) or a short-lived signed link minted by it. The web audit found unauthenticated certificate URLs in the vendor system; the apps must never copy that pattern.

## 2.17 Behaviour Records add-on

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Behaviour Records Incident (catalogue) | Incident types with positive/negative points (read; setup by office) | Missing — Conditional on add-on active | NEW API-170 `behaviourCatalog` | SA/A (+ Discipline custom role) | W2 |
| Assign Incident | Record an incident for a student (type, date, note) from the student detail or class list | Missing | API-170 Staffsync `behaviourAssign` | T (assigned)/SA/A | W2 |
| Student behaviour record | Behaviour tab on student detail: points, incidents, comments | Missing (Connect shows families their side) | API-170 `studentBehaviour` | SA/A/T (assigned) | W2 |
| Behaviour reports/ranks | Class/house rank views | Missing | API-220 reports family | SA/A | W2–W3 |
| Behaviour Setting | **Web-only** setup | Web-only | — | SA | — |

## 2.18 Reports (web: 51 reports)

**Mobile pattern for every report:** a report is a **summary card + clean table + share/export file**, not a photograph of the web page. The Checker reconciles the app's totals against the web report on staging data. Print-perfect layouts belong to the web print programme; the app generates the same data honestly.

| Report family (all 51 named) | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Student: Student Report, Guardian Report, Student History, Admission Report, Sibling Report, Student Profile, Student Gender Ratio, Student Teacher Ratio, Online Admission Report, Student Login Credential Report | Report catalogue entries with filters (class/section/date) | Missing | NEW API-220 `reportCatalog`/`reportRun`/`reportExport` | SA/A/R (credential report: SA only, and it must never print a password — see note) | W2 |
| Fees & finance: Fees Statement, Balance Fees Report, Balance Fees Report With Remark, Balance Fees Statement, Fees Collection Report, Online Fees Collection Report, Daily Collection Report, Income Report, Expense Report, Income Group Report, Expense Group Report, PayRoll Report | Catalogue entries; money totals reconciled to the rupee | Missing | API-220 | SA/A/AC | W2 |
| Attendance: Attendance Report, Daily Attendance Report, Student/Period Attendance Report, Student Attendance Type Report, Staff Attendance Report, Biometric Attendance Log | Catalogue entries by date/class/staff | Missing (biometric log: only if a device integration exists — otherwise the entry explains that) | API-220 | SA/A/T (own classes) | W2 |
| Academic: Class Subject Report, Homework Evaluation Report, Exam Marks Report, Rank Report, Syllabus Status Report, Teacher Syllabus Status Report, Online Exam Wise Report, Online Exams Report, Online Exams Attempt Report, Online Exams Rank Report | Catalogue entries | Missing | API-220 | SA/A/T | W2 |
| Operations: Transport Report, Hostel Report, Book Issue Report, Book Due Report, Book Inventory Report, Book Issue Return Report, Stock Report, Add Item Report, Issue Item Report, Alumni Report, Staff Report, Audit Trail Report, User Log | Catalogue entries | Missing (audit/user log: SA only) | API-220 | SA/A + module roles | W2–W3 |

> **Student Login Credential Report — safety exception:** the web report exists in a system whose family passwords are currently stored in plaintext (audit FL-009). The app will offer **credential reset-link sending** (API-63), never a screen or export that displays passwords. If the owner wants the report itself in-app, it ships only after the password migration removes plaintext.

## 2.19 Online Admission, Alumni, Online Course, Live Classes, Multi Branch

| Web feature | Workspace feature | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| Online Admission (review) | Application list/detail; approve/reject; convert an approved application into a student (duplicate check first) | Missing — Conditional on the module being enabled | NEW API-180 `onlineAdmissions`/`onlineAdmissionReview`/`onlineAdmissionConvert`, online-only | SA/A/R | W3 (promote to W2 in admission season if the owner asks) |
| Manage Alumni + Alumni Events | Alumni directory + detail; alumni event list/publish | Missing | NEW API-180 `alumniList`/`alumniSave`/`alumniEvents` | SA/A/R | W3 |
| Online Course add-on (teacher side: courses, publish, sections, lessons, quiz, question bank, assignments + evaluation, course exams, ratings, reports) | Course studio for teachers: my courses, build sections/lessons, mark assignments, view enrolments/progress | Missing — Conditional on the add-on + published courses; **XL build** | NEW API-200 `courseManage` family | T (creator)/SA/A | W3 |
| Zoom / Gmeet Live Classes add-ons | Schedule a live class for my class (provider, topic, time), start/join link, class history/report | Missing — Conditional on add-on + provider account | NEW API-210 `liveClasses`/`liveClassSave` | T/SA/A | W3 |
| Multi Branch add-on | Branch overview + cross-branch collection/payroll/income/expense summaries; branch context switch | Missing — Conditional; **setup Web-only** | NEW API-240 `branchOverview` + API-220 | SA only | W3 |
| Two Factor Authentication add-on | My 2FA status + setup/recovery for my own staff login | Missing — must be designed so nobody is locked out (same rule as the password migration) | NEW API-230 `twoFactorStatus`/`twoFactorSetup` in Staffauth family | ALL (own); policy SA (web) | W3 |

## 2.20 System Settings & Front CMS (web: 19 + 7 functions)

| Web feature | Workspace treatment | Status | Data path | Roles | Wave |
|---|---|---|---|---|---|
| General/Session/Notification/SMS/Email/Payment settings; Languages; Backup/Restore; Custom & System Fields (design); Print Header Footer; Sidebar Menu; Currency setup; Front CMS (Menus, Media, Banners, Pages, Gallery, Events, News) | **Web-only.** These are server configuration, secret-bearing, template or public-website tools — infrequent, high-risk, and unsuited to a phone form. The apps must never become a second, weaker admin for them | Web-only | — | SA (web) | — |
| System status (new, read-only) | “School system” screen: current session, which modules/add-ons are active, which integrations are configured (gateway/FCM/SMS shown as **configured / not configured — never the secret**), app/API versions | Missing | NEW API-230 `systemStatus` | SA/A | W3 |
| Custom fields (consume) | Student/staff create/edit forms render the school's active custom fields | Missing | NEW API-03 `formSchema` drives API-10/API-80 forms | SA/A | W2 |
| Student Profile Update policy (consume) | Workspace shows the policy that Connect's edit screen obeys | Missing | API-230 `systemStatus` includes the policy summary | SA/A | W3 |

---

# 3. New Staffapi / Staffsync endpoint catalogue (target contracts)

These are **specifications for the API lane to build**, not claims that the endpoints exist. Rules for every endpoint: identity and scope come from the staff session (never from a client-sent staff id); the capability for the action is checked server-side; list endpoints paginate (`page`, `page_size`, `total`); money is returned as integer rupees plus formatted string; dates are `YYYY-MM-DD`; every write returns the full updated record so the app never guesses state. The API lane verifies the vendor model/table mapping on staging before the app lane builds a screen — the homework-subject gap (a planned read that was never built) must not repeat.

## 3.1 Foundation

| ID | Endpoint (POST JSON unless noted) | Request → Response shape |
|---|---|---|
| API-00 | `staffapi/capabilities` | `{}` → `{record:{staff:{…}, roles:[…], session_id, capabilities:[{module, actions:[view,add,edit,delete,…]}], scope:{type:all\|assigned, class_sections:[…]}, modules_configured:{homework:true, exams:false, …}}}` |
| API-01 | `staffapi/academicCatalog` | `{session_id?}` → `{record:{classes:[…], sections:[…], subjects:[{id,name,code}], subject_groups:[{id,name,class_id,section_id,subjects:[{subject_group_subject_id,subject_id,teacher_id?}]}], class_teachers:[…], attendance_types:[{id,type}]}}`; also `staffapi/classTimetable {class_id,section_id}` and `staffapi/teacherTimetable {staff_id?}` → `{record:{days:[{day, periods:[{time_from,time_to,subject,teacher,room}]}]}}` |
| API-02 | `staffapi/dashboardWorklist` | `{date}` → `{record:{cards:[{key,label,count,detail,route:{screen,params}}], generated_at}}` — every count must equal its list's total |
| API-03 | `staffapi/formSchema` | `{entity:student\|staff}` → `{record:{fields:[{key,label,type,required,options?}]}}` (system + active custom fields) |
| API-04 | `staffapi/fileOpen` | `{kind:receipt\|certificate\|admit_card\|marksheet\|id_card\|visitor_pass, id}` → streams the file or returns a short-lived signed URL minted for this session |
| API-05 | `staffapi/referenceData` / `staffapi/referenceSave` | `{kind:student_category\|house\|disable_reason\|department\|designation\|leave_type\|income_head\|expense_head\|content_type\|front_office_type}` → `{records:[{id,name,…}]}`; save is online-only `{kind, id?, name, …}` → updated record |

## 3.2 Students & fees

| ID | Endpoint | Request → Response shape |
|---|---|---|
| API-10 | `staffapi/studentCreate` (online-only) | full admission payload (core + guardian + class_id/section_id + custom fields per API-03) → `{record:<student detail>}`; duplicate admission number returns `{status:0}` with a plain reason |
| API-11 | `staffapi/studentStatusSave` (online-only) | `{student_id, action:disable\|enable, reason_id?, note?}` → updated student record |
| API-12 | `staffapi/studentTimeline` (+ Staffsync save/delete) | `{student_id}` → `{records:[{id,date,title,description,document?,visibility,created_by}]}`; save `{student_id, id?, title, description, date, visibility, document?}` |
| API-13 | `staffapi/studentMultiClass` (+ save, online-only) | `{student_id}` → `{records:[{student_session_id,class,section,session,is_primary}]}` |
| API-14 | `staffapi/studentIdCard` / `staffapi/staffIdCard` | `{student_id}` / `{staff_id}` → card view-model + API-04 file reference for print/share |
| API-20 | `staffapi/feeDueSearch` | `{session_id?, class_id?, section_id?, fee_group_id?, query?, due_on_or_before?, page, page_size}` → `{records:[{student_session_id, student_id, name, admission_no, class, section, total, discount, paid, balance, oldest_due_date}], summary:{students, balance}, total}` — filters applied server-side |
| API-21 | `staffapi/feeStatement` | `{student_session_id}` → `{record:{student:{…}, groups:[{name, lines:[{feetype, amount, discount, fine, paid, balance, status}]}], deposits:[{date, invoice_id, sub_invoice_id, amount, discount, fine, mode, received_by}], totals:{amount, discount, fine, paid, balance}}}` |
| API-22 | `staffapi/feePaymentSearch` | `{date_from?, date_to?, query?, invoice_no?, payment_mode?, page, page_size}` → payment rows as in API-21 deposits + `summary:{count, amount}` |
| API-23 | `staffapi/feeReceipt` | `{invoice_id, sub_invoice_id, format:screen\|pdf\|thermal}` → receipt view-model or API-04 file |
| API-24 | `staffapi/offlinePayments` / `staffapi/offlinePaymentReview` | list `{status:pending\|approved\|rejected, page}` → family submissions incl. slip file ref + fee line; review (online-only) `{id, decision:approve\|reject, reason?}` → updated record; approval posts through the same vendor fee-deposit path as `feeCollect` |
| API-25 | `staffapi/feeSetup` + `feeMasterSave`/`feeGroupSave`/`feeTypeSave`/`feeDiscountSave` (online-only) | read → masters/groups/types/discounts with usage counts; saves return the saved record + `affects_students` count |
| API-26 | `staffapi/feeAssignmentSave` (online-only) | `{kind:group\|discount, source_id, target:{type:class\|section\|students, ids:[…]}}` → `{record:{assigned, skipped, summary}}` |
| API-27 | `staffapi/feeCarryForwardPreview` / `…Apply` (online-only) | `{from_session_id, to_session_id, class_id?}` → preview rows + totals; apply repeats the same payload + `confirm:true` → job result with audit id |
| API-28 | `staffapi/feeCollectVoid` (online-only) | `{invoice_id, sub_invoice_id, reason}` → reversal record; refused if the caller lacks the supervisor capability or collected it themselves without one |
| API-29 | `staffapi/feeReminderSend` (online-only) | `{target:{…as API-20 filters}, template_id?, channel:auto\|sms\|email\|push}` → `{record:{queued, channels_used, skipped_no_contact}}` + API-61 log id |

## 3.3 Attendance, exams, learning

| ID | Endpoint | Request → Response shape |
|---|---|---|
| API-30 | `staffapi/attendanceRegister` | `{class_id, section_id, date, period?:{subject_group_subject_id, time_from}}` → `{record:{date, types:[…], students:[{student_session_id, name, roll_no, existing_type_id?, remark?, on_approved_leave}], summary}}`; Staffsync `attendance` v2 accepts `records:[{student_session_id, attendence_type_id, remark?}]` and optional period fields, same transaction-id discipline |
| API-31 | `staffapi/studentLeaveList` / `staffapi/studentLeaveReview` | list `{status, class_id?, section_id?}` → family applications; review (online-only) `{leave_id, decision, remark?}` → updated application |
| API-40 | `staffapi/examCatalog` | `{session_id?}` → `{record:{groups:[{id,name,exams:[{id,name,published,subjects:[{id,subject,date,time_from,time_to,room,max_marks,passing_marks}]}]}]}}` |
| API-41 | `staffapi/examMarksRoster` + Staffsync `examMarksSave` | roster `{exam_id, subject_id, class_id, section_id}` → students with current marks/absent; save `{exam_id, subject_id, entries:[{student_id, marks?, is_absent, remark?}], client_txn_id}` → `{saved, refused:[{student_id, reason}]}` (marks > max refused per-row, never silently clipped) |
| API-42 | `staffapi/examResult` | `{exam_id, student_id? \| class_id+section_id}` → result rows (subjects, total, grade, division, rank, published flag) |
| API-43 | `staffapi/examSave` family + `examPublish` + `examRankGenerate` (online-only) | typed saves for group/exam/subject/grade/division; publish `{exam_id, publish:true\|false}` → affected count; rank → job result |
| API-44 | `staffapi/examDocument` | `{type:admit_card\|marksheet, exam_id, student_id? \| class_id+section_id}` → API-04 file |
| API-45 | CBSE family: `staffapi/cbseCatalog`, `cbseMarksRoster`, Staffsync `cbseMarksSave`, `cbseObservations`, `cbseDocument` | Mirrors the add-on's terms/assessments/observations model; shapes fixed by the API lane from the add-on's own controllers on staging |
| API-51 | `staffapi/homeworkList` / `homeworkDetail`; Staffsync `homeworkUpdate`/`homeworkDelete` | list `{class_id?, section_id?, date_from?, date_to?, mine:true}` → homework rows incl. submission counts; detail adds description + attachment ref |
| API-52 | `staffapi/homeworkSubmissions` + Staffsync `homeworkEvaluate` | `{homework_id}` → `[{student, submitted_at, message, file ref, marks?, note?}]`; evaluate `{submission_id, marks, note}` |
| API-53 | `staffapi/dailyAssignments` (+ save/delete) | `{class_id, section_id, date}` → assignment rows |
| API-54 | `staffapi/lessonPlans`, `syllabusStatus`, `syllabusManage`, `syllabusComments`, `lessonCopy` | plan `{staff_id?, class_id, section_id, subject_group_subject_id, week}` → lessons/topics with completion; status update via Staffsync `{topic_id, complete}`; manage/copy online-only |

## 3.4 Communication, front office, HR, finance

| ID | Endpoint | Request → Response shape |
|---|---|---|
| API-60 | `staffapi/noticeList` / `noticeDetail`; Staffsync `noticeUpdate`/`noticeDelete` | list `{mine?, audience?, page}` → notices incl. publish state; update carries `version` so two editors cannot silently overwrite each other |
| API-61 | `staffapi/messageSend` (online-only), `messageLog`, `scheduledMessages` (+ save/cancel) | send `{channel:email\|sms\|push, target:{…}, subject?, body, template_id?, send_at?}` → `{job_id, accepted, per_channel_status}`; log rows carry recipient, channel, status, time |
| API-62 | `staffapi/messageTemplates` (+ save) | `{channel}` → templates; save online-only |
| API-63 | `staffapi/credentialSend` (online-only) | `{user_type:student\|parent\|staff, id, channel}` → `{sent:true, channel}` — **no credential value is ever returned**; every call is audit-logged |
| API-66 | `staffapi/calendarEvents` / `staffapi/myTasks` CRUD | events `{date_from, date_to}` → school events + holidays; tasks are the signed-in staff member's own (create/update/delete in Staffsync) |
| API-70 | `staffapi/enquiryList`/`enquiryDetail`/`enquirySave`, `enquiryFollowUps` (+ save) | enquiry rows carry status, source, class sought, next follow-up date; follow-up save in Staffsync so the desk works offline |
| API-71 | Staffsync `visitorCheckIn`/`visitorCheckOut` + `staffapi/visitorList` | check-in `{name, phone, purpose, meet_staff_id?/meet_student_id?, note?}` → visitor record + pass ref; list `{date}` |
| API-72 | `staffapi/callLogList`/`callLogSave`, `postalList`/`postalSave`, `complaintList`/`complaintSave`/`complaintStatusSave` | register rows with type-specific fields; complaint status save is online-only when assigning/closing |
| API-80 | `staffapi/staffDirectory`/`staffDetail`/`staffSave`/`staffStatusSave`/`staffPhoto` | directory `{query?, department_id?, designation_id?, role?, page}` → staff rows; detail adds contact/role/joining; saves online-only |
| API-81 | `staffapi/staffAttendance` + Staffsync save; `staffapi/myAttendance`; Staffsync `staffQrCheckIn` | `{date, department_id?}` → staff rows with existing types; my view `{month}` → day states |
| API-82 | `staffapi/myLeaves` + Staffsync `myLeaveApply`; `staffapi/staffLeaveApprovals` + `staffLeaveReview` (online-only) | my view → balances by type + applications; apply `{leave_type_id, from_date, to_date, reason, document?}`; review `{leave_id, decision, remark?}` with self-approval refused server-side |
| API-83 | `staffapi/payrollList`/`payrollDetail`/`myPayslips` | `{month}` → payroll rows (gross, deductions, net); detail adds components; amounts integer rupees |
| API-84 | `staffapi/staffTimeline` (+ save), `staffapi/teacherRatings` | timeline as API-12 for staff; ratings `{staff_id}` → average + comment rows + moderation state |
| API-90 | Online exams: `staffapi/onlineExamList`/`onlineExamSave`/`questionBank`/`onlineExamAssign`/`onlineExamResults` | list → exams with class, window, attempts; save online-only; results `{online_exam_id}` → per-student attempt/score/status |
| API-95 | `staffapi/financeSummary`, `incomeList`, `expenseList`, Staffsync `incomeSave`/`expenseSave`, online deletes | lists `{date_from?, date_to?, head_id?, query?, page}` → rows + totals; save `{head_id, amount, date, name, note?, invoice_no?, photo?}` |

## 3.5 Operations, content, reports, system

| ID | Endpoint | Request → Response shape |
|---|---|---|
| API-100 | Library: `staffapi/libraryCatalog`, `bookSave`, `libraryCirculation`, Staffsync `libraryIssue`/`libraryReturn`, `libraryMemberSave` | catalogue `{query?, available_only?}` → books with copies/issued; circulation `{member_type, member_id}` or `{book_id}` → open issues; issue `{book_id, member_type, member_id, due_date}` |
| API-110 | Inventory: `staffapi/inventoryStock`, Staffsync `stockAdd`/`inventoryIssue`/`inventoryReturn`, setup saves | stock `{store_id?, category_id?, query?}` → items with quantity; issue `{item_id, quantity, to_type, to_id, note?}` |
| API-120 | Transport: `staffapi/transportOverview`, `studentTransport` (+ saves) | overview → routes/vehicles/drivers/counts; per-student → assignment + transport fee rows |
| API-130 | Hostel: `staffapi/hostelOverview`, `hostelAssign` | overview → hostels/room types/rooms with occupancy; assign online-only |
| API-140 | Content: `staffapi/contentList`, `contentUpload` (multipart), `contentShares`, `contentDelete`, `videoTutorials` (+ save) | content rows carry type, audience, validity, file ref (API-04); upload mirrors the proven photo-upload discipline (size/type checked server-side) |
| API-150 | Certificates: `staffapi/certificateList`, `certificateGenerate` | `{student_id}` → available certificates; generate → API-04 file |
| API-170 | Behaviour: `staffapi/behaviourCatalog`, Staffsync `behaviourAssign`, `staffapi/studentBehaviour` | catalogue → incident types with points; assign `{student_id, incident_id, date, note?}`; record → points total + incident rows + comments |
| API-180 | `staffapi/onlineAdmissions` (+ review/convert), `alumniList`/`alumniSave`/`alumniEvents` | admission rows carry status + documents checklist; convert returns the created student id or a duplicate warning |
| API-200 | Courses: `staffapi/courseManage` family | my courses → course with sections/lessons/enrolments; saves online-only; assignment marking via Staffsync |
| API-210 | Live classes: `staffapi/liveClasses`, `liveClassSave` | `{provider:zoom\|gmeet, class_id, section_id, topic, starts_at}` → meeting with join/start links as the provider returns them |
| API-220 | Reports: `staffapi/reportCatalog`, `reportRun`, `reportExport` | catalog → reports the capability map allows, each with its filter schema; run `{report_key, filters}` → `{columns:[…], rows:[…], totals:{…}}`; export → API-04 file (PDF/CSV) |
| API-230 | `staffapi/systemStatus`; Staffauth family `twoFactorStatus`/`twoFactorSetup` | status → `{session, modules:{…active}, integrations:{gateway:bool, fcm:bool, sms:bool, email:bool}, versions}` — booleans only, never secrets; 2FA setup returns a secret **once, to the owner of the account only**, with recovery codes and a no-lockout grace path |
| API-240 | Multi-branch: `staffapi/branchOverview` | `{branch_id?}` → cross-branch summaries; every other endpoint gains an explicit branch context from the session, never a free client parameter |

---

# 4. CONNECT FEATURE MATRIX — what remains after v2.5 (+ Student Card v2.6, rename v2.7)

Connect's base is **Have** and is not re-planned here: sign-in (student + parent), child switching, Home, attendance, fees view with the honest Paid/Discount/Balance split, timetable, homework (view/hand-in/evaluation), daily assignments, leave CRUD, notices + attachments, downloads + saved-on-phone files, events/calendar + task reading, my subjects, library (issued + catalogue), transport, exams + results, online-exam attempt + result, syllabus status, lesson plan + forum, teachers + one-time rating, profile (documents, school-gated edit), timeline, bank-payment reporting, forgot password, share, Student Card.

**Verification debt (applies to the whole “Have” column):** Wave B's writes were built against the byte-identical backend copy and staging-probed for clean 401s, but **no staging family test account exists**, so the first live write proof (one homework hand-in, one leave application) is still outstanding. Wave 0 creates that fixture; the Checker re-marks any feature that fails live proof as Partial until it passes. Nothing in this section is “done” on code alone.

| # | Remaining item | Status today | What it takes | Dependency type |
|---|---|---|---|---|
| C-1 | **Visual repair**: giant Student Card preview on Home; “Attendance” nav label wraps mid-word; sparse oversized More tiles | **Defect in current build** | Wave 0 design repair under §5 rules + Checker founding tests (§6.4) | App only |
| C-2 | Behaviour records (incidents, points, comments) | Missing — endpoints exist (`getstudentbehaviour`, comments family) | One screen + comments, following ClassDojo's visibility rule (§5): family sees what the school shares, points always with their reason | App only; visible data depends on the Behaviour add-on being used |
| C-3 | Visitor records for my child + register a visitor | Missing — endpoints exist (`getVisitors`, `addvisitor`) | Small list + add form inside Profile/visits | App only |
| C-4 | Video tutorials | Missing — endpoint exists (`getVideoTutorial`) | List inside Downloads/Learn area; opens the video externally or in the system player (no WebView) | App only; needs class/section resolution like the timetable |
| C-5 | Personal tasks — write side (add/edit/delete/mark done) | Partial — tasks are read in Events; writes unverified | Verify the `addTask`/`updatetask`/`deletetask` shapes on the staging family fixture, then enable the compose/edit UI | App + staging verification |
| C-6 | Online-exam descriptive attachments | Partial — text answers only | Add the `attachment_<qid>` file parts to the existing attempt hand-in | App only |
| C-7 | Daily-assignment edit; homework re-submit after evaluation | Partial — deliberately not built in v2.5 | Small additions on existing screens (endpoint support exists) | App only |
| C-8 | Official report-card / receipt PDF | Partial — results and receipts render in-app; the web's official PDF is a web route, not an API | API decision: expose an authorised family-side document read (same API-04 pattern, family session) or accept the in-app rendering as the record | API + web-overhaul coordination |
| C-9 | CBSE result variant | Missing — endpoints exist (`cbseexamresult`, `cbseexamtimetable`) | CBSE result/schedule screens | **School setup:** CBSE add-on active + CBSE exams configured. ⚠ The vendor `cbseexamresult` currently answers **without any authentication** (audit finding) — Connect must not ship a screen on it until the overhaul's Wave 1 fixes that endpoint |
| C-10 | Push notifications (FCM) | Missing | Firebase project + Android app registered for `pk.edu.iqrs.family` + FCM server key in the web notification settings; then app token work (login already carries the token field) | **School setup (Wave C)** |
| C-11 | Online fee payment | Partial — fees view + bank-payment reporting exist; checkout missing | Gateway activated in web Payment Settings with the school's merchant account (JazzCash/Stripe/PayFast controllers ship with the system); app: fee selection → `fees_pay` → hosted checkout in the **browser/Custom Tab (never a WebView)** → re-read fees | **School setup (Wave C)** |
| C-12 | Live classes (Zoom/Gmeet) | Missing | Add-ons installed/activated + school's Zoom/Google credentials + teachers scheduling classes; app: list + join hand-off | **School setup (Wave C)** |
| C-13 | Online Course | Missing — XL | Add-on active + courses published; then a dedicated course milestone (catalogue, lessons, quizzes, assignments, progress, reviews, certificates) | **School setup (Wave C)** + own milestone |
| C-14 | Urdu language + RTL | Missing — XL | Human-reviewed Urdu strings (not the legacy app's runtime machine translation), full RTL layout pass, per-student language saved via `updatestudentlanguage` | App milestone; no school setup |
| C-15 | Change password (real) | Missing — the legacy item was a “coming soon” façade; no backend endpoint exists | Net-new additive endpoint in the staff-extension style (family session, current-password check, hashed storage per the overhaul migration) + app screen. Forgot password (shipped) remains the interim path | API decision + web-overhaul Wave 1 coordination |
| C-16 | Chat with teachers | **Not a parity item** — it does not exist in the legacy app or the backend routes (proven from source) | Only as a net-new product with safeguarding, logging and moderation decided first (same decision as Workspace §2.5) | Owner decision only |
| C-17 | Rate the app | Deferred — there is no store listing to rate yet | Add the row when the Play listing exists (store milestone) | Store stage |
| C-18 | Hostel details; multi-currency | Skip — no evidence IQRS uses hostel; the school is single-currency | Revisit only if the school's facts change | — |
| C-19 | Subject-wise attendance | **Not available** — no endpoint exists in the backend and the legacy app does not have it (proven from source) | Would need a backend data model first; not promised | — |

---

# 5. International case studies → concrete design rules

Calm Campus (`design-system-v2.md`) remains the visual identity. This section adds the **checkable** rules the case studies imply. Every rule has an ID; the Checker (§6) tests rule IDs, not taste.

## 5.1 What the leading products teach

- **PowerSchool Mobile** puts one account over all children and a dashboard that combines class overview, assignments due/graded, attendance, bulletins and fees, with a Classes view carrying schedule, teacher, grades and absences. Lesson: a family Home is a **child-scoped progress brief**, not a module catalogue; a staff search should open the same kind of unified student brief. ([PowerSchool Mobile](https://www.powerschool.com/solutions/communication/powerschool-mobile/), [Parent & Student Resource Center](https://www.powerschool.com/community-support/parent-student-resource-center/))
- **Seesaw** connects portfolios, activities, feedback and family communication in one flow: families see real work, teachers approve work before it reaches the family journal, and messages sit next to the learning they are about. Lesson: homework and timeline features must carry **evidence + review state** (handed in → seen → checked), not just text rows. ([Seesaw — research-based practices](https://seesaw.com/blog/research-based-best-teaching-practices/))
- **ClassDojo** makes behaviour points visible to families **at the sharing level the teacher/school chooses**, keeps two-way messages logged and school-visible, and gates portfolio posts behind teacher approval. Lesson: behaviour UI shows points **with their reason**, never a public rank or a shaming wall; any future messaging is logged and governed, or it does not ship. ([ClassDojo for instructional leaders](https://www.classDojo.com/districts/roles/instructional/))
- **Toddle** runs one connected cycle — planning, assessment, gradebook and reporting flow into each other — and attendance flexibly (daily, period or rotation), with one family app for portfolios, grades, reports, deadlines and announcements. Lesson: **enter data once, use it everywhere** (marks entry feeds result and report; a period register is the same register with a period, not a second system). ([Toddle](https://www.toddleapp.com/independent-schools/), [Toddle FAQ](https://www.toddleapp.com/faqs/))
- **Revolut** holds a very broad product suite without a cluttered Home: everyday banking stays prominent, advanced areas are progressively disclosed in product cards, and important controls are surfaced rather than buried in settings. Lesson for Workspace: Home = today's work; the full module catalogue lives in a grouped More; setup tools appear only inside their module. ([Fintech design guide — Revolut analysis](https://www.saasfactor.co/blogs/fintech-mobile-app-design), [Banking app design guide](https://gapsystudio.com/blog/banking-app-design/))
- **Wise** shows the exact fee, rate and arrival time **before** commitment and then tracks the transfer stage by stage. Lesson: every money/approval form in both apps ends with a **complete review step** (student, fee line, amount, discount, fine, method, total, date) and a truthful status afterwards (recorded → sent → confirmed). ([Fintech design guide — Wise analysis](https://www.saasfactor.co/blogs/fintech-mobile-app-design))
- **NayaPay (Pakistan)** puts school-fee payment among everyday services and gives the user a usable card immediately, with card controls inside the app — but its feature-rich Home is also a cautionary example of density. Lesson: our Student Card must be a **working credential** (real QR/barcode, gate-ready), and local payment language (bank transfer reporting, JazzCash-era expectations) matters — while Home stays calm. ([NayaPay on Google Play](https://play.google.com/store/apps/details?id=com.nayapay.app&hl=en_US&gl=US))
- **Material 3** navigation bars carry **3–5 destinations**, each with an icon **and** a label; labels are short (1–2 words). **Apple's HIG** says the same for tab bars: symbol + short text label for every tab, tabs are for navigation between sections, and state is preserved when switching. ([Material 3 — Navigation bar](https://m3.material.io/components/navigation-bar/overview), [Apple HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars))
- **Android screenshot testing** exists precisely because behaviour tests cannot see pixels: a screenshot test compares a render with a previously **approved** reference and produces a diff for human judgement — a failed diff means “look”, not automatically “bug”. Our Checker protocol (§6) adopts exactly that discipline. (Android Developers — *Screenshot testing*.)

## 5.2 Navigation rules (NAV)

- **NAV-1.** Bottom navigation has **4 destinations in Connect** (Home · Attendance · Fees · More) and **at most 5 in Workspace**. Workspace keeps three fixed anchors — position 1 **Home**, middle **Scan**, last **More** — and the two work slots are role-shaped at sign-in from the capability map (Teacher: Classes · Homework; Accountant: Students · Fees; Admin/Super Admin: Classes · Tasks; Receptionist: Office · Tasks; Librarian: Library · Tasks). Destinations never change while signed in.
- **NAV-2.** Every label is **one line, fully visible, never wrapped, never ellipsised, never shrunk below 10sp**. Implementation rule: the label is measured before render; if the measured label + icon do not fit the slot at 360dp and font scale 1.3, the **layout changes** (icon above label) or the **label is renamed shorter** — the text is never allowed to break. “Attendance” is the standing test case.
- **NAV-3.** Item layout is **icon above label** (the M3 default anatomy) in both apps. The current side-by-side icon+label pill is retired: it is what squeezed “Attendance”.
- **NAV-4.** Nav height budget: **64dp ± 2dp** including its floating margins treatment; content scrolls behind/above it with the design system's clearance; the nav never overlaps a sticky action bar — the two stack with an 8dp gap.
- **NAV-5.** Tabs are destinations, not actions (HIG). The only exception is Scan, which is a true destination screen in Workspace. Create actions live as a labelled button/FAB inside their list screen.
- **NAV-6.** Switching tabs preserves each tab's scroll and filter state; re-tapping the active tab returns it to its top/root.
- **NAV-7.** Badges are counts of **work waiting** (approvals, unread notices), never decoration; a badge count must reconcile with the list behind it.

## 5.3 Home composition rules (HOME)

- **HOME-1.** First viewport order is fixed: greeting/identity → **today** (classes/worklist) → primary money or learning signal → quick actions. Nothing decorative precedes data (design principle 1, now testable: the first actionable card must start within the first 45% of the viewport height at 360×640dp).
- **HOME-2.** Every Home card declares a **height budget in its spec** before it is built. No card may size itself from an unconstrained child. A card with no data renders its compact state (≤ 96dp) — it never keeps the populated height as empty surface.
- **HOME-3.** The Student Card on Home is a **wallet strip**, not the card: fixed height **84dp**, photo/initials, name, class, admission number, mini-QR. The full card renders only on the card screen, where **height = width × 54 ÷ 85.6 (±2dp)** — true CR80 proportions in every host, including the Workspace student detail (there it is collapsible, default collapsed to the same strip).
- **HOME-4.** A Home shows **at most three large cards** before the fold pattern repeats as list rows; the rest of the modules live in More's grouped grid.
- **HOME-5.** More-grid tiles are content-sized: **88–104dp** tall, icon + label (+ optional count), no dead vertical space; groups are headed (Today's work / Money / Learning / Office / Records / Setup) so a 30-module catalogue stays scannable (Revolut's progressive disclosure, §5.1).
- **HOME-6.** Counts on cards are **links, not claims**: tapping any number opens the exact list that produced it, and the list's total equals the number (the web dashboard's miscounting tile is the anti-example).

## 5.4 Card rules (CARD)

- **CARD-1.** One card = one object or one job: title, one primary datum in display type, one line of context, at most one action. Anything else is a list or a detail screen.
- **CARD-2.** Money cards always separate **Amount · Discount · Paid · Balance** (the school's discount history makes this a trust rule, not a style choice); a discount is never coloured or worded as a payment.
- **CARD-3.** Before any money or approval is committed, a **review sheet** shows every component (Wise rule): who, what for, amount, discount, fine, method, total, date. The primary button repeats the total (“Collect Rs 1,700”).
- **CARD-4.** A status is always a **word** (Paid, Due, Recorded, Waiting to send, Approved) with its colour — never colour alone, never a code, never a developer term (language lockdown, design-system §6.3, unchanged).
- **CARD-5.** ID/QR cards: QR and barcode render only from the real payload (`IQRS-<student_id>`, admission number), keep their quiet zones, and are decode-tested in the Checker pass; no placeholder codes, ever.
- **CARD-6.** Photo-bearing cards fall back to initials on a stable tint; a missing photo never changes the card's height or layout.

## 5.5 List and form rules (LIST / FORM)

- **LIST-1.** Rows are 64dp (72dp with subtitle) with the design system's anatomy; sorting is **natural/numeric** (roll 1, 2, 10 — the web register's string sort is a named defect, never to be copied).
- **LIST-2.** Filters the user set **stay set** when results render and when they return from a detail (the web's section-reset bug is the anti-example); a filter summary line states the active filters in words.
- **LIST-3.** Every list declares its states before build: loading (6 skeleton rows), populated, empty, no-results-for-search (query echoed + Clear), not-configured, offline-cached (with the quiet “Last updated” caption), error-with-retry. Pull-to-refresh everywhere.
- **LIST-4.** Bulk lists (registers, marks entry) keep a **sticky summary + save bar**; totals update live and must reconcile before Save enables.
- **FORM-1.** Labels are always visible above fields — placeholders are examples, never labels. Required fields are marked; pickers are fed by server catalogues (API-01/API-05), never free-typed where reference data exists.
- **FORM-2.** Errors appear **under the field**, in plain words, and a failed save **preserves all input** (both apps already do this; it is now a rule, not a habit). The server's plain refusal is shown as-is.
- **FORM-3.** One primary action per screen, sticky at the bottom on long forms; long office forms autosave a local draft. Double-tap cannot double-submit: the button disables and money writes carry their transaction id.
- **FORM-4.** Destructive or school-wide actions (void, publish, disable, delete) are online-only, confirmed with a summary of effect (“This will unpublish results for 214 students”), and audit-logged.
- **FORM-5.** At 135% system font size and font scale 1.3, no amount, name or label truncates: rows grow, figures never shrink below 15sp (carried from design-system §5.3, now Checker-tested).

## 5.6 Empty-state rules (EMPTY)

- **EMPTY-1.** Five distinct states, five distinct designs: **loading** (skeleton in the final layout's bounds), **truly empty** (nothing exists yet), **not configured** (the school has not set this up), **no results** (a search/filter matched nothing), **unavailable to your role** (permission). One generic blank is a defect.
- **EMPTY-2.** Anatomy and budget: spot icon ≤ 48dp, headline ≤ 2 lines, guidance ≤ 3 lines, at most one action; total block **96–160dp inline** or ≤ 320dp as a full-screen state. **No empty surface may exceed 160dp without content** — the giant navy card preview is the founding violation.
- **EMPTY-3.** Copy says what is true and what happens next: “Homework needs subjects, and the school office has not set them up yet.” — never “No data found”, never an error voice for a setup fact.
- **EMPTY-4.** Not-configured states name the **owner of the fix** (school office / system settings) and carry no dead button; when the configuration appears, the same screen lights up with no app update (API-00 `modules_configured` drives this).
- **EMPTY-5.** Empty is per-card, never per-screen, on Home: one module's emptiness degrades its own card only (per-card failure isolation, design-system §F2).

---

# 6. THE CHECKER PROTOCOL — independent verification for every wave

## 6.1 The role

The **Checker** is a named team member who **did not build the wave being checked**. The Checker receives: the APK(s) with SHA-256, the source-tree state, the staging endpoint build (file + size + hash) the APK was tested against, the test fixtures/accounts used, and this plan. The Checker — and only the Checker — marks a wave **PASS** (fit to send to the owner) or **REJECT** (returned with defects). Builders cannot approve their own goldens; an intentional visual change is approved by the Designer + Checker together, and the golden is replaced only then.

## 6.2 The five gates (all must pass)

| Gate | What is checked | Evidence |
|---|---|---|
| **G1 Contract** | Every new/changed endpoint on **staging**: happy path, refusal path, wrong-role path, foreign-record path (a teacher requesting another class's data must be refused), malformed input. Response fixtures diffed against §3 shapes | Staging test log with request/response pairs per endpoint |
| **G2 Logic** | The existing JVM suite (all green) + new tests for the wave's payload builders, mappers, reconciliation arithmetic (fee split, marks totals, dashboard counts) | Test run output, count stated |
| **G3 Visual** | The layout-budget assertions (§6.3) + screenshot checklist (§6.4) on the device matrix (§6.5) | Screenshot set + assertion log, per screen PASS/FAIL |
| **G4 Language & metadata** | Banned-strings lint, package/version/permissions gate, apksigner verify, app-name lint (no retired names) | Gate outputs |
| **G5 Data truth** | On staging fixtures: every Home/worklist count equals its list total; a fee statement's Paid/Discount/Balance equals a hand-computed fixture; marks totals equal the roster sum; the due-fees class filter returns only that class (the web bug, §1.5) | Reconciliation sheet signed by the Checker |

A wave with any **S0/S1** defect (§6.6) is rejected outright. S2 defects may pass only if the Checker records them as accepted debt with a fix wave named.

## 6.3 Layout-budget assertions (automated, run at 360dp first)

The tree is Gradle-free native Views, so the harness is: host-side budget unit tests for pure layout decisions (the pattern `MottoFit` already proves) **plus** instrumented/device captures read through the view hierarchy (UI Automator dump bounds) and screenshot comparison against approved goldens. Every screen's spec must name its measurable budgets; the standing budgets are:

| ID | Assertion | Pass criterion |
|---|---|---|
| LAY-NAV-1 | Bottom nav geometry | Height 64dp ± 2dp; item slots equal width ± 1dp; nav bottom inset respected at 360×640 and 360×800 |
| LAY-NAV-2 | Nav labels | For every destination, active and inactive: label is **one line** (`lineCount == 1`), its measured text width ≤ slot content width at font scale 1.0 **and** 1.3, label bounds height ≤ 1.15 × line height, and the screenshot shows the complete word |
| LAY-CARD-1 | Student Card aspect | On the card screen and in Workspace detail: `|height − width × 54/85.6| ≤ 2dp` |
| LAY-CARD-2 | Home wallet strip | Height exactly 84dp ± 2dp in populated, no-photo and no-class-data states |
| LAY-EMPTY-1 | No unbounded emptiness | No background-only region taller than **160dp** exists on any Home/list/detail render in any state (loading skeletons excepted — they must match the final layout's bounds) |
| LAY-TEXT-1 | No clipping/overlap | Every visible text view's bounds sit inside its parent; no two text bounds overlap; long-name fixture (40 characters) and longest class name render without mid-word breaks |
| LAY-TARGET-1 | Touch targets | All interactive bounds ≥ 48×48dp (register segments ≥ 44×44dp, the design system's stated exception) |
| LAY-FONT-1 | Font scale | At font scale 1.3: no amount, name, nav label or button label truncates; screens scroll instead of squeezing |
| LAY-DARK-1 | Dark mode | Same assertions in night mode; gold is never text on white; semantic colours keep their word labels |
| LAY-RTL-1 | RTL readiness | Layouts use start/end consistently (checked by hierarchy inspection); full RTL pass is a C-14 milestone gate |

**LAY-NAV-2 scope (amended 2026-11-07).** The font-scale-1.3 arm of LAY-NAV-2 is asserted at **360dp and wider**; at **320dp** the assertion runs at font scale **1.0** only. The 320dp × 1.3 corner is a documented known limitation, not a gated combination — see the §6.5 amendment below.

## 6.4 Screenshot checklist — per screen, pass/fail

For **each** screen in the wave, the Checker captures and judges these states at 360dp (states that cannot occur are marked N/A with a reason):

| # | State / shot | Pass criteria |
|---|---|---|
| 1 | Populated (rich fixture) | Hierarchy reads in 3 seconds: title → primary datum → action. No card exceeds its budget. Real-looking data (never lorem, never a developer string) |
| 2 | Loading | Skeleton matches the final layout's shape; no blank flash, no full-screen spinner (sign-in and camera start excepted) |
| 3 | Empty (true) | EMPTY-1/2/3 anatomy and copy; block ≤ 160dp inline |
| 4 | Not configured | Names the setup owner; no dead button; no error voice |
| 5 | No search results | Query echoed, Clear action, filters intact (LIST-2) |
| 6 | Offline with cache | Cached data + quiet “Last updated” caption only where the design system allows; **no status pill, no banner, no domain text** |
| 7 | Error without cache | The approved error copy + Retry; nothing raw (no codes, no stack words) |
| 8 | Long content | Longest names/titles wrap by word or ellipsise at line end — **never mid-word**; amounts never truncate |
| 9 | Form with an error | Error under the field, input preserved, primary action reachable above the keyboard |
| 10 | Review/confirm step (money & approvals) | CARD-3 completeness: every component visible before the commit button, which repeats the total |
| 11 | Success | Confirmation states what happened in plain words + the reference (receipt no., count saved) |
| 12 | Role-denied | The module is absent from nav/More for that role; a deep link explains plainly that it is not available for their role |

**Archetype additions:** *Scanner* — frame guide visible, torch reachable, result card readable at arm's length, duplicate state in amber words. *Register/marks grid* — sticky summary visible while scrolling, segment labels are words/symbols with text equivalents, totals reconcile on screen. *Card screen* — QR decodes with a stock scanner app, barcode scans, flip keeps the same bounds (LAY-CARD-1 in both orientations of the flip).

## 6.5 Device matrix

Baseline **360×640dp @ font 1.0** (the owner's class of device) → **360×800** → **320dp narrow** → **411dp wide**; font scales **1.0 and 1.3**; light + dark; at least one real-device pass on the owner's phone model class before the wave is called device-verified. Emulator/harness passes are reported as harness passes — the report never upgrades them into “works on the phone”.

**Amendment — guaranteed width × font combinations (owner decision, 2026-11-07).** The bottom-nav label guarantee (NAV-2, tested by LAY-NAV-2) holds, and is Checker-gated, for exactly these combinations: **360dp and wider at font scales 1.0 and 1.3**, and **320dp at font scale 1.0**. The remaining matrix corner, **320dp × font scale 1.3**, is a **documented known limitation — not a defect and not a design target**. The physical reason: under NAV-3's equal slots, a 320dp nav leaves a ≈69dp slot per label, while the standing test word “Attendance” measures 75.5dp at the NAV-2 floor of 10sp in the bundled typeface at scale 1.3 — an ≈6.5dp overflow that no layout honouring both equal slots and the 10sp floor can absorb. The Wave 0 Checker measured this corner directly (CHECKER-REPORT-wave0.md, finding F1; confirmed in CHECKER-REPORT-wave0-reentry.md, which records it as an S2 debt outside the §6.5 baseline), and on **2026-11-07 the owner decided** the guarantee stays at the 360dp baseline rather than commissioning a narrow-width nav variant. The corner may be revisited only on a new owner decision.

## 6.6 Defect severity and the sign-off artefact

- **S0 Blocker:** money/attendance wrong, data loss, a role seeing another role's/family's data, a crash on a primary journey. **S1 Major:** a founding-test failure (§6.7), a broken state (blank/unbounded/clipped), a count that does not reconcile. **S2 Minor:** spacing/copy polish that does not mislead.
- The Checker files **`CHECKER-REPORT-<wave>.md`** next to the build report: APK hashes, endpoint build hashes, fixture accounts (ids only), gate-by-gate results, the screenshot set location, defects with severity, and the explicit **PASS / REJECT** line. The parent agent sends the owner the APK only with this report present.
- **Golden discipline:** goldens live with the tree; a diff is a question, not a failure (per Android's screenshot-testing doctrine, §5.1) — but an *unreviewed* diff blocks delivery exactly like a failure.

## 6.7 Founding regression tests (permanent)

These two defects, caught by the owner on 2026-11-07, are the protocol's founding examples and run on **every** future build of both apps:

1. **REG-NAV-ATTENDANCE** — Connect, 360dp, font 1.0 and 1.3, light and dark: the **“Attendance”** bottom-nav label renders as one complete word on one line, active and inactive. (Failed in the wild as “Attendanc / e” because the side-by-side nav item squeezed the label and wrapping was allowed.)
2. **REG-HOME-CARD** — Connect Home with a real child record, with no photo, and Workspace student detail: the Student Card preview is the bounded wallet strip (84dp) and the full card keeps CR80 proportions; **no mostly-empty card surface** may render in any data state. (Failed in the wild as a full-height navy rectangle carrying only an avatar and a QR.)

A third standing check joins them from the same week's history: **REG-DIALOG-TEXT** — every confirmation dialog's text is readable against its background in both modes (the blank sign-out dialog of 2026-11-07).

---

# 7. Team, build order and approvals

## 7.1 The team

| Role | Owns | Never does |
|---|---|---|
| **Planner** (this role, continuing) | This plan, wave scopes, endpoint contracts (§3), acceptance criteria; keeps the matrices truthful as waves land | Build the waves it scopes |
| **Designer** | Calm Campus screen specs per wave: budgets for every card/list/form **before** build, goldens, copy (language lockdown) | Approve a build |
| **API lane** | New Staffapi/Staffsync endpoints: staging build → contract proof (G1 evidence) → deploy notes with exact file/size/hash | Touch production without the owner's per-change approval |
| **Workspace builder** | Workspace app waves in the shared tree | Check own work |
| **Connect builder** | Connect app waves in the shared tree | Check own work |
| **Shared-components builder** | BottomNav, cards, lists, forms, empty states used by both apps (one fix lands in both) | — |
| **Checker** | §6 protocol, staging fixtures, reconciliation, sign-off/rejection | Build any part of the wave under check |
| **School-data coordinator** | Staging fixtures (one account per staff role + a family account with two children), subject/exam staging data, and the school-setup decisions (D1/D2 subjects & exams, gateway, Firebase, add-ons) prepared for the owner | Invent school data on production |
| **Release coordinator** (parent agent) | File Manager/server uploads strictly from the API lane's manifests (backup → upload → size-verify, the proven pattern), owner communications | Change scope |

## 7.2 Build order (dependencies first)

| Step | Contents | Depends on | Owner touchpoint |
|---|---|---|---|
| **Wave 0 — rails & repair** | Checker harness + founding tests (§6.7); BottomNav redesign (NAV-3); wallet strip (HOME-3); More-tile budgets (HOME-5); staging fixtures (all staff roles + family); capability map API-00 + academic catalogue API-01 **on staging**; Connect Wave B live-write proof on the staging family account | Plan approval | **Approval 1: this plan** |
| **Wave 1A — API (staging)** | API-02 worklist, API-30 register, API-31 student leave, API-20/21/22/23/24 fees desk, API-60 notices, API-80 directory (read), API-82 leave (mine + approvals), API-66 calendar/tasks, API-70/71/72 front-desk core, homework unblock (API-01 subjects + API-51/52) | Wave 0 contracts | — (staging only) |
| **Wave 1B — Workspace app** | Role-shaped Home + nav, complete register, fees desk, approvals, notices, directory, my leave/timetable, front-desk core, homework list/submissions | 1A staging PASS (G1) | Device check on the owner's phone |
| **Wave 1C — production endpoints** | The proven 1A endpoint files move to production **one file at a time** | 1B + Checker PASS | **Approval per production file swap** (Staffapi.php, Staffsync.php separately), each with staging evidence |
| **Wave 2 — depth** | Exams + marks (API-40–44), lesson plan/syllabus (API-54), library (API-100), income/expenses (API-95), fee setup (API-25/26), reports (API-220), behaviour (API-170), ID/certificate files (API-14/150), content (API-140), transport/inventory ops (API-120/110), HR depth (API-80 saves, 81 marking, 83 payroll view, 84), online-exam authoring (API-90), Connect C-2/C-3/C-4/C-5/C-6/C-7 | Wave 1 pattern proven; exam/subject staging data | Per-file production approvals; D1/D2 school-data decisions land as prepared proposals |
| **Wave 3 — specialist** | CBSE (API-45), courses (API-200), live classes (API-210), hostel (API-130), alumni/admissions (API-180), multi-branch (API-240), system status + 2FA (API-230), carry-forward (API-27), quick fees, thermal print, Connect Wave C (C-10–C-14) as school setups complete | Add-ons/gateway/Firebase decisions | Owner decision per school-setup item |
| **Store stage** | Production signing + Play publication (existing M5 track; package-id decision still open there) | Device-verified waves | Owner custodies the keystore password, as already agreed |

## 7.3 Approval discipline (kept minimal, kept real)

1. **One plan approval** (now) covers all staging work and all app builds in Waves 0–2.
2. **Production server changes:** the owner's approval is asked **per file swap**, with the exact file, size, hash and staging Checker evidence in the request — the pattern already in use for Staffapi.php. Nothing reaches production on a staging approval.
3. **School-setup decisions** (subjects list, exam structure, gateway merchant account, Firebase project, add-on purchases/activation) are brought as prepared proposals when their wave arrives — never as mid-build surprises, and never allowed to block unrelated waves.
4. **Sensitive capabilities** (payroll display, credential sending, fee void, 2FA) get one explicit owner confirmation before their build starts, because they change what the app *can do to people*, not just what it shows.
5. Everything else — staging endpoints, app screens, checker rejections and rebuilds — proceeds without asking, and is reported as results.

---

*End of plan. Companion evidence: `Smart_School_7.2_Roles_and_Features.md`, `FAMILY-PARITY-PLAN.md`, `LEGACY-SOURCE-FINDINGS.md`, `design-system-v2.md`, `WEB-APP-AUDIT-AND-DESIGN.md`, the web-overhaul `FLAW-REGISTER.md`, and the build reports in `~/workspace/your_files/iqrs-app/`.*
