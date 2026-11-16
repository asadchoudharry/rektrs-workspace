# FREE PLUGIN — WhatsApp Embedded Signup (v5.0.4)

**What it is:** the free plugin that gives tenants Meta's one-click
**Embedded Signup** onboarding for WABA, plus WhatsApp Business app
**Coexistence** (using the same number in the WA Business app and the
API). Demo state: Active, Configured — "requires WABA" (Lane 4 §C).

## What it contains (Lane 5 §5.7-4)
The most substantial free plugin: slug `waba_embedded_signup`, type
**`waba_provider`** (an extension of the WABA channel — it cannot
activate unless WABA is present/active). Seven PHP files in the ZIP
root:
- `EmbeddedSignupPlugin.php` — config shell
- `WabaOnboardingService.php`
- `SignupEndpoints.php`
- `SignupReadiness.php`
- `CoexistenceSyncRequests.php`
- `CoexistenceContactSync.php`
(+ the manifest)

It implements Meta Embedded Signup + Coexistence onboarding on top of
core WABA (`../01-CORE-MODULES/waba.md`); core tracks attempts and
syncs in `waba_onboarding_attempts`, `waba_coexistence_syncs`,
`waba_contact_sync_links`.

## Integration shape
An extension plugin: no new channel, no companion server. It needs
the platform's Meta app configuration (`WABA_APP_ID`, `WABA_APP_SECRET`,
`WABA_CONFIG_ID` in `.env` / system settings). Public docs mention it
only as a single link from the WABA page (Lane 2 gap #6) — the real
documentation is inside the plugin ZIP.

## Our stance
- **Use it (interim and likely long-term):** unlike the QR/binary
  components, this is plain PHP implementing a public Meta flow —
  exactly the kind of thing Phase 1 (white-label + WABA live) wants
  working on day one.
- **Own replacement:** only if the custom licence or independence
  strategy requires it; the pattern (7-file `waba_provider` extension)
  is fully visible and replicable against Meta's public Embedded
  Signup documentation. Priority: low — no rebuild scheduled.
