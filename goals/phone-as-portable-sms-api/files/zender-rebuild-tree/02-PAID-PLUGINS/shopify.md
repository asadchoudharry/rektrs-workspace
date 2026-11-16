# PAID PLUGIN SPEC — Shopify (integration)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/shopify/
- **Demo state:** Active/Configured; tenant Integrations lists Shopify
  with connection details + event counts (Lane 4 §§B, C).
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Turn Shopify order/payment/checkout events into automated customer
messages (SMS/WhatsApp) with consent-aware sending.

## Features
Store events — order, payment, cancellation, refund, fulfilment,
delivery, abandoned checkout — feed shared **Store Automation**
triggers. **COD confirmations** with writebacks (add order tags, or
cancel an order with restocking — without requesting a refund or a
Shopify customer notification). **Abandoned-checkout reminders** that
check opt-outs, the store marketing switch, purchase status and
sending hours; a completed checkout or matching purchase stops
recovery automatically. Consent-aware sending from Shopify customer
records (unknown consent = no cart reminder; explicit SMS consent
required before US reminders). Tabs: Stores, Orders, Automations,
Messages (per permissions) with connection health, order/COD status,
shared automations, message activity. Privacy: customer-redaction
events erase that customer's store data; raw webhook payloads cleared
after 7 days; delivery rows deleted after 30 days; deactivating keeps
store/order history.

## Workflow
Upload → activate → Admin > Plans > Integrations: enable Shopify, set
Connected Stores limit, enable Flows + channels → create an app in
your own Shopify Dev Dashboard organisation with all five scopes →
install on store → Integrations > Shopify > Connect Store (myshopify
domain + Client ID + Client Secret).

## Logic / technology
Scopes: `read_orders, write_orders, read_customers,
read_fulfillments, read_checkouts`. App and store must be in the same
Shopify organisation; access tokens renew automatically. Connected
Stores limit is **shared with WordPress stores**. Requires public
HTTPS webhooks, scheduler + queue worker. Sends go through core
channels (consent + opt-out state from `contacts-forms.md` governs).

## Data it touches
Contacts (sync + consent), conversations/messages, store/order data
(plugin-side; core has `integration_site_routing` for site connectors).

## Dependencies
A Shopify store + own Dev Dashboard app; Flows; sending channels.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract).
- **Key interfaces:** Shopify webhook ingest (signature-verified,
  idempotent, 7-day raw retention), event → Store Automation trigger
  mapping shared with WordPress/WooCommerce where core expects it,
  COD writeback actions, consent gate before any reminder send,
  Connect Store OAuth flow with token auto-renewal.
- **Priority:** Phase 4, integrations group.
- **Difficulty:** Medium (Hard on consent/privacy edge cases — copy
  the vendor's stated retention rules exactly).
