# Sendqon Gateway App v5.2.2 — Report (2026-11-20)

Owner-reported defects from his own phone (v5.2.1, Redmi/HyperOS, screenshots 2026-11-20 11:52 PKT: *"Setting allow Ker Di hy phir bhi same issue dikha Raha hy"*), plus Workstream 3 — vendor-app parity items the owner asked to fold in from his walkthrough of the vendor gateway app v5.0.4.

- **APK:** `files/android-app/sendqon-gateway-own-v5.2.2.apk` — 4,510,794 bytes, SHA-256 `d1b491624b5fb5075f0f7af87ce63ae9517fb22f7143edc904d0d5217537d7ba`
- **Version:** 5.2.2 / versionCode 50202 (in-place update over v5.2.1)
- **Signer:** custody keystore, cert SHA-256 `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` — byte-identical to v5.2.0/v5.2.1 (apksigner-verified on the shipped APK)
- **Source:** branch `app-own-android`, commit `18fc6e8` (base `74eaa3a` = v5.2.1), ls-remote verified. 5 files changed, +463/−74: `Health.kt`, `MainActivity.kt`, `Store.kt`, `Strings.kt`, `build.gradle.kts`.

---

## Defect A — "Keep the app active" row showed Missing with autostart ON

### Root cause (from the code)
The checklist/Settings row is built in `MainActivity.keepOnlineCard()`. In v5.2.1 its state was:

```kotlin
ok = health.standbyBucket == "active" || health.standbyBucket == "working_set"
```

where `Health.standbyBucket` reads `UsageStatsManager.getAppStandbyBucket()` — the **AOSP usage-frequency bucket**. The row's own Fix button, however, opens the **MIUI/HyperOS Background autostart manager** (`com.miui.securitycenter` AutoStartManagementActivity). The autostart toggle and the standby bucket are different systems: turning autostart ON never moves the bucket, so on the owner's phone (app not opened frequently enough to sit in `active`/`working_set`) the row kept rendering **Missing** next to the label suffix "(restricted)" even with autostart screenshot-proven ON. Detection and remedy disagreed — the row was lying.

### What signal genuinely exists for MIUI autostart?
MIUI exposes **no public API** for the autostart state. The strongest readable signal found (web evidence, not guesses): MIUI's vendor AppOps operation **10008 (`OP_AUTO_START`)**, readable through the public (deprecated) `AppOpsManager.checkOpNoThrow(int, int, String)` — documented by community sources: the tutorialpedia MIUI-autostart walkthrough; getActivity/XXPermissions issue #300 confirming the reflective `checkOpNoThrow` call for MIUI special permissions; the XiaomiUtilities gist (`OP_AUTO_START = 10008`); the judemanutd/AutoStarter and XomaDev/MIUI-Autostart libraries. All sources caveat that the op is **not guaranteed across all MIUI/HyperOS versions**.

### The fix — detection and remedy now measure the same system
New `Health.autostartState()` returns `ALLOWED / NOT_ALLOWED / UNKNOWN / NOT_APPLICABLE`:

- **Applicability:** the device is treated as Xiaomi-family when the MIUI autostart activity resolves (`resolveActivity`/`queryIntentActivities` on the AutoStartManagementActivity intent) **or** the manufacturer/brand is xiaomi/redmi/poco. Otherwise `NOT_APPLICABLE`.
- **Probe:** reflective `checkOpNoThrow(10008, myUid, packageName)`; `MODE_ALLOWED` → `ALLOWED`, any other mode → `NOT_ALLOWED`, any exception → `UNKNOWN`.

Row presentation on Xiaomi-family devices:

- `ALLOWED` → **Granted**.
- `NOT_ALLOWED` or `UNKNOWN` → a **neutral** state (new `CheckItem.neutral`): grey pill "Check", muted "–" glyph, plus the hint *"Xiaomi does not let apps read this switch, so its state cannot be shown — tap to open the guide and check the autostart list; keep Sendqon switched on."* — **never Missing**.

Off Xiaomi nothing changes: there is no autostart manager, and the row keeps the original standby-bucket reading.

**Acceptance bar — met by construction:** on a HyperOS device with autostart ON, the row can no longer show Missing after returning from the Fix screen: a positively-read ON shows Granted, and every other reading shows the neutral Check state. **Honest trade-off, stated plainly:** on Xiaomi the row also no longer *warns* when autostart is genuinely off unless the unofficial op positively distinguishes the states — negative/unreadable results are not trusted as proof of restriction, because crying Missing falsely (the owner's exact complaint) is the worse failure. The row's Fix on Xiaomi now opens the new Keep Phone Online guide (below), whose autostart step carries the button into the manager itself.

## Defect B — Companions section showed "Download & install vnull" → "Failed: no protocol: null"

### App-side root cause
The Settings page read `receiver_version` / `receiver_app_url` / `ussd_*` / `rcs_*` from the device settings payload (`POST /auth/pair` + `GET /device`, built server-side by `DeviceSettingsPayload`). The app read them with `JSONObject.optString()`, which converts a JSON **null** into the literal string `"null"` — so `url.isNotEmpty()` was true, the row rendered **"Download & install vnull"**, and the button called the download path with `"null"`, where `java.net.URL("null")` throws `MalformedURLException: no protocol: null` — the owner's toast, verbatim.

### Server-side findings (read-only www-data probes on production, 2026-11-20; nothing changed)
- App slots: `android_gateway` POPULATED (vendor gateway.apk v5.0.4, package `com.rektrs.sendqon`, **vendor signer**); `android_receiver` POPULATED (v5.0.4, `com.rektrs.sendqon.receiver`, vendor signer); `android_ussd` POPULATED (v5.0.4, `com.rektrs.sendqon.ussd`, vendor signer); `android_rcs` **EMPTY** (no file — no RCS package exists anywhere, as established in setup).
- The payload gates each companion on `AppFiles::mayDownload` (**true** for the owner — not the blocker) **and** `GatewayAppVersions::matches(...)` ("belongs"): package + suffix match (`com.rektrs.sendqon` + `.receiver` = the slot package), but the **signer differs** — the slot APKs are signed by the vendor build's key, our app by the Rektrs custody key (`eba2c40d…`). Core only ever serves a companion download to a device whose app shares the upload's signer, so for our app `belongs()` is false and the payload emits all six companion keys as **null** — verified live against production device id 2 (our app, v5.2.1): `receiver_version/receiver_app_url/ussd_version/ussd_app_url/rcs_version/rcs_app_url` all null.
- **Conclusion:** the nulls are core's signer-gate working as designed, not malformed slot data. The vendor-signed slot files can never legitimately be served to our custody-signed app. Production slot data was deliberately **not** changed in this lane.

### The fix — the section now states the built-in truth
Per the settled v5.2.1 design (receiving is built into this app via `CompanionReports`; USSD runs built-in via the official `TelephonyManager` API; no RCS companion package exists), the Companions section is rewritten with built-in state rows and **no download buttons at all**:

| Row | Now shows | Pill |
|---|---|---|
| Receiver Companion | "Built into this app — the gateway itself receives incoming SMS." | **Built in** (green) |
| USSD Companion | "Built into this app — USSD runs through the phone's own telephony." | **Built in** (green) |
| RCS Companion | "Not available — no RCS companion package exists for this app." | **Not available** (grey) |

Section note: *"Receiving and USSD are built into this app — there is nothing extra to install."* The old `companionRow()` and the now-dead `installApk()` are deleted; the dex of the shipped APK contains **zero** references to `receiver_app_url`. "vnull" and "no protocol: null" are unreachable.

## Workstream 3 — vendor parity (owner's vendor-app walkthrough, 2026-11-20)

### 1. Keep Phone Online guide page — DONE in 5.2.2
A dedicated page (new `Screen.GUIDE`), reachable from the "Open the guide" button in the Keep-phone-online card (checklist + Settings) and from the Defect A row's Fix on Xiaomi. Contents:

- **Summary banner:** "✓ Looks good" only when every readable step is On **and** every manual To-Do is confirmed; otherwise "⚠ N items need attention".
- **Per-brand steps** ("Steps for Xiaomi, Redmi and POCO" on Xiaomi-family devices; generic title elsewhere), each with an honest state — On (green) / Needs Action (amber) / Check (grey, unreadable) — and its own settings button where one exists: Turn off battery optimization (exemption state), Allow background activity (restriction state), Keep the app active (standby bucket), Allow notifications, and — Xiaomi only — **Turn on Autostart** on the Defect A model (positive read = On; anything else = neutral Check, never Needs Action).
- **Manual To-Dos with user-confirmed Done checkboxes** (persisted in `Store`; never fake-detected): Remove battery restrictions (Battery saver → No restrictions, with an Open Settings button to App info), Turn off MIUI optimization (Developer options path text + button; Xiaomi only), Lock the app in Recents (long-press card → lock icon; no button exists for this, so none is shown).
- **Footer:** *"After a force stop, Sendqon stays stopped until you open it again."* + a **More Help** button opening the panel's `/help/guides` (shown only when a site URL is paired).

### 2. Home dashboard parity — DONE with two honest exceptions
- **"Push is off" warning card — added.** Shown only when push is genuinely unconfigured for this app: the server delivers a Firebase config in the settings payload (`firebase` key → `Store.firebaseConfigJson`, from which `GatewayApp` initialises Firebase); the card appears when that config is absent/blank, with the vendor's text: *"New messages are picked up every few minutes. Ask the site admin to set up push."*
- **Today tiles — added:** Sent today / Failed today / Received today, summed across the phone's SIMs from the app's own `Stats` counters. **Pending is not shown:** this engine drains the server queue inside each poll cycle, so the app holds no honest pending count of its own — the queue lives on the panel. Inventing the number was rejected.
- **Send Test SMS — omitted, deliberately.** `ApiClient` has no test-send endpoint (pair, login, twoFactor, getDevice, putFcmToken, syncSims, setPaused, postDiagnostics, pending, patch/inbound, USSD and update calls only) and there is no panel test path in the device protocol — no honest test path exists, so per the workstream's own rule the button is not faked.
- Already present before 5.2.2 (verified in code): Online/Paused pill (+ "service stopped" pill), attention card, status card, per-SIM cards with per-SIM sent/received/failed today, Sending card (send-delay / parallel / receive-inbound), Pause/Resume primary button, Sync Now, Sync SIMs (with receiver report).

### 3. Settings parity — read-only block already complete; local toggles deferred
The Settings device card already shows the full dashboard-managed block from the payload — Device Name, Receive SMS, Send Delay (Random min–max s / Off), Parallel Sending, RCS, Error Reporting — under a *"Set from the dashboard"* hint. Nothing was missing, so nothing was added. The vendor's **local Send SMS / Run USSD toggles are deferred to v5.3**: the engine has no local gate for them today (`Store` holds no such preference and `GatewayService` does not consult one), so adding switches that switch nothing would be fake. They need an engine change, not a UI row.

### 4. Assess-only items (not built in 5.2.2)
- **(a) Sign In With Email — v5.3, UI-only, low risk.** Core's device protocol already supports credential pairing and `ApiClient` already implements it end-to-end: `login(email, password)` → optional `twoFactor(challenge, code)` → `acceptAuthPayload()` consuming the same payload shape as code pairing. The only missing piece is a third option on the pairing screen next to Scan QR / Enter Code, plus the 2FA prompt. No protocol work needed.
- **(b) Diagnostics — mostly present; one gap.** Settings → Diagnostics has the Debug Logging switch (`Store.debugLogging` → `LogBuffer.debugEnabled`) and Upload Logs (`ApiClient.postDiagnostics()`); the Logs page has Copy Logs, Share Logs and Upload Logs; the debug note states numbers are masked when logs are shared. **Gap:** the toggle is a plain persisted boolean — there is **no auto-off after 24 h** (verified: no timestamp is stored with the flag). v5.3: store the enable-time and auto-clear after 24 h.
- **(c) Language picker — already exceeds the vendor.** Settings → Language offers English / اردو (persisted app-side); the vendor shows a single "English (United Kingdom)". Nothing to do.
- **(d) Logs screen — partial.** Present: level filter chips (All / Info / Warn / Error / Debug), Copy Logs, Share Logs, Upload Logs. Missing vs the vendor: **source filters** (APP/FCM/MSG/SMS — log lines do carry tags, so this is feasible), **search**, and **clear**. v5.3 candidates. (The Activity tab separately has All/Messages/USSD/Events filters + Share Activity.)
- **(e) Unpair — present.** Settings → Account has Unpair with a confirmation dialog; it clears the pairing (token, device id, cached settings).

## Verification

- **Build:** Gradle 8.7 toolchain (`~/workspace/toolchain`), `BUILD SUCCESSFUL`; custody-signed release. (Build-environment note: the Gradle client JVM needs `GRADLE_OPTS` with `-Djava.net.preferIPv4Stack=true` in this sandbox — without it the client cannot reach the IPv4-only build daemon over loopback and every build dies with "The first result from the daemon was empty"; the first daemon was also OOM-killed once under box-wide memory pressure after producing a verified APK. Final build was clean.)
- **APK checks:** aapt2 badging = `com.rektrs.sendqon`, versionCode 50202, versionName 5.2.2; apksigner cert = custody `eba2c40d…` (matches v5.2.1 → in-place update); dex spot-checks: `guide_open`, `push_off_title`, `companion_builtin_receiver` present; `receiver_app_url` absent.
- **DEV battery (protocol harness, DEV copy `sendqon-dev` only; no emulator exists on this VM):** a throwaway device cloned from DEV device 2's shape, set to app_version 5.2.2 with the receiver block exactly as `CompanionReports` builds it (installed, version "5.2.2", bridge 1/1, connected, receive/read SMS, notifications, battery unrestricted, default_sms=false, mms_ready=null), asserted through core's own classes as www-data: `ReceiverReadiness::ready()` = **true**, `bridgeCompatible()` = **true**, `appOutdated()` = **false**, `CompanionAppUpdates::outdated(receiver)` = **false**, `DeviceCompanions::attentionCount()` = **0**. The throwaway row was deleted (device count 2 → 2). As designed since v5.2.1, no USSD block is reported, so core's USSD payload for such a device still reads "not set up" — a reporting-design artifact, unchanged in 5.2.2; the app's Companions section now states the built-in truth instead of offering the vendor model's dead download. `CompanionReports.kt`/`ApiClient.kt` are unchanged in 5.2.2 — only `BuildConfig.VERSION_NAME` flows through, so the reported receiver version becomes "5.2.2" automatically on the owner's phone.

## Remaining owner-phone proof (the only step left)

1. Install `sendqon-gateway-own-v5.2.2.apk` over v5.2.1 (same signer — in-place update, pairing kept).
2. Checklist/Settings → "Keep the app active" row: with autostart ON it must show **Granted** or the neutral **Check** — never Missing. Tap it → the Keep Phone Online guide opens; its Autostart step leads into the manager.
3. Settings → Companions: Receiver and USSD show **Built in**, RCS shows **Not available**, and there are no download buttons anywhere in the section.
4. Panel → the device's Companions tab should read healthy for the receiver once the app next syncs (it now reports version 5.2.2).
