# IQRS Android Apps — Full Audit (2026-11-15)

Owner order: 2026-11-15 ~08:24 PKT (IQRS updates chat) — complete jaanch of both
Android apps (bugs, security plugin, duplicate icons, missing elements) before
production. Method: three evidence legs run in parallel (build/bugs, security,
icons/completeness) plus first-hand CEO verification of the shipped prod APKs.
No production changes, no deploys — read/build/test only.

**Apps audited**

| | IQRS Connect | IQRS Workspace |
|---|---|---|
| Package | `pk.edu.iqrs.family` | `pk.edu.iqrs.admin` |
| Version | 2.14 (code 25) | 2.18 (code 31) |
| Prod APK | `IQRS-Connect-App-v2.14-prod.apk` — 1,643,376 B, md5 `f2f77ae84e8c8daabb8a1cb1ddf148f4` | `IQRS-Workspace-App-v2.18-prod.apk` — 1,729,392 B, md5 `133ee489c7e3def6cb556f458d80b561` |
| Source | `~/workspace/iqrs-app-v2/` — 337 Java files, 52,206 LOC under `src/` | (same tree, variant build) |

Toolchain note: `ocr`/`cs` were found wiped by a VM replacement
("command not found", `npm list -g` empty) and were **reinstalled and verified**
during this audit — `@alibaba-group/open-code-review@1.13.9`
(`ocr --version` → v1.13.9) and `@openai/codex-security@0.10.0`
(`cs --version` → 0.10.0). The command-not-found state was NOT treated as a
scan result.

---

## 1. Build

- `./build.sh both` — **SUCCESS, exit 0**, both variants. Only output of note:
  javac deprecation notes (×2, one per variant).
- Rebuilt vs prod APKs (`aapt2 dump badging` + `dump permissions`,
  build-tools 34.0.0): **identical in every field** — package, versionCode,
  versionName, label, minSdk 26, targetSdk 34, compileSdk 34, permissions —
  and **file sizes byte-count identical** (1,643,376 / 1,729,392). SHA-256
  differs despite identical size and identical signer — consistent with
  signing/zip timestamp nondeterminism, not a content difference provable
  from badging.
- Config cross-check: `config/family.properties` (25 / 2.14) and
  `config/admin.properties` (31 / 2.18) match prod and rebuilt badging exactly.
- Gates:
  - `tools/run_tests.sh` (35 JUnit classes): **OK (352 tests), 0 failed,
    0 errors**, exit 0.
  - `tools/banned_strings.sh`: **PASSED** (all 15 checks).
  - `tools/metadata_check.sh`: **PASSED on all 4 APKs** (prod + rebuilt ×2) —
    package, versions, SDK levels, every permission inside the allowed set
    {INTERNET, CAMERA, POST_NOTIFICATIONS, USE_BIOMETRIC}, signature verifies.
  - `tools/contract_check.py` (offline form): **PASSED** — 210/210 source
    routes proven live in the stored manifest. ⚠️ Caveat: the manifest was
    probed **2026-11-07T19:26:18Z** — 8 days stale; the live re-probe was not
    run (it rewrites the manifest and fires live probes, outside this lane's
    read-only scope).

## 2. Bugs (source pattern scan, `src/**/*.java`, 337 files)

Classic patterns are exceptionally clean:

| Pattern | Count |
|---|---|
| TODO / FIXME / XXX | **0** |
| `printStackTrace()` / `System.out` / `System.err` | **0** |
| String `==` defects | **0** (7 raw flags, all verified false positives: `JSONObject.NULL` sentinel checks, enum `==`, model-object identity) |
| Hardcoded `http://` URLs | **0** (3 hits are scheme-prefix *checks*, not URLs) |
| Confirmed unclosed streams/cursors | **0** (21 try-with-resources cover all opens; 5 `HttpURLConnection` sites all `disconnect()` in `finally`) |
| `catch (Throwable)` | **0** |

The one substantive code-quality problem is the swallowing-catch idiom:

- **301 catch blocks total; 206 are `catch (Exception …)` (68%); 50 are empty
  (31) or comment-only (19)** — all using the `ignored` variable name.
- **Worst — functional bug:** `ui/staff/StaffTransportActivity.java:231, 255,
  294, 336` — four empty `catch (Exception ignored) {}` around the save-button
  handlers (`routeSave`). A failure is a **silent no-op on a user-initiated
  save**: no toast, no log, the network call simply never happens.
- Camera catches: `ui/staff/StaffQrActivity.java:332, 340, 349, 368` and
  `ui/staff/StaffScanActivity.java:227, 232, 241, 281` — empty catches around
  camera session/torch/close; failures leave camera state silently
  inconsistent.
- Benign-but-undocumented: `data/FamilyRepository.java:310` (cached-homework
  parse; sibling sites carry the explanatory comment, this one does not),
  `data/SessionStore.java:113` (staff-session persistence).
- The 19 comment-only catches are documented fallbacks by design (e.g.
  `api/LibraryMapper.java:53`, `StaffQrActivity.java:401`).

## 3. Security

### 3a. OCR (Alibaba OpenCodeReview v1.13.9, delegation mode — free route)

- In-tree `ocr delegate preview` / `ocr delegate rule` fail verbatim with
  `Error: /home/hatch/workspace/iqrs-app-v2 is not a git repository` (exit 1) —
  the v2 tree is not a git repo and OCR delegation hard-requires a git root.
- Workaround (target tree untouched): `src/` copied to a throwaway git repo in
  `/tmp`, delegation run there, deleted after. Preview: **434 reviewable /
  453 total files**, all 337 Java files reviewable.
- `ocr delegate rule` on the representative set (ApiClient, SessionStore,
  OutboxEngine, MainActivity, Json) returned **one rule group only
  (`system / **/*.java`)**: typos, dead code, logic errors, severe performance,
  thread safety. **Honest gap: the OCR Java rule group contains no security
  rules** — security coverage rests on the manual pass (§3c) and Codex (§3b).
- Host review of the security-critical files against those rules: **no logic
  errors, dead code, or thread-safety findings** (OutboxEngine's unsynchronized
  `flush()` is guarded by an `AtomicBoolean` CAS gate in its sole caller,
  `WaitingSender.flushSoon()`). One minor performance item:
  `PhotoLoader.java:108-110` buffers the whole network stream via `readAll()`
  before checking the 4 MB cap — non-blocking.

### 3b. Codex Security (v0.10.0)

- `cs login status` → **"Not logged in"** (exit 1) — as expected; the owner's
  ChatGPT workspace has device-code login OFF.
- `cs scan . --dry-run` → **"Preflight complete"**, exit 0 (model gpt-5.6-sol,
  mode standard) — preflight validation passes exactly as the skill predicts.
- **A real Codex scan is pending an owner-only step**: `cs login --device-auth`
  with the owner's own ChatGPT in his own browser. Not attempted; no
  password/code requested.

### 3c. Manual security pass

**BLOCKING**

- **B1 — Production APKs are signed with the DEBUG key, and the keystore +
  password live in the source tree.** `build.sh:188-190` signs every variant
  (including `-prod`) with `iqrs-debug.keystore`, `--ks-pass pass:android`,
  alias `androiddebugkey`; the keystore (2,650 B) sits in the tree root.
  Verified on the shipped files: both prod APKs report signer
  `CN=IQRS Debug, O=IQRS School, C=PK`, cert SHA-256
  `f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e`.
  Anyone with the tree (or the well-known debug password) can build a
  malicious APK Android accepts as a legitimate same-signer **update**,
  inheriting the installed app's data access. It also cannot be published to
  Play Store. Fix: private release keystore kept out of the tree + re-sign +
  a signer-change migration plan (existing installs cannot update across a
  signer change — uninstall/reinstall or managed rollout required).
- **B2 — Session tokens and app data stored in plaintext at rest.**
  `data/SessionStore.java:26` — tokens in `MODE_PRIVATE` SharedPreferences
  (`iqrs_session`), written as plain JSON (`:35` family, `:107` staff).
  Zero uses of `EncryptedSharedPreferences` / Android Keystore in the tree.
  Same pattern for cached API payloads — children's fees/attendance/profile
  data — in plaintext SQLite (`data/CacheDb.java:23-27`) and pending staff
  fee-write payloads (`data/AdminDb.java:36-48`). Mitigating fact:
  `allowBackup="false"` blocks adb-backup extraction. Fix:
  Keystore-backed EncryptedSharedPreferences for tokens at minimum.
- **B3 — Hardcoded shared API credential embedded in the APK.**
  `api/ApiConfig.java:30`: `HEADER_AUTH_KEY_VALUE = "schoolAdmin@"`, sent on
  every request (`ApiClient.java:62-63`, `FileDownloader.java:100-101`).
  Recoverable by any string extraction from the dex. It is vendor-mandated
  for the Smart School API, so it must be **treated as public** — the server
  must never treat it as authentication; the per-user token is the only real
  credential.
- **B4 — Session token sent to arbitrary server-supplied hosts (token
  leakage).** `api/ImageUrls.java:25-27` and `api/FileLinks.java:89-91` pass
  absolute URLs from server records through untouched;
  `data/FileDownloader.java:103-104` unconditionally attaches the user-id and
  authorization headers to whatever URL it is given (callers:
  `ui/family/AttachmentOpener.java:42-50`,
  `ui/family/DownloadsScreen.java:316-324`). A malicious/compromised record
  pointing at an attacker HTTPS host receives a valid session token. Fix:
  attach auth headers only when the URL host matches the configured school
  host(s).

**NON-BLOCKING**

- N1 — AppLock PIN digest is a **single SHA-256 iteration** over `salt:pin`
  (`AppLockRules.java:37-38`) for a 4–6 digit PIN — trivially brute-forced
  offline if the prefs file is extracted. Use a stretched KDF.
- N2 — **No PIN attempt throttling/lockout** in the unlock UI
  (`AppLockActivity.java:115, :220`).
- N3 — Biometric prompt uses the legacy builder without
  `setAllowedAuthenticators(BIOMETRIC_STRONG)`, while availability is checked
  against STRONG on API 30+ (`BiometricUnlock.java`).
- No certificate pinning (platform TLS defaults are intact — a hardening
  note, not a defect).
- `PhotoLoader.java:108-110` read-before-size-check (see §3a).
- Server-supplied video links opened via external `ACTION_VIEW`
  (`DownloadsScreen.java:155-166`) — by design ("never an embedded web
  view"), no credentials attached; minor phishing surface only.

**CLEAN (verified)**

- **No WebView anywhere**: grep for `WebView`, `setJavaScriptEnabled`,
  `addJavascriptInterface`, `loadUrl` across `src/` = **zero hits**. The apps
  do not embed iqrs.edu.pk.
- **No cleartext**: `usesCleartextTraffic="false"` (manifest template:21,
  confirmed in both generated manifests); no network-security-config file;
  all hardcoded endpoints HTTPS (`ApiConfig.java:11-15`).
- **No custom TLS trust code**: zero hits for TrustManager / HostnameVerifier
  / SSLSocketFactory — platform certificate + hostname verification only.
- **No logging**: zero hits for `Log.`, `System.out`, `printStackTrace` —
  nothing can leak tokens/PINs/amounts to logcat.
- **Permissions least-privilege, per variant** (verified on prod APKs):
  Connect = INTERNET + POST_NOTIFICATIONS + USE_BIOMETRIC (**no CAMERA**);
  Workspace = those three + CAMERA. No location/contacts/storage/SMS.
  (Note: this supersedes the older "INTERNET + CAMERA only" expectation —
  POST_NOTIFICATIONS serves the on-device `LocalNotifier`, USE_BIOMETRIC the
  AppLock; both are used in code.)
- **Exported surface = launcher only**: SplashActivity `exported="true"`;
  every other activity, the admin RetryReceiver, and SharedFileProvider are
  `exported="false"` (provider with grantUriPermissions; its `resolve()`
  canonicalizes paths and rejects anything outside the downloads dir).
- **No SQL injection**: bound parameters / ContentValues throughout;
  `client_txn_id` UNIQUE (`AdminDb.java:38`) and preserved across retries —
  no double-posting path found in the outbox.
- **Passwords never persisted** (login request body only). AppLock stores a
  salted PIN digest (16-byte `SecureRandom` salt), never the PIN; constant-time
  verify; biometric opt-in and preference-only.
- QR/manual code input is trimmed, non-empty-checked, and used only as a data
  string — never treated as a URL/intent/command (per M5 audit, re-confirmed
  by structure).

## 4. Icons / UI

Icon sources: `assets-common/icons-svg/` (Phosphor), converted by
`tools/gen_assets.py:34-42` to `src/res/drawable/ic_*.xml`.

- Inventory: **88 SVGs** — bold 29, fill 29, regular 30 (regular-only extra:
  `envelope`). Identical filenames across weights are intentional variants.
- **Duplicate found: exactly 1 byte-identical pair** — `bold/phone.svg` ≡
  `fill/phone.svg` (md5 `3be7b8b182ccd96e48989b4e57311193`). There is no
  distinct fill phone glyph. (Launcher `ic_launcher.png` ≡
  `ic_launcher_round.png` in all 5 densities is by design.)
- Drawables: **92 `ic_*.xml` on disk; 0 duplicates among them; 2 missing** —
  `ic_phone_bold` and `ic_phone_fill` were never generated (consequence of
  the duplicate above). 6 hand-made drawables have no SVG source:
  `ic_download`, `ic_lock`, `ic_qr_code`, `ic_qr_code_fill`, `ic_share`,
  `ic_video_camera`.
- **Referenced vs missing: 44 distinct drawables referenced in code; 0 missing
  on disk** — nothing referenced is broken.
- **Unreferenced: 49 of 93 drawable resources ship dead** — including **all 28
  `_bold` variants** (zero `*_bold` references in code) and the entire
  `dots-three`, `gear-six`, `magnifying-glass`, `x` families in every weight.
- **Same icon → two functions (owner's specific question — YES, found):**
  - `ui/staff/StaffNav.java:83-85` — the OFFICE bottom-nav slot uses
    `ic_phone` for **both** unselected and selected states (the only slot
    without a fill pair — caused by the missing `ic_phone_fill`). Bottom navs
    are otherwise clean (one icon per destination, regular/fill pairs).
  - Connect "More" grid (18 tiles, `ui/family/MoreScreen.java`): 6 icons
    reused — `ic_book_open` ×3 (Homework :165, Subjects :193, Daily
    Assignments :197), `ic_clock` ×2 (Timetable, Lesson Plan),
    `ic_calendar_blank` ×2 (Events, Leave), `ic_chart_bar` ×2 (Results,
    Online Exams), `ic_books` ×2 (Library, Syllabus), `ic_student` ×2
    (Profile, Teachers).
  - Workspace "More" (32 rows, `ui/staff/StaffMoreActivity.java`):
    `ic_book_open` ×6, `ic_wallet` ×5, `ic_receipt` ×4, `ic_calendar_check` ×3,
    `ic_user` ×3, `ic_squares_four` ×3, `ic_books` ×2, `ic_megaphone` ×2.
  - `ic_receipt` (23 references, the most-used icon) also doubles as the
    generic attachment icon in 8 family detail screens.

## 5. Missing / Extra Elements

**Screens present** (from build.sh-generated manifests):

| | Connect | Workspace |
|---|---|---|
| Manifest activities | 21 (Splash + AppLock, Login, Main + 18 family) + 17 hosted screens inside MainActivity | 73 (Splash + 72 staff) + RetryReceiver |
| Source check | 19 of 20 `ui/family` activities in manifest (20th, `WaveBActivity`, is an abstract base — correctly unlisted) | **72/72 staff activities in manifest, 0 missing** |

**Catalogue correction:** the "54 modules / 171 screens" catalogue is **not in
the v2 source** — it was the legacy v1 bundle's module list (pruned 54 → 50 in
`BUILD-REPORT-two-apps.md`). In v2 the catalogue is **server-driven**:
`ModuleCatalogMapper` / `ModuleMapper` read the school's module switches;
fixtures pin **25 module codes** across 4 categories. Three modules have no
screen **by design** — `online_course`, `cbseexam`, `hostel_rooms`
(`ModuleCatalogMapper.java:32-35`); when the school has them off, the app
renders a non-clickable "not set up yet" row (`MoreScreen.java:326-352`,
decision D-W2-1a), never a dead tile. `live_classes`, once in that class, now
has a real screen.

**Role gating — PASS, airtight on all three mechanisms:**

- QR attendance is **staff/admin-only**: family build excludes the `qr`,
  `sync`, and `ui/staff` packages (`build.sh:172`); `StaffQrActivity` /
  `StaffScanActivity` exist only in the admin manifest block; the QR launcher
  shortcut exists only in `shortcuts_admin.xml`; CAMERA is injected only in
  the admin branch (`build.sh:42`). Deliberate documented exception: the
  family APK bundles ZXing core for **encoding** the student card's QR /
  Code 128 on-device — scanning/decoding stays staff-only.
- **Premise correction — the family app is NOT read-only and v2 has no guest
  mode** (0 hits for "guest" in `src/`; guest existed only in legacy v1).
  Family has **15 own-child-scoped write operations** via
  `api/FamilyWrites.java` (called from `data/FamilyRepository.java:742-1026`):
  homework submit, daily-assignment create/edit/delete, leave
  create/update/delete, offline bank-payment report, document upload, profile
  edit, timeline save/delete, online-exam save, personal tasks, behaviour
  comment, lesson-forum add/delete, teacher rating. **No staff capability
  leaks in**: no attendance marking, no fee collection, no leave approvals,
  no student/staff editing in the family variant.
- Present-but-should-not-be: **nothing functional**. Cosmetic only: (1) both
  APKs carry both apps' name/tagline strings (shared `strings.xml`,
  acknowledged in `BUILD-REPORT-apps-rename.md`; each app renders only its
  own); (2) `FamilyWrites.java` is compiled (unused) into the Workspace dex —
  harmless dead code.

**Known-deferred items — CONFIRMED ABSENT (Wave C, owner's separate
programme, decided 2026-11-15 for after 09:00):**

| Item | Evidence |
|---|---|
| Firebase / FCM push | 0 hits (`firebase\|fcm\|google-services`); no `google-services.json`. Notifications are on-device only (`data/LocalNotifier.java`) |
| Online fee gateway | 0 hits for any gateway; only offline bank-payment reporting exists |
| Online Course | No screen/mapper/fixture; only the by-design "not set up yet" row |
| Urdu / RTL | No `values-ur`, no `supportsRtl`/`layoutDirection`; UI is English/LTR (Roman-Urdu copy exists in some strings) |

**Identity — CONFIRMED:**

- Labels: `IQRS Connect` / `IQRS Workspace` from `config/*.properties` into
  the manifest template; taglines present and wired — "For Students &
  Parents" and "For Teachers & Administrators" (`strings.xml:9, :11`,
  rendered on both login screens and About surfaces).
- Crest: **fixed-size circular gold-ring badge only** — `CrestBadge.java:12-31`
  (white circular badge, 2dp gold ring `#C9A227`, FIT_CENTER, 7% inset, never
  clipped/stretched/recoloured); fixed call-site sizes only (Splash 96dp,
  sign-in 54dp, Workspace home 48dp, AppLock 72dp, receipt 56dp). Launcher
  art: crest at 82% centred on navy `#10204D`. No other logo assets exist.

**Stale documents warning:** `M5-AUDIT.md` (2026-11-07) audits Family v2.2 /
Admin v2.3.1 with 90 tests — it does **not** describe the current v2.14 /
v2.18 builds and must not be cited for them.

---

## 6. Production-Readiness Verdict

# READY-WITH-FIXES

The apps are functionally complete and unusually clean (352/352 tests, clean
rebuild reproducing prod exactly, zero TODO/printStackTrace/String-`==`/
cleartext/resource-leak defects, airtight role gating, no WebView, correct
identity). Production rollout must wait for the blockers below — none requires
new features; B1 and B4 are the true gates.

### Blockers (fix before production)

1. **B1 — Debug-signed prod APKs** (§3c): re-sign with a private release
   keystore kept out of the source tree; plan the signer-change migration
   for existing installs. Also the Play Store gate (owner's M5 step —
   production keystore is his).
2. **B4 — Auth headers leak to arbitrary server-supplied hosts** (§3c):
   host-allowlist in `FileDownloader` / `ImageUrls` / `FileLinks` before
   attaching session headers.
3. **B2 — Plaintext token/data at rest** (§3c): Keystore-backed encrypted
   storage for session tokens at minimum (children's data is cached in the
   same plaintext pattern).
4. **B3 — Embedded shared Auth-Key** (§3c): cannot be removed (vendor API
   requirement) — production is only safe on the confirmed basis that the
   server treats this header as public and never as authentication.
5. **Silent save failure** (§2): `StaffTransportActivity.java:231, 255, 294,
   336` — surface an error (toast/retry) instead of silently dropping a
   user-initiated `routeSave`.
6. **B6 — Print design parity** (§7, added 2026-11-15 on the owner's
   addition): see §7 for the full print/document inventory and the
   updated blocker entry.
7. **B7 — Role-aware visibility** (§8, added 2026-11-15 on the owner's
   addition): see §8 for the surface inventory, the concrete gap
   examples, and the updated blocker entry.

### Non-blockers (fix in the refinement pass)

- Icon fixes: regenerate/deduplicate the phone glyph so `ic_phone_fill`
  exists and the StaffNav OFFICE slot gets its selected-state icon; give the
  reused More-grid icons distinct glyphs where functions differ
  (`ic_book_open` ×3/×6, `ic_wallet` ×5, `ic_receipt` ×4+); drop the 49
  unreferenced drawables (all 28 `_bold`) from the shipped tree.
- N1/N2/N3 AppLock hardening: stretched PIN KDF, attempt throttling,
  `BIOMETRIC_STRONG` on the biometric prompt.
- Certificate pinning (optional hardening); PhotoLoader size-check before
  buffering.
- Re-run the contract live probe (manifest is from 2026-11-07) as part of
  the production battery.
- `FamilyWrites.java` dead code in the Workspace dex; both-apps strings in
  each APK (cosmetic).

### Pending owner-only steps (not defects)

- **Codex Security real scan**: preflight passes; sign-in
  (`cs login --device-auth`, owner's ChatGPT) is his step — the deep scan
  result is the one audit leg still outstanding.
- **Production keystore + Play Store publication (M5)**: keystore password
  and package decisions are his.
- **First production sign-in + §6.4 device pass** on his phone (unchanged
  from the 2026-11-08 status).
- **Wave C** (Firebase push, online fee gateway, Online Course, Urdu/RTL):
  confirmed absent; owner's programme for today after 09:00, tracked
  separately from this audit.

---

## 7. Print-design parity (owner addition, 2026-11-15)

**Owner's rule (2026-11-15 ~08:38 PKT):** every print-related output in the
mobile apps must carry the **web app's print design** — the unified print
system (Print Center / Print Studio: `Print_viewmodel` producers, the
unified receipt views, `Exam_documents`, Print Canvas, the governed
payslip producer) — **not** the app's own design, and not an ad-hoc
template of its own.

**Method:** full-source sweep of `~/workspace/iqrs-app-v2/src` (337 Java
files) for `print`, `PdfDocument`, `PrintManager`, share/export intents
(`ACTION_SEND` / chooser), download/open-file machinery, and every
document door (`"kind"` bodies), then a server-side read of both door
implementations (`api/Familydocs.php`, `api/Staffapi.php` in
`~/workspace/iqrs-repo/api/`) to verify what actually renders the files,
and of the web print record (BL-034 / BL-035 / BL-044 execution records)
to name the unified target for each document.

**Negative results that bound the inventory:** there is **no**
`PrintManager`, `PdfDocument`, bitmap/canvas document rendering, or
share/export intent anywhere in either app — the apps never print
natively and never export a self-made file. Every document an app hands
to a user arrives by exactly three routes: (i) a server document door
(`fileOpen`), (ii) a stored file the school/family uploaded, opened
as-is, or (iii) an in-app screen that itself lays out a document.

### 7.1 Classification key

- **(A) SERVER-RENDERED** — the app asks the service for the document
  and opens the returned file; the app lays out nothing.
  - **A⚠** — server-rendered, **but in the API extension's own ad-hoc
    inline HTML**, not the unified web print design (see §7.3).
  - **A◐** — server-rendered partly from the school's designed template
    (certificate text/headers), with a recorded design loss.
  - **A-file / A-data** — a stored file (school/family upload) or a raw
    data file (CSV); no print design applies to it.
- **(B) APP-RENDERED** — the app itself lays out a printable /
  document-style view in its own design. **Violates the owner's rule.**
- **(C) ON-SCREEN ONLY** — a data view, not a print/document output;
  out of scope, listed so the boundary is proven.

### 7.2 Inventory — every print/document output in both apps

| # | App | Screen (file:line) | Document | Class | Door / kind → server renderer |
|---|---|---|---|---|---|
| 1 | Connect | Fees → payment row → "Printed receipt" (`ui/family/FeesScreen.java:515–537`) | Fee receipt (official) | **A⚠** | `POST familydocs/fileOpen` kind=`fee_receipt` (`FamilyDocOpener.java:39`; `FamilyRepository.java:1536`) → `Familydocs::fee_receipt()` — own inline HTML + mPDF |
| 2 | Connect | Exam result → "Report card" (`ui/family/ExamResultScreen.java:142–175`) | Report card | **A⚠** | `familydocs/fileOpen` kind=`report_card` → `Familydocs::report_card()` — own inline HTML + mPDF |
| 3 | Workspace | Fee receipt → "See the receipt file" (`ui/staff/StaffFeeReceiptActivity.java:148–163`) | Fee receipt (official) | **A⚠** | `POST staffapi/fileOpen` kind=`fee_receipt` (`W2Ui.openFile`, `W2Ui.java:154`; `StaffRepository.java:1123`) → `Staffapi::fileOpen` — own inline HTML + mPDF |
| 4 | Workspace | Exam result → "Marksheet" (`ui/staff/StaffExamResultActivity.java:129–133, 142–151`) | Marksheet | **A⚠** | `staffapi/fileOpen` kind=`marksheet` — own inline HTML + mPDF |
| 5 | Workspace | Exam result → "Admit card" (`ui/staff/StaffExamResultActivity.java:135–139, 142–151`) | Admit card | **A⚠** | `staffapi/fileOpen` kind=`admit_card` — own inline HTML + mPDF |
| 6 | Workspace | Certificates → "Make" (`ui/staff/StaffCertificatesActivity.java:160–170`) | Student certificate | **A◐** | `staffapi/fileOpen` kind=`certificate` — body from the DB certificate template (text + header/footer fields), but the template **background image is explicitly not applied** (server answers `background_applied:false` with that note) |
| 7 | Workspace | Certificates → ID card → "Make the card file" (`ui/staff/StaffCertificatesActivity.java:227–256`) | Student ID card PDF | **A⚠** | `staffapi/fileOpen` kind=`id_card` — a bare text block (school, name, Adm, class, guardian, **QR value printed as a text string**); the designed ID-card template is **not** rendered (86×54 mm page) |
| 8 | Workspace | Certificates → staff ID card → same button (`StaffCertificatesActivity.java:227–256`) | Staff ID card PDF | **A⚠** | `staffapi/fileOpen` kind=`staff_id_card` — same bare-text rendering |
| 9 | Workspace | Reports → run → "CSV" (`ui/staff/StaffReportRunActivity.java:105–114`) | Report export | **A-data** | `staffapi/fileOpen` kind=`report` — server-generated CSV of the governed report run; a data file, no design surface |
| 10 | Workspace | Content → "Open" (`ui/staff/StaffContentActivity.java:128–140`) | Download-centre file | **A-file** | `staffapi/fileOpen` kind=`document`, source=`content` — the school's stored file, byte-for-byte |
| 11 | Workspace | Finance (income/expense) → document (`ui/staff/StaffFinanceActivity.java:134–146`) | Income/expense attachment | **A-file** | `staffapi/fileOpen` kind=`document`, source=`income`/`expense` — stored file, byte-for-byte |
| 12 | Connect | Downloads / homework & notice attachments / profile documents (`ui/family/DownloadsScreen.java:360`, `AttachmentOpener.java:77`, `DocumentsActivity.java`) | School-shared files, attachments, the child's uploaded documents | **A-file** | `FileDownloader` pipeline — stored files opened as-is; the app designs none of them |
| 13 | Connect | Fees → payment row → receipt sheet (`ui/family/FeesScreen.java:478–546`) | **Fee receipt (in-app)** | **B** | No door — the app builds the receipt itself: crest badge (`FeesScreen.java:482`), school name, "Receipt" title, `receiptRow` lines (student/for/amount/date/mode, `:498–505`), PAID chip, and the note *"Thank you. Keep this receipt for your records."* (`strings.xml:109`) |
| 14 | Workspace | Fee receipt screen (`ui/staff/StaffFeeReceiptActivity.java:76–167`) | **Fee receipt (in-app)** | **B** | No door for the screen itself — a full receipt card in app design (school name, receipt no, student/class/date/fee/mode/received-by, amount–discount–fine–received figures). The code admits it: *"the screen copy is the receipt"* (`model/FeeDesk.java:292`) and the on-screen caption *"This is the screen copy of the receipt. The school office can print the paper copy."* (`strings.xml:859`) |
| 15 | Workspace | Payroll → payslip sheet (`ui/staff/StaffPayrollActivity.java:93–145`) | **Payslip (in-app)** | **B** | No door exists at all — the app lays out the complete payslip (basic, allowances, gross, deductions, tax, net, status, mode, date) in its own sheet design. Server side is read-only by the earlier D-W2-3 decision (*"payslips are generated on the web; here they are read"* — `Staffapi.php` HR-depth header, ~L8204), so the app-designed sheet is the **only** payslip a staff member can obtain from the app |
| 16 | Connect | Student Card display (`ui/family/StudentCardScreen.java`) | In-app student card (display) | **C** | **Explicitly out of scope** — the banking-style in-app card is the owner's own 2026-11-07 design decision; it is an on-screen display, not a print output, and is **not** flagged |
| 17 | Connect | Exam result summary + marks cards (`ExamResultScreen.java:182+`) | Result data view | **C** | Data cards; the printed form is #2 (report card) |
| 18 | Workspace | Exam result sheet screen (`StaffExamResultActivity.java:84–140`) | Result data view | **C** | Data view; the printed forms are #4 / #5 |
| 19 | Workspace | ID-card field sheet (`StaffCertificatesActivity.java:227–256`, `showCard`) | ID-card field preview | **C** | Field list preview only; the printable file is #7 / #8 |
| 20 | Both | Fee statement screens (Connect `FeesScreen.java:89+`; Workspace `StaffFeeStatementActivity.java:74+`) | Fee statement (ledger view) | **C** | On-screen ledgers with no print/export door in either app. **Gap note:** the web Print Center carries a *unified fee statement* and a *household combined statement* (BL-034) — the apps offer no statement document at all |
| 21 | Workspace | Report run tables (`StaffReportRunActivity.java:65–103`) | Report data view | **C** | Readable screen rendering by documented design (*"the service's table rendered readably… the spreadsheet file comes from the service too, never from the app re-typing the table"*); the file form is #9 |
| 22 | Connect | Online exam result (`OnlineExamResultActivity.java`), offline-payment slips (`OfflinePaymentsActivity.java`) | Result view / family's own uploaded payment slips | **C / A-file** | On-screen result; the slips are the family's own photos/files, opened as-is — the app designs neither |

**Counts:** 22 inventoried outputs — **A: 12** (9 generated documents:
8× A⚠ + 1× A◐; 1× A-data CSV; stored-file openings counted as 2 rows,
#10–#12 covering 5 call sites) · **B: 3** · **C: 7**.

### 7.3 The server-rendered legs are NOT the unified web design (A⚠)

The fee official-receipt leg the audit's starting evidence pointed at
**is truly server-rendered** — verified in `api/Familydocs.php`:
`fee_receipt()` builds the PDF on the server and returns it base64 in
the authenticated answer; the app (`FamilyDocOpener`) only saves and
opens the file. The same holds for every `fileOpen` kind on both doors.

**But** none of those PDFs pass through the web system's unified print
producers. Both API controllers carry their **own private copy** of a
mini print layer — `doc_header_html()` / `w2_doc_header_html()`
(`Familydocs.php` ~L549; `Staffapi.php` ~L4695: a text-only letterhead,
school name in navy `#10204D` over a 2px rule, no crest, no footer, no
signature block, no print.css) plus hand-built inline-styled tables per
kind, rendered by the tree's mPDF (`pdf_bytes()` / `w2_pdf_bytes()`).
The unified web producers — `Print_viewmodel` + `print/printFeesByName.php`
/ `print/thermalPrintFeesByName.php` for receipts, `Exam_documents` for
marksheet/admit card, Print Canvas for certificates/ID cards, the
governed payslip producer — are **never invoked** by the API doors.
So even the "official" documents the apps deliver today carry a third,
API-only design — neither the app's design nor the web app's unified
print design. The owner's rule is therefore breached on **two layers**:
the app layer (§7.4, B items) and the API layer (this section).

Worst single case: the ID-card PDFs (#7/#8) do not render the school's
designed card template at all — no photo, no card layout, and the QR
code is printed as a literal text string (`QR: <value>`), where the web
Print Canvas ID card is a designed CARD-profile document (BL-034).

### 7.4 Blocker B6 — Print design parity (production blocker list, updated)

**B6 — Print design parity.** Production must not ship with
app-designed or API-designed documents where the web unified print
design exists. Items, with the web equivalent each must carry:

| Item | What renders today | Web unified equivalent (target) |
|---|---|---|
| **B6-1** Family fee-receipt sheet (#13) | App layout (`FeesScreen.java:478–546`) | Unified fee receipt — Print Center money documents (BL-034): `Print_viewmodel::fromFeeRecord()` via producer views `print/printFeesByName.php` (A5-receipt) / `print/thermalPrintFeesByName.php` (THERM-80), doors `Studentfee::printFeesByName` / portal twin `user/User::printFeesByName`. Fix shape: the sheet stops presenting an app-designed receipt; the receipt a family keeps/prints is the server document (the #1 door, re-rendered per B6-4) |
| **B6-2** Staff fee-receipt screen (#14) | App layout (`StaffFeeReceiptActivity.java:76–167`) | Same unified fee receipt as B6-1 (admin door `Studentfee::printFeesByName`) |
| **B6-3** Staff payslip sheet (#15) | App layout (`StaffPayrollActivity.java:93–145`); no server door exists | Print Center payslip (BL-044 Set 2): `Print_viewmodel::payslip()` producer + standalone print document `payslip.php`, routes `admin/printcenter/payslips` / `payslip/<id>`, generation-logged. Fix shape: add a `payslip` kind to `staffapi/fileOpen` rendered by that producer (or retire the sheet as "the payslip" and label it a data view) |
| **B6-4** All A⚠ generated documents (#1–#5, #7, #8) | API-private inline HTML (`doc_header_html` / `w2_doc_header_html` + per-kind tables, mPDF) | Re-render each kind through the unified producers: fee receipt → unified receipt views (as B6-1); report card / marksheet → `Exam_documents` + Print Center routes `admin/Printcenter::exammarksheet` (BL-035); admit card → `admin/Printcenter::examadmitcard` (BL-035, `Exam_gate`-aware — note the API admit card currently applies **no** fee gate); student/staff ID cards → Print Canvas CARD-profile documents (BL-034) with photo + real QR/barcode assets, replacing the bare-text rendering |
| **B6-5** Certificate design loss (#6, A◐) | DB template text/headers rendered, **background image dropped** (`background_applied:false`) | Print Canvas certificates & letters (BL-034) — snapshot-pinned designed rendering incl. background, "Reprint original" policy |

**Blocker list as updated by this section:** B1 (debug signing) · B4
(token leakage to arbitrary hosts) · B2 (plaintext at rest) · B3
(embedded vendor Auth-Key) · silent-save failure (§2) · **B6 — Print
design parity (B6-1…B6-5, this section)**. The verdict of §6
(READY-WITH-FIXES) is unchanged; B6 joins the fix-before-production
list. Non-blocker gap recorded for the fix lane: no fee-statement
document exists in either app (#20) although the unified fee statement
and household combined statement exist on the web (BL-034).

---

## 8. Role-aware visibility (owner addition, 2026-11-15)

**Owner's rule (2026-11-15 ~08:41 PKT):** the apps must be role-aware —
a login sees **only** the icons and features its assigned
roles/permissions include; anything blocked for that role must **not
appear at all** — not disabled, not greyed, not visible-but-error-on-tap.

**Method:** read-only source audit of `~/workspace/iqrs-app-v2/src`
(337 Java files) plus the capabilities fixtures stored in the tree
(`fixtures/w1b_cap-admin.json` = staff 113 Super Admin, 41 modules;
`w1b_cap-teacher.json` = staff 114 Teacher, 22 modules;
`w1b_cap-limited.json` = staff 115 "TEST Limited", **0 modules**; w2b
twins of the same three). No live staging re-probe was run in this
lane; where a role has no fixture (Accountant, Receptionist), the
example is marked *code-derived*, and a live probe is listed as a
pending step (§8.6). This section audits **UI visibility only** — the
server's own permission checks on data calls were proven in earlier
waves and are not re-litigated here.

### 8.1 How visibility is decided today

**The foundation is sound.** `Capabilities.can()` is strict — a
missing module, permission key, or action answers `false`; only a
server-issued `superAdmin` flag answers true wholesale
(`model/Capabilities.java:134–145`). The model's own contract states
the intent: "The app shapes its menus and navigation from this map
and from nothing else" (`Capabilities.java:10–16`). Two of the three
big staff surfaces honour it (§8.2, class A). The gaps are in the
third surface (Home), in the always-on Scan door, in deep-screen
entry, and in the family app's different, weaker mechanism.

**Staff (Workspace)** decides visibility three ways, mixed per
surface: (i) the capabilities map (`caps.can/canAny/hasModule`) —
nav slots, More grid, Fees Desk tabs, several in-screen actions;
(ii) hardcoded per-variant — anything compiled into the admin build
is shown to every staff login (Home quick tiles/tools, Scan, launcher
shortcuts); (iii) server-data-driven — Home stats and worklist cards
exist only if the server returns them. The school-configuration half
of the map (`Capabilities.configured()` / `modulesConfigured`) is
**never consumed** by any staff screen (no call site outside the
model) — staff visibility has no school-switch layer at all.

**Family (Connect)** has no per-user permission map. Visibility is:
(i) hardcoded per variant — the 4-tab bar and most tiles are the same
for every parent and every student login; (ii) school module
switches (`ModuleStatus.enabledFor`, server-issued) for 6 More-grid
tiles + fail-closed for the bank-payments tile; (iii) session data —
the child switcher and all reads are scoped to the session's own
children. Parent vs student logins see **identical** navigation and
grids; the only `isParent()` UI differences are the children list /
child switcher and parent-only refresh (`HomeScreen.java:120`,
`MoreScreen.java:76,226`, `FeesScreen.java:92`,
`ProfileScreen.java:93`).

### 8.2 Surface inventory + classification

**A** = permission-driven (hidden when not assigned) ·
**A\*** = school-switch-driven (family analogue; not a user
permission) · **B** = variant-driven (visible to every login of the
variant, regardless of assigned role) · **C** = server-data-driven
(appears only when the server returns data; not a permission
control) · **P** = personal-always (the login's own data only —
calendar, own attendance, own profile; not a role feature).

#### Workspace — 37 inventoried surface entries: A 18 · B 10 · C 2 · P 7

| # | Surface | Class | Evidence |
|---|---|---|---|
| W1 | Bottom-nav work slots (2 of 5) | **A** | `api/NavSlots.java:59–83` `available()` gates every Dest on `caps`; `slotsFor()` (`:102–119`) fills only allowed destinations, empty map → no slots. The *preference order* uses the coarse role-name string (`:86–94` — teacher/accountant/receptionist/librarian/admin), but every candidate is still permission-filtered, so the string can reorder, never reveal |
| W2 | Bottom-nav centre **Scan** | **B** | `ui/staff/StaffNav.java:62–64,106–109` — always added, always opens `StaffQrActivity`; that activity contains **zero** capabilities references (whole-file grep) |
| W3 | Home quick tile — Mark attendance | **B** | `StaffHomeActivity.java:108–110` built unconditionally in `onCreate`; `loadNav()` never hides it |
| W4 | Home quick tile — QR scan | **B** | `StaffHomeActivity.java:111–113`, same as W3 |
| W5 | Home quick tile — Homework | **A** | Hidden at `StaffHomeActivity.java:474` when `!caps.can("homework","homework","view")` (async — see §8.4) |
| W6 | Home quick tile — Notice | **B** | `StaffHomeActivity.java:121–124` built unconditionally; never hidden, even without `communicate/notice_board view` |
| W7 | Home Tools — Classes link | **B** | Tools card built unconditionally; only the Fees row of the same card is ever hidden |
| W8 | Home Tools — Students link | **B** | Same card; no caps check (contrast W1 STUDENTS slot and §8.3) |
| W9 | Home Tools — Fees row | **A** | Hidden at `StaffHomeActivity.java:470` when `!caps.can("fees_collection","collect_fees","view")`. Note the key is *narrower* than the nav/More test (`canAny … search_due_fees/search_fees_payment/collect_fees/offline_bank_payments`): a login with due-fees search but no collect permission sees Fees in nav + More but not on Home — inconsistent, in the safe direction |
| W10 | Home stats cards | **C** | `renderStats()` shows only what the staff dashboard endpoint returns |
| W11 | Home worklist cards | **C** | Cards are server-issued (`loadWorklist`); taps route via `StaffNav.openWorklistCard` with **no local caps re-check** — the server is the only filter |
| W12 | Launcher shortcuts (QR / Fees / Attendance) + Home `open` extras | **B** | `res/xml/shortcuts_admin.xml` — static shortcuts, identical for every install and login (static shortcuts cannot be per-user filtered); `StaffHomeActivity.applyOpenExtra` (`:176 ff`) opens the three screens with no caps check |
| W13 | More — My Leave | **A** | `StaffMoreActivity` render: `caps.can("human_resource","apply_leave","add")` |
| W14 | More — Timetable | **A** | `caps.can(academics …teachers_time_table/class_timetable, view)` |
| W15 | More — Attendance section (Classes, student leaves, staff leave approvals) | **A** | Section gated on `student_attendance view`; sub-links separately gated (`approve_leave view`, `human_resource/approve_leave_request view`) |
| W16 | More — Exams + Online Exams/Question Bank | **A** | Gated on `examination/exam view` / `online_examination view` |
| W17 | More — Library (+ Due) | **A** | Gated on `library books/issue_return view` |
| W18 | More — Money (Fees Desk, Collect, Bank, Fee Setup) | **A** | Section `canAny(fees_collection…)`; each link separately gated |
| W19 | More — Accounts (Finance, Reports) | **A** | `income/expense view`, `hasModule("reports")` |
| W20 | More — Front Office link | **A** | `canAny(front_office…)`; the destination screen is itself fully caps-rendered (W24) |
| W21 | More — Staff Directory link | **A** | `caps.can("human_resource","staff","view")` |
| W22 | More — Payroll link | **A** | `caps.can("human_resource","staff_payroll","view")` |
| W23 | More — Students link (People section) | **B** | `StaffMoreActivity.java:202` — added **unconditionally**; the People card is therefore rendered for every staff login, and a login with no `student_information` permission still gets the Students door (the section's other two links are A, W21/W22) |
| W24 | In-screen action/section gates (where present) | **A** | `StaffFrontOfficeActivity:43–77` (each sub-door gated); `StaffFeesDeskActivity:112–114` (per-tab `can`); `StaffStudentActivity:96–99` (behaviour/transport sections); `StaffExamDetailActivity:115–124` (publish/rank actions); `StaffExamResultActivity:129–135` (print marksheet/admit-card buttons); `StaffDirectoryDetailActivity:107–110` (edit/timeline/ID-card); `StaffMarksEntryActivity:105–108` (save button hidden without `exam_marks edit`) |
| W25 | Deep-screen **entry** gates (~45 staff screens) | **B** | 47 of 75 files in `ui/staff/` contain zero capabilities references (incl. `StaffClassesActivity`, `StaffStudentsActivity`, `StaffFeesActivity`, `StaffQrActivity`, `StaffHomeworkListActivity`, `StaffNoticesBoardActivity`, `StaffPayrollActivity`, `StaffReportsActivity`, `StaffTasksActivity`). Entry is controlled only by which menu surface offered the door — any B-class door (W2–W4, W6–W8, W12, W23) delivers a blocked login into the screen, where only the server's data refusal stops it: visible-but-error, exactly what the owner's rule forbids |
| W26 | Personal-always: Home/More shell, Calendar, My Tasks (More), My Attendance, Profile, Waiting, App Lock | **P** | `StaffMoreActivity:62` ("My day — personal, always available"), `:82` (own attendance). Own-data only. One inconsistency: the nav TASKS slot is caps-gated (`NavSlots` requires `calendar_to_do_list`) while the More Tasks link to the same screen is not |

#### Connect — 14 inventoried surface entries: A\* 7 · B 4 · C 3

| # | Surface | Class | Evidence |
|---|---|---|---|
| F1 | Bottom nav (Home / Attendance / Fees / More) | **B** | `ui/family/MainActivity.java:51–56` — fixed 4 items for every family login; parent and student identical |
| F2 | More grid — Homework, Results, Transport, Library, Downloads, Events tiles | **A\*** | `MoreScreen.applyModuleVisibility` (`:101–134`) hides each when the **school** switch is off (`homework`, `examinations`, `transport`, `library`, `download_center`, `calendar`). Fail-open: on error "every tile stays as rendered" (`:130`); tiles also render visible first and hide asynchronously |
| F3 | More grid — Bank Payments tile | **A\*** (fail-closed) | `MoreScreen:60–71` — starts `GONE`, shown only when the server proves offline payments are on; failure keeps it hidden. The one fail-closed gate in the family app |
| F4 | More grid — 11 ungated tiles (Timetable, Notices, Live Classes, Subjects, Profile, Daily Assignments, Leave, Online Exams, Syllabus, Lesson Plan, Teachers) | **B** | `MoreScreen.render()` — no switch or session check. Two notes: Live Classes is *deliberately* always present per the owner's earlier requirement (screen carries the honest state); **Online Exams is not gated by the `examinations` switch that gates the Results tile** — an inconsistency, not a policy |
| F5 | Home bento tiles (Results, Transport, Library, Downloads, Events, Subjects, Live Classes) | **B** | `HomeScreen.java:204–231` — always rendered; module status only fills each tile's subtitle, it never hides the tile. The same destinations that More hides when the school switch is off (F2) stay visible and tappable on Home |
| F6 | Home cards (Today, Fees summary, Homework, Notices, Student Card) + "see all" links | **C/B** | Content is per-child server data (C); the navigation links themselves are unconditional (B) |
| F7 | Child switcher + children list | **C** | Shown only for a parent session with >1 child, listing only the session's own children (`MoreScreen:226`, `MainActivity.showChildSwitcher`). All family reads are scoped to the selected child; no other child's data and no staff item appears anywhere in the family build (source exclusion, §3/§5) |
| F8 | "Not set up yet" rows (Online Course, Live Classes, CBSE Exam, Hostel) | **C** | `MoreScreen.fillNotSetup` — non-clickable honest rows naming modules the school has not switched on; a deliberate owner-approved pattern (D-W2-1a), recorded here so the boundary is proven, not a permission control |
| F9 | Family deep screens (all pushed flows/activities) | **B** | No family screen re-checks a switch or session role on entry; the server data read is the only filter |

**Totals: 51 surface entries — A/A\* 25 · B 14 · C 5 · P 7.**
The two surfaces the owner named first are split: the Workspace
**bottom nav work slots are permission-driven** (A, W1) but its
centre Scan is not; the Workspace **More grid is permission-driven**
(A, with one B link, W23), while the Connect More grid is only
school-switch-driven for 7 of 18 tiles.

### 8.3 Concrete gap examples (fixture-proven unless marked)

1. **Zero-permission login (staff 115, "TEST Limited", empty map —
   fixture `w1b_cap-limited.json`).** Nav slots correctly vanish
   (bar = Home/Scan/More) and every A-class More section correctly
   disappears. But this login still sees and can open: the **Scan
   centre + QR screen** (W2), Home **Mark** and **QR** quick tiles
   (W3/W4), Home **Notice** tile (W6), Home Tools **Classes** and
   **Students** (W7/W8), More **Students** (W23), and all three
   **launcher shortcuts** (W12). Every one of those screens then
   fails at the server read — the textbook visible-but-error state
   the owner's rule bans. This is the worst case because it needs
   no special role: it is the default for *any* restricted custom
   role, which is precisely what the 234-permission model exists
   to serve.
2. **Teacher (staff 114, fixture `w1b_cap-teacher.json`, 22
   modules).** Fees are handled **correctly end-to-end**: no
   `fees_collection` module → no Fees nav slot, no More Money
   section, Home Fees row hidden. But the same map contains **no
   `qr_code_attendence` module at all** (it exists only in the
   Super Admin map) — yet the QR Scan centre and the Home QR tile
   are offered to this teacher exactly as to the super admin.
   Attendance *marking* visibility is correct (he holds
   `student_attendance`), which makes the QR gap a clean,
   isolated counterexample: the one attendance mechanism his role
   does not include is the one the app never gates.
3. **Accountant-type login (code-derived — no accountant fixture
   exists in the tree).** Nav preference gives Students+Fees, both
   permission-filtered (A). But an accountant with no
   `student_attendance` still gets the Home **Mark** tile, the
   **Classes** tools link, and the **Scan** centre (W2/W3/W7) —
   attendance doors his role does not include. Needs a live
   fixture to upgrade from code-derived to proven (§8.6).
4. **Parent login (Connect).** No staff item and no other family's
   child ever appears (F7 — this direction is clean). The role
   failure runs the other way: a parent and a student see the
   *same* app (F1/F4/F5), and school-off modules stay visible on
   Home (F5) even where More hides them (F2) — e.g. with the
   library switch off, the Library tile disappears from More but
   remains on Home, opening a screen that can only report its own
   empty state.

### 8.4 Fail-open and flash behaviour (both apps)

Even the A-class gates mostly **render first, hide after**: Home
builds its tiles in `onCreate` and hides Fees/Homework only when
the capabilities answer arrives (`loadNav`); if that answer errors,
`onError` does nothing and **nothing is hidden** (fail-open).
Family module gating is explicitly fail-open (`MoreScreen:130`).
Against the owner's wording — blocked features "must not appear at
all" — a blocked door that flashes on every cold start, and stays
permanently on any capabilities fetch failure, does not meet the
rule even where the eventual steady state is correct. The single
fail-closed precedent in the codebase is the family's Bank
Payments tile (F3).

### 8.5 Reverse direction — assigned but never offered

Permissions the server issues that no app surface ever consumes
(brief list, from the fixture maps): in the **Teacher** map —
`chat`, `online_admission`, `multi_class`, `zoom_live_classes`,
`gmeet_live_classes`, `online_course` (staff side),
`system_settings/language_switcher`; additionally in the **Super
Admin** map — `hostel`, `alumni`, `front_cms`, `system_settings`
(full), `student_cv`, `thermal_print`, `whatsapp_messaging`,
`google_authenticator`, `cbseexam`. Most are Wave-C or web-only
areas and their absence is a scope fact, not a visibility defect;
they are recorded so "assigned" and "offered" are never silently
treated as the same set. No case was found of a permission the app
*intends* to surface being unreachable — every A-class gate's
destination exists.

### 8.6 Pending proof (not invented in this lane)

- **Live staging re-probe with restricted logins** — create/refresh
  Accountant and Receptionist fixtures (none exist in the tree) and
  re-run the capabilities comparison per role; upgrade §8.3 item 3
  from code-derived to proven.
- **On-device visual proof (§6.4 device pass, already owed)** —
  sign in on a phone as the limited role and photograph Home / nav
  / More against §8.2; source audit proves what the code does, not
  what the shipped APK renders after the async hide.

### 8.7 Blocker B7 — Role-aware visibility (production blocker list, updated)

**B7 — Role-aware visibility.** Production must not ship with
blocked features visible to a login that does not hold them.
Confirmed items:

| Item | Gap | Fix shape |
|---|---|---|
| **B7-1** | Scan centre + `StaffQrActivity` ungated (W2) — offered to every staff login incl. zero-permission and no-`qr_code_attendence` roles (§8.3 #1, #2) | Gate the centre slot and the QR screen on the capabilities map (`qr_code_attendence/qr_code_attendance view`, or `student_attendance view` if QR is treated as an attendance mechanism — one rule, applied in nav, Home, and the screen itself) |
| **B7-2** | Home quick tiles Mark / QR / Notice and Tools links Classes / Students ungated (W3, W4, W6–W8); only Fees + Homework are hidden | Build Home's tiles/tools from the same caps answers as nav/More (hide in the same `loadNav` pass, for every tile, using the *same* keys as nav/More — resolving the W9 key mismatch) |
| **B7-3** | More People → Students link unconditional (W23) | Gate on `student_information/student view`, exactly as the nav STUDENTS slot already does |
| **B7-4** | Launcher shortcuts + `open` extras land on QR/Fees/Attendance with no caps check (W12) | Check caps in the landing path (fall back to Home when not allowed); note static shortcuts themselves cannot be per-user — the landing check is the only available control |
| **B7-5** | Deep screens have no entry gate (W25): any B-class door or leftover path delivers a blocked login into the screen | Add a per-screen entry check in `DeskActivity` (screen → required `can()` declared by each activity; on failure, close with an honest message) so menu-hiding is not the only UI control |
| **B7-6** | Fail-open + render-then-hide on the A-class gates (§8.4) | Render gated surfaces only after the caps answer (skeleton meanwhile), and fail **closed** for permission surfaces, following the family's own Bank Payments precedent (F3) |
| **B7-7** | Family Home bento tiles never hide (F5) and Online Exams tile ungated (F4), contradicting the More grid's own switch gates (F2) | Apply `applyModuleVisibility` to Home tiles as well; gate Online Exams under the `examinations` switch (Live Classes stays always-visible per the owner's standing requirement) |

**Blocker list as updated by this section:** B1 (debug signing) ·
B4 (token leakage to arbitrary hosts) · B2 (plaintext at rest) · B3
(embedded vendor Auth-Key) · silent-save failure (§2) · B6 — Print
design parity (§7) · **B7 — Role-aware visibility (B7-1…B7-7, this
section)**. The verdict of §6 (READY-WITH-FIXES) is unchanged; B7
joins the fix-before-production list.
