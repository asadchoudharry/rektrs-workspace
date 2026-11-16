# CORE — Localization

**Status: core-owned (purchased).**
Sources: Lane 2 (Localization), Lane 4 §§A–B, Lane 5 §1.

## Purpose
Full UI translation system: shipped languages, a DB-backed translation
editor, per-contact language, and developer language files. Relevant
to us: an Urdu language pack is a realistic own-addition later.

## Shipped state
- Languages shipped: **English, Arabic (RTL), Japanese** — demo shows
  all three at 100%. Locale trees in `lang/` (206 files, 8.5 MB).
- Translations live in the **database** and survive upgrades.
- Admin > Languages manages packs; the editor tracks progress in
  separate tabs per surface: Android / Phone Bridge / USB Modem /
  Mobile App (companion apps have their own string sets).
- AI Translate is available in the editor (needs an AI provider —
  `ai-providers-credits.md`).

## Rules
- Language code: 2–3 letters + optional region/script (`pt_BR`,
  `zh_Hant`, `ckb`). RTL is automatic for RTL languages.
- Import matches code/name/native name case-insensitively; an invalid
  language yields `invalid_language`.
- The editor preserves placeholders (`:name`, `{{contact.name}}`) and
  pipe plurals — breaking them breaks rendering.
- Contacts carry their own language; message translation uses it
  (`message_translations` table).

## Developer files
`lang/<code>/<file>.json` — copy `lang/en/`, keep 4-space indent and
unescaped Unicode. Tables: `languages`, `translation_overrides`.

## API surface
`routes/i18n.php` (locale switching); `api.apps.translations` feeds
the mobile/branded apps so languages can change **without an app
rebuild** (used by `02-PAID-PLUGINS/mobile-app.md`).

## Keep / extension notes
- Core-owned. Adding Urdu = a new language pack through this system
  (translation work, not code). Any plugin we ship must put its strings
  in the same system — hard-coded English in a plugin is a defect.
