# FREE PLUGIN — WhatsApp (QR linked-device) (v5.0.4)

**What it is:** the free plugin enabling unofficial WhatsApp via QR /
pairing-code linked devices. Free for verified buyers. Demo state:
Active, Configured; the demo tenant's WhatsApp QR channel showed
"Failed to sync — device disconnected" (Lane 4 §§B, C).

## What it contains (Lane 5 §5.7-2)
A single-file plugin class: slug `whatsapp`, type `channel`, channel
key `wa`, implementing `Plugin, ProvidesValidatedPluginConfig,
UsesSystemSettingConfig`. Its config is only WA-server device-name
settings. **All protocol logic is core PHP + the closed Go binary**,
which is distributed **outside** the ZIP in the branch's `server/`
folder (linux/arm64/macos builds, ~46–50 MiB each). See
`04-NO-SOURCE/whatsapp-qr-server.md` for the binary contract.

## Integration shape
- Core registers WA servers as Service Servers (kind `whatsapp`,
  100 accounts/server), balances accounts across them, and runs the
  health/warmer/temp-ban machinery (`wa:health-check`,
  `wa:warmer-tick`, `wa:resume-temp-bans` — Lane 5 §12).
- Traffic: Reverb channels `wa.account.{id}.commands` / `.events` +
  `POST /api/v1/internal/whatsapp/events`; lifecycle over HTTP
  (`accounts` assign/release) with the server's service token.
- Sessions/keys live inside the binary on the WA server host; core
  stores only account metadata (`wa_accounts`, `wa_account_events`).

## Hard limits (product truths)
- **No voice/video calls, ever** — the linked-device protocol cannot
  see WhatsApp calls; they ring only on the phone (master plan
  Addendum 9). Multi-agent *chats* on one QR number work fine
  (shared inbox).
- Unofficial method: number-ban / Meta-terms risk stands permanently.
  WABA (`../01-CORE-MODULES/waba.md`) is always the first route.

## Docs inside the ZIP
The public docs have **no WhatsApp QR setup page** (Lane 2 gap #4 —
no pairing/session/protocol documentation); the plugin's own docs
live inside its ZIP.

## Our stance
- **Reference + interim:** usable to run QR numbers before our bridge
  exists; never a dependency.
- **Own replacement (Phase 3):** Evolution API / Baileys-type engine +
  a small Reverb adapter speaking core's exact surface — spec in
  `04-NO-SOURCE/whatsapp-qr-server.md`.
