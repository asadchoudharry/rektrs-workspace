# PAID PLUGIN SPEC — Website Chat (widget channel)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/website-chat/
- **Demo state:** Active/Configured; tenant has 2 Website Widgets, one
  Live (Lane 4 §§B, C).
- **Source status:** not stated. Note: the widget **frontend source is
  in core** (`resources/js/widget/`, three Vite builds — Lane 5 §1).
  We do not buy the plugin.

## Purpose
A live-chat widget for the tenant's website; visitor conversations
land in the shared Messenger inbox.

## Features
Replies in Messenger (team access, assignment, typing, history follow
shared-inbox rules); customisable widget (theme, launcher position/
visibility, header branding, welcome text/greeting, preview before
publish, "Avoid Overlap" keeps the button clear of other floating
buttons); prechat (off / optional / required — name, email, phone);
availability from workspace hours or a custom schedule + away message
+ offline form; **verified visitor identity** (pass a user ID with an
HMAC-SHA256 hash computed server-side; unsigned details stay
unverified and cannot claim an existing contact); JavaScript API
(open/close/toggle, theme overrides, send/prefill messages, event
tracking after consent, ready/open/close/message/unread events);
**live visitors** list + optional country (from trusted CDN headers
or a free MaxMind key — only the 2-letter code is stored). Allowed
domains: exact host, optional port, or `*.example.com` (wildcard does
not include the apex itself).

## Workflow
Upload → activate → enable on plans, set widget limit → Channels >
Connect Channel > Website Chat → name widget, allowed domains,
appearance → enable until status reads Live → paste the snippet into
the site template (or use the generated WordPress plugin) → test
message → answer in Messenger.

## Logic / technology
Core already ships: channel slug `widget` in the registry, widget
routes (`routes/widget.php`, ~18 routes), widget tables
(`widget_visitors`, `widget_campaigns`, `widget_campaign_stats`,
`widget_proof_*`), the widget React source + a separate widget-frame
Vite build, and the "Powered by {name}" component (Lane 5 §§1, 10).
Realtime requires Reverb or Pusher. Offline email replies use the
Email plugin (optional). Webhooks: `widget.message.*`.

## Data it touches
`widget_*` tables, `conversations`, `contacts` (verified identity
linking).

## Dependencies
Reverb/Pusher; HTTPS on both sites; Email plugin (optional, for
offline replies).

## OUR REBUILD SPEC
- **Plugin type:** `channel` (channel key `widget`).
- **Key interfaces:** widget connection CRUD + domain allowlist,
  snippet generation, visitor session + identity verification
  (HMAC-SHA256), presence for Live Visitors, plan limit (widget
  count). Much of the runtime already exists in core — first task is
  a gap audit of what the paid plugin adds beyond core (Phase 0/1
  verification item; the split is UNVERIFIED).
- **Priority:** Phase 4, channels group (with Telegram + Email).
- **Difficulty:** Easy–Medium (core carries the widget itself).
