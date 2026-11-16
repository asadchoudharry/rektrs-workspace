# CHECKER REPORT — Wave 2B: IQRS Workspace v2.13

**Checker:** independent Wave 2B checker (not the builder)
**Date:** 2026-11-07 (PKT)
**Build report checked:** `BUILD-REPORT-wave2b.md`
**Artefact:** `IQRS-Workspace-App-v2.13.apk`
**Package / version:** `pk.edu.iqrs.admin` · versionCode 26 · versionName 2.13
**Size / SHA-256:** 1,679,945 bytes · `8c4e7a22127c1f603494f42f9c787411a4e3bb134df901f9e78de898b83f2771`
**Network boundary for this check:** staging only. Every live probe below was pinned to `https://staging.iqrs.edu.pk/api`. No production URL was called by the Checker.

## Verdict

# REJECT

One **S1** defect defeats a binding Wave 2 §3 design rule: the Exam Centre's publish completeness sheet is not actually a gate. The remaining requested checks pass, including the independent test/harness reruns, 8/8 spot-verified captures, the honesty contracts, the over-maximum marks probe, the disclosed syllabus non-delivery, and the spacer guard.

Per the plan's severity rule, a wave with an S1 defect is rejected outright. The S2 items below are recorded for the fix/re-entry pass.

---

## Findings

### S1-1 — Publish completeness sheet can be bypassed, and can falsely say “ready”

**Rule:** WAVE2-PROPOSAL §3.2 — publishing is a check-answers moment; a completeness sheet comes **first**, ahead of the publish confirmation; “Nobody publishes blind.” The design research wording is the same: the completeness sheet is added **first**, before the FORM-4 confirmation.

**Evidence in the shipped source:**

- In `StaffExamDetailActivity`, the “Check before publishing” button and the Publish button are independent controls:
  - line 118: the check button calls `checkGaps(check)`.
  - line 129: the Publish toggle calls `publish(toggle, !detail.published)` directly.
  - lines 251–262: `publish()` opens only the generic confirmation sheet (“Publish — families will see these results”) and then `doPublish()`. It never calls `checkGaps()`, and there is no state flag recording that a successful check happened.
- The sheet itself does not list every subject with its entered/total count. `checkGaps()` builds only a list of gap strings; `showGaps()` (lines 203–220) displays only those gap subjects. Complete subjects are omitted.
- Worse, a roster load error is treated the same as a completed load: each `onError` in `checkGaps()` only decrements the remaining counter. If every subject roster fails to load, the gap list remains empty and `showGaps()` displays the “every student has a mark or is marked absent in every subject” ready message. An unknown state can therefore be presented as complete.

**Effect:** a user can publish an incomplete exam without ever seeing the gaps, contrary to the build report's claim that publishing is preceded by the check-answers sheet and “never happens blind.”

**Required for re-entry:** make Publish invoke the completeness step and proceed to the confirmation only after every subject roster has loaded successfully; list every subject's entered/total count and name each gap in words; treat any roster load failure as “could not check,” never as ready. Add a test that proves the Publish action cannot reach the confirmation/write path without a successful completeness check.

### S2-1 — B14 librarian pair is correct in code, but the named unit test does not prove the pair

**Evidence:**

- The production code is correct on inspection:
  - `NavSlots.available(..., LIBRARY)` accepts `library/books/view` OR `library/issue_return/view` (NavSlots.java lines 84–86).
  - `NavSlots.preference("…librarian…")` returns `{LIBRARY, TASKS}` (line 98).
  - `StaffNav` maps LIBRARY to the books icon pair and to `StaffLibraryActivity` (lines 95–99 and 155–157).
  - The shipped dex contains `NavSlots$Dest.LIBRARY`.
- `Wave2BLayoutTest.libraryLabelFitsItsNavSlot` proves the “Library” label fits its slot, but `libraryIsTheLibrariansFirstSlot` (lines 90–95) asserts only `NavSlots.label(LIBRARY) == "Library"`. No test calls `slotsFor(caps, "Librarian")` and asserts the ordered pair `{LIBRARY, TASKS}`.
- Fixture limitation, stated honestly: fixture 115 was re-checked live during this pass. Its capabilities response has **0 capability entries**, and `libraryCatalog` refuses it with “You do not have permission to view the library catalogue.” Fixture 115 therefore cannot prove the librarian slot in the running app. This part of the builder's disclosure is accurate.

**Disposition:** S2 evidence debt. Add a direct `slotsFor` pair assertion in the fix pass; do not use fixture 115 as B14 proof.

### S2-2 — The contract gate is staging-only; the shipped APK's active base URL is production

This corrects a possible misreading of the evidence:

- `tools/contract_check.py` is staging-only (`BASE = https://staging.iqrs.edu.pk/api/`) and the Checker's rerun passed against staging (see Gate results).
- The shipped APK itself is **not** staging-pointing. `ApiConfig.baseUrl()` returns `BASE_URL` in source (ApiConfig.java lines 11–18), and the shipped dex's `ApiConfig.baseUrl()` method returns the production string `https://iqrs.edu.pk/api/`. This matches the long-standing v2.12 behaviour; the v2.13 signer certificate digest is also identical to v2.12 (`f7874c3f…462e`).

**Disposition:** S2 release-boundary ambiguity, **not** a finding that the builder changed or contacted production. No production server state was inspected, per scope. But this binary must not be described as a staging-pointing APK. If the Wave 2 device gate is to exercise the staging-only 2A endpoints before the 2D production swaps, the release coordinator needs either a staging-pointing device-gate build or an explicit sequence decision; the shipped v2.13 binary alone does not settle that.

### S2-3 — Fee check-details sheets do not give every value a Change link

**Evidence:** `W2Ui.checkSheet` renders a Change link only when `CheckRow.onChange != null` (W2Ui.java lines 240–248). The group-save and discount-create flows pass focus callbacks, but the fee **line** save rows (StaffFeeGroupActivity lines 287–295) and the fee-group **assignment** rows (lines 333–338) pass `null` for every row, so those sheets show values with no Change link, despite WAVE2-PROPOSAL §3.4's “every value with a Change link.”

The affects-count half of the rule does hold for group/line saves: the service-supplied `affects_students` is shown in the sheet and repeated on the confirm button (W2Ui.java lines 250–259).

**Disposition:** S2 design-rule debt for the fix pass.

### S2-4 — Build report names the wrong payroll endpoint (app is correct)

`BUILD-REPORT-wave2b.md` §B6 lists the payroll read as `staffapi/payroll`. The shipped app and the staging service both use `staffapi/staffPayroll` (StaffRepository.java line 862; Staffapi.php `staffPayroll()`). Documentation typo only; no app defect found.

---

## Gate results (all independently run)

| Check | Result | Evidence |
|---|---|---|
| Artefact identity | PASS | Size 1,679,945 B and SHA-256 `8c4e7a22…2771` re-computed by the Checker; harness metadata gate confirms package `pk.edu.iqrs.admin`, versionCode 26, versionName 2.13, minSdk 26, targetSdk 34, CAMERA + INTERNET, signature verifies. |
| Unit suite | PASS | `tools/run_tests.sh` rerun by the Checker: **OK (287 tests)**. This matches the builder's arithmetic: 232 baseline + 47 Wave 2B mapper/payload tests + 8 layout assertions. |
| Checker harness — tree | PASS | `tools/checker/run_checker.sh`: **0 failed check groups**. Real-font JUnit: OK (5 tests). All source mechanism checks PASS. Banned-strings lint PASS. |
| Checker harness — shipped APK | PASS | `tools/checker/run_checker.sh --apk-workspace <v2.13>`: **0 failed check groups**; metadata gate PASS; shipped-dex mechanism classes present; shipped AlertDialogTheme pins present. |
| Contract gate | PASS | `tools/contract_check.py` rerun by the Checker: dummy login rejected as expected (HTTP 200, status 0); unauthenticated dashboard call returns HTTP 401. Staging only. |
| SRC-NOSPACER-IN-ROW | PASS | Harness output in both runs: **846 sites examined, 0 allowlist-excused**, no row violation. The guard's `SPACER_GUARD_ALLOWLIST` in `check_sources.py` is an empty set — the allowlist was not used to excuse anything. |
| Nav fit evidence | PASS within the gated matrix | 360dp fits at font 1.0 and 1.3; 320dp fits at font 1.0. The nav table's 320dp × 1.3 overflow is the plan's documented known limitation outside the §6.5 guarantee, not a new finding. |
| Device gate | NOT RUN | No phone proof was performed or claimed. This report is harness + staging-live verification only. |

---

## Spot verification of pinned captures — 8/8 genuine

Method: the Checker logged in to **staging** with fixture staff 113 (admin), 114 (teacher) and 115 (limited), re-issued the reads behind eight pinned `w2b_*.json` captures with curl, and compared the pinned records against the live responses. Credentials were taken from the existing staging test script and are not reproduced here.

| # | Capture | Result | Evidence |
|---|---|---|---|
| 1 | `w2b_capabilities_teacher.json` | PASS | Live staff 114: scope `assigned`; `examination/exam_marks/edit` present; `library/books/view` absent — exactly as pinned. |
| 2 | `w2b_exam_catalog.json` | PASS (exact subset) | Every pinned group, exam, grade and division object is present byte-equal in the live catalogue. Live aggregates are larger now (16 groups / 8 exams vs the pinned 12 / 4), consistent with the builder's disclosed trimming of large payloads and later staging fixture activity; no pinned object differs. Exam 4 remains published with rank generated, 1 subject, 48 students. |
| 3 | `w2b_exam_detail.json` | PASS | Live exam 4: 48 students; one subject, Art, max 50 — exactly as pinned. |
| 4 | `w2b_marks_roster.json` | PASS (exact subset) | All 5 pinned roster rows are present in the live 22-row roster with identical student/name/admission/mark/attendance fields; entered/total still 2/22; first pinned row (exam_student 97) still carries mark 32. |
| 5 | `w2b_library_catalog.json` | PASS | Live catalogue still holds exactly books 1 and 2 (`W2A-BK-001` / `W2A-BK-002`) with the pinned titles, ISBNs, quantities and active flags. |
| 6 | `w2b_library_member.json` | PASS (exact subset) | Live member for student 3699 is member 1, card `LIB-S3699`. All 4 pinned history rows are present byte-equal in the now-longer live history (10 rows); every live issue's `fine` is null. |
| 7 | `w2b_report_catalog.json` | PASS (exact) | Live catalogue is identical in structure and content: 57 entries, 19 available, 38 unavailable, and every unavailable entry carries a non-empty reason. |
| 8 | `w2b_syllabus.json` | PASS (exact subset) + missing-id proof | Live syllabus for class 3 / section 2 still returns the same 11 subjects; both pinned topics are present byte-equal among the live topics (live totals now 6/7). A recursive key search finds **no `subject_group_class_sections_id` anywhere** in either the pinned capture or the live response. |

**Conclusion:** the pinned captures checked are genuine staging responses, not fabricated fixtures. Where a capture is a subset, every pinned object survives byte-equal in the live response.

---

## Honesty contracts

### Library fine — PASS (code + live behaviour)

- Code: `LibraryDeskMapper.returnAnswer` maps `fine` to a `Double` only when the service sends a number; JSON null stays null (LibraryDeskMapper.java lines 83–88). `StaffLibraryIssueActivity.showReturned` displays days late and the service's `fine_note` only — there is no branch that renders a fine amount.
- Unit evidence: `Wave2BMapperTest.libraryReturnAnswerHasDaysLateAndNoFine` asserts `fine == null` against the pinned return capture.
- Live behaviour (Checker probe, staging, transaction ids named `W2B-CHK-…`): issued book 1 to fixture student 3699 (issue 11, available-after 2), then returned it. The return answer was `days_late: 0`, **`fine: null`**, with a non-empty `fine_note`; the member's open issues were back to 0 afterwards. No amount was invented at any point.

### Payroll view-only — PASS

- The only payroll network call in the app source is the read `staffapi/staffPayroll` via `StaffRepository.loadPayroll` (line 861–863). A tree search finds no payroll `postAction`, no payroll save endpoint call, and no edit affordance in `StaffPayrollActivity`, which only renders basic / allowances / gross / deductions / tax / net / status / mode / date figures supplied by the service.
- The crafted-fixture disclosure for payroll is accurate: staging holds no payslip rows, and the mapper test is labelled crafted. View-only (D-W2-3) holds.

### Reports unavailable entries — PASS (code + live behaviour)

- Code: `StaffReportsActivity.row` renders an unavailable entry's name and reason in the muted ink (`Tokens.INK_3`), applies row alpha 0.75, shows its reason text (with a generic fallback only if the service sent none), and attaches the click handler only when `available` is true (lines 78–105).
- Live behaviour: the re-issued report catalogue (spot check 7) returns 38 unavailable entries, every one with a reason. Unavailable reports are listed greyed with reasons, never hidden.

### Marks over-maximum refusal — PASS (live staging probe)

The Checker created its own clearly-named staging fixture through the API: group **`W2B-CHK Group`** (id 17), exam **`W2B-CHK Overmax Probe`** (id 9), subject link id 10 with max 50, and assigned class 3 / section 2 (22 exam students).

One `examMarksSave` call then carried two rows for the same subject:

- first roster row: mark **30** (valid);
- second roster row: mark **75** (above the maximum of 50).

The service answered `saved: 1`, `refused: 1`, with the refusal naming the second row's exam_student_id (358) and the reason **“Marks 75 are above the maximum 50 for this subject.”** A roster re-read confirms the valid row holds 30 and the refused row's mark is still **null** — refused per row, never clipped to 50, and the valid row in the same batch still saved.

The app's own entry screen additionally blocks an over-maximum value locally in words (“Above the maximum of 50”) and keeps Save disabled until every row resolves (MarksEntryRules / StaffMarksEntryActivity), which matches the pinned anatomy.

### Other §3 design rules spot-checked

- **Marks-entry anatomy — PASS:** one editable numeric column beside roll + name, labelled Absent chip per row, keyboard-Next focus chain, sticky bar reading “N of M entered · A absent · B still blank”, Save disabled until all rows resolve, and a post-save sheet naming each refused row with the service's reason (StaffMarksEntryActivity / MarksEntryRules; layout budgets pinned by `Wave2BLayoutTest` and re-run in the 287-test suite).
- **Library two-scan — PASS:** member first (scan or typed id/card), then book (scan or typed code), review sheet before issue, a running this-session list, returns from the member/due screens (StaffLibraryIssueActivity). The fine rule above governs the return display.
- **Fee check-details — PASS WITH S2-3:** check sheets and the affects-count on the confirm button are present; the Change-link gap is S2-3 above.
- **Syllabus two-level worded progress — PASS:** subject head and lesson line both render “N of M topics covered” from the same counts; no bare percentage is shown (StaffSyllabusActivity); Covered toggles go through the saved-write outbox and the screen re-reads service counts.

---

## Disclosed non-delivery: lesson/topic creation — CONFIRMED HONEST

- The live `syllabusStatus` response (spot check 8) contains no `subject_group_class_sections_id` at any depth, and neither does the pinned capture. The 2A `syllabusStatus()` builder in Staffapi.php selects subject, lessons and topics without emitting that link id, while `Staffsync.lessonSave` requires it to create a lesson.
- The Workspace syllabus model/mapper carries only `subject_group_subject_id` (LearningMapper / LearningData.SyllabusSubject) — the link id is never modelled, guessed, or derived in the Wave 2B Workspace path.
- A tree search finds **no** Workspace call to `staffsync/lessonSave` or `staffsync/topicSave`. `StaffLessonPlanNewActivity` creates a lesson **plan** via `lessonPlanSave`, which is a different, shipped flow — not syllabus lesson/topic creation.
- The only literal use of `subject_group_class_sections_id` in the shared tree is the pre-existing Connect family read (`FamilyRepository.loadSyllabusLessons`), which sends back an id supplied by the vendor `getsyllabussubjects` response for a read. It is not invented and is not a creation path.

**Conclusion:** the builder's §5.6 disclosure is accurate. Lesson/topic creation is genuinely blocked by the frozen read contract; browse + Covered toggle shipped. No fabricated id exists in the Wave 2B work.

---

## B14 librarian nav — code PASS, evidence S2

See S2-1 for the full grading. Summary: the capability logic (`library/books/view` OR `library/issue_return/view`), the librarian preference `{LIBRARY, TASKS}`, the icon, and the `StaffLibraryActivity` route are all present in source and in the shipped dex. Fixture 115 honestly cannot prove it live (zero-module capability map; the catalogue itself refuses that account). The missing direct `slotsFor` pair assertion is the S2 debt.

---

## Production boundary

- The Checker made **no production contact**: all curl probes and the contract gate used the staging base URL only, and no production server file was inspected or changed.
- Nothing in the supplied build artefacts evidences a production server swap by the 2B lane; the build report states staging-only server work, and the Checker's staging masters responded as expected.
- The one correction is S2-2: the **shipped APK's active base URL is production** (long-standing app behaviour, identical in v2.12). That is a statement about the binary's target, not evidence that the lane touched production — and it must not be reported the other way round.

## Staging side-effects of this check (all staging, all named)

- `W2B-CHK Group` / `W2B-CHK Overmax Probe` exam fixture (group 17, exam 9) remains on staging, clearly named, with one valid mark of 30 saved by the probe.
- One library issue/return round trip (`W2B-CHK-…` transaction ids) was completed and returned; the fixture student's open issues are 0 afterwards.
- No source or fixture files were edited by the Checker. (The mandated test reruns refresh the harness's own generated build directories, as designed.)

## Re-entry conditions

1. Fix S1-1 and add the bypass/error-path test described there.
2. Close or explicitly accept S2-1 (direct librarian pair assertion), S2-3 (Change links on line/assignment check sheets), and S2-4 (build-report endpoint name).
3. Release coordinator settles S2-2's device-gate artefact question before the APK is sent for the phone pass.
4. Checker spot re-entry on the fix build: publish-gate path, full unit suite, checker harness on tree + APK. The §6.4 device gate remains owed after that and is not replaced by this report.

---

# RE-ENTRY — Wave 2B FIX build: IQRS Workspace v2.14

**Checker:** same independent checker (built neither v2.13 nor v2.14)
**Date:** 2026-11-07 (PKT)
**Fix report checked:** `BUILD-REPORT-wave2b-fix.md`
**Artefact:** `IQRS-Workspace-App-v2.14.apk` — 1,684,041 bytes, SHA-256 `eadeea78fa093d9f453b4223bec2ef6e5df2f728bb6df6ce8d2e1704bf6061ed` (both re-computed by the Checker; matches the fix report)
**Package / version:** `pk.edu.iqrs.admin` · versionCode 27 · versionName 2.14 · minSdk 26 · targetSdk 34 (aapt, from the shipped APK)
**Network boundary:** staging only, read-only. No publish was performed and no production URL was called.

## Verdict

# PASS-WITH-NOTES

Every re-entry condition is closed: S1-1 is fixed and proven on the shipped artefact (source path, dex disassembly, unit tests, and a live read-only rehearsal of the gate's inputs), S2-1 to S2-4 are closed, and the regression sweep is clean. The two notes below concern the *form* of evidence for S2-1 and S2-3, not open defects; there is **no S1 and no open S2**.

**Wave 2B is cleared for the device gate.** The §6.4 phone pass remains owed and is to be run with this staging-pointing v2.14, before any 2D production swap; this re-entry does not replace it.

## Per-finding verdicts

### S1-1 — Publish gate: FIXED, proven four ways

- **Source path (`StaffExamDetailActivity` + `api/PublishGate`, read in full):** the Publish toggle's `publish(button, true)` now calls `runPublishCheck(button, true)` — the check is invoked first, unconditionally. `runPublishCheck` builds a `PublishGate` over every subject and loads each register live; the sheet (`showPublishCheck`) on BLOCKED — any register failed, or the exam has no subjects — shows the honest wording (`w2b_publish_blocked` / `w2b_publish_no_subjects`), names each subject that could not be checked, and returns with **no forward control**. On READY/GAPS the sheet lists **every** subject with its entered/total count (`w2b_publish_subject_count`) and names each gap in words; in publish mode the only road onward is the sheet's Continue → the existing FORM-4 confirmation → `doPublish`. Unpublish keeps its direct confirmation, as designed (the gate governs publishing only).
- **Cached copies never settle a subject — verified against the repository contract, not just the activity:** `runPublishCheck`'s `onData` returns early on `fromCache` without settling. The generic `StaffRepository.load()` always follows a cache delivery with a network attempt whose outcome is exactly one terminal callback — fresh `onData(..., false, ...)` or `onError` — so every subject settles exactly once (the gate's first-terminal-result rule double-counts nothing) and no subject can hang unsettled or settle from cache. A subject whose fresh count cannot be had settles as failed → BLOCKED.
- **Shipped-dex proof:** disassembly of the shipped APK's `StaffExamDetailActivity.publish(TextView, Z)` shows the unpublish branch going to its confirmation and returning, and the publish branch falling through to `invoke-direct runPublishCheck(TextView, Z)` with `true` and returning — the gate is in the shipped binary's publish path, and `PublishGate` (incl. `verdict`, `mayProceed`, `recordLoaded`, `recordFailed`) is present in the shipped dex.
- **Unit tests (read line by line, then run):** `PublishGateTest`, 9 tests — unrun check PENDING/cannot proceed; partly settled PENDING; **every register failed → BLOCKED, never ready** (the v2.13 defect, pinned by name); one failure blocks an otherwise complete check; zero-subject exam BLOCKED; all-complete READY; the listing carries every subject with entered/total/missing counts; first terminal result stands; settle signals fire once per subject. All pass in the independently rerun suite (below).
- **Live rehearsal of the gate inputs (read-only, staging, fixture admin 113):** `examDetail` + `examMarksRoster` re-issued by the Checker for both staging fixture exams. Exam 4 ("W2A Script Monthly"): Art entered **2 / total 48** (gate verdict GAPS, Art named). Exam 9 ("W2B-CHK Overmax Probe"): Rhymes & Activities entered **1 / total 22** (GAPS). Both match the fix report's smoke figures exactly. No publish call was made; nothing was written.

### S2-1 — Librarian pair assertion: CLOSED (note on evidence form)

`Wave2BLayoutTest.libraryIsTheLibrariansFirstSlot` now maps a capabilities envelope through `CapabilitiesMapper` and asserts through **`NavSlots.slotsFor(caps, "Librarian")`**: exactly 2 slots, slot 1 = `Dest.LIBRARY` ("Library"), slot 2 = `Dest.TASKS` ("Tasks") — the ordered pair, not the label alone. The test runs green in the suite. **Note:** the capabilities map is crafted in-test and labelled as such in the test's own comment, because fixture 115's live map is empty (proven in the original pass) and cannot exercise the pair in the running app. The pair is therefore proven at unit level through the real `slotsFor` code path plus the capability logic — the remedy this report's re-entry conditions accepted. A live proof on a real librarian account remains a device-gate observation, not a blocker.

### S2-2 — Build target: CLOSED, proven on the shipped APK itself

Disassembly of the shipped v2.14 dex: `pk.edu.iqrs.app.api.ApiConfig.baseUrl()` is `const-string v0, "https://staging.iqrs.edu.pk/api/"` → `return-object v0` — the same mechanism this checker used to prove v2.13 production-pointing now proves v2.14 **staging-pointing**, from the artefact, not from source alone. The fix report's first lines state the staging target and the reason (device gate exercises the staging-only 2A endpoints; production-pointing returns only after 2D).

### S2-3 — Fee check-sheet Change links: CLOSED (note on evidence form)

In `StaffFeeGroupActivity` as shipped in source and covered by the APK harness's mechanism checks: the fee-**line** check rows (fee type / amount / due date) each carry a real callback reopening the new `lineForm(existing, typeIdx, amountText, dueDate, FOCUS_*)` overload with the entered draft values preserved and focus landing on the named field; the fee-group **assignment** rows carry `() -> nameField.requestFocus()` and `() -> assignStudentField.requestFocus()` (the field promoted from render-local to a member, as the fix report states). No row passes `null` any longer. **Note:** no host-side unit test exists for these callbacks (the Checker searched `tests/` — none reference `CheckRow`/`StaffFeeGroupActivity`); they are Android view operations (focus requests, form reopening) that the host JUnit suite cannot exercise, so this item is verified by code inspection. The affects-count half of §3.4 was already proven in the original pass.

### S2-4 — Build-report errata: CLOSED

`BUILD-REPORT-wave2b.md` ends with a dated **ERRATA — 2026-11-07 (Wave 2B fix lane, v2.14)** section correcting `staffapi/payroll` → `staffapi/staffPayroll` in §2 B6, citing this report's S2-4. The original text is otherwise intact: the §2 B6 line (line 53) still reads `staffapi/payroll` as written, and the errata is the correction of record, exactly as required.

## Regression sweep (all independently rerun by the Checker)

| Check | Result | Evidence |
|---|---|---|
| Artefact identity | PASS | Size and SHA-256 re-computed (above); aapt badging from the APK: package `pk.edu.iqrs.admin`, versionCode 27, versionName 2.14, minSdk 26, targetSdk 34. |
| Signer / package continuity | PASS | `apksigner verify --print-certs` on both APKs: v2.14 signer cert SHA-256 `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` — **identical to v2.13**; signature verifies on v2.14. |
| Unit suite | PASS | `tools/run_tests.sh` rerun: **OK (296 tests)** — exactly the builder's arithmetic (287 + 9 new `PublishGateTest`; the strengthened `Wave2BLayoutTest` counts once). Both classes confirmed registered in `run_tests.sh`. |
| Checker harness — tree | PASS | `tools/checker/run_checker.sh`: **0 failed check groups**; banned-strings PASSED; **SRC-NOSPACER-IN-ROW PASS — 848 sites examined, 0 allowlist-excused**. |
| Checker harness — shipped APK | PASS | `tools/checker/run_checker.sh --apk-workspace <v2.14>`: **0 failed check groups**; METADATA GATE PASSED (versionCode 27, versionName 2.14, signature verifies); APK CHECK PASSED. |
| Contract gate | not rerun | Unchanged tool, staging-only; the fix lane's run passed and nothing in the fix touches the contract surface. The Checker's live staging contact in this pass was the read-only gate-input rehearsal under S1-1. |

## Production boundary

The Checker made no production contact: all live calls went to `https://staging.iqrs.edu.pk/api` (fixture admin 113 login, `examDetail`, `examMarksRoster` — all reads). No publish, no writes, no staging fixtures created or altered in this pass.

## What remains owed (unchanged from the original report)

- The §6.4 device gate on the owner's phone, now with this staging-pointing v2.14 (publish sheet walk on a real exam, plus the standing Wave 2 checklist), before any 2D production swap is proposed.
- The Wave 2 sequence continues: 2C Connect, riders, checker full pass, then 2D production swaps per file with owner approval each.
