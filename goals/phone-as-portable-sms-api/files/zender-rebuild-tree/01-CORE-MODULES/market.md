# CORE — Market (in-dashboard shop)

**Status: core-owned (purchased). Not a plugin marketplace — a shop
where the operator sells products to tenants.**
Sources: Lane 2 (Market), Lane 4 §§A–B, Lane 5 §4/§9-F3.

## Purpose
Operator-run store inside the dashboard: tenants browse and buy
hardware, physical goods, digital downloads, licence keys and services
with their account balance/checkout. **This is how we will sell modems
and Bridge Adapters** (SIM7600 boards, ESP32 adapters) to tenants.

## Screens / pages
- Admin > Market: Products / Orders tabs, Categories, New Product.
  Demo: 24 draft physical products ($25–$144, stock 0).
- Tenant > Market: product grid; My Orders (demo: 24 orders,
  DEMO-ORDER-*; 16 Delivered / 4 Cancelled on page 1).
- No cart — **1 product per order.**

## Features + rules
- Product types: Hardware / Physical / Digital Download (≤ 100MB) /
  License Keys (`.txt`/`.csv` ≤ 2MB) / Service.
- Order lifecycle: Pending Payment → Paid → Processing → Shipped →
  Delivered / Refunded / Cancelled. Unpaid orders auto-cancel after
  48h (bank transfer: 14 days) via `market:expire-pending` (hourly).
- Refund revokes downloads and licence codes.
- Market is **not plan-gated**; agents cannot buy (owners/admins can).
- Admin Billing settings: Market Enabled toggle, Ships To (demo:
  Worldwide).

## Data (tables)
`market_categories`, `market_products`, `market_orders`,
`market_order_events`, `market_license_codes`. (Commerce tables —
`commerce_*` — belong to tenant storefronts like Telegram Store, not
to this Market.)

## API surface
Web UI only in core routes; webhooks `commerce.order.*` are the
tenant-commerce family (see `07-API-MAP.md`) — Market order events are
tracked in `market_order_events`. UNVERIFIED: whether Market orders
emit outgoing webhooks (not in the Lane 2 catalogue).

## Keep / extension notes
- Core-owned. Note the naming trap Lane 5 §9-F3 cleared up: the
  `market_license_codes` table is THIS shop's licence-key inventory —
  it has nothing to do with vendor licensing of Zender itself.
- Our hardware fulfilment (modem/adapter shipping) is an operations
  process on top of these order states; no code needed.
