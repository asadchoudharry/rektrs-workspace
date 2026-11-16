# CORE — Plans, Billing & Credits (the SaaS engine)

**Status: core-owned (purchased).**
Sources: Lane 2 (Plans & Billing), Lane 4 §§A–B, Lane 5 §4 + seeders.

## Purpose
Everything commercial: plan catalogue, subscriptions, the credit
ledger, credit packs, vouchers, invoices, refunds — and the feature
switch/limit system every other module obeys.

## Screens / pages
- Admin: Plans (demo: Demo $0 Private, Free $0, Starter $19, Pro $49
  "Popular", Enterprise $199 — drag-reorder, Edit/Deactivate/Delete),
  Credit Packs (8 in demo), Vouchers (24; New + Bulk Generate),
  Subscriptions (41), Transactions (115; TXN- IDs; filters by gateway/
  type/ref/status; Completed/Pending/Refunded/Failed).
- Tenant Billing: current plan + renewal date, credits balance
  (demo 9,034.08, +2,000/period, rollover on), Buy Credits, Redeem
  Voucher, History (Grants/Debits), links to Referrals, Message Costs,
  AI Usage.
- Seeded plans (`PlanSeeder`): Free $0, Starter $19, Pro $49,
  Enterprise $199 — **our own pricing will differ; these are vendor
  demo values.**

## Plan model
- Cycles: Monthly / Yearly / Lifetime, plus a one-time **Setup Fee**.
- **Feature switches** (a missing switch → 403 `feature_not_in_plan`):
  SMS, WABA, Messenger, Inbox Automation, **White Label**, API Access,
  flows, support, `messenger_custom_domain`, `payment_links`,
  `appointment_booking`, `ai_agents`, `ai_flow_generation`, plus every
  plugin's own plan keys (channels register theirs).
- **Limits** (blank = unlimited, 0 = none): Contacts, Team Members,
  Flows, Phone Numbers (WABA + WhatsApp shared), `sms_monthly`,
  `waba_monthly`, inbound monthly, `max_storage_mb`,
  `max_file_size_mb`, `support_open_tickets`.
- Demo comparison facts (vendor's demo gating, ours will differ):
  White Label = Pro+; Messenger Custom Domain = Pro+; Custom Roles =
  Enterprise; API Access = Starter+; OTP = Starter+; Webhooks = Pro+;
  AI Agents = Pro+; Call Logs = Pro+; Bookings = Pro+; Drips =
  Starter+; RCS/Telegram/Phone Bridge/GSM Modems = Enterprise only.

## Subscription lifecycle
`subscriptions:manage` runs hourly. Reminders 3 days and 1 day before
renewal; subscription expires 7 days after a failed renewal; pending
states are cleaned after 14 days; on cancel, the plan runs to period
end, then the workspace falls to the first free plan. Monthly plan
credits granted by `subscriptions:grant-monthly-credits` (hourly).

## Credits
- Spend order: monthly allowance first, then purchased credits.
  Overage Cost per unit (blank = 1). Failed/cancelled sends refund.
  Ad-click replies are free. Inbound messages above allowance are
  recorded but get no auto-reply.
- **Credit Packs:** Name / Credits / Bonus / Price / Plan Availability;
  a pack with purchases cannot be deleted.
- **Vouchers:** Subscription or Credits type, Max Uses, bulk generate
  ≤ 1,000 with a Prefix.
- One wallet serves SMS + WABA + AI (see `ai-providers-credits.md`).

## Invoices & refunds
PDF invoices from Billing History (mpdf). Gateway webhook events are
idempotency-recorded (`gateway_webhook_events`). Refunds: partial or
full; a full refund ends the subscription / returns pack credits /
returns plan credits (yearly: per month) / claws back referral
commission. PayPal webhook refunds are protected against double-count.

## Data (tables)
`plans`, `plan_ai_provider`, `plan_service_servers`, `plan_wa_servers`,
`plan_usage_alerts`, `subscriptions`, `transactions`, `credit_packs`,
`credit_pack_plan`, `credit_reservations`, `credit_transactions`,
`vouchers`, `voucher_redemptions`, `payment_accounts`, `disputes`,
`gateways`, `gateway_customers`, `gateway_webhook_events`.

## Gateways in core
Bank Transfer + PayPal are core plugins (Lane 5 §5.6). PayPal webhook:
`/api/payment-gateways/paypal/webhook`; events
`BILLING.SUBSCRIPTION.*`, `PAYMENT.SALE/CAPTURE.COMPLETED/REFUNDED`;
signature verified; events older than 5 min ignored; 25 currencies.
All other gateways are plugins — our rebuilds in `02-PAID-PLUGINS/`
(stripe, paystack, razorpay, crypto-com-pay, yookassa, freemius).
Setup fee is collected with the first payment on Stripe / YooKassa /
Razorpay / Bank Transfer.

## Keep / extension notes
- Core-owned. **Currency: one currency platform-wide, no conversion.**
- Our payment gateway plugins implement core contracts
  (`PaymentGatewayPlugin` + capability interfaces) — never patch the
  billing engine.
- Licence note: charging end users is exactly what the Regular licence
  forbids — commercial use of this module waits for the owner's custom
  licence (see `00-OVERVIEW.md`).
