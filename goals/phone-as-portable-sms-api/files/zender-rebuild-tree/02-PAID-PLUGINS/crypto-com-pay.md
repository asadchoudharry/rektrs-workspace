# PAID PLUGIN SPEC — Crypto.com Pay (payment gateway)

- **Vendor price:** $39 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/crypto-com/
  (catalogue name "Crypto.com Pay"; `/zender/crypto-com-pay/` is a 404).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Subscriptions and one-time payments in cryptocurrency via Crypto.com
Pay.

## Features
Crypto payments; subscriptions; retries; payment-method updates;
refunds; invoices/receipts; failed-payment handling; webhook support.

## Workflow
Same gateway pattern: upload → activate → Crypto.com Pay API keys →
test → select in Admin > Plan > Payments.

## Logic / technology
No Crypto.com SDK in core (Lane 5 §2) — REST + webhooks. Crypto
payments have slow/irreversible settlement semantics; how the vendor
maps those onto subscription renewals is UNVERIFIED beyond the page's
claims.

## Data it touches
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`subscriptions`, `transactions`.

## Dependencies
Crypto.com Pay merchant account + keys; core billing.

## OUR REBUILD SPEC
- **Plugin type:** `payment_gateway`.
- **Contracts:** `PaymentGatewayPlugin` + capabilities as the API
  allows (one-time at minimum; subscription support to be verified
  against the live Crypto.com Pay API at build time).
- **Key interfaces:** config schema, payment intent creation, webhook
  verification + idempotency, refund handling (note: crypto refunds
  may be manual — design the admin UX for that case).
- **Priority:** Phase 4, payments group — last of the gateways; only
  if crypto-paying customers actually appear.
- **Difficulty:** Medium (Medium-Hard on refund/renewal edge cases).
