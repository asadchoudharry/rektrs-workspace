# ZENDER 5 REBUILD TREE — OVERVIEW

This tree is the development blueprint for Rektrs' own WhatsApp + SMS SaaS
("Sendqon"), built on the purchased Zender 5.0.4 core. Every item we will
ever build — core understanding, own plugins, clean-room replacements for
closed components — has exactly one file here. Nothing is built from
memory; every file traces to the Lane 2–6 audit reports in
`../zender-audit-lanes/`.

Master plan: `../ZENDER-CORE-PLUS-OWN-PLUGINS-PLAN-2026-11-15.md`
(phases + Addenda 1–10). Build order: `08-REBUILD-ROADMAP.md`.
Differentiation layer (the six USPs): `09-USP-ADDENDUM-10.md`.

## What the system is

A multi-tenant SaaS for SMS + WhatsApp messaging: shared team inbox
(Messenger), campaigns, chat flows/drips, contacts, OTP verification,
SaaS plans/credits/billing, a REST API + webhooks + MCP surface, and a
plugin system. Tenants (workspaces) send through channels: SMS providers
(16 built-in HTTP drivers + SMPP), Android phones with SIMs, official
WhatsApp Business (WABA), unofficial WhatsApp (QR linked-device), and —
via paid-plugin equivalents we will build ourselves — Telegram, Email,
Website Chat, Web Push, Phone Bridge and GSM Modems.

## Architecture (text diagram)

```
                        ┌─────────────────────────────────────────────┐
   Tenants / agents ───▶│  ZENDER CORE (Laravel 13 + React/Inertia)   │
   Admins               │  web UI · REST API v1 · webhooks · MCP      │
   Public visitors ────▶│  Messenger inbox · campaigns · flows        │
                        │  plans/credits/billing · plugin engine      │
                        └──────┬───────────────┬──────────────┬───────┘
                               │ MySQL         │ Reverb (WS)  │ Queue
                               │ (316 tables)  │ or Pusher    │ workers
                               ▼               ▼              ▼
        ┌──────────────────────────────────────────────────────────────┐
        │              5 COMPANION SERVER FAMILIES (Go, closed)        │
        │  WhatsApp QR server · SMPP server · Telephony server         │
        │  Telegram server · Email server                              │
        │  (registered as Service Servers; load-balanced by core)      │
        └──────────────────────────────────────────────────────────────┘
                               ▲
        ┌──────────────────────┴───────────────────────────────────────┐
        │  DEVICES & EXTERNAL WORLD                                    │
        │  Android gateway phones (SIM) · ESP32 Bridge Adapters        │
        │  GSM modems (SIM7600G-H) · Meta Graph API (WABA)             │
        │  16 SMS provider APIs · Stripe/PayPal/… · Firebase FCM       │
        └──────────────────────────────────────────────────────────────┘

   PLUGINS (PHP, in app/Plugins/<Type>/<Name>/ + plugin.json) attach to
   core through contracts — 9 plugin types (see 05-INFRA / Lane 5 §5).
```

Key architectural facts (Lane 5):
- Core "plugins" shipped by the vendor (PayPal, Bank Transfer, WABA,
  SMS Providers) are mostly manifest + config-schema shells; heavy logic
  lives in core services (`app/Services/`, 1,178 PHP files).
- Live traffic to companion servers runs over **Reverb private channels**
  (Pusher protocol); HTTP is used only at lifecycle/bootstrap/event
  boundaries under `api/v1/internal/*`.
- A channel needing a companion server program requires core-side
  registration in `app/Services/Channels/ChannelPlugins.php` — this is
  the one hard limit of the plugin sandbox.

## Exact tech stack (from lock files — Lane 5 §2)

| Layer | Version / choice |
|---|---|
| PHP | ^8.4 (installer refuses < 8.4.1) |
| Laravel | **13.37.0** |
| Inertia (server) | inertia-laravel 3.0.6 |
| React | ^19.0.0, @inertiajs/react ^3.0.0 |
| Vite / TypeScript / Tailwind | Vite ^8.1, TS ^5.0.2, Tailwind ^4.3.2 |
| Realtime | laravel/reverb 1.10.0 (self-hosted) or Pusher cloud |
| Auth | Sanctum 4.3.1 (tenant API), Passport 13.7.6 (OAuth/MCP), Socialite, pragmarx/google2fa (TOTP) |
| Firebase | kreait/firebase-php 8.2.0 (FCM wake-up pushes to Android gateways) |
| MCP | laravel/mcp 1.0.1 (core plumbing under the paid MCP surface) |
| Payments SDKs in core | stripe-php 20.0.0, twilio/sdk 8.11.4, razorpay ^2.9, yookassa-sdk ^3.13 |
| Database | MySQL 8 / MariaDB (InnoDB); SQLite trial only |
| Queues | Laravel queues (21+ named queues), cron-driven workers supported |
| App size | 26,829 files / 480 MB incl. vendor/; 510 migrations; 316 core tables |

## Licence position

- Purchased: Zender 5 **Regular** licence (held now).
- The owner has **applied to the vendor for a custom licence** to obtain
  proprietary rights over the system and our own developments on it.
  Until that lands, the Regular terms govern: end users may not be
  charged on a Regular licence — commercial SaaS launch waits for the
  custom licence (or Extended).
- We buy **no paid plugins**. Every paid plugin in `02-PAID-PLUGINS/` is
  a build spec for our own implementation. Free plugins are
  reference/interim only (`03-FREE-PLUGINS/`).
- Vendor compiled components are **never** decompiled or copied; closed
  components are replaced clean-room against the PHP-visible contract
  (`04-NO-SOURCE/`).

## Phone-home facts (Lane 5 §9 — exactly 4 points)

1. **Vendor error reporting (the only direct vendor phone-home in PHP):**
   `https://sentry.titansys.dev` ingest endpoint. OFF by default; sends
   only when an admin enables `sentry_enabled` AND a purchase code is
   stored. Payload is scrubbed (secrets/PII stripped) and the purchase
   code is prepended at send time. Companion apps/servers relay into the
   same pipeline and read the same on/off switch. → Keep OFF; the patch
   register records this decision.
2. **WhatsApp server licence gate:** the closed WA binary refuses to
   start while its `config.json` `purchase_code` is the placeholder
   `REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE`. Online vs offline
   validation: UNVERIFIED.
3. **SMPP server licence gate:** same pattern —
   `REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE`. Mechanism UNVERIFIED.
4. **Telephony server licence gate:** same pattern —
   `REPLACE_ME_WITH_GSM_MODEMS_OR_PHONE_BRIDGE_LICENSE_CODE`. Mechanism
   UNVERIFIED.

There is **no** licence activation or purchase-code validation gating
the Laravel core app itself (Lane 5 §9-F3), and no vendor update feed is
polled in core (updates are manual — see `05-INFRA.md`).

## Master index

Top level:
- `00-OVERVIEW.md` — this file
- `05-INFRA.md` — servers, services, cron/queue, throughput, backups, upgrade discipline
- `06-DATABASE-MAP.md` — 316 core tables grouped, tenancy model, plugin table pattern
- `07-API-MAP.md` — REST API v1, auth/permissions, webhooks catalogue, MCP surface
- `08-REBUILD-ROADMAP.md` — phases, master checklist of every build item, open UNVERIFIED items

`01-CORE-MODULES/` (22 files — the purchased core, documented so our
plugins integrate correctly):
auth-accounts · workspaces-teams-roles · contacts-forms ·
messenger-inbox · campaigns · flows-drips · otp-verification ·
channels-hub · sms-providers · waba · plans-billing-credits ·
payment-links · market · ai-providers-credits ·
referral-partner-network · landing-builder-tours · settings-admin ·
privacy-gdpr-security · localization · custom-domains · files-storage ·
cron-logs-status

`02-PAID-PLUGINS/` (34 files — vendor's paid catalogue as OUR build specs):
stripe · paystack · razorpay · crypto-com-pay · yookassa · freemius ·
admin-api · appointment-booking · auto-update · ai-agents ·
ai-flow-builder · knowledge-base · telegram · telegram-store ·
website-chat · web-push · email · shopify · odoo · google-sheets ·
browser-extension · blesta · flarum · osticket · wordpress · whmcs ·
perfex-crm · gohighlevel · monday-com · phone-bridge · gsm-modems ·
mcp · rcs · mobile-app

`03-FREE-PLUGINS/` (6 files):
android-gateway · whatsapp-qr · smpp · whatsapp-embedded-signup ·
legacy-api-wrapper · legacy-importer

`04-NO-SOURCE/` (8 files — closed components + clean-room replacements):
whatsapp-qr-server · smpp-server · telephony-server · telegram-server ·
email-server · android-gateway-apk · mobile-app ·
browser-extension-branded-builds
