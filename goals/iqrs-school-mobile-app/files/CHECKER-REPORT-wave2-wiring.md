# CHECKER REPORT — Wave 2 WIRING + RIDERS (Connect v2.12 / Workspace v2.16)

**Checked:** 2026-11-08 (~00:05–00:25 PKT) · **Checker:** independent checker lane (built neither app; did not write the wiring lane's proof scripts — every live claim below was re-probed with the checker's own calls, and every source claim read in the shipped tree / dex)
**Artefacts:** IQRS-Connect-App-v2.12.apk (code 23; 1,639,280 B; sha256 `a499bd036f960db0090dfbb7b0258b941e32497a3b09335306906627ed2aec23`) · IQRS-Workspace-App-v2.16.apk (code 29; 1,725,296 B; sha256 `d3fd65b3664fb5eaad96386660be0d2722e02771c79fd225d356c2061a5b1a41`) — sizes and hashes re-measured on disk, identical to the task pins and the build report.

## Overall verdicts

- **Connect v2.12 — PASS-WITH-NOTES. CLEARED for the device gate now** for documents, Live Classes, PIN lock and launcher shortcuts (and local notifications on pre-Android-13 devices). The Connect version notice and the Android 13+ halves of two riders clear **only with the remediation builds** (Wave 2C-B API + the apps fix build) — recorded as S-notes §5b/§5c, already commissioned by the coordinator; they are not defects of this build.
- **Workspace v2.16 — PASS-WITH-NOTES. CLEARED for the device gate now** for visitor registration, the app lock, launcher shortcuts and the version notice (proven silent under today's `configured:false`). Local notifications on Android 13+ clear **only with the permission remediation build** — S-note §5c.
- **No S1 and no S2 against either build.** Every live behaviour the build report claims was reproduced independently; the three flags in the build report are accurate as stated and are graded as recorded S-notes per the coordinator's adjudications.

---

## Item 1 — Family documents (familydocs/fileOpen) — **PASS**

Checker's own family-fixture calls against staging (parent 7396 + student 7397 sessions):

- **Published report card (builder's W2W exam 16, child 3699):** parent session → `report-card-16-3699.pdf`, declared size **29,310** == decoded length **29,310**, `%PDF` header verified. Student session → the identical real PDF (29,310 B). The shipped path (not just the endpoint) is what the build exercised and what the pinned captures assert; the endpoint behaviour the app depends on is exactly reproduced.
- **Unpublished exam:** the checker built its **own** fixture (group 25 / exam 17 "W2W-CHECK Unpub Monthly", Seven–Diamond assigned, never published) → `file:null` + **"Results for this exam have not been published yet."** — the exact service sentence.
- **Foreign student (parent → 2397, exam 16):** `file:null` + **"This report card is not available for your account."**
- **Reason rendering (source):** `FamilyDocOpener` shows `doc.reason` **verbatim** in a calm bottom sheet whenever `file` is null (a stock fallback appears only if the reason itself is empty); on success it decodes `content_base64` on the app's IO executor, saves through the existing `FileDownloader` directory and opens with the phone's own viewer via `FileDownloader.open` — no WebView anywhere in the path.
- **Fee receipt (real deposit 3013 / sub "5"):** parent session → `fee-receipt-3013-5.pdf`, declared **28,905** == decoded **28,905**, `%PDF` verified.
- **Bogus pair (invoice 999999):** `file:null` + **"Receipt not found."** — B13's verbatim reason.
- **Receipt action visibility rule (source):** `FeesScreen` adds the "Printed receipt" action only under `depositId != null && !depositId.isEmpty() && !in.subInvoiceId.isEmpty()`. Provenance verified in `FeesMapper`: `Line.depositId` is read from the line's `student_fees_deposite_id` (line 93), and instalments are parsed out of `amount_detail` (`{"1": {entry}, "2": {entry}}`) with the payment's own key carried as `Instalment.subInvoiceId`; `HistoryEntry` propagates the pair. The door renders from that deposit alone, so a wrong receipt cannot be produced — a mismatched pair can only return the service's reason.
- **Report-card action placement (source):** `ExamResultScreen.renderResult` adds `reportCardAction()` in **both** branches (unpublished and published), posting `{kind:"report_card", exam_id, student_id}` for the *selected* child.

## Item 2 — Live Classes — **PASS**

- **Option always present, never module-gated (source):** the Home bento tile (`HomeScreen`: "Wave 2 wiring: Live Classes — ALWAYS here…") and the More grid tile (`MoreScreen`: "deliberately NOT one of the module-gated tiles") are both added unconditionally; the neighbouring gated tiles use the catalogue-controlled fields, this one does not.
- **State machine vs staging reality (mapper + own probes):** `LiveClassesMapper.stateFor` = no settings row → NOT_SET_UP; settings row + empty list → NONE_SCHEDULED; settings row + rows → CLASSES. Checker's probes: `getzoomsettings` → `live_classes: null` ⇒ **Zoom = NOT_SET_UP** on staging, as claimed; `getgmeetsettings` → a settings row exists ⇒ Meet resolves by its class list.
- **The genuine W2GMEET class, both sessions:** `gmeetclasses {student_id:3699}` returned **exactly one row** — id 1, title "W2GMEET Test Class (staging)", url `https://meet.google.com/abc-defg-hij`, date `2026-11-08 10:00:00`, teacher fields present — for the **student** session and identically for the **parent** session. The mapper maps title/url/date from the genuine payload shape and joins `staff_name` + `staff_surname` for the teacher.
- **Section targeting both ways (own probes):** `gmeetclasses {student_id:2667}` (Four–Daffodils) → **zero rows**; the class reaches Seven–Diamond only.
- **No parent_live_class gate in shipped logic — and stronger live proof than the build report claims:** the staging Gmeet settings row carries `parent_live_class = '0'`, yet the parent session above was handed the class. The app follows the service: `parentLiveClass` is parsed into `LiveClassesMapper.Settings` but has **no consumer anywhere in src/ or tests/** (grep-verified); `stateFor` never reads it. The builder's draft correction is confirmed in the shipped code.
- **Join (source):** `LiveClassesScreen.join` fires the history write, then immediately `startActivity(ACTION_VIEW, Uri.parse(e.joinUrl))`. `FamilyRepository.postLiveClassHistory` runs on the IO executor and swallows every exception (`catch (Exception ignored)` — livehistory for Zoom with `conference_id`, gmeethistory for Meet with `gmeet_id`); the join never waits on it and cannot be failed by it. Rows without a URL render the no-link caption instead of a dead button (`e.canJoin()`).
- **Disclosed limit (accepted):** Zoom class rows exist nowhere on staging, so Zoom row rendering is pinned by the lane's labelled crafted fixture; Meet rendering is pinned by the genuine capture. This is the same evidence posture the programme accepted for the 2C-A spot-gate.

## Item 3 — Visitor registration (Workspace) — **PASS**

Checker's own writes through the app's payload shape (`SyncPayloads.visitorSave` field set, `client_txn_id` minted per write):

- **Registration lands:** staff 113, meet_student_id 3699 → `status:1`, **visitor_id 20**; the write's response record carries `meeting_with: "student"`.
- **Read-back with the meeting resolved:** `staffapi/visitorList` (2026-11-08) shows row 20 with `meeting_with = {"type":"student","id":3699,"name":"TEST Fixture W0","admission_no":"TEST-W0-001"}` — the meeting is resolved to the real student, not an id echo.
- **Replay creates no second row:** re-sending the identical body + `client_txn_id` returned visitor_id **20** again; the register holds exactly **one** "W2W-CHECK Visitor" row.
- **Role 8 (fixture 115):** `status:0` + **"You do not have permission to register visitors"** — the service's own refusal text, exactly as the form would surface it from the Waiting list.
- **App-side contract (source):** `StaffVisitorsActivity` mints the txn via `sender.mintTxnId()`, builds via the shared `visitorBody` (one builder for check-in and registration — identical field set), and enqueues `OutboxItem.KIND_VISITOR_SAVE`, which `SyncPayloads.endpointFor` routes to `staffsync/visitorSave`. My probe body is byte-equivalent in shape to what the form sends.
- **The visitor-18 disclosure — CHECKED against the register, holds:** today's register carries the lane's three named rows — **17** ("W2W Visitor 190009", student meeting, "W2W registration proof"), **18** ("W2W Visitor", student meeting, same proof purpose), **19** ("W2W Replay 190041", **staff** meeting id 114, "W2W replay proof", exactly one row). Rows 18 and 19 are distinct registrations under distinct txn ids (18 = the lane's disclosed second legitimate write from its proof-script slip; 19 = the controlled replay subject, whose replay the lane proved and whose semantics my own replay of row 20 independently reproduces). Two rows with distinct txn ids are two legitimate writes — **not** a service duplicate. The idempotency contract (same txn → same id → one row) is proven by rows 19 and 20 alike.

## Item 4 — Riders as shipped — **PASS** (with §5c applying to two halves)

- **PIN lock:** `AppLock.isEnabled()` = stored flag (default **false**) **and** a PIN exists → **off by default**. Storage (`data/AppLock`, prefs `iqrs_applock`) holds only `salt`, `digest`, `enabled`: `setPin` stores `AppLockRules.digest(salt, pin)` — salted SHA-256 over `salt + ":" + pin` with a 16-byte `SecureRandom` salt; verification recomputes and compares in constant time. A tree-wide grep for PIN-bearing `putString` finds exactly **one** hit — the digest write itself; **no plaintext PIN exists in code or storage**. Gates: `SplashActivity` checks `needsUnlock()` at cold start (line 97); resume gates call `AppLockGate.maybeLock` from family `MainActivity`, staff `StaffHomeActivity` and `DeskActivity`; the rules' background grace is **5 minutes** (`GRACE_MS`), spent via `AppLock.noteForegrounded`. The lock screen itself is exempt from the gate.
- **Launcher shortcuts:** source XMLs present for both apps (family: Fees / Attendance / Student Card → SplashActivity with `open` extras, targetPackage `pk.edu.iqrs.family`; admin: Scan QR / Collect fees / Mark attendance, `pk.edu.iqrs.admin`). **In the shipped artefacts:** `aapt dump xmltree` shows the `android.app.shortcuts` meta-data on the launcher activity of **both** APKs (@0x7f070001 family / @0x7f070000 admin).
- **Local notifications — implemented:** `LocalNotifier.ensureChannels` creates two channels (notices + reminders) from `IqrsApp.onCreate`; triggers fire from data the app already holds — new notices announce-once (`ReminderRules.freshIds`/`remember`; first run baselines), fees-still-to-pay once a day per child and homework-due-tomorrow once a day per child (`dueToday`), hooked at `HomeScreen`'s notice/fees/homework loads, plus staff-board notices in Workspace. Posting on Android 13+ is blocked **only** by the undeclared permission — §5c.
- **Version notice:** Workspace reads `staffapi/appVersions` at sign-in (`StaffRepository.loadAppVersions` → `StaffHomeActivity.loadVersionNotice`/`renderVersionNotice`). The checker's own staff probe tonight: `{"configured": false, "connect": null, "workspace": null}` — under which the shipped decision logic stays **silent**, as claimed (and the decision set NONE / UPDATE_AVAILABLE / UPDATE_REQUIRED is unit-pinned in the green suite). Connect carries no such call — §5b.

## Item 5 — Known flags, graded as recorded S-notes (verified as stated; not re-litigated)

- **(a) API-64 permission slips / notice acknowledgement — NOT BUILT. S-note, accepted.** No proven endpoint exists; WAVE2-PROPOSAL §4 #5 defers API-64 to Wave 3 by design ("it deserves its own workflow design… Wave 3 opener", restated in §8's deferred list). No route was invented: the shipped route set (Item 6) contains no slip/ack route.
- **(b) Connect version notice — NOT WIRED. S-note, remediation in flight.** Source confirms the only `appVersions` caller is `StaffRepository` (staff session); a family session is refused at that door (the proven family-door behaviour from the 2C-A gate). The coordinator's Wave 2C-B amendment (family-readable `appVersion` on the Familydocs rails) is the commissioned fix; Connect clears this note only when the apps fix build wires it.
- **(c) Manifest permissions — MEASURED on the shipped APKs (`aapt dump permissions`):** Connect v2.12 declares **only** `android.permission.INTERNET`; Workspace v2.16 declares `android.permission.INTERNET` + `android.permission.CAMERA`. **`POST_NOTIFICATIONS` and `USE_BIOMETRIC` are absent from both**, exactly as flagged — so the remediation delta (the coordinator's allowed-set expansion to {INTERNET, CAMERA, POST_NOTIFICATIONS, USE_BIOMETRIC} + the fix build) is precisely measurable against this baseline: +POST_NOTIFICATIONS/+USE_BIOMETRIC on Connect, +POST_NOTIFICATIONS/+USE_BIOMETRIC on Workspace, nothing else.

## Item 6 — Regression sweep — **PASS** (artefacts); two tree-state observations

- **Unit suite, re-run by the checker:** `tools/run_tests.sh` → **OK (346 tests)** — the claimed count exactly (326 prior + 20 `Wave2WiringTest`).
- **SRC-ROUTE-LIVE, re-run live by the checker:** **209/209 routes exist on staging** for the route set the shipped builds contain (familydocs/fileOpen and staffsync/visitorSave among them, probed, not manifest-trusted); manifest refreshed from the checker's own probes (staging base). A subsequent live run over the *current* tree reads **210/210** — the 210th route is the remediation lane's `familydocs/appVersion`, **absent from the shipped v2.12 dex** (dex string census: only `familydocs/fileOpen`), i.e. the delta belongs to the fix build, not to these artefacts.
- **Checker harness on tree + both APKs:** with the shipped versions pinned via the harness's own `--expect-connect 2.12 --expect-workspace 2.16` overrides, **both APK CHECKs PASS** — metadata gates (package, versionCode 23/29, minSdk 26, targetSdk 34, permission sets exactly as §5c, **signature verifies**), mechanism classes in dex, REG-DIALOG-TEXT in shipped resources; **BANNED-STRINGS gate PASSED**; offline **CONTRACT GATE PASSED**. Font/nav/card source groups pass.
  - *Why the pins were needed (observation, not a defect):* the tree's `config/family.properties` / `config/admin.properties` already read **2.13 / 2.17** — the parallel remediation fix build has advanced the tree past the shipped builds. An unpinned harness run fails the Workspace metadata group on versionName alone (expected 2.17 vs shipped 2.16): the H1 expectation mechanism working as designed against a moving tree, **not** an artefact defect. The same mid-check tree motion produced one further transient: the remediation lane's new file `ui/VersionNoticeCard.java` (mtime during this check; present in **neither** shipped dex — string census 0/0) trips SRC-NOSPACER-IN-ROW at its line 72 in the latest tree state. That finding belongs to the fix build's own checker pass and is handed over here for the record; it does not touch v2.12/v2.16, whose shipped sources predate the file.
- **Signer:** `apksigner verify --print-certs` → SHA-256 `f7874c3f…3bda462e` on **both** new APKs, identical to v2.11 and v2.15 (all four measured in this pass).
- **Staging targets in the shipped dexes:** `ApiConfig.baseUrl()` disassembles to `const-string "https://staging.iqrs.edu.pk/api/"` in **both** v2.12 and v2.16 (dexdump-verified; the production constant exists in source but is not what `baseUrl()` returns). Version codes badging-verified: family 23 / admin 29.
- **Prior artefacts byte-identical:** Connect v2.11 sha256 `8faef355…` and Workspace v2.15 sha256 `5e1feda4…` re-hashed in this pass — untouched by the wiring lane.

---

## What clears when

- **Cleared for the device gate NOW:** everything in Items 1–3; the PIN lock, shortcuts and (pre-Android-13) notifications in Item 4; the Workspace version notice's silent state.
- **Clears only with the remediation builds:** Connect's version notice (§5b — needs the 2C-B endpoint + the fix build's wiring), local notifications on Android 13+ and the biometric half of the app lock (§5c — needs the two permissions declared). API-64 (§5a) is Wave 3 scope, not a remediation item.
- **Device-gate note for the owner pass:** the W2GMEET class (2026-11-08 10:00, Seven–Diamond) is the live Join target; the fixture child's parent/student sessions are the ones proven above.

## Fixtures the checker left on staging (all clearly named)

- Exam group 25 / exam 17 "W2W-CHECK Unpub Monthly" (unpublished; fixture child assigned; the unpublished-reason proof).
- Visitor row 20 "W2W-CHECK Visitor" (meet-student registration + its idempotent replay).

Production was never contacted.
