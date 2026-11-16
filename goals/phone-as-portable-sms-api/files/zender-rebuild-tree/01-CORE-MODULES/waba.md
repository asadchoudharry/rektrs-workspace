# CORE — WABA (Official WhatsApp Business)

**Status: core-owned (purchased) — a thin plugin shell over core
services. This is our primary WhatsApp route (master plan: WABA
always first).**
Sources: Lane 2 (WABA), Lane 4 §B, Lane 5 §§5.6, 4.

## Purpose
Official WhatsApp Business Platform access via Meta Graph API:
numbers, message templates, template library, 24h-window messaging,
account health, Click-to-WhatsApp (CTWA) ads attribution.

## Connection model
- Meta Graph API **v22.0**. Connect with Business Account ID + Access
  Token (system user token with `whatsapp_business_messaging` +
  `whatsapp_business_management`; a never-expire option exists). An own
  Meta app is optional (config in `.env`: `WABA_APP_ID/SECRET`,
  `WABA_CONFIG_ID`, `WABA_GRAPH_API_VERSION`,
  `WABA_WEBHOOK_VERIFY_TOKEN`; runtime config also in system settings
  via the WABA plugin's config schema).
- Numbers sync up to the plan's Phone Numbers limit (shared with
  WhatsApp QR). Templates sync in the background. Number registration
  uses a 6-digit 2FA PIN.
- Embedded Signup (one-click Meta onboarding) is a free extension
  plugin — `../03-FREE-PLUGINS/whatsapp-embedded-signup.md`.

## Webhook
`/api/webhooks/channels/waba`; verify token + `X-Hub-Signature-256`.
Subscriptions: `messages`, `message_template_status_update`,
`phone_number_quality_update`, `account_review_update`,
`business_capability_update`, `account_update`. Raw events land in
`meta_webhook_events`.

## Templates
- Variables `{{1}}`…; categories Utility / Marketing / Authentication.
- Headers: text/image/video/document; footer; up to 10 buttons
  (≤ 10 quick reply, ≤ 2 URL, 1 phone, 1 copy-code). Auth templates:
  Code Copy or One-Tap Autofill (One-Tap needs Android Package Name +
  App Signing Key Hash), Security Recommendation, Expiry Warning
  Minutes.
- Template Library is admin-reviewed: name ≤ 128 chars, lowercase/
  digits/underscore; auth expiry 1–90 min. **If a submission's outcome
  is uncertain, check via Sync — never retry under a new name.**
- Statuses: Approved / Pending / Rejected / Paused / Disabled.
- Messaging rule: free-form replies only inside the **24h window**;
  outside it, templates only. Red quality rating auto-pauses campaigns.

## Account health & ads
- Health actions: Resubscribe / Check / Reconnect / Disconnect.
  Scheduler: `waba:sync-templates` (6h), `waba:sync-messaging-limits`
  (daily), `waba:fail-stale-queued`.
- CTWA: ad attribution tag on conversations; tables `ctwa_ads`,
  `ctwa_ad_conversations`, `ctwa_attribution_settings`,
  `ctwa_conversion_configs`, `ctwa_conversions`, `ctwa_referrals`;
  tenant UI under Campaigns > WhatsApp Ads.

## Data (tables)
`waba_accounts`, `waba_phone_numbers`, `waba_templates`,
`waba_template_library_entries`, `waba_template_library_variants`,
`waba_received`, `waba_sent`, `waba_scheduled`, `waba_reactions`,
`waba_entry_points`, `waba_onboarding_attempts`,
`waba_coexistence_syncs`, `waba_contact_sync_links`,
`meta_webhook_events`.

## API surface
`messages.waba`, `waba.templates.refresh`; webhooks `waba.message.*`,
`waba.template.approved`.

## Plan gates
WABA switch + `waba_monthly` allowance + Phone Numbers limit.

## Keep / extension notes
- Core-owned; the plugin class only declares config schema — logic is
  in `app/Services/Messaging/Waba/*`. Our extensions attach as
  `waba_provider` plugins (Embedded Signup is the example).
- **WhatsApp voice calls to agent dashboards** require Meta's WhatsApp
  Business Calling API on this WABA channel (master plan Addendum 9) —
  a future own voice module here, Phase 3/5; QR numbers can never do
  it (see `../03-FREE-PLUGINS/whatsapp-qr.md`).
