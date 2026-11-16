# Family App Feature-Parity Plan — Legacy Parent/Student App → Family v2.3

Analysis only (no building, no deploying). Written 2026-11-07 for the coordinator.

## Sources and method

1. **Legacy inventory** — two layers:
   - The coordinator's established inventory of the purchased CodeCanyon
     "Smart School Mobile App" (Flutter) for Smart School 7.2: the 31 features
     in the parity table below.
   - `Smart_School_7.2_Roles_and_Features.md` (same folder), §5 "Android
     student/parent app functions" — used for the supplementary rows in §5 of
     this plan. (The rest of that document is the *web* system's staff RBAC
     inventory and is out of scope for the Family app.)
2. **Our Family app** — read from the code in `~/workspace/iqrs-app-v2/`
   (single tree, family flavour), not from report claims: screens in
   `src/pk/edu/iqrs/app/ui/family/`, data layer in `data/FamilyRepository.java`,
   mappers in `api/`. Cross-checked against `BUILD-REPORT-v2.md` and
   `BUILD-REPORT-v2.4-visual.md` in `~/workspace/your_files/iqrs-app/`.
3. **Vendor API** — `~/workspace/iqrs-api/production/api/application/`
   (controllers `Webservice.php`, `Auth.php`, `Payment.php`, models).
   Line numbers below are into those files.

Conventions: **HAVE** = shipped in Family v2.3 and working against the vendor
endpoint. **PARTIAL** = a real subset ships; the delta is spelled out.
**MISSING** = nothing in the app. Effort: S (≤1 screen, existing patterns),
M (new screen + repository + mapper), L (multi-screen or new client capability),
XL (app-wide).

---

## 1. What Family v2.3 has today (evidence baseline)

Screens (`ui/family/`): `MainActivity` (shell, bottom nav: Home / Attendance /
Fees / More), `HomeScreen`, `AttendanceScreen`, `FeesScreen`, `MoreScreen`,
`ProfileScreen`, `TimetableScreen`, `HomeworkScreen` + `HomeworkDetailActivity`,
`ExamsScreen`, `ExamResultScreen`, `LibraryScreen`, `TransportScreen`,
`NoticesScreen` + `NoticeDetailActivity`, `AboutActivity`, login via
`ui/LoginActivity` / `ui/BaseLoginActivity`.

Endpoints the family flavour actually calls (all in `FamilyRepository`):
`auth/login`, `webservice/dashboard`, `getStudentProfile`,
`getAttendenceRecords`, `fees`, `getClassTimetable`, `getHomework`,
`getNotifications`, `getSchoolDetails`, `getExamList`, `getExamSchedule`,
`getExamResult`, `getTransportroute`, `getLibraryBookIssued`,
`getModuleStatus`, `Parent_GetStudentsList`. Everything is read-only; the
client posts JSON only (no multipart anywhere in the family flavour), caches
responses in `CacheDb` (cache-first loaders), and has **no Firebase/FCM code,
no `google-services.json`, no download manager usage, and a single
`res/values/strings.xml` (English only)**.

Home (v2.3, enriched): hero with child photo/switcher, attendance ring,
today's periods, fees overview card with Paid/Discount/Balance bar, homework
due, latest notice, bento tiles (Results / Transport / Library).

---

## 2. Parity table — the 31 legacy features

| # | Legacy feature | Status | Vendor endpoint(s) | Build takes |
|---|---|---|---|---|
| 1 | Login | **HAVE** | `auth/login` (Auth.php:14) | — |
| 2 | Dashboard | **HAVE** (delta in #16) | `webservice/dashboard` (819) | — |
| 3 | Profile | **PARTIAL** | `getStudentProfile` (429); `getDocument` (919), `uploadDocument` (3517), `editprofile` (3128), `checkProfileUpdate` (3068), `profileUpdateFields` (3086) unused | M–L |
| 4 | Switch Child | **HAVE** | `Parent_GetStudentsList` (2794) | — |
| 5 | FCM Notifications + device-token registration | **MISSING** | `auth/login` accepts `deviceToken` → stored as `students.app_key` / `parent_app_key` (Auth_model.php:29,85,217); `webservice/logout` (700) clears it | L + Wave C config |
| 6 | Class Timetable | **HAVE** | `getClassTimetable` (1639) | — |
| 7 | Exam Schedule | **HAVE** | `getExamList` (1440) + `getExamSchedule` (1461) | — |
| 8 | Exam Result | **HAVE** | `getExamResult` (2542) | — (CBSE variant: §5) |
| 9 | Homework (view + SUBMIT) | **PARTIAL** | `getHomework` (961), `getHomeworkById` (938); submit = `addhomework` (1049, multipart) | M |
| 10 | Syllabus Status | **MISSING** | `getsyllabussubjects` (2178), `getSubjectsLessons` (2203), `getsyllabus` (2157) | M |
| 11 | Lesson Plan | **MISSING** | `getlessonplan` (2117) | M |
| 12 | Attendance | **HAVE** | `getAttendenceRecords` (2009) + dashboard % | — (subject-wise: see §6) |
| 13 | My Subjects | **MISSING** (screen) | `getstudentsubject` (1022), `getSubjectList` (1500) | S |
| 14 | Live Classes (Zoom/Gmeet) | **MISSING** | `liveclasses` (2929), `livehistory` (2980), `getzoomsettings` (2960); `gmeetclasses` (3003), `gmeethistory` (3045), `getgmeetsettings` (3026) | M + Wave C addons |
| 15 | Notice Board | **HAVE** | `getNotifications` (1481) | — |
| 16 | Events / Calendar | **MISSING** | Already inside `dashboard` response (`public_events`, `date_lists`, `student_incomplete_task`); tasks: `getTask` (899), `addTask` (584), `updatetask` (632), `deletetask` (667) | M |
| 17 | Library | **PARTIAL** | issued: `getLibraryBookIssued` (1774) ✔ used; catalogue: `getLibraryBooks` (1756) unused | S |
| 18 | Transport Route | **HAVE** | `getTransportroute` (1796); detail: `getTransportVehicleDetails` (1943) unused | — (minor delta) |
| 19 | Fees — view + ONLINE PAYMENT | **PARTIAL** | view: `fees` (2322) ✔; pay: `Payment::fees_pay` (Payment.php:365) → `redirect_url = payment/pay/<session>`; gateways in `controllers/gateway/*` (incl. Jazzcash.php, Stripe.php, Payfast.php) | L + Wave C gateway config |
| 20 | Previous Payment History | **HAVE** (delta: §3) | Derived from `fees` response deposits; official PDF: `Payment::successinvoice` (Payment.php:732); list: `getOfflineBankPayments` (5424) unused | — |
| 21 | Apply for Leave | **MISSING** | `getApplyLeave` (39), `addLeave` (73), `updateLeave` (246), `deleteLeave` (375) | M |
| 22 | Chat (teacher/admin) | **MISSING** | `searchuser` (2836), `addChatUser` (2866) only — **no message send/fetch endpoint exists** (see §6) | Blocked (Wave C) |
| 23 | Download Content | **MISSING** | `getDownloadsLinks` (1890), `getDownloadsLinksById` (1923); plus homework documents, notice attachments, `getDocument` (919) | M |
| 24 | Online Course | **MISSING** | Full family: `courselist` (3574), `coursedetail` (3682), `coursecurriculum` (3710), quiz (`getquestionbyquizid` 3791, `saveanswer` 3846, `submitquiz` 3898, `quizresult` 3816), `markascomplete` (4047), `courseperformance` (4089), reviews (3756/4136), assignments (6081/6452), course exams (6177/6245/6327), certificate (6538); payments in `controllers/course_payment/*`; gating `getOnlineCourseSettings` (6059), `getELearningModuleStatus` (5176) | XL + Wave C addon |
| 25 | Change Password | **MISSING** | **None in the API** (see §6). Recovery exists: `forgot_password` (732) | Blocked / decision |
| 26 | Change Language (incl. Urdu/RTL) | **MISSING** | `updatestudentlanguage` (4182), `getstudentcurrentlanguage` (4215) | XL (app-side) |
| 27 | Logout | **HAVE** | local sign-out; `webservice/logout` (700) unused (moot, token empty) | — |
| 28 | Rate App | **MISSING** | n/a (store link) | S (caveat §6) |
| 29 | Share App | **MISSING** (Family) | n/a | S (caveat §6) |
| 30 | About & Privacy Policy | **PARTIAL** | About: `getSchoolDetails` (408) ✔ used. Privacy: no API field — a web URL | S |
| 31 | Offline downloaded content | **MISSING** | n/a (follows #23) | with #23 |

### Row evidence (app side)

- **#1 Login** — `FamilyRepository.login()` posts `{username, password,
  deviceToken: ""}` to `auth/login`; `LoginMapper` handles student vs parent
  records (student id from `record.student_id`). Student + parent logins are
  both live-verified in earlier milestones.
- **#2 Dashboard** — `dashboard` POST `{student_id, date_from, date_to, role}`
  (our app sends the current month window). `DashboardMapper` reads only
  `student_attendence_percentage` and `student_homework_incomplete`; the same
  response's `public_events`, `date_lists`, `student_incomplete_task` and
  `attendence_type` are fetched and discarded today (Webservice.php:855–895).
- **#4 Switch Child** — switcher on Home hero, More header and Profile children
  section; `refreshChildren()` re-pulls `Parent_GetStudentsList` and replaces
  the cached list without wiping the device copy first.
- **#6 Timetable** — `getClassTimetable`; a student login carries no
  class/section, so the repository first resolves them from
  `getStudentProfile` (chained call in `loadTimetable`).
- **#7/#8 Exams** — `ExamsScreen` lists exams (`getExamList`), opens the
  schedule (`getExamSchedule`: date, room, full/passing marks) and the result
  (`getExamResult` → `ExamResultScreen`: overall %, total marks, grade,
  pass/fail, division, rank, per-subject marks incl. absent flags;
  not-published state handled).
- **#12 Attendance** — month calendar with prev/next navigation, day detail,
  summary counts; data `getAttendenceRecords` `{attendence_type, data:[{date,
  type…}]}`.
- **#15 Notice Board** — `getNotifications` with `{type: <role>}` reads the
  `send_notification` table filtered `visible_student`/`visible_parent`
  (Webservice_model.php:124) — i.e. exactly the board the legacy app shows.
  List + detail ship; notice **attachments** (`uploads/notice_board_images/…`)
  are referenced in the payload but never opened/downloaded (part of #23).
- **#18 Transport** — `TransportMapper` maps route title + vehicles
  (vehicle_no, model, driver_name, driver_contact). Not mapped: pickup-point
  detail; the vendor also offers `getTransportVehicleDetails {vehicleId}` and
  transport fee balance helpers (`getStudentTransportFeetypeBalance`, 5915) —
  transport fees already appear inside the `fees` response our app renders.
- **#27 Logout** — Profile → sign out with confirmation; wipes the local
  session. `webservice/logout` (which nulls `students.app_key` for a device
  token) is never called — harmless while our token is empty, must be wired
  if #5 lands.

---

## 3. PARTIAL items — the exact deltas

### #19/#20 Fees (view HAVE; payment + history depth is the delta)

**Today (code):** `FeesScreen` renders, from the single `fees` response
(2322): a totals card (total / paid / discount / fine due / fine paid, and a
proportional Paid–Discount–Balance bar), per fee-group lines with status
chips (Paid / Settled by discount / Partial / Unpaid — status computed from
money paid, discounts shown against the fee, per the school's discount
history), expandable per-line payment detail, and a **history section**:
`FeeStatement.history()` flattens every deposit instalment across all groups
(newest first) into rows that open an in-app receipt dialog
(`FeesScreen.showReceipt`). Transport fees are part of the same statement.

**Legacy delta:**
1. **Online payment — missing entirely.** Legacy pays through
   `Payment::fees_pay`: POST (token auth) `{payments: [{student_id,
   fee_groups_feetype_id, student_fees_master_id, amount,
   student_transport_fee_id}]}`; the server totals the selection (incl.
   discount/fine balances and gateway processing charge from
   `getProcessingfees`, 5575), creates a gateway session and returns params
   with `redirect_url = <site>/payment/pay/<session_id>`; the gateway
   controllers (`controllers/gateway/Jazzcash.php`, `Stripe.php`,
   `Payfast.php`, ~26 more) run the hosted checkout and
   `Payment::successinvoice` issues the invoice. Our build would be:
   fee-selection UI → `fees_pay` → open `redirect_url` in the browser /
   Custom Tab (**not** a WebView — house rule) → on return, re-pull `fees`
   and show the settled state. Hard blocker is school-side (Wave C): if no
   payment method is active in the web system's Payment Settings,
   `fees_pay` answers `400 "Payment method not configured."` — verified in
   code (Payment.php, `pay_method` empty check).
2. **Offline bank payment submission — missing.** Legacy lets parents report
   a bank transfer for office verification: `addofflinepayment` (5096,
   form POST: `payment_type`, `payment_date`, `bank_account_transferred`,
   amount/fee references, optional slip upload), status/instructions via
   `getOfflineBankPaymentStatus` (5529) / `getOfflineBankPaymentInstruction`
   (5552), list via `getOfflineBankPayments` (5424); the web system has the
   matching "Offline Bank Payments" permission group. App work + staging
   verification of the form encoding (Wave B).
3. **History depth — mostly there.** Our history is complete for *deposits
   recorded in the fee response* (amount, discount, fine, mode, date,
   invoice/sub-invoice numbers via the instalment model). What it is not:
   the official **PDF invoice/receipt** the website issues
   (`successinvoice` is a web route, not a JSON API) — downloading official
   PDFs is unproven from the API copy (Wave B check if wanted).

### #9 Homework (view HAVE — richer than it looks; SUBMIT is the delta)

**Today (code):** `loadHomeworkMerged()` calls `getHomework` three times
(`homework_status` = pending / submitted / evaluated — the endpoint filters
by its server-computed status) and merges by id. `HomeworkScreen` groups
into Due today / This week / Earlier / Done. `HomeworkDetailActivity`
(doc-comment in code: *"Read-only in M1"*) shows subject, given/due dates,
status chip (Done / Checked) and the full description text.

**Missing vs legacy, precisely:**
1. **Submit** — no UI, no call. The endpoint exists and is student-side
   despite its name: `addhomework` (1049) is a **multipart form POST**
   `{student_id, homework_id, message, file?}` validated by form rules,
   storing to `homework/assignment/` and inserting into `submit_assignment`;
   returns `{status:'1', msg:'Success'}`. Our family client is JSON-only —
   build needs a multipart path in `ApiClient` (the staff flavour's sync
   code is the in-tree precedent) plus a compose UI on the detail screen.
2. **Teacher's document** — `document` is mapped into
   `HomeworkItem.documentPath` and cached, but the detail screen never
   receives or opens it. Opening/downloading it is part of #23's file
   pipeline.
3. **Evaluation detail** — the `getHomework` payload carries
   `evaluation_marks`, `marks`, `evaluation_date`, `evaluated_by` (961–1020);
   `HomeworkMapper` maps none of them, so a "Checked" homework shows no
   marks or teacher note. Mapper + detail-screen addition, S.
4. **Daily assignments** — a separate legacy sub-feature with its own
   endpoints: `getdailyassignment` (4367, `{student_id}`),
   `adddailyassignment` (4236, form + attachment to
   `homework/daily_assignment/`), `addeditdailyassignment` (4399),
   `deletedailyassignment` (4495). Not in our app at all.

### #3 Profile (view HAVE; documents + school-permitted editing missing)

**Today:** `ProfileScreen` renders the full read-only record from
`getStudentProfile` (`{student_result}`): personal details (DOB, gender,
blood group, roll no, admission date, session, phone, email, address),
father/mother/guardian section, children switcher, and Settings (dark mode,
About, sign out). A caption (`profile_change_note`) tells parents changes are
made by the school office.

**Delta:** (a) **Documents** — the legacy profile shows the student's
document list: `getDocument` (919, student's uploaded documents) and
`uploadDocument` (3517, multipart). (b) **Edit profile** — the vendor gates
it: `checkProfileUpdate` (3068) says whether this school allows app-side
profile updates at all, `profileUpdateFields` (3086) lists which fields,
and `editprofile` (3128) applies them (incl. photo fields via
`edit_handle_upload`). Whether iqrs has profile update enabled is a live
setting — check on staging before designing the UI (Wave B).

### #17 Library (issued HAVE; catalogue missing)

`LibraryScreen` shows currently-issued books and returned history from
`getLibraryBookIssued`. The catalogue endpoint `getLibraryBooks` (1756)
takes no parameters and returns `{success, data: [all books]}` — a
searchable catalogue screen (title/author) is S-size app work on data we
can already authenticate for.

### #30 About & Privacy Policy

About ships (school name, motto, phone, email, address, session from
`getSchoolDetails`). No privacy-policy content or URL exists anywhere in
the API responses we call; the legacy app links the school website's
privacy page. Needs the URL confirmed from the legacy ZIP / live site
(Wave B, trivial once known).

---

## 4. Build waves

### Wave A — vendor endpoint exists; app work only

| Item | Work | Size |
|---|---|---|
| #13 My Subjects | New screen listing subjects + codes (and teachers where returned) from `getstudentsubject`; tile + Home link | S |
| #17 Library catalogue | Second Library tab/screen over `getLibraryBooks` with search | S |
| #16 Events / Calendar (read side) | Parse `public_events` + `date_lists` from the **already-fetched** dashboard response; month calendar screen marking event/task dates; event list per day. Personal-task read via `getTask` | M |
| #23 Download Content (+ #31 offline library) | Downloads screen over `getDownloadsLinks`/`ById` (shared assignments, study material, syllabus, other documents); files fetched with the session headers to app-private storage via a download helper, listed in-app, opened with system viewers. Same pipeline then opens homework documents (#9.2) and notice attachments (#15) | M–L |
| #25 Forgot password (interim for Change Password) | Login-screen link → `forgot_password` (email reset link flow) | S |
| #29 Share App | Share intent (text + school site link) from More/Profile | S |
| #28 Rate App | Store-link row — only meaningful once a store listing exists (see §6); build the row, gate the link | S |
| #26 Change Language | Language picker (English / اردو to start), full string externalisation is already resource-based; add `values-ur`, RTL layout pass, persist choice and report it via `updatestudentlanguage`; honour `getstudentcurrentlanguage` at login | XL |

Order inside Wave A by value: Downloads (unlocks homework docs + notice
attachments too) → Events/Calendar → My Subjects → Library catalogue →
Forgot password → Share → Language (largest, schedule separately) → Rate.

### Wave B — endpoint exists, but verify real behaviour on staging first

| Item | What must be verified before/while building |
|---|---|
| #9 Homework submit (+ evaluation detail, + daily assignments) | `addhomework` multipart encoding against staging with a disposable student: file lands in `homework/assignment/`, `submit_assignment` row created, status flips to submitted in `getHomework`. Same for `adddailyassignment`. (School data caveat: homework itself needs subject groups configured — production currently has none; staging fixtures may be needed.) |
| #21 Apply for Leave | Encoding now confirmed from code: `getApplyLeave` is JSON (`{student_id}` → `{result_array}`); `addLeave` is **form-encoded** (`input->POST()` + form validation; required `from_date`, `to_date`, `apply_date`, `student_id`, `reason`; optional document via `handle_upload_file`). Still to verify on staging: leave status values in real rows, `updateLeave`/`deleteLeave` rules (only pending leaves editable?), and the form-vs-JSON split working through our client (our family client posts JSON only today, so leave writes need the form/multipart path — same new capability as homework submit). Full CRUD screen set |
| #19.2 Offline bank payments | `addofflinepayment` required fields against staging; status/instruction endpoints' shapes; the web office-side approval flow reflected in status |
| #3 Profile documents + edit | `getDocument` shape; whether `checkProfileUpdate` is ON for iqrs and which fields `profileUpdateFields` returns; `uploadDocument` multipart contract |
| #10 Syllabus Status + #11 Lesson Plan | Response shapes of `getsyllabussubjects`/`getSubjectsLessons`/`getsyllabus`/`getlessonplan` on staging, **and whether iqrs has any syllabus data at all** — both features hang off subject groups / syllabus entries the school must have created in the web system (production subject-group tables are currently empty, so expect an empty-but-correct UI until the school populates them) |
| Online Exam (supplementary, §5) | `getOnlineExam` → `getOnlineExamQuestion` → `saveOnlineExam` attempt lifecycle on staging; timed-exam UX is unforgiving of shape surprises |
| #18 Transport depth | `getTransportVehicleDetails` shape; whether route payloads include pickup points worth surfacing |
| #30 Privacy Policy URL | Confirm the live site's policy page URL (or that none exists → school decision) |
| #22 Chat discovery | Confirm by staging probe that no send/fetch endpoint answers (see §6); if confirmed, the additive-extension route (same pattern as the staff `Staffsync`/`Staffapi` additions) is a coordinator decision, scoped and built server-first |

### Wave C — blocked on school-side setup or external services

| Item | Precise blocker |
|---|---|
| #5 FCM push notifications | Needs (1) a **Firebase project** with an Android app registered for package `pk.edu.iqrs.family` and its config in the build; (2) the **FCM server key configured in Smart School's notification settings** in the web admin, so the system actually sends pushes to the `app_key` tokens `auth/login` stores; (3) then app work: token fetch at login (today we send `deviceToken: ""`), refresh handling, notification display. Without (1)+(2) the app-side work delivers nothing |
| #19 Online fee payment | A **payment gateway must be activated in the web system's Payment Settings** with the school's merchant credentials (JazzCash is the natural PK choice and its controller ships in `gateway/`; Stripe/PayFast also present). Until one is active, `fees_pay` returns "Payment method not configured." App work (selection UI + `fees_pay` + browser hand-off + re-check) can be built ahead but cannot be end-to-end verified |
| #14 Live Classes | The **Zoom Live Classes v7.0 / Gmeet Live Class v6.0 addons** must be installed+activated on iqrs with the school's Zoom/Google credentials in their settings, and teachers must actually schedule classes. Endpoints (`liveclasses`/`gmeetclasses`) return the student's classes with join URLs; app side is a list + join hand-off |
| #24 Online Course | The **Online Course v4.0 addon** must be installed+activated and courses published (gating endpoints `getELearningModuleStatus` / `getOnlineCourseSettings` report this). Also the largest app build in the programme (catalogue, curriculum, lesson attachments, quizzes, course exams, assignments, progress, reviews, certificates, paid-course checkout) — schedule as its own milestone after A/B |
| #8 CBSE result variant | CBSE Examination v3.0 addon state + CBSE exams configured; endpoints `cbseexamresult` (5666), `cbseexamtimetable` (5840) exist in the API regardless |

---

## 5. Supplementary features (in the §5 web-inventory / vendor API, not in the 31-item legacy list)

| Feature | Status | Endpoints | Wave |
|---|---|---|---|
| Online Examination (take online exams) | MISSING | `getOnlineExam` (1140), `getOnlineExamQuestion` (1184), `saveOnlineExam` (1331), `getOnlineExamResult` (1240) | B |
| Daily Assignments | MISSING | see #9.4 | B |
| Calendar To-Do / Tasks (personal) | MISSING | `getTask` (899), `addTask` (584), `updatetask` (632), `deletetask` (667); counter already in dashboard | A read / B write-verify |
| Student Timeline | MISSING | `getTimeline` (4573), `getStudentTimelineStatus` (5506) | B (shape) |
| Visitors (front-office visitor records for the student) | MISSING | `getVisitors` (4336) | B (shape) — low value |
| Behaviour Records | MISSING | `getstudentbehaviour` (4742), `getincidentcomments` (4779), `addincidentcomments` (4818), `deleteincidentcomments` (4855) — needs the Behaviour Records addon active | C-leaning B |
| Student documents | MISSING | `getDocument` (919), `uploadDocument` (3517) — counted under #3 | B |
| Video Tutorials | MISSING | `getVideoTutorial` (4313, `{class_id, section_id}`) | A/B — data-dependent |
| Hostel details | MISSING | `getHostelList` (1858) | Skip unless the school uses hostel — no evidence it does |
| Teachers list / rate a teacher | MISSING | `getTeachersList` (1555), `addStaffRating` (1723) | B — not in the legacy 31; include only if Assad wants it |
| Multi-currency switch | MISSING | `get_currency_list` (4877), `updatestudentcurrency` (4927) | Skip — single-currency school |

Also already available to gate all of the above per-module:
`getModuleStatus` (2816, used today for 4 tiles) and the finer-grained
`getELearningModuleStatus` (5176), `getAcademicsModuleStatus` (5250),
`getCommunicateModuleStatus` (5324), `getOthersModuleStatus` (5370) — the
parity build should read these so school-disabled modules hide their tiles,
the pattern MoreScreen already follows.

---

## 6. Honest uncertainties — verify from the legacy ZIP source when it arrives

1. **Chat (#22) is the biggest gap between claim and evidence.** The
   inventory says the legacy app chats with teachers/admins, and
   `Chatuser_model` contains `addMessage()`, `getUpdatedchat()` and
   `myChatAndUpdate()` — but **no method in `Webservice.php` exposes
   sending or fetching messages**; only `searchuser` and `addChatUser`
   (which creates a connection and returns its last messages) are routed.
   Either the legacy app used endpoints from a different API build, or
   messaging rides on `addChatUser` polling in a way the model code alone
   doesn't make obvious. Do not promise chat until the ZIP shows the actual
   calls.
2. **Change Password (#25).** No change-password endpoint exists anywhere
   in `api/application` (full recursive search: the only matches are inside
   third-party vendor SDKs under `third_party/omnipay/` — no application
   controller, model or library). The
   web panel has one (`user/User::change_password`) behind a website
   session cookie, which a token-auth app cannot use directly. How the
   legacy app implemented it — WebView, a different API version, or not at
   all in the build Assad had — must come from the ZIP. Interim cover:
   `forgot_password` (Wave A). A real in-app change would need an additive
   extension endpoint (Wave B decision).
3. **Subject-wise attendance.** The inventory's §5 mentions "Attendance and
   subject attendance". The API copy exposes only day-based records
   (`getAttendenceRecords`) plus the school's `attendence_type` flag in the
   dashboard response; no subject-attendance endpoint was found. If the
   legacy app shows per-subject attendance, the ZIP must show where it came
   from.
4. **"Notifications" vs "Notice Board" as separate legacy screens.** Our
   one Notices screen reads `send_notification` via `getNotifications`,
   which is the board. If the legacy app also kept a separate push-history
   list, that history most likely lived on-device from received FCM
   messages (nothing server-side in the API copy stores per-user push
   history beyond `send_notification`). ZIP will confirm.
5. **Addon presence cannot be proven from the API copy.** The distribution
   ships controllers for Zoom/Gmeet/Online Course/CBSE regardless of what
   is activated on iqrs. The truth test is calling the module-status
   endpoints with a real parent session (staging or production read-only) —
   scheduled as part of Wave B verification, not assumed here.
6. **Config values are not in the API copy** (same finding as the photo
   lane): `image_validate` limits, active payment method, and FCM keys live
   in the live install's settings/DB, not in these files. Every Wave C
   blocker above is therefore stated as "configured in the web admin", not
   as a code absence.
7. **Response shapes asserted from code, not from live calls**, for every
   endpoint our app does not already call (leave, syllabus, lesson plan,
   downloads, courses, live classes, tasks write-path, offline payments).
   They are described from the controller/model code; Wave B exists
   precisely to replace those readings with observed staging behaviour
   before UI is built on them.
8. **Rate App (#28) / Share App (#29) targets.** The app is distributed by
   direct APK, not a store listing, so "Rate" has no destination and
   "Share" has no public download URL today. Both rows are trivial to
   build; what they should point at is a distribution decision for Assad,
   not a technical question.
