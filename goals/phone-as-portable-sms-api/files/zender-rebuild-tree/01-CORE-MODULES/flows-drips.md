# CORE — Flows & Drips (Chat Flows engine)

**Status: core-owned (purchased). The docs' biggest page — the
automation heart of the product.**
Sources: Lane 2 (Flows), Lane 4 §B, Lane 5 §4/§6/§12.

## Purpose
A visual node engine for chat automation: triggers start runs, send
nodes message across channels, action nodes change data, control nodes
branch/wait/loop. Drips are Flows specialised as Send+Wait sequences.

## Screens / pages (tenant, Lane 4)
- Flows: 8 in demo (1 Active "Website Chat Welcome", 7 Draft; 24 runs
  each). Canvas built on @xyflow/react + dagre layout (Lane 5 §2).
- Drips: 8 sequences × 3 steps (7 Paused, 1 Draft). Drip reports:
  Overview / Performance / Contacts.

## Triggers
Inbound SMS / WABA / WhatsApp / Website Chat / Email, WhatsApp Poll,
USSD, Schedule, Date Field, Webhook, Message Failed, Status, Link
Clicked, Conversation Closed, Payment Received, Form Submitted.
Webhook trigger: `POST /api/webhooks/flow/{uuid}` + `X-Flow-Secret`
header; idempotency window 24h.

## Node families
- **Send:** SMS, RCS, WhatsApp, WABA, Web Push, Email, Telegram,
  **Phone Bridge, GSM Modem** (voice-capable sends).
- **Action:** Set Field, Add/Remove Tag/Group, Add Note, Assign Agent,
  Add/Remove Drip, Webhook, Generate QR, Send/Verify OTP, Record
  Payment, Cancel Run, Add Credits, Create Contact/Lead.
- **Control:** Wait, Condition, Branch, Switch, Loop, A/B Split, Random
  Split, Jump, End, AI Message, Ask Question (Text/Number/Email/Phone/
  Yes-No/Single/Multiple/Media/Date/Location; timeout 1 min – 30 days).
- AI node output 64–4,000 tokens, exposed as `{{ai.text}}` (charged via
  `ai-providers-credits.md`).

## Engine limits (hard numbers)
- 500 nodes / 1,000 edges per flow; 1,000 steps per run; 50 nodes per
  tick; tick 120s; run lock 5 min; Loop 1–10,000 iterations (default
  1,000).
- Expressions: Symfony ExpressionLanguage + helpers — upper/lower/trim/
  length/contains/replace/substring/split/join/default/now/dateAdd/
  dateDiff/formatDate/number/currency/round/random/uuid/wordCount…
- Resume: `POST /api/webhooks/flow-runs/{uuid}/resume` +
  `X-Resume-Token`, valid up to 7 days (max 30). Scheduler: `flow:tick`
  + `flow:resume` every minute; stranded runs failed by
  `flow:fail-stranded-runs`; run history pruned (90-day retention).
- Plugin flow nodes: channel plugins declare `flowNodes` in the channel
  registry; integrations add nodes by implementing the core
  `NodeExecutor` contract. Voice flows for telephony are compiled by
  core and executed by the telephony server (`flows/{id}/compiled`) —
  see `04-NO-SOURCE/telephony-server.md`.

## Data (tables)
`flows`, `flow_nodes`, `flow_edges`, `flow_runs`, `flow_run_steps`,
`flow_answers`, `flow_run_idempotency`, `flow_schedule_holds`,
`date_trigger_cursors`, `date_trigger_occurrences`, `sequences`,
`sequence_enrollments`, `voice_flow_versions`.

## API surface
`flows.trigger`, `flows.runs`, `flows.compiled`, `flows.facts`,
`flow-runs.show`, `flow-runs.resume`, `drips.enroll`, `drips.index`.

## Plan gates
Flows switch (all demo plans had it); Drips switch (Starter+ in demo
pricing); per-plan Flows count limit.

## Keep / extension notes
- Core-owned engine. Our plugins extend it only via declared nodes:
  Google Sheets nodes, Appointment Booking node, AI Flow Builder
  (generates flows), Telegram nodes — all specified in
  `02-PAID-PLUGINS/`.
- Anything that must survive a vendor update belongs in a plugin, not
  in the flow engine's core files (patch register rule).
