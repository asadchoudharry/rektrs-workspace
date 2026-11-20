# Sendqon Gateway App v5.3.0 — Report (2026-11-20)

Owner's order (chat, 2026-11-20 ~13:04 PKT): *"App design mazeed advanced or features bhi mazeed advanced kro, activity or navigation buttons floating or animation bhi dalo pori app main or sab cheezin set kro"* — advanced design + advanced features, floating navigation, animations throughout, everything set. Feature spec = the v5.2.2 report's v5.3 assessment list.

- **APK:** `files/android-app/sendqon-gateway-own-v5.3.0.apk` — 4,527,178 bytes, SHA-256 `c433ec61cd8143dab12c240beaa77cccbfc7a84040ed3e66cd4531ee001b0f35`
- **Version:** 5.3.0 / versionCode 50300 (in-place update over v5.2.2)
- **Signer:** custody keystore, cert SHA-256 `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` — byte-identical to v5.2.0–v5.2.2 (apksigner-verified on the shipped APK)
- **Source:** branch `app-own-android`, commit `997bb26` (base `18fc6e8` = v5.2.2), ls-remote verified. 8 files changed, +858/−173: `MainActivity.kt`, `Ui.kt`, `Strings.kt`, `Store.kt`, `GatewayService.kt`, `GatewayApp.kt`, `LogBuffer.kt`, `build.gradle.kts`.

---

## Workstream 1 — advanced design + motion

The existing design language is kept (white cards, ink text, indigo→blue gradient, green/amber/grey pills) and polished — no re-theme. All motion uses platform animators only (no libraries), 140–450 ms, and entry animations are gated to **real screen/tab changes** (`animateContent` in `MainActivity.render()`): refresh renders (onResume, state re-reads) stay instant, so nothing ever waits on an animation.

- **Floating navigation (all tabs):** the flat bottom bar is replaced by a rounded (24 dp), elevated white pill inset 14 dp from the screen edges, floating over the ground colour. Each tab carries a glyph + label (⌂ Home, ≋ Activity, ☰ Logs, ⚙ Settings); the selected tab sits on an indigo→blue gradient pill that scales/fades in on selection. The bar stays in the shell's flow, so no content ever hides behind it. Unselected tabs get ripple press feedback.
- **Floating action:** a circular gradient **Sync Now** button floats at the bottom-end of Home and Activity (above the nav bar), spins on tap, and runs exactly the Sending card's sync work (engine wake + settings refresh). It scales in on page entry.
- **Screen transitions:** the tab content fades in (180 ms) on tab/screen change; page cards enter with a staggered fade + 14 dp rise (35 ms steps, delay capped at 210 ms).
- **Home:** the Online status pill now carries a **gently pulsing dot** (850 ms breathe; static while Paused, and the animator cancels itself when the view leaves the window — it is the app's only loop). The three today tiles **count up** to their true values on entry. A local-gate row appears in the Status card whenever a phone-side switch is off, and the Sending card states it in words too.
- **Checklist + Guide:** state pills **pop** (scale 0.8→1) whenever they re-render, so returning from a Fix reads as a change; whole permission rows are ripple-pressable tap targets (as before, the whole row opens that permission's own settings screen).
- **Pairing:** the three options are now full-width buttons (see Workstream 2); switching between the code and email forms animates the newly shown form (fade + settle).
- **Buttons everywhere:** primary/ghost/small buttons gained ripple press feedback over their existing gradients/outlines; primary buttons gained a slight elevation.
- **Empty states:** Activity (✉), Logs (☰) and the no-SIMs card (▤) now render an icon + text empty state instead of a bare hint line.
- **Polish pass:** consistent 24 dp nav radius / 18 dp selected-pill radius, unified chip builder for Logs filters, spacing normalised across the new sections.
- **Dark theme:** the codebase has **no dark theme** (hardcoded light palette, no night resources) — per the brief, none was bolted on. Recorded here as the one design item knowingly left for a future version.

## Workstream 2 — advanced features

### 1. Sign In With Email pairing — LANDED
The pairing screen is restructured to the vendor arrangement: **Scan QR Code** (primary) / **Enter Code** / **Sign In With Email** as three options above two switchable forms; the site-URL card sits above the choices since it serves all three. The code form remains the default, exactly as before. The email form wires the already-implemented `ApiClient.login`/`twoFactor`: email + password, a 2FA field that reveals (animated) only when the server answers 202 with a challenge, then the same `acceptAuthPayload` registration the code path performs. Errors are plain words: 401/403/422 → *"Sign-in failed — check the email and password and try again."* The password lives only in the form field and the sign-in call — it is never written to `Store` — and the field is cleared on success.
**DEV proof (below): the full login round-trip was exercised against the DEV copy with the project's B7 battery tenant — 200 with the complete auth payload, and 401 `invalid_credentials` for a wrong password.**

### 2. Local Send SMS / Run USSD toggles with real engine gates — LANDED
New Settings section **Gateway (this phone)** with two switches, both default ON, persisted in `Store`. The gates are in `GatewayService`, read every cycle:
- **Send SMS off** → the engine does not pull the send queue at all (a pulled message is marked served server-side, so fetch-and-hold would strand it); a mid-drain switch-off also stops the current page. Settings refresh, outbox flush, SIM sync and update checks keep running.
- **Run USSD off** → USSD pulls never execute; with Send SMS off, USSD keeps working through its own `/ussd/pending` endpoint, so the two gates are genuinely independent.
- Gate flips are logged once by the engine and recorded in Activity from the switch; Home reflects a switched-off gate in the Status card and the Sending card note. The dashboard pause remains a separate, server-side control, unchanged.

### 3. Send Test SMS (on-device) — LANDED
Home → Sending card gains **Send Test SMS · SIM a → SIM b** buttons in both directions, shown only when both SIMs are present **and** both numbers are known to the phone (carriers can withhold a SIM's number; where a number is unknown the button honestly does not appear). A confirmation dialog states plainly that this sends a **real SMS that uses the SIM's balance**. The send goes through the same `SmsManager` per-subscription path as the engine, and the result settles from the radio's sent-result broadcast: Activity records it, today's Sent/Failed counters move, and a toast states the outcome. The server protocol has no test endpoint — this is a local device test, exactly what the vendor button does.

### 4. Debug logging 24-hour auto-off — LANDED
The Diagnostics switch now stores its switch-on time (`Store.debugEnabledAt`). Expiry is enforced on read — `debugLoggingActive()` clears an expired flag — and is applied at app start (`GatewayApp`), in Settings, and by the log buffer. While on, Settings states the remaining window in plain words (*"On — turns off automatically in about N h."*). The masked-numbers sharing rule is unchanged.

### 5. Logs completion — LANDED
Logs now has, alongside the existing level chips and Copy/Share/Upload:
- **Source filters:** All sources / App / SMS / USSD / FCM / Sync, mapped from this app's own log tags (`LogBuffer.sourceOf`).
- **Text search:** filters by message or tag as you type; only the list card rebuilds, so the field never loses focus.
- **Clear logs:** confirmed action that empties the on-phone buffer and its file; already-uploaded diagnostics are unaffected.
- Copy/Share now export exactly the filtered selection (`LogBuffer.shareTextFor`).

### 6. Rest of the v5.2.2 parity table
Nothing remains deferred from it: the dashboard read-only block was already complete in 5.2.2, the language picker already exceeds the vendor (English / اردو), Unpair already exists, and the Companions section's built-in truth is unchanged. The two standing honest omissions from 5.2.2 are unchanged and still hold: **no Pending tile** (the queue lives on the panel; the app holds no honest pending count) and **no server test-send** (no such endpoint exists — superseded on-device by feature 3 above).

## Not regressed (v5.2.1 / v5.2.2 behaviour)
Permission deep links and whole-row tap targets; `CompanionReports` (receiver built-in reporting; the USSD block still deliberately NOT asserted); the Defect A autostart model (Granted / neutral Check, never a false Missing); the Companions section (Built in / Built in / Not available, no download buttons — the shipped dex still contains **zero** `receiver_app_url` references); the Keep Phone Online guide; QR pairing and code pairing flows untouched.

## Verification

- **Build:** Gradle 8.7 toolchain, `BUILD SUCCESSFUL`, custody-signed release. (Environment note: the first attempt's daemon was killed under box-wide memory pressure after Kotlin compilation had already succeeded — the v5.2.2 lane's known failure mode; the retry completed cleanly.)
- **APK checks:** aapt2 badging = `com.rektrs.sendqon`, versionCode 50300, versionName 5.3.0; apksigner cert = custody `eba2c40d…` (matches v5.2.2 → in-place update); dex spot-checks: `Sign In With Email`, `TEST_SMS_RESULT`, the engine gate log lines present; `receiver_app_url` absent.
- **DEV battery (sendqon-dev, as www-data, core's own classes):** a throwaway device cloned from DEV device 2's shape, set to app_version 5.3.0 with the receiver block exactly as `CompanionReports` builds it in 5.3.0 → `ReceiverReadiness::ready()` = **true**, `bridgeCompatible()` = **true**, `appOutdated()` = **false**, `CompanionAppUpdates::outdated(receiver)` = **false**, `DeviceCompanions::attentionCount()` = **0**. The throwaway row was deleted (device count 2 → 2). As designed since v5.2.1, no USSD block is reported, so core's USSD payload still reads "not set up" — a reporting-design artifact, unchanged.
- **Email-login battery (DEV HTTP, 127.0.0.1:18081, app identity headers at 5.3.0):** the B7 battery tenant (DEV-only `@example.test` account from the project's own harness) signed in through `/auth/login` → **200** with `{hash, device_unique, settings}` — the exact payload the app's `acceptAuthPayload` consumes; a wrong-password control → **401 `invalid_credentials`**, the status the app's new plain-words mapping covers. The device row the login created was deleted afterwards (count back to 2). No production server was touched; no production data changed.

## Remaining owner-phone proof (the only step left)

1. Install `sendqon-gateway-own-v5.3.0.apk` over v5.2.2 (same signer — in-place update, pairing kept).
2. Bottom bar is now the floating pill; switching tabs animates the selected pill; Home/Activity show the floating Sync button; the Online dot breathes; today's numbers count up.
3. Pairing screen (after Unpair, or on a fresh install): three options — Scan QR Code / Enter Code / Sign In With Email; the email form signs in with the panel account (2FA prompt appears only if the account has 2FA on).
4. Settings → Gateway (this phone): turn Send SMS off → the panel queue stops draining to this phone while USSD still runs; turn it back on → sending resumes. Home's Status card shows the off state while it lasts.
5. Home → Sending: Send Test SMS SIM 1 → SIM 2 (needs both numbers visible to the phone) — a real SMS arrives on the other SIM and the result appears in Activity.
6. Logs: source chips + search filter the list; Clear logs empties it. Diagnostics: debug logging shows its auto-off countdown.
7. Panel → the device's Companions tab should read healthy for the receiver once the app next syncs (it now reports version 5.3.0).
