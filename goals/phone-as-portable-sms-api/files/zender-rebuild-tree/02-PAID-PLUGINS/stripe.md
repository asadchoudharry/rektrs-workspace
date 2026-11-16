# PAID PLUGIN SPEC — Stripe (payment gateway)

- **Vendor price:** $39 (Regular-licence rate; "reduced price" for
  Extended holders, amount never stated). **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/stripe/
- **Source status:** not stated on the product page (UNVERIFIED). We do not buy it.

## Purpose
Accept subscription and one-time payments in Zender through Stripe —
plan purchases, renewals and credit top-ups.

## Features (vendor page)
Cards Visa/Mastercard/Amex/Discover/Diners Club/JCB/UnionPay, Link,
Apple Pay, Google Pay; subscription payments; payment retries; payment
method updates; refunds; invoices/receipts; failed-payment handling;
webhook support.

## Workflow
Upload plugin in Admin > Plugins → activate → enter Stripe API keys →
test payment → select Stripe as gateway in Admin > Plan > Payments →
customers pay at checkout; subscription lifecycle is webhook-driven.

## Logic / technology
Standard gateway pattern shared by all five $39 gateways. Core already
ships `stripe/stripe-php v20.0.0` (Lane 5 §2) and the billing engine's
webhook idempotency (`gateway_webhook_events`). The setup fee is
collected with the first payment on Stripe. Stripe also serves as a
**Payment Links provider** for tenants (their own accounts) — see
`../01-CORE-MODULES/payment-links.md`; the two roles must not be
conflated.

## Data it touches
`gateways`, `gateway_customers`, `gateway_webhook_events`,
`subscriptions`, `transactions`, `payment_accounts`.

## Dependencies
Core billing (`../01-CORE-MODULES/plans-billing-credits.md`); a Stripe
account + API keys (operator's own).

## OUR REBUILD SPEC
- **Plugin type:** `payment_gateway` (`app/Plugins/PaymentGateways/Stripe/`).
- **Contracts:** `PaymentGatewayPlugin` + `SupportsBillingPeriods`,
  `SupportsOneTimePurchase`, `SupportsPlanChange`, `SupportsRefund`,
  `SupportsSetupFee`, `InspectsRenewalPlan`, `ChargesPlanUpgradeInPlace`
  (implement the ones Stripe supports — it supports all of these per
  the feature list). Reference implementation to study: core's PayPal
  plugin (Lane 5 §5.6).
- **Key interfaces:** config schema (publishable key, secret key,
  webhook secret — `sensitive` fields), checkout session creation,
  webhook endpoint with signature verification feeding
  `gateway_webhook_events`, renewal processing job, refund path that
  triggers core's refund cascade (subscription end / pack return /
  referral clawback).
- **Priority:** Phase 4, payments group — **first gateway we build**
  (master plan: "Payments: Stripe + local").
- **Difficulty:** Medium. The SDK is in core; the work is lifecycle
  correctness (retries, dunning, plan change proration) and webhook
  idempotency.
