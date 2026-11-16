# CORE — OTP Verification & Sign-in with WhatsApp

**Status: core-owned (purchased).**
Sources: Lane 2 (Forms/OTP/Sign-in), Lane 4 §B, Lane 5 §4/§6.

## Purpose
A verification-as-a-service surface: workspaces send/check one-time
codes over any channel, plus an inbound "verify by WhatsApp" mode, plus
a full OIDC identity provider "Sign in with WhatsApp" that third-party
apps can federate to.

## Screens / pages (tenant, Lane 4)
- OTP > Usage: 32 starts, 24 approved, 75% conversion (demo; all SMS/US).
- OTP > Settings: Delivery (SMS timeout 60s, Email 120s, Resend 30s,
  Max sends 3, **Retry on Another SIM** on; WhatsApp-unofficial and
  Partner Lines toggles off in demo), Protection, Messages, WhatsApp
  Message sections.
- OTP > Sign-In Apps: registered OIDC client apps.

## Features + rules / limits
- **Delivery channels:** SMS, RCS, Email, Phone Bridge, WhatsApp
  (QR), Partner Lines, WABA, **Voice Call**.
- **Inbound Verify by WhatsApp:** `POST /api/v1/otp/verifications` with
  `{"mode":"inbound"}` (ability `otp.send`); the user scans a QR/SVG
  shown **once** and sends a WhatsApp message; clients poll ≥ 2s;
  approval yields `verified_phone`. Code/link expiry 60–3,600s. Logs
  are masked.
- **Protection:** Allowed Countries list; per-recipient, per-IP and
  per-workspace rate limits; Resend Cooldown; Max Sends; suspicious
  prefixes can be suspended (`otp_prefix_suspensions`).
- **Sign in with WhatsApp = OIDC provider:** issuer
  `{APP_URL}/oauth/whatsapp`, RS256 signing keys derived from APP_KEY,
  rotated every 90 days (`oidc:rotate-keys --force`), retired JWKS kept
  30 days, `APP_PREVIOUS_KEYS` honoured during rotation. Demo note:
  the feature shows disabled until OTP is configured.
- Scheduler: `otp:expire` every minute, `otp:prune` daily.

## Data (tables)
`otp_verifications`, `otp_settings`, `otp_prefix_suspensions`,
`whatsapp_sign_in_apps`, `whatsapp_sign_in_grants`, `oidc_signing_keys`.

## API surface
`otp.verifications.store/show/check/resend/cancel`; routes in
`routes/whatsapp-sign-in.php`. Webhooks: `otp.*` family.

## Plan gates
OTP switch (Starter+ in demo pricing). Verification sends consume the
normal channel allowances/credits.

## Keep / extension notes
- Core-owned. Many integration plugins (WHMCS, Perfex, Odoo, Blesta,
  Flarum) deliver *their* sign-in/verification codes through this
  service — when we build those plugins we call this API, never a
  private code path.
- APP_KEY rotation destroys derived keys' usefulness — coordinate with
  the backup rules in `05-INFRA.md` before any key change.
