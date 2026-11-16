# Build Report — App rename: IQRS Connect / IQRS Workspace

Date: 2026-11-07 · Owner decision (same day) from the REKTRS metadata draft
(`~/workspace/goals/iqrs-school-mobile-app/files/IQRS_REKTRS_App_Metadata/`)

| App | Was | Now | Package (unchanged) | Version |
|---|---|---|---|---|
| Student & Parent | IQRS Family | **IQRS Connect** — "For Students & Parents" | `pk.edu.iqrs.family` | v2.7 / code 18 |
| Teacher & Staff | IQRS Admin | **IQRS Workspace** — "For Teachers & Administrators" | `pk.edu.iqrs.admin` | v2.8 / code 21 |

## Deliverables

- [IQRS-Connect-App-v2.7.apk](sandbox://workspace/your_files/iqrs-app/IQRS-Connect-App-v2.7.apk) — 1,454,514 B, sha256 `1e640d57dd767de457641e713452623b605c91f92638bec00997b599b5a5578b`
- [IQRS-Workspace-App-v2.8.apk](sandbox://workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.8.apk) — 1,397,170 B, sha256 `98128fa279ea2ecf7907fd9ed1da018e3a5331518fcfd60145ef092ed9491be0`

Both install over the existing apps (same package ids, same signing key, higher version codes).

## Every place the name / metadata changed

### Build identity — `config/`
- `config/family.properties`: `appLabel` IQRS Family → **IQRS Connect** (this value is what the manifest template substitutes into `android:label` — the tree has no `app_name` string; the label is generated from config), `versionCode` 17 → 18, `versionName` 2.6 → 2.7, `apkName` → `IQRS-Connect-App-v2.7.apk`.
- `config/admin.properties`: `appLabel` IQRS Admin → **IQRS Workspace**, `versionCode` 20 → 21, `versionName` 2.7 → 2.8, `apkName` → `IQRS-Workspace-App-v2.8.apk`.

### Strings — `src/res/values/strings.xml`
New canonical identity strings (one place for the apps to name themselves):
- `app_name_family` = "IQRS Connect"
- `app_tagline_family` = "For Students & Parents"
- `app_name_staff` = "IQRS Workspace"
- `app_tagline_staff` = "For Teachers & Administrators"
- `app_about_staff` = "Teachers aur management ke liye professional app: class management, live class attendance, assignments, examinations, approvals aur administrative operations." (the owner's staff description line, verbatim)

Changed strings:
- `welcome_family`: "Welcome to IQRS" → "Welcome to IQRS Connect" (family sign-in heading)
- `welcome_staff`: "Welcome to IQRS Staff" → "Welcome to IQRS Workspace" (staff sign-in heading)
- `share_app_message`: "%1$s — our school app. Visit %2$s to learn more." → "%1$s — IQRS Connect, our school app for students and parents. Visit %2$s to learn more." (the Family Share App message now names IQRS Connect)

### Code
- `ui/BaseLoginActivity.java`: new `taglineRes()` hook (default: none); when a variant supplies one, the tagline renders as a gold caption directly under the sign-in heading — the natural tagline spot on both login screens. Layout otherwise untouched.
- `ui/LoginActivity.java` (Connect): overrides `taglineRes()` → `app_tagline_family`.
- `ui/staff/StaffLoginActivity.java` (Workspace): overrides `taglineRes()` → `app_tagline_staff`.
- `ui/family/AboutActivity.java` (Connect, "About School"): a quiet footer line under the school's contact card — "IQRS Connect · For Students & Parents" — composed from the canonical name/tagline strings. The screen remains the school's About; the app line sits below the school's identity, always rendered (not network-dependent).
- `ui/staff/StaffProfileActivity.java` (Workspace): the profile's About dialog keeps the school name as its title and the motto first; its message now continues with "IQRS Workspace — For Teachers & Administrators" and the `app_about_staff` description line.

### Lint — `tools/banned_strings.sh`
Three new permanent checks so the retired names cannot creep back into any user-visible string:
`no old family app name` ('IQRS Family'), `no old admin app name` ('IQRS Admin'), `no old staff app name` ('IQRS Staff').

## Deliberately left unchanged (and why)

- **Package ids** `pk.edu.iqrs.family` / `pk.edu.iqrs.admin` — unchanged by design, so these builds update the installed apps in place. (The draft's proposed `com.rektrs.*` ids remain a store-stage decision, exactly as recorded in the programme notes.)
- **School-name surfaces** — Splash, the BrandBand on both Home and both sign-in screens, the Student Card (front and back), certificates: these carry the SCHOOL's identity (IQRA REHMANIA TUL ATFAL HIGH SCHOOL + motto + crest) and are not app-name surfaces. Untouched.
- **`staff_fee_share_text`** ("IQRS fee receipt …") — "IQRS" there is the school's brand on a fee receipt shared by staff, not the app's name. Untouched.
- **Role names** ("Super Admin", "Admin" in role checks), class names, file names, internal identifiers, code comments that say "the family app"/"the staff app" generically — internal only, never rendered.
- **The shared resource table**: both apps compile the same `strings.xml`, so each APK's resource table also carries the sibling app's name/tagline strings (exactly as before the rename, when e.g. the Family APK already contained the staff welcome string). What each app *shows* — its label, its sign-in, its About, its share text — is its own new name; verified per-surface above.

## Gates

- **JVM suite: OK (187 tests)** — unchanged count; no test pinned the old names or version strings, so nothing needed re-pinning (the rename is pinned going forward by the new lint checks instead).
- **Banned-strings lint: PASSED** — all 15 checks, including the three new old-name checks.
- **Source grep**: zero occurrences of "IQRS Family" / "IQRS Admin" / "IQRS Staff" in `src/` or `config/`.
- **Metadata gate: PASSED for both APKs** — package, versionCode (18 / 21), versionName (2.7 / 2.8), minSdk 26, targetSdk 34, signature verifies; permissions unchanged: Connect = INTERNET only; Workspace = INTERNET + CAMERA.
- **Badging proof**: `application-label:'IQRS Connect'` (Connect APK), `application-label:'IQRS Workspace'` (Workspace APK).
- **Built-APK scan**: `aapt2 dump resources` on both APKs → **0** occurrences of the old names; new names/taglines present. A full binary scan of the extracted APKs (dex included) → **0** hits for the old names.
- **Cross-regression**: both variants built from the shared tree in one `./build.sh both` run; only pre-existing deprecation notes (MainActivity, StaffQrActivity), no new warnings.

## Not verified off-device

The tagline caption's exact on-screen fit under the 26sp heading and the About footer's placement are code-reviewed against the existing layout patterns but, as with every wave, the final look is confirmed on the owner's phone.
