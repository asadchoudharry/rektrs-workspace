# SENDQON — IMAGE REBUILD + RECREATE REPORT (2026-11-19)

Owner approval: 2026-11-19 ~10:47 PKT ("Jo recommended setup hy wo
perform kro image waly") — 2026-11-19 ki B9 plugin-mode repair ke baad
di gayi tajweez par amal: saare own plugins (B1–B9) ko Docker image
mein bake karke app containers usi image se recreate karna, taake koi
bhi container recreate plugins ko na urra sake.

**Natija: MUKAMMAL + LIVE.** Nayi image `sendqon:5.0.4-20261119`
(`sha256:f16b16db32ad…`, 2.04 GB) se web/queue/reverb/scheduler
recreate hue; post-verify ki har shart pass — khaas tor par www-data
probe mein **50/50 plugins baseline se byte-identical status/version
ke sath, sab main classes LOAD**. Pehli dafa queue aur scheduler
containers mein bhi plugin code asal mein chal raha hai (neeche §5).

---

## 1. Pre-state baseline (swap se pehle, live se liya gaya)

- Running image: `sendqon:5.0.4` = `sha256:5746721d3622…`
  (2026-11-16T07:31Z bani hui; is mein koi own plugin NAHI tha —
  saare plugins sirf running containers ki writable layer +
  host build tree `~/sendqon-build/src` mein thay).
- Containers: sendqon / sendqon-queue / sendqon-reverb /
  sendqon-scheduler (image 5746721d3622), sendqon-db mysql:8
  (Up 2 days — is task mein haath nahi lagaya gaya).
- **Plugins DB baseline: 50 rows** (slug|status|version) — pura table
  §5 ki comparison ka reference hai; appendix mein darj hai.
- Build tree inventory: `app/Plugins/` ke neeche **50 plugin dirs** —
  running container ke dirs se file-list diff **IDENTICAL**; har DB
  plugin ka dir tree mein maujood. `lang/ur/` (7 files) ✓,
  PR-003 (`Currencies.php` + `currency.ts` mein PKR) ✓,
  PR-004 (`app/Services/Cascade/CascadeAccess.php` +
  NodeTypeCatalog hunks) ✓, `docker-entrypoint.sh` mein PR-001/PR-002
  logic ✓.
- **Mode check (trap wala):** tree ke 386 plugin files 660 aur 247
  dirs 770 thay (ubuntu-owned) — Docker COPY inhein aise hi image
  mein le jata aur www-data parh hi na sakta (B9 wali khami ki
  doosri shakal). Build se pehle poora tree normalise kiya gaya:
  `root:root`, dirs 755, files 644 (exec-bit wali files 755) —
  verification: bad files 0, bad dirs 0, non-root-owned 0.

## 2. Safety snapshots

- **Nightly backup script — status flag par DEVIATION (saboot ke
  sath):** do runs (05:51, 05:53 UTC) `status=FAIL push=OK` ke sath
  aye. Root cause live reproduce karke sabit kiya: storage tar ka
  exit code 1 sirf is liye ke live app ki
  `_data/logs/laravel-2026-11-19.log` tar ke parhne ke darmiyan
  badal gayi ("file changed as we read it") — archive khud
  mukammal hai. Teeno artifacts independently verify kiye:
  DB dump gzip-valid, **356 CREATE TABLE** + mysqldump completion
  footer; config tar aur storage tar dono saaf list hue; teeno
  micro-2 replica par push hue (push=OK). Isi din ke pehle do full
  backups (03:15 + 05:23 UTC) `status=OK` ke sath maujood hain.
  (Dump size 14.8 MB → 7.07 MB ki wazah: subah wali mode-repair
  lane ne cache/session tables clear kiye thay; dump ka footer +
  table count mukammal hai.)
- **Docker commit snapshot (asal rollback):** running web container
  ko commit karke `sendqon:pre-rebuild-20261119` =
  `sha256:308965546e4b…` (2.06 GB) — container layer plugins samet.
- File backups: `docker-compose.yml.bak-20261119-prerebuild`,
  `sendqon.yaml.bak-20261119-prerebuild`,
  `.env.bak-20261119-prerebuild` (panel dir mein).

## 3. Build — pehli koshish fail, PR-005, doosri kamyab

- **build5 FAIL (production untouched):** `npm run build` ka
  widget-frame step `UNRESOLVED_ENTRY` par gira —
  `app/Plugins/Channels/Widget/resources/js/widget/frame/main.tsx`
  maujood nahi. Root cause: vendor ke do build scripts
  (`scripts/build-widget-frame.mjs`,
  `scripts/build-telegram-store.mjs`) sirf `plugin.json` ki
  maujoodgi par trigger hote hain aur vendor ke paid plugins ke
  React sources ki tawaqqu rakhte hain. Hamare B4 Widget /
  Telegram Store plugins apna frame/storefront khud serve karte
  hain (koi vite build nahi). 2026-11-16 ki asal build mein ye
  plugins thay hi nahi, is liye steps khamoshi se skip hue thay
  (build4.log se sabit).
- **PR-005 (PATCH-REGISTER mein pehle entry, phir apply — register
  discipline):** dono scripts ki guard mein doosri `existsSync`
  shart: frame build sirf tab jab asal entry file bhi ho; store
  build sirf tab jab plugin ki apni `vite.config.ts` bhi ho.
  Har file mein 1 line. Vendor plugin sources ke sath aye to
  build bilkul asal jaisa chalega.
- **build6 SUCCESS:** image `sendqon:5.0.4-20261119` =
  `sha256:f16b16db32ada481c1dc403038759a813f68cfc9524a9f577f8e45c5a1de0a04`,
  size 2,038,145,147 B. Build route asal wali hi:
  `docker build --network=host -f ~/sendqon-build/Dockerfile
  ~/sendqon-build/src` (log: `~/sendqon-build/build6.log`).
- **Image ki swap se pehle jaanch (throwaway container):**
  plugin dirs 50 ✓; plugin files not-644 = 0, dirs not-755 = 0 ✓;
  **www-data ki haisiyat se har `plugin.json` readable (0
  unreadable)** ✓; lang/ur 7 files ✓; PR-003 PHP + compiled asset
  mein `Rs - PKR` ✓ (frontend ka `Rs` glyph ab is build se live);
  PR-004 files ✓; PR-005 guards dono scripts mein ✓; entrypoint
  executable + `storage:link` step ✓.

## 4. Swap

Pin teen jagah badla gaya (taake panel re-render pin revert na
kare):
1. `/var/serverkit/apps/sendqon/.env` mein `VERSION=5.0.4-20261119`
   add (pehle VERSION line thi hi nahi).
2. Rendered `docker-compose.yml` ke 4 image defaults
   `${VERSION:-5.0.4}` → `${VERSION:-5.0.4-20261119}`.
3. Panel template `/etc/serverkit/templates/sendqon.yaml`:
   `version: "5.0.4-20261119"` + 4 image defaults.
- `.serverkit-template.json` check kiya gaya: woh image pin NAHI
  karta (sirf template_id/template_version/variables) — is liye
  jaan boojh kar nahi chheera gaya.
- `docker compose config` se resolved images verify karke
  `docker compose up -d app reverb queue scheduler` chalaya gaya.
  **sendqon-db recreate NAHI hua.** Companions wale compose ko
  haath nahi lagaya gaya.

## 5. Post-verify — SAB PASS

- Containers: sendqon / queue / reverb / scheduler — chaaron image
  ID `sha256:f16b16db32ad…` par Up; db Up 2 days (untouched).
- Public: `/` 200, `/login` 200, branding logo
  `/storage/branding/logo-….png` 200.
- **www-data probe (naya web container, fresh process): 50/50
  plugins — slug|status|version baseline se IDENTICAL (zero
  difference), har plugin ki main class LOAD (NOLOAD=0).**
- **PR-004 live:** `CascadeAccess::installEnabled=true`;
  `NodeExecutorRegistry::resolve('action.cascade_send')` →
  `CascadeSendExecutor` (pre-fix ye NULL tha);
  `NodeTypeCatalog::all()` = 101 types, cascade shamil;
  `availableFor(admin)` = 98 types, cascade shamil (null owner par
  filter design ke mutabiq hata deta hai — code line 542).
- **Queue + scheduler ab plugin code chala rahe hain (pehli
  dafa):** queue log mein SimFleet `FleetTickJob` DONE + WaGuard
  `GuardTickJob` DONE swap ke foran baad; scheduler log mein
  `telegram:poll` + `sims:resume-carrier` DONE. Dono containers ka
  image ID nayi image wala verify kiya gaya.
- **PR-002 ab effective:** naye container mein `public/storage`
  symlink entrypoint ne khud bana liya
  (`-> /var/www/zender/storage/app/public`); `.env` entrypoint se
  materialise hua (16 lines); `php artisan about` saaf —
  Sendqon, Laravel 13.37.0, PHP 8.4.27, production, debug OFF.
- Urdu pack live container mein maujood (lang/ur, 7 files).
- **Companions untouched + healthy:** sendqon-whatsapp /
  sendqon-smpp Up 2 days (baqi companions ke uptime bhi
  unchanged). App-side `wa:health-check`: **2 servers, 2 healthy**
  (vendor Primary WhatsApp + Own Bridge). SMPP rows healthy
  (smpp-1 + Primary SMPP (Own)) — swap ke foran baad ki ek reading
  mein vendor WhatsApp row lamhati tor par `unhealthy` dikhi thi;
  companion log se sabit hua ke woh recreate window mein Reverb
  socket ka EOF/502 retry cycle tha, binary khud resubscribe kar
  gaya aur health-check cycle ke baad row bhi `healthy` hai.
  Kisi companion ke `work/` ko haath nahi lagaya gaya (licence
  tokens mehfooz).

## 6. Nayi durability halat + rollback

- **Ab saare own plugins (B1–B9) + Urdu pack + PR-003/PR-004/PR-005
  image `sendqon:5.0.4-20261119` ke andar pakke hain.** Web
  container ka koi bhi recreate (panel ya compose se) ab plugins
  nahi urraye ga; pin compose + panel .env + panel template —
  teenon jagah darj hai.
- Rollback (agar kabhi chahiye): (a) compose/.env/template pin
  wapas `5.0.4` karke `docker compose up -d` (purani image
  `5746721d3622` host par maujood hai — lekin us surat mein
  plugins sirf tab bachte hain jab container layer purani ho,
  is liye asal rollback (b) hai); (b) snapshot image
  `sendqon:pre-rebuild-20261119` (`308965546e4b…`) ko web service
  par laga kar recreate — us layer mein saare plugins swap se
  pehle wali halat mein hain. Dono images host par rakhi hain.
- Note: PR-005 ka patch abhi sirf host build tree mein hai;
  `~/sendqon-dev` (dev copy) ki agli image build se pehle wahan
  bhi mirror karna hoga — register entry is ki yaad-dehani hai.

## Appendix — Plugins baseline (pre-state = post-state, identical)

50 rows, www-data probe se dono dafa liye gaye. Active (37):
admin-api 1.0.0 · ai_agents 1.0.1 · ai_flow_builder 1.0.0 ·
android 5.0.4 · appointment_booking 1.0.0 · blesta 1.0.0 ·
browser_extension 1.0.1 · cascade 1.1.0 · clinics_pack 1.0.0 ·
ecommerce_pack 1.0.0 · email 1.0.7 · flarum 1.0.0 · gsm_modem 1.0.0 ·
legacy_importer 5.0.4 · mcp 1.0.0 · odoo 1.0.0 · osticket 1.0.0 ·
pbx 1.0.0 · perfex 1.0.0 · pta_mask 1.1.0 · push 1.0.0 ·
reseller_plus 1.0.0 · schools_pack 1.0.0 · shopify 1.0.0 ·
sim_fleet 1.0.0 · smpp 5.0.4 · sms_providers 1.0.0 ·
spam_score 1.1.0 · telegram 1.1.0 · telegram_store 1.0.2 ·
wa_guard 1.0.0 · waba 1.0.0 · waba_embedded_signup 5.0.4 ·
whatsapp 5.0.4 · whmcs 1.0.0 · widget 1.0.0 · wordpress 1.0.0.
Inactive by design (13): bank-transfer 1.0.0 · cryptocom 1.0.0 ·
easypaisa 1.0.0 · google_sheets 1.0.0 · hlr 1.1.0 · jazzcash 1.0.0 ·
knowledge_base 1.0.0 · paypal 1.0.0 · paystack 1.0.0 · raast 1.0.0 ·
razorpay 1.0.0 · stripe 1.0.0 · yookassa 1.0.0.
