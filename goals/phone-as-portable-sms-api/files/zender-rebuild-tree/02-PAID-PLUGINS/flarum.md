# PAID PLUGIN SPEC — Flarum (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/flarum/
- **Demo state:** Active/Configured (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Text notifications, phone verification and moderator alerts for a
Flarum forum, with delivery managed on the Zender site.

## Features
Text-message notifications: members choose "Text Message" in the
native Flarum notification grid after verifying a phone; preferences
start OFF; admins decide which notification types the forum offers.
Phone verification by code in forum settings; delivery reloads the
current verified phone before sending. **Moderator alerts:** mods
with the right permissions get texts for flagged posts and approvals;
up to ten moderator alert numbers can receive enabled events directly.
Privacy-conscious messages: sender name, shortened discussion title
and a link where appropriate — **post and private-message bodies are
never included**; texts capped at 320 characters. Routing on the
Zender site: the forum sends only a phone recipient, a short text and
a stable reference; a single Connect approval links them. Queued
delivery via the Flarum queue with bounded retries; optional native
GDPR support exports/erases phone data through the standard request
flow.

## Workflow
Upload → activate → enable Flarum + API Access on the plan
(verification also needs OTP / Verify API) → download the branded
extension from Integrations → place in the forum's extensions folder,
require with Composer → enable in Flarum Admin → Connect in extension
settings → approve in Zender → Edit Routing → run queue worker +
scheduler.

## Logic / technology
Requires Flarum 2.0.2+ (2.x series), PHP 8.3+, Composer. **No server
address / API key field exists in Flarum** — the downloaded extension
fixes the service address (branded-connector pattern). Flags and
Approval extensions are optional. A durable queue driver is mandatory
— the sync driver runs once during the request and cannot keep
retries.

## Data it touches
Contacts, messages, OTP verifications.

## Dependencies
API Access; OTP for verification.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + Flarum extension
  (PHP/Composer) as connector half.
- **Key interfaces:** Connect approval, notification-type mapping,
  moderator alert list, 320-char privacy-safe message composer, GDPR
  export/erase hooks on the Flarum side + personal-data participation
  on the Zender side.
- **Priority:** Phase 4, integrations group — low (on demand).
- **Difficulty:** Easy–Medium.
