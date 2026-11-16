# CORE — SMS Providers (16 built-in drivers + Custom HTTP + SMPP slot)

**Status: core-owned (purchased). SMPP itself is a free plugin +
closed server — see `../03-FREE-PLUGINS/smpp.md` and
`../04-NO-SOURCE/smpp-server.md`.**
Sources: Lane 2 (SMS Providers), Lane 5 §§5.6, 11.

## Purpose
Outbound/inbound SMS through commercial aggregators. Core ships a thin
channel plugin ("SMS Providers") that gates 16 built-in HTTP drivers;
SMPP joins as a 17th driver via the free SMPP plugin.

## The 16 drivers
Twilio, Vonage, Infobip, **Custom HTTP**, Telnyx, Plivo, Routee, Sinch,
Bird, ClickSend, Bandwidth, Clickatell, Africa's Talking, MSG91,
SignalWire, TextMagic.

- Twilio callback: `/api/webhooks/channels/sms/<connection-key>` with
  signature verification; `TRUSTED_PROXIES` matters behind proxies.
- Status callbacks via `?event=status`: Africa's Talking, MSG91,
  TextMagic.
- **Max message parts:** Twilio/Telnyx/Plivo/Infobip/SignalWire/Sinch
  10; Vonage/Clickatell/MSG91/Routee/TextMagic 6; ClickSend 8; Bird 12.
  (SMPP driver: unicode, up to 255 parts, alphanumeric sender, DLR +
  inbound — Lane 5 §11.)

## Custom HTTP driver — our aggregator slot
- GET with query params, or POST/PUT as JSON or Form. Placeholders
  `{{to}}`, `{{body}}`, `{{from}}`. Configurable Message ID Path
  (default `id`), Success Field/Value, inbound field mapping, status
  mapping (e.g. `DELIVRD` → delivered). No signature support — restrict
  by Allowed IPs.
- **This is how a Pakistani masked-SMS aggregator (SendPK-type, PTA
  mask) connects** (master plan masked-SMS addendum): the aggregator's
  API/SMPP goes into a provider slot; each tenant's mask is registered
  under that tenant's own business name.

## Sender IDs & routing
- Sender ID ≤ 32 chars; first one is default; approval flow exists
  (Pending → Approved/Rejected, gated by Sending Safety —
  `privacy-gdpr-security.md`); unapproved sender → 403
  `sender_id_not_approved`.
- **Provider Routes:** longest prefix wins; a campaign must explicitly
  enable "Use Provider Routes". DLT (India) fully supported: PE ID,
  Template ID, `{#var#}`; MSG91 var1/var2 mapping; non-matching
  templates refund. 10DLC brand/campaign is reference-only, with
  Custom HTTP vars `{{tcr_brand_id}}` etc.

## Data (tables)
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`sms_provider_routes`, `sender_ids`, `dlt_templates`, `sent`,
`received`.

## API surface
`sms-providers.index/enable/disable`, `gateways.*` (billing-side
gateway listing is separate), inbound webhook route above.

## Plan gates
SMS channel switch + `sms_monthly` allowance; sends beyond allowance
draw credits (see `plans-billing-credits.md`).

## Keep / extension notes
- Core-owned. A new aggregator = a new `sms_provider` plugin
  implementing `SmsProviderPlugin::smsDrivers()` (the SMPP plugin is
  the working example) or simply a Custom HTTP configuration — prefer
  config over code.
- Flash SMS is NOT possible via Android SIMs; via aggregator/SMPP only
  when the provider supports it (master plan flash addendum); via GSM
  modems it is supported (see `../02-PAID-PLUGINS/gsm-modems.md`).
