# IQRS Two-App Build Report — Family + Admin APKs

Built 2026-11-06 from the v1.1 shell (`~/workspace/iqrs-apk-shell/`), build trees kept at
`~/workspace/iqrs-apk-two/{family,admin}/` (each with its own `build.sh`, sources and assets,
fully reproducible). The previous combined APK (`IQRS-School-App.apk`, `pk.edu.iqrs.app`)
was **not** modified (sha256 `34893a7b…`).

## Deliverables

| APK | Package | Label | Version | Size | SHA-256 |
|---|---|---|---|---|---|
| `IQRS-Family-App.apk` | `pk.edu.iqrs.family` | IQRS Family | 1.0 (code 1) | 1,398,137 bytes | `2e032c98…` |
| `IQRS-Admin-App.apk` | `pk.edu.iqrs.admin` | IQRS Admin | 1.0 (code 1) | 1,410,558 bytes | `775ad00b…` |

Both: minSdk 26 (Android 8), targetSdk 34, permissions **INTERNET + CAMERA only**,
debug-signed with the existing `iqrs-debug.keystore` (same signer as v1.1).
The three packages (`pk.edu.iqrs.app`, `.family`, `.admin`) can be installed side by side.

## How each app was made (smallest coherent changes to the shared shell/bundle)

Shared shell changes per variant: AndroidManifest package + label; the Admin shell's
loopback asset server base port moved 18765 → **18766** so the two apps never collide.
The bundle is still served from the loopback HTTP origin inside the app (the v1.1 lesson —
WebView blocks ES-module scripts from `file://`).

**Family app** — the bundle's entry handler was patched so *any* entry from the welcome
screen lands in family mode (`onEnter` now forces `"family"`), and CSS in `index.html`
hides the staff card, the guest button and the app-switcher button. The app therefore
opens on the Student & Parent side only. Family live login is exactly as already wired:
native bridge → `POST https://iqrs.edu.pk/api/auth/login`, session persisted
(`iqrs_live_session` in localStorage), 401 → session-expired handling in the bundle.

**Admin app** — the bundle's initial mode was patched to `"staff"` and `onEnter` forces
`"staff"`, so it opens straight into the Teacher/Staff/Admin side (staff/guest cards and
the switcher hidden by CSS). Because the bundle's own data layer talks to an absent
backend and cannot be re-pointed at the school API from outside, the live staff features
are delivered by a **companion module** (`assets/iqrs-admin.js` + `iqrs-admin.css`,
loaded by `index.html` before the bundle; its UI lives outside the React root so React
re-renders never remove it). It appears as a floating **“⇅ Staff Sync”** button (with a
pending-count badge) in the staff app and provides:

- **Real staff login** through the native bridge → `POST /api/staffauth/login`
  (staff email + password). Session `{staffId, token, role, name, email, employeeId}`
  persisted in localStorage (`iqrs_staff_session`); authenticated calls send
  `User-ID` + `Authorization` exactly as the API contract requires. Any 401 from a
  staff/sync endpoint switches the companion to a *session-expired* state that asks for
  the password again; sign-out clears the session (the queue is preserved).
- **Live dashboard**: `POST /api/staffapi/dashboard` (students/teachers/staff/classes +
  today's attendance totals) shown in the panel, cached in localStorage
  (`iqrs_staff_dash`) so the last live figures remain visible offline.
- **Offline outbox** (below).

## Outbox design

- Storage: localStorage key `iqrs_staff_outbox` on the app's loopback origin
  (survives app restarts — verified, see Tests). A plain classic script storage layer was
  used because the bundle's own state is in-memory only.
- Every write op is created with a **UUID `client_txn_id`** and stored as
  `{txn, kind, path, body, label, staffId, createdAt, state}`. The `client_txn_id` is
  added to the POST body at send time, so the *same* id is reused across retries —
  the server's idempotency log makes a re-post return the stored response with
  `"duplicate": true`, which the outbox counts as **delivered**.
- Flush triggers: app start, the browser `online` event, opening the panel, and a
  manual **Sync now** button. Flush is sequential (FIFO).
- Outcomes: `{status:1}` or `duplicate:true` → delivered and pruned. Network failure
  (bridge status 0 / no bridge) → stop, op stays `queued`. HTTP 401 → flush pauses,
  session-expired state shown, **queue preserved**. `{status:0}` business rejection →
  op marked `rejected`, the server's message is shown on the op, and it is removed
  **only** when the user taps Dismiss (or Try again to re-queue it) — never silently
  dropped. Ops queue only under the signed-in staff account; a queue created by one
  staff member will not flush under a different sign-in.
- Covered operations (Staff Sync panel forms, all queue-first — usable fully offline):
  **QR attendance** (camera scan via `BarcodeDetector`+getUserMedia where the WebView
  supports it, plus manual code entry — code may be the QR text, `IQRS-<id>`,
  roll/admission no.), **class attendance** (class/section/date + one line per student:
  `student_id attendance_type_id`), **homework** (class/section/subject-group-subject id,
  dates, description), **notice** (title, message, student/parent/staff visibility),
  **fee collection** (below).

### Fee collection identifiers

The panel's fee form needs `student_fees_master_id` + `fee_groups_feetype_id`.
Online and signed in, **Look up** calls `POST /api/staffsync/feeInvoice`
`{student_session_id}` and lists the payable lines found in the response; tapping
“Use this line” fills both IDs. Offline, a fee op can be queued only when both IDs are
already known (from an earlier lookup or the printed challan) — the form says so
explicitly, and validation refuses to queue without them.

## Verification performed

1. **apkanalyzer** on both APKs: package ids, labels ("IQRS Family" / "IQRS Admin"),
   versionName 1.0 / versionCode 1, minSdk 26, targetSdk 34, and exactly the two
   permissions INTERNET + CAMERA.
2. **Headless-Chromium render checks** (Chrome for Testing 157, assets served over the
   same loopback HTTP origin the shell uses; console captured via CDP):
   - Family: page renders (not blank); staff card and guest button compute to
     `display:none`; clicking the (hidden) staff card's *“Enter Staff App”* button still
     lands in the **Family** app — header “Hello Parent 👋 / Student & Parent App”,
     no staff QR control. No JS exceptions. (Only console noise: two 501s from the
     bundle POSTing to its absent Space backend on the test's GET-only static server —
     the bundle degrades to its offline state, same as the standalone v1.1 build.)
   - Admin: opens straight into “Staff & Admin App” (“Hello Teacher 👋”); companion
     booted (`data-ia="ready"`), floating Staff Sync button present; panel opens with
     the sign-in form and sync queue; a dummy sign-in attempt returns the honest
     “Could not reach iqrs.edu.pk” outcome in the desktop harness (no native bridge
     there) and does **not** persist a session; notice + QR ops created through the
     real forms were queued with 36-char UUID transaction ids and the pending badge
     updated to 2. **Persistence test:** after a graceful browser shutdown and
     relaunch with the same profile, the queued op was still present and the badge
     restored (an earlier abrupt-kill run lost the last write to a storage-flush race
     in the test harness; clean lifecycle shutdown — the normal Android app case —
     persists correctly). No JS exceptions in either run.
   - Both patched bundles pass `node --check` (ES-module syntax).
3. **Bridge contract checks with curl** (production, dummy data only — no real login
   attempted):
   - `POST /api/staffauth/login` with a non-existent user →
     `{"status":0,"message":"Invalid Username or Password"}` ✓
   - `POST /api/staffsync/attendance` without a token →
     HTTP 401 `{"status":401,"message":"Unauthorized."}` ✓
   - `POST /api/auth/login` (family path) with a non-existent user →
     `{"status":0,"message":"Invalid Username or Password"}` ✓

## Honest limitations

- **No real staff credentials exist in this workspace**, so a genuine staff login,
  a live dashboard fetch and an end-to-end sync delivery could not be exercised;
  they are verified against the documented contracts, the Phase-B production
  behaviour, and the dummy/401 checks above. First real test: sign in with a real
  staff account, queue a notice offline, go online, confirm it appears in the web app.
- The companion panel is the live-data path for staff. The bundle's built-in staff
  screens still read/write the bundle's own (absent) backend, exactly as in v1.1 —
  they were designed around the Space backend, and re-wiring every built-in screen
  was not possible from the built bundle in one pass. All five required write actions
  (attendance, QR, homework, notice, fees) are covered by the companion outbox.
- Fee invoice lines from `feeInvoice` are detected generically from the response
  (objects carrying the two IDs); if the live response shape differs, the IDs can
  still be typed manually — the queue/send path is unaffected.
- Outbox persistence relies on the WebView keeping the same loopback origin/port
  (the shell's deterministic port selection, base 18766 for Admin); clearing the
  app's storage would clear the queue, like any local outbox.
- QR camera scanning depends on WebView `BarcodeDetector` support; where unsupported,
  the manual code entry performs the identical queued operation.
- Both APKs are debug-signed for owner testing, same as v1.1 — a release keystore is
  needed before any Play Store distribution.

---

## v1.1 student-id fix (2026-11-06, evening)

**Bug.** First real student login on device (AIKA SAJID, adm. no. IQ-STU2328) succeeded, but Home showed "Dashboard unavailable" and the header stayed OFFLINE. Cause, proven from the vendor API source: the bundle's live-session child resolver `_u(session, idx)` computed the student-branch child id from `record.id`, which in the vendor login response is the **users-table id**, not the student id. The real student id is in `record.student_id` (the parent branch already used `student_id` from `parent_childs` correctly). Every student live call — `webservice/dashboard`, `webservice/getStudentProfile`, `webservice/getAttendenceRecords`, `webservice/fees` — therefore sent the wrong `student_id`. All of those calls derive their id from `_u`'s return value (verified by auditing every `student_id:` payload in the bundle; the only other `a.id` hit is a React list key for notices, not an id derivation).

**Patch** (exact string replacement, once per file, in `assets/assets/index-nqk2ms3q.js` inside BOTH build trees `~/workspace/iqrs-apk-two/{family,admin}/` and in the canonical shell bundle `~/workspace/iqrs-apk-shell/assets/assets/index-nqk2ms3q.js` so future builds inherit it):

- Before: `let a=e.record;return{id:nl(a.id)??(e.userId||null),…`
- After:  `let a=e.record;return{id:nl(a.student_id)??nl(a.id)??(e.userId||null),…`

The parent branch was not touched. Fallback order: `record.student_id` → `record.id` → session `userId`.

**Version bump.** Both variants: versionName 1.0 → **1.1**, versionCode 1 → **2** (in each tree's `src/AndroidManifest.xml`), so Android installs over the delivered v1.0. Package ids, labels, min/target SDK and permissions unchanged.

**Verification.**
- Patched expression present exactly once and old expression absent in the bundle extracted from each built APK.
- `apkanalyzer` on both delivered APKs: `pk.edu.iqrs.family` / `pk.edu.iqrs.admin`, versionName 1.1, versionCode 2, minSdk 26, targetSdk 34, permissions INTERNET + CAMERA only, labels "IQRS Family" / "IQRS Admin".
- JS-level test (Node, executing the `_u`/`nl`/`Ei`/`Ut`/`yo` functions extracted verbatim from each patched bundle): mock student session `{userId: 9999, record: {id: 9999, student_id: 123, …}}` → `_u` returns **id 123** (pre-patch: 9999); student record without `student_id` → falls back to 555 (`record.id`); parent session → 777 from `parent_childs` (unchanged). All cases passed in both trees.
- Headless-Chromium render (Chrome for Testing 157, assets served over loopback HTTP as in the shell): Family renders its entry screen with the Student & Parent card; Admin opens straight into "Staff & Admin App" ("Hello Teacher 👋") with the companion ⇅ Staff Sync control present. **No JS exceptions or app console errors in either app**; the only failed requests were `GET /actions` 404s from the plain static test server (that endpoint is served by the shell's LocalAssetServer inside the real APK, not by a file server — a test-harness artifact, also unrelated to this patch).

**Delivered files (overwritten in place).**
- `IQRS-Family-App.apk` — 1,398,137 bytes — sha256 `7cedf6bfaca8560f3d1ae7b5f00be509948d5e134d5d1de99416296b870995a9`
- `IQRS-Admin-App.apk` — 1,410,558 bytes — sha256 `31aac6c789db94a917499a46effd80aff5b9abc80d8a99228f8f50068cdf554d`

**Still untested (unchanged from v1.0 notes).** A genuine student login → live dashboard on a real device with the fixed build: the fix is proven at the code level above, and the on-device confirmation is Assad's re-test with AIKA SAJID's account — Home should now load live data instead of "Dashboard unavailable".

---

## v1.2 — owner-feedback cleanup + live-data wiring fixes (2026-11-06)

versionCode 3 / versionName 1.2 for both apps. Packages, labels, SDK levels (min 26 / target 34) and permissions (INTERNET + CAMERA only) unchanged. The v1.1 student-id fix is intact (verified inside the shipped bundles: `nl(a.student_id)` ×2). The canonical shell bundle (`~/workspace/iqrs-apk-shell/assets/`) received the same bundle patches, so future builds inherit everything below. No production changes; no real logins attempted.

### 1) Domain text removed from visible UI (Assad: "her jagha domain likha hoa hy")
52 exact display-string replacements applied to all three bundles; each bundle went from 59 visible-domain mentions to 6, and the only 6 remaining are functional `https://iqrs.edu.pk` URLs (API base + portal links) — never visible text. Spots cleaned include: the "Live — iqrs.edu.pk" badge (now just "Live"), the "Student & Parent App · iqrs.edu.pk" app-mode pill, the login screen's connection-status strings, session-expired text, profile/logout strings ("Log out of iqrs.edu.pk" → plain), fees/timetable/attendance aria-labels and headings, the five portal-link cards (rewritten as "The 'User Login' page", "The separate staff-side sign-in", "Production web app", "Help & support page", etc.), the "Live Web App" card title (now "School Website"), the profile footer, and the System Setting catalogue note. The Admin companion module (`iqrs-admin.js`) was cleaned the same way (3 visible strings; only its functional API base URL remains). School name and crest kept everywhere. Verified in rendered DOM text: no `iqrs.edu.pk` visible on welcome, home, catalogue, or staff home.

### 2) Filler pruned from the "All Web App Modules" catalogue (Assad: "note waghera")
Catalogue went 54 → **50 entries**. Removed (no matching real Smart School module/screen):
- **Student CV** — decorative filler
- **Guardian Management** — no such standalone module (guardians are part of Student Information)
- **Annual Calendar** — duplicate/decorative (calendar functions live in Notice Board / Events screens)
- **Print Section** — not a functional module
Also removed the decorative **School Identity Kit** entry from the More/Explore menu (the crest and logos remain throughout the UI itself). Note: there is no literal "Notes" entry anywhere in the catalogue — Assad's "note waghera" was interpreted as this class of filler entries. Kept borderline-but-real entries: Quick Fees Create, Thermal Printing, Academics, Attendance Reports, Grading, Behaviour Records, CBSE Examination, and the school's custom fee developments. Verified in the rendered catalogue of BOTH apps: "50 modules & add-ons", pruned items absent, real modules (Fees Collection, QR Code Attendance, Homework, Library, Transport, …) present.

### 3) Admin app live experience — route taken: PRIMARY (live summary on staff home)
The companion "Staff Sync" module now surfaces its live `staffapi/dashboard` data directly on the staff home: it finds the dead "Dashboard unavailable" card and restyles it in place (text-only mutation of the card's existing nodes, so React's DOM is untouched) into a live card driven by the same dashboard cache the panel uses — never invented numbers:
- Signed in + dashboard loaded: "School today — live" with real counts (students / teachers / staff / classes) and "Attendance today: N marked (date)".
- Signed in, cache pending: "School today — live" + signed-in-as pointer to the panel.
- Session expired / signed out: "Live staff workspace" card pointing to the Staff Sync panel for sign-in.
A MutationObserver + short sweep re-applies the swap when React re-renders, and it re-applies after every panel render. Verified headless with a seeded staff session (fixture numbers 1668 students / 103 teachers / 12 classes / 214 marked all rendered) and signed-out (pointer card shown, dead card gone).

### 4) Live-data wiring fixes (owner re-test: data still didn't load — root causes fixed)
Diagnosed from the vendor PHP (`api/application/controllers/Webservice.php`) and fixed in the bundle's live layer (`il()`):
- **Fees transform** — `webservice/fees` returns fee GROUPS nesting `fees[]` (`{student_due_fee:[{name, fees:[…]}], transport_fees:[…], grand_fee:{…}}`); the old transform only looked for flat arrays → always null. New transform flattens `student_due_fee[].fees[]` plus `transport_fees[]` into rows (title from the feetype `type`, amount from `amount` / transport `fees`, status from the PHP-computed `status`, due date in the meta line) and takes Paid/Due totals from `grand_fee.amount_paid` / `grand_fee.amount_remaining` (exact, incl. discounts).
- **Profile transform** — `webservice/getStudentProfile` returns `{student_result:{…}, student_fields, custom_fields}`; the old transform flattened the top level → always null. It now reads `student_result` first.
- **Timetable** — ground truth differs from the initial diagnosis: `getClassTimetable` DOES return `{result_list:[…]}` and the transform already read it. The real failure was upstream: a STUDENT login record carries no `class_id`/`section_id` (the vendor session data has only class/section NAMES; parent child records DO carry the ids), so the call went out with class_id 0 and returned an empty list. Fix: the timetable component now chains `getStudentProfile` (whose `student_result` carries `class_id`/`section_id`) when the child has no class id, then calls the timetable with the resolved ids; it also now reads the teacher's `staff_name` (previously looked for `teacher_name`/`teacher` → always blank).
- **Attendance** (`{attendence_type, data:[{date, type}]}`) and **dashboard** (flat, `student_attendence_percentage`) transforms already matched the PHP shapes — verified and left unchanged.

### 5) Home screens + LIVE/OFFLINE pill rewired to the real API
- The Family/Guest Home was gated by the app's dead internal data client (`X.getDashboard`): when it returned nothing (always, in the installed app), Home short-circuited to "Dashboard unavailable" BEFORE the live sections could render. That gate is removed for family/guest (staff branch unchanged — its home is served by the companion card in §3): Home now renders immediately, with a safe empty local object feeding the legacy demo widgets, and the live sections drive the screen.
- Family Home gained the live cards alongside the existing live progress/attendance summary: **Live fees** card, **Live timetable** card, and a **live notices** card wired to the vendor's real `webservice/getNotifications` endpoint (the local notice list remains for guest/demo mode).
- The header pill said OFFLINE because it read the same dead client (`X.checkLiveSite`). Now every successful real API call through the bridge layer stamps an API-ok flag + event, and the pill ORs that into its state: once the school API answers (login, dashboard, fees, …) the pill shows **LIVE** and stays live; it still shows OFFLINE honestly when nothing has answered.

### 6) Verification with real response shapes (headless Chromium, stubbed bridge)
The native bridge was stubbed to return payloads copied field-for-field from `Webservice.php` (nested fee groups + `grand_fee`, `student_result` profile, `{data:[{date,type}]}` attendance, `{result_list:[…]}` timetable, flat dashboard, `{success:1, data:[…]}` notifications), with a mock STUDENT session and a mock PARENT session (two children). **33/33 checks passed, zero console errors:**
- Student Home: name + 86% attendance ring from live dashboard; Live fees card with Rs 5,000 paid / Rs 4,500 due (from `grand_fee`) and Tuition Fee / Exam Fee / Transport fee rows; timetable card with Mathematics + teacher FATIMA; live notice "Winter Vacation"; pill **LIVE**; no "Dashboard unavailable", no "Live data unavailable", no visible domain text. Bridge calls observed for dashboard, fees, timetable, profile (chained), notifications.
- Fees tab and Attendance tab render the stubbed live data (Present register) with no unavailable notes.
- Profile screen renders from `student_result` (name, admission no. IQ-STU2328, father name).
- Parent Home: both child chips render; per-child live summary/fees/timetable/notices load; switching children re-fetches and stays live; pill LIVE.
- Cleanup re-verified on the final bundles: Admin signed-out + seeded-session home cards, 50-entry catalogues in both apps, pruned items absent, no visible domain text. (The only console noise anywhere was the local test server's 501s for POST — a test-harness artifact, not app errors.)

### Delivered files (overwritten in place)
- `IQRS-Family-App.apk` — 1,402,233 bytes — sha256 `570abd2f1b81bf2211cd3a7123d614ba281f0b387fcb9abfaea9d48ae28dbde3`
- `IQRS-Admin-App.apk` — 1,410,558 bytes — sha256 `fd79bce21da7e07956d8de2d9a3aa59504475203c753424653d26e77cf5c104f`
Badging verified on the delivered files: `pk.edu.iqrs.family` / `pk.edu.iqrs.admin`, versionCode 3, versionName 1.2, minSdk 26, targetSdk 34, labels "IQRS Family" / "IQRS Admin", INTERNET + CAMERA only; patch markers confirmed inside the shipped bundles.

**Still untested.** A genuine on-device student/parent login with the v1.2 build (Assad's re-test) — the full live flow is now proven against PHP-faithful payloads in headless Chromium, and the first real staff sign-in → offline queue → sync test on the Admin app is still pending a real staff account.
