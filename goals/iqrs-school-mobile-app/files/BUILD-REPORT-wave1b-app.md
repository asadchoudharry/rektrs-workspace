# BUILD REPORT — Wave 1B (Workspace app on the Wave 1A endpoints)

**Date:** 2026-11-07 · **Builder:** builder agent (Wave 1B) · **Tree:** `~/workspace/iqrs-app-v2/`
**Deliverable:** IQRS Workspace **v2.11 (code 24)** — `~/workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.11.apk`
**Size:** 1,520,201 bytes · **SHA-256:** `7ffad477fee70f3f619a26b305c3a2a6f08400869e14e455f0cbbdec4a6ee732`
**Connect:** unchanged source; rebuilt green as v2.9 (code 20), sha256 `05bb5765b50f7d30dff5d712d4e427ffdfa3e71a7d4556d710a2fa5655943dc9` (build tree only — no new delivery needed).
**Server contact:** none by the builder (no uploads, no swaps). One disclosure in §6.

---

## 1. What was built, against the plan's Wave 1B row (§7.2)

Plan row: *"Role-shaped Home + nav, complete register, fees desk, approvals, notices, directory, my leave/timetable, front-desk core, homework list/submissions."* All of it is in the build.

### Foundations (consumed by every screen)
- **Capability map drives everything** (plan §1.3): `Capabilities`/`CapabilitiesMapper` parse the API-00 payload (roles, per-permission actions, scope, modules_configured). Menus, Home tiles, the More sections and the bottom-bar slots are all shaped by `can(module, key, action)`; nothing is offered that the service would refuse. The teacher capture proves it: fixture 114's map has **no fees_collection module**, and the fees desk simply does not exist for that sign-in.
- **Role-shaped bottom bar** (`NavSlots` + `StaffNav`): Home · slot 1 · Scan · slot 2 · More, icon-above-label (NAV-3), built on Home and More. Preference pairs per plan §5 (Teacher Classes·Marking, Accountant Students·Fees, Admin Classes·Tasks, Receptionist Office·Tasks); unfilled preferences fall through a fixed fill order. **Librarian deviation (documented):** the plan's Library slot is a Wave 2 module; shipping it now would be a dead destination, so librarians get Tasks·Directory via the fill order instead.
- **"Marking" label rename (NAV-2's own remedy):** the teacher's second slot opens the Homework screens, whose titles stay "Homework". Measured with the checker's real-font metrics (jakarta-700.ttf) against the 5-slot bar at 360dp: slot = 63.2dp; "Homework" at the 10sp floor × font-scale 1.3 = **70.3dp — does not fit**; "Marking" = **51.0dp — fits with headroom** ("Checking" 60.6dp also fits, less headroom). Every other slot label fits at the floor (worst: "Students" 57.9dp).
- **Saved writes extended** (`OutboxItem` +12 kinds, `SyncPayloads` builders + endpoint map, `AttentionCopy` refusal wording): notice update/delete, homework update/delete/evaluate, my-leave apply, enquiry save/follow-up, visitor check-in/out, task save/delete — all carrying `client_txn_id`, all worded "Waiting to send" only. Approvals and money-state changes stay **live-only**, per plan §1.2.
- **Repository**: ~35 cache-first reads + live actions added to `StaffRepository`, all on the existing cache-then-fresh pattern with per-card error states.

### Screens (25 new activities, all in the admin manifest)
| Area | Screens | Notes |
|---|---|---|
| Worklist home | StaffHomeActivity (reworked) | Identity → waiting strip → **worklist** (service counts, tap routes via DeskRoutes with the route's own params) → today's figures → quick actions → tools → recent activity. Worklist failure is isolated to its own card. Bottom bar mounts once the map arrives. |
| Attendance register | StaffRegisterActivity | All 10 types (incl. the retired type 2 when it is a student's recorded mark), any date ≤ today, existing marks + remarks pre-filled, on-approved-leave noted, mark-all-present, saves through the existing attendance write incl. edit-from-Waiting. Classes row and Waiting editor both repointed here. Nothing is pre-marked that the service did not record. |
| Student leave | StaffStudentLeavesActivity | Pending/approved/disapproved/all chips; review sheet; live decide; lists refresh/replace honestly. |
| Staff leave | StaffLeaveApprovalsActivity + StaffMyLeavesActivity | Approvals live-only with optional remark; my leave applies as a saved write (type picker from the read, half-day, dates), applications listed with status chips; empty balances on staging are tolerated, not rendered. |
| Fees desk | StaffFeesDeskActivity (Due / Payments / Bank segments, each re-gated by the map), StaffFeeStatementActivity, StaffFeeReceiptActivity, StaffBankPaymentActivity | Due: debounced search, server totals, paging. Statement: per-line Amount·Discount·Fine·Paid·Balance (CARD-2), totals reconcile, deposits tap through to receipts, Collect hands off to the existing collect flow pre-filled. Receipt shows only the receipt's own figures; the captured receipt **is** a discount entry (amount 0, discount 1,000, received 0) and renders exactly that. Bank: pending list → detail from the row (no single-record read exists) → review sheet whose approve button repeats the amount (CARD-3); reject requires a reason. UI wording is "Bank payments" throughout (language lockdown). |
| Notices | StaffNoticesBoardActivity + StaffNoticeDetailActivity | All/Mine chips, audience chips, creator + publish date; detail edits/deletes via saved writes carrying the record's `version` guard; compose stays on the existing screen. |
| Homework | StaffHomeworkListActivity + StaffHomeworkDetailActivity; compose unblocked | List shows the service's own submitted/evaluated counts and a "to check" chip; detail lists every student, evaluates via a saved write behind a review sheet; edit/delete saved writes. **Compose is unblocked**: the subject picker is now fed by the academic catalogue (`subjectsFor(classId, sectionId)`); a section with no group keeps the honest not-configured state and still refuses to save. |
| Directory | StaffDirectoryActivity + StaffDirectoryDetailActivity | Renders what the record carries — the limited view (fixture 115) shows no contact fields and says so once, plainly; full view dials from phone rows. Placeholder joining dates ("0001-11-30") are normalised away. |
| Calendar / tasks / timetable | StaffCalendarActivity, StaffTasksActivity, StaffTimetableActivity | Next-30-days events+holidays grouped by day; tasks open/done with add/toggle/delete as saved writes; timetable Mine/Class with a catalogue-fed section picker. Unconfigured reads render the honest not-configured state naming the school office. |
| Front office | StaffFrontOfficeActivity (capability-gated hub), StaffEnquiriesActivity + StaffEnquiryDetailActivity, StaffVisitorsActivity, StaffCallLogActivity, StaffPostalActivity, StaffComplaintsActivity | Enquiries honour the worklist's follow-up-due route; follow-ups are saved writes that move the next date. Visitors check in/out as saved writes. Call log and postal write straight through (small live books). Complaints: status is derived — assigning a handler is the update; the update form writes assigned/action/note live. |
| More | StaffMoreActivity | Capability-gated sections (My day, Attendance, Money, School office, People, Communication) + Profile + Waiting; hosts the bar with More active. |

### F5 (pre-1B debt) — CLOSED
Workspace student detail: the always-expanded card block is replaced by the **84dp wallet strip**; a tap expands the full CR80 card in place, a second tap collapses it (default collapsed). The checker's `SRC-STAFF-CARD-CONDITIONAL` literals are preserved verbatim and the check passes.

### Connect app
No feature work (per brief). Build green; version untouched (2.9 / code 20).

---

## 2. Gates — all pass

| Gate | Result |
|---|---|
| Unit suite (`tools/run_tests.sh`) | **OK — 232 tests** (199 baseline + 33 new: `Wave1BMapperTest` 23, `Wave1BPayloadsTest` 10) |
| Banned-strings lint | **PASSED** (15/15 checks) |
| Build (`./build.sh both`) | Both APKs built and signed |
| Metadata gate | **PASSED** both apps (package, versionCode 24 / versionName 2.11, minSdk 26, targetSdk 34, CAMERA+INTERNET on Workspace, signature verifies) |
| Checker harness (`run_checker.sh` with both APKs) | **0 failed check groups** — real-font nav table FITS at 360dp × 1.0/1.3 and 320dp × 1.0; all source mechanism checks PASS incl. REG-DIALOG-TEXT, SRC-STAFF-CARD-CONDITIONAL, SRC-DIALOG-SITES-THEMED; dex contains NavFit/CardPreviewLayout/BottomNav/PreviewStrip |
| Contract gate (`tools/contract_check.py`) | **PASSED** (see disclosure §6) |

Test evidence base: 34 real staging captures (`fixtures/w1b_*.json`, taken from the 1A-verified endpoints for fixtures 113/114/115) + 6 crafted fixtures where staging holds no data yet (student/staff leave rows, a pending bank payment, calendar events, tasks, one configured timetable day) — each crafted field-for-field from the service's own record builders.

One correction the captures forced: the teacher's worklist is **3 cards** (attendance_unmarked count **1** — their one section — plus student_leave_pending and homework_to_check at 0), not a single card. The test pins the capture.

## 3. Not built — with evidence
- **My-attendance (API-81)** was not among the 1A endpoints (see the 1A reports); there is no read to build the screen on. "My leave/timetable" is delivered as My Leave + Timetable above.
- **Receipt/slip file**: the receipt read returns `file: null` (API-04 is a later wave) — the receipt screen is the screen copy and says the office prints the paper copy. No print/share of a file is offered.
- **Timetable content**: staging returns empty days (Wave 0 finding — timetable unconfigured). The screens ship and render the honest not-configured state; they light up when the office publishes one.
- **Bank payment detail** has no single-record read in 1A — the detail screen works from the list row; the review answer returns the updated record.
- **Receipt `received_by`** is a bare staff id in the payload, not a name — the row is shown only when the value is not a bare number.
- **320dp × font-scale 1.3** nav overflow remains the owner-accepted known limitation (decided 2026-11-07 12:44 PKT; guarantee baseline is 360dp). The harness table shows it as OVERFLOWS by design of the accepted baseline.

## 4. Device pass still owed (§6.4 checklist)
The 12-state screenshot checklist has **not** been executed — it is owed on Assad's phone on this exact APK, per new screen at 360dp, plus the standing regressions: REG-NAV-ATTENDANCE (bar with role slots on Home + More, both font scales), REG-HOME-CARD (84dp strip; F5 collapse/expand on student detail), REG-DIALOG-TEXT (review sheets + confirm sheets readable). Also owed from earlier waves and unchanged by this build: the §6.4 pass on Connect v2.9 / Workspace v2.10 visuals, the student-card QR scan, and the Subhan fees eyeball.

## 5. Version + files
- `config/admin.properties`: versionName **2.11**, versionCode **24**, apkName `IQRS-Workspace-App-v2.11.apk`. Connect config untouched.
- `build.sh`: the 25 new Workspace activities added to the generated admin manifest.
- New test classes registered in `tools/run_tests.sh`.

## 6. Disclosures
- **`tools/contract_check.py` was run as part of the gate suite.** It is the tree's own pre-existing gate; it probes the production host with exactly two refusal-path calls (a dummy login that is rejected, and an unauthenticated dashboard call that returns 401). No real credentials were used and nothing was written. Flagged here because the brief limited service contact to staging reads; the coordinator may retire or repoint that gate.
- The Wave 1A API itself is **not yet on production** (staging only, per the programme) — this build consumes it correctly but the new screens will only light up end-to-end once the 1A endpoints deploy. Existing Workspace features (dashboard, classes, fees collect, notices compose, QR) run against production exactly as before.
