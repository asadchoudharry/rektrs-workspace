# Sendqon — Step-1 Finishing Lane Report (2026-11-26)

Server-side completion of the Firebase + AI configuration saved earlier the same day through the owner's Chrome session (Android Gateway form saved; Gemini provider row created). Three jobs: gateway Firebase credentials copy, Gemini provider row correction, end-to-end verification with a real AI test call. **No credential value was printed, logged, or written to any file at any point — presence/length/status only.**

## Backup first
Fresh `backup.sh` run before any write: **status=OK, push=OK** (db 10,716,352 B · config 29,287,708 B · storage 103,258,492 B); all three 2026-11-26 artifacts `gzip -t` verified.

## Job 1 — Gateway Firebase credentials copy (DB-internal) ✅
Access path followed exactly as core uses it: values live in `system_settings`, read/written via `App\Models\SystemSetting::get()/set()` with type `encrypted_json` (gateway group `integrations`, per `AndroidPlugin.php`; mobile group `mobile_credentials`, per `MobileSettings.php`).

| Key | Before | After |
|---|---|---|
| `mobile_firebase_credentials` (source) | SET — type `encrypted_json`, group `mobile_credentials`, stored len 4384 | unchanged (byte-identical after the copy) |
| `firebase_credentials` (gateway) | ABSENT | SET — type `encrypted_json`, group `integrations`, stored len 4384 |
| `firebase_android_config` | SET (len 180, saved via panel form) | SET, untouched by this lane |

- The mobile value was read through `SystemSetting::get()` and written as `firebase_credentials` through `SystemSetting::set()` **in the same process**; the decrypted payloads compared equal in-process (project_id `sendqon`, private key present). The raw value never left the process.
- **Construction proof (fresh process, so the boot path ran with the new value):** `config('firebase.projects.app.credentials')` = SET (project `sendqon`); Kreait `Factory::withServiceAccount(...)->createMessaging()` constructed OK (dry construction only — no push sent).
- **Cross-check proof:** `FirebaseAndroidConfig::status()` → `configured: true, project_id: sendqon, matches_service_account: true`; `clientConfig()` returned non-null (it only does so when the android config's project matches the service account's project) — sender `746192050120`, API key present.

## Job 2 — Gemini provider row correction ✅ (one evidence-forced deviation, below)
Row: id 1, "Gemini (AI Studio)", type `openai`, status `active` — via the Eloquent model so casts/encryption behaved.

| Field | Before | After |
|---|---|---|
| `config.base_url` | (unset → effective `https://api.openai.com/v1`) | `https://generativelanguage.googleapis.com/v1beta/openai` |
| `config.default_model` | `gpt-6.1-sol` | `gemini-3.5-flash` (see deviation note) |
| `config.feature_models` | `[]` | `[]` (nothing to remap) |
| `available_models` | `["gpt-6.1-sol","gpt-6-astra","gpt-6-luna"]` | `["gemini-3.5-flash"]` |
| API key (`credentials`) | SET, len 53 | **untouched** — identical value compared in-process before/after |
| id / name / type / status | 1 / Gemini (AI Studio) / openai / active | identical |

**Deviation — the briefed model `gemini-2.0-flash` no longer exists.** The first verification call returned HTTP 404 with Google's own message: *"This model models/gemini-2.0-flash is no longer available. Please update your code to use models/gemini-3.8-flash…"* (`gemini-2.5-flash` is likewise closed to new users.) Google's recommended successor `gemini-3.8-flash` was then tried and returned **503 "high demand… temporary"** on repeated attempts during the lane. `gemini-3.5-flash` — present in the account's live model catalogue (`GET /models` → 200) — answered **200** immediately, so the model surface was set to it rather than shipping a configuration pointed at a retired or overloaded model. Switching the row to `gemini-3.8-flash` later is a one-line change once its demand settles.

## Job 3 — Verification ✅
- **AI Agents gate:** `AiGateway::resolve()` for the master-admin user (id 1) returned **non-null** → provider "Gemini (AI Studio)", isByok = no, effective baseUrl `https://generativelanguage.googleapis.com/v1beta/openai`, key present (len 53), default model `gemini-3.5-flash`, allowedModels `["gemini-3.5-flash"]`.
- **Real test call (live):** direct HTTPS POST from inside the container to the row's own endpoint + key (key read in-process, never printed), model `gemini-3.5-flash`, prompt *"Reply with the single word: ready"* → **HTTP 200, reply `ready`, finish_reason `stop`, 116 total tokens.** (An earlier probe with max_tokens 10 returned 200 with the budget spent on internal reasoning and empty visible content; the 200-token probe above is the clean proof.)
- **Push side:** `firebase_android_config` SET + gateway `firebase_credentials` SET + project match (Job 1 proofs above).
- **Site:** https://sendqon.rektrs.com → HTTP 200. **Logs:** 0 ERROR lines in the lane window (07:20–07:59 UTC).

## Honest limits — what is still unproven
- **No real FCM push has reached the phone yet.** `devices.firebase_token` is still empty: the gateway app must pick up the new Firebase config on its next sync cycle and register a token before any push can be delivered. That is an app/owner-side cycle, not a server gap — server-side Firebase is now fully configured and construction-proven.
- The AI proof is a direct endpoint call using the provider row's own key/URL/model (the gateway's resolve path was separately proven non-null with the same effective values). A full in-panel AI Agents conversation was not driven; the billing/reservation path in `AiGateway::complete()` was deliberately not exercised for a smoke test.
- **Pre-existing issue observed (not this lane's doing, not fixed here):** today's log carries a large number of ERROR lines from the morning's inbound-SMS ingestion (messages whose `occurred_at` arrives as the epoch `1970-01-01 00:00:00` are rejected by MySQL strict mode), clustered around 07:14 UTC during the sign-in SMS flood — the affected inbox messages were not stored. Worth its own lane.

## Net state after this lane
Step 1 of the approved sequence is **complete on the server side**: push configuration is fully in place (config + credentials + project match), and the AI provider is live with a proven real call — the AI Agents surface is unblocked for the master admin. Remaining owner-side item: the gateway app's next sync registering an FCM token, after which a real push test can close the push story end to end.
