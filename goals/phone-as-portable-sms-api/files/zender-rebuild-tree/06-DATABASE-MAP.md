# 06 — DATABASE MAP

Source: Lane 5 §4 + `LANE-5-DB-TABLES.md` (the full alphabetical list of
all **316 core tables**, extracted from `Schema::create()` calls across
510 migration files). This file is the grouped map; the Lane 5 file is
the complete register.

## Tenancy model — workspace-centric

Almost every tenant-owned row hangs off a **workspace**. Users are
platform accounts (`users`); workspaces group members, roles, channels,
contacts, conversations, billing. Key spine:

- `users` — platform users (admins + tenant owners/agents)
- `workspace_roles`, `workspace_invitations` — per-workspace RBAC and invites
- `subscriptions` → `plans` — one active plan per workspace drives all
  feature gates and limits
- `channel_connections` — every connected channel (SMS provider, Android
  device, WABA number, WA account, …) belongs to a workspace
- `contacts`, `conversations`, `campaigns`, `flows` — all workspace-scoped
- `credit_transactions`, `credit_reservations` — the workspace money ledger
- `service_servers`, `plugins`, `system_settings` — platform-level (no
  workspace): companion servers, plugin ledger, global config

Platform staff are separate from tenant roles: `admin_roles` (Super
Admin 62 permissions in the demo) vs `workspace_roles` (Admin 73 /
Manager 54 / Supervisor 6 / Agent 20 / Read Only 19 permissions).

## Grouped summary of the 316 core tables

**Identity & workspaces:** users, admin_roles, workspace_roles,
workspace_invitations, personal_access_tokens, oauth_access_tokens,
oauth_auth_codes, oauth_clients, oauth_device_codes,
oauth_refresh_tokens (Passport), password_reset_tokens, sessions,
login_handoff_tokens, oidc_signing_keys, user_consents,
user_notifications, user_onboarding_progress, onboarding_flows,
onboarding_steps, onboarding_flow_contents, onboarding_step_contents,
whatsapp_sign_in_apps, whatsapp_sign_in_grants, mobile_devices,
mobile_sign_in_tokens, companies, shipping_addresses

**Messaging core:** messages, message_attachments, message_deliveries,
message_reactions, message_translations, message_rollups,
message_rollup_state, platform_message_rollups,
message_connection_rollups, channel_messages, channel_connections,
channel_webhook_events, conversations, conversation_events,
conversation_label_links, conversation_labels, conversation_messages,
conversation_notes, conversation_participants, conversation_reads,
conversation_rounds, conversation_views, messenger_teams,
messenger_team_members, messenger_team_round_robin_cursors,
messenger_macros, messenger_reads, messenger_domain_releases,
canned_responses, quick_replies, csat_surveys, sla_policies,
assignment_rules, agent_round_robin_cursors, agents

**Contacts:** contacts, contact_aliases, contact_consents,
contact_fields, contact_field_values, contact_groups, contact_group,
contact_identities, contact_imports, contact_import_errors,
contact_exports, contact_data_exports, contact_notes, contact_segments,
contact_tags, contact_tag, contact_tasks, contact_unsubscribe_tokens,
unsubscribed, unsubscribed_emails

**Campaigns & flows:** campaigns, campaign_recipients,
campaign_variants, campaignables, scheduled_messages, scheduled,
sequences, sequence_enrollments, flows, flow_nodes, flow_edges,
flow_runs, flow_run_steps, flow_answers, flow_run_idempotency,
flow_schedule_holds, date_trigger_cursors, date_trigger_occurrences

**SMS / Android / telephony:** devices, device_connections,
device_diagnostics, device_heartbeats, device_invites,
device_offline_alerts, device_pairings, device_sign_in_challenges,
device_update_notices, sims, sim_carrier_events, sim_route_rules,
sms_provider_routes, gateways, gateway_customers,
gateway_webhook_events, smpp_assignment_history, calls, call_events,
call_transcripts, call_agent_rings, call_contact_graphs,
call_media_streams, call_tombstones, call_uploads, call_webhook_marks,
call_log_exports, phone_bridge_pairings,
telephony_assignment_history, voice_prompts, voice_flow_versions,
voicemail_reads, ussd, ussd_schedules, ussd_scripts, sender_ids,
dlt_templates, sent, received, sms_campaign_processed,
send_velocity_counters, sender_binding_cursors

**WhatsApp (QR):** wa_accounts, wa_account_events, wa_instances,
wa_connect_links, wa_connection_alerts, wa_groups, wa_group_members,
wa_poll_votes, wa_reactions, wa_received, wa_sent, wa_server_releases,
wa_suppressions, wa_library_errors, wa_warmer_conversations,
wa_warmer_messages, wa_warmer_partners, wa_warmer_runs

**WABA:** waba_accounts, waba_phone_numbers, waba_templates,
waba_template_library_entries, waba_template_library_variants,
waba_received, waba_sent, waba_scheduled, waba_reactions,
waba_entry_points, waba_onboarding_attempts, waba_coexistence_syncs,
waba_contact_sync_links, meta_webhook_events, ctwa_ads,
ctwa_ad_conversations, ctwa_attribution_settings,
ctwa_conversion_configs, ctwa_conversions, ctwa_referrals

**Billing / SaaS:** plans, plan_ai_provider, plan_service_servers,
plan_usage_alerts, plan_wa_servers, subscriptions, transactions,
credit_packs, credit_pack_plan, credit_reservations,
credit_transactions, vouchers, voucher_redemptions, payment_accounts,
payment_links, disputes, referral_codes, referrals,
referral_credit_transactions

**Plugins & servers:** plugins, service_servers, service_server_moves

**Partner Network:** network_lines, network_line_country_rates,
network_charges, network_reply_routes, network_reply_route_events,
network_reports, partners, partner_ledger, partner_payouts

**Market:** market_categories, market_products, market_orders,
market_order_events, market_license_codes

**Commerce (Telegram Store etc.):** commerce_stores, commerce_products,
commerce_product_variants, commerce_carts, commerce_checkouts,
commerce_orders, commerce_order_events, commerce_customer_links

**Bookings:** appointments, appointment_calendar_events,
appointment_trigger_fires, booking_pages, booking_services,
booking_members, booking_service_member, booking_time_off,
calendar_connections, calendar_busy_blocks, calendar_event_deletes

**AI / knowledge / MCP:** ai_providers, ai_usage_logs, user_ai_keys,
user_ai_feature_models, knowledge_bases, knowledge_sources,
knowledge_chunks, knowledge_queries, knowledge_workspaces,
prompt_assets, mcp_oauth_grants, mcp_send_receipts

**Channels misc:** widget_visitors, widget_campaigns,
widget_campaign_stats, widget_proof_events, widget_proof_presence,
widget_proof_stats, push_subscription_states, fcm_sends,
google_sheet_connections, google_sheet_files,
google_sheet_operations, google_sheet_row_occurrences,
google_sheet_subscriptions, integration_site_routing

**Platform / ops:** system_settings, system_heartbeats, cron_runs,
audit_logs, abuse_flags, workspace_abuse_settings,
api_idempotency_keys, jobs, job_batches, failed_jobs, cache,
cache_locks, stored_files, file_folders, languages,
translation_overrides, custom_pages, custom_page_contents,
custom_page_versions, landing_contents, landing_drafts, landing_items,
landing_sections, landing_versions, pages, tickets, ticket_messages,
ticket_attachments, status_daily, status_email_sends,
status_incident_updates, status_incidents, status_observations,
status_subscribers, setup_check_runs, connection_update_notices,
privacy_requests, account_data_exports, account_deletion_requests,
sentry_pending_reports, otp_settings, otp_verifications,
otp_prefix_suspensions, subscribe_forms, subscribe_form_submissions,
cookie_consents, tracked_links, tracked_link_codes, link_clicks,
report_email_sends, actions

Note: several plugin-shaped features already have **core tables**
(bookings, knowledge base, MCP grants, commerce, Google Sheets) — the
paid plugins activate logic against schemas core already ships. When we
build our own versions we reuse these tables where the core models
expect them; we do not invent parallel schemas.

## Plugin table pattern (for our own plugins)

- A plugin declares its migrations **in its manifest** (`migrations`
  list, manifest-relative paths). `PluginManager` runs them in place at
  install (`migrate --path --realpath`) and records them on the
  plugin's row in the `plugins` table (slug, status, stored config,
  ran-migrations ledger). Uninstall rolls back exactly the recorded
  migrations and deletes the plugin's files (Lane 5 §5.5).
- Reference example: Legacy Importer adds `legacy_import_runs`,
  `legacy_import_maps` via one manifest-listed migration (Lane 5 §5.7).
- Rules for our plugins: table names prefixed with the plugin's domain
  (like core does: `wa_*`, `waba_*`, `network_*`); every tenant table
  carries the workspace reference; personal-data tables must be declared
  (`personal_data: true` in the manifest) so GDPR export/erasure reaches
  them (see `01-CORE-MODULES/privacy-gdpr-security.md`).

## Key relationships to respect when building

- **Credits are a ledger, not a balance field:** `credit_transactions`
  + `credit_reservations`; failed/cancelled sends refund through the
  same path. Anything we build that sends must charge/refund identically.
- **Messages are rollups-friendly:** raw `messages` + deliveries, with
  `message_rollups`/`platform_message_rollups` rebuilt by scheduled
  jobs — reports read rollups, not raw rows.
- **Devices/SIMs:** `devices` holds the phone (session token stored only
  as SHA-256 hash), `sims` the per-slot lines with caps and
  `sim_route_rules`; routing picks explicit SIM → provider prefix route
  → default.
- **Servers:** `service_servers` + `service_server_moves` +
  `plan_service_servers`/`plan_wa_servers` tie companion capacity to
  plans — our replacement servers inherit plan gating for free if they
  register properly.
