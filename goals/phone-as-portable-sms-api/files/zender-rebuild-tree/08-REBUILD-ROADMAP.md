# 08 — REBUILD ROADMAP

Build order for everything in this tree. Source: the master plan
(`../ZENDER-CORE-PLUS-OWN-PLUGINS-PLAN-2026-11-15.md`, phases +
Addenda 1–9) mapped onto the Lane 2–6 evidence. Standing rules for
every phase:

- System stays **standalone**; Operqon coupling is loose REST/webhook
  only, and only after the Operqon stop lifts / via Cursor.
- Own code lives in plugins; core edits are minimal and **every core
  change goes in the patch register** (`05-INFRA.md`).
- Vendor compiled components are never decompiled or copied —
  clean-room replacements only (`04-NO-SOURCE/`).
- Consumer-SIM campaigns: rate limits + opt-out handling mandatory.
- Credentials never in chat — Secure Vault / owner-only steps only.

## Phase 0 — remainder (install + foundations)

The purchase and the six-lane audit are done. Remaining:

1. **Install** Zender 5.0.4 standalone on our own subdomain + VPS
   (autosetup anatomy in `05-INFRA.md`); create the admin account in
   the installer; verify the signed-in tenant branding question on
   our own install (Lane 4 answered it for the demo: no "Powered by
   Zender" — confirm on ours).
2. **Patch register** opened on day one; first entries: Error
   Reporting stays OFF (phone-home #1), Reverb self-hosted, APP_KEY
   custody + backup snapshot (DB + config + storage + channel state)
   before any change.
3. **Licence-code handling under the custom licence:** the Regular
   licence is held; the owner's custom-licence application (for
   proprietary rights) is in progress with the vendor. Until it
   lands: no charging end users. The three binary licence codes
   (WhatsApp / SMPP / Telephony placeholders) are obtained from the
   vendor dashboard as a verified buyer for interim use of the free
   plugins' servers; record each code's storage location in the
   register (never the code itself in this tree). When the custom
   licence lands, re-check: plugin terms (e.g. "free for Extended"
   items), error-reporting identifier, and whether our own builds
   still need any vendor code at all (our replacements have no
   licence gate by design).
4. **Phase 0 verification items** (from the lane reports): how much of
   Appointment Booking / Knowledge Base already runs on core alone;
   the Website Chat core-vs-plugin split; exact Laravel-facing
   payload schemas for the telephony contract (read core controllers,
   since `docs/api/telephony-v1.yaml` is absent from the tree).

## Phase 1 — White-label + WABA live

- Brand: APP_NAME/site name, logos, colour theme, landing via Landing
  Builder, custom pages (Terms/Privacy/Cookie) — all configuration,
  no code (`01-CORE-MODULES/landing-builder-tours.md`,
  `settings-admin.md`). Owner's white-label kit applies here when
  supplied.
- Our own plan catalogue + pricing replaces the seeded demo plans.
- **WABA live:** connect a real Meta business number (Embedded Signup
  plugin), register templates, first official WhatsApp send/receive
  test end-to-end. SMS provider (Custom HTTP or a named driver)
  connected as the second live channel.
- Go-live gate: the licence position must allow the intended use
  (custom licence for charging; internal/testing use before that).

## Phase 2 — Own Android gateway app

Clean-room Kotlin app (or SMS Gate fork + adapter) against core's
documented protocol — spec in `04-NO-SOURCE/android-gateway-apk.md`.
Order inside the phase: pairing/auth → SMS send (FCM wake + pull) →
SMS receive → SIM sync/heartbeat/diagnostics → self-update → USSD
module → (RCS module last, optional). Pilot on a real phone + SIM
(Redmi-class, battery-optimisation behaviour proven) before any tenant
device. Exit criterion: vendor APK no longer needed on our own
gateway phones.

## Phase 3 — Own WhatsApp QR bridge

Evolution API / Baileys-type engine + our Reverb adapter speaking
core's exact WA surface — spec in `04-NO-SOURCE/whatsapp-qr-server.md`.
Register as Service Server kind `whatsapp`; session persistence and
health reporting included. Number-ban warning ships in the UI copy;
WABA remains the recommended route. Optional in this phase: evaluate
Meta's **WhatsApp Business Calling API** on the WABA channel for
agent-dashboard voice calls (Addendum 9) — QR numbers can never do
calls.

## Phase 4 — Own PHP plugins (priority order)

Master-plan order: **MCP → payments → AI group → channels group →
integrations.**

1. **MCP** (`02-PAID-PLUGINS/mcp.md`) — Medium. First because it is a
   thin, safety-railed wrapper over core plumbing and unlocks
   agent-driven operations.
2. **Payments:** **Stripe** (Medium) + the local route (Bank Transfer
   + PayPal are already core). Then on demand: Paystack, Razorpay,
   YooKassa, Crypto.com Pay (all Medium); Freemius only if its
   evidence gap closes and a need appears.
3. **AI group:** AI Agents (Hard), AI Flow Builder (Medium),
   Knowledge Base (Medium) — one group, shared core AI wallet.
4. **Channels group:** Telegram (bot mode Easy–Medium, account mode
   later), Website Chat (Easy–Medium), Email (Easy–Medium + its
   service), Telegram Store (Medium, after Telegram), Web Push
   (Easy–Medium).
5. **Integrations:** Google Sheets (Easy–Medium), WordPress (Medium),
   WHMCS (Medium), Shopify (Medium), Odoo (Medium-Hard), Perfex
   (Medium), Appointment Booking (Easy–Medium), Browser Extension
   (Easy), Admin API (Medium — pull forward if Operqon coupling is
   scheduled), osTicket (Easy–Medium), Blesta (Medium), Flarum
   (Easy–Medium), GoHighLevel + monday.com (evidence first —
   UNVERIFIED specs).
6. **SMPP server replacement** (Jasmin + adapter, Medium) slots in
   here or Phase 5 — needed when an aggregator offers SMPP binds;
   Custom HTTP covers the interim.
7. **Not building:** Auto Update (deliberate — manual upgrade
   discipline instead).

## Phase 5 — Telephony / PBX + hardware + late items

- **PBX module + Asterisk** (Hard): Zender-side module (extensions,
  IVR builder, queues, agents, recordings, call logs, click-to-call,
  minutes) over Asterisk via AMI/ARI — spec in
  `04-NO-SOURCE/telephony-server.md`. Line side in Addenda order:
  **DID/SIP trunk first** (Addendum 7 rule; Pakistan DID sourcing in
  Addendum 8), then GSM gateway device (GoIP/Yeastar TG), USB dongle
  pilot (`chan_dongle`), SIM7600 AT daemon, Bluetooth bridge
  (`chan_mobile`), conference bridge in our Android app (Addendum 6 —
  pilot proof on a real phone + SIM required). PTA licensing check
  before selling PBX as a service (Addendum 1).
- **GSM Modem daemon** (Medium for SMS/USSD/flash; voice folds into
  the PBX work): SIM7600G-H first.
- **RCS** (Medium-Hard): as a module of our Android app.
- **Mobile App** (Medium): own Flutter client on core's mobile API,
  MVP scope frozen in `04-NO-SOURCE/mobile-app.md`; revisit the
  buy-the-$150-source option at phase start.
- **Masked SMS (Pakistan):** partner with a PTA-recognised aggregator;
  connect via Custom HTTP or our SMPP replacement; each tenant's mask
  registered under the tenant's own business name (Addendum: masked
  SMS). Flash SMS rides the aggregator/SMPP or modem route only.

## Master checklist — every build item

Status key: **spec ready** = this tree contains a buildable spec;
**keep** = purchased core, no build (understanding documented);
**evidence first** = spec blocked on an UNVERIFIED item below.

### Core (keep — documented in `01-CORE-MODULES/`)
| Item | Status |
|---|---|
| Auth & accounts | keep |
| Workspaces, teams & roles | keep |
| Contacts & subscribe forms | keep |
| Messenger (shared inbox) | keep |
| Campaigns | keep |
| Flows & drips | keep |
| OTP verification & Sign-in with WhatsApp | keep |
| Channels hub (devices/SIMs/USSD) | keep |
| SMS providers (16 drivers + Custom HTTP) | keep |
| WABA (official WhatsApp) | keep |
| Plans, billing & credits | keep |
| Payment Links | keep |
| Market | keep |
| AI providers & AI credits | keep |
| Referral & Partner Network | keep |
| Landing builder, custom pages, tours | keep |
| Settings & admin operations | keep |
| Privacy / GDPR / sending safety | keep |
| Localization | keep |
| Custom domains | keep |
| Files & storage | keep |
| Cron, logs, audit & status page | keep |

### Own plugins (build — `02-PAID-PLUGINS/`)
| Item | Phase | Difficulty | Status |
|---|---|---|---|
| MCP | 4.1 | Medium | spec ready |
| Stripe | 4.2 | Medium | spec ready |
| Paystack | 4.2 | Medium | spec ready |
| Razorpay | 4.2 | Medium | spec ready |
| YooKassa | 4.2 | Medium | spec ready |
| Crypto.com Pay | 4.2 | Medium | spec ready |
| Freemius | — | UNVERIFIED | evidence first |
| AI Agents | 4.3 | Hard | spec ready |
| AI Flow Builder | 4.3 | Medium | spec ready |
| Knowledge Base | 4.3 | Medium | spec ready |
| Telegram (bot → account) | 4.4 | Easy–Med / Med-Hard | spec ready |
| Website Chat | 4.4 | Easy–Medium | spec ready |
| Email (+ service) | 4.4 | Easy–Medium | spec ready |
| Telegram Store | 4.4 | Medium | spec ready |
| Web Push | 4.4 | Easy–Medium | spec ready |
| Google Sheets | 4.5 | Easy–Medium | spec ready |
| WordPress / WooCommerce | 4.5 | Medium | spec ready |
| WHMCS | 4.5 | Medium | spec ready |
| Shopify | 4.5 | Medium | spec ready |
| Odoo | 4.5 | Medium-Hard | spec ready |
| Perfex CRM | 4.5 | Medium | spec ready |
| Appointment Booking | 4.5 | Easy–Medium | spec ready |
| Browser Extension | 4.5 | Easy | spec ready |
| Admin API | 4.5 | Medium | spec ready |
| osTicket | 4.5 | Easy–Medium | spec ready |
| Blesta | 4.5 | Medium | spec ready |
| Flarum | 4.5 | Easy–Medium | spec ready |
| GoHighLevel | 4.5 | UNVERIFIED | evidence first |
| monday.com | 4.5 | UNVERIFIED | evidence first |
| Auto Update | — | — | **not building** (manual discipline) |
| Phone Bridge (vendor form) | — | — | **not building** — replaced by PBX module (Phase 5) |
| GSM Modems (vendor form) | 5 | Medium / Hard w/ voice | spec ready (own daemon) |
| RCS | 5 | Medium-Hard | spec ready |
| Mobile App (client) | 5 | Medium | spec ready |

### Free plugins (stance — `03-FREE-PLUGINS/`)
| Item | Stance |
|---|---|
| Android Gateway | use interim; replaced by own app (Phase 2) |
| WhatsApp QR | use interim; replaced by own bridge (Phase 3) |
| SMPP | use interim; replaced by Jasmin adapter (Phase 4/5) |
| WhatsApp Embedded Signup | use (Phase 1); rebuild only if licence requires |
| Legacy API Wrapper | skip (no legacy integrations) |
| Legacy Importer | skip as a tool; keep as plugin-architecture reference |

### Closed components (replace — `04-NO-SOURCE/`)
| Component | Replacement | Phase | Difficulty | Status |
|---|---|---|---|---|
| WhatsApp QR server | Evolution/Baileys + Reverb adapter | 3 | Medium-Hard | spec ready |
| SMPP server | Jasmin + adapter | 4/5 | Medium | spec ready |
| Telephony server | Asterisk PBX module | 5 | Hard | spec ready |
| Telegram server | Bot API + Telethon/TDLib service | 4 | Medium | spec ready |
| Email server | Standard IMAP/SMTP service | 4 | Easy–Medium | spec ready |
| Android gateway APK | Clean-room Kotlin app (or SMS Gate fork) | 2 | Medium | spec ready |
| Mobile app client | Own Flutter app (core mobile API) | 5 | Medium | spec ready |
| Browser extension / branded builds | MV3 extension + build-step pattern | 4 | Easy–Medium | spec ready |

## Open UNVERIFIED items — resolve before the dependent build

1. **Binary licence validation mechanism** (WhatsApp / SMPP /
   Telephony codes): online or offline? Affects how interim servers
   behave without vendor contact and how the custom licence should be
   worded. Resolve in Phase 0 by observation on our own install
   (never by decompiling).
2. **WhatsApp session format/location** inside the WA binary: affects
   migration of live QR accounts from the vendor binary to our
   Phase 3 bridge (worst case: tenants re-link by QR — plan the
   comms, not a hack).
3. **Freemius plugin**: price, features, workflow all UNVERIFIED (no
   portal page). Evidence first; no build scheduled.
4. **GoHighLevel + monday.com plugins**: existence proven only by the
   demo list; everything else UNVERIFIED. Obtain vendor docs or the
   plugins' in-ZIP docs before speccing.
5. **Core-vs-plugin split** for Appointment Booking, Knowledge Base
   and Website Chat: core ships their tables/queues/UI shells — how
   much the paid plugins actually add is UNVERIFIED until tested on
   our install (Phase 0 checks).
6. **`docs/api/telephony-v1.yaml` missing** from the tree: telephony
   payload schemas must be read from core controllers before the PBX
   module's adapter work (Phase 5 prep).
7. **Telegram server internals** (MTProto library, session storage,
   flood policy): UNVERIFIED — our Telethon/TDLib design proceeds on
   public protocol knowledge; no dependency on the answers.
8. **Android app MMS support + Receiver-app duty split**: UNVERIFIED;
   our app spec treats MMS as out of scope until proven needed.
9. **Mobile API field-level payloads**: read `routes/mobile.php` +
   controllers at Phase 5 build time.
10. **Plugin file watermark** (whitespace block in free-plugin class
    files, Lane 5 §9-F5): noted, not decoded; do not alter distributed
    plugin files.
11. **Multi-node Laravel app scaling**: UNVERIFIED (no vendor guide);
    assume single app node + scaled companion servers until tested.
12. **Masked-SMS display on Telenor/Ufone** (numeric code vs
    alphanumeric mask — conflicting sources in the master plan):
    confirm with the chosen aggregator before selling masks.
