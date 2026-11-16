# PAID PLUGIN SPEC — GSM Modems (telephony channel) — **own daemon + Asterisk route**

- **Vendor price:** $100 (reduced for Extended holders, amount
  unstated). **Version:** v1.0.4 in the demo (Lane 4 §C); portal card
  shows no version/date.
- **Portal:** https://products.titansys.dev/zender/gsm-modems/
- **Source status:** **explicitly NO Modem App source** — "To brand or
  customize the app, use the Modem App builder in your buyer
  dashboard." Telephony server also prebuilt. We do not buy it.

## Purpose
Send texts, **flash SMS** and USSD through your own GSM modem lines,
with calls on voice-capable lines.

## Features
Standard and **flash SMS** through modem lines, including on
campaigns (flash is impossible via Android SIMs — this is the route
for it, with the aggregator/SMPP route). USSD requests from the USSD
tab on supporting lines (USSD may need 2G/3G fallback or carrier
USSD-over-IMS). **Calls on voice lines:** agents answer/place calls
in Messenger; call flows can answer, play prompts, record and
transfer to an agent. **Per-site Modem App:** branded builds from the
buyer dashboard for Windows / Linux x64 / Linux ARM64; it runs on the
computer hosting the modems and pairs with an **8-character code**.
The download includes the **telephony server** (Linux x86-64 +
ARM64); multiple servers register — devices go to the least loaded
and move off a disabled server; the same service also powers Phone
Bridge. Plan control: enable GSM Modems + limits per plan; voice
needs the "GSM Modem Calling" plan switch; each line shows its
readiness.

## Supported modem profiles (vendor-documented)
- **SIM7600G-H** — LTE texts, flash SMS, USSD, call detection; calling
  on lines reporting voice capability.
- **SIM800C** — SMS only, 2G networks only.
- **A7670 and EG25-G — NOT supported** today.

(The SIM7600 family is also our own preferred pilot hardware —
master plan Addendum 4. Same hardware choice, our own software.)

## Workflow
Extract ZIP → upload plugin.zip → activate → save settings → enable
on eligible plans → run the telephony server on a Linux VPS, register
in Admin → build the Modem App in the buyer dashboard → upload it in
the plugin's Configure page → install on the modem computer → connect
via Channels → pair with the 8-character code → check each line's
readiness.

## Logic / technology
The Modem App is a **daemon, not an Android APK**. It drives modems
(AT commands — sequences UNVERIFIED, the daemon is closed) and talks
to the Telephony Server, which talks to core over the
`v1/internal/telephony` contract (`04-NO-SOURCE/telephony-server.md`).
Flow nodes "GSM Modem" and webhook family `gsm_modem.message.*` are
core surfaces.

## Data it touches
`devices`-adjacent line records, `calls` family (voice),
`phone_bridge_pairings` pattern for pairing, message tables, USSD
tables.

## Dependencies
Telephony Server; a computer that stays online with supported modems
+ active SIMs; plan switches (GSM Modems; GSM Modem Calling for voice).

## OUR REBUILD SPEC
- **Own Modem daemon:** a small AT-command daemon for SIM7600G-H
  (texts, flash SMS, USSD, call detect/voice) on Linux (x64/ARM64 —
  Raspberry Pi class hardware included), pairing by code, reporting
  per-line readiness. AT sequences are standard for this chipset
  family (documented by the module vendor — not copied from Zender).
- **Voice:** the daemon hands voice lines to our Asterisk PBX module
  (see `phone-bridge.md`) rather than re-implementing the vendor's
  telephony server.
- **Plugin type:** `channel` (channel key `gsm_modem`) for the
  Zender-side surface: lines, readiness, send nodes, webhooks.
- **Priority:** Phase 5 (with telephony). SMS/USSD/flash part can land
  earlier than voice if a tenant needs modem SMS.
- **Difficulty:** Medium for SMS/USSD/flash daemon; Hard when voice is
  included (folds into the PBX module's difficulty).
