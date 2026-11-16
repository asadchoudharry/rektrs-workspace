# CORE — Channels Hub (connections, devices, SIMs, USSD)

**Status: core-owned (purchased).**
Sources: Lane 2 (Channels Hub), Lane 4 §B, Lane 5 §§5.4, 7, 12.

## Purpose
The single place every sending/receiving path is connected and
monitored: SMS providers, Android devices/SIMs, WABA numbers, and (via
plugins) WhatsApp QR, Telegram, Email, Website Widget, Web Push, Phone
Bridge, GSM Modems, RCS.

## Screens / pages (tenant, Lane 4)
- Channels list: 7 connections in demo — WABA (Inactive), WhatsApp QR
  (Disabled, "Failed to sync — device disconnected"), Phone Bridge
  (Disabled), Website Widget ×2 (one Live), Email mailbox (Disabled,
  "Ramping up…"), Telegram Bot (Disabled).
- **Connect Channel wizard, 4 steps:** Channel → Select Provider →
  Configure → Review. Channel types offered: WhatsApp / WABA / SMS /
  RCS, Email, Telegram, Website Widget, Phone Bridge, GSM Modems,
  Web Push, WABA Embedded Signup.
- Card actions: Rename, Disable, Sender IDs, Webhook URL, Provider
  Routes, Test, Edit, **Get Adapter, Get Modem**, Remove.
- Message Logs (10,000+ rows in demo; Time/Direction/Contact/
  Connection/Message/Status/**SIM**/Source; Export CSV) and Call Logs
  live beside the hub.

## Health warnings (built-in)
- SMS: provider login failed, or ≥ 5 failures today with ≥ 50% of
  today's sends failed.
- Android: paused / offline / no SIM / low battery / update available.
- WABA: token expiring < 7 days, webhook unsubscribed, low quality.
- Channels outside the current plan are dimmed ("Not in Plan").

## Routing rules
Explicit SIM first → provider prefix routes → default route. Replies
prefer the last-used Sender ID. Per-SIM caps and carrier pause
(`carrier_pause_hours`, default 6) protect consumer SIMs; pending work
is moved off offline devices every minute
(`sms:move-pending-from-offline`); missing delivery reports are
detected hourly.

## Devices & SIMs (server side — Lane 5 §7)
Pairing by code from the UI (Reverb broadcast of the pairing flow);
session auth = Bearer token (only its SHA-256 hash stored) +
`X-Device-Id`. Device record tracks model, Android version, app
version, battery, charging, signal, SIM list, RCS state, diagnostics.
Full protocol: `04-NO-SOURCE/android-gateway-apk.md` +
`03-FREE-PLUGINS/android-gateway.md`.

## USSD
Server queue-and-relay: a request creates an `ussd` row; the phone's
USSD companion is woken (FCM + Reverb) and drives the carrier session
step by step (`start` → `menu` → final PATCH). Scheduled USSD (balance
checks) runs every minute (`ussd:run-schedules`); sessions expire via
`ussd:expire-sessions`. Scripts + schedules are API-manageable
(`ussd.scripts.*`, `ussd.schedules.*`). Webhooks: `ussd.result`,
`ussd.completed`, `ussd.failed`.

## Data (tables)
`channel_connections`, `channel_messages`, `channel_webhook_events`,
`devices` + device_* family, `sims`, `sim_carrier_events`,
`sim_route_rules`, `sender_ids`, `ussd`, `ussd_schedules`,
`ussd_scripts`, `connection_update_notices`.

## API surface
`channels`, `channels.available`, `connections.*`, `senders.*`,
`sims.*`, `sim-routes.*`, `devices.*`, `ussd.*`. Webhooks:
`device.online`, `device.offline`, `ussd.*`.

## Plan gates
Phone Numbers limit (WABA + WhatsApp shared); per-channel switches;
per-channel quotas from the channel registry `limitKeys`.

## Keep / extension notes
- Core-owned hub. **Every channel we build registers here** through
  `ChannelPlugins.php` registry fields (planKeys, limitKeys, queues,
  flowNodes, broadcasts, abilities, mcpTools…) — see Lane 5 §5.4. If a
  channel needs a companion server, it also needs a `service_servers`
  kind (`05-INFRA.md`).
