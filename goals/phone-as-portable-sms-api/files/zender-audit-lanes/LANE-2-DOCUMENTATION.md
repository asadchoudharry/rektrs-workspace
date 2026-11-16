# LANE 2 — OFFICIAL DOCUMENTATION COMPLETE STUDY (2026-11-15, cloud browser)
Site: https://zender.titansys.dev/documentation/ (hash-routed #/<slug>)
43 pages parhi gayin — poori docs. Footer har jagah "Zender v5.0.4".

## Install / Infra (rebuild tree ke 05-INFRA ki bunyaad)
- Requirements: PHP **8.4.1+** (purana PHP ho to installer refuse), extensions
  pdo_mysql/pdo_sqlite, mbstring, openssl, curl, gd, zip, bcmath, intl, xml;
  upload/post ≥128M; storage/ + bootstrap/cache writable; proc_open lazmi.
- Production DB: MySQL InnoDB (MariaDB supported); SQLite sirf trial.
  MySQL FULLTEXT word-prefix only ("sm" ≠ "smith").
- Cron: `* * * * * php artisan schedule:run`. Queue: `queue:work
  --stop-when-empty --max-time=300` (priority queues). Privacy exports worker
  par, 1 ghanta tak lag sakta hai.
- Web Installer 4 steps (Requirements → Database → Admin Account → Finish);
  admin yahin banta hai warna sign-in namumkin. Manual: migrate --force,
  storage:link, db:seed --force (dobara NAHI chalana), cache/config clear,
  optimize, installer lock copy, chmod storage 775.
- **VPS Auto Setup:** `Install/autosetup.sh` Ubuntu 24.04 — DOMAIN=… bash
  autosetup.sh; flags CF_API_TOKEN, CERTBOT_EMAIL, ADMIN_EMAIL, --skip-ssl,
  --dry-run; fixed path /var/www/zender; user `zender`; nginx + MySQL +
  certbot + supervisor + ffmpeg; PHP 8.4 FPM (128M upload, 512M memory, 120s);
  Node 22; DB credentials /var/lib/zender/db-credentials; admin password
  /var/lib/zender/admin-credentials; services: zender-reverb (loopback),
  zender-queue; nginx public/ root + /app aur /apps/<id>/ proxy; LE ya CF
  wildcard SSL. Ye script deployment checklist ke tor par bhi istemal hogi.
- Shared hosting limits (docs khud kehte hain): no Reverb (Pusher lo), no
  channel servers, no custom Messenger domains, Android long-polling process
  limits se takrata hai, bare campaigns slow.
- Upgrade: Web Updater /upgrade (ZIP ≤300MB chunked; Install/ + zender.zip
  lazmi; purani file refuse). Manual: mysqldump backup → artisan down → queue
  stop → rsync (exclude .env/storage) → Settings > Updates se System Upgrade
  → services restart. **APP_KEY jaan hai:** system_settings isi se decrypt
  hote hain; cache table mein decrypted settings — backup se pehle
  cache:clear; key kho jaye to SMTP/OAuth/Meta/PayPal secrets dobara dalne
  parte hain aur opt-out hashes chup chaap kho jate hain. `Zender:update`
  buyer path NAHI (git pull karta hai; download mein git nahi).
- Backups operator ki zimmedari (koi plugin/plan nahi): DB + config + tenant
  storage + channel service state ek consistent snapshot; real files (symlink
  nahi); restore isolated jagah, sending disabled; encrypted + off-server;
  APP_KEY preserve.

## Realtime
- Reverb (self-hosted service) ya Pusher (cloud); settings DB mein (.env
  mein nahi); driver Reverb/Pusher/Off. Reverb: App ID/Key/Secret, Host,
  Port (443/80), Scheme, Server loopback 8080. nginx `location /app/`
  (trailing slash ahem); /apps/<id>/ sirf events/batch/channels/connections/
  users serve karta hai. CLI: `zender:configure-realtime`. WebSocket /app/
  par 101 = kaam kar raha hai. Pusher clusters mt1/us2/us3/eu/ap1/ap2/ap3/ap4;
  Test Connection save se pehle real event bhejta hai.

## System Settings (Admin > Settings — 17 tabs)
General, Billing, Referral, Domains, Integrations, Support, Authentication,
Email, Contact, Custom Code, Mobile App, Updates, Maintenance, WhatsApp,
Partner Network, Sending Safety, Privacy. Secrets encrypted, kabhi return
nahi hote; blank = purani value, "Clear" = remove; changes audit-logged.
- Email: SMTP/Sendmail/Log, TLS/SSL, From, Admin Notification Emails;
  password resets queue se jate hain.
- Auth: registration on/off, verification None/Email Link/Code, "Send Codes
  From" (admin workspace), approval, DOB Off/Optional/Required, sign-ups ko
  Contacts mein add (Signup tag), disposable emails block (default ON),
  password length 4–128, session timeout, reCAPTCHA (login/register/forgot/
  reset/WhatsApp) — **misconfigured reCAPTCHA = koi sign-in nahi kar sakta**;
  Google/Facebook/GitHub OAuth.
- Currency: ek hi currency, koi conversion nahi.
- Cron Jobs page: Scheduled / Execution Logs / Queued / Failed + Run Now.
  Logs: Audit; laravel-YYYY-MM-DD.log 14 din; Incoming Webhooks replay ke sath.
- Maintenance mode: message + Retry After 5–3600s; admins ko access rehta hai
  (artisan down se farq).
- Error Reporting default OFF; Purchase Code chahiye (encrypted); error type
  + scrubbed message + stack trace developer ko jata hai. **(Phone-home point
  #1 — Phase 0 audit list mein.)**

## Localization
EN + Arabic (RTL) + Japanese shipped; translations DB mein, upgrades mein
bachte hain. Language code 2–3 letters + region/script (pt_BR, zh_Hant, ckb);
RTL automatic; contact ki apni language; import code/name/native name
case-insensitive; ghalat language = `invalid_language`. Editor placeholders
(:name, {{contact.name}}) aur pipe plurals preserve karta hai; progress tabs
alag: Android / Phone Bridge / USB Modem / Mobile App. AI Translate ko AI
provider chahiye. Developer files: lang/<code>/<file>.json (lang/en/ ki
copy), 4-space indent, unescaped Unicode.

## Custom Domains
Subdomains: wildcard DNS + wildcard cert; blocked names www/api/admin.
Tenant custom domain: Messenger Settings > Domain — states Pending DNS →
Securing → Active; CNAME APP_URL host ko ya A record server IP; har 30s
check; exact host only (www variant nahi); apne hosts/registrable domains
refuse; TXT challenge nahi. SSL: `messenger-domain:provision-ssl` har minute
(LE); nginx conf zender-<domain>.conf; helpers zender-certbot/zender-nginx-
site; sudoers zender-ssl; roz 03:30 reverify; Admin Force Verify. Cloudflare:
DNS-only ya "SSL Managed Externally" (CF for SaaS). Realtime main host par
rehta hai. Tracking domains (go.example.com): Link Tracking + Custom Link
Domain plan feature; downgrade par saved domain rehta hai, naye links
default par.

## Privacy / GDPR / Security
Retention: incoming webhooks 30 din; outgoing deliveries 30 din (setting);
cookie consent 730 din; exports 7 din; link clicks 90 din (counts rehte
hain); flow history 90 din; pre-update backups aakhri 3; audit logs "Audit
Logs Days" (0 = indefinite). Opt-out keywords STOP/UNSUB/UNSUBSCRIBE/CANCEL/
END/QUIT; opt-in START/UNSTOP/RESUME (config unsubscribe_keywords.php).
Contact erase: content/media delete, pending sends cancel, khaali rows +
audit rehte hain, number hashed (APP_KEY) opted-out rehta hai. Account
deletion: password + 2FA, grace 0–90 din, scheduler mukammal karta hai.
Security: 2FA + recovery codes; Sending Safety — Trial/Under Review mode,
trial par international restriction, Blocked Words (regex), Blocked/Allowed
Domains, shorteners allow/flag/block, phishing heuristics, Sender ID
approval (Pending→Approved/Rejected). Activity Log per workspace.

## Channels Hub
Types: SMS Provider, Android, WABA. Warnings: SMS login failed ya ≥5 fail +
aaj ke sends ka ≥50% fail; Android paused/offline/no SIM/low battery/update;
WABA token <7 din mein expire, webhook unsubscribed, low quality. Card
actions: Rename, Disable, Sender IDs, Webhook URL, Provider Routes, Test,
Edit, **Get Adapter, Get Modem**, Remove. Plan se bahir channel dimmed
("Not in Plan"). Routing: explicit SIM pehle → provider prefix routes →
default; replies aakhri istemal shuda Sender ID ko tarjeeh.

## SMS Providers (16 drivers)
Twilio, Vonage, Infobip, Custom HTTP, Telnyx, Plivo, Routee, Sinch, Bird,
ClickSend, Bandwidth, Clickatell, Africa's Talking, MSG91, SignalWire,
TextMagic. Twilio webhook: /api/webhooks/channels/sms/<connection-key> +
signature check; TRUSTED_PROXIES. **Custom HTTP:** GET query ya POST/PUT
JSON/Form; placeholders {{to}} {{body}} {{from}}; Message ID Path (default
`id`); Success Field/Value; inbound mapping; status mapping (DELIVRD →
delivered); signature nahi — Allowed IPs se restrict. **Yahi hamare masked-
SMS aggregator (SendPK waghera) ko jodne ka rasta hai.** Sender ID ≤32
chars, pehla default, approval flow. DLT (India) full support (PE ID,
Template ID, {#var#}; MSG91 var1/var2; na-match = refund). 10DLC brand/
campaign sirf reference; Custom HTTP vars {{tcr_brand_id}} waghera.
Provider Routes: longest prefix jeet-ta hai; campaign mein "Use Provider
Routes" on karna parta hai. Max message parts: Twilio/Telnyx/Plivo/Infobip/
SignalWire/Sinch 10; Vonage/Clickatell/MSG91/Routee/TextMagic 6; ClickSend
8; Bird 12. Status callback ?event=status: Africa's Talking, MSG91, TextMagic.

## WABA (official)
Graph API **v22.0**. Webhook /api/webhooks/channels/waba; verify token;
X-Hub-Signature-256; subscriptions: messages, message_template_status_update,
phone_number_quality_update, account_review_update, business_capability_
update, account_update. System user token (whatsapp_business_messaging +
_management); never-expire option. Connect: Business Account ID + Access
Token; numbers plan limit tak sync; templates background sync. Apna Meta app
optional. Number register: 6-digit 2FA PIN. Templates: {{1}}; Utility/
Marketing/Authentication; header text/image/video/document; footer; 10
buttons tak (10 quick reply, 2 URL, 1 phone, 1 copy code); Auth Code Copy/
One-Tap Autofill (One-Tap ko Android Package Name + App Signing Key Hash);
Security Recommendation; Expiry Warning Minutes. Template Library admin-
reviewed (name ≤128, lowercase/digits/underscore; auth expiry 1–90 min;
uncertain submission ko Sync se check karo, naye naam se retry NAHI).
Statuses Approved/Pending/Rejected/Paused/Disabled. 24h window. Account
Health: Resubscribe/Check/Reconnect/Disconnect. Ad Attribution tag.

## Sending performance
Scheduler har minute; ek worker 300s max, overlap lock. SMS: 45s walk,
80s job timeout, DB batch 1,000; WhatsApp chunks ≤100. Bounds: shared
hosting ≤6 walks/run; persistent 2-vCPU worker ≤80 walks/hour. Watchdog har
5 min; 15 min no-progress + kaam baqi = "Not sending" + owner ko email.

## Messenger (shared inbox)
Assignment: round-robin (DB cursor) / least-busy / manual; offline 1–120
min (default 10). Teams/supervisors; labels + rules (≤5 conditions, ≤10
labels); SLA first-response/resolution per priority + business hours;
Requeue Breached; Auto-Close 1–720h (default 24); away message ≤1/5min;
WABA replies sirf 24h window mein; snooze; macros ≤10 actions; scheduled
replies 1 min – 1 saal; review links ≤2,048 chars {{review_link}}; CSAT.
Reverb channels: conversation.{id}.owner / .member.{id} / presence user.
{id}.inbox / agent.{id}; typing throttle 1/2s.

## Contacts
E.164; phone/email per-workspace unique; custom fields Text/Number/Date/
Checkbox/Select/Multi-select/URL/Email ({{contact.key}}); groups/tags/
segments; import CSV/XLSX ≤50MB, 5 steps, ≤2,000 rows foran, bare queued;
email check Valid/Risky/Invalid/Unknown (local DNS); export; duplicate merge.

## Campaigns
5-step wizard; channels SMS/RCS/WABA/WhatsApp/Web Push/Email/Telegram;
merge fields + fallback, {{unsubscribe_link}}, spintax {Hi|Hey}, WABA {{1}},
AI Write; scheduling + Repeat (cron misal 0 9 * * 2#2), Local Time, pacing;
statuses Draft/Scheduled/Running/Paused/Completed/Failed/Canceled; WABA red
quality par auto-pause; A/B 2–5 variants = 100%; send windows; "Do Not Send
After"; Ads attribution 30 din.

## Flows (docs ka sab se bara page)
Triggers: inbound SMS/WABA/WhatsApp/Website Chat/Email, WhatsApp Poll, USSD,
Schedule, Date Field, Webhook, Message Failed, Status, Link Clicked,
Conversation Closed, Payment Received, Form Submitted. Webhook trigger:
POST /api/webhooks/flow/{uuid} + X-Flow-Secret; idempotency 24h.
Send nodes: SMS, RCS, WhatsApp, WABA, Web Push, Email, Telegram, **Phone
Bridge, GSM Modem**. Action nodes: Set Field, Add/Remove Tag/Group, Add Note,
Assign Agent, Add/Remove Drip, Webhook, Generate QR, Send/Verify OTP, Record
Payment, Cancel Run, Add Credits, Create Contact/Lead. Control: Wait,
Condition, Branch, Switch, Loop, A/B Split, Random Split, Jump, End, AI
Message, Ask Question (Text/Number/Email/Phone/Yes-No/Single/Multiple/Media/
Date/Location; timeout 1 min – 30 din). AI node 64–4,000 tokens {{ai.text}}.
Caps: 500 nodes/1,000 edges; 1,000 steps/run; 50 nodes/tick; tick 120s; lock
5 min; Loop 1–10,000 (default 1,000). Expressions: functions upper/lower/
trim/length/contains/replace/substring/split/join/default/now/dateAdd/
dateDiff/formatDate/number/currency/round/random/uuid/wordCount waghera.
Resume: POST /api/webhooks/flow-runs/{uuid}/resume + X-Resume-Token, 7 din
tak (max 30). Drips = Flows par Send+Wait sequences; reports Overview/
Performance/Contacts.

## Forms / OTP / Sign-in with WhatsApp
Subscribe Forms: hosted/embed; white-label; email/phone/dono; consent text,
group, tags; Business Name override. OTP channels: SMS, RCS, Email, Phone
Bridge, WhatsApp, Partner Lines, WABA, **Voice Call**. Inbound Verify by
WhatsApp: POST /api/v1/otp/verifications {"mode":"inbound"} (otp.send);
QR/SVG ek dafa; poll ≥2s; approved → verified_phone; expiry 60–3,600s;
masked logs. **Sign in with WhatsApp = OIDC provider:** issuer {APP_URL}/
oauth/whatsapp, RS256 keys APP_KEY se, rotate 90 din (oidc:rotate-keys
--force), retired JWKS 30 din, APP_PREVIOUS_KEYS. OTP limits: Allowed
Countries, per-recipient/IP/workspace, Resend Cooldown, Max Sends.

## Plans & Billing (core SaaS engine)
Plans Monthly/Yearly/Lifetime + Setup Fee (ek dafa). subscriptions:manage
hourly; reminders 3 din + 1 din pehle; renewal ke 7 din baad expire; pending
14 din baad saaf; cancel → period end tak plan, phir pehle free plan par.
**Plan switches:** SMS, WABA, Messenger, Inbox Automation, **White Label**,
API Access, flows, support, messenger_custom_domain, payment_links,
appointment_booking, ai_agents, ai_flow_generation… na ho to 403
`feature_not_in_plan`. Limits: Contacts, Team Members, Flows, Phone Numbers
(WABA+WhatsApp shared), sms_monthly/waba_monthly, inbound monthly,
max_storage_mb, max_file_size_mb, support_open_tickets; blank = unlimited,
0 = none. Credits: monthly allowance pehle, phir credits (Overage Cost,
blank = 1); failed/cancelled refund; ad-click replies free; allowance se
upar inbound record hota hai, auto-reply nahi. Credit Packs (Name/Credits/
Bonus/Price/Plan Availability; purchases wala pack delete nahi hota).
Vouchers: Subscription/Credits, Max Uses, bulk ≤1,000 + Prefix. Invoices PDF
Billing History se; gateway_webhook_events idempotency. Refunds: partial/
full; full = subscription end / pack credits wapas / plan credits (yearly:
har month) / referral commission wapas; PayPal webhook refund double-count
nahi hota.

## Payment Links / Market / AI / Tours / Landing
Payment Links: workspace apna Stripe/Razorpay/Paystack istemal karta hai —
**platform paisa kabhi nahi pakarta**; payment_links switch lazmi. Stripe
webhook auto-create; Razorpay event payment_link.paid; Paystack currencies
NGN/USD/GHS/ZAR/KES. Flows: Send Payment Link / Wait / Payment Received.
Market: in-dashboard shop, cart nahi (1 product/order). Types: Hardware /
Physical / Digital Download (≤100MB) / License Keys (.txt/.csv ≤2MB) /
Service. Statuses Pending Payment→Paid→Processing→Shipped→Delivered/
Refunded/Cancelled; unpaid auto-cancel 48h (bank transfer 14 din); refund
par download/codes revoke; plan-gated nahi; agents khareed nahi sakte.
**Hardware bechna (modems/adapters) isi Market se hoga.**
AI: ek wallet (SMS+WABA+AI). Pricing precedence Feature > Model > Per Call;
embeddings /1k tokens, speech /1k chars, transcription /minute. Price na ho
= refused, 0 = free; credits pehle katein, failure par refund; admin
workspace free. Seeded: Free 0/BYOK off; Starter 100/off; Pro 500/on;
Enterprise 2,000/on. BYOK Billing > API Keys (0 credits; refusal par
platform key fallback NAHI; downgrade par key bekaar; APP_KEY rotation keys
destroy kar deti hai). Providers: Anthropic, OpenAI, Grok, DeepSeek,
OpenRouter, ElevenLabs (caps: OpenAI sab kuch; OpenRouter Chat/Embeddings;
baqi Chat; ElevenLabs Speech only). Max Tokens 64–16,000; fallback providers
order mein try.
Onboarding: default tour 4 steps; checklist plan/email/contact/channel/
**GSM modem**/first message/invite. Guided Tours admin bana sakta hai
(audience/plans; per page/audience ek active).
Landing Builder: sections Hero/Trusted By/Channels/Shared Inbox/Automation/
Features/AI/Own Your Data + FAQ/Pricing/Testimonials/Video/Rich Text;
draft/publish/history; per-language SEO.

## API (core) — 07-API-MAP ki bunyaad
Base /api/v1; Bearer token (creation par ek dafa dikhta hai); permission
groups Account, Contacts, SMS, WhatsApp, WABA, Messenger, Campaigns, Flows,
**Calls**, Webhooks; `*` = full; key creator ki permissions se upar nahi ja
sakti. MCP presets Read Only / Read+Write / Read Write Send; MCP send cap
20/hour. Limits per key/workspace/IP + Retry-After. Idempotency-Key 24h
replay (Idempotent-Replayed: true; conflict 409). POST /api/v1/messages/sms
→ 202. In-app API Docs + OpenAPI download. Number validation local (free).
Meters 80%/100% par warn. **Admin API = /api/v1/admin — alag paid plugin.**

## Webhooks (core)
Developer > New Webhook; Signing Secret ek dafa. Headers: X-Webhook-
Signature `t=<ts>,v1=<hex>`, X-Webhook-Timestamp, X-Webhook-Event,
X-Webhook-Delivery-Id. Body {id, event, payload, sent_at}. HMAC-SHA256 raw
bytes par; stale timestamp reject (sample 300s). Delivery: 2xx within 15s =
delivered; redirects follow nahi; **private/loopback/metadata addresses save
aur delivery dono par refuse**. Retries 7: 60s, 5m, 30m, 3h, 24h, 72h. 410
Gone = foran unsubscribe. Health/Success Rate (7 din). Rotate Secret purana
foran band. API Access switch lazmi. Events GET /api/v1/webhooks/events.
**Event families (poori list rebuild tree mein jayegi):** otp.*, sms.*
(queued/sent/delivered/read/canceled/failed/received), waba.message.* +
waba.template.approved, wa.message.*, email.message.*, widget.message.*,
push.message.* (received nahi), phone_bridge.message.*, gsm_modem.message.*,
call.started/answered/ended, voicemail.received, recording.ready,
transcript.ready, media_stream.requested, device.online/offline, ussd.
result/completed/failed, contact.created/unsubscribed, form.submitted/
confirmed, payment.paid, commerce.order.* (+cod_confirmed/cod_cancelled),
appointment.*, campaign.started/completed, link.clicked (bots count nahi),
billing.payment.completed, billing.subscription.*, conversation.created/
assigned/resolved, csat.received, webhook.test.

## Permissions
Roles owner control karta hai; role paid feature unlock NAHI kar sakta.
Custom Roles = plan feature. Built-in: Admin 73 permissions (billing/
ownership ke siwa sab), Manager 54, Supervisor 6 (escalations/labels),
Agent 20, Read Only 19; Messenger-only access alag (sirf chat). Admin Roles
(staff) is se alag hain.

## Gateways / Storage / Plugins / Referral / Shared Network
Included gateways: Bank Transfer + PayPal (webhook /api/payment-gateways/
paypal/webhook; BILLING.SUBSCRIPTION.* + PAYMENT.SALE/CAPTURE.COMPLETED/
REFUNDED; signature verify; 5 min se purane events ignore; currencies 25).
Plugin gateways: Stripe, Paystack, Razorpay, Crypto.com Pay, YooKassa,
**Freemius** (docs mein hai, portal catalogue mein Lane 3 ko nahi mila —
31wa item shayad yehi). Setup fee Stripe/YooKassa/Razorpay/Bank Transfer
pehli payment ke sath lete hain.
Storage: **sirf local** (storage/app) — S3 is release mein NAHI (env keys
hone ke bawajood local hi rakho). Folders private/wa-media, private
(imports/exports/tickets), public (Messenger logos); signed short-lived
links; 5MB chunks; 80% warning; storage full ho to inbound message file ke
baghair save. `storage:recalculate [--tenant=ID]`.
**Plugins system:** types = Payment Gateways, SMS Providers, AI Providers,
Channels, Features, Integrations. Plugin = plugins/ folder + **plugin.json**
(name unique, type, version, author, description, requires, settings, icon).
Install: Admin > Plugins > Upload (ZIP ≤20MB, inactive install) → Configure
→ Activate. Update in place (same/newer version). Core plugins uninstall
nahi hote.
Referral: defaults Commission 10%, Signup Bonus 0, Min Redemption 5, Credits
per 1.00 = 100, Attribution 30 din; commission pehli real payment par ek
dafa; refund par clawback; self-referral nahi; redemption sirf credits.
**Shared Network (Partner Network):** partners apni Android / Phone Bridge /
GSM lines share karte hain (**WhatsApp share NAHI ho sakta**); rates text
0.1–5 credits, MMS 0.2–10 (abhi MMS nahi), minute 0.5–20; commission 20%;
hold 72h; min payout 100 credits; quality auto-pause (<80% over 50 msgs/7
din); sender limits 200/hour, 1,000/day; admin lines full platform revenue.

## Admin guide khaas points
Users: suspend = API keys revoke; impersonate admins NAHI kar sakte; owner
delete irreversible. SMPP Servers balancing: down server se move, After 10
min (5–120), Rebalance on, Busy Above 90% (50–100), Moves Per Run 5 (1–50),
auto-return nahi. Status Page: 90-din history, har minute check, 3 bad =
incident, 3 good = resolve, email confirm + RSS. Mobile APK: `php artisan
mobile:install-apk <file>`.

## Error codes (khulasa)
401 unauthenticated; 403 missing_ability/forbidden/feature_not_in_plan/
workspace_pending_review/trial_destination_not_allowed/sending_blocked/
content_blocked/sender_id_not_approved; 404 not_found; 404/503
channel_unavailable; 409 idempotency_conflict; 422 validation_failed/
contacts_cap_reached/recipient_unsubscribed/recipient_blocked/
not_on_whatsapp/no_active_sim_or_sms_provider/insufficient_credits/
storage_quota_exceeded waghera; 429 rate_limited; 500 server_error.

## ⚠️ DOCS MEIN JO NAHI HAI (sab se ahem finding)
1. **Plugin development guide BILKUL NAHI** — koi hooks/events, service
   provider, class/function names, sample code nahi. Sirf plugin.json
   manifest + upload/activate. → Plugin banana source parh kar hi samajh
   ayega (Lane 5). Har plugin ki apni docs us ke ZIP ke andar hoti hai.
2. **Android gateway ki koi setup page nahi** — APK install/pairing, SIM
   selection, long-poll protocol, battery, FCM — kuch nahi; sirf bikhre
   ishare. Aur **Firebase ka docs mein zikr hi nahi**, halanke Welcome page
   kehta hai docs mein setup hai — hai nahi.
3. **SMPP protocol page nahi** — host/port/bind/DLR kuch nahi; sirf plugin
   listing + balancing defaults. SMPP docs plugin ZIP ke andar hain.
4. **WhatsApp QR plugin** ki koi setup page nahi (pairing/session/protocol).
5. Email/Phone Bridge/GSM/RCS/Telegram/Website Chat/Web Push/AI/MCP aur
   integrations ki koi public setup pages nahi — sirf catalogue entries,
   plan switches, webhook families.
6. WhatsApp Embedded Signup: sirf WABA page se ek link.
7. **Database schema/ERD nahi**, poora .env reference nahi, Docker/multi-
   server guide nahi (sirf throughput bounds), changelog nahi, v4 se
   migration/Legacy Importer detail nahi, consolidated CLI reference nahi
   (commands bikhre hue: schedule:run, queue:work, zender:configure-
   realtime, mobile:install-apk, oidc:rotate-keys, storage:recalculate,
   messenger-domain:provision-ssl, subscriptions:grant-monthly-credits).
