# Sendqon B4 Build Report — Channels + USP-3 (Deliverability engine)

**Date:** 2026-11-18 (PKT) · **Plan:** `SENDQON-OWN-PLUGINS-BUILD-PLAN-2026-11-17.md` §3 Phase B4
**Pattern:** B1–B3 discipline — dev copy first (`~/sendqon-dev/` on offbox-1, own DB + dev-only APP_KEY), per-item battery, production backup → `PluginManager` install → live-safe verification → bake into host build tree → push per item.
**Architecture finding (verified against live core code before building):** core's `ChannelPlugins::PLUGINS` **already pre-registers** all five runtime slugs (`RUNTIME_SLUGS = ['email', 'widget', 'push', 'telegram', 'telegram_store']`, runtime contract **5**) with their plan keys, limit keys, flow nodes, queues, URI prefixes and manifest paths (`Channels/Widget/plugin.json`, `Channels/Push/plugin.json`, `Channels/Telegram/plugin.json`, `Channels/Email/plugin.json`, `TelegramExtensions/Store/plugin.json`). Core also ships the route shells (pointing at `UnavailableChannelEndpoint`), the tenant hub controllers, and most channel logic (widget config/visitors/inbound, push config/subscriptions, omnichannel sender/recorder). Each plugin supplies the runtime surface core resolves by contract: a `ChannelRuntimePlugin` main class (`registerRuntime` / `registerRoutes` / `registerConsole` / `registerSchedule` / `registerCompatibility`), the channel adapter + provider, the service-contract implementations, the public endpoint controllers that replace the shells, and — where the plan calls for one — our own companion service. **No `ChannelPlugins.php` core registration patch is needed** — the registration the plan feared is already in core; the plugins slot into it.
**Credential rule:** no real credentials exist for any B4 item (Telegram bot token, Telegram app api_id/api_hash, HLR provider account, tenant mailbox passwords/OAuth). All are sensitive plugin/connection config fields, entered later in the UI. Dev batteries use stubbed transports and documented test payloads; live verification is marked **PENDING-ACCOUNT** per item.
**Email reality:** outbound port 25 from offbox-1 is **blocked** (proven in an earlier lane) — the Email channel sends through each mailbox's configured SMTP relay (submission port), never direct port-25 delivery; the companion sync/send service design records this precisely.

Per-item sections are appended as each item completes.

---

## Item 1 — Website Chat (widget channel) — COMPLETE, LIVE

**Plugin:** `widget` (type `channel`, runtime_contract 5), v1.0.0, namespace `App\Plugins\Channels\Widget\` at manifest path `Channels/Widget/plugin.json`. Source: Sendqon branch `plugin-widget` @ 898a883 (`plugins/website-chat/`).

**What the plugin supplies** (core already ships the definition, tenant management screens, loader `/widget.js`, visitor services and route shells):

- `WidgetAdapter` — omnichannel adapter. A send is a conditional claim `pending → sent` on the message row, so a replayed or racing dispatch never delivers twice; the visitor receives the message over Reverb and/or the next poll. The realtime broadcast is wrapped best-effort: the core event is `ShouldBroadcastNow`, and core's own events document that a broadcast outage must not fail a send — the battery proved this in dev (no Reverb in the dev copy: first attempt failed the send; after the guard, sends succeed and polling delivers).
- The public visitor API replacing the shells under `/widget/api/{key}`: launcher boot payload (full `WidgetBoot` shape from core's shared TS protocol), session (visitor find-or-start, token issue, ban check, availability, history), messages (cursor poll + post via core's `WidgetInbound`), uploads (core's `recordFile`), heartbeat/status, visitor typing, prechat, attributes, transcript (rate-limited, mail-failure tolerant), broadcasting auth (Pusher-protocol HMAC, only the visitor's own `private-widget.visitor.*` channel), end/search/events/alerts. Unknown keys answer a clean `widget_not_found` 404 (found by the production probe; fixed in-plugin and re-verified before the final install).
- The frame document `/widget/frame/{key}` (blank when the widget is not live or the embedding origin is not allowlisted; CSP `frame-ancestors` set from the widget's domains) and the plugin's own frame app (`frame.js`/`frame.css`, implementing the shared `cw:*` host protocol; poll-first delivery) served from `/widget/assets/*` — fully self-hosted, no CDN.
- Identity: prechat details link the visitor to a known contact through core's `ContactMerger` when the email/phone already belongs to another contact (contacts are unique per workspace); signed identities verify by HMAC-SHA256 over the user id with the connection's identity secret — a forged hash stays unverified and applies nothing. A typed/verified name fills gaps and replaces generated `Visitor NNNN` auto-labels, never a real existing name.
- `HeaderCountryLookup` (the `CountryLookup` contract binding — trusted CDN country headers only), and the `widget-visitors` named rate limiter core's visitor service resolves (registering it is part of the runtime surface; core never registers it).
- Availability uses core's `BusinessHours` helpers (workspace mode + per-widget schedule mode), so the frame's open/away state matches the rest of the product.

**Dev battery (all PASS):** install/activate via `PluginManager`; `ChannelPlugins::live('widget')` true; registry adapter resolves to `WidgetAdapter`, provider to core's `ChannelConnectionProvider`. HTTP battery **21/21**: loader 200; frame serves boot + frame assets for an allowlisted origin and renders blank for a disallowed one; session issues a token and creates the visitor; a visitor message lands as a conversation + inbound `ChannelMessage`; a duplicate `client_id` returns the same message flagged duplicate; bad token 401; heartbeat/typing/prechat/transcript OK; prechat with an already-known email merges into the known contact; broadcasting auth refuses another visitor's channel (403) and, with a configured connection, signs exactly per the Pusher protocol (verified byte-for-byte in-process; the dev copy has no Reverb key/secret, so over HTTP it honestly answers `broadcasting_unavailable` there — production has Reverb configured). Agent reply through core's `MessageSender` → adapter dispatch → status `sent`, visible on the visitor's next poll; re-dispatch idempotent. Identity battery **4/4** (valid HMAC → verified + name/email applied; forged hash → unverified, nothing applied). Country lookup: `CF-IPCountry: PK` → `PK`, `XX` → null. Lifecycle: deactivate → endpoints 503 `channel_unavailable`; uninstall → core shells answer 503 again; reinstall → live.

**Cross-plugin fix (B3 plugin, not core):** the battery exposed that core's `ContactMerger` unconditionally re-points `ai_agent_turns.contact_id` when the table exists, but our B3 `ai_agents` plugin created that table **without** a `contact_id` column — every contact merge crashed wherever AI Agents is installed (dev and production). Fixed in the plugin: migration `2026_11_18_000004_add_contact_id_to_ai_agent_turns.php`, version **1.0.1**, applied in dev and production through `PluginManager` (column verified present both sides), baked into the build tree, pushed to branch `plugin-ai_agents` @ cd75c4f. **No core files were touched; PATCH-REGISTER unchanged.**

**Production state:** fresh backup first (run 2026-11-18T05:37:33Z, status=OK, push=OK). `widget` plugin **installed + Active v1.0.0**; fresh-process verification: `live('widget')` true, adapter + `CountryLookup` resolve to the plugin classes. Public: `/`, `/login`, `/widget.js` → 200; unknown key → 404 on frame and API. Plan flags untouched (seed state: `widget` on for all paid plans, off on Free — tenant enablement remains the owner's call). Baked into `~/sendqon-build/src/app/Plugins/Channels/Widget/`.

**Pending:** none account-side. Tenant widgets are created by tenants in Channels → Website Chat. Known limit: in-frame help search reports unavailable until a knowledge base exposes a cross-plugin search contract (boot carries `helpSearch: false`).

---

---

## Item 2 — Web Push — COMPLETE + LIVE (2026-11-18)

- **Plugin:** slug `push`, channel type, runtime_contract 5, v1.0.0, namespace
  `App\Plugins\Channels\Push\`. Source: `~/workspace/sendqon-plugins/web-push/`.
  **Push source push (initially blocked by the VM's intermittent O_EXCL
  write fault) was CLEARED by the continuation lane: branch `plugin-push`
  @ 0b67d98.** The continuation lane also re-verified items 1–2 in a fresh
  process on production before building further: widget LIVE v1.0.0,
  push LIVE v1.0.0, ai_agents v1.0.1 — all as recorded here; no
  discrepancies found.
- **What it supplies** (everything core's push contracts demand):
  - `WebPushTransport` (`PushTransport`) — minishlink/web-push with the site's
    own VAPID keys from the connection credentials (core's PushSiteController
    generates them at site creation — no external account exists or is needed).
    Outcome mapping: 201 → accepted; 404/410 → gone; 429 → rate_limited
    (Retry-After honoured); 413 → payload_too_large; missing keys →
    vapid_not_configured.
  - `PushAdapter` — capabilities text+subject; send window/refusals from core's
    `PushRuntime::state()`; dispatch claims pending→queued and queues
    `SendPushMessageJob` on `push-send`, delayed past the subscriber's quiet
    hours (site config quiet_hours, subscriber's timezone).
  - `SendPushMessageJob` — settles every outcome through core's StatusUpdater
    (accepted → Sent + `push.message.sent` webhook; gone → subscription expired
    + Failed `subscription_gone`; failures recorded on the subscription state).
  - `ServiceWorker` (`PushWorker`) — renders the site's `push-sw.js` with the
    site public key embedded (core's install verification greps for it), push /
    notificationclick / notificationclose handlers; click-through and close
    tracking ride core's signed `PushTrackingController` URLs.
  - Public API replacing core's shells under `/push/api/{key}` (config,
    registered, subscribe, unsubscribe) — origin-allowlist guarded, loader's
    text/plain JSON convention honoured; subscriptions recorded through core's
    `PushSubscriptions` (plan cap + plan hold apply).
  - Campaigns: `PushCampaignRunnerImpl` + `PushCampaignContentImpl` +
    `ProcessPushCampaignChunkJob` on `push-campaigns` — the full core campaign
    lifecycle (approval guard, audience scope, local-time stamping, pause/
    resume/cancel/stop-pending/restart) with sends only via MessageSender.
  - Flow node `send.push` executor; `push:release-held` command (registered via
    the console kernel's addCommands — the facade's resolveCommands does not
    exist in this Laravel build) scheduled every 15 min + core's own
    `push:fail-stale-queued`.
  - Wire payload byte-mirrors core's TS `push-payload.ts` (FCM web_push 8030
    document, signed click/closed URLs minted by core's PushLinkToken).
- **Dev battery: 44/44 PASS** — registry (9: adapter/transport/worker/runner/
  content/executor/command all resolve to plugin classes in a fresh process);
  site + worker (5: VAPID keys via core's creation path, runtime live, worker
  contains the site key + handlers); pipeline (9: subscription recorded,
  accepted → sent with exact wire shape, gone → failed + subscription expired,
  rejected → failed with code, quiet-hours job delayed ~window end + message
  stays queued, release-held clears a hold); HTTP (8: config/subscribe/
  registered/unsubscribe, evil-origin 403, unknown key 404); campaign + flow
  (13: start→chunk→send→counters→completed, pause/resume/cancel, flow node
  sends + no-contact handled); lifecycle: deactivate → API 503, reinstall →
  200. Delivery outcome logic used a stubbed transport plus a documented fake
  subscription endpoint — real end-to-end delivery is **PENDING-ACCOUNT**
  (needs a real visitor subscribing on a real tenant site; no credential is
  involved).
- **Production:** backup 2026-11-18T05:55:41Z status=OK push=OK → installed +
  Active v1.0.0 → fresh-process live(push)=true with plugin bindings → public
  `/`, `/login` 200, unknown site key → plugin 404. Baked into
  `~/sendqon-build/src/app/Plugins/Channels/Push/`. Plan flags untouched.
- **One plugin bug found + fixed during the battery:** command registration
  used a non-existent facade method; switched to the console kernel's
  `addCommands()` (guarded). No core files touched.

---

---

## Item 3 — Telegram channel (bot mode + own companion + account mode) — COMPLETE + LIVE

**Plugin:** slug `telegram` (type `channel`, runtime_contract 5), **v1.1.0**, namespace `App\Plugins\Channels\Telegram\`. Source: Sendqon branch `plugin-telegram` @ 65fe641 (`plugins/telegram/`, incl. `server/`). The first lane left a partial source; the continuation lane assessed it against live core code, rewrote the main class to the proven channel-plugin shape, and completed the runtime surface core hard-references under `Runtime\` (business connections, groups, command parsing, command publisher, server assigner, server kind, HPKE move client) plus the five tables core queries (`telegram_business_connections`, `telegram_groups`, `telegram_channels`, `channel_subscribers`, `telegram_outreach_stats`). **Twelve plugin bugs were found by the dev batteries and fixed in the plugin** (wrong base class, wrong DTO namespaces, `StatusUpdate` lookup semantics, a login state machine that never advanced, flood-wait treated as failure instead of a delay, a `validate()` call that stripped the very event fields the handlers need, an over-long MySQL index name, and more). No core files touched.

**Dev battery: 82/82 PASS** (two scripts) + lifecycle in separate processes — bot connect with faked Bot API, inbound poll incl. opt-in consumption + join requests + callback answers, outbound send settled with the provider id stored, blocked → `bot_blocked`, 429 → retry_after parsed; adapter refusals (`telegram_connection_disabled` / `telegram_bot_not_configured` / `telegram_server_not_configured`); companion bus over kernel HTTP (401 for missing/bad/wrong-kind tokens; the full login state machine `login_start → code_sent → password_required → ready`; account send settled; **flood_wait requeues the command and does NOT fail the message**; group/channel learning from events; heartbeat); business-connection routing stamped onto sends; server kind + least-loaded assigner; move client prepare/export(digest verified)/import against a faked companion; public-sender mutations; campaigns (broadcast post + contact audience); flow executors. Deactivate → live false; uninstall → row gone; reinstall → live true in a fresh process.

**Own companion server** (`server/companion.py`, Python + Telethon): polls the plugin's internal bus, executes logins/sends/mutations/join decisions, pushes inbound events, serves the HPKE move endpoints (RFC 9180 base mode implemented in pure Python: info = suite string, empty AAD, wire = nonce‖ciphertext). **Dev battery against the REAL companion:** placeholder-token config → refuses to start (exit 2); heartbeat lands (`last_health=healthy`); a queued `login_start` with no api credentials anywhere was claimed and honestly failed `app_not_configured`, driving the connection to `auth_state=failed`; **move round-trip over direct HTTP: prepare → export (sealed, digest verified) → import returned the session identity** — the app-client→companion path in dev is additionally constrained by core's own move transport policy (HTTPS, or HTTP only on loopback in local/testing), which is core's design, recorded here honestly. Ops rule (same as the vendor companions): never wipe the companion's data volume casually — sessions live there.

**Production:** backup first (run 2026-11-18, status=OK push=OK, DB dump 8,792,186 B) → telegram **ACTIVE v1.0.0**, then **v1.1.0** with the store update; ServiceServer **"Telegram Server" (id 3, `http://sendqon-telegram:8900`, capacity 500)** created through the app's own model + `issueServiceToken()`; companion deployed as container `sendqon-telegram` in the companions compose (config.json 600 via `TelegramServerKind::configJson`, data volume, no host ports); **heartbeat healthy in production**; fresh-process `live('telegram') = true`, telegram kind registered, all 7 plugin tables present, site 200. Baked into `~/sendqon-build/src/app/Plugins/Channels/Telegram/` (37 PHP files). **Live verification PENDING-ACCOUNT:** a real bot token (BotFather) and/or Telegram app api_id/api_hash for account mode are sensitive config entered in the UI; none exist yet.

---

## Item 4 — Telegram Store — COMPLETE + LIVE

**Plugin:** slug `telegram_store` (type `telegram_extension`, runtime_contract 5 — the slug sits in core's RUNTIME_SLUGS, so contract 5 is required), **v1.0.2**, namespace `App\Plugins\TelegramExtensions\Store\`. Source: Sendqon branch `plugin-telegram_store` @ 67fe670 (`plugins/telegram-store/`). Parent = telegram (activation requires it; battery-proven: parent off → store not live).

**What it supplies:** the two classes core hard-references (`StoreReadiness` for the admin setup screen; the `PaymentNeedsReview` mailable core's mail previews instantiate); the in-Telegram storefront (catalog → product → cart → checkout) driven through the telegram plugin's Bot API as interactive messages (not conversation messages); orders written into **core's commerce tables** following `CommerceIngest` conventions — all money integer minor units, line items in core's `{title, qty, unit_price}` shape; **COD orders** (rail `external`, cod_state/cod_token) and **Telegram Payments invoices** (rail `provider`) when a BotFather provider token is set in the plugin's sensitive config — hidden otherwise; pre-checkout verification (pending order + exact amount + currency) and successful-payment settlement (paid + charge ids + `order_paid` event); the `send.store_product` flow node (product card with Add-to-cart / Open-store buttons, via telegram v1.1.0's reply_markup support + the new `TelegramInteractiveUpdate` event); the tenant catalog API `api/v1/commerce/products`; the `tg-store/{connection}` web redirect to the bot.

**Dev battery: 33/33 PASS** — store live + `CommerceAccess::providerLive('telegram')`; /store opens the catalog; view/add/cart accumulation; checkout offers COD and hides card payment without a token; COD order created (rail external, cod pending + token, total = 550,000 minor units, contact linked, `order_created` + `cod_pending` events, cart cleared); invoice sent with payload `tgorder:<checkout_token>` and minor-unit amounts; pre-checkout accepts the matching query and refuses a mismatch; successful payment settles (status paid, telegram charge id stored, `order_paid` event); flow node dry-run + real card carrying the store markup; `StoreReadiness` ready; products API lists the catalog; parent gate. **Production:** telegram_store **ACTIVE v1.0.2**, fresh-process live + providerLive true; baked into `~/sendqon-build/src/app/Plugins/TelegramExtensions/Store/`. **Live verification PENDING-ACCOUNT:** needs a real bot (+ a BotFather payment provider for card checkout; COD works without one).

---

## Item 5 — Email channel + own companion — COMPLETE + LIVE

**Plugin:** slug `email` (type `channel`, runtime_contract 5), **v1.0.7**, namespace `App\Plugins\Channels\Email\`. Source: Sendqon branch `plugin-email` @ 67b65ee (`plugins/email/`, incl. `server/`).

**What it supplies:** `EmailAdapter` in core's real adapter contract (capabilities with subject/cc, open send window, refusals, default-mailbox resolution, dispatch = claim pending→queued + one bus command row); `EmailServerKind` (with the `defaultPort`/`healthMetrics`/`isHealthy` methods core's contract docblock assigns to the email plan) + least-loaded `EmailServerAssigner` + `EmailMoveClient`; the companion bus (`EmailInternalController`: config — mailbox IMAP/SMTP settings served **only** over the service-token bus — command claim/result settling via `StatusUpdater`, events: inbound mail → `InboundRecorder` with the subject in core's dedicated field, DSN bounces → suppression + message failure, heartbeat); mailbox connect/probe/disconnect controllers (credentials in the encrypted cast; the mailbox password is a sensitive field, never displayed back); email campaigns (`EmailCampaignRunner` + chunk job on core's `email-campaigns` queue, subject/HTML from the campaign's `email_settings`); the `send.email` flow node (also the extension's reply executor); suppressions (plugin table + core's `unsubscribed_emails` both honoured before queueing); the **mailbox warmer** (rising daily volume by mailbox age, warm-up sends between mailboxes on the same server, health + prune); and all **seven console commands core lists** for the slug. Sending velocity is core's own `SendVelocity` (email_* plan limits) — the plugin deliberately does not duplicate it.

**Dev battery: 26/26 PASS** — live + commands registered + kind available; adapter refusals (disabled mailbox, missing SMTP settings, suppressed recipient not queued); happy-path send → bus claim → companion result settles the message Sent with the provider Message-ID; bus auth (401 without token; wrong-kind token rejected by kind-scoped lookup); inbound event recorded threaded with subject; bounce event → suppression created + original message failed; flow node dry-run + real send; campaign chunk queues one companion command per recipient; warmup tick queues warm-up sends; lifecycle (deactivate → live false → reactivate → true).

**Own companion** (`server/companion.py`, Python stdlib IMAP/SMTP + aiohttp): IMAP sync with per-mailbox last-UID state, SMTP submission sends, DSN detection, warm-up delivery, HPKE move endpoints. **Dev end-to-end against a scripted fake IMAP/SMTP server: PROVEN** — heartbeat healthy; the seed inbox message synced into the shared inbox; a real MessageSender send was claimed by the companion, delivered over SMTP to the fake server, and settled **Sent** with the companion-generated Message-ID. Placeholder-token config → refuses to start. **Port 25 honesty:** outbound port 25 is blocked on offbox-1; the companion only ever uses each mailbox's configured SMTP **submission** port (587/465) — there is no direct port-25 path, by design.

**Production:** email **ACTIVE v1.0.7**; ServiceServer **"Email Server" (id 4, `http://sendqon-email:8901`, capacity 500)**; companion container `sendqon-email` deployed in the companions compose; **heartbeat healthy in production**; fresh-process `live('email') = true`; baked into `~/sendqon-build/src/app/Plugins/Channels/Email/` (23 PHP files). **Live verification PENDING-ACCOUNT:** a real tenant mailbox (IMAP/SMTP credentials, or Gmail/Microsoft OAuth apps in core's `email_sign_in` settings for one-click sign-in).

**Proposed PATCH-REGISTER entry (not applied — no core edits in B4):** core's `ServerMoves::clientFor()` hardcodes move clients for whatsapp/telegram and throws `unsupported` for email, and `recount()` likewise — so mailbox moves cannot be initiated from core today. The companion implements the move endpoints and `EmailMoveClient` mirrors the wire protocol; enabling moves later is a two-line core arm (`KIND_EMAIL => new EmailMoveClient($server)`) plus the recount kind, to be taken as a registered patch if the owner wants mailbox moves.

---

## Item 6 — HLR number validation (USP-3) — COMPLETE + LIVE (inactive until provider configured)

**Plugin:** slug `hlr` (type `integration`), **v1.0.1**, namespace `App\Plugins\Integrations\Hlr\`. Source: Sendqon branch `plugin-hlr` @ 93a4e2e (`plugins/hlr/`).

**Provider contract (chosen at build time, recorded here as the plan card requires):** `POST {provider_url}` with `Authorization: Bearer {api_key}` and JSON `{"number": "+92…"}`; the provider answers `{"status": "valid"|"invalid"|"unknown", "carrier": "…", "ported": bool}`. Any HLR provider honouring that shape plugs in without code changes. URL + key are **sensitive plugin config**; the app's own rule refuses activation until both are set — so on production the plugin is **installed, INACTIVE, config empty**, which is the correct end state until the owner adds a provider account (**PENDING-ACCOUNT**). Without config, checks honestly return `unknown` and nothing is filtered. Results cache per workspace+number for 30 days (`hlr_lookups`); Pakistani local format `03XXXXXXXXX` normalises to `+923XXXXXXXXX`. Surfaces: single check, bulk audience filter, and a **campaign preflight** that validates pending recipients and excludes proven-invalid ones through core's own `CampaignDeliveryRules::skip` (reason `hlr_invalid`, visible in the recipient list — never silent deletion), returning valid/invalid/unknown counts.

**Dev battery (stubbed provider over `Http::fake`):** valid → status + carrier recorded; second check served from cache; invalid and unknown classified; audience split 1/1/1; lookups persisted; preflight counts exact, invalid recipient skipped with `hlr_invalid`, valid recipient untouched. (Battery totals are in the consolidated count below.)

---

## Item 7 — Cross-channel cascade (USP-3) — COMPLETE + LIVE

**Plugin:** slug `cascade` (type `integration`), **v1.0.0**, namespace `App\Plugins\Integrations\Cascade\`. Source: Sendqon branch `plugin-cascade` @ b905b17 (`plugins/cascade/`).

**Design:** one logical send, up to three physical attempts (default WhatsApp → SMS → email, order configurable). The plugin owns **no transport** — every attempt is a core `MessageSender` send, so opt-outs, plan feature gates, sending velocity and the **WhatsApp 24h window** (the WA adapter's own send-window refusal) apply exactly as for a direct send; a refusal or a failed message logs and advances the cascade; an accepted (queued/sent) message stops it. Every attempt is written to `cascade_attempts` (cascade id, channel, step, outcome, detail, message id). Surfaces: tenant endpoint `POST integrations/cascade/send` and the `action.cascade_send` flow node (sent branch carries the delivering channel; exhausted cascade → error branch).

**Dev battery:** WhatsApp refused (`channel_not_available` — no WA connection/plan path in dev) → email accepted, attempts logged in order and persisted; the full three-channel chain delivers (in dev, SMS accepted at step 2 — the dev tenant has a working SMS route — proving stop-on-first-acceptance); single-channel email send; a contact with no identities exhausts honestly with `delivered_channel = null` and all steps logged; flow node dry-run simulates, real run sends via email. (Battery totals below.)

---

## Item 8 — Spam-content score (USP-3) — COMPLETE + LIVE

**Plugin:** slug `spam_score` (type `tool`), **v1.0.1**, namespace `App\Plugins\Tools\SpamScore\`. Source: Sendqon branch `plugin-spam_score` @ d2f4c83 (`plugins/spam-score/`).

**Design:** advisory pre-send scoring — `POST tools/spam-score/check {text}` → `{score 0–100, level clean|review|high, reasons[]}`. Transparent heuristics only (link density, link shorteners, ALL-CAPS ratio, punctuation bursts, bait phrases in **English, Urdu and Roman Urdu**, money+win combinations, multiple-phone bait, repeated characters, link-only micro-messages). **It never blocks a send by itself** — it warns, the tenant decides, exactly per the plan card.

**Dev battery:** a bait+shortener message scores **high** (≥50) with ≥3 reasons; a normal school fee message scores **clean** (<25); a link-heavy sale message lands in review territory; Urdu bait text is detected. (Battery totals below.)

---

## Consolidated battery totals (dev copy, all green)

| Item | Battery |
|---|---|
| 1 · Website Chat | HTTP 21/21 + identity 4/4 |
| 2 · Web Push | 44/44 |
| 3 · Telegram plugin | 82/82 + lifecycle |
| 3 · Telegram companion (real) | placeholder refusal · heartbeat · honest login failure · HPKE move round-trip |
| 4 · Telegram Store | 33/33 |
| 5 · Email plugin | 26/26 |
| 5 · Email companion (real, fake IMAP/SMTP) | heartbeat · IMAP sync into inbox · SMTP send settled Sent |
| 6 · HLR | 9/9 (within the 23-check USP-3 battery) |
| 7 · Cascade | 9/9 (within the 23-check USP-3 battery) |
| 8 · Spam score | 5/5 (within the 23-check USP-3 battery) |

## Summary — production state at close (fresh-process verified)

| Item | Plugin | Version | Production state |
|---|---|---|---|
| Website Chat | `widget` | 1.0.0 | **Active, live** |
| Web Push | `push` | 1.0.0 | **Active, live** |
| Telegram | `telegram` | 1.1.0 | **Active, live** + companion `sendqon-telegram` healthy (server id 3) |
| Telegram Store | `telegram_store` | 1.0.2 | **Active, live**, commerce provider live |
| Email | `email` | 1.0.7 | **Active, live** + companion `sendqon-email` healthy (server id 4) |
| HLR | `hlr` | 1.0.1 | Installed, **inactive + unconfigured by design** (owner provider account) |
| Cascade | `cascade` | 1.0.0 | **Active** |
| Spam score | `spam_score` | 1.0.1 | **Active** |

All eight plugins are baked into the host build tree (`~/sendqon-build/src/app/Plugins/…`). No core files were edited anywhere in B4; no plan features, prices or flags were changed (tenant enablement remains the owner's pricing decision, as in B1–B3). Site `/` → 200 after every install; all containers Up. One cross-plugin fix shipped along the way (B3 `ai_agents` v1.0.1 `contact_id`, item 1).

## Push ledger (Sendqon repo, author "Muse (Sendqon)")

| Branch | Hash | Content |
|---|---|---|
| `plugin-widget` | 898a883 | Website Chat source (first lane) |
| `plugin-ai_agents` | cd75c4f | B3 fix: `contact_id` on `ai_agent_turns` (v1.0.1) |
| `plugin-push` | 0b67d98 | Web Push source (pending push cleared by continuation lane) |
| `plugin-telegram` | 71bc2ef → **65fe641** | Telegram v1.0.0 + companion; then v1.1.0 store hooks + pip-only companion Dockerfile |
| `plugin-telegram_store` | 67fe670 | Telegram Store v1.0.2 |
| `plugin-email` | 67b65ee | Email channel v1.0.7 + companion |
| `plugin-hlr` | 93a4e2e | HLR validation v1.0.1 |
| `plugin-cascade` | b905b17 | Cross-channel cascade v1.0.0 |
| `plugin-spam_score` | d2f4c83 | Spam content score v1.0.1 |
| `rebuild-tree` | (this report) | B4 consolidated report |
| rektrs-workspace `main` | (this report) | B4 consolidated report (goal files) |

## Pending-account / owner-side list (nothing else outstanding)

1. **Telegram bot token** (BotFather) — Admin → Plugins → Telegram / Channels → Telegram → connect a bot; and/or **Telegram app api_id/api_hash** (my.telegram.org) for account mode. Until then the telegram channel is live but has no real bot/account.
2. **Telegram Store payments** — a BotFather payment provider token in the store plugin's config enables card checkout; COD works without it. A real bot (item 1) is required for any live storefront use.
3. **Email mailbox** — a real mailbox's IMAP/SMTP credentials (Channels → Email → connect), or Gmail/Microsoft OAuth apps in Admin → Settings → email_sign_in for one-click sign-in.
4. **HLR provider account** — provider URL + API key in the HLR plugin's Configure, then Activate (the plugin refuses activation unconfigured, by design).
5. **Web Push** — no credential exists; real delivery needs a real visitor subscribing on a real tenant site.
6. **Plan flags** — per-plan feature enablement for the new channels/integrations remains the owner's pricing decision (unchanged from B1–B3); nothing was flipped.
