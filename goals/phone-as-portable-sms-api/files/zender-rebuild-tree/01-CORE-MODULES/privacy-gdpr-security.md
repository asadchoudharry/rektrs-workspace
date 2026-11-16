# CORE — Privacy, GDPR & Sending Safety

**Status: core-owned (purchased).**
Sources: Lane 2 (Privacy/GDPR/Security), Lane 4 §§A, D, Lane 5 §§5.3, 12.

## Privacy & retention (defaults)
| Data | Retention |
|---|---|
| Incoming webhooks | 30 days |
| Outgoing webhook deliveries | 30 days (setting) |
| Cookie consent | 730 days |
| Data exports | 7 days |
| Link clicks | 90 days (counts kept) |
| Flow run history | 90 days |
| Pre-update backups | last 3 |
| Audit logs | "Audit Logs Days" setting (0 = indefinite) |

- Cookie banner: Automatic mode (demo); consent records in
  `cookie_consents`.
- **Opt-out keywords:** STOP / UNSUB / UNSUBSCRIBE / CANCEL / END /
  QUIT; opt-in: START / UNSTOP / RESUME (config
  `unsubscribe_keywords.php`).
- **Contact erase:** content + media deleted, pending sends cancelled,
  empty rows + audit trail remain, and the number stays opted-out as an
  APP_KEY hash.
- **Account deletion:** password + 2FA, grace 0–90 days, scheduler
  completes it (`privacy:account-deletions` hourly). Privacy exports
  run on the dedicated `privacy-exports` queue (can take ~1 hour).
- Plugins participate via the `PersonalDataSource` /
  `PersonalDataClassification` / `PersonalDataMessageContent`
  contracts and the manifest flag `personal_data: true` — **every
  plugin we build that stores personal data must implement these**
  (Legacy Importer is the reference).

## Sending Safety (anti-abuse)
- Trial / Under Review mode: demo config = trial 3 days, 50 messages;
  trial workspaces face an international-destination restriction
  (403 `trial_destination_not_allowed`).
- Blocked Words (regex), Blocked/Allowed Domains, URL shortener policy
  (allow / flag / block — demo: Allow), phishing heuristics, URL Policy
  (demo: Blocklist Only).
- Sender ID approval: Pending → Approved / Rejected (demo: approval
  requirement off).
- Admin > Abuse Review: tabs Flagged / Workspaces / Blocked Words /
  Blocked Domains. Per-workspace velocity counters
  (`send_velocity_counters`, pruned daily) and `workspace_abuse_settings`.
- Workspace Activity Log gives each tenant its own audit view.

## Security mechanics
- 2FA + recovery codes (see `auth-accounts.md`).
- Webhook SSRF guard: private/loopback/metadata addresses refused at
  save and delivery (see `07-API-MAP.md`).
- Plugin config secrets: masked in UI, encrypted at rest by
  `PluginManager` + `SystemSetting` storage.
- Error reporting (vendor Sentry) is OFF by default — keep it OFF
  (`00-OVERVIEW.md` phone-home #1).

## Data (tables)
`privacy_requests`, `account_data_exports`, `account_deletion_requests`,
`contact_data_exports`, `cookie_consents`, `user_consents`,
`audit_logs`, `abuse_flags`, `workspace_abuse_settings`,
`send_velocity_counters`, `sentry_pending_reports`.

## Keep / extension notes
- Core-owned. Compliance posture for Pakistan operations (PTA mask
  rules, grey-traffic ban) is an operations/legal layer on top of
  these mechanics — see the master plan addenda; the code hooks we
  need (blocked words/domains, sender approval, velocity limits)
  already exist here.
