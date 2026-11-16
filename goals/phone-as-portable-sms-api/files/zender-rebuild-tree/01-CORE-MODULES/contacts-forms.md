# CORE — Contacts & Subscribe Forms

**Status: core-owned (purchased).**
Sources: Lane 2 (Contacts, Forms), Lane 4 §B, Lane 5 §4/§6.

## Purpose
The address book every other module sends to: contacts with custom
fields, groups/tags/segments, imports/exports, opt-out state, and the
hosted/embedded subscribe forms that feed it.

## Screens / pages (tenant, Lane 4)
- Contacts: 400 in demo. Tabs: Contacts, Phone Opt-Outs, Suppressed
  Emails, Suppressed WhatsApp, Segments, Duplicates, Privacy Requests,
  Settings.
- Add Contact dialog (First/Last Name, Phone, Email); Import/Export CSV.
- Groups (24 in demo), Tags (24), Segments (24).
- Forms: 12 subscribe forms in demo (30 submissions / 27 confirmed
  each); Double Opt-In toggle shown per form.

## Features + rules / limits
- Phone stored as **E.164**; phone and email are unique **per
  workspace**. Custom fields: Text / Number / Date / Checkbox / Select /
  Multi-select / URL / Email, referenced as `{{contact.key}}`.
- Organisation: groups, tags, segments (saved filters).
- Import: CSV/XLSX ≤ 50MB, 5-step wizard; ≤ 2,000 rows processed
  immediately, larger files queued (`contact-imports` queue). Email
  validation on import: Valid / Risky / Invalid / Unknown (local DNS
  checks). Duplicate merge tool. Export to file.
- Opt-outs are first-class: keyword opt-outs (STOP etc.) land contacts
  in `unsubscribed` / `unsubscribed_emails` / `wa_suppressions`; sends
  to opted-out recipients fail with 422 `recipient_unsubscribed`.
  Contact erasure keeps a hashed number on the opt-out list (APP_KEY
  hash) — see `privacy-gdpr-security.md`.
- Each contact carries its own language (drives message translation).

## Subscribe Forms
- Hosted or embedded; white-labelled; capture email, phone, or both;
  consent text; target group + tags; optional Business Name override.
- Double opt-in produces `form.submitted` → `form.confirmed` webhooks.
- Public routes in `routes/subscribe.php`; form pages carry
  "Powered by {site name}" unless the plan has White Label
  (Lane 5 §10).

## Data (tables)
`contacts`, `contact_aliases`, `contact_consents`, `contact_fields`,
`contact_field_values`, `contact_groups`, `contact_group`,
`contact_identities`, `contact_imports`, `contact_import_errors`,
`contact_exports`, `contact_data_exports`, `contact_notes`,
`contact_segments`, `contact_tags`, `contact_tag`, `contact_tasks`,
`contact_unsubscribe_tokens`, `unsubscribed`, `unsubscribed_emails`,
`subscribe_forms`, `subscribe_form_submissions`.

## API surface
Contacts CRUD/upsert/bulk/lookup/consent, notes, tags, groups,
segments (+count), imports, exports; `forms.index`,
`forms.submissions`. Webhooks: `contact.created`,
`contact.unsubscribed`, `form.submitted`, `form.confirmed`.

## Plan gates
Contacts limit (422 `contacts_cap_reached` when hit).

## Keep / extension notes
- Core-owned. Integrations (Shopify/WordPress/WooCommerce in
  `02-PAID-PLUGINS/`) sync *into* this module through the API/contracts
  — they never write contact tables directly.
- Consent state here is the legal record our campaigns rely on; any own
  import tooling must write through the same import pipeline so
  validation + opt-out checks apply.
