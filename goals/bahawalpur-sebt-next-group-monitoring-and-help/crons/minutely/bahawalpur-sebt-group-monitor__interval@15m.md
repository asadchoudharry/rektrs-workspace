---
id: bahawalpur-sebt-group-monitor
title: Bahawalpur SEBT Next group monitoring and help
enabled: true
owner: goal:bahawalpur-sebt-next-group-monitoring-and-help
mode: task
schedule:
  kind: interval
  timezone: Asia/Karachi
  at: 2026-11-13T09:11:47
  every: 15m
timeout_secs: 1500
delivery:
  - chat_id: 912e9812-4d40-413e-b611-bfb095ceba16
metadata:
  tags: [cron:automatic-interval-anchor]
  originating_chat_context_json: '{"chat_id":"912e9812-4d40-413e-b611-bfb095ceba16","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false}'
  presentation_locale: en-US
---
Standing duty ordered by Assad on 2026-11-13 (~01:53 PKT): continuously monitor the "Bahawalpur SEBT Next" group chat inside my.iskills.com (Chat section; group URL https://my.iskills.com/chats/01a11797-58e0-747c-8c50-a6997d4b9dff) and help members there in Assad's style.

ROUTE (owner directive, main chat, 2026-11-13 ~09:21 PKT — supersedes all earlier sign-in instructions): ALL reading happens in Assad's OWN laptop Chrome through the device browser (browser="device"). Assad logs into my.iskills.com there himself and leaves the Bahawalpur SEBT Next group tab open; read from that tab. Do NOT use the cloud browser for this group, do NOT open the my.iskills.com login page in the cloud browser, and do NOT attempt the Cloudflare "Verify you are human" checkbox there — that route is closed. Never ask Assad for a password or code. If the device browser is not available, or the group tab is not open, or the session there is logged out, note the block in the state file and end the run silently — Assad already has the setup steps; do not send repeated login reminders.

Each run:
1. Read the watermark/state file at ~/workspace/goals/bahawalpur-sebt-next-group-monitoring-and-help/hidden_files/monitor-state.md (create it if missing). Baseline already handled before this job existed: replies sent 2026-11-13 01:49 PKT (to Bilal Ahmad, Mam Aiman lecture) and 01:52 PKT (to sikander rasheed, digital planners) — never answer those again.
2. In Assad's laptop Chrome (device browser), use the group chat tab he leaves open and read MESSAGES ONLY. Never open the members list or group info (Assad: "members q dekh rahy, chats dekho na"). Do not close the group tab when finished — Assad ordered the tab to stay open.
3. Consider only messages newer than the watermark that are genuine course/help TOPIC questions still unanswered (not already answered well by another member, not already answered by Asad Ahmad, and not casual chat).
4. For each such question whose solution is clear and safe, send ONE reply in the group: use the chat's reply/quote action to TAG the person's message, then send only the plain solution text. Style rules are locked by Assad: SHORT — no long messages, only the solution to the problem; NO name and NO "bhai" or any salutation; Roman Urdu + English mix like Assad's; respectful; topic only.
5. NEVER send: a personal/DM message to anyone; anything personal, abusive, or off-topic; replies about payments, refunds, account buying/selling/sharing, or disputes; or any answer whose facts are uncertain or need a teacher/admin (sir/mam) confirmation. Instead, collect those items and flag them to Assad in the run report with a short draft, and wait for his word.
6. Update the state file: new watermark (latest message seen, with sender and time) and a log line for every reply sent (time, who was tagged, exact text). Never send the same reply twice; if a send's outcome is uncertain, check the chat before any retry.
7. Reporting: if at least one reply was sent or one item needs Assad's decision, end with a short report to Assad in this chat (Roman Urdu mix): what was asked, what was sent, what is flagged. If nothing new happened, end the run silently with no chat message.
