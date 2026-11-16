# NO-SOURCE — Mobile App (agent/owner client)

Full evidence: Lane 6 §7 + Lane 3 (Mobile App page) + Lane 4 §D.
Vendor sells this as the only full-source paid item ($150 Flutter) —
**we are not buying it**; this file is the clean-room client spec.
Feature spec: `../02-PAID-PLUGINS/mobile-app.md`.

## The key fact
**The mobile API is core.** `routes/mobile.php` (~117 routes),
`mobile_devices` + `mobile_sign_in_tokens` tables, admin Settings >
Mobile App (APK slot, store links, Firebase status), the artisan
command `mobile:install-apk`, theme endpoint `api.apps.theme` and
translations endpoint `api.apps.translations` — all ship in the
purchased core. Only the client is missing.

## Behaviour evidence (what the client must do)
- **Inbox:** search/filters/views; threads with reply, internal
  notes, attachments, voice record/play, email reading, contact
  details; start conversations from a contact, a number, or a
  Telegram user; template messages.
- **Conversation actions:** assign/transfer/team, label, priority,
  snooze, pin, unread, resolve/reopen, macros, AI summary, pause AI
  replies, copy/retry/unsend/react/edit where the channel supports
  it; contact's orders with payment/COD status.
- **Realtime + push:** live inbox/unread badges; push (own Firebase
  project) opens the exact conversation on tap.
- **Owner modules** (each visible only when the site enables it):
  overview metrics, contacts CRUD/groups, campaigns (stats, cancel),
  call history, channel status, USSD, WABA template statuses,
  members, billing (invoices, credit history), support tickets.
- **Auth:** password, 2FA, or sign-in code + QR scan; password reset;
  biometric lock; signed-in device review; in-app account deletion.
- **Branding/i18n:** one config file (name, application ids, icons,
  splash, notification icon colour) + rebrand tool in the vendor
  model; theme presets (light/dark) follow the site; EN/AR/JA + RTL
  built in, more languages from the site's translation editor with
  **no rebuild**.

## UNVERIFIED
- Field-level payloads of the mobile API per screen (route surface is
  clear from `routes/mobile.php`; details are read at build time).
- The vendor app's offline behaviour / sync strategy.

## Clean-room spec (our own app)
1. **Client:** Flutter (one codebase, Android + iOS) against
   `routes/mobile.php`; auth via core mobile sign-in tokens
   (password / 2FA / code + QR). No new backend.
2. **MVP first:** inbox (views/filters), conversation screen (reply,
   notes, attachments, voice notes), conversation actions
   (assign/label/priority/snooze/resolve), push (own Firebase;
   tap → conversation), channel status + credits overview.
3. **Second tier:** contacts CRUD, campaigns (stats/cancel), call
   history, USSD screen, billing (invoices/credits), members, tickets.
4. **Branding:** single config (name/ids/icons/splash/colour); theme
   from `api.apps.theme`; translations from `api.apps.translations`
   at runtime (no rebuild for new languages).
5. **Distribution:** own Play Store account, or direct APK installed
   on the site via `mobile:install-apk`.

## Difficulty / risk
**Medium.** Backend ready; the client is a genuine product (realtime
inbox + push + voice notes). Risk control: frozen MVP scope — without
it this becomes a never-ending project. Phase 5; the web inbox
carries operations until then. The build-vs-buy-$150 decision is
revisited in Phase 5 with this spec as the yardstick.
