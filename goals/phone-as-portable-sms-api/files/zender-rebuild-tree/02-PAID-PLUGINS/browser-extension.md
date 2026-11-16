# PAID PLUGIN SPEC — Browser Extension

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/browser-extension/
- **Demo state:** Active/Configured; tenant Integrations lists it
  (Lane 4 §§B, C).
- **Source status:** not stated; the extension ships as a per-site
  packaged build (see `04-NO-SOURCE/browser-extension-branded-builds.md`).
  We do not buy it.

## Purpose
A Chromium extension, branded per site, to message (and call) from
any web page.

## Features
Branded per site: each site downloads its own build from the
dashboard (site name shown, fixed to the site address); connects one
authorised member account at a time. Right-click a phone number or
email on any page to act (optional automatic highlighting — only then
does it ask for broader page access). Popup messaging: unread counts,
recent conversations, permitted templates, contact creation with
groups/tags. **Calls through Messenger** when plan, role and lines
allow — the server checks the connected member's rights for every
action. Realtime via a packaged worker with polling fallback. Runs
**only packaged code, no remote scripts**. Connection token in local
extension storage, expiring after **90 days**; revoke any browser
from the dashboard; an update lock prompts installing new files.

## Workflow
Member menu > Browser Extension > Download → unzip into a permanent
folder → browser extensions page: Developer mode on → Load unpacked →
select folder → pin → dashboard Browser Extension page: Connect
Extension → name the browser → confirm.

## Logic / technology
Chromium 120+; manual install only (no Web Store listing). The
extension is a client of the tenant REST API + realtime; per-action
authorisation is server-side (roles — `../01-CORE-MODULES/workspaces-teams-roles.md`).

## Data it touches
Conversations, contacts, templates via API; a per-browser connection
record (token, name, last seen) for revocation.

## Dependencies
Plan + role must allow Browser Extension; telephony channels for the
call feature.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) for the dashboard
  side (download/connect/revoke) + a Manifest V3 extension as the
  client half.
- **Key interfaces:** token issue/revoke endpoints (90-day tokens,
  per-browser records), popup inbox on the tenant API, context-menu
  actions (Send SMS / WhatsApp to this number), optional per-site
  branded build step (bake site URL + name into the package — the
  pattern in `04-NO-SOURCE/browser-extension-branded-builds.md`; a
  settings-entered URL is an acceptable v1 simplification).
- **Priority:** Phase 4, integrations group.
- **Difficulty:** Easy (Lane 6 verdict).
