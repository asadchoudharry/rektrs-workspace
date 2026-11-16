---
id: operqon-15min-updates
title: Operqon 15-minute progress update (ERP chat)
enabled: false
owner: goal:operqon-erp-r2-completion-and-vps-deployment
mode: task
schedule:
  kind: interval
  timezone: Asia/Karachi
  at: 2026-11-09T21:26:14
  every: 15m
timeout_secs: 900
delivery:
  - chat_id: 0730cd96-36fb-43d7-a850-12b027d9ecec
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"0730cd96-36fb-43d7-a850-12b027d9ecec","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"c9eb963c30511050"}'
  presentation_locale: en-GB
---
Standing instruction from Assad (2026-11-09): post a progress update in the ERP side chat (Operqon Updates) every 15 minutes about the Operqon ERP programme. This run's report IS that update — it is delivered to the ERP chat.

Compose ONE short update in Roman Urdu (a few lines, no essay):
- First establish the CURRENT state before writing: read the ERP chat's recent messages, check running/recent subagents and browser tasks, and the Operqon goal workspace (~/workspace/goals/operqon-erp-r2-completion-and-vps-deployment/, incl. files/HANDOVER-TO-CHATGPT.md) plus today's memory log for what completed, what is running, and any blocker.
- Report only what the evidence supports: what finished since the last update, what is in progress right now, and anything waiting on Assad. If genuinely nothing changed, say so in one line — never invent progress, and never claim a deployment or verification is done without its evidence.
- STATUS-FIRST: apart from the Inspector pass actions below, start no new work, deploy nothing, change nothing during this run.
- Keep school/IQRS detail OUT of this update (it has its own chat and its own update job).

INSPECTOR PASS (Assad, 2026-11-09 — runs BEFORE composing the update; charter: ~/workspace/team/SUPERVISION-SYSTEM.md). Act as Inspector — Operqon:
- Census every running/recent Operqon lane (subagents + browser tasks): status, running time, last-activity age. A lane is alive only if it has ACTED recently — the runtime status label alone is not evidence.
- Health classes: HEALTHY = activity within 30 min, or waiting on a named owner input (e.g. a console sign-in only the owner can do) — waiting-on-owner is NOT a stall. SUSPECT = 30–60 min quiet: name it in the update with its last known step. STALLED = over 60 min quiet: investigate in this same run — (a) probe the target system read-only (VPS via the established rssh route / service reachability) to separate system-down from lane-dead, (b) read the lane session transcript's last step for the death point and whether any deploy or write was in flight, (c) send the lane ONE wake/status nudge (subagent message or browser-task update). DEAD = no transcript writes for over 2h, or the last step ended in an unrecovered error, or the agent is failed/interrupted: the update MUST state the cause, the evidence, and the exact resume action needed (the CEO closes the lane and dispatches a state-preflight resume lane), and append the lane's debrief to ~/workspace/team/TRAINING-LOG.md.
- Hurdle chasing: fix in this run what needs no owner decision (answer a lane's pending question from its assignment context, point it at the correct tree/route). Never start a deploy, never close a browser window, never touch production systems in this run — closures and redispatches are the CEO's.
- Never report an unmoved lane as merely "still running": the update carries its health class, the cause, and the action taken or needed.
- Training sweep: for every Operqon lane that completed or failed since the last run and has no debrief yet, append its debrief (outcome, mistakes, unusual things, one-line lesson) to ~/workspace/team/TRAINING-LOG.md.
