# Sendqon Gateway App v5.5.0 — Dark Theme

**Date:** 2026-11-20 (release registered 19:17:31 UTC / 2026-11-21 00:17:31 PKT)
**Identity:** package `com.rektrs.sendqon`, version 5.5.0 / code 50500, signer `eba2c40d377418385830b1228a6ea19c65593f837790e2971a5431a9fd7742ee` (custody key, verified from the built APK with apksigner — in-place update over 5.4.1 holds)
**APK:** `files/android-app/sendqon-gateway-own-v5.5.0.apk`, 4,587,871 bytes, SHA-256 `45a7ecf47c447378ae6869915c674e6f7f9ef35620a904c7064def597f565981`
**Source:** branch `app-own-android` commit `3c0bc2a` (on top of v5.4.1 `1af10f4`)
**Authorisation:** owner "Teeno bana do" (chat, 2026-11-20 23:56 PKT) — item 3 of three approved builds. v5.3.0–v5.4.1 knowingly shipped light-only (no palette existed); this release closes that gap.

## 1. What shipped

**A token layer, not a coat of paint.** New `Theme.kt` (pure JVM) defines a `Palette` data class with 21 tokens and two complete instances. `Ui`'s colour constants are now getters over `ThemeState.current`, so every screen that was already built from the kit (Home, Activity, Logs, Settings, SIM cards, balance cards, checklist, guide, pairing) picks up the palette at render time with no per-screen colour code. Screens read tokens; only `Theme.kt` names raw colours.

**The choice.** Settings → **Appearance**: System / Light / Dark chips (EN + UR strings added). The choice persists in `Store.themeMode` (SharedPreferences, default `system`) and is resolved by the pure `ThemeState.resolve(mode, systemDark)` at app start, activity start and resume — so under System, a phone-level dark-mode flip is picked up at the next natural render. Changing the choice in Settings recreates the activity, re-rendering every surface in the new tokens immediately. Framework chrome follows: `MainActivity` selects a new `Theme.Sendqon.Dark` framework theme (Material dark — dialogs, switches, platform widgets) and sets window chrome per palette (brand indigo status bar over the gradient header in both; navigation bar on the page ground with matching icon contrast). One deliberate side-effect: in light, the navigation bar now sits on the page ground (#F4F5FB) instead of pure white — the same colour the floating nav's own backdrop already used.

**Dark palette** — derived from the brand family, not a generic grey: surfaces are deep navy out of the launcher navy (#1E1B4B), text is lavender-tinted, the indigo→blue gradient, cyan signal accent and brand fills are unchanged.

| Token | Light | Dark |
|---|---|---|
| ground | #F4F5FB | #0C0B21 |
| card | #FFFFFF | #1B1A38 |
| line | #E5E7EB | #34335C |
| ink | #171717 | #F2F1FA |
| muted | #646C79 † | #A5A3C7 |
| accentText | #2563EB | #8AB8FF |
| headerChip | #FFFFFF | #14132E |
| green / greenBg | #15803D † / #DCFCE7 | #4ADE80 / #0F3520 |
| amber / amberBg | #B45309 / #FEF3C7 | #FBBF24 / #3D2C07 |
| red / redBg | #B91C1C † / #FEE2E2 | #F87171 / #40191C |
| greyBg | #F3F4F6 | #26254A |
| indigo / blue / cyan | #4F46E5 / #2563EB / #38BDF8 | unchanged (brand) |
| onBrand / onBrandMuted | #FFFFFF / #DCFFFFFF | unchanged (on-gradient) |
| ripple | #26111111 | #38FFFFFF |

† Three light values moved **one shade step inside their own colour family** so light body text reaches AA too (they were the shipped design's only sub-AA text pairs): muted #6B7280 → #646C79 (4.44 → 4.87 on ground), green #16A34A → #15803D (3.00 → 4.57 on its pill background; 3.30 → 5.02 on white), red #DC2626 → #B91C1C (3.95 → 5.30 on its pill background; 4.83 → 6.47 on card). No other light value changed.

## 2. Contrast — computed, and pinned by tests

WCAG ratios for every text-on-surface pair the screens produce (the same pairs `ThemeTest` asserts ≥ 4.5 in **both** palettes):

| Pair | Light | Dark |
|---|---|---|
| ink on card / ground | 17.93 / 16.48 | 14.97 / 17.26 |
| muted on card / ground / greyBg | 5.30 / 4.87 / 4.82 | 6.92 / 7.98 / 5.99 |
| accentText on card / ground | 5.17 / 4.75 | 8.29 / 9.56 |
| green on greenBg | 4.57 | 7.77 |
| amber on amberBg | 4.51 | 8.05 |
| red on redBg / on card | 5.30 / 6.47 | 5.53 / 6.07 |
| green / amber / red on headerChip | 5.02 / 5.02 / 6.47 | 10.37 / 10.82 / 6.53 |
| onBrand on blue / indigo (fills) | 5.17 / 6.29 | 5.17 / 6.29 |

Every pair ≥ 4.5 (WCAG AA for body text) in both appearances. Semantic colours stay distinguishable in dark: green/amber/red pills use bright foregrounds on deep tinted grounds of the same hue, and the SIM state colours (enabled green, carrier-paused amber, disabled red, low-balance red) ride the same tokens.

## 3. Sweep evidence

Raw-colour lines (`Color.*` constructors / hex literals) in UI code, before → after:

- `Ui.kt`: 23 → 3. The 3 remaining are not surface colours: the ripple **mask** in `pressable()` (a shape mask — RippleDrawable reads its alpha only) and two white ripple **washes over the brand gradient** buttons (on-brand, identical in both themes by design).
- `MainActivity.kt`: 12 → **0**. All twelve sites (header subtitle, input background, FAB glyph, nav-pill surface + selected text, header status chip, stopped pill, filter/log chips) now read tokens.
- `QrScanActivity.kt`: 3 → 3, **intentionally unchanged**: it is a camera overlay — white text on a translucent black scrim over the live preview, correct under any appearance.
- Brand drawables (launcher icon, splash) hold brand hex by design and are identical in both themes.

## 4. Battery

JVM battery over the pure logic, run the v5.4.x way (Gradle-compiled classes + JUnitCore, because the Gradle test executor dies on this box): **OK (45 tests)** — the full 38 of v5.4.1 re-run green (parser, codes, logic, battery-read), plus **7 new ThemeTest tests**: both palettes define every token (opaque where required, deliberate alphas only on onBrandMuted/ripple), brand tokens shared while surface/text tokens genuinely differ, `resolve()` honours explicit choices over the system flag and falls back to System on an unknown stored value, `apply()` sets the live palette, WCAG AA asserted for all 16 pairs in each palette, and contrast-maths sanity (black/white = 21, identity = 1, symmetry). Debug + release builds clean (`assembleDebug` + `assembleRelease`, lint vital passed). Persistence is code-level by construction: the choice is one SharedPreferences string written on tap and read at every start (the same pattern as the existing language choice); there is no second store to disagree with it.

## 5. Slot registration proof (production)

Via core `AppFiles::store()` as www-data (APK staged host → container by tar-pipe, SHA-256 verified at every hop: local = host = in-container = stored):

- Before: 5.4.1, sha `8ab5b9d1…`, uploaded 2026-11-20T16:56:27Z.
- After: **5.5.0**, sha `45a7ecf4…`, size 4,587,871, package `com.rektrs.sendqon`, signer `eba2c40d…`, uploaded **2026-11-20T19:17:31Z (2026-11-21 00:17:31 PKT)**.
- Offer matching (in-process `GatewayAppVersions::matches`): our signer → **true**; the real vendor cert `77f4e3df…` → **false** (empty offer).
- `required_at` = **2026-11-23T19:17:31Z (2026-11-24 00:17:31 PKT)** — registration +72 h exactly; `min_required_version` stays 5.0.0 until then.
- Signed download URL (the same `api.internal.android.app.download` link the update check hands out) fetched over HTTPS: **HTTP 200, 4,587,871 bytes, SHA-256 = `45a7ecf4…`** — byte-identical to the built APK.
- Device rows 1 and 2 untouched by the registration (id 2's `updated_at` moved only by its own live sync; it still reports 5.4.1 until it takes this update); staging files removed from container and host.

## 6. Honest limits

- **Rendered dark-mode proof is the owner's phone.** This VM's emulator is not reliable (RAM gate), so theming is proven at token/unit level + framework-theme wiring, not by screenshot. What he should check after updating: Settings → Appearance → **Dark** — Home (header pill, SIM cards, balance states), Activity + Logs (chips, dots), Settings (cards, switches, dialogs e.g. Unpair), then back to **System** and flip the phone's own dark mode to see it follow.
- The pairing screen does not re-render mid-typing on a system flip (existing behaviour: the pairing form is never yanked away on resume); the new palette applies at the next natural render or launch.
- Notifications, the splash and the launcher icon are brand surfaces and intentionally identical in both appearances.
