---
id: postiz-upstream-watch
title: Postiz upstream weekly watch
enabled: true
owner: goal:rektrs-social-postiz-takeover-and-roadmap
mode: task
schedule:
  kind: weekly
  timezone: '@user.current'
  time: 10:48:00
  dow: [Mon]
delivery:
  - chat_id: ed9843f2-6d7c-44ad-b885-782e92893144
metadata:
  tags: [cron:flexible-time]
  originating_chat_context_json: '{"chat_id":"ed9843f2-6d7c-44ad-b885-782e92893144","origin_provider":"main","chat_kind":"direct","event_kind":"message","require_mention":false,"device_id":"8f304747-70b9-4463-af81-be16d13f42dc"}'
  presentation_locale: en-GB
---
Weekly upstream watch for Rektrs Social (Postiz). Owner: Assad. Report ONLY into the Postiz Update chat (the delivery chat of this job).

WHAT TO CHECK (read-only — never push, merge, deploy, or change anything):
1. In the local clone ~/workspace/rektrs-social-takeover/postiz-app, fetch upstream (git fetch upstream --tags) and read: (a) the newest upstream release tag and its date, (b) upstream main head commit and how many commits upstream main is ahead of the newest release tag, (c) how many commits our GitHub fork main (origin/main after fetch) is behind upstream main, (d) which upstream release tag our production branch release/rektrs-social-next16-2026-11-13 is currently based on (its latest upstream tag merge).
2. Read the watermark file ~/workspace/goals/rektrs-social-postiz-takeover-and-roadmap/hidden_files/upstream-watch-state.md for the last reported state, then update that file with today's checked values and date.

WHAT TO REPORT:
- Report in Roman Urdu + English mix, short, ONLY when something changed since the watermark: a NEW upstream release/tag appeared, the newest release contains security fixes, or the production branch's base tag fell behind the newest release.
- The report must state: newest upstream release + date, what it contains (read the release notes on GitHub; flag any security/access-control fixes first), how far behind our production branch is, and the recommendation (merge the new tag / no action needed).
- If NOTHING changed since the watermark (same newest release, production branch base unchanged), send NO message to the user — finish silently after updating the watermark.
- Never do the merge yourself and never sync the fork from this job; merging a tag into the production branch is a separate decision for Assad, proposed in the report.
