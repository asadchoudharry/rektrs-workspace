# BUILD REPORT — Wave 2D production-pointing apps (Connect v2.14-prod / Workspace v2.18-prod)

Built 2026-11-08 (PKT) from the final Wave 2 tree `~/workspace/iqrs-app-v2/`
(the v2.13/v2.17 sources — the checker-passed final state,
CHECKER-REPORT-wave2-fix2.md). These builds follow the 2D API rollout:
production (iqrs.edu.pk) now runs the same extension masters as staging
(Staffapi 570,998 B / Staffsync 151,515 B / Familydocs 30,067 B), so the
apps' API target flips from staging to production. **Nothing else changes.**

| Artefact | versionCode | versionName | Size | sha256 |
|---|---|---|---|---|
| IQRS-Connect-App-v2.14-prod.apk | 25 | 2.14 | 1,643,376 B | `fd5cbb710380d9ef2b9510e5057132add62943f4f0178b0119518f9d44667c09` |
| IQRS-Workspace-App-v2.18-prod.apk | 31 | 2.18 | 1,729,392 B | `0939d25ad5ea16218cc4357c6fdfbb993c7c596ab8e14d2c65aa8f98e676074b` |

Signer (both, and identical to every prior build): SHA-256
`f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e`
(apksigner --print-certs, verified on the shipped files).

## 1. The complete change set — 3 files, target flip only

The tree's established mechanism was used; no code was forked.

1. `src/pk/edu/iqrs/app/api/ApiConfig.java` — the single flip point:
   `baseUrl()` now returns `BASE_URL` (`https://iqrs.edu.pk/api/`)
   instead of `STAGING_BASE_URL`. The method's comment was updated to
   name these builds and record why (2D landed; production runs the
   same extension masters as staging). Both URL constants remain
   declared, as before.
2. `config/family.properties` — versionCode 24 → **25**,
   versionName 2.13 → **2.14**, apkName → `IQRS-Connect-App-v2.14-prod.apk`.
3. `config/admin.properties` — versionCode 30 → **31**,
   versionName 2.17 → **2.18**, apkName → `IQRS-Workspace-App-v2.18-prod.apk`.

The `-prod` suffix is deliberate: these artefacts can never be confused
with the staging-pointing v2.13/v2.17 builds. The tree is left in this
production configuration, matching the shipped artefacts (the checker
harness derives its expectations from these same properties files).

## 2. Gates

| Gate | Result |
|---|---|
| JVM suite (`tools/run_tests.sh`) | **OK (352 tests)** — same count as v2.13/v2.17 |
| Checker harness on tree + both APKs (`run_checker.sh --apk-connect … --apk-workspace …`) | **0 failed check groups** — metadata gate PASSED per APK (package, versionCode/Name, SDK levels, exact permission sets: Connect {INTERNET, POST_NOTIFICATIONS, USE_BIOMETRIC}, Workspace {INTERNET, CAMERA, POST_NOTIFICATIONS, USE_BIOMETRIC}, signature verifies), mechanism classes in both dexes, REG-DIALOG-TEXT in shipped resources, banned-strings clean, SRC-NOSPACER-IN-ROW clean |
| SRC-ROUTE-LIVE (harness step 5b, offline form) | **PASS** — all 210 source route strings exist in the manifest |
| Dex proof of target (dexdump, both shipped APKs) | `ApiConfig.baseUrl()` body is `const-string v0, "https://iqrs.edu.pk/api/"` + `return-object` — the production constant, in both |
| Prior artefacts | every pre-existing APK in `~/workspace/your_files/iqrs-app/` re-hashed after the build: **byte-identical** (incl. Connect v2.13 `5d091c8e…`, Workspace v2.17 `63928534…`) |

## 3. Production route proof (guard level)

The SRC-ROUTE-LIVE **manifest was NOT rewritten**: it stays the
staging-probed manifest (`tools/checker/route_manifest.json`, base
`https://staging.iqrs.edu.pk/api/`, probed 2026-11-07T19:26:18Z), exactly
as the harness design intends.

As the production counterpart, the same 210 route strings were probed
against `https://iqrs.edu.pk/api/` with the contract gate's own probe
shape — unauthenticated POST, vendor Client-Service/Auth-Key headers,
empty JSON body (curl, per the standing Cloudflare note). No logins, no
credentials, no production accounts exist or were created, and an
empty-body POST refused at the guard writes nothing.

**Result: 210/210 routes answer; 0 × 404; 0 × 5xx; 0 transport failures.
Every route's HTTP code is identical to its code in the staging manifest
(210/210 exact-code parity).** Distribution:

- **200 × HTTP 401** — the extension + session guards' refusal
  (`{"status":0,"message":"Unauthorized."}` shape), as recorded for
  production since the 1C rollout.
- **8 × HTTP 200, all refusal bodies**: `auth/login` and
  `staffauth/login` → `{"status":0,"message":"Invalid Username or Password"}`
  (empty-body login attempt refused; nothing authenticated); six vendor
  webservice routes (`addTask`, `updatetask`, `deletetask`,
  `deletedailyassignment`, `deletetimeline`, `deleteforummessage`) →
  field-validation errors (`status:"0"` + the missing-field list) — the
  vendor's own input guards answering before any write is possible.
- **2 × HTTP 400**: `webservice/forgot_password` (field validation) and
  `webservice/getLibraryBooks` (`{"status":400,"message":"Bad request."}`).

In particular the extension surfaces the Wave 2 apps depend on —
`staffapi/*`, `staffsync/*`, `staffauth/*`, `familydocs/fileOpen`,
`familydocs/appVersion` — all refuse unauthenticated callers with 401
on production, none 404, none 500: the routes exist and their guards
are up, matching staging exactly.

## 4. Limits honoured

- No production account was created, and no real user's credentials
  were used anywhere. The only production contact was the
  unauthenticated guard probes above.
- No production data was written (every probe carried an empty body
  and was refused at a guard or by input validation).
- The authenticated end-to-end proof on production remains the owner's
  own first sign-in on his phone with these builds — by design, since
  no production test accounts exist.
