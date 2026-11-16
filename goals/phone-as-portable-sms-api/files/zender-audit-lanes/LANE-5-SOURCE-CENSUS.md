# LANE 5 — SOURCE CENSUS: Zender 5.0.4 (read-only audit)

Audited trees (nothing modified):
- App: `~/workspace/zender-branches/app/` (git branch checkout of the purchased package)
- Free plugins: `~/workspace/zender-branches/plugin-{android-gateway,whatsapp,smpp,whatsapp-signup,legacy-importer}/`
- Raw package: `~/workspace/zender-package/` (`Install/` = same app tree, `Documentation/` = vendor HTML docs)

Version proof: `app/.version` contains `5.0.4`.

Sub-files: [LANE-5-DB-TABLES.md](LANE-5-DB-TABLES.md) (all 316 tables), [LANE-5-API-ROUTES.md](LANE-5-API-ROUTES.md) (named routes in routes/api.php).

---

## 1. Tree census

App tree totals: **26,829 files, 480 MB** including a committed `vendor/` (~19,656 files). Excluding `vendor/`: **7,173 files**.

File counts by extension (excluding `vendor/`):

| Ext | Count | Notes |
|---|---|---|
| php | 3,564 | backend + Blade |
| js | 1,213 | mostly prebuilt/widget + generated |
| tsx | 1,023 | React components/pages |
| json | 346 | manifests, lang, configs |
| jpeg | 300 | bundled imagery (lang/docs/assets) |
| ts | 294 | |
| svg | 275 | icons |
| png | 57 | |
| css | 11 | Tailwind entry points |
| woff2 | 16 | fonts |

Top directories (excluding vendor):

| Dir | Files | Size | Contents |
|---|---|---|---|
| `app/` | 2,891 | 19 MB | Laravel backend (2,891 files, ~2,800 PHP) |
| `database/` | 531 | 2.6 MB | 510 migrations, seeders, factories |
| `lang/` | 206 | 8.5 MB | `en`, `ar`, `ja` locale trees |
| `public/` | 1,568 | 16 MB | web root; includes prebuilt `public/build/` assets |
| `resources/` | 1,568 | 17 MB | frontend source + Blade views |
| `storage/` | 310 | 49 MB | app/framework/logs scaffolding + bundled files |
| `routes/` | 14 | 352 KB | see §6 |
| `config/` | 32 | 156 KB | Laravel + product configs (incl. `config/plugins.php`, `config/channel_plugins.php`) |
| `bootstrap/` | 3 | 36 KB | `app.php`, `providers.php`, cache |
| `scripts/` | 4 | 24 KB | build helpers (`build-widget-frame.mjs`, `generate-api-webhooks.php`, …) |

Root files of note: `artisan`, `composer.json`/`composer.lock`, `package.json`/`package-lock.json`, `vite.config.js` + `vite.widget.config.ts` + `vite.widget-frame.config.ts` (three separate Vite builds: main app, website-chat widget, widget frame), `tsconfig.json`, `components.json` (shadcn/ui), `autosetup.sh` (vendor VPS auto-installer), `.env.example`, `.version` (= `5.0.4`), `README.md`.

**Frontend location:** `resources/js/` — Inertia/React SPA source: **397 page components** (`resources/js/Pages/**/*.tsx`), **592 components** (`resources/js/components/`), 1,315 `.ts`/`.tsx` files total; sub-areas `Layouts/`, `hooks/`, `lib/`, `contexts/`, `types/`, `generated/`, and `widget/` (the embeddable website-chat widget source). Blade is thin: `resources/views/` holds `app.blade.php` (SPA shell) plus mail/invoice/status/subscribe templates.

The raw package (`~/workspace/zender-package/`, 365 MB) contains the same app under `Install/` plus `Documentation/`.

---

## 2. Tech stack (exact, from the lock files)

`composer.json` self-describes: *"Zender v5.0 — SMS + WhatsApp messaging platform on Laravel 13 + React 19 + Inertia 3"*, package name `titansystems/zender-laravel`.

### Backend — `composer.json` / `composer.lock`

- **PHP:** `^8.4` (composer.json `require.php`)
- **Laravel framework: `v13.37.0`** (composer.lock) — this settles the previously UNVERIFIED Laravel version: **Laravel 13**.
- Inertia server: `inertiajs/inertia-laravel v3.0.6`
- Websockets: `laravel/reverb v1.10.0` (first-party Reverb server; frontend uses `laravel-echo` + `pusher-js`, so Pusher protocol)
- Auth: `laravel/sanctum v4.3.1` (tenant API tokens), `laravel/passport v13.7.6` (OAuth — used by the MCP/OAuth surface), `laravel/socialite ^5.25` (Google/Facebook/GitHub login), `pragmarx/google2fa ^8.0` (TOTP 2FA), `firebase/php-jwt ^7.0` + custom JWT secret for mobile/device flows
- Firebase: `kreait/firebase-php 8.2.0` + `kreait/laravel-firebase ^7.0` (FCM push to Android gateways)
- MCP: `laravel/mcp v1.0.1` (first-party MCP server package — the paid "MCP plugin" surface is built on core plumbing; see `routes/mcp.php`, `app/Services/Mcp/`)
- Payments SDKs **in core**: `stripe/stripe-php v20.0.0`, `twilio/sdk 8.11.4` (also an SMS driver), `razorpay/razorpay ^2.9`, `yoomoney/yookassa-sdk-php ^3.13` (gateway plugins wrap these)
- Data/media: `spatie/laravel-medialibrary 11.23.1`, `spatie/laravel-data ^4.8`, `spatie/laravel-schemaless-attributes`, `staudenmeir/eloquent-has-many-deep`, `staudenmeir/eloquent-json-relations`, `doctrine/dbal ^4.4`
- Docs/files: `mpdf/mpdf` (PDF invoices), `openspout/openspout` (spreadsheet import/export), `phpoffice/phpword`, `smalot/pdfparser` (knowledge-base ingestion)
- Utilities: `giggsey/libphonenumber-for-php` (number parsing), `minishlink/web-push` (Web Push), `maxmind-db/reader` (GeoIP), `google/recaptcha`, `bacon/bacon-qr-code`, `symfony/expression-language` (flow conditions), `symfony/html-sanitizer`, `tightenco/ziggy` (route names in JS)
- Dev: PHPUnit 11.5, Paratest, Laravel Breeze/Pail/Pint/Sail, Spectator (OpenAPI testing), Mockery, Faker

### Frontend — `package.json` / `package-lock.json`

- **React `^19.0.0`**, `@inertiajs/react ^3.0.0`, **Vite `^8.1.0`**, TypeScript `^5.0.2`, Tailwind CSS `^4.3.2` (`@tailwindcss/vite`)
- UI kit: Radix UI primitives (full set), `lucide-react` icons, `@tanstack/react-table`, `recharts`, Tiptap 3 (rich text), `@xyflow/react` + `@dagrejs/dagre` (chat-flow builder canvas), `@monaco-editor/react`, Leaflet (maps), `laravel-echo` + `pusher-js` (Reverb client), `qrcode.react`, `sonner` (toasts), `cmdk`, `esptool-js` (ESP32 flashing for Phone Bridge adapters, in-browser)
- Build: `npm run build` = auth-manifest generation + `tsc` + three Vite builds + widget/telegram-store bundling scripts (`scripts/*.mjs`)
- Tests: Vitest 4 + Testing Library

Runtime processes implied by `package.json` scripts + `routes/console.php`: web (PHP-FPM/`artisan serve`), queue workers (many named queues, §12), Reverb websocket server (`php artisan reverb:start`, port 8892 in dev script), scheduler (cron `schedule:run`).

---

## 3. Config — `.env.example` keys (names only, grouped)

File: `app/.env.example` (55 keys; all values are placeholders — no real secrets found in the example).

- **App:** `APP_NAME, APP_ENV, APP_KEY, APP_DEBUG, APP_URL, APP_LOCALE, APP_FALLBACK_LOCALE`
- **Database:** `DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD`
- **Cache/session/queue/broadcast:** `CACHE_STORE, QUEUE_CONNECTION, SESSION_DRIVER, SESSION_LIFETIME, SESSION_SECURE_COOKIE, SESSION_DOMAIN, BROADCAST_CONNECTION`
- **Mail:** `MAIL_MAILER, MAIL_HOST, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD, MAIL_SCHEME, MAIL_FROM_ADDRESS, MAIL_FROM_NAME`
- **Social login (Socialite):** `GOOGLE_CLIENT_ID/SECRET/REDIRECT_URI`, `FACEBOOK_*`, `GITHUB_*`
- **WhatsApp Business (Meta):** `WABA_APP_ID, WABA_APP_SECRET, WABA_CONFIG_ID, WABA_GRAPH_API_VERSION, WABA_WEBHOOK_VERIFY_TOKEN`
- **Auth/misc:** `JWT_SECRET`, `FFMPEG_PATH` (voice-note transcoding), `TRUSTED_PROXIES`
- **Logging:** `LOG_CHANNEL, LOG_DAILY_DAYS, LOG_LEVEL, LOG_DEPRECATIONS_CHANNEL`
- **Storage (S3):** `FILESYSTEM_DISK, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, AWS_BUCKET, AWS_USE_PATH_STYLE_ENDPOINT`

Note: most product configuration does **not** live in `.env` — it lives in the DB table `system_settings` (admin UI; encrypted for secrets, see §9) and per-plugin config. Reverb/Pusher/Firebase keys are admin-managed settings, not `.env` keys in the example.

Secret hygiene: no real credentials were found in `.env.example`. (Vendor plugin licence codes are *not* in the tree — they are placeholders, §9.)

---

## 4. Database map

- **510 migration files** in `app/database/migrations/`; **316 unique tables** created via `Schema::create()` (full list: [LANE-5-DB-TABLES.md](LANE-5-DB-TABLES.md)).
- Plugin migrations add tables on install (e.g. Legacy Importer adds `legacy_import_runs`, `legacy_import_maps` via its manifest-listed migration — §5).

Grouped summary of the 316 core tables:

- **Identity & workspaces:** `users, admin_roles, workspace_roles, workspace_invitations, personal_access_tokens, oauth_*` (Passport: access tokens, auth codes, clients, device codes, refresh tokens), `password_reset_tokens, sessions, login_handoff_tokens, oidc_signing_keys, user_consents, user_notifications, user_onboarding_progress, onboarding_*` (flows/steps/contents), `whatsapp_sign_in_apps, whatsapp_sign_in_grants` (Sign-in with WhatsApp), `mobile_devices, mobile_sign_in_tokens`
- **Messaging core:** `messages, message_attachments, message_deliveries, message_reactions, message_translations, message_rollups, message_rollup_state, platform_message_rollups, message_connection_rollups, channel_messages, channel_connections, channel_webhook_events, conversations, conversation_*` (events, labels, notes, participants, reads, rounds, views), `messenger_teams, messenger_team_members, messenger_macros, messenger_reads, messenger_domain_releases, canned_responses, quick_replies, csat_surveys, sla_policies, assignment_rules, agent_round_robin_cursors, agents`
- **Contacts:** `contacts, contact_aliases, contact_consents, contact_fields, contact_field_values, contact_groups, contact_group, contact_identities, contact_imports, contact_import_errors, contact_exports, contact_notes, contact_segments, contact_tags, contact_tag, contact_tasks, contact_unsubscribe_tokens, unsubscribed, unsubscribed_emails`
- **Campaigns & flows:** `campaigns, campaign_recipients, campaign_variants, campaignables, scheduled_messages, sequences, sequence_enrollments, flows, flow_nodes, flow_edges, flow_runs, flow_run_steps, flow_answers, flow_run_idempotency, flow_schedule_holds, date_trigger_cursors, date_trigger_occurrences`
- **SMS/Android/telephony:** `devices, device_connections, device_diagnostics, device_heartbeats, device_invites, device_offline_alerts, device_pairings, device_sign_in_challenges, device_update_notices, sims, sim_carrier_events, sim_route_rules, sms_provider_routes, gateways, gateway_customers, gateway_webhook_events, smpp_assignment_history, calls, call_events, call_transcripts, call_agent_rings, call_contact_graphs, call_media_streams, call_tombstones, call_uploads, call_webhook_marks, call_log_exports, phone_bridge_pairings, telephony_assignment_history, voice_prompts, voice_flow_versions, voicemail_reads, ussd, ussd_schedules, ussd_scripts, sender_ids, dlt_templates, sent, received, scheduled` (legacy-named tables), `sms_campaign_processed`
- **WhatsApp (QR):** `wa_accounts, wa_account_events, wa_instances, wa_connect_links, wa_connection_alerts, wa_groups, wa_group_members, wa_poll_votes, wa_reactions, wa_received, wa_sent, wa_server_releases, wa_suppressions, wa_library_errors, wa_warmer_*` (conversations, messages, partners, runs)
- **WABA:** `waba_accounts, waba_phone_numbers, waba_templates, waba_template_library_entries, waba_template_library_variants, waba_received, waba_sent, waba_scheduled, waba_reactions, waba_entry_points, waba_onboarding_attempts, waba_coexistence_syncs, waba_contact_sync_links, meta_webhook_events, ctwa_*` (Click-to-WhatsApp ads: ads, ad_conversations, attribution_settings, conversion_configs, conversions, referrals)
- **Billing/SaaS:** `plans, plan_ai_provider, plan_service_servers, plan_usage_alerts, plan_wa_servers, subscriptions, transactions, credit_packs, credit_pack_plan, credit_reservations, credit_transactions, vouchers, voucher_redemptions, payment_accounts, payment_links, disputes, referral_codes, referrals, referral_credit_transactions`
- **Plugins & servers:** `plugins` (slug/status/config/migrations ledger), `service_servers, service_server_moves, plan_service_servers`
- **Network (partner line-sharing):** `network_lines, network_line_country_rates, network_charges, network_reply_routes, network_reply_route_events, network_reports, partners, partner_ledger, partner_payouts`
- **Market (plugin marketplace):** `market_categories, market_products, market_orders, market_order_events, market_license_codes`
- **Commerce (Telegram Store etc.):** `commerce_stores, commerce_products, commerce_product_variants, commerce_carts, commerce_checkouts, commerce_orders, commerce_order_events, commerce_customer_links, shipping_addresses`
- **Bookings:** `appointments, appointment_calendar_events, appointment_trigger_fires, booking_pages, booking_services, booking_members, booking_service_member, booking_time_off, calendar_connections, calendar_busy_blocks, calendar_event_deletes`
- **AI/knowledge:** `ai_providers, ai_usage_logs, user_ai_keys, user_ai_feature_models, knowledge_bases, knowledge_sources, knowledge_chunks, knowledge_queries, knowledge_workspaces, prompt_assets, mcp_oauth_grants, mcp_send_receipts`
- **Channels misc:** `widget_visitors, widget_campaigns, widget_campaign_stats, widget_proof_*` (events/presence/stats), `push_subscription_states, fcm_sends, google_sheet_*` (connections, files, operations, row_occurrences, subscriptions), `integration_site_routing` (WordPress/WooCommerce-style site connectors)
- **Platform/ops:** `system_settings, system_heartbeats, cron_runs, audit_logs, abuse_flags, workspace_abuse_settings, send_velocity_counters, api_idempotency_keys, jobs, job_batches, failed_jobs, cache, cache_locks, stored_files, file_folders, languages, translation_overrides, custom_pages + contents/versions, landing_*` (contents/drafts/items/sections/versions), `pages, tickets, ticket_messages, ticket_attachments, status_*` (incidents, observations, subscribers, daily rollups, email sends), `setup_check_runs, connection_update_notices, privacy_requests, account_data_exports, account_deletion_requests, contact_data_exports, sentry_pending_reports` (error-report outbox, §9), `otp_settings, otp_verifications, otp_prefix_suspensions, subscribe_forms, subscribe_form_submissions, cookie_consents, tracked_links, tracked_link_codes, link_clicks, report_email_sends`

### Seeders (`app/database/seeders/`)

`DatabaseSeeder` runs `channel-plugins:sync` (registers channel plugin manifests into the `plugins` table), then: `LanguageSeeder` (en/ar/ja), `CustomPageSeeder`, `OnboardingSeeder`, `PlanSeeder`, `WabaTemplateLibrarySeeder` (Meta template library), `SystemSettingSeeder`, `UserSeeder`; then any seeders tagged `plugin.seeders`; `DemoSeeder` only when `config('app.demo')`.

- **Plans seeded by `PlanSeeder`:** Free ($0), Starter ($19), Pro ($49), Enterprise ($199), each with a large feature/limit matrix (the plan feature keys are the same keys plugins gate on, §5).
- **`UserSeeder`:** creates the initial admin user (`User::DEMO_EMAIL` constant, role `admin`) and attaches an Enterprise-plan subscription with `payment_method = manual`.
- **Demo data** (`DemoDataSeeder`, `DemoSeeder`, `DemoWorkspaceSeeder`, `DemoStatusHistorySeeder`, `seeders/Demo/*`): full fake workspace — contacts, conversations, campaigns, status history — only in demo mode; `demo:cleanup` scheduled command removes it.
- `InstallationSeeder` supports the web installer flow (`app/Services/InstallerService.php`).

---

## 5. Plugin system in code — the core finding

There is **no public developer guide**, but the system is fully visible in code. It is a real, contract-based plugin architecture — not a hook afterthought.

### 5.1 Where plugins live & how they are found

- Plugins are plain folders under **`app/Plugins/<TypeDir>/<PluginDir>/`**, each with a **`plugin.json`** manifest and a `src/` PSR-4 source folder. Root is overridable via `PLUGINS_ROOT` env → `config/plugins.php` → `PluginManager::path()` (default `app_path('Plugins')`).
  Evidence: `app/Services/PluginManager.php` (1,756 lines — the whole lifecycle), `app/Providers/PluginServiceProvider.php`, `config/plugins.php`.
- Discovery: `PluginManager::discover()` / `scan()` walks the type directories, parses each `plugin.json`, cross-checks the **`plugins` DB table** (slug → status `active`/inactive, stored config, ran-migrations ledger). `isActive($slug)` reads the DB.
- Autoloading: `registerPluginAutoloading()` adds PSR-4 prefixes `App\Plugins\<TypeDir>\…` → each plugin's `src/` at runtime (plugins are **not** Composer packages), including a classmap fix-up for optimized autoloaders.
- Boot: `PluginServiceProvider::boot()` calls `PluginManager::boot()` (registers autoloading, migrations from each plugin's `database/migrations/`, runtime compatibility + console commands), then separately registers **service providers** for plugins of type `integration`, `ai_integration` and `tool` whose manifest declares the matching `runtime_contract` and whose main class implements the runtime contract interface; finally, on app booted, every channel runtime plugin gets `registerRoutes()`. `PluginPageRouteServiceProvider` is registered last so plugin public pages get the catch-all routes.

### 5.2 plugin.json schema (as validated in code)

Validated in `PluginManager::validateManifest()` / `validateRequirements()` / `packageDirectory()`:

Required: `name, slug, type, main_class, namespace, version, author`.
Optional seen in real manifests: `description, channel` (required for type `channel`, regex `^[a-z][a-z0-9_]{1,15}$`), `runtime_contract` (int), `is_core` (bool), `personal_data` (bool), `migrations` (list of manifest-relative migration paths, run in place at install), `requirements` (`php`, `laravel` version floors).

Rules enforced: slug regex `^[a-z0-9_\-]{1,64}$`; namespace **must** start with `App\Plugins\` and match the type directory; `main_class` is a safe relative path (no `..`).

**Types → directories** (`PluginManager::TYPE_DIRECTORIES`):

| type | directory | purpose |
|---|---|---|
| `payment_gateway` | `PaymentGateways/` | billing gateways |
| `channel` | `Channels/` | messaging channels (declare `channel` key) |
| `sms_provider` | `SmsProviders/` | SMS drivers (extension of parent `sms_providers`) |
| `wa_provider` | `WaProviders/` | extensions of the WhatsApp channel |
| `waba_provider` | `WabaProviders/` | extensions of the WABA channel |
| `telegram_extension` | `TelegramExtensions/` | extensions of Telegram channel |
| `ai_integration` | `AiIntegrations/` | AI providers (runtime contract) |
| `integration` | `Integrations/` | third-party app integrations (runtime contract) |
| `tool` | `Tools/` | admin tools (runtime contract) |

**Extension parents** (`PluginManager::EXTENSION_PARENTS`): `sms_provider → sms_providers`, `waba_provider → waba`, `wa_provider → whatsapp`, `telegram_extension → telegram` — an extension plugin cannot activate unless its parent channel plugin is present/active (`assertParent()`).

### 5.3 The contracts a plugin implements

Base contract `app/Contracts/Plugin.php`: `getName, getDescription, getIcon, getVersion, getType, getAuthor, getAuthorUrl, isConfigured, validateConfig(array), getConfigSchema(): array` — the config schema is a declarative field list (name/label/type/default/placeholder/help, `sensitive` flag) rendered by the admin UI; sensitive values are masked/encrypted by `PluginManager` + `SystemSetting` storage.

Capability interfaces (all in `app/Contracts/`, a plugin opts in by implementing them):

- **Channels:** `ChannelPlugin`, `ChannelRuntimePlugin` (`registerRuntime(ChannelRuntimeRegistry), registerRoutes(), registerConsole(), registerSchedule(Schedule), registerCompatibility()`), `SmsProviderPlugin` (`smsDrivers(): array<string, class-string>`)
- **Payments:** `PaymentGatewayPlugin` + `SupportsBillingPeriods, SupportsOneTimePurchase, SupportsPlanChange, SupportsRefund, SupportsSetupFee, InspectsRenewalPlan, ChargesPlanUpgradeInPlace`
- **Config:** `ProvidesValidatedPluginConfig` (validated config array), `UsesSystemSettingConfig` (config persisted in `system_settings`), `TestsPluginConfiguration`
- **UI/surface:** `ProvidesAppSlots` (downloadable companion apps — see Android plugin §7), `ProvidesPublicPages` (public landing pages w/ slug/title/nav/icon/renderer/plan_key), `ProvidesAppSlots`/`AppSlot` (`app/Services/Apps/`)
- **Data/privacy:** `PersonalDataSource, PersonalDataClassification, PersonalDataMessageContent` (GDPR export/erasure participation)
- Plus domain contracts plugins consume: `NodeExecutor` (flow nodes), `Messageable/Campaignable`, `FansOut`, `FlowAiBuilder`, `MarketFileStorage`, `Updates/*`, `ServiceServers/*` (server-kind registration), `Telephony/*`, `Omnichannel/*`, `Channels/*`, `Email/*`, `Push/*`, `Api/*`, `Admin/*`, `AiAgents/*` — 91 contract files in `app/Contracts/` overall.

### 5.4 The channel registry — what a channel plugin can hook

Channel plugins are additionally described in a central registry, **`app/Services/Channels/ChannelPlugins.php`** (609 lines, `RUNTIME_CONTRACT = 5`). For each channel slug it declares everything core must know:

`channel` key, connection `types`, `planKeys` (plan features it gates), `limitKeys` (plan quotas), `manifest` path, `core` flag, `serverKinds` (companion server programs), `broadcasts` (Reverb channel patterns), `queues`, `uriPrefixes`, `routeNames`, `settingsGroups`, `flowNodes` (chat-flow triggers/actions it adds), `voice` capability, `appSlots`, `drivers`, `optionSources`, `abilities` (API token abilities), `mcpTools` (tools exposed to the MCP server), `permissions`, `controllerNamespaces`, `commands` + `commandPrefixes`, `adminNav` entries, `attentionSources`, `marketKinds`, `apiTags`, `helpRoutes`, `usageMeters`, `webhookPrefixes`, and `exempt` route exemptions.

Registered channel slugs in core code: `telegram, widget, push, android, whatsapp, email, smpp, phone_bridge, gsm_modem, waba, sms_providers` (+ extension `telegram_store`). Feature gating everywhere goes through this registry + plan keys: route middleware `channel:<slug>`, `api.feature:<key>`, plan limits — e.g. `routes/api.php` uses `->middleware('channel:android')`.

Plugin lifecycle events: `app/Events/ChannelPluginToggled.php` is fired on activate/deactivate; core listeners reconcile dependent state (`app/Listeners/Channels/ReconcileCoreChannelPlugin.php`, `app/Listeners/Telephony/PublishModemPluginChanges.php`). Plugins can also register scheduled commands (`ChannelRuntimePlugin::registerSchedule`, invoked from `routes/console.php`) and console commands (`registerConsole`).

### 5.5 Install / activate flow (code path)

`PluginManager::installFromZip(UploadedFile)` (admin uploads a ZIP in Admin → Plugins):
1. Unzip to a temp dir (ceilings: 5,000 entries / 100 MB, zip-slip guarded).
2. Locate payload + manifest dir (`findReleasePayload`, `resolveManifestDir`), `validateManifest()` + `validateRequirements()`.
3. Back up any previous version to `storage/app/plugin_backup_*`, move into `app/Plugins/<TypeDir>/<Dir>/`.
4. Run manifest-listed migrations in place (`migrate --path --realpath`), record them on the `plugins` row.
5. `install($slug)` creates/updates the `plugins` DB row; `activate()/deactivate()/toggle()` flip status, fire `ChannelPluginToggled`, assert parent/config first (`assertCanActivate`, `assertConfigured`), and `restartQueueWorkers()` (`queue:restart`).

`uninstall()` rolls back recorded migrations and deletes files. Broken plugins are surfaced in admin with `is_broken` + reason instead of crashing (`getPluginsForAdmin()`).

### 5.6 Core-bundled plugins (inside the app tree)

| Plugin | Path | Type | Notes |
|---|---|---|---|
| PayPal | `app/Plugins/PaymentGateways/PayPal/` | payment_gateway, `is_core: true` | Full gateway: implements `PaymentGatewayPlugin, SupportsBillingPeriods, SupportsOneTimePurchase, SupportsPlanChange, InspectsRenewalPlan`; webhook verification, refunds, plan changes via `app/Services/Billing/*` |
| Bank Transfer | `app/Plugins/PaymentGateways/BankTransfer/` | payment_gateway, core | manual payment flow |
| WABA | `app/Plugins/Channels/Waba/` | channel (`channel: waba`) | Thin plugin class: config schema only (Meta app id/secret, graph version, webhook verify token — stored as system settings); all logic in core `app/Services/Messaging/Waba/*` |
| SMS Providers | `app/Plugins/Channels/SmsProviders/` | channel | Thin plugin class gating the 16 built-in HTTP SMS drivers (§11) |

Pattern: core "plugins" are mostly **manifest + config-schema shells**; the heavy logic lives in core services. Third-party-style plugins (below) can carry real code.

### 5.7 The 5 free plugins — how each integrates

Each free plugin ships as a `plugin.zip` (the installable artifact) in its branch folder; unzipped layout = `<PluginDir>/plugin.json` + `src/<MainClass>.php` (+ optionally `Runtime/`, `migrations/`). All are version `5.0.4`, author "Titan Systems".

1. **Android Gateway** (`plugin-android-gateway/plugin.zip` → `Android/plugin.json`, slug `android`, type `channel`, channel `sms`, namespace `App\Plugins\Channels\AndroidPlugin`): single-file plugin class implementing `Plugin, ProvidesAppSlots, ProvidesValidatedPluginConfig, UsesSystemSettingConfig`. It contributes **no routes/logic** — the entire Android protocol lives in core (§7). Its real jobs: (a) declare the 4 downloadable app slots (`android_gateway`, `android_rcs`, `android_receiver`, `android_ussd` APK slots with version-compat patterns), (b) config schema: `carrier_pause_hours` (default 6), `rcs_pacing_seconds` (default 6), `firebase_credentials` (FCM service-account JSON, stored encrypted). Presence of this plugin's manifest is what `ChannelPlugins::present('android')` checks.
2. **WhatsApp** (`Whatsapp/plugin.json`, slug `whatsapp`, type `channel`, channel `wa`): single-file class implementing `Plugin, ProvidesValidatedPluginConfig, UsesSystemSettingConfig` — config = WA server device-name settings. All protocol logic is core + the closed Go binary (§8). The binary itself is distributed **outside** the zip, in the branch's `server/` folder.
3. **SMPP** (`Smpp/plugin.json`, slug `smpp`, type `sms_provider`, namespace `App\Plugins\SmsProviders\SmppPlugin`): implements `SmsProviderPlugin` with `smsDrivers(): ['smpp' => SmppDriver::class]` — i.e. it registers one driver class that lives in **core** (§11). The closed SMPP server binary is in the branch's `server/` folder.
4. **WhatsApp Embedded Signup** (`EmbeddedSignup/plugin.json`, slug `waba_embedded_signup`, type `waba_provider` — extension of WABA): the most substantial free plugin: 7 PHP files in the zip root (`EmbeddedSignupPlugin.php` config shell + `WabaOnboardingService.php`, `SignupEndpoints.php`, `SignupReadiness.php`, `CoexistenceSyncRequests.php`, `CoexistenceContactSync.php`) implementing Meta Embedded Signup + WhatsApp Business app "Coexistence" onboarding on top of core WABA.
5. **Legacy Importer** (`LegacyImporter/plugin.json`, slug `legacy_importer`, type `tool`, `runtime_contract: 1`, `personal_data: true`, manifest-listed migration): a full self-contained plugin — `src/LegacyImporterPlugin.php` + `Runtime/` tree (own ServiceProvider `LegacyImporterServiceProvider.php`, routes `Runtime/Routes/web.php`, controller, 3 jobs, 2 models, dump parsers, importers for users/contacts/subscriptions, personal-data service) + `migrations/2026_10_27_000001_create_legacy_import_tables.php`. **This is the reference example of a "real" third-party plugin**: own provider, routes, jobs, models, migrations — all loaded through the generic mechanisms in §5.1–5.5.

Also present in each extracted plugin dir: `src/.installed.cache` (install marker file; Android's contains a 16-hex-char stamp — value not reproduced here).

**Extensibility verdict:** genuinely extensible for PHP-side features — new channels, SMS drivers, payment gateways, integrations, AI providers, tools, flow nodes, MCP tools, public pages, app slots, scheduled commands and migrations are all first-class. Two hard limits: (1) a channel that needs a **companion server program** (WhatsApp/SMPP/telephony/Telegram/email servers) requires core-side registration in `ChannelPlugins` + a `ServiceServer` kind — the binary side is vendor-closed; (2) plugin namespaces are locked to `App\Plugins\…` and manifests are strictly validated, so plugins cannot escape the sandbox contract.

---

## 6. Core modules map

`app/` subdirectories (PHP file counts): Http 593, Services 1,178, Support 160, Console 119, Models 243 (234 in `Models/` root + Commerce subdir), Events 83, Jobs 84, Listeners 69, Contracts 91, Notifications 45, Mail 44, Providers 14, plus Actions, Auth, Billing, Broadcasting, Casts, Concerns, DTOs (30), Database, Enums (12), Exceptions (30), Helpers, Observers (10), Policies, Queue, Repositories, Routing, Rules (13), Sanctum, Traits.

### Models (grouped, from `app/Models/`)

- Identity: `User, AdminRole, WorkspaceRole, WorkspaceInvitation, PersonalAccessToken, UserConsent, UserNotification, UserOnboardingProgress`
- Messaging: `Message` (via channel models), `ChannelConnection, ChannelMessage, ChannelWebhookEvent, Conversation, ConversationEvent/Label/Note/Round/View, Team (messenger_teams), Macro, CannedResponse, QuickReply, CsatSurvey, SlaPolicy, AssignmentRule, Agent`
- Contacts: `Contact, ContactAlias/Consent/Field/FieldValue/Identity/Import/ImportError/Export/Note/Segment, Tag, Group`
- Campaigns/flows: `Campaign, CampaignRecipient, CampaignVariant, Campaignable, ScheduledMessage, Sequence, SequenceEnrollment, Flow, FlowNode, FlowEdge, FlowRun, FlowRunStep, FlowAnswer`
- Devices/SIM/calls: `Device, DeviceDiagnostic/Invite/Pairing/SignInChallenge/UpdateNotice, Sim, SimRouteRule, SmsProvider, SmsProviderRoute, Call, CallEvent/Transcript/AgentRing/ContactGraph/MediaStream/Tombstone/Upload, PhoneBridgePairing, UssdPull, UssdSchedule, UssdScript, SenderId, DltTemplate`
- WhatsApp/WABA: `WaAccount, WaAccountEvent, WaConnectLink, WaConnectionAlert, WaGroup, WaGroupMember, WaPollVote, WaServerRelease, WaSuppression, WaWarmer*, WabaAccount, WabaPhoneNumber, WabaTemplate, WabaTemplateLibraryEntry/Variant, WabaCoexistenceSync, WabaContactSyncLink, WabaEntryPoint, WabaOnboardingAttempt`
- Billing: `Plan, PlanAiProvider, PlanUsageAlert, Subscription, Transaction, CreditPack, CreditReservation, CreditTransaction, Voucher, VoucherRedemption, PaymentAccount, PaymentLink, Dispute, Referral, ReferralCode, ReferralCreditTransaction, GatewayCustomer, GatewayWebhookEvent`
- Platform: `Plugin, ServiceServer, ServiceServerMove, SystemSetting, Language, TranslationOverride, CustomPage(+Content/Version), StoredFile, FileFolder, Webhook, WebhookDelivery, AuditLog (via Services/AuditLogger), AbuseFlag, Ticket(+Message/Attachment), StatusIncident(+Update), StatusSubscriber, SetupCheckRun, CronRun-adjacent models, PrivacyRequest, AccountDataExport, AccountDeletionRequest, OtpVerification, OtpSetting, AiProvider, AiUsageLog, UserAiKey, KnowledgeBase/Source/Chunk/Query/Workspace, McpOAuthGrant, NetworkLine(+CountryRate), NetworkCharge, NetworkReplyRoute(+Event), NetworkReport, Partner, PartnerLedgerEntry, PartnerPayout, MarketCategory/Product/Order/OrderEvent/LicenseCode, Commerce (subdir), Booking/Appointment/Calendar models, Widget models, GoogleSheet models, SubscribeForm(+Submission), TrackedLink(+Code), LinkClick, Landing* models, Onboarding* models, MobileDevice, MobileSignInToken, WhatsAppSignInApp/Grant, OidcSigningKey, LoginHandoffToken, MediaStreamSecret, PushSubscriptionState, IntegrationSiteRouting, ConnectionUpdateNotice, CookieConsent, Company, ShippingAddress`

### Controllers (`app/Http/Controllers/`, 415 files)

By area: `Api/` 114 (V1 public API + internal device/server APIs), `Admin/` 49, `Messenger/` 35, `Channels/` 18, `Auth/` 16, `Contacts/` 14, `Help/` 11, `Public/` 11, `Billing/` 8, `Bookings/` 6, `Payments/` 6, `Waba/` 6, `Integrations/` 6, `Wa/` 5, `WhatsAppSignIn/` 5, `Network/` 4, `Webhooks/` 4, `Links/` 3, `Market/` 3, `Otp/` 3, `Calls/` 2, `Commerce/` 2, `Referral/` 2, `Support/` 2, `Profile/` 1, `Push/` 1, `Widget/` 1, `Concerns/` 1.

### Services (`app/Services/`, 1,178 PHP files, ~65 sub-areas)

Largest domains: `Messaging/` (Sms, Wa, Waba, Rcs sub-trees), `Channels/`, `Messenger/`, `Flow/`, `Campaigns/`, `Billing/`, `Payments/`, `Admin/`, `Api/`, `Mcp/`, `Ai/` + `AiAgents/`, `Android/` + `Devices/`, `Telephony/` + `Voice/`, `Network/`, `Market/`, `Commerce/`, `Bookings/`, `Contacts/`, `Integrations/`, `Webhooks/`, `Omnichannel/`, `Push/`, `Otp/`, `Auth/`, `OAuth/`, `Oidc/`, `Installation/`, `Updates/`, `ErrorReporting/`, `Privacy/`, `Reports/`, `Search/`, `Status/`, `Storage/`, `Media/`, `Knowledge/`, `Links/`, `Mobile/`, `Apps/`, `ServiceServers/`, `SetupCheck/`, `Usage/`, `Team/`, `Help/`, `Dashboard/`, `Demo/`, `GoogleSheets/`, `Sequences/`, `SubscribeForms/`, `WhatsAppSignIn/`, `Abuse/`, `Activity/`, `Attribution/`, `Referral/`, `Tickets/`, `Widget/`, `Pdf/`, `Http/`, `Profile/`, `LandingPageService`, `PluginManager.php`, `InstallerService.php`.

### Events / Listeners / Notifications / Mail

- `app/Events/` (83 files, subdirs: Android, Billing, Campaign, Contacts, Links, Market, Messaging, Messenger, Mobile, Omnichannel, Telephony, Voice, Widget + `ChannelPluginToggled`, `UserNotificationEvent`, `WorkspaceAiKeyChanged`). Wiring in `app/Providers/EventServiceProvider.php`.
- `app/Listeners/` (69 files; subdirs Abuse, Admin, Auth, Billing, Campaigns, Channels, Email, Market, Network, Privacy, Sms, Telephony, Waba, Webhooks + `CarrierPaused`, `RcsNeedsAttention`, …).
- `app/Notifications/` 45 files; `app/Mail/` 44 files.

### Routes inventory

| File | Lines | Route statements | Role |
|---|---|---|---|
| `routes/web.php` | 2,089 | ~893 | Inertia web app: public site, auth'd tenant UI, admin panel, messenger, channels, billing, market, help |
| `routes/api.php` | 565 | ~231 | Public REST API v1 (Sanctum) + internal APIs (android, whatsapp, smpp, telephony, email/telegram fallbacks) |
| `routes/mobile.php` | 146 | ~117 | Mobile app API (Flutter app surface) |
| `routes/channels.php` | 229 | — | Reverb broadcast channel authorisation |
| `routes/console.php` | 390 | — | Scheduler + artisan commands (§12) |
| `routes/auth.php` | 107 | ~37 | login/register/2FA/social |
| `routes/mcp.php` | 39 | ~9 | MCP server endpoints (OAuth + API key) |
| `routes/widget.php` | 34 | ~18 | website-chat widget frame/API |
| `routes/whatsapp-sign-in.php` | 37 | ~11 | Sign-in with WhatsApp |
| `routes/push.php` | 16 | ~6 | Web Push endpoints |
| `routes/bookings.php` | 21 | ~8 | public booking pages |
| `routes/payments.php` | 10 | ~3 | payment link/checkout |
| `routes/subscribe.php` | 9 | ~3 | subscribe forms |
| `routes/i18n.php` | 10 | ~1 | locale switching |

Public API v1 (`routes/api.php`, prefix `v1`, Sanctum + tenant + ability middleware): endpoint groups — commerce orders, integrations/site + WooCommerce, channels/available, messages (email + per-channel sends), contacts (CRUD/upsert/consent/notes/tags/groups/segments/imports/exports/lookup), conversations (list/show/messages/reply/assign/resolve/reopen), OTP verifications, numbers/validate, network lines/quote, forms, social-proof events, unsubscribed, me/usage/rates, telegram sub-API, voice (calls) sub-API, `v1/whatsapp` (WA account management). Full named-route list: [LANE-5-API-ROUTES.md](LANE-5-API-ROUTES.md).

---

## 7. Android gateway protocol (server side)

All server logic is **core** (the free plugin is just a manifest/config shell, §5.7). Contract documented in-repo as `docs/api/android-v1.yaml` (referenced from `routes/api.php` comments and the plugin code).

### Endpoints — `routes/api.php`, prefix `api/v1/internal/android`, middleware `channel:android`

Public (throttled):
- `POST auth/pair` — pair a phone using a pairing code (created in UI; `device_pairings` table; pairing flow broadcast over Reverb channel `user.{id}.device-pairings.{pairingId}`); gated by `RequireCompatibleGatewayApp` (app version ≥ `GatewayAppCompat::MIN_APP_VERSION`)
- `POST auth/login`, `POST auth/login/two-factor` — email sign-in for branded app builds
- `GET app/update` — latest gateway APK version info; `GET app/download` (signed URL) — APK download; companion downloads: `GET ussd-companion/app`, `GET receiver/app`, `GET rcs/app` (all signed)

Authenticated (middleware `android.session` + `android.tenant.scope` + per-device throttle):
- `GET device` — device profile; `PUT device/fcm-token`; `PUT device/sims` — SIM sync; `PUT device/pause`; `POST device/diagnostics`
- `GET messages/pending` — paginated outbound queue pull; `PATCH messages` / `PATCH messages/{id}` — delivery status batch/single update; `POST messages/inbound` — inbound SMS upload
- `POST error-reports` — phone app error reports (relayed into the error-reporting pipeline, §9)
- `GET ussd/pending`; `POST ussd/{id}/start`; `POST ussd/{id}/menu`; `PATCH ussd/{id}` — USSD session relay
- `GET rcs/selectors` — RCS capability data

### Authentication

`app/Http/Middleware/AndroidSession.php`: `Authorization: Bearer <token>` + `X-Device-Id` header. The server stores only the **SHA-256 hash** of the session token in `devices.hash`; the bearer must hash-match a device whose `android_id` equals the header (a stolen hash alone is useless). Tenant scoping via `AndroidTenantScope`. Pairing codes are short-lived (`cleanup:stale-pairings` daily; `device_pairings` table).

### Send/receive flow — push-wake + pull (hybrid)

1. Outbound messages are queued as rows (status pending) assigned to a device/SIM (SIM routing rules, per-SIM caps, carrier-pause logic in `app/Services/Messaging/Sms/*`).
2. Server wakes the phone with an **FCM data push**: job `app/Jobs/SendPushNotification.php` → `app/Services/Push/DevicePush` sends data payload `action=message_request` (+ `campaign_id` for campaigns) to `devices.firebase_token` via Kreait Firebase (service-account JSON from the Android plugin's `firebase_credentials` setting). Variants: `SendCampaignControlPush`, `SendUssdPendingPush` (USSD wake), `SendDeviceUpdatePush`, `SendRcsSetupPush`, `PushAppUpdateToDevices`.
3. Phone pulls `GET messages/pending`, sends via the SIM, reports back with `PATCH messages…`; inbound SMS arrives via `POST messages/inbound`.
4. **Polling fallback:** the pending endpoint is explicitly exempted from channel-gating ("Control-only polling keeps phones paired" — `ChannelPlugins` `exempt` map), so phones without working FCM still poll. Delivery-report gaps are detected hourly (`sims:detect-missing-delivery-reports`); pending work is moved off offline devices every minute (`sms:move-pending-from-offline`).

### USSD handling

Server-side queue-and-relay: a USSD request creates an `ussd` row (`UssdPull` model; tables `ussd, ussd_scripts, ussd_schedules`); the phone (USSD Companion app slot) is woken (FCM + Reverb channels `user.{id}.ussd.{pullId}` incl. a `.masked` variant), polls `ussd/pending`, then drives the carrier session via `start` → `menu` (per-menu responses) → `PATCH` final result. Scheduled USSD (balance checks etc.) runs via `ussd:run-schedules` every minute; sessions expire via `ussd:expire-sessions`.

### Per-device / per-SIM data stored

`devices` table (model `app/Models/Device.php`): user_id, android_id, session hash (hidden), name, model, manufacturer, android_version, sdk_version, app_version(+code), app_package, app_signer, firebase_token (hidden), battery_level, is_charging, signal_strength, is_enabled, is_online, last_seen_at, random_send_min/max_delay, receive_sms_enabled, installed packages list, is_paused/paused_at, parallel_sending(+audit), battery_optimization_exempt, background_restricted, standby_bucket, device_brand, pause_count_24h, longest_gap_minutes_24h, sms_pause_reason, bluetooth_name(+source), ussd_report, receiver_report, rcs_enabled, rcs_sms_fallback, rcs_failure_streak, rcs_report, rcs_attention_hash. Plus related tables: `device_heartbeats` (liveness log), `device_diagnostics`, `device_connections`, `device_offline_alerts`, `device_update_notices`, `sims` (per-SIM: device, slot, number, carrier, caps, route rules via `sim_route_rules`, `sim_carrier_events`).

---

## 8. WhatsApp plugin (QR) — binaries & PHP↔binary protocol

### Bundled binaries (`~/workspace/zender-branches/plugin-whatsapp/server/`)

| File | Size | Platform |
|---|---|---|
| `titansys-whatsapp-linux` | 52,281,470 B (~49.9 MiB) | ELF x86-64, statically linked, stripped |
| `titansys-whatsapp-arm64` | 48,234,622 B (~46.0 MiB) | ELF ARM aarch64, static, stripped |
| `titansys-whatsapp-macos` | 49,648,354 B (~47.3 MiB) | Mach-O arm64 |

Closed-source Go binaries (the PHP docblock in `WaBinaryClient` calls it "a Go WA binary" / "the WhatsApp library session" — a whatsmeow-style linked-device engine). Admins register one or more as **Service Servers** (`service_servers` table, kind `whatsapp`, capacity-managed, load-balanced, movable accounts via `service_server_moves`).

### How PHP talks to the binary

Evidence: `app/Services/Messaging/Wa/WaBinaryClient.php`, `app/Services/Messaging/Wa/WhatsappServerKind.php`, `routes/api.php` (`v1/internal/whatsapp`), `routes/channels.php`.

- **Config hand-off:** admin downloads a generated `config.json` per server: `{ purchase_code, server: { host, port (default 8899), service_token }, laravel: { url } }`. The binary **refuses to start** while `purchase_code` or `service_token` still hold the placeholder strings (`REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE`, `REPLACE_ME_WITH_WA_SERVER_SERVICE_TOKEN`).
- **Main traffic = Reverb (websockets), not HTTP.** The binary subscribes to private channel `wa.account.{id}.commands`; Laravel publishes send/control commands there; binary events come back on `wa.account.{id}.events` and via **`POST /api/v1/internal/whatsapp/events`** (ingested by `WaEventIngestService`). Broadcast auth for the binary goes through `Api\V1\Wa\BroadcastAuthController`.
- **HTTP is used only at lifecycle boundaries:** `WaBinaryClient` (Bearer = the server's service token, same token both directions) calls `POST /api/v1/internal/whatsapp/accounts` (assign/subscribe an account, with `session_token`, login method `qr` or pairing-code, proxy, throttle and reject-call settings) and `DELETE …/accounts/{id}` (release).
- **Session storage:** the WhatsApp linked-device session/keys live **inside the Go binary on the WA server host** (it "(re)creates the WhatsApp library session"); Laravel stores only account metadata/state in `wa_accounts` (+ `wa_account_events`, `wa_instances` legacy table for server registry data: base_url, basic-auth user/pass, webhook_secret, version, health, capacity). Exact on-disk session format of the binary: **UNVERIFIED** (closed binary, not inspected beyond `file` metadata).

---

## 9. Licence / phone-home audit

Search scope: whole app tree excluding `vendor/` (composer.json's `titansystems/zender-laravel` name and the bundled gateway app package id `dev.titansys.smsgateway` in `app/Services/Push/FirebaseAndroidConfig.php` are identifiers, not network calls). Findings:

### F1 — Vendor error-reporting endpoint (opt-in, OFF by default) ⚠️ the only direct vendor phone-home in PHP
- `config/services.php`: `'sentry' => ['endpoint' => env('APP_SENTRY') ?: 'https://sentry.titansys.dev']`
- `app/Services/ErrorReporting/SentryReporterService.php`: unexpected exceptions are buffered in DB table `sentry_pending_reports`, scrubbed (`ErrorReportScrubber` strips secrets/PII), and flushed by the scheduled `sentry:flush` command (every 5 minutes per `routes/console.php` comment; batch 50, 3 attempts) via HTTP POST to `{endpoint}/api/error-logs/ingest`.
- **Trigger conditions (all required):** admin setting `sentry_enabled` = true (default **false**, `SentryReporterService::DEFAULT_ENABLED`) **and** a **purchase code** stored in admin settings (`purchase_code`, stored encrypted — `app/Http/Controllers/Admin/SettingsController.php`). At send time the payload is prepended with the installation's `purchase_code` ("the purchase code is added at send time, never stored" in the report rows). Payload keys: exception class, message, file, line, stack trace, route-template context, environment, PHP/Laravel/app versions.
- Companion apps/servers relay into the same pipeline: Android phones `POST api/v1/internal/android/error-reports`; SMPP server `POST api/v1/internal/smpp/error-reports` (+ `GET error-reporting` to read the switch) — the Go binaries read the same on/off switch ("read by the Go services too", `app/Contracts/ErrorReporting/ErrorReportingSwitch.php`).

### F2 — Plugin licence codes gate the closed server binaries (vendor-side validation, UNVERIFIED mechanism)
- `app/Services/Messaging/Wa/WhatsappServerKind.php`: `LICENSE_PLACEHOLDER = 'REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE'` — pasted into the WA server's `config.json`; binary refuses to start with the placeholder.
- Same pattern: `app/Services/Messaging/Sms/SmppServerKind.php` (`REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE`), `app/Services/Telephony/TelephonyServerKind.php` (`REPLACE_ME_WITH_GSM_MODEMS_OR_PHONE_BRIDGE_LICENSE_CODE`).
- The codes are the per-plugin purchase/licence codes from the vendor dashboard. Whether the binaries validate them online against titansys.dev or offline cannot be determined from PHP source — **UNVERIFIED** (closed binaries; strings not extracted for this audit).

### F3 — No core licence activation / purchase-code validation for the main app
- No Envato/purchase-code check gates the Laravel app itself: the `purchase_code` setting exists **only** as the error-reporting identifier (F1). No outbound "activation", "verify licence" or update-check call to vendor infrastructure was found in PHP. The `plugins`/`market_license_codes` tables belong to the **built-in Market** (the operator's own plugin marketplace for *their* customers — `app/Services/Market/*`), not vendor licensing.
- Updates: `app/Services/Updates/` contains only `UnavailableReleaseNotice.php` — no vendor update feed is polled in core (the paid Auto Update plugin is external to this tree; UNVERIFIED here).

### F4 — Other outbound calls (all operator-configured, not vendor)
Meta Graph API (WABA), SMS provider APIs (16 drivers), Stripe/PayPal/Razorpay/YooKassa APIs, Firebase FCM, Google/Microsoft (calendar, Sheets, OAuth), Telegram, MaxMind — all use the operator's own credentials/endpoints. `autosetup.sh` fetches Composer + NodeSource installers from their official URLs during VPS setup only.

### F5 — Plugin file watermark (observation)
The free plugins' main class files (e.g. `Android/src/AndroidPlugin.php` in the extracted zip) end with a large block of tab/space whitespace after the closing code, under a `phpcs:disable Generic.Files.LineLength` comment — consistent with a whitespace-encoded vendor watermark/copy marker. Content not decoded in this audit; flagged for awareness only.

**Phone-home count: 1 direct vendor endpoint in PHP (F1, opt-in/off by default), + 3 licence-code gates inside closed binaries (F2, mechanism UNVERIFIED).**

---

## 10. Branding — where "Zender" reaches end users

- **Product name is configuration, not hard-coded UI:** `config/app.php` `'name' => env('APP_NAME', 'Zender')`; `site_name()` helper (`app/Support/helpers.php`) resolves admin setting `system_settings.site_name` → config → fallback. Frontend reads a server-injected `window.__APP_NAME__`, falling back to the literal `'Zender'` only if unset (`resources/js/app.tsx`, `resources/js/components/BrandMark.tsx`).
- **"Powered by" exists but shows the operator's own site name, never "Zender":**
  - Chat widget: `resources/js/widget/shared/panel/PoweredBy.tsx` renders "Powered by {poweredBy.name}" from widget config.
  - Payment pages: `resources/js/Pages/Payments/Pay.tsx` — "Powered by {site name}".
  - Subscribe forms: `resources/views/subscribe/form.blade.php` — "Powered by {site_name()}".
  - White-label is a **plan feature**: `app/Services/Billing/PlanCatalog.php` — `white_label`: "Workspace branding on the Messenger and chat widget, and no 'Powered by' on forms". Removing it is a per-plan toggle, not a code change.
- Literal `Zender` strings in the frontend source: only 6 hits across `resources/js` (the two fallbacks above, an accessibility comment in `GuestLayout.tsx`, admin PlanForm, onboarding tour coordinator) — all defaults/comments, all overridden by site name at runtime.
- Vendor name appears freely in **code/admin contexts only**: composer package name, plugin `author: "Titan Systems"` in manifests, admin plugin listings, docs. No tenant-facing "Powered by Zender" was found anywhere. **Verdict: white-labelling = set APP_NAME/site name + logo settings; no code surgery needed.**

---

## 11. SMPP plugin

- **Not PHP-only:** the plugin.zip contains only the manifest + `SmppPlugin` class (§5.7), but the actual SMPP protocol engine is a **closed Go server binary** distributed in the branch's `server/` folder: `titansys-smpp-linux` (15,016,062 B, ELF x86-64 static stripped), `titansys-smpp-arm64` (13,893,758 B), `titansys-smpp-macos` (14,275,602 B, Mach-O arm64). Registered as a Service Server kind (`app/Services/Messaging/Sms/Smpp/SmppServerKind.php`, with the F2 licence placeholder).
- **PHP side (all core):** `app/Services/Messaging/Sms/Smpp/` — `SmppDriver` (implements the core `SmsProviderDriver` contract: unicode, 255 parts, alphanumeric sender, delivery reports, inbound), `SmppCommands`/`SmppCommandChannel` (commands to the binary over Reverb), `SmppServerAssigner` + balancing settings (gateways distributed across SMPP servers), `SmppBindStateHandler`, `SmppInboundHandler`, `SmppMessageStatusHandler` (DLRs), `SmppConnectionTests`, `SmppConfigSchema` (host/port/system_id/password/TLS/bind options per gateway).
- **Registration as a provider:** the plugin class's `smsDrivers()` returns `['smpp' => SmppDriver::class]` into `app/Services/Messaging/Sms/Drivers/SmsDriverRegistry.php` (via `SmsDriverServiceProvider`); from then on SMPP gateways are configured like any other provider in `gateways`/`sms_provider_routes`, with per-gateway assignment history (`smpp_assignment_history`).
- **Binary↔Laravel API:** `routes/api.php` prefix `api/v1/internal/smpp` (middleware `channel:smpp`, `smpp.server`): `POST events`, `GET bootstrap`, `GET gateways`, `GET gateways/{gateway}`, `GET gateways/{gateway}/pending` (outbound pull), `GET connection-tests/{id}`, broadcasting auth, error-reporting relay (§9 F1). Scheduler keeps it healthy: `smpp:sweep`, `smpp:servers-health` (every minute), `smpp:balance` (every 5 min).
- Built-in (non-SMPP) SMS drivers in core for comparison — `app/Services/Messaging/Sms/Drivers/`: AfricasTalking, Bandwidth, Bird, ClickSend, Clickatell, CustomHttp, Infobip, Msg91, Plivo, Routee, SignalWire, Sinch, Telnyx, TextMagic, Twilio, Vonage (16 HTTP drivers + SMPP = 17 driver classes).

---

## 12. Scheduler & queues

### Scheduler (`routes/console.php`, 390 lines, ~116 `Schedule::` entries)

Cadence highlights (all `withoutOverlapping`, many gated on `ChannelPlugins::live('<slug>')`):

- **Every minute:** `messaging:tick` (core send pump), `otp:expire`, `campaigns:launch-recurring`, `campaigns:decide-ab-winners`, `flow:resume`, `flow:tick`, `flows:google-sheets-poll`, `bookings:tick`, `commerce:tick`, `bookings:calendar-poll`, `servers:alerts`, `status:observe`, `system:heartbeat` + queue heartbeat job, `wa:health-check`, `smpp:sweep`, `smpp:servers-health`, `wa:outbox-pump`, `wa:warmer-tick`, `wa:connection-alerts`, `wa:resume-temp-bans`, `devices:offline-alerts`, `sms:move-pending-from-offline`, `sims:resume-carrier`, `ussd:run-schedules`, `ussd:expire-sessions`, `phone-bridge:sms-outbox`, `phone-bridge:device-webhooks`, `network:reserve-call-minutes`, snoozed-conversation wake job, SLA breach flag job
- **Every 5–15 min:** `messages:rollup` (15m), `flows:date-trigger-tick`, `wa:fail-stale-queued`, `sms:fail-stale-queued`, `waba:fail-stale-queued`, `push:fail-stale-queued`, `campaigns:sweep-counters` (15m), `campaigns:watchdog`, `servers:sweep-moves`, `smpp:balance`, `telephony:balance`, `telephony:servers-health`, `wa:delivery-health` (15m), `android:app-updates` (15m), `knowledge:refresh` (15m) / `knowledge:retry`, `billing:usage-alerts` (15m), `payments:expire-links` (15m), `network:release-earnings` (15m), `network:health` (15m), `sentry:flush` (error reports, §9)
- **Hourly:** `subscriptions:manage`, `subscriptions:grant-monthly-credits`, `reports:send-cost-emails`, `market:expire-pending`, `privacy:account-deletions`, conversation auto-close job, `sims:detect-missing-delivery-reports`, `flow:sweep-dry-runs`
- **Daily (mostly 02:00–04:56 UTC prune/maintenance window):** `messages:rollup --days=3`, `otp:prune`, `whatsapp-sign-in:prune`, `oidc:rotate-keys`, `wa:sweep-server-counters`, `wa:expire-stale-pairings`, `wa:warmer-prune`, `wa:media-garbage`, `wa:prune-group-messages`, `wa:prune-suppressions`, `wa:prune-connect-links`, `landing:sweep-uploads`, `status:rollup`, `status:prune-subscribers`, `android:cleanup-heartbeats`, `cleanup:stale-pairings`, `cleanup:import-files` (5m), `voice:prune-prompt-assets`, `api:prune-idempotency-keys`, `calls:prune-recordings`, `links:prune-click-details`, `flows:prune-runs`, `flows:prune-date-occurrences`, `abuse:prune-velocity-counters`, `subscribe:prune-submissions`, `widget-campaigns:prune-stats`, `flow:fail-stranded-runs`, `flow:sweep-media`, `knowledge:prune`, `privacy:prune`, `queue:prune-failed --hours=720`, `queue:prune-batches`, `yookassa:process-renewals` + `paystack:process-renewals` (00:30), `waba:sync-messaging-limits`, `waba:prune-onboarding-attempts`, `model:prune` (15 models), plugin-registered schedules via `registerSchedule`, `integrations:prune-routing`, demo-only `demo:cleanup`
- **Periodic:** `waba:sync-templates` (6h), `phone-bridge:publish-minutes` (monthly), `messages:unlock-inbound` (monthly), `voice:prune-voice-samples` (weekly)
- **Queue self-hosting:** the scheduler itself launches `queue:work --stop-when-empty` runners for the main queue list and a long-timeout `privacy-exports` runner (i.e. cron-driven workers are a supported deployment mode, Horizon not required).

### Queue jobs (`app/Jobs/`, 84 PHP files incl. subdirs)

Named queues seen in code: `waba-media, channel-webhooks, wa-control, wa-media, email, sms-send, push-send, default, ai-agents, voice-ai, contact-imports, knowledge, sms-campaigns, sms-bulk, waba-campaigns, wa-campaigns, push-campaigns, email-campaigns, telegram-campaigns, wa-warmer, privacy-exports` (+ plugin queues e.g. `telegram-campaigns`).

Job families: webhook delivery (`DeliverWebhookJob`), contact imports (`ImportContactsJob`, `ImportContactsSlice`), flow engine (`RunFlowJob`, `SendFlowFanoutJob`, `FanOut*`), device pushes (`SendPushNotification` §7, `SendUssdPendingPush`, `SendDeviceUpdatePush`, `PushAppUpdateToDevices`, `SendCampaignControlPush`, `SendRcsSetupPush`, `SendNetworkMessageHoldsPush`), scheduled sends (`SendScheduledMessageJob`), heartbeat (`RecordQueueHeartbeatJob`), and subdir families: Messaging, Messenger, Omnichannel, Billing, Payments, Commerce, Market, Knowledge, Contacts, Links, Otp, Privacy, Mobile, ServiceServers, Status, Telephony, Voice, Widget, AiAgents-adjacent, Flow.

Artisan commands overall: 119 PHP files in `app/Console/` (incl. the scheduled commands above and admin utilities like `channel-plugins:sync`).

---

## Appendix — evidence index (key files)

- Stack: `app/composer.json`, `app/composer.lock`, `app/package.json`, `app/.version`
- Plugin engine: `app/Services/PluginManager.php`, `app/Providers/PluginServiceProvider.php`, `app/Providers/PluginPageRouteServiceProvider.php`, `app/Services/Channels/ChannelPlugins.php`, `app/Contracts/Plugin.php`, `app/Contracts/ChannelRuntimePlugin.php`, `app/Contracts/SmsProviderPlugin.php`, `config/plugins.php`
- Core plugins: `app/Plugins/PaymentGateways/{PayPal,BankTransfer}/`, `app/Plugins/Channels/{Waba,SmsProviders}/`
- Android: `routes/api.php` (internal/android block), `app/Http/Middleware/AndroidSession.php`, `app/Models/Device.php`, `app/Jobs/SendPushNotification.php`
- WhatsApp: `app/Services/Messaging/Wa/WaBinaryClient.php`, `app/Services/Messaging/Wa/WhatsappServerKind.php`, `plugin-whatsapp/server/`
- SMPP: `app/Services/Messaging/Sms/Smpp/*`, `app/Services/Messaging/Sms/Drivers/SmppDriver.php`, `plugin-smpp/server/`
- Phone-home: `app/Services/ErrorReporting/SentryReporterService.php`, `config/services.php`, `app/Http/Controllers/Admin/SettingsController.php`
- Branding: `app/Support/helpers.php` (`site_name()`), `resources/js/widget/shared/panel/PoweredBy.tsx`, `app/Services/Billing/PlanCatalog.php`
- Scheduler: `routes/console.php`
