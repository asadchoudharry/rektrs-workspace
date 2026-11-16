# CORE — Referral Programme & Partner Network (Shared Network)

**Status: core-owned (purchased). Two distinct systems in one file:
(A) referrals = tenants earning credits for bringing customers;
(B) Partner Network = partners renting their sending lines to others.**
Sources: Lane 2 (Referral, Shared Network), Lane 4 §§A–B, Lane 5 §4.

## A. Referral programme

### Screens
Admin > Referrals: 16 commission entries in demo (Referrer /
Commission / Withdrawn / Balance) + Settings. Tenant side: Billing >
Referrals link, referral code/link per user.

### Rules (admin defaults)
Commission **10%**, Signup Bonus 0, Min Redemption 5, **100 credits per
1.00** currency, Attribution window 30 days. Commission is earned once,
on the referred user's **first real payment**; a refund claws it back.
Self-referral is blocked. Redemption is **credits only** (no cash out).

### Data
`referral_codes`, `referrals`, `referral_credit_transactions`.

## B. Partner Network (Shared Network)

### Concept
Partners share their own sending lines — Android devices, Phone Bridge
lines, GSM modem lines — and other workspaces send through them for
credits. **WhatsApp lines can NOT be shared.** Admin (platform) lines
earn full platform revenue.

### Screens (Lane 4)
- Admin > Partner Network: Partners (12 workspaces; Lines 1–4,
  Performance, Commission, Approved/Suspended, Grant Partner);
  Payouts (total owed $1,786, 24 requests, Bank Transfer, Paid/
  Declined); Lines (12, all Offline in demo; Network ID like `SIM1`;
  Price/Text $0.2–$0.8; Shared / Not Shared / Paused); Reports (a report
  puts earnings on hold until an admin decides).
- Tenant > Network: in the demo it showed "Shared network is currently
  unavailable" (feature state depends on plan + admin enablement).

### Rates & rules (admin settings, Lane 4 §D)
Text $0.1–$5 per message, MMS $0.2–$10 (MMS not actually available
yet), calls $0.5–$20 per minute. Platform commission **20%**. Earnings
hold **72h**. Min payout 100 credits (demo shows $100). Payout methods:
Bank Transfer / PayPal. Reply Window 7 days (replies route back to the
sending workspace). Quality auto-pause: below 80% success over 50
messages / 7 days. Sender limits: 200/hour, 1,000/day per line. Trust
mode: Auto (demo).

### Data
`partners`, `partner_ledger`, `partner_payouts`, `network_lines`,
`network_line_country_rates`, `network_charges`, `network_reply_routes`,
`network_reply_route_events`, `network_reports`. Scheduler:
`network:reserve-call-minutes` (every minute), `network:release-
earnings` + `network:health` (15 min).

### API surface
`network.lines`, `network.quote` — quote a send through the network
before sending. OTP can deliver over Partner Lines (a channel option in
`otp-verification.md`).

## Plan gates
Shared Network is a plan feature (demo showed it on Starter/Pro —
oddly not on Enterprise in the vendor's demo comparison; our own plan
design decides). 

## Keep / extension notes
- Core-owned. Our GSM Modem / Phone Bridge replacements
  (`04-NO-SOURCE/telephony-server.md`) automatically become shareable
  line types once they register as channels — no extra network code.
- Fraud surface to watch when enabling: partner line quality and the
  report/hold flow are the only controls; keep Trust manual until
  volume justifies Auto.
