# FREE PLUGIN — SMPP (SMS provider) (v5.0.4)

**What it is:** the free plugin that adds SMPP as a 17th SMS provider
driver. Demo state: Active, Configured, listed as "SMPP SMS Provider
v5.0.4 (requires SMS Providers)" (Lane 4 §C).

## What it contains (Lane 5 §§5.7-3, 11)
The ZIP holds only the manifest + `SmppPlugin` class: slug `smpp`,
type `sms_provider`, namespace `App\Plugins\SmsProviders\SmppPlugin`,
implementing `SmsProviderPlugin` with
`smsDrivers(): ['smpp' => SmppDriver::class]`. That is: **the plugin
registers one driver class that lives in core** —
`app/Services/Messaging/Sms/Smpp/` contains `SmppDriver` (unicode,
255 parts, alphanumeric sender, delivery reports, inbound),
`SmppCommands`/`SmppCommandChannel` (commands to the binary over
Reverb), `SmppServerAssigner` + balancing, `SmppBindStateHandler`,
`SmppInboundHandler`, `SmppMessageStatusHandler` (DLRs),
`SmppConnectionTests`, `SmppConfigSchema` (per-gateway host/port/
system_id/password/TLS/bind options).

The actual SMPP wire engine is the **closed Go binary** in the
branch's `server/` folder (linux ~14.3 MiB, arm64, macos) — contract
in `04-NO-SOURCE/smpp-server.md`.

## Integration shape
- Internal API `api/v1/internal/smpp` (middleware `channel:smpp` +
  `smpp.server`): `POST events`, `GET bootstrap`, `GET gateways`,
  `GET gateways/{gateway}`, `GET gateways/{gateway}/pending`,
  `GET connection-tests/{id}`, broadcast auth, error-reporting relay.
- Gateways are configured like any provider (`gateways`,
  `sms_provider_routes`, `smpp_assignment_history`); balancing:
  move off a down server after 10 min (5–120), Busy Above 90%
  (50–100), Moves Per Run 5 (1–50), no auto-return. Scheduler:
  `smpp:sweep` + `smpp:servers-health` every minute, `smpp:balance`
  every 5 min.

## Docs inside the ZIP
Public docs have **no SMPP protocol page** (Lane 2 gap #3 — no host/
port/bind/DLR detail); SMPP documentation lives inside the plugin ZIP.

## Our stance
- **Reference + interim.** SMPP matters when an aggregator (e.g. a
  PTA-masked-SMS provider) offers SMPP binds; until then Custom HTTP
  covers aggregator hookup (`../01-CORE-MODULES/sms-providers.md`).
- **Own replacement:** Jasmin SMS Gateway (open-source SMPP) + an
  adapter to core's internal API/Reverb surface — spec in
  `04-NO-SOURCE/smpp-server.md`. Phase 4/5, not a launch blocker.
