# NO-SOURCE — SMPP Server (closed Go binary)

Full evidence: Lane 6 §2 + Lane 5 §11. No binary was executed or
reverse-engineered.

## What it is
The protocol engine of the free SMPP plugin: keeps SMPP binds to
aggregators/telcos, sends at scale, receives delivery reports (DLR)
and inbound messages. Core presents SMPP as an ordinary SMS provider;
the wire protocol is this binary's job.

## Inventory (in our possession — free plugin)
| File | Size | Platform |
|---|---|---|
| `titansys-smpp-linux` | 15,016,062 B | ELF x86-64, static, stripped |
| `titansys-smpp-arm64` | 13,893,758 B | ELF aarch64, static, stripped |
| `titansys-smpp-macos` | 14,275,602 B | Mach-O arm64 |

## Interface evidence
- The plugin registers exactly one driver — `['smpp' =>
  SmppDriver::class]` — and `SmppDriver` is **core PHP**, as are
  `SmppCommands`/`SmppCommandChannel` (commands over Reverb),
  `SmppServerAssigner`, `SmppBindStateHandler`, `SmppInboundHandler`,
  `SmppMessageStatusHandler` (DLRs), `SmppConnectionTests`,
  `SmppConfigSchema` (per-gateway host/port/system_id/password/TLS/
  bind options). Policy is ours to read; only the wire engine is closed.
- **Binary↔Laravel API** (`api/v1/internal/smpp`, middleware
  `channel:smpp` + `smpp.server`): `POST events`, `GET bootstrap`,
  `GET gateways`, `GET gateways/{gateway}`,
  `GET gateways/{gateway}/pending` (outbound pull),
  `GET connection-tests/{id}`, broadcast auth, error-reporting relay.
- Licence gate: `REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE` in the
  server config (same pattern as WhatsApp).
- Balancing (admin): move gateways off a down server after 10 min
  (5–120), rebalance toggle, Busy Above 90% (50–100), Moves Per Run 5
  (1–50), no auto-return. Scheduler: `smpp:sweep` +
  `smpp:servers-health` (minute), `smpp:balance` (5 min).
- Demo: SMPP Servers — 1, Healthy, v5.0.4, 0/500 SMS Providers. The
  demo status page's seeded incidents were all "SMPP down" — health
  monitoring runs on this family.
- Public docs have no SMPP protocol page; the plugin ZIP's internal
  docs carry it (Lane 2 gap #3).

## UNVERIFIED
- Bind management internals (transceiver/receiver sessions),
  throttling and reconnection policies inside the binary.
- ~~Licence validation mechanism (online/offline)~~ **RESOLVED
  2026-11-16** (`../../ZENDER-LICENCE-VERIFICATION-TEST-REPORT-2026-11-16.md`):
  one-time online activation vs api.titansys.dev, then a stored
  token (`work/storage/license.token` + `machine.id`) verified
  OFFLINE at every start — proven with all non-local egress
  dropped; no periodic re-verification.
- Real wire throughput — "500 providers/server" is a core-side
  capacity figure, not a measured messages/sec.

## Clean-room replacement spec
Base: **Jasmin SMS Gateway** (mature open-source SMPP server/client)
+ our adapter; lighter alternative: a maintained SMPP library
(Go `fiorix/go-smpp`, Node `smpp`) in a small daemon. Must present:
1. Service Server kind `smpp` registration + config bootstrap
   (no licence gate in our build).
2. Client of `GET bootstrap` / `gateways` / `gateways/{id}/pending`:
   take assigned gateway configs, pull pending outbound.
3. Maintain SMPP bind(s) per gateway; send `submit_sm`; receive
   `deliver_sm` (DLR + inbound MO).
4. Report back via `POST events` + listen on the Reverb command
   channel (`SmppCommandChannel`).
5. Connection-test results and bind state so
   `SmppBindStateHandler`/balancing work unchanged.

## Difficulty / risk
**Medium.** SMPP is an open, documented protocol — no vendor magic;
the work is adapter correctness and DLR matching. Not a launch
blocker: aggregators can connect via the Custom HTTP driver meanwhile
(`../01-CORE-MODULES/sms-providers.md`).
