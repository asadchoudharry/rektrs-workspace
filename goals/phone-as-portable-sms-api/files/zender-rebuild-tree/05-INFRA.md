# 05 — INFRASTRUCTURE

Sources: Lane 2 (docs), Lane 4 (demo), Lane 5 §§1–2, 12.

## Server requirements

- PHP **8.4.1+** (installer refuses older). Extensions: pdo_mysql/
  pdo_sqlite, mbstring, openssl, curl, gd, zip, bcmath, intl, xml.
  `proc_open` required. upload/post ≥ 128M.
- MySQL 8 / MariaDB (InnoDB) for production; SQLite is trial-only.
  MySQL FULLTEXT is word-prefix only ("sm" ≠ "smith") — search behaviour
  to remember when debugging contact/message search.
- `storage/` + `bootstrap/cache` writable; ffmpeg on the host (voice-note
  transcoding, `FFMPEG_PATH`).
- Shared hosting is a degraded mode (docs say so themselves): no Reverb
  (Pusher required), no channel companion servers, no custom Messenger
  domains, Android long-polling fights process limits, campaigns slow.
  **Our deployment: VPS only.**

## VPS Auto Setup anatomy (`Install/autosetup.sh`, Ubuntu 24.04)

`DOMAIN=… bash autosetup.sh`; flags `CF_API_TOKEN`, `CERTBOT_EMAIL`,
`ADMIN_EMAIL`, `--skip-ssl`, `--dry-run`. It installs:

- Fixed path `/var/www/zender`, system user `zender`
- nginx (public/ web root; `/app` and `/apps/<id>/` proxied to Reverb)
- MySQL, certbot (Let's Encrypt or Cloudflare wildcard SSL)
- PHP 8.4 FPM: 128M upload, 512M memory, 120s timeout
- Node 22, supervisor, ffmpeg
- DB credentials at `/var/lib/zender/db-credentials`; generated admin
  password at `/var/lib/zender/admin-credentials`
- Two supervisor services: **zender-queue** and **zender-reverb**
  (Reverb bound to loopback; public traffic via nginx proxy)

We use this script as the deployment checklist even if we install
manually; every deviation goes in the patch register.

Web installer (alternative): 4 steps — Requirements → Database → Admin
Account → Finish. The admin account is created here; without it sign-in
is impossible. Manual install: `migrate --force`, `storage:link`,
`db:seed --force` (never re-run), cache/config clear, `optimize`,
installer lock copy, `chmod storage 775`.

## Services & realtime

- **zender-reverb** — Laravel Reverb 1.10 websocket server (Pusher
  protocol). Settings live in the DB (`system_settings`), not `.env`:
  driver Reverb/Pusher/Off; Reverb App ID/Key/Secret, host, port
  (443/80), scheme; server side loopback :8080. nginx `location /app/`
  (trailing slash matters); `/apps/<id>/` serves only events/batch/
  channels/connections/users. Health check: WebSocket upgrade on `/app/`
  returns 101. CLI: `zender:configure-realtime`. Pusher clusters:
  mt1/us2/us3/eu/ap1/ap2/ap3/ap4; Test Connection sends a real event
  before saving.
- **zender-queue** — queue workers. Reference invocation:
  `queue:work --stop-when-empty --max-time=300` over priority queues.
  21+ named queues: `waba-media, channel-webhooks, wa-control, wa-media,
  email, sms-send, push-send, default, ai-agents, voice-ai,
  contact-imports, knowledge, sms-campaigns, sms-bulk, waba-campaigns,
  wa-campaigns, push-campaigns, email-campaigns, telegram-campaigns,
  wa-warmer, privacy-exports` (+ plugin-registered queues).
- **Scheduler:** cron `* * * * * php artisan schedule:run`; ~116
  scheduled entries in `routes/console.php` (full cadence map in
  `01-CORE-MODULES/cron-logs-status.md`). The scheduler itself can launch
  `queue:work --stop-when-empty` runners — cron-driven workers are a
  supported deployment mode; Horizon is not required. Privacy exports
  run on a dedicated long-timeout worker (an export can take ~1 hour).

## Sending throughput bounds (docs, Lane 2)

- Core send pump `messaging:tick` runs every minute; one worker max
  300s with overlap lock. SMS: 45s "walk", 80s job timeout, DB batches
  of 1,000; WhatsApp chunks ≤ 100.
- Bounds: shared hosting ≤ 6 walks/run; a persistent 2-vCPU worker
  ≤ ~80 walks/hour. Watchdog every 5 min: 15 min without progress while
  work remains → "Not sending" state + email to the workspace owner.
- These bounds size our VPS: queue/CPU headroom, not PHP-FPM, is the
  campaign bottleneck.

## The 5 companion server families

Closed Go server programs, one per channel family, registered in Admin
as **Service Servers** (`service_servers` table), each with capacity and
core-side load balancing/moves (`service_server_moves`,
`servers:sweep-moves`, per-kind assigners). Bootstrap is a generated
`config.json`: `{ purchase_code, server: { host, port, service_token },
laravel: { url } }` — a binary refuses to start on placeholder values
(licence gates, see `00-OVERVIEW.md`).

| Kind | Serves | Demo capacity | Default port | Detail file |
|---|---|---|---|---|
| `whatsapp` | QR linked-device accounts | 100 accounts/server | 8899 | `04-NO-SOURCE/whatsapp-qr-server.md` |
| `smpp` | SMPP SMS provider binds | 500 providers/server | — | `04-NO-SOURCE/smpp-server.md` |
| `telephony` | Phone Bridge + GSM Modem devices | 500 devices/server | public host:port (demo :443, Quick Tunnel option) | `04-NO-SOURCE/telephony-server.md` |
| `telegram` | Telegram bots + accounts | 500 bots/server | — | `04-NO-SOURCE/telegram-server.md` |
| `email` | Tenant mailboxes | 500 mailboxes/server | — | `04-NO-SOURCE/email-server.md` |

Balancing behaviour (SMPP example, same pattern per kind): gateways move
off a down server after 10 min (range 5–120), rebalance toggle, "Busy
Above 90%" (50–100), max 5 moves/run (1–50), no auto-return. Health
commands run every minute (`smpp:servers-health`, `telephony:servers-
health`, `wa:health-check`).

Registration rule for OUR replacements: any clean-room server we build
must register as the same `service_servers` kind and speak the same
surface (Reverb channels + `api/v1/internal/*` + config.json bootstrap,
minus the licence gate) — then core cannot tell the difference.

## Storage

- **Local only.** This release has no working S3 despite `.env` keys
  existing — keep `FILESYSTEM_DISK` local (Lane 2). Root: `storage/app`.
  Folders: `private/wa-media`, `private/` (imports/exports/tickets),
  `public/` (Messenger logos). Signed short-lived links; 5MB upload
  chunks; 80% usage warning; when storage is full, inbound messages are
  saved without their files. `storage:recalculate [--tenant=ID]`.
- Per-workspace quotas are plan limits (`max_storage_mb`,
  `max_file_size_mb`) — see `01-CORE-MODULES/plans-billing-credits.md`.

## Backups discipline (operator's responsibility — no plugin does this)

Per vendor docs: one consistent snapshot of **DB + config + tenant
storage + channel service state**; real files (not symlinks); encrypted
and off-server; restore first into an isolated location with sending
disabled. **APP_KEY is life-critical:** `system_settings` secrets are
decrypted with it, and the cache table holds decrypted settings — run
`cache:clear` before backup; if APP_KEY is lost, SMTP/OAuth/Meta/PayPal
secrets must be re-entered and opt-out hashes are silently lost.

## Upgrade discipline + patch register

- Manual `/upgrade` web updater accepts a ZIP ≤ 300MB in chunks;
  requires `Install/` + `zender.zip` inside; refuses stale files.
  Manual path: mysqldump backup → `artisan down` → stop queues → rsync
  (exclude `.env`, `storage`) → Settings > Updates → System Upgrade →
  restart services. `Zender:update` artisan command is NOT for buyers
  (it git-pulls; the download has no git).
- The paid Auto Update plugin is deliberately **not** bought and **not**
  rebuilt (see `02-PAID-PLUGINS/auto-update.md`).
- **Patch register rule (standing):** core Zender files are changed as
  little as possible; every own change to a core file is entered in the
  patch register (file, reason, diff summary, upstream version) so a
  vendor update never silently wipes our work. Own features live in
  plugins (`app/Plugins/…`) wherever the contract system allows.
- Pre-update backups: the system keeps the last 3.

## Scaling notes

- Multi-server is a documented pattern only for the companion servers
  (register more, core balances). There is **no** Docker or multi-server
  guide for the Laravel app itself in the docs (Lane 2 gap #7) — the app
  tier scales vertically; the channel tier scales by adding Service
  Servers. UNVERIFIED: running multiple app nodes against one DB
  (scheduler overlap locks suggest caution; test before relying on it).
- Custom Messenger domains need per-domain nginx + cert automation
  (`messenger-domain:provision-ssl` every minute, sudoers helper
  `zender-ssl`) — see `01-CORE-MODULES/custom-domains.md`.
