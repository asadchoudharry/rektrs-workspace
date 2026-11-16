# ZENDER (SENDQON) — ORACLE INSTALLATION PLAN
Date: 2026-11-16 · Status: PLAN (install on owner GO) · Audit base: Lanes 1–6 + rebuild tree

## ADDENDUM — ROUTE CHANGE (owner, 2026-11-16 ~10:49 PKT)
**Install ServerKit panel ke raste se hoga** — vendor autosetup seedha host OS
par NAHI chalega. Wajah: offbox-1 par **ServerKit pehle se installed hai**
(v1.11.40, 2026-11-15; panel.rektrs.com; nginx + docker services active) aur
wahi is server ka management layer hai. Tabdeelian:
- Autosetup ke 17 steps ab **spec/checklist** hain: jo kuch woh karta hai
  (env values, FPM pool limits, Reverb/queue services, har-minute cron,
  nginx ke Reverb proxy paths, SSL) wohi ServerKit deployment ko reproduce
  karna hoga — zyada imkaan **custom template / Docker compose stack**
  (app + MySQL + Reverb + queue + scheduler) ki surat mein.
- Host par pehle se **nginx (ServerKit ka) + Docker** hai — bare-metal
  takrao wala khatra khatam; lakin panel ka template mechanism pehle
  verify hoga (fork `asadchoudharry/OperqonServer` ke templates ka jaiza)
  ke custom PHP/Laravel app kis surat deploy hoti hai.
- **Owner step (gate):** panel ka first-admin banana abhi owner ke zimme
  baqi hai (setup code install ke waqt bana tha) + 2FA. Panel login ke
  baghair panel-route aage nahi barh sakta.
- Baqi plan (backup design, verification battery, APP_KEY hifazat, licence
  codes wala mamla, phases) wesay ka wesa laagu hai.

## 0. Faisla khulasa (decisions up front)
- **Host: offbox-1** (129.146.96.133) — 2 OCPU / 12 GB RAM / 100 GB, Ubuntu 24.04 **ARM64**.
  Dono micro instances (1 OCPU / 1 GB) Zender ke liye bohat chhote hain
  (Laravel + MySQL + Reverb + queue ek sath nahi chal sakta wahan).
- **Subdomain (proposed): `sendqon.rektrs.com`** — DNS-only A record → 129.146.96.133.
  (`send.rektrs.com` pehle se Resend ke paas hai, woh nahi milega.)
- **Install route: vendor autosetup script** (`Install/autosetup.sh`) — supported rasta,
  phir hamari hardening + backup layer upar.
- **Scope of this install:** CORE platform live + free plugins jo hum le chuke hain
  (Android Gateway, WhatsApp QR*, SMPP*, WhatsApp Signup, Legacy Importer).
  \* WhatsApp/SMPP **binaries licence code ke baghair start nahi hote** — woh codes
  custom licence finalize hone par milenge; core install un ke baghair mukammal
  hota hai, channels baad mein activate honge.
- **Commercial launch abhi nahi** — ye install testing/internal hai; paying
  tenants custom licence ke baad (standing rule).

## 1. Mojooda surat-e-haal (verified facts)
- Oracle Always Free, home region Phoenix. Teen instances:
  offbox-1 (ARM, 2 OCPU/12 GB), micro-1 (Kuma + Vaultwarden + Apprise),
  micro-2 (Healthchecks + WireGuard hub + Gitea + registry cache).
- WireGuard mesh live hai: micro-2 = 10.10.0.1, offbox-1 = 10.10.0.2, micro-1 = 10.10.0.3.
- VCN ingress 80/443 pehle se khula hai.
- offbox-1 ka tay-shuda role: ServerKit panel + backup copy #3. **Zender wahan
  co-host hoga** — is plan mein resource limits is liye rakhe gaye hain taake
  dono aram se chalain. (Agar aage ja kar paying load barha to Zender ko apni
  jagah dena pehla upgrade hoga.)
- Idle-reclaim note: Zender ek **genuine always-on workload** hai (cron har
  minute, queue worker, Reverb) — offbox-1 ke reclaim risk ko kam karega,
  koi artificial load nahi chahiye.

## 2. Zender ki requirements (audit se verified)
- PHP **8.4.1+**, MySQL 8 **ya** MariaDB, web server, public HTTPS.
- Cron: `schedule:run` **har minute**. Queue worker: `--stop-when-empty --max-time=300`
  (autosetup is ke liye systemd service banata hai).
- Autosetup (Ubuntu 24.04): app `/var/www/zender` mein; services
  **zender-reverb** + **zender-queue**; setup credentials `/var/lib/zender/` mein.
- **APP_KEY sab se critical cheez hai** — system_settings isi se decrypt hote
  hain; gum ho jaye to saare saved secrets + opt-out hashes khatam.
  Backup se pehle `cache:clear` ki vendor hidayat bhi note hai.
- Storage **local only** (S3 option nahi) — disk planning isi hisab se.
- Frontend React/Inertia pehle se built aata hai; Node build ki zaroorat nahi.

## 3. Pre-flight (install se pehle, Muse karega)
1. offbox-1 ka inventory: mojooda services, ports (80/443 par kya chal raha
   hai — Caddy?), disk/RAM ki asal surat, ServerKit panel laga hai ya nahi.
2. **Poora snapshot/backup**: offbox-1 ka OCI boot-volume backup + `/etc` aur
   mojooda web roots ka tar — kuch bigre to wapas ana mumkin ho.
3. DNS: `sendqon.rektrs.com` A record (DNS-only) → 129.146.96.133.
4. System update + timezone Asia/Karachi confirm.
5. Swap ki surat check (12 GB RAM ke sath bhi 2 GB swap rakha jayega safety ke liye).
6. Firewall: OCI security list mein 80/443 pehle se hai; host iptables mein
   sirf wohi khula rahe; Reverb ka port bahar se band, sirf reverse proxy se.

## 4. Install steps (sequence)
1. **Database**: MariaDB (ya MySQL 8) install; `zender` database + kam-ikhtiyar
   user; InnoDB buffer pool ~2 GB; bind sirf localhost.
2. **PHP 8.4** + zaroori extensions (vendor list ke mutabiq: mbstring, xml,
   curl, zip, gd, intl, bcmath, mysql, redis agar autosetup mange).
3. **Vendor autosetup chalana**: package ke `Install/autosetup.sh` ko pehle
   **parh kar** (kya karta hai, step by step log) phir chalana — andha bharosa
   nahi. Ye web server, PHP-FPM, services aur cron set karta hai.
   ⚠️ **ARM note**: autosetup x86 farz karke likha ho sakta hai. PHP core
   architecture-free hai; jahan script koi binary laye, wahan ruk kar check
   hoga. WhatsApp plugin mein ARM binary maujood hai (Lane 5 verified).
4. **HTTPS**: Caddy (agar pehle se hai to usi mein site add) ya autosetup ka
   web server + Let's Encrypt. Reverb ke liye WSS reverse proxy rule.
5. **Web installer** browser mein mukammal karna: admin account banana —
   **ye step owner ke sath hoga** (admin email/password owner tay karega;
   Muse password kabhi nahi leta — owner khud type karega ya Muse ke
   samne browser mein).
6. **SMTP**: Hostinger par `sendqon@rektrs.com` mailbox (owner hPanel se
   banayega — account action hai), phir Zender admin mein SMTP settings;
   test email se verification.
7. **Purchase code / error reporting**: admin mein agar code dala bhi jaye to
   **Sentry error reporting OFF rakhna hai** (audit finding: woh vendor ko
   exception reports bhejta hai). Default off hi hai — bas on nahi karna.
8. **Free plugins install** (Admin > Plugins, ZIP upload): Android Gateway,
   WhatsApp Signup, Legacy Importer pehle; WhatsApp + SMPP plugins install
   ho jayenge lekin un ke servers licence code par rukenge (expected hai).
9. **Firebase project** (Android push ke liye): owner apne Google account se
   Firebase project banayega; config Zender admin mein dalegi. Is ke baghair
   gateway polling par chalta hai (kaam karta hai, instant delivery nahi).

## 5. Post-install configuration
- **Plans apne banane hain** (vendor demo prices Free/Starter $19/Pro $49/
  Enterprise $199 sirf seed hain — hamari pricing alag hogi, baad mein tay).
- Site name/branding: Sendqon (white-label kit ane par full apply hoga;
  abhi naam + logo basic).
- Language: English default; Urdu baad ki phase.
- Cron verify: `schedule:run` har minute chal raha hai (121 scheduled jobs
  register hote hain — admin Cron Jobs page se cross-check).
- Services auto-start: zender-queue, zender-reverb, DB, web — reboot test
  ek dafa (maintenance window mein) taake boot par sab khud uthe.

## 6. Verification battery (install "done" tab kahlayega jab ye pass ho)
1. `https://sendqon.rektrs.com` par login page + admin login kaam kare.
2. Tenant workspace bana kar Messenger khule; test user register ho.
3. Cron + queue: ek test campaign/notification queue se nikal kar process ho.
4. Reverb: browser mein real-time inbox update (dusri window se message).
5. Android Gateway: phone pair ho (8-char code flow / device token), ek
   **test SMS** apne number par — 2026-11-13 wali kamyabi ka repeat is naye
   system par.
6. SMTP: password-reset email pohche.
7. Backup restore ka **ek dry test**: backup lena + alag folder mein
   restore karke APP_KEY se settings decrypt hona verify.
8. Kuma (micro-1) mein naya monitor: sendqon.rektrs.com uptime + HTTPS cert.

## 7. Backup & safety design
- **Roz raat**: DB dump + `/var/www/zender` (storage samet) + `.env` ki
  encrypted copy → WireGuard par **micro-2** ko push; hafte mein ek copy
  Oracle Object Storage (20 GB free vault) mein.
- **APP_KEY alag se** teen jagah mehfooz (Vaultwarden samet) — ye gum to
  sab gum.
- Patch register shuru din se: core mein jo bhi tabdeeli hogi woh
  `PATCH-REGISTER` mein likhi jayegi (ServerKit discipline) taake vendor
  update hamari tabdeeli kha na jaye.
- Rollback point: har bara step (DB install, autosetup, plugin install)
  se pehle snapshot; step fail ho to wapas usi point par.

## 8. Risks & open items
| # | Risk / sawal | Hal |
|---|---|---|
| 1 | Autosetup ARM par koi x86 binary farz kare | Script pehle parhna; binary steps par ruk kar ARM alternative (WhatsApp ARM binary maujood hai) |
| 2 | offbox-1 par ServerKit panel ke sath resource takrao | MariaDB/PHP-FPM limits; Kuma + memory watch; load barhe to Zender ko alag host pehla upgrade |
| 3 | WhatsApp/SMPP binaries licence code ke baghair band | Expected — custom licence finalize hote hi codes; tab tak core + Android gateway live |
| 4 | Oracle idle-reclaim (A1) | Genuine workload (cron/queue/Reverb) risk kam karta hai; PAYG upgrade owner ka billing faisla, abhi nahi |
| 5 | Ek hi server = single point of failure | Backup micro-2 + Object Storage; one-click restore wala purana faisla jab owner kahe |
| 6 | Consumer SIM par carrier throttle (Android gateway) | Rate limits + opt-out discipline pehle din se (audit rule) |

## 9. Owner-only steps (sirf ye aap ke hain)
1. Admin account ka email/password (install ke waqt browser mein khud dalna).
2. Hostinger mein `sendqon@rektrs.com` mailbox banana.
3. Firebase project banana (apne Google account se).
4. Cloudflare mein `sendqon.rektrs.com` DNS record — ya to aap dalain, ya
   mujhe kahein to main browser se koshish karoon (login aap ka hoga).
5. Aakhri GO: install shuru karne ki ijazat + kis waqt (maintenance window).

## 10. Is ke baad (phases, pehle se tay hain)
Phase 1: white-label kit apply + WABA live → Phase 2: apni Android gateway
app → Phase 3: apna WhatsApp bridge → Phase 4: apne plugins (USP list
samet) → Phase 5: telephony/PBX. Roadmap: `zender-rebuild-tree/08-REBUILD-ROADMAP.md`.
