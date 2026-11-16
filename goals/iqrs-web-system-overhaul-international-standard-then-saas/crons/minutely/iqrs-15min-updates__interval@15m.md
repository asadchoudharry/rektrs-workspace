---
id: iqrs-15min-updates
title: All projects 15-minute update (main chat)
enabled: true
owner: goal:iqrs-web-system-overhaul-international-standard-then-saas
mode: task
schedule:
  kind: interval
  timezone: Asia/Karachi
  at: 2026-11-09T21:26:08
  every: 15m
timeout_secs: 900
delivery:
  - chat_id: 912efd32-16a2-43e0-9b9b-8ff5ea7f9b6a
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"912efd32-16a2-43e0-9b9b-8ff5ea7f9b6a","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"c9eb963c30511050"}'
  presentation_locale: en-GB
---
Standing instruction from Assad (2026-11-09, expanded 2026-11-15 ~17:47 PKT): post a progress update in the MAIN chat every 15 minutes covering EVERY project, not only the school programmes. Assad's exact words on 2026-11-15: "Her project ki details update dety raho 15 minute baad".

Compose ONE update in Roman Urdu, project-wise, short but with real detail (per project: kya ho gaya / kya chal raha hai / kya ruka hai aur kyun / koi owner-only step hai to sirf naam lo, nag mat karo):
Projects to cover every run (skip a project in one line if genuinely nothing changed — "koi change nahi" — never invent progress):
1. IQRS web overhaul + PreSkool purchased-package build (PKG track)
2. IQRS mobile apps (Connect + Workspace Android)
3. IQRS Workspace desktop app (D3 track)
4. Operqon ERP + Cursor execution
5. Rektrs Social / Postiz
6. Phone-as-API / WhatsApp+SMS system (Zender plan)
7. Oracle fleet + ServerKit/OperqonServer + Launchpad + Vaultwarden/Kuma/Healthchecks
8. Rektrs Security SaaS
9. UITraining design intelligence
10. iSkills SEBT Next playbook + Bahawalpur SEBT group monitoring
11. Multi-agent coordination hub
12. Any other active tracked goal / lane running at run time

Before writing, establish CURRENT state from evidence: check running/recent subagents and browser tasks, each project's goal workspace under ~/workspace/goals/, today's memory log (~/memory/<current-date>.md), and the relevant trackers (e.g. Postiz ROADMAP-EXECUTION.md, desktop D2-EXECUTION/D3 records, PreSkool deployment plan + PKG records). Report only what the evidence supports.

HARD RULES:
- PreSkool: STAGING ONLY. Production par PreSkool ka kuch nahi jayega — D-027, reaffirmed by Assad 2026-11-15 ~17:47 ("PreSkool staging per kerna abhi production per nhi"). Production implementation only as ONE gated owner-approved package after the full build is complete. If any lane/report suggests a PreSkool production change, flag it as a violation in the update, do not approve it.
- STATUS-FIRST: apart from the Inspector pass actions below, start no new work, deploy nothing, change nothing during this run.
- Never mention or nudge about: the §6.4 device pass / phone sign-in proof, the PreSkool Figma file (does not exist — confirmed 2026-11-12), the PreSkool licence (Assad holds it), the school-questions email (he sends it himself), owner sign-ins/OTPs/passwords (owner-only steps; name the step only, never collect credentials).
- Operqon detail that belongs only to the ERP/Cursor chats: keep it to a 1-2 line status in this rollup (ho gaya / chal raha / ruka) — no deep ERP internals here.

INSPECTOR PASS (Assad, 2026-11-09 — runs BEFORE composing the update; charter: ~/workspace/team/SUPERVISION-SYSTEM.md). Act as Inspector — IQRS (full pass) and light census for all other projects:
- Census every running/recent lane (subagents + browser tasks): status, running time, last-activity age. A lane is alive only if it has ACTED recently — the runtime status label alone is not evidence.
- Health classes: HEALTHY = activity within 30 min, or waiting on a named owner input — waiting-on-owner is NOT a stall. SUSPECT = 30–60 min quiet: name it in the update with its last known step AND send the lane ONE wake/status nudge in this same run (one nudge per quiet spell). STALLED = over 60 min quiet: investigate in this same run — (a) for IQRS, curl-probe staging.iqrs.edu.pk and iqrs.edu.pk (~1–2s HTTP 200 = host fine; ~10s empty reply = known stall signature, but check the laptop route before calling the host stalled), (b) read the lane session transcript's last step, (c) send ONE wake/status nudge if none sent yet in this spell. DEAD = no transcript writes for over 2h, or last step ended in an unrecovered error, or agent failed/interrupted: the update MUST state cause, evidence, and exact resume action needed, and append the lane's debrief to ~/workspace/team/TRAINING-LOG.md.
- Hurdle chasing: fix in this run what needs no owner decision. Never start a deploy, never close a browser window, never touch production in this run.
- Never report an unmoved lane as merely "still running": carry its health class, cause, and action taken or needed.
- Training sweep: for every lane that completed or failed since the last run and has no debrief yet, append its debrief (outcome, mistakes, unusual things, one-line lesson) to ~/workspace/team/TRAINING-LOG.md.
