# IQRS v2 apps — operator runbook

Apps: **IQRS Family** (`pk.edu.iqrs.family`) and **IQRS Admin**
(`pk.edu.iqrs.admin`) for IQRA REHMANIA TUL ATFAL HIGH SCHOOL
(iqrs.edu.pk, Smart School 7.2). Current builds: Family v2.2 (code 12),
Admin v2.3.1 (code 15). Source tree: `~/workspace/iqrs-app-v2/`.

## 1. Building the apps

Gradle-free pipeline, scripted end-to-end in `~/workspace/iqrs-app-v2/build.sh`
(toolchain under `~/workspace/android-tools/`: JDK + SDK build-tools 34.0.0):

```
cd ~/workspace/iqrs-app-v2
./build.sh family    # or: admin | both
```

Per variant the script: reads `config/<variant>.properties` → generates the
manifest from `src/AndroidManifest.xml.tpl` (single shared source tree;
Admin adds the CAMERA permission and staff activities, Family excludes the
staff/sync/QR sources, Admin links the vendored ZXing jar) → `aapt2 compile`
+ `link` (minSdk 26, targetSdk 34) → `javac` (Java 17) → `d8` → `zipalign` →
`apksigner` with the tree's debug keystore `iqrs-debug.keystore`
(alias `androiddebugkey`).

**Versioning rules**

- Version numbers live ONLY in `config/family.properties` /
  `config/admin.properties` (`versionCode`, `versionName`, `apkName`).
  Bump all three together; `versionCode` must always increase.
- History: Family 2.2 = code 12 (next would be 2.2.1 = 13);
  Admin 2.2 = 12, hotfix 2.2.1 = 13, 2.3 = 14, 2.3.1 = 15 (next: 2.3.2 = 16).

**Gates — run all three before any APK is delivered**

```
tools/run_tests.sh                                  # JVM fixture tests (90)
tools/banned_strings.sh                             # language-lockdown lint
tools/metadata_check.sh <apk> <package> <versionName>
```

**Delivery:** finished APKs + a `BUILD-REPORT-*.md` go to
`~/workspace/your_files/iqrs-app/` (mirrored in this goal's files folder).
Never overwrite a delivered APK; a fix ships as a new versioned file.

## 2. Server side — the staff API extension

Three Muse-built, additive PHP controllers (vendor files are never edited).
Local home: `~/workspace/iqrs-api/staff-ext/` (`Staffauth.php`,
`Staffapi.php`, `Staffsync.php`, deploy notes, and the SQL for the two
extension-owned tables `api_staff_sessions` and `api_sync_log`).
Vendor source copies for reference: `~/workspace/iqrs-api/production/` and
`~/workspace/iqrs-api/staging/`.

| | Staging | Production |
|---|---|---|
| Site root | `/home/u238632175/domains/iqrs.edu.pk/public_html/staging` | `/home/u238632175/domains/iqrs.edu.pk/public_html` |
| Controllers | `…/staging/api/application/controllers/` | `…/api/application/controllers/` |
| Database | `u238632175_test123` | `u238632175_KliTy` |
| Base URL | `https://staging.iqrs.edu.pk/api/` | `https://iqrs.edu.pk/api/` |

**Swap procedure (staging first, always):**

1. Back up the live file in the same folder with a dated suffix —
   the backup actually created for the M3 swap is
   `Staffapi.php.bak-2026-11-07-m3` (present in both trees).
2. Upload the replacement; guard on the old file's byte size before
   overwriting.
3. Smoke-test with curl (production sits behind Cloudflare bot checks —
   use curl, not a browser or urllib): no-token call must return
   `401 {"status":401,...}` (a 500 means a PHP parse problem → roll back);
   staging additionally logs in with the disposable test staff
   (id 113) and exercises each endpoint. Production smoke stays read-only
   / no-token unless a rollout explicitly says otherwise.
4. Only after staging passes, repeat on production.

**Rollback:** restore the `.bak-*` file over the controller. The extension
is additive and its tables are its own, so rollback never touches vendor
behaviour. (There is no `php` binary in the Muse VM — the staging smoke
test is the parse check.)

Auth contract: login `POST /api/staffauth/login` `{email, password}`;
authenticated calls send headers `Client-Service: smartschool`,
`Auth-Key: schoolAdmin@`, `User-ID: <staff_id>`, `Authorization: <token>`.
Staff sign in with their **email**; the login record's id field is
`record.staff_id` (this exact field name caused the v2.2 logout bug —
the app must read `staff_id`, not `id`).

## 3. Verified ground truths

- **Attendance types** (`attendence_type`, verified from the school's own
  table): 1 Present · 2 Late With Excuse · 3 Late · 4 Absent · 5 Holiday ·
  6 Half Day · 7 Approved Leave · 8 Medical Leave · 9 Official Activity ·
  10 Unexcused Absence. The app marks Present/Absent/Late = ids **1/4/3**
  (`AttendanceTypes.SEGMENT_IDS = {1, 4, 3}`, pinned by a JVM test).
  Do not assume vendor seed order — id 2 is *not* Absent.
- **default_login fix (production, 2026-11-07):** the vendor fees endpoint
  silently 500s for any student whose `student_session` row (current
  session id 21) lacks `default_login = 1`. Fix applied:
  `UPDATE student_session SET default_login=1 WHERE session_id=21 AND
  default_login=0` (1,680 rows). Backup table
  **`backup_ss_default_login_20261107`** holds exactly the affected rows;
  rollback = set `default_login=0` again for the ids in that table.
  New-session rollover will need the same check for the new session's rows.
- **Fees discount fact:** discounts for all students were recorded at
  collection time as discount entries inside the payment record's
  `amount_detail`. A discount is **not** a part-payment: displays must show
  Paid / Discount / Balance as three separate figures (the apps do; the
  web view `views/student/studentShow.php` was patched display-only to
  derive status from money actually paid — backups
  `studentShow.php.bak-2026-11-07-display` in BOTH the staging and
  production trees; totals and stored data were not changed).
- **Staging base_url fix:** `staging/application/config/config.php` had
  `base_url = https://iqrs.edu.pk/` (bounced staging visitors to
  production); corrected to `https://staging.iqrs.edu.pk/`, backup
  `config.php.bak-2026-11-06-baseurl` alongside it.
- **Known gap:** production has **no subject groups configured**
  (subject-group tables empty), so the app's homework subject picker shows
  its honest empty state until the school configures subject groups in the
  web admin panel. Not an app bug.
- Offline writes (Admin): every saved write carries one `client_txn_id`,
  minted once and reused on every retry; the server deduplicates on it
  (`api_sync_log`) and answers `duplicate:true`. Never re-mint an id for a
  retry — that is what prevents double fee collections.

## 4. Production signing (do only when Assad confirms device tests)

Current builds are signed with the shared debug keystore — fine for
testing, not for distribution.

1. On the build machine, generate ONE release keystore, e.g.
   `keytool -genkeypair -keystore iqrs-release.keystore -alias iqrs-release
   -keyalg RSA -keysize 2048 -validity 10000`.
2. **Assad sets the keystore password himself and keeps custody of it**
   (his own password manager). The password is never typed into chat,
   never stored in this workspace or in memory files. Losing it means the
   apps can never be updated under the same identity.
3. Keep the keystore file itself backed up with Assad's own records; the
   build tree keeps only the debug keystore.
4. Rebuild both apps (`./build.sh both` with the signing step pointed at
   the release keystore instead of `iqrs-debug.keystore`), re-run all
   three gates, and verify with
   `apksigner verify --print-certs <apk>` that the certificate is the
   release one.
5. **Uninstall first:** a release-signed build will NOT install over the
   debug-signed builds (different signer). Every test device must
   uninstall the old Family/Admin apps before installing the release
   builds; on-device app data (session, cache, any waiting writes) is
   removed by the uninstall, so make sure no Admin device has unsent
   "Waiting to send" items at switch-over time.
6. Deliver as new versioned APKs (Family v2.2.1 / code 13 and Admin
   v2.3.2 / code 16, or the then-current next versions) with a build
   report noting the signer change.

## 5. Release checklist

- [ ] Code/manifest changes reviewed; version triple bumped in
      `config/<variant>.properties`
- [ ] `tools/run_tests.sh` — all tests pass
- [ ] `tools/banned_strings.sh` — PASSED
- [ ] `tools/metadata_check.sh` — PASSED for the new APK
- [ ] Any server file change: staging-first swap with dated `.bak-*`
      backup, curl smoke passed, then production
- [ ] APK + `BUILD-REPORT-*.md` (with size + SHA-256) in
      `~/workspace/your_files/iqrs-app/`
- [ ] Device confirmation on Assad's phone before the build is called done
