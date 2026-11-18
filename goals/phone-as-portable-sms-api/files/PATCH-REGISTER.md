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
| PR-004 | NAYI `app/Services/Cascade/CascadeAccess.php` + `app/Services/Flow/NodeTypeCatalog.php` (2 hunks) + `app/Providers/FlowServiceProvider.php` (1 block) | (a) Nayi `CascadeAccess` class — vendor ke `AiAgentsAccess`/`BookingAccess` pattern ki copy: `SLUG='cascade'`, `NODE_TYPES=['action.cascade_send']`, `installed()` = plugin manifest ki file check, `installEnabled()` = installed + PluginManager active, `nodes()` = plugin ki `CascadeNodes` class ka naam. (b) `NodeTypeCatalog::pluginEntries()` mein ek line: `...(CascadeAccess::installed() ? CascadeAccess::nodes()::entries() : [])`; aur `availableFor()` mein BookingAccess-style filter: plugin active na ho to cascade node types palette se hata do. (c) `FlowServiceProvider` ke NodeExecutorRegistry singleton mein maujooda conditional blocks ke sath ek block: `if (CascadeAccess::installed()) { foreach (CascadeAccess::nodes()::executors() as $executor) { $registry->register($executor); } }`. Kul diff: 1 nayi file (~50 lines) + ~9 lines edits. **Rollback:** teeno hunks revert + `CascadeAccess.php` delete — plugin apni HTTP endpoint wali pre-fix halat par wapas. | Apna Cascade plugin channel plugin NAHI hai (type `integration`, core ke `ChannelPlugins` maps mein slug maujood nahi), is liye `ChannelRuntimeRegistry::refresh()` — jo sirf channel plugins ke `registerRuntime()` se rebuild hota hai — is ka flow executor kabhi carry nahi kar sakta, aur `NodeTypeCatalog` mein non-channel plugin nodes ka koi merge point nahi. Vendor ke apne non-channel plugins (Google Sheets, Bookings, AI Agents, Commerce) bilkul isi Access-class pattern se wired hain; PR-004 usi pattern ki cascade ke liye copy hai — is se chhota koi core touch mumkin nahi jo editor palette + validation + execution teeno asal raaston se kaam kare. Evidence (dev battery): fresh-process `NodeExecutorRegistry::resolve('action.cascade_send')` non-null; `availableFor()` mein node maujood; dev flow end-to-end execute. | 5.0.4 | **APPLIED + LIVE (2026-11-18, UI-fixes lane):** dev battery 13/13 (fresh-process resolve, catalogue gating, dry run + asal run — WhatsApp refused → SMS accepted, attempts logged); production web container mein teeno files applied (prod originals build tree se byte-identical thay — md5-verified), fresh-process probe: executor resolve + node catalogue mein maujood; build tree `~/sendqon-build/src` mein baked (agli image build se queue/scheduler containers ko bhi milega — maujooda topology mein plugin code sirf web container mein chalta hai, B1–B4 se yahi chala aa raha hai). Sath plugin-side executor fix (register mein nahi — plugin history): `CascadeSendExecutor` ab tenant `$run->flow->user_id` se leta hai (`$run->user_id` dispatcher runs par khali hota hai — B4 ka latent bug, node pehle kabhi asal run mein chala hi nahi tha). Source: `SENDQON-UI-FIXES-REPORT-2026-11-18.md` §2 |

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
