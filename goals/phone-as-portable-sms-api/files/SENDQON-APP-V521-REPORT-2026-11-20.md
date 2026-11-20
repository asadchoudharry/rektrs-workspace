# Sendqon Gateway App v5.2.1 — Checklist Deep Links + Single-App Companion Fulfilment (2026-11-20)

Two owner directives from 2026-11-20, shipped in one build:

1. **Checklist deep links** — on the v5.2.0 Setup checklist screenshot: *"Jab yeah
   permissions per click ho to wo mujhy khud un settings per ly k jana chahiye"*
   (a tap on a permission must land on that permission's own settings screen).
2. **Companion fulfilment** — on the panel device page screenshot (Companions tab:
   Receiving **Needs Attention**, Receiver Companion **Not Installed**, USSD **Not
   Set Up**): *"yeah issue bhi resolve kerna is new build main"*. That device row
   belongs to the vendor app, whose model splits receiving/USSD into separate
   companion APKs. Our product is one app; this build makes the one app fulfil
   the Receiver Companion role itself.

| | |
|---|---|
| Version | 5.2.1 (versionCode 50201), package `com.rektrs.sendqon`, minSdk 26 / targetSdk 34 |
| APK | `files/android-app/sendqon-gateway-own-v5.2.1.apk` — 4,510,794 bytes |
| APK SHA-256 | `b005e5cbb346d7ca9f91aadf7bd5faf1e1de5c8363c5f42fdcbbf92b7002dab0` |
| Signer cert SHA-256 | `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` — byte-identical to v5.2.0 (verified with apksigner on both), so it installs as an in-place update |
| Source | Sendqon repo branch `app-own-android`, commit `74eaa3a` (ls-remote verified) |
| Build | `gradle :app:assembleRelease` with the B7.1 recipe — **BUILD SUCCESSFUL in 3m 41s**; badging verified (50201 / 5.2.1); dex contains the new bridge-report keys, the MIUI autostart component and the restricted-settings hint |

---

## 1. Workstream 1 — every checklist row now lands on its own settings screen

The checklist rows are built once (`permissionChecks()` + `keepOnlineCard()`) and
shared by the first-run checklist and Settings → Permissions, so one fix covers
both surfaces. Changes in `MainActivity.kt` (+ asked-state flags in `Store.kt`):

- **Whole row is the tap target**, not only the Fix button, with a `›` chevron as
  the affordance; the Fix button still works. Granted rows show no dead controls.
- **State refresh on return** already existed (`onResume` re-renders); it now
  visibly settles each row after the user comes back from a settings screen.
- **Asked-state tracking** (`Store.wasAsked/markAsked`): Android's rationale flag
  reads identically before the first ask and after a permanent denial, so the app
  now records that a group was asked; `canStillAsk()` = never asked, or rationale
  still offered. That is what lets a blocked group fall back to settings instead
  of re-firing a dialog Android will never show.

Per-row tap result:

| Row | Tap opens |
|---|---|
| SMS (send, receive, read) | Runtime permission dialog while still askable → after permanent denial, **App info page** (package details settings). If the group is blocked, a hint line appears under the row: App info → ⋮ → *Allow restricted settings*, then Fix again (Android gives apps no intent to that toggle — the hint is the honest maximum, nothing is faked) |
| Phone (SIM details, USSD) | Runtime dialog while askable → App info page after permanent denial |
| Notifications | Runtime dialog (API 33+, while askable) → **App notification settings** for this package, App info as fallback |
| Battery — unrestricted | Battery-exemption request for this package → exemption list → App info (fallback chain) |
| App updates (install own updates) | "Install unknown apps" page for this package → App info on failure (previously the failure was swallowed and the tap did nothing) |
| Turn off battery optimization | Same exemption chain as Battery above |
| Allow background activity | App info page (where background use is set) |
| **Keep the app active** | **Was a dead row (no action at all)** → now opens the **MIUI/HyperOS autostart manager** (`com.miui.securitycenter` AutostartManagementActivity — the owner's Redmi class) when present, else the App info page |
| Allow notifications (Keep Phone Online) | App notification settings, App info fallback (previously no fallback) |

New strings added in both app languages (EN + UR): `sms_restricted_hint`.

## 2. Workstream 2 — the one app is now its own Receiver Companion

### What core expects (protocol findings, from the core source on the DEV copy)

- Companion state lives in two JSON columns on the device row:
  `devices.receiver_report` and `devices.ussd_report`. The panel's Companions
  tab is rendered from them by `DeviceCompanions` / `ReceiverReadiness` /
  `UssdReadiness`.
- **The gateway app itself is the reporter.** The only device write that accepts
  companion blocks is `PUT /api/v1/internal/android/device/sims`
  (`DeviceController::syncSims` spreads `ReceiverReports::rules()` and
  `UssdReports::rules()` into its validation) — the SIM-sync call our app
  already makes. No separate companion package, signature or pairing is
  involved anywhere in the write path.
- Receiver validation shape: only the keys `installed, version,
  bridge_protocol_version, gateway_bridge_protocol_version, connected,
  receive_sms, read_sms, notifications, battery_unrestricted, default_sms,
  mms_ready, rcs_role_conflict` are allowed; the seven booleans are required;
  `mms_ready` must be present (nullable).
- Readiness semantics (`ReceiverReadiness`): ready = device enabled +
  `receive_sms_enabled` (panel-side switch) + connected, where connected =
  installed + non-empty version + `connected` + **bridge-compatible:
  `bridge_protocol_version` and `gateway_bridge_protocol_version` are equal
  positive integers**. `default_sms` is a display check only (the panel labels
  it Optional); `mms_ready` is tri-state (null → "Not verified").
- Update semantics (`CompanionAppUpdates::outdated`): a companion counts as
  outdated exactly when its reported `version` ≠ the gateway's stored
  `app_version`. In a single app the truthful receiver version **is** the app
  version — reporting anything else would flag a permanent fake "update".

### What was implemented

New `CompanionReports.kt`; `ApiClient.syncSims()` gained an optional `receiver`
block; the engine's SIM sync and the Settings "Sync SIMs" button both attach it.
Every value is measured live on the phone:

| Field | Value / source |
|---|---|
| `installed` | `true` — the receiver is this app (`InboundSmsReceiver`) |
| `version` | `BuildConfig.VERSION_NAME` ("5.2.1") — equals the gateway `app_version` core stores from the `X-App-Version` header, so the companion is never "outdated" |
| `bridge_protocol_version` / `gateway_bridge_protocol_version` | Both `1` — this app's internal bridge version, reported as both sides because both sides are this app; core requires the pair to be equal |
| `connected` | `GatewayService.isRunning` — the in-process bridge is up while the engine runs |
| `receive_sms` / `read_sms` | Live `RECEIVE_SMS` / `READ_SMS` permission states |
| `notifications` | `NotificationManagerCompat.areNotificationsEnabled()` |
| `battery_unrestricted` | `PowerManager.isIgnoringBatteryOptimizations()` |
| `default_sms` | Whether this app holds the default-SMS role (normally false — Optional row) |
| `mms_ready` | **`null` — honest.** MMS receiving needs the default-SMS-app role and is not implemented in this build, so the panel keeps showing "Not verified" instead of a state we cannot back |

Freshness: the sync fingerprint now includes the receiver state, so a permission
flip re-syncs on the next engine cycle instead of waiting for a SIM change or
the hourly refresh.

### USSD companion — deliberately NOT reported (protocol evidence)

- `UssdReadiness` encodes the vendor companion's design: ready requires
  `accessibility === true` (an enabled accessibility service — the vendor
  companion reads USSD dialogs that way) **and** `self_test.status === 'passed'`.
  Our app executes USSD through the official `TelephonyManager.sendUssdRequest`
  API and runs no accessibility service; asserting either value would be false.
- Asserting a partial block would also backfire: `DeviceCompanions` counts a
  companion as needing attention when `in_use && !ready`, and `in_use` flips on
  with `installed` — an honest-but-incomplete USSD report would pin a permanent
  "needs attention" on an optional feature.
- Nothing functional depends on the report: `UssdController` and the flow
  `RunUssdExecutor` never read `ussd_report` (grep-verified), and the B7 battery
  already proved the full USSD cycle on DEV with no report present. USSD keeps
  working; its companion card stays "Not Set Up", as the panel itself marks the
  USSD companion Optional.
- MMS is the same shape of answer: reported `null` → "Not verified" by design.

### DEV battery — 19/19 + 3 negative probes (protocol harness, DEV copy only)

Same verification level as B7: a harness on the DEV copy (127.0.0.1:18081)
speaking exactly like the app (same endpoints, identity headers, payload
bytes), assertions read back through core's own service classes. A fresh
battery device was paired for the run and deleted afterwards; **no production
device row was touched**.

- Pair with v5.2.1 identity headers → 200; device row stores `app_version`
  "5.2.1".
- Baseline PUT (sims only, the v5.2.0 shape) → 200; `receiver_report` stays
  null (old builds unaffected).
- PUT with the v5.2.1 receiver block → 200; report stored verbatim.
- `ReceiverReadiness::ready()` **true**, reason null, `canRead()` true,
  `mmsReady()` false (honest), all six functional checks true, `default_sms`
  false; `DeviceCompanions` receiver `in_use` + `ready`, **attentionCount 0**;
  `CompanionAppUpdates::outdated(receiver)` false.
- Negative probes: extra key in the block → **422**; `mms_ready` omitted →
  **422** (present-with rule — our payload always carries it as null);
  bridge versions 1≠2 → 200 but readiness reason becomes *"Update Receiver
  Companion to match the gateway bridge."* (proves why the equal pair matters);
  good payload re-sent → ready again.

## 3. What remains — owner-phone proof

Verification above is protocol-level (no device/emulator in this environment —
the standing B7 caveat). The on-phone proof, in order:

1. Install `sendqon-gateway-own-v5.2.1.apk` over the existing v5.2.0 (in-place
   update, same signer; pairing and settings survive).
2. Open the app → Setup checklist: tap each row — SMS, Phone, Notifications,
   Battery, and **Keep the app active** (should land on the Redmi autostart
   screen) — and confirm each lands on its settings screen and the row flips
   to Granted on return.
3. Pair (or confirm the existing pairing), press **Start gateway**, grant the
   SMS permissions.
4. Panel → the device paired with **our** app → Companions tab: Receiving
   should show ready (no "Needs Attention") once SMS receiving is on for the
   device in the panel and the permissions are granted; USSD remains "Not Set
   Up" by design (§2); Picture-Message remains "Not verified" by design.
   Note: the pre-existing "Asad Ahmad device" row belongs to the vendor app
   and will keep showing its own companion state — the healthy tab is on the
   device row our app creates when it pairs.

## 4. Hygiene note

The signing pass was passed to Gradle as a `-P` property (the B7/B7.1 recipe);
such properties are visible in the build host's process list while a build
runs. `build.gradle.kts` already supports the `SENDQON_KEYSTORE_PASS`
environment variable instead — future lanes should prefer it. No credential
value appears in this report, the commit, or any pushed file.

## 5. Push ledger (all ls-remote verified)

| Item | Where | Hash |
|---|---|---|
| App source v5.2.1 | Sendqon `app-own-android` | `74eaa3a` |
| This report | Sendqon `rebuild-tree` (`planning/`) + rektrs-workspace `main` (`goals/phone-as-portable-sms-api/files/`) | see repo history (this file) |
