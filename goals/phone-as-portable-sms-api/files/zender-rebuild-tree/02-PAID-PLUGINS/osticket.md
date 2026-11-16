# PAID PLUGIN SPEC — osTicket (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.1 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/osticket/
- **Demo state:** Active/Configured v1.0.1 (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Helpdesk integration: customer/agent/staff ticket notifications by
text, and replies that update the ticket.

## Features
Customer texts: ticket created, staff reply, resolved/closed — only
staff responses send reply texts, **internal notes never do**. Agent
notifications on assignment or when a ticket becomes overdue (to the
mobile on the staff profile; tickets without an assigned-agent mobile
are skipped). Staff alert numbers (one per line): new tickets in the
instance's departments send the Staff Alert template; each outgoing
row records instance, ticket and department. Every event has an
editable template (enable switch + plain-text template with ticket
variables) and can attach an approved WABA template by name/language
with header/body/button parameter mapping. Incoming replies attach to
the latest matching ticket within the instance's departments;
"Create Tickets From Unknown Numbers" is optional and **off by
default**; closed tickets reopen only when allowed. **Text Message
Code 2FA** for staff via osTicket's native 2FA (enrol with profile
mobile, verify with a code at login).

## Workflow
Upload → activate → Admin > Plans: enable osTicket + API Access →
download the branded connector from Integrations → extract into
`include/plugins` → osTicket: Add New Plugin → enable → add an
enabled instance → Connect → Test Connection → review routing
summary → choose departments → save.

## Logic / technology
Requires osTicket 1.18.x, PHP 8.2+, curl; HTTPS both ways; osTicket's
native cron running. Routing is managed in the connected Zender site,
not in osTicket. HTML is stripped from outgoing text.

## Data it touches
Contacts, messages, OTP (2FA codes); per-instance connector state.

## Dependencies
API Access; WABA (optional, for template attach).

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + osTicket plugin
  (PHP) as connector half.
- **Key interfaces:** event templates with variables, reply-to-ticket
  matching scoped by department, staff alert fan-out, 2FA code
  delivery via core OTP.
- **Priority:** Phase 4, integrations group.
- **Difficulty:** Easy–Medium.
