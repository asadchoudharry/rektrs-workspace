# Sendqon — Backup Restore Rehearsal Report — 2026-11-20

**Verdict: PASS.** Today's production backups restore cleanly onto an isolated scratch
stack: the app boots, serves its real sign-in page, record counts match production
(after restore-point timing is accounted for), and production-encrypted data decrypts
with the APP_KEY carried in the backup's config artifact. The one substantive finding
is about the restore point's timing, not its integrity — see "Restore-point finding".

Authorisation: owner "Proceed next build" (2026-11-20 14:22 PKT) + standing approval
for routine lane tooling. Production was not stopped, restarted, or written to at any
point; the rehearsal ran in its own compose project, volumes, and network, bound to
localhost only, and was fully torn down afterwards.

## Artifacts used (all dated 2026-11-20, from /var/backups/sendqon/)

| Artifact | Size | Integrity |
|---|---|---|
| sendqon-db-2026-11-20.sql.gz | 8,740,085 B | `gzip -t` OK; imported with zero errors |
| sendqon-config-2026-11-20.tar.gz | 30,058,470 B | lists cleanly, 167 entries |
| sendqon-storage-2026-11-20.tar.gz | 54,809,297 B | lists cleanly, 482 entries |

These files are the **08:31:06 UTC** backup run (`backup.log`: status=OK, push=OK,
sizes match the log line exactly). An earlier run the same morning (06:51 UTC) logged
status=FAIL with a smaller DB artifact; its files were superseded by the 08:31 run —
the set on disk is the good one.

What each artifact holds (per `/var/serverkit/apps/sendqon/backup.sh`):

- **DB**: full `mysqldump --single-transaction` of the production database.
- **Config**: the panel `.env` (carries the production APP_KEY and DB credentials),
  the production `docker-compose.yml`, and the whole `servers/` tree (companion
  configs + own companion sources).
- **Storage**: the full contents of the `sendqon_sendqon_storage` volume (the app's
  `storage/` tree: uploads, app files, framework cache, logs, OAuth keys).

## Method

Scratch stack in `~/sendqon-restore-test/` on offbox-1, compose project
`sendqon-restore-test`, built from the **same images as production**
(`sendqon:5.0.4-20261119` for the app, `mysql:8` for the DB — production's DB is
MySQL 8, so the rehearsal used MySQL 8, not MariaDB):

- Web bound to **127.0.0.1:18099** only; DB on the project network only (no host port).
- App environment taken from the restored config artifact (production APP_KEY and DB
  credentials), with three scratch-only deviations, none of which affect the restored
  data: `APP_URL` pointed at the localhost address, `SESSION_SECURE_COOKIE=false`
  (plain-HTTP localhost), and a scratch-only DB root credential generated on the host
  and destroyed with the stack.
- Restore order: DB container up → dump piped in → storage tar extracted into the
  scratch volume (root-preserved ownership) → web container up.

## Smoke battery (scratch stack, localhost)

| Check | Result |
|---|---|
| `GET /` | **200** |
| `GET /login` | **200**, 57,227 bytes, branded Sendqon sign-in page (Sign in / Welcome markers present) |
| `php artisan --version` (as www-data) | Laravel Framework **13.37.0**, boots clean |
| App log after boot | **No new entries** — the restored 2026-11-20 log file was not appended to during boot or smoke (zero errors) |
| Encrypted-payload spot check | **DECRYPT-OK** — an APP_KEY-encrypted payload from the restored DB (in `oidc_signing_keys`; the dump holds 4 such payloads) decrypted with the restored key; plaintext length 1,704 chars, content never printed |

## Record-count parity

Production counts read read-only at 09:25 UTC; scratch counts after restore.
The backup's restore point is **08:31 UTC**, so deltas from live traffic after
08:31 UTC are expected and explained — everything else matches exactly.

| Table | Scratch (restored) | Production (09:25 UTC) | Note |
|---|---|---|---|
| users | 1 | 1 | exact |
| devices | 2 | 2 | exact (versions differ — see finding) |
| conversations | 12 | 12 | exact |
| contacts | 14 | 14 | exact |
| campaigns | 1 | 1 | exact |
| channel_messages | 67 | 69 | Δ2 = messages synced after 08:31 UTC (incl. the 09:12 UTC inbound) |

(Note: this core has no `workspaces` or `messages` table; the workspace concept lives
in settings/companies and messages in `channel_messages` — those are the anchors used.)

## Storage parity

File-level diff of the restored volume against the live production volume:
417 files live vs 419 restored, and the difference reconciles **exactly** with the
ecosystem switch (below): the restored volume holds the 3 vendor slot APKs that
production has since deleted, and lacks the 1 new gateway APK production has since
gained (+3 −1 = +2). No unexplained differences. The gateway slot APK inside the
restored storage hashes to `2b8af65be3a3…`, matching its DB metadata byte-for-byte.

## Restore-point finding (the one thing to act on)

**The restored app-download slot shows the vendor family, not our v5.3.0** —
gateway / receiver / USSD all at v5.0.4, bundle record present (bundle cert
`77f4e3df…`), device 2 reporting app v5.2.2. This is **not** a restore defect: the
backup completed at **08:31:06 UTC** and the ecosystem switch executed at
**08:48:55 UTC**, ~18 minutes later. The restore is faithful to its point in time;
the switch, device 2's v5.3.0 update, and ~2 messages simply postdate it.

Implication: if production were lost right now, recovery to the 08:31 state would
roll the panel slot back to the vendor app family (rollback material for which is
preserved) and the switch would need re-applying. **Recommendation: run one fresh
backup now that the switch has landed** (the nightly run will otherwise capture it
tonight). Taking that backup was outside this lane's scope and was not done here.

## Gaps — what this backup set does NOT cover

- **Companion runtime state.** backup.sh covers the main DB, the panel config, and
  the main storage volume only. The companion containers (WhatsApp vendor + own
  bridge, SMPP/Jasmin, PBX, Telegram, Email) keep their runtime state in their own
  volumes, which are **not** in this backup set. Their configs and own sources ARE
  preserved (inside the config artifact's `servers/` tree), so companions can be
  re-provisioned — but live session state (e.g. a linked WhatsApp session) would
  need re-linking after a real disaster.
- **Queue / scheduler / reverb services** were not stood up in the rehearsal. They
  run the same image against the same DB and storage; the web smoke covers the app
  core, but their boot was not separately proven.
- The DEV stack was not touched and is not part of this rehearsal.

## Teardown + production-untouched proof

- `docker compose down -v` removed the scratch containers and network; the manually
  created storage volume was removed explicitly afterwards. Verified residual state:
  **0** scratch containers, **0** scratch volumes, **0** scratch networks, rehearsal
  directory deleted.
- Production after teardown: `sendqon` Up 27 hours and `sendqon-db` Up 4 days
  (unchanged uptimes — never restarted), site answering **200** on its loopback port,
  and the anchor counts re-read identical to the pre-rehearsal snapshot
  (users 1, devices 2, channel_messages 69, device 2 still on v5.3.0).

## Bottom line

The nightly backup set is genuinely restorable — config, database, and storage come
back together, the encryption key travels with the config artifact, and the restored
system serves and decrypts correctly. The follow-ups worth having: (1) a fresh backup
to capture the post-switch state, and (2) a decision on whether companion runtime
volumes should join the backup set.
