# PAID PLUGIN SPEC — WHMCS (integration)

- **Vendor price:** $59 — **FREE for Extended licence holders**.
  **Version:** v1.4.2 (6 Nov 2026) — highest version in the catalogue.
- **Portal:** https://products.titansys.dev/zender/whmcs/
- **Demo state:** Active with the "Extended" label (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Connect WHMCS (hosting billing) to SMS/WhatsApp/WABA for
notifications, phone verification and sign-in codes.

## Features
Event-based notifications (SMS, WhatsApp, WhatsApp Business from
selected WHMCS events; **every rule starts disabled**). Staff Copy
per rule (comma-separated numbers); ticket rules can notify the
assigned admin and department staff. **Ticket replies by text:** a
client's reply is matched to a verified/unique client phone and added
to their most recently created active ticket; unmatched replies stay
in the Log. Phone verification at registration, on phone change and
at checkout (editing the number requires a new code). Two-factor
"Codes" provider for clients and administrators. Client preference
"Text me about my account" — rules respect it, **except Password
Reset**, which bypasses the preference but never sends a password or
reset link. Delivery widget + per-client Message History; transport
failures / HTTP 429 / server errors retry with backoff, up to 5
attempts.

## Workflow
Upload → activate → enable WHMCS + API Access + channels on the plan
→ Integrations: Download Module → upload its `modules` folder to the
WHMCS root → activate the addon → Connect → approve in Zender → Test
Connection → enable the rules you want.

## Logic / technology
Requires WHMCS 9.0+; connector PHP 8.2+; public HTTPS both ways;
working WHMCS system cron. Phone verification/sign-in codes need the
plan's OTP / Verify API with an eligible delivery channel. The addon
keeps its data unless "Delete Data On Uninstall" is on (then
deactivation removes settings, rules, queue, logs, signup field).

## Data it touches
Contacts, messages, tickets (WHMCS-side), OTP verifications.

## Dependencies
API Access + OTP plan features; sending channels.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + WHMCS addon
  module (PHP) as connector half.
- **Key interfaces:** Connect approval, rule engine (WHMCS event →
  channel/template), reply-to-ticket matching (verified phone →
  latest active ticket), Codes 2FA provider via core OTP, retry
  policy (backoff, max 5) in the delivery queue.
- **Priority:** Phase 4, integrations group (hosting-industry tenants
  make this commercially relevant for Rektrs).
- **Difficulty:** Medium.
