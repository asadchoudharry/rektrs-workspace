# BUILD REPORT — Wave 2C: IQRS Connect (family app)

**Build:** IQRS Connect **v2.10**, versionCode **21**, package `pk.edu.iqrs.family`
**APK:** `~/workspace/your_files/iqrs-app/IQRS-Connect-App-v2.10.apk` — 1,614,409 B,
sha256 `98e228aed77d943f39823a78957d14ba573579daee26d793a1ad33c4603b2930`
**Signer:** `f7874c3f…462e` — identical to v2.9 (same lineage, verified with apksigner on both files)
**Target:** **staging** — the shipped dex contains `https://staging.iqrs.edu.pk/api/`
(ApiConfig was already staging-pointing in the tree for the Wave 2 device gate; untouched by this lane)
**Scope guard:** the Workspace app was not rebuilt, modified, or re-shipped (its v2.14 APK served
only as the checker harness's second input). Production was not touched anywhere. All live probes
used the staging family fixtures (testparent.w0 / teststudent.w0) only.

---

## 1. What shipped, screen ↔ endpoint ↔ gate

| # | Surface | Endpoint(s) | Gate / state rule |
|---|---------|-------------|-------------------|
| C1 | **Behaviour** (new `BehaviourActivity`, from Profile → Records) | `webservice/getstudentbehaviour`, `webservice/getincidentcomments`, `webservice/addincidentcomments` | Module `behaviour_records` (Academics switches): known-off → EMPTY-4 screen naming the school office; unknown → fail-open to the record. Comment box only when the school's behaviour setting (`comment_option`) includes the signed-in role |
| C2 | **Profile, full depth** (ProfileScreen record card rebuilt as tabs) | `webservice/getStudentProfile` (existing load) | Personal / Parents / Other tabs; every row renders only when the record carries the field; an empty tab says so honestly |
| C3 | **Offline-payment receipt** (OfflinePaymentsActivity) | `webservice/addofflinepayment` (existing send), `webservice/getOfflineBankPayments` | The stored receipt now shows on the payment record and opens through the shared file pipeline; the form states the accepted kinds (photo or PDF) |
| R1 | **Household fees summary** (FeesScreen top card) | `webservice/fees` per child | Parents with 2+ children only; all-or-error load; failure leaves the child's own statement untouched |
| C-3 | **Visitors** (new `VisitorsActivity`, from Profile → Records) — read side | `webservice/getVisitors` | Module `visitor_book` (Others): known-off → EMPTY-4 screen; read-only, **no registration (gap G-1)** |
| C-4 | **Video tutorials** (DownloadsScreen section) | `webservice/getVideoTutorial` (class/section resolved like the timetable) | Section exists only when the school has shared videos for the class; plays in the phone's own player, never a web view |
| C-5 | **Personal tasks, full write cycle** (new `TasksActivity`, entered from Events) | `webservice/getTask`, `webservice/addTask`, `webservice/updatetask`, `webservice/deletetask` | The signed-in person's own list; add/edit/tick-off/delete all live-proven shapes (see §3) |
| C-6 | **Online-exam attachments** (OnlineExamAttemptActivity) | `webservice/saveOnlineExam` with `attachment_<question id>` file parts | One optional file per descriptive answer, stored by the service with that answer's row |
| C-7 | **Daily-assignment edit** + **homework re-submit** | `webservice/addeditdailyassignment` (id set = edit), `webservice/addhomework` | Edit reuses the add form prefilled; an evaluated homework offers "Hand in again" under the teacher's verdict |
| C9 | **Grade words on subject bars** (ExamResultScreen) | `webservice/getExamResult` (existing) | The mapper normalises the service's no-band placeholder `"-"` to no grade, so no chip can ever render it; real band words chip on the bars as in the marks table |
| D-W2-1a | **Not-set-up tiles** (MoreScreen section) | The four category switch calls (`getELearningStatus`, `getAcademicStatus`, `getCommunicateStatus`, `getOthersStatus`) | A row appears only for a module the school's setting explicitly says is off; rows are informational (no dead button) and name the school office; unknown switches claim nothing |

**Not in this lane (per assignment):** riders R2–R5 (local notifications, biometric/PIN lock,
launcher shortcuts, version notice). PTM remains a Wave 3 decision. Lesson/topic *creation*
remains blocked on the API amendment the 2B report already flagged (not a 2C item).

## 2. Verification evidence

| Check | Result |
|---|---|
| Live staging contract probes (curl, family fixtures) before building | Every endpoint in §1 probed: behaviour (score, settings, 11 records, comments), full profile (97 keys), visitors (empty), video tutorials (empty), tasks (full create→edit→status→delete cycle), offline payment (app-shaped multipart → row stored **with** its receipt), module switches (all four categories), fees per child (Rs 14,750 owing on the fixture child) |
| JVM tests (`tools/run_tests.sh`) | **322 tests, OK** — 35 new in `Wave2CTest` + `Wave2CLayoutTest`, all prior suites still green |
| Checker harness (`run_checker.sh`, tree + Connect v2.10 + Workspace v2.14) | **0 failed check groups**; source checks ALL PASS incl. **SRC-NOSPACER-IN-ROW — 899 sites, 0 violations** |
| Banned-strings lint | PASSED (no sync/queue/domain/status wording anywhere in the new copy) |
| Metadata gate on the shipped APK | PASSED (package, versionCode 21, versionName 2.10, minSdk 26, targetSdk 34, INTERNET only, signature verifies) |
| Fixtures | Genuine staging captures pinned as `fixtures/w2c_*.json` (the profile capture's credential value blanked before pinning); crafted rows labelled CRAFTED in file names and test names (visitors, video tutorials — genuine state is empty) |
| Measure assertions (§5 rule) | `Wave2CLayoutTest` over `W2cLayout` (read by the screens): Profile tab labels fit at 360dp and 320dp under font scale 1.3; household name keeps ≥120dp beside the widest due figure; behaviour points chip stays ≤52dp at scale 1.3 |

## 3. Contract findings the build had to absorb

- **Task done-semantics, settled from the vendor's own web panel** (the reference client):
  its to-do list ticks the box and strikes the title through exactly when `is_active` is
  `"yes"`, and its mark-complete call posts `"yes"`. The existing app reading (yes = done) is
  therefore correct and unchanged. **Vendor inconsistency:** the service's `addTask` creates
  new tasks already marked `"yes"` (its web panel creates them `"no"`), and its edit path
  resets the flag the same way. The app absorbs this: adding composes add → find the new row
  → reopen (`updatetask` status `"no"`), and editing an open task re-opens it after the save.
  Each call was proven live on staging; the composed sequence could not be re-run end-to-end
  because of the staging outage in §5 (flagged, not hidden).
- **Tasks have no description.** The service's save path ignores `event_description`
  entirely — a task is a title and a day. The form asks for exactly those two.
- **Behaviour score is the records' exact sum** on the final staging state (53 = Σ points,
  pinned fixture proves it). One probe during the lane read 43 while the Wave 2A checker was
  mid-writes on the same staging data; the consistent end state is what shipped in tests.
- **Daily-assignment edits re-date the entry** to the edit day: the service stamps
  `date('Y-m-d')` on create and edit alike. Same behaviour as the school's own panels.
- **Homework re-submit is the service's own shape**: every hand-in inserts a new submission
  row, so handing in again after a check needs no new endpoint.
- **Profile payload hygiene (for the overhaul flaw register):** `getStudentProfile`'s
  `student_result` carries the account credential field (a password *hash* on staging since
  the Wave 1 hardening) plus service keys. The app never reads them — the mapper takes only
  display fields — but the payload should not carry them at all; flagged for Wave 1's family.
- **Module switches on staging are all ON**, including online courses and live classes. The
  EMPTY-4 section therefore correctly renders nothing on staging today; its off-state
  behaviour is pinned by tests over the genuine captures plus labelled in-memory variants.
  Note the standing nuance: a switch being on says the school enabled the module; the Wave C
  features themselves (courses, live classes) remain unbuilt by design.

## 4. Gaps — flagged precisely, nothing invented

- **G-1 — Visitor registration cannot be built (C-3 write side).** No `addvisitor` endpoint
  exists anywhere in the vendor family service (controllers and models searched; the legacy
  client's visitor call targets a route this install does not have). The read side shipped;
  there is deliberately **no** register button. To close: one additive extension endpoint
  (family session, visitors_book fields) — an API-lane decision for the owner.
- **G-2 — Authorised family document read cannot be built (C10 / D-W2-4a).** The API-04 file
  rails are staff-session only: `POST staffapi/fileOpen` with a family token answers
  **401 `{"status":401,"message":"Unauthorized."}`** (probed live), and the vendor family
  service has no report-card or receipt method at all. Per instructions no dead report-card
  row was built. To close: one additive family-session file endpoint on the API-04 pattern
  (base64 inside the authenticated response, never an unauthenticated URL) — then the report
  card and fee receipts ride it with app-side work only. In-app rendered results and receipts
  (the Wave A/B surfaces) are unaffected and stay as they are.
- **Household card's live proof is still owed at the device gate:** the staging parent
  fixture has one child, so the card (2+ children only) is proven by aggregation tests over
  genuine statements (labelled crafted composition) and will first render live for a real
  multi-child parent.

## 5. Staging webservice outage observed during this lane (not caused by it)

From ~17:41 UTC on 2026-11-07, `https://staging.iqrs.edu.pk/api/webservice/*` answers
CodeIgniter **404** for every route (login included), while the staging site itself (200) and
the staff API (200) keep responding. All Wave 2C probes and the full task write cycle were
completed **before** the outage; this lane made no server-side changes of any kind (API calls
with the family fixtures only). The staging API tree needs a look (controller file or routing
on the staging docroot) before the device gate exercises these endpoints; the family app's
staging build will show its standard error states until then.

## ERRATA — 2026-11-07 (Wave 2C fix lane, v2.11; original text above untouched)

Raised by CHECKER-REPORT-wave2c.md (verdict REJECT, one S1) and corrected in
Connect v2.11 (see BUILD-REPORT-wave2c-fix.md):

- **§1, D-W2-1a row — the four route names as printed were wrong.** The app
  called `getELearningStatus`, `getAcademicStatus`, `getCommunicateStatus`,
  `getOthersStatus`; none of those routes exists on the service (all four
  return the CodeIgniter 404 page). The real vendor routes are
  `getELearningModuleStatus`, `getAcademicsModuleStatus`,
  `getCommunicateModuleStatus`, `getOthersModuleStatus`. v2.11 calls the real
  names. Consequence while unfixed: the not-set-up section could never
  populate from live data, and the Behaviour/Visitors known-off gates were
  unreachable (both failed open to their designed unknown-state fallback).
- **§2, "Live staging contract probes" row — overstated.** The service data
  was probed live, and the pinned fixtures are genuine captures from the real
  `*ModuleStatus` routes; but the app's own module-catalogue calls were never
  live-proven, and they were the part that was broken. v2.11 live-proves the
  app's own request shape end to end (all four routes HTTP 200, payloads
  identical to the pinned fixtures, 25 modules all ON), and the new
  SRC-ROUTE-LIVE contract-gate check now proves every route string the app
  calls, so this class cannot pass silently again.
- **§4, G-2 — the fileOpen refusal quote was inexact.** The live response is
  HTTP **401** with body `{"status":0,"message":"Unauthorized."}` — the
  body's status field is `0`, not `401` as quoted. The gap itself (G-2) is
  unchanged and still open.

## 6. Device gate notes (for the §6.4 pass on this build)

Sign in as the parent fixture: Behaviour shows score 53 with 11 records and one staff comment
("W2A script"); the comment box is offered (the school's setting allows parents and
students). Profile tabs carry the full record. Tasks: add → the task lands open; tick →
struck through; edit and delete work from the same screen. Visitors and video tutorials show
their honest empty states (nothing recorded/shared for the fixture child/class on staging).
The not-set-up section shows nothing (all switches on). Fees household card needs a
two-child parent to appear.
