# Sendqon B7 — Own Android App + USP-2 SIM Fleet Intelligence — Build Report (2026-11-18)

Phase B7 of `SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md`: replace dependence on the
vendor-built gateway app with our own clean-room Android app, and ship USP-2
(SIM Fleet Intelligence) as the `sim_fleet` plugin. **Both halves are complete.**
The app is built, protocol-verified against the DEV copy and archived; the plugin
is built, batteried and **ACTIVE in production**. No core files were edited; no
plan features, prices or flags were changed; **no production device state was
touched and the own APK was NOT registered in any production slot** (owner
decision, see §6).

---

## 1. Own Android gateway app

Clean-room Kotlin implementation written against the server-side protocol in the
PHP source (routes under `/api/v1/internal/android`) — pairing, token auth,
long-poll sending, inbound relay, USSD and self-update speak the same wire
protocol, but the code, package identity and signing key are ours.

| | |
|---|---|
| Package | `com.rektrs.sendqon` |
| Version | 5.1.0 (versionCode 50100) — above the server's 5.0.0 minimum |
| minSdk / targetSdk | 26 / 34 |
| Final APK | `files/android-app/sendqon-gateway-own-v5.1.0.apk` — 4,373,241 bytes |
| APK SHA-256 | `ec5f0cad1df1f1d3073a3f3a0a1da624444cc7bcada55d9998c9a8977a71a78c` |
| Signer cert SHA-256 | `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` |
| Source | Sendqon repo branch `app-own-android` (`android/gateway/`), local tree `~/workspace/sendqon-android/` |
| Signing custody | Keystore + password ONLY in the goal's `hidden_files/release-custody/` — never in git, never printed |

**Post-build fix included in this final build:** the pairing scanner now strips
the `zender-pair:` QR prefix (the panel QR payload is `zender-pair:XXXX-XXXX`,
per core's `PairingQrPayload`) in `MainActivity.extractPairingCode()` — the
previously archived APK predated the fix and has been replaced; the prefix
string is present in the shipped dex and the source edit is the only post-build
source change.

**Toolchain (this VM, `~/workspace/toolchain/`):** Temurin JDK 17, Gradle 8.7
(installed distribution, no wrapper), Android SDK 34 (platform + build-tools
34.0.0) installed from direct zips. Proxy fixes recorded: `gradle.properties`
carries `-Djava.net.preferIPv4Stack=true` and a proxy-CA truststore
(`gradle-truststore.jks`); `GRADLE_USER_HOME=~/workspace/toolchain/gradle-home`.
Release build: `gradle :app:assembleRelease` — BUILD SUCCESSFUL in 2m 1s;
badging and signer verified with aapt2/apksigner after the build.

## 2. Protocol battery vs DEV — 34/34

The harness speaks to the DEV copy (127.0.0.1:18081) exactly like the app does —
same endpoints, same identity/health headers. **Verification level, stated
honestly: this is a protocol harness against the DEV server, not a device run.
There is no physical device or emulator in this environment; the owner's phone
is the final proof (§6b).**

- **Phase 1 — 8/8:** app below the server minimum refused 426; pairing 200 with
  a 64-hex token; bad token 401; device settings + heartbeat 200; SIM sync
  (Jazz slot 0, Zong slot 1) 2/2; FCM token upload 204. (Re-run in this lane
  after the §16 fix: 8/8 again.)
- **Phase 2 — 15/15:** queued message pinned to its SIM slot; PATCH
  sent→delivered; inbound relay 201 with duplicate relay 200; USSD interactive
  full cycle.
- **Phase 3 — caps/pause:** capped SIM's message withheld while the uncapped
  SIM is served; all SIMs capped + waiting work → 429 `all_sims_capped`; pause
  empties the pull without killing the session; resume restores service.
- **§16 app-update offer — closed in this lane (was 33/34).** Root cause: the
  DEV slot registration had run as root via docker exec, leaving
  `storage/app/private/apps/android_gateway/` as `drwx------ root:root`; the
  PHP-FPM process (www-data) could not traverse it, so `AppFiles::currentPath()`
  returned null under FPM only — CLI/controller calls saw the upload, real HTTP
  got an empty offer. A dev-rehearsal artefact; production registration runs
  through the panel as www-data and is unaffected by construction. Fix on DEV:
  chown www-data + 755. The DEV `AppUpdateController` was verified
  byte-identical to the first lane's backup — the temporary debug patch was not
  present and nothing needed restoring. After the fix, over real HTTP:
  - older build (5.0.0, our signer) → offer: `latest_version 5.1.0`, signed
    `apk_url`, `checksum_sha256` of the registered APK,
    `required_at` = upload + 72 h grace, `min_required_version 5.0.0`;
  - the signed URL downloads the exact registered bytes (SHA-256 matches the
    published checksum) — the DEV `APP_URL` omits the `:18081` port, so the raw
    link 308s at the host's port-80 layer; with the dev port restored it serves
    200 (production's APP_URL is the public https hostname — unaffected);
  - foreign signer → empty offer (latest 1.0.0, no URL);
  - current build (5.1.0) → the endpoint returns `latest_version` equal to the
    running version; the no-prompt behaviour is the client's version
    comparison (`UpdateManager.compareVersions`), verified in the app source.
  - After the final APK was built, the DEV slot was re-registered with it; the
    offer now carries the final checksum `ec5f0cad…a78c`.

## 3. USP-2 — what enforces, what advises

The plugin manages levers core already owns; it never sits in the send path.

| Feature | Mechanism | Enforced or advisory |
|---|---|---|
| Warm-up ramp (7-day ladder 30→300/day) | Plugin writes `sims.daily_cap`/`hourly_cap` per ramp day | **Enforced by core** (`SimCaps` at pull time) |
| Graduation cap | Ramp day ≥7 → tenant's fleet daily cap (null = uncapped), hourly cleared | **Enforced by core** (same caps) |
| Health score (0–100) | Deterministic from 7 days of `channel_messages` + device heartbeat + carrier-pause state | **Advisory** — display + auto-rest input; never blocks by itself |
| Auto-rest | Score below tenant threshold on 2 consecutive ticks → `sims.is_enabled=false`; auto-wake when the rest expires | **Enforced by core** availability (disabled SIMs are excluded from all serving); the plugin decides and schedules |
| Carrier routing | Plugin-managed `SimRouteRule` rows point each carrier's prefixes at the tenant's healthiest SIM of that carrier | **Enforced by core** (`SimPrefixRoutes` at send time); the prefix→carrier map itself is a **heuristic** (MNP — a ported number keeps its prefix) and is labelled as such in the UI |
| Fleet page numbers | Core `SimCaps::payloadFor` windows + plugin state | Advisory display |

Carrier map: Jazz `+9230,+9232` (incl. Warid), Zong `+9231,+9236`, PTML
`+9233,+9234,+9235` (Ufone + Telenor, amalgamated 1 Jul 2026).

## 4. sim_fleet plugin — battery results

Plugin: slug `sim_fleet`, type `tool`, v1.0.0, `isConfigured()=true` (activates
unconfigured by design). Source: Sendqon repo branch `plugin-sim_fleet`
(`plugins/sim_fleet/`), local tree `~/workspace/sendqon-plugins/sim-fleet/`.

**Functional battery (DEV, in-process + artisan): 21/21 PASS** — enroll →
day-0 caps 30/10 with previous caps snapshotted; backdate −3 days → tick →
100/13; fleet cap 500 + backdate −8 days → graduated 500/hourly-null; unenroll
restores previous caps; health seed (10 delivered + 10 failed) → stored score
matches `HealthScorer` exactly (85); threshold 90 + auto-rest → first low tick
only counts, second tick rests the SIM (`is_enabled=false`, `rest_until`
+12 h); expired rest → SIM woken; carrier routing on → exactly 4 rules
(Jazz×2 → Jazz SIM, Zong×2 → Zong SIM, no PTML SIM exists) + 4 tracked rows;
routing off → all rules deleted; `FleetTickJob::handle()` re-queues the chain
on the database queue driver (jobs 23→24 in the final run; the sync-driver
guard is in the shipped code); `sim-fleet:tick` exits 0.

**UI-surface battery (DEV, real HTTP + forms, per the owner's 2026-11-18
directive): 18/18 PASS** — guest → 302 to login; owner page renders (both SIMs,
warm-up/settings/routing sections, MNP heuristic note); owner enrolls and
unenrolls through the real forms (caps 30/10 applied, then restored); workspace
member sees the page read-only with no action buttons and POST enroll → 403;
admin plugins list shows “SIM Fleet Intelligence” (via the page's own search —
the Inertia list is paginated at 24).

**One real plugin bug found by the UI battery and fixed before production:**
`FleetController::index` called `SimCaps::payloadFor()` statically with a
single SIM; core's method is an instance method taking a Collection and
returning per-SIM windows — the fleet page 500'd on DEV. Fixed plugin-side
(resolve via container, map `used`/`left` per SIM); page renders, batteries
re-run green. (Two further failures during the battery were battery-side, not
plugin: message-seed rows missing core-required `kind`/`source` fields, since
corrected in the battery script; and the DEV member fixture lacked workspace
linkage — repaired with the B6 fixture recipe. A first `rest_until` assertion
also misused Carbon 3's signed diff; the engine value was verified exactly
+12 h.)

## 5. Production state

- Pre-install backup: **2026-11-18T16:12:26Z status=OK push=OK** (nightly
  script run on demand).
- `sim_fleet` **ACTIVE v1.0.0** via PluginManager; fresh-process verification:
  3 tables present, routes registered, `sim-fleet:tick` command present.
- Public checks: `/` 200, `/login` 200, `/sim-fleet` 302 → login (auth-gated);
  all 13 sendqon containers Up.
- Baked into the host build tree at
  `~/sendqon-build/src/app/Plugins/Tools/SimFleet/` — 17 files, md5-verified
  against the shipped source (incl. the fixed controller).
- Zero core edits; no PATCH-REGISTER entry needed; no plan/price/flag changes.

## 6. Owner decisions / owner steps

a. **Production slot registration of our APK — NOT done.** Registration was
   rehearsed on DEV only (twice: pre-fix and final build). Registering in
   production (Admin → Plugins → Android Gateway → Configure → Gateway App)
   makes the own app the fleet's update source — owner's call, owner's moment.
b. **Phone install + pairing + first live SMS — owner's step.** Install the
   archived APK on the phone, pair with a Pair Device code from the panel,
   and the first live SMS completes the device-level proof this environment
   cannot provide (no device/emulator here).
c. **Keystore custody — owner to hold a copy in Vaultwarden.** The release
   keystore lives only in the goal's `hidden_files/release-custody/`. Losing
   it means a new app identity: existing installs could no longer be updated
   in place.

## 7. Push ledger (all ls-remote verified)

| Item | Where | Hash |
|---|---|---|
| Plugin source | Sendqon `plugin-sim_fleet` | `d1c3bf9` |
| App source | Sendqon `app-own-android` | `b72bf5c` |
| This report | Sendqon `rebuild-tree` (`planning/`) + rektrs-workspace `main` (`goals/phone-as-portable-sms-api/files/`) | see repo history (this file) |
