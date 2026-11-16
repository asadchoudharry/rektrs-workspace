# PAID PLUGIN SPEC — WordPress / WooCommerce (integration)

- **Vendor price:** $59 — **FREE for Extended licence holders**.
  **Version:** v1.1.2 (6 Nov 2026) — the most mature integration.
- **Portal:** https://products.titansys.dev/zender/wordpress/
- **Demo state:** Active with the "Extended" label (Lane 4 §C).
- **Source status:** not stated (UNVERIFIED). We do not buy it; note
  the custom-licence negotiation may change what "free for Extended"
  means for us — UNVERIFIED until the licence lands.

## Purpose
Connect WordPress + WooCommerce to messaging, contacts and flows:
notifications, form actions, phone sign-in.

## Features
Notification rules (choose recipient, write messages with merge
tags, delay delivery up to 30 days; routing follows the connected
site's policy). **Form-plugin actions** — Contact Form 7, WPForms,
Gravity Forms, Fluent Forms, Ninja Forms, Elementor Pro get native
messaging actions, with optional contact sync to a tag/group.
WooCommerce order rules (New Order, Customer Note, native order
statuses, Low Stock, Out Of Stock; checkout consent works with
classic and block checkout; HPOS supported). Contact sync on
registration/profile change with role tags; WooCommerce orders sync
contacts + optional checkout consent for flows. Consent-based cart
reminders (shopper consent checkbox unticked by default; recovery
links signed, expiring, single-use; cart data removed on uninstall).
Phone verification and sign-in (verify at registration, second step
for selected roles, passwordless login, phone password reset). Can
also load the Website Chat and Web Push widgets when those plugins
are active and plan-allowed.

## Workflow
Upload → activate → enable WordPress + API Access on the plan →
download the **branded connector** from Integrations → WordPress:
Plugins > Add New > Upload → activate → Connection page: Connect →
approve in Zender → Test Connection → review routing summary →
enable notifications.

## Logic / technology
Requires WordPress 6.6+, PHP 8.1+; WooCommerce 9.0+ only for store
features. Core support: `integration_site_routing` table and core
routes `integrations.site`, `integrations.woocommerce.connect`,
`integrations.woocommerce.events` (Lane 5 §6). Connected Stores limit
shared with Shopify. Connector pattern: site address baked into the
branded download; routing managed on the Zender side.

## Data it touches
Contacts (sync), conversations/messages, `integration_site_routing`.

## Dependencies
API Access plan switch; Website Chat / Web Push plugins (optional,
for widget loading); OTP for phone sign-in.

## OUR REBUILD SPEC
- **Plugin type:** `integration` (runtime contract) + a WordPress
  plugin (PHP) as connector half.
- **Key interfaces:** Connect approval flow, event rules engine
  mapping WP/Woo hooks → sends via tenant API, contact sync with
  role tags, cart-reminder scheduler with signed single-use links,
  uninstall cleanup (cart records always deleted; rest per the
  "Delete Data On Uninstall" setting).
- **Priority:** Phase 4, integrations group — likely our highest-
  demand integration (WordPress is the most common tenant stack).
- **Difficulty:** Medium.
