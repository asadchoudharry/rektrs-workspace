# PAID PLUGIN SPEC — Telegram (channel)

- **Vendor price:** $59 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.0 (6 Nov 2026).
- **Portal:** https://products.titansys.dev/zender/telegram/
- **Demo state:** Active/Configured; Telegram Servers list shows 1
  healthy server, v1.0.0, 0/500 bots (Lane 4 §§A, C).
- **Source status:** the PHP plugin ships with its own migrations; the
  companion **Telegram Server is a closed binary** installed on a
  Linux VPS (Lane 3/6). We buy neither.

## Purpose
Connect Telegram **bots and user accounts** as a messaging channel:
private chats in Messenger, broadcast channels for campaigns, flow
nodes, API sending.

## Features
Bot connect via BotFather token; account sign-in by code or QR with
two-step verification (account setup can create a bot for you);
private chats arrive in Messenger; broadcast channels (bot needs
admin rights to post/edit/delete; refresh; choose a channel as a
campaign target); campaigns to contacts or a broadcast channel;
**single-use opt-in links** (expire after 1 day) to invite someone to
start your bot; flow nodes — Telegram Message / Telegram First
Contact / Telegram Button Tap triggers + Send Telegram action with
Sent/Error outcomes; plan allowances for Bots and Accounts separately.

## Workflow
Upload → install (ships its own migrations) → activate → **register a
Telegram Server in Admin → install the matching binary on a Linux
VPS** → save your Telegram app `api_id` + `api_hash` → Test
Configuration → enable Telegram on plans → Channels > Connect Channel
→ add bot or account.

## Logic / technology
Two protocol tiers: Bot API (bots) and **MTProto** (user accounts) —
the MTProto side is why a companion server binary exists at all.
Requires Reverb or Pusher for live updates. Hard limits from the
domain: bot sends report only "Sent" (no delivery/read receipts); a
bot can only reach people who started it. Core side: channel slug
`telegram` is registered in the core registry; core routes contain a
**fallback 503 handler** for `v1/internal/telegram/*` and a public
`v1/telegram` sub-API — the real internal routes arrive with the
plugin (Lane 6 §4).

## Data it touches
`channel_connections`, `conversations`, campaign tables; Telegram
Store commerce tables when that extension is active.

## Dependencies
Companion Telegram Server (own build — `04-NO-SOURCE/telegram-server.md`);
own Telegram application (`api_id`/`api_hash`); Reverb/Pusher.

## OUR REBUILD SPEC
- **Plugin type:** `channel` (channel key `telegram`), registering its
  internal routes, flow nodes, plan keys (bots/accounts allowances)
  and MCP tools in the channel registry.
- **Companion service:** our own — Bot API client for bot mode
  (no binary needed), Telethon/TDLib service for account mode
  (Lane 6 §4 spec).
- **Key interfaces:** `v1/internal/telegram/*` (implement the real
  routes core expects), Service Server kind `telegram` registration,
  session storage (encrypted, per account), flood-wait → queue
  translation (never hard-block).
- **Priority:** Phase 4, channels group (Telegram / Website Chat /
  Email) — bot mode first (80% of value), account mode second.
- **Difficulty:** Bot mode Easy–Medium; account mode Medium-Hard
  (MTProto sessions + Telegram flood limits + terms care).
