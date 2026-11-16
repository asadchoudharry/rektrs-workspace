# PAID PLUGIN SPEC — Telegram Store

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/telegram-store/
- **Demo state:** Active/Configured, type "Telegram Extension,
  requires Telegram" (Lane 4 §C); tenant Integrations lists it.
- **Source status:** not stated (UNVERIFIED). We do not buy it.

## Purpose
Sell products inside Telegram: a storefront in the chat, orders and
payments through Zender.

## Features
Storefront + product catalog inside Telegram; product images and
variants; shopping cart; Zender checkout (one-time payments and
subscriptions); order management, shipping and tax; sales analytics.

## Workflow
Upload → activate → enable Telegram + Telegram Store + API Access on
the plan → connect a Telegram bot → import products → customers open
the store in Telegram, add to cart, pay with Zender checkout.

## Logic / technology
An **extension plugin**: type `telegram_extension`, parent = Telegram
channel (Lane 5 §5.2 — an extension cannot activate unless its parent
is active). Commerce data is core: `commerce_stores`,
`commerce_products`, `commerce_product_variants`, `commerce_carts`,
`commerce_checkouts`, `commerce_orders`, `commerce_order_events`,
`commerce_customer_links`, `shipping_addresses`; `commerce:tick` runs
every minute. Webhooks: `commerce.order.*` (+ `cod_confirmed`,
`cod_cancelled`). The vendor also bundles a telegram-store JS build
step in the frontend build (Lane 5 §2).

## Data it touches
`commerce_*` tables; `payment_accounts` (checkout); conversations for
order chats.

## Dependencies
**Telegram plugin (ours) must exist first**; API Access plan switch.

## OUR REBUILD SPEC
- **Plugin type:** `telegram_extension` (parent `telegram`).
- **Key interfaces:** storefront rendering inside Telegram (inline
  keyboards / web-app surface — UNVERIFIED which the vendor uses;
  decide at build time from Telegram's current capabilities), catalog
  sync from `commerce_products`, cart/checkout against core commerce
  services, order events → webhooks + Messenger notifications.
- **Priority:** Phase 4, integrations group — after Telegram channel.
- **Difficulty:** Medium.
