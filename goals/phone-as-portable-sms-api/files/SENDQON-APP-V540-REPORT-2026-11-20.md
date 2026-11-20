# Sendqon Gateway App v5.4.0 — Report (2026-11-20)

**Release:** `sendqon-gateway-own-v5.4.0.apk` · 4,587,543 bytes · SHA-256 `947409242149a9073345257074d33d653b7e669d4c0595942bf86d05dd745a31`
**Identity:** package `com.rektrs.sendqon`, version 5.4.0 / code 50400, signer `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` (custody key, verified from the built APK with apksigner — in-place update over 5.3.0 holds)
**Source:** branch `app-own-android`, commit `fb92573` (pushed, ls-remote verified)
**Slot:** registered in the production `android_gateway` slot 2026-11-20T10:10:59Z (15:10:59 PKT) — proof in §5.

v5.4.0 carries four things: the SIM balance feature the owner picked after v5.3.0, a branded launcher icon (owner addition, 14:17 PKT), and two field fixes from the owner's own phone logs of the 5.2.2 → 5.3.0 auto-update (field fix #1, 14:19 PKT) and his battery observation (field defect #2, 14:30 PKT).

---

## 1. SIM balance auto-check + low-balance alert

The 2026-11-20 SIM2 lesson: a send failed with a radio error because the Ufone SIM simply had no balance, and nothing anywhere could see that coming. Now the app asks the carrier.

**How it works**
- Each SIM's balance is a USSD dial of the carrier's balance code over the same official `TelephonyManager.sendUssdRequest` channel the queued-pull executor uses (`BalanceChecker`). Codes resolve from the SIM's operator — defaults Zong `*222#`, Ufone `*706#`, Jazz `*111#`, Telenor `*444#` — and every code is editable per SIM in Settings → SIM balance (codes change; the field exists precisely so a changed code is a setting, not an app update). Saving a field that still holds the carrier default stores no override, so a future correction to a default still reaches the phone.
- **Manual:** a *Check balance* button on each Home SIM card. **Scheduled:** `BalanceWorker` (WorkManager, ~6 h) while paired; scheduled on pair/boot/app start when the auto-check switch is on, cancelled on unpair or switch-off.
- **Gates — one decision point** (`BalanceLogic.gateBlock`, unit-pinned): checks run only while paired, only while the local **Run USSD** switch is ON (the v5.3.0 gate, respected absolutely — off means no dials, manual or scheduled), never while the gateway is paused, and only with the CALL_PHONE permission. A blocked manual tap explains itself with a toast instead of recording a fake carrier failure.
- **Parsing + honesty:** the amount is parsed only from an explicitly currency-marked figure (`Rs`, `Rs.`, `PKR`, روپے; digits may be Latin or Arabic-Indic). With several marked figures, the one nearest the word "balance" wins. A real **Rs 0 parses as 0** — that is the alert case, not an error. The RAW reply is always stored verbatim with the parsed amount (nullable) and timestamp. An unparseable reply shows **"Couldn't read balance"** with the carrier's reply viewable in a dialog; a failed dial shows **"Check failed"**. No value is ever invented.
- **Display + alert:** the SIM card shows `Balance Rs X · checked <relative time>` (green, or red when low). Threshold default **Rs 50**, editable in Settings. Any SIM under threshold raises a Home alert card in the existing attention style: *"SIM 2 balance low — Rs X"*.
- **Panel reporting:** the latest check rides the existing `PUT /device/sims` sync per SIM — `balance_amount` (null when unread), `balance_text` (raw, ≤160 chars), `balance_checked_at` (ISO), `balance_status`, `balance_low` — built by the unit-tested `BalanceLogic.payloadFields`. A fresh balance changes the engine's sync fingerprint, so it reports on the next cycle, not the hourly one. **Server behaviour, verified from live core source** (`DeviceController::syncSims`): validation names only slot/phone_number/operator/country (+ companion blocks), so the unruled balance keys are silently dropped today — no 422, no storage, no core patch made. **Follow-up (not built):** the natural home for surfacing this is the `sim_fleet` plugin — `sim_fleet_states` is already keyed per `sim_id` with a `health_detail` JSON and a fleet dashboard; a plugin-side capture of these fields belongs there when the owner wants balance visible in the panel.

## 2. Branded launcher icon

The owner's home screen showed our app with a generic blue chat-bubble glyph — the same white-bubble-and-dots mark as the brand wordmark's glyph and effectively indistinguishable from the vendor's. New mark, from the app's own kit palette (colors.xml / Ui.kt: indigo `#4F46E5`, blue `#2563EB`, cyan `#38BDF8`):

- **Design:** a bold white **S** drawn as one stroked path, two **cyan broadcast arcs** leaving its upper terminal — the gateway's signal, not another bubble — on a **dark navy gradient** (deep indigo `#1E1B4B` → brand blue `#2563EB`, the header gradient's diagonal taken dark). Flat, no text, legible at 48 px (checked).
- **Implementation:** adaptive icon (vector foreground + gradient background drawable) for API 26+, `ic_launcher_round` adaptive twin + `android:roundIcon` now declared, legacy PNG mipmaps at all five densities (square + round) rendered from the *same* geometry as the vector (one drawing, two forms). The foreground-service notification previously used the system `stat_notify_sync` glyph; it now uses `ic_stat_notify`, the same mark as a monochrome silhouette.
- **Verification from the built APK:** `aapt2 dump resources` shows `mipmap/ic_launcher` + `ic_launcher_round` at mdpi→xxxhdpi plus anydpi entries; `aapt2 dump xmltree` on the packaged adaptive icon shows background → `drawable/ic_launcher_bg` (gradient) and foreground → `drawable/ic_launcher_foreground` (the S mark); the packaged xxxhdpi PNG was extracted and visually confirmed as the new mark; `ic_launcher_background` colour now reads `#ff1e1b4b`.

## 3. Field fix #1 — updater noise + duplicate-download race

From the owner's logs of the (successful) 5.2.2 → 5.3.0 update: `Update offered: 5.3.0` was logged ~15 times in two minutes, and a second download attempt raced the pending install, its corrupted bytes correctly discarded by the checksum. `UpdateManager` now:

- logs the offer **on state change only** (first sight of a version; the marker resets when the running version catches up);
- downloads a version **at most once**: the verified file is kept and reused, a download in flight is never duplicated (process-wide single-flight), and bytes land in a `.part` staging file that is renamed into place **only after the checksum passes** — a stray attempt can no longer clobber the good copy the installer holds;
- while an install prompt for a version is pending, engine re-checks stay quiet; an explicit user tap (Home banner, Settings → Check for update) passes `forceInstall` and re-opens the installer from the kept, verified file.
- **The checksum verification itself is unchanged** — it caught the bad bytes exactly as designed.

## 4. Field defect #2 — battery state frozen at 58%

Owner's proof: phone status bar 16% while app + panel reported `battery_level 58, is_charging 0`, and 58 had held for hours across fresh syncs. Root cause: **both** readers (Home via `Health.snapshot`, panel via `ApiClient` health headers) took the **sticky** `ACTION_BATTERY_CHANGED` intent, which on the owner's Xiaomi kept returning the snapshot from around pairing time.

Fix: `Health.battery()` reads **BatteryManager's live fuel-gauge properties** (`BATTERY_PROPERTY_CAPACITY` / `_STATUS`) on every call — nothing is cached anywhere. The sticky intent survives only as a fallback when a property read is unavailable, and charging reports `null` (header omitted) when no source answers, never a guessed false. Home and the per-request panel headers both use this one path, so both track reality. Additionally the engine registers for `ACTION_BATTERY_CHANGED`: the broadcast is only a *trigger* — on a level change (throttled to 1/min) it refreshes device settings, and the values sent are re-read live at send time. The pure decision (live property wins, sticky fallback math, charging states) is extracted to `BatteryRead` and unit-pinned, including the field case itself (sticky 58 vs gauge 16 → 16).

## 5. Slot registration proof (production)

Via core `AppFiles::store()` as www-data (companion guard no longer applies; vendor family already removed in the ecosystem switch):

- Before: 5.3.0, sha `c433ec61…`, uploaded 2026-11-20T08:48:55Z.
- After: **5.4.0**, sha `94740924…`, size 4,587,543, package `com.rektrs.sendqon`, signer `eba2c40d…`, uploaded **2026-11-20T10:10:59Z (15:10:59 PKT)**.
- Offer matching (in-process `GatewayAppVersions::matches`): our signer → **true**; the real vendor cert `77f4e3df…` → **false** (empty offer).
- `required_at` = **2026-11-23T10:10:59Z (2026-11-23 15:10:59 PKT)** — registration +72 h exactly; `min_required_version` stays 5.0.0 until then.
- Signed download URL fetched over HTTPS: **HTTP 200, 4,587,543 bytes, SHA-256 = `94740924…`** — byte-identical to the built APK.
- Device rows 1 and 2 read identically before and after (id 2's `updated_at` moved only by its own live sync); staging files removed from container and host.

## 6. Battery (tests) — and an honest note on evidence

JVM battery over the pure logic (`Balance.kt`, `BatteryRead.kt`), **22 tests, all passing**: parser (11 — Zong/Ufone/Jazz/Telenor wordings, Rs 0, thousands separators, Urdu digits + روپے marker, balance-figure-vs-package-price, validity-date trap, unmarked numbers never parse), carrier codes (2), threshold + gate + payload shape (5), battery-read decision (4).

Evidence trail, stated plainly: Gradle's own test *executor* repeatedly died on this box ("Unable to connect to the child process", daemons OOM-killed under shared memory pressure — the box also needed Gradle 8.7 fetched, since AGP 8.5.2 refuses the 8.3 that was installed). The classes were compiled by Gradle (`compileDebugKotlin` + `compileDebugUnitTestKotlin`, clean), and the battery was then executed directly with JUnitCore 4.13.2 over those compiled classes: output `OK (22 tests)`. An interim progress claim of test results made earlier in this lane was premature and is corrected here — this paragraph is the verified account. The full app (debug + release) compiles clean with all changes; no regressions by construction: pairing, toggles, Send Test SMS, deep links and CompanionReports are untouched except additive wiring (worker scheduling beside PollWorker's, one fingerprint term, the two `forceInstall` tap sites).

## 7. Honest limits

- **Live USSD proof is the owner's phone.** No SIMs exist in this environment, so real carrier replies cannot be exercised here; the parser is pinned against plausible reply wordings for exactly his two carriers that matter (Zong SIM1, Ufone SIM2). The first real checks — manual from the SIM cards, then the 6-hour auto-check — will show parsed amounts or honest failure states with the raw reply one tap away.
- **Battery fix proof is likewise on his phone:** after it updates to 5.4.0, the panel's battery value must move off 58 and track the status bar.
- Carrier balance codes are defaults, not gospel — if a carrier's reply comes back unparseable or the code has changed, the raw reply is in the app and the code is editable in Settings.
- The panel does not store or display balance yet (§1 follow-up: sim_fleet). The phone-side alert is the working surface in this release.
- Dark theme remains knowingly unbuilt, as in v5.3.0.
