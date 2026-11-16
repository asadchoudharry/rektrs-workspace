---
id: operqon-pr-watch
title: Operqon GitHub PR watch (Cursor wave)
enabled: true
owner: goal:operqon-erp-r2-completion-and-vps-deployment
mode: task
schedule:
  kind: interval
  timezone: Asia/Karachi
  at: 2026-11-14T00:06:59
  every: 15m
delivery:
  - chat_id: d030d516-48d1-463e-a006-f25e4b8c18b2
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"d030d516-48d1-463e-a006-f25e4b8c18b2","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"c9eb963c30511050"}'
  presentation_locale: en-GB
---
Assad's standing order (2026-11-13 ~23:51 PKT, side chat "Monitor Cursor GitHub PR activity"): "GitHub per PR check kerty rehna" — keep checking the PRs of repo s22benlg1m01140-sudo/operqon-core on GitHub and report changes to Assad in this chat.
Assad's second standing order (2026-11-13 ~23:57 PKT, approved by him; route corrected ~00:00 PKT 2026-11-14 because his laptop is OFF — "Mera laptop to band hy isi liye to keh Raha tha"): AUTO-SIGNAL to Cursor from the GITHUB side after every PR event — the signal is a COMMENT on the PR itself on GitHub (Cursor works through GitHub, so it reads the signal there) — WITHOUT touching Cursor's code, branches or files, WITHOUT any approval-review (no merge-gate effect), and without needing his laptop or the Cursor chat at all.
Assad's third standing order (2026-11-14 ~16:47 PKT, via the ERP chat): Cursor has an ADOPTION-DECISION task (decision/planning only) — watch branch docs/adoption-decision-20261114 for its deliverable landing (step 8).
Assad's fourth standing order (2026-11-15 ~00:07 PKT, via the "Operqon and Cursor updates" chat, which is also this job's delivery chat since 2026-11-15): "Cursor ko ja ke continue to kar aaya karo, PR ke baad woh ruk jata hai" — after a PR, Cursor stalls; go to Cursor and make it CONTINUE (step 9).

Each run, on GitHub (never merge, close, or approve-review any PR in this job; creating PRs happens only in the main chat routine on Cursor's explicit request, never in this job):
1. Run: /opt/hatch/bin/github call-read-tool --name list_pull_requests --arguments-json '{"owner":"s22benlg1m01140-sudo","repo":"operqon-core","state":"all","perPage":10,"fields":["number","title","state","merged","merged_at","head"]}'
2. Read the last snapshot: ~/workspace/goals/operqon-erp-r2-completion-and-vps-deployment/hidden_files/pr-watch-state.json (it carries a "signaled" list of event keys like "70:created" and "69:merged" whose GitHub signal comment was already posted, and an "adoption_branch_tip" SHA).
3. Compare per PR number: state, merged flag, head SHA. Also note any PR number higher than the snapshot's highest_seen.
4. Update the state file with the new snapshot (same JSON shape, preserving the "signaled" list) BEFORE deciding the report.
5. Report to Assad ONLY if something changed since the snapshot: a PR merged (name it: number + title), a PR closed without merge, a brand-new PR appeared (number + title + head branch), or an open PR's head SHA advanced (Cursor pushed fixes). Write the report in Roman Urdu + English mix, short, in Assad's format: "✅ Kya ho gaya" lines for merges/completions and "⏳ Kya rehta hai" for still-open PRs among #70 and above. If NOTHING changed, end the run silently with no message to the user.
6. PR #56 (draft handover) is parked by Assad's order — never signal it, and its state never counts as a change worth reporting unless it gets merged or closed, which WOULD be reported immediately as unexpected.
7. GITHUB AUTO-SIGNAL (PRs numbered 65 or higher with head branch starting "cursor/", never #56): for each event not already in "signaled" —
   a. A PR newly appeared (created): post a comment on it via /opt/hatch/bin/github call-tool --name add_issue_comment with owner s22benlg1m01140-sudo, repo operqon-core, issue_number = PR number, body: "Signal for the Cursor agent (from Claude, on Assad's instruction — GitHub-side signal, laptop-independent): PR #NN is CREATED and verified OK on GitHub. Title: <title>. Head <branch> @ <short sha> → base release/operqon-provider-r2. Cursor: CI green par merge + deploy tumhara apna step hai — Muse merge nahi karega, ye comment sirf signal hai, code/flow mein koi change nahi." Then add "NN:created" to "signaled".
   b. A PR newly merged: post a comment on it the same way, body: "Signal for the Cursor agent (from Claude, on Assad's instruction — GitHub-side signal): PR #NN OK ho gaya hai — MERGED (<title>). Agla queued step apne flow se aage barhao. Ye comment sirf signal hai, code/flow mein koi change nahi." Then add "NN:merged" to "signaled".
   If a comment call fails, do NOT retry repeatedly: leave that event key out of "signaled" and, only if an Assad report is already being sent this run, mention the signal is pending.
8. ADOPTION-DECISION BRANCH WATCH: run /opt/hatch/bin/github call-read-tool --name list_commits --arguments-json '{"owner":"s22benlg1m01140-sudo","repo":"operqon-core","sha":"docs/adoption-decision-20261114","perPage":3,"fields":["sha","commit"]}' and compare the tip SHA with the state file's "adoption_branch_tip" (baseline 8ffaeb033b00eb19373effc6a5b115be15fbb7b0, the owner-directive docs commit). If the tip advanced, update "adoption_branch_tip" in the state file and include in the Assad report (same ✅/⏳ format) the new commit's subject line — in particular, if a commit adds docs/adoption-decision/CURSOR-BOARD-FINDINGS.md, report prominently: "✅ Cursor Board findings aa gayi hain" with the commit SHA. This branch is decision/planning only: never signal, comment, merge or modify it in this job.
9. CURSOR CONTINUE NUDGE (Assad's fourth standing order): for each PR created or merged event detected in this run (PRs ≥65, cursor/* head, never #56), ALSO send a task with chat.send_message to the Cursor-monitoring chat (chat_id 96ce3e3b-c784-446a-b4e9-0b851889b127) instructing its agent to go to Cursor's panel via its established laptop-Chrome route and tell Cursor to CONTINUE with its next queued step — do not stop after the PR — naming the PR number, title and event (created/merged). This is in addition to the GitHub signal comment in step 7, not a replacement. Do NOT claim in the Assad report that the nudge reached Cursor's panel; the monitoring chat confirms panel delivery separately. If chat.send_message fails, mention "Cursor continue nudge bhejna pending hai" in the Assad report for this run.
Baseline at setup (2026-11-13 23:51 PKT): #70 open @8a82d2a, #71 open @7f6991b, #69 merged, release tip 230e402. Signal comments for 70:created and 71:created were posted manually by Muse at ~00:02 PKT 2026-11-14 (comment ids 6862233223 and 6862238103); 69:merged was signaled manually earlier via the Cursor chat. Adoption branch baseline set 2026-11-14 ~16:47 PKT: tip 8ffaeb03 on release cfd670f.
