# Sendqon Verification Battery — Part 1 Report (2026-11-16)

Scope: the battery items that need **no owner input** — public-surface checks,
production nightly backups (local + replica to micro-2), and the Uptime Kuma
monitor. Everything below is an observed result from this run, not a plan.
Times are UTC (PKT = UTC+5).

## 1. Public-surface checks (curl from the Muse VM)

| Check | Expected | Observed |
|---|---|---|
| `GET https://sendqon.rektrs.com/` | 200, shows the Sendqon name | **200** in ~1.5 s; the HTML contains "Sendqon" (2 matches) |
| `GET https://sendqon.rektrs.com/login` | 200 | **200**; page carries "Sign In / Log in" |
| `GET https://sendqon.rektrs.com/register` | 200 (public registration enabled) | **200**; page carries "Create Your Account / Sign up / Register" — a genuine signup page, not a redirect |
| WebSocket probe `https://sendqon.rektrs.com/app/<key>` with `Connection: Upgrade` / `Upgrade: websocket` headers | path reaches Laravel Reverb (101 or 400) | **101 Switching Protocols** — a full WebSocket handshake completed through Cloudflare, with response header `X-Powered-By: Laravel Reverb` and a valid `Sec-WebSocket-Accept`. The public Reverb path is live end to end. |

## 2. Nightly backups — offbox-1 → local + micro-2 replica

**Script:** `/var/serverkit/apps/sendqon/backup.sh` (executable, owned by
`ubuntu`, uses `sudo` where needed). Per run it:

- dumps the `zender` DB via `docker exec sendqon-db`, with the dump running
  **inside** the container using the container's own `MYSQL_USER` /
  `MYSQL_PASSWORD` / `MYSQL_DATABASE` env vars — no secret value is printed,
  logged, or written anywhere by the script;
- tars the config set: panel app-dir `.env` + `docker-compose.yml` + the whole
  `servers/` dir (companion configs, compose, `apply-licence.sh`);
- tars the `sendqon_storage` volume data
  (`/var/lib/docker/volumes/sendqon_sendqon_storage/_data`);
- writes date-stamped artifacts to `/var/backups/sendqon/`, deletes local
  artifacts older than 7 days;
- pushes the same three artifacts to micro-2 over WireGuard
  (`ubuntu@10.10.0.1:/srv/replicas/sendqon/`, key `/root/.ssh/replica_key` —
  the same key/pattern as the existing panel replica);
- appends one line per run to `/var/backups/sendqon/backup.log`
  (timestamp, per-artifact sizes, push result — no secrets).

**Push-route change (noted):** the existing `replica_key` was not authorized
on micro-2. Its **public** key (already in use for the micro-1 panel replica)
was added to micro-2 `ubuntu`'s `authorized_keys` via the existing
VM→micro-2 SSH route, and `/srv/replicas/sendqon/` was created beside the
existing `hc/` and `vault/` replica dirs. No new keypair was generated.

**First run (2026-11-16 07:55 UTC) — verified on both hosts:**

| Artifact | Size (bytes) | offbox-1 `/var/backups/sendqon/` | micro-2 `/srv/replicas/sendqon/` |
|---|---|---|---|
| `sendqon-db-2026-11-16.sql.gz` | 1,772,067 | ✅ | ✅ |
| `sendqon-config-2026-11-16.tar.gz` | 23,718,453 | ✅ | ✅ |
| `sendqon-storage-2026-11-16.tar.gz` | 42,438,988 | ✅ | ✅ |

Log line: `2026-11-16T07:55:00+00:00 status=OK db=1772067 config=23718453 storage=42438988 push=OK`
Dump sanity: the DB artifact contains **309 `CREATE TABLE` statements** — a
real, complete dump. Sizes are byte-identical on both hosts.

**Schedule:** cron entry installed at `/etc/cron.d/sendqon-backup`:

```
15 3 * * * root /var/serverkit/apps/sendqon/backup.sh
```

⚠️ **Host fact:** the `cron` package is **not installed** on offbox-1
(verified: no cron binary; the pre-existing `/etc/cron.d/panel-db-backup`
entry is inert for the same reason). The host's working pattern is systemd
timers (the panel replica uses `panel-replica-push.timer`, 03:35 UTC), so a
matching pair was installed and enabled as the operative trigger:
`sendqon-backup.service` + `sendqon-backup.timer` (`OnCalendar=*-*-* 03:15:00`,
`Persistent=true`). `systemctl list-timers` confirms the next run:
**Tue 2026-11-17 03:15:00 UTC**. The cron.d line stays as the documented
entry; the timer is what actually fires.

**Known gap:** the micro-2 replica side has no rotation yet (the 7-day
rotation is local-only). At ~66 MB/day the replica dir grows ~2 GB/month
against 38 GB free on micro-2 — safe for months, but a remote rotation
should be added when convenient.

## 3. Uptime Kuma monitor — micro-1

- **Pre-change DB backup:** `/var/lib/docker/volumes/uptime-kuma-data/_data/kuma.db.bak-20261116-075554`
  (2,674,688 bytes, taken with SQLite's online backup before any change).
- **Monitor added:** id **8**, name **Sendqon**, type **http**,
  URL **https://sendqon.rektrs.com**, interval **60 s**, active — inserted as
  an exact copy of the existing monitor id 1 ("Rektrs Website") row's column
  pattern (same user, retries, timeout, accepted status codes `200-299`,
  etc.), with only name/URL/created-date changed. No other monitor was
  touched. Kuma was restarted to load the change and is **healthy**.
- **UP proof (Kuma's own heartbeat data):** two consecutive heartbeats for
  monitor 8, both `status = 1` (UP), `msg = "200 - OK"`:
  2026-11-16 07:57:02 UTC (ping 359 ms) and 07:58:02 UTC (ping 427 ms).
- Transparency: two earlier insert attempts failed on shell-quoting syntax
  errors **before** any write — the DB was unchanged by them (the successful
  insert ran afterwards, and the pre-change backup predates all attempts).

## 4. Battery part 2 still needs

- **Owner login test** — sign in at https://sendqon.rektrs.com with the admin
  created in the installer and eyeball the dashboard/Messenger (needs the
  owner's own credentials — owner-only step).
- **WhatsApp + SMPP companion start** — the owner runs
  `/var/serverkit/apps/sendqon/servers/apply-licence.sh` once (two pastes
  from the vendor portal); only then can the admin health states
  (currently Unhealthy / Not Responding, expected) be re-checked as healthy.
- **Android Gateway pairing + test SMS** — needs the separate phone-app
  bundle (vendor portal "format 2" download, not yet fetched) and the
  owner's Firebase project for instant delivery; then pair the Redmi and
  send a real test SMS.
- **Email test** — the owner has chosen the sending identity
  `no-reply@sendqon.rektrs.com` on a new subdomain; once that sending setup
  exists, the app-side SMTP fields (Admin → Settings → Email) get filled and
  a password-reset / test email proves delivery.
- **Plans pricing decision** — the four seeded plans still carry vendor USD
  prices; PKR pricing is the owner's call.
- **APP_KEY copy in Vaultwarden** — owner step (the key itself never passes
  through chat).
