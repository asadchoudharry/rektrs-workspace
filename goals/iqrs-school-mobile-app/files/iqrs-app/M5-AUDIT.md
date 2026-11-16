# M5 hardening audit — IQRS v2 apps (2026-11-07)

Scope: Family `pk.edu.iqrs.family` v2.2 (code 12) and Admin `pk.edu.iqrs.admin`
v2.3.1 (code 15), tree `~/workspace/iqrs-app-v2/`. Method: source greps +
direct inspection, plus `aapt2 dump xmltree` on the shipped APKs themselves.

| # | Item | Status | Evidence |
|---|------|--------|----------|
| 1 | Network security | **OK** | Manifest template sets `android:usesCleartextTraffic="false"`; confirmed `=false` inside both shipped APKs. Base URL is HTTPS-only (`ApiConfig.BASE_URL = https://iqrs.edu.pk/api/`; the staging constant in the same file is never selected by `baseUrl()`). No network-security-config file exists (none needed). Grep for `TrustManager`, `HostnameVerifier`, `X509Certificate`, `SSLSocketFactory`, trust-all patterns across `src/`: **zero hits** — the client is a plain `HttpURLConnection` with platform TLS defaults. |
| 2 | Session & token storage | **OK** | Tokens persist only in `SessionStore` → `SharedPreferences` file `iqrs_session`, `MODE_PRIVATE`. Passwords are **never** persisted (used only in the login request body). Cached payloads live in app-private SQLite (`iqrs_cache.db`, `iqrs_admin.db`). `android:allowBackup="false"` in the template and confirmed `=false` in both shipped APKs, so Android cloud backup cannot carry session material. |
| 3 | Logging | **OK** | Grep for `Log.`, `System.out`, `System.err`, `printStackTrace` across all of `src/`: **zero hits**. Nothing can log passwords, tokens, auth headers, or fee amounts. |
| 4 | Manifests / exported components / permissions | **OK** | Template + shipped APKs agree: only `SplashActivity` (launcher) is `exported=true`; every other activity and the Admin `RetryReceiver` are `exported=false`. Permissions exactly: Family = INTERNET; Admin = INTERNET + CAMERA. No `android:debuggable` (defaults false). |
| 5 | WebView | **OK** | Grep for `WebView` / `loadUrl` in sources and resources: **zero hits**. Neither app contains a WebView; the hard rule holds. |
| 6 | Outbox at rest (Admin) | **OK** | `AdminDb.pending_writes` stores `client_txn_id` (UNIQUE), `kind`, `payload_json`, `summary`, `state`, attempts/error bookkeeping. Fee payloads (see `SyncPayloads.feeCollect`) contain only business fields: fee master ids, amount/discount/fine, a `payment_mode` label, date, description — no card data exists anywhere in the codebase, and no credentials: auth headers are attached at send time from `SessionStore` (`WaitingSender`), never written into stored payloads. Txn-id discipline untouched (minted once, UNIQUE constraint, reused on retry). |
| 7 | QR / manual code input | **OK** | Scanned and typed codes are `trim()`ed, checked non-empty, and used only as the `code` string in the `staffsync/qrAttendance` JSON plus a local same-day dedupe key (`qr_marks`). No path treats scan content as a URL, intent, or command; resolving `IQRS-<id>` / numeric id / admission number happens server-side. |
| 8 | Obfuscation | **ACCEPTED LIMITATION** | The Gradle-free pipeline (`aapt2 → javac → d8 → zipalign → apksigner`) runs d8 with no shrinking/obfuscation and ships no R8 config. Accepted for sideloaded school builds per the M5 brief; no shrinker attempted. |

## Fixes applied

**None.** Every audited item was already in the required state, so Part B
shipped **no new builds**. Current deliverables remain Family v2.2 (code 12)
and Admin v2.3.1 (code 15).

## Gates run on the unmodified tree / shipped APKs (2026-11-07)

- JVM fixture tests (`tools/run_tests.sh`): **OK (90 tests)**
- Banned-strings lint (`tools/banned_strings.sh`): **PASSED**
- Metadata (`tools/metadata_check.sh`): **PASSED** for both shipped APKs
  (Admin: package `pk.edu.iqrs.admin`, code 15, name 2.3.1, minSdk 26,
  targetSdk 34, permissions CAMERA + INTERNET, signature verifies;
  Family: package `pk.edu.iqrs.family`, code 12, name 2.2, INTERNET,
  signature verifies)
