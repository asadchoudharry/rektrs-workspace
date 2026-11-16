# IQRS Family App — Build Report v2.2 (Milestone M2: Family complete)

**Date:** 2026-11-07 · **Variant:** Family only (Admin app not rebuilt, no Admin sources edited)
**APK:** `IQRS-Family-App-v2.2.apk` — 1,024,289 bytes · sha256 `c37119d8c22bf207ccb5c47cac8c5508a03b3b415688afb46638669ad1e877a0`
**Package / version:** `pk.edu.iqrs.family` · versionCode **12** · versionName **2.2** · minSdk 26 · targetSdk 34
**Permissions:** INTERNET only · signed with the existing debug keystore (installs over v2.1)
**v2.1 preserved:** `IQRS-Family-App-v2.apk` untouched (sha256 `cb140eab…`, unchanged)

---

## What M2 added

| Design screen | Status | Notes |
|---|---|---|
| F8 Exams & Results | ✅ Built | Exam list → per-exam detail: summary card (overall %, grade chip, Pass/Fail chip, totals, division, position only when the school generated ranks), subject bars in the design's subject colours, full marks table, exam date sheet. Unpublished result = designed information state. |
| F9 Transport | ✅ Built | Route card + pickup point + own bus (vehicle no., model, driver, tap-to-call), other buses on the route. Not-enrolled information state. |
| F10 Library | ✅ Built | Books out with due chips (amber ≤ 2 days, red overdue) + returned-books history. Not-a-member answer maps to the honest empty state. |
| F11 Profile | ✅ Built | Navy identity hero (initials, name, class · section, gold rule, admission no.), student details, parents & guardian with tap-to-call, children switcher (parents), Settings (dark mode, About school), sign out, "contact the school office" change note. View-only, as designed. |
| F12 More grid | ✅ Updated | Tiles are now exactly the design's seven: Homework, Timetable, Notices, Results, Transport, Library, Profile. Profile header opens F11. About school moved into Profile → Settings (per design). |
| F2 Home bento row | ✅ Added | Results (latest exam, + % once its published result loads) · Transport (route or "Not using transport") · Library (books-out count). Each tile loads and fails independently of the others and of the main sections. |
| Dark mode | ✅ Built | Design §2.1 "night navy" palette (see below), toggle in Profile → Settings. |
| V16 children refresh | ✅ Wired | More screen pull-to-refresh re-fetches a parent's children; a failed/empty answer never wipes the on-device list. |
| V17 module status | ✅ Wired | More tiles for Homework / Results / Transport / Library hide only when the service explicitly reports the section off; any failure leaves tiles visible (fail-open). |

## Endpoints used — all verified from the PHP source

Source root: `~/workspace/iqrs-api/production/api/application/` (`controllers/Webservice.php` + models).

| Endpoint | Request (as the PHP reads it) | Response shape used | PHP reference |
|---|---|---|---|
| `webservice/getExamList` (V10) | POST `{student_id}` | `{examSchedule:[…]}` — rows of `exam_group_class_batch_exam_students` joined with `exam`, `description`, `exam_active`, `result_publish` | Webservice.php `getExamList()`; `models/Examgroup_model.php::studentExams()` |
| `webservice/getExamSchedule` (V11) | POST `{exam_group_class_batch_exam_id}` | `{exam_subjects:[…]}` — subject rows + `subject_name`, `subject_code`, `subject_type` | Webservice.php `getExamSchedule()`; `Examgroup_model::getExamSubjects()` |
| `webservice/getExamResult` (V12) | POST `{student_id, exam_group_class_batch_exam_id}` | `{status:"200", exam:{…}}` with `subject_result[]` (`name, code, get_marks, max_marks, min_marks, exam_grade, attendence, note`), `total_get_marks`, `total_max_marks`, `percentage`, `division`, `exam_grade`, `exam_result_status`, `rank`, `is_rank_generated`. **No `exam` key when unpublished.** | Webservice.php `getExamResult()` |
| `webservice/getTransportroute` (V13) | POST `{student_id}` | Top-level **array**: `[]` when no route; else `[{route row…, vehicles:[{vec_route_id, vehicle fields…, assigned:"yes"/"no"}]}]` | Webservice.php `getTransportroute()`; `models/Vehroute_model.php::getVechileByRoute()` |
| `webservice/getLibraryBookIssued` (V15) | POST `{studentId}` (capital I — verbatim) | Top-level **array** of `{book_title, author, book_no, subject, issue_date, due_return_date, is_returned, return_date}`; non-members get `{success:0, status:401, errorMsg:"No books issued."}` (HTTP stays 200) | Webservice.php `getLibraryBookIssued()`; `models/Librarymember_model.php::checkIsMember()`; `models/Bookissue_model.php::book_issuedByMemberID()` |
| `webservice/Parent_GetStudentsList` (V16) | POST `{parent_id}` (the signed-in parent's user id) | `{childs:[…]}` — full student rows + `class_id, class, section_id, section, student_session_id` | Webservice.php `Parent_GetStudentsList()`; `models/Student_model.php::read_siblings_students()` |
| `webservice/getModuleStatus` (V17) | POST `{user}` = session role | `{module_list:[{id, name, short_code, status}]}` | Webservice.php `getModuleStatus()`; `models/Module_model.php::get()` |
| `webservice/getStudentProfile` (V4, extended) | POST `{student_id, user_type}` | Same payload as M1; M2 additionally maps dob, gender, blood group, roll no., admission date, session, guardian/father/mother contacts, addresses, and the transport fields (`route_title`, `vehicle_no`, `driver_name`, `driver_contact`, `pickup_point_name`) — all present in the model's select list | `models/Student_model.php::get()` |

Supporting change: `ApiClient` gained `postRaw()` (same headers/classification) because V13/V15 answer top-level arrays, which the M1 object-only transport rejected as unparseable. `post()` is now layered on it; classification behaviour is unchanged (the v2.1 fix's test still passes).

## Fixtures & tests (Gate 1)

New fixtures in `fixtures/`, copied field-for-field from the PHP above: `exams.json`, `exam_schedule.json`, `exam_result.json`, `exam_result_unpublished.json`, `transport.json`, `transport_empty.json`, `library_issued.json`, `library_not_member.json`, `children.json`, `modules.json`, `profile_details.json`. New test class `M2MappersTest` (13 tests) registered in `tools/run_tests.sh`.

**Full suite: 51 tests, OK** (38 pre-existing M1 tests still passing + 13 new).

## Gates

| Gate | Result |
|---|---|
| Gate 1 — JVM fixture tests | ✅ OK (51 tests) |
| Gate 3a — banned-strings lint (design lockdown) | ✅ PASSED (all 12 checks) |
| Gate 3b — metadata check on the built APK | ✅ PASSED — package, versionCode 12, versionName 2.2, minSdk 26, targetSdk 34, INTERNET only, signature verifies |
| Admin variant compile check (shared theme/client code changed) | ✅ Builds clean (not shipped; still v2.0/code 10) |
| Dex/resource spot check | ✅ All new screens/mappers present in `classes.dex`; new strings compiled in |

## Dark mode implementation

- `Tokens` now holds two palettes and an `apply(dark)` switch; light values are byte-identical to M1's. Dark values are the design's: bg `#081731`, card `#12264F`, raised `#182F5E`, text `#F4F6FB` / `#A9B7D4`, dividers `#22386A`, gold unchanged, strong colours lightened one step (present `#3ECF8E`, absent `#FF7A85`, leave `#F2B544`).
- Because `NAVY_900` served both as heading text and as chrome background, two tokens were split out: `DEEP` (fixed deepest navy — splash field, text on gold) and `CHROME` (bottom bar / toast — deepest navy by day, raised navy by night). Four call sites changed (Splash, BottomNav, ToastBar, gold button).
- Preference persists on device (`SessionStore`), applied at app start; toggling in Profile → Settings restarts the main stack so every screen rebuilds in the new palette. The Family shell also sets the window status/navigation bar colours from the palette.
- Known polish items (not blockers): the XML `AppTheme` window background/status-bar colour is still the light paper colour (only visible before the first frame draws); a few small navy-on-tint text spots (subject initials, secondary buttons) are lower-contrast in dark mode.

## What could NOT be verified from the PHP source — flagged, not guessed

1. **Module short codes (V17).** The `short_code` values live in the school's `permission_student` table, not in any PHP file. The app matches the Smart School conventional codes (`examinations`, `transport`, `library`, `homework`) and **fails open**: a tile is hidden only on an exact
...[truncated 2085 chars]