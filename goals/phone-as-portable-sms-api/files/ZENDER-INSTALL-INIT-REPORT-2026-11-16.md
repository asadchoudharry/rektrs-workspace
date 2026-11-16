# SENDQON (ZENDER) — INSTALL INIT REPORT (2026-11-16)
Init & Fix Lane: panel install ke baad ke dono crash fix + Zender init + verify.
**Natija: SAARA STACK LIVE HAI** — 5/5 containers Up/stable, migrations+seed
mukammal, app installer par jawab de raha hai (302 → /install).

## 1. Panel app storage (kesay rakhta hai)
- Har installed app: **`/var/serverkit/apps/<id>/`** — sendqon ke liye:
  - `docker-compose.yml` — panel ka rendered compose (env values inline),
    compose project name `sendqon`, working dir yahi.
  - `.env` (600, root) — template variables: APP_NAME, HTTP_PORT, APP_URL,
    DB_PASSWORD (+ ab APP_KEY, neeche dekho).
  - `.serverkit-template.json` — install record + variables ki copy.
- Panel DB (`/opt/serverkit/backend/instance/*.db`) mein `applications`
  waghera ki tables hain, lekin containers ki asal halat Docker se hi
  parhi jati hai — is liye **safe recreate route = usi directory mein
  `docker compose up -d`** (panel ke apne compose se, project name wahi).
  Yahi route istemal hua; panel UI se koi takrao nahi.
- **Panel ne ports khud assign kiye** (install form mein port fields nahi
  thay): app **8081** (0.0.0.0:8081→80), panel app ko
  `http://panel.rektrs.com:8081` par dikhata hai.
- **Reverb port (Caddy ke liye asal maloomat):** compose binding
  `127.0.0.1:18080→8080` — verified listening. Caddy ko WSS ke liye
  **127.0.0.1:18080** par proxy karna hai (draft block mein yahi tha ✓).
  App ke liye Caddy target **127.0.0.1:8081** hoga (18081 nahi — woh
  andaza ghalat tha, panel ne 8081 diya).

## 2. Image fix (pcntl)
- Wajah: Reverb crash `Undefined constant "...SIGINT"` — image mein
  **pcntl** missing tha.
- Fix: Dockerfile ke `docker-php-ext-install` mein **pcntl + sockets**
  jore (local `files/serverkit/Dockerfile` + server `~/sendqon-build/`).
- Pehli rebuild ghalat context se fail hui (npm ci: package-lock nahi
  mila — context `src/` hona chahiye tha, Dockerfile bahir se `-f` se).
  Sahi command: `docker build --network=host -f Dockerfile -t sendqon:5.0.4 src`
- Nayi image: **0784fcd230a3** (purani c84854b14900 ki jagah);
  `php -m` mein pcntl ✓ sockets ✓ verified.

## 3. APP_KEY (bina expose kiye)
- APP_KEY kahin nahi thi (na .env file container mein, na env) — generate
  karke is tarah persist ki ke value kabhi print nahi hui:
  - Container se `key:generate --show` ka output shell variable mein
    pakra; pehli koshish mein PHP deprecation line bhi sath aa gayi thi
    (191 chars ki garbage) — pakar kar saaf kiya: sirf `base64:` wali
    value, **length 51, prefix verified**, value kabhi screen/log par nahi.
  - Persist teen jagah (sab app ki apni directory mein):
    1. `/var/serverkit/apps/sendqon/.env` mein `APP_KEY=` line.
    2. `docker-compose.yml` ke chaaro PHP services (app/reverb/queue/
       scheduler) mein `- APP_KEY=${APP_KEY}` (compose .env se
       interpolate karta hai).
    3. `.serverkit-template.json` ke variables mein bhi APP_KEY jor di
       taake panel-side record mein bhi rahe.
  - Backups: `docker-compose.yml.bak-init`, `.env.bak-init`,
    `.serverkit-template.json.bak-init` usi directory mein.
  - Container ke andar verify: APP_KEY present, len 51, prefix `base64:` ✓
  - ⚠️ **Owner ke liye note (design rule):** ye APP_KEY ab is install ki
    jaan hai — is ki copy Vaultwarden mein rakhna baqi kaam hai; panel se
    full re-install kabhi ho to yehi key wapas lagani hogi warna purana
    encrypted data nahi khule ga.

## 4. Recreate + init (vendor autosetup ka tarjuma)
- `docker compose up -d` (panel directory se) — chaaro app containers
  nayi image + APP_KEY ke saath recreate; db untouched.
- `php artisan migrate --force --seed` (env CHANNEL_PLUGINS_CORE_ONLY=1):
  **518 DONE lines, koi failure nahi** (log ke "FAIL" matches sirf ek
  column ke naam `media_failed_at` se thay). DB mein **300 tables**
  (audit ki 316 ginti plugin/optional tables samet thi; core-only seed
  mein 300 bani hain — migrations sab DONE hain).
- `php artisan channel-plugins:sync` — exit 0 ✓
- `php artisan zender:configure-realtime --driver=reverb
  --host=sendqon.rektrs.com --port=443 --scheme=https
  --server-host=reverb --server-port=8080` — "Realtime settings written
  to the database." ✓
- `php artisan storage:link` ✓
- Container ke andar alag `.env` file ki zaroorat nahi pari — artisan
  saare commands env variables se chal gaye.

## 5. Verification (2026-11-16 ~06:57 UTC / 11:57 PKT)
| Check | Natija |
|---|---|
| sendqon (app) | Up, restarts 0 |
| sendqon-db | Up, restarts 0 |
| sendqon-reverb | Up, restarts 0 — 127.0.0.1:18080 LISTEN, HTTP 404 (WS server ka normal jawab) |
| sendqon-queue | Up — jobs process ho rahe hain (WakeSnoozedConversations, FlagSlaBreaches, RecordQueueHeartbeat sab DONE); restart count 8 par ruka hua (woh purane pre-migration crash loop ke thay) |
| sendqon-scheduler | Up — schedule chal raha hai (ussd:expire-sessions DONE 06:57:11) |
| `curl http://127.0.0.1:8081/` | **302 → /install** (Zender web installer — bilkul expected) |
| App logs | koi fatal/error nahi |
| Reverb cache error | sirf boot ke pehle seconds ki lines (migrations se pehle); cache table banne ke baad `reverb:restart` signal bhi kamyab gaya |

## 6. Ab baqi kya hai (is lane se bahir)
1. **DNS** `sendqon.rektrs.com` A → 129.146.96.133 (owner/Cloudflare) —
   us ke baghair site public nahi khule gi (andar sab tayyar hai).
2. **Caddy block** apply karna (draft `files/serverkit/Caddyfile.sendqon`
   mein hai — lekin app port **18081 ki jagah 8081** karna hoga, panel ne
   8081 assign kiya hai; reverb 18080 durust hai).
3. **Zender admin banana** — /install ke web installer se (owner khud
   kare ga; koi seed admin production guard ki wajah se nahi bana).
4. Plugins (Android Gateway waghera) + SMTP + backups — install plan ki
   agli steps.
5. APP_KEY ki copy Vaultwarden mein (owner).
