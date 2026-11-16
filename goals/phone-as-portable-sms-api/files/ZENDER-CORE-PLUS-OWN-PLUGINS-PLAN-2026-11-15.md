# WhatsApp + SMS System — FINAL PLAN (Owner GO 2026-11-15)

## Faisla
Sirf Zender 5 ka **main script** khareeda jayega (full PHP source).
**Koi paid plugin NAHI liya jayega.** Plugins aur Android app hum khud banayenge —
source, malkiyet aur white-label poora Rektrs ka hoga.
Free plugins (Android Gateway, WhatsApp QR, SMPP, WABA Embedded Signup) verified
buyer ke tor par le liye jayenge, lekin system un par depend NAHI karega —
woh sirf reference / interim hain jab tak apne version tayyar na hon.

## Buy list (sirf ye)
| Cheez | Daam (study 2026-11-15) | Note |
|---|---|---|
| Zender 5 — **Extended licence** (CodeCanyon) | $350 | Users se charge karna hai, is liye Regular ($19) kabhi nahi — woh licence ke khilaf hoga |
| Support 12 months extension | $5.25 | Khareedte waqt sasta hai, le lena behtar |
| **Total** | **~$355** | Vendor store par Extended $299 bhi dikha tha — khareedte waqt pehle woh rate + licence terms verify honge; jo sasta aur saaf licence de, wahan se |

**NAHI khareedna:** Stripe $39, AI Agents $59, AI Flow $59, Telegram $59,
Website Chat $59, Email $59, Auto Update $59, Phone Bridge $100, GSM Modems $100,
MCP $120, RCS $59, payment gateways $39 each — ye sab apne banenge.
**Exception sochne wali:** Mobile App plugin $150 full Flutter source deta hai —
Phase 5 mein faisla hoga, abhi nahi.

## Khareedne se PEHLE ki ek check (muse ki zimmedari) — DONE 2026-11-15
Live demo (zender.titansys.dev) check ho gaya (public pages, baghair sign-in):
kahin bhi "Powered by" wali line NAHI mili. Demo par dikhne wala Zender
logo/footer vendor ki apni site identity hai — self-host par admin se
apni identity set hoti hai (docs). Pricing table mein White Label per-plan
feature hai (Pro/Enterprise mein shamil). Login/register ka footer minimal
hai (sirf links). Ek hissa ab bhi khula hai: signed-in tenant ke andar ka
view baghair account ke verify nahi ho sakta — woh Phase 0 mein apni
install par confirm hoga.

## Phases
- **Phase 0 — Purchase + Source Audit (khareed ke foran baad)**
  Script install (standalone, apne subdomain + VPS, Operqon se alag).
  Source khol kar 3 cheezein map karni hain: (1) plugin system kis tarah hook
  hota hai, (2) Android gateway ka server-side protocol, (3) WhatsApp channel
  ki internal API. Har apni change ek patch register mein — vendor update aye
  to apni cheezein gum na hon.
- **Phase 1 — White-label + Live setup**
  Site identity, logo, domain, landing — owner ki white-label kit se.
  WABA (shamil hai) connect karke pehla official WhatsApp test.
- **Phase 2 — Apni Android Gateway App (sab se qeemti hissa)**
  Clean-room Kotlin app: server source mein dikhne walay protocol par apni
  implementation, ya SMS Gate (Apache 2.0, pehle live prove shuda) fork +
  Zender adapter. Vendor ki app builder wali bandish khatam — source apna,
  naam/packaging apna, features apne. Vendor ke compiled code ko decompile/copy
  NAHI karna (licence/copyright) — sirf protocol par nayi implementation.
- **Phase 3 — Apna WhatsApp QR bridge**
  Open-source engine (Evolution API / Baileys type) par apna channel module,
  taake QR wala WhatsApp vendor ke compiled binary ke baghair chale.
  Number-ban risk ki warning har jagah sath — official WABA hamesha pehla rasta.
- **Phase 4 — Apne PHP plugins (priority order)**
  1. MCP (REST API wrapper — sab se asaan, agents ke liye)
  2. Payments: Stripe + local tareeqa (bank transfer + PayPal pehle se shamil)
  3. AI Agents / AI Flow Builder
  4. Telegram, Website Chat, Email channel
  5. Integrations (Google Sheets, Shopify, Odoo, WHMCS waghera) — zaroorat par
- **Phase 5 — Baad walay / hardware walay**
  Phone Bridge (calls), GSM Modems, RCS, Mobile App (khud banana ya $150 wala
  full-source plugin — us waqt faisla).

## Rules jo har phase mein lagu
- System STANDALONE rahega; Operqon se jorna sirf loose API/webhook integration
  se, woh bhi Operqon stop lift honay par / Cursor ke through.
- Apna code alag layer mein; core Zender files mein kam se kam change,
  har change patch register mein darj.
- Consumer SIM par bulk = carrier throttle risk; campaigns mein rate limit
  aur opt-out lazmi.
- Credentials kabhi chat mein nahi — Secure Vault / owner-only steps owner ke.

## Addendum (2026-11-15) — Call Centre/PBX, Flash SMS, Masked SMS
Owner sawal par research (sources plan ke neeche):
- **PBX/Call Centre:** Zender messaging platform hai, PBX NAHI. Phone Bridge
  plugin sirf phone-bridge calls hai — IVR/queues/extensions/recording NAHI.
  Asal call centre = alag open-source PBX (Asterisk/FreePBX) + SIP trunk/DID
  number (+ SIM ke liye GSM gateway hardware), phir Zender se apna integration
  module: caller screen-pop, missed-call par auto SMS/WhatsApp, call ke baad
  follow-up. Ye Phase 5 ka add-on hoga. PBX ko doosron ko service ke tor par
  bechne se pehle PTA licensing ki legal check lazmi (apne istemal se alag).
  **Architecture clarification (owner sawal 2026-11-15):** PBX Zender KE ANDAR
  hi develop hoga as an own module — extensions, IVR builder, queues, agents,
  recordings, call logs, click-to-call sab Zender dashboard mein. Sirf voice
  ENGINE (call audio/SIP/RTP) PHP mein nahi ban sakta — us ke liye open-source
  Asterisk service neeche chalegi, jo hamara module AMI/ARI se control karega;
  tenant ko Asterisk kabhi nazar nahi ayega. Yehi pattern Zender khud apne
  WhatsApp plugin mein use karta hai (PHP UI + compiled server peeche).
- **Flash SMS (Class 0):** screen par pop-up, inbox mein save nahi. Android
  SIM gateway se NAHI ho sakta — Android ke public SmsManager mein message
  class set karne ka option hi nahi. Sirf aggregator/SMPP route se, jab
  provider explicitly flash support kare; device/carrier support variable,
  reliability aam SMS se kam — sirf urgent alert type use.
- **Masked/Branded SMS (Pakistan):** SIM se NAHI — sirf telco/aggregator
  route se. Mask PTA se register hota hai: 3–11 characters, mask lazmi
  NTN/registered business name se match kare, letterhead par stamped
  application (rep CNIC + company NTN), ek registration saare 4 networks
  (Jazz/Zong/Telenor/Ufone) cover karti hai, aggregator (SendPK) ke mutabiq
  Rs 5,000 one-time + Rs 5,000 annual, approval 30–45 business days.
  Model: PTA-recognized aggregator ke partner ban kar unki API/SMPP ko
  Zender ke provider slot mein jorna; har tenant ka mask USI ke business
  naam par register hoga (mask share/lease nahi hota) — service-provider
  principle ke mutabiq. Kuch sources ke mutabiq Telenor/Ufone par mask ki
  jagah numeric code dikhta hai — aggregator se confirm karna baki.

## Addendum 2 (2026-11-15) — Owner ka asal call-centre model: GSM Gateway device
Owner ne apna matlooba model wazeh kiya: ek device computer ke sath lage, us
mein SIMs hon, computer ka software calls ko internet route (VoIP) par le
jaye, aur jo agent available ho woh live call utha kar baat kare.
- Ye device **GSM VoIP Gateway** kehlata hai: GoIP (1/4/8/16 channels),
  Yeastar TG (TG200/400/800/1600 = 2/4/8/16 SIMs, 4G LTE models), Dinstar,
  OpenVox. USB se nahi, LAN/network se lagta hai; server par Asterisk chalta
  hai jo isay SIP trunk ke tor par control karta hai.
- Har SIM = 1 line = ek waqt mein 1 call (4 SIM = 4 concurrent calls).
  Inbound: customer SIM number par call → gateway SIP mein badal kar PBX ko →
  PBX available agent ke softphone (browser/app, kahin se bhi) ko bhejta hai.
  Outbound ulta: agent dial kare → PBX → gateway → SIM se bahir, customer ko
  SIM ka number dikhta hai.
- Yeastar TG se SMS send/receive bhi hota hai — yehi device SMS gateway ka
  kaam bhi de sakta hai. Pakistan ke liye 4G LTE + VoLTE model lena hai,
  purane 2G GoIP models risky hain. GoIP-8 listings ~$359–760 (seller farq).
- Yehi hamare PBX module (Addendum 1) ke neeche lagega — owner ka model aur
  hamara plan ek hi hai. SIMs biometric-verified, company ke naam par;
  grey-route international termination is se alag aur ghair-qanooni hai.

## Addendum 3 (2026-11-15) — USB dongle route (owner sawal)
Owner: simple SIM device USB jaisi ho, baqi saara kaam hamara software kare?
- **SIM reader se NAHI hoga** — woh sirf SIM data parhta hai, us mein radio
  nahi hota, network se jur hi nahi sakta.
- **USB GSM modem dongle se HOGA:** dongle mein SIM + radio hota hai, baqi
  sab software ka kaam. Proven route: Asterisk ka open-source driver
  **chan_dongle** Huawei 3G dongles (E1550/E173/E175X waghera) ko AT commands
  se control karta hai — voice calls (in+out), SMS, USSD teeno chaltay hain.
- Har dongle = 1 SIM = 1 call. Zyada SIMs = zyada dongles + powered USB hub;
  dongle purane/discontinued models hain, bazaar mein voice-enabled dhundna
  hoga (Jazz/Zong wali data dongles voice nahi kartin). USB power/RF masail
  scale par atay hain.
- Faisla: **pilot ke liye dongle** (sasta, software-first proof — owner ki
  soch ke mutabiq), **customers/production ke liye GSM gateway device**.
  Software (Asterisk + hamara Zender module) DONO par ek hi chalega — sirf
  neeche ka raasta badlega.

## Addendum 4 (2026-11-15) — Baqi device families (owner sawal)
- **Bluetooth route:** Asterisk ka chan_mobile driver mobile phone ko
  Bluetooth HFP (hands-free) se PBX ki GSM line banata hai — calls + SMS
  phone ke through. **Zender ka paid Phone Bridge plugin bhi yehi karta hai**
  (ESP32 box + Bluetooth + phone). Limits: 1 phone = 1 call, Bluetooth range
  ~10m, phone ki HFP implementation par quality farq — pilot/lab theek,
  production nahi. Alag se buy karne ki zaroorat nahi, ye pattern apne
  software se bhi ban sakta hai.
- **4G module boards (naya pasandeeda pilot):** Waveshare SIM7600 4G HAT /
  USB dongle — SIM lagti hai, USB se PC/Raspberry Pi se jurta hai, AT
  commands se hamara software control karta hai: voice calls, SMS, DTMF
  sab supported, 4G LTE (purane Huawei dongles ki tarah band-shuda 3G nahi).
  Ek module = 1 SIM = 1 call.
- **Computer ke andar wali card:** PCIe telephony card GSM modules ke sath
  (OpenVox type) — server ke andar lagti hai, professional lekin mehngi.
- **Android phone khud** sab se sasta gateway hai (SMS Gate se prove ho
  chuka) — calls ke liye apni app wala route (Phase 2).

## Addendum 5 (2026-11-15) — Option 4 brief: Android phone khud gateway
- SMS hissa PROVEN hai (SMS Gate, 2026-11-13, live test pass).
- Calls mein Android ki HARD bandish (2026-11-13 se recorded): aam app ko
  cellular call ki audio stream tak access NAHI milti — app call laga/kaat
  sakti hai, lekin agent ki awaz internet se call ke andar nahi ja sakti.
  Is liye sirf-app route se asal call centre NAHI banta.
- Asal phone-wala call centre = **Bluetooth bridge**: phone chhotay server
  (PC/Pi) ke pas rakha, Bluetooth HFP se audio server tak, server (Asterisk
  + hamara module) agent ko internet par bhejta hai. Zender ka Phone Bridge
  plugin yehi model hai.
- Limits: 1 SIM = 1 call; phone dedicated + hamesha charging par (heat/
  battery); Bluetooth range ~10m; phone ki quality par munhasir.
- Kharcha: taqreeban zero (purana phone + mojooda PC) — pilot ke liye
  sab se sasta asal-call proof.

## Addendum 6 (2026-11-15) — Phone ki call seedha dashboard par (owner ki asal khwahish)
Owner ko Bluetooth bridge pasand nahi aya; woh chahta hai call phone se
seedha internet dashboard par aye. Do asal tareeqay:
- **Conference bridge (hamari apni app):** app phone ki DEFAULT DIALER banti
  hai. Incoming call → app auto-answer → doosri call hamare server ke number
  (DID) par → dono calls MERGE (3-way conference). Agent dashboard par live
  baat karta hai; customer ko SIM ka number hi dikhta hai; recording/IVR/
  queue server par. Limits: carrier conference-call support + do calls ka
  kharcha + quality do hops ki; kuch phones/carriers par merge ki pabandi —
  pilot mein asal phone+SIM par test lazmi.
- **Call forwarding (sab se asaan):** SIM ki calls carrier-level par hamare
  DID number par forward — call seedha dashboard par ring. Koi app nahi.
  Limit: calls phone par aati hi nahi, number ka control server ke pas;
  outbound ke liye callback bridge.
- Rooted phone se audio stream mumkin hai lekin product-grade nahi —
  rejected for product, lab only.

## Addendum 7 (2026-11-15) — Owner ka sahi nuqta: DID hai to phone kyun?
Owner: agar DID/SIP lena hi hai to customer ko direct wohi number de sakty
hain, phone ki kya zarorat? **Baat durust hai** — faisla is rule par hoga:
- **DID direct (phone NAHI):** jab naya number chal sakta ho aur achha local
  DID mil jaye. Yehi sab se saaf/professional call centre hai.
- **Phone/SIM bridge sirf tab:** (1) number MOBILE wala hi rakhna ho — purana
  number jo customers ke pas pehle se hai / card par chhapa hai; (2) wahi
  number WhatsApp Business ka bhi ho — call aur chat ek number; (3) outbound
  calls par customer ko mobile number dikhana ho (SIP se aam tor par ajeeb/
  ghair-mulki number dikhta hai, log kam uthate hain); (4) Pakistan mein
  local DID milna mushkil/regulated hai — yehi wajah hai ke yahan SIM
  gateways aam hain; (5) SIM bundle package SIP per-minute se sasta pare.

## Addendum 8 (2026-11-15) — Pakistan mein SIP/DID kon bechta hai, qeemat
Research 2026-11-15 (sources neeche plan discussion mein):
- **Local official:** PTCL SIP Trunk (business/enterprise, DID/DOD + UAN
  mapping, qeemat public NAHI — quote/KAM based). Jazz/Telenor/Zong corporate
  bhi SIP/PRI dete hain, quote based. Local integrators (masalan Lahore ki
  ipphone.com.pk) SIP trunk + DID + PBX setup quote par dete hain.
- **International online providers:** GlobalCallForwarding — Pakistan SIP
  trunk **$73.95/month, 10 channels**, number shamil. Continent Telecom —
  Pakistan landline DID **$70/month + $80 setup**. KataTelecom — DID from
  **$56.70/month**. DIDLogic — rental from $8 (type par munhasir, documents
  lag sakty hain). Twilio — **Pakistan ka voice number NAHI deta**, sirf
  outbound trunking: Pakistan landline $0.151/min, mobile $0.176/min
  (mehnga — Rs 42–50/min ke qareeb).
- Khulasa average: international DID ~$55–75/month per number; local PTCL/
  corporate route sasta parta hai lekin sales/quote process hai, online
  khareed nahi hoti. Grey-market saste SIP resellers se bachna — PTA grey
  traffic enforcement real hai.

## Addendum 9 (2026-11-15) — QR number par multi-agent calls?
Owner sawal: QR walay number par multiple agents, client call kare to free
agent ke dashboard par jaye?
- **Chats: HAAN** — ek QR number, bohat agents, shared inbox (Zender mein
  pehle se hai).
- **WhatsApp voice calls QR se: NAHI** — Baileys/Evolution (QR linked-device
  protocol) voice/video calls support hi nahi karta; WhatsApp call sirf
  phone par bajti hai, system ko nazar bhi nahi aati.
- **Usi number par aam mobile call:** PBX queue se free agent ko jayegi —
  Addendum 6/7 wala system (SIM bridge ya DID).
- **WhatsApp calls dashboard par multi-agent chahiye to:** Meta ki official
  **WhatsApp Business Calling API** (July 2025 se available) — number Cloud
  API (WABA) par hona chahiye, QR wala number is ke liye nahi. Customer ki
  taraf se anay wali calls free, business ki taraf se per-minute charge;
  kuch shartein (messaging limit waghera). Ye hamare WABA channel ke sath
  apna voice module hoga — Phase 3/5 item.

## Addendum 10 (2026-11-16) — USPs: Sendqon ka farq (differentiation layer)
Guftugu 2026-11-15 ~22:47 PKT mein 6 USP tajaveez samne aayi theen; owner
ne 2026-11-16 ko faisla kiya: **sab 6 is addendum mein darj** hon. Ye
features core ke upar hamari apni layer hain — yahi woh cheez hai jo
Sendqon ko Zender ki baqi copies aur aam messaging panels se alag karegi.

1. **Pakistan-first pack** — JazzCash / EasyPaisa / Raast payments panel
   ke andar; masked SMS ke liye PTA registration ka workflow panel se
   (mask apply → approval tracking → live); Urdu / Roman Urdu UI aur
   tayyar templates (school fees, COD confirmation waghera). Koi global
   competitor Pakistan ko is tarah nahi karta.
2. **SIM Fleet Intelligence** — SIM warm-up schedule, per-SIM daily
   limit + rotation, per-SIM health score (delivery rate, carrier
   blocks), carrier-wise routing. Tenant ki SIMs ban se bachana
   SIM-bhej ki sab se bari takleef hai — ye usi ka hal hai.
3. **Deliverability engine** — bhejne se pehle number validation (HLR),
   cross-channel cascade (WhatsApp fail → SMS → email), campaign se
   pehle spam-content score. Credits bachenge, delivery % barhega.
4. **WhatsApp warm-up + ban-risk score** — naye QR numbers ke liye
   warm-up ramp, per-number risk score, mehfooz bhejne ke pattern.
5. **Vertical packs** — industry ke liye tayyar packs: schools (fee
   reminder, results), clinics (appointments), e-commerce (COD,
   abandoned cart) — templates + flows + reports pehle se bane hue.
6. **Reseller++** — partners apni branded SaaS chalayen (apna domain,
   apni pricing, apne sub-tenants) — vendor ke Partner Network se
   gehra model.

**Tarteeb (Muse ki sifaris; owner ka faisla: sab darj hon):** pehle
1, 2, 3 — yehi Pakistani market ka asal moat hai; phir 4 (Phase 3 ke
sath), 5 (channels tayyar hone ke baad), 6 sab se aakhir (SaaS proven
hone par). Phase mapping: USP-1 → Phase 1 (Urdu UI) + Phase 4
(payments/PTA workflow); USP-2 → Phase 2; USP-3 → Phase 2/4
cross-cutting; USP-4 → Phase 3; USP-5 → Phase 4 ke baad; USP-6 →
Phase 5 ke aas paas. Tafseel rebuild tree ki file
`09-USP-ADDENDUM-10.md` mein hai.

## Owner ka sirf ek step
Khareedna (payment) owner ka apna step hai — CodeCanyon par Zender 5
**Extended** licence. Us se pehle Powered-by wali demo check muse karega
aur result batayega, phir owner khareede ga.
