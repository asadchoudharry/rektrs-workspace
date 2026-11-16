# PAID PLUGIN SPEC — YooKassa (payment gateway)

- **Vendor price:** $39 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/yookassa/
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Subscriptions and one-time payments via YooKassa (Russia/CIS-focused).

## Features
Visa/Mastercard/Mir/SberPay; subscriptions; retries; payment-method
updates; refunds; invoices/receipts; failed-payment handling; webhooks.
Setup fee is collected with the first payment on YooKassa.

## Workflow
Same gateway pattern: upload → activate → API keys → test → select in
Admin > Plan > Payments.

## Logic / technology
Core ships `yoomoney/yookassa-sdk-php ^3.13` (Lane 5 §2) and a
scheduled `yookassa:process-renewals` command (00:30 daily) — renewals
are polled, not purely webhook-driven.

## Data it touches
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`subscriptions`, `transactions`.

## Dependencies
YooKassa shop account + keys; core billing.

## OUR REBUILD SPEC
- **Plugin type:** `payment_gateway`.
- **Contracts:** `PaymentGatewayPlugin` + Supports* set; renewal job
  registered via plugin schedule hook (mirror the core command name
  expectation).
- **Key interfaces:** config schema (shop id, secret key), payment +
  subscription creation via bundled SDK, webhook/polling renewal
  reconciliation, refunds.
- **Priority:** Phase 4, payments group — on demand only (CIS market
  is not our launch market).
- **Difficulty:** Medium.
