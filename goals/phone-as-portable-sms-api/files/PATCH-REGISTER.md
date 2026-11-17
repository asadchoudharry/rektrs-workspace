# SENDQON — PATCH REGISTER (consolidated)

Har apni tabdeeli jo vendor ke core / deployment layer ko chhooti
hai, yahan darj hoti hai — taake vendor update (upstream Zender
**5.0.4**) aye to koi patch khamoshi se gum na ho. Discipline
`zender-rebuild-tree/05-INFRA.md` se: core files kam se kam change;
har change = entry yahan (file, wajah, diff summary, upstream
version); har patch host build tree (`~/sendqon-build/src/`,
offbox-1) mein mirror, taake agli image build mein zinda rahe.
Vendor update aye to har entry naye version par re-verify hogi —
jo patch upstream mein aa jaye, woh entry **absorbed** mark hogi.

Consolidated 2026-11-17 (B0 tyariyan,
`SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md` §2.4) — PR-001…
PR-003 purani lane reports se uthaye gaye; aage ke saare entries
yahin lagen ge.

| # | File(s) | Change (diff summary) | Reason | Upstream | Status |
|---|---|---|---|---|---|
| PR-001 | `docker-entrypoint.sh` (nayi file, image level) + container start par materialize honay wali `.env` | Entrypoint generated `.env` mein `TRUSTED_PROXIES=*` pin karta hai (16 keys ki list mein shamil). Koi vendor PHP source edit NAHI hua — `bootstrap/app.php` pehle se `trustProxies(at: env('TRUSTED_PROXIES', '*'), headers: X-Forwarded-*)` register karta hai; value sirf explicitly pin ki gayi. | Install-era `http://` redirect ka root cause: prepended `BootstrapInstallation` middleware proxy-trust se pehle jawab deta tha. Pin ke baad URL generation Caddy/Cloudflare ke peeche hamesha https rehti hai, env default badalne par bhi. Evidence: `GET /messenger` + `/admin` → `Location: https://sendqon.rektrs.com/login`. | 5.0.4 | Live (image `5746721d3622` se); source: `ZENDER-PLUGINS-SETTLE-REPORT-2026-11-16.md` §6 |
| PR-002 | `files/serverkit/Dockerfile` + `docker-entrypoint.sh` | (a) Entrypoint naya: container start par `.env` materialize (missing ya `DB_PASSWORD` na ho tab; mojooda achhi `.env` kabhi overwrite nahi), app-root/`public/`/`database/` ki `www-data` 775 ownership dobara apply. (b) Dockerfile mein wahi ownership build time par bake + entrypoint `COPY`/`ENTRYPOINT`. (c) **Extension (2026-11-16, email-logo lane):** entrypoint `public/storage` symlink missing ho to `php artisan storage:link` se dobara banata hai (guarded step, `exec` se pehle) — symlink container layer mein rehta hai aur recreate par gum ho jata tha, jis se saari `/storage/*` URLs 404 hoti theen. | Installer writability fix + haath se likhi `.env` ki durability recreates ke paar; (c) branding/logo URLs ka 404 root cause khatam karna. App-source change NAHI — deployment layer only. **Caveat:** (c) agli image build se effective hai; us se pehle ke recreate par one-command remedy wohi `php artisan storage:link` hai. | 5.0.4 | Live (a, b); (c) build tree + goal files + dono repos mein patched, agli image build ki muntazir; source: `ZENDER-PLUGINS-SETTLE-REPORT-2026-11-16.md` §5–6, `ZENDER-EMAIL-LOGO-REPORT-2026-11-16.md` |
| PR-003 | `app/Support/Currencies.php` + `resources/js/lib/currency.ts` | `Currencies::KNOWN` mein `'PKR'` add; `SYMBOLS` mein `'PKR' => 'Rs'`; TS `CURRENCIES` mein PKR entry (label `Rs - PKR`). Diff kul 3 lines (PHP 2 + TS 1 block). | Upstream 5.0.4 ki currency list mein PKR hai hi nahi — baghair patch ke `Currencies::code()` har PKR setting ko khamoshi se USD par gira deta aur admin Settings UI PKR reject karti. Site currency PKR karne ke liye lazmi tha. | 5.0.4 | Live (host build tree + live container dono mein, PHP lint saaf); live frontend abhi Intl fallback se "PKR" render karti hai, `Rs` glyph TS entry wali build se aye ga; source: `SENDQON-PKR-PRICING-PROPOSAL-2026-11-16.md` |

## Register rules (aage ke liye)

1. Kaam se PEHLE entry: file(s), wajah, diff summary, upstream
   version.
2. Patch host build tree mein mirror + agli image build ki
   checklist mein shamil.
3. Vendor update par: har entry re-verify; upstream mein aa jane
   wali entry "absorbed" mark ho.
4. Plugin ke andar ki tabdeeli register mein NAHI aati — woh plugin
   ki apni history hai. Register sirf core/deployment-layer touches
   ke liye hai.
