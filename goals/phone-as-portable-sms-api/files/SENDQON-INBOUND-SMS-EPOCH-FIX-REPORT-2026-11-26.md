# SENDQON — INBOUND SMS EPOCH-TIMESTAMP FIX (PR-006) — 2026-11-26

**Natija: bug band, khoye hue 4 messages khud recover ho gaye.** Ek
inbound SMS ab us ki ghari (clock) ki wajah se kabhi refuse nahi hogi —
epoch, us se purani, garbled ya missing `received_at` — har surat mein
message receive time ke sath store hogi. Production par fix live hai,
aur phone ke outbox mein phanse hue charon messages fix lagtay hi
khud panel mein land ho gaye (rows 234–237).

## 1. Root cause — saboot ke sath, andaza nahi

Zanjeer ke har link ka saboot maujood hai:

1. **App (gateway) — PDU timestamp par andha bharosa.**
   `InboundSmsReceiver.kt` har live SMS par `timestamp = sms.timestampMillis`
   (PDU ka SMSC timestamp) leti hai, phir usi se
   `client_message_id = timestamp` aur
   `received_at = isoFormat().format(Date(timestamp))` banati hai.
   Kuch PDUs service-centre timestamp ke baghair ate hain — un par
   `timestampMillis = 0` hota hai, to app ne bheja:
   `received_at = "1970-01-01T00:00:00.000Z"`, `client_message_id = 0`.
   **Saboot:** production log ke teeno dedup hashes is formula se
   ha-ba-hu reproduce hue — `sha256("3|0|Google|<body>|0") = 3897a8e1…`,
   `sha256("4|0|Google|<body>|0") = ef5f6601… / 5e2b2935…` — yani
   panel ko asal mein `client_message_id=0` aur bucket=0 (epoch) hi mila tha.
2. **Panel — past-side koi defence nahi thi.** Controller validation
   `received_at: required|date` epoch ko pass kar deti hai;
   `DeviceInbound` use `CarbonImmutable::parse()` se verbatim leta tha;
   `InboundRecorder::occurredAt()` sirf **future** times clamp karti thi
   (broken SMSC clock wali comment ke sath) — past ke liye kuch nahi tha.
3. **Database — strict mode ne row refuse kar di.**
   `channel_messages.occurred_at` TIMESTAMP column hai; `1970-01-01 00:00:00`
   us ki range se bahar hai → `SQLSTATE[22007] … 1292 Incorrect datetime
   value` → HTTP 500.
4. **Retry loop — nuqsan barhta gaya.** App ka `flushOutbox()` har wo entry
   rakhta hai jis ka jawab 2xx/422 na ho — to ye messages har engine cycle
   (~22 s) dobara try hote rahe, aur har try ek nayi ERROR likhti rahi.

In khaas messages ke PDU timestamp 0 kyun thay, ye phone ke bahar se
sabit nahi ho sakta — lekin 0 value khud log + hash dono se sabit hai,
aur app ka defect (bina floor ke bharosa) aur panel ka defect (bina
floor ke qabul) dono jagah zahir hain. Fix dono taraf laga hai.

## 2. Nuqsan — kitne messages, kab se, recovery

| Din (UTC) | Failed insert attempts (log entries) |
|---|---|
| 2026-11-24 (pehli ERROR 11:46:55 UTC) | 4,692 |
| 2026-11-25 | 10,686 |
| 2026-11-26 (aakhri 07:21:56 UTC, patch se pehle) | 2,818 |
| **Kul** | **18,196** |

- **Distinct khoye hue messages: sirf 4** — saare ke saare owner ki apni
  SIMs par aye Google verification-code SMS (SIM 3 / Zong par 1, SIM 4 /
  Ufone par 3; teesra din ek naya code bhi phansa). 2026-11-24 se pehle
  ke logs (16–20 Nov) mein is class ki ek bhi ERROR nahi.
- Koi aur sender/class is bug se mutasir nahi hua — distinct list har
  roz sirf yahi messages dikhati hai. Baqi inbound traffic aaj bhi
  normal store hoti rahi (fix se pehle aaj 13 messages store hue thay).
- **Recovery: mukammal, khud-ba-khud.** Charon messages phone ke durable
  outbox mein mehfooz thay. Panel fix live hotay hi aglay flush ne
  charon ko store kar liya — `channel_messages` ids **234–237**,
  2026-11-26 07:22:18–21 UTC, har hash bilkul **1 row** (duplicate koi nahi).
- **Iman-dar hadd:** un ke `occurred_at` ab asal receive time (07:22 UTC)
  hain, SMSC wala waqt nahi — wo waqt kabhi transmit hi nahi hua tha
  (0 aya tha), is liye wo wapas nahi aa sakta. Message ka **matn (body)
  mukammal mehfooz** hai; sirf ghari fallback hai.

## 3. Fix — PR-006 (PATCH-REGISTER mein darj)

Panel (core, 3 files — live container + build tree `~/sendqon-build/src`
dono mein, md5-verified):

| File | Tabdeeli | md5 pehle → baad |
|---|---|---|
| `app/Services/Omnichannel/InboundRecorder.php` | `occurredAt()` mein past-floor: 2000-01-01 se purani event time `now()` par (future clamp pehle se tha — ye us ka mirror hai). Ye recorder **har channel** ka choke point hai, to WhatsApp/Telegram/SMPP waghera sab cover. | `3913f588…` → `4234eea9…` |
| `app/Services/Messaging/Sms/DeviceInbound.php` | Naya `receivedAt()` helper: missing/unparseable par throw ki bajaye `now()`; SMS + RCS dono paths isi se; dedup bucket ab parsed Carbon ke timestamp se (well-formed values par hash byte-identical — stuck messages ke hashes se sabit). | `155fe3a5…` → `42c7b1b5…` |
| `app/Http/Controllers/Api/V1/Android/MessageController.php` | `received_at` validation `required|date` → `sometimes|nullable|string|max:40` — garbled value ab 422 par drop nahi hoti, service ke fallback tak pohonchti hai. | `b2384ab6…` → `7fb72569…` |

App (source only — **is lane mein release nahi kata**, agle release mein
jayega): `InboundSmsReceiver.kt` mein floor — `timestampMillis <
946684800000` (2000-01-01) ho to dono fields ke liye phone ka apna
receive time. Commit `210eacf`, branch `app-own-android` (ls-remote verified).

## 4. Battery — DEV pehle, phir production proof

**DEV (zender_dev, device 1/sim 4) — fix se pehle asal bug reproduce:**
epoch → bilkul wahi `QueryException 1292`; 1960 → wahi; garbled →
`InvalidFormatException`; missing → `ErrorException`; normal → exact
timestamp par store; duplicate → `duplicate=true`.

**DEV — fix ke baad 6/6 PASS:** epoch → stored, `occurred_at` = receive
time · normal → `2026-11-25 10:15:00` **bilkul exact** · usi ka retry →
`duplicate=true`, wohi row · garbled → stored, receive time · missing →
stored, receive time · 1960 → stored, receive time.

**Production:**
- Pehle fresh backup (2026-11-26 07:21 UTC, `status=OK push=OK`,
  teeno artifacts gzip-verified).
- www-data fresh-process clamp probe (koi DB write nahi): epoch → now ·
  pre-epoch → now · normal → exact · future → now (purana behaviour qaim).
- **Asal proof traffic se aya:** koi synthetic message production mein
  NAHI dala gaya — phone ke apne retries ne charon stuck messages ko
  store kiya (§2), aur 22007 ERRORs 07:21:56 UTC ke baad **sifar** hain.
- Site HTTP 200; teeno files `php -l` saaf (www-data).

## 5. Haddain / note

- Fix abhi web container ki layer + build tree mein hai (PR-003/PR-004
  wala hi pattern) — agli image build ise har container mein bake kar
  degi. Ingestion HTTP path hai jo web container serve karta hai;
  queue/scheduler ko recorder ka ye hissa nahi chahiye.
- DEV battery ki fixture rows `zender_dev` mein rehti hain (scratch env,
  production data se koi ta'alluq nahi).
- Floor 2000-01-01 jaan boojh kar rakha hai: asal historical SMS is se
  purani ho hi nahi sakti, aur TIMESTAMP ki asal range (1970–2038) ke
  andar ki har asal value bilkul waisi ki waisi store hoti hai — sirf
  broken-clock values girti hain.
