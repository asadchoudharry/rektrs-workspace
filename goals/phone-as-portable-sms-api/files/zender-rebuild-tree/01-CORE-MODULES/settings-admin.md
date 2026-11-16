# CORE — Settings & Admin Operations

**Status: core-owned (purchased).**
Sources: Lane 2 (System Settings, Admin guide), Lane 4 §§A, D, Lane 5 §9.

## Admin Settings — 17 tabs (Lane 2) / 15 groups walked in demo (Lane 4)
General, Billing, Referral, Domains, Integrations, Support,
Authentication, Email, Contact, Custom Code, Mobile App, Updates,
Maintenance, WhatsApp, Partner Network, Sending Safety, Privacy.
Secrets are stored encrypted in `system_settings`, never returned by
the UI; saving a blank field keeps the old value, "Clear" removes it;
every change is audit-logged.

- **General:** Site Name "Zender" (ours will be our brand), Tagline,
  Description, Logo / Dark Logo / Favicon, Default Theme (System),
  **Color Theme: Neutral (options Blue/Green/Orange/Red/Rose/Violet/
  Yellow)**, Timezone, Date Format, Public API Docs toggle, Error
  Reporting toggle, **Purchase Code (encrypted)** — the purchase code
  exists ONLY as the error-reporting identifier (Lane 5 §9-F3).
- **Contact:** support email/phone/WhatsApp + social links.
- **Custom Code:** master toggle; Custom CSS, Head Code, Footer Code,
  Consent Marketing — public pages only.
- **Domains:** Workspace Subdomains on/off; Custom Domains on/off
  (see `custom-domains.md`).
- **Integrations:** Realtime driver (demo: Pusher cloud, ap1 cluster)
  + Test Connection (see `05-INFRA.md`).
- **Mobile App:** Enabled toggle; APK slot (demo file
  `zender-demo-mobile-v5.0.4.apk`, 99 MB, v1.0.0); Play/App Store
  links; Firebase push status. APK installed via
  `php artisan mobile:install-apk <file>`.
- **Support:** tickets on/off; Max Open Tickets/User 5; file 10MB;
  attachments 5.
- **Maintenance:** on/off + message; Retry After 5–3,600s (demo 60s);
  admins keep access (differs from `artisan down`).
- **Billing:** Currency (single, no conversion), Market Enabled,
  Ships To.
- **Referral / Partner Network:** see `referral-partner-network.md`.
- **Authentication:** see `auth-accounts.md`.
- **Email (system):** SMTP / Sendmail / Log, TLS/SSL, From address,
  Admin Notification Emails. Password resets go through the queue.
  This is system mail only — tenant mailboxes are the Email plugin.
- **WhatsApp tab:** platform-level WhatsApp defaults (WABA config
  surface — `waba.md`).
- **Updates:** System Upgrade entry point for manual updates
  (`05-INFRA.md`).
- **Sending Safety / Privacy:** see `privacy-gdpr-security.md`.

## Admin operations screens (Lane 4 §A)
Overview dashboard (signups/subscribers/revenue/messages/servers/
tickets + charts), Users, Subscriptions, Tickets (20 in demo),
Referrals, Plans, Credit Packs, Vouchers, Transactions, Market,
Partner Network, **Servers** (the 5 companion families — `05-INFRA.md`),
Status Page admin, Landing Builder, Custom Pages, Guided Tours,
Languages, Domains (41 workspaces listed), AI Providers, Admin Roles,
Cron Jobs, Abuse Review, System Logs, Plugins (42 — the plugin
universe; see Lane 4 §C).

## Plugins admin (install surface)
Admin > Plugins > Upload ZIP (≤ 20MB per docs; installer ceilings in
code: 5,000 entries / 100MB) → installed **inactive** → Configure →
Activate. Update in place (same/newer version). Core plugins cannot be
uninstalled. Broken plugins surface with `is_broken` + reason instead
of crashing (Lane 5 §5.5). There is **no separate marketplace screen**
— install happens on this page; the tenant-facing shape is the
tenant's Integrations page.

## Keep / extension notes
- Core-owned. Our admin work here is configuration, not code: brand,
  currency, domains, realtime, safety defaults.
- **Standing decisions to record at install (Phase 0):** Error
  Reporting stays OFF (phone-home point #1); Purchase Code handling
  follows the custom-licence outcome; Reverb self-hosted (not Pusher)
  for production.
