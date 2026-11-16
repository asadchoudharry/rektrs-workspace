# LANE 6 — NO-SOURCE COMPONENTS: BEHAVIOR MAP + CLEAN-ROOM REBUILD SPECS

Audit date: 2026-11-15. Method: read-only inventory of the purchased trees +
Lane 2/3/4/5 evidence. **No binary was executed, decompiled or
reverse-engineered** — behavior below is from vendor documentation, product
pages, the live demo, and the PHP source that talks to each component (file
paths cited). Anything not provable from those sources is marked
**UNVERIFIED**.

## Cross-cutting pattern (pehle ye samajhna zaroori hai)

Zender 5 ka har "band" hissa ek hi pattern par chalta hai (evidence:
LANE-5 §5.4, §8, §11; `app/Services/ServiceServers/`):

1. Har channel family ka apna **companion server program** hota hai jo admin
   mein **Service Server** ke tor par register hota hai (`service_servers`
   table; kinds: `whatsapp`, `smpp`, `telephony`, `telegram`, `email` —
   demo mein har kind ka 1 server "Healthy" dikha, LANE-4 §A).
2. Admin har server ke liye ek generated **`config.json`** download karta
   hai: `{ purchase_code, server: { host, port, service_token }, laravel:
   { url } }`. Binary **placeholder values ke sath start hi nahi hota** —
   `purchase_code` ki jagah asal plugin licence code aur `service_token` ki
   jagah asal token dalna lazmi hai (LANE-5 §8, §9-F2). Licence codes teen
   jagah gate karte hain:
   - WhatsApp: `REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE`
     (`app/Services/Messaging/Wa/WhatsappServerKind.php`)
   - SMPP: `REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE`
     (`app/Services/Messaging/Sms/SmppServerKind.php`)
   - Telephony: `REPLACE_ME_WITH_GSM_MODEMS_OR_PHONE_BRIDGE_LICENSE_CODE`
     (`app/Services/Telephony/TelephonyServerKind.php`)
   Codes vendor dashboard (dashboard.titansys.dev) se milte hain; binary in
   ko online validate karta hai ya offline — **UNVERIFIED** (LANE-5 §9-F2).
3. Har server ki **capacity** hoti hai aur core load-balancing/move karta
   hai (`service_server_moves`, `servers:sweep-moves`, per-kind assigners).
   Demo capacities: WA server **0/100 accounts**, Telephony **0/500
   devices**, SMPP **0/500 SMS providers**, Telegram **0/500 bots**, Email
   **0/500 mailboxes** (LANE-4 §A).
4. Zinda traffic aksar HTTP nahi, **Reverb (Pusher protocol) private
   channels** par chalti hai; HTTP sirf lifecycle/bootstrap/events ke liye
   (`routes/api.php` ke `v1/internal/*` blocks).
5. Saare band servers ek hi error-reporting switch parhte hain aur apni
   errors core ke zariye vendor ke Sentry endpoint par bhej sakte hain —
   default OFF (LANE-5 §9-F1).

**Rebuild ke liye ahem natija:** core PHP in servers se sirf inhi documented
surfaces se baat karta hai — Reverb channels, `v1/internal/*` HTTP APIs,
`config.json` bootstrap, aur `service_servers` registration. Jo replacement
yehi surface de de, core ko farq nahi padta ke peeche vendor ka binary hai
ya hamara apna program. Yehi hamari clean-room strategy hai.

---

## 1. WhatsApp QR Server (closed Go binary — WhatsApp plugin)

### (a) Ye kya hai / kya karta hai
Free WhatsApp plugin ke sath milne wala linked-device WhatsApp engine. Ek
server par 100 tak WhatsApp numbers (QR ya pairing-code se link) chala kar
un ke messages core ke shared inbox/campaigns/flows tak pohonchata hai.
Vendor ka apna binary hai — hamare pas is ka source nahi, lekin binary
hamare pas **hai** (free plugin ke sath mila).

### (b) Evidence-based behavior / interface
Binary inventory (sirf `ls`/`file` inspection, LANE-5 §8 +
`~/workspace/zender-branches/plugin-whatsapp/server/`):

| File | Size | Platform |
|---|---|---|
| `titansys-whatsapp-linux` | 52,281,470 B (~49.9 MiB) | ELF x86-64, static, stripped |
| `titansys-whatsapp-arm64` | 48,234,622 B (~46.0 MiB) | ELF aarch64, static, stripped |
| `titansys-whatsapp-macos` | 49,648,354 B (~47.3 MiB) | Mach-O arm64 |

- PHP docblock ise "a Go WA binary" / "the WhatsApp library session" kehta
  hai — whatsmeow-style linked-device engine (LANE-5 §8).
- **Bootstrap:** admin generated `config.json` deta hai:
  `{ purchase_code, server: { host, port (default **8899**),
  service_token }, laravel: { url } }`
  (`WhatsappServerKind.php:80`). Placeholder licence code/service token ho
  to binary start refuse karta hai.
- **Main traffic = Reverb:** binary private channel
  **`wa.account.{id}.commands`** subscribe karta hai; Laravel send/control
  commands wahan publish karta hai. Wapas events
  **`wa.account.{id}.events`** par aur **`POST
  /api/v1/internal/whatsapp/events`** se (`WaEventIngestService` ingest
  karta hai). Binary ki broadcast auth `Api\V1\Wa\BroadcastAuthController`
  se hoti hai (LANE-5 §8; `routes/channels.php`).
- **HTTP sirf lifecycle par** (`WaBinaryClient`, Bearer = server ka
  service token, dono taraf ek hi token):
  - `POST /api/v1/internal/whatsapp/accounts` — account assign/subscribe,
    sath mein `session_token`, login method `qr` ya pairing-code, proxy,
    throttle aur reject-call settings.
  - `DELETE /api/v1/internal/whatsapp/accounts/{id}` — account release.
- **Session storage binary ke andar hai:** linked-device session/keys WA
  server host par binary khud (re)create rakhta hai; Laravel ke pas sirf
  account metadata/state hai (`wa_accounts`, `wa_account_events`; purani
  `wa_instances` table mein server registry data: base_url, basic-auth,
  webhook_secret, version, health, capacity).
- Core ki taraf se health/balancing: `wa:health-check` (har minute),
  `wa:outbox-pump`, `wa:fail-stale-queued`, `wa:delivery-health`,
  `wa:connection-alerts`, `wa:resume-temp-bans`, warmer system
  (`wa:warmer-tick`, `wa_warmer_*` tables) — ye sab **core PHP** hai, binary
  sirf session + send/receive engine hai (LANE-5 §12).
- Webhook family bahir ki duniya ke liye: `wa.message.*` (LANE-2 Webhooks).
- Demo: WA Servers page — 1 server, Healthy, v5.0.4, **0/100 WhatsApp**
  (LANE-4 §A). Tenant Channels mein "WhatsApp QR" channel isi par banta
  hai; demo mein woh "Failed to sync — device disconnected" state mein tha.

### (c) Jo vendor ke baghair nahi jaan sakte — UNVERIFIED
- Binary ke andar session/keys ka on-disk format aur location.
- Licence code ki validation online hai ya offline; binary vendor ko
  phone-home karta hai ya nahi (error-reporting switch ke ilawa).
- Commands/events ke exact payload schemas jo sirf binary ki taraf se
  define hain (PHP side ke publish/ingest code se zyada tar surface wazeh
  hai, lekin binary-internal retries/reconnect behavior nahi).
- Ek binary ke andar 100 accounts ki asal resource limits (RAM/CPU).

### (d) Clean-room replacement spec
Hamara plan (final plan Phase 3): apna WhatsApp bridge **Evolution API /
Baileys-type open-source engine** par. Replacement ko core ke samne ye
surface deni hai — is se zyada core ko kuch nahi chahiye:

1. **Service Server registration:** kind `whatsapp` ke tor par register ho;
   `config.json` bootstrap accept kare (host/port/service_token/laravel
   url) — licence-code gate hamari apni build mein nahi hoga.
2. **Reverb client:** har account ke liye `wa.account.{id}.commands`
   subscribe kare (broadcast auth endpoint se authenticate karke) aur
   commands execute kare: send text/media, group actions, polls,
   reactions waghera — jo command set core publish karta hai
   (`WaBinaryClient` + command publishers core mein parhe ja sakte hain).
3. **Event return:** `wa.account.{id}.events` par live events +
   `POST /api/v1/internal/whatsapp/events` par ingest-able events
   (message received/sent status, connection state, QR/pairing progress) —
   Bearer service token ke sath.
4. **Lifecycle HTTP:** `POST/DELETE /api/v1/internal/whatsapp/accounts`
   wale assign/release flow ka client bane: `session_token`, login method
   `qr` | pairing-code, proxy, throttle, reject-call settings accept kare.
5. **Session persistence apni taraf:** linked-device session apne store
   mein rakhe (Baileys/Evolution apna auth state rakhta hai); server
   restart par sessions resume hon.
6. **Capacity/health:** 100 accounts/server ka core-side hisaab hai;
   replacement ko health state core ko report karni hai taake
   `wa:health-check` aur balancing kaam kare.

Open-source base: **Evolution API** (Baileys/whatsmeow-family ka tayyar
server) sab se qareeb hai — lekin note: core Reverb channels par baat karta
hai, REST par nahi; is liye Evolution ke upar ek **chhota adapter service**
lazmi hoga jo Reverb commands ko Evolution API calls mein badle aur events
wapas bheje. Adapter hamara apna code hoga (koi vendor code nahi).

### (e) Difficulty / risk
**Medium-Hard.** Interface surface chhoti aur PHP side se poori parhi ja
sakti hai; asal mushkil linked-device protocol ki reliability hai (session
drops, temp bans — core mein `wa:resume-temp-bans` aur warmer ka wajood
khud is risk ka saboot hai). Standing warning barqarar: QR method
unofficial hai — number ban/Meta terms ka risk; WABA hamesha pehla rasta.

---

## 2. SMPP Server (closed Go binary — SMPP plugin)

### (a) Ye kya hai / kya karta hai
Free SMPP plugin ka protocol engine. SMPP woh protocol hai jis se
aggregators/telcos ke sath bind bana kar bare paimane par SMS bheje aur
delivery reports (DLR) liye jate hain. Core mein SMPP ek aam "SMS provider"
ki tarah dikhta hai, lekin asal SMPP wire protocol ye binary chalata hai.

### (b) Evidence-based behavior / interface
Binary inventory (`~/workspace/zender-branches/plugin-smpp/server/`,
LANE-5 §11):

| File | Size | Platform |
|---|---|---|
| `titansys-smpp-linux` | 15,016,062 B (~14.3 MiB) | ELF x86-64, static, stripped |
| `titansys-smpp-arm64` | 13,893,758 B (~13.3 MiB) | ELF aarch64, static, stripped |
| `titansys-smpp-macos` | 14,275,602 B (~13.6 MiB) | Mach-O arm64 |

- **Registration:** plugin class sirf ek driver register karti hai —
  `smsDrivers(): ['smpp' => SmppDriver::class]` — aur `SmppDriver` **core
  mein** hai (`app/Services/Messaging/Sms/Smpp/`). Yani plugin = manifest +
  driver registration; protocol engine = binary; saari policy = core PHP.
- **Core PHP side (poora hamare pas hai):** `SmppDriver` (core
  `SmsProviderDriver` contract: unicode, 255 parts tak, alphanumeric
  sender, delivery reports, inbound), `SmppCommands`/`SmppCommandChannel`
  (binary ko commands **Reverb** par), `SmppServerAssigner` (gateways ko
  servers par taqseem), `SmppBindStateHandler`, `SmppInboundHandler`,
  `SmppMessageStatusHandler` (DLRs), `SmppConnectionTests`,
  `SmppConfigSchema` (per-gateway host/port/system_id/password/TLS/bind
  options — credentials ke asal values yahan reproduce nahi kiye gaye).
- **Binary↔Laravel API** (`routes/api.php`, prefix `api/v1/internal/smpp`,
  middleware `channel:smpp` + `smpp.server`): `POST events`,
  `GET bootstrap`, `GET gateways`, `GET gateways/{gateway}`,
  `GET gateways/{gateway}/pending` (outbound pull), `GET
  connection-tests/{id}`, broadcasting auth, error-reporting relay
  (`POST error-reports`, `GET error-reporting`).
- **Licence gate:** config mein `REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE`
  (`SmppServerKind.php:23`) — WA wali hi pattern.
- **Admin balancing settings** (docs/demo se, LANE-2 Admin guide): down
  server se gateways move karna — After **10 min** (range 5–120),
  Rebalance on, **Busy Above 90%** (50–100), **Moves Per Run 5** (1–50),
  auto-return nahi. Scheduler: `smpp:sweep` + `smpp:servers-health` har
  minute, `smpp:balance` har 5 min (LANE-5 §12).
- Demo: SMPP Servers — 1 server, Healthy, v5.0.4, **0/500 SMS Providers**
  (LANE-4 §A). Status Page ke seeded incidents sab "SMPP down" thay —
  health monitoring isi server family par chalta hai.
- Docs mein SMPP protocol page **nahi** hai (host/port/bind/DLR ki detail
  plugin ke ZIP wali docs mein hai — LANE-2 finding #3).

### (c) UNVERIFIED
- Binary ke andar bind management (transceiver/receiver sessions), throttling
  aur reconnection ki exact policies.
- Licence validation ka mechanism (online/offline).
- Binary ki asal throughput (messages/sec) — 500 providers/server capacity
  core-side figure hai, wire performance nahi.

### (d) Clean-room replacement spec
Replacement ko core ke samne ye dena hai:

1. Service Server kind `smpp` registration + `config.json`-style bootstrap
   (licence gate apni build mein nahi).
2. `GET /api/v1/internal/smpp/bootstrap` + `gateways` +
   `gateways/{id}/pending` ka client bane: apne assigned gateways ki
   config (host/port/system_id/TLS/bind) le, pending outbound pull kare.
3. Har gateway ke liye SMPP bind(s) barqarar rakhe, `submit_sm` bheje,
   `deliver_sm` (DLR + inbound MO) receive kare.
4. Results wapas: `POST /api/v1/internal/smpp/events` (status/DLR/inbound)
   + Reverb command channel (`SmppCommandChannel`) par core ke commands
   sune.
5. `connection-tests/{id}` ke test results aur bind-state core ko report
   kare taake `SmppBindStateHandler`/balancing kaam kare.

Open-source base: **Jasmin SMS Gateway** (mature open-source SMPP server,
SMPP client + server dono) sab se mazboot candidate hai; us ke upar ek
adapter jo Zender ke internal API/Reverb surface se baat kare. Halka
alternative: koi maintained SMPP library (Go `fiorix/go-smpp` ya Node
`smpp`) par apna chhota daemon — lekin Jasmin mein routing/DLR/throughput
pehle se proven hai.

### (e) Difficulty / risk
**Medium.** SMPP ek khula, documented protocol hai (vendor ki koi khaas
jadugari nahi) — mushkil sirf adapter ki durustgi aur DLR matching hai.
Masked-SMS aggregator (SendPK waghera) ko jodne ka ek rasta Custom HTTP
driver bhi hai (LANE-2), is liye SMPP replacement Phase 4/5 ki cheez hai,
launch blocker nahi.

---

## 3. Telephony Server (Phone Bridge + GSM Modems paid plugins — hum ne NAHI khareede)

### (a) Ye kya hai / kya karta hai
Ek hi band **Go telephony service** do paid plugins ko power karti hai:
**Phone Bridge** ($100 — apna mobile phone ESP32 Bridge Adapter ya Windows
App ke zariye PBX line banta hai) aur **GSM Modems** ($100 — computer se
lage GSM modems lines bante hain). Agents browser ke Messenger mein calls
uthate/bhejte hain; voice flows (IVR menus, prompts, record, transfer)
server par chalte hain. **In plugins ka source bhi nahi aur binaries bhi
hamare pas nahi** — ye section Lane 3/4 ke documented behavior + core PHP
mein maujood is service ke contract se bani hai. Core PHP mein is ki poori
surface maujood hai kyun ke flows, minutes, pairings aur call logs core
manage karta hai (`app/Services/Telephony/` — 50+ files, LANE-5 appendix).

### (b) Evidence-based behavior / interface
- **Service contract core mein likha hai:** `routes/api.php` comment —
  "Telephony service API (Phone Bridge): the **Go service** calls these
  with its service_servers token (kind telephony). Contract:
  docs/api/telephony-v1.yaml." Endpoints (prefix `v1/internal/telephony`,
  middleware `channel:phone_bridge,gsm_modem` + `telephony.server`):
  - `GET bootstrap` — service apni config/assignments leti hai
  - `POST pair` — device pairing claim
  - `POST events` — call/device events ingest
  - `GET connections/{connection_id}` — ek line/device ki detail
  - `GET ussd/{ussd_id}` — modem line par USSD chalane ka kaam
  - `GET outbound/{message_id}` — outbound SMS ka content (phone/modem se
    bhejne ke liye)
  - `GET flows/{flow_id}/facts` + `GET flows/{flow_id}/compiled` — **voice
    flows core compile karke deta hai, service unhen locally execute
    karti hai** (IVR isi liye server par chalta hai)
  - `GET prompts/{asset_id}` — voice prompt audio download
  - `POST media` — recordings/media upload wapas core ko
  - `POST broadcasting/auth` — Reverb auth (commands
    `TelephonyCommandPublisher` / `PusherTelephonyTransport` se jate hain)
  - `PUT public-url` — service apna public URL report karti hai
  - `GET error-reporting` / `POST error-reports` — F1 wala relay
- **Config/bootstrap:** `TelephonyServerKind::configJson()` —
  `{ purchase_code (licence placeholder upar §Cross-cutting), server:
  { public_host, public_port, service_token }, laravel: { url } }`.
  Public host/port lazmi (1–65535); demo mein Telephony Server ka host
  `:443` masked dikha aur **"Quick Tunnel"** option Off tha — yani service
  ke liye public reachability ka ek tunnel mode bhi maujood hai (LANE-4 §A).
- **Device host lookup:** Bridge Adapters aur Windows Apps site se
  telephony service ka current host poochte hain (`POST/GET
  v1/telephony/device/host`, signed + public variants; code comment:
  "PROTOCOL.md section 7") — tunnel restart ke baad devices naya host
  dhoond lete hain. Device apps ke updates bhi yahin se:
  `v1/telephony/device/update` + `/update/download`.
- **Pairing:** devices 8-character code se pair hote hain (LANE-3 GSM
  Modems); core mein `phone_bridge_pairings`, `IssuedPairingCode`,
  `PairingClaim` is ka saboot hain.
- **Balancing:** `TelephonyServerAssigner` + `TelephonyBalancingSettings`;
  scheduler `telephony:balance`, `telephony:servers-health`; devices
  least-loaded server par jate hain, disabled server se move ho jate hain
  (LANE-3). Demo capacity: **0/500 Devices** per telephony server.
- **Call surface (webhooks, LANE-2):** `call.started`, `call.answered`,
  `call.ended`, `voicemail.received`, `recording.ready`,
  `transcript.ready`, `media_stream.requested`; alag families
  `phone_bridge.message.*` aur `gsm_modem.message.*`. Call data core mein:
  `calls`, `call_events`, `call_transcripts`, `call_agent_rings`,
  `call_media_streams`, `call_uploads` tables (LANE-5 §4). Flow nodes:
  **Phone Bridge** aur **GSM Modem** send nodes core flow engine mein
  maujood hain (LANE-2 Flows). OTP delivery channel ke tor par bhi
  "Phone Bridge" aur "Voice Call" listed hain (LANE-2 OTP).
- **Scheduler (core):** `phone-bridge:sms-outbox` (har minute — phone se
  SMS bhejne ki queue), `phone-bridge:device-webhooks`,
  `phone-bridge:publish-minutes` (monthly minutes accounting);
  `GsmModemMinutes`/`PhoneBridgeMinutes` core mein hain — minute billing
  core karta hai, service sirf calls chalati hai.
- **Bridge Adapter (ESP32):** recommended board **Waveshare
  ESP32-WROVER-E-N16R8** (16 MB flash, 8 MB PSRAM); sirf original ESP32
  mein Bluetooth Classic hai jo calls ke liye chahiye — S2/S3/C3 kaam nahi
  karte (LANE-3). Adapter phone se Bluetooth par jurta hai, audio relay
  karta hai. **Firmware flashing browser se hoti hai:** frontend mein
  `esptool-js` aur core mein `app/Services/Telephony/BridgeFlashing.php` —
  yani adapter firmware bhi per-site build ke tor par dashboard se flash/
  distribute hoti hai. iPhone par sirf calls; texts ke liye Android lazmi.
  Ek agent ek waqt mein ek call.
- **Windows App:** Windows 11 computer + Bluetooth se wohi phone-bridge
  kaam; device apps buyer dashboard ke "Builds" se branded bante hain;
  updates licence entitlement se ate hain (LANE-3).
- **Modem App:** per-site branded **daemon** (Android APK nahi) — Windows /
  Linux x64 / Linux ARM64 builds buyer dashboard se; modems wale computer
  par chalti hai, 8-char code se pair hoti hai, telephony server se jurti
  hai. **Supported modem profiles (LANE-3):**
  - **SIM7600G-H** — LTE texts, **flash SMS**, USSD, call detection;
    voice-capable lines par calling.
  - **SIM800C** — SMS only, sirf 2G networks.
  - A7670 aur EG25-G abhi supported NAHI.
  USSD ko 2G/3G fallback ya carrier USSD-over-IMS chahiye ho sakta hai.
  Har line apni "readiness" dikhati hai; voice ke liye plan par "GSM Modem
  Calling" switch chahiye.
- **Source halat (LANE-3, vendor ke apne alfaaz ka khulasa):** "The
  telephony server programs, the Windows App and the adapter firmware are
  delivered prebuilt" — koi source nahi. Modem App ka source bhi explicitly
  nahi milta.

### (c) UNVERIFIED
- Telephony Go service ke andar ka media stack (SIP/RTP/WebRTC codecs,
  jitter handling) — core contract se bahir ki cheez hai.
- ESP32 firmware ka Bluetooth profile implementation (HFP/HSP details) aur
  Windows App ka internal Bluetooth stack.
- Modem App ke AT-command sequences (SIM7600/SIM800 ke liye) — daemon band
  hai; profiles sirf documented behavior se maloom hain.
- Quick Tunnel ka mechanism (vendor relay hai ya standard tunnel).
- `docs/api/telephony-v1.yaml` contract file is tree mein maujood nahi
  mili (routes comment reference karta hai; sirf `resources/contracts/
  public-v1.yaml` mili) — exact payload schemas ke liye core controllers
  hi source hain.

### (d) Clean-room replacement spec — hamara Asterisk PBX module
Owner ka faisla (plan Addenda 1–7) pehle se hai: **hum ye plugins nahi
banayenge vendor ki nakal mein — hum apna PBX module banayenge** jo Zender
ke andar dashboard/IVR/queues/agents/recordings de aur neeche open-source
**Asterisk** voice engine AMI/ARI se control ho; tenant ko Asterisk kabhi
nazar nahi ayega. Yehi pattern vendor khud istemal karta hai (PHP UI +
band server peeche) — farq ye ke hamara engine khula hoga.

Replacement ko do hisso mein core se jurna hai:

**Hissa 1 — Zender ke telephony contract ki jagah apna module:**
Asal mein hum vendor ke Go service ko replace nahi kar rahe, hum us ki
*jagah* apna channel/module laga rahe hain jo core ki in surfaces ko
istemaal kare:
- `calls`/`call_events`/`call_transcripts` data model aur webhook family
  (`call.started/answered/ended`, `recording.ready`, `transcript.ready`)
  — apna module yehi events paida kare taake Messenger Call Logs, flows
  aur billing (minutes) wese hi chalein jese core expect karta hai.
- Voice flow execution: core `flows/{id}/compiled` se compiled flow leta
  hai — hamara engine (Asterisk ARI application) in compiled steps ko
  IVR menu/prompt/record/transfer actions mein chalaye. Prompt assets
  `prompts/{asset_id}` se milte hain (tenant "Call Prompts" bana sakta
  hai — LANE-4 §B).
- Agent side: browser mein call bar (Mute/Hold/keypad/Transfer/Hang Up)
  vendor Messenger mein hai; hamare module mein agent leg WebRTC
  (browser softphone → Asterisk) se juregi — ek agent = ek call ki hadd
  Asterisk queue se enforce hogi.

**Hissa 2 — Line side (SIM/phone ko system se jorna), Addenda ke routes:**
- **DID/SIP trunk pehle (Addendum 7 ka rule):** customer seedha DID par
  call kare → SIP trunk → Asterisk → queue → free agent ke dashboard.
  Koi phone/modem hi nahi chahiye. Pakistan DID ki qeematein Addendum 8
  mein darj hain (PTCL quote-based; online ~$55–75/month).
- **GSM gateway device (Addendum 2):** GoIP/Yeastar TG (4G LTE + VoLTE
  models) LAN se Asterisk ko SIP trunk ke tor par — 1 SIM = 1 concurrent
  call; Yeastar TG SMS bhi de sakta hai.
- **USB dongle pilot (Addendum 3):** Asterisk **chan_dongle** Huawei 3G
  dongles (E1550/E173/E175X) ko AT commands se chalata hai — voice + SMS
  + USSD; pilot ke liye, production ke liye gateway device. Software dono
  par ek hi.
- **SIM7600 board (Addendum 4, pasandeeda pilot):** Waveshare SIM7600 4G
  HAT/USB — AT-command control hamare apne daemon se (vendor ke Modem App
  ki jagah apna chhota AT daemon jo Asterisk/SIP se jure). Dilchasp
  ittefaq: vendor ka supported profile bhi SIM7600G-H hi hai (LANE-3) —
  hardware pasand dono ki ek hai, software hamara apna hoga.
- **Bluetooth phone bridge (Addendum 4/5):** Asterisk **chan_mobile** phone
  ko Bluetooth HFP se GSM line banata hai — vendor ke Phone Bridge ka
  khula jawab; pilot/lab grade (1 phone = 1 call, ~10m range).
- **Conference bridge (Addendum 6, owner ki asal khwahish):** hamari apni
  Android app (Section 6) default dialer ban kar incoming call auto-answer
  kare, server ke DID par doosri call laga kar merge kare — agent
  dashboard par baat kare. Carrier conference support par munhasir; pilot
  mein asal phone+SIM par proof lazmi. Asaan variant: carrier call
  forwarding seedha DID par.

**PTA note (Addendum 1):** PBX ko doosron ko service ke tor par bechne se
pehle PTA licensing check lazmi hai; apna istemal is se alag hai.

### (e) Difficulty / risk
**Hard — lekin ye hamari marzi ka hard hai.** Vendor ki telephony band
hai aur hum usay replicate nahi kar rahe; Asterisk route proven open-source
hai, lekin voice quality, echo, NAT/WebRTC aur carrier quirks asal kaam
hain. Phase 5 ki cheez hai. Sab se bara risk scope ka hai: PBX module
(queues/IVR/recordings/billing) ek poora product hai — Addendum 1 ki
tanbeeh ke sath ke pehle messaging business chale, phir ye.

---

## 4. Telegram Server (closed binary — paid Telegram plugin, $59, hum ne NAHI khareeda)

### (a) Ye kya hai / kya karta hai
Telegram channel ka engine: bots (BotFather token) **aur** asal user
accounts (phone number + code/QR + 2-step verification) dono ko Zender se
jorta hai — private chats Messenger mein, broadcast channels campaigns ke
liye, flow nodes (Telegram Message / First Contact / Button Tap triggers,
Send Telegram action).

### (b) Evidence-based behavior / interface
- **Server model (LANE-3):** pehle Admin mein **Telegram Server register**
  hota hai; download se matching **binary Linux VPS par install** hoti hai;
  phir apne Telegram application ke **api_id + api_hash** save karke Test
  Configuration. Demo: Telegram Servers — 1 server, Healthy, **v1.0.0**,
  **0/500 Telegram Bots** (LANE-4 §A).
- BotFather token sirf bot connection ke liye hai — application credentials
  (api_id/api_hash) ki jagah nahi leta (LANE-3). Account login code ya QR
  se, 2-step verification ke sath; account setup bot bhi bana sakta hai.
- Live updates ke liye Reverb ya Pusher lazmi. Bot sends par delivery/read
  receipts nahi milte — sirf "Sent"; bot sirf un logon ko pohonch sakta hai
  jinhon ne usay start kiya ho (LANE-3). Single-use opt-in links (1 din
  expiry) isi liye hain.
- Core ki taraf: channel slug `telegram` core registry mein registered hai
  (LANE-5 §5.4) aur core routes mein telegram internal API ka **fallback
  503 handler** hai (`v1/internal/telegram/*` → `channel_unavailable` jab
  plugin live na ho) — yani asal internal routes plugin ke sath ate hain.
  Public API mein `v1/telegram` sub-API bhi core routes mein hai (LANE-5
  §6). Plan allowances bots aur accounts ke liye alag alag.
- Telegram Store plugin isi par dependent hai (LANE-3).

### (c) UNVERIFIED
- Binary kis MTProto library par bana hai (TDLib/custom) — product page
  aur core se pata nahi chalta.
- Account sessions kahan/kaise store hoti hain (server par, kis format
  mein); ek server par 500 bots/accounts ki asal mixing ratio.
- Flood-limit/rate-limit handling ki policies.

### (d) Clean-room replacement spec
1. **Do mode lazmi:** (i) **Bot mode** — Bot API (BotFather token) —
   ye akele bots ke liye kafi hai aur kisi binary ki zaroorat nahi; (ii)
   **Account mode** — MTProto client (user account login: phone + code,
   QR, 2FA password) broadcast channels aur account-level features ke
   liye.
2. Open-source base: **Telethon** (Python, MTProto) ya **TDLib** (official
   Telegram library) par apni service; Bot mode ke liye seedha Bot API
   client. Service ko core ke samne wohi surface deni hai jo core
   expect karta hai: Service Server kind `telegram` registration,
   api_id/api_hash config, channel connection lifecycle (connect/
   disconnect/health), incoming private-chat messages → core inbox,
   outgoing sends (campaigns/flows/API se), channel (broadcast) listing
   aur post/edit/delete, opt-in link flow.
3. Session storage apni encrypted store mein; har account ki session
   alag; flood-wait ko queue mein badalna (block nahi karna).

### (e) Difficulty / risk
**Medium.** Bot-only version **Easy** hai (Bot API khula hai). Account
mode Medium-Hard: MTProto session management aur Telegram ke flood limits
asal kaam hain, aur user-account automation Telegram ki terms ke andar
reh kar karna hai. Priority kam hai — bots se 80% kaam ho jata hai.

---

## 5. Email Server (closed binary — paid Email plugin, $59, hum ne NAHI khareeda)

### (a) Ye kya hai / kya karta hai
Email channel ka sync/send engine: mailboxes (Gmail/Microsoft sign-in,
Gmail App Password, ya koi bhi IMAP/SMTP mailbox) ko Messenger se jorta
hai — threaded email inbox mein, email campaigns (speed/daily limit/health
ramp ke sath), mailbox **Warmer** (naye mailbox ki sending reputation
banaana), suppressed emails/bounce reports, flows aur API se email.

### (b) Evidence-based behavior / interface
- **Bundled email service Linux VPS par install hoti hai — x86_64 aur ARM
  binaries download mein shamil** (LANE-3). Admin mein **Email Servers**
  register hote hain; service ko Zender URL aur mailbox providers dono tak
  pohonch chahiye. Demo: Email Servers — 1, Healthy, v1.0.0, **0/500
  Mailboxes** (LANE-4 §A).
- Live updates ke liye Reverb/Pusher lazmi (LANE-3).
- Core ki taraf: channel slug `email` registered hai; core routes mein
  `v1/internal/email/*` ka fallback 503 handler hai (plugin live na ho to
  `channel_unavailable`). Webhook family: `email.message.*` (received/
  sent/delivered/read/failed — LANE-2). API se send idempotent retries ke
  sath.
- **Ye Zender ke system email se alag hai:** password resets/invoices
  core ke apne SMTP se jate hain (LANE-2 Email settings); plugin sirf
  tenant mailboxes ke liye hai (LANE-3).

### (c) UNVERIFIED
- Sync ka tareeqa (IMAP IDLE vs polling interval), thread-matching ki
  exact logic, Warmer ka algorithm (kis ko, kitni email, kis pattern par).
- Binary ka internal storage (mail bodies server par cache hote hain ya
  sirf core DB mein).

### (d) Clean-room replacement spec
Email sab se khula protocol hai — replacement mein koi band cheez nahi:
1. Apni service **standard IMAP/SMTP libraries** par: IMAP sync (IDLE
   jahan mumkin, warna polling), SMTP send per-mailbox credentials/OAuth
   (Gmail/Microsoft OAuth core Socialite pattern se milta julta hai).
2. Core ko wohi surface: Service Server kind `email` registration,
   mailbox connect/health, incoming mail → threaded conversation
   (subject/To/Cc/attachments ke sath), outgoing send + status events
   (`email.message.*`), campaign pacing (speed, rolling daily limit,
   health ramp) queue ki taraf se.
3. Warmer: apna simple warm-up scheduler (rozana barhti hui volume,
   seed addresses par engage) — algorithm hamara apna hoga, vendor ka
   nahi dekha ja sakta.
4. Bounce/suppression: SMTP reply codes + bounce mailbox parsing se
   Suppressed Emails list core ko feed karna.

### (e) Difficulty / risk
**Easy-Medium — saari list mein sab se asaan server replacement.** IMAP/
SMTP mature aur documented hai; mushkil sirf Gmail/Microsoft OAuth ki
app-verification formalities aur deliverability (SPF/DKIM/DMARC tenant ki
apni zimmedari) hai.

---

## 6. Android Gateway APK + Companion Apps (app builder se bane hue — source nahi)

### (a) Ye kya hai / kya karta hai
Gateway phone par chalne wali Android app jo SIM ko Zender ki SMS line
banati hai. App ka source hamare pas nahi — har site ke liye vendor ke
**app builder** se branded build banti hai (name, icon, logo, colours,
package name, site address — LANE-5 study/LANE-3 cross-cutting). Plugin
sirf 4 downloadable **app slots** declare karta hai (LANE-5 §5.7-1):
`android_gateway` (asal gateway app), `android_rcs` (RCS Companion),
`android_receiver` (Receiver app), `android_ussd` (USSD Companion) — har
slot ke version-compat patterns hain. Gateway app ka package id core code
mein `dev.titansys.smsgateway` ke tor par maujood hai (LANE-5 §9).

**Sab se ahem baat: server-side protocol poora CORE PHP mein hai aur
hamare pas hai** (LANE-5 §7) — is liye apni app banana is list ki sab se
zyada tayyar-shuda cheez hai.

### (b) Evidence-based behavior / interface (server side se — LANE-5 §7)
Contract in-repo documented hai: `docs/api/android-v1.yaml` (routes
comments reference karte hain). Base: `api/v1/internal/android`,
middleware `channel:android`.

- **Pairing:** `POST auth/pair` — UI mein bana pairing code; flow Reverb
  channel `user.{id}.device-pairings.{pairingId}` par broadcast hota hai;
  app version gate: `RequireCompatibleGatewayApp` (≥
  `GatewayAppCompat::MIN_APP_VERSION`). Pairing codes short-lived
  (`device_pairings`, rozana cleanup).
- **Auth:** `Authorization: Bearer <token>` + `X-Device-Id` header. Server
  token ka sirf **SHA-256 hash** `devices.hash` mein rakhta hai; bearer ko
  us device se match hona chahiye jis ki `android_id` header ke barabar
  ho. Alag se `POST auth/login` + `auth/login/two-factor` branded builds
  ke email sign-in ke liye.
- **Device sync:** `GET device` (profile), `PUT device/fcm-token`,
  `PUT device/sims` (SIM sync), `PUT device/pause`,
  `POST device/diagnostics`.
- **Send flow (push-wake + pull):** outbound rows pending queue mein;
  server **FCM data push** bhejta hai (`action=message_request`, campaigns
  ke liye `campaign_id` bhi) `devices.firebase_token` par — Firebase
  project **operator ka apna** hota hai (plugin config mein
  `firebase_credentials` service-account JSON, encrypted store). Phone
  `GET messages/pending` se pull karta hai, SIM se bhejta hai,
  `PATCH messages` / `PATCH messages/{id}` se status wapas. Inbound:
  `POST messages/inbound`.
- **Polling fallback:** pending endpoint channel-gating se exempt hai
  ("Control-only polling keeps phones paired") — FCM na chale to app poll
  karke bhi zinda rehti hai. Server har minute offline devices ka pending
  kaam move karta hai (`sms:move-pending-from-offline`), ghante par
  missing delivery reports detect karta hai.
- **USSD relay:** `GET ussd/pending`, `POST ussd/{id}/start`,
  `POST ussd/{id}/menu`, `PATCH ussd/{id}` — server queue-and-relay model:
  request `ussd` row banti hai, phone (USSD Companion) FCM + Reverb
  (`user.{id}.ussd.{pullId}`, ek `.masked` variant bhi) se jagta hai,
  carrier session step-by-step chalata hai, result wapas. Scheduled USSD
  (balance checks) `ussd:run-schedules` har minute.
- **RCS:** `GET rcs/selectors` capability data; RCS Companion Google
  Messages ke sath kaam karti hai (Section neeche (d) mein); device par
  `rcs_enabled`, `rcs_sms_fallback`, `rcs_failure_streak`, `rcs_report`
  core track karta hai. RCS plugin (paid extra, $59) ki checklist:
  Accessibility + Notification Access, battery limits remove, Google
  Messages default SMS app, phone unlocked/screen lock OFF (LANE-3).
- **App updates:** `GET app/update` (latest version info), `GET
  app/download` (signed URL); companions ke downloads bhi signed:
  `ussd-companion/app`, `receiver/app`, `rcs/app`. Server push se bhi
  update jagaya jata hai (`SendDeviceUpdatePush`, `android:app-updates`
  har 15 min).
- **Device jo data server ko deta hai** (`devices` table, LANE-5 §7):
  android_id, model, manufacturer, android_version, sdk, app_version,
  app_package, app_signer, firebase_token, **battery_level, is_charging,
  signal_strength**, is_online/last_seen, SIM list (slot, number, carrier
  — `sims` table + route rules + caps), receive_sms_enabled,
  battery_optimization_exempt, background_restricted, standby_bucket,
  installed packages list, diagnostics (`device_diagnostics`,
  `device_heartbeats`).
- **Plugin config jo app ke behavior ko control karti hai:**
  `carrier_pause_hours` (default 6), `rcs_pacing_seconds` (default 6).
- Demo/Docs ishare: Android channel warnings — paused/offline/no SIM/low
  battery/update (LANE-2 Channels Hub); tenant OTP settings mein "Retry
  on Another SIM" (LANE-4 §B).

### (c) UNVERIFIED
- App ke andar ki UI/UX aur exact permission set (screenshots plugin ki
  Documentation mein hain — `plugin-android-gateway/Documentation/
  screenshots/companions-2026-10-16.png`, `app-bundle-2026-10-16.png` —
  lekin andar ka code nahi).
- **MMS support:** Partner Network rates mein MMS ka zikr hai lekin
  LANE-2 note kehta hai "abhi MMS nahi" — gateway app se MMS send/receive
  **UNVERIFIED / muhtamalan nahi hai**.
- App FCM ke ilawa koi vendor relay istemal karti hai ya nahi (protocol
  se lagta hai nahi — FCM operator ke apne Firebase se jata hai).
- Receiver app ka exact farq gateway app se (slot alag hai; kaam ka
  taqseem documentation se poora wazeh nahi).

### (d) Clean-room Android app spec (hamari apni app — final plan Phase 2)
Server protocol hamare pas hai, is liye spec seedha usi contract par hai.
**Ek app, chaar salahiyatein** (vendor ke 4 slots ki jagah hum ek hi app
mein modules rakh sakte hain — slots core sirf download/compat ke liye
declare karta hai):

1. **Pairing & auth:** pairing-code flow (QR scan bhi — code wahi hai),
   token ko Android Keystore mein mehfooz rakhna, har request par
   `Bearer` + `X-Device-Id`; token hash server par hai is liye app ko
   rotation/re-pair flow bhi chahiye.
2. **SMS send:** FCM data push (`action=message_request`) par jagna →
   `messages/pending` pull → `SmsManager` se bhejna (multi-SIM mein sahi
   subscription id chunna server ke diye hue SIM assignment se) → har
   message ka status `PATCH` se wapas (sent/delivered/failed + error
   reason). FCM fail ho to exponential-backoff polling (endpoint exempt
   hai). Random send delay (server `random_send_min/max_delay` deta hai)
   aur carrier pause (`carrier_pause_hours`) ki pabandi.
3. **SMS receive:** incoming SMS listener → `POST messages/inbound`
   (offline ho to local queue, net ate hi flush).
4. **SIM sync & status heartbeat:** `PUT device/sims` (slots, numbers,
   carriers), periodic heartbeat jisme battery_level, is_charging,
   signal_strength, app_version, battery-optimization/background
   restriction states hon — server ke offline alerts aur warnings
   (`device_offline_alerts`, Channels Hub warnings) inhi par chalte hain.
   `POST device/diagnostics` par demand par diagnostics.
5. **USSD module (companion ki jagah in-app):** `ussd/pending` pull/FCM
   wake → Android `TelephonyManager.sendUssdRequest` se session chalana
   → `start`/`menu`/`PATCH` relay. (Android ki USSD API ki had: kuch
   carriers/devices par responses adhoori milti hain — pilot test lazmi.)
6. **RCS module:** Google Messages ko default SMS app rakh kar, vendor
   ke documented tareeqe (Accessibility + Notification Access) se RCS
   send/status — `rcs/selectors` se capability. **Ye hissa sab se nazuk
   hai** (Google Messages ki internal behavior par munhasir); spec mein
   ise optional module rakha jaye, SMS core pehle.
7. **Updates:** `app/update` check + signed download se self-update
   (Play Store par ye apps nahi jate — vendor bhi yahi karta hai).
8. **Branding:** hamari apni app hai — koi builder nahi chahiye; site URL
   pairing se configure hoti hai (ek hi APK sab sites ke liye mumkin hai,
   vendor ke per-site build ki majboori hamari nahi).
9. **Error reports:** `POST error-reports` par app crashes server ko
   (server inhen apni pipeline mein leta hai).

Base options: **clean-room Kotlin app** is contract par (final plan ki
pehli pasand), ya **SMS Gate (Apache 2.0) fork + adapter** — SMS Gate se
hamara 2026-11-13 ka live proof pehle se hai. Adapter ko bas upar wale
endpoints/auth/FCM actions se map karna hai.

### (e) Difficulty / risk
**Medium — aur sab se zyada tayyar.** Protocol 100% hamare pas hai; asal
kaam Android ki background limits (battery optimization, OEM killers —
Redmi/Xiaomi waghera par khaas), multi-SIM quirks aur carrier throttling
hai. Consumer SIM par campaign volume ka block risk standing warning hai
— app mein rate-limit/delay ki pabandi lazmi.

---

## 7. Mobile App (paid Extra, $150, Flutter — hum NAHI khareed rahe)

### (a) Ye kya hai / kya karta hai
Workspace ke agents/owners ke liye Messenger ki mobile app (Android +
iOS) — vendor is ka **full Flutter source** deta hai (list ki wahid paid
cheez jis ka source milta hai, LANE-3), lekin hamara faisla hai ke hum
apni app khud banayenge. Khush-khabri: **mobile API core mein hai** —
`routes/mobile.php` (~117 routes, LANE-5 §6) aur `mobile_devices`,
`mobile_sign_in_tokens` tables core ki hain; demo admin settings mein
"Mobile App" tab maujood hai jahan demo APK (**zender-demo-mobile-
v5.0.4.apk, 99 MB, v1.0.0**) aur Firebase push "Configured" dikha
(LANE-4 §D), aur `php artisan mobile:install-apk <file>` command core
mein hai (LANE-2). Yani server side tayyar hai — sirf client banana hai.

### (b) Evidence-based behavior (LANE-3 Mobile App page + LANE-4)
- **Inbox:** search/filters/views; threads kholna, reply, internal notes,
  attachments, voice messages record/play, emails parhna, contact
  details; nayi conversation contact/number/Telegram user se shuru.
- **Conversation actions:** assign/transfer/team, label, priority,
  snooze, pin, mark unread, resolve/reopen, macros, AI summary, AI
  replies pause, copy/retry/unsend/react/edit (jahan channel support
  kare); contact ke orders + payment/COD status.
- **Live updates + push:** realtime inbox/unread badges; push tap par
  sahi conversation khulti hai; push **apne Firebase project** se.
- **Owner modules (har module sirf tab jab site enable kare):** overview/
  inbox metrics, contacts (CRUD/groups), campaigns (delivery stats,
  cancel), call history, channel status, USSD, WABA template statuses,
  members, billing (invoices, credit history), support tickets.
- **Sign-in/security:** password, 2FA, ya sign-in code + QR scan;
  password reset; biometric lock; signed-in devices review; account
  delete.
- **Branding model:** ek config file se rebrand (app name, application
  ids, icons, splash, notification icon ka brand colour) + rebrand tool;
  site ke theme presets follow (light/dark); languages EN/AR/JA built-in
  + RTL, site ke translation editor se mazeed languages **bina rebuild**
  (core mein `v1/app-translations/{app}` endpoint is ka saboot hai).
- Requirements vendor ke liye: Android 8.0+/iOS 15.0+, apne Play/App
  Store developer accounts, iOS ke liye Mac + Xcode. Updates free; source
  ki resale/redistribution mana hai.

### (c) UNVERIFIED
- Mobile API ke exact payloads har screen ke liye (routes/mobile.php se
  surface wazeh hai; field-level detail implementation ke waqt parhi
  jayegi).
- Vendor app ke offline behavior/sync strategy ki detail.

### (d) Clean-room spec — hamari apni agent/owner app
1. **Client:** Flutter (ek code base, Android + iOS) `routes/mobile.php`
   ke against; auth core ke mobile sign-in tokens se (password/2FA/code +
   QR) — koi naya backend nahi chahiye.
2. **MVP scope (pehle ye):** inbox (views/filters), conversation screen
   (reply, notes, attachments, voice notes), conversation actions
   (assign/label/priority/snooze/resolve), push notifications (apna
   Firebase; tap → conversation), channel status + credits overview.
3. **Doosra darja:** contacts CRUD, campaigns (stats/cancel), call
   history, USSD screen, billing (invoices/credits), members, tickets.
4. **Branding:** ek config (name/ids/icons/splash/colour) — vendor ke
   model ki tarah; theme site presets se `v1/apps/theme` endpoint se;
   translations `v1/app-translations/{app}` se bina rebuild ke.
5. **Distribution:** apne Play Store account se ya direct APK (admin
   `mobile:install-apk` se site par lagti hai).

### (e) Difficulty / risk
**Medium.** Backend tayyar hai; kaam sirf client ka hai, lekin woh chhota
nahi (inbox realtime + push + voice notes). MVP scope bandh kar rakha
jaye warna ye kabhi khatam na hone wala project ban jata hai. Phase 5
item hai (final plan) — pehle web inbox se kaam chalta hai.

---

## 8. Browser Extension Builds + Per-Site Branded Connectors

### (a) Ye kya hai
Do paid cheezein ek hi pattern par chalti hain — **server har site ke
liye us ki branded build generate karke deta hai:**
- **Browser Extension ($59):** per-site branded Chromium extension —
  dashboard se apni build download hoti hai (site name + site address
  fixed), Developer mode → Load unpacked se install (koi Web Store
  listing nahi) (LANE-3).
- **Integration connectors:** WordPress, WHMCS, Perfex, Blesta, Flarum,
  osTicket, Odoo, Shopify waghera ke connectors **branded downloads** hain
  — Integrations page se download hone wale connector mein messaging site
  ka address pehle se fixed hota hai; aksar mein API key ka field hi nahi
  hota, "Connect" par OAuth-style approval hota hai aur routing (channels/
  senders/fallbacks) Zender site par manage hoti hai (LANE-3 har
  integration ki entry). Core mein is ka saboot: `integration_site_routing`
  table aur `Integrations/` services (LANE-5 §4/§6). Website Chat aur Web
  Push ke liye bhi generated WordPress plugin/snippet isi pattern par hai
  (LANE-3).

### (b) Evidence-based behavior
- Extension: web page par phone/email right-click → action; popup se
  messages (unread counts, recent conversations, templates, contact
  create); Messenger se calls (server har action par member ke rights
  check karta hai); realtime packaged worker + polling fallback; **sirf
  packaged code, koi remote script nahi**; connection token local storage
  mein, **90 din** expiry; dashboard se kisi browser ko revoke; nayi
  build par update lock (LANE-3). Chromium 120+.
- Connectors: download → host app mein install → Connect (Zender mein
  approve) → Test Connection → routing Zender side par. Har connector
  apne host ki zabaan mein hai (WordPress plugin PHP, WHMCS addon,
  Perfex module, Flarum extension Composer se, osTicket plugin,
  Odoo add-ons Python mein — LANE-3 Odoo entry).

### (c) UNVERIFIED
- Build generation ka andar ka mechanism (template + config injection
  muhtamalan hai, lekin vendor code nahi dekha).
- Extension ke source ki halat product page par stated nahi (packaged
  build hi milti hai).

### (d) Clean-room spec — hamare rebuild ke liye
1. **Pattern apnana hai, code nahi:** hamari integrations (Phase 4) mein
   har connector ke liye ek chhota sa "build step" rakha jaye jo site URL
   + site name ko connector package mein bake karke download de —
   tenant ko API key copy-paste ki jhanjhat na ho. Yehi is pattern ki
   asal qeemat hai (UX), aur ye banana asaan hai: connector source hamara
   apna hoga, build sirf config file replace karke zip karega.
2. **Browser Extension (apni):** Manifest V3 Chromium extension — popup
   inbox (core REST API + API key/token se), context-menu actions
   (phone/email par Send SMS/WhatsApp), click-to-message; token expiry/
   revoke core API keys se hi ho jata hai. Koi per-site build asal mein
   lazmi nahi — site URL user ek dafa settings mein dal sakta hai; lekin
   white-label tajurbe ke liye generated build wala pattern rakha ja
   sakta hai.
3. **Connectors ki tarteeb final plan ki hai:** pehle woh jo hamare
   customers ko chahiye (WordPress/WooCommerce sab se aam), baqi baad
   mein. Har connector sirf core REST API + webhooks par chalega — koi
   band server nahi chahiye.

### (e) Difficulty / risk
**Easy-Medium per connector.** Pattern saaf hai; har host platform (WP/
WHMCS/Perfex…) ki apni plugin API seekhni parti hai, lekin koi band
binary beech mein nahi. Extension **Easy** hai.

---

## Khulasa table — replacements ki mushkil ka darja

| # | Component | Hamare pas kya hai | Replacement | Mushkil |
|---|---|---|---|---|
| 1 | WhatsApp QR server | Band binaries (3 platforms) + poora PHP contract | Evolution/Baileys + Reverb adapter | Medium-Hard |
| 2 | SMPP server | Band binaries (3 platforms) + core driver | Jasmin + adapter | Medium |
| 3 | Telephony server (Phone Bridge/GSM Modems) | Kuch nahi (paid, na khareeda) — sirf core contract | **Asterisk PBX module** (apna rasta, Addenda 1–7) | Hard |
| 4 | Telegram server | Kuch nahi (paid) — documented behavior | Telethon/TDLib service (bot mode asaan) | Medium |
| 5 | Email server | Kuch nahi (paid) — documented behavior | Standard IMAP/SMTP service | Easy-Medium |
| 6 | Android gateway + companions | Koi APK/source nahi — **poora server protocol core mein hai** | Clean-room Kotlin app (ya SMS Gate fork + adapter) | Medium |
| 7 | Mobile App (Flutter) | Kuch nahi — **mobile API core mein tayyar hai** | Apni Flutter app, MVP scope | Medium |
| 8 | Browser Extension + branded connectors | Kuch nahi — pattern documented hai | MV3 extension + apne connectors, build-step pattern | Easy-Medium |

**Aakhri note:** Is list ki koi bhi cheez launch blocker nahi hai. Core
Zender (jo hamare pas source mein hai) WABA + 16 HTTP SMS providers +
Android protocol ke sath akela chal sakta hai; band servers sirf channel
engines hain jin ki surface core PHP se poori parhi ja sakti hai — aur har
surface ke liye khula open-source jawab maujood hai.
