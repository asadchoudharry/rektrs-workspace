# PAID PLUGIN SPEC — Web Push

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/web-push/
- **Demo state:** Active/Configured (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Browser push notifications to subscribed website visitors — from
campaigns, flows and the API.

## Features
Visitor subscriptions (browser permission; a subscription belongs to
one push site + one browser installation); configurable prompt
(headline, message, button labels, delay or scroll trigger, days
before asking again); **quiet hours** (optional start/end; eligible
sends held until the window ends, using subscriber timezone when
known, else workspace timezone); Web Push campaigns (title, body,
link, image/actions; reports with recipients, links, A/B tests) and a
**Send Push** flow node; install/test tools (generated snippet,
Verify Installation checks the service worker, Test Send); a generated
WordPress plugin that installs snippet + service worker without theme
edits.

## Workflow
Upload → activate → enable on plans, set site/subscriber limits →
Channels > Connect Channel > Web Push → name site, allowed domains,
prompt settings → paste snippet before `</body>`, upload generated
`push-sw.js` to the website root → Verify Installation → allow
notifications → Test Send → campaign or flow.

## Logic / technology
Core ships `minishlink/web-push` (Lane 5 §2), channel slug `push` in
the registry, `routes/push.php`, tables `push_subscription_states`,
`fcm_sends`, and the `push-send` / `push-campaigns` queues +
`push:fail-stale-queued`. VAPID-based standard Web Push. Domain facts:
on iPhone/iPad the visitor must first add the site to the Home Screen;
push-service acceptance is not proof the person saw it. Webhooks:
`push.message.*` (no `received`).

## Data it touches
`push_subscription_states`, campaign tables, `widget_*` (shared site
concept with Website Chat).

## Dependencies
HTTPS website + HTTPS Zender; queue worker; plan enablement. Works
alongside Website Chat.

## OUR REBUILD SPEC
- **Plugin type:** `channel` (channel key `push`).
- **Key interfaces:** push-site CRUD + limits, subscription capture
  endpoints, VAPID key management per site, Send Push flow node
  (`NodeExecutor`), campaign surface registration, quiet-hours hold in
  the send pipeline.
- **Priority:** Phase 4, integrations group (after the main channels).
- **Difficulty:** Easy–Medium — the protocol library and queues are core.
