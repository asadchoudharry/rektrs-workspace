# PAID PLUGIN SPEC — Phone Bridge (telephony channel) — **we take a different route**

- **Vendor price:** $100 (reduced for Extended holders, amount
  unstated). **Version:** v1.0.4 in the demo (Lane 4 §C); the portal
  catalogue card shows no version/date.
- **Portal:** https://products.titansys.dev/zender/phone-bridge/
- **Source status:** **explicitly NO source** — "the telephony server
  programs, the Windows App and the adapter firmware are delivered
  prebuilt" (Lane 3). We do not buy it.

## Purpose
Relay calls and texts through your own phone, turning it into a PBX
line agents use from the browser Messenger.

## Features
Your own phone line via a **Bridge Adapter (ESP32)** or the
**Windows App**; texts require Android — **iPhone supports calls
only**. With several Telephony Servers, devices go to the least
loaded one and move off a disabled server. Browser calling: agents
answer/place calls in Messenger; the call bar offers Mute, Hold,
keypad, Transfer, Hang Up (needs HTTPS + microphone permission).
**Voice flows:** an incoming call rings the phone or is answered by a
flow — menus, transfers, background steps (e.g. text the caller), then
branching after the call. Call logs and recordings; recordings and
transcripts stay in the call log, never in flow variables. Plan
controls: per-plan on/off + limits; the plugin must be active for
every account including admins, and owners also need the plan switch.
Device apps are branded from the buyer dashboard's Builds area;
updates use the licence entitlement and do not reconnect devices on
their own. One agent handles one call at a time. Turning the plugin
off keeps saved configuration and history.

## Workflow
Extract ZIP → upload plugin.zip → activate → Configure + save
settings → Admin > Plans: turn on Phone Bridge + limits → build the
per-site device app in the buyer dashboard → upload it under the
plugin's Apps settings → install the included server program on a
Linux VPS per the setup guide → Channels > Connect Channel → connect
the phone.

## Logic / technology
Runs on the closed **Telephony Server** (shared with GSM Modems) —
full contract in `04-NO-SOURCE/telephony-server.md`. Recommended
adapter board: **Waveshare ESP32-WROVER-E-N16R8** (16MB flash, 8MB
PSRAM); only the original ESP32 has Bluetooth Classic, which calls
need — S2/S3/C3 boards do not work. Adapter firmware is flashed from
the browser (core ships `esptool-js` + `BridgeFlashing` service).
Pairing uses 8-character codes (`phone_bridge_pairings`). OTP can
deliver over Phone Bridge / Voice Call (core OTP channels).

## Data it touches
`calls`, `call_events`, `call_transcripts`, `call_agent_rings`,
`call_media_streams`, `call_uploads`, `phone_bridge_pairings`,
`voice_prompts`, `voice_flow_versions`, `voicemail_reads`.

## Dependencies
Telephony Server (companion); a supported phone + Bridge Adapter, or
a Windows 11 PC with Bluetooth; public HTTPS; plan switches.

## OUR REBUILD SPEC — different architecture, same outcome
Per master plan Addenda 1–7, we do **not** clone this plugin. We
build our own **PBX module inside Zender** (extensions, IVR builder,
queues, agents, recordings, call logs, click-to-call) controlling an
open-source **Asterisk** engine via AMI/ARI — the same layering the
vendor uses (PHP UI + separate voice engine), except our engine is
open. Line-side routes, in order:
1. **DID/SIP trunk first** (Addendum 7 rule) — customers call the DID
   directly; no phone needed at all.
2. **GSM gateway device** (GoIP / Yeastar TG, 4G LTE + VoLTE) as a SIP
   trunk — 1 SIM = 1 concurrent call (Addendum 2).
3. **USB dongle pilot** via Asterisk `chan_dongle` (Addendum 3).
4. **Bluetooth phone bridge** via Asterisk `chan_mobile` — the open
   equivalent of this plugin (Addendum 4/5).
5. **Conference bridge** in our own Android app (default dialer →
   auto-answer → second call to DID → merge) for the owner's
   "call straight to the dashboard" requirement (Addendum 6).
- **Plugin type (for the Zender-side module):** `channel`
  (channel key `phone_bridge` surface: calls, voice flows, minutes)
  + the Asterisk adapter service speaking core's telephony contract
  where practical (Lane 6 §3 spec).
- **PTA note:** selling PBX as a service to others needs a PTA
  licensing check first (Addendum 1).
- **Priority:** Phase 5 (hardware/telephony phase).
- **Difficulty:** Hard — a full product (queues/IVR/billing), chosen
  deliberately; voice quality/NAT/WebRTC are the real work.
