# Zender — Complete Study (CodeCanyon item 26594230) + CodeCanyon Alternatives

Research date: 14–15 November 2026 (PKT). Vendor: titansys (TitanSystems).

**Method / sourcing note.** CodeCanyon itself was blocked by a Cloudflare check in the live research browser, so all CodeCanyon facts come from fresh web-index crawls of the actual item/support/comments/category pages (crawl timestamps 2026-11-14 19:49–19:53 UTC) and are flagged **[index]**. The vendor's own sites (products.titansys.dev, zender.titansys.dev/documentation) were read in the live research browser and are flagged **[verified live]**. Anything that could not be confirmed from a source is marked **unverified** rather than guessed.

**Critical framing.** Zender has been completely rewritten as **Zender 5** (current version **5.0.4**). The old v3 description, requirements (PHP 7.x / Android 4.4) and prices circulating on third-party and nulled-download sites are obsolete. There is **no upgrade path from Zender ≤3.x to Zender 5** (vendor FAQ). Old documentation at docs.titansystems.ph and community.titansystems.ph is v3-era and is not used for v5 claims below.

## Summary

- Zender 5 is a Laravel + React WhatsApp & SMS messaging SaaS: shared team inbox ("Messenger"), bulk campaigns, chatbot flows, contacts/segments, SaaS plans/credits/billing, REST API, webhooks, an OTP verification API and USSD. The PHP script ships as **full source code**; the Android gateway apps and the WhatsApp server do **not** — they are free downloads for verified buyers, rebrandable only through the vendor's app builder (apps) or shipped as a compiled binary (WhatsApp server).
- CodeCanyon price at crawl time: **Regular $19 on sale (was $79), Extended $350**; rating **4.47 from 207 reviews**; **~2K sales**; last update **11 November 2026**. The vendor's own store lists different prices (Regular $59 / Extended $299) — see §1.
- WhatsApp works two ways: the **official WhatsApp Business API (WABA) is included**, and a **free, unofficial QR-linked plugin** covers ordinary numbers.
- The plugin ecosystem is large (31 add-ons on the vendor store): 6 free plugins and ~25 paid ones ($39–$150), including Phone Bridge (calls via your own phone, $100), GSM Modems ($100), MCP server for AI assistants ($120), RCS ($59) and a full-source Flutter Mobile App ($150).
- On CodeCanyon, the closest competitor is **rbsoft's SMS Gateway** ($89, 4.96★, 4.4K sales) — more established but SMS-only and also no Android source. **VeroSMS** ($49) is the only checked rival that includes full Android app source, but it has no SaaS billing. **XSender** ($79) is the nearest like-for-like rival combining Android SMS + both WhatsApp methods + SaaS. Dead/stale items flagged in §12: Sendroid (dead, 2021), WhatSender (stale, Nov 2025), PicoMSG (changelog stale since Feb 2025).

---

## 1. Core product

**Identity.** Current CodeCanyon title: "Zender – WhatsApp & SMS Messaging SaaS with Shared Inbox, Campaigns and Chatbots", by titansys, item 26594230. [index]
Source: https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230

**Price, rating, sales, version (CodeCanyon, crawl 2026-11-14 19:49–19:50 UTC).** [index]

| Fact | Value |
|---|---|
| Regular licence | **$19** (sale; was $79) |
| Extended licence | **$350** |
| Rating | **4.47** (207 reviews) — the page's JSON-LD shows 4.5 / 207 ratings |
| Sales | **~2K** (category listings; an earlier crawl showed 1.9K) |
| Last update | **11 November 2026** |
| Current version | **5.0.4** (documentation header "Zender v5.0.4") |
| Created | 7 years ago |
| Software version (listing) | PHP 8.x, MySQL 8.x / 5.x |
| Files included (listing) | JS, HTML, CSS, Sass, PHP, SQL |
| Support | 6 months included; extend to 12 months for **$5.25** (was $12.25) |

Sources: https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230 · https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230/support · https://zender.titansys.dev/documentation/

**Price discrepancy (do not merge).** The vendor's own store lists Zender at **Regular $59 / Extended $299** (products page published 2026-11-09), and a BuyMeACoffee "Zender Extended License (Zender 5 Launch Promo)" was seen at $80. All three price sets are real, from different storefronts/promotions; the CodeCanyon figures above are the ones a CodeCanyon buyer pays. [index]
Source: https://products.titansys.dev/zender/

**What the purchase includes** (CodeCanyon "What You Get"). [index]

- The full PHP script **source code** (Laravel + React application — see §2).
- WhatsApp Business API (WABA) channel — included.
- SMS providers: Twilio plus 14 others plus a Custom HTTP provider (the vendor store counts "16 drivers" including Custom HTTP; SMPP is a separate free plugin — see §5).
- Payment gateways included: Bank Transfer and PayPal (others are paid plugins — §5).
- Offline documentation, a web installer, and a VPS auto-setup script for fresh Ubuntu 24.04.

**Feature list** (CodeCanyon item page [index]; corroborated on the vendor product page [verified live]: https://products.titansys.dev/zender/):

- **Messenger shared inbox** — team inbox with assignment, teams, labels, SLA, CSAT ratings, macros/canned replies.
- **Campaigns** — bulk sending to groups/tags/segments, scheduling, send windows, A/B tests, link tracking, spintax, duplicate and opt-out protection.
- **Chatbots / Flows** — drag-and-drop flow builder, keyword triggers, AI replies, drip sequences, away messages.
- **Contacts** — groups, tags, segments, custom fields, CSV/XLSX import, opt-out handling, hosted subscribe forms.
- **SaaS billing** — plans with feature switches and limits, credits and credit packs, vouchers, PDF invoices, a referral program, a "Market", and a "Partner Network" for sharing Android lines.
- **API & webhooks** — REST API with scoped keys; signed outgoing webhooks with logs and retries.
- **OTP Verify API** — create / check / resend / cancel verification flows with channel fallback.
- **USSD** — via the Android plugin (see §3/§5).
- **Platform** — multi-language (ships English, Arabic, Japanese; RTL support), 2FA, roles/permissions, workspace isolation.

Demo: https://zender.titansys.dev · Buyer portal: https://dashboard.titansys.dev

## 2. Tech stack & requirements

[index + verified live — CodeCanyon item page; https://products.titansys.dev/zender/; https://zender.titansys.dev/documentation/]

- **Backend:** "the full Laravel and React application" (CodeCanyon). The exact Laravel version number is **unverified** — the vendor names Laravel + React but does not state a Laravel major version on the pages read.
- **PHP:** 8.4.1+ (64-bit), extensions: pdo_mysql, mbstring, openssl, curl, gd, zip, bcmath, intl, xml.
- **Database:** MySQL 8 (MariaDB accepted); the docs also mention SQLite / pdo_sqlite.
- **Scheduling/queues:** cron/scheduler every minute; a queue worker per the product page — but CodeCanyon states "No queue daemon and no Redis are needed" for the base install.
- **Realtime:** included Laravel Reverb on a VPS, or Pusher on shared hosting.
- **Optional:** ffmpeg (for WhatsApp voice notes); HTTPS required for Phone Bridge browser calling and the Telegram Store plugin.
- **Hosting:** the vendor **strongly recommends a VPS**. The VPS Auto Setup targets a fresh **Ubuntu 24.04** with root. Shared hosting runs the PHP script only and is slower, with stated limits: campaigns/inbox fall behind, no channel services, no custom Messenger domains, limited number of Android phones, and proc_open/upload caps can break the scheduler.
- **Android (gateway phones):** Android **8.0+** with an active SIM (see §3).

## 3. Android gateway app

**Source code: NOT included.** The vendor's own wording on the CodeCanyon page (substance, [index]):

> "Android Gateway and WhatsApp are separate plugins and are not included with the script. Both are free for verified purchases and are downloaded from our customer portal. Their source code is not included: the Android apps are built with the app builder in our customer portal, where you can change the app name, icon, logo, colors, package name and site address, and the WhatsApp server comes as a compiled program. You get the full source code of the PHP script. Your customers download the Android apps from your own dashboard; they are not meant for the Play Store."

Source: https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230

**App-builder rebranding — exactly what can be changed:** app name, icon, logo, colours, package name, site address. Nothing else is listed. Whether **features inside the app** can be changed: no vendor statement says they can; the builder's documented scope is the six branding/site items above. Treat feature modification as **not offered** (the absence is sourced; a positive claim either way beyond the listed items would be unverified).

**The app bundle** (product page/FAQ [verified live], https://products.titansys.dev/zender/): gateway app, Receiver app, RCS app (RCS needs the paid RCS extra, §5) and USSD app. Pairing is by QR code; multi-SIM with each SIM as its own sender; two-way SMS lands in the Messenger inbox; delivery reports; USSD codes and schedules; per-SIM limits and destination-prefix routing.

**Requirements:** Android **8.0+**, active SIM. Instant delivery needs your own free Firebase project; without it, phones poll every few minutes.

## 4. WhatsApp

[index — CodeCanyon item page; docs verified live: https://zender.titansys.dev/documentation/]

Zender offers **two distinct WhatsApp methods**:

1. **WABA — included with the script.** The official Meta WhatsApp Business API: templates and sending at scale. A free **WhatsApp Embedded Signup** plugin adds "Connect With Facebook" onboarding and Coexistence numbers.
2. **QR-linked — free plugin, unofficial.** Links an ordinary WhatsApp number by QR code. The download's WhatsApp server is a **compiled/static binary** for Linux x86-64/ARM64 or macOS Apple Silicon. Groups sync and group sending are supported.

Both plugins are free **for verified buyers** and, in the vendor's wording, free plugins are "provided at our discretion" — they are not part of the CodeCanyon item itself (see §3 quote).

**Ban/terms warnings.** No explicit ban warning appears on the current v5 CodeCanyon page. A vendor changelog from the v3 era (v3.3.4, community.titansystems.ph) warned that priority WhatsApp sending carries "a risk of being banned if it is abused." That is a dated v3-era vendor warning, not a v5 statement — reported as such.

## 5. All plugins

Source for the catalogue structure: docs "Optional Plugins" table [verified live] https://zender.titansys.dev/documentation/#/optional-plugins — prices from the vendor store [index], https://products.titansys.dev/zender/ and its per-plugin pages (pattern https://products.titansys.dev/zender/<slug>/), crawled 2026-11-14 19:51–19:52 UTC. Regular prices shown; most paid plugins are discounted for Extended licence holders unless noted.

### Free plugins (not part of the script; verified buyers only; "at our discretion")

| Plugin | What it does |
|---|---|
| Android Gateway | Send/receive SMS via your own Android phones (§3) |
| WhatsApp | QR-linked WhatsApp via compiled server binary (§4) |
| SMPP | SMPP protocol connectivity for SMS |
| WhatsApp Embedded Signup | "Connect With Facebook" onboarding / Coexistence for WABA |
| Legacy API Wrapper | Compatibility layer for the old (v3) API |
| Legacy Importer | Imports data from Zender ≤3.x installs |

### Paid plugins

| Plugin | Price | What it does / notes |
|---|---|---|
| Admin API | $39 | Admin endpoints for accounts, subscriptions, credits, vouchers, plans, transactions. Requires Zender 5.0.3+ (published 2026-11-08) |
| Stripe | $39 | Payment gateway |
| Paystack | $39 | Payment gateway |
| Razorpay | $39 | Payment gateway |
| Crypto.com Pay | $39 | Payment gateway |
| YooKassa | $39 | Payment gateway |
| Appointment Booking | $59 | Booking/appointments |
| Auto Update | $59 | One-click updates. **Paid for everyone, incl. Extended**; manual update via /upgrade remains free |
| AI Agents | $59 | AI agent features |
| AI Flow Builder | $59 | AI-assisted chatbot flow building |
| Knowledge Base | $59 | Knowledge base |
| Blesta | $59 | Blesta billing integration |
| Flarum | $59 | Flarum forum integration |
| osTicket | $59 | osTicket support integration |
| Odoo | $59 | Odoo integration |
| Perfex | $59 | Perfex CRM integration — **free with Extended** |
| WHMCS | $59 | WHMCS integration — **free with Extended** |
| Shopify | $59 | Shopify integration |
| WordPress | $59 | WordPress integration — **free with Extended** |
| Browser Extension | $59 | Browser extension |
| Google Sheets | $59 | Google Sheets integration |
| Telegram | $59 | Telegram channel |
| Telegram Store | $59 | Store inside Telegram (needs HTTPS) |
| Website Chat | $59 | Website live-chat widget |
| Web Push | $59 | Web push notifications |
| Email | $59 | Email channel (channel service; needs VPS — §11) |
| Phone Bridge | $100 | Calls/texts via your own phone. Hardware Bridge Adapter (ESP32-WROVER-E) or Windows 11 Bluetooth app; server programs prebuilt, **no source** |
| GSM Modems | $100 | Send via GSM modem hardware. SIM7600G-H full support, SIM800C SMS-only/2G; A7670/EG25-G **not** supported. Modem App source not included |
| MCP | $120 | Connects Claude / ChatGPT / Claude Code / Cursor to Zender. **No Extended discount.** Safety defaults: sending off by default, max 20 messages/hour/connection, campaigns draft-only |
| RCS | $59 | RCS via Google Messages on a paired phone; needs Android Gateway + SMS on the plan. **No Extended discount** |
| Mobile App | $150 | Separate product: **full Flutter source** for an Android/iOS Messenger app; rebrand via one config file; publish under your own Play/App Store accounts. (Contrast §3: here source IS included — but it may not be resold/redistributed, per its FAQ) |
| Freemius | Paid (docs table) | Sell subscriptions via Freemius checkout. **Price unverified** — no price captured on the vendor store |

**Built-in SMS providers (not plugins):** Twilio, Vonage, Plivo, Telnyx, Sinch, Infobip, Bandwidth, Bird, Clickatell, ClickSend, Africa's Talking, MSG91, Routee, SignalWire, TextMagic + Custom HTTP. PayPal and Bank Transfer gateways are built in; the other gateways above are plugins. Plugin documentation ships inside each plugin ZIP, not in the main docs.

## 6. Documentation

[verified live] https://zender.titansys.dev/documentation/ (header: Zender v5.0.4)

**Structure:**

- **Getting Started** — Welcome, Installation, VPS Auto Setup, Pusher Setup, Upgrade Guide, Optional Plugins
- **Configuration** — System Settings, Realtime, Localization, Custom Domains, Privacy/GDPR, Security, Backups
- **Channels** — Channels Hub, SMS Providers, HTTP Provider Guides, WABA, Sending Performance
- **Guides** — User Guide, Admin Guide, Messenger Inbox, Contacts, Campaigns, Flows, Drips, Subscribe Forms, OTP Verifications, Plans and Billing, Payment Links, Market, AI Providers and Credits, Onboarding Tours, Landing Builder, API, Webhooks, Permissions
- **Integrations** — Payment Gateways, File Storage, Plugins, Referral Program, Shared Network
- **Support** — Error Codes, Troubleshooting, Support Center

**Install/ops facts from the docs:** the download contains `Install/` (ships with `vendor/` and a compiled frontend — no build step for manual upload) and `Documentation/` (offline HTML). The scheduler must run every minute (§2). Stated limitations live mainly in the hosting guidance: shared-hosting limits (§2) and the fact that channel services (WhatsApp, SMPP, Email, Telegram, telephony) are long-running programs that require a VPS (§11). No Zender-stated per-SIM/carrier sending cap was found in the v5 docs — see §11.

## 7. Changelog

[index] Sources: https://changelogs.titansys.dev/ (v3 line) and CodeCanyon/plugin pages for v5 dates.

- **v3 era (old community changelogs):** frequent releases ending at **v3.10.2 (2026-08-10)** (a WhatsApp server update). Historical pattern worth knowing: updates had to be applied sequentially without skipping; updates required rebuilding the gateway app and replacing the WhatsApp binary; v3.8 replaced the dashboard template and required WhatsApp server re-setup; v3.8.3 dropped old PHP (required 8.2+); v3.9 required PHP 8.3+.
- **v5 era:** Zender 5 launched shortly before the current cycle — most plugin pages were published 2026-11-06 to 2026-11-08, the Admin API plugin (2026-11-08) already requires Zender **5.0.3+**, and the current version is **5.0.4** with the CodeCanyon item updated **11 November 2026** — i.e. at least five v5 point releases in roughly a week. That cadence cuts both ways: active development, and a very new codebase.
- The individual release-note contents for v5.0.0–5.0.4 were **not captured** (the v5 entries on changelogs.titansys.dev were not opened) — **unverified**.

## 8. White-label

[index + verified live — CodeCanyon item page; docs "Configure the Platform"; https://products.titansys.dev/zender/]

What the v5 sources support:

- **Site identity** is set in the admin (docs, "Configure the Platform").
- **Landing Builder and Custom Pages** for the public site.
- **Custom domains**, including custom Messenger domains (VPS only, §2).
- **Workspace branding can be switched on/off per plan** (product page, "Roles, Branding And Domains": "plans can switch on workspace branding").
- **Branded Android app bundle** via the app builder (§3).
- Integration downloads (WordPress/WHMCS/Perfex etc.) are described as "branded" connectors.
- The **Mobile App** plugin ($150) is a full rebrand from its Flutter source (§5).

The v3-era listing line "full white-label platform solution, no one will know" survives on third-party mirrors of the old listing; it is **not** a v5 claim.

**Does "Powered by Zender" or other vendor branding remain visible to end users/tenants? — unverified.** No v5 page read states its presence or its complete removal. This is the single most important open question for a white-label buyer and should be checked in the live demo (https://zender.titansys.dev) before purchase.

## 9. Licence terms

[index] Sources: https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230/support and the item page.

Two different layers apply, and they answer different questions:

1. **Envato standard terms (shown on the item):** Regular licence = use by you or one client in a **single end product** whose end users are **not charged**. Extended licence ($350) = the single end product **may charge end users**. Both include Envato's quality check, future updates and 6 months of support.
2. **Vendor's own v5 FAQ (additional distinction):** "Both licenses include Zender 5. The Extended license also gives reduced prices on most paid plugins and free access to the WordPress, WHMCS and Perfex plugins. MCP, RCS and other extras are not discounted." Auto Update is paid under either licence (§5).

**Modifying source / removing branding:** the PHP script ships as full source code, so it can be modified. The gateway apps, WhatsApp server, Phone Bridge server programs and Modem App ship compiled/prebuilt with **no source** — they cannot be modified or de-branded beyond what the app builders allow. The Mobile App's Flutter source may not be resold or redistributed (its FAQ); it may only be published for your own Zender site.

## 10. Reviews & support

[index] Sources: item page and https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230/support

- **Rating: 4.47 from 207 reviews** (item page; JSON-LD 4.5/207).
- **Individual review themes: unverified.** The comments-page crawl returned only the licence sidebar, not comment bodies, so common complaints/praise (bugs, WhatsApp bans, update breakage) could **not** be systematically captured and are not invented here.
- **Support model (Envato item-support statement):** the author "will respond to buyers' questions and provides limited support through their own support system" — after purchase, support runs through the vendor's portal (https://dashboard.titansys.dev, Envato login). Item support **includes**: author availability, answers to feature questions, help with bugs/issues, help with included third-party assets. It **excludes**: customisation and installation services.
- **Renewal cost:** extending support to 12 months costs **$5.25** (sale; was $12.25) at purchase time. A post-expiry renewal price was not separately captured — **unverified**.

## 11. Risks & limits

- **Play Store:** the gateway apps are **"not meant for the Play Store"** (vendor, §3) and are distributed as APKs via your own dashboard — consistent with Google Play's SMS-permission policy (the old v3 listing explicitly cited that policy change; a v3.9.7 fix release added sending SMS without being the default SMS app, while receiving still required default-app status). [index]
- **Android version floor rose:** Android **8.0+** is now required; old "Android 4.4/KitKat" claims on third-party sites are obsolete.
- **Firebase dependency:** instant delivery requires running your own free Firebase project; otherwise delivery degrades to polling every few minutes.
- **Unofficial WhatsApp risk:** the QR-linked method is labelled unofficial by the vendor's own ecosystem; the only vendor ban warning found is v3-era (§4). Meta can ban numbers used this way regardless of what any script promises — flagged as a structural risk, sourced to the method being unofficial.
- **VPS dependency:** channel services (WhatsApp, SMPP, Email, Telegram, telephony) are long-running programs requiring a VPS; shared hosting has the explicit limits in §2.
- **Carrier/SIM throttling:** **unverified for Zender v5** — no explicit per-SIM or carrier cap statement was found in the v5 sources read. (For contrast, rival VeroSMS states carrier per-SIM daily caps explicitly — §12.)
- **Known vulnerability (historical, precisely scoped):** NVD **CVE-2025-56676** affects TitanSystems Zender **v3.9.7** — a password-reset account-takeover flaw (reset token not bound to the requesting user), CVSS vector AV:N/AC:L/PR:N/UI:R/S:U/C:L/I:N/A:L. Nothing found states that v5 is affected; do not read it either way. Source: https://nvd.nist.gov/vuln/detail/cve-2025-56676
- **Rewrite risk:** no upgrade path from ≤3.x (§Summary), and free plugins are provided "at our discretion" (§4/§5) — both are vendor-stated terms a buyer should price in.

## 12. Alternatives to Zender on CodeCanyon

All facts [index] — CodeCanyon item/category crawls 2026-11-14 19:53 UTC. "Unverified" = not stated on the item page read; not a guess. Prices are Regular licence.

### 12.1 Comparison table

| Item (author) | Price | Rating | Sales | Last update | Android app source? | WhatsApp method | SaaS billing | White-label | Status vs Zender |
|---|---|---|---|---|---|---|---|---|---|
| **SMS Gateway (rbsoft)** | $89 | 4.96 (200) | 4.4K | 12 Oct 2026 | **No** — app builder only | **None** (SMS/MMS only) | Yes — plans + 5 gateways + offline; vendor says sellable as a service **on a Regular licence** | "Complete White-Label" for the app; built-in landing page | Closest established rival; more sales/better rating, but no WhatsApp at all |
| **VeroSMS (SoftNix)** | $49 | 5.00 (6) | 28 | 09 Dec 2025 | **Yes — full Android Studio + Laravel source** | None | **None found** on item page | White-Label Guide (app rebuild in Android Studio; panel branding live) | Only checked rival with app source; but it's a single-business gateway, **not a SaaS**; tiny sales base |
| **XSender (igensolutionsltd)** | $79 | 4.13 (83) | 973 | 31 Oct 2026 | **No** (vendor note) | **Both QR and Cloud API** | Yes — marketed [SAAS] | Unverified | Nearest like-for-like rival (Android SMS + both WhatsApp + SaaS, plus email); weaker rating |
| **SMSLab (ViserLab)** | $39 | 4.62 (8) | 173 | 13 Oct 2026 | "Full Source Code" listed; **app source specifically unverified** | None | Pitched as own SMS service; plan/gateway detail unverified | Panel logo & favicon settings | Cheaper SMS-only option; thin review base |
| **SMSpro Gateway (Acnoo)** | $59 | 4.33 (6) | 84 | 02 May 2026 | **No** — panel source + APK only | **Not yet** — "WhatsApp Messaging (Beta)" is a planned feature | Yes — subscription plans + PayPal/Stripe/Razorpay/crypto/offline | "Total White-Label" for the app | rbsoft-style model (max 3 custom APKs/version); vendor tells users to disable Play Protect to install — red flag |
| **PicoMSG (picotechofficial)** | $19 | 4.58 (12) | 171 | 27 Apr 2026 | Unverified | None | Yes — plans, recurring billing, 10 gateways | Unverified | **Semi-maintained flag:** in-page changelog stops at v1.5 (5 Feb 2025) despite a 2026 "last update" |
| **TweetSMS (ViserLab)** | $49 | 4.20 (5) | 77 | 12 Oct 2026 | "Full Source Code" listed; app source unverified | None stated (unverified) | Yes — marketed as SaaS platform | Unverified | New, low traction; very thin item page |
| **WhatsJet SaaS (livelyworks)** | $85 | Unverified | 602 | 11 Sep 2026 | n/a (no Android gateway) | **Official Cloud API only** | Yes — subscriptions via Stripe; some features need Extended | Unverified | WhatsApp-only; the "safe/official" WhatsApp route, clients pay their own Meta usage |
| **WhatsML (AMCoders)** | $69 | Unverified | 225 | 16 Oct 2026 | n/a | **Both Cloud API (official) and Web API (unofficial, QR/pairing)** | Yes — 12+ gateways + offline | Unverified | WhatsApp-only; adds AI + Google Maps number scraping (compliance risk) |
| **WhatSender / "WASender" (AMCoders)** | $79 (Ext $325) | Unverified | Unverified | **15 Nov 2025** | n/a | QR/device-linked server (Node.js) | Yes — 10+ gateways + offline | Unverified | **STALE flag:** ~1 year without an update |
| **Sendroid (author unverified)** | $50 | Unverified | 97 | **22 Dec 2021** | n/a (provider-based) | Included (method unverified) | Reseller system (per title) | "White-Label Reseller System" (per title) | **DEAD:** PHP 7.x / MySQL 5.x, untouched since Dec 2021 — do not buy |

### 12.2 Per-item notes and sources

- **SMS Gateway — rbsoft**, item 21419519. v10.0.0-b.8. Vendor disclaimer: Android source not included; you get the web panel source plus an app-builder server; change name, logo, package name, server URL, languages, theme; **max 3 custom APKs per new version**; custom APK cannot go on the Play Store (Google policy cited by vendor). "SaaS Ready — you can sell it as a service with a regular license" (notable: stricter Envato reading usually requires Extended for charging end users — this is the vendor's own wording). Plans can limit credits/contacts/devices/servers/sender IDs/templates/webhooks/API tokens/auto-responses. Gateways: Crypto.com, PayPal, Paystack, Razorpay, Stripe + offline. One licence = one domain/subdomain/PC. Firebase push optional; dual SIM; third-party gateways (Twilio, Textlocal…); USSD pulls need Android 8+.
  Source: https://codecanyon.net/item/sms-gateway/21419519
- **VeroSMS — SoftNix**, item 58958174. "Everything ships as complete, readable source code — the Laravel panel and the Android Studio project." v4.0.2: Laravel 12, PHP 8.2+, Android SDK 37, Android 7.0+. No licence key/activation/"phone home"; updates are manual signed uploads. Own Firebase project required. Vendor explicitly states carrier per-SIM daily caps and Android's large-volume SMS permission prompts (the clearest carrier-throttling statement found in this whole study). No plans/subscriptions/tenant billing anywhere in its full feature list — staff logins with 19 granular permissions instead.
  Source: https://codecanyon.net/item/verosms-android-sms-gateway-source-code-laravel-admin-panel/58958174
- **XSender — igensolutionsltd**, item 39055616. Vendor: "Please note that the source code for the SMS Gateway App is not included in this script." WhatsApp warning on page: follow WhatsApp policies "to prevent blocking issue WhatsApp number." Android 5.0+, Google Play Services required; app may not be published on the Play Store. Laravel, PHP 8.2+, Node 20+. Also email marketing (SMTP/PHPMailer/SendGrid).
  Source: https://codecanyon.net/item/xsender-mass-email-and-sms-messaging-for-digital-marketing/39055616
- **SMSLab — ViserLab**, item 40311458. v3.0 (30 Jun 2026) on Laravel 13. "What you get: Full Source Code, Project Documentation, Complete Project Database" — the page never separates app source from panel source, hence the unverified flag.
  Source: https://codecanyon.net/item/smslab-android-based-sms-gateway-server/40311458
- **SMSpro Gateway — Acnoo**, item 53077366. "you will get only admin panel Source Code & app apk only (The App source code is not available for this project.)" Mirrors rbsoft's model incl. the 3-custom-APK limit. Its on-page changelog stops at v1.2 (Aug 2024).
  Source: https://codecanyon.net/item/smspro-bulk-sms-marketing-software/53077366
- **PicoMSG — picotechofficial**, item 37780522. Recurring billing added in v1.2 (2022); gateways PayPal, Stripe, Paytm, Mollie, PayStack, Flutterwave, VoguePay, Iyzico, Authorize.Net, Coinbase.
  Source: https://codecanyon.net/item/picomsg-phone-as-an-sms-gateway-for-bulk-sms-marketing/37780522
- **TweetSMS — ViserLab**, item 57145151. v2.0 (28 Jun 2026) on Laravel 13; self-hosted, unlimited devices/SIMs.
  Source: https://codecanyon.net/item/tweetsms-sms-marketing-platform-as-saas/57145151
- **WhatsJet SaaS — livelyworks**, item 51167362, v7.5.2 (11 Sep 2026). Vendor: "WhatsJet uses the Official WhatsApp Cloud API, which is a paid service… if utilized as a SaaS platform, your clients are responsible for covering the expenses associated with their individual WhatsApp Cloud API usage." Features marked "#" on the page require the Extended License.
  Source: https://codecanyon.net/item/whatsjet-saas-a-whatsapp-marketing-platform-with-bulk-sending-campaigns-chat-bots/51167362
- **WhatsML — AMCoders**, item 59497566. Its CodeCanyon page lists "Option A: WhatsApp Cloud API (Meta Business Account required)" and "Option B: WhatsApp Web API (via QR Code or Pairing Code)", labels the Web API "(Unofficial)", and states "12+ automatic payment gateways and unlimited offline payment methods."
  Source: https://codecanyon.net/item/whatsml-aibased-marketing-automation-tools-for-whatsapp-saas/59497566
- **WhatSender — AMCoders**, item 44936224. Laravel + Node.js 20+, VPS recommended; multiple WhatsApp devices, chatbot, bulk/template sending. Regular $79 / Extended $325 from its support page.
  Source: https://codecanyon.net/item/wasender-whatsapp-server-and-bulk-sender-saas/44936224
- **Sendroid** — figures from CodeCanyon category crawls ($50, 97 sales, last updated 22 Dec 21, PHP 7.x/MySQL 5.x). Its item URL, author and rating were not captured verbatim — **unverified**; the dead/unmaintained conclusion rests on the category data.
  Source: https://codecanyon.net/search/bulk%20sms%20marketing

### 12.3 Bottom line vs Zender

- **No CodeCanyon rival checked matches Zender 5's combination** (Android gateway + WABA included + QR WhatsApp + shared inbox/chatbots + SaaS billing + plugin ecosystem) in one item. XSender comes closest on channels but has a weaker rating (4.13) and no app source either.
- **Android app source:** only **VeroSMS** includes it — and it gives up SaaS billing to do so. Every SaaS-positioned rival (rbsoft, XSender, SMSpro, Zender itself) withholds app source and offers an app builder instead.
- **WhatsApp:** Zender and XSender/WhatsML offer both official + QR; WhatsJet is official-only; the Android-gateway SaaS rivals other than XSender have no WhatsApp at all.
- **Dead/stale:** Sendroid is dead (2021); WhatSender is stale (Nov 2025); PicoMSG's changelog is stale (Feb 2025); SMSpro's on-page changelog stops in Aug 2024 despite a 2026 listing update.
- **Adjacent, not evaluated in depth:** Ultimate SMS by codeglen ($79, seen at $39 on sale; 3.2K sales; last update 07 Oct 2026 — provider-based bulk SMS, not verified as an Android gateway); Waziper SaaS ($69, only 18 sales, 16 Aug 2026); WhatSaaS by saasfy (item 61257201, $35, official Cloud API only, full Next.js source, multi-tenant); SaleBot by spagreen (683 sales, 13 May 2026, WhatsApp+Telegram SaaS).

## Could not verify

- Whether "Powered by Zender" or any vendor branding remains visible to end users/tenants in v5 (§8) — no v5 source states it either way.
- Zender's exact Laravel major version (§2).
- Zender v5.0.0–5.0.4 individual release-note contents (§7).
- Zender review/comment themes — comments page crawl returned no comment bodies (§10).
- Zender post-expiry support renewal price (§10).
- Freemius plugin price (§5).
- Alternatives cells marked "unverified" in §12.1: XSender white-label; SMSLab/TweetSMS Android-app-source specificity and plan/gateway detail; PicoMSG app source and white-label; WhatsJet rating and white-label; WhatsML rating and white-label; WhatSender rating and sales; Sendroid author, rating, WhatsApp method and item URL.
- Whether Zender v5 states any per-SIM/carrier sending cap (§11).

## Sources

**Zender — CodeCanyon [index, crawled 2026-11-14 19:49–19:50 UTC]**
- https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230
- https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230/support
- https://codecanyon.net/item/zender-android-mobile-devices-as-sms-gateway-saas-platform/26594230/comments

**Zender — vendor sites [products store index 2026-11-14 19:51–19:52 UTC; docs verified live 2026-11-14]**
- https://products.titansys.dev/zender/ (and per-plugin pages under https://products.titansys.dev/zender/<slug>/)
- https://zender.titansys.dev/documentation/ and https://zender.titansys.dev/documentation/#/optional-plugins
- https://changelogs.titansys.dev/ (v3.10.2, 2026-08-10)
- Demo https://zender.titansys.dev · Buyer portal https://dashboard.titansys.dev

**Security**
- https://nvd.nist.gov/vuln/detail/cve-2025-56676 (Zender v3.9.7 only)

**Alternatives — CodeCanyon [index, crawled 2026-11-14 19:53 UTC]**
- Category snapshot: https://codecanyon.net/search/android%20sms%20gateway
- Item pages listed in §12.2 (rbsoft 21419519; VeroSMS 58958174; XSender 39055616; SMSLab 40311458; SMSpro 53077366; PicoMSG 37780522; TweetSMS 57145151; WhatSender 44936224; WhatsJet 51167362; WhatsML 59497566)
- Sendroid figures: https://codecanyon.net/search/bulk%20sms%20marketing

**Note on page content:** several CodeCanyon item pages (Zender alternatives) display public demo login credentials and installation instructions as part of their listings. These were read as source material only — no sign-in, download, purchase or form submission was performed anywhere in this study, and CodeCanyon pages containing instructions directed at readers were treated as evidence, never as instructions to follow.
