# PAID PLUGIN SPEC — Mobile App (Extra) — **full source exists; we still build our own**

- **Vendor price:** $150. No Extended discount stated on the page.
  **Version:** v1.0.0 (7 Nov 2026). Classed as an "Extra".
- **Portal:** https://products.titansys.dev/zender/mobile-app/
- **Demo state:** Admin Settings > Mobile App shows a demo APK
  (`zender-demo-mobile-v5.0.4.apk`, 99 MB, v1.0.0) with Firebase push
  "Configured" (Lane 4 §D).
- **Source status:** **YES — full Flutter source included** (the only
  paid item with source), plus a rebrand tool and an offline
  step-by-step HTML guide; updates free. Source may **not** be resold
  or redistributed — build/publish for your own Zender site only.
  Support does not cover building/signing/publishing. Checkout asks
  for the CodeCanyon username.
- **Our decision (master plan Phase 5):** build our own app against
  core's mobile API; buying the $150 source remains an open option to
  re-decide in Phase 5. This file is the feature spec either way.

## Purpose
The Messenger in the pocket of workspace agents and owners (Android +
iOS): inbox work on the go, plus owner modules.

## Features
**Inbox:** search, filters, views; open threads, reply, internal
notes, attachments, record/play voice messages, read emails, contact
details; start a conversation with a contact, a phone number or a
Telegram user; template messages. **Conversation actions:** assign,
transfer or move to a team; label, priority, snooze, pin, mark
unread, resolve/reopen; macros; AI summary; pause AI replies; copy,
retry, unsend, react to and edit messages where the channel supports
it; see a contact's orders with payment and COD status. **Live
updates + push:** inbox and unread badges update in real time; push
opens the right conversation when tapped; push uses a Firebase
project **you own**. **Owner modules** (each shows only when the site
enables it): overview/inbox metrics, contacts (create/edit/groups),
campaigns (delivery stats, cancel), call history, channel status,
USSD, WABA template statuses, members, billing (invoices, credit
history), support tickets. **Sign-in & security:** password, 2FA, or
sign-in code with QR scanning; password reset; optional biometric
lock; review signed-in devices; delete account from the app.
**Branding:** rebrand from one configuration file (app name,
application ids, icons, splash, monochrome notification icon in brand
colour); follows the site's theme presets, light and dark.
**Languages:** English, Arabic, Japanese built in with RTL; more
languages arrive from the site's translation editor while the app
runs — no rebuild. **Tablets:** two-pane layouts for inbox, contacts,
campaigns.

## Workflow (vendor)
Set name/ids/icons/splash in the config file → run the rebrand tool →
create your own Firebase project for push → build Android, or iOS on
a Mac with Xcode → submit from your own developer accounts, or offer
the Android APK as a direct download from the dashboard.

## Logic / technology
The **mobile API is core**: `routes/mobile.php` (~117 routes),
`mobile_devices`, `mobile_sign_in_tokens`, theme via
`api.apps.theme`, translations via `api.apps.translations`, admin APK
management via Settings > Mobile App + `mobile:install-apk`
(Lane 5 §6, Lane 6 §7). Requirements: Android 8.0+ / iOS 15.0+; a
Zender site with Mobile App enabled in admin settings; own Play/App
Store developer accounts; Mac + Xcode for iOS.

## Data it touches
Everything the web inbox touches — through the mobile API only.

## Dependencies
Core mobile API; own Firebase project; developer accounts.

## OUR REBUILD SPEC
- **Plugin type:** N/A — this is a **client app**, not a server
  plugin. The server side is core; the deliverable is a Flutter app
  in its own repo. Clean-room detail: `04-NO-SOURCE/mobile-app.md`.
- **MVP scope (build first):** inbox (views/filters), conversation
  screen (reply, notes, attachments, voice notes), conversation
  actions (assign/label/priority/snooze/resolve), push (own Firebase;
  tap → conversation), channel status + credits overview.
- **Second tier:** contacts CRUD, campaigns (stats/cancel), call
  history, USSD screen, billing (invoices/credits), members, tickets.
- **Branding:** single config file (name/ids/icons/splash/colour);
  theme + translations fetched from core endpoints at runtime.
- **Priority:** Phase 5 (master plan — decide build-vs-buy-$150 then;
  the web inbox carries operations until then).
- **Difficulty:** Medium. Backend is ready; the client is a real but
  bounded product — MVP scope discipline is the risk control.
