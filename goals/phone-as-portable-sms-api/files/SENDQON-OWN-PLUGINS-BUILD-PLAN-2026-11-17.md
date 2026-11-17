# SENDQON OWN-PLUGINS BUILD PLAN — Phase-wise (2026-11-17)

Owner ka faisla (2026-11-17): planning + tyariyan shuru hon, aur **har
cheez "plugins ki terhan" bane gi** — yani vendor ke plugin architecture
ke andar, apne plugins ke tor par. Ye document master plan
(`ZENDER-CORE-PLUS-OWN-PLUGINS-PLAN-2026-11-15.md`, phases + Addenda
1–10) aur rebuild tree (`zender-rebuild-tree/`: `00-OVERVIEW.md`,
`05-INFRA.md`, `08-REBUILD-ROADMAP.md`, `09-USP-ADDENDUM-10.md`) ko ek
**build programme** mein badalta hai: kya, kis tartib mein, kis type ke
plugin ke tor par, aur kis acceptance test ke sath bane ga.

Grounded facts jo har jagah lagu hain:

- Core = Zender 5.0.4 (Laravel 13.37, PHP 8.4, React 19), live
  production `sendqon.rektrs.com` (offbox-1, ServerKit/Docker).
- Plugin system: **9 contract-based types** (Lane 5 §5), namespaces
  `App\Plugins\` par locked, har plugin `app/Plugins/<Type>/<Name>/` +
  `plugin.json`, install ZIP **≤ 20 MB**, install/activate
  `PluginManager` ke through (live par prove shuda route — plugins
  settle report 2026-11-16).
- **Hard limit (Lane 5):** jis channel ko companion server program
  chahiye, us ki core-side registration
  `app/Services/Channels/ChannelPlugins.php` mein hoti hai — ye
  plugin sandbox ke bahir ki ek core touch hai, is liye hamesha
  patch register se guzre gi.
- Patch register ab tak: **PR-001** (docker-entrypoint +
  `TRUSTED_PROXIES=*`), **PR-002** (entrypoint `storage:link`
  durability), **PR-003** (PKR currency — `app/Support/Currencies.php`
  + `resources/js/lib/currency.ts`). Register ki discipline
  `05-INFRA.md` mein hai; entries lane reports mein darj hoti ayi
  hain — is programme se pehle register ko ek alag file mein
  consolidate karna tyariyon mein shamil hai (§2.4).
- Licence gate (standing): Regular licence held hai; custom licence
  ki application vendor ke pas in progress hai. **Custom licence
  land honay tak end users se charge NAHI hoga** — plugins bante
  rahen ge, commercial launch usi gate par ruka rahe ga.

---

## 1. Architecture rules — sab kuch plugin ki terhan

1. **Plugin first.** Har nayi feature pehle 9 contract types mein se
   kisi ek ke tor par design hogi: `channel`, `sms_provider`,
   `payment_gateway`, `integration`, `tool`, `telegram_extension`
   waghera (poori list Lane 5 §5). Jo feature kisi contract mein fit
   na ho, woh ruk kar pehle design review se guzre gi — core edit
   default jawab NAHI hai.
2. **Companion-server pattern (vendor ka apna pattern).** Jis channel
   ko background engine chahiye (WhatsApp bridge, Telegram account
   mode, Email sync), wahan plugin (PHP, panel side) + **hamara apna
   companion service** hoga — bilkul waisay jaisay vendor ke WhatsApp/
   SMPP/Telegram/Email servers hain. Hamara service:
   - Admin mein **Service Server** ke tor par register hoga (wahi
     `service_servers` kind, wahi capacity/load-balance surface);
   - core se wahi surface bolega: Reverb private channels (live
     traffic) + `api/v1/internal/*` (lifecycle/bootstrap) +
     generated `config.json` bootstrap;
   - **koi licence gate NAHI hoga** — vendor binaries wala
     purchase-code placeholder hamare builds mein nahi hoga;
   - core-side `ChannelPlugins.php` registration is pattern ki
     wajih core touch hai → patch register entry lazmi (§2.4).
3. **Core edits: sirf jahan contract majboor kare.** Har core touch:
   (a) pehle patch register mein PR-### entry (file, reason, diff
   summary, upstream version 5.0.4), (b) host build tree
   (`~/sendqon-build/src/`) mein bhi mirror, taake agli image build
   mein patch zinda rahe (PR-003 precedent), (c) vendor update aye
   to register se re-apply/check ho.
4. **Clean-room discipline.** Vendor ke compiled components (Go
   binaries, vendor APK) kabhi decompile/copy NAHI honge. Replacements
   sirf PHP-visible contract, public protocol knowledge aur apni
   install par observed behaviour se bane ge (rebuild tree
   `04-NO-SOURCE/` ki specs).
5. **White-label.** Har plugin ki identity Sendqon hogi: naam,
   plugin.json author, UI strings, icons — vendor ka naam/brand
   kahin nazar nahi aye ga. Urdu/Roman Urdu strings USP-1 ke sath
   (§3, Phase B2).
6. **Standalone.** System Operqon se coupled NAHI hoga. Koi
   integration chahiye ho to loose REST API / signed webhooks
   per-tenant — woh bhi Operqon stop lift honay par. Is programme
   ka koi phase Operqon par depend NAHI karta.
7. **Plan-gating by design.** Har plugin apni feature ko plan flag
   se jor kar bane ga (core ka plan/feature system), taake kis plan
   mein kya mile — ye admin ka faisla ho, code ka nahi. (MCP card
   mein is ki concrete misaal hai, §4.)
8. **Sending safety defaults.** Jo plugin bhej sakta hai, us mein
   rate limit + opt-out + per-connection caps pehle din se
   (consumer-SIM throttle risk — master plan standing rule). MCP ke
   safety rules (§4) is ki template hain.

---

## 2. Preparations — tyariyan (Phase B0, kisi bhi build se pehle)

### 2.1 Plugin skeleton + template
- Ek **Sendqon plugin skeleton** bane ga: `plugin.json` template
  (Sendqon author/branding ke sath), type-wise stub classes (9
  contracts mein se jo hamare kaam ke hain: channel, sms_provider,
  payment_gateway, integration, tool, telegram_extension), config
  schema helper, migration stub (plugin ki apni tables —
  `06-DATABASE-MAP.md` ka plugin table pattern), aur ZIP packaging
  script jo ≤ 20 MB limit + structure validate kare.
- Reference implementations: core ke shipped plugins (PayPal, Bank
  Transfer — manifest + config-schema shells) aur free plugins
  (Legacy Importer = plugin-architecture reference, roadmap ki
  stance). Vendor plugin files ke watermark wale hisse ko haath
  nahi lagana (roadmap open item #10).

### 2.2 Dev workflow — production live hai, mehfooz rasta
Production par asal system chal raha hai; development wahan NAHI
hoga. Tarteeb:

1. **Dev copy:** host build tree `~/sendqon-build/src/` live app ko
   mirror karta hai. Har plugin pehle ek **alag containerised dev
   copy** mein bane ga (usi image se compose copy, apni DB —
   production DB ka sanitised snapshot ya seed data; production
   credentials dev mein NAHI).
2. **Package:** plugin ko ZIP (≤ 20 MB) bana kar dev copy par
   `PluginManager::installFromZip()` + `activate()` se install —
   bilkul wahi route jo production par jayega.
3. **Local pass:** §2.3 ka type-wise acceptance harness dev copy par
   green ho.
4. **Production install:** pehle backup (DB dump + config tar —
   nightly backup wala pattern, APP_KEY mehfooz), phir PluginManager
   se install/activate. Koi bhi plugin seedha file-copy se live
   NAHI jayega.
5. **Rollback:** har install ke sath rollback note likha jayega —
   aam tor par: PluginManager se deactivate → uninstall → (agar
   plugin ne core touch kiya tha) register entry ke mutabiq patch
   revert → backup se plugin rows restore. Rollback dev copy par
   ek dafa rehearse hoga.
6. **Vendor-tree purity:** `zender-branches/*` pristine rahen ge;
   apna code sirf build tree + plugin ZIPs mein.

### 2.3 Acceptance harness — type-wise (har plugin ke liye lazmi)
| Plugin type | Minimum acceptance battery |
|---|---|
| `payment_gateway` | Test/sandbox mode mein checkout end-to-end (plan subscribe ya payment link) → webhook aye, signature verify ho, galat signature reject ho → payment panel mein settled dikhe → refund/cancel path (gateway support kare to) → duplicate webhook idempotent rahe |
| `channel` (companion ke baghair) | Test workspace mein channel connect → ek asal message send + ek receive → Messenger thread sahi bane → disconnect/reconnect saaf ho |
| `channel` (companion ke sath) | Service Server register → health green → channel connect → send + receive asal message → server restart par session/state wapas aye → server down par core ka move/health behaviour dikhe |
| `sms_provider` | Test bind/credentials → ek asal SMS deliver → DLR wapas aye → ghalat credentials par saaf error, crash nahi |
| `integration` | Trigger event → bahir ke system mein record bane/update ho → wapas ka event (webhook) idempotent ho (replay par duplicate na bane) → credentials tenant ke apne hon, free-text nahi — system ke data se selection |
| `tool` | Tool ka surface (API/UI) har permission level par test: jis role ko access nahi, use saaf refusal → audit log mein entry |
| `telegram_extension` | Parent Telegram channel live honay par hi activate ho → extension ka flow bot par end-to-end chale |

Aam shartein har battery mein: plugin deactivate karne se core
baki features chaltay rahen; plugin ki tables usi ke namespace
mein; koi vendor phone-home nahi (apne plugins mein Sentry-vendor
endpoint bilkul nahi).

### 2.4 Patch register step (har core touch ke liye)
1. Kaam se PEHLE register mein PR-### entry: file(s), wajah,
   diff summary, upstream version (5.0.4).
2. Register ko ab ek consolidated file mein lana hai
   (`PATCH-REGISTER.md`, goal files mein) — PR-001…PR-003 purani
   reports se utha kar, aage ke saare entries yahin. (Tyariyon ka
   pehla kaam.)
3. Patch host build tree mein mirror + agli image build ki
   checklist mein shamil.
4. Vendor update aye to: register ki har entry naye version par
   re-verify — jo patch upstream mein aa gaya ho, woh entry
   "absorbed" mark ho.

### 2.5 B0 checklist (tyariyan mukammal = ye sab ho)
- [ ] `PATCH-REGISTER.md` consolidated (PR-001…003 darj).
- [ ] Plugin skeleton + ZIP packaging script (≤ 20 MB validation).
- [ ] Dev container copy khari hai (apni DB, production se alag).
- [ ] Type-wise acceptance harness ki checklist templates.
- [ ] Backup + rollback ka ek rehearsed run (kisi dummy plugin par).

---

## 3. Phase-wise build table

Tarteeb master plan Phase 4 ki priority + roadmap ki dependency
order se hai: **MCP → Payments (Pakistan pack pehle) → AI → Channels
→ Integrations → Vertical packs → bare replacements (Android app,
WhatsApp bridge) → Telephony/hardware → Reseller++ aakhir mein.**
Beech ke channels interim vendor/free implementations se chal rahe
hain, is liye bare replacements peeche hain — service rukti nahi.

Size key: **S** = chand din, **M** = 1–2 haftay scale, **L** = bara
(3+ haftay scale), **XL** = sab se bara / multi-part. (Roadmap ki
difficulty se mapped: Easy→S, Easy–Medium→S/M, Medium→M,
Medium-Hard→L, Hard→XL.) Vendor price woh hai jo tree file mein
darj hai — ye woh raqam hai jo hum nahi de rahe.

### Phase B1 — Pehla plugin: MCP
| Item | Replaces | Type | Size | Depends on | Acceptance (ek line) |
|---|---|---|---|---|---|
| MCP plugin | $120 (no Extended discount) | `tool` | M | Core `laravel/mcp` plumbing (mojood) | Poora card §4 mein — pehla build yahi hai |

### Phase B2 — Payments + USP-1 (Pakistan-first pack)
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| JazzCash gateway | vendor ke pas hai hi nahi (USP-1) | `payment_gateway` | M | Owner: merchant account + API credentials (§5) | Sandbox checkout → callback verify → plan active; galat hash reject |
| EasyPaisa gateway | vendor ke pas hai hi nahi (USP-1) | `payment_gateway` | M | Owner: merchant account + credentials (§5) | Sandbox checkout → callback verify → plan active; duplicate callback idempotent |
| Raast gateway | vendor ke pas hai hi nahi (USP-1) | `payment_gateway` | M | Route UNVERIFIED — bank/aggregator integration build time par tay hoga (§5) | Ek asal chhota payment end-to-end reconcile ho |
| Stripe | $39 | `payment_gateway` | M | Core mein `stripe-php` SDK mojood; owner: Stripe account (§5) | Test-mode subscribe + webhook settle + refund path pass |
| Paystack | $39 | `payment_gateway` | M | B2 ka gateway pattern tayyar | Test checkout + webhook verify pass |
| Razorpay | $39 | `payment_gateway` | M | Core mein razorpay SDK mojood | Test checkout + webhook verify pass |
| YooKassa | $39 | `payment_gateway` | M | Core mein yookassa SDK mojood | Test checkout + webhook verify pass |
| Crypto.com Pay | $39 | `payment_gateway` | M | — | Test checkout + webhook verify pass |
| Freemius | UNVERIFIED (portal par hai hi nahi) | `payment_gateway` (agar bana) | — | **Evidence first** — price/features sab UNVERIFIED; zaroorat sabit honay tak NAHI bane ga | — |
| PTA mask workflow (USP-1) | vendor ke pas nahi | `tool`/`integration` | M | Aggregator contract (owner/commercial, §5); mask display open item #12 aggregator se confirm | Tenant panel se mask apply → status track → approved mask se test SMS (aggregator route) |
| Urdu/Roman Urdu pack (USP-1) | vendor ke pas nahi | core localization (config) + templates | S | Core localization module (keep) | Urdu UI strings live; tayyar templates (fee reminder, COD) ek test campaign mein sahi render hon |

Note: Bank Transfer + PayPal **core mein pehle se hain** — is phase
mein sirf un ki activation owner steps par hai (§5), koi build nahi.

### Phase B3 — AI group (shared core AI wallet par)
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| AI Flow Builder | $59 | `integration` | M | Core flows engine + AI providers/credits (keep) | AI se bana flow save ho, test chat mein chale, credits sahi katein |
| Knowledge Base | $59 | `integration` | M | Core-vs-plugin split pehle verify (open item #5) | Document upload → AI jawab source ke sath aye; tenant data alag rahe |
| AI Agents | $59 | `integration` | XL | Flow Builder + Knowledge Base tayyar | Agent ek asal conversation sambhale, handoff rule par insaan ko de, har action audit mein |

### Phase B4 — Channels group + USP-3 (Deliverability engine)
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| Website Chat | $59 | `channel` (key `widget`) | M | Core-vs-plugin split verify (open item #5) | Test site par widget → chat Messenger mein aye → jawab site par wapas jaye |
| Web Push | $59 | `channel` (key `push`) | M | — | Browser subscribe → push campaign deliver → unsubscribe kaam kare |
| Telegram (bot mode) | $59 | `channel` (key `telegram`) | M | Bot API — companion server nahi chahiye | Bot connect → private chat inbox mein → campaign bot par deliver |
| Telegram server replacement (`04-NO-SOURCE/telegram-server.md`) | closed binary | companion service (apna) | M | Telegram plugin; account mode ke liye Telethon/TDLib design (internals UNVERIFIED — open item #7) | Service Server register + health green; user account connect (phone+code) bot ke sath chale |
| Telegram (account mode) | $59 ka doosra hissa | `channel` | L | Apna Telegram server tayyar | User account se send/receive; flood-limit par saaf behaviour |
| Telegram Store | $59 | `telegram_extension` | M | Telegram channel live | Bot par store catalogue → order flow end-to-end |
| Email channel | $59 | `channel` (key `email`) | M | Apna Email server (neeche) | Mailbox connect → email thread inbox mein → reply usi mailbox se jaye |
| Email server replacement (`04-NO-SOURCE/email-server.md`) | closed binary | companion service (apna) | M | Standard IMAP/SMTP service design (tree spec) | Service Server register; mailbox sync + send; warmer ka basic run |
| HLR number validation (USP-3) | vendor ke pas nahi | `integration` | M | Lookup provider ka contract build time par (provider choice `05-INFRA.md` mein darj hogi) | Campaign se pehle dead numbers filter hon, report sahi aye |
| Cross-channel cascade (USP-3) | vendor ke pas nahi | `integration` (flows par) | M | WhatsApp + SMS + Email channels live (Email is phase mein) | Test flow: WhatsApp fail → SMS jaye → woh bhi fail to email; har qadam log ho |
| Spam-content score (USP-3) | vendor ke pas nahi | `tool` | S | Core campaigns | Risky text par score + warning bhejne se pehle aye; saaf text bina rokay jaye |

### Phase B5 — Integrations
Pehle **quick/config-style** (pattern ek jaisa: branded connector
download ya API-key/OAuth connect — `04-NO-SOURCE/
browser-extension-branded-builds.md` wala pattern), phir **real
builds**.

| Item | Replaces | Type | Size | Style | Depends on | Acceptance |
|---|---|---|---|---|---|---|
| Google Sheets | $59 | `integration` | S | quick | — | Contact/message row sheet mein bane; flow node se bhi chale |
| Browser Extension | $59 | `integration` | S | quick | Branded-build pattern (§2.1) | Apni branded build download → browser mein load → dashboard action kaam kare |
| osTicket | $59 | `integration` + osTicket-side plugin | S | quick | — | Chat se ticket bane; status wapas sync ho |
| Flarum | $59 | `integration` + Flarum extension | S | quick | — | Forum event par message trigger ho |
| Appointment Booking | $59 | `integration` + flow node | S | quick — lekin pehle core-split verify (open item #5) | Booking → reminder flow end-to-end |
| WordPress / WooCommerce | $59 (Extended par FREE tha) | `integration` + WP plugin | M | real | Branded connector pattern | WP site connect (bina API-key typing ke approval flow) → WooCommerce order event par WhatsApp/SMS jaye |
| WHMCS | $59 (Extended par FREE tha) | `integration` + WHMCS addon | M | real | — | Invoice event par client ko message jaye |
| Shopify | $59 | `integration` | M | real | — | Order event → message; abandoned-cart trigger kaam kare |
| Perfex CRM | $59 (Extended par FREE tha) | `integration` + Perfex module | M | real | — | CRM event par message trigger ho |
| Blesta | $59 | `integration` + Blesta plugin | M | real | — | Billing event par message jaye |
| Odoo | $59 | `integration` + Odoo addons (3) | L | real | — | Odoo record event → message; do-tarfa sync ka basic pass |
| Admin API | $39 | `tool` | M | real | — | Admin-level API se tenant/plan action ho; permission baghair refusal. **Pull-forward:** Operqon coupling schedule ho to ye pehle aa sakta hai |
| GoHighLevel | UNVERIFIED | `integration` (presumed) | — | **Evidence first** — sirf demo list se existence; docs milein tab spec bane | — |
| monday.com | UNVERIFIED | `integration` (presumed) | — | **Evidence first** — upar ki terhan | — |

### Phase B6 — Vertical packs (USP-5) — channels ke baad
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| Schools pack | vendor ke pas nahi | `integration` (templates+flows+reports bundle) | M | B4 channels; IQRS experience reference spec | Test workspace mein fee-reminder flow ek din mein live ho |
| Clinics pack | vendor ke pas nahi | `integration` | M | Appointment Booking (B5) | Appointment → reminder → follow-up drip end-to-end |
| E-commerce pack | vendor ke pas nahi | `integration` | M | Shopify/WooCommerce (B5) | COD confirmation + abandoned-cart recovery flow chale |

### Phase B7 — Apni Android Gateway App + USP-2 (SIM Fleet Intelligence)
Ye **app hai, plugin nahi** — lekin isi programme ka hissa hai
(master plan Phase 2). Spec: `04-NO-SOURCE/android-gateway-apk.md`
— server-side protocol poora core PHP mein hamare pas hai; ye is
programme ka sab se well-prepared replacement hai.

| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| Apni gateway app (clean-room Kotlin, ya SMS Gate fork + adapter) | vendor portal-built APK (interim live hai) | Android app + free Android Gateway plugin ke app slots | M | Protocol spec (tree); asal phone + SIM pilot | Tartib: pairing/auth → SMS send (FCM wake + pull) → receive → SIM sync/heartbeat → self-update → USSD module. Exit: hamare gateway phones par vendor APK ki zaroorat khatam |
| SIM Fleet Intelligence (USP-2) | vendor ke pas nahi | app + server-side plugin (`tool`/`integration`) | L | Apni app (device-side data hamara ho tabhi mumkin) | Warm-up schedule ek nayi SIM par apply ho; per-SIM daily cap par rotation ho; health score panel mein dikhe aur bemaar SIM rest ho |
| RCS module (app ke andar) | $59 | Android channel extension | L | Apni app; RCS spec `02-PAID-PLUGINS/rcs.md` | RCS-capable number par RCS message send/receive; fallback SMS kaam kare |

### Phase B8 — Apna WhatsApp QR Bridge + USP-4
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| WhatsApp QR server replacement (`04-NO-SOURCE/whatsapp-qr-server.md`) | closed Go binary | companion service (apna) + `channel` registration (patch register) | L | Evolution API/Baileys-type engine; core ka WA surface (tree spec) | Service Server kind `whatsapp` register → QR link → send/receive asal number par → restart par session wapas. Number-ban warning UI mein shamil |
| WhatsApp warm-up + ban-risk score (USP-4) | vendor ke pas nahi | `tool`/`integration` (bridge ke data par) | M | Apna bridge (session data hamara) | Naye number par warm-up ramp lage; risk score panel mein dikhe; khatarnak pattern par pehle warning aye |

Note (open item #2): vendor binary ke andar mojooda QR sessions ki
format/location UNVERIFIED hai — migration ka worst case tenants ka
QR se dobara link hai; is ki comms pehle se plan hogi, koi hack nahi.

### Phase B9 — Telephony / hardware / aakhri items
| Item | Replaces | Type | Size | Depends on | Acceptance |
|---|---|---|---|---|---|
| PBX / Call Centre module (Addenda 1–7) | Phone Bridge $100 (vendor form **nahi bane ga** — ye us ki asal replacement hai) | Zender-side module (`channel` family) + Asterisk (apna companion engine, AMI/ARI) | XL | Telephony contract ke payload schemas core controllers se parhna (open item #6 — `docs/api/telephony-v1.yaml` tree mein missing hai) | Dashboard mein extension/queue/IVR bane → DID par call aye → free agent ke browser par ring → recording + call log panel mein |
| Line side (PBX ke neeche, Addenda order) | — | hardware/service | — | **DID/SIP pehle** (Addendum 7 rule; Pakistan sourcing Addendum 8) → GSM gateway (GoIP/Yeastar TG) → USB dongle pilot (`chan_dongle`) → SIM7600 AT daemon → Bluetooth bridge (`chan_mobile`) → conference bridge (apni Android app, Addendum 6) | Har route par ek asal call end-to-end; SIM route par customer ko mobile number dikhe |
| GSM Modem daemon | $100 | `channel` (key `gsm_modem`) + daemon service | M (SMS/USSD/flash); voice PBX mein fold | SIM7600G-H hardware (owner purchase, §5) | Modem se SMS send/receive + USSD; flash SMS supported route par test ho |
| SMPP server replacement (`04-NO-SOURCE/smpp-server.md`) | closed Go binary | companion service (Jasmin + adapter) | M | Aggregator SMPP bind ki zaroorat — **pull-forward mumkin:** koi aggregator SMPP offer kare to ye B4/B5 ke sath aa sakta hai; interim Custom HTTP chal raha hai | Aggregator se bind → asal SMS + DLR; server health/move behaviour core ke sath sahi |
| Mobile App (apna Flutter client) | $150 (full-source plugin — **nahi khareeda**) | client app (plugin nahi); core mobile API par | M | Core mobile API mojood (`routes/mobile.php` ~117 routes); field payloads build time par parhne hain (open item #9). Phase start par $150-source wala option dobara dekhna hai (master plan) | Agent login → inbox → reply; push notification (Firebase) aye |
| Reseller++ (USP-6) | vendor ke pas nahi (Partner Network se gehra) | core-adjacent module — design review lazmi (§1 rule 1) | XL | **Gate:** single-brand SaaS paying tenants se proven ho | Partner apna domain + pricing laga kar sub-tenant chala sakay |

### NAHI bane ga (deliberate)
| Item | Faisla |
|---|---|
| Auto Update ($59) | **Not building** — manual upgrade discipline hi rahe gi (roadmap + `02-PAID-PLUGINS/auto-update.md`) |
| Phone Bridge (vendor form, $100) | **Not building** — PBX module (B9) is ki asal replacement hai |
| Legacy API Wrapper / Legacy Importer (free) | Build nahi — koi legacy integration nahi; Importer sirf architecture reference hai |

---

## 4. First build card — MCP plugin (Phase B1, shuru karne ke liye tayyar)

Spec source: `zender-rebuild-tree/02-PAID-PLUGINS/mcp.md` (vendor
price **$120**, no Extended discount — hum nahi khareed rahe).
Difficulty: Medium. Ye is liye pehla hai: core plumbing pehle se
mojood hai, plugin ek thin, safety-railed wrapper hai, aur ye
agent-driven operations ki bunyaad hai.

### 4.1 Scope — plugin kya de ga
Ek MCP (Model Context Protocol) server surface jis se AI apps
(Claude, ChatGPT, Claude Code, Cursor waghera) ek workspace ke
tools/resources istemal kar saken:
- **Read tools/resources:** conversations parhna, contacts parhna
  (aur jo read surface core API deta hai).
- **Send tools — default OFF:** "Allow sending messages" ka alag
  switch on ho tab hi send tools nazar ayen ge aur chalenge;
  warna hidden + refused.
- **Campaign tools — draft only:** campaign sirf draft bane ga;
  schedule/launch inputs plugin strip kar de ga — AI app apne tor
  par campaign kabhi start nahi kar sakta.
- **Per-connection cap:** 20 messages/hour per connection.
- **Channel-aware:** kisi channel ke tools sirf tab, jab us ka
  plugin live ho (registry ke `mcpTools` se aggregation).
- **Connections management:** owners/admins API Keys > MCP
  Connections mein har OAuth connection review/revoke kar saken;
  members apni connections Account Settings mein; unverified apps
  par saaf badge.

### 4.2 Pehle se core mein mojood (banana NAHI hai)
Audit (Lane 5 §§2, 4; Lane 2) ke mutabiq core mein pehle se hai:
- `laravel/mcp` package (1.0.1) — MCP protocol plumbing;
- `routes/mcp.php` — server endpoint ki route shell;
- `app/Services/Mcp/` — core MCP services;
- tables `mcp_oauth_grants` + `mcp_send_receipts`;
- Passport (OAuth) + API-key system, jiss mein key presets
  **Read Only / Read+Write / Read Write Send** pehle se hain;
- tenant REST API `/api/v1` (Bearer + Idempotency-Key) jis ke
  services ke upar tools bane ge;
- channel registry ka `mcpTools` declaration point.

**Live haalat (operational setup, 2026-11-16):** MCP plugin na
honay ki wajah se endpoints saaf 404 dete hain — yani plugin ke
baghair koi adha surface live nahi hai; plugin hi is ko on kare ga.

### 4.3 Plugin ko kya ADD karna hai
- `tool` contract par plugin: activation par MCP surface ko enable
  karna (endpoint registration/activation jo core shell ko live
  kare), "Enable MCP" config + readiness checks ki config screen.
- **Auth dono tareeqay:** (a) OAuth sign-in flow (Passport) jiss
  mein user Read Only ya Read and Write choose kare; (b) API keys
  — "AI App (MCP)" type ki key apni permission level ke sath.
- **Tool registry implementation:** core channels (Messenger/
  contacts waghera) ke read tools + send tools ki definitions,
  har tool ke peeche wahi tenant API service — koi alag data path
  nahi. Workspace permissions + API limits har request par lagu.
- **Send gate + limiter:** send switch (default off) ki
  enforcement, 20/hour per-connection limiter jo
  `mcp_send_receipts` mein likhe.
- **Draft-only campaign guard:** campaign tool se schedule/launch
  fields ka strip hona — code level par, UI par nahi.
- **Review/revoke UI:** API Keys page ki MCP Connections tab ke
  liye plugin ki taraf ka data/actions surface; unverified-app
  badging (Claude/ChatGPT ke known callbacks match hon to Verified
  badge ka logic).

### 4.4 Files / namespace plan
- Directory: `app/Plugins/<ToolType>/<Name>/` + `plugin.json` —
  type directory ka exact naam aur slug build ke pehle din
  installed **Legacy Importer** (`tool` type, live par mojood) ke
  structure se confirm hoga (namespace `App\Plugins\` locked hai;
  directory convention wahi se mile gi). **UNVERIFIED** jab tak
  confirm na ho.
- Plugin ki apni koi nayi table nahi (core ki `mcp_*` tables
  kaafi hain) — agar zaroorat pari to plugin migration, core
  migration NAHI.
- Core touch ki tawaqqu: **koi nahi** — agar endpoint activation
  ko core mein koi hook na mila to woh pehla design-review point
  hoga; majboori pari to patch register pehle, code baad mein (§1
  rule 3).

### 4.5 ⚠️ Plan-gating note (go-live se pehle lazmi)
- MCP ki dependency hai: **plan par "MCP + API Access" enabled
  ho** (spec file ki Dependencies).
- **Live haalat:** mojooda chaaron plans mein `mcp` feature flag
  **false** hai (aur `otp` bhi) — operational setup report
  2026-11-16 mein prove shuda. API khud bhi plan-gated hai (Free
  plan par API 403 deta hai).
- Matlab: plugin ban + install honay ke bawajood, jab tak admin
  plans mein `mcp` flag on na kare, kisi tenant ko MCP nahi mile
  ga. Ye **ghalti nahi, design hai** (§1 rule 7) — lekin build
  card isay flag karta hai taake "plugin lag gaya magar chala
  nahi" wala confusion na ho. Kis plan mein on karna hai (sirf
  Pro/Enterprise? sab mein?) — ye pricing faisla owner ka hai
  (§5), build us faislay ki muntazir NAHI hai.

### 4.6 Acceptance battery (MCP-specific, §2.3 ke `tool` harness ke upar)
1. Dev copy par install/activate → readiness checks saare green.
2. Ek asal MCP client (Claude ya Cursor) se OAuth connect —
   Read Only: read tools chalen, send tool **nazar bhi na aye**.
3. Read+Write key se connect: send switch OFF ho to send refused;
   ON ho to ek asal test message jaye aur plan ke message count
   mein gina jaye.
4. 21st message ek ghantay mein refused (20/hour cap) —
   `mcp_send_receipts` mein entries durust.
5. Campaign tool se campaign bane to **sirf draft** — schedule
   input bhej kar bhi launch na ho.
6. Workspace permission test: jis member ko contacts ka access
   nahi, us ki connection se contact read refused.
7. Revoke: admin MCP Connections se connection revoke kare →
   agla client request foran refused.
8. Channel-awareness: ek channel plugin deactivate ho to us ke
   tools list se gayab hon.
9. Production install: backup → PluginManager install → battery
   ke points 2–7 ek test workspace par dobara → rollback note
   likha jaye (plans mein `mcp` flag tab tak OFF rahe ga jab tak
   owner pricing faisla na kare, §4.5).

---

## 5. Owner-only steps — planning in ko done NAHI samajhti

Ye steps sirf owner kar sakta hai (accounts, paisa, qanooni
kaagaz). Har phase apni jagah ruk kar in ka intezar kare gi;
planning ne in mein se kisi ko bhi "ho gaya" nahi mana.

| Step | Kis phase ke liye | Haalat |
|---|---|---|
| Meta assets (Meta app + WABA + registered number) | Phase 1 remainder (WABA live) — is programme se pehle ka baqaya | Owner ke pas; Muse ko assets nahi chahiyein, sirf owner ka connect step |
| Phone pairing + pehla test SMS (gateway app install + QR/code pair) | Interim Android channel ki takmeel | Owner ka phone step baqi hai |
| Bank Transfer activation — asal bank details (bank name, account title, account number) | B2 ki bunyaad (core plugin pehle se installed) | Owner details de tab activate hoga |
| PayPal Business API credentials | Core PayPal plugin activation (optional gateway) | Owner step baqi |
| JazzCash / EasyPaisa merchant accounts + API credentials | B2 | Owner khole ga; credentials Secure Vault se — chat mein NAHI |
| Raast route ka bank/aggregator account | B2 | Route hi owner ke account par tay hoga (UNVERIFIED) |
| Stripe account (agar lena hai) | B2 | Owner step |
| Aggregator contract (masked SMS + HLR lookup ke liye) | B2 (mask workflow) + B4 (HLR) | Commercial/owner; PTA mask har tenant ke apne business naam par — documents tenant ke |
| PTA licensing check — PBX ko service ke tor par bechne se pehle | B9 | Legal check owner/counsel ke sath; apne istemal se alag cheez hai |
| Hardware khareed: SIM7600G-H / GSM gateway (Yeastar TG waghera) | B9 | Owner purchase |
| Custom licence (Titan Systems) ka final hona | Commercial launch gate (saare programme ke upar) | Application in progress; draft aye to Muse review kare ga — **is ke baghair charging NAHI** |
| APP_KEY ki copy Vaultwarden mein | Operations (purana baqaya) | Owner step baqi |
| Pricing faisla: `mcp` (aur `otp`) flag kin plans mein on ho | B1 go-live (§4.5) | Owner ka faisla; build is par nahi ruki |

---

## 6. Tartib ek nazar mein

```
B0 Tyariyan (skeleton, dev copy, patch register, harness)
 └─ B1 MCP plugin                    ← pehla build (§4 card tayyar)
     └─ B2 Payments: JazzCash/EasyPaisa/Raast + Stripe (+ baqi gateways)
     │    + USP-1: PTA mask workflow, Urdu pack
     ├─ B3 AI: Flow Builder → Knowledge Base → AI Agents
     ├─ B4 Channels: Website Chat, Web Push, Telegram (+ apna server),
     │    Email (+ apna server), Telegram Store
     │    + USP-3: HLR, cascade, spam score
     ├─ B5 Integrations: quick (Sheets, Extension, osTicket, Flarum,
     │    Appointment) → real (WordPress, WHMCS, Shopify, Perfex,
     │    Blesta, Odoo, Admin API) · GHL/monday = evidence first
     ├─ B6 Vertical packs (USP-5): Schools, Clinics, E-commerce
     ├─ B7 Apni Android app + USP-2 SIM Fleet (+ RCS module)
     ├─ B8 Apna WhatsApp bridge + USP-4 warm-up/ban-risk
     └─ B9 PBX/Asterisk + line routes, GSM modem daemon,
          SMPP server (pull-forward mumkin), Mobile App,
          USP-6 Reseller++ (sab se aakhir, gate ke sath)
NAHI bane ga: Auto Update · Phone Bridge (vendor form)
```

Har phase ka exit wohi hai jo §3 ki table mein us ki har line ka
acceptance hai — acceptance green honay se pehle koi item "done"
nahi kehlaye ga, aur production par kuch nahi jayega jab tak dev
copy par wahi battery pass na ho (§2.2).
