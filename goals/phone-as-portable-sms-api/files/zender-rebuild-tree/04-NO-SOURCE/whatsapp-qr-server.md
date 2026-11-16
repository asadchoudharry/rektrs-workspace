# NO-SOURCE — WhatsApp QR Server (closed Go binary)

Full evidence: Lane 6 §1 + Lane 5 §8. **No binary was executed,
decompiled or reverse-engineered** — behaviour below is from the PHP
source that talks to it, vendor docs/pages and the demo.

## What it is
The linked-device WhatsApp engine shipped with the free WhatsApp
plugin: runs up to **100 WhatsApp numbers per server** (QR or
pairing-code link) and feeds messages into core's inbox/campaigns/
flows.

## Inventory (in our possession — free plugin)
| File | Size | Platform |
|---|---|---|
| `titansys-whatsapp-linux` | 52,281,470 B | ELF x86-64, static, stripped |
| `titansys-whatsapp-arm64` | 48,234,622 B | ELF aarch64, static, stripped |
| `titansys-whatsapp-macos` | 49,648,354 B | Mach-O arm64 |

PHP docblocks call it "a Go WA binary" / "the WhatsApp library
session" — a whatsmeow-style linked-device engine.

## Interface evidence (the surface core sees)
- **Bootstrap:** admin downloads a generated `config.json`:
  `{ purchase_code, server: { host, port (default 8899),
  service_token }, laravel: { url } }`. The binary **refuses to
  start** on placeholder licence code / service token
  (`REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE`).
- **Main traffic = Reverb:** the binary subscribes to private channel
  `wa.account.{id}.commands`; Laravel publishes send/control commands
  there. Events return on `wa.account.{id}.events` and via
  `POST /api/v1/internal/whatsapp/events` (`WaEventIngestService`).
  Broadcast auth via `Api\V1\Wa\BroadcastAuthController`.
- **HTTP only at lifecycle boundaries** (`WaBinaryClient`, Bearer =
  the server's service token, same token both directions):
  `POST /api/v1/internal/whatsapp/accounts` (assign/subscribe with
  `session_token`, login method `qr` | pairing-code, proxy, throttle,
  reject-call settings) and `DELETE …/accounts/{id}` (release).
- **Sessions live inside the binary** on the WA server host; Laravel
  keeps only account metadata/state (`wa_accounts`,
  `wa_account_events`; legacy `wa_instances` holds server registry
  data). Health/balancing is core PHP: `wa:health-check` (minute),
  `wa:outbox-pump`, `wa:fail-stale-queued`, `wa:delivery-health`,
  `wa:connection-alerts`, `wa:resume-temp-bans`, the warmer system.
- Demo proof: Admin > WA Servers — 1 server, Healthy, v5.0.4, 0/100.

## UNVERIFIED
- On-disk session/key format and location inside the binary.
- Whether licence validation is online or offline; any phone-home
  beyond the (default-OFF) error-reporting switch.
- Exact payload schemas for command/event fields defined only on the
  binary side; binary-internal retry/reconnect behaviour.
- Real per-server resource limits at 100 accounts.

## Clean-room replacement spec (Phase 3)
Base: **Evolution API** (Baileys/whatsmeow family) + a small **adapter
service of ours** (core speaks Reverb, not REST — the adapter is
unavoidable and is our own code). The replacement must present:
1. Service Server registration, kind `whatsapp`; `config.json`
   bootstrap (host/port/service_token/laravel url) — **no licence
   gate in our build**.
2. A Reverb client per account: subscribe `wa.account.{id}.commands`,
   execute the command set core publishes (send text/media, group
   actions, polls, reactions — enumerable from core's publishers).
3. Event return on `wa.account.{id}.events` + ingestible events to
   `POST /api/v1/internal/whatsapp/events` (message received/status,
   connection state, QR/pairing progress), Bearer service token.
4. Lifecycle client behaviour for the assign/release flow
   (`session_token`, `qr` | pairing-code, proxy, throttle,
   reject-call settings).
5. Own session persistence (the engine's auth state), resumable
   across restarts.
6. Health reporting so `wa:health-check` and balancing keep working.

## Difficulty / risk
**Medium-Hard.** The interface surface is small and fully readable
from PHP; the hard part is linked-device reliability (session drops,
temp bans — core's warmer/temp-ban machinery exists precisely because
this is flaky). Standing warning: QR is unofficial — number-ban/Meta
terms risk; WABA is always the first route.
