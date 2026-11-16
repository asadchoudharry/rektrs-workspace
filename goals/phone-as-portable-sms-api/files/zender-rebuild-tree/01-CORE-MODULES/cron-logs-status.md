# CORE — Cron, Logs, Audit & Status Page

**Status: core-owned (purchased).**
Sources: Lane 2 (Cron/Logs, Status), Lane 4 §A, Lane 5 §12.

## Scheduler map (`routes/console.php`, ~116 entries, all
`withoutOverlapping`; many gated on `ChannelPlugins::live('<slug>')`)

- **Every minute:** `messaging:tick` (send pump), `otp:expire`,
  `campaigns:launch-recurring`, `campaigns:decide-ab-winners`,
  `flow:resume`, `flow:tick`, `flows:google-sheets-poll`,
  `bookings:tick`, `commerce:tick`, `bookings:calendar-poll`,
  `servers:alerts`, `status:observe`, `system:heartbeat`,
  `wa:health-check`, `wa:outbox-pump`, `wa:warmer-tick`,
  `wa:connection-alerts`, `wa:resume-temp-bans`, `smpp:sweep`,
  `smpp:servers-health`, `devices:offline-alerts`,
  `sms:move-pending-from-offline`, `sims:resume-carrier`,
  `ussd:run-schedules`, `ussd:expire-sessions`,
  `phone-bridge:sms-outbox`, `phone-bridge:device-webhooks`,
  `network:reserve-call-minutes`, snooze-wake + SLA-breach jobs,
  `messenger-domain:provision-ssl`.
- **Every 5–15 min:** `messages:rollup` (15m), `flows:date-trigger-tick`,
  `wa/sms/waba/push:fail-stale-queued`, `campaigns:sweep-counters`
  (15m), `campaigns:watchdog`, `servers:sweep-moves`, `smpp:balance`,
  `telephony:balance`, `telephony:servers-health`,
  `wa:delivery-health` (15m), `android:app-updates` (15m),
  `knowledge:refresh`/`knowledge:retry` (15m), `billing:usage-alerts`
  (15m), `payments:expire-links` (15m), `network:release-earnings`
  (15m), `network:health` (15m), `sentry:flush` (error reports — OFF
  for us), `cleanup:import-files` (5m).
- **Hourly:** `subscriptions:manage`, `subscriptions:grant-monthly-
  credits`, `reports:send-cost-emails`, `market:expire-pending`,
  `privacy:account-deletions`, conversation auto-close,
  `sims:detect-missing-delivery-reports`, `flow:sweep-dry-runs`.
- **Daily (02:00–04:56 UTC prune window):** rollups/prunes for
  messages, OTP, WhatsApp sign-in, OIDC key rotation
  (`oidc:rotate-keys`), WA server counters/pairings/warmer/media/
  groups/suppressions/connect-links, landing uploads, status rollup,
  Android heartbeats, stale pairings, voice prompt assets, API
  idempotency keys, call recordings, link click details, flow runs,
  abuse velocity counters, subscribe submissions, widget stats,
  knowledge, privacy, `queue:prune-failed --hours=720`,
  `queue:prune-batches`, gateway renewal processors
  (`yookassa:process-renewals`, `paystack:process-renewals` 00:30),
  `waba:sync-messaging-limits`, `model:prune` (15 models),
  `demo:cleanup` (demo mode only).
- **Periodic:** `waba:sync-templates` (6h), `phone-bridge:publish-
  minutes` (monthly), `messages:unlock-inbound` (monthly),
  `voice:prune-voice-samples` (weekly).
- Plugins add their own entries via `ChannelRuntimePlugin::
  registerSchedule` — our plugins must do the same, never edit
  `routes/console.php` (patch register).

## Cron Jobs admin page
Tabs: Scheduled / Execution Logs / Queued / Failed + Run Now per job.
Demo: 121 jobs listed. Tables: `cron_runs`, `jobs`, `job_batches`,
`failed_jobs`, `system_heartbeats`.

## Logs & audit
- Admin > System Logs: Audit (1,506 entries in demo) with tabs Errors /
  Incoming Webhooks / Privacy; columns Time / Actor / Action / Target /
  IP. Incoming webhooks can be **replayed** from the log.
- Laravel log files `laravel-YYYY-MM-DD.log` kept 14 days.
- Settings changes and admin actions are audit-logged (`audit_logs`).

## Status Page
- Public status page with 90-day history; checks every minute;
  3 bad checks = incident, 3 good = auto-resolve; email confirmation +
  RSS for subscribers. Demo: 46 incidents (all seeded "SMPP down"),
  1 open. Admin tabs: Incidents / Settings.
- Tables: `status_incidents`, `status_incident_updates`,
  `status_observations`, `status_subscribers`, `status_daily`,
  `status_email_sends`. Commands: `status:observe` (minute),
  `status:rollup` + `status:prune-subscribers` (daily).

## Support tickets (platform)
Admin > Tickets + tenant Help > Support (demo: 12 tickets, 3 open).
Tables: `tickets`, `ticket_messages`, `ticket_attachments`. Limits in
Settings > Support (`settings-admin.md`).

## Keep / extension notes
- Core-owned. Operational rule: when "messages are not sending", check
  in this order — cron alive (`system:heartbeat`), queue workers,
  `messaging:tick` watchdog state, companion server health — before
  touching code.
