# NO-SOURCE — Telephony Server (Phone Bridge + GSM Modems)

Full evidence: Lane 6 §3 + Lane 3 + Lane 5. **We own nothing of this
component** — the plugins were not bought; there are no binaries in
our tree. Everything below is the documented behaviour plus the
contract core PHP exposes.

## What it is
One closed **Go telephony service** powering two paid plugins:
**Phone Bridge** ($100 — a phone becomes a PBX line via an ESP32
Bridge Adapter or a Windows App) and **GSM Modems** ($100 — GSM
modems on a computer become lines). Agents answer/place calls in the
browser Messenger; voice flows (IVR menus, prompts, record, transfer)
execute on this server. Vendor's own words: "The telephony server
programs, the Windows App and the adapter firmware are delivered
prebuilt." The Modem App source is likewise excluded.

## Interface evidence (core contract — routes/api.php comment cites
`docs/api/telephony-v1.yaml`)
Prefix `v1/internal/telephony`, middleware
`channel:phone_bridge,gsm_modem` + `telephony.server`:
- `GET bootstrap` — service fetches its config/assignments
- `POST pair` — device pairing claim (8-character codes;
  `phone_bridge_pairings`)
- `POST events` — call/device event ingest
- `GET connections/{connection_id}` — one line/device's detail
- `GET ussd/{ussd_id}` — run a USSD session on a modem line
- `GET outbound/{message_id}` — outbound SMS content to send via
  phone/modem
- `GET flows/{flow_id}/facts` + `GET flows/{flow_id}/compiled` —
  **core compiles voice flows; the service executes them locally**
  (this is why IVR lives server-side)
- `GET prompts/{asset_id}` — voice prompt audio download
- `POST media` — recordings/media uploaded back to core
- `POST broadcasting/auth` — Reverb auth (commands go out via
  `TelephonyCommandPublisher` / `PusherTelephonyTransport`)
- `PUT public-url` — service reports its public URL
- `GET error-reporting` / `POST error-reports` — the shared relay

Bootstrap: `TelephonyServerKind::configJson()` =
`{ purchase_code (placeholder
REPLACE_ME_WITH_GSM_MODEMS_OR_PHONE_BRIDGE_LICENSE_CODE), server:
{ public_host, public_port, service_token }, laravel: { url } }`.
Public host/port are mandatory (1–65535). The demo server showed host
`:443` masked with a **"Quick Tunnel"** option Off — a tunnel mode
exists for public reachability. Device apps discover the current host
via `v1/telephony/device/host` (signed + public variants; code
comment cites "PROTOCOL.md section 7") and update via
`v1/telephony/device/update` + `/update/download`.

Balancing: `TelephonyServerAssigner` + `TelephonyBalancingSettings`;
`telephony:balance`, `telephony:servers-health`; devices land on the
least-loaded server and move off disabled ones. Demo capacity:
**0/500 devices** per telephony server.

Call surface: webhooks `call.started/answered/ended`,
`voicemail.received`, `recording.ready`, `transcript.ready`,
`media_stream.requested`; families `phone_bridge.message.*`,
`gsm_modem.message.*`. Data: `calls`, `call_events`,
`call_transcripts`, `call_agent_rings`, `call_media_streams`,
`call_uploads`. Minutes billing is **core** (`GsmModemMinutes`,
`PhoneBridgeMinutes`; `phone-bridge:publish-minutes` monthly);
`phone-bridge:sms-outbox` runs every minute.

**Bridge Adapter (ESP32):** recommended board **Waveshare
ESP32-WROVER-E-N16R8** (16MB flash, 8MB PSRAM); only the original
ESP32 has Bluetooth Classic (needed for calls) — S2/S3/C3 do not work.
Firmware is flashed from the browser (core ships `esptool-js` +
`app/Services/Telephony/BridgeFlashing.php`). iPhone: calls only;
texts need Android. One agent = one call at a time.

**Modem App:** per-site branded **daemon** (not an APK) — Windows /
Linux x64 / Linux ARM64 from the buyer dashboard; pairs with an
8-character code. Supported profiles: **SIM7600G-H** (LTE texts,
flash SMS, USSD, call detection, voice on capable lines), **SIM800C**
(SMS only, 2G only); A7670 / EG25-G not supported. USSD may need
2G/3G fallback or carrier USSD-over-IMS.

## UNVERIFIED
- The service's media stack (SIP/RTP/WebRTC codecs, jitter handling).
- ESP32 firmware's Bluetooth profile implementation (HFP/HSP detail);
  the Windows App's internal Bluetooth stack.
- Modem App AT-command sequences for SIM7600/SIM800.
- Quick Tunnel's mechanism (vendor relay vs standard tunnel).
- `docs/api/telephony-v1.yaml` itself: referenced by route comments
  but **not present in the tree** (only `resources/contracts/
  public-v1.yaml` was found) — exact payload schemas must be read
  from core controllers at build time.

## Clean-room replacement spec — our Asterisk PBX module
Owner decision (master plan Addenda 1–7): we do **not** clone this
service. We build a **PBX module inside Zender** (extensions, IVR
builder, queues, agents, recordings, call logs, click-to-call)
controlling open-source **Asterisk** via AMI/ARI — invisible to
tenants, the same layering the vendor uses, with an open engine.

Two integration halves:
1. **Zender side:** our module produces the core-expected artefacts —
   `calls`/`call_events`/`call_transcripts` data, the `call.*` /
   `recording.ready` / `transcript.ready` webhooks, minutes billing —
   and executes core-compiled voice flows (`flows/{id}/compiled`,
   prompts via `prompts/{asset_id}`) as Asterisk ARI applications.
   Agent leg: WebRTC browser softphone → Asterisk; one-call-per-agent
   enforced by the queue.
2. **Line side (Addenda routes, in order):**
   - **DID/SIP trunk first** (Addendum 7): customers call the DID →
     Asterisk → queue → free agent's dashboard. No phone needed.
     Pakistan DID pricing: Addendum 8 (PTCL quote-based; online
     ~$55–75/month).
   - **GSM gateway device** (Addendum 2): GoIP / Yeastar TG (4G LTE +
     VoLTE) on LAN as a SIP trunk; 1 SIM = 1 concurrent call.
   - **USB dongle pilot** (Addendum 3): Asterisk `chan_dongle` with
     Huawei 3G dongles (E1550/E173/E175X) — voice + SMS + USSD.
   - **SIM7600 board** (Addendum 4, preferred pilot): Waveshare
     SIM7600 4G HAT/USB under our own AT daemon.
   - **Bluetooth phone bridge** (Addenda 4/5): Asterisk `chan_mobile`
     (HFP) — the open Phone Bridge equivalent; pilot/lab grade.
   - **Conference bridge** (Addendum 6): our Android app as default
     dialer auto-answers, calls the DID, merges — needs a real
     phone+SIM pilot proof (carrier conference support varies).
     Simpler variant: carrier call forwarding straight to the DID.

**PTA note (Addendum 1):** selling PBX as a service needs a PTA
licensing check first; own use is different.

## Difficulty / risk
**Hard — deliberately.** Voice quality, echo, NAT/WebRTC and carrier
quirks are the real work; the PBX module is a whole product. Phase 5.
Scope risk is the main risk: messaging business first, PBX second.
