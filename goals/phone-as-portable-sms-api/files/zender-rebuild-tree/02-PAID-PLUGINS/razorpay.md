# PAID PLUGIN SPEC — Razorpay (payment gateway)

- **Vendor price:** $39 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/razorpay/
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Subscriptions and one-time payments via Razorpay (India-focused).

## Features
Visa/Mastercard/RuPay, UPI, netbanking, wallets; subscriptions;
retries; payment-method updates; refunds; invoices/receipts;
failed-payment handling; webhooks. Setup fee is collected with the
first payment on Razorpay. As a Payment Links provider it emits the
`payment_link.paid` event core listens for.

## Workflow
Same gateway pattern: upload → activate → API keys → test → select in
Admin > Plan > Payments.

## Logic / technology
Core ships `razorpay/razorpay ^2.9` SDK (Lane 5 §2). Webhook-driven
lifecycle like the other gateways.

## Data it touches
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`subscriptions`, `transactions`, `payment_links` (provider role).

## Dependencies
Razorpay account + keys; core billing; Payment Links module for the
provider role.

## OUR REBUILD SPEC
- **Plugin type:** `payment_gateway`.
- **Contracts:** `PaymentGatewayPlugin` + the Supports* capabilities
  Razorpay offers; reference = core PayPal plugin.
- **Key interfaces:** config schema, subscription + order creation via
  the bundled SDK, webhook signature verification + idempotent ingest,
  refund cascade, Payment Links provider registration.
- **Priority:** Phase 4, payments group — after Stripe/Paystack; on
  demand (Indian customer base).
- **Difficulty:** Medium.
