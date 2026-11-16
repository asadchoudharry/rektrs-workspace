# CORE — Campaigns

**Status: core-owned (purchased).**
Sources: Lane 2 (Campaigns, Sending performance), Lane 4 §B, Lane 5 §4/§12.

## Purpose
Bulk sending across channels with audience targeting, personalisation,
scheduling/repeat, pacing, A/B testing and per-recipient accounting.

## Screens / pages (tenant, Lane 4)
- Campaigns list: 28 in demo (channel / status / delivered / failed /
  replies / clicks).
- New Campaign composer — 5 steps: Channel → Audience → Message →
  Schedule → Review & Send. Channels offered: SMS / WABA / Telegram /
  Email / Web Push / WhatsApp. If no SMS source exists the composer
  says so ("No SMS sending source — Pair a Device or Add a Provider")
  with a phone preview.
- Tabs beside Campaigns: Email Templates (30 in demo), WhatsApp Ads
  (24; Attribution Settings — CTWA, see `waba.md`).

## Features + rules / limits
- Message building: merge fields with fallbacks, `{{unsubscribe_link}}`,
  spintax `{Hi|Hey}`, WABA template variables `{{1}}`, AI Write assist
  (AI credits — `ai-providers-credits.md`).
- Scheduling: immediate, scheduled, or **Repeat** (cron-style, e.g.
  `0 9 * * 2#2`), Local Time option, pacing controls, send windows,
  "Do Not Send After" deadline.
- Statuses: Draft / Scheduled / Running / Paused / Completed / Failed /
  Canceled. WABA campaigns **auto-pause on red quality rating**.
- **A/B testing:** 2–5 variants summing to 100%; winners decided by
  `campaigns:decide-ab-winners` (every minute).
- Ads attribution retained 30 days.
- Throughput is bounded by the send pump — see `05-INFRA.md`
  (SMS 45s walk / 1,000-row batches; WhatsApp chunks ≤ 100; watchdog
  emails the owner after 15 min without progress).
- Per-channel queues: `sms-campaigns`, `sms-bulk`, `waba-campaigns`,
  `wa-campaigns`, `push-campaigns`, `email-campaigns`,
  `telegram-campaigns`.
- Standing Rektrs rule (master plan): consumer-SIM campaigns need rate
  limits + opt-out handling — enforced via SIM caps, carrier pause and
  Sending Safety (`privacy-gdpr-security.md`).

## Data (tables)
`campaigns`, `campaign_recipients`, `campaign_variants`,
`campaignables`, `scheduled_messages`, `scheduled`,
`sms_campaign_processed`, `tracked_links`, `tracked_link_codes`,
`link_clicks`.

## API surface
Campaigns start/launch/pause/resume/cancel/stats/failures. Webhooks:
`campaign.started`, `campaign.completed`, `link.clicked` (bot clicks
don't count). Link tracking can use a custom tracking domain
(`custom-domains.md`).

## Plan gates
Per-channel monthly allowances (`sms_monthly`, `waba_monthly`, inbound
monthly); Campaigns feature required by some integrations for bulk
sending (e.g. Perfex).

## Keep / extension notes
- Core-owned. Channel plugins we build join campaigns by registering
  their channel + queue + campaign surface in the channel registry —
  the composer picks them up automatically.
- MCP-created campaigns are always drafts (see
  `../02-PAID-PLUGINS/mcp.md`) — that rule is core-side, keep it.
