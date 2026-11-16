# BUILD REPORT — Wave 2B: IQRS Workspace v2.13 (versionCode 26)

**Lane:** Wave 2B BUILD (staff app screens against the Wave 2A API)
**Date:** 2026-11-07 (evening, PKT)
**Base for build/verification:** staging (`staging.iqrs.edu.pk`) — production untouched, per the standing rule.
**API state built against:** Wave 2A staging masters, battery run 4 **PASS=305 FAIL=0 SKIP=0**. Contracts treated as frozen throughout; every surprise found is listed in §6 — none was worked around silently.

## 1. The artefact

| Fact | Value |
|---|---|
| File | `IQRS-Workspace-App-v2.13.apk` in `~/workspace/your_files/iqrs-app/` |
| Size | 1,679,945 bytes |
| SHA-256 | `8c4e7a22127c1f603494f42f9c787411a4e3bb134df901f9e78de898b83f2771` |
| Package / version | `pk.edu.iqrs.admin` · versionCode 26 · versionName 2.13 |
| minSdk / targetSdk | 26 / 34 |
| Signature | verifies (tree signer, same as v2.12) |
| Permissions | CAMERA, INTERNET (metadata gate) |

32 new activities registered in `build.sh`'s ADMIN manifest list; version bumped in `config/admin.properties` (25/2.12 → 26/2.13).

## 2. Screen ↔ endpoint ↔ capability gate mapping

All reads are cache-first through `StaffRepository` (Wave 1B pattern); all writes are live `postAction` calls except the syllabus Covered toggle, which is the design's saved write (outbox kind `syllabus_topic_status` → `staffsync/syllabusTopicStatus`). Every submit disables on tap until the service answers. Every list screen has pull-to-refresh. Entry points are capability-gated links in the More screen (sections below) — a surface exists only when API-00 grants it.

### B1 Exam Centre — `StaffExamsActivity`, `StaffExamDetailActivity`, `StaffMarksEntryActivity`, `StaffExamResultActivity`
- Reads: `staffapi/examCatalog`, `examDetail`, `examRoster`, `examStudentResult`; files via `staffapi/fileOpen` {kind: marksheet | admit_card, exam_student_id}.
- Writes (live): `staffapi/examMarksSave`, `examPublish`, `examRankGenerate`.
- Gates: entry `examination/exam/view`; marks save `examination/exam_marks/edit`; publish `examination/exam_publish/view` OR `examination/exam/edit`; rank `examination/generate_rank/view`; marksheet/admit-card buttons `examination/print_marksheet|print_admit_card/view`.
- Anatomy as pinned: one editable column (width budget in `api/MarksRowLayout`, §5), roster in register order, per-row Absent chip, keyboard-Next focus chain, sticky bar "N of M entered · A absent · B still blank", Save disabled until every row resolves, over-maximum words under the field ("Above the maximum of 50"), partial-save sheet naming each refused row with the service's own reason; refused rows keep their typed values. Publish is preceded by the check-answers sheet listing each subject's entered/total gaps, loaded per subject from `examRoster` counts.

### B2 Library desk — `StaffLibraryActivity`, `StaffLibraryIssueActivity`, `StaffLibraryDueActivity`, `StaffScanActivity` + `qr/AnyCodeDecoder`
- Reads: `staffapi/libraryCatalog`, `libraryMember`, `libraryDueList`.
- Writes (live, `client_txn_id` on each): `staffsync/libraryIssue`, `staffsync/libraryReturn`.
- Gates: entry `library/books/view` OR `library/issue_return/view`; issue/return `library/issue_return/view`; More-screen Due link `library/issue_return/view`.
- Two-step flow (member first, then book) with scan (QR + Code 128/39, EAN, UPC, ITF) or manual code (`IQRS-<id>` understood); due date prefilled +14 days and always sent explicitly; CARD-3 review sheet before issuing; a running this-session list; returns show days late and the service's `fine_note` only — the API's fine is null and **no amount is ever shown**.

### B3 Fee setup — `StaffFeeSetupActivity`, `StaffFeeGroupActivity`, `StaffFeeDiscountActivity`
- Reads: `staffapi/feeSetup`. Writes (live): `staffapi/feeGroupSave`, `feeMasterLineSave`, `feeGroupAssign`, `feeDiscountSave`, `feeDiscountAssign`.
- Gates: entry `fees_collection/fees_master/view` OR `fees_group/view`; group save add|edit per operation; discount assign `fees_collection/fees_discount/assign/view`-family gate as pinned from the PHP.
- Every school-wide save goes through the shared check-details sheet (`W2Ui.checkSheet`): what changes, and the affects-count **on the confirm button** ("Confirm and save — affects N students"). Group assignment is per-student (see §6.1); the sheet's count comes from the service answer's `affects_students`.

### B4 Reports — `StaffReportsActivity`, `StaffReportRunActivity`
- Reads: `staffapi/reportCatalog`, `staffapi/reportRun`; CSV via `fileOpen` {kind:"report", report_key}.
- Gate: More link on `reports` module presence; the catalogue itself decides per-report availability.
- `available:false` entries render greyed **with the service's reason**, never hidden. Results render as labelled cards (first column = heading), totals verbatim from the service; column labels humanised typographically only.

### B5 Behaviour (staff side) — `StaffBehaviourActivity` (+ door from `StaffStudentActivity`)
- Reads: `staffapi/behaviourCatalog`, `staffapi/studentBehaviour`. Write (live): `staffapi/behaviourAssign`.
- Gates: door `behaviour_records/behaviour_records_assign_incident/view` OR `student_incident_report/view`; assign `behaviour_records/behaviour_records_assign_incident/add`.

### B6 HR depth — `StaffMemberEditActivity`, `StaffMyAttendanceActivity`, `StaffPayrollActivity`, `StaffTimelineActivity` (+ doors from `StaffDirectoryActivity` / `StaffDirectoryDetailActivity`)
- Reads: member record via `staffapi/staffTimeline`'s staff block; `staffapi/myAttendance`, `staffapi/payroll`, `staffapi/staffTimeline`, `staffapi/staffRatings`.
- Write (live): `staffapi/staffSave` — the edit form sends **only changed fields** (`api/StaffMemberEdit` whitelist, a subset of the service's own); create requires employee id + name + email + password. Every save ends in a check-changes sheet.
- Gates: edit `human_resource/staff/edit`; create (Directory "New staff member") `human_resource/staff/add`; payroll link `human_resource/staff_payroll/view`; timeline/ID-card doors from the directory detail.
- **Payroll is view-only (D-W2-3):** no edit affordance anywhere; basic, allowances, gross, deductions, tax and net are separate figures, never recomputed. My attendance is personal and always available from My day. Ratings show the approved average with its count and approved/pending chips.

### B7 Lesson & syllabus — `StaffLessonPlansActivity`, `StaffLessonPlanActivity`, `StaffLessonPlanNewActivity`, `StaffSyllabusActivity`
- Reads: `staffapi/lessonPlans`, `lessonPlan`, `syllabusStatus`; class/subject pickers from `staffapi/classes` + `staffapi/syllabusStatus`.
- Writes: `staffsync/lessonPlanSave`, `staffsync/lessonPlanCommentSave` (live, `client_txn_id`); syllabus toggle via outbox (above).
- Gates: plans `lesson_plan/manage_lesson_plan/view`, new plan `…/add`; syllabus `lesson_plan/manage_syllabus_status/view`, toggle `…/edit`.
- Progress is two-level and **always in words** ("7 of 11 topics covered" at subject and lesson level), never a bare percentage. Lesson/topic *creation* is not offered — see §5 item 6.

### B8 Online exams authoring — `StaffOnlineExamsActivity`, `StaffOnlineExamActivity`, `StaffOnlineResultsActivity`, `StaffQuestionBankActivity`
- Reads: `staffapi/onlineExamCatalog`, `onlineExamDetail`, `questionBankList`, `onlineExamResults`; subjects from `staffapi/academicCatalog`.
- Writes (live): `staffapi/onlineExamSave`, `onlineExamQuestionSave` (attach with marks / detach), `onlineExamAssignSave`, `staffapi/questionSave`.
- Gates: entry `online_examination/online_examination/view`; create `…/add`; attach `online_examination/add_questions_in_exam/edit`; assign `online_examination/online_assign_view_student/edit`; bank add `online_examination/question_bank/add`.
- The question form is one-question-per-page and the **class picker is mandatory before anything is written** (the service's FK requirement, §6.3); assignment answers with the service's own students-reached count. Results show real per-student rows (attempted / not taken yet / passed chips).

### B9 Content, Transport, Inventory — `StaffContentActivity`, `StaffTransportActivity`, `StaffInventoryActivity` (+ `StaffStudentTransportActivity`)
- Content: reads `staffapi/contentList`, `contentTypes`; upload via `staffapi/contentUpload` (multipart, stepped flow: details → system file picker); delete `staffapi/contentDelete` {share_id} behind a FORM-4 confirm; files open via `fileOpen` {kind:"document", source:"content", id}. Gate `download_center/upload_content/view|add`.
- Transport: reads `staffapi/transportCatalog`, `studentTransport`; writes `staffapi/routeSave`, `vehicleSave`, `pickupPointSave`, `routePickupPointSave`, `staffsync/transportAssign` (clear = assign with nulls). Gates: `transport/routes/view`, forms `…/add`, assign `transport/assign_vehicle/edit`.
- Inventory: reads `staffapi/itemCatalog`, `itemStock`, `itemIssues` (outstanding filter); writes `staffapi/itemSave`, `itemStockSave`, `inventoryIssue`, `inventoryReturn`. Gate `inventory/item/view|add`. Availability figures are the service's own totals (held / out / on shelf), never derived in the app.

### B10 Certificates & ID — `StaffCertificatesActivity`
- Reads: `staffapi/certificateCatalog`, `studentIdCard`, `staffIdCard`; files via `fileOpen` {kind:"certificate", certificate_id, student_id} and {kind:"id_card"|"staff_id_card", …}.
- Gate: `certificate` module presence. Accepts the `staff_id` extra sent by the directory detail and opens that member's card first. A card whose template is not configured shows the service's fields with the honest not-set-up note and **no file button**; a certificate whose background is not applied shows the service's `background_note` in the file sheet.

### B11–B14 cross-cutting
- **B11 files:** one shared flow (`W2Ui.openFile`): the service's bytes are decoded in the UI layer, saved via `FileDownloader`, opened with the phone's viewer; `file:null` shows the service's reason (+ background note) in a sheet — used by marksheet, admit card, receipt, certificate, ID cards, report CSV, content and finance documents.
- **B12 documents on the student record** ride the same flow (authorised family document read, D-W2-4, was delivered API-side in 2A; the staff-side doors here are behaviour + transport on `StaffStudentActivity`).
- **B13 receipt file:** `StaffFeeReceiptActivity` now offers "See the receipt file" → `fileOpen` {kind:"fee_receipt", invoice_id, sub_invoice_id} (the Wave 1B "no file exists" note is superseded in the class comment).
- **B14 nav slot:** `NavSlots.Dest.LIBRARY` added (icon `ic_books`), availability = `library/books/view` OR `library/issue_return/view`; the librarian preference is now **{LIBRARY, TASKS}** (was {TASKS, DIRECTORY} with a "later wave" comment — the wave has arrived); LIBRARY also joins the general fill order last.

### More-screen additions (all capability-gated)
My day += My attendance (personal, always) · **Exams** section (Exam Centre, Online exams, Question bank) · **Library** section (Library, Books still out) · Money += Fee setup · **Money in, money out and reports** section (Income & expenses, Reports — catalogue-driven) · People += Payroll · **Learning** section (Lesson plans, Syllabus) · **The school** section (Content, Transport, Inventory, Certificates and ID cards).

## 3. Verification

- **Unit suite: OK (287 tests)** — 232 pre-wave baseline + 47 Wave 2B mapper/payload tests (`Wave2BMapperTest`, `Wave2BPayloadsTest`) + 8 layout assertions (`Wave2BLayoutTest`, §4). Mappers are pure Java/org.json pinned to staging captures, per the Wave 1B pattern.
- **Captures:** 73 genuine staging responses pinned in `~/workspace/iqrs-app-v2/fixtures/w2b_*.json` (large payloads trimmed to genuine subsets; base64 bodies truncated; every trim keeps the real envelope and real records). Capture writes were unwound on staging afterwards (the transport assignment was re-cleared, the W2B content share deleted). **Plus 3 CRAFTED fixtures (76 `w2b_*` files in total), labelled crafted in their file names and in the consuming tests** — `w2b_my_attendance_crafted.json`, `w2b_payroll_crafted.json`, `w2b_ratings_crafted.json` — because staging holds no such rows; each was built field-for-field from the Staffapi.php record builders.
- **Banned-strings lint: PASSED** (no LIVE/OFFLINE pills, no sync/outbox/queue/API wording — the offline hold reads "Waiting to send").
- **Checker harness: 0 failed check groups**, run twice — tree-only and against the shipped APK (`--apk-workspace`). Includes the permanent SRC-NOSPACER-IN-ROW guard: the new screens comply by construction (row builders extracted as helper methods so every `Ui.spacer` receiver resolves to a column); the allowlist was not touched.
- **Metadata gate: PASSED** (package, versionCode 26 ≥ floor, versionName 2.13, minSdk 26, targetSdk 34, CAMERA + INTERNET, signature verifies).
- **Contract gate: PASSED** (`tools/contract_check.py` — dummy login rejected, unauthenticated call 401).
- **Live smoke at ship time (curl, staging):** all three fixture logins succeed; admin reads for examCatalog, libraryCatalog, reportCatalog, contentList, certificateCatalog, transportCatalog, itemCatalog all return status 1. Teacher 114's capability map contains no library module (correct — no Library surface for that role). Limited fixture 115 is refused by libraryCatalog itself (see §6.8).
- **Family/Connect:** not modified. Its APK was rebuilt only to prove the shared sources (NavSlots, strings, MarksRowLayout) still compile for both variants; the shipped Connect v2.9 binary in `your_files` is unchanged.

## 4. Layout assertions (proposal §5)

New pure-Java budget class `api/MarksRowLayout` — the marks-entry row's anatomy stated once and read by the screen itself (roll 34dp, name margins 8dp, field 64dp, chip margin 8dp; page 20dp, card 18dp). `Wave2BLayoutTest` pins, in the VisualLayoutTest stand-in-measurer style: the constants; a five-figure mark ("999.9") fits the 64dp field; the name keeps ≥80dp at 360dp, also at font scale 1.3; at 320dp the fixed parts stay whole and the single-line name keeps ≥48dp; and the new **Library** nav label fits its equal slot at the floor size under pessimistic widths, with `NavSlots.label(LIBRARY) = "Library"`.

## 5. Contract surprises (frozen contracts — handled as found, none improvised around)

1. **`feeGroupAssign` assigns a group to ONE student** ({fee_session_group_id, student_id | student_session_id}), not to a class. The app's assignment flow is per-student; the answer's `affects_students` drives the check-sheet count.
2. **There is no `feeMasterLineDelete` endpoint** in the frozen API. Fee lines can be added and edited in the app; no delete is offered (rather than faking one).
3. **`questionSave` lives in Staffapi** (not Staffsync), and options travel as `opt_a`…`opt_e` fields with `correct` naming the key — not as an options object. Also `questions.class_id` is a real FK: the create form cannot submit without a class, so the class picker comes first and Save stays blocked without it.
4. **Parameter names that differ from their siblings:** discount assign takes `fees_discount_id` (with an s); discount save uses `percentage` for a percentage discount and `amount` for a fixed one; group edit id is `fee_group_id`; income/expense save takes `head_id`; route-point linking takes `transport_route_id` (+ `pickup_point_id`, answer `route_pickup_point_id`); content delete takes `share_id`. All captured live and pinned in `Wave2BPayloadsTest`.
5. **Envelope split:** single-record endpoints answer `{status, message, record:{…}}`; list endpoints answer records at the TOP level with `total`/`page`. Many 2A reads type booleans as PHP strings ("True"/"False") while examDetail/roster use real JSON types — `api/W2Json.truthy` handles both, pinned by fixtures of each kind.
6. **The syllabus read carries no `subject_group_class_sections_id`**, which `lessonSave` requires. Lesson/topic *creation* therefore cannot be built without inventing an id — it is omitted (browse + Covered toggle shipped in full) and flagged here for a future API amendment. This is the one proposal item not delivered, for a contract reason, not an effort reason.
7. **Staff create has no role picker:** API-00 exposes only the signed-in member's own capability map; there is no role catalogue endpoint. Create sends the documented required fields; role assignment stays in the web admin until the API offers a catalogue.
8. **Fixture 115 (limited librarian) holds a zero-module capability map** — the school's RBAC grants that account nothing, and `libraryCatalog` itself refuses it ("You do not have permission to view the library catalogue"). Consequences: (a) the app correctly shows that account no Library surface; (b) B14's LIBRARY slot cannot be proven with fixture 115 — it is proven by the NavSlots unit assertions plus the capability logic, and will appear for any real role the school grants `library/books` or `library/issue_return` view. Also noted in 2A: teacher comment rights on lesson plans come from the API's participation branch (creator / created-for / admin), since school RBAC never granted Teachers the comments category — the app simply shows the service's refusal words when they come back.
9. **Library fines:** the API's fine is null with a `fine_note` ("This library does not record fines…"). The app shows days late and the note verbatim; no fine amount exists anywhere in the UI.

## 6. Boundaries held

- Production untouched (no file swaps, no production calls beyond the standing contract check's dummy-login probe pattern used by every wave). Staging writes were fixture-account captures only, and content/transport capture writes were unwound.
- Connect app untouched functionally (see §3).
- No secrets in the tree, fixtures, or this report; fixture passwords appear only in the tasking, never in captures (the battery's stored hashes are the integrity reference and are unchanged).

## 7. Still owed (not this lane's to close)

- **Device gate on Assad's phone:** install v2.13 and walk the Wave 2B surfaces (marks entry save/refusal sheet, library issue/return with a real scan, fee-setup check sheet, syllabus toggle reconciling after send) — headless proof is complete; the phone proof is the programme's standing rule before any 2D production swap.
- The §5.6 syllabus lesson/topic creation forms, if the parent lane amends the API to expose the class-sections link id.

---

## ERRATA — 2026-11-07 (Wave 2B fix lane, v2.14)

- **§2 B6 endpoint name:** the payroll read listed in §2 (B6) as `staffapi/payroll` should read **`staffapi/staffPayroll`**. The shipped app and the staging service both use `staffapi/staffPayroll` (StaffRepository `loadPayroll`; Staffapi.php `staffPayroll()`); the report text was wrong, the app was not. (Checker finding S2-4 in CHECKER-REPORT-wave2b.md.) The original text above is left as written; this note is the correction of record.
