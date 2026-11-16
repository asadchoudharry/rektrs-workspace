# Sendqon — WhatsApp + SMPP Licences Applied (2026-11-16)

**Scope:** apply the two vendor plugin licence codes (WhatsApp Plugin, SMPP Plugin) to the prepared companion-server configs on offbox-1 and start both services. The owner explicitly authorised Muse to fetch and apply these codes, superseding the earlier owner-paste plan (`apply-licence.sh`).

**Result: COMPLETE — both licences ACCEPTED by the vendor check, both services running, both showing Healthy in the app.**

**Secret handling:** the code values reached the host only via stdin into a short-lived script — never in command strings, shell history, any log, or this report. Each code is 38 characters. A dedicated scan confirmed neither value appears in either container's logs. The helper scripts used on the host were deleted afterwards.

## 1. Config update (per server)

- **Backup first:** `config.json.bak-licence` (mode 600) created beside each config, holding the pre-licence version (placeholder intact) — the rollback copy.
- Placeholder replaced with the corresponding code; verified by structure only: JSON valid, placeholder absent, `purchase_code` equals the supplied code, file mode 600 preserved.
  - `servers/whatsapp/config.json`: 303 → 297 bytes
  - `servers/smpp/config.json`: 372 → 370 bytes

## 2. Service start

`docker compose up -d` in `/var/serverkit/apps/sendqon/servers/` — `sendqon-whatsapp` and `sendqon-smpp` created and started; both still Up at every subsequent check (a refused licence makes these binaries exit, per the earlier smoke tests — staying Up is itself evidence).

Log evidence (redacted; neither code value appears anywhere in the logs; no refusal lines):

- **WhatsApp:** `license verified … outcome=licensed` (2026-11-16 09:21:51 UTC); `Starting WhatsApp Server (port=8899, laravel=https://sendqon.rektrs.com, version=5.0.4)`; `Bootstrap OK (server_id=1, server_name=Primary WhatsApp)`; `HTTP server starting (address=0.0.0.0:8899)`; WhatsApp protocol version fetched/updated normally.
- **SMPP:** `zender-smpp starting (version=5.0.4)`; `license verified … outcome=licensed`; `bootstrap OK (server_id=2, server_name=smpp-1)`; `HTTP server listening (address=[::]:8898)`; `reverb subscribed (channel=private-smpp.server.2.commands)`.

## 3. App-side health (service_servers table, read ~09:23 UTC)

| id | kind | name | status | last_health_at (UTC) | unhealthy_since |
|---|---|---|---|---|---|
| 1 | whatsapp | Primary WhatsApp | **healthy** | 2026-11-16 09:22:54 | NULL |
| 2 | smpp | smpp-1 | **healthy** | 2026-11-16 09:22:55 | NULL |

Loads 0/100 (WhatsApp) and 0/500 (SMPP); SMPP row reports version 5.0.4. The admin Service Servers pages should now read Healthy for both (they previously read Unhealthy / Not Responding while the binaries were down).

## 4. Main stack untouched

`sendqon`, `sendqon-db`, `sendqon-queue`, `sendqon-reverb`, `sendqon-scheduler` all Up with their pre-existing uptimes — no restarts or recreates by this lane.

## 5. Notes

- The owner no longer needs to run `apply-licence.sh` — the codes are already applied. The script remains on the host; re-running it is harmless (it skips configs whose placeholder is gone).
- Rollback (not needed): restore `config.json.bak-licence` over `config.json` and `docker compose up -d` — returns a server to its pre-licence state.
- **Next product steps (not licence matters):** no WhatsApp number is linked yet — QR linking is required before WhatsApp messages flow; SMPP reports `gateways=0` — provider binds are admin configuration work.
