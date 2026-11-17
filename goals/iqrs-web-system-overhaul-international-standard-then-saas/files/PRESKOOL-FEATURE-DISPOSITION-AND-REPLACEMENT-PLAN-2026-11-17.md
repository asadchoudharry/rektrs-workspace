# PreSkool Feature Disposition & Replacement Plan — 2026-11-17

**Owner ruling (2026-11-17 ~15:27 PKT), governing this plan:** "Sary features sirf PreSkool waly ain gy, Smart School waly nahi — Smart School se sirf wo feature aye ga jo PreSkool main nahi hy; baki sab PreSkool wala, Smart School wala DELETE; PreSkool wala kerna hy or usi ke hisab se DATABASE or DESIGN set kerna hy."

In plain terms: **the feature set is PreSkool's.** Where PreSkool has a feature — or a similar ("milta julta") one — the Smart School implementation is deleted and replaced by PreSkool's feature: its screens, its workflow, and its data-model shape. Smart School features survive **only** where PreSkool has no counterpart. The school's real records and balances are never dropped: they migrate into the PreSkool-shaped model, with counts proven before and after.

**This supersedes** the earlier union framing (D-038 and deployment-plan §10 item 6, under which legacy features were kept and polished alongside). Those framings are closed. It absorbs and replaces the PF-7 build plan: the 25 BUILD-LATER pages of the target map appear here as build cards (§4), most of them as the surface-builds of REPLACE modules.

**Status of this document:** plan only. No deletions and no feature builds were executed in the P2 lane. Production is explicitly held by the owner (2026-11-17 ~15:19 PKT); everything here is staging-first when lanes run.

**Evidence base:** P2 lane record (`hidden_files/preskool/p2fix-2026-11-17/P2FIX-LANE-RECORD.md`) — per-role sidebar census before/after (SA 266 items, Teacher 98 items, zero lost), the vendor package tree (426 pages, `~/workspace/preskool-branches/html/`), staging table census 2026-11-17.

---

## 1. Verdict key

- **REPLACE** — PreSkool has the feature (or a similar one). Our current implementation (legacy Smart School screens, and PK-workspace screens where they duplicate the vendor feature) is deleted once the PreSkool-shaped replacement is proven; the data model is reshaped to PreSkool's pages and real data migrates into it.
- **KEEP-OURS** — PreSkool has no counterpart. The feature stays ours, unchanged in scope.
- **BUILD-NEW** — PreSkool has it, we have nothing (or only an engine/table foundation). Built new on PreSkool's pages.

Deletion discipline for every REPLACE lane: the replacement is built and proven on staging first (rendered captures + data carry-over counts); the menu entry switches to the new surface; only then are the legacy controller/view files deleted, in the same lane. Database tables are archive-renamed at replacement time and dropped only in a later cleanup lane, after the migration proof has survived a full reporting cycle.

---

## 2. REPLACE — module by module

### 2.1 Fees, Billing & Accounts core — REPLACE (first, foundational)
- **Vendor pages:** `fees-master`, `fees-type`, `fees-group`, `fees-assign`, `fee-rules`, `discount-rules`, `fine-management`, `invoices`, `invoice-details`, `edit-invoice`, `fee-installments`, `accounts-income`, `accounts-transactions`, `ledger`, `expenses`, `expenses-category`.
- **Ours today:** legacy `admin/feemaster`, `admin/feegroup`, `admin/feetype`, `studentfee/*`, `admin/fine`, `admin/income`, `admin/expense`, `admin/expensehead` + PK workspace `admin/pkfees/*` (collections, billing, fines, offline, arrears) + `admin/pkledger`.
- **Delete on replacement:** the legacy controllers/views above and the PK fee workspace views (the workspace was a bridge; the vendor feature replaces it).
- **Data model:** the AFM engine tables (`afm_*`, built PKG-6) already follow the vendor shape — installment plans/lines, scholarships + assignments, scheduled fees, settlement plans, posting batches. They become THE model. Legacy `student_fees_master*` / `student_fees_deposite` (1,555 deposit rows) history migrates into AFM posting/settlement records; **balances carry over exactly** — PKG-6 reconciliation snapshots (`afm_reconciliation_snapshots`) are the proof instrument; a lane is not done until snapshot deltas are zero.
- **Dependencies:** none upstream; Scholarships (§4.3) and Fee Installments (§4.2) ride this lane. Everything else in the system reads fee state, so this model lands first.

### 2.2 Examinations — REPLACE
- **Vendor pages:** `exams`, `exam-types`, `exam-attendance`, `marks-entry`, `exam-results`, `grade-setup`, `grading-rules`, report-card pages, `exam-settings`.
- **Ours today:** legacy `admin/examgroup`, `admin/exam_schedule`, `admin/marksregister`, `admin/examresult` + PK workspace `admin/pkexams/*` (exams, schedule, marks, results, grades, online, cbse) + legacy report-card print routes.
- **Delete on replacement:** legacy exam controllers/views + PK exams workspace views.
- **Data model:** `exam_groups` (10 real groups after segregation, incl. Exam 19 group 27 + DEMO group 29), `exam_group_exam_batches`, marks/results tables carry into the vendor-shaped group→exam→marks→grade flow. Exam types become a first-class table (vendor `exam-types`); today they are implicit — the lane creates it and back-fills from existing groups.
- **Dependencies:** Question Bank (§4.5) lands before Online Examination (§4.6). CBSE (2.3) is a separate, later decision.

### 2.3 CBSE examinations — REPLACE (when adopted)
- **Vendor pages:** the package's CBSE exam set.
- **Ours today:** the `cbseexam` add-on (`admin/cbseexam/*`, PK tab `admin/pkexams/cbse`).
- **Data state:** add-on tables exist but are **empty** (0 terms, 0 exams — verified 2026-11-17). Replacement is therefore cheap: no data migration, only the vendor-shaped build if/when the school adopts CBSE. Until then the honest not-configured landing stays.

### 2.4 Online examinations & question bank — REPLACE (legacy feature, vendor shape)
- **Vendor pages:** `online-examination`, question-bank pages.
- **Ours today:** legacy `admin/onlineexam` + `admin/question` (live data: 14 questions, 10 exams, 8 exam-question links).
- **Delete on replacement:** legacy onlineexam/question controllers and views.
- **Data model:** `questions`, `onlineexam`, `onlineexam_questions`, `onlineexam_attempts`, `onlineexam_student_results` carry over — the vendor pages' question types (MCQ/true-false/short) map onto the existing question rows; any type we cannot represent is flagged in the lane, not silently dropped.
- **Dependencies:** question bank first, then the exam player (§4.5 → §4.6).

### 2.5 Attendance — REPLACE
- **Vendor pages:** `daily-attendance`, `student-day-wise`, `teacher-day-wise`, `staff-day-wise`, `student-attendance-type`, `attendance-reports`, `biometric-rfid`, leave pages (`leave-list`, `leave-policies`, `leave-reports`).
- **Ours today:** legacy `admin/stuattendence`, `admin/staffattendance`, `admin/approve_leave` + PK workspace `admin/pkattendance/*` (register, bydate, period, staff, qr, leave, biometric) + the `qrattendance` add-on module (KEEP-OURS, §3 — no vendor counterpart for QR marking itself; its menu entry already sits inside the vendor Attendance entry).
- **Delete on replacement:** legacy attendance controllers/views + PK attendance workspace views.
- **Data model:** `student_attendence`, `staff_attendance`, `subject_attendances`, leave tables carry unchanged in substance (the register is the school's legal record — rows are never rewritten, only re-presented). Attendance types become the vendor-shaped settings surface (§4.4). Biometric: no device layer exists (proven P2) — the vendor `biometric-rfid` page becomes real only when the school procures devices; the current honest landing is its entry point.
- **Dependencies:** day-wise/report cards (§4.4) ride this lane.

### 2.6 Students & admissions — REPLACE
- **Vendor pages:** `students`, `student-profile`, `admissions`, `admission-details`, `student-promotion`, `parents`, `parent-grid`, `guardians`, `guardian-grid`, `alumni` (see 2.15).
- **Ours today:** legacy `student/*` (create, search, profilesetting, bulkdelete, bulkmail, multiclass, disablestudentslist) + PK workspace `admin/pkstudents/*` (students, profile, promotion, alumni, downloads, lifecycle) + legacy `admin/guardian`, `admin/parent`.
- **Delete on replacement:** legacy student controllers/views + PK students workspace views.
- **Data model:** `students` (1,714), `student_session`, guardian/parent link tables carry 1:1 in substance — the vendor profile anatomy (already adopted in P1) becomes the data presentation contract. Bulk delete/mail and multi-class stay as actions inside the vendor list page (they are functions, not pages).
- **Dependencies:** none; the ID-card build (§4.7) reads from this model.

### 2.7 HR: staff, teachers, payroll, leave — REPLACE
- **Vendor pages:** `staff`, `edit-staff`, `teachers`, `teacher-profile`, `edit-teacher`, `departments`, `designation`, `employee-payroll`, salary-structure and payslip pages, `leave-list`, `leave-policies`, `leave-reports`, `holidays`.
- **Ours today:** legacy `admin/staff`, `admin/payroll`, `admin/leavetypes`, `admin/apply_leave`, `admin/department`, `admin/designation` + PK workspace `admin/pkhr/*` (staff, ratings) + legacy `admin/teacher/assign_class_teacher`, `admin/staff/rating` (the one P2 fallback item — a legacy duplicate of `admin/pkhr/ratings`; both are deleted when the vendor Teachers Rating surface lands).
- **Delete on replacement:** legacy HR/payroll controllers/views + PK HR workspace views + both rating pages.
- **Data model:** `staff` (113), `staff_roles`, departments/designations, payroll and leave tables carry. Salary structure + payslips are vendor sub-features we lack as pages — BUILD-NEW inside this lane on the existing payroll tables.
- **Dependencies:** reports (§4.8) ride this lane.

### 2.8 Academics: classes, subjects, timetable, lesson plan, homework — REPLACE
- **Vendor pages:** `classes`, `class-section`, `classrooms`, `class-subject`, `class-syllabus`, `class-time-table`, `class-routine`, `class-schedule`, `lesson-planning`, `homework`, `academic-calendar`, `academic-year`, `academic-settings`, `class-settings`.
- **Ours today:** legacy `classes`, `sections`, `admin/subjectgroup`, `admin/teacher_subject`, timetable controllers, `admin/lessonplan`, `admin/syllabus`, `admin/homework` + PK workspace `admin/pkacademics/*` (overview, timetable, syllabus, homework, analytics).
- **Delete on replacement:** legacy academics controllers/views + PK academics workspace views.
- **Data model:** `classes` (incl. Fixture class 16), `sections` (incl. Fixture section 85), `subjects`, `subject_groups`, `teacher_subject`, timetable and lesson tables carry. The segregation state (Fixture class/section, DEMO enrolments) is data, and migrates untouched.
- **Dependencies:** none upstream; Examination scheduling reads this model (2.2 can run in parallel).

### 2.9 Library — REPLACE
- **Vendor pages:** `library-books`, `library-categories`, `library-members`, `library-issue-book`, `library-return`, `library-reservations`, `library-reports`.
- **Ours today:** legacy `admin/book`, `admin/member` (+ student/teacher member routes) inside the PK ops workspace (`admin/pkops`).
- **Delete on replacement:** legacy book/member controllers/views + the library part of the ops workspace.
- **Data model:** `books`, `library_members` (libarary_members in legacy spelling), `book_issues` carry. Categories become first-class (vendor `library-categories`) — back-filled from existing book rows.

### 2.10 Transport — REPLACE (+ BUILD-NEW sub-features)
- **Vendor pages:** transport set — routes, vehicles, drivers, GPS tracking, transport fees.
- **Ours today:** legacy `admin/route`, `admin/vehicle`, `admin/vehroute`, `admin/pickuppoint` (+ assign, student_fees), `admin/transport/feemaster`.
- **Delete on replacement:** legacy transport controllers/views.
- **Data model:** routes/vehicles/assignments/pickup points and student transport-fee links carry. **Drivers** (we have no driver records) and **GPS Tracking** (no feed exists) are BUILD-NEW sub-features: drivers as a staff-linked register; GPS only when a device/app feed is chosen — named, not faked.

### 2.11 Hostel — REPLACE
- **Vendor pages:** `hostel-list`, `hostel-rooms`, `hostel-room-type`, `hostel-fees`, `hostel-visitor-log`.
- **Ours today:** legacy `admin/hostel`, `admin/hostelroom`, `admin/roomtype`.
- **Delete on replacement:** legacy hostel controllers/views.
- **Data model:** hostel/room/room-type tables carry 1:1 in substance.

### 2.12 Inventory & assets — REPLACE
- **Vendor pages:** `assets`, `asset-allocation`, `asset-maintenance`.
- **Ours today:** legacy `admin/item`, `admin/itemstock`, `admin/issueitem`, `admin/itemcategory`, `admin/store`, `admin/supplier`.
- **Delete on replacement:** legacy inventory controllers/views.
- **Data model:** items/stock/issue tables carry; vendor "assets" = our items with allocation = issue records.

### 2.13 Communication — REPLACE
- **Vendor pages:** `notice-board`, `email`, `email-templates`, `email-settings`, `email-notifications`, SMS pages, WhatsApp entry, `parent-communication`.
- **Ours today:** legacy `admin/mailsms/*` (email/SMS send + templates), `admin/notification`, `admin/communicate` + PK workspace `admin/pkcommunicate/*` (workspace, todo) + the WhatsApp add-on (currently unconfigured/hidden).
- **Delete on replacement:** legacy mailsms/notification controllers/views + PK communicate workspace views.
- **Data model:** message logs, templates, gateway settings carry. The WhatsApp add-on surfaces inside the vendor Communication → WhatsApp entry when configured (its engine is ours; the vendor has the menu slot only).

### 2.14 Front office — REPLACE
- **Vendor pages:** front-office set — visitor log, `gate-pass`, `gate-entry`, `exit-pass`, appointment requests, `call-history`, enquiries, complaints.
- **Ours today:** legacy `admin/front_office` (visitors, enquiry, complaint, calls, postal) + PK module `admin/pkfrontoffice/*` (overview — real since P2 — gatepass, verify, appointments) + `pk_gate` sick-exit queue.
- **Delete on replacement:** legacy front_office controllers/views; the PK module's pages are reshaped to the vendor set (its data layer, `pk_frontoffice_lib` + `pk_gate`, is retained — it is already the governed record).
- **Data model:** `visitors_purpose`/visitor book, `enquiry` (7), `general_calls` (7), complaint and gate-pass tables carry. Call History (§4.9) is this lane's build card.

### 2.15 Alumni — REPLACE (surface) on existing tables
- **Vendor pages:** `alumni`, `add-alumni`, `alumni-profile`.
- **Ours today:** legacy `admin/alumni` (students, events) + PK workspace `admin/pkstudents/alumni` (already a vendor-shaped workspace, refinement A1).
- **Delete on replacement:** legacy alumni controllers/views.
- **Data model:** `alumni_students` (0 rows — records derive from passed-out students at build time), `alumni_events` carry. Build cards §4.10.

### 2.16 Behaviour records — REPLACE (surface)
- **Vendor pages:** `behavior-discipline` (+ AI analysis, §4.11).
- **Ours today:** the `behaviour` add-on (`behaviour/*` setting/report) + PK behaviour pages inside the students workspace (`admin/pkstudents` behaviour/overview/lifecycle, incident assignment).
- **Data model:** `student_behaviour` (12 rows), `behaviour_settings` carry. Build card §4.11.

### 2.17 Certificates, ID cards & print — REPLACE
- **Vendor pages:** `generate-certificates`, `id-card-templates`, `digital-id-card`.
- **Ours today:** legacy `admin/certificate`, `admin/generatecertificate`, `admin/idcard`, `admin/generateidcard` + the PK print studio (`admin/printstudio`, `admin/printsection`, `admin/printdocuments` — menu "Print & Documents").
- **Delete on replacement:** legacy certificate/idcard controllers/views; the print studio is reshaped onto the vendor pages (its governed issuance register is the data that carries).
- **Data model:** certificate templates, `id_card` designs (0 rows today), issuance records carry. Build card §4.7.

### 2.18 Reports — REPLACE
- **Vendor pages:** the `*-reports` set (attendance, fee-collection, grade, financial, academic, library…).
- **Ours today:** legacy report controllers (`admin/studentfee/report`, `financereports/*`, `attendencereports/*`, per-module report pages).
- **Delete on replacement:** legacy report controllers/views as each domain lane lands its vendor reports (reports are views over the domain models — they are replaced domain by domain, not in one sweep).
- **Data model:** none of their own; derived. No migration.

### 2.19 Settings — REPLACE
- **Vendor pages:** the settings tree — general, academic, financial, communication, email, localization/language, security/permission pages.
- **Ours today:** `schsettings`, `admin/admin/update` (currency), `admin/language`, `admin/session`, `admin/roles`, `admin/gauthenticate/admin` (2FA — KEEP-OURS, §3), `admin/smsconfig`, `admin/emailconfig`, payment settings, print settings.
- **Delete on replacement:** legacy settings screens reshaped into the vendor settings tree (same underlying `settings`/`sessions`/`languages` tables — configuration data carries untouched).
- **Dependencies:** the Permission build card (§4.12) is this lane's RBAC surface.

### 2.20 Front CMS — REPLACE
- **Vendor pages:** CMS set — `pages`, blog (`blog`, `blog-categories`, `blog-tags`, `blog-comments`), gallery/testimonial/FAQ-style page builders.
- **Ours today:** legacy `admin/front/*` (gallery, notice/news, media, page, menus, banner) + `admin/cmsmenu` etc.
- **Delete on replacement:** legacy front-CMS controllers/views.
- **Data model:** front CMS content tables carry; blog categories/tags/comments are vendor sub-features we lack — BUILD-NEW inside this lane if the school site adopts the blog; otherwise the CMS lane covers pages/gallery/media/menus/banners only and blog is named deferred.

### 2.21 Annual calendar & events — REPLACE
- **Vendor pages:** `academic-calendar`, `events`.
- **Ours today:** `admin/holiday/index` (menu leaf "Holidays" since P2) + `admin/front/events` + calendar data in the communicate/front modules.
- **Data model:** `holidays` and event rows carry into the vendor calendar/events shape.

---

## 3. KEEP-OURS — no PreSkool counterpart

| Feature | Why it stays |
|---|---|
| QR attendance add-on (`admin/qrattendance`) | PreSkool has no QR marking (audit EX-PKG5-02). Its entry already sits inside the vendor Attendance group. |
| Student CV builder (`admin/student_cv`, Build/Download CV) | No CV feature in the package. |
| Two-factor authentication (`admin/gauthenticate`) | Security infrastructure; the package has no admin 2FA management. |
| Online Course (LMS) module | Config-hidden add-on; the package has no course player. Stays hidden until licensed/configured. |
| Gmeet / Zoom live-class add-ons | Config-hidden; no vendor counterpart. |
| Rektrs platform layer — License, Custom Module Manager, School Operations & Extensions (Pakistan ops), multi-branch | SaaS/platform features of our own product; the package is a single-school template. Menu home: Administration → Platform (P2). |
| Thermal print add-on | No vendor counterpart; hidden until configured. |
| Desktop-app sync (Staffsync) + PK gate queue mechanics | Our own device layer; front-office *pages* are REPLACE (2.14) but the sync/queue engine stays. |
| Exam Recheck Register, Exam Release Gate (PK exams) | IQRS examination-governance features with no vendor page; they remain as actions inside the replaced Examinations surface. |

---

## 4. BUILD-NEW build cards (the target map's 25)

Each card: vendor source → what it does → our readiness → dependency. Cards marked ◆ are the surface-build of a REPLACE module in §2 (same lane).

1. **◆ Question Bank** — vendor question-bank pages → categorized question library (types, difficulty, subject/chapter). Readiness: `questions` table live (14 rows), legacy UI exists. **First in the exams chain.**
2. **◆ Online Examination** — vendor `online-examination` → exam delivery + attempts + results. Readiness: `onlineexam*` tables live (10 exams). Depends on Card 1.
3. **◆ Fee Installments** — vendor `fee-installments` → installment plans per student/fee. Readiness: AFM engine tables exist, **0 plans** — pure UI/workflow build on a ready engine. Rides lane 2.1.
4. **◆ Scholarship Management** — vendor scholarship pages → scholarship definitions + assignment + fee effect. Readiness: `afm_scholarships` + `afm_scholarship_assignments` exist, 0 rows. Rides lane 2.1.
5. **◆ AI Scholarship Recommendation** — vendor AI scholarship page → suggests scholarship matches from student/family data. Readiness: needs Card 4's data + the platform AI configuration (keys exist platform-side). After Card 4.
6. **◆ Edit Invoice** — vendor `edit-invoice`/`invoice-details` → governed invoice correction with audit trail. Readiness: PK billing exists; corrections must write through AFM posting rules. Rides lane 2.1.
7. **◆ Online Payment Receipts** — vendor `online-payment-receipts` → receipt views for gateway-paid fees. Readiness: **blocked on a payment-gateway decision** (no gateway configured); build the receipts surface with the first gateway integration, not before.
8. **◆ Daily Attendance + day-wise set** — vendor `daily-attendance`, `student-day-wise`, `teacher-day-wise`, `staff-day-wise`, `student-attendance-type`, `leave-reports` → the register + per-person day-wise views + attendance-type settings + leave reporting. Readiness: register tables live and complete; pure surface build. Rides lane 2.5. (`staff-report`/`teacher-report` from the target map are the same lane's report cards.)
9. **◆ Call History** — vendor `call-history` → front-office call log with follow-ups. Readiness: `general_calls` live (7 rows) + `pk_gate_queue_calls`. Rides lane 2.14.
10. **◆ Add Alumni + Alumni Profile** — vendor `add-alumni`, `alumni-profile` → alumni record creation + profile. Readiness: `alumni_students`/`alumni_events` exist (0 student rows; derivation from passed-out students is part of the build). Rides lane 2.15.
11. **◆ Behavior Discipline + AI Behavior Analysis** — vendor `behavior-discipline`, `ai-behavior-analysis` → incident/discipline workflow + pattern analysis. Readiness: `student_behaviour` live (12 rows), settings table exists. AI card after the discipline surface.
12. **◆ Permission** — vendor permission page → role/permission matrix editor. Readiness: RBAC tables + `admin/roles` exist; the build is the vendor-shaped matrix UI over them. Rides lane 2.19.
13. **◆ Digital ID Card** — vendor `digital-id-card` + `id-card-templates` → designed ID cards (student/staff) with QR. Readiness: `id_card`/`staff_id_card` tables exist (0 designs); the PK print studio's issuance register is the carry-over. Rides lane 2.17.
14. **AI Notification Assistant** — vendor AI notification page → drafts/schedules guardian notifications. Readiness: communicate data + platform AI exist; build after lane 2.13 lands the vendor communication surfaces.
15. **AI Settings** — vendor `ai-settings` → per-module AI feature configuration. Readiness: platform AI configuration exists (Operqon-side); this is the school-side settings surface. After Cards 5/11/14 define what it configures.
16. **Rewards & Gamification** — vendor rewards/achievements pages → points/badges for students. Readiness: **no tables exist** — new data model (points ledger + badge definitions) designed in its lane. Independent; schedule by school value.

**Vendor-only items beyond the 25, dispositioned here so nothing is unaccounted:** Student Attendance History (folds into Card 8), Exam Types + Exam Attendance (fold into 2.2), Salary Structure + Payslips (fold into 2.7), Teacher Attendance (folds into 2.5), Library Categories (folds into 2.9), Drivers + GPS Tracking (fold into 2.10; GPS needs a feed decision), Online Payments + Payment History (gateway-blocked, with Card 7), Sports + Medical Visits (small BUILD-NEW registers — no tables today; schedule opportunistically), Automation + AI Insights menu entries (demo entries; the real AI features are Cards 5/11/14/15), Notes (demo app entry — not built; named dropped), Multi School + Mobile App entries (demo/marketing entries — not features; our platform layer covers the substance), Layouts section (demo showcase — never carried).

---

## 5. Recommended execution order

1. **Lane F1 — Fees foundation (2.1 + Cards 3, 4, 6).** The data model everything reads; biggest daily-use win (collections, invoices, installments, scholarships). Carry-over proof via AFM reconciliation snapshots.
2. **Lane E1 — Examinations (2.2 + Cards 1, 2).** Question bank → online examination → vendor exams/marks/results. Exam data is live and seasonal — land outside exam windows.
3. **Lane A1 — Attendance (2.5 + Card 8).** Register surfaces + day-wise + leave reports.
4. **Lane S1 — Students (2.6) + Card 13's student half.** Admissions/profile/guardians on the carried model.
5. **Lane H1 — HR (2.7 + payroll sub-builds).** Staff/teachers/leave/payroll; deletes both legacy rating pages.
6. **Lane AC1 — Academics (2.8).** Classes/subjects/timetable/lesson/homework.
7. **Lane C1 — Campus (2.9–2.12 + cafeteria sub-pages on the PK workspace).** Library, transport (+drivers), hostel, assets.
8. **Lane CM1 — Communication + Front Office + CMS (2.13, 2.14, 2.20 + Cards 9, 14).**
9. **Lane X1 — Alumni, Behaviour, Certificates/ID (2.15–2.17 + Cards 10, 11, 13).**
10. **Lane ST1 — Settings + Reports sweep (2.18, 2.19, 2.21 + Card 12).**
11. **Lane AI1 — AI surfaces (Cards 5, 15 + analysis halves of 11/14)** once their data surfaces exist.
12. **Lane G1 — Gateway-dependent (Card 7 + online payments)** when the school chooses a gateway; **Rewards (Card 16)** by school value anytime after S1.

Every lane: staging-first, per-file backups, rendered paired captures vs the vendor pages, census before/after (menu + data counts), legacy deletion only after the replacement is proven, and the owner's signed-in check before anything is called done. Production (D-027) stays held until the owner lifts it.

*End of plan.*
