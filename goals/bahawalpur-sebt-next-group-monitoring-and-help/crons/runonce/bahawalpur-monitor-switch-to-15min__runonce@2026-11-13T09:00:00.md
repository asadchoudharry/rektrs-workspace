---
id: bahawalpur-monitor-switch-to-15min
title: 'Bahawalpur monitor: switch to every 15 minutes at 9 AM'
enabled: true
owner: goal:bahawalpur-sebt-next-group-monitoring-and-help
mode: task
schedule:
  kind: runonce
  timezone: Asia/Karachi
  at: 2026-11-13T09:00:00
delivery:
  - chat_id: 912e9812-4d40-413e-b611-bfb095ceba16
metadata:
  originating_chat_context_json: '{"chat_id":"912e9812-4d40-413e-b611-bfb095ceba16","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"c9eb963c30511050"}'
  presentation_locale: en-GB
---
One-time schedule change ordered by Assad on 2026-11-13 (~01:57 PKT): from 9:00 AM onwards the Bahawalpur SEBT Next group monitoring must run every 15 minutes instead of every 30 minutes.

Do exactly this:
1. Read the existing cron job `bahawalpur-sebt-group-monitor` in full (cron.view).
2. Update that same job id with cron.update: change ONLY its schedule to an interval of every 15 minutes (Asia/Karachi). Preserve its title, body, owner, delivery destination, and enabled state exactly as they are.
3. Read it back (cron.view) and verify the schedule now says every 15 minutes.
4. Send Assad one short message in this chat (Roman Urdu mix): monitoring is now every 15 minutes. Nothing else — do not run a group check in this job; the updated monitor job does the checks.
