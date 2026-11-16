# LANE 4 — LIVE DEMO SIGNED-IN DEEP DIVE (2026-11-15, cloud browser)
Demo: https://zender.titansys.dev — login page khud "Demo Mode" mein demo
admin account publish karti hai (admin@example.com, password site ne
pre-fill kiya). Koi private credential istemal nahi hua. Alag tenant demo
account publish nahi hai — wohi account demo workspace (Titansys / Acme
Inc.) ka owner bhi hai, is liye dono panels ek hi session mein walk hue.
Demo Mode mein settings/destructive actions disabled thay; kuch save/submit
NAHI hua. Neeche ke figures seeded demo data hain (15 Nov 2026).

## A. ADMIN PANEL (/admin/*)
- **Overview:** 30 din — 27 signups, 1,500 subscribers, $27,027 revenue,
  7,000 messages, 14 servers (6 online), 15 open tickets. Charts: signups,
  subscribers, messages, plan revenue.
- **Users:** 53 users; tabs Users/Pending (8)/Deletion Requests; roles
  Admin, Manager, Billing, Support, Content, Operations; Active/Suspended/
  Pending. New User button.
- **Subscriptions:** 41; Owner/Email/Plan/Status/Cycle/Renews; Active/Past
  due/Expired.
- **Tickets:** 20; Open/Closed; ref/subject/assignee/status.
- **Referrals:** 16 commission entries; Referrer/Commission/Withdrawn/
  Balance; Settings button.
- **Plans (5):** Demo $0 (Private), Free $0, Starter $19, Pro $49 (Popular),
  Enterprise $199 — har plan ke sath contacts/channels/members/SMS-month/
  credits/subscribers ki limits admin UI mein dikhti hain. Drag-reorder,
  Edit/Deactivate/Delete.
- **Credit Packs:** 8 bundles (1,000 credits $25 +200 bonus … 8,000 $200
  +500), sab Inactive (demo mein actions disabled).
- **Vouchers:** 24, New Voucher + Bulk Generate.
- **Transactions:** 115; gateway/type/refund/status filters; TXN- IDs;
  Completed/Pending/Refunded/Failed.
- **Market (admin):** 24 draft physical products ($25–$144, stock 0);
  tabs Products/Orders, Categories, New Product.
- **Partner Network:** Partners 12 workspaces (Lines 1–4, Performance,
  Commission, Approved/Suspended, Grant Partner); Payouts — total owed
  $1,786, 24 requests (Bank Transfer; Paid/Declined); Lines 12 (sab Offline;
  Network ID SIM1 type; Price/Text $0.2–$0.8; Shared/Not Shared/Paused);
  Reports 0 (report par earnings hold hota hai jab tak admin faisla na kare).
- **Servers (har ek: Name/Status/Region/Version/Load + Balancing toggle +
  New Server):**
  - WA Servers: 1 (Healthy, v5.0.4, 0/100 WhatsApp)
  - Telephony Servers: 1 (Healthy, host :443 masked, Quick Tunnel Off,
    0/500 Devices)
  - SMPP Servers: 1 (Healthy, v5.0.4, 0/500 SMS Providers)
  - Telegram Servers: 1 (Healthy, v1.0.0, 0/500 Telegram Bots)
  - Email Servers: 1 (Healthy, v1.0.0, 0/500 Mailboxes)
  → **Infra natija: har channel family ka apna alag server program hai jo
  admin mein register + balance hota hai — yahi Lane 6 ka naqsha hai.**
- **Status Page:** 46 incidents (sab "SMPP down" seeded), 1 Open; tabs
  Incidents/Settings.
- **Landing Builder:** alag UI (sidebar nahi); sections Header/Hero/Logos/
  Features/AI Highlights/App Preview/Messaging/Workflows/Pricing/FAQ/
  Testimonials/CTA/Footer; pages Landing/Pricing/Blog/Channels/Contact;
  Settings/Preview/Edit/Publish.
- **Custom Pages:** Terms/Privacy/Cookie — Published; New Page.
- **Guided Tours:** 8 active tours (Dashboard 12 steps, Campaigns 5,
  Channels 5, Flows 4, AI Agents 4, API Keys 4, Messenger Overview 5,
  Status Page 5).
- **Languages:** English (default), Arabic (RTL), Japanese — 100% translated.
- **Domains:** 41 workspaces, sab ke Subdomain/Custom Domain "None/Off"
  (pehle Settings → Domains se enable karna parta hai).
- **AI Providers:** 1 demo provider (Anthropic, claude-haiku-5-5, 1,024 max
  tokens, 10 credits/request).
- **Admin Roles:** Super Admin 62 permissions, Billing 24, Operations 18,
  Support 6, Content 4; New Role.
- **Cron Jobs:** 121 jobs; tabs Scheduled/Execution/Queued/Failed; Run Now;
  misal "Renew active subscriptions", "Rebuild message stats".
- **Abuse Review:** tabs Flagged/Workspaces/Blocked Words/Blocked Domains.
- **System Logs:** Audit 1,506 entries; tabs Errors/Incoming Webhooks/
  Privacy; Time/Actor/Action/Target/IP.
- **Plugins:** 42 total — poori list section C mein.

## B. TENANT PANEL (workspace Titansys / Acme Inc.)
- **Overview:** 3,728 sent (+63.2%), 50 failed, 1,669 received, 98.7%
  delivery, 174 new contacts; credits 9,034 (~133 din); Enterprise plan;
  channel counts Email 657 / SMS 659 / Telegram 672 / WhatsApp 665 / WABA
  661 / Website Widget 414. 10-step welcome tour.
- **Campaigns:** 28 campaigns (channel/status/delivered/failed/replies/
  clicks). Tabs: Campaigns; **Email Templates** (30); **WhatsApp Ads** (24,
  Attribution Settings). New Campaign composer 5 steps (Channel → Audience
  → Message → Schedule → Review & Send); channels SMS/WABA/Telegram/Email/
  Web Push/WhatsApp; SMS par "No SMS sending source — Pair a Device or Add
  a Provider" + phone preview.
- **Channels:** 7 channels — WABA (Inactive), WhatsApp QR (Disabled,
  "Failed to sync — device disconnected"), Phone Bridge (Disabled), Website
  Widget ×2 (ek Live), Email mailbox (Disabled, "Ramping up…"), Telegram
  Bot (Disabled). **Connect Channel wizard 4 steps** (Channel → Select
  Provider → Configure → Review); channel types: WhatsApp/WABA/SMS/RCS,
  Email, Telegram, Website Widget, Phone Bridge, GSM Modems, Web Push,
  WABA Embedded Signup.
- **Network (tenant):** "Shared network is currently unavailable" — partner
  lines se credits ke badle text bhejne ki sahulat ki wazahat maujood.
- **Files:** 27 files, 532 KB; "Recordings" folder (8); filters Source/
  Type/Channel/Size/Date; New Folder/Upload.
- **Messenger:** 29 conversations; views Conversations/My Inbox/Mentions/
  Participating/Unattended/**Live Visitors**; 12 Teams; channels SMS, RCS,
  WABA, WhatsApp, Phone Bridge, GSM Modems, Website Widget, Web Push; 24
  Labels; Mine/Unassigned/All tabs; "Open Next". **Overview:** 29 open, 58
  conversations, 29 resolved, first response 7m, resolution 40m, 4 SLA
  breaches, CSAT 4.6/5, Live Queue. **Tools:** Labels 24; Rules 24 (sab Off;
  trigger "When Channel is…", action "Then —"); Macros 27 (misal "Assign to
  Support Team and close" = Add label + Set priority + Closed).
- **Workspace:** Members 13 (12 seats; Owner + 12 Agents); Teams 12 (Support,
  Sales, Billing, Onboarding, Retention, VIP, Escalations, Product,
  Compliance, QA, Logistics, Marketing — har team ka named lead); Roles:
  Admin 73, Manager 54, Supervisor 6, Agent (demo mein 6 permissions dikhe);
  Activity Log 35 (Export CSV). **Workspace Settings sections:** Inbox,
  Notifications, Lead Capture, AI Agents, Away Messages, SLA, CSAT, General,
  Data Retention, Business Hours, Reviews, **Branding**, Shipping Address.
  Inbox defaults: Assignment Round-robin, Agent Offline 10m, Auto-Close 24h.
  General: Phone Offline Alert 15 min.
- **Branding (white-label, tenant):** logo upload (PNG/JPG/WebP ≤2MB), Brand
  Color (#2563eb demo), Business Name, Business Address. Preview dikhata
  hai branding kahan lagti hai: **Messenger sign-in page, unsubscribe/
  payment pages, invitation pages, email footer.**
- **Contacts:** 400 contacts; tabs Contacts, Phone Opt-Outs, Suppressed
  Emails, Suppressed WhatsApp, Segments, Duplicates, Privacy Requests,
  Settings. Import/Export CSV; Add Contact dialog (First/Last Name, Phone,
  Email). Groups 24 segments; Tags 24; **Forms:** 12 subscribe forms (30
  submissions/27 confirmed each; Double Opt-In Disabled). **Bookings:**
  (paid plugin) Appointments/Services/Team tabs, booking page Off.
  **Payments:** Payment Links/Providers tabs, 0 links.
- **Flows:** 8 (1 Active "Website Chat Welcome", 7 Draft; har ek 24 runs).
- **Drips:** 8 sequences × 3 steps; 7 Paused, 1 Draft.
- **AI Agents:** 8 agents (sab Off); templates Support/Sales/Appointments/
  Order Status/Custom/Lead Qualification; channels Telegram/WABA/WhatsApp/
  Email.
- **Call Prompts:** 8 prompts (0:01, Ready, Play button).
- **Integrations (tenant):** 11 apps — Blesta, Browser Extension, Flarum,
  Google Sheets (Not Connected), Odoo, osTicket, Perfex, Shopify, Telegram
  Store, WHMCS, WordPress; har ek "Connection Details" + event counts.
- **API Keys:** 64 keys; tabs API Keys / **MCP Connections**; "Stream
  Secret" + New API Key; permissions columns (aksar "No permissions", kuch
  sms.read). MCP connection "MCP Server" Active bhi listed.
- **OTP:** Usage — 32 starts, 24 approved, 75% conversion (sab SMS/US).
  Settings: Delivery (SMS timeout 60s, Email 120s, Resend 30s, Max sends 3,
  **Retry on Another SIM on**; WhatsApp unofficial + Partner Lines off) +
  Protection/Messages/WhatsApp Message sections. Tabs Usage/Settings/
  Sign-In Apps.
- **Webhooks:** 12 (sab Disabled; endpoints integrations.acme.example).
- **Message Logs:** 10,000+ rows; Time/Direction/Contact/Connection/Message/
  Status/**SIM**/Source; Export CSV.
- **Call Logs:** Report — 32 calls (21 in / 11 out), 78% answer rate, 4m
  avg, 112 billable minutes; per-agent + per-device tables.
- **Market (tenant):** products khaali (admin wale sab Draft thay); My
  Orders 24 (DEMO-ORDER-*, 16 Delivered/4 Cancelled page 1 par).
- **Billing (tenant):** Enterprise $199/mo Active, renews 2026-12-14;
  credits 9,034.08 (+2,000/period, rollover on); Buy Credits; Redeem Voucher
  (WELCOME50 placeholder); History Grants/Debits; links Referrals, Message
  Costs, AI Usage. **Plans comparison (vendor ke demo plans — hamare apne
  plans mukhtalif honge):** White Label = Pro+; Messenger Custom Domain =
  Pro+; Custom Roles = Enterprise; Shared Network = Starter/Pro (ajeeb:
  Enterprise par nahi dikha); **RCS/Telegram/Phone Bridge/GSM Modems =
  Enterprise only**; API Access = Starter+; OTP = Starter+; Webhooks =
  Pro+; AI Agents = Pro+; Call Logs = Pro+; Bookings = Pro+; Drips =
  Starter+; Flows = sab plans.
- **Help:** Guides 11 cards; Support 12 tickets (3 Open); sidebar docs
  links: API Docs, **Android Docs**, Workspace Docs, WhatsApp Docs, WABA
  Docs, Email Docs, Phone Bridge, GSM Modems, MCP Docs, Telegram Docs,
  Error Codes. (Ye per-plugin docs links hain — in ki study Lane 5/6 mein
  source ke sath hogi; demo walk mein individually nahi khole gaye.)

## C. PLUGINS — /admin/plugins (42 TOTAL; 3 "Needs Attention")
Core (Active, Configured): Bank Transfer (Payment v1.0.0), SMS Providers
(v1.0.0), WABA (v1.0.0). PayPal (Core, Not installed).
Free (Active, Configured): Android Gateway v5.0.4; WhatsApp v5.0.4; SMPP
SMS Provider v5.0.4 (requires SMS Providers); WhatsApp Embedded Signup
v5.0.4 (requires WABA). Not installed: Legacy API Wrapper v1.0.0, Legacy
Importer v5.0.4.
Paid Active/Configured: AI Agents, AI Flow Builder, MCP (AI); Email v1.0.0;
GSM Modems **v1.0.4**; Phone Bridge **v1.0.4**; Telegram; Web Push; Website
Chat; Appointment Booking v1.0.1; Blesta; Browser Extension; Flarum; Google
Sheets; Odoo v1.0.1; osTicket v1.0.1; Shopify; Telegram Store (Telegram
Extension, requires Telegram); Admin API v1.0.1 (Tools).
Paid Not installed: Crypto.com Pay, Paystack, Razorpay, Stripe, YooKassa
(Payment v1.0.0 each); **Freemius v1.1.0**; Auto Update v1.0.1 (Tools).
"Extended" label ke sath Active: Perfex v1.0.1, WHMCS v1.4.2, WordPress
v1.1.2 (Extended holders ke liye free wale).
**Inactive — Configuration required (3):** Knowledge Base; **GoHighLevel
v1.0.0**; **monday.com v1.0.0** — ye do plugins (GoHighLevel, monday.com)
na products portal par thay na docs catalogue mein; demo se pehli dafa
samne aye. **Kul plugin universe ab 42 hai.**
Har installed plugin par Configure (+ Uninstall, demo mein disabled);
not-installed par Install. Alag marketplace screen nahi — install isi page
se hota hai. Tenant Integrations page inhi ki tenant-facing shakl hai.

## D. ADMIN SETTINGS (15 groups — sab khole gaye)
- **General:** Site Name "Zender", Tagline, Description, Branding (Logo/
  Dark Logo/Favicon — default), Default Theme System, **Color Theme Neutral
  (options Blue/Green/Orange/Red/Rose/Violet/Yellow)**, Timezone, Date
  Format, Public API Docs on, Error Reporting on, **Purchase Code
  (encrypted)**.
- **Contact:** support email/phone/WhatsApp + social links.
- **Custom Code:** Load Custom Code on; Custom CSS; Head Code; Footer Code;
  Consent Marketing — sirf public pages par.
- **Domains:** Workspace Subdomains Off; Custom Domains Off.
- **Integrations:** Realtime Pusher (cloud) ap1 cluster; Test Connection.
- **Mobile App:** Enabled; **APK zender-demo-mobile-v5.0.4.apk, 99 MB,
  v1.0.0**; Play/App Store links; **Firebase push Configured**.
- **Support:** Tickets on; Max Open Tickets/User 5; File 10MB; Attachments 5.
- **Maintenance:** Off; Retry After 60s.
- **Billing:** Currency USD; Market Enabled; Ships To Worldwide.
- **Referral:** on; 10%; bonus 0; attribution 30 din; min redemption 5;
  100 credits per 1.00.
- **Partner Network:** rates Text $0.1–$5, MMS $0.2–$10, Minute $0.5–$20;
  commission 20%; hold 72h; min payout $100; methods Bank Transfer/PayPal;
  Reply Window 7 din; auto-pause <80% after 50 msgs; sender limits
  200/hour, 1,000/day; Trust Auto.
- **Authentication:** Registration on; Block Disposable on; Signups→Contacts
  on; Min Password 8; Session Timeout 120 min; Verification Email Link;
  Manual Approval off; reCAPTCHA off; Google/Facebook/GitHub OAuth (callback
  URLs); "Sign In with WhatsApp" OTP ke baghair disabled.
- **Email:** SMTP, port 587 TLS; Server Alerts on.
- **Sending Safety:** Trial on (3 din, 50 messages); Sender IDs Require
  Approval off; URL Policy Blocklist Only; Shorteners Allow; Phishing Flag.
- **Privacy:** Cookie Banner Automatic; Consent 730 din; Self-Service
  Deletion on (grace 14 din); Download My Data on (24h gap); retention
  Audit 0 (forever), Exports 7d, Webhook Logs 30d, Link Clicks 90d, Flow
  History 90d, Backups 3.

## E. White-label — hatmi natija
Platform branding admin se (site name/tagline/logo/dark logo/favicon/color
theme); tenant branding workspace se (logo/color/name/address → Messenger
sign-in, unsubscribe/payment pages, invitations, email footer); landing
poori Landing Builder se editable; White Label aur Messenger Custom Domain
plan features hain (Pro+). **Signed-in tenant view mein koi "Powered by
Zender" nahi dikha** — ye hamara purana unverified sawal tha, demo ki hadd
tak jawab mil gaya: branding vendor ki nahi, site owner ki chalti hai.

## F. Haddeen
Sirf ek demo account publish hai (admin); alag tenant login nahi — tenant
panel usi account ka workspace hai. Demo Mode mein Save/Activate/Uninstall/
Cancel disabled thay. Kuch hisse seeded lekin ghair-faal: tenant Network
unavailable, campaign composer mein SMS source nahi, channels aksar
Disabled, tenant Market khaali (products Draft). Sidebar ke per-plugin docs
links (Android/Phone Bridge/GSM/MCP waghera) is walk mein individually nahi
khole gaye — woh Lane 5/6 mein source ke sath parhe jayenge.
