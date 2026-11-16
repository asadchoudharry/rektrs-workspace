# IQRS Mobile Apps — Rebuild Plan v2 (Engineering)

**Author:** App Architect / Lead Engineer · **Date:** 2026-11-06 · **Status:** for build team execution
**Design input:** `design-system-v2.md` ("Calm Campus", owner-approved) — this plan implements it 1:1.
**Hard rule:** clean codebase written by us. The vendor Android bundle is never patched, embedded, or
referenced again. The verified server side (vendor API + our Staffauth/Staffapi/Staffsync) is reused as-is.

---

## 1. Stack decision

### 1.1 What this environment actually is (verified 2026-11-06, commands run)

| Check | Result |
|---|---|
| OS / CPU / disk | Linux x86_64, 4 cores, 144 GB free on `~/workspace` |
| RAM | 7.7 GB total, heavily shared with other agent processes (~1.1–1.6 GB available at times) |
| Node | v24.22.1, npm 10.9.4 (`/usr/bin/node`) |
| JDK | **Temurin OpenJDK 17.0.21** at `~/workspace/android-tools/jdk` (no system java) |
| Android SDK | `~/workspace/android-tools/sdk`: platform **android-34**, build-tools **34.0.0**, cmdline-tools, platform-tools (installed during this audit via curl zip) |
| Gradle | **not installed**; wrapper distribution fetchable only via curl (see §1.2) |
| Flutter | SDK 3.24.5 downloaded (683,285,508-byte tarball) and extracted to `~/workspace/flutter-sdk`; `flutter doctor`: **Android toolchain ✓ green** |
| Chrome for Testing | 157.0.8103.38 at `~/workspace/cft-chrome2/chrome-linux64/chrome` (headless verification of web artefacts) |
| Android emulator | **Impossible** — no `/dev/kvm`, no emulator package. Device verification is the owner's phone + staging API tests. |
| Network | Egress via authenticated proxy (`hatch-egress-proxy:3128`). curl / Python / Node networking works fully (683 MB Flutter tarball and 200 MB Gradle zip fetched via curl without error). |

### 1.2 The decisive finding: Java client sockets are reset in this VM

Every Gradle-based stack (Flutter, React Native, native Gradle) was tested and **cannot build here**:

- `flutter create` + `flutter build apk --debug` fails reproducibly: *"A new daemon was started but
  could not be connected to"* / *"The first result from the daemon was empty."*
- The Gradle daemon itself starts and listens correctly (daemon log: `Listening on [… port:44251,
  addresses:[localhost/127.0.0.1]]`); the **client handshake dies**.
- Root cause isolated with minimal repros (~/workspace/jvmtest, since removed):
  - Python client → Python server on 127.0.0.1: **works**
  - Python client → Java server on 127.0.0.1: **works both directions**
  - **Java client → Python server on 127.0.0.1: `java.net.SocketException: Connection reset` on read**
  - Gradle wrapper + sdkmanager downloads (Java HTTPS clients): **Connection reset**; the same URLs
    fetch fine with curl.
- Conclusion: in this VM, **Java-initiated client connections are reset** (loopback and egress alike).
  Gradle needs client↔daemon sockets *and* Java-HTTP dependency downloads, so it is triply blocked.
  Foreground JVM *compute* is unaffected (a 20 s JVM sleep test and all javac/d8 runs pass).

### 1.3 Decision

**PRIMARY STACK — Native Android, Gradle-free, built with the proven manual pipeline.**

- Language: **Java 17** (Android API 26–34 subset). Kotlin is *not* used: `kotlinc`'s compile daemon
  uses localhost sockets (broken here, §1.2) and its in-process fallback is unproven in this VM;
  Java + `javac` is the zero-risk compiler and the team's existing pipeline already runs it.
- UI: **Android Views + Material Components** (AARs fetched via curl from Google Maven — curl works),
  RecyclerView, ViewBinding-free (plain `findViewById`/programmatic views + a small in-house
  binding helper), custom `View`s for the signature pieces (attendance ring = Canvas arc,
  fee split-bar, week strip). This is genuinely native UI — real Android widgets, real camera,
  real RecyclerView scrolling — not a WebView.
- Networking: **OkHttp** (single JAR + Okio, curl-fetched) or `HttpURLConnection`; decision: OkHttp
  for interceptors/timeouts/logging discipline. JSON: **org.json** (framework) for parsing into
  typed models by hand-written mappers — no Gson/Moshi codegen, no annotation processing.
- Local store: **SQLite via framework `SQLiteOpenHelper`** (no Room — it needs annotation
  processing and a Gradle plugin). 
- QR: **ZXing core JAR** (pure Java, curl-fetched) + framework **Camera2** API. No CameraX (AAR graph
  too heavy to hand-wire).
- Fonts: Plus Jakarta Sans + Inter **bundled as assets** (design §2.2; never runtime-fetched).
  Icons: Phosphor — exported SVG→VectorDrawable set checked into the repo (design §2.6).
- Build: the existing, proven pipeline from `~/workspace/iqrs-apk-two/*/build.sh`
  (aapt2 compile/link → javac → d8 → zipalign → apksigner), generalised into one script (§6.1).
  Every step is a short-lived foreground process — nothing in the chain opens a socket.

**Why this wins here:** it is the only stack that is (a) buildable in this VM *today, with evidence*,
(b) truly native in feel — the owner's "ye to phir wahi web page hai" objection is impossible,
(c) dependency-light enough to vendor by curl with pinned checksums, and (d) already understood by
this team (the v1.x shells were built exactly this way; only the app content was borrowed — now the
content is ours too).

**FALLBACK — Flutter, built on the VPS build lane.** If a future requirement (iOS, or native-view
velocity problems) justifies it: Flutter 3.24.5 is already installed at `~/workspace/flutter-sdk`
(doctor-green except its Gradle step) and the Hostinger VPS (SSH via `~/workspace/scripts/rssh.sh`,
rsync working) is a normal Linux host where Java networking works — Flutter/Gradle builds run there,
APKs are pulled back. The Dart codebase in §2–§5 maps 1:1 if this lane is ever taken (models,
endpoints, outbox semantics are stack-neutral in this plan). **React Native is rejected outright**:
it assembles via the same blocked Gradle, with a heavier JS/native toolchain and no advantage over
Flutter as the fallback.

**Explicitly rejected:** any WebView-based rebuild (owner-rejected experience; also the root of the
v1.x failure), Cordova/Capacitor (WebView), .NET MAUI (no dotnet toolchain; Android build still
Gradle-adjacent), Kotlin Multiplatform (Gradle).

---

## 2. One codebase → two apps

```
~/workspace/iqrs-app-v2/
├── build.sh                  # one entry: ./build.sh family|admin|both  (aapt2→javac→d8→sign)
├── config/
│   ├── family.properties     # packageId, label, versionCode, feature flags (see below)
│   └── admin.properties
├── libs/                     # vendored, checksummed (§6.1): okhttp, okio, zxing-core,
│   │                         # material-components AAR extracts, androidx core/recyclerview/etc.
│   └── SHA256SUMS
├── assets-common/            # fonts (Jakarta, Inter), crest artwork, phosphor vector drawables
├── src/
│   ├── pk/edu/iqrs/app/
│   │   ├── IqrsApp.java              # Application: theme tokens, session, db, outbox init
│   │   ├── api/                      # §3 — typed client, one file per resource
│   │   ├── model/                    # §3.3 — immutable model classes (Java records-style POJOs)
│   │   ├── data/                     # repositories: cache-first reads (design §3.13), DbHelper
│   │   ├── ui/
│   │   │   ├── theme/                # CalmCampus tokens from design §2 as Java constants + styles.xml
│   │   │   ├── components/           # design §3 components, one class each (Ring, WeekStrip, …)
│   │   │   ├── family/               # Activities/Fragments for F-screens (§5.1)
│   │   │   └── staff/                # Activities/Fragments for S-screens (§5.2) — admin variant only at runtime
│   │   ├── sync/                     # §4 — outbox, flusher, activity log (admin)
│   │   └── qr/                       # Camera2 + ZXing pipeline (admin)
│   └── res/                          # layouts, drawables, values (themes, dimens from design tokens)
├── fixtures/                 # §6.2 — PHP-verbatim stub payloads (JSON), one file per endpoint
├── tests/                    # JVM unit tests (JUnit 4 JAR, run with plain java — no Gradle)
│   └── pk/edu/iqrs/app/api/  # mapper tests against fixtures/; outbox state-machine tests
└── tools/
    ├── contract_check.py     # §6.2 — staging smoke via curl-equivalent (python requests/urllib)
    └── banned_strings.sh     # §6.3 — design §6.3 lint over strings.xml + layouts + java sources
```

**Variant mechanism (no code forks):** `build.sh family|admin` reads `config/<variant>.properties`:
`applicationId` (`pk.edu.iqrs.family` / `pk.edu.iqrs.admin`), app label ("IQRS Family" / "IQRS Admin"),
`versionCode`/`versionName` (start at 4 / 2.0 — above the rejected v1.2's code 3, so installs upgrade
in place), and a generated `BuildVariant.java` (`VARIANT_FAMILY` / `VARIANT_ADMIN`, feature flags:
`HAS_STAFF_SYNC`, `HAS_QR`). One manifest template; the variant file decides which Activities are
declared/launched. Family APK physically excludes staff/sync/qr classes via a source-set list in the
build script (javac compiles only the listed roots) — the Family app cannot contain staff code it
doesn't need, and the Admin app reuses 100% of api/model/theme/components.

**Shared invariants:** minSdk 26, targetSdk 34, permissions **INTERNET + CAMERA only** (CAMERA
declared but runtime-requested only in Admin), debug keystore for owner testing (same keystore as
v1.x so upgrades install over), release = same pipeline with the production keystore when the owner
supplies one.

---

## 3. Typed API client spec

All contracts below were read from the deployed sources on 2026-11-06:
`~/workspace/iqrs-api/production/api/application/controllers/{Auth,Webservice}.php`,
`models/Auth_model.php`, and `~/workspace/iqrs-api/staff-ext/{Staffauth,Staffapi,Staffsync}.php`.
Nothing here is guessed; where the PHP is the only source of truth, the file/line region is named.

### 3.1 Transport rules (both APIs)

- Base URL: `https://iqrs.edu.pk/api/` (production). A build-time `API_BASE` constant allows the
  staging base `https://staging.iqrs.edu.pk/api/` for test builds.
- Every call is **POST with a JSON body** (even reads — the vendor API has no GET endpoints).
- Client headers on **every** request (vendor `check_auth_client()`):
  `Client-Service: smartschool`, `Auth-Key: schoolAdmin@`, `Content-Type: application/json`.
- Authenticated calls add: `User-ID: <id>`, `Authorization: <token>` (raw token, no "Bearer").
  - Vendor API: `User-ID` = login response top-level `id` (the **users**-table id); token checked
    against `users_authentication`, sliding +8760 h renewal on each call (`Auth_model::auth()`).
  - Staff extension: `User-ID` = **staff_id**; token checked against `api_staff_sessions`.
    The two token realms are disjoint by design — a staff token is meaningless on vendor endpoints
    and vice versa. The client keeps two separate session objects and never mixes them.
- **No CORS exposure**: native HTTP clients are unaffected by the API's missing CORS headers.
  (There is no WebView and no browser origin anywhere in v2 — the v1.x CORS/loopback-server
  machinery is deleted, not ported.)
- Timeouts: connect 10 s, read 20 s. One automatic retry on transport failure for idempotent reads;
  writes are never auto-retried outside the outbox (§4).

### 3.2 Error model (the client never leaks raw states to UI)

Every call returns a sealed result: `Ok<T>` | `ApiError(kind, messageFromServer)` |
`TransportError` | `SessionExpired`.

| Server behaviour (verified) | Client mapping |
|---|---|
| HTTP 200, body `status: 0, message: "…"` (login failure, sync rejection, validation) | `ApiError(BUSINESS, message)` — message is shown via design §3.16 copy rules, never raw if a mapped string exists |
| HTTP 200, body `status: 1` (+ `record`/payload keys) | `Ok` |
| HTTP 401, `{status:401, message:"Unauthorized."}` or `"Your session has been expired."` | `SessionExpired` → session cleared per §3.4 (Admin: outbox **preserved**, design S11) |
| HTTP 400 `{status:400, message:"Bad request."}` | `ApiError(CLIENT_BUG)` — logged, generic §3.16 copy shown |
| HTTP 5xx / non-JSON / timeout / no network | `TransportError` → cache-first UI (§3.13 of design) or queued (writes, §4) |
| Vendor read endpoints return the payload **without** a `status` envelope (e.g. dashboard, fees) | Treated as `Ok` when HTTP 200 + expected top-level keys present; key-absence = `ApiError(CONTRACT)` — this is the v1.x failure detector, wired to the fixture tests (§6.2) |

### 3.3 Session & identity model

**Family session** (`auth/login` → `Auth_model::login`):
- Request: `{username, password, deviceToken}` (deviceToken may be `""`).
- Success: HTTP 200 `{status:1, message, id:<usersId>, token, role:"student"|"parent", record:{…}}`.
- Failure: HTTP 200 `{status:0, message:"Invalid Username or Password"}` (or suspended message).
- **Student record** (from `Auth_model` student branch): `record.student_id` = **the real student
  id — always use this, never `record.id`** (the v1.0 bug); `record.student_session_id`,
  `record.admission_no`, `record.username` (full name), `record.class`, `record.section` (names
  only — **no class_id/section_id**), `record.image`, `record.sch_name`, `record.currency_symbol`.
- **Parent record**: same identity fields for the parent + `record.parent_childs[]`, each child:
  `{student_id, name, class, section, class_id, section_id, student_session_id, admission_no, image}`.
  Parent `User-ID` for calls = top-level `id`; per-child calls use the child's `student_id`.
- App model: `Session{usersId, token, role, self: ChildRef, children: List<ChildRef>}` where
  `ChildRef{studentId, studentSessionId, classId?, sectionId?, name, className, sectionName,
  admissionNo, imageUrl}`. For a student login, classId/sectionId start **null** and are resolved
  once from `getStudentProfile.student_result` (which carries them), then cached (§3.5).

**Staff session** (`staffauth/login` → `Staffauth.php`):
- Request: `{email, password}` (`username` accepted as alias; we always send `email`).
- Success: `{status:1, message:"Successfully login.", id:<staffId>, token, role:<primaryRoleName>,
  record:{…staff fields + roles}}`. Failure: `{status:0, message:"Invalid Username or Password"}`
  (identical for unknown email / wrong password / disabled, by server design).

**Storage:** token + session JSON in app-private storage via `SharedPreferences` wrapped by
`SessionStore` (file in internal storage, MODE_PRIVATE; tokens never in logs, never in the outbox
DB). Persist across restarts; Family and Admin stores are separate by package. Logout =
`webservice/logout` best-effort + local clear. Session expiry (401) → design §3.16 session copy;
Admin re-login **keeps the outbox and activity log** (design S11 trust rule).

### 3.4 Endpoint catalogue — Family (vendor `Webservice.php`, all POST JSON)

| # | Endpoint | Request body | Response → app model |
|---|---|---|---|
| V1 | `auth/login` | `{username, password, deviceToken}` | §3.3 → `Session` |
| V2 | `webservice/getSchoolDetails` | `{}` | flat school object (name, address, phone, email, image/logo, session, currency…) → `SchoolInfo` (About screen F11, splash data) |
| V3 | `webservice/dashboard` | `{student_id, user_id (parent only), role, date_from, date_to}` (month window) | flat object: `student_attendence_percentage` (int %), `student_homework_incomplete`, `student_incomplete_task`, `attendence_type`, `class_id`, `section_id`, `public_events[]`, `date_lists` → `DashboardSummary` (Home hero F2) |
| V4 | `webservice/getStudentProfile` | `{student_id, user_type}` | `{student_result:{…full student row incl. class_id, section_id, student_session_id, guardian fields, transport fields}, student_fields[], custom_fields{}}` → `StudentProfile` (F11; also the class/section resolver for student logins) |
| V5 | `webservice/getAttendenceRecords` | `{student_id, year, month}` (date-wise mode: `{student_id, date}` when `attendence_type` is date-wise) | `{attendence_type, data:[{date:"Y-m-d", type:"Present"|"Absent"|…}]}` → `List<AttendanceDay>` (F3; month view) |
| V6 | `webservice/fees` | `{student_id}` | `{pay_method:0|1, student_due_fee:[{id, fees:[{…fee head rows with amounts/status}], …}], transport_fees:[…], student_discount_fee:[…], grand_fee:{amount, amount_discount, amount_fine, amount_paid, amount_remaining, fee_fine}}` → `FeeStatement{groups[], transport[], discounts[], totals}` — mapper flattens `student_due_fee[].fees[]` preserving group order, transport kept as its own group (design §3.10/F4) |
| V7 | `webservice/getClassTimetable` | `{user_id, class_id, section_id}` | `{result_list:[{day, subject_name, staff_name, time_from, time_to, …}]}` → `List<Period>` grouped by day (F5, Home "Today") |
| V8 | `webservice/getHomework` | `{student_id, homework_status:"incomplete"|"complete", subject_group_subject_id (optional)}` (form-style params read via `$this->input->post` after JSON decode — send in JSON body like all others) | `{homeworklist:[{id, subject_name, homework_date, submit_date, description, status, …}]}` → `List<HomeworkItem>` (F6, Home section = incomplete only) |
| V9 | `webservice/getNotifications` | `{type:"student"|"parent"}` (from session role) | array of `{id, title, message, date, publish_date, created_by, …}` from `send_notification` → `List<Notice>` (F7) |
| V10 | `webservice/getExamList` | `{student_id}` | `{examSchedule:[{exam_group_class_batch_exam_id, exam (name), …}]}` → `List<Exam>` (F8) |
| V11 | `webservice/getExamSchedule` | `{exam_group_class_batch_exam_id}` | `{exam_subjects:[{subject_name, date, time_from, time_to, …}]}` → exam date sheet (F8) |
| V12 | `webservice/getExamResult` | `{student_id, exam_group_class_batch_exam_id}` | marks structure per exam group (subjects, obtained/total, grade via server `getGradeByMarks`) → `ExamResult` (F8). Mapper is fixture-locked (§6.2) because this payload is the most nested of the set |
| V13 | `webservice/getTransportroute` | `{student_id}` | route/vehicle/driver structure (student's route assignment; 400 `{message:"student_id required"}` when missing) → `TransportInfo` (F9). Cross-checked against profile's transport fields (`route_title`, `vehicle_no`, `driver_name`, `pickup_point_name` in `student_result`) |
| V14 | `webservice/getLibraryBooks` | `{}` | book catalogue array → `List<Book>` (F10 browse) |
| V15 | `webservice/getLibraryBookIssued` | `{studentId, member_type:"student"}` (note the capital-I `studentId` — verbatim from PHP) | issued-books array → `List<IssuedBook>` (F10) |
| V16 | `webservice/Parent_GetStudentsList` | `{}` (parent session) | children array → refresh of `Session.children` (used on pull-to-refresh of the child switcher; login already returns `parent_childs`, this is the re-fetch path) |
| V17 | `webservice/getModuleStatus` | `{}` | `{module_list}` → feature visibility (e.g. hide Transport/Library tiles when the school disabled the module) — replaces any hard-coded module catalogue |
| V18 | `webservice/getTeachersList` | `{user_id, class_id, section_id}` | teacher/subject assignments → used inside Timetable detail + Profile "my teachers" if design expands; **Phase 2** |
| V19 | `webservice/getApplyLeave` / `addLeave` | per PHP (leave list / create) | **Phase 2** — not in the design's 24 screens; listed so the client reserves the resource file |
| V20 | `webservice/logout` | `{}` | best-effort session end |

Mapper discipline (the v1.x lesson, made structural): **one mapper class per endpoint**, pure
functions `JSONObject → Model`, no Android imports, each paired with a fixture test (§6.2). Numeric
fields arrive as strings or numbers unpredictably in PHP JSON — mappers coerce via one `Json` helper
(`optDouble/optInt/optString` with defaults), never `getX` that throws. Missing optional keys →
model defaults; missing **required** keys (the ones the screen renders) → `CONTRACT` error, which in
debug builds is loud and in release builds degrades that card only (design §F2 isolation rule).

### 3.5 Endpoint catalogue — Staff (our extension, all POST JSON, staff-session headers)

| # | Endpoint | Request body | Response → app model |
|---|---|---|---|
| S1 | `staffauth/login` | `{email, password}` | §3.3 → `StaffSession{staffId, token, role, record}` |
| S2 | `staffapi/me` | `{}` | staff record → `StaffProfile` (S11) |
| S3 | `staffapi/schoolDetails` | `{}` | school object → `SchoolInfo` |
| S4 | `staffapi/dashboard` | `{}` | `{status:1, record:{total_students, total_staff, total_teachers, total_classes, session_id, attendance_today:{date, marked, by_type:{<typeName>:count}}}}` → `StaffDashboard` (S2 stats; **only these figures may be displayed** — design §6.2) |
| S5 | `staffsync/feeInvoice` | `{student_session_id}` | `{status:1, record: <same fee structure as vendor getStudentFees>}` → invoice lines for fee collection (S8): each line carries `student_fees_master_id` + `fee_groups_feetype_id` + balance |
| S6 | `staffsync/attendance` | §4.3 | §4.3 |
| S7 | `staffsync/qrAttendance` | §4.3 | §4.3 |
| S8 | `staffsync/homework` | §4.3 | §4.3 |
| S9 | `staffsync/notice` | §4.3 | §4.3 |
| S10 | `staffsync/feeCollect` | §4.3 | §4.3 |

**Known server gaps the plan does not hide** (client must be built knowing them):
- Staff class/student rosters for S3/S4/S10 (my classes, student lists, search) have **no read
  endpoint yet** in the extension. Milestone M3 (§7) includes a small additive `Staffapi`
  extension (`classes`, `students`, `studentSearch`, `subjects`) written by us in the same style —
  it is server work, listed openly here rather than discovered mid-build. Until it lands, S3/S4
  cannot be built against real data (fixtures first, §6.2).
- Production has **no subject groups configured** (only subjects Computer + Computer Practical);
  homework sync resolves subjects via `subject_group_subjects` — the S6 subject picker must handle
  the empty-configuration state honestly (design §3.15 empty state) until the school configures
  groups in the web admin. Flagged for the owner, not worked around in the client.

---

## 4. Offline design — Admin app

Design contract: design-system §3.13 + S9. **The words "outbox / queue / sync" never appear in the
UI.** Internally we call it the outbox; the user sees "Waiting to send".

### 4.1 Local store (SQLite, `iqrs_admin.db`, via `DbHelper extends SQLiteOpenHelper`)

Tables:
- `outbox(id INTEGER PK, client_txn_id TEXT UNIQUE NOT NULL, kind TEXT, payload_json TEXT,
  summary TEXT, created_at INTEGER, state TEXT, attempts INTEGER DEFAULT 0,
  last_error TEXT, server_response TEXT)` — `kind ∈ {attendance, qr_attendance, homework, notice,
  fee_collect}`; `summary` is the human line for S9 ("Attendance — Class Eight, 40 students"),
  composed at enqueue time so S9 needs no joins.
  `state ∈ {waiting, sending, needs_attention}` (delivered rows are deleted, §4.4).
- `activity_log(id INTEGER PK, outbox_id INTEGER, kind TEXT, summary TEXT, created_at INTEGER,
  delivered_at INTEGER, outcome TEXT)` — powers the Staff Home "Recent activity" list (design S2)
  and the post-delivery history in S9. Kept 90 days, pruned on start.
- `cache(endpoint TEXT, key TEXT, payload_json TEXT, fetched_at INTEGER, PK(endpoint,key))` —
  last-good responses for cache-first reads (staff dashboard, feeInvoice lookups, rosters),
  the mechanism behind design §3.13-2 ("Last updated …" captions).
- Family app uses the same `cache` table design (its own DB, no outbox/activity tables compiled in).

### 4.2 Enqueue rules

- Every staff write is **born in the outbox**: the UI action writes the row (UUID v4
  `client_txn_id` generated once, at compose time — never regenerated on retry), shows the design's
  saved-on-this-phone copy, and returns instantly. Online or offline makes no difference to the
  user's flow (this is what makes S4/S5/S8 feel identical in a basement classroom and in the office).
- Attendance for a whole class is **one** outbox item (server takes batched `records[]`), so a
  class of 40 is one transaction, one idempotency key, one S9 row.
- QR scans are one item **each** (server contract is per-scan) but flush back-to-back (§4.4).

### 4.3 Write payloads (verbatim from `Staffsync.php` docblocks — do not paraphrase)

| Kind | Endpoint | Body |
|---|---|---|
| attendance | `staffsync/attendance` | `{client_txn_id, class_id, section_id, date? (Y-m-d, default today), records:[{student_session_id \| student_id, attendence_type_id?, remark?}]}` — Present = `attendence_type_id 1` (verified in staging tests) |
| qr_attendance | `staffsync/qrAttendance` | `{client_txn_id, code, date?, attendence_type_id?}` — `code` accepts `IQRS-<studentId>`, a bare numeric id, or an admission number (server resolves all three); the app sends the raw card text unmodified |
| homework | `staffsync/homework` | `{client_txn_id, class_id, section_id, subject_group_subject_id, homework_date, submit_date, description}` |
| notice | `staffsync/notice` | `{client_txn_id, title, message, date?, publish_date?, visible_student?, visible_parent?, visible_staff?, role_ids?}` — defaults from server: students+parents visible, staff not |
| fee_collect | `staffsync/feeCollect` | `{client_txn_id, student_fees_master_id, fee_groups_feetype_id, amount, amount_discount?, amount_fine?, payment_mode? (default "Cash"), date?, description?}` — posts through the vendor `fee_deposit()`; success response carries the receipt reference (`invoice_id` + `sub_invoice_id`) which the app stores into `activity_log` and shows on the S8 success screen |

### 4.4 Flush engine

- **Triggers:** app start; connectivity regained (framework `ConnectivityManager` network callback);
  enqueue (immediate attempt); entering S9; manual "Send now" pull-to-refresh on S9; a periodic
  `AlarmManager` retry every ~15 min while items wait (no WorkManager — it is an AAR + codegen
  burden; AlarmManager is framework). No background service, no persistent notification.
- **Order & concurrency:** strict FIFO by `created_at`, one request in flight. A failure stops the
  run (order is meaningful: a fee collected after attendance shouldn't overtake it on a flaky link).
- **Response handling:**
  - `status:1` → delivered: delete outbox row, write `activity_log` (with receipt ref for fees),
    update the pending-count UI (§4.5).
  - `status:1` or stored response with **`duplicate:true`** → the server already applied this
    `client_txn_id` (its `api_sync_log` returns the original response verbatim): treat **exactly
    like delivered**. This is the exactly-once guarantee the user never hears about (design S8).
  - Claim-in-flight response (server: key still `__PENDING__` and fresh) → leave `waiting`,
    back off; a later trigger retries with the **same** key and the server resolves it.
  - `status:0` with a business message ("Fee invoice not found", "Invalid subject_group_subject_id",
    validation text) → `needs_attention`, row stays in S9 under "Needs your attention" with the
    reason translated to plain words (§4.5), Edit/Discard offered. **Never silently dropped,
    never retried automatically** (it would fail identically forever).
  - HTTP 401 → pause the whole run, keep every row, prompt re-login (design S11); resume after
    login with the same keys.
  - Transport error / 5xx → row back to `waiting`, attempts++, exponential backoff
    (30 s → 2 min → 10 min cap), run stops.
- **Crash safety:** state transitions are single-row SQLite updates; a process death mid-request
  leaves the row in `sending` — on next start, `sending` older than 60 s resets to `waiting`
  (the server's claim mechanism makes the retry safe, §4.3 duplicate rule).

### 4.5 User-visible states (consumer language only — design §3.13/§3.16 are normative)

| Internal state | What the user sees |
|---|---|
| outbox empty | nothing (no chrome at all) |
| N waiting | Staff-only slim bar above the nav: *"N items waiting to send — they'll go on their own when you're back online."* + View → S9 |
| flushing | bar text swaps to *"Sending…"* with the count decreasing |
| flush complete after a wait | one toast: *"You're back online — everything is up to date."* (once per reconnection) |
| needs_attention | S9 group "Needs your attention": plain-words reason from the §3.16 table (e.g. fee: *"This payment couldn't be recorded: the invoice was already settled. It has NOT been saved — you can fix it and send again."*) + Edit / Discard (confirm dialog) |
| 401 during flush | sign-in screen with §3.16 session copy; after re-login a caption: *"Your waiting items are still here."* |
| per-screen cached reads (both apps) | quiet caption *"Last updated today, 9:41 AM"* on Fees/Attendance/Timetable only; no banners, no pills, **no LIVE/OFFLINE text anywhere** (lint-enforced, §6.3) |

---

## 5. Screen inventory → endpoints

Composed only from design §3 components; states (skeleton / empty / error / cached) per design
§3.15–3.16 are part of each screen's definition of done.

### 5.1 Family (design §4.A)

| Screen | Endpoints | Notes |
|---|---|---|
| F0 Splash | V2 (prefetch) + session restore | ≤1.2 s; failure keeps crest + retry (design F0) |
| F1 Sign in | V1 | students + parents only (server-enforced); honest "contact the school office" forgot-password copy |
| F2 Home | V3 (hero %), V7 (today), V6 (fee card), V8 incomplete (homework), V9 (notices), V17 (tile visibility) | **per-card isolation**: each section is an independent repository call; one failure degrades one card (design §F2) — the structural fix for "whole Home dead" |
| F3 Attendance | V5 (per month), V3 (term %) | week strip + month grid from `{date,type}` only |
| F4 Fees | V6 | groups/transport/discounts rendered in payload structure; receipt sheet from paid instalment rows inside the fee payload |
| F5 Timetable | V7 | day pager over `result_list`; needs class/section — student logins resolve via V4 first (cached) |
| F6 Homework | V8 (incomplete + complete tabs) | subject filter chips from returned data |
| F7 Notices | V9 | type = session role |
| F8 Exams & Results | V10 → V11 (schedule), V12 (result per exam) | "not published yet" is a designed info state |
| F9 Transport | V13 (+ V4 transport fields as fallback display) | not-enrolled info state |
| F10 Library | V15 (issued), V14 (browse) | |
| F11 Profile + About | V4, V2 | only fields inside `student_result` are shown (design §6.2) |
| F12 More grid | — (navigation) + V16 (children refresh for parents) | replaces the v1 54-module catalogue with the 10 real things (design §F12) |
| Child switcher (cross-cutting) | V1 record + V16 | re-scopes every screen's `student_id` (design §3.2) |

### 5.2 Staff (design §4.B)

| Screen | Endpoints / source | Notes |
|---|---|---|
| S0/S1 Splash + Sign in | S3 prefetch, S1 | staff email + password |
| S2 Staff Home | S4 (+ outbox count, activity_log) | stats limited to what S4 returns; today's classes need the M3 roster endpoints (§3.5 gap) until then the card shows attendance_today + quick actions |
| S3 Classes | M3 `staffapi/classes` (to build) + outbox state per class/date | "Marked / Not marked" chip derives from local outbox + server attendance state |
| S4 Mark attendance | roster: M3 `staffapi/students`; write: S6 via outbox | P/A/L segmented control, "Mark all present", sticky save — design S4 is normative |
| S5 QR attendance | S7 via outbox; fallback manual code entry (same endpoint) | Camera2 + ZXing; duplicate scan = "Already marked present" from local day-cache + server duplicate rule |
| S6 Homework | write: S8 via outbox; list: own activity_log + M3 (to build) | subject picker = configured subject groups only; empty-config state per §3.5 |
| S7 Notices | write: S9 via outbox; list: V9-type staff view via M3 or activity_log (own posts) | audience segmented control maps to `visible_*`/`role_ids` |
| S8 Fee collection | S5 (invoice lookup by student_session_id; student search via M3 `staffapi/studentSearch`) → S10 via outbox | success screen shows server receipt ref after delivery; while waiting, copy per design S8 |
| S9 Waiting to send | local outbox/activity_log only | §4.5 language; Edit re-opens the compose flow with the same `client_txn_id` **only if never sent** — an attempted item keeps its key forever (editing a needs-attention item edits payload, key unchanged) |
| S10 Students lookup | M3 `staffapi/studentSearch` + roster | read-only mini-profile (guardian phone from roster payload) |
| S11 Profile & settings | S2 | sign-out preserves outbox (design S11) |

---

## 6. Build + verification pipeline

### 6.1 Build (this VM, Gradle-free — §1.2 is why)

`./build.sh <family|admin|both>` — generalises `~/workspace/iqrs-apk-two/*/build.sh`:

1. Resolve variant from `config/<variant>.properties`; generate `BuildVariant.java` + manifest.
2. Fetch/verify vendored libs into `libs/` (OkHttp, Okio, ZXing core, Material Components +
   AndroidX AARs from Google Maven) — **via curl only**, each pinned in `libs/SHA256SUMS`;
   the build fails on checksum drift. AARs are unzipped once; their `classes.jar` + resources
   feed javac/aapt2 exactly like the current shell build does for the platform.
3. `aapt2 compile` (res + AAR res) → `aapt2 link` against `android-34/android.jar`.
4. `javac` (JDK 17, `-source/-target 17`, classpath = android.jar + lib jars) — app sources +
   generated R/BuildVariant.
5. `d8 --min-api 26` → `zipalign` → `apksigner` (debug keystore for owner builds; the existing
   `iqrs-debug.keystore` is reused so v2 installs over v1.x during testing).
6. **Badging gate:** `apkanalyzer` asserts package id, label, versionCode ≥ 4, minSdk 26,
   targetSdk 34, permissions ⊆ {INTERNET, CAMERA}. Build fails otherwise.

Environment prep (one-time, scripted in `tools/setup_env.sh`): JDK/SDK paths as in §1.1,
platform-tools present, `GRADLE_USER_HOME` not needed (no Gradle), Flutter SDK left in place
for the fallback lane.

### 6.2 Verification — three automated gates + the owner's phone

**Gate 1 — Mapper contract tests (JVM, offline, blocks release).** `fixtures/` holds one JSON file
per endpoint in §3.4/§3.5, **copied field-for-field from the PHP sources** (the v1.2 33-check
suite's stub discipline, made permanent): e.g. `fees.json` is the nested
`{student_due_fee:[{fees:[…]}], transport_fees:[…], grand_fee:{…}}`, `profile.json` wraps
`student_result`, `timetable.json` is `result_list`, `login_student.json` carries
`record.student_id ≠ record.id` on purpose. JUnit 4 (single JAR, curl-fetched) runs every mapper
against its fixture on the plain JVM (`java` foreground — works here), plus outbox state-machine
tests (enqueue→flush→duplicate→needs-attention transitions against a fake transport).
**A mapper change without a fixture change fails review; a fixture may only change when the PHP
changes, with the PHP diff cited.**

**Gate 2 — Staging API smoke (Python, blocks release).** `tools/contract_check.py` (Python +
urllib — networking that works in this VM) runs against `https://staging.iqrs.edu.pk/api/` with
the disposable staging accounts: vendor login (student + parent shapes asserted: `student_id`
present, children carry class/section ids), dashboard/fees/profile/timetable/attendance key
assertions, staff login, and the full sync cycle on staging only (attendance batch, QR, homework,
notice, fee collect + **replay of the same `client_txn_id` asserting `duplicate:true` and no
second posting** — the Phase-B C2 suite, automated). Production is checked read-only
(dummy-login error string + 401-without-token), never written.

**Gate 3 — Static + package checks (blocks release).** banned-strings lint (§6.3), apkanalyzer
gate (§6.1 step 6), and a strings/layout audit that every user-visible string comes from
`strings.xml` (so the design's copy table is the only copy).

**Device gate (the v1.x lesson, non-negotiable).** No build is "done" when the gates pass — it is
done when the **owner's phone** confirms: install-over-previous, real student login (live Home
data), real staff login, one offline attendance + one offline fee collection that deliver on
reconnect. This checklist is printed in every build report (the `BUILD-REPORT` format from v1.x,
kept). There is no emulator in this VM (§1.1) — pretending otherwise is how v1.x shipped blind.

**What happened to "headless Chromium smoke tests"?** They verified the old WebView app. A native
app has no Chromium surface; the equivalent confidence comes from Gate 1 (payload truth) + Gate 2
(server truth) + the device gate (rendering truth). Chrome for Testing remains in the toolbox for
one job: screenshotting the *staging web admin* when a server-side question needs eyes.

### 6.3 Banned-strings lint (design §6.3/§6.4-4)

`tools/banned_strings.sh` greps `strings.xml`, layouts and Java sources for: `LIVE`, `OFFLINE`,
`Dashboard unavailable`, `Live data unavailable`, `iqrs.edu.pk` (as visible text; the API base URL
lives in one non-UI constant, whitelisted by path), `API`, `sync`, `outbox`, `queue`, `401`,
`STAFF SYNC` — case-insensitive, word-boundaried, with an explicit allowlist file for internal
identifiers (class names like `OutboxEngine` are code, not copy — the lint targets resources and
`setText` literals). Any hit fails the build.

---

## 7. Phased build sequence

| Milestone | Contents | Exit criteria |
|---|---|---|
| **M0 — Skeleton & pipeline** | Repo layout (§2), `build.sh` both variants producing empty-shell APKs (splash + sign-in screens, theme tokens from design §2, component stubs §3), vendored libs pinned, Gate 3 + badging live | Both APKs install side-by-side; badging gate green; banned-strings lint green on the skeleton |
| **M1 — Family read-only core = FIRST SHIPPABLE** | §3 client (V1–V9), session + child switcher, F0–F7 (Home with per-card isolation, Attendance, Fees, Timetable, Homework, Notices), cache-first reads, Gate 1 fixtures for V1–V9, Gate 2 staging login/data smoke | **Owner's phone: real student AND parent logins show live Home data** (the exact test v1.x failed); build report issued. *This is the first shippable milestone: a Family app that does the 80% job — see today, attendance, fees, timetable, homework, notices — with real data and the approved design.* |
| **M2 — Family complete** | F8–F12 (Exams/Results, Transport, Library, Profile/About, More), V10–V17 integrated, dark mode (tokens already in design §2.1), 135% type + TalkBack pass on Home/Fees (design §6.4-5) | Full Family screen inventory live-data verified on staging + owner device |
| **M3 — Staff server reads + Staff core** | Additive `Staffapi` reads (`classes`, `students`, `studentSearch`, `subjects`) built + staging-tested + production-deployed in the established staff-ext pattern; S1–S3, S10, S11; S4 attendance online-first (outbox wired but flush immediate) | Real staff login on the owner's phone; a class marked and visible in the web admin |
| **M4 — Offline engine + QR + money** | §4 outbox/flush/activity complete; S5 QR (Camera2+ZXing), S6 homework, S7 notices, S8 fee collection, S9 Waiting to send; Gate 2 full sync cycle incl. duplicate-replay assertions on staging | Airplane-mode test on the owner's phone: attendance + fee collected offline, both delivered exactly once on reconnect (DB-verified, the Phase-B standard) |
| **M5 — Hardening & handover** | Error-copy audit vs design §3.16, accessibility pass (design §5.3), icon/font asset audit, production keystore signing (owner-supplied), build report + runbook (build, fixture update rule, staging accounts) | Owner acceptance on both apps; v1.x APKs retired |

**Sequencing notes.** M1 is deliberately Family-first: it carries the owner's loudest complaint
("no data") and the design's first impression, and it exercises the entire client/cache/test
machinery before the harder offline engine lands. Staff *server* reads (M3) start in parallel with
M2 — they are independent of the Family UI. Nothing in M3–M4 changes the Family app.

**Team shape (matches the owner's "complete development team" ask):** Design Lead (spec exists —
guardian of §6.4 done-criteria), Architect (this plan; owns §3 contracts + fixtures), Builder A
(Family), Builder B (Staff + sync), QA (Gates 1–3 + device checklist). Builders never edit
fixtures or the API client of the other app without the Architect — the v1.x transforms failed
precisely because payload knowledge lived in one hurried head.

---

## 8. Risks & open items (stated, not buried)

1. **Hand-wired AAR graph** (Material/AndroidX without Gradle) is the main engineering risk of the
   chosen stack: transitive AndroidX versions must be pinned coherently in `libs/SHA256SUMS`.
   Mitigation: minimal dependency set (core, appcompat *or* plain framework widgets — spike in M0
   decides; if Material's AAR graph fights back, framework widgets + our own token styles still
   satisfy the design, which is token/component-based, not Material-widget-based).
2. **No emulator** (§1.1): UI iteration is slower (device installs). Mitigation: component gallery
   screen in debug builds (all §3 components + states on one scrollable screen) so design review
   needs one install, not twenty.
3. **Vendor payload drift**: Smart School updates could change shapes. Gate 2 runs against staging
   before any school-side update is accepted; fixtures make drift a failing test, not a user report.
4. **Homework subjects** (§3.5): production has no subject groups — S6 is blocked on school
   configuration, surfaced to the owner as an admin task, not hidden in the app.
5. **RAM pressure on this VM** (7.7 GB shared): builds are single-variant, sequential, and the
   pipeline's heaviest step (d8) is capped (`-J-Xmx1G`-style flags as in the current build.sh).
   If the VM is busy, builds queue — they never corrupt.

*End of plan — Architect, v2.0.*
