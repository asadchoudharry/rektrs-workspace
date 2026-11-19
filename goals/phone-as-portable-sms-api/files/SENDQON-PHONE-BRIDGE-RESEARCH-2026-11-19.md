# SENDQON — PHONE BRIDGE RESEARCH (B10)

**Date:** 2026-11-19 · **Status:** RESEARCH ONLY — no production changes, no builds.
Owner order (2026-11-19): *"Phone Bridge system bhi banao full advace kisam ka
vendor sy bhi bara full research ker k."*
**Grading:** ✅ official (vendor/regulator/project primary source) ·
📰 industry (reputable third-party, reseller, community, peer-reviewed) ·
❓ unverified (single-source, marketing, or our extrapolation — never build on
it without a test). All web sources accessed 2026-11-19.

---

## Executive verdict

**Build it — and the surprising news is how much of it core already is.**
The vendor's $100 Phone Bridge plugin is mostly a *switch* plus one closed
Go "Telephony Server". Zender core already ships the switch's entire
server side: the telephony tables (`calls`, `call_events`,
`call_transcripts`, `call_agent_rings`, `call_media_streams`,
`phone_bridge_pairings`, `voice_prompts`, `voice_flow_versions`), 8-character
pairing, telephony-server registration with least-loaded balancing
(`TelephonyServerAssigner`, `telephony:balance`, capacity 500/server),
**core-compiled voice flows** (core compiles, the server executes:
`flows/{id}/compiled`, prompts via `prompts/{asset_id}`), call webhooks
(`call.*`, `recording.ready`, `transcript.ready`), **minutes billing in
core** (`PhoneBridgeMinutes`, monthly `phone-bridge:publish-minutes`), OTP
voice channels, and even the ESP32 browser-flashing service
(`BridgeFlashing` + `esptool-js`). What we must actually build is the
*server the vendor kept closed* — and we already own most of one: the B9
PBX companion (Asterisk + AMI daemon). **B10 = a thin `phone_bridge`
channel shim (the `gsm_modem` pattern) + the PBX companion grown into
core's telephony server + a source-built Asterisk 22 + the line-side
routes below.**

Five findings decide the design:

1. **The B9 IVR digit-crash is almost certainly a known upstream bug, not
   a mystery.** Asterisk issue **#566**: SIGSEGV on DTMF when **no
   `res_timing_*` module is loaded** — listed for **20.6.0** (our exact
   version), in Docker, "constant", silent, on first digit in a menu. ✅
   The 30-second check (`module show like timing`) comes before any
   rebuild. Then: source-build **Asterisk 22 LTS** (20.x left full support
   2026-10-19 ✅) with `chan_websocket` + `chan_audiosocket` explicitly
   enabled, and move IVR logic into **our own process** (ARI
   `ChannelDtmfReceived` interim; `chan_websocket` `DTMF_END` events as
   the target). FreeSWITCH is Plan B, not the first move.
2. **The Android conference bridge (Addendum 6) is the only software-only
   way to bridge a SIM call — and it is conditional.** Android gives a
   third-party app **no** access to cellular call audio: downlink capture
   needs `CAPTURE_AUDIO_OUTPUT` ("reserved for system components") ✅ and
   uplink injection has no API ✅. A **self-managed ConnectionService
   cannot touch a real SIM call at all** ✅ — that route is dead. What
   works: our app as **default dialer** answers via `InCallService`,
   places a second call to our number, and the **carrier** merges them.
   Merge availability is decided by the carrier/OEM, not by us ✅/📰 —
   viable as the primary route **only on a tested fleet** (known phone +
   Jazz/Zong SIM with 3-way calling confirmed). The owner's phone is the
   gate, exactly as Addendum 6 warned.
3. **For vendor parity, the ESP32 route is real and ownable; the Windows
   app route is a trap.** Espressif's official ESP-IDF HFP-HF stack gives
   full call control + DTMF + SCO audio on the **original ESP32 only**
   (WROVER-E-N16R8; S3/C3 are BLE-only and physically cannot do HFP) ✅.
   On stock Windows, a third-party app **cannot extract a phone's HFP
   audio** to a PBX (Microsoft's own Phone Link does the single-user job
   and keeps the media path closed) 📰 — we will not promise a Windows
   bridge. `chan_mobile` still ships in Asterisk 20/21/22 but is
   unmaintained and dongle-fragile ✅/📰 — lab fallback only, as Addendum
   4/5 already judged.
4. **The browser softphone is standard work:** JsSIP (alive; SIP.js's npm
   build is a stalled 2022 artefact) 📰 + PJSIP WSS + `webrtc=yes` +
   `codec_opus` + **coturn from day one**. Chrome-first; Safari
   best-effort and device-tested.
5. **Urdu voice honesty:** peer-reviewed telephonic Urdu WER for Whisper
   Large is **≈46.6%** 📰 (CHiPSAL 2025) — transcripts are for search,
   summaries and agent-assist, **never** sold as verbatim records.
   Local Whisper on offbox-1 (2 OCPU) is a batch queue, not a per-call
   feature ❓ (extrapolation, labelled). API STT first for Urdu;
   **recorded human prompts** for IVR menus, cloud Urdu TTS (Azure
   ur-PK first on evidence) only for dynamic fragments.

**The open market space (📰 analysis of §8):** nobody verified offers all
four at once — (1) the customer's *existing phone + SIM + number* stays
the line, (2) exposed as a *real PBX trunk* (IVR, queues, recording,
browser agents), (3) at single-line cost, (4) outside the US/CA
virtual-number world. That intersection is the product.

**Compliance posture (§9):** PTA's grey-traffic enforcement targets
international/third-party traffic bypassing LDI gateways at SIM-bank
scale (Nov 2025 raids: 682 SIMs + 128/256-port gateways) ✅. An
own-SIM/own-calls bridge shares none of those triggers — but **PTA
publishes no own-SIM safe harbour** ❓, recording law is genuinely
unsettled in accessible sources ❓, and the CVAS Voice licence route is
currently **suspended** ✅. So: build now, design to the safe line
(announce-and-log recording, true CLI, no third-party termination), and
gate the *commercial launch* — not the build — on a Pakistani counsel
opinion, the same posture as the aggregator track.

---

## 1. What core already provides vs what B10 must supply

| Layer | Core already ships ✅ (from audit + telephony spec) | B10 supplies |
|---|---|---|
| Channel switch | `phone_bridge` pre-registered as a telephony channel; `ChannelPlugins::live('phone_bridge')` gate (same pattern as our `gsm_modem` shim) | Thin channel shim plugin (plugin.json + main class — the B9 GsmModem shape) |
| Pairing | 8-char codes, `phone_bridge_pairings`, device host discovery/update endpoints (`v1/telephony/device/*`) | Nothing server-side; app/adapter claim flow |
| Telephony servers | Registration, bootstrap config (`TelephonyServerKind::configJson()`), least-loaded assignment + move-off-disabled, health commands, 500 devices/server | Our companion registers as a telephony server |
| Internal API | `v1/internal/telephony/*`: bootstrap, pair, events, connections, outbound, flows facts+compiled, prompts, media upload, broadcasting auth, public-url, error relay | Our adapter *consumes* this contract (the vendor server did the same) |
| Voice flows | Core **compiles** flows (`voice_flow_versions`); flow editor already has Phone Bridge send nodes | Adapter **executes** compiled flows on Asterisk (ARI → chan_websocket) |
| Calls data | `calls`, `call_events`, `call_agent_rings`, `call_media_streams`, `call_uploads` + webhooks `call.started/answered/ended`, `voicemail.received`, `recording.ready`, `transcript.ready` | Adapter writes events/media through the contract; PBX recordings land via `POST media` |
| Billing | Minutes in core (`PhoneBridgeMinutes`, `phone-bridge:publish-minutes`, `phone-bridge:sms-outbox` per minute) | Nothing — plan flag + pricing is the owner's decision |
| Plan gates | Per-plan on/off + limits for `phone_bridge` (core) | Nothing |
| OTP | Voice-call OTP is a core OTP channel | Nothing — lights up when the channel is live |
| ESP32 flashing | `BridgeFlashing` service + `esptool-js` in core | Our open firmware image to flash |
| Agent surface | Messenger call UI is the vendor's SPA surface for *its* server; our panel has no softphone | JsSIP softphone page in the `pbx` plugin (Blade, by URL — plugins cannot add sidebar entries) |
| Voice engine | — | Asterisk 22 (source build) inside the existing PBX companion + ARI/websocket adapter daemon |
| Line side | — | Android Bridge Mode (conference) · ESP32 adapter · GSM gateway/DID trunks (already PBX routes) · chan_mobile (lab) |

**Consequence:** B10 is *not* a second PBX. It is the B9 PBX finished —
the same companion, the same Asterisk, the same `pbx` plugin surfaces —
plus the telephony-contract adapter that lets core's own call log,
pairing, balancing, billing and compiled flows run on our engine instead
of the vendor's closed one. (B9's honest boundary stands corrected in one
place: core messenger call-log integration *does* belong to the
`phone_bridge` channel — B10 is precisely the phase that claims it.)

---

## 2. Parity+ matrix — every vendor feature, our route

| # | Vendor feature | Our route | Verdict |
|---|---|---|---|
| 1 | Phone as PBX line via ESP32 Bridge Adapter (Bluetooth) | Own ESP-IDF firmware on ESP32-WROVER-E-N16R8 (official HFP-HF stack ✅), flashed from the browser via core's `BridgeFlashing` | **Parity, exceeded**: firmware is ours/open — auditable, no licence entitlement, no vendor kill-switch |
| 2 | Phone as line via Windows App | **Not replicable on stock Windows**: SCO audio is unreachable to third-party apps; Phone Link owns the single-user version free 📰 | **Not worth it** — replaced by routes 3+1; revisit only if a custom-driver spike ever proves otherwise ❓ |
| 3 | Texts through the phone (Android) | Already live: our gateway app (B7/B7.1) sends/receives SMS on the same phone, multi-SIM, sim_fleet-managed | **Exceeded** (vendor: one phone app; ours: fleet intelligence on top) |
| 4 | iPhone = calls only | ESP32 route is phone-agnostic (HFP) → iPhone calls work; texts stay Android-only (same as vendor) | **Parity** |
| 5 | Browser calling in Messenger; call bar (Mute, Hold, keypad, Transfer, Hang Up) | JsSIP softphone in the panel (pbx plugin page): full call bar + blind/attended transfer + recording indicator + click-to-call from conversations | **Parity, exceeded** (recording indicator + conversation context; vendor bar has neither per its spec) |
| 6 | Voice flows answer incoming calls (menus, transfers, background steps e.g. text-the-caller, post-call branching) | Core-compiled flows executed by our adapter; background steps inherit the *whole* core flow engine (SMS/WhatsApp/email actions mid-call) | **Parity, exceeded** (cross-channel steps are native, not bolted on) |
| 7 | Call logs + recordings | Core `calls`/`call_events` + MixMonitor recordings via adapter `POST media` | **Parity** |
| 8 | Transcripts in the call log | STT pipeline (§6): API-first for Urdu, local Whisper batch for English; `transcript.ready` webhook | **Parity with an honesty label**: Urdu telephonic WER ≈46.6% 📰 — assist-grade, not verbatim |
| 9 | Multi-server least-loaded balancing; devices move off disabled servers | Core `TelephonyServerAssigner` — already implemented | **Parity for free** |
| 10 | Per-plan on/off + limits; plugin must be active for all incl. admins | Core plan machinery | **Parity for free** (pricing = owner decision) |
| 11 | One agent = one call at a time | PBX queue discipline + core `call_agent_rings` | **Parity** |
| 12 | 8-char pairing codes | Core pairing | **Parity for free** |
| 13 | Branded per-site device apps from the buyer dashboard | Our app is already Sendqon-branded, one build, server-driven config (B7.1) | **Exceeded** (no per-site build step at all) |
| 14 | App updates via licence entitlement; updates don't reconnect devices | Our §16 app-update offers (signed URL, client decides) | **Parity** |
| 15 | OTP delivery by voice call | Core OTP channel over the bridge line | **Parity for free** once live |
| 16 | Turning the plugin off keeps config + history | Plugin lifecycle (house pattern) | **Parity** |
| 17 | "Quick Tunnel" for server reachability (vendor demo) | Not needed: our companion is co-located with core on offbox-1; the ESP32/app reach core over the existing public HTTPS | **Exceeded** (one less moving part) |

**Explicitly not replicable / not promised:** a Windows desktop media
bridge (#2); any in-app capture or injection of SIM-call audio (§3c);
guaranteed conference merge on an untested carrier/OEM combination
(§3a); verbatim-grade Urdu transcripts (#8).

---

## 3. Line-side routes — how a call gets from a SIM into our Asterisk

### 3a. Android-app conference bridge (Addendum 6) — PRIMARY software route, conditional ✅/📰

**Mechanism (no audio ever touches the app):** our app holds the
**default dialer role** → `InCallService.onCallAdded()` fires for the
incoming SIM call → `Call.answer()` → `placeCall()` to our bridge number
(a DID, or our own GSM-modem line — §10) → when it connects,
`Call.conference()` / the conferenceable-calls list merges the legs →
the **carrier** mixes; the agent talks on the PBX leg; recording, IVR and
queues happen server-side. Outbound is the mirror: server signals the
app (persistent socket; FCM only as a reconnect kick), app places the
SIM call to the customer, then the PBX leg, then merges — the customer
sees the SIM's number.

Hard facts that shape it:

- **The dialer role is total.** ROLE_DIALER requires a real dial-pad UI
  and a *fully implemented* InCallService for **all** calls, or
  RoleManager removes the role automatically; emergency calls always go
  to the preloaded dialer ✅. Bridge Mode is therefore a real dialer
  inside our app (v5.3.0 scope, §10), not a background trick.
- **Build on `Call.answer()`, never `acceptRingingCall()`** — the latter
  is deprecated, needs `ANSWER_PHONE_CALLS`, and is privileged-caller
  restricted for self-managed calls ✅. `ANSWER_PHONE_CALLS` still
  exists on Android 12–15; the InCallService path is the supported one.
- **Merge is not ours to guarantee.** `getConferenceableCalls()` returns
  what the system ConnectionService + carrier *allow*; on GSM the
  network surfaces conferences already-merged, on CDMA-heritage networks
  merge is an explicit, sometimes 30–45 s-delayed step ✅. Industry
  evidence (TapeACall's support record — a shipping product living on
  this exact step): merge missing/greyed ≈ carrier 3-way calling not
  enabled on the line; prepaid/MVNO plans often have it off; carrier
  participant caps ~5–6 📰. **No source documents Jazz/Zong/PTML merge
  behaviour ❓ — the battery must prove it per carrier on real SIMs.**
- **Wake is solved by the role, not by push.** Telecom binds the
  InCallService before ringing; `CallScreeningService` (same app, second
  role) fires *before* ringing with the caller's number — the early
  server signal ✅. FCM high-priority is **not** a reliable control
  channel: Google deprioritises per-instance when messages don't surface
  notifications ✅. Design: persistent socket in a `phoneCall`-type
  foreground service + FCM as reconnect kick only.
- **Android 14/15 traps:** FGS must be typed (`phoneCall` needs
  `FOREGROUND_SERVICE_PHONE_CALL` + the dialer role ✅); Android 15
  forbids starting a `phoneCall` FGS from `BOOT_COMPLETED` — after a
  reboot the gateway stays down until another exempt trigger or a user
  launch ✅ (onboarding must say so). OEM battery managers (Xiaomi,
  Samsung, Oppo/Vivo/Huawei) kill background processes unless
  whitelisted — a per-OEM onboarding checklist is part of the feature 📰.
- **Quality/latency (honest):** two cellular legs in tandem = two codec
  hops and additive setup time (two call setups ≈ several seconds
  before the agent hears ringing); inbound leg is free to receive, the
  outbound leg to our number burns the phone's own bundle minutes —
  Addendum 6's "do calls ka kharcha", unchanged. Call-waiting behaviour
  inside an active bridged conference is **not documented ❓** — battery
  item. Caller DTMF reaching the PBX leg through a carrier conference
  is expected as network-carried audio/regenerated tones but is
  **unproven for PK carriers ❓** — battery item (if it fails, IVR on
  conference-bridged lines degrades to agent-side + voice-recognition
  menus; ESP32/GSM lines keep full DTMF).

**Verdict:** primary route for the *software-only* offer, sold honestly
as "works on tested phones/carriers" — the fleet model (a dedicated
phone per line, which is already our gateway-app model) fits it
perfectly.

### 3b. Bluetooth HFP — the parity route is ESP32; chan_mobile is lab; Windows is out

- **ESP32 adapter (vendor parity, ownable) ✅:** ESP-IDF ships the exact
  primitive — the `hfp_hf` example + HFP Client API (`dial`, `answer`,
  `reject`, `send_dtmf` AT+VTS, `query_current_calls` AT+CLCC, SCO audio
  with Voice-over-HCI PCM callbacks we can pipe onward over Wi-Fi).
  Community component `walinsky/a2dpSinkHfpClient` (A2DP+HFP+PBAP) is
  the closest reusable block 📰. **Radio law:** HFP is Bluetooth Classic
  (RFCOMM + SCO/eSCO); BLE has no HFP — only the **original ESP32**
  (WROOM/WROVER, BR/EDR+BLE) qualifies; S3/C3/C6 are BLE-only, S2 has no
  Bluetooth ✅/📰. The vendor's recommended board (Waveshare
  ESP32-WROVER-E-N16R8) is the right class; found listed at **₹1,015–
  1,432** (Indian resellers) and **CAD 41.11** (Newegg Canada) 📰 — **no
  Pakistani retail price was verified ❓**. Constraints to design
  around: a phone holds exactly **one** HFP connection (bridge *or*
  earbuds, not both) 📰; Bluetooth range ~10 m; the adapter + phone are
  a dedicated desk pair. Media path ESP32→Asterisk: RTP/SIP over Wi-Fi
  from our firmware (we own both ends).
- **chan_mobile (Linux/BlueZ) 📰:** still in the Asterisk tree for
  20/21/22 with *extended* support — **not deprecated** ✅ — but the
  core team's own words: "community supported with no active
  maintainer"; the one serious overhaul PR was closed by its author,
  who now keeps a private fork. Reliability is dongle roulette (CSR
  chipsets the safe bet, one adapter per phone, handset-specific
  success), and there is **no reliable incoming DTMF** on the mobile
  leg. Zero-cost lab proof only — Addendum 4/5's judgement stands.
- **Windows desktop bridge 📰:** Windows supports HFP as *Audio
  Gateway* for headsets inbox; as *Hands-Free unit to a phone* the
  capability exists only inside Microsoft's **Phone Link** (free,
  single user/phone/PC, no PBX leg). A hands-on 2026 investigation
  found the SCO path unreachable to third-party Windows apps (not
  enumerable via WASAPI/MME/DirectShow; the sanctioned WinRT API is
  call-control only). **No commercial Windows product pipes phone HFP
  audio into a PBX.** We do not build this in B10; the vendor's Windows
  app is the one feature we consciously leave unmatched (§2 #2).

### 3c. Self-managed ConnectionService — KILLED ✅

Officially a VoIP-only construct: an app creates Connections only for
calls on **its own** PhoneAccount and supplies their audio itself.
System telephony owns SIM calls; no public API lets a third party
create, adopt, route or tap a carrier Connection's media — and a
carrier call and a self-managed call cannot even run concurrently
(answering one ends the other). Any design sketch that "bridges the SIM
call through our ConnectionService" is fiction on modern Android.

### 3d. Direct SIM control for outbound — what the app can and cannot do ✅

The app **can** place SIM calls (`placeCall`, `CALL_PHONE`). It
**cannot** hear the far end or speak into the call: `VOICE_CALL` /
`VOICE_UPLINK` / `VOICE_DOWNLINK` capture requires
`CAPTURE_AUDIO_OUTPUT`, "reserved for use by system components and not
available to third-party applications" ✅; Android 10+ gives ordinary
apps silence when competing with a voice call ✅; no API targets the
telephony uplink for injection ✅ (the only "injection" is acoustic —
speaker next to mic — not a product). Therefore outbound agent calls
exist in exactly two shapes: **conference merge** (§3a) or an **external
HFP host** (§3b). This is the same hard wall recorded on 2026-11-13
(Addendum 5) — 2026 evidence changes nothing.

**Route order for B10 (revises Addenda order for the bridge product
only; DID-first still governs the PBX):** ① conference bridge on the
fleet phone (zero hardware, ships first, carrier-gated) → ② ESP32
adapter (full parity + DTMF certainty, desk lines) → ③ GSM gateway /
SIM7600 modem lines + DID trunks (already PBX routes; a bridge line is
just another trunk to the router, §7) → ④ chan_mobile (lab only).

---

## 4. The IVR/DTMF fix — root cause first, then outgrow the dialplan

**The B9 defect, re-read with 2026 evidence:** reproduced on `Read()`
and `Background`+`WaitExten`, Local and PJSIP channels, GSM and WAV
prompts, DTMF via AMI PlayDTMF, Dial `D()` and RFC 4733 — everything
non-interactive stable. That fingerprint (below the codec layer,
triggered by the *first digit*) matches **asterisk/asterisk issue
#566** ✅: *"Without res_timing modules loaded, Asterisk will segfault
when it receives DTMF on a call, such as in a dialplan menu"* —
versions **20.6.0** / 18.21.0, Docker, constant, no log line. The older
ASTERISK-28800 thread pins it to a null timer handle in DTMF emulation
(`ast_timer_set_rate(handle=0x0)`); reporters confirm *"Loading the
timer module eliminated the crash."* The defensive guard (log instead
of segfault) landed only in **20.19.0-rc1** — and note: the guard stops
the *crash*, DTMF emulation still needs the timer. Ubuntu 24.04 ships
exactly `asterisk 1:20.6.0~dfsg…` ✅ — our companion's package. Whether
*our* container actually lacks a loaded timing module is ❓ until the
check runs — but it is the prime suspect by a wide margin, and the
check costs 30 seconds.

**Ranked fix plan (this ordering is a B10 gate, §10 B10.0):**

1. **Diagnose today:** `module show like timing` in the companion; if
   empty → `module load res_timing_timerfd.so`, inspect `modules.conf`
   for selective-load/`noload` lines, re-run the exact B9 DTMF battery.
2. **Source-build Asterisk 22 LTS** in the companion's Docker build
   (pinned tarball; the community norm for production telephony 📰):
   20.x left full support 2026-10-19; 22.x is supported to 2028-10-16
   ✅. menuselect explicitly: `res_timing_timerfd`, `chan_pjsip`,
   `res_pjsip_transport_websocket`, `res_http_websocket`, `res_srtp`,
   `codec_opus`, `chan_audiosocket`, **`chan_websocket` (not in default
   menuselect!)**. This single move also buys: the #566 crash guard,
   AudioSocket DTMF forwarding (only exists ≥20.14/22.4 ✅ — on 20.6
   AudioSocket cannot forward digits at all), and chan_websocket.
3. **Move voice-flow logic into our own process anyway** (this is the
   strategic step, crash or no crash): core hands us *compiled* flows;
   our adapter should execute them, not a hand-written dialplan.
   - *Interim:* ARI/Stasis — Asterisk plays prompts (the path B9 proved
     stable), our daemon receives **`ChannelDtmfReceived`** events and
     runs the menu state machine. Asterisk's own ARI guide builds an
     attendant exactly this way ✅.
   - *Target:* **chan_websocket** (22.6+) — media + control over one
     WebSocket; emits **`DTMF_END` events with the digit**, plus
     `FLUSH_MEDIA` (barge-in), pause/continue and flow control;
     Asterisk handles packet timing; use slin/ulaw toward our app
     (Opus is passthrough — framing becomes ours) ✅. New in 2025 but
     first-party, in four release series, with an official sample repo
     and a documented Pipecat integration 📰.
   - *Fallback:* AudioSocket (TCP PCM + DTMF type `0x03`) — simpler,
     older, but we own the 20 ms pacing ✅.
   - ⚠️ Honest warning: if the crash is the null-timer path, it fires
     in the core when the DTMF frame is processed — possibly *before*
     any forwarding. **Fix the timer first, then offload.**
4. **FreeSWITCH sidecar = Plan B only.** MPL 1.1 (friendlier than
   GPLv2 inside a commercial product) ✅; IVR is genuinely first-class
   (`play_and_get_digits`, XML menus, ESL — a cleaner AMI analogue) ✅.
   But it is a second SIP stack, a second CDR/recording model, and
   weeks of learning curve to replace the one feature that is probably
   a one-line fix. Pilot it (voice-flows-only, SIP-trunked to
   Asterisk) **only if steps 1–3 fail the battery.** No official
   concurrency figures exist for either engine — every "10×" claim
   online is ❓.

---

## 5. Browser softphone — the agent's half of the bridge

- **Library: JsSIP** (vendored + pinned). Alive: npm 3.13.9, Oct 2026
  📰. SIP.js is not dead but its pipeline is stalled — GitHub tag
  0.21.3 (Mar 2025) never reached npm, which still serves the Oct 2022
  build ✅/📰. SIP.js only if we deliberately vendor the GitHub tag for
  its TypeScript ergonomics.
- **Asterisk side 📰 (consistent across current guides):** `http.conf`
  TLS on 8089 with a **trusted** cert (browsers silently refuse
  self-signed WSS); `pjsip.conf` `[transport-wss]` + endpoint
  `webrtc=yes` (sets rtcp_mux/AVPF/ICE/DTLS); modules
  `res_http_websocket`, `res_pjsip_transport_websocket`, `res_srtp`,
  `chan_pjsip`; **`codec_opus` actually loaded** (its absence is the
  most common instant-failure cause); `allow=opus,ulaw`.
- **Exposure design (our infra rule):** no new public ports on the PBX.
  WSS reaches agents **through the existing site** — Caddy already
  reverse-proxies `/app/*` + `/apps/*` to Reverb; the softphone's WSS
  path gets the same treatment to the companion on the internal
  network. SIP credentials per agent extension (the pbx plugin already
  issues per-extension secrets).
- **STUN/TURN:** STUN covers cone NAT (most home/office routers); TURN
  relay is required for symmetric NAT / CGNAT / UDP-blocking corporate
  firewalls — a real minority of agent networks will *never* connect
  without it (the "~15%" figure circulating is ❓; the direction is
  not). **coturn from day one**, co-located with Asterisk: it is not
  CPU/memory intensive (BigBlueButton's admin docs 📰); the real cost
  is relay bandwidth. Known topology trap 📰: coturn on the same LAN →
  Asterisk drops relayed DTLS ("Source not in ICE active candidate
  list") until a source-NAT rule is added — a named battery case.
  Opening coturn's public UDP range on offbox-1 is an **owner
  decision** (§11).
- **Call bar (all standard with JsSIP + PJSIP):** answer/reject, mute,
  hold/resume, DTMF keypad (RFC 4733; pin the Opus 48 kHz vs PCMU
  8 kHz telephone-event pairing in tests 📰), blind + attended
  transfer, hangup — plus our additions: recording indicator (a
  compliance surface, §9), live transcript pane (§6), AI-assist pane
  (§7), click-to-call from any conversation/contact.
- **Browser policy:** Chrome = supported; Safari = best-effort
  (consistently rated "partial" in current WebRTC guides 📰; no
  Asterisk-specific Safari defect found) — and a real iOS device is a
  named battery case, because Safari gives the least ICE/DTLS
  visibility when audio fails.

**Surface placement:** a new page in the existing `pbx` plugin (Blade,
reached by URL — the standing plugin-UI constraint), *not* a fork of
the vendor Messenger. The conversation screen links out to it with the
contact's number pre-filled (click-to-call), which delivers the
vendor's "call from the inbox" outcome without rebuilding the inbox.

---

## 6. Voice stack — prompts, TTS, transcription (with honest Urdu numbers)

**IVR prompts — recorded human audio is the primary, not the
fallback.** A menu is a finite set ("Press 1 for…", greetings, retry
lines). Recording it once with a real Urdu speaker gives the best
intelligibility, zero per-call cost, no API dependency — and playback
is the path B9 already proved stable. Cloud TTS is reserved for
**dynamic fragments** (names, amounts, dates, reference numbers),
pre-rendered/cached where values are predictable:

| TTS option | Urdu | Published price | Grade |
|---|---|---|---|
| Azure Speech | `ur-PK-UzmaNeural` + `ur-PK-AsadNeural` (strongest paper trail) ✅ | Neural $15/1M chars; 0.5M chars/mo free ✅ | No published Urdu quality eval ❓ |
| Google Cloud TTS | `ur-PK-Standard-A` (in production use in an open-source Urdu calling system 📰) | Standard $4/1M chars 📰 | Anecdotal intelligibility proof only |
| ElevenLabs | Urdu only on v3 (no low-latency Flash) 📰 | ≈$0.10/1K chars (v3) 📰 | No Urdu-specific evidence ❓ |
| Piper (local) | Catalogue status murky; voices carry non-commercial licences 📰 | Free if licence permits | ❓ — do not ship commercially without a licence check |
| Coqui XTTS-v2 | **No Urdu** in the official list 📰 | — | Dead end |

**Transcription — API-first for Urdu; local Whisper is batch-only:**

- Peer-reviewed reality 📰: CHiPSAL 2025 — Whisper Large zero-shot
  **Urdu broadcast WER ≈27.97%, telephonic ≈46.64%**; a fine-tuned
  small model did *worse* telephonically (62.01%). LaTeLL 2026 —
  large-v3-Turbo 25.33% on YouTube Urdu, 21.75% after LoRA +
  correction. Clean-clip best case (small sample): turbo 14.7%.
  Plus the script trap: spoken Urdu often returns in **Devanagari** —
  force `language=ur` and post-normalise, or transcripts are unusable.
- Local on offbox-1 (2 OCPU Ampere, 12 GB): large-v3-turbo int8 fits
  (~2.3 GB) 📰, but speed anchors (20-core ARM ≈ real-time; Pi 5 large
  = slower than real-time 📰) extrapolate to **~5–10× slower than real
  time on 2 cores ❓ (our extrapolation, labelled)** — a 10-minute call
  ≈ 1–1.5 h. That is an overnight batch queue for English/tolerant
  work, never a per-call promise. **Benchmark on the actual instance
  before quoting any turnaround.**
- APIs (published prices as read Nov 2026 📰, re-verify at purchase):
  AssemblyAI Universal-2 **$0.15/hr** (≈$0.0025/min, Urdu incl.,
  code-switching claims) · Deepgram Nova-3 **$0.0043/min** mono
  pre-recorded (Urdu in its language list) · OpenAI whisper-1
  **$0.006/min** · Google Chirp batch ≈**$0.003/min** (ur-PK ✅).
  **None publishes Urdu telephony WER** — B10.5 A/B-tests two of them
  on *our own recorded Urdu calls* before choosing.
- Product label, non-negotiable: transcripts ship as **"assist-grade"**
  (search, summaries, agent notes). The Gawah-grade record (§7) is the
  *recording + seal*, never the transcript alone.

---

## 7. The "vendor se bara" layer — multi-line intelligence (v2/v3, scoped, not v1)

The vendor sells a pipe. The moat is the *intelligence across lines* —
and most of it reuses machinery this programme already built:

- **One line registry, every line type.** Bridge phones (conference +
  ESP32), GSM modem lines (B9 daemon), SIP/DID trunks — one table in
  the `pbx` plugin, one router. An outbound call picks a route; an
  inbound DID can ring any of them. (v1 ships the registry + manual
  route choice; the intelligence below is layered on it.)
- **Call caps + warm-up in sim_fleet (v2).** sim_fleet already enforces
  SMS caps/health via core (`SimCaps`, prefix routes, health scores,
  auto-rest). The same per-SIM record gains **call fields**: daily
  minutes cap, concurrent-call = 1 by physics, a **warm-up ramp for
  calling** (a fresh SIM blasting 200 calls on day one is the exact
  silhouette §9 warns about — ramps are both a deliverability and a
  compliance feature), enforced by the adapter at call setup.
- **Line health score for calls (v2).** Mirror `wa_guard`'s pattern:
  deterministic, explainable — answer/seizure ratio, failed-setup
  streaks, merge-failure rate (conference lines), HFP disconnects
  (ESP32 lines), audio-quality proxies — advisory display, with
  auto-rest only through the line's own enable switch, exactly like
  sim_fleet's auto-rest discipline.
- **Least-cost routing for calls (v2).** Route order per destination:
  bridge SIM with bundle minutes (≈free) → GSM modem SIM → SIP trunk
  per-minute → (future) aggregator voice. The B9 trunk form's
  verified-CLI fields plug in here: present the tenant's *verified*
  number where the trunk supports it (PTA caveat from B9 stands —
  presenting a PK mobile CLI over an international trunk is a research
  item, not a launch promise).
- **Failover cascade for calls (v2).** Line busy / no-answer /
  merge-failed → next route, every attempt logged — `cascade`'s
  discipline moved from messages to calls.
- **AI first-answer, human conference-in (v2/v3 — innovation #3's
  ground floor).** B3's `ai_agents` gains a voice persona: the
  chan_websocket media path + STT/TTS loop lets the agent answer,
  qualify, and — at its limits — conference in a human from the queue
  (the Human-by-the-Minute shape: AI first, human by the minute, all
  inside one recorded call). The research for #3 already priced this;
  B10 builds its *plumbing*, not the marketplace.
- **Gawah mode (v3 — innovation #4's natural home).** A bridge call is
  already SIM-bound and recorded. One tap (or one IVR digit) switches
  the call into Gawah mode: the announcement plays (consent, §9), the
  promise segment is recorded, bound to both numbers + Raast titles,
  sealed, and both parties receive a verification code by SMS. No new
  transport is needed — Gawah is a *mode* of this system, which is why
  it was always going to live here.
- **Trust signals out (v3).** Call outcomes (answered, kept
  appointments, completed Gawahs) are exactly the behavioural history
  innovation #1 (Number Trust Bureau) eats. The bridge is the bureau's
  richest sensor; #6 Insaan Check's SIM-possession proof is a bridge
  primitive (we can *make* the number ring/answer on demand).

## 8. Commercial prior art — the ceiling, and the gap 📰

| Product | What it is | Published price | Why it isn't this |
|---|---|---|---|
| Yeastar TG series | SIP↔GSM/LTE gateway; SIMs sit **in the box**; trunk to any PBX; SMS on some models | TG100 MSRP $180, listed $209 (VoIP Supply) | SIM leaves the phone; $180+ per site before the PBX; no agent UI |
| Dinstar UC2000 | Same category, 1–32 channels, SIM-bank class at the top | 4-port £234.80 (UK); PK import listings 4-port ≈Rs 132,857, 16-ch ≈Rs 382,559 | Same structural limits; high-channel class is the hardware PTA raids associate with grey setups when misused |
| GoIP | Same category, 1–32 ch | PK listings: 1-ch ≈Rs 41,698 → 16-ch ≈Rs 215,616 | Fragmented white-label quality; same limits |
| Quo (ex-OpenPhone) | Shared-inbox business phone, apps/web | $15/$23/$35 per user/mo (annual); US/CA numbers only | Virtual number — a PK mobile number cannot be the line; no SIP devices at all |
| Grasshopper | Virtual system over existing phones | $14/$25/$55 per mo (annual); US/CA only | No SIM, no API; forwarding, not a trunk |
| MBX / NoPBX | "Mobile PBX": business number rings staff mobiles as real cellular calls | Not retrieved from an official page — not stated | New/ported number + carrier divert; no server media (no recording/whisper/WebRTC by construction) |
| Microsoft Phone Link | PC as the phone's hands-free unit | Free, built into Windows | 1 user ↔ 1 phone ↔ 1 PC; no PBX, no sharing, no export |
| ESP32 HFP→SIP products | Two 2026 marketing prototypes claim the Titan-style bridge (BOM ~20 CNY / "Pro $79/yr") | **Uncorroborated** ❓ | No shipped-unit or review evidence — concept being explored, not competition |

**The gap (analysis):** gateways own the trunk but not the phone;
Quo owns the inbox but not the number; Phone Link owns the desk but
not the team. **"Your number, your SIM, your phone — as a PBX line,
with IVR, queues, recording and browser agents, at single-line cost,
in a market where the mobile number *is* the business identity"** is
unoccupied by any verified offering. That — plus §7's intelligence —
is the "vendor se bara" claim we can defend.

## 9. Pakistan compliance — design lines, and the launch gate

**Grey traffic is a traffic pattern, not a device.** PTA's own
releases define the target: *concealment of incoming international
calls terminated through unauthorised channels, bypassing lawful LDI
gateway exchanges* ✅. Enforcement is current and hardware-focused —
12 Nov 2025, Lahore/Mansehra: **660 Jazz + 22 Ufone SIMs and 256- and
128-port gateways** seized in one "grey setup" ✅; 2020–2022, ~4.4M
SIMs blocked as grey suspects 📰. The triggers, synthesised: ①
third-party/international origin presented as local, ② LDI bypass,
③ SIM-bank scale on bulk SIMs, ④ concealed CLI.

**Our design shares none of the four** — a business's own,
biometrically-verified SIM, carrying its own domestic calls, originated
by its own staff, true caller ID, no international re-origination, no
third-party termination, single-line scale. **But:** no PTA publication
found creates an own-SIM safe harbour ❓, and PTA detection is
traffic-pattern-based — a single SIM carrying all-day call-centre
shaped traffic can *look* anomalous regardless of intent. Hence the
standing design rules (build-time, not launch-time):

1. Own lines only — a tenant bridges **their own** SIMs; the platform
   never terminates third-party traffic and never re-originates
   international calls. (This is also why §7's LCR never includes a
   "cheap international termination" leg.)
2. True CLI always; verified-CLI presentation only where a provider
   verified ownership (B9 rule), and the PK-mobile-over-international-
   trunk question stays closed until researched.
3. sim_fleet warm-up + caps apply to calls from day one (§7) — the
   anti-silhouette control.
4. Volume honesty: a bridge line is *a* line (1 SIM = 1 call). Tenants
   who need 16 concurrent calls get gateways/trunks, not 16 phones.

**Recording:** accessible sources **conflict** ❓. One line: PECA 2016
s.19 criminalises interception only "with dishonest intention", and a
Supreme Court judgment text retrieved in this research states
participant recording is generally not wiretapping, expressly
distinguishing *routine recordings in the ordinary course of duty*
from trap recordings 📰; admissibility remains strict (Qanun-e-
Shahadat + *Ishtiaq Ahmed Mirza* conditions). Another aggregator claims
all-party consent, citing a 2026 SC citation that **could not be
independently verified** ❓. **Design consequence (safe under both):**
every recorded call opens with the announcement ("this call may be
recorded…"), the announcement is logged with the recording, opt-out
routes to an unrecorded line. Never ship silent recording as a
default. (The Human-by-the-Minute research reached the same posture
independently.)

**Selling it as a service:** PTA's Class VAS page states the **Voice
and Data Class Licences are suspended until further notice**; Class
*Registration* (our aggregator category — SMS Aggregator, Rs 10,000,
from the feasibility report) does not cover voice ✅. Historic Voice
CVAS categories (card payphone, premium rate, trunk radio) do not
cleanly include hosted PBX SaaS ❓. Industry guidance puts a business
*using* VoIP under PSEB registration + PTA IP whitelisting, and CVAS
against *providing* voice services to others 📰. Selling **software a
business runs with its own SIM** sits near the use side; selling a
**hosted multi-tenant voice service** edges toward provision, whose
licence route is suspended — a structural risk to price into the
model. **Owner gate (§11): PTA Licensing Division clarification /
counsel opinion before any commercial voice launch** — the build does
not wait for it; the sale does. (Addendum 1's rule, unchanged.)

---

## 10. Build plan — B10 (phased; follows the programme's house discipline)

**Shape (decided by §1):** *extend, don't fork.* (i) NEW thin channel
plugin **`phone_bridge`** (the `gsm_modem` shim pattern — core owns the
surface); (ii) EXTEND the **`pbx`** plugin (line registry, softphone
page, route/LCR surfaces); (iii) EXTEND the **PBX companion** with a
telephony-adapter daemon speaking core's `v1/internal/telephony`
contract to Asterisk 22 via ARI/chan_websocket; (iv) NEW Bridge Mode in
our Android app (v5.3.0); (v) NEW ESP32 firmware. Core edits: **none
expected** — if the telephony contract needs an arm core lacks (the
B4 email `ServerMoves` precedent), it goes through PATCH-REGISTER
first, as always. Every phase: dev first → battery → fresh verified
backup → PluginManager install → www-data probe → UI-surface check →
build-tree bake → pushes ls-remote-verified.

| Phase | Scope | Gate / battery highlights | Effort (est.) |
|---|---|---|---|
| **B10.0 — IVR fix + Asterisk 22** | Timer diagnosis on the current companion; source-build Asterisk **22 LTS** Docker image (menuselect per §4); swap into the *dev* companion; B9 battery re-run | **DTMF battery green** (`Read`, `Background`+`WaitExten`, ARI DTMF events, RFC 4733 + inband, all codecs) + full B9 regression (bridge/queue/record/config-push) | ~1 lane-day |
| **B10.1 — Telephony adapter + shim** | `phone_bridge` shim plugin; adapter daemon in the companion: bootstrap/pair/events/media/prompts/compiled-flow fetch against core's contract; companion registers as a telephony server; a SIP line pairs end-to-end on dev (no phone hardware yet) | Pairing round-trip; call events land in core `calls`; recording upload → `recording.ready`; server health + least-loaded assignment with a second dummy server | ~3–5 lane-days |
| **B10.2 — Android Bridge Mode (app v5.3.0)** | Default-dialer shell (dial pad, recents, in-call UI for all calls); InCallService answer policy per line; screening-service early signal; persistent socket + `phoneCall` FGS; outbound signal→dial→merge; OEM-whitelist onboarding; bridge status surfaced in the app + server payload | **REAL-PHONE PROOF (non-negotiable):** owner's phone, Jazz + Zong SIMs — incoming bridge, outgoing bridge, merge success rate, caller DTMF through conference, call-waiting behaviour, reboot behaviour, battery cost. Merge failure on a carrier = that carrier ships ESP32-only, stated plainly | ~5–8 lane-days + owner phone sessions |
| **B10.3 — ESP32 adapter** | Firmware from ESP-IDF `hfp_hf` (+ the walinsky component evaluated first): HFP control + SCO→Wi-Fi RTP to Asterisk; Wi-Fi provisioning; browser flashing via core `BridgeFlashing`; 8-char pairing; desk-pair UX (one HFP slot notice) | Two boards on the bench: iPhone + Android pairing, DTMF both ways, audio quality vs the conference route, disconnect/reconnect, flash-from-browser round-trip | ~5–10 lane-days (firmware is the wild card) |
| **B10.4 — Browser softphone** | JsSIP vendored into the `pbx` plugin page; WSS via Caddy proxy (no new public PBX ports); coturn deployed (owner port decision); per-extension WebRTC credentials; full call bar + recording indicator + click-to-call from conversations | Agent battery: register/answer/place/hold/transfer/DTMF on Chrome; TURN-relay forced case + the same-LAN coturn NAT trap case; real Safari/iOS device case; two agents, one-call-each discipline | ~3–5 lane-days |
| **B10.5 — Voice flows + prompts + transcripts** | Adapter executes core-compiled flows (ARI interim → chan_websocket target); recorded Urdu prompt library + Azure TTS dynamic fragments (BYOK); STT pipeline: two API providers A/B-tested on our own recorded Urdu calls, local Whisper batch for English; `transcript.ready` wiring; assist-grade labelling in the call log | Flow battery: menu→queue, menu→text-the-caller step, post-call branch, voicemail; STT A/B report on real calls (WER measured, not quoted from brochures); Devanagari-script trap check | ~4–6 lane-days |
| **B10.6 — Production install** | Backups → installs → www-data probes → UI-surface sweep (channel pages, call log, softphone, admin) → production real-phone proof with the owner's number → plan flags left **OFF** (owner pricing, §11) | The full house battery, production edition; rollback rehearsed on dev first (uninstall → channel 404s → reinstall) | ~1–2 lane-days |

**v1 scope, explicitly:** one bridge line per phone (conference *or*
ESP32), inbound + outbound, IVR/voice flows, queues, recording,
softphone, call log + transcripts, pairing/balancing/billing via core.
**Not v1:** §7's intelligence (v2: caps/health/LCR/failover; v3: AI
first-answer production shape, Gawah mode, trust-signal export),
Windows bridge (not planned at all), chan_mobile beyond the lab,
FreeSWITCH (only on the §4 trigger).

**Total v1 estimate: ~4–7 weeks of lane time** (planning estimate ❓ —
firmware and the carrier-merge proof are the variance).

**The bridge number (a detail that saves real money):** the conference
leg needs a number our Asterisk can answer. Options: a DID (Addendum 8
band: DIDLogic from ~$8/mo; intl providers $56–75/mo; PTCL
quote-based) — **or zero-DID**: the phone calls the tenant's own
SIM7600 modem line (B9 daemon), which hands the call to Asterisk. The
zero-DID variant ships first for the pilot; a DID is a scale purchase.

**Hardware the owner must buy (only this):**

| Item | Qty | Evidence |
|---|---|---|
| Waveshare ESP32-WROVER-E-N16R8 (original ESP32 — **not** S3/C3) | 2 (bench + spare) | Listed ₹1,015–1,432 (India) / CAD 41.11 (Newegg CA) 📰; PK landed price ❓ — source locally or import |
| CSR-chipset USB Bluetooth dongle (chan_mobile lab only, optional) | 1 | voip-info compatibility table 📰 |
| Second cheap Android (two-line tests, optional) | 1 | Owner's Redmi Note 12 remains the primary proof device |
| DID for the bridge leg (optional at pilot; zero-DID variant exists) | 1 | Addendum 8 prices |

**Owner-only steps:** phone proof sessions (B10.2/B10.6 — his phone,
his SIMs); ESP32 purchase; coturn public-port approval (B10.4); STT +
Azure TTS accounts (BYOK, entered in-panel, never via chat — the B3
pattern); DID purchase if chosen; plan-flag/pricing decisions;
counsel opinion before commercial launch (§9).

## 11. Owner decisions the build will need

1. **GO on B10** with this phase order (B10.0's IVR fix is worth doing
   even if the rest pauses — it also completes B9's one open defect).
2. **Carrier facts:** is 3-way/conference calling enabled on his Jazz /
   Zong SIMs? (The B10.2 battery answers this empirically — no separate
   step, but a "no" from a carrier routes that carrier to ESP32-only.)
3. **ESP32 boards:** buy 2× WROVER-E-N16R8 (source/price per §10).
4. **coturn exposure:** approve public UDP (3478 + relay range) on
   offbox-1 for agent WebRTC — or restrict v1 agents to
   WireGuard/LAN-reachable networks (limits the tenant story).
5. **Voice AI accounts:** AssemblyAI *or* Deepgram (STT) + Azure Speech
   (TTS) — BYOK in-panel; free tiers first per the standing rule.
6. **Pricing:** `phone_bridge` plan flag + per-minute posture (core
   already meters minutes; the number is his).
7. **Launch gate, not build gate:** PTA/counsel opinion on (a) the
   own-SIM bridge posture, (b) hosted-voice/CVAS fit — before the
   first paying voice tenant (§9).

---

## Sources (all accessed 2026-11-19; grouped)

**Asterisk / IVR:** github.com/asterisk/asterisk issue #566 (20.6.0
DTMF segfault, no timing module) · issues-archive.asterisk.org
ASTERISK-28800 (null timer handle; module-load fix) ·
downloads.asterisk.org ChangeLogs 20.19.0-rc1 (#566 guard), 22.4.0 /
20.14.0 (AudioSocket DTMF), 22.6.0 (chan_websocket) ·
docs.asterisk.org (Versions lifecycle; Timing Interfaces; ARI DTMF
guide; AudioSocket; chan_websocket) · launchpad.net/ubuntu/noble
Asterisk 20.6.0 package · developer.signalwire.com (FreeSWITCH
dptools/ESL) · andrius.kair.page Pipecat/chan_websocket field notes ·
ictinnovations/asterisk-ai-voice-agent (AudioSocket + chan_websocket
in production-aimed OSS).
**Android:** developer.android.com (dialer app / ROLE_DIALER;
InCallService, TelecomManager, Call.Details, RemoteConference,
CallScreeningService references; audio-input sharing; FGS types;
Android 15 behaviour changes) · source.android.com (FSI limits; HFP
Audio Gateway) · firebase.google.com (FCM priority/deprioritisation) ·
support.google.com (Play SMS/Call Log policy) · TapeACall + RingOwl
support docs (carrier merge behaviour, industry).
**Bluetooth/ESP32:** community.asterisk.org (chan_mobile state, core
team) · voip-info.org chan_mobile (dongles, one-adapter-per-phone) ·
docs.espressif.com ESP-IDF HFP Client API + examples ·
components.espressif.com walinsky/a2dpSinkHfpClient ·
github.com/ikequan/fox-1 call-audio findings · learn.microsoft.com
(Windows Bluetooth classic audio; accessory guidelines) ·
github.com/famjam1/camrelay WINDOWS.md (SCO extraction investigation)
· newegg.ca + Hubtronics listings (WROVER-E-N16R8).
**Softphone/WebRTC:** npm/JsSIP + onSIP/SIP.js GitHub (release state) ·
configmanual.com + siperb.com (Asterisk WebRTC configuration) ·
docs.bigbluebutton.org (coturn footprint) · community.asterisk.org
(coturn same-LAN ICE trap).
**STT/TTS:** CHiPSAL 2025 + LaTeLL 2026 proceedings (Urdu WER) ·
AssemblyAI language/pricing pages · Deepgram pricing via Nov 2026
trackers · OpenAI pricing via trackers · Google Cloud Speech/TTS docs
· Microsoft Learn Azure Speech language support + pricing ·
loudness.ai Piper catalogue audit · Home Assistant community (Piper /
XTTS Urdu status).
**Prior art:** voipsupply.com + vdsae.com (Yeastar TG) · voipon.co.uk
(Dinstar) · shoppingbag.pk (GoIP/Dinstar PKR listings) · quo.com
pricing · grasshopper.com · mbx.onrelay.com · NoPBX Play listing.
**Pakistan compliance:** pta.gov.pk (grey-traffic raids 2025-11-13 +
2023; Class VAS suspension notice) · taazataren.com (grey definition;
SIM blocks) · shahbazshahlaw.com judgment copy (participant recording)
· recordinglaw.com (conflicting all-party claim — unverified) ·
uplyft.pk (PSEB/IP-whitelisting guidance) · this programme's
aggregator feasibility report (CVAS Registration facts).

## Unverified register (❓ — do not build on these)

1. That *our* container lacks a loaded timing module — prime suspect,
   30-second check in B10.0 decides.
2. Jazz/Zong/PTML conference-merge availability + caller-DTMF-through-
   conference + call-waiting-in-conference behaviour — real-SIM battery
   only.
3. Local Whisper speed on offbox-1 (5–10× slower than real time is an
   extrapolation from 20-core ARM + Pi 5 anchors).
4. Pakistani retail price for the WROVER-E-N16R8 board.
5. The two ESP32 HFP→SIP "products" (Xianma, IntenseCircuit) — no
   shipped evidence.
6. An own-SIM PTA safe harbour — none published; counsel opinion is
   the gate.
7. Pakistan recording law's settled position — sources conflict;
   announce-and-log is the design answer, not a legal conclusion.
8. Hosted-PBX-SaaS fit under CVAS — categories don't map cleanly and
   the Voice licence route is suspended.
9. All STT/TTS prices are as-read Nov 2026 via the cited pages/
   trackers — re-verify on the vendor's own page at purchase.
10. B10 effort figures are planning estimates; B10.3 firmware and the
    B10.2 carrier proof carry the variance.
