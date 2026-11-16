# PAID PLUGIN SPEC — Paystack (payment gateway)

- **Vendor price:** $39 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/paystack/
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Subscriptions and one-time payments via Paystack (Africa-focused).

## Features
Visa/Mastercard/Verve, bank transfers, USSD; subscriptions; retries;
payment-method updates; refunds; invoices/receipts; failed-payment
handling; webhooks. As a Payment Links provider its currencies are
NGN/USD/GHS/ZAR/KES (`../01-CORE-MODULES/payment-links.md`).

## Workflow
Same gateway pattern: upload → activate → API keys → test → select in
Admin > Plan > Payments → webhook-driven subscriptions.

## Logic / technology
Core has a scheduled `paystack:process-renewals` command (00:30 daily,
Lane 5 §12) — renewal polling is part of the expected design, not just
webhooks. No Paystack SDK in core's composer list (Lane 5 §2) —
integration is REST-level. UNVERIFIED: exact API version the vendor
plugin targets.

## Data it touches
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`subscriptions`, `transactions`.

## Dependencies
Paystack account + keys; core billing.

## OUR REBUILD SPEC
- **Plugin type:** `payment_gateway`.
- **Contracts:** `PaymentGatewayPlugin` + billing-period / one-time /
  plan-change / refund / setup-fee capabilities as supported.
- **Key interfaces:** config schema (public/secret keys, sensitive),
  charge + subscription create/cancel, webhook verify + idempotent
  ingest, a `paystack:process-renewals`-style scheduled renewal job
  registered via the plugin's schedule hook.
- **Priority:** Phase 4, payments group — after Stripe; only if our
  customer base needs African payments.
- **Difficulty:** Medium.
