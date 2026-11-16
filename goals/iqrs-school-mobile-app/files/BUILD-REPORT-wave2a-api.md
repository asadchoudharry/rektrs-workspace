# BUILD REPORT — Wave 2A API (staging wave)

**Built:** 2026-11-07 · **Builder:** API builder lane (local build only — no server touched)
**Masters:** `~/workspace/iqrs-api/staff-ext/Staffapi.php` + `Staffsync.php`
**Battery:** `~/workspace/iqrs-api/staff-ext/test-wave2a-api-staging.sh`
**Contract:** WAVE2-PROPOSAL.md §2 (A-rows) + FEATURE-AND-DESIGN-PLAN.md §3 shapes + DESIGN-RESEARCH-WAVE2.md binding rules.

---

## 1. Files

| File | Before (Wave 1A master) | After (Wave 2A) |
|---|---|---|
| Staffapi.php | 282,897 B · md5 `654e2493c6b40280eebe60777dff048d` · 5,888 lines | **563,365 B · md5 `78956f1474b13688b122eacae2eb8182` · 11,067 lines** |
| Staffsync.php | 97,582 B · md5 `8f309d69b8ac31691b322749ba661fd4` · 2,335 lines | **140,772 B · md5 `e276a536be5ce82dbd8f896717dd8820` · 3,221 lines** |

Baselines kept alongside as `Staffapi.php.pre-wave2a` / `Staffsync.php.pre-wave2a` (md5-verified copies of the 1A masters before the build).

**Additivity (diff vs the `.pre-wave2a` baselines): Staffapi +5,179 lines / −0 lines; Staffsync +886 lines / −0 lines.** The wave is a pure insertion: every Wave 0/1A endpoint's bytes are preserved exactly; no existing line was edited. The two Wave 2A sections sit under their own banners (`WAVE 2A` in Staffapi before the Wave 1A helpers section; `WAVE 2A sync writes` in Staffsync before its Wave 1A helpers).

The one compression vs the 1A style: each new endpoint opens with a shared guard preamble (`w2_begin()` in Staffapi, `w2_sync_begin()` in Staffsync) that performs exactly the 1A sequence — POST-only → `check_client()` → `require_staff_session()` (→ `txn_key`/`sync_claim` in Staffsync) — and a capability helper (`w2_can()`) that emits the 1A-style refusal. Behaviour at the wire is identical; refusals keep the 1A shapes (401 JSON for guard failures; HTTP 200 + `status: 0` + plain message for capability/validation refusals; sync refusals are stored through `sync_finish`, as 1A does).

## 2. Endpoint inventory (code-derived) — 87 new endpoints

### Staffapi.php — 71

| Family (plan ID) | Endpoints | Gate (group / category / action) |
|---|---|---|
| Exams (API-40) | examCatalog, examDetail, examMarksRoster | examination / exam view; exam_marks view |
| Exams (API-42) | examStudentResult | examination / exam_result view |
| Exams (API-44) | examPublish, examRankGenerate | exam_publish view or exam edit; generate_rank view |
| Exams setup (API-43) | examGroupSave, examSave, examSubjectSave, examStudentsAssign, examGradeSave, examDivisionSave | exam_group / exam / marks_grade / marks_division add·edit |
| Lesson plan + syllabus (API-54) | lessonPlanList, lessonPlanDetail, syllabusStatus | lesson_plan / manage_lesson_plan view; manage_syllabus_status view |
| Library (API-100) | libraryCatalog, libraryMember, libraryDueList | library / books view; issue_return view |
| Income/expenses (API-95) | incomeList, expenseList, financeHeads, financeDocumentAttach (multipart) | income / income·search_income view; expense mirror; attach = edit |
| Fee setup (API-25/26) | feeSetup, feeGroupSave, feeMasterLineSave, feeDiscountSave, feeGroupAssign, feeDiscountAssign | fees_collection / fees_master·fees_group·fees_discount view·add·edit; assigns on their categories' view (1A offline-payments precedent) |
| Behaviour (API-170) | behaviourCatalog, studentBehaviour | behaviour_records / behaviour_records_incident view |
| Certificates + ID (API-150/14) | certificateCatalog, studentIdCard, staffIdCard | certificate / student_certificate·student_id_card·staff_id_card view |
| Content (API-140) | contentList, contentTypes, contentUpload (multipart), contentDelete | download_center / upload_content view·add; delete on content_share_list delete or upload_content delete |
| Transport (API-120) | transportCatalog, transportStudent, routeSave, vehicleSave, vehicleAssignSave, pickupPointSave, routePickupPointSave | transport / routes·vehicle·assign_vehicle·pickup_point·route_pickup_point |
| Inventory (API-110) | itemCatalog, itemStockList, itemIssueList, itemSave, itemCategorySave, itemStoreSave, itemSupplierSave, itemStockSave | inventory / item·item_stock·issue_item·item_category·store·supplier |
| HR (API-80/81/83/84) | staffSave, myAttendance, staffPayroll, staffTimeline, staffTimelineSave, staffRatings, staffRatingSave | human_resource / staff add·edit; staff_attendance view (self always); staff_payroll view; staff_timeline view·add·edit; teachers_rating view·edit |
| Online exams (API-90) | onlineExamCatalog, onlineExamDetail, onlineExamResults, questionBankList, questionSave, onlineExamSave, onlineExamQuestionSave, onlineExamAssignSave | online_examination / online_examination·question_bank·add_questions_in_exam·online_assign_view_student |
| Reports (API-220) | reportCatalog, reportRun | reports / <the report's own category> view |
| Files (API-04) | fileOpen (kinds: fee_receipt, marksheet, admit_card, certificate, id_card, staff_id_card, report, document) | the owning module's view per kind |
| App versions (API-230 slice) | appVersions | any staff session |

### Staffsync.php — 16 (all `client_txn_id`-idempotent, 1A claim/finish discipline)

| Family | Endpoints | Notes |
|---|---|---|
| Marks (API-41) | examMarksSave | saved + refused[] per-row contract |
| Lesson plan (API-54) | lessonPlanSave, lessonSave, topicSave, syllabusTopicStatus, lessonPlanCommentSave | authoring writes |
| Library (API-100) | libraryIssue, libraryReturn | member-then-book desk flow |
| Finance (API-95) | incomeSave, expenseSave, incomeDelete, expenseDelete | deletes are the vendor soft delete |
| Behaviour (API-170) | behaviourAssign | + optional first comment |
| Inventory (API-110) | inventoryIssue, inventoryReturn | availability-checked |
| Transport (API-120) | transportAssign | sets student_session assignment |

### Not built (by the proposal's own §8 / scope)
Book master saves (the §2 library row is the issue desk; book records are web-managed), membership-card printing beyond API-14, CBSE (API-45), courses (200), live classes (210), hostel (130), alumni/admissions (180), multi-branch (240) and the full API-230 beyond `app_versions`, fee carry-forward/void (27/28), reminders/messaging/credentials (29/61/62/63). **Family behaviour read needed no build:** the vendor Webservice already serves it (`getstudentbehaviour`, verified in the production copy) — A8/C1's family side rides that; this wave built the staff side.

## 3. Design decisions taken inside the contract

- **Exam model:** built on the CURRENT Smart School model (`exam_groups` → `exam_group_class_batch_exams` → `_subjects`/`_students` → `exam_group_exam_results`), never the legacy `exams`/`exam_schedules` pair. Marks rows are keyed by exam-student row + exam-subject row, mirroring `Examgroup_model`'s own joins; `exam_group_student_id` is filled from the `exam_group_students` row when one exists.
- **Roster honesty:** `examMarksRoster` returns `students_assigned: false` with an empty list when an exam has no assigned students (the vendor web likewise shows nobody until assignment). `examStudentsAssign` writes both the exam enrolment and the group-level `exam_group_students` row the web maintains.
- **Result computation:** totals are computed over subjects that HAVE a result row; the card returns `subjects_entered`/`subjects_total` and stays `result_status: "incomplete"` until every subject is entered — an unentered subject is never silently zero. Per-subject pass uses the subject's `min_marks`, falling back to the exam's `passing_percentage` of max when unset; overall pass uses `passing_percentage`.
- **Grades/divisions:** resolved the family API's way — grade bands of the exam group's `exam_type`, matched on the rounded percentage, falling back to all bands when the type has none (the seeded bands are keyed to a grade-system name the groups don't carry); divisions from `mark_divisions`.
- **Rank:** the web's rank screen edits `rank` by hand; `examRankGenerate` computes it — per class+section, by total marks, competition ranking (equal totals share a rank) — writes the same column and sets `is_rank_generated`. Students with no marks keep rank 0 and are counted in `unranked_no_marks`.
- **Marks save (API-41):** per the design rule — entries above the subject's max are **refused per-row with the reason**, never clipped; absent entries store `get_marks` 0; foreign-section entries for an assigned teacher are refused per-row ("not in your classes").
- **Fee setup (API-25/26):** every save answers `affects_students` (count of `student_fees_master` rows carrying the session group). `feeGroupAssign` writes the vendor's own assignment row with `amount` = the group's current line total (the statement engine reads lines, not this total); re-assignment reports `already_assigned` and never duplicates. Discount assignment likewise.
- **Library:** availability = `books.qty` − open issues. Issue auto-creates a membership ONLY when the caller holds the matching `add_student`/`add_staff_member` grant; card numbers are deterministic (`LIB-S<student_id>` / `LIB-T<staff_id>`).
- **Inventory stock truth** follows the vendor's own item-list SQL: total = `item.quantity` + signed `item_stock` movements; outstanding = `item_issue` sums with **`is_returned = 1`** (the vendor's counter-intuitive flag: 1 = still issued, 0 = returned — proven from `Item_model`); available = total − outstanding. Issue validates against it.
- **Payroll (API-83) is view-only** (owner decision D-W2-3): components from `payslip_allowance` split by `cal_type`; gross shown as basic + `total_allowance`, kept separate from deductions and net.
- **Content (API-140)** builds on the current share system (`upload_contents`/`share_contents`/`share_content_for`), not the legacy `contents` table. Upload validation is deliberately stricter than the install's seeded file-type row (which allows apk/svg): documents/images/video/archives only, 25 MB cap, image content verified.
- **Reports (API-220):** the catalogue is derived from the caller's own API-00 capability map (reports group), each key marked available/unavailable. Runs exist for 19 keys (due/balance fees, fees collection, daily collection, income/expense + group variants, student roster, attendance, staff attendance, book issue/due/inventory, stock, add-item, issue-item, payroll, syllabus status) on engines that exist in the extension; all other catalogued keys answer `available: false` with a plain reason and `reportRun` refuses them — no report is fabricated.
- **Files (API-04):** one authorised door. Generated documents are rendered with the API tree's own mPDF (`M_pdf`, the library the vendor Webservice itself uses) and returned as bytes **inside the authenticated JSON response** (`{format, filename, mime, size, content_base64}`) — never as an unauthenticated URL, which is the vendor pattern the audit flagged. Report export is CSV of the same run. Stored documents are read from their own upload directory by stored name only (`basename()`), behind the owning module's capability.

## 4. Honesty contracts taken

1. **Library fine:** the library schema has no fine column or setting anywhere (verified in the web Bookissue code) → returns carry `days_late` and `fine: null` (+ `fine_note` on return). Never an invented amount.
2. **Certificates:** generation renders the template and files **no copy** — this install has no generated-certificates table. A template with a background image returns `background_applied: false` with a note.
3. **Receipt file (B13):** `fileOpen kind=fee_receipt` renders from the deposit's own `amount_detail` entry; a missing entry answers `file: null` + reason. (Wave 1A's `feeReceipt` view-model is unchanged.)
4. **Reports:** unimplemented catalogue keys are `available: false` with a reason; payroll report returns totals-only (columns/rows empty) rather than a fabricated table.
5. **appVersions:** reads the extension-owned `api_app_versions` table **if it exists**; until the office creates it (fixture F5), the answer is `configured: false` with both apps null — the apps then show no update notice.
6. **Syllabus progress** is two-level counts (subject → lesson → topic with covered/total at every level), never a bare percentage (the top-level percent is derived from those same counts).
7. **Online-exam results:** unattempted students return `obtained: null`, `percentage: null`, `passed: null` — not zeros.
8. **Lesson plans:** a non-office teacher's list contains only plans they wrote or that were written for them; detail of another teacher's plan is refused.
9. **Question bank:** non-office staff see and edit only their own questions.
10. **myAttendance:** reading your own record needs no HR privilege; reading anyone else's requires `staff_attendance` view.
11. **staffRatings:** moderation states are returned as the raw `status` int plus a best-effort name (0 declined / 1 approved per the model; 2 labelled pending) — the int is authoritative.
12. **Exam catalogue with class/section filters** lists only exams that actually enrol students of that pair — an exam with no enrolment is not presented as belonging to the class.
13. **Transport:** `transportAssign` sets the assignment only; monthly `student_transport_fees` charge rows are still generated on the web (the 1A fee engine already reads them once they exist).

## 5. Self-checks performed (local; staging smoke is the parse test — no PHP binary on this VM)

- Bracket/paren balance (string- and comment-aware): **OK both files**. Duplicate function names: **none** (229 functions in Staffapi, 63 in Staffsync). Every `$this->…()` call in the new code resolves to a method defined in the same file.
- **Table audit:** all 82 tables referenced by the new Staffapi code and all 28 in Staffsync exist in the staging export DDL — the only exception is `teacher_subjects`, referenced solely behind the proven `table_exists()` guard. Extension-owned tables (`api_staff_sessions`, `api_sync_log`, `api_app_versions`) are the known additive set.
- **Column audit:** every qualified `table.column` reference in the new code resolves against the export DDL — **0 problems**.
- **Defects caught by self-review and fixed before delivery** (the Wave 1A classes): (a) department/designation joins first written against `departments`/`designations` — the real tables are `department`/`staff_designation`; fixed in both selects and joins. (b) `onlineExamDetail` read the link row's `id` as the question id — now selects `questions.id AS question_id`. (c) fee-receipt identity first read a `student_session_id` column `student_fees_deposite` does not carry (defect #5's exact trap) — identity now resolves through `student_fees_master`. (d) `payroll_report` double-ran its query for the count — fixed to count the fetched rows.
- Insert/update key sets were checked table-by-table against the DDL, including NOT NULL columns without defaults (`staff_timeline.document` is set explicitly; `vehicles` placeholders follow the vendor's own 'None'/'' pattern; `topic.status`, `onlineexam.duration/attempt` defaulted in code).

## 6. Staging swap manifest (for the coordinator)

Swap **both** files into the staging API tree (`staging.iqrs.edu.pk` → `api/application/controllers/`), in this order, verifying preflight sizes first:

| Step | File | Preflight (staging, Wave 1A build) | Backup name | New size | New md5 |
|---|---|---|---|---|---|
| 1 | Staffapi.php | 282,897 B | `Staffapi.php.bak-2026-11-07-wave2a` | **563,365 B** | `78956f1474b13688b122eacae2eb8182` |
| 2 | Staffsync.php | 97,582 B | `Staffsync.php.bak-2026-11-07-wave2a` | **140,772 B** | `e276a536be5ce82dbd8f896717dd8820` |

Then run `test-wave2a-api-staging.sh` (it refuses any base other than `https://staging.iqrs.edu.pk/api`). The battery opens with no-token/no-header probes for all 87 endpoints — a 404 there means the swap didn't land; a 500/blank means a parse/runtime fault to roll back from the backups. **Production is not in this manifest.**

## 7. The battery

`test-wave2a-api-staging.sh` (~150 checks): guard probes for all 87 endpoints; fixture logins (113/114/115); **the exam fixture is created through the API itself** (group → exam → subject → assign Four–Daffodils (3,2) plus a second section for the foreign-scope check); marks save present/absent + over-max per-row refusal + idempotent replay; result totals reconciled by re-summing subject rows; teacher roster restriction + foreign marks refusal; publish + rank; marksheet PDF magic-byte check; lesson/topic/syllabus round trip with count reconciliation; library, finance, behaviour sections that **skip with a named reason when staging lacks the web-created master data** (see §8); fee-setup assignment reconciliation (`affects_students` 0 → 1, group total = line sum, no duplicate masters); content share round trip; transport + inventory end-to-end with availability reconciled at every step (15 → 12 → 15); staff creation + sign-in proof of the hashed password; payroll/timeline/ratings reads; online-exam authoring round trip; report-vs-fee-desk balance reconciliation; limited-staff (115) refusals; Wave 0/1A regression spot checks. The script leaves clearly-named "W2A Script" fixture rows in staging.

## 8. Fixture needs (phpMyAdmin / web — only where the API cannot create the master data)

- **F1 — Library books:** if staging still holds 0 `books` rows, add 1–2 (title, book_no, qty ≥ 2). Without them the battery skips the issue/return round trip (catalogue/member/due-list checks still run). Book master saves were not in the wave's §2 scope.
- **F2 — Behaviour incident types:** if `student_behaviour` is empty, add 2–3 types with points (e.g. "Late to class" −2 style values as the school uses). Without them the assign/score reconciliation skips.
- **F3 — Income/expense heads:** if `income_head`/`expense_head` are empty, add one of each. Without them the finance write checks skip.
- **F4 — Certificate/ID templates (optional):** `certificates` (created_for=2) and `id_card` rows make the certificate-PDF and template-flag checks meaningful; the ID-card PDF check runs without a template (view-model defaults).
- **F5 — `api_app_versions` (extension-owned, optional):** create when the office wants in-app update notices:
  ```sql
  CREATE TABLE IF NOT EXISTS `api_app_versions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `app` varchar(32) NOT NULL,
    `latest_version_code` int(11) DEFAULT NULL,
    `latest_version_name` varchar(32) DEFAULT NULL,
    `min_supported_code` int(11) DEFAULT NULL,
    `store_url` varchar(255) DEFAULT NULL,
    `message` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`), UNIQUE KEY `app` (`app`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
  ```
  Until then `appVersions` honestly answers `configured: false`.
- **Not needed:** exam, lesson, syllabus, inventory, transport, content, HR and online-exam fixtures — the battery creates them through the API.
