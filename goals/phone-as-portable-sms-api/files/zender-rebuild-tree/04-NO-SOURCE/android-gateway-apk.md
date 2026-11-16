# NO-SOURCE — Android Gateway APK + Companion Apps

Full evidence: Lane 6 §6 + Lane 5 §7. The app **source** is not
included with Zender — each site gets a branded build from the
vendor's app builder (name, icon, logo, colours, package name, site
address). **The server-side protocol is entirely core PHP and in our
possession** — this is the best-prepared replacement in the tree.

## What it is
The phone app that turns an Android phone's SIMs into Zender SMS
lines. The free Android Gateway plugin declares **4 app slots**:
`android_gateway` (the gateway app), `android_rcs` (RCS Companion),
`android_receiver` (Receiver app), `android_ussd` (USSD Companion),
each with version-compat patterns. The gateway app's package id in
core code: `dev.titansys.smsgateway`.

## Interface evidence (server side — Lane 5 §7)
Contract documented in-repo: `docs/api/android-v1.yaml` (referenced
from route comments). Base `api/v1/internal/android`, middleware
`channel:android`.

- **Pairing:** `POST auth/pair` with a UI-created pairing code; flow
  broadcast on Reverb `user.{id}.device-pairings.{pairingId}`; app
  version gate `RequireCompatibleGatewayApp` (≥
  `GatewayAppCompat::MIN_APP_VERSION`); codes short-lived, cleaned daily.
- **Auth:** `Authorization: Bearer <token>` + `X-Device-Id`. Server
  stores only the token's **SHA-256 hash** (`devices.hash`); the
  bearer must match the device whose `android_id` equals the header.
  Branded builds also get `POST auth/login` + `auth/login/two-factor`.
- **Device sync:** `GET device`, `PUT device/fcm-token`,
  `PUT device/sims`, `PUT device/pause`, `POST device/diagnostics`.
- **Send flow (push-wake + pull):** outbound rows queue as pending;
  server sends an **FCM data push** (`action=message_request`, plus
  `campaign_id` for campaigns) to `devices.firebase_token` — the
  Firebase project is the **operator's own** (plugin config
  `firebase_credentials`, encrypted). Phone pulls
  `GET messages/pending`, sends via SIM, reports via `PATCH messages`
  / `PATCH messages/{id}`. Inbound: `POST messages/inbound`.
- **Polling fallback:** the pending endpoint is exempt from channel
  gating ("Control-only polling keeps phones paired") — no FCM, still
  alive. Server moves pending work off offline devices every minute;
  detects missing delivery reports hourly.
- **USSD relay:** `GET ussd/pending`, `POST ussd/{id}/start`,
  `POST ussd/{id}/menu`, `PATCH ussd/{id}`; wake via FCM + Reverb
  (`user.{id}.ussd.{pullId}`, plus a `.masked` variant); scheduled
  USSD via `ussd:run-schedules` (minute).
- **RCS:** `GET rcs/selectors` capability data; core tracks
  `rcs_enabled`, `rcs_sms_fallback`, `rcs_failure_streak`, `rcs_report`
  per device (see `../02-PAID-PLUGINS/rcs.md`).
- **Updates:** `GET app/update`, `GET app/download` (signed URL);
  companion downloads also signed (`ussd-companion/app`,
  `receiver/app`, `rcs/app`); server can push update wakes
  (`android:app-updates`, 15 min).
- **Device data reported:** android_id, model, manufacturer, Android
  + SDK versions, app version/package/signer, firebase token, battery
  level, charging, signal strength, online/last-seen, SIM list (slot,
  number, carrier — `sims` + route rules + caps), receive_sms_enabled,
  battery-optimization exemption, background restriction, standby
  bucket, installed packages, diagnostics/heartbeats.
- **Plugin config driving behaviour:** `carrier_pause_hours`
  (default 6), `rcs_pacing_seconds` (default 6).

## UNVERIFIED
- The apps' internal UI/UX and exact permission set (screenshots exist
  in the plugin's Documentation folder; code does not).
- **MMS support:** Partner Network rates mention MMS, but Lane 2
  notes "abhi MMS nahi" — MMS via the gateway app is UNVERIFIED /
  probably absent.
- Whether the app uses any vendor relay beyond FCM (protocol evidence
  says no — FCM runs on the operator's own Firebase project).
- The exact split of duties between the gateway app and the Receiver
  app (separate slots; documentation does not fully clarify).

## Clean-room Android app spec (Phase 2 — the plan's most valuable build)
One app, modular (we are not bound to the vendor's 4-slot split):
1. **Pairing & auth:** pairing-code flow (QR scan of the same code),
   token in Android Keystore, `Bearer` + `X-Device-Id` on every call,
   re-pair/rotation flow.
2. **SMS send:** wake on FCM data push → pull `messages/pending` →
   send via `SmsManager` with the server-assigned SIM subscription →
   per-message status back via `PATCH` (sent/delivered/failed +
   reason). Exponential-backoff polling when FCM fails. Honour
   server random delay (`random_send_min/max_delay`) and carrier
   pause (`carrier_pause_hours`).
3. **SMS receive:** inbound listener → `POST messages/inbound`;
   offline queue, flush on reconnect.
4. **SIM sync & heartbeat:** `PUT device/sims`; periodic heartbeat
   with battery/charging/signal/app-version/battery-optimization
   state (drives core's offline alerts + Channels Hub warnings);
   `POST device/diagnostics` on demand.
5. **USSD module:** pull/wake → `TelephonyManager.sendUssdRequest` →
   `start`/`menu`/`PATCH` relay. (Android's USSD API is uneven across
   carriers/devices — pilot test mandatory.)
6. **RCS module (optional, last):** Google Messages as default SMS
   app + the documented Accessibility/Notification-Access approach;
   capability via `rcs/selectors`. Most fragile part — never a core
   promise.
7. **Self-update:** `app/update` check + signed download (these apps
   do not go to the Play Store — same as the vendor's model).
8. **Branding:** our own app — site URL set at pairing; one APK can
   serve all sites (the vendor's per-site build compulsion is not ours).
9. **Error reports:** `POST error-reports` into core's pipeline.

Base options (master plan): **clean-room Kotlin app** on this
contract (first choice), or **SMS Gate (Apache 2.0) fork + adapter** —
SMS Gate already has our live proof from 2026-11-13; the adapter maps
its engine onto the endpoints/auth/FCM actions above.

## Difficulty / risk
**Medium — and the best-prepared item in the tree.** Protocol 100% in
hand. Real work: Android background limits (battery optimisation, OEM
killers — Xiaomi/Redmi especially), multi-SIM quirks, carrier
throttling. Standing warning: bulk campaigns on consumer SIMs risk
carrier blocks — rate limits/delays are mandatory in the app.
