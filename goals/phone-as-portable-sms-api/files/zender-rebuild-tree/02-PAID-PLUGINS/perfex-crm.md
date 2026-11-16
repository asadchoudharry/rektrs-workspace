# PAID PLUGIN SPEC — Perfex CRM (integration)

- **Vendor price:** $59 — **FREE for Extended licence holders**.
  **Version:** v1.0.1 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/perfex/
  (`/zender/perfex-crm/` is a 404).
- **Demo state:** Active with the "Extended" label (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Connect Perfex CRM notifications, phone verification and sign-ins to
Zender channels, with Perfex's own SMS gateway slot filled by Zender.

## Features
Branded SMS gateway module inside Perfex (SMS, WhatsApp, WhatsApp
Business; under Setup > Settings > SMS: connect / test / disconnect +
a read-only routing summary). Business-event triggers — Perfex's
native SMS templates stay available; grouped templates for CRM events
(expand a group, write a message, choose recipients, optionally map a
WhatsApp Business template). **Safe recipient rules:** related
contacts must be active and allow the matching notification topic;
responsible staff come from record assignment; security messages go
only to Staff Alert Numbers and omit passwords and codes. Manual and
bulk sending (Send Message on a contact/lead/staff profile; Send Bulk
Message from Customers/Contacts/Leads lists — recipient counts and
skipped reasons shown before queueing). Verification and sign-in
codes delivered through the Zender site. Routing (channels, senders,
fallback) managed in the connected Zender site, not in Perfex; phone
numbers keep a leading plus; Zender applies its own number handling
and unsubscribe rules.

## Workflow
Upload → activate → Admin > Plans: enable Perfex, API Access and
sending channels → Integrations > Perfex: Download Module → install
the branded module in Perfex via its module uploader → Setup >
Settings > SMS: Connect → Test → activate provider → fill templates.

## Logic / technology
Requires Perfex CRM 3.3+ (3.4.1 is the compatibility reference),
PHP 8.1+; public HTTPS both ways; Perfex cron running. **Blank
template = event disabled** — nothing sends for an event until a
message is written. Bulk messaging needs Campaigns on the connected
Zender plan. Codes ride core OTP (`../01-CORE-MODULES/otp-verification.md`).

## Data it touches
Contacts, messages/campaigns (bulk), OTP verifications.

## Dependencies
API Access; Campaigns for bulk; OTP for codes.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + Perfex module
  (PHP) as connector half.
- **Key interfaces:** Perfex SMS-gateway driver contract (send +
  status), event template groups, recipient-safety filter, bulk send
  via core campaigns, Connect/routing summary.
- **Priority:** Phase 4, integrations group.
- **Difficulty:** Medium.
