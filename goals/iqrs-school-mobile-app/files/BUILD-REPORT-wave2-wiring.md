# BUILD REPORT — Wave 2 WIRING + RIDERS (the last build lane of Wave 2)

Built 2026-11-07 (evening, PKT) from the shared tree `~/workspace/iqrs-app-v2/`.
Both builds staging-pointing (ApiConfig unchanged), same signer as every
previous build, production never touched.

| Artefact | versionCode | Size | sha256 |
|---|---|---|---|
| IQRS-Connect-App-v2.12.apk | 23 | 1,639,280 B | a499bd036f960db0090dfbb7b0258b941e32497a3b09335306906627ed2aec23 |
| IQRS-Workspace-App-v2.16.apk | 29 | 1,725,296 B | d3fd65b3664fb5eaad96386660be0d2722e02771c79fd225d356c2061a5b1a41 |

**Gates (both builds):** unit suite **346 tests OK** (326 prior + 20 new in
`Wave2WiringTest`); **SRC-ROUTE-LIVE 209/209 routes live** (manifest grown by
probe only: 200 → 208 after Connect, → 209 after Workspace); **checker harness
0 failed groups** on the tree and on both shipped APKs (run twice: v2.12 +
shipped v2.15, then v2.12 + v2.16); banned-strings clean (one self-caught
failure — the word "API" in two new code comments — fixed and re-gated);
permissions unchanged (Connect INTERNET only; Workspace INTERNET + CAMERA).

---

## BUILD 1 — Connect v2.12

### 1. Family documents (D-W2-4a) — familydocs/fileOpen
Contract source: BUILD-REPORT-wave2ca-api.md + CHECKER-REPORT-wave2ca.md
(spot-gate proven). New: `model/FamilyDoc`, `api/FamilyDocMapper`,
`FamilyRepository.openFamilyDocument`, `ui/family/FamilyDocOpener` (decodes
the returned file on the background executor, saves it through the existing
FileDownloader directory, opens it with the phone's own viewer — no WebView;
a `file:null` answer shows the service's reason word for word in a calm sheet).

- **Report card** — a "Report card" action on the child's exam screen,
  offered in BOTH the published and unpublished branches: the door itself
  answers honestly, so the unpublished state arrives as the service's own
  sentence, not an error.
- **Fee receipt** — inside the Fees screen's existing receipt view, a
  "Printed receipt" action appears exactly when the statement payload ties
  the payment to its record: the line's `student_fees_deposite_id` plus the
  payment's own key inside `amount_detail` (both now carried by FeesMapper —
  Instalment gained `subInvoiceId`, Line/HistoryEntry gained `depositId`).
  The door renders from that deposit alone, so a wrong document is impossible;
  a mismatched pair can only return `file:null` + reason.

**Live proof (staging, this lane):** fixtures created through the service
itself — exam group 24, exam **16** "W2W Monthly", marks 43/50 for the fixture
child. Before publish: `file:null` + "Results for this exam have not been
published yet." After publish: parent AND student sessions each received a
real PDF (**report-card-16-3699.pdf, 29,310 B**, %PDF verified); a foreign
student was refused with "This report card is not available for your account."
Fee: Rs 100 collected on fixture master 5154 (deposit **3013**, sub **5**) →
**fee-receipt-3013-5.pdf, 28,905 B**, %PDF verified; a bogus pair →
"Receipt not found." Pinned captures: `w2w_doc_card.json`,
`w2w_doc_card_unpublished.json`, `w2w_doc_card_foreign.json`,
`w2w_doc_receipt.json`, `w2w_doc_receipt_missing.json` — all asserted in tests.

### 2. Live Classes screen — the option is ALWAYS present
Contract source: vendor Webservice.php lines 2929/3003 in the held
staging-tree copy (read, not guessed). New: `model/LiveClassData`,
`api/LiveClassesMapper`, `FamilyRepository.loadLiveClasses /
postLiveClassHistory`, `ui/family/LiveClassesScreen`. Entry points: a Home
bento tile and a More grid tile — **neither is module-gated** (owner
requirement 2026-11-07 23:32 PKT); per kind, per child, the three honest
states render in separate cards so one kind's failure never hides the other.

**A real staging target now exists** (created by the coordinator in the
staging admin, manual mode): "W2GMEET Test Class (staging)", Seven–Diamond,
2026-11-08 10:00, teacher Muhammad Waseem. This lane re-proved it directly:

| Read | Result on staging |
|---|---|
| gmeetclasses {student_id:3699} (student session) | exactly that class, with url + date + teacher |
| gmeetclasses {student_id:3699} (PARENT session) | the same class — **the payload is not gated by parent_live_class** |
| gmeetclasses {student_id:2667} (Four–Daffodils) | zero rows — section targeting holds both ways |
| liveclasses {student_id:3699} | zero rows; getzoomsettings → null (no Zoom settings exist) |

**States staging produces today:** Zoom = **NOT_SET_UP** (no settings row —
the honest not-set-up card naming the school office); Meet = **CLASSES**
(one real class, joinable). NONE_SCHEDULED is pinned by unit test
(settings present + empty list).

**Design correction made on evidence:** the first mapper draft gated parents
by the settings row's `parent_live_class` switch. The staging proof (the
coordinator's, then this lane's own parent-session probe) shows the service
hands the classes to a parent session regardless — so the app follows the
service and applies no gate of its own. Recorded here so the decision is
auditable.

**Test-pinned vs live-proven:** Meet row rendering is pinned by the GENUINE
capture (`w2w_live_gmeet_classes.json`). Zoom rows exist nowhere to capture,
so Zoom row rendering is pinned by a labelled crafted fixture
(`w2w_CRAFTED_zoom_classes.json`, built from the service's own column list).
Join hands the class address to the phone after a best-effort history write
(livehistory / gmeethistory — both proven to exist by SRC-ROUTE-LIVE); the
history writes are fire-and-forget by design and were deliberately NOT
exercised with junk rows.

### 3. Connect riders (D-W2-5a remainder)
- **Local notifications** (`data/LocalNotifier` + `api/ReminderRules`):
  new school notices announced once each (first run baselines silently),
  fees-still-to-pay once a day per child, homework due tomorrow once a day
  per child — all raised on the phone from data the app already holds.
  Hooks: Home's notice/fees/homework loads; the staff board in Workspace.
  **Flagged below** (permission gate) — implemented in full, inert on
  Android 13+ until the gate's allowed set changes.
- **App lock** (`api/AppLockRules`, `data/AppLock`, `ui/AppLockActivity`,
  `ui/AppLockGate`): PIN lock, off by default, set/changed/removed from
  More → App lock (Workspace: More → App lock too). Salted SHA-256 digest
  only — the PIN is never stored. Asked at cold start (splash gate) and
  when a signed-in screen resumes after 5 minutes in the background
  (IqrsApp lifecycle watch). Back from the lock goes to the phone's home.
  **Biometric is NOT built — flagged below.**
- **Launcher shortcuts** (`res/xml/shortcuts_family.xml`): Fees,
  Attendance, Student Card — entering through the splash (lock first when
  on), landing via MainActivity's "open" handling. Manifest meta-data
  verified present in the shipped APK.
- **Version notice on Connect: NOT wired — honest flag.** The only
  versions read (staffapi/appVersions) is staff-session-only by contract
  (a family session is refused 401, the proven family-door behaviour);
  the vendor family service has NO version route. Connect does not fake
  a check. The shared `VersionNotice` logic ships and is used by
  Workspace, where the route is real.
- **Notice acknowledgement / permission slips: NOT built — honest flag.**
  No proven endpoint exists: BUILD-REPORT-wave2a-api.md's not-built list
  covers the messaging family and WAVE2-PROPOSAL §4/§8 deferred API-64
  to Wave 3. No route was invented.

## BUILD 2 — Workspace v2.16

### 4. Visitor registration — staffsync/visitorSave through the holding area
Contract source: BUILD-REPORT-wave2ca-api.md (proven 47/0 battery +
checker spot-gate). `SyncPayloads.visitorSave` shares the one visitor
body builder with the existing check-in (identical field set);
`OutboxItem.KIND_VISITOR_SAVE` routes to `staffsync/visitorSave`; the
check-in kind stays for already-queued items. The Visitors form is now a
registration form: name / phone / purpose required; "Here to see" —
nobody in particular (default), a student (search → RosterStudent's
student_session_id), or a staff member (directory search → staff id);
optional people count and note. Saving mints a client_txn_id and places
the write in the "Waiting to send" area; the register reloads after the
established beat. A desk without the front-office permission gets the
service's refusal in the Waiting list — never a made-up success.

**Live proof (staging, app-shaped bodies, fixture staff 113):**
- Register (meet_student_id 3699) → **visitor_id 17**, stored read-back
  shows meeting_with student = "TEST Fixture W0".
- Register (meet_staff_id 114) → **visitor_id 19**; replaying the SAME
  client_txn_id returned visitor_id 19 again and the register holds
  exactly **one** such row.
- Role 8 (no front_office/visitor_book/add) → `status:0` "You do not have
  permission to register visitors" — the service's own words.
- Disclosure: an intermediate proof attempt sent a second registration
  (visitor_id 18) under a different txn id because of a shell-variable
  slip in the proof script itself — a legitimate new row, not a service
  duplicate; the controlled replay above is the valid no-duplicate proof.
  All three rows are named W2W and stay on staging.

### 5. Workspace riders
App lock (shared implementation, More → App lock; DeskActivity +
StaffHomeActivity resume gates + splash gate), launcher shortcuts
(Scan QR / Collect fees / Mark attendance → StaffHomeActivity "open"
landings), staff-board local notifications (same LocalNotifier), and the
**version notice**: StaffHomeActivity reads staffapi/appVersions at
sign-in; `configured:false` (today's genuine answer, pinned as
`w2w_app_versions.json`) stays silent; a newer build becomes a calm
dismissible card (per-version, once a day), below the supported floor
it cannot be dismissed for the day. Decision logic unit-pinned
(NONE / UPDATE_AVAILABLE / UPDATE_REQUIRED).

---

## The three honest flags (decisions for the Checker / owner — NOT made by this lane)

1. **API-64 (permission slips / notice acknowledgement) does not exist**
   as a proven contract. Deferred to Wave 3 by the proposal itself.
   Nothing was built and no route was invented.
2. **Connect has no version-notice source.** appVersions is
   staff-session-only; no family route exists. If Connect must carry
   the notice, a family-reachable versions read is a (small) server-side
   addition for a future lane.
3. **The metadata gate's permission allowed set {INTERNET, CAMERA}
   blocks two rider halves.** (a) **POST_NOTIFICATIONS** is not in the
   set, so the local notifications — fully implemented — cannot post on
   Android 13+ (the system refuses an app that never declared it);
   on older versions the app's notification switch governs. (b)
   **USE_BIOMETRIC** is not in the set, so the PIN lock ships without
   the biometric option (the platform's BiometricPrompt is present in
   the platform jar — the permission is the only blocker). The gate
   file was NOT edited by this lane; amending the allowed set is a
   Checker/owner decision. Both APKs still declare exactly the allowed
   permissions.

## Fixtures left on staging (all named, safe to delete later)
W2W exam group 24 / exam 16 (published, with the fixture child's card),
deposit 3013 (Rs 100, fixture master 5154), visitors 17 / 18 / 19,
and the coordinator's W2GMEET class (id 1) — which the device gate will use.
