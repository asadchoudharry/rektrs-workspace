# PAID PLUGIN SPEC — Freemius (payment gateway)

- **Vendor price:** UNVERIFIED — not on the products portal and not in
  the Lane 3 catalogue. **Version:** v1.1.0 (from the live demo's
  plugin list, Lane 4 §C — listed there as "Not installed", type
  Payment).
- **Portal:** none found. **Docs:** Lane 2 lists Freemius among the
  plugin payment gateways ("Plugin gateways: Stripe, Paystack,
  Razorpay, Crypto.com Pay, YooKassa, **Freemius**").
- **Source status:** UNVERIFIED. We do not buy it.

## What is known (only this)
1. It exists as a Zender payment-gateway plugin, v1.1.0, visible in the
   demo admin's plugin list but not installed there.
2. The vendor docs name it in the gateway list alongside the five $39
   gateways — so it presumably follows the same pattern (keys →
   checkout → webhook subscriptions).
3. Freemius itself is a hosted licensing + payments platform for
   software sellers (public knowledge); how this plugin maps Zender
   plans onto Freemius products/pricing is **UNVERIFIED**.

Everything else — price, feature list, workflow, requirements — is
UNVERIFIED and must be established from the vendor before any build
decision. Do not guess.

## OUR REBUILD SPEC (provisional)
- **Plugin type:** `payment_gateway` (if built at all).
- **Priority:** None currently. Our gateway order is Stripe → local →
  others on demand (`08-REBUILD-ROADMAP.md`). Freemius only becomes
  relevant if we ever sell through Freemius's own marketplace/model.
- **Difficulty:** UNVERIFIED (presumably Medium, like its siblings).
- **First step if ever revived:** obtain the vendor's Freemius plugin
  page/docs and re-audit; replace this file's UNVERIFIED marks.
