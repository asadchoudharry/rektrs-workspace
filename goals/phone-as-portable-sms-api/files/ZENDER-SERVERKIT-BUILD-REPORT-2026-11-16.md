# ZENDER × SERVERKIT — BUILD REPORT (2026-11-16)
Build lane, owner PROCEED ke baad. Design: `ZENDER-SERVERKIT-DEPLOY-DESIGN-2026-11-16.md`.
Server: offbox-1 (ARM64, Ubuntu 24.04). Panel/Caddy/host config ko haath nahi lagaya;
saara kaam `~/sendqon-build/` aur Docker images ke andar raha.

## 1. Source transfer — ✅ verified byte-exact
- Local `~/workspace/zender-branches/app/` → server `~/sendqon-build/src/`.
- **rsync server par installed nahi tha** (aur package install scope se bahar
  tha), is liye transfer **tar-over-SSH** se hua, `.git` exclude karke.
- Verification: dono taraf **26,798 files** aur **305,573,798 bytes** — exact match.
  Server par `.git` nahi gaya; `vendor/autoload.php`, `artisan`, `.version` (5.0.4) maujood.

## 2. Dockerfile — decisions
File: `files/serverkit/Dockerfile` (server par `~/sendqon-build/Dockerfile`).
- **Stage 1** `node:22-bookworm-slim`: poora source copy, `npm ci && npm run build`
  (build script: manifests + tsc + vite + widget builds), phir `node_modules` delete.
- **Stage 2** `php:8.4-fpm-bookworm` (Debian): nginx + supervisor + ffmpeg +
  extensions **autosetup wali list** — pdo_mysql, mysqli, mbstring, xml, curl,
  zip, bcmath, gd (freetype+jpeg configure karke), intl, opcache —
  `docker-php-ext-install` se; Composer official image se copy.
- **vendor/**: source mein complete ship hota hai — build mein autoload verify
  hua ("vendor/ verified: autoload OK"), is liye **composer install skip** hua
  (Dockerfile mein fallback maujood hai agar kabhi autoload fail ho).
- Stage 2 poora app tree stage 1 se leta hai (taake build ki har generated file
  — public/build, widget outputs — sath aaye). WORKDIR `/var/www/zender`
  (vendor layout mirror).
- **FPM limits** `conf.d/zender.ini` mein: upload/post **128M**, memory **512M**,
  max_execution 120s (autosetup pool parity). Deviation note: autosetup ye
  values FPM pool ke `php_admin_value` mein rakhta hai; image mein php.ini
  values hain — FPM par laagu hoti hain, farq sirf itna ke pool-level admin
  lock nahi hai.
- **nginx** (container ke andar, port 80): autosetup vhost ka simplified
  faithful version — front-controller, sirf `index.php` execute, baqi `.php`
  404, `/storage/` mein script extensions deny, dotfiles deny, security
  headers, 128M body, `/build/assets/` 1y cache. **Deviation:** Reverb proxy
  paths (`/app/`, `/apps/…`) yahan nahi hain — design ke mutabiq woh host
  Caddy se reverb service ko jayenge.
- **Supervisor** app container mein nginx + php-fpm chalata hai. Reverb /
  queue / scheduler compose mein alag services hain (wahi image, apne commands).

## 3. Build — ✅ success (2nd attempt)
- Pehli koshish **fail**: BuildKit ke default bridge network se
  `deb.debian.org` nahi mila — host ka DNS usay sirf **IPv6** par resolve
  karta hai aur container bridge mein IPv6 nahi hai (host par curl 200,
  container mein timeout). npm registry chal gaya tha (IPv4), sirf apt atka.
- Fix: **`docker build --network=host`** — build steps host network par,
  apt theek chal gaya. (Runtime containers par is ka koi asar nahi; ye sirf
  build-time flag hai. Template lane note kare: panel agar khud build kare
  to yehi masla ayega — lekin hamari image pehle se bani hui hai, panel ko
  build nahi karna.)
- **Image: `sendqon:5.0.4` — ID `c84854b14900`, size 2.01 GB.**
- Logs: `~/sendqon-build/build.log` (fail), `build2.log` (success).

## 4. Smoke test — ✅ pass (throwaway container, baad mein removed; ab 0 containers)
- `php -v` → **PHP 8.4.27**.
- Extensions maujood: bcmath, curl, gd, intl, mbstring, mysqli, pdo_mysql,
  xml, zip, **Zend OPcache**.
- `nginx -t` → successful.
- `php artisan --version` → **Laravel Framework 13.37.0**.
  - `.env` ke baghair: ek harmless deprecation warning
    (`config/filesystems.php:44` — rtrim(null), APP_URL khali hone par)
    ke sath version print hua.
  - `.env.example` se minimal `.env` banane par: saaf **Laravel Framework
    13.37.0**, koi warning nahi.
- Koi migration nahi chalayi, koi DB connect nahi hua (design ke mutabiq
  woh install step hai).

## 5. Template registration — ✅ code se jawab mil gaya (koi index/DB/restart nahi)
Panel backend `/opt/serverkit/backend` parh kar:
- **`app/services/template_catalog.py`** — `TemplateCatalogMixin.list_local_templates()`:
  dono directories ko **har request par `os.scandir`** se scan karta hai —
  `TEMPLATES_DIR` pehle, phir `LOCAL_TEMPLATES_DIR`. Parse results sirf
  (mtime_ns, size) par memoize hain: **nayi ya badli hui file agli listing
  par khud pick ho jati hai.**
- **`app/paths.py:14`** — `TEMPLATES_DIR = $SERVERKIT_CONFIG_DIR/templates`
  (default `/etc/serverkit/templates` — server par maujood hai);
  `template_service.py:37` — `LOCAL_TEMPLATES_DIR = <backend>/templates`
  (bundled 121 templates wali jagah).
- **`template_catalog.py` `get_template()`** (line ~497): install ke waqt
  `<id>.yaml` **seedha file se** parhta hai — pehle config dir, phir bundled.
- **`index.json` install path mein istemal hi nahi hota**: woh sirf
  `build_repo_index()` se banta hai taake bundle ko remote template repo
  ke tor par publish kiya ja sake. Local catalog usay nahi parhta.
- **Natija: `sendqon.yaml` ko `/etc/serverkit/templates/` (operator dir —
  bundled par precedence rakhta hai) ya `backend/templates/` mein rakhna
  hi kafi hai. Na index regenerate, na DB import, na panel restart.**
  Ek caveat: `get_template` mein provider-owned templates ka gate hai
  (`PROVIDER_OWNED_TEMPLATES`) — `sendqon` naya id hai, us par laagu nahi.

## 6. Template draft — ✅ likha, panel mein NAHI dala
- `files/serverkit/sendqon.yaml` — BookStack format par: 5 services
  (`db` mysql:8; `app`, `reverb`, `queue`, `scheduler` — chaaron
  `sendqon:${VERSION:-5.0.4}`), variables (HTTP_PORT hidden port,
  APP_URL, DB_PASSWORD `generate: password`), volumes
  (`sendqon_storage`, `sendqon_db`), requirements **memory 4GB / storage 20GB**.
- Reverb sirf **127.0.0.1:${REVERB_PORT:-18080}** par publish hai — public
  WSS rasta host Caddy se ayega (design ke mutabiq).
- `post_install` mein one-time init steps likhe hain: key:generate,
  migrate --seed (CHANNEL_PLUGINS_CORE_ONLY=1), channel-plugins:sync,
  configure-realtime, storage:link, phir web installer.
- Draft decisions jo template lane confirm kare: (a) MySQL root password
  abhi wohi generated `${DB_PASSWORD}` hai (BookStack pattern) — alag
  variable chahiye to badla ja sakta hai; (b) APP_KEY template variable
  nahi hai — woh post-install `key:generate` se banta hai (design step 5
  ke mutabiq); (c) icon URL placeholder hai (serverkit.ai par sendqon icon
  maujood hona confirm nahi).

## Blockers / baqi kaam
- Is lane ka koi blocker nahi. Agle steps design ki sequence par hain:
  template file panel ke templates dir mein rakhna (template lane),
  owner gate (panel first-admin + `sendqon.rektrs.com` DNS), phir panel se
  install → init steps → Caddy block → verification battery.
- Note: runtime containers ke liye bhi wahi IPv6/DNS wali baat zehen mein
  rahe — app ko bahar sirf APIs (Meta/SMTP waghera) chahiyein; agar kisi
  endpoint ka sirf IPv6 mile to container se nahi pahunchega. Install ke
  baad ki verification battery mein ye check shamil rakha jaye.
