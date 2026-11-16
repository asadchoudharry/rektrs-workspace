# NO-SOURCE — Telegram Server (closed binary)

Full evidence: Lane 6 §4 + Lane 3. The Telegram plugin was **not
bought** — no binary in our possession; behaviour is from the product
page, the demo and core's visible surface.

## What it is
The engine of the paid Telegram channel plugin: connects Telegram
**bots** (BotFather token) and **user accounts** (phone + code/QR +
2-step verification) to Zender — private chats in Messenger,
broadcast channels for campaigns, Telegram flow nodes.

## Interface evidence
- **Server model (Lane 3):** register a **Telegram Server** in Admin →
  install the matching **binary on a Linux VPS** → save your own
  Telegram application `api_id` + `api_hash` → Test Configuration →
  connect channels. Demo: Telegram Servers — 1, Healthy, **v1.0.0**,
  **0/500 Telegram Bots**.
- A BotFather token belongs to a bot connection only — it does not
  replace the application credentials. Account setup can create a bot.
- Live updates require Reverb or Pusher. Bot sends report only
  "Sent" (no delivery/read receipts); a bot reaches only people who
  started it — hence single-use opt-in links (1-day expiry).
- Core side: channel slug `telegram` is registered in the core
  registry; core routes carry a **fallback 503 handler** for
  `v1/internal/telegram/*` (returns `channel_unavailable` while the
  plugin is not live) — the real internal routes arrive with the
  plugin. A public `v1/telegram` sub-API exists in core routes.
  Plan allowances for bots and accounts are separate. The Telegram
  Store plugin depends on this channel.

## UNVERIFIED
- Which MTProto library the binary is built on (TDLib / custom).
- Where/how account sessions are stored; real mixing limits behind
  the "500 bots/server" capacity figure.
- Flood-limit / rate-limit handling policies.

## Clean-room replacement spec
1. **Two modes:** (i) **Bot mode** — plain Bot API client; sufficient
   for bots, needs no binary-equivalent at all. (ii) **Account mode**
   — an MTProto client service (phone+code login, QR, 2FA) for
   broadcast channels and account-level features.
2. **Base:** Telethon (Python MTProto) or TDLib (official library)
   for account mode; a direct Bot API client for bot mode.
3. **Surface to core:** Service Server kind `telegram` registration;
   `api_id`/`api_hash` config; channel connection lifecycle
   (connect/disconnect/health); inbound private chats → core inbox;
   outbound sends from campaigns/flows/API; broadcast channel list +
   post/edit/delete; opt-in link flow; implementation of the real
   `v1/internal/telegram/*` routes.
4. **Sessions:** own encrypted store, one session per account;
   flood-wait responses converted to queue delays, never hard blocks.

## Difficulty / risk
**Medium overall:** bot-only is **Easy** (open Bot API); account mode
is Medium-Hard (MTProto session care, Telegram flood limits, and
staying inside Telegram's terms for user-account automation).
Priority is low — bots cover ~80% of the value. Build order: bot mode
in Phase 4 (see `../02-PAID-PLUGINS/telegram.md`), account mode later.
