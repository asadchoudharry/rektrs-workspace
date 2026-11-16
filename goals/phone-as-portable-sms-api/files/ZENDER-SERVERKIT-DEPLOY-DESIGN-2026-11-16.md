# ZENDER × SERVERKIT — DEPLOY DESIGN (2026-11-16)
Owner GO ke baad offbox-1 ka live jaiza + panel mechanism ki tehqeeq par mabni.

## Live evidence (offbox-1, 2026-11-16 ~10:55 PKT, read-only SSH)
- Host: ARM64, load ~0.2, RAM 11 GB (10 available), disk 92 GB free.
- Services active: **serverkit, nginx, docker, caddy**. MySQL host par nahi.
- **Public face Caddy hai** (80/443 usi ke paas); Caddyfile mein abhi sirf
  `panel.rektrs.com → 127.0.0.1:8080`. Panel backend 127.0.0.1:5000.
- Docker chal raha hai, **koi container abhi nahi** — saaf slate.
- Panel: ServerKit v1.11.40, root `/opt/serverkit`, backend
  `/opt/serverkit/backend` (gunicorn, 127.0.0.1:5000).

## Template mechanism (kesay kaam karta hai)
- Har app = **ek YAML file** `/opt/serverkit/backend/templates/<id>.yaml`;
  sath `index.json` registry (name/schema_version/count/templates).
- YAML ka khaka (BookStack template se verified — woh bhi PHP+MySQL hai):
  `id, name, version, description, icon, website, categories`,
  **variables** (type: port/password, `generate: password` support),
  `ports`, `volumes`, `requirements` (memory/storage),
  **`compose:`** — andar poora docker-compose (services, env, volumes,
  depends_on), aur `post_install` notes.
- Matlab Zender ke liye **custom template `sendqon.yaml`** bane ga; panel
  usi se compose chala kar app bana de ga. Registry/index mein nayi file
  kesay register hoti hai (folder scan ya index regenerate) — build lane
  panel ke code se confirm kare gi.
- Panel ka CLI bhi hai (`cli.py`: create_admin, setup_code, reset_password…)
  lekin **first-admin banana owner ka step hai** (setup code + apna password);
  install ka aakhri click panel UI se hoga.

## Zender ki surat — services design
Autosetup ke 17 steps ko compose services mein tarjuma:

| Service | Image | Kaam |
|---|---|---|
| `db` | mysql:8 (ARM64 official) | Zender database; volume `sendqon_db` |
| `app` | **custom `sendqon:5.0.4`** | nginx + PHP-FPM 8.4 ek container mein (supervisor); code image mein baked; volume `sendqon_storage` + `.env` |
| `reverb` | sendqon:5.0.4 | `artisan reverb:start --host=0.0.0.0 --port=8080` (sirf internal network) |
| `queue` | sendqon:5.0.4 | `artisan queue:work --tries=3 --timeout=300` |
| `scheduler` | sendqon:5.0.4 | har minute `schedule:run` (loop/supercronic) |

- **Custom image lazmi hai**: Zender koi public image nahi deta. Dockerfile:
  multi-stage — pehle Node 22 stage mein `npm ci && npm run build`, phir
  php:8.4-fpm (Debian) + nginx + ffmpeg + PHP extensions (autosetup wali
  list) + Composer install --no-dev. **Build offbox-1 par hi hoga** (ARM
  native; ye VM x86 hai, wahan ki image nahi chalegi).
- Source: Sendqon repo ki `app` branch ka content (local
  `~/workspace/zender-branches/app`) rsync se offbox-1 par jayega.
- Env (autosetup review se): APP_ENV=production, APP_DEBUG=false,
  LOG_LEVEL=error, DB_CONNECTION=mysql, CACHE_STORE=database,
  QUEUE_CONNECTION=database, APP_URL=https://sendqon.rektrs.com,
  SESSION_SECURE_COOKIE=true. APP_KEY + DB password install par generate
  (template variables / init step `key:generate`).
- Reverb public rasta: browser WSS → **Caddy** → reverb service.
  Autosetup ki nginx `/app/` + `/apps/…` proxy families Caddy ke
  reverse_proxy rules mein translate hongi (Caddy WebSocket khud sambhalta hai).
- Upload limits: app container ki FPM pool mein 128M (autosetup ki wajah:
  Meta 100MB document limit).

## Public rasta
- DNS: `sendqon.rektrs.com` A (DNS-only) → 129.146.96.133 — **owner/Cloudflare step**.
- Caddyfile mein naya block: `sendqon.rektrs.com` → app service ka port
  (127.0.0.1 par publish), `/app/*` aur `/apps/*` (events family) → reverb port.
  Cert Caddy khud Let's Encrypt se le ga. (Wildcard ki zaroorat is route
  mein nahi — har domain ka cert Caddy alag leta hai; tenant custom domains
  ke liye Zender ke apne helpers host-nginx farz karte hain — woh feature
  is Docker surat mein **abhi out of scope** hai, roadmap mein note hai.)

## Step 0 — Panel × Keycloak SSO (owner directive, 2026-11-16 ~10:55 PKT)
**Standing pattern:** panel ki login Operqon wale Keycloak se hogi, aur aage
bhi jo cheez jahan install hogi woh isi SSO se attach hogi — ek hi login
her jagha. (login.operqon.cloud, realm `operqon-provider`.)

Halat (2026-11-16 live check): discovery URL offbox-1 se **200**; panel ke
SSO fields abhi khali hain (sso_oidc_enabled=false, client_id/discovery
khali); defaults durust pehle se set hain (auto_provision=false,
default_role=viewer, proxy-hop config validated 2026-11-15); panel mein
**1 admin user maujood hai**.

Exact values (2026-11-15 ko installed panel ke code se verified):
- Redirect URI: `https://panel.rektrs.com/login/callback/oidc`
- Discovery URL: `https://login.operqon.cloud/realms/operqon-provider/.well-known/openid-configuration`
- Client ID: `serverkit-panel` (confidential, client authentication ON)
- Panel provider name: `Rektrs Login`

**Admin console public NAHI hai (2026-11-16 verified, owner ki baat durust
thi):** login.operqon.cloud ka Caddy sirf `/realms/operqon-provider/*`,
`/realms/operqon-customers/*`, `/resources/*`, `/.well-known/*` proxy karta
hai — `/admin/*` aur master realm jaan-bujh kar band hain (browser mein
"Not Found" aata hai). Ye hardening **barqarar rahe gi** — admin public
nahi khule ga. Keycloak VPS ke andar zinda hai:
`http://127.0.0.1:18086/admin/` → 302 (console login).
**Rasta: owner apne laptop se SSH tunnel** (Termius port-forward
localhost:18086 → VPS 127.0.0.1:18086), phir browser mein
`http://localhost:18086/admin/` — master admin se login, realm
operqon-provider select karke client banana.

Steps — dono **owner ke haath se** (secret chat/Muse se kabhi nahi guzrega):
1. (tunnel ke baad) Keycloak admin console → realm operqon-provider →
   Clients → naya client `serverkit-panel`, upar wala redirect URI exact;
   Credentials tab se secret.
2. Panel → Settings → SSO → OIDC: enable, provider name, discovery URL,
   client id, secret wahi paste.
3. **Owner ka apna sign-in test** (panel login → "Rektrs Login" → Keycloak →
   wapas panel) = gate proof. Pehli test par us ka panel account email se
   link hoga (auto_provision=false).
Note: Keycloak groups panel mein propagate nahi hote — panel ke roles
panel-local rehte hain; MFA Keycloak realm mein enforce hoga.

## Sequence
1. ✅ Panel mechanism + host inventory (ye document).
2. **Build lane**: source rsync → Dockerfile → `sendqon:5.0.4` image build
   offbox-1 par → image smoke test (php -v, artisan --version).
3. **Template lane**: `sendqon.yaml` likhna + panel templates mein rakhna +
   registry registration confirm karna.
4. **Gate — owner**: panel first-admin (setup code se) + DNS record.
5. Panel se install → .env/APP_KEY → migrate+seed (CHANNEL_PLUGINS_CORE_ONLY=1)
   → Zender web installer par admin (owner khud type kare ga).
6. Caddy block + HTTPS verify.
7. **Verification battery** (install plan wali 8 cheezein: login, tenant,
   realtime, queue, Android pair + test SMS, SMTP, backup dry-restore, Kuma).

## Risks / notes
- Build waqt: 2 OCPU ARM par npm build + composer sust ho sakta hai —
  panel idle hai, masla nahi; build server par background mein chalega.
- Template registry ka exact registration tareeqa build lane confirm kare gi;
  agar panel sirf UI se install deta hai to step 5 owner ke login ke baad hoga,
  us se pehle ki saari tayyari (image + template) mukammal rakhi jayegi.
- MySQL 8 ka ARM64 official image maujood hai; vendor docs MariaDB bhi
  ijazat dete hain — db service mein MySQL 8 pehli pasand (autosetup bhi
  mysql-server lagata hai).
- Tenant custom-domain SSL helpers (autosetup step 16) Docker surat mein
  laagu nahi hote — woh feature baad ki phase mein alag hal hoga.
