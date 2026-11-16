# PAID PLUGIN SPEC — Odoo (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.1 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/odoo/
- **Demo state:** Active/Configured v1.0.1 (Lane 4 §C).
- **Source status:** the Zender-side plugin is not stated; the Odoo
  side is three add-ons delivered as a branded download. We buy neither.

## Purpose
Connect Odoo (19.0 / 20.0) databases to Zender messaging: native Odoo
SMS flows, "Send WhatsApp" actions, automation rules, and phone-code
sign-in.

## Features
Native Odoo SMS flows via the connector while "Use Messaging Service"
is on — transactional and marketing batches follow saved routing, keep
native consent/blacklist checks, and update through signed receipts.
"Send WhatsApp" actions on Contacts, CRM Leads, Sales Orders,
Invoices, Journal Entries and Calendar Events (confirm recipient,
write a message or pick an approved template with mapped variables).
Odoo automation rules gain a Send WhatsApp action (model, trigger,
conditions; per-record send using the record's company). **Phone-code
sign-in:** users enable SMS or WhatsApp Code in security preferences
and enter a code after password sign-in — Zender generates/checks the
codes, the add-on never stores code values. Optional phone
verification pausing account creation until the number is approved;
portal phone changes keep the old number until the new one is proved;
local rate limits on top of Zender's. Per-company connections, routing
managed once per connected database. Updates: "Update Now" replaces
all three add-ons together, then "Finish Upgrade".

## Workflow
Upload → activate → Admin > Plans: enable Odoo + API Access +
channels → Integrations > Odoo: choose series 19.0 or 20.0 → Download
Addons → extract into Odoo's add-ons path → refresh apps → install →
per company: Connect in Company Messaging → Test Connection → review
routing summary → send.

## Logic / technology
No API key is typed into Odoo — the messaging site address is fixed
in the branded download and Connect supplies private credentials (the
branded-connector pattern, `04-NO-SOURCE/browser-extension-branded-builds.md`).
Odoo server needs Python packages `requests` + `phonenumbers`, the
`sms`, `base_automation`, `auth_totp` modules, public HTTPS both
ways, and Odoo's scheduled jobs running. Sign-in codes ride core's OTP
service (`../01-CORE-MODULES/otp-verification.md`).

## Data it touches
Contacts/conversations via API; per-company connection records
(plugin-side).

## Dependencies
Odoo 19.0/20.0 with server add-ons path access; API Access plan
switch; OTP for verification features.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + three Odoo
  add-ons (Python) as the connector half.
- **Key interfaces:** Zender-side Connect approval + routing config;
  Odoo-side add-ons calling the tenant REST API (send message/template,
  OTP verify) — no direct DB access either way; signed delivery
  receipts back into Odoo.
- **Priority:** Phase 4, integrations group — notable for us because
  Operqon-adjacent customers may run Odoo, but it stays a loose
  integration (master plan rule).
- **Difficulty:** Medium-Hard (two codebases; Odoo add-on API care).
