# SENDQON — FULL OPERATIONAL SETUP REPORT — 2026-11-16

Lane: audit every feature of the live Zender 5.0.4 install
(https://sendqon.rektrs.com, offbox-1), fix/configure everything safely
possible, end-to-end test with a disposable account, and produce the
exact owner-needed list. Pre-change backup taken first:
`backup.sh` run 09:34 UTC — **status=OK, push=OK** (DB 4,611,112 B,
config 23,735,082 B, storage 42,470,025 B, replica pushed).

Status key: **WORKING** = tested this lane · **CONFIGURED** = set up
and ready, cannot be exercised without owner assets/accounts ·
**NEEDS-OWNER** = one exact owner item · **NEEDS-ACCOUNT** = a
third-party signup/credentials · **ROADMAP** = paid plugin not bought;
own-build phase per the master plan / rebuild tree.

## 1. Feature inventory

| Feature | Status | Evidence / note |
|---|---|---|
| Messenger shared inbox | CONFIGURED | Engine + tables live; `messenger` feature on Pro/Enterprise; 0 conversations — needs a connected channel to receive real chats |
| Campaigns | CONFIGURED | Campaign engine + recipient tables live; sending needs a channel with a number/device (no real send attempted, per rules) |
| Flows / Drips | CONFIGURED | Flow builder tables live; feature on Pro+ (limit 10 / unlimited); Free/Starter off in vendor seed |
| Contacts (import/export/segments) | WORKING | Full REST surface (CRUD, bulk, imports, exports, fields, segments) routed; authenticated `GET /api/v1/contacts` → 200 |
| OTP service | ROADMAP | `otp` flag is **false in all four seeded plans** and `otp_settings` is empty — OTP is a premium-gated surface; enabling is a plan decision (see §5) and delivery needs a live SMS/WhatsApp channel |
| Android Gateway channel | CONFIGURED + NEEDS-OWNER | Plugin active; pairing/heartbeat/USSD scheduler jobs running; 0 devices paired — needs the portal phone-app bundle + Firebase (see §4.4) |
| WhatsApp QR channel | CONFIGURED | Plugin active; companion server `Primary WhatsApp` **healthy** (licence verified); 0 numbers linked — linking is the owner's QR scan with his number |
| WABA (official WhatsApp) | CONFIGURED + NEEDS-ACCOUNT | WABA + Embedded Signup plugins active; Graph API v22.0; 0 accounts — needs the owner's Meta app / WABA / registered number |
| SMPP channel | CONFIGURED | Plugin active; companion server `smpp-1` **healthy**, capacity 500; 0 gateway binds — a bind needs an SMPP provider account |
| Built-in SMS provider drivers (16) | CONFIGURED + NEEDS-ACCOUNT | All drivers in code (incl. Custom HTTP); 0 provider instances configured — each needs that provider's account credentials |
| Telegram channel | ROADMAP | Paid plugin not bought; `telegram` false in all plans; Phase 4 own-build |
| Website Chat | ROADMAP | Widget flags exist in plans (Starter+); the chat-channel equivalent is a paid plugin — Phase 4 own-build |
| Email channel | ROADMAP | Channel equivalent is a paid plugin — Phase 4 own-build. (System/transactional email is separate and WORKING, below) |
| Plans, credits & trial | WORKING | 4 plans active (Free/Starter/Pro/Enterprise, vendor USD seed — untouched); signup→plan assignment proven (§3); credit ledger tables live; trial-abuse caps set: 3 days / 50 messages; sender-ID approval ON |
| Billing — Bank Transfer | NEEDS-OWNER | Plugin installed, **inactive**: vendor code refuses activation until real bank details are configured (§4.1) |
| Billing — PayPal | NEEDS-OWNER | **Installed this lane** (was: not installed), inactive, config empty — needs PayPal credentials to configure + activate (§4.2). No payment gateway is active yet, so paid checkout cannot complete; free signup works |
| Support tickets | CONFIGURED | `support_enabled=1`; feature Starter+; limits set (5 open/user, attachments); 0 tickets |
| Referral program | OFF — owner decision | Tables live; program not enabled (§5) |
| Partner Network | OFF — owner decision | Tables live; not enabled (§5) |
| REST API + API keys | WORKING | Proven end-to-end (§3): Sanctum token issue, `/api/v1/me` 200, contacts 200; **plan-gated** — Free plan excludes `api` (403 `feature_not_in_plan` proven); public API docs flag ON |
| Webhooks | WORKING | Full CRUD via API proven: create 201 + HMAC secret issued, list 200, events registry 200 (51 subscribable events), delete 204; deliveries table live |
| MCP surface | ROADMAP | Core ships `/mcp` routes + OAuth discovery scaffolding, but the MCP **plugin is a paid plugin — not bundled, not bought** — endpoints correctly 404 until it exists; `mcp` false in all plans. Phase 4 own-build priority #1 |
| Mobile App settings + push | CONFIGURED + NEEDS-OWNER | Mobile enabled by default; **store URLs are NOT stored values** (keys absent in DB — the settings UI shows placeholders only; nothing fake is stored, nothing to blank); push **not configured** — needs Firebase service-account JSON (§4.4). Tenant mobile app itself = Phase 5 own-build |
| Landing page / branding | WORKING | `/`, `/login`, `/register` all 200 with Sendqon name/tagline/description and wordmark logos (logo URL 200 image/png); no vendor branding found. Favicon is still the shipped default file — replaced by the white-label kit (§4.7) |
| Email templates / system mail | WORKING | Code mailables themed via Branding/EmailTheme; proven by received test mail earlier + three live sends this lane (§3) over Hostinger SMTP; SPF/DKIM/DMARC live |
| Scheduler / queue / cron | WORKING | Scheduler container runs per-minute jobs (USSD, SIM carrier, network) — all DONE in logs; queue worker processing; failed_jobs cleaned 1 → 0 (§2) |
| Storage / uploads | WORKING | `public/storage` symlink present in the running container; uploaded logos served 200; `stored_files` infra live |
| Maintenance mode | OFF | Site fully live (200s) |
| Sign-up verification options | CONFIGURED | Current method: **none** (registration open, auto-approved — proven §3). Email-code and SMS-code methods exist in code; SMS method needs a live SMS channel first |
| reCAPTCHA | OFF + NEEDS-ACCOUNT | Option present (`recaptcha_enabled=0`); enabling needs Google reCAPTCHA keys + owner decision (§5) |
| Social login (Google/Facebook/GitHub) | NEEDS-ACCOUNT | All client IDs empty; needs OAuth apps in each provider |
| AI integrations (BYOK) | NEEDS-ACCOUNT | `ai_providers` empty; per-plan BYOK surface ready; needs the owner's own provider keys |
| USSD | CONFIGURED | Scripts/schedules tables + scheduler jobs live; needs a paired Android device |
| Voice / Telephony / PBX, GSM modems, Phone Bridge, RCS | ROADMAP | Phase 5 per master-plan Addenda 1–7; no companion telephony server deployed |
| Knowledge base | CONFIGURED | Tables + plan limits present |
| Backups & monitoring | WORKING | Nightly backup + micro-2 replica (fresh run this lane, status=OK push=OK); Kuma monitor "Sendqon" UP (earlier lane) |
| Error reporting (Sentry) | OFF — deliberate | Vendor phone-home stays OFF |

## 2. Everything changed this lane

1. **Backup** — fresh `backup.sh` run before any change (above).
2. **PayPal plugin: not installed → installed.** Via the app's own
   `PluginManager::install('paypal')` (bundled core plugin, v1.0.0).
   Resulting row: `status=inactive`, `is_active=0`, config empty —
   **not activated** (same posture as Bank Transfer; activation needs
   the owner's PayPal credentials). Known vendor side effect, same as
   the Bank Transfer install: `install()` fires `queue:restart`; the
   queue container restarted gracefully under Docker policy and
   resumed processing.
3. **Failed jobs: 1 → 0.** The single failed job was a stale
   install-era artifact: `RecordQueueHeartbeatJob` at 06:52 UTC
   failing on `system_heartbeats` table-not-found (it ran before
   migrations finished). The same job has succeeded every few minutes
   since. Cleared with the app's own `php artisan queue:flush`.
4. **Nothing else was altered.** No settings values changed, no plan
   prices/features/currency touched, nothing activated. Placeholder
   audit: mobile store links are UI placeholders, **not stored data**
   (keys absent from `system_settings`); contact phone/social fields
   are all empty; social-login client IDs are NULL — no fake values
   exist anywhere in stored config.

## 3. End-to-end test evidence (disposable account)

Test account `test-ops@rektrs.com` ("Ops Test", country PK), created
through the **real public registration path**, fully deleted after.

- `POST /register` → 302 → `/overview`; authenticated
  `GET /overview` → **200**.
- Account state on creation: role=user, status=active,
  approval=approved (auto-approve), **Free plan auto-assigned**,
  subscription row active ($0), credits_balance 0 (Free grants no
  credits; its limits are 500 contacts / 100 SMS per month).
- Mail pipeline fired by registration: `SubscriptionActivatedMail`
  DONE (2 s) and `AdminUserRegisteredMail` DONE — both over the live
  SMTP. (The admin also received the in-app registered/deleted
  notifications — the test is honestly visible in his inbox.)
- **API key + calls:** Sanctum token created for the test user.
  On the Free plan: `GET /api/v1/me` → **403 `feature_not_in_plan`
  (api)** — plan gating proven. After a test-only assignment of the
  Pro plan to the disposable user: `/api/v1/me` → **200** (profile +
  workspace + plan payload), `/api/v1/contacts` → **200**,
  `/api/v1/webhooks/events` → **200**.
- **Webhooks:** `POST /api/v1/webhooks` (events
  `wa.message.received`, `contact.created`) → **201**, webhook id 1,
  HMAC secret issued; list → 200 showing the webhook healthy;
  `DELETE` → **204**, list empty.
- **Password-reset email:** `POST /forgot-password` → 302;
  `password_reset_tokens` row created; queue job
  `QueuedResetPassword` **DONE** (SMTP accepted the reset mail).
- **Cleanup verified:** webhook deleted via API; test user,
  subscription, all API tokens, consents, sessions, idempotency rows,
  the captured signup contact and the reset token deleted. Baseline
  restored and re-counted: **users=1**, contacts=0, subscriptions=0,
  webhooks=0, tokens=0, consents=0, idempotency=0, failed_jobs=0.
  (The one remaining onboarding row belongs to the admin himself,
  created 07:20 UTC during install — untouched.)
- **Final health:** all 7 containers Up; both service servers
  `healthy`; site / login / register all 200.

## 4. OWNER-NEEDED list (exact items)

1. **Bank details for Bank Transfer** — Admin → Plugins → Bank
   Transfer → Configure: bank name, account title, account number,
   then Activate. *Unlocks: manual bank-transfer checkout for paid
   plans (the only PKR-friendly gateway available today).*
2. **PayPal Business account + API credentials** — Admin → Plugins →
   PayPal → Configure (client ID + secret from his PayPal business
   account), then Activate. *Unlocks: card/PayPal checkout.*
3. **WhatsApp number QR-link** — Workspace → Channels → WhatsApp →
   add number and scan the QR with the phone that owns the number.
   *Unlocks: WhatsApp QR sending/receiving (server already healthy).*
4. **Android Gateway bundle + Firebase project** — buyer portal
   (dashboard.titansys.dev) → Android Gateway plugin → download the
   "format 2" phone-app bundle and install it on the SIM phone; and
   create a Firebase project, uploading its service-account JSON at
   Admin → Settings → Mobile. *Unlocks: Android device pairing, the
   first real test SMS, and mobile push notifications.*
5. **Meta assets for WABA** — his Meta developer account: create the
   Meta app + WhatsApp Business account and register a phone number;
   connect via Admin → Channels → WABA (or Embedded Signup).
   *Unlocks: the official WhatsApp API channel.*
6. **An SMS provider / SMPP account (when he wants aggregator SMS)**
   — sign up with any supported provider and enter its credentials at
   Admin → Channels → SMS Providers (or an SMPP bind on `smpp-1`).
   *Unlocks: aggregator SMS — also the future masked-SMS route.*
7. **White-label kit** — supply the real logo + favicon files.
   *Replaces the temporary Sendqon wordmark and the shipped default
   favicon everywhere, including emails.*
8. **APP_KEY custody** — copy the `APP_KEY` from
   `/var/serverkit/apps/sendqon/.env` (offbox-1) into Vaultwarden.
   *Protects every encrypted setting/secret if the server is lost.*

## 5. OWNER DECISIONS (business switches — nothing changed)

1. **PKR pricing** for Free/Starter/Pro/Enterprise + billing currency
   (still vendor USD seed: $0/$19/$49/$199). Muse's PKR proposal is
   owed; prices stay untouched until he approves.
2. **Referral program** — currently OFF. Turn on?
3. **Partner Network** — currently OFF. Turn on?
4. **OTP in plans** — currently excluded from every plan. Include it
   (and in which plans)?
5. **First live payment gateway** — Bank Transfer (manual, PKR) or
   PayPal (automatic, USD) — after §4.1/§4.2 details exist.
6. **Abuse controls** — reCAPTCHA and/or social login: off today;
   both need his provider accounts (§1).
7. **Sign-up verification** — none today (open signup, auto-approved,
   trial caps on). Switch to email-code or SMS-code verification?
8. **Free-plan API access** — the vendor seed excludes API/webhooks
   from Free (proven in §3). Keep API as a paid-plan feature?

---
*No vendor code was edited; no real SMS/WhatsApp message was sent; no
plan, price or currency was changed; Error Reporting remains OFF.*
