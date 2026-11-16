# LANE 3 — PAID PLUGINS COMPLETE STUDY (2026-11-15, cloud browser)
Source: https://products.titansys.dev/zender/add-ons/ — 31 paid add-ons total
(28 Plugins + 3 Extras: MCP, Mobile App, RCS). Koi free plugin portal par
list nahi. Har product page poora parha gaya.

## Cross-cutting facts
- Prices (Regular-licence rates): payment gateways $39 each (Stripe, Paystack,
  Razorpay, Crypto.com Pay, YooKassa); Admin API $39; zyada tar plugins $59;
  GSM Modems $100; Phone Bridge $100; MCP $120; Mobile App $150.
  **Sab 31 ka total = $1,923.**
- Extended treatment: aksar plugins par "reduced price" (amount kahin nahi
  likha); **WordPress, WHMCS, Perfex = Extended holders ke liye FREE**;
  Auto Update, MCP, RCS = **koi discount nahi**; Mobile App par koi Extended
  zikr nahi.
- Delivery: khareed ke baad dashboard.titansys.dev par Envato login se
  download + support. Admin API aur Mobile App checkout par CodeCanyon
  username bhi mangta hai.
- Source: sirf **Mobile App** explicitly full source (Flutter). GSM Modems
  explicitly NO Modem App source. Phone Bridge explicitly NO source (sab
  prebuilt). Baqi 28 par source ka zikr nahi (unverified).
- Common requirements: Zender 5.0+ (Admin API 5.0.3+), PHP 8.4+, public
  HTTPS, scheduler + queue worker; live channels ke liye Reverb ya Pusher.
- Note: catalogue ki pehli load par kam prices dikhe thay ($29/$49/$99 wali
  ghalat list) — product pages ke prices ($39/$59) hi authoritative hain.

## Payment gateways ($39 each, sab v1.0.0, 6 Nov 2026)
Sab ka ek hi pattern: plugin upload (Admin > Plugins) → API keys → test →
Admin > Plan > Payments mein gateway select → customer plan/renewal/top-up
pay karta hai → subscriptions webhooks se handle. Sab mein: subscription +
one-time payments, retries, payment method update, refunds, invoices/receipts,
failed payment handling, webhook support. Source: not stated.
- **Stripe** — Visa/MC/Amex/Discover/Diners/JCB/UnionPay/Link/Apple Pay/Google Pay. Stripe account + keys chahiye.
- **Paystack** — Visa/MC/Verve/bank transfer/USSD. Paystack account.
- **Razorpay** — Visa/MC/RuPay/UPI/netbanking/wallets. Razorpay account.
- **Crypto.com Pay** — crypto payments. URL /zender/crypto-com/.
- **YooKassa** — Visa/MC/Mir/SberPay.

## Admin API — $39, v1.0.1
Admin area ka complete REST API: workspaces, members, plans, subscriptions,
invoices, charges, announcements, templates, API keys — sab ek OpenAPI 3.1
document mein; CRUD; API keys workspace scopes ke sath; auth = API key ya
session cookie. Requires Zender 5.0.3+. Workflow: plugin activate → plan par
Admin API enable → OpenAPI doc se integrate.
**Rebuild note:** hamari apni Admin API isi spec se banegi — ye Operqon/
external automation ke liye sab se ahem plugin hai.

## Appointment Booking — $59, v1.0.1
Chat flow mein booking node: services, staff, days, times, contact timezone;
customer text se book/reschedule/cancel; Google Calendar / Outlook writeback;
booking dashboard; email notifications. Requires: Chat Flows + feature plan
par enable; Google/Microsoft account calendar permissions ke liye.

## Auto Update — $59, v1.0.1 — NO Extended discount
Dashboard se one-click Zender + plugins update; auto version check; update se
pehle backup; restore point (1 week rakha jata hai); CLI se bhi update mumkin.
Updates = official signed packages from Titan Systems. Requires curl + unzip,
write permissions. **Note:** hum updates manual rakhenge (apni patch register
discipline) — ye plugin khareedna hamare liye ghair-zaroori hai.

## AI Agents — $59, v1.0.0
GPT-5 / Claude agents conversations mein: per-agent system prompt; knowledge
sources (own files, Knowledge Base plugin, system resources); tool calls
(Chat Flows, API, WhatsApp/Telegram messages, WABA templates, customer
create/update); human handoff rules (tag/keyword/AI decision); reply review
modes (auto/review/pause); conversation summaries; auto labels; per-agent
limits/model settings. Requires OpenAI ya Anthropic API key; Chat Flows.

## AI Flow Builder — $59, v1.0.0
Plain-language description se complete chat flow (nodes, steps, conditions,
branches); templates; chat se edit (adjust/remove/rebuild/redo); edit history;
add karne se pehle preview. Requires OpenAI API key.

## Knowledge Base — $59, v1.0.0
AI Agents/Flow Builder ke liye searchable document store: PDF/DOCX/TXT/
Markdown (upload, URL, public link, HTML paste); document reader headings/
lists preserve karta hai; 2,048-token chunks with overlap; metadata/authorship/
language detection; search ranking; AI Flow Builder content ki auto indexing;
search API.

## Telegram — $59, v1.0.0 (channel plugin — binary service)
Bots + accounts: BotFather token se bot, ya code/QR + 2-step se account login;
private chats Messenger mein; broadcast channels (bot admin rights se post/
edit/delete); campaigns contacts ya channel ko; single-use opt-in links
(1 day expiry); flow nodes (Telegram Message, First Contact, Button Tap
triggers; Send Telegram action); plan allowances bots/accounts alag.
**Workflow khaas:** pehle Admin mein Telegram Server register, download se
matching **binary Linux VPS par install**, apna Telegram app api_id/api_hash
save, Test Configuration — phir channels connect. Requires Reverb/Pusher.
Bot sends par delivery/read receipts nahi; bot sirf un logon ko pohonchta hai
jinhon ne start kiya ho.

## Telegram Store — $59, v1.0.0 (Telegram plugin par dependent)
Telegram ke andar storefront: catalog, images/variants, cart, Zender checkout
(one-time + subscriptions), orders/shipping/tax, sales analytics.

## Email — $59, v1.0.0 (channel plugin — binary service)
Mailboxes connect (Gmail/Microsoft sign-in; Gmail App Password bhi; "Other"
koi bhi IMAP/SMTP); threaded email Messenger mein (subject/To/Cc/attachments);
agents rich text + Cc/Bcc + signature se reply; email campaigns (speed,
rolling daily limit, health ramp); mailbox Warmer (warm-up); Suppressed
Emails/bounce reasons/domain reports; flows incoming email se start ya email
send; API se send (idempotent retries); webhooks email.message events.
**Bundled email service Linux VPS par install hoti hai (x86_64 + ARM
binaries).** System emails (password reset/invoices) core Zender mein rehte
hain — ye plugin un se alag hai.

## Website Chat — $59, v1.0.0
Website par live chat widget; conversations Messenger mein (shared inbox
rules); widget customise (theme, launcher position, header branding, welcome
text); prechat (off/optional/required — name/email/phone); availability
workspace hours/custom schedule + away message + offline form; verified
visitor identity (server-side HMAC-SHA256 user ID); JavaScript API
(open/close/toggle, theme overrides, prefill, events); live visitors +
optional country (CDN headers ya free MaxMind key — sirf 2-letter code save).
Allowed domains: exact host, port, ya *.example.com. Requires Reverb/Pusher;
offline email replies ke liye Email plugin (optional).

## Web Push — $59, v1.0.0
Browser notifications: visitor subscription (per push site + browser);
configurable prompt (headline/message/buttons, delay/scroll trigger, dobara
poochne ke din); quiet hours (subscriber/workspace timezone); campaigns
(title/body/link/image/actions, reports, A/B) aur flows mein Send Push;
install tools (snippet + Verify Installation + Test Send); WordPress ke liye
generated plugin. iPhone/iPad: pehle Home Screen par add karna lazmi.
Push-service acceptance ≠ dekha gaya.

## Browser Extension — $59, v1.0.0
Per-site branded Chromium extension: dashboard se apni build download;
web page par phone/email right-click se action; popup se messages (unread
counts, recent conversations, templates, contact create groups/tags ke sath);
Messenger se calls (plan/role/line rights server check karta hai); realtime
packaged worker + polling fallback; sirf packaged code (no remote scripts);
connection token local storage, 90 days expiry; dashboard se kisi browser ko
revoke; update lock. Install: Developer mode → Load unpacked (koi Web Store
listing nahi). Chromium 120+.

## Shopify — $59, v1.0.0
Store events (order/payment/cancel/refund/fulfilment/delivery/abandoned
checkout) → Store Automation triggers; COD confirmations (writebacks: order
tags, cancel with restocking — refund/Shopify notification ke baghair);
abandoned-checkout reminders (opt-outs, marketing switch, purchase status,
sending hours check; purchase par auto stop); consent-aware sending (unknown
consent = no reminder; US ke liye explicit SMS consent); tabs: Stores, Orders,
Automations, Messages; privacy: customer redaction par data erase, raw webhook
payloads 7 din baad clear, delivery rows 30 din baad delete. Setup: apni
Shopify Dev Dashboard org mein app (5 scopes: read_orders, write_orders,
read_customers, read_fulfillments, read_checkouts), phir Connect Store
(myshopify domain + Client ID/Secret). Connected Stores limit WordPress
stores ke sath shared.

## Odoo — $59, v1.0.1
Odoo 19.0/20.0: native SMS flows connector se (routing, consent/blacklist,
signed receipts); "Send WhatsApp" actions Contacts/CRM Leads/Sales Orders/
Invoices/Journal Entries/Calendar Events par (approved template + variable
mapping); automation rules mein Send WhatsApp action; phone-code sign-in
(Zender codes generate/check karta hai, add-on codes store NAHI karta);
optional phone verification (account creation pause), portal phone change
protection, local rate limits; per-company connections. Teen add-ons branded
download se; Update Now teeno ko sath replace karta hai, phir Finish Upgrade.
Odoo server par Python `requests` + `phonenumbers` chahiye. API key Odoo mein
nahi dalti (messaging site download mein fixed; Connect credentials deta hai).

## Google Sheets — $59, v1.0.0
Flow nodes: Add Row (flow tokens column mapping; values plain text, formula
nahi bante); Find Row (ek column par pehli match; Found/Not Found/Error alag
outputs); New Row trigger (unique ID column; ~5 min check; har naye ID par
flow ek dafa). Files Google Picker se (grant sirf chosen files). Apna Google
app: OAuth client + project number + restricted browser API key; secrets
encrypted + masked. Limits: 100 columns, 10,000 rows. Uncertain append dobara
blindly retry nahi hota (duplicates se bachao). Testing grants 7 din mein
expire — consent screen "In production" rakhna hai.

## Blesta — $59, v1.0.0 (integration pattern: branded connector)
Blesta 6.0.3+ ke events ka complete catalogue branded messenger se; templates
Blesta settings mein edit; routing Zender site par (channels/senders/fallbacks
admin choose karta hai); durable queue + Message Log (masked destinations,
retry/resend); ticket replies existing Support Manager ticket se attach;
phone verification (registration/change; sirf verified numbers ko bhejna
optional); sign-in codes clients/staff; client apni Messaging page se text
notifications off kar sakta hai. Settings per Blesta company scoped. Connector
PHP 8.3 (8.4 par Blesta 6.0.3 verify fail hua tha — vendor note).

## Flarum — $59, v1.0.0
Flarum 2.x forum: members notification grid mein Text Message choose (phone
verify ke baad; preferences default off); moderator alerts (flagged posts/
approvals; 10 numbers tak direct); privacy: post/PM bodies kabhi nahi,
320 chars limit; routing Zender par; Flarum queue se delivery + bounded
retries; optional GDPR export/erase. Extension download mein service address
fixed — koi API key field nahi. Durable queue driver lazmi (sync driver
retries nahi rakh sakta).

## osTicket — $59, v1.0.1
osTicket 1.18.x: customer texts (created/staff reply/resolved-closed; internal
notes kabhi nahi); agent notifications (assignment/overdue — staff profile
mobile); staff alert numbers (per line; department ke new tickets); har event
ka editable template + optional WABA template attach (name/language, header/
body/button params mapping); incoming replies latest matching ticket se
attach; "Create Tickets From Unknown Numbers" default off; Text Message Code
2FA staff ke liye. Connector include/plugins mein; routing Zender site par
manage hoti hai; outgoing text se HTML strip.

## WordPress — $59, v1.1.2 — Extended holders ke liye FREE
WordPress 6.6+ / WooCommerce 9.0+: notification rules (recipient, merge tags,
30 din tak delay); form plugins ke native messaging actions (CF7, WPForms,
Gravity Forms, Fluent Forms, Ninja Forms, Elementor Pro) + optional contact
sync (tag/group); WooCommerce order rules (New Order, Customer Note, statuses,
Low/Out of Stock; classic + block checkout consent; HPOS); registration/profile
contact sync + role tags; consent-based cart reminders (signed, expiring,
single-use recovery links; uninstall par cart data delete); phone verification
+ sign-in (2nd step per role, passwordless login, phone password reset);
Website Chat/Web Push widgets bhi load kar sakta hai (woh plugins active hon
to). Branded connector Integrations se download.

## WHMCS — $59, v1.4.2 — Extended holders ke liye FREE
WHMCS 9.0+: event-based notifications (SMS/WhatsApp/WABA; har rule default
disabled); Staff Copy per rule (comma numbers); ticket rules assigned admin/
department ko notify; client text reply → verified/unique phone se match →
sab se recent active ticket mein add (unmatched Log mein); phone verification
(registration/change/checkout); Two-Factor "Codes" provider clients + admins
ke liye; client preference "Text me about my account" (Password Reset is ko
bypass karta hai lekin password/link kabhi nahi bhejta); delivery retries
backoff ke sath 5 attempts tak (429/5xx). Connector PHP 8.2+.

## Perfex CRM — $59, v1.0.1 — Extended holders ke liye FREE
Perfex 3.3+: branded SMS gateway module (SMS/WhatsApp/WABA; Setup > Settings
> SMS mein connect/test/disconnect + read-only routing summary); CRM event
template groups (native templates bhi rehte hain); safe recipient rules
(active + topic-allowed contacts; staff record assignment se; security
messages sirf Staff Alert Numbers ko, passwords/codes kabhi nahi); manual +
bulk sending (contact/lead/staff profile se; Customers/Contacts/Leads lists
se bulk — counts + skipped reasons pehle dikhte hain); verification/sign-in
codes (OTP API). Blank template = event disabled. Bulk ke liye plan par
Campaigns chahiye.

## MCP (Extra) — $120, v1.0.0 — NO Extended discount
MCP server: Claude, ChatGPT, Claude Code, Cursor waghera connect (Claude/
ChatGPT par Verified app badge jab callbacks match hon); OAuth sign-in
(Read Only / Read and Write) ya API keys ("AI App (MCP)" type); **sending
default OFF** — "Allow sending messages" bhi on karna padta hai, warna
sending tools hidden/refused; per connection max **20 messages/hour**;
campaign creation hamesha **draft only** (AI khud launch nahi kar sakta);
OAuth connections review/revoke: owners/admins API Keys > MCP Connections,
members Account Settings; unverified apps par clear badge; channel tools sirf
tab jab required plugin live ho. Requires MCP + API Access plan par; public
HTTPS. **Ye hamari Phase 4 ki pehli priority hai — spec yahi hai.**

## Mobile App (Extra) — $150, v1.0.0 — FULL FLUTTER SOURCE
Agents/owners ke liye Messenger app (Android + iOS): inbox (search/filters/
views), threads, reply, internal notes, attachments, voice messages record/
play, emails parhna, contact details; conversation actions (assign/transfer/
team, label, priority, snooze, pin, unread, resolve/reopen, macros, AI
summary, pause AI replies, copy/retry/unsend/react/edit jahan channel
support kare); contact ke orders + payment/COD status; live updates + push
(apna Firebase project; tap par sahi conversation); owner modules (overview
metrics, contacts, campaigns + stats/cancel, call history, channel status,
USSD, WABA template statuses, members, billing/invoices/credit history,
support tickets — har module sirf tab jab site enable kare); sign-in
(password/2FA/sign-in code + QR scan), password reset, biometric lock,
signed-in devices review, account delete; **rebrand ek config file se**
(name, app ids, icons, splash, notification icon colour) + rebrand tool;
site theme presets follow (light/dark); languages EN/AR/JA built-in + RTL,
site translation editor se mazeed languages bina rebuild; tablet two-pane.
Guide: offline step-by-step HTML (setup, rebrand, push, builds, publishing,
updates). Updates free. **Source resale/redistribution mana hai** — sirf apni
Zender site ke liye build/publish. Support building/signing/publishing cover
NAHI karta. Requires Android 8.0+/iOS 15.0+, apne Play/App Store developer
accounts, iOS ke liye Mac + Xcode.

## Web Push / Website Chat — upar alag sections mein (25/26 report order).

## GSM Modems — $100 (catalogue card par version/date nahi)
Apne GSM modem lines se texts, **flash SMS** aur USSD; voice-capable lines
par calls. Agents Messenger mein calls answer/place; call flows (answer,
prompts, record, transfer). **Per-site Modem App** buyer dashboard se build
(Windows / Linux x64 / Linux ARM64) — modems wale computer par chalti hai,
8-character code se pair. **Telephony server download mein included** (Linux
x86-64 + ARM64); kai servers register — devices least-loaded par, disabled
server se move. Wahi service Phone Bridge ko bhi support karti hai.
**Supported modems: SIM7600G-H** (LTE texts, flash SMS, USSD, call detection;
voice lines par calling), **SIM800C** (SMS only, 2G only); A7670 aur EG25-G
abhi supported NAHI. USSD ko 2G/3G fallback ya carrier USSD-over-IMS chahiye
ho sakta hai. **Source: Modem App ka source NAHI milta** (branding builder
se). Modem App daemon hai, Android APK nahi.

## Phone Bridge — $100 (catalogue card par version/date nahi)
Apna phone line bana kar calls + texts relay: Bridge Adapter (ESP32) ya
Windows App se; **texts ke liye Android lazmi — iPhone sirf calls**.
Agents browser mein calls answer/place (call bar: Mute, Hold, keypad,
Transfer, Hang Up; HTTPS + mic permission); voice flows (call phone par ring
ho ya flow answer kare; menus, transfers, background steps jaisay caller ko
text karna; call ke baad branching); call logs + recordings + transcripts
(log mein rehte hain, flow variables mein kabhi nahi); per-plan on/limits.
Device apps buyer dashboard ke Builds se (branding mumkin); updates licence
entitlement se. **Recommended board: Waveshare ESP32-WROVER-E-N16R8 (16 MB
flash, 8 MB PSRAM); sirf original ESP32 mein Bluetooth Classic hai jo calls
ke liye chahiye — S2/S3/C3 kaam nahi karte.** Ek agent ek waqt mein ek call.
**Source: NAHI — telephony server programs, Windows App, adapter firmware
sab prebuilt.**

## RCS (Extra) — $59 — NO Extended discount
Google Messages (paired Android phone) se RCS text + 1 image (caption
optional; doosray file types nahi); har RCS message = 1 allowance unit (SMS
segment splitting nahi); **RCS Companion app** checklist (Accessibility +
Notification Access, battery limits remove, Google Messages default SMS app,
connection confirm); self-test (message nahi bhejta; rozana + Google Messages
updates ke baad bhi auto test); device setting se SMS fallback (default off;
failed RCS refund, SMS charge); verification codes mein bhi kaam; Network
Directory mein partner lines/destinations/credits (RCS aur SMS alag).
Requires: free Android Gateway plugin active; plan par SMS + Android Devices
+ RCS; phone unlocked, screen lock OFF. Delivery guaranteed nahi — unknown
outcomes failed mark + refund + kabhi resend nahi. RCS on ho to phone sirf
text receive karta hai (images/files receive nahi hote).

## Lane 3 natija (rebuild ke liye)
- Kul paid catalogue = 31 items / $1,923 (Regular rates). Hum khareed NAHI
  rahe — ye specs hamari own-build list hain (custom licence ke baad).
- Teen items mein vendor ka compiled server binary shamil hai (Telegram,
  Email, telephony for GSM/Phone Bridge) — ye Lane 6 (no-source) ka core hain.
- GSM Modems ka supported modem **SIM7600G-H** hai — hamari Addendum 4 wali
  pasand vendor ke system se match karti hai; aur **flash SMS modem route se
  mumkin hai** (Android gateway se nahi tha).
