# Sendqon B8 — Own WhatsApp Bridge + USP-4 (WhatsApp Guard) — Build Report — 2026-11-18

**Status: COMPLETE + LIVE.** (1) Our own WhatsApp QR bridge is built, battery-proven against the dev copy, and deployed on production alongside the vendor binary — registered as its own service server and healthy; new pairings land on it by core's own load-based pick. (2) USP-4 shipped as the `wa_guard` plugin (ban-risk score + warm-up management), battery-proven on dev and ACTIVE on production. **One production fact changed the cutover:** the owner's number is now LINKED and live on the vendor server (see §4) — the live account was deliberately NOT moved; that move is a named owner decision (§7).

**Legal line honoured:** the bridge is clean-room. The contract below was extracted from the core PHP side only (WhatsApp plugin + channel/service-server code). The vendor's closed binary was never decompiled, inspected, or probed beyond the documented health/licence behaviour recorded in earlier phases.

---

## 1. The extracted app↔companion contract

Sources: `WaBinaryClient`, `WhatsappServerKind`, `BootstrapController`, `BroadcastAuthController`, `EventIngestController`, `WaEventIngestService`, `WaOutbox`, `WaCommandBuilder`, the command/outbound event classes, `WaMoveClient`, `config/wa.php`, `routes/api.php` + `routes/channels.php`. (No `docs/api/whatsapp-v1.yaml` exists in the tree; this extraction is the contract of record.)

**Bootstrap (companion → app).** The companion reads `config.json` — `{purchase_code, server:{host, port 8899, service_token}, laravel:{url}}` — and calls `GET {laravel}/api/v1/internal/whatsapp/bootstrap` with `Bearer <service_token>` and UA `zender-whatsapp/<version> (<os>/<arch>)`. The response carries the server row, the broadcast (Reverb) coordinates + app credentials, and the account list to resume: accounts on this server **with a JID**, status not Deleted/LoggedOut/Banned, excluding `stream_replaced` — each with a freshly issued per-account `session_token` and its settings (throttle range, reject-calls, proxy, suppression TTL). A successful bootstrap marks the server **healthy** immediately. Errors: 401 `invalid_service_token`; 503 when broadcast is not configured.

**Reverb (app → companion commands).** Per account, the companion connects to Reverb (Pusher protocol) and subscribes to `private-wa.account.{id}.commands`, authorizing via `POST /api/v1/internal/whatsapp/broadcasting/auth` with the **account session token** (the web-user channel auth for `.commands` is hard-false — only the companion subscribes). Command events (`wa.command.*`, payloads via `broadcastWith`): send_text / send_media / send_location / send_contact / send_poll / edit_message / revoke_message / send_reaction / mark_read / update_config / check_phone / lookup_username / resync_groups / suppression_clear / watch_chat_presence / logout. The send queue contract (from `WaOutbox`): humanize every send, one FIFO queue per account, fail any frame that waited over 8 minutes; origin gap floors: agent 1 s, automation/campaign 3 s.

**Lifecycle HTTP (app → companion, Bearer service token both ways).** `POST /api/v1/internal/whatsapp/accounts` (assign: session token, login method qr|pairing_code, phone?, existing JID?, device name, per-account settings, move_id?) → 2xx ack, errors as `{error:{code,message}}`; `DELETE .../accounts/{id}` → 204 idempotent; `GET /healthz` — healthy iff 200 AND (`{"status":"ok"}` as the only key OR `healthy === true`) AND `reverb_connected !== false`; the JSON body is stored as the server's `last_health`, `version` feeds the binary-version setting; polled every minute by `wa:health-check`. `GET /api/v1/internal/whatsapp/media/{account}/{filename}` — the app pulls inbound media bytes from the companion (the filename is the one the companion named in its inbound event).

**Events (companion → app).** `POST /api/v1/internal/whatsapp/events` (or `/events/batch`), Bearer service token, `{event, wa_account_id, payload}` → `{status:"accepted"}`; 404 `account_not_on_server` when the account is not on this server. Catalogue: qr_generated (PNG base64 + expiry) · pairing_code · paired (jid/lid/phone/name; anchors warm-up) · account_status (connected/disconnected/logged_out/banned + reason; `server_shutdown` and `stream_replaced` are special-cased by core) · risk_signal (timestamped; kinds message_capping, reachout_timelock, low_delivery, ban_cooldown, rate_overlimit, consecutive_failures, with core hold durations) · inbound_message (full type set incl. media filename, location, contact, poll, referral) · message_status (sent/delivered/read/failed/revoked) · reaction · message_edited · message_revoked · outbound_mirror · chat_presence · poll_vote · check_phone_result / username_lookup_result (on lookup **error** the companion must send `wa.event.error` with the request_id — never a fabricated negative) · groups_synced (authoritative; an empty list never mass-deletes) · group_info · contact_resolved · contact_username_changed · protocol_outdated · library_error · error.

**Server moves (HPKE).** `POST /moves/{uuid}/prepare|export|abort|rollback|complete|activate` + `PUT /moves/{uuid}/bundle`. Suite string `hpke-x25519-sha256-aes256gcm`; the variant is companion-defined (Laravel relays sealed bundles and never opens them): KEM context enc‖pkR, key-schedule info = the suite string, wire = base_nonce(12) ‖ AES-256-GCM ciphertext‖tag, enc carried separately (base64url). This is byte-identical to the house variant proven in the B4 Telegram companion. Transport must be HTTPS or loopback/local.

**Core machinery that already exists (USP-4 builds on it, never duplicates):** warm-up ramp (`warmup_enabled` default on + `warmup_started_at`; 20/day base +20/day to 1,000; replies to people who wrote first are free), per-account throttle (default 8–22 s), risk holds (`risk_signal`/`risk_until`, `WaAccountRestrictions`, `WaDeliveryHealth` — 24 h window, 30 min settle, sample ≥ 50, trips below 90% delivered), temp bans + resume command, quiet hours, the WaWarmer system, and full health history in `wa_account_events`.

## 2. The bridge (Part 1)

**Stack:** Node 20 + **Baileys `@whiskeysockets/baileys` 6.7.18 (MIT)** for the WhatsApp Web linked-device protocol; `ws` for the hand-rolled Pusher/Reverb client; `qrcode` for QR PNGs; HPKE re-implemented on Node's built-in crypto (X25519/HKDF/AES-256-GCM). Source: Sendqon branch `bridge-whatsapp-own` (under `bridge/whatsapp-own/`); on the host: `/var/serverkit/apps/sendqon/servers/whatsapp-own/` (build context + config + data). Container `sendqon-whatsapp-own`, image `sendqon-whatsapp-bridge:1.0.0`, network `sendqon_default`, no host ports, `extra_hosts` pinning like the other companions.

**No licence gate.** The config's `purchase_code` slot is ignored entirely; the bridge refuses to start only when the service token is missing/placeholder (the B4 companion discipline).

**Battery findings that changed the code (all fixed in the shipped build):**
1. **WhatsApp rejects Baileys' pinned default client version** at the pairing handshake ("Connection Failure" before any QR). The bridge resolves the current version live at startup (`fetchLatestBaileysVersion`, refreshed daily) and passes it to the socket — with it, the QR arrives immediately.
2. **Idle Reverb sockets die silently** (Reverb activity timeout ≈ 30 s; no close frame across the docker/NAT path) — commands dispatched minutes after subscribing vanished. The client now heartbeats (ping every 20 s; forced reconnect after 50 s of total silence), proven by a check-phone dispatched after 90 s idle resolving correctly.
3. **`check_phone` on a not-open socket hangs inside Baileys.** The bridge now answers immediately with an honest `wa.event.error` (code `not_connected`) when the session is not fully open, plus a 20 s timeout race when it is — never a fabricated result.

**Dev battery (against the dev copy, dev tenant + dev WA account):**
- Bootstrap succeeds; server row healthy; `wa:health-check` ✓ (bridge version 1.0.0 recorded as the server binary version); `PickWaServerService` picks the bridge. ✅
- Assign → Baileys session → **QR event lands → account flips to `pending_pair` with a real PNG QR in account meta + expiry set** (the awaiting-scan state). ✅
- Send through the adapter's local path → settled Failed `not_connected` (core-recorded). ✅
- Send through the **bridge command path** (account fixture-marked Connected so the adapter hands the claim to the companion): claim → `queued` → bridge verdict `not_connected` settles the row Failed with the bridge's own error code/message. ✅
- check_phone → waiter resolves `{failed: true, code: not_connected}` — including after 90 s of socket idle. ✅
- Release → session removed (healthz accounts 0). ✅
- Restart/periodic bootstrap → server healthy again; bootstrap resume re-assigns accounts the app lists. ✅
- Moves: prepare → export (sealed bytes + digest/enc/suite headers) → bundle PUT (identity returned) → activate OK; **tampered digest rejected** (`digest_mismatch`). HPKE cross-tested Node ↔ the house Python variant (seal/open round-trip, identical derivation). ✅
- **Boundary — where the battery stops:** no real phone number was scanned by the lane. A live pairing (QR scan), a real send/receive on a real number, inbound media relay and group sync against a live session are therefore **not** exercised; they are the owner's QR-link step and the final proof. Pairing-code issuance was likewise not exercised (it requires a real number).

## 3. USP-4 — WhatsApp Guard plugin (Part 2)

`wa_guard`, type `tool`, v1.0.0 — source on branch `plugin-wa_guard`, production **ACTIVE**, baked into the build tree. Page: **https://sendqon.rektrs.com/wa-guard** (reached by URL — plugins cannot add sidebar entries in this architecture).

**Ban-risk score — ADVISORY.** Deterministic 0–100 (Low/Moderate/High/Critical) per account, computed on each tick from core's own records only: banned/logged-out status (+60/+35), active WhatsApp risk signal (+45), running temp ban (+55), settled 24 h delivery rate (+10/+20/+35 below 98/95/90% — warning *before* core's own 90% low-delivery trip), failure streak ≥ 5 (+15), warm-up pressure on days 0–3 (+15), young account with the ramp off (+10), session-health events in 7 days (up to +10), protocol-outdated flag (+10). Score + factors + guidance are shown on the guard page; full history is kept per account.

**Enforcement — only through core's own tenant-setting columns, only for guard-enrolled accounts, only when the tenant leaves auto-guard on:**

| Lever | Mechanism | Real? |
|---|---|---|
| Warm-up ramp | Enrollment ensures `warmup_enabled = true`; core's `WaWarmupService` caps new-contact sends (replies stay free) | ✅ core-enforced |
| Throttle tightening at High risk | `throttle_min/max_seconds` raised to ≥ 15/30 s + core's own `WaConfigUpdateRequested` event so a live companion applies it at once; tenant's previous values restored when risk clears (hysteresis) | ✅ core-enforced |
| Re-warm at Critical risk | `warmup_started_at = now` (max once per 24 h) — core's ramp restarts at the day-0 base | ✅ core-enforced |
| Ban-risk score + warnings | Plugin tables + page | Advisory (labelled) |
| `risk_signal` / `risk_until` / `banned_until` | **Never written by the plugin** — they record WhatsApp's own verdicts; faking them would corrupt core's health machinery | — |

**Dev battery:** functional — install/activate + tables ✅; calm account scores 0/Low ✅; seeded delivery collapse (20 failed, 0% delivered) scores exactly 50/High (35 delivery + 15 streak) with **no enforcement while unenrolled** ✅; + active risk signal → 95/Critical → throttle tightened 8/22 → 15/30 (previous stored) **and** warm-up restarted, history action `rewarm+throttle_tightened` ✅; fixtures cleared → score 0 → throttle restored to 8/22 (`throttle_restored`) ✅; the plugin never wrote the risk columns (values byte-identical to what the battery seeded) ✅. UI-surface — guest → 302 to login ✅; owner page 200 with live score, warm-up day/cap and factor list ✅; owner enroll/unenroll through the real forms ✅; workspace member (created via core's parent + workspace-role machinery) reads the page read-only and POST enroll → **403** ✅; `wa-guard:tick` command + 6 routes registered ✅. Two battery-found bugs fixed pre-production (enum-cast streak comparison; history-prune `offset` without `limit`).

**Production:** fresh verified backup first (status=OK, push=OK) → PluginManager install → **ACTIVE v1.0.0**, tables live, routes registered, guest probe 302, site 200s. Nothing enrolled yet — the owner's account appears on the guard page for him to switch on.

## 4. Production state — bridge + the cutover question

- Vendor companion `sendqon-whatsapp` — **running, untouched**, service server id 1 "Primary WhatsApp", healthy, load 1.
- **Own bridge `sendqon-whatsapp-own` — running**, service server id 5 "Primary WhatsApp (Own Bridge)", base URL `http://sendqon-whatsapp-own:8899`, capacity 100, **healthy** (`wa:health-check`: 2 servers, 2 healthy), load 0. Companions compose backed up first (`docker-compose.yml.bak-20261118-b8`).
- **⚠️ The live account:** production `wa_accounts` id 1 (the owner's workspace) is **Connected** on the vendor server — JID `923474162393:6@s.whatsapp.net`, phone +92 347 4162393. Earlier phases recorded zero linked numbers; the owner has since linked his. **The lane did not move it, did not disable the vendor row, and did not touch its session.**
- Consequence for new pairings: core's picker chooses the healthy enabled server with the lowest load — the own bridge (0) ahead of the vendor (1) — so **numbers linked from now on land on our bridge automatically**, while the existing number keeps working on the vendor binary. The final step of the vendor exit is moving that one live account (the HPKE move protocol both companions speak, or a fresh QR re-link) — a deliberate owner decision, not something to do silently under a live session (§7).
- **Ops rule (new):** never wipe `/var/serverkit/apps/sendqon/servers/whatsapp-own/data` casually — Baileys auth state (linked sessions) lives there; it rides the nightly config backup.

## 5. Plan-card corrections

1. The plan card said the bridge needs "`channel` registration (patch register)". **No core patch was needed:** the WhatsApp channel plugin is the vendor's free plugin (already installed), and the bridge is a companion behind core's existing service-server contract — the same pattern as B4's companions. PATCH-REGISTER unchanged.
2. The plan card's worst case for session migration ("tenants re-link by QR") assumed sessions exist in the vendor binary's own format. Reality: exactly **one** live session exists (the owner's), and the contract's HPKE move protocol offers a designed transfer path — so the choice is move-vs-relink for one number, not a fleet-wide re-link.
3. USP-4's card imagined the plugin would lean on "the bridge's session data". In fact everything the guard needs is already recorded by **core** (delivery rows, risk columns, account events) — the guard works identically for numbers on the vendor binary and on our bridge, and no bridge-side data feed was needed.

## 6. Push ledger (ls-remote verified)

- Bridge source → Sendqon `bridge-whatsapp-own` @ **a4663a8**
- Plugin source → Sendqon `plugin-wa_guard` @ **7e6983a**
- This report → Sendqon `rebuild-tree` @ **51e08a9** · rektrs-workspace `main` @ **df23adc** (ledger completed by the follow-up amendment commits)

## 7. Owner items

1. **Final proof of the bridge (your number):** link a *second* WhatsApp number (or re-link after deciding item 2) from Workspace → Channels → WhatsApp — it will land on our bridge by the load pick; send/receive once. The dev battery proved everything up to the awaiting-scan state; a real scan is the one step a lane cannot do.
2. **Cutover decision for your live number (+92 347 4162393):** it currently runs on the vendor binary. Options: (a) leave it there (it keeps working; vendor binary stays as a single-number legacy), (b) move it to our bridge via the built-in server-move (designed path, small interruption risk while WhatsApp replaces the session), or (c) re-link it by QR onto our bridge (simplest, brief offline moment). On your word the lane will execute (b) or (c) with the vendor row disabled afterwards — completing the vendor exit.
3. **WhatsApp Guard:** open https://sendqon.rektrs.com/wa-guard and switch the guard **on** for your number if you want automatic pacing protection; the score is already computed either way.
