# Sendqon — Plugin UI-Surface Check (2026-11-18)

**Why this check exists:** the owner asked whether, alongside installing our own plugins,
their *features and menus* are also being checked from the panel side. The B1–B4 batteries
proved features deeply at API/service level, but nobody had systematically verified what a
tenant/admin actually *sees*. This sweep closes that gap for all 21 own plugins (B1–B4).

**Method:** source review of every plugin + fresh-process probes inside both containers
(dev `sendqon-dev`, prod `sendqon`) + full route tables (1,507 routes, dev == prod) + SPA
bundle analysis (which pages/menus the shipped React app actually contains) + a rendered-page
tour on the dev copy (fresh lane-created dev admin/tenants — see §4). Screenshots: **not
available** — no headless browser exists on this VM, the host, or in the containers
(checked `chromium/google-chrome/wkhtmltoimage` — none installed, and installing one was
out of scope), so the tour records HTTP status + a rendered marker string per page.

**Architecture fact that decides everything below:** the panel is an Inertia + React SPA
whose pages and navigation are hardcoded in the vendor's TypeScript
(`resources/js/Pages/**`, `DashboardLayout.tsx`, gated by Inertia shared props). The plugin
system has **no page-registration and no navigation-registration hook** — a plugin ZIP
installed at runtime cannot add a React page or a menu entry. Core's own seams for plugin
surfaces are: (a) plugin web routes (any response, incl. server-rendered Blade — the core
Booking plugin registers a Blade view namespace exactly this way), (b) Configure drawers on
Admin → Plugins (every plugin with a config schema gets one automatically), (c) the flow
node catalogue — but only via hardcoded core *Access* classes for specific plugins.

## 1. Per-plugin surface table (state at sweep time, before the UI fixes)

| Plugin | Version / state (prod) | Panel surface found | Verdict |
|---|---|---|---|
| MCP (`mcp`) | 1.0.0 active | Admin → Plugins entry + Configure/readiness screens (vendor-prebuilt SPA support) | OK (plan flag `mcp` = false on all plans — owner pricing decision) |
| JazzCash | 1.0.0 inactive, unconfigured | Plugins list + Configure drawer with full schema | OK — by design (owner credentials pending) |
| EasyPaisa | 1.0.0 inactive, unconfigured | same | OK — by design |
| Raast | 1.0.0 inactive, unconfigured | same | OK — by design |
| Stripe | 1.0.0 inactive, unconfigured | same | OK — by design |
| Paystack | 1.0.0 inactive, unconfigured | same | OK — by design |
| Razorpay | 1.0.0 inactive, unconfigured | same | OK — by design |
| YooKassa | 1.0.0 inactive, unconfigured | same | OK — by design |
| Crypto.com Pay | 1.0.0 inactive, unconfigured | same | OK — by design |
| **PTA Mask (`pta_mask`)** | 1.0.0 **active** | **NONE.** JSON endpoints only (`GET/POST /pta-masks`, submit, admin list/review). SPA bundle: zero references to `pta-masks` / "PTA Mask". Only presence = Plugins list row. Prod: 0 applications. | 🔴 **FLAG 1 — fixed in v1.1.0** (see fix report) |
| AI Flow Builder | 1.0.0 active | Works inside the flow editor (generation endpoint); plan flag `ai_flow_generation` false on all plans | OK (owner pricing decision) |
| Knowledge Base | 1.0.0 inactive + unconfigured (by design) | SPA page exists (vendor-prebuilt); activation refused until an embeddings provider is configured + probed | OK — by design (Gemini key pending, owner step) |
| AI Agents | 1.0.1 active | SPA page exists (`/ai-agents`, vendor-prebuilt); plan flag `ai_agents` false on all plans → page gate returns 404 for tenants today | OK (owner pricing decision) |
| Website Chat (`widget`) | 1.0.0 active | Channel hub + widget settings surfaces (core runtime contract) | OK |
| Web Push (`push`) | 1.0.0 active | Channel hub surface | OK |
| Telegram | 1.1.0 active | Channel hub + own companion (server id 3, heartbeat healthy) | OK (bot token = owner step) |
| Telegram Store | 1.0.2 active | Store surface inside Telegram channel | OK (BotFather payment token = owner step; COD works) |
| Email | 1.0.7 active | Channel hub + own companion (server id 4, healthy) | OK (mailbox credentials = owner step) |
| **Cascade (`cascade`)** | 1.0.0 active | HTTP endpoint `POST /integrations/cascade/send` works, **but the flow node is broken**: fresh-process `ChannelRuntimeRegistry::executor('action.cascade_send')` = null (registration in the plugin provider's `boot()` is wiped by `refresh()`, which rebuilds only from channel plugins' `registerRuntime()`), and `action.cascade_send` is **absent from NodeTypeCatalog** (92 types) → the flow editor shows no Cascade node. | 🔴 **FLAG 2 — fixed in v1.1.0 + PR-004** |
| **Spam Score (`spam_score`)** | 1.0.1 active | **API only:** `POST /tools/spam-score/check`; nothing in core calls it; no screen anywhere. | 🔴 **FLAG 3a — fixed in v1.1.0** |
| **HLR (`hlr`)** | 1.0.1 **inactive + unconfigured** (by design — no provider account) | **API only:** `POST /integrations/hlr/check|bulk`, `POST /integrations/hlr/campaigns/{campaign}/preflight`; core never calls `HlrValidator` automatically. | 🔴 **FLAG 3b — screens shipped in v1.1.0, dormant with the plugin** |

## 2. The three flags (detail)

1. **PTA Mask has no UI at all.** The whole workflow (draft → submitted → under_review →
   approved/rejected, mask regex `^(?=.*[A-Za-z])[A-Za-z0-9]{3,11}$` stored uppercase, NTN
   `^[0-9-]{8,15}$`, duplicate approved mask → 422, cross-workspace → 404, reviewer gate
   `can:admin.plugins.update`) existed only as JSON. A tenant could not apply, an admin
   could not review, without API calls. Root cause: it is *our own* plugin — the vendor's
   prebuilt SPA contains pages for vendor-anticipated features only.
2. **Cascade's flow node never existed at runtime.** Two independent breaks: executor
   registration into the wrong registry (wiped on refresh), and no catalogue entry.
   Deeper finding during the fix: the executor also read the tenant from `$run->user_id`,
   which is empty on dispatcher-launched runs — it would have failed `contact_not_found`
   on its first real run even if registered. (Core resolves the tenant via
   `$flow->user_id` everywhere.)
3. **Spam Score + HLR are invisible.** Both work (batteries green in B4) but a tenant
   cannot discover or use them: no screen, and no automatic hook in core's compose/campaign
   flow calls them. No genuine plugin hook into core's compose/campaign screens exists —
   Tools screens served by the plugins are the honest surface (see fix report).

## 3. Plan-gating facts (observed, NOT changed — owner pricing decisions)

- Flags `mcp`, `ai_agents`, `ai_flow_generation`, `knowledge_base`, `telegram`,
  `telegram_store` = **false on all 7 plans** → those features are installed but not
  sellable/usable by tenants until the owner prices them.
- `widget`, `push`, `email` = true on paid plans, false on Free.
- PTA Mask, Cascade, Spam Score, HLR have no plan keys (available whenever active).

## 4. Rendered-page tour (dev copy, 2026-11-18, fresh lane users)

Authenticated with lane-created dev users (`ui-admin@` / `ui-tenant-a@sendqon.local`,
dev copy only). SPA pages report their Inertia component as the rendered marker.

| Page | HTTP | Marker |
|---|---|---|
| Tenant `/overview` | 200 | `Dashboard/Home` |
| Tenant `/messenger` (channel hub) | 403 | `Upgrade/FeatureLocked` — correct for the plan-less test tenant |
| Tenant `/ai-agents` | 404 | `Error` — page gate closed while plan flag is false (§3) |
| Tenant `/pta-masks` *(new)* | 200 | "New application" (Blade) |
| Tenant `/tools/spam-score` *(new)* | 200 | "Check a message" (Blade) |
| Tenant `/integrations/hlr` *(new)* | 200 | "Check one number" (Blade) |
| Admin `/admin/overview` | 200 | `Admin/Dashboard` |
| Admin `/admin/plugins` | 200 | `Admin/Plugins/Index` |
| Admin `/admin/plugins/stripe/configure` | 302 | → `/admin/plugins?configure=stripe` (Configure is a drawer on the Plugins page — same for `pta_mask`, `jazzcash`) |
| Admin `/admin/pta-masks` *(new)* | 200 | "Review Queue" (Blade) |

## 5. Outcome

All three flags were fixed and production-installed the same day — see
`SENDQON-UI-FIXES-REPORT-2026-11-18.md`. Standing rule from the owner (2026-11-18) now
applies to every future plugin battery: **a UI-surface check (menus + pages) is part of
the battery**, not an afterthought.
