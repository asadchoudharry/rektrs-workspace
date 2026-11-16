# PAID PLUGIN SPEC — Email (channel)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/email/
- **Demo state:** Active/Configured v1.0.0; Email Servers list: 1
  healthy server, 0/500 mailboxes; tenant mailbox channel shows
  "Ramping up…" (Lane 4 §§A–C).
- **Source status:** PHP plugin not stated; the companion **email
  service is a closed binary** (x86_64 + ARM Linux). We buy neither.

## Purpose
Connect tenant mailboxes so email becomes a first-class channel:
threaded email in Messenger, email campaigns, flows and API sending.
**Not** the system email (password resets/invoices stay on core SMTP).

## Features
Mailbox connect: Gmail and Microsoft via sign-in; Gmail also via App
Password; "Other" = any mailbox with IMAP/SMTP server details.
Threaded email in Messenger (subject, To, Cc, attachments, replies
grouped); agent replies with rich text, Cc, Bcc and a mailbox
signature. Email campaigns with sending speed, a rolling daily limit
and a **health ramp**; a mailbox **Warmer** that builds sending
reputation for new mailboxes; Suppressed Emails, bounce reasons and
domain reports. Flows can start on incoming email or send email; the
Website Chat widget can use a mailbox for offline replies. API sending
with idempotent retries; webhooks `email.message.*` (received, sent,
delivered, read, failed).

## Workflow
Upload → install → activate → **install the bundled email service on
a Linux VPS** → register it in Admin > Email Servers (it must reach
both the Zender URL and the mailbox providers) → enable Email on
plans, set mailbox limit → Channels > Connect Channel → add mailbox.

## Logic / technology
Standard IMAP/SMPP—no: IMAP/SMTP — the binary is a sync/send engine,
not a protocol invention. Core side: channel slug `email` registered;
core routes hold only a fallback 503 for `v1/internal/email/*`;
`email` + `email-campaigns` queues exist. Live updates need Reverb or
Pusher.

## Data it touches
`channel_connections`, `conversations` (threaded), campaign tables,
suppression lists (`unsubscribed_emails` + plugin-side suppressed
emails — exact split UNVERIFIED).

## Dependencies
Companion email service (own build — `04-NO-SOURCE/email-server.md`);
mailbox credentials or Gmail/Microsoft OAuth; Reverb/Pusher.

## OUR REBUILD SPEC
- **Plugin type:** `channel` (channel key `email`) + companion service.
- **Companion service:** standard IMAP/SMTP libraries — IMAP sync
  (IDLE where possible, else polling), SMTP send per mailbox,
  bounce parsing → suppression feed, warmer scheduler (our own
  algorithm). Lane 6 rates this the easiest server replacement.
- **Key interfaces:** Service Server kind `email` registration,
  mailbox connect/health, inbound mail → threaded conversation,
  outbound send + status events (`email.message.*`), campaign pacing
  (speed, rolling daily limit, health ramp) enforced queue-side.
- **Priority:** Phase 4, channels group (Telegram / Website Chat /
  Email).
- **Difficulty:** Easy–Medium (service) + Medium (plugin glue:
  threading, signatures, campaign pacing).
