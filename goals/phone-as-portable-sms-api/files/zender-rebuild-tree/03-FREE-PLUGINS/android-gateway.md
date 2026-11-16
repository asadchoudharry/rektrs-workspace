# FREE PLUGIN — Android Gateway (v5.0.4)

**What it is:** the free plugin that enables Android phones as SMS
gateway devices. Free for verified buyers "at vendor discretion"
(Lane 3 study). Demo state: Active, Configured (Lane 4 §C).

## What it actually contains (Lane 5 §5.7-1 — the key insight)
The plugin ZIP (`plugin-android-gateway/plugin.zip` → `Android/`) is a
**single-file plugin class**: slug `android`, type `channel`, channel
key `sms`, namespace `App\Plugins\Channels\AndroidPlugin`, implementing
`Plugin, ProvidesAppSlots, ProvidesValidatedPluginConfig,
UsesSystemSettingConfig`. It contributes **no routes and no protocol
logic** — the entire Android gateway protocol lives in **core**
(Lane 5 §7). Its real jobs:

1. Declare the **4 downloadable app slots**: `android_gateway`,
   `android_rcs`, `android_receiver`, `android_ussd` — each with
   version-compatibility patterns (this is how the dashboard offers
   the right APK builds).
2. Provide the **config schema**: `carrier_pause_hours` (default 6),
   `rcs_pacing_seconds` (default 6), `firebase_credentials` (FCM
   service-account JSON, stored encrypted).

Core checks this plugin's manifest presence via
`ChannelPlugins::present('android')` — without the plugin installed,
the Android channel does not exist even though the code is core's.

## Docs inside the ZIP
Like every plugin, it carries its own documentation inside the ZIP
(the public docs site has **no Android setup page at all** — Lane 2
gap #2: no APK install/pairing, SIM selection, long-poll protocol,
battery or FCM setup in the public docs; the ZIP docs + screenshots
under `plugin-android-gateway/Documentation/` are the source).

## Our stance
- **Use as reference + interim:** keep it installed so the Android
  channel works while our own app is built; the system must not
  *depend* on the vendor APK.
- **Own replacement:** our clean-room Android app against core's
  documented protocol — spec in `04-NO-SOURCE/android-gateway-apk.md`.
  The plugin shell itself needs no replacement (it's a manifest +
  config; if the custom licence ever required it, an equivalent shell
  is a one-class plugin).
- File watermark note: the plugin's main class file ends with a large
  whitespace block consistent with a vendor copy marker (Lane 5 §9-F5)
  — do not strip or alter distributed plugin files.
