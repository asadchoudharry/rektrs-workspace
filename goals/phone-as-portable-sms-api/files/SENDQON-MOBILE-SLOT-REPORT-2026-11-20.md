# Sendqon — Mobile App Panel Slot Report — 2026-11-20

**Task:** make the signed Flutter tenant app (Sendqon Mobile v1.0.0) downloadable from the panel for tenants.
**Outcome: COMPLETE — and the registration itself needed no new write from this lane.** A previous lane on this exact task had ended silently (no report, no pushes) after several SSH sessions. This lane's first job was ground truth; the registration turned out to be already done, correctly, by that lane. This lane verified it end-to-end and produced the missing record. **Production writes by this lane: zero.**

---

## 1. Step 0 — ground truth: what the silent lane did and did not do

All probes read-only, run 2026-11-20 ~19:00–19:05 UTC on offbox-1 (production, as www-data unless noted). Reference point: gateway v5.4.1 slot registration at 16:56:27 UTC; owner approval "Teeno bana do" at 18:56 UTC (23:56 PKT).

### The silent lane DID (evidence-backed)

1. **Ran the pre-write backup.** `/var/backups/sendqon/backup.log` line: `2026-11-20T18:59:42+00:00 status=OK db=9009081 config=29993439 storage=50307866 push=OK` — artifacts `sendqon-{db,config,storage}-2026-11-20.*` written 18:59:35 UTC. This is newer than the sim_fleet lane's 16:35:41 UTC backup and is the only backup after it.
2. **Registered the mobile APK through core's own MobileApk mechanism at 18:59:50 UTC** (8 seconds after the backup completed):
   - `system_settings` key `mobile_android_apk` (group `mobile_app`), `updated_at = 2026-11-20 18:59:50`, value: path `apps/mobile_android/82b7c702-e85e-43fc-be67-a1e68ceeec7a.apk`, name `sendqon-mobile-v1.0.0.apk`, size 23092503, sha256 `c57732fd8dadb1089e067a07eedd1f60c0a6851ce2191118ee531de7342a9d4c`, version `1.0.0`, uploaded_at `2026-11-20T18:59:50+00:00`. The meta shape matches `MobileApk::store()` output exactly (no package/signer keys — that class does not store them).
   - File on disk: `storage/app/private/apps/mobile_android/82b7c702-e85e-43fc-be67-a1e68ceeec7a.apk`, 23,092,503 bytes, written 18:59 UTC, sha256 verified on disk = `c57732fd…` (byte-identical to the custody APK in `files/android-app/`).

### The silent lane did NOT (evidence-backed)

- **Gateway slot untouched:** `app_file_android_gateway` still holds our gateway v5.4.1 (name `sendqon-gateway-own-v5.4.1.apk`, sha256 `8ab5b9d1…`, uploaded 2026-11-20T16:56:27Z) — unchanged. It is the **only** `app_file_%` row; no new or duplicate slot rows exist.
- **Devices untouched:** device 2 still `app_version 5.4.1`, last_seen 2026-11-20 19:00:49 UTC (live).
- **No other setting touched:** `mobile_android_apk` is the only `system_settings` row with `updated_at` after 18:30 UTC. All other `mobile_*` keys (`mobile_enabled=1`, `mobile_min_android=null`, `mobile_min_ios=null`, `mobile_store_android=''`, `mobile_store_ios=''`) date from 2026-11-17.
- **No plugin touched:** 0 rows in `plugins` updated after 18:30 UTC. **No `stored_files` rows** created in the window. **No partial or duplicate registration** — nothing required cleanup.
- **No report and no pushes** — the only missing pieces; completed by this lane (§5).

**Verdict:** production was NOT "exactly as of 18:56 UTC" — it carries one complete, correct mobile registration from 18:59:50 UTC plus its pre-write backup. The silent lane finished the write and died before the record.

---

## 2. Mechanism (discovered from live source — a dedicated core mechanism exists)

Core ships a site-owner mobile-app distribution mechanism, independent of the plugin app-slot system (`AppFiles`/`AppSlots`, which serves the gateway and companions — a different app, never touched here):

- **Service:** `App\Services\Mobile\MobileApk` — setting key `mobile_android_apk`, folder `apps/mobile_android/` on the private `local` disk, chunked-upload staging at `apps/.chunks/mobile_android`. `store()` validates the APK signature + reads the version from the package, stores one current file, deletes the replaced file.
- **Admin surface:** `Admin\MobileApkController` — routes `POST /settings/mobile-app/apk/upload/{chunk,complete}`, `GET …/status`, `DELETE /settings/mobile-app/apk` (admin settings permissions).
- **Tenant/public download:** `GET /mobile-app/android/download` (`MobileApkDownloadController`, route name `mobile-app.android.download`, throttle 30/min, public). It 404s unless the mobile app is enabled and a file is present; otherwise it streams the stored APK as `application/vnd.android.package-archive`.
- **Panel surfacing:** `MobileSettings::downloads()` returns `{apk: {url, version, size}}` (store links null — none configured) and `HandleInertiaRequests` shares it into panel pages as the **`mobileAppDownloads`** Inertia prop; `MemberInviteMail` also carries the downloads payload. Enablement: `mobile_enabled = 1` (set 2026-11-17).
- A `MobileInstallApkCommand` console command also exists for CLI installs of the same slot.

Because the mechanism is core's own and the registration was already in place, **no plugin was built and no DEV detour was needed** — building a parallel surface would have duplicated a native one.

---

## 3. Registration state (as verified)

| Field | Value |
|---|---|
| Setting | `mobile_android_apk` (group `mobile_app`) |
| File | `apps/mobile_android/82b7c702-e85e-43fc-be67-a1e68ceeec7a.apk` (private disk) |
| Name | `sendqon-mobile-v1.0.0.apk` |
| Size | 23,092,503 bytes |
| SHA-256 | `c57732fd8dadb1089e067a07eedd1f60c0a6851ce2191118ee531de7342a9d4c` |
| Package | `com.rektrs.sendqon.mobile` (read from the stored file) |
| Version | 1.0.0 / code 1 (read from the stored file) |
| Signer (SHA-256) | `ea42872792ad83a3007f8f42bd849de3786d0884a408da157ba442690756a48b` — the custody `sendqon-mobile` signer |
| Registered | 2026-11-20T18:59:50Z (23:59:50 PKT), after backup 18:59:42Z status=OK |
| Pre-write backup | 2026-11-20 18:59:35–42 UTC set (`db 9009081 / config 29993439 / storage 50307866`, push=OK) |

---

## 4. Verification battery (this lane, all as www-data unless noted)

1. **Stored meta + file:** setting value matches §3; on-disk sha256 recomputed = `c57732fd…` — identical to the custody APK and to the local `files/android-app/sendqon-mobile-v1.0.0.apk`. ✅
2. **Admin payload:** `MobileApk::adminPayload()` → file present, **`missing: false`**, name/version/size correct. ✅
3. **Identity from the file itself:** `ApkVersionReader` → package `com.rektrs.sendqon.mobile`, versionName `1.0.0`, versionCode `1`; `ApkCertificateReader` → signer `ea428727…` = custody mobile signer (not the gateway signer, not debug). ✅
4. **Downloads payload:** `MobileSettings::downloads()` → `apk: {url: https://sendqon.rektrs.com/mobile-app/android/download, version: 1.0.0, size: 23092503}`. ✅
5. **Signed download over public HTTPS:** `curl https://sendqon.rektrs.com/mobile-app/android/download` → **HTTP 200, 23,092,503 bytes, sha256 of the downloaded bytes = `c57732fd…`** — hash-identical end to end. ✅
6. **Tenant reachability (UI surface):** the download is surfaced to the panel as the shared `mobileAppDownloads` Inertia prop on panel pages (and in member-invite mail). A signed-in tenant browser click-through was not performed — no tenant sign-in was used by this lane; the prop + public route + payload are the surface evidence. ✅ (with the stated limit)
7. **No collateral change:** gateway slot still v5.4.1 (§1), device 2 live on 5.4.1, 0 plugins touched, site homepage **HTTP 200**. ✅
8. **Logs clean:** `laravel-2026-11-20.log` has had no writes at all after 06:11 UTC — nothing logged during or after the 18:59 registration; the day's 5 ERROR lines all predate the evening lanes. ✅

---

## 5. Records / pushes

- This report: `files/SENDQON-MOBILE-SLOT-REPORT-2026-11-20.md`, pushed to Sendqon `rebuild-tree` (`planning/`) and rektrs-workspace `main` (`goals/phone-as-portable-sms-api/files/`), both ls-remote verified (hashes in the lane summary).
- No plugin source (nothing built). App source unchanged (branch `app-mobile-flutter`).

## 6. Honest limits

- **Scope is download distribution only.** The owner's phone-side proofs for the mobile app (install + sign-in with his Sendqon account) remain open items tracked elsewhere; nothing in this lane proves in-app behaviour.
- **No minimum-build gate is set** (`mobile_min_android` is null) and **no store links** are configured — the direct APK is currently the only mobile download channel, which matches the owner's distribution model today.
- The tenant surface was verified at the shared-props + route + payload level (§4.6), not by a signed-in tenant browser session.
- Rollback, if ever wanted, is one admin action (`DELETE /settings/mobile-app/apk` / `MobileApk::remove()`) or restoring the 18:59 UTC backup set; the gateway slot is a separate mechanism and is unaffected either way.
