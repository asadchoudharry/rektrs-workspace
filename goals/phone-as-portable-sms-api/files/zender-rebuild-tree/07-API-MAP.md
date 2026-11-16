# 07 — API MAP

Sources: Lane 2 (API + webhooks docs), Lane 5 §6 + `LANE-5-API-ROUTES.md`
(231 named routes in `routes/api.php`).

## REST API v1 (tenant API)

- Base: `/api/v1`. Auth: **Bearer token** (Sanctum personal access
  token), shown once at creation. A key can never exceed its creator's
  permissions.
- Permission groups: Account, Contacts, SMS, WhatsApp, WABA, Messenger,
  Campaigns, Flows, **Calls**, Webhooks; `*` = full access.
- Gating: the plan switch **API Access** is required (403
  `feature_not_in_plan` otherwise); channel routes additionally pass
  `channel:<slug>` middleware; feature routes pass `api.feature:<key>`.
- Rate limits: per key / per workspace / per IP, with `Retry-After`.
  Usage meters warn at 80% and 100%.
- **Idempotency:** `Idempotency-Key` header → 24h replay window;
  replayed responses carry `Idempotent-Replayed: true`; a conflicting
  reuse returns 409 `idempotency_conflict`. Keys are pruned daily
  (`api:prune-idempotency-keys`); ledger table `api_idempotency_keys`.
- Sends are async: `POST /api/v1/messages/sms` → **202**. Number
  validation is local (libphonenumber) and free.
- In-app API Docs + downloadable OpenAPI document ship in the product;
  a public contract copy exists in-tree as `resources/contracts/
  public-v1.yaml` (Lane 6 note).

### Endpoint groups (from named routes)

- **Account:** `me`, `usage`, `rates.index`, `subscriptions.current`,
  `subscriptions.index`, `vouchers.redeem`
- **Messages:** `messages.sms`, `messages.whatsapp`, `messages.waba`,
  `messages.email`, `messages.push`, `messages.batch`, `messages.store`,
  `messages.index/show/update/destroy`, `messages.cancel`,
  `messages.edit`, `messages.pin/unpin`, `messages.reaction`,
  `messages.pending`, `messages.inbound`
- **Contacts:** CRUD/upsert (`contacts.upsert`, `contacts.bulk`),
  `contacts.lookup`, `contacts.consent`, notes, tags, groups
  (`groups.*`), segments (+count), imports (store/show/errors), exports
  (store/show/download), `contacts.fields`
- **Conversations (Messenger):** index/show/messages/reply/assign/
  unassign/resolve/reopen
- **Campaigns:** start/launch/pause/resume/cancel/stats/failures
- **Flows & drips:** `flows.trigger`, `flows.runs`, `flows.compiled`,
  `flows.facts`, `flow-runs.show`, `flow-runs.resume`, `drips.enroll`,
  `drips.index`
- **OTP:** `otp.verifications.store/show/check/resend/cancel`
  (see `01-CORE-MODULES/otp-verification.md`)
- **Channels & senders:** `channels`, `channels.available`,
  `connections.index/show`, `senders.index`, `senders.default`,
  `sms-providers.*`, `sims.enable/disable`, `sim-routes.*`,
  `devices.enable/disable`, `check-number(+status)`,
  `numbers.validate`, `unsubscribed.*`
- **Calls (voice):** `calls.index/show/store`, `calls.events`,
  `calls.hangup`, `calls.recording`, `calls.transcript`,
  `calls.voicemail`, `calls.media-streams.store`, voice prompts CRUD
  (`prompts.*`)
- **USSD:** `ussd.*` incl. scripts and schedules CRUD/run
- **Webhooks management:** `webhooks.*` CRUD + `webhooks.events`,
  `webhooks.deliveries.*`, `webhooks.test`, `webhooks.toggle`,
  `webhooks.rotate-secret`
- **Commerce:** `commerce.orders`, `commerce.orders.show`
- **Network (Partner lines):** `network.lines`, `network.quote`
- **Forms:** `forms.index`, `forms.submissions`
- **Gateways (billing):** `gateways.index/show/pending`
- **WhatsApp account mgmt:** `api.v1.whatsapp.*` sub-API; WABA template
  refresh `waba.templates.refresh`
- **Notifications:** `notifications.index/read/read-all`
- **Apps surface:** `api.apps.theme`, `api.apps.translations`
  (mobile app + branded clients read theme/translations from here)

### Internal APIs (not public — server/device facing)

Under `api/v1/internal/*`, each behind its channel middleware + a
server-token middleware. These are the contracts our clean-room servers
must speak (detail in `04-NO-SOURCE/`):

- `internal/android` — gateway phones (pair/login/device/SIM sync,
  pending pull, status PATCH, inbound POST, USSD relay, RCS selectors,
  app update/download, error-reports)
- `internal/whatsapp` — WA binary lifecycle (`accounts` assign/release)
  + `events` ingest; live traffic on Reverb `wa.account.{id}.*`
- `internal/smpp` — `bootstrap`, `gateways`, `gateways/{id}/pending`,
  `events`, `connection-tests/{id}`, error-reporting relay
- `internal/telephony` — `bootstrap`, `pair`, `events`,
  `connections/{id}`, `ussd/{id}`, `outbound/{message_id}`,
  `flows/{id}/facts|compiled`, `prompts/{asset_id}`, `media`,
  `broadcasting/auth`, `public-url`, error-reporting
- `internal/telegram`, `internal/email` — core ships only fallback 503
  handlers (`channel_unavailable`); the real routes arrive with the
  (paid) plugins → our own plugins must register these routes.

### Other route files

`routes/mobile.php` (~117 routes — the mobile app API, core),
`routes/mcp.php` (MCP endpoints), `routes/widget.php` (website-chat
widget), `routes/whatsapp-sign-in.php` (OIDC), `routes/push.php`,
`routes/bookings.php`, `routes/payments.php`, `routes/subscribe.php`,
`routes/channels.php` (Reverb channel authorisation),
`routes/console.php` (scheduler).

## Admin API (separate — paid plugin, we build our own)

Vendor's Admin API plugin ($39) exposes `/api/v1/admin`: full admin
REST (workspaces, members, plans, subscriptions, invoices, charges,
announcements, templates, API keys) as one OpenAPI 3.1 document; auth by
API key or session cookie; enabled per workspace plan. Our rebuild spec:
`02-PAID-PLUGINS/admin-api.md`. This is the surface Operqon/external
automation would use — loose coupling only, per the master plan.

## Error model (Lane 2)

401 `unauthenticated` · 403 `missing_ability` / `forbidden` /
`feature_not_in_plan` / `workspace_pending_review` /
`trial_destination_not_allowed` / `sending_blocked` / `content_blocked`
/ `sender_id_not_approved` · 404 `not_found` · 404/503
`channel_unavailable` · 409 `idempotency_conflict` · 422
`validation_failed` / `contacts_cap_reached` /
`recipient_unsubscribed` / `recipient_blocked` / `not_on_whatsapp` /
`no_active_sim_or_sms_provider` / `insufficient_credits` /
`storage_quota_exceeded` · 429 `rate_limited` · 500 `server_error`.
Our plugins must reuse these codes, not invent new ones.

## Webhooks (core, outgoing)

Configured under Developer > New Webhook; **API Access plan switch
required**. Signing secret shown once.

- Headers: `X-Webhook-Signature: t=<ts>,v1=<hex>`,
  `X-Webhook-Timestamp`, `X-Webhook-Event`, `X-Webhook-Delivery-Id`.
  Body: `{id, event, payload, sent_at}`. HMAC-SHA256 over raw bytes;
  stale timestamps rejected (sample tolerance 300s).
- Delivery: 2xx within 15s = delivered; redirects are NOT followed;
  **private/loopback/metadata addresses are refused at save and at
  delivery** (SSRF guard). Retries: 7 attempts — 60s, 5m, 30m, 3h, 24h,
  72h. HTTP 410 Gone = immediate unsubscribe. Health/Success Rate shown
  over 7 days. Rotating the secret disables the old one immediately.
  Event catalogue also via `GET /api/v1/webhooks/events`.
- Retention: incoming webhook log 30 days; outgoing deliveries 30 days
  (setting) — see `01-CORE-MODULES/privacy-gdpr-security.md`.

### Full event catalogue, grouped by family

- **OTP:** `otp.*` (verification lifecycle)
- **SMS:** `sms.queued`, `sms.sent`, `sms.delivered`, `sms.read`,
  `sms.canceled`, `sms.failed`, `sms.received`
- **WABA:** `waba.message.*` (sent/delivered/read/failed/received),
  `waba.template.approved`
- **WhatsApp (QR):** `wa.message.*`
- **Email:** `email.message.*` (received/sent/delivered/read/failed)
- **Website widget:** `widget.message.*`
- **Web Push:** `push.message.*` (no `received` — push has no inbound)
- **Phone Bridge:** `phone_bridge.message.*`
- **GSM Modem:** `gsm_modem.message.*`
- **Calls & voice:** `call.started`, `call.answered`, `call.ended`,
  `voicemail.received`, `recording.ready`, `transcript.ready`,
  `media_stream.requested`
- **Devices & USSD:** `device.online`, `device.offline`,
  `ussd.result`, `ussd.completed`, `ussd.failed`
- **Contacts & forms:** `contact.created`, `contact.unsubscribed`,
  `form.submitted`, `form.confirmed`
- **Payments & commerce:** `payment.paid`, `commerce.order.*`
  (incl. `cod_confirmed`, `cod_cancelled`)
- **Appointments:** `appointment.*`
- **Campaigns & links:** `campaign.started`, `campaign.completed`,
  `link.clicked` (bots do not count)
- **Billing:** `billing.payment.completed`, `billing.subscription.*`
- **Messenger:** `conversation.created`, `conversation.assigned`,
  `conversation.resolved`, `csat.received`
- **System:** `webhook.test`

Inbound webhook endpoints (other direction): SMS provider callbacks at
`/api/webhooks/channels/sms/<connection-key>` (signature-checked),
WABA at `/api/webhooks/channels/waba` (verify token +
`X-Hub-Signature-256`), PayPal at `/api/payment-gateways/paypal/webhook`,
flow triggers at `POST /api/webhooks/flow/{uuid}` (+ `X-Flow-Secret`,
24h idempotency) and flow resume at
`POST /api/webhooks/flow-runs/{uuid}/resume` (+ `X-Resume-Token`, up to
7 days, max 30).

## MCP surface

Core already contains the plumbing: `laravel/mcp` package,
`routes/mcp.php`, `app/Services/Mcp/`, tables `mcp_oauth_grants` +
`mcp_send_receipts`, and API-key presets (Read Only / Read+Write / Read
Write Send). The paid MCP plugin ($120) is the productised surface:
OAuth or API-key connect for Claude/ChatGPT/Claude Code/Cursor, sending
OFF by default (separate "Allow sending messages" switch), **max 20
messages/hour per connection**, campaigns always draft-only. Our
rebuild — Phase 4 priority #1 — spec: `02-PAID-PLUGINS/mcp.md`.
Channel plugins declare their MCP tools in the channel registry
(`mcpTools`), so our channel plugins expose tools the same way.
