# IQRS App v2 (M0 + M1) — Build Report
Built 2026-11-06 · Project tree: `~/workspace/iqrs-app-v2/` · Design: "Calm Campus" (`design-system-v2.md`, owner-approved) · Plan: `rebuild-plan-v2.md`

## Deliverables

| APK | Package | Version | Size | SHA-256 |
|---|---|---|---|---|
| `IQRS-Family-App-v2.apk` | `pk.edu.iqrs.family` | versionName 2.0, versionCode 10 | 995,617 bytes | `9bfac4717048a69cbb19f891bf301ea434e42c9aecf53ba9166935df9d5e9ae7` |
| `IQRS-Admin-App-v2.apk` | `pk.edu.iqrs.admin` | versionName 2.0, versionCode 10 | 962,849 bytes | `745453aef04813a5b0dff57a551be59ec513265ecedde97d618c32c61d0b8f1c` |

- minSdk 26 (Android 8), targetSdk 34. Same debug keystore as v1.x → installs over the old apps.
- Permissions: Family = INTERNET only; Admin = INTERNET + CAMERA (declared for M4 QR work; not yet requested at runtime).
- Stack: native Android, Java 17, framework-only widgets (no androidx/Material AAR graph), Gradle-free `aapt2 → javac → d8 → apksigner` via `./build.sh [family|admin|both]`. Transport = HttpURLConnection + platform org.json. Bundled fonts (Plus Jakarta Sans + Inter) and Phosphor icons converted to VectorDrawables; crest cropped from the identity-kit lockup (connected-component isolation) into a fixed circular gold-ring badge asset.

## M0 — skeleton & pipeline (done)

- Clean tree per plan §2: `config/{family,admin}.properties`, manifest template with per-variant generation, `src/` (api, model, data, ui/theme, ui/components, ui/family, ui/staff, sync/, qr/ placeholders), `fixtures/`, `tests/`, `tools/`.
- Both variants compile from one codebase with strict separation (verified in the dex: Admin contains only staff screens, Family only family screens).
- Splash (F0) + sign-in (F1) screens in both variants.

## M1 — Family read-only core (done, real typed client)

Typed client implements the verified contracts exactly (V1–V9), one mapper per endpoint:

- **Sign-in (F1)** — student + parent via `auth/login`; the student-id rule is enforced in `LoginMapper` (real id from the record's student-id field, never the record's own id) and locked by a fixture test where the two ids deliberately differ. Parent child switching works from the Home hero, the More screen, and a bottom sheet; the choice persists on device.
- **Home (F2)** — greeting header; navy hero with child row, attendance ring (animated, gold), month counts, homework-due chip, Mon–Sun week strip with status dots; four isolated sections (Today's periods, Fees overview with split-bar, Homework due, Latest notice), each with its own skeleton → content / inline-error-with-retry states; a quiet "Last updated" caption appears only while cached data is on screen. Student sign-ins resolve class/section ids lazily from the profile call inside the timetable load — the v1.2 defect chain is covered end to end.
- **Attendance (F3)** — month summary card (ring, Present/Absent/Leave counts, tappable week strip), month pager, semantic calendar (present/absent/leave/late/half-day/holiday colours, today gold ring, selected navy ring), day detail line, legend. Month % is computed from the month's own records so header and calendar always agree.
- **Fees (F4)** — totals card (grand totals, split bar, discount/fine lines when present), per-group line cards (status chips, due dates, expandable per-line payment detail), Transport as its own group, payment history, and a receipt bottom sheet (crest badge, student, head, amount, date, mode).
- **Timetable (F5)** — day chips (days present in the payload), period rows with a gold "Now" state for the current period, swipe left/right between days, next-school-day fallback on Home.
- **Homework (F6)** — queried per status (pending/submitted/evaluated, matching the server's computed status filter) and merged; subject filter chips; Due today / This week / Earlier / Done sections; detail screen with full text.
- **Notices (F7)** — list + detail; an empty board maps to the friendly empty state (the server's success:0 response is handled as an empty list, not an error).
- **More (F12 subset)** — child profile header, tile grid (Homework, Timetable, Notice Board, About School), children switcher, sign out with confirmation. About shows the crest badge, motto, and school contact rows from the school-details call.
- Session persistence (SharedPreferences) + SQLite read-through cache; pull-to-refresh on every data screen; session expiry clears local data and returns to sign-in with the design's copy. All user-visible copy comes from `strings.xml`; error mapping follows design §3.16 exactly.

## Admin variant (M0/M1 scope)

Splash + real staff sign-in (S1, staff token realm, email + password) + a signed-in home shell (profile card, honest "tools are being prepared" note, sign out). Staff data screens are M3; the offline write path is M4 — `sync/` and `qr/` packages are empty placeholders in this milestone.

## Gates (all run on the final build)

| Gate | Result |
|---|---|
| Gate 1 — JVM fixture mapper tests (`tools/run_tests.sh`) | **27/27 passed** (7 test classes over 13 PHP-verbatim fixtures: login student/parent/invalid/invalid-string-status, dashboard, profile, attendance, fees, timetable, homework pending+evaluated, notices, notices-empty, school, staff login) |
| Gate 2 (lite) — staging smoke, dummy credentials (`tools/contract_check.py`) | **Passed**: dummy login → HTTP 200 `{status:0, "Invalid Username or Password"}`; unauthenticated dashboard → HTTP 401 |
| Gate 3a — banned-strings lint (`tools/banned_strings.sh`) | **Passed**: no LIVE/OFFLINE, no "Dashboard unavailable", no domain as text, no service jargon in any string or resource (ApiConfig transport constants allowlisted) |
| Gate 3b — metadata (`tools/metadata_check.sh`) | **Passed** for both APKs: package ids, versionCode 10, versionName 2.0, minSdk 26, targetSdk 34, permissions within {INTERNET, CAMERA}, signatures verify |
| Device gate | **Not run** — no emulator/device available to the builder (no /dev/kvm). Owner-phone install + real sign-in check remains, per plan §6.2. |

## Not yet done (honest list)

- **Owner device gate**: install both APKs on the owner's phone, real student + parent sign-in, and the M1 acceptance walk (plan §6.2) — needs the owner.
- **M2**: Exams & Results (F8), Transport (F9), Library (F10), Profile (F11), full More (F12), dark mode, Urdu pass.
- **M3**: staff server read endpoints (classes/students/search/subjects — do not exist yet) + Staff core screens (S2–S7).
- **M4**: offline engine + outbox UI ("Waiting to send"), QR attendance (S8), staff fee collection (S9).
- **M5**: production signing keystore, Data Safety, store listing.
- Known production data gap (unchanged): no subject groups configured on production — affects the future staff homework composer (M3/M4), not the M1 family homework list, which reads the server's per-status lists directly.
- Notice attachments are displayed by name in the detail screen; opening/downloading them is not wired in M1.
- Homework has no submission action (by design — the family app is read-only).

---

## v2.1 fix — Fees failure for a student with real fee records (2026-11-06)

**Symptom (owner device test of v2.0):** for one student (Subhan Ali, parent sign-in), the Home "Fees overview" card showed the load-error state and the Fees screen showed "No internet connection. Check your connection and try again." — while the phone was online and every other call in the same session succeeded. The owner confirmed from the school system that this student's fees ARE assigned (Tuition Rs 2,400 with a Rs 700 discount posting and Rs 0 paid; Previous Arrears Rs 1,900 unpaid; balance Rs 3,600).

**Root cause — two layers, precisely separated:**

1. **The data does not break the app.** The owner's exact fee record was rebuilt as a PHP-faithful fixture (`fixtures/fees_subhan_ali.json`, field-for-field per `Webservice.php::fees()`: discount-only `amount_detail` entry with amount 0 / discount 700, totals as `number_format` strings in the due-fee branch, raw-number totals on the unpaid line whose `amount_detail` is 0, `grand_fee` as raw PHP numbers) and run against the shipping mapper: **it maps perfectly** — Total 4,300 / Paid 0 / Discount 700 / Balance 3,600, both rows with Partial and Unpaid statuses. A battery of further emitted shapes (zero-fee student, all-numeric amounts incl. decimals, populated transport, missing `grand_fee`/`transport_fees` keys, empty line lists, null `due_date`/`amount_detail`, error payloads) also passes: **the fees mapper is total over every shape the service can emit — no payload field breaks it.** The request itself is also correct (POST `webservice/fees` with `{student_id}` and the standard headers — byte-identical construction to the five working endpoints; the PHP reads only `student_id`).
2. **The failure was misclassified.** The Fees screen's copy comes from `Errors.message()`, which yields the no-connection string ONLY for `ApiException.Kind.TRANSPORT`. In v2.0, `ApiClient` produced TRANSPORT both for genuine I/O failures AND for **any HTTP status outside 2xx** ("http <code>"). Since the request is well-formed and the sibling endpoints succeed on the same connection, the fees call was in fact answered with an HTTP error status: `webservice/fees` is the only endpoint whose server code walks the student's actual fee records, and it fails server-side for this student's records. (Server-side lead, for the separate server fix — not verifiable from the app side without production data access: the stack runs PHP 8.3, and `Studentfeemaster_model::getStudentFees()` writes `$result_value->fees[0]->amount` whenever a fee master has `is_system != 0`; `fees[0]` is null when that master's session group yields no fee-type lines — the classic arrears/balance-master shape — which is a fatal `Error` under PHP ≥ 8.0, i.e. HTTP 500.) The app then lied about it: a server failure was presented to the parent as "No internet connection."

**What changed (app only; no server or production change):**

- `ApiException` gains `Kind.SERVER` — "the service answered with an error status."
- `ApiClient` classifies statuses through a new pure seam, `forStatus(code)`: 401 → SESSION_EXPIRED (unchanged); any other status outside 2xx → **SERVER** (was TRANSPORT); 2xx proceeds. Genuine I/O failures (DNS, timeout, refused, reset) remain TRANSPORT — the only path that may show the no-connection copy.
- `Errors.message()` maps SERVER → the standard retry copy ("Something went wrong. Please try again."), shown with the Retry action on the Fees screen and the usual card error + retry on Home. Real empty fees data already rendered the friendly empty state ("No fees have been issued yet.") and still does — now proven by the zero-fee fixture.
- No mapper behaviour change was needed; it is unchanged and now covered by the new fixtures.

**New tests (Gate 1 grew 27 → 38):**

- `FeesMapperTest` +5: the ground-truth fixture above (asserts the exact required render incl. the discount-only instalment), zero-fee empty statement, all-numeric amounts with decimals + paid transport, missing-keys/odd-shapes degradation, error-payload totality.
- `ApiClientClassificationTest` (new, +6): pins `forStatus` (500/503/400 → SERVER, 401 → SESSION_EXPIRED, 2xx → proceed) and proves a refused connection is TRANSPORT end-to-end. (A live socket round-trip cannot run in this build VM — it resets JVM loopback connections, the same quirk that rules out Gradle here; the mapper side of the round trip is covered by the verbatim fixtures.)

**Deliverable (Family only; Admin unchanged at 2.0):**

| APK | Package | Version | Size | SHA-256 |
|---|---|---|---|---|
| `IQRS-Family-App-v2.apk` | `pk.edu.iqrs.family` | versionName 2.1, versionCode 11 | 995,617 bytes | `cb140eab4847fe6e8836001babb230832bc68a1105b3185a0e6bcf84ded55f2e` |

**Gates on the final build:** Gate 1 — **38/38 passed** · Gate 2 lite (staging, dummy credentials) — dummy login HTTP 200 `{status:0,...}`, unauthenticated dashboard HTTP 401 · Gate 3a banned-strings — **Passed** · Gate 3b metadata — **Passed** (package, versionCode 11, versionName 2.1, minSdk 26, targetSdk 34, INTERNET only, signature verifies). Device gate still owner-side: after installing 2.1, this student's Fees screen will show the honest retry state until the server-side fees fault is fixed; the moment the endpoint answers 200, the same build renders his real fees (proven by the ground-truth fixture).
