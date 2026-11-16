# NO-SOURCE — Email Server (closed binary)

Full evidence: Lane 6 §5 + Lane 3. The Email plugin was **not
bought**; behaviour is from the product page, demo and core's surface.

## What it is
The sync/send engine of the paid Email channel plugin: connects
tenant mailboxes (Gmail/Microsoft sign-in, Gmail App Password, or any
IMAP/SMTP mailbox) to Messenger — threaded email in the inbox, email
campaigns with pacing, a mailbox **Warmer**, suppression/bounce
reporting, flows and API sending. Distinct from core's system email
(password resets/invoices), which stays on core SMTP.

## Interface evidence
- The bundled email service installs on a **Linux VPS** (x86_64 + ARM
  binaries in the plugin download). Admin registers **Email
  Servers**; the service must reach both the Zender URL and the
  mailbox providers. Demo: Email Servers — 1, Healthy, v1.0.0,
  **0/500 Mailboxes**.
- Live updates require Reverb or Pusher.
- Core side: channel slug `email` registered; core routes hold only a
  fallback 503 for `v1/internal/email/*`; queues `email` +
  `email-campaigns` exist. Webhook family `email.message.*`
  (received/sent/delivered/read/failed). API sends support idempotent
  retries.

## UNVERIFIED
- Sync mechanics (IMAP IDLE vs polling interval), thread-matching
  logic, the Warmer's algorithm (who gets mailed, how much, what
  pattern).
- Whether mail bodies are cached on the email server or only in core
  DB.

## Clean-room replacement spec
Email is the most open protocol in this tree — nothing closed needs
inventing:
1. Own service on **standard IMAP/SMTP libraries**: IMAP sync (IDLE
   where possible, else polling), SMTP send with per-mailbox
   credentials/OAuth (Gmail/Microsoft OAuth mirrors core's Socialite
   patterns).
2. Surface to core: Service Server kind `email` registration; mailbox
   connect/health; inbound mail → threaded conversation (subject /
   To / Cc / attachments); outbound send + status events
   (`email.message.*`); campaign pacing (speed, rolling daily limit,
   health ramp) enforced queue-side.
3. Warmer: our own simple warm-up scheduler (daily rising volume,
   seed addresses, engagement) — the algorithm is ours by design.
4. Bounces/suppression: SMTP reply codes + bounce-mailbox parsing
   feeding core's Suppressed Emails.

## Difficulty / risk
**Easy–Medium — the easiest server replacement in the tree.** IMAP/
SMTP are mature and documented; the real friction is Gmail/Microsoft
OAuth app verification and deliverability hygiene (SPF/DKIM/DMARC are
the tenant's own responsibility).
