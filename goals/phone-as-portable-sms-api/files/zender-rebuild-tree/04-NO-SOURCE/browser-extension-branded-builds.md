# NO-SOURCE — Browser Extension Builds + Per-Site Branded Connectors

Full evidence: Lane 6 §8 + Lane 3. Two paid surfaces share one
pattern: **the server generates a per-site branded build** for the
tenant to download.

## The pattern
- **Browser Extension ($59):** each site downloads its own build from
  the dashboard (site name + site address baked in); installed via
  Developer mode → Load unpacked; no Web Store listing.
- **Integration connectors:** WordPress, WHMCS, Perfex, Blesta,
  Flarum, osTicket, Odoo, Shopify (and Website Chat / Web Push
  generated WordPress plugins) are **branded downloads** — the
  connector package has the messaging site's address fixed inside;
  most have **no API-key field at all**: the admin clicks "Connect",
  approves in Zender, and routing (channels/senders/fallbacks) is
  managed on the Zender side. Core evidence: `integration_site_routing`
  table + `app/Services/Integrations/*` (Lane 5 §§4, 6).

## Behaviour evidence
- Extension: right-click phone/email → action; popup inbox (unread
  counts, recent conversations, templates, contact create); calls via
  Messenger with **server-side rights checks per action**; realtime
  packaged worker + polling fallback; **packaged code only, no remote
  scripts**; connection token in local storage with **90-day expiry**;
  dashboard revocation per browser; update lock prompts new installs.
  Chromium 120+.
- Connectors: download → install in host app → Connect (approve in
  Zender) → Test Connection → routing on the Zender side. Each
  connector is written in its host's native form (WordPress plugin,
  WHMCS addon, Perfex module, Flarum Composer extension, osTicket
  plugin, Odoo add-ons in Python).

## UNVERIFIED
- The build-generation mechanism inside the vendor's system (template
  + config injection is the obvious reading, but no vendor code was
  seen).
- Whether the extension's source is ever provided (product page does
  not say; only packaged builds are described).

## Clean-room spec — adopt the pattern, not the code
1. **Build step for our connectors:** every integration we ship
   (Phase 4) gets a small packaging step that bakes the site URL +
   site name into the connector package before download — the tenant
   never copy-pastes API keys. *This UX is the actual value of the
   pattern*, and it is cheap: our connector source + a config-file
   swap + zip.
2. **Our Browser Extension:** Manifest V3 Chromium extension — popup
   inbox on the tenant REST API, context-menu actions (Send SMS /
   WhatsApp to this number/email), click-to-message; token expiry/
   revocation via core API keys. A per-site generated build is
   optional polish; a settings-entered site URL is acceptable for v1.
   Spec: `../02-PAID-PLUGINS/browser-extension.md`.
3. **Connector order** follows Phase 4 priorities: WordPress/
   WooCommerce first (most common tenant stack), then WHMCS, Perfex,
   Shopify, Odoo, and the rest on demand. Every connector runs purely
   on the core REST API + webhooks — **no companion server is ever
   needed for this family**.

## Difficulty / risk
**Easy–Medium per connector** (each host platform has its own plugin
API to learn; nothing closed sits in the way). Extension: **Easy**.
