# Sendqon Urdu Pack v1 (USP-1)

Urdu user-interface language pack + ready message templates for Sendqon
(Zender v5.0.4), built as part of the B2 Pakistan pack (USP-1).

## What is inside

- `lang/ur/*.json` — 7 translation files, 3,523 strings, covering the
  highest-traffic surfaces: `common` (491), `auth` (210), `navigation` (26),
  `billing` (527), `emails` (627), `landing` (644), `chat` (998).
  Every key present in the English source is present here; all `:placeholders`
  and `{{merge fields}}` are preserved byte-for-byte (machine-verified).
  Brand and technical terms (WhatsApp, SMS, WABA, MCP, API, SIM, GSM and the
  payment/integration names) stay in Latin script, matching the vendor's own
  Arabic/Japanese packs. Strings not covered by these 7 files, and any key not
  yet translated, fall back to English per key by design.
- `templates/ready-templates.json` — ready-to-use message templates in Urdu
  and Roman Urdu: fee reminder, cash-on-delivery order confirmation,
  appointment reminder, with `{{variable}}` merge fields.

## How it installs (no core edits, no plugin)

The app's localization system reads `lang/<locale>/*.json` directly and
registers selectable languages in the `languages` table
(`App\Services\Translations::dictionary()` merges the English base, the
locale files, then database overrides; missing keys fall back to English).

1. Copy `lang/ur/` into the app tree at `lang/ur/` (same relative position as
   `lang/en/`).
2. Register the language through the app's own model (equivalent to
   Admin → Settings → Languages → Add): code `ur`, country code `PK`,
   name "Urdu", native name "اردو", `is_rtl = true`, active.
3. Clear/refresh the compiled dictionary cache if present
   (`bootstrap/cache/translations`) — the app rebuilds it on demand.

Rollback: delete `lang/ur/` and deactivate/delete the `ur` language row.
Nothing else is touched.

## Ready templates

The templates ship as pack content. To use them in a workspace, add each one
as a canned response (Messenger → Canned Responses) or paste it into a
campaign; the `{{...}}` fields are substituted by the app at send time.

## Side benefit

Because the pack registers Urdu as a real site language, Urdu also becomes
selectable in the Titan Android app builder's language list (the builder
reads the site's installed languages — previously only Arabic and Japanese
were offered).
