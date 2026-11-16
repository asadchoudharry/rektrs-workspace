# CORE — Messenger (Shared Inbox)

**Status: core-owned (purchased).**
Sources: Lane 2 (Messenger), Lane 4 §B, Lane 5 §4/§6.

## Purpose
One shared inbox for every channel: SMS, RCS, WABA, WhatsApp QR, Phone
Bridge, GSM Modems, Website Widget, Web Push, Email, Telegram. Agents
reply, assign, label, macro and resolve; supervisors watch SLA/CSAT.

## Screens / pages (tenant, Lane 4)
- Messenger: 29 conversations in demo. Views: Conversations, My Inbox,
  Mentions, Participating, Unattended, **Live Visitors**. Tabs: Mine /
  Unassigned / All; "Open Next" work mode.
- Overview: open/resolved counts, first response 7m, resolution 40m,
  4 SLA breaches, CSAT 4.6/5, Live Queue (demo figures).
- Tools: Labels (24), Rules (24, all Off in demo — trigger "When Channel
  is…", action "Then —"), Macros (27; e.g. "Assign to Support Team and
  close" = Add label + Set priority + Closed).
- Workspace Settings > Inbox defaults: Assignment Round-robin, Agent
  Offline 10m, Auto-Close 24h.

## Features + rules / limits
- **Assignment:** round-robin (DB cursor), least-busy, or manual.
  Agent counts as offline after 1–120 min idle (default 10).
- **Teams & supervisors** (see `workspaces-teams-roles.md`); labels with
  label rules (≤ 5 conditions, ≤ 10 labels per rule).
- **SLA:** first-response and resolution targets per priority, computed
  against business hours; "Requeue Breached" option.
- **Auto-Close:** 1–720h (default 24). Away message throttled to 1 per
  5 min per conversation. Snooze; scheduled replies from 1 min to
  1 year.
- **Macros:** ≤ 10 actions each. Canned responses / quick replies.
- **CSAT:** survey after resolve; review links ≤ 2,048 chars via
  `{{review_link}}`.
- **WABA rule:** replies only inside Meta's 24h window; outside it, a
  template message is required (enforced here and in `waba.md`).
- Realtime via Reverb channels: `conversation.{id}.owner`,
  `conversation.{id}.member.{id}`, presence `user.{id}.inbox`,
  `agent.{id}`; typing indicator throttled 1 per 2s.
- Live Visitors view is fed by the Website Chat widget
  (`../02-PAID-PLUGINS/website-chat.md`).

## Data (tables)
`conversations`, `conversation_messages`, `conversation_events`,
`conversation_labels`, `conversation_label_links`, `conversation_notes`,
`conversation_participants`, `conversation_reads`, `conversation_rounds`,
`conversation_views`, `assignment_rules`, `sla_policies`, `csat_surveys`,
`messenger_macros`, `canned_responses`, `quick_replies`, `messenger_reads`.

## API surface
Conversations list/show/messages/reply/assign/unassign/resolve/reopen.
Webhooks: `conversation.created`, `conversation.assigned`,
`conversation.resolved`, `csat.received`.

## Plan gates
Messenger switch; Inbox Automation switch (rules/macros automation).

## Keep / extension notes
- Core-owned. Every channel plugin we build (Telegram, Email, Website
  Chat…) delivers conversations *into* this inbox through the channel
  contracts — no plugin renders its own inbox. The Mobile App
  (`02-PAID-PLUGINS/mobile-app.md`) is a client of this module.
- Call bar (Mute/Hold/keypad/Transfer/Hang Up) renders here for
  telephony channels; the voice itself is the telephony server's job
  (`04-NO-SOURCE/telephony-server.md`).
