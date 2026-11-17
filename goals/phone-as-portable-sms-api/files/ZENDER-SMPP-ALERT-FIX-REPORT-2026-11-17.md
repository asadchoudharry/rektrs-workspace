# SENDQON — SMPP FALSE "SERVER DOWN" ALERTS: FIX REPORT (2026-11-17)

**Status: FIX LIVE.** The Cloudflare hairpin is removed from both
companion servers' path to the app. Post-fix watch: zero connection
resets, both servers healthy.

## Symptom

Admin received "Server down: smpp-1" emails on 2026-11-16 at
18:41:08 UTC and 21:40:34 UTC ("unreachable since …"), each followed
by a "Server back online" mail ~1m18s later.

## Cause (proven from logs, 2026-11-17 morning)

- The `sendqon-smpp` container **never crashed**: RestartCount=0,
  continuously Up since 2026-11-16T10:21Z.
- The companions reach the app (Reverb WebSocket + internal API)
  via the **public URL** `https://sendqon.rektrs.com` — i.e. out
  through Cloudflare (edge IPs 172.67.204.161 / 104.21.85.108) and
  back in. Cloudflare periodically resets these long-lived sockets:
  log lines `reverb ws loop exited … connection reset by peer`,
  once literally `CloudFlare WebSocket proxy restarting`.
- The binary re-subscribes in ~2 s every time, but the app's health
  checker twice caught a failure window and mailed "Server down".
  Before the fix the resets occurred every 1–10 minutes (e.g.
  21:39, 21:40, 21:50, 21:51, 21:53, 21:54 UTC — six in 15 min).
  `sendqon-whatsapp` had the same exposure.

## Fix

One change, in OUR OWN companion compose only
(`/var/serverkit/apps/sendqon/servers/docker-compose.yml`; backup
`docker-compose.yml.bak-20261117-040401-alertfix` alongside it):

```yaml
extra_hosts:
  - "sendqon.rektrs.com:172.19.0.1"
```

added to **both** services. 172.19.0.1 is the gateway of the
`sendqon_default` bridge — the host itself, where Caddy serves
`sendqon.rektrs.com` on 443 with the real Let's Encrypt cert. The
companions now reach Caddy directly on the host; DNS/public
visitors are unaffected (Cloudflare still fronts the site).

**Pre-flight proof (before recreating anything):** from inside
`sendqon-smpp`, `openssl s_client -connect 172.19.0.1:443
-servername sendqon.rektrs.com -verify_hostname
sendqon.rektrs.com` → cert CN=sendqon.rektrs.com (Let's Encrypt),
**Verify return code: 0**, `HTTP/1.1 200 OK` from our app.

## Apply sequence + evidence

1. **SMPP recreated 04:04 UTC** — `stored license verified …
   outcome=licensed` at start; bootstrap OK; `reverb subscribed`.
   `getent ahosts sendqon.rektrs.com` → **172.19.0.1**; established
   connections in /proc/net/tcp → **172.19.0.1:443** (previously
   Cloudflare edge IPs). (Note: plain `getent hosts` still prints
   Cloudflare AAAA records — a glibc per-family quirk; `ahosts`
   and the actual connection table prove the effective path.)
2. **WhatsApp recreated 04:07 UTC** — same licence/bootstrap
   result; app-path connection → 172.19.0.1:443 (its separate
   Meta/web.whatsapp.com connection is unchanged and unrelated).
3. **Watch (final check 04:18 UTC):**
   - SMPP, 14 min post-restart: **0** `connection reset` /
     `ws loop exited` lines, **0** warnings/errors.
   - WhatsApp, 10 min post-restart: **0** / **0**.
   - App-side health: both rows **healthy** (last_health 04:17 /
     04:14 UTC).
   - All 7 containers Up; the 5 main app containers were never
     restarted (uptimes 19–22 h intact).
   - (One monitoring SSH session dropped mid-watch; re-checked
     immediately — containers unaffected, counts above are from
     the full post-restart log windows.)

## Durability / notes

- The change lives in the servers compose, not the panel DB, so it
  survives companion recreates. No vendor file, config.json or
  licence state was touched; no firewall rules were changed.
- If a future companion is added, it needs the same `extra_hosts`
  line to stay off the Cloudflare path.
