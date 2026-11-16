# Build Report — Dialog Fix (Admin v2.3.2 / Family v2.2.1)

Polish-fix build, 2026-11-07. Two changes only; no features, no server changes.
Both apps ship because `styles.xml` / `strings.xml` are shared resources.

## Fix 1 — Sign-out dialog text invisible (blank white box)

**Symptom (on device, Admin v2.3.1):** the sign-out confirmation dialog rendered
as a blank white box — title "Sign out?" and body text invisible, only the
CANCEL / SIGN OUT buttons (accent colour) visible.

**Cause:** `AlertDialogTheme` (`src/res/values/styles.xml`, parent
`android:Theme.Material.Dialog.Alert`) overrode `windowBackground` to
`@color/surface` (white) but never pinned text colours, so title/message
colours resolved to near-white on the white surface on the device.

**Fix:** two items added to `AlertDialogTheme`; `windowBackground` and
`colorAccent` unchanged:

```xml
<item name="android:textColorPrimary">@color/ink</item>     <!-- #14181F -->
<item name="android:textColorSecondary">@color/ink_2</item> <!-- #4A5160 -->
```

These are the palette's standard ink colours for text on `@color/surface` —
the same values the code-side tokens use for card text (`Tokens.INK` /
`Tokens.INK_2` in `ui/theme/Tokens.java`, verified identical hex).
Verified inside the shipped APK (`aapt2 dump resources`): `style/AlertDialogTheme`
carries all four items (textColorPrimary=@color/ink, textColorSecondary=@color/ink_2,
windowBackground=@color/surface, colorAccent=@color/navy).

**Dialog call sites covered (every `AlertDialog.Builder(..., R.style.AlertDialogTheme)` in the tree — 4 sites, all now readable):**

| # | File | Dialog |
|---|------|--------|
| 1 | `ui/staff/StaffProfileActivity.java` — `confirmSignOut()` | Sign out? (the reported defect) |
| 2 | `ui/staff/StaffProfileActivity.java` — `showAbout()` | School name / motto, Done button |
| 3 | `ui/family/ProfileScreen.java` — `confirmSignOut()` | Sign out? |
| 4 | `ui/family/MoreScreen.java` — `confirmSignOut()` | Sign out? |

## Fix 2 — Dead strings removed

Swept all 343 strings in `src/res/values/strings.xml`: each name was grepped
across the whole tree (`R.string.<name>`, `@string/<name>`, and bare-word) —
no `getIdentifier` dynamic lookups exist, so zero references is conclusive.
10 strings removed (343 → 333), each with literally zero references anywhere
outside `strings.xml`:

`staff_shell_note` (the known dead M3-shell placeholder), `nav_back`,
`profile_admission_no`, `staff_home_title`, `staff_marked_count`,
`staff_loading`, `staff_att_saved_phone`, `staff_qr_not_found`,
`staff_hw_homework_date`, `staff_fee_pick_line`.

Verified absent from both built APKs' compiled resources; `sign_out_confirm_title`
still present in both.

## Gates

| Gate | Result |
|------|--------|
| JVM suite (`tools/run_tests.sh`) | **OK (90 tests)** — full baseline, all pass |
| Banned-strings lint (`tools/banned_strings.sh`) | **PASSED** (12/12 checks) |
| Metadata — Admin | **PASSED** — pk.edu.iqrs.admin, code 16, name 2.3.2, minSdk 26, targetSdk 34, INTERNET + CAMERA, signature verifies |
| Metadata — Family | **PASSED** — pk.edu.iqrs.family, code 13, name 2.2.1, minSdk 26, targetSdk 34, INTERNET, signature verifies |

## Deliverables

| APK | Version | Size | SHA-256 |
|-----|---------|------|---------|
| `IQRS-Admin-App-v2.3.2.apk` | 2.3.2 / code 16 | 1,311,009 bytes | `7468f7fdeb11f8e11ca5d8b7104068affa01b7582e550e44b699246025b555c5` |
| `IQRS-Family-App-v2.2.1.apk` | 2.2.1 / code 13 | 1,052,961 bytes | `cb2c09c4ea427fb58c524677a7659e87d55eb121d83a80587ac9a633a46b1344` |

Built with the tree's Gradle-free pipeline (`build.sh both`: aapt2 → javac → d8 →
zipalign → apksigner) and the existing debug keystore. Installs over Admin v2.3.1
and Family v2.2 respectively. Remaining gate is on-device only: open Profile →
Sign out on the Admin app and confirm the dialog title and body are readable.
