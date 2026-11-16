# AUTOSETUP SCRIPT REVIEW — `Install/autosetup.sh` (parha gaya 2026-11-16)

File: `zender-package/Install/autosetup.sh` = `zender-branches/app/autosetup.sh`
(md5 dono ka ek: 265d27ac…). **1,074 lines**, bash, `set -euo pipefail`.
Owner ki hidayat par chalane se pehle poora parha gaya. Natija neeche hai.

## Pehchan
- "Zender v5.0 one-shot installer" — fresh **Ubuntu 24.04** ke liye.
- **Idempotent + resume-aware**: har step ka checkpoint `/var/lib/zender/setup-state`
  mein; dobara chalane par mukammal steps skip ho jate hain.
- Flags: `--dry-run` (sirf print), `--skip-ssl`.
- Env inputs: `DOMAIN`, `CF_API_TOKEN`, `CERTBOT_EMAIL`, `ADMIN_EMAIL`.

## 17 steps — kya karte hain
1. **apt_update** — cloud-init khatam hone ka intezar + apt lock timeout (600s),
   30 koshishon tak retry.
2. **system_packages** — nginx, **mysql-server**, certbot + Cloudflare/nginx
   plugins, supervisor (install hota hai, istemal nahi hota), **ffmpeg**
   (voice notes WebM→Ogg conversion ke liye), git/curl/unzip.
3. **php** — ondrej PPA se **PHP 8.4** + extensions (mysql, mbstring, xml,
   curl, zip, bcmath, gd, intl, opcache) + Composer (getcomposer.org se).
4. **node** — NodeSource se **Node 22** (frontend build ke liye).
5. **zender_user** — `zender` system user, home `/var/www/zender`.
6. **php_pool** — dedicated FPM pool `zender` user par; upload/post **128M**,
   memory 512M, max_execution 120s (wajah comments mein: Meta ka 100MB
   document limit).
7. **database** — MySQL mein `zender` DB + user, random password →
   `/var/lib/zender/db-credentials` (chmod 600).
8. **app_deploy** — ⚠️ **sirf folder banata + chown karta hai.** Code deploy
   NAHI karta; comment: "we assume the admin has rsynced the release package."
   → Install plan mein script se pehle **package rsync ka step lazmi** hai.
9. **env_file** — .env configure: APP_KEY generate, **APP_ENV=production,
   APP_DEBUG=false, LOG_LEVEL=error**, SESSION_SECURE_COOKIE (SSL ho to),
   DB_CONNECTION=mysql + credentials, JWT_SECRET random, cache/queue =
   database. Aakhir mein .env **chown zender + chmod 640**.
   (Comments batate hain ye fixes kyun hain: pehle debug mode mein poora
   environment error page par leak hota tha; DB sqlite par reh jati thi.)
10. **app_bootstrap** — composer install → `migrate --force --seed`
    (CHANNEL_PLUGINS_CORE_ONLY=1) → channel-plugins:sync → Reverb settings
    DB mein (zender:configure-realtime; browser ke liye domain:443/https,
    internal 127.0.0.1:8080) → storage:link → `npm ci && npm run build`.
    Seed ka nuqta: production mode mein UserSeeder demo admin
    (admin@example.com/"password") NAHI banata — guard maujood hai.
11. **admin** — `zender:install-admin` se admin banta hai; email =
    ADMIN_EMAIL ya `admin@<domain>`; **password random generate** hota hai →
    `/var/lib/zender/admin-credentials` (600) + script ke aakhir mein screen
    par print. Web installer ki zaroorat nahi.
12. **reverb** — systemd unit; bind sirf **127.0.0.1** (port settings se).
13. **queue_worker** — systemd unit: `queue:work --tries=3 --timeout=300`.
14. **scheduler** — zender user ke crontab mein `schedule:run` har minute;
    duplicate-entry guard ke sath.
15. **nginx** — vhost `default_server` catch-all (workspace subdomains/custom
    domains ke liye), security headers `always`, client_max_body_size 128M,
    Reverb proxy `/app/` + `/apps/…` API paths, sirf `index.php` execute,
    `/storage/` mein script extensions deny, default site **hata deta hai**.
16. **custom_domains** — tenant custom domains ke SSL ke liye root-owned
    helper scripts (`zender-certbot`, `zender-nginx-site`) + bohat tang
    sudoers (zender user sirf in helpers + `nginx -t`/`reload` chala sakta
    hai); sudoers visudo se validate, fail ho to file hata deta hai.
17. **ssl** — Let's Encrypt: DOMAIN ho to webroot cert; **CF_API_TOKEN ho to
    wildcard** (`domain` + `*.domain`) Cloudflare DNS se. Fail ho to site
    HTTP par rehti hai aur warning deta hai, install nahi rukta.

## Phone-home / bahar rabta — AUDIT
Script mein **koi vendor endpoint nahi**. Bahar sirf ye jata hai:
Ubuntu apt repos, ondrej/php PPA, deb.nodesource.com, getcomposer.org,
Let's Encrypt. Koi titansys.dev call nahi. (App ke andar wala Sentry mamla
alag hai — woh default off hai, install plan mein OFF rakhna darj hai.)

## offbox-1 (ARM) ke liye khaas nataij
- **ARM rukawat nazar nahi ayi**: script koi prebuilt binary install nahi
  karta — sab apt packages hain (ARM builds maujood), Node NodeSource ARM
  deta hai, Composer PHP hai. WhatsApp Go binary script ke header mein
  saaf likha hai: woh **alag se deploy** hota hai, installer use chhoota
  hi nahi.
- ⚠️ **nginx takrao**: script nginx install karke khud default_server ban
  jata hai aur default site hata deta hai. offbox-1 par pehle se koi web
  server (Caddy waghera) 80/443 par ho to takrao hoga → **pre-flight
  inventory is liye lazmi hai** (install plan step 3.1).
- ⚠️ **MySQL root**: install ke baad `sudo mysql` bina password khulta hai
  (socket auth — aam Ubuntu tarz). Baad mein sakht karna hardening list mein.
- ⚠️ Script **fresh host farz** karta hai: mysql-server pehle se laga ho ya
  port ghira ho to steps atak sakte hain — checkpoints ki wajah se resume
  mumkin hai.
- Queue sirf **ek worker process** hai; load barhne par baad mein barhana hoga.

## Install plan mein tabdeeli (is review ki roshni mein)
1. Autosetup se pehle **package rsync step** add: Install/ ka content
   `/var/www/zender` mein pehle se rakhna hai.
2. Admin password owner browser mein nahi dalega — script generate karke
   `/var/lib/zender/admin-credentials` mein rakhta hai. **Muse woh password
   chat mein nahi layega**: owner khud server par file parh kar pehla login
   karega aur foran password badlega (yeh owner step hai).
3. **Wildcard SSL ke liye CF_API_TOKEN** chahiye (warna sirf main domain ka
   cert, workspace subdomains HTTP). Token sirf rektrs.com zone ke DNS-edit
   tak mehdood ho; woh bhi owner apne pas se dega/server par dalega.
4. Baqi plan (backup, verification battery, Kuma) wesay ka wesa laagu hai.

## Faisla
Script **bharosay ke qabil** hai: comments mein har ghair-mamooli faislay ki
wajah likhi hai, purani vendor ghaltiyon (debug leak, sqlite default, seed
backdoor) ke fixes nazar ate hain, idempotent hai aur credentials hamesha
600/640 permissions par rakhta hai. **Tajweez: isi ko chalaya jaye** —
pre-flight + package rsync + pehle `--dry-run` karke output ka jaiza,
phir asal run.
