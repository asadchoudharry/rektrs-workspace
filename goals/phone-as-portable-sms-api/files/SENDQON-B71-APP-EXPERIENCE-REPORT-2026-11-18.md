# Sendqon B7.1 — Own Android Gateway App Experience Upgrade (v5.2.0)

**Date:** 2026-11-18 · **Lane:** B7.1 (follow-up to B7) · **Status: COMPLETE — built, battery-proven on DEV, archived, pushed**

Owner feedback (2026-11-18 ~22:28 PKT): the B7 app was *"bilkul basic"* next to the vendor's designed, feature-rich app. Owner updates the same evening set the design target: **match the vendor app's design as closely as the references allow — same screens, layout, ordering, flows and visual language — rendered in our code with Sendqon branding.** The owner states his Titan custom licence has arrived with all modification rights; on his word the design-matching bar is lifted.

**Legal line held:** the vendor binary was NOT decompiled or inspected. The design was mirrored from legitimate visual references only — the vendor's own user Documentation (inside the portal ZIP), the rebuild-tree spec, and the live server contract in core PHP. All code, assets and signing are ours.

---

## 1. What the app now has

The 5.1.0 protocol shell (one scrolling status screen) is replaced by the documented product flow, in three states:

**State 1 — Pairing** (mirrors Documentation "Pairing"): gradient brand header with the Sendqon kit logo; site URL field (default `https://sendqon.rektrs.com`); **Scan QR** (branded scanner overlay; accepts the panel's `zender-pair:<CODE>` payload — a 5.1.0 bug where the raw payload was sent as the code is fixed); manual code entry with automatic `XXXX-XXXX` formatting; busy/error states; below a divider, the documented **email sign-in + 2FA** card (owners/admins only, per docs).

**State 2 — Setup checklist** (mirrors Documentation "Permissions" + "Keep Phone Online"): permission rows with live Granted/Missing pills and Fix deep-links — Send SMS, Receive SMS, Phone state, Notifications, Camera (QR only), Install apps (updates/companions); a Keep Phone Online card — battery optimisation exemption, background-activity restriction, app standby bucket, notifications — each row showing live state; **Start gateway** button.

**State 3 — Tabbed shell** with bottom navigation **Home / Activity / Logs / Settings**:

- **Home** — gradient header + connection pill (Online / Paused / Offline from the service's live state); update-offer banner when the server offers a newer build; attention card when health needs a fix (with Fix deep-link); **Status card** (connection, server, device, app version, paired-at, last sync); **per-SIM cards** (slot, operator, number, live signal bars, Enabled / Carrier-paused pills with resume time, today's sent / received / failed counters); **Sending card** (send-delay mode incl. random range, parallel sending, receive-inbound — all from the server payload; Pause/Resume, Sync Now, Sync SIMs); battery-fix card with Fix button (docs' home composition).
- **Activity** — persistent local feed (messages, USSD, app events; newest first; survives restarts; capped at 500) with filter chips (All / Messages / USSD / Events) and **Share** — numbers masked to last 4, message bodies never included (docs' sharing rule).
- **Logs** — the live log buffer (now file-persistent, cap 500) with level filter chips, Copy / Share (masked), and **Upload to dashboard** (the server's diagnostics-request flow).
- **Settings** — Device settings from the server payload, read-only with "Set from the dashboard" (name, receive inbound, delay mode/range, parallel sending, paused); SIM controls; Permissions and Keep Phone Online sections (live states + fix links); **Companions** (Receiver / USSD / RCS with the payload's versions; Download & install via the server's signed URL + FileProvider when a build is available, "Not available" otherwise); **Updates** (current version, Check — with the 72-hour required-update note); **Diagnostics** (debug-logging switch, upload logs; note: the vendor app auto-disables debug logging after 24 h — ours is a manual switch, see §5); **Language** — English / اردو (full in-app string table, ~120 keys, persisted; the app's own strings, written for this app); **Account** (server, device ID, Unpair with confirmation).

**Branding:** white-label kit throughout — icon set generated from the kit's `play-store-512.png` (all densities + round), kit logos in the pairing header and Settings, splash screen (kit gradient #4F46E5→#2563EB + centred icon), kit colour palette in the theme. No vendor visual identity anywhere.

## 2. Feature inventory — source per feature

| Feature | Source |
|---|---|
| Pairing QR (`zender-pair:`) + 8-char code, single-use, 10-min expiry; sign-in + 2FA fallback | Spec `04-NO-SOURCE/android-gateway-apk.md`; Documentation "Pairing"; core `PairingQrPayload` |
| Permissions list after pairing (SMS required; Phone, Notifications, Battery, App Updates as setup items; camera for QR only) | Documentation "Permissions" |
| Keep Phone Online checklist (battery exemption, background activity, keep app active, notifications) | Documentation "Keep Phone Online"; core health headers (battery, charging, signal, exemption, background restriction, standby bucket) |
| Home: status, paused + Resume, pacing, battery-fix card, Sync Now | Documentation "Home" |
| Activity feed + masked Share | Documentation "Activity" |
| Logs with level filter, Copy/Share, diagnostics upload (numbers masked to last 4) | Documentation "Logs" / "Remote Diagnostics"; core `diagnostics_requested` payload flag |
| Settings: permissions, Keep Phone Online, companions install/update, debug logging, update check | Documentation "Settings" / "Update prompt" |
| Device settings shown + honoured (name, receive_sms_enabled, random delay range, parallel_sending, paused, per-SIM controls incl. carrier pause + resume time) | Live read of core `DeviceSettingsPayload.php` on offbox-1 |
| Companion versions + download URLs (receiver / ussd / rcs) | Same payload (`receiver_app_url`, `ussd_app_url`, `rcs_app_url` + versions) |
| Update offer (latest version, signed URL, checksum; prompt only when newer; 72-h grace note) | Core `AppUpdateController` contract; Documentation "Update prompt" |
| Per-SIM daily sent/received/failed counters | App-side statistics (the payload carries no counters — counted locally from the app's own send/receive events) |
| EN/Urdu UI strings | App-side (server Urdu pack covers the panel; app strings are ours) |
| Error reporting toggle state | Payload `error_reporting{enabled}` (displayed in Diagnostics) |

## 3. Screens matched to references

| Our screen | Reference |
|---|---|
| Pairing (header, site URL, QR + code, sign-in/2FA below divider) | Documentation "Pairing" page flow |
| Setup checklist (Permissions rows → Keep Phone Online → Start) | Documentation "Permissions" + "Keep Phone Online" pages |
| Home composition (status header, Status card, SIM cards, Sending card, battery-fix card) | Documentation "Home" page; the ZIP's web-panel device screenshots (device-overview / sim-routing) for the card arrangement the phone UI mirrors |
| Activity (filter + masked share) | Documentation "Activity" page |
| Logs (level filter, copy/share, upload) | Documentation "Logs" page |
| Settings sections and ordering | Documentation "Settings" page |
| Update prompt behaviour (Update/Later; required = no Later; 72-h grace) | Documentation "Update prompt" page |

The Documentation's screenshots are of the **web panel's** device pages (1440×1000); no phone-UI screenshots exist in the ZIP. Phone-screen composition therefore follows the docs' written flow + the panel pages' card arrangement. Anything that could not be determined from the references was built to the docs' text, not improvised from the binary.

## 4. Build

- **New files:** `Strings.kt` (EN/UR string table), `Ui.kt` (design kit: gradient, cards, rows, pills, buttons), `ActivityLog.kt` (persistent feed), `Stats.kt` (per-SIM daily counters), `Health.kt` (live health snapshot).
- **Rewritten:** `MainActivity.kt` (pairing → checklist → tabbed shell).
- **Additive edits only:** `Store.kt`, `LogBuffer.kt` (persistence, masking, debug gate), `ApiClient.kt`, `GatewayApp.kt`, `GatewayService.kt` (activity/stats hooks + running flag), `InboundSmsReceiver.kt`, `UssdExecutor.kt`, `QrScanActivity.kt` (branded overlay).
- **Protocol layer untouched** — pairing, heartbeat, message/USSD relay, caps/pause behaviour are the battery-proven B7 code paths.
- **Resources:** kit logos (`logo.png`/`logo-dark.png` at 880 px, splash icon), mipmap set from the kit icon, `themes.xml` + splash drawable, kit colours.
- **Version:** 5.2.0 (versionCode 50200), package `com.rektrs.sendqon`, minSdk 26 / targetSdk 34 — unchanged identity.

**Build-environment note (for future lanes):** Gradle daemons on this VM currently die ~10 s after start ("first result from the daemon was empty") unless the client JVM options match the project's — the working recipe is `GRADLE_OPTS="-Xmx1664m -Dfile.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -Djavax.net.ssl.trustStore=<toolchain truststore> -Djavax.net.ssl.trustStorePassword=changeit"` plus `ANDROID_HOME` set. With that recipe the release build completes (~6 min).

## 5. Verification — protocol battery re-run on DEV

Full B7 harness re-run against the DEV copy (127.0.0.1:18081) after the UI work:

- **Phase 1 (pairing/session): 8/8 PASS**
- **Phase 2 (messages, inbound, USSD, no-offer precondition): 15/15 PASS**
- **Phase 3 (SIM caps, all-capped 429, pause/resume): 8/8 PASS**
- **§16 update offer, re-based on the real contract: 8/8 PASS** — latest = 5.2.0; a 5.1.0 identity is offered 5.2.0 with the correct checksum; a 5.0.0 identity likewise; foreign signer → no offer; foreign package → no offer; the signed URL downloads bytes whose SHA-256 equals the registered APK's.

**Total: 39/39.** (§§1–15 are the original B7 checks, unchanged; §16 carries 8 checks instead of the original 4.)

Two findings from the re-run, recorded plainly:

1. **§16 contract correction.** The original B7 §16 asserted "current build gets no offer (empty apk_url)". Reading `AppUpdateController` shows the server does **no** version comparison: any signed-in device whose package+signer match the upload receives `latest_version` + signed URL + checksum, and the **client** decides whether to prompt. (B7's pass on that line coincided with the slot-directory ownership fault that made every offer empty over HTTP.) B7.1's §16 asserts the controller's actual contract, and our app implements the client-side rule (prompt only when `latest_version` > own version). The 5.1.0 → 5.2.0 requirement from the task is proven by the checks above.
2. **State artefacts, not regressions.** The first re-run showed 3 failures caused by leftover DEV state (a stale pending message from an earlier battery era served first; the 5.1.0 slot registration breaking phase 2's "no offer yet" precondition). After settling 7 stale pending messages and clearing the slot (DEV-only battery data), the full run is clean 39/39. The DEV slot was then re-registered with the final 5.2.0 build as part of phase 3.

**Verification level:** protocol harness against DEV only — no physical device or emulator exists in this environment. The owner's phone install + pairing + first live SMS remains the final proof (already an open owner step from B7).

## 6. APK identity

| | |
|---|---|
| File | `files/android-app/sendqon-gateway-own-v5.2.0.apk` (5.1.0 archive kept alongside) |
| Package | `com.rektrs.sendqon` |
| Version | 5.2.0 (versionCode 50200) |
| Size | 4,510,798 bytes |
| SHA-256 | `76f0866babf321bcf4d7bf925c10f4c14ff05c879757451d30c3e8af8587adab` |
| Signer | CN=Sendqon Gateway, O=Rektrs (Private) Limited — cert SHA-256 `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` (our custody keystore; unchanged from 5.1.0, so the update installs over it) |
| DEV slot | Re-registered with this build (verified: slot meta shows version 5.2.0, same SHA-256 + signer) |
| **Production slot** | **NOT registered — owner decision stands** (starts a 72-hour required-update clock for our-app phones once registered) |

## 7. Not built — and why

- **Per-SIM caps display in the app** — caps are enforced server-side via `SimCaps` but are **not carried in the device settings payload** (verified by reading `DeviceSettingsPayload.php`); the app cannot show what the server does not send. Panel-side only, as in the vendor product.
- **MMS** — the spec marks MMS UNVERIFIED/absent in the protocol; nothing to build against.
- **RCS sending** — the engine reports RCS001 (not implemented); RCS exists only as a companion slot, which the Settings screen surfaces like the vendor flow.
- **USSD scripts/schedules UI** — panel-side per the Documentation; the app relays USSD sessions only.
- **Debug-logging 24-hour auto-off** — the vendor app auto-disables debug logging after 24 h; ours is a manual switch (noted in Settings). Behaviour difference recorded, not hidden.
- **Firebase push wake** — unchanged from B7 (FCM token registration is in the protocol layer; the server-side Firebase configuration is a separate open item).

## 8. Pushes (ls-remote verified)

- App source → Sendqon `app-own-android`: **d2a9091** (from b72bf5c)
- This report → Sendqon `rebuild-tree` + rektrs-workspace `main` (hashes in the lane's closing message)
