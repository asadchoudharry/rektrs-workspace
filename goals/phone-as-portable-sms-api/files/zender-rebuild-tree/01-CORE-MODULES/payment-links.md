# CORE — Payment Links

**Status: core-owned (purchased).**
Sources: Lane 2 (Payment Links), Lane 4 §B, Lane 5 §4.

## Purpose
A workspace creates hosted payment links and collects money **with its
own** Stripe / Razorpay / Paystack account — the platform never touches
the funds. Links plug into Flows (send a link, wait for payment).

## Screens / pages (tenant, Lane 4)
- Contacts area > Payments: tabs Payment Links / Providers; 0 links in
  the demo workspace. Provider connection happens on the Providers tab.
- Public checkout page (branded; "Powered by {site name}" footer —
  Lane 5 §10). Expired links are swept by `payments:expire-links`
  (every 15 min).

## Features + rules
- Requires the plan switch `payment_links` — otherwise the module is
  off (this is a plan feature, not a plugin).
- Stripe: webhook auto-created for the connected account. Razorpay:
  listens for `payment_link.paid`. Paystack currencies: NGN / USD /
  GHS / ZAR / KES.
- Flow integration: **Send Payment Link** node → Wait → **Payment
  Received** trigger starts/continues automations.
- Successful payment fires webhook `payment.paid` and is recorded in
  `payment_links` + the workspace's payment account.

## Data (tables)
`payment_links`, `payment_accounts`.

## API surface
Public checkout routes in `routes/payments.php`; flow nodes/triggers
above; webhook `payment.paid`.

## Plan gates
`payment_links` switch (see `plans-billing-credits.md`).

## Keep / extension notes
- Core-owned and **distinct from billing gateways**: billing gateways
  (Stripe plugin etc.) collect *our* subscription money from tenants;
  Payment Links collect *the tenant's* money from their customers using
  the tenant's own provider account. Do not merge the two when
  building the Stripe gateway plugin — the gateway plugin must also
  serve as a Payment Links provider where core expects one.
- A local (Pakistani) payment method for tenant links is UNVERIFIED in
  core (only Stripe/Razorpay/Paystack are named) — if we add one, it
  attaches as a provider here plus a `payment_gateway` plugin for
  billing.
