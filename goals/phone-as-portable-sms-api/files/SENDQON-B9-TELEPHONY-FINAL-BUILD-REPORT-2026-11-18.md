# Sendqon B9 — Telephony / Hardware / Final Items — Build Report

**Date:** 2026-11-18 · **Phase:** B9 (final phase of the own-plugins programme) · **Owner GO:** 2026-11-18 ~23:05 PKT
**Programme state:** all six §B9 items built and battery-proven on the dev copy; production installs are live-inert wherever an owner-gated input (trunk, hardware, upstream bind, activation decision) is still missing. Zero core edits in this phase — no PATCH-REGISTER entries were needed.

---

## Item 1 — PBX / Call Centre module + own Asterisk companion ✅ (live-inert)

**Built**
- **Companion** (`companions/pbx/`): Asterisk 20.6.0 in Docker (Ubuntu 24.04 package — Debian bookworm/trixie ship no Asterisk package at all) + a Node control daemon. The daemon speaks AMI (hand-rolled client, event stream proven at boot by a self `UserEvent` round-trip), tracks calls (Newchannel → Bridge → Hangup, MixMonitor recording linked by uniqueid, JSONL log), and serves a token-gated HTTP API on the internal container network only: health, per-tenant config push/delete, endpoints, test-call/test-queue/test-ivr originators, call list, recording download. **No host ports; AMI and SIP stay inside the container/network** (SIP fraud rule).
- **Plugin** `pbx` (tool type, PTA-Mask pattern): tenants manage **extensions** (per-extension SIP secret, call recording on/off), **queues** (strategy, timeout, members), **IVR menus** (entry extension, prompt sound, digit → queue/extension map) and **SIP trunks** (host/auth/DID/outbound prefix + the verified-CLI fields below). An **AsteriskConfigRenderer** turns the rows into pjsip endpoints/aors/auths, queues and a per-tenant dialplan; **Apply** pushes it to the companion. Call-log page (tenant-filtered), admin overview page. Tenant URL `/pbx-panel`, admin `/admin/pbx`.

**Battery (dev) — all pass**
- Companion: health + AMI verified; AMI-originated test call bridged two legs, played the prompt, **MixMonitor WAV written and linked in the call log** with duration/answered; queue routing proven in isolation; tenant config push → endpoints loaded.
- Plugin: install/configure/activate; 4 migrations; render checks (extension endpoints, queue, IVR context, **verified-CLI number rendered as the trunk endpoint's callerid**); Apply → Asterisk CLI shows `t38-1001`, `t38-1002`, `trunk-t38-1` loaded; **UI-surface check 3/3** (tenant dashboard, call log, admin — 200 with markers, as dev users).

**Environment defect (recorded honestly):** interactive digit collection **crashes this Ubuntu Asterisk 20.6 build** — reproduced with `Read()` and with `Background`+`WaitExten`, on Local and on real PJSIP channels, with GSM and WAV prompts, and with DTMF delivered by AMI PlayDTMF, by Dial `D()`, and by RFC4733 alike. Every non-interactive flow (originate, bridge, queue, record, config push, AMI tracking) is stable across dozens of runs. The plugin therefore renders IVRs in the standard `Background`+`WaitExten` pattern, and the digit step will complete on a healthy Asterisk build (a source-built Asterisk is the clean follow-up). The plan card's acceptance also names a **browser agent ringing (WebRTC)** — not built: extensions register from any SIP softphone today; a WebRTC agent needs a WSS endpoint, which stays internal/WireGuard under the standing rule and is a follow-up item, not silently claimed here.

**Production:** fresh verified backup → companion `sendqon-pbx` running (internal only, fresh token + AMI secret, config chmod 600), plugin installed + ACTIVE + configured, migrations run, **zero tenant rows (inert)**; code baked into `~/sendqon-build/src`. One deploy bug caught and fixed on the spot: the AMI user in `manager.conf` is the fixed name `pbxdaemon` — the first prod config used a different name and AMI auth failed until aligned.

**Battery-caught platform lessons (all folded into the code):** `#include dir/*.conf` with zero matches aborts Asterisk config parsing (placeholder files shipped); `pjsip reload` is not a CLI command (module reloads used); AMI login can succeed while its event stream never starts (self-test round-trip at boot); core's `/{locale}` route group swallows bare 2–3-letter first URL segments (tenant prefix is `pbx-panel`, not `pbx`); core has no `admin` middleware alias (admin pages gate on `can:admin.access`).

## Item 2 — Line side (prep; every route is owner-gated hardware/service)

Order per Addendum 7 (DID-first). Nothing here can be proven without the purchases; the prep below is the deliverable for this item.

**Trunk selection criteria (apply in this order)**
1. Pakistan DID availability + lawful inbound routing; per-minute + per-DID pricing against Addendum 8 benchmarks (DIDLogic from $8/mo; KataTelecom from $56.70/mo; Continent $70/mo + $80 setup; GlobalCallForwarding $73.95/mo; PTCL quote-based; Twilio has NO Pakistan voice numbers — outbound only, landline $0.1510/min, mobile $0.1760/min).
2. **Verified custom CLI presentation (owner criterion, 2026-11-18):** prefer a trunk whose provider **verifies the tenant owns a number (OTP/call proof) and then allows it as the outbound caller ID** — the Skype / Twilio Verified Caller IDs pattern, no hardware needed. The PBX trunk form already records `supports_verified_cli` + the verified number, and the renderer presents it as the endpoint callerid. **Pakistan caveat:** presenting a Pakistani mobile number as CLI over an international trunk may fall foul of PTA anti-grey-traffic rules — this must be cleared in the PTA/trunk research before it is offered as a feature; it is **not** promised as a launch capability.
3. SIP over TLS/SRTP support, G.711 + G.729, RFC4733 DTMF, and a test account before any annual commitment.

**Config templates:** the PBX plugin's trunk form *is* the template (host/port/auth/DID/outbound prefix/verified CLI) — a purchased trunk is entered there and Applied; inbound DIDs land in the tenant's `pbx-t{id}-in` context, which routes to the first IVR (or can be extended per-DID when the first trunk lands).

**Remaining routes (Addenda order, all owner purchases):** GSM gateway (GoIP/Yeastar TG — 1 SIM = 1 concurrent call) → USB dongle pilot (`chan_dongle`) → SIM7600 AT daemon (the B9 GSM item below already speaks to a SIM7600-class modem over TCP/serial) → Bluetooth bridge (`chan_mobile`, lab only) → conference bridge via our own Android app. **PTA check (owner/legal):** selling PBX as a service needs a PTA licensing review separate from own use (plan § owner-items table) — flagged, not blocking the build.

## Item 3 — GSM modem daemon ✅ (live-inert, from earlier in this lane)

Own `gsm_modem` channel plugin (live-switch for the core-pre-registered channel) + Node AT-command daemon speaking core's telephony contract (pairing, line_status, Reverb commands, outbound/USSD fetches). Full battery against a simulated SIM7600G-H (fake modem): pairing → line created → SMS send (exact body, status sent) → **flash SMS (PDU mode, DCS 0x10 captured)** → inbound SMS → USSD (completed + interactive menu session) → UI check 4/4. Production: plugin ACTIVE, telephony server row "Primary Telephony (Own)" pending, daemon service defined but **not started**; plan flag `gsm_modem` still false on all production plans. Physical proof awaits the owner's SIM7600 HAT/gateway purchase. (Details in the lane checkpoint; pushes `plugin-gsm_modem` 8480bd8, `companion-modem-daemon` ed180eb.)

## Item 4 — Own SMPP server (Jasmin + adapter) ✅ (live-inert, from earlier in this lane)

Own SMPP adapter (Node, node-smpp) + Jasmin 0.10.12 in Docker (own ARM64 image from PyPI — upstream image is amd64-only). Full dev battery: aggregator-style bind → core send → Jasmin → test SMSC with exact bodies (GSM text, UCS2 Urdu, multipart), DLR → delivered, inbound MO → core conversation, connection test OK, UI check pass. Production: server row "Primary SMPP (Own)" **healthy with zero gateways assigned (inert)**; the production provider route activates when an upstream exists — the aggregator track's owner step (Veevo Tech reseller enquiry first, per the feasibility report; this deployment is Phase C of that track and is ready for the first bind). Key wire finding: node-smpp's "ASCII" codec is an 8-bit passthrough (no septet packing) — wire convention data_coding 0 = plain ASCII, 8 = UCS2, UDH concatenation for long messages. (Push `companion-smpp-own` 6acb86e.)

## Item 5 — Mobile App (own Flutter client) ✅ app built; push owner-gated

**Built:** `sendqon-mobile/` — Flutter 3.24.5, application id `com.rektrs.sendqon.mobile`, single config file (`lib/config.dart`, kit branding). MVP exactly per the NO-SOURCE spec: **login** (password / 2FA challenge / sign-in code / forgot password; editable site address), **inbox** (counts, cursor pagination, search), **conversation** (thread, reply through the conversation's own reply options, internal notes, attachments upload → media message, actions: assign, labels, priority, snooze, resolve/reopen, pin, read), **overview** (channel status + credits, permission-gated gracefully), **me** (profile, devices, sign out), **push registration** wired (guarded — see below).

**Battery (dev) — all pass:** every endpoint the app calls was exercised live against the dev copy (login token+me, counts, views, conversations, thread, labels list+set, assignees, assign+unassign, priority, status, note, read, channels, credits, push PUT, heartbeat 204), and **a reply sent through the mobile API travelled core → SMPP adapter → Jasmin → test SMSC with the exact body**. `flutter analyze` clean; widget test passes. Signed APK: the release build is **pending an owner approval** for the build toolchain's local daemon connection (approval card in the parent chat, requested 2026-11-18 20:59 UTC; the first attempt's Gradle failure after 622 s is being re-captured with a full log in the same run). When it lands, the APK is archived at `files/android-app/sendqon-mobile-v1.0.0.apk`, signed with the custody key (cert SHA-256 EA:42:87:27:92:AD:83:A3:00:7F:8F:42:BD:84:9D:E3:78:6D:08:84:A4:08:DA:15:7B:A4:42:69:07:56:A4:8B; keystore only in `hidden_files/release-custody/`). App source, analyze, tests and the API battery are complete and pushed — only the binary build waits.

**Boundaries, plainly:** (a) **Push delivery** needs this application id registered in the Sendqon Firebase project + a `google-services.json` dropped into the build — an owner console step (same class as the gateway app's optional registration). The app tolerates its absence and the API itself answered `push: {ready: false, reason: 'not_configured'}` in the battery. (b) No emulator/device run on this VM — the owner's phone is the final proof, as with B7. (c) Second-tier screens (contacts, campaigns, USSD, tickets, voice-note recording, realtime) are mapped but not built, per the spec's MVP split. (d) The site-side APK slot (`mobile:install-apk` / Admin → Settings → Mobile App) is NOT populated — same owner-decision class as the gateway app's slot registration.

## Item 6 — Reseller++ (USP-6) ✅ (production-installed inert; activation = owner decision)

**Recon first:** core's built-in Partner Network is a **shared-line referral/earnings** system (Partner = line contributor with balances/payouts) — not white-label resale; core *does* have per-workspace custom domains (`messenger_custom_domain` + verification/SSL fields) and global plans with per-user plan assignment. The plan gate ("single-brand SaaS proven with paying tenants") is **not met**, so per the brief the plugin layer was built and dev-proven, and production is installed inert.

**Built:** plugin `reseller_plus` (tool type): partner application + **admin approval** (pending → active/suspended), partner **branding** (name, logo, colour, support email), **own domain** record with the core workspace-domain verification state mirrored on the partner page, **price book** per core plan, and **sub-tenant provisioning** that creates a real core workspace (user + core plan + approved) and emails a password-set link via core's broker — no password is shown to the partner or stored by the plugin. Admin page lists partners with status controls and sub-tenant counts.

**Battery (dev) — all pass:** install/activate, 3 migrations; a **pending partner is blocked** from provisioning; an active partner provisions → sub-tenant created with the price book's agreed price recorded (Rs 7,999) → **the sub-tenant signs in through the mobile API with their own workspace**; UI check 2/2 (partner + admin pages).

**Honesty boundary:** platform billing charges **core plan prices** — core has no per-partner checkout override, and none was faked. The price book is what the partner charges *their* customers (the standard reseller model: platform bills partner, partner bills theirs). **Production:** backup → installed + ACTIVE, migrations run, **zero partners, zero sub-tenants**; core's Partner Network setting remains OFF — turning any of this on for real partners is the owner's decision.

---

## Owner-gated list (nothing here blocks on Muse)

1. **DID/SIP trunk purchase** (PBX PSTN in/out; criteria + prices in Item 2; verified-CLI support preferred, PTA grey-traffic caveat to clear first).
2. **PTA licensing check** for selling PBX as a service (owner/counsel).
3. **GSM hardware purchase** (SIM7600G-H HAT or GSM gateway) → then: set the modem host in the prod daemon config, start `sendqon-modem-daemon`, decide the `gsm_modem` plan flag.
4. **SMPP upstream** — aggregator/reseller bind (Veevo Tech first per the feasibility report) → then create the first production gateway on "Primary SMPP (Own)".
5. **Partner Network / Reseller++ activation decision** — approving the first real partner is the owner's call; the machinery is live-inert.
6. **Firebase registration for `com.rektrs.sendqon.mobile`** (owner console) + `google-services.json` → enables mobile push end-to-end.
7. **Mobile App slot registration** on the site (owner decision, like the gateway app's).
8. Optional: source-built Asterisk if IVR digit-collection must be proven before the first trunk lands (current build's interactive-playback defect, Item 1).

## Plan-card corrections (recorded, per standing practice)

- The telephony contract **does** ship in core as `resources/contracts/telephony-v1.json` (~400 KB) even though `docs/api/telephony-v1.yaml` is absent — payload schemas did not need reverse-guessing.
- `routes/mobile.php` carries **~144 route entries** (120 `Route::` lines), not ~117.
- The PBX card's "channel family" placement is not implementable as written: core pre-registers only `phone_bridge` + `gsm_modem` as telephony channels — there is no plugin slot for a new telephony channel, so the PBX module is a `tool` plugin + companion (the same shape the plan mandates for core-adjacent modules), with its own call log; core messenger call-log integration belongs to the phone_bridge channel and was deliberately not rebuilt.
- Jasmin: upstream Docker image is amd64-only; the PyPI wheel needs Python 3.10 (3.11 breaks jCli) and a hand-supplied AMQP spec XML.

## Push ledger (all ls-remote verified)

| Branch | Hash | Contents |
|---|---|---|
| `companion-smpp-own` | 6acb86e | SMPP adapter + Jasmin (Item 4) |
| `plugin-gsm_modem` | 8480bd8 | GSM modem channel plugin (Item 3) |
| `companion-modem-daemon` | ed180eb | Modem daemon + fake modem (Item 3) |
| `plugin-pbx` | b89954a | PBX plugin (Item 1) |
| `companion-pbx` | 377ffa1 | Asterisk companion (Item 1) |
| `plugin-reseller_plus` | bdbc0ec | Reseller++ plugin (Item 6) |
| `app-mobile-flutter` | 0627ff6 | Flutter client source (Item 5) |
| `rebuild-tree` + workspace `main` | (this report) | This report |

No credentials, keys, licence codes, or session files are in any pushed tree (companion dev config with live secrets was deliberately excluded; production secrets were generated on the host and never left it).
