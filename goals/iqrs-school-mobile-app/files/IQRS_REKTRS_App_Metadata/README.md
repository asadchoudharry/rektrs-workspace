# IQRS Connect + IQRS Workspace - development and Play Store metadata

Prepared on 2026-11-07. All metadata is a **draft** for two separate releases, not proof of implementation or publication. This bundle does not modify GitHub, the school backend, or Google Play Console.

## App identity

| App | Access roles | Proposed Android application ID | Flutter flavor |
| --- | --- | --- | --- |
| IQRS Connect | Student, Parent | `com.rektrs.iqrs.connect` | `connect` |
| IQRS Workspace | Teacher, Admin | `com.rektrs.iqrs.workspace` | `workspace` |

Publisher/developer: **REKTRS PRIVATE LIMITED**. Verified public legal/contact details are in `developer.json`. School: IQRS (`https://iqrs.edu.pk`). School ownership and IP license are NOT inferred from developer identity.

## Repository status (inspected main on 2026-11-07)

Repository `asadchoudharry/Smart-School-Android` currently has `pubspec.yaml` at version `0.2.0+2` with `webview_flutter: ^4.13.0`. Its GitHub Actions workflow generates Android scaffolding dynamically with `--org=pk.edu.iqrs`. There are no separate Connect or Workspace release configurations in the inspected tree. Neither native app, API login, nor publishing has been verified.

## How to apply to a future verified Flutter release

1. Generate and commit Android scaffolding. Configure distinct Gradle product flavors (`connect`, `workspace`), matching launcher names and the proposed package IDs. Confirm the IDs do not conflict with any previously published IQRS app.
2. Wire each flavor to an appropriate native entry screen and enforce role access on the backend, not just in mobile navigation. Keep production school data outside public repo and test fixtures.
3. Optionally adapt `Flutter_brand_metadata.dart` for the on-screen About/Support developer credit. Set `--dart-define=IQRS_APP=connect` or `--dart-define=IQRS_APP=staff` as appropriate.
4. Import the relevant `fastlane/metadata/<flavor>/en-US` **drafts only after verifying every described feature in the signed build**.
5. Build, sign and test two independent `.aab` files. Keep signing keys and runtime secrets private.

## Release blockers (intentionally not invented)

- [ ] Both Android flavors and application IDs actually implemented
- [ ] Native features and real authenticated backend integration verified
- [ ] Separate app-specific public privacy policy URL(s) live and linked in app
- [ ] Actual SDK and data flow reviewed for Google Play Data safety disclosure
- [ ] Target-age declaration and Families policy reviewed for the student app
- [ ] Permission rationale, data retention, secure handling, deletion process checked
- [ ] Copyright/IP terms and school brand authorization confirmed
- [ ] Correct app icons, Play Store graphics, screenshots and content rating provided
- [ ] Organization Play Console details match existing legal developer record
- [ ] Owner approval granted before external code changes or store submission

## Official policy references

https://support.google.com/googleplay/android-developer/answer/9859152
https://support.google.com/googleplay/android-developer/answer/9859455
https://support.google.com/googleplay/android-developer/answer/10144311
https://support.google.com/googleplay/android-developer/answer/9893335
https://developer.android.com/build/configure-app-module

## Approved product naming and audience positioning

| App name | Audience tagline | Planned core workflows |
| --- | --- | --- |
| IQRS Connect | For Students & Parents | Attendance, learning, homework, results, fees and school communication |
| IQRS Workspace | For Teachers & Administrators | Class management, live class attendance, assignments, examinations, approvals and administrative operations |

**Developer:** REKTRS PRIVATE LIMITED. The legal/contact metadata is kept in `developer.json`.
**Important:** Names and descriptions reflect the product definition, not verification that these features are already implemented or live. The Google Play short/full descriptions are drafts and must be reconciled against tested release capabilities before submission. The audience tagline is a marketing descriptor, not a separate Google Play listing field.

**Compatibility note:** The earlier proposed `com.rektrs.iqrs.staff` has been superseded in this draft by `com.rektrs.iqrs.workspace`. Confirm the actual Play Console package registration and previous signing identity before applying the new identifier.
