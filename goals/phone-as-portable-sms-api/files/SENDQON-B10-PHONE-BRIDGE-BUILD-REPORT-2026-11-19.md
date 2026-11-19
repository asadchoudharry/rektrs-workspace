# Sendqon B10 Phone Bridge — Build Report (2026-11-19)

Programme: Phone Bridge (phone-as-API) on Sendqon core. This report covers
§B10.0 (IVR/DTMF timing fix — completed earlier, summarised) and §B10.1
(the `phone_bridge` channel shim plugin + the telephony adapter daemon in
the B9 PBX companion). All work dev-first, battery-proven, then production
in the programme pattern. No core PHP was edited at any point.

---

## §B10.0 — IVR/DTMF timing fix (summary)

**Baseline:** Asterisk 20.6.0 with **0 timing modules loaded**. Any
DTMF-driven dialplan path (Background/WaitExten, Read) crashed Asterisk:
**segfault, exit 139, core dumped**, reproduced with a PID change.

**Root cause:** no `res_timing_*` interface loaded; the DTMF wait paths
dereference the missing timer.

**Fix (one line):** load `res_timing_timerfd.so` in
`companions/pbx/asterisk/modules.conf`.

**Batteries — 5/5 in every round:** dev runtime-load, dev rebuilt-image
persistence, prod runtime, prod recreated-from-fixed-image final.
Cases: A Background/WaitExten + Dial D(2); B Read(); C PJSIP RFC4733;
D AMI PlayDTMF; E test-call + queue regression.

**Production proof:** www-data probe — pbx plugin active, companion
health ok, 0 tenant rows. Image `sendqon-pbx:1.0.0` = `86c315966182`.
Companion push: `companion-pbx` @ `11544d4`.

**Notes:**
- B9-era image content was missing from the host image store, so
  commit/retag rollback was unavailable — rollback for this change is
  the one-line config revert.
- The prod compose build hung on sandbox DNS (apt) and was killed;
  image provenance is the dev-built image from byte-identical source.
- Robustness note: the daemon's AMI socket can go half-open after an
  Asterisk crash; a container restart is needed to recover actions.

---

## §B10.1 — phone_bridge shim plugin + telephony adapter daemon

### What was built

**1. Shim plugin `phone_bridge` v1.0.0** (`~/workspace/sendqon-plugins/phone_bridge/`)
- `plugin.json` — slug `phone_bridge`, type channel, channel
  `phone_bridge`, namespace `App\Plugins\Channels\PhoneBridgePlugin`,
  main class `src/PhoneBridgePlugin.php`.
- `src/PhoneBridgePlugin.php` — mirrors the live `gsm_modem` shim
  exactly: `isConfigured() = true`, empty settings schema. It exists so
  core's ChannelPlugins registry lights the channel (types
  ['phone_bridge'], serverKinds ['telephony'], planKeys ['phone_bridge'],
  broadcasts `telephony.server.{id}.commands`, adminNav
  `/admin/service-servers/telephony`). **All plan flags left OFF**
  (pricing is the owner's decision).

**2. Telephony adapter inside the PBX companion**
(`~/workspace/sendqon-pbx-companion/src/`)
- `telephony-client.js` — HTTP client for core's contract
  (`v1/internal/telephony`, Bearer service token): bootstrap, pair,
  events, connections/{id}, outbound/{id}, ussd/{id}, flows/{id}/facts,
  flows/{id}/compiled (ETag-cached), prompts/{asset_id} (binary),
  media (multipart WAV upload), broadcasting/auth, public-url,
  error-reporting.
- `ws.js` — dependency-free RFC 6455 WebSocket client. The companion
  image carries no npm dependencies and Node 18 has no stable global
  WebSocket, so the modem daemon's `ws`-based client could not be
  reused as-is.
- `reverb.js` — Pusher-protocol layer over `ws.js`: broadcasting/auth
  via core, subscribe to `private-telephony.server.{id}.commands`,
  command dispatch.
- `telephony.js` — the adapter itself:
  - Writes its own Asterisk config (`pjsip.d/phonebridge.conf`
    endpoints `pbline-<ext>`; `extensions.d/phonebridge.conf` contexts
    phonebridge-in/-out/-line) and reloads; B9 tenant config untouched.
  - Bootstrap → PUT public-url `{status: off}` (no tunnel in this
    deployment) → per paired line: device_status + phone_status.
  - AMI mapping: Newchannel / Newstate / Hangup / DTMFEnd →
    call_started / call_updated (ringing, answered, dtmf) / call_ended;
    MixMonitor WAV uploaded after hangup → call_uploads +
    recording.ready (upload decision uses a fresh GET connections/{id}
    so a changed record_calls setting is honoured).
  - Pairing: POST /telephony/pair claims codes; state (connection_id,
    generated 6-digit device PIN, paired_at) persisted in the data
    dir's `telephony-state.json`.
  - Commands handled: dial (flow/api modes originated via AMI through
    the line; agent/stream/verification modes logged as later-phase),
    test_call, answer, hangup, hold, send_dtmf, ussd (answered from
    core's ussd endpoint), send_sms (fetches the outbound record and
    reports sms_status failed/not_supported — a SIP line has no SMS),
    connection_updated, flow_updated, sync; restart/unpair/set_pin
    family acknowledged.
  - Compiled flows: on a call whose connection has an assigned flow,
    fetches compiled + facts + first prompt asset and caches them
    under the data dir (fetch proven by battery; full compiled-flow
    EXECUTION is B10.5 — calls follow the Asterisk path).
  - Health loop every 240 s: error-reporting poll + status refresh
    (core's health command flags servers silent > 10 min).
- `index.js` wiring (surgical; B9 behaviour intact): adapter starts
  only when the config carries a `telephony` block; adds
  GET /telephony/status and token-guarded POST /telephony/pair;
  adapter start is failure-isolated from the AMI daemon.
- Battery rig: `tools/lineagent/` (SIP handset), `battery/b10-1-battery.php`
  + `battery/b10-1-battery.sh` (dev), `battery/b10-1-prod.php` (prod).

**3. Companion fix — pre-existing B9 latent bug** (surfaced by the
regression battery): the daemon's GET /endpoints returned raw CLI text,
but core's `PbxCompanion::endpointsText()` reads a JSON `{text}` body,
so it always returned '' — the admin PBX page's endpoint list was
silently empty and the B9 battery's `endpoints_loaded_t38` flag could
never be true. The daemon now returns `{ok: true, text: …}`.
Companion-side only; no core edit.

### Adapter engineering notes (root-caused during the battery)

- **BridgeEnter is not an answer signal** with Local legs: Asterisk
  forms the bridge at dial time. Answer detection uses AMI **Newstate
  ChannelState 6 (Up)**.
- **Caller number race:** on Originate→Local legs, AMI Newchannel
  carries CallerIDNum `<unknown>`; the number lands on the channel a
  beat later. The adapter settles briefly, then reads it back with AMI
  **Getvar CALLERID(num)** on the entry leg.
- **Fast answers beat record creation** (number resolution settles
  first): early Newstate-Up events are buffered per uniqueid and
  adopted when the call record is created; started → ringing →
  answered posts are sequenced so core sees them in order.
- AMI **list actions (Status) resolve on the EventList-start packet**,
  which carries no per-channel state — a Status-based fallback was
  removed in favour of the event buffer.
- Dev runs **no persistent queue worker**: telephony events are
  processed by ProcessTelephonyEventJob on the `channel-webhooks`
  queue. The battery drains the queues bounded (dev only) before
  asserting; production's real workers process them continuously.
- **Webhook deliveries to private/loopback URLs are refused by core's
  SSRF guard by design** (`ssrf_blocked: refused_non_public_url`). In
  dev, dispatch is proven by the delivery rows; a 2xx end-to-end
  delivery needs a public webhook URL.

### Dev battery — 13/13 PASS (runs 7 and 8, identical)

Environment: telephony server **id 12 "Dev PBX Telephony"** (created via
ServiceServer model + issueServiceToken; token only in the dev
companion config, 600). Lines: ext 1001/1002 (device_ids pbx-line-1001/2).

1. **Shim** — PluginManager install → activate →
   ChannelPlugins::live('phone_bridge') true in a fresh process; class
   loads; isConfigured true; schema empty. PASS
2. **Adapter** — bootstrap 200 (server 12), public-url accepted,
   Reverb auth + subscription live. PASS
2b. **Health** — `telephony:servers-health` keeps the server healthy
   (0 marked unhealthy). PASS
3. **Pairing round-trip** — code issued via PhoneBridgePairings (admin
   user 1; admins hold every live feature on their own workspace, plan
   flags stay OFF) → adapter POST pair → **connection 87** "SIP Line
   1001" on server 12; GET connections/87 matches. PASS
3b. **Wrong code refused** — core `422 pair_code_invalid`. PASS
3c. **Flow** — flow **265** "B10 Battery Inbound" compiled **ready**,
   servable; assigned to connection 87 (inbound_mode=flow,
   record_calls=true) via PhoneBridgeConfigWriter. PASS
4a. **Inbound call** — call **132**: from **+923009876543**, state
   ended, outcome **answered_by_agent**, call_events ringing →
   answered, recording uploaded (call_uploads row, calls.recording_file_id
   set), **recording.ready webhook delivery dispatched** (delivery row;
   SSRF refusal on the private target is core working as designed). PASS
4b. **Compiled flow fetch** — adapter fetched flows/265/compiled
   (200, etag `W/"f265-v1"`) + facts for the inbound call; repeat fetch
   304 from cache. PASS
4c. **Outbound** — core command path (test_call + DialCommand::forFlow,
   origin api) → adapter originated via AMI → calls ended
   answered_by_agent with recordings uploaded. PASS
5a. **Balancing pick** — dummy server **id 13** (capacity 500, no
   adapter) registered → TelephonyServerAssigner pick = dummy. PASS
5b. **Placement** — line 1002 pairing claimed with
   accepts_server_assignment → **connection 88 landed on dummy 13**
   (server_changed=true). PASS
5c. **Disable move** — dummy disabled → assigner moved connection 88
   to an eligible server (11). Note: core's telephony pool is shared
   across adapter kinds — the modem server is a legitimate assignee by
   core design; the adapter (server 12 token) correctly gets 403
   connection_not_on_server for status posts about connection 88. PASS
7. **UI sweep** — guest /admin/service-servers/telephony 302; admin
   telephony page, plugins list (shows "Phone Bridge"), connection
   page, call-logs all 200; tenant connection page **403** (plan flag
   off — correct); tenant test-call POST refused (302). Tenant
   /call-logs is 200 because gsm_modem is live and in that tenant's
   plan — recorded honestly, not a phone_bridge leak. PASS

**Regressions on dev:** B10 DTMF battery **5/5**; B9 PBX battery
install/seed/apply/ui **all green** (including endpoints_loaded_t38
after the /endpoints fix above).

### Production — installed and verified 2026-11-19

- **Backup first:** backup.sh status=OK, push=OK; artifacts verified
  substantively (gzip -t, tar -t, real MySQL dump of `zender`).
- **Shim:** PluginManager **zip install** (phone_bridge-1.0.0.zip) →
  active. **www-data fresh-process probe:** plugin active,
  ChannelPlugins::live('phone_bridge') true, class loads, isConfigured
  true. Installed files root:root 644/755 (zip route normalises).
  Baked into the host build tree
  `~/sendqon-build/src/app/Plugins/Channels/PhoneBridge/`
  (root:root 644/755, md5-verified against canonical source).
- **Telephony server:** NEW server **id 8 "PBX Telephony"** created via
  the ServiceServer model + issueServiceToken; the plain token went
  only into the prod companion config (600). Pre-existing server 7
  "Primary Telephony (Own)" is the modem daemon's server (base_url
  sendqon-modem-daemon, token already issued to that consumer) —
  **untouched**, still pending. Schema note: prod `service_servers`
  has no `transport` column (dev does); registration used only
  prod-supported fields.
- **Adapter deploy:** pbx-src synced byte-identical to canonical
  (src + asterisk); `servers/docker-compose.yml` and `pbx/config.json`
  backed up (`*.bak-20261119-b101`); telephony block merged into the
  prod companion config (laravel_url http://sendqon, lines: [] —
  no device paired in production yet; pairing a real phone is B10.2).
  The prod compose build hung on the sandbox apt/DNS path again (same
  as B10.0) and was killed; **only sendqon-pbx was recreated**, from
  the host-store image `sendqon-pbx:1.0.0` (`8c2529f0bfb7`, dev-built
  from byte-identical source; content verified in-image: adapter +
  endpoints fix present; dev DTMF battery 5/5 on this image). The
  companion's /data and config.json mounts survived; the web, queue,
  scheduler, reverb and DB containers were never touched.
- **Prod verification:**
  - Adapter: bootstrap complete (**server_id 8**, connections 0),
    Reverb connected + subscribed to
    `private-telephony.server.8.commands`; /telephony/status clean
    (enabled, no errors); companion /health ok, AMI connected.
  - Core: server 8 **healthy** after `telephony:servers-health`,
    version 1.0.0 recorded, tunnel_status off, load 0.
  - **DTMF battery against prod sendqon-pbx: 5/5** (Asterisk PID
    stable at 17, 0 exit lines).
  - pbx plugin www-data probe: active, configured, companion health ok.
  - **0 tenant rows:** channel_connections 0, calls 0, pbx extensions /
    queues / ivrs / trunks 0.
  - **Plan flags untouched:** phone_bridge = false on all 7 plans.
  - Site `/` and `/login`: HTTP 200.
- **Rollback:** deactivate/uninstall the shim + restore
  `docker-compose.yml.bak-20261119-b101` / `pbx/config.json.bak-20261119-b101`
  and recreate sendqon-pbx.

### Deviations

- /endpoints JSON-shape fix in the companion (above) — companion-side
  only, no core PHP edit.
- Battery item 5c assertion relaxed to "moved to an eligible telephony
  server" (shared pool is core's design, not an adapter defect).
- Tenant /call-logs 200 on dev is gsm_modem-driven (above).
- **No PATCH-REGISTER proposals:** the contract was fully satisfiable
  adapter-side; no core PHP change was needed.

### Pushes

- Plugin source → Sendqon branch `plugin-phone_bridge` (plugins/phone_bridge/)
- Companion changes → Sendqon branch `companion-pbx` (companions/pbx/)
- This report → Sendqon `rebuild-tree` (planning/) and rektrs-workspace `main`

**Status: COMPLETE (completed by the parent agent after the lane
halted).** The lane's git fetch was flagged by an execution-risk check
and it halted the pushes on its own authority. The parent agent then
verified the local trees (companion diff = exactly the lane's adapter
files; secret-scan clean — no tokens in any pushed file) and completed
the pushes under the programme's standing push-as-you-go mandate, all
ls-remote verified: plugin source → `plugin-phone_bridge` @ `f72c105`;
companion changes → `companion-pbx` @ `c190838` (on top of B10.0's
`11544d4`); this report → `rebuild-tree` + rektrs-workspace `main`
(hashes in the push log of the completing session).

### Left for later phases (STOP gates respected)

- **B10.2** — pair a real phone (device_pin flow) against production
  server 8 and prove a real call. ← next gate
- **B10.3** — ESP32 device kind.
- **B10.4** — softphone page.
- **B10.5** — compiled-flow execution (adapter currently fetches and
  caches compiled flow + facts + prompts; calls follow the Asterisk
  path).
- Dial modes agent/stream/verification: logged as later-phase by the
  adapter (flow/api modes handled).
- Plan flags / pricing: owner's decision, untouched.
