# Zender — Complete Component Map (2026-11-15)

**Source read:** the full documentation shipped inside the purchased CodeCanyon package
("Zender – WhatsApp & SMS Messaging SaaS with Shared Inbox, Campaigns and Chatbots",
CodeCanyon item 26594230) — all 43 documentation pages (`Documentation/md/`), the package
readme content (Welcome page), `llms-full.txt`, plus spot-checks of the shipped code
(`Install/composer.json`, app-slot services, in-app Android help topics) where the docs
pointed at them. Package version: **Zender 5.0.4** (`Install/.version`).

**Vendor, exactly as written in the docs:** **Titan Systems** — the documentation footer
links "Titan Systems" and "Support Center" to **https://titansys.dev**. The shipped code's
composer package name is `titansystems/zender-laravel`.

**How the vendor splits the product (the docs' own framing):**

> "Only `Install/` is required. `Documentation/` holds the main guides. Optional features
> are available to buy or download from the portal; each plugin's documentation ships in
> its plugin ZIP." — Welcome

> "The main script includes WABA, SMS Providers, and the Bank Transfer and PayPal
> gateways." — Optional Plugins

The docs call the download source simply **"the portal" / "the buyer portal"** — no
separate portal URL is printed anywhere in the package. The only vendor URL the docs give
is **titansys.dev**. Plugins reach the platform manually: the buyer downloads the plugin
ZIP from the portal and uploads it under Admin → Plugins ("Upload Plugin", ZIP up to
20 MB); each plugin's own guide ships inside its ZIP.

---

## 1. What IS in the purchased package — [IN-PACKAGE]

| Component | What it does | Path in the zip |
|---|---|---|
| Web platform (the "main script") | The whole SaaS: dashboard, Messenger shared inbox, campaigns, flows, drips, contacts, OTP, plans/billing, Market shop, landing builder, REST API, webhooks, referral program, shared network | `Install/` (Laravel 13 + React 19; ships with `vendor/` and compiled frontend — no build step) |
| VPS Auto Setup script | One-shot installer for a fresh Ubuntu 24.04 VPS (nginx, PHP, MySQL, Reverb, queue worker, scheduler, Let's Encrypt) | `Install/autosetup.sh` |
| Documentation | These 43 guides, readable offline | `Documentation/` (`index.html` + `md/`) |
| WABA channel | Official WhatsApp Business Platform via Meta Cloud API (numbers, templates, webhooks) — **core, not a plugin purchase** | inside `Install/` |
| SMS Providers channel + built-in driver catalog | SMS via cloud HTTP providers — built-in catalog incl. **Twilio, Telnyx, Vonage, Custom HTTP**; "The SMS Providers core plugin ships installed and active" | inside `Install/` (`app/Plugins/SmsProviders/`) |
| Bank Transfer gateway | Plan/credit-pack payments by manual bank transfer, admin-approved | `Install/app/Plugins/PaymentGateways/BankTransfer/` |
| PayPal gateway | Plan/credit-pack payments with auto-renewing subscriptions | `Install/app/Plugins/PaymentGateways/PayPal/` |
| Reverb realtime server | Live dashboard/inbox updates on your own VPS (Laravel Reverb, installed by Auto Setup) | inside `Install/` |
| Payment Links | Workspaces collect chat/flow payments through **their own** Stripe, Razorpay or Paystack accounts | inside `Install/` (feature of the main script — not the paid gateway plugins below) |
| In-app Android help topics | The gateway app's built-in help (pairing, permissions, updating, USSD, RCS…) rendered by the platform | `Install/resources/android-docs/` |

## 2. FREE from the vendor — [FREE-VENDOR] ★ the owner's "free" promise

All six are listed **"Free\*"** in the docs' Optional Plugins table. The footnote is the
condition, in the docs' own words:

> "* Free plugins are not part of the script. We provide them to verified buyers at our
> discretion, and we may change or withdraw access to them at any time."

> "These features are optional. Buy or download them from the portal."

So: source = **the vendor portal (Titan Systems, titansys.dev)**; condition = you must be a
**verified buyer** (the installation identifies itself with the Envato **Purchase Code**,
entered under Admin → Settings → General — "The code is stored encrypted and identifies
your installation"); access is discretionary and can be withdrawn. No price, no separate
purchase.

| # | Free component | What it adds (docs' words) | Notes from the rest of the docs |
|---|---|---|---|
| 1 | **Android Gateway** | "Send and receive SMS through your own Android phones." | This is the original Zender function. Plans gate it as the **Android Devices** feature: "Android Devices requires the free Android plugin" (Billing). Without it there is no phone-based sending at all. |
| 2 | **WhatsApp** | "Link WhatsApp numbers with a QR code." | The unofficial QR-pairing WhatsApp channel (distinct from the built-in official WABA). Its channel service is a long-running program that needs a VPS (Installation → Shared Hosting limits). |
| 3 | **SMPP** | "Connect SMS providers over SMPP." | An extra SMS provider driver; needs the SMS Providers channel active. |
| 4 | **WhatsApp Embedded Signup** | "Connect WhatsApp Business accounts through Meta's Embedded Signup, with optional WhatsApp Business app numbers (Coexistence)." | Extends the built-in WABA channel. |
| 5 | **Legacy API Wrapper** | "Accept WhatsApp sends from integrations built for the previous version's API." | Compatibility shim only; data movement is the Legacy Importer's job. |
| 6 | **Legacy Importer** | "Import users, contacts and active subscriptions from a legacy installation." | Reads the "Export for Zender 5" file (v3.12.0+) or a full DB export of the old install; devices/WhatsApp accounts/messages are set up again (Upgrade Guide). Only relevant if migrating an old Zender. |

### The Android gateway app (APK) itself

- **No APK and no Android source code are inside the CodeCanyon zip** (verified: the zip
  contains only `Install/` + `Documentation/`).
- The gateway app is distributed **through your own Zender installation**: the platform
  holds the APK in an "app slot" that the site owner fills, and users get it from the
  dashboard — in the app's own help words: **"Download [the app] from the Pair Device
  dialog and install it."** Updates likewise come from the installation's uploaded APK
  (72-hour grace, then required). Companion apps (Receiving, USSD, RCS) install/update
  from the gateway app's Settings on the phone.
- The docs bundled in this package never state in so many words "the APK is inside the
  Android Gateway plugin ZIP" — that detail lives in the plugin's own guide, which ships
  in the plugin ZIP from the portal. Classification: the app rides with the **free Android
  Gateway plugin [FREE-VENDOR]**; the exact packaging is **[UNCLEAR]** from this package
  alone (see §5).

## 3. PAID vendor plugins — [PAID-VENDOR]

All from the same portal; the docs state **no prices** (prices live on the portal only).
"Extended licenses include plugin discounts. Auto Update remains paid with either license."

| Plugin | What it adds |
|---|---|
| **Auto Update for Zender** | "Download and apply releases from the admin area." **Paid for everyone, including Extended license holders.** (Without it, updates are manual — see §4.) |
| Email | Send/receive email through connected mailboxes (own channel service; needs VPS) |
| Phone Bridge | Calls and texts through your own phone (ships a Windows bridge app slot) |
| RCS | RCS through Google Messages on a paired Android phone — **requires the free Android Gateway** |
| GSM Modems | Calls and texts through GSM modems (Windows/Linux modem apps + bridge firmware slots) |
| Website Chat | Website visitor chat widget + campaign popups |
| Web Push | Browser notifications to website subscribers |
| Telegram | Messaging through Telegram bots and accounts |
| Telegram Store | Sell goods/products in a Telegram Mini App (needs Telegram) |
| AI Agents | AI agents answering on channels, safe actions, human handover |
| Knowledge Base | Index workspace documents for AI answers |
| AI Flow Builder | Describe a flow, AI drafts it, edit by chat |
| MCP | Connect AI clients (e.g. Claude) to workspace tools/resources |
| WordPress | Connect a WordPress site to messaging, contacts and flows |
| Shopify | Order updates, COD confirmations, cart reminders |
| WHMCS | Billing/notifications/sign-in integration |
| Perfex | CRM notifications and sign-ins |
| Odoo | Database notifications and sign-ins |
| osTicket | Helpdesk notifications and sign-ins |
| Flarum | Forum notifications and phone verification |
| Blesta | Billing notifications and sign-ins |
| Admin API | Manage accounts/subscriptions/credits/vouchers from your own code via admin API keys (needs Zender 5.0.3+) |
| Google Sheets | Add/find/watch Sheets rows in flows |
| **Stripe** (gateway) | Card payments, global, automatic renewal |
| **Paystack** (gateway) | Card/bank/mobile-money — "built for Africa" |
| **Razorpay** (gateway) | UPI, cards, netbanking, wallets — India + global |
| **Crypto.com Pay** (gateway) | Crypto + fiat payments |
| **YooKassa** (gateway) | Payments via YooMoney (Russia) |
| **Freemius** (gateway) | Sell subscriptions via Freemius hosted checkout, tax handling, license sync |
| Appointment Booking | Booking page + in-chat appointments, flow reminders, Google Calendar sync |
| Browser Extension | Use workspace messaging from the browser |

## 4. Updates & licensing — how future Zender releases reach the buyer

- **Default path is manual and free:** download the new release from the **buyer portal**,
  upload `Install/` over the existing files (preserving `.env` and `storage/`), then run
  **System Upgrade** in the admin (the built-in Web Updater finalizes uploaded files; it
  "does not upload or fetch the release for you").
- **In-admin one-click updates are the paid Auto Update plugin** (§3) — paid on both
  license tiers.
- `php artisan zender:update` is explicitly **not** the buyer path: "It runs `git pull`,
  which needs a git working copy, and the download from the buyer portal deliberately
  ships without one."
- **Purchase Code:** entered under Admin → Settings → General; stored encrypted;
  "identifies your installation" (also switches on vendor Error Reporting). The docs
  describe no separate activation-server step for the main script, but sending can pause
  with error `license_unverified` — "Sending is temporarily unavailable. Contact support."
- Plugin updates: upload the newer plugin ZIP the same way; same/newer version updates in
  place and keeps settings; older versions are refused.

## 5. Third-party pieces the system depends on — [THIRD-PARTY]

| Piece | Why / condition |
|---|---|
| Meta developer app + WhatsApp Business account | Required for the built-in WABA channel (your own Meta app ID/secret, webhook, number registration — WABA guide) |
| SMS provider accounts (Twilio, Telnyx, Vonage, or any custom HTTP API) | Your own accounts/credentials + Sender IDs for the SMS Providers channel |
| PayPal developer app | Client ID/Secret + Webhook ID from the PayPal Developer Dashboard for the included PayPal gateway |
| Pusher Channels account (optional) | Paid third-party realtime, only for hosting that cannot run the built-in Reverb server (shared hosting) |
| AI provider accounts/keys (optional) | Core AI assist runs on providers you connect with your own keys, billed in workspace credits |
| S3-compatible storage (optional) | Files live on the server disk by default; S3-compatible storage is a built-in option |
| Let's Encrypt / Cloudflare (optional) | Auto Setup gets HTTPS certs from Let's Encrypt; wildcard workspace-subdomain certs optionally via a Cloudflare API token |

## 6. Unclear from the documentation — [UNCLEAR]

1. **The portal's exact URL.** The docs say only "the portal" / "the buyer portal"; the
   sole vendor URL printed anywhere in the package is **https://titansys.dev** (docs
   footer: "Titan Systems" / "Support Center"). The plugin download area presumably sits
   behind the buyer account there, but the docs do not spell out a downloads URL.
2. **Gateway APK packaging.** That the APK comes with the free Android Gateway plugin is
   the docs' clear implication (plugin model + "each plugin's documentation ships in its
   plugin ZIP" + phones download the app from the owner's own Pair Device dialog), but no
   page in this package states the APK's exact source file/location. Confirm inside the
   plugin ZIP once downloaded from the portal.
3. **Android app source code.** Never mentioned anywhere in the documentation — the docs
   treat all phone/bridge/modem apps as ready binaries the owner uploads into the
   platform's app slots. No source-code offer is documented.
4. **The end-user "Mobile App".** Admins can offer members a mobile app via a Google Play
   link, App Store link, or an uploaded APK (`php artisan mobile:install-apk`), but the
   docs never say where the owner obtains that app. Not in this package.
5. **Paid plugin prices.** The docs mark plugins "Paid" only; every price lives on the
   portal. "Extended licenses include plugin discounts" is the only pricing statement.

---

*Compiled 2026-11-15 from the purchased package's own documentation (Zender 5.0.4).
Quotes are the docs' own wording. Nothing was downloaded from the vendor; obtaining the
six free plugins is a portal step for the verified buyer (Titan Systems — titansys.dev).*

---

## 7. Portal claim outcome — 2026-11-15 (addendum)

The verified buyer opened the Titan Systems buyer portal in the cloud browser on
2026-11-15, claimed the free plugins and downloaded them; they are archived in the
private repo **asadchoudharry/Sendqon**, each on its own branch with the extracted
download at the branch root plus a provenance README (source-ZIP size + SHA-256,
install route). Portal prices seen during the claim are recorded where the portal
showed them.

### FREE-VENDOR items — status after the claim

| # | Component (§2) | Status | Archive |
|---|---|---|---|
| 1 | Android Gateway v5.0.4 | ✅ CLAIMED + DOWNLOADED + ARCHIVED | branch `plugin-android-gateway`, commit `82b33f80…`, 19 files |
| 2 | WhatsApp v5.0.4 | ✅ CLAIMED + DOWNLOADED + ARCHIVED | branch `plugin-whatsapp`, commit `213eaee2…`, 11 files |
| 3 | SMPP v5.0.4 | ✅ CLAIMED + DOWNLOADED + ARCHIVED | branch `plugin-smpp`, commit `25f42dea…`, 10 files |
| 4 | WhatsApp Embedded Signup v5.0.4 | ✅ CLAIMED + DOWNLOADED + ARCHIVED (portal name: "WhatsApp Signup for Zender") | branch `plugin-whatsapp-signup`, commit `7c397a46…`, 10 files |
| 5 | Legacy API Wrapper | ⚠ **NOT PRESENT in the portal's plugin list** — checked in two browsers on 2026-11-15; the portal listed five claimable free plugins, not six. Status stays **vendor-docs-only** (§2 row 5) until the vendor clarifies where it is obtained. | — |
| 6 | Legacy Importer v5.0.4 | ✅ CLAIMED + DOWNLOADED + ARCHIVED | branch `plugin-legacy-importer`, commit `2cb53196…`, 13 files |

The repo's `main` branch (commit `3f7ba87f…`) now indexes the five plugin branches in a
"Free plugins (claimed 2026-11-15)" section.

### Resolved: the gateway APK packaging (§2 note / §6 item 2 — was [UNCLEAR])

The downloaded Android Gateway plugin settles it, from the plugin's own documentation:

- **No APK is inside the Android Gateway plugin ZIP.** The ZIP carries only
  `Documentation/` and a small `plugin.zip` (the PHP channel plugin), whose code merely
  registers four **app slots** (Android Gateway App, RCS Companion, Receiver Companion,
  USSD Companion) with the platform.
- The phone app is a **separate buyer-portal download**: a single "format 2" Android
  **app bundle** ZIP containing the Gateway, Receiver, RCS and USSD apps plus the bundle
  manifest. The admin uploads it in **Admin → Plugins → Android Gateway → Configure →
  Android Gateway App → Upload App Bundle**; users then download the gateway APK from the
  dashboard's **Pair Device** dialog. The vendor states the app is not on Google Play.
- The app bundle was **not** among the five ZIPs downloaded on 2026-11-15 and is not yet
  archived — it is a further portal download for the verified buyer.
- No Android **source code** is offered anywhere in the plugin either (consistent with
  §6 item 3): all phone apps are ready binaries.

### Resolved: the WhatsApp backend (§2 row 2 note)

The WhatsApp plugin download **does** contain the separately-deployed backend the
installer docs mentioned: native server binaries in `server/` —
`titansys-whatsapp-linux` (x86-64, 52,281,470 B), `titansys-whatsapp-arm64`
(48,234,622 B), `titansys-whatsapp-macos` (49,648,354 B) — run on the VPS as a service
(the plugin guide's systemd example uses `/opt/whatsapp`, health check
`localhost:8899/healthz`). The SMPP plugin ships the same way (`titansys-smpp-*`,
service registered in Admin → SMPP Servers, `http://127.0.0.1:8898`).

### Portal extras seen — PAID, NOT bought

| Extra | Portal price | Status |
|---|---|---|
| Zender Mobile App | $150 | ❌ NOT bought — owner declined at the portal; left for the owner to decide later. |
| MCP (Model Context Protocol) plugin | $120 | ❌ NOT bought — same as above. |

(Prices are the portal's own figures seen on 2026-11-15; §3 of this map records that the
package documentation itself states no prices.)
