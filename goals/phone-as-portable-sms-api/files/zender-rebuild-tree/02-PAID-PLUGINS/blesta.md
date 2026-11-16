# PAID PLUGIN SPEC — Blesta (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/blesta/
- **Demo state:** Active/Configured (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Connect Blesta billing: notifications, ticket replies, phone
verification and sign-ins delivered through Zender.

## Features
Native messenger notices — Blesta keeps its own templates/screens; a
branded messenger delivers the complete catalogue of applicable
Blesta events; templates are edited in Blesta settings. Routing lives
on the Zender site (Blesta supplies recipient, rendered text and
event; the Zender admin chooses channels, senders, fallbacks).
**Durable queue + Message Log:** messages queue without slowing the
Blesta event, drain after the response and by cron; the log shows
masked destinations, status, progress, with retry and resend. Ticket
replies attach inbound replies to an existing Support Manager ticket.
Phone verification at registration or on change; optionally send
notifications only to verified numbers (unverified destinations are
skipped at delivery). Sign-in codes for clients and staff. Clients
can turn text notifications off on their Messaging page (applies to
native and plugin templates).

## Workflow
Upload → activate → enable Blesta, API Access and sending permissions
on plans (verification also needs OTP / Verify API) → download the
branded connector from Integrations → extract its plugin + messenger
folders into Blesta → install both, assign the messenger to SMS →
plugin Manage page: Connect → approve in Zender → Test Connection →
set delivery routing on the Zender Integrations page.

## Logic / technology
Requires Blesta 6.0.3+; connector minimum PHP 8.3 (vendor note:
Blesta 6.0.3 verified on PHP 8.3; a PHP 8.4 install failed); public
HTTPS both; working Blesta cron. Settings/queue/verification/
enrolment are scoped **per Blesta company** — connect separately per
company. Plugin templates overlapping native notices start OFF to
avoid duplicates (other applicable templates start on). Edits survive
upgrades; uninstalling removes template changes — disable instead.

## Data it touches
Contacts, messages, OTP verifications; per-company connector state.

## Dependencies
API Access; OTP / Verify API for verification.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + Blesta plugin +
  messenger (PHP) as connector half.
- **Key interfaces:** event catalogue mapping, durable queue with
  post-response drain, Message Log with masked destinations,
  reply-to-ticket attach, per-company scoping.
- **Priority:** Phase 4, integrations group — low (niche billing
  platform; build on tenant demand).
- **Difficulty:** Medium.
