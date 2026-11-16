# Sendqon — Free Plugins Settle Report (2026-11-16)

**Scope:** install the 5 claimed free plugins into the LIVE Sendqon (Zender 5.0.4) app on offbox-1, stage the WhatsApp/SMPP companion binaries, and make the whole install durable across container recreates (image rebuild + panel-route recreate + full verification).

**Result: COMPLETE.** All 5 plugins are installed **and active** in the live app; the install survived a full image rebuild + recreate with every check green. No licence check was bypassed, no licence code was invented or entered — the licence map in §4 tells the owner exactly where each real code goes.

---

## 1. Mechanism used (the vendor's own)

From the core source (`app/Services/PluginManager.php`, `app/Http/Controllers/Admin/PluginController.php`, Lane 5):

- A plugin is a directory under `app/Plugins/<TypeDir>/` holding `plugin.json` + its main class. Type map: `channel → Channels`, `sms_provider → SmsProviders`, `waba_provider → WabaProviders`, `tool → Tools`, etc.
- The admin UI's **Plugins → Upload** path calls `PluginManager::installFromZip()`: it validates the manifest, extracts the package into the type directory, runs any manifest-declared migrations in place, and creates the `plugins` DB row (status `inactive`). Activation is `PluginManager::activate()` (the UI's toggle), which enforces parent plugins and `isConfigured()`.
- This lane drove **exactly that code path** from artisan tinker (`installFromZip()` with an `UploadedFile`, then `activate()` per slug) — no hand-written DB rows, no file copying into the live container outside the manager. `php artisan channel-plugins:sync --all` was run afterwards as the vendor's own reconciliation pass: exit 0, no changes (all rows already existed).
- Parent requirements were already satisfied by the bundled core channel plugins: `sms_providers` (parent of SMPP) and `waba` (parent of WhatsApp Embedded Signup) were installed + active from the core install.

## 2. Per-plugin end state

| Plugin | Slug | Type | Package md5 (plugin.zip) | End state |
|---|---|---|---|---|
| Android Gateway | `android` | channel (sms) | `6439561107085ae67df7c6e2d3e80c7c` | **Installed + Active** (v5.0.4) |
| WhatsApp (QR) | `whatsapp` | channel (wa) | `dd37e3b6c91976c19118db521fba3945` | **Installed + Active** (v5.0.4); companion binary staged, **not started — licence code required** (§3) |
| SMPP | `smpp` | sms_provider | `62a1cf999a772e15222938643aa82131` | **Installed + Active** (v5.0.4); companion binary staged, **not started — licence code required** (§3) |
| WhatsApp Embedded Signup | `waba_embedded_signup` | waba_provider | `ea837daf68411d7f52bc87d09e8ad3fa` | **Installed + Active** (v5.0.4) |
| Legacy Importer | `legacy_importer` | tool | `bc7d934c56f2f8c63f371eaa016648f8` | **Installed + Active** (v5.0.4); its migration ran — 9 `legacy_import_*` tables created and the migration recorded on the plugin row |

All five `isConfigured()` implementations return `true`, so activation needed no settings first. Plugin rows after the lane (read-only proof from the DB): `android, legacy_importer, smpp, sms_providers, waba, waba_embedded_signup, whatsapp` — **all `active`**.

**Owner clicks still needed for the plugins themselves: none.** Activation is done. Remaining owner actions are only the licence/server steps in §4 and the follow-ups in §6.

## 3. Companion binaries (WhatsApp / SMPP servers)

- The binaries are single static ARM64 ELF executables (this host is ARM64). Staged — **not executed, no config written**:
  - `/var/serverkit/apps/sendqon/servers/whatsapp/titansys-whatsapp-arm64` — 48,234,622 B, md5 `ff2e66ecb3882df45b62f14793911f18` (byte-identical to the claimed package)
  - `/var/serverkit/apps/sendqon/servers/smpp/titansys-smpp-arm64` — 13,893,758 B, md5 `c98d306a0d98490ed7d18b22a35c30df` (byte-identical)
- Verified no `titansys` process is running. The binaries are started only after a service server exists in the admin panel and its generated `config.json` carries the real licence code (§4). Starting them before that is pointless by design: the vendor's server refuses to start while the config still holds a placeholder.

## 4. Licence map — where each code goes (owner enters the real codes)

No admin-UI field exists for the per-plugin codes anywhere in the PHP app (searched); they live **only** in the generated server `config.json`. The core purchase code is the opposite: a Settings field only.

### 4.1 Core purchase code (the Zender licence itself)
- **Where:** Admin → **Settings** (`/admin/settings`) → **General** group → field **“Purchase Code”** (`purchase_code`). Source: `Admin\SettingsController` FIELD_META (`general` group), listed in `ENCRYPTED_KEYS` — stored encrypted in `system_settings`.
- **What it does:** identifies this installation to the vendor's error-reporting ingest — `SentryReporterService` attaches it to reports **only when Error Reporting (`sentry_enabled`) is on**. It gates nothing else in the core; the app runs fully without it.
- **Server creation:** unaffected — service servers can be created with or without it.

### 4.2 WhatsApp plugin licence code
- **Where:** Admin → **Service Servers → WhatsApp** (`/admin/service-servers/whatsapp`) → create a server (the form asks only for **base URL** and **capacity** — `WhatsappServerKind::settingsRules()`). The server's page then shows its generated **`config.json`** (`ServiceServerController` passes `configJson` to the view), shaped as:
  `{"purchase_code": "REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE", "server": {"host": …, "port": 8899, "service_token": "<real per-server token>"}, "laravel": {"url": "https://sendqon.rektrs.com"}}`
- **The step that applies the licence:** replace the `purchase_code` placeholder value in that config.json with the **WhatsApp plugin licence code from the vendor portal claim**, save the file next to the staged binary (`/var/serverkit/apps/sendqon/servers/whatsapp/`), then start the binary (ops follow-up, deliberately not done in this lane).
- **Can a service server be created before the code exists? YES.** Creation never asks for the code; only the binary's start is gated — it refuses to run while the placeholder (or the token placeholder) is still in config.json.

### 4.3 SMPP plugin licence code
- **Where:** Admin → **Service Servers → SMPP** (`/admin/service-servers/smpp`) → create a server (base URL + capacity only, `SmppServerKind::settingsRules()`). Generated `config.json`:
  `{"purchase_code": "REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE", "server": {"host": …, "port": <from base URL>, "debug": false, "service_token": "<real per-server token>"}, "laravel": {"url": "https://sendqon.rektrs.com"}, "storage": {"dir": "storage"}}`
- **Apply step:** identical pattern — replace the placeholder with the **SMPP plugin licence code from the vendor portal claim**, place beside `/var/serverkit/apps/sendqon/servers/smpp/titansys-smpp-arm64`, then start.
- **Can a service server be created before the code exists? YES** — same as WhatsApp; only the binary start is gated.

### 4.4 For completeness — Telephony (GSM Modems / Phone Bridge)
Not part of this lane's five plugins, same pattern when those are ever claimed: `TelephonyServerKind` generates its config with `purchase_code: REPLACE_ME_WITH_GSM_MODEMS_OR_PHONE_BRIDGE_LICENSE_CODE` (and a separate service-token placeholder).

## 5. Durability changes (why this survives recreates)

Before this lane, the plugins and the installer's `.env` lived only in the web container's writable layer — any recreate would have wiped both. Fixed at image level:

1. **Plugins baked into the build tree:** the 5 extracted packages now sit in `~/sendqon-build/src/app/Plugins/` (`Channels/Android`, `Channels/Whatsapp`, `SmsProviders/Smpp`, `WabaProviders/EmbeddedSignup`, `Tools/LegacyImporter`), so every rebuild ships them. Their DB rows + Legacy Importer tables live in the `sendqon_db` volume.
2. **Entrypoint (`docker-entrypoint.sh`, new):** on every container start it
   - materializes `/var/www/zender/.env` from the container's own env vars **when the file is missing or lacks a `DB_PASSWORD`** (keys: APP_NAME, APP_ENV, APP_KEY, APP_DEBUG, APP_URL, LOG_LEVEL, DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD, CACHE_STORE, QUEUE_CONNECTION, SESSION_DRIVER, TRUSTED_PROXIES) — an existing good `.env` is never overwritten (both branches probe-tested before the rebuild);
   - re-applies the writability fixes (below), then `exec "$@"` so web/reverb/queue/scheduler all pass through it.
3. **Dockerfile (files/serverkit/Dockerfile):** bakes the same writability at build time — app root directory entry, `public/` and `database/` owned by `www-data` (775) — plus `COPY` of the entrypoint and `ENTRYPOINT ["/usr/local/bin/sendqon-entrypoint.sh"]` ahead of the existing supervisord `CMD`.
4. **Safety copies taken before any change:** live `.env` → `/var/serverkit/apps/sendqon/.env.live-backup` (mode 600, md5-identical to the live file at copy time); full DB dump → `/var/serverkit/apps/sendqon/db-backup-pre-plugins-20261116.sql.gz` (945,638 B).

Rebuild + recreate were then executed: `docker build --network=host -f Dockerfile -t sendqon:5.0.4 src` (new image `5746721d3622`, 2.03 GB) and the panel route `cd /var/serverkit/apps/sendqon && docker compose up -d`.

## 6. Patch register

| # | File | Change | Reason |
|---|---|---|---|
| PR-001 | `docker-entrypoint.sh` (new) + materialized `.env` | Pins `TRUSTED_PROXIES=*` in the generated `.env` | `bootstrap/app.php` already registers the framework's own `$middleware->trustProxies(at: env('TRUSTED_PROXIES', '*'), headers: X-Forwarded-For/Host/Port/Proto)` — **no vendor source was edited**; the value is pinned explicitly so URL generation stays https behind Caddy/Cloudflare even if the env default ever changes. Root cause of the install-era http:// redirect: the prepended `BootstrapInstallation` middleware answered before proxy trust applied, and only until the install completed. Post-install evidence: `GET /messenger` and `/admin` on the public URL now return `Location: https://sendqon.rektrs.com/login`. |
| PR-002 | `files/serverkit/Dockerfile` + `docker-entrypoint.sh` | Entrypoint added; app-root/public/database ownership baked | Durability of the installer writability fix and of the hand-written `.env` (§5). Not an app-source change. |

No other source files were modified. The vendor trees (`zender-branches/*`) remain pristine.

## 7. Verification evidence (post-recreate, ≥60 s stable)

- Containers: `sendqon`, `sendqon-queue`, `sendqon-reverb`, `sendqon-scheduler` Up on the new image, **RestartCount 0** each; `sendqon-db` untouched (data volume preserved).
- `https://sendqon.rektrs.com/` → **200**; `/login` → 200; `/messenger` and `/admin` → 302 with **`Location: https://sendqon.rektrs.com/login`** (https, not http).
- `storage/installed.marker` present in the fresh web container.
- Users count still **1** (the owner's admin).
- Plugins in the fresh container: all 7 rows **active**; all 5 plugin directories present in the image.
- Fresh container's `.env`: materialized by the entrypoint with all 16 keys, `DB_PASSWORD` populated (value never printed).
- Queue is processing real jobs after the recreate (log shows `WakeSnoozedConversationsJob` / `FlagSlaBreachesJob` → DONE).
- Entrypoint pre-tests on the previous image: missing-`.env` branch writes all keys; existing-`.env` branch leaves the file byte-identical (md5 match).
- Package integrity: all 5 plugin zips and both ARM64 binaries md5-identical between this VM and offbox-1.

## 8. UNVERIFIED / owner follow-ups (labelled honestly)

- **UNVERIFIED — binary start with a real licence code:** not attempted (no codes held by this lane, none invented). The refusal-to-start-with-placeholder behaviour is from the vendor's own source comments + Lane 6 findings, not from a live run.
- **UNVERIFIED — admin UI eyeball:** plugin states were proven via DB + artisan + filesystem, not by opening Admin → Plugins in a browser.
- **Android Gateway use** still needs the gateway phone app (the separate buyer-portal app bundle, not part of the plugin zip) and, for instant delivery, a Firebase project (Admin → Settings group `firebase_android`). Plugin side is ready.
- **Embedded Signup use** still needs the Meta app values (config ID etc.) in the plugin's settings before a live WABA onboarding can run. Plugin side is ready.
- **Licence codes themselves** (core purchase code, WhatsApp, SMPP) are entered by the owner per §4 — the codes the Rektrs purchase/claims already hold; the custom-licence negotiation with Titan Systems is a separate owner thread and nothing in this lane depends on its outcome for the plugins' installed/active state.
