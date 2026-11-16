# BUILD REPORT — Wave 2 close-out fixes (Connect v2.13 / Workspace v2.17)

Built 2026-11-08 (PKT) from the shared tree `~/workspace/iqrs-app-v2/`.
These two builds close the wiring lane's flags 2 and 3
(BUILD-REPORT-wave2-wiring.md) under the coordinator's 2026-11-08
decision. Both builds staging-pointing (ApiConfig unchanged), same
signer as every previous build, production never touched.

| Artefact | versionCode | Size | sha256 |
|---|---|---|---|
| IQRS-Connect-App-v2.13.apk | 24 | 1,643,376 B | 5d091c8e850b0e4f1aa930d66e16228148f64159960d037cc8b40d040f19eb0a |
| IQRS-Workspace-App-v2.17.apk | 30 | 1,729,392 B | 6392853453cde7f57791933b53de0815350f4a114908b47b4032c2d44d51eb58 |

Signer (all four of v2.12/v2.13/v2.16/v2.17): SHA-256
`f7874c3f69e4ee1cfbf54ef3616b2dde920423baa16f70d25724771f3bda462e` —
identical. Prior artefacts untouched, re-hashed after the builds:
v2.12 `a499bd03…`, v2.16 `d3fd65b3…` (unchanged).

**Gates (final tree + both shipped APKs):** unit suite **352 tests
OK** (346 prior + 6 new in `Wave2Fix2Test`); **SRC-ROUTE-LIVE
210/210 routes live** (manifest grown by probe only: 209 → 210, see
§4); **checker harness 0 failed groups** on the tree and on both
shipped APKs (run twice, identical); banned-strings clean; metadata
gate PASSED on both APKs under the amended allowed set (§1).

---

## 1. Step 0 — the harness amendment (coordinator decision, 2026-11-08)

`tools/metadata_check.sh` is the single place the permission allowed
set lives (check_apk.sh delegates to it; no other gate file pins the
set — verified by sweep). Its header now carries the dated amendment
note and its case allows exactly four permissions:

> AMENDMENT (2026-11-08, coordinator decision): the allowed set grows
> from {INTERNET, CAMERA} to {INTERNET, CAMERA, POST_NOTIFICATIONS,
> USE_BIOMETRIC}. Both additions serve owner-approved riders
> (D-W2-5a) and both are runtime-consented on the device:
> POST_NOTIFICATIONS — without it the on-device reminders (R2) can
> never post on Android 13+, where the platform refuses an app that
> never declared it; USE_BIOMETRIC — the only blocker for the
> biometric half of the app-lock rider (R3); the PIN half shipped
> without it in Wave 2 (wiring report, flag 3). Nothing else about
> the gate changes.

### Manifest permission delta (badging, before → after)

| App | Before | After |
|---|---|---|
| Connect | INTERNET | INTERNET, **POST_NOTIFICATIONS**, **USE_BIOMETRIC** |
| Workspace | INTERNET, CAMERA | INTERNET, CAMERA, **POST_NOTIFICATIONS**, **USE_BIOMETRIC** |

Exactly +2 per app, nothing removed, nothing else added — declared
in `src/AndroidManifest.xml.tpl`, shared by both variants (CAMERA
stays Workspace-only, as before).

## 2. Connect v2.13 — the version notice, wired (flag 2 closed)

- `FamilyRepository.loadAppVersion` reads **familydocs/appVersion**
  (the Wave 2C-B family door; battery PASS=29 FAIL=0, coordinator-run)
  with the family session and parses the record's `connect` entry
  through the shared `VersionNotice` rules — the same record the
  staff app reads, scoped to this app.
- Home carries a `versionSlot` under the hero; `refresh()` — Home's
  established refresh cycle (first show + pull-to-refresh) — runs the
  read beside the other section loads. A failed read stays silent.
- The card is now a shared renderer, `ui/VersionNoticeCard`,
  extracted verbatim from the staff home's proven rendering (same
  strings, same per-version-per-day dismissal, same non-dismissible
  required state); StaffHomeActivity delegates to it, so both homes
  show the identical card.

**Live proof of the silence path (this lane, app's exact request
shape):** fixture parent session (users 7396) →
`POST familydocs/appVersion {}` answered
`{"status":1,"message":"Successfully.","record":{"configured":false,"connect":null,"checked_at":"2026-11-08 00:17:26"}}`
— captured verbatim as `fixtures/w2cb_app_version_family.json` and
pinned in tests: parse → not configured → decision NONE at code 24.
The family scoping is visible in the capture itself: no `workspace`
key exists in the record.

**True path (labelled crafted):** the versions table does not exist
yet (office decision F5), so no configured:true answer can be
captured live. The rendering decisions are pinned by
`fixtures/w2cb_CRAFTED_app_version_family.json` — a composition in
the battery-verified shape (latest 26 / floor 20 → UPDATE_AVAILABLE
at 24, NONE at 26; a floor-25 variant → UPDATE_REQUIRED at 24).
The live true-path proof remains owed until the office creates the
table, at which point any family read demonstrates it — the same
owed proof the 2C-B report records server-side.

## 3. Workspace v2.17 — regression side

The staff read (`staffapi/appVersions`) and its decision rules are
untouched; only the rendering moved into the shared card (same
code path, same dismissal prefs). The genuine configured:false
capture (`w2w_app_versions.json`) still pins silence in the suite.
Everything else in this build is the shared §5 work: the two
permissions, the notification ask, the biometric path — Workspace
gets all three identically.

## 4. SRC-ROUTE-LIVE — grown by probe only

After the code landed, `tools/contract_check.py` ran in its default
live mode: dummy-login and unauthenticated-401 checks pass, then
**210/210 route strings probed live on staging** —
`familydocs/appVersion` entered `route_manifest.json` from the
probe (answer 401 at the guard = the route exists), never
hand-edited. The harness's offline form re-verified 210/210.

## 5. The two permissions at work

- **Notifications ask** (`ui/NotificationPermission.askOnce`): from
  each app's home screen (family MainActivity, staff
  StaffHomeActivity), in the established check-then-ask shape the
  camera screens use — Android 13+ only, only when not already
  granted, **once per install** (remembered in the reminders'
  own prefs; a no is respected, and LocalNotifier still checks the
  system switch before every post).
- **Biometric unlock** (both apps share the lock): pure decisions in
  `api/BiometricRules` (the platform's success value is the only
  "usable" answer; the offer needs lock on + owner on + phone
  usable; the platform prompt exists from level 28). Storage is one
  preference in `data/AppLock` — it counts only while the lock is on
  and dies with it; the PIN and its salted digest are untouched. The
  platform glue (`ui/BiometricUnlock`) uses the framework prompt
  (present in the platform jar; no new library): strong-authenticator
  check on Android 11+, the negative button is "Use PIN", and any
  error or cancellation leaves the PIN standing. In
  `ui/AppLockActivity`: the settings' manage section gains the
  owner's switch (shown only on a phone that can authenticate), and
  the unlock screen offers the prompt at once when the owner turned
  it on, with a "Use fingerprint" button to call it again. The PIN
  path is unchanged and always available.
  One platform fact worth recording: the framework builder's
  negative-button call is `setNegativeButton(text, executor,
  listener)`, not the AndroidX `setNegativeButtonText` — found by
  the compiler, fixed in the glue.

## 6. The wiring checker's flag on this lane's new file — fixed

The checker's tree sweep flagged `ui/VersionNoticeCard.java` under
SRC-NOSPACER-IN-ROW (line 72): the trailing spacer's receiver was
the caller's `slot` parameter, whose orientation the guard cannot
resolve inside a method that also builds a row — the v2.12 defect
class's detection shape. The layout is restructured, the guard
untouched: card + trailing spacer now travel in their own local
`Ui.column` box added to the slot (visually identical; dismissal
still clears the slot). Guard re-run: **SRC-NOSPACER-IN-ROW PASS —
943 sites examined, 0 violations, 0 allowlist-excused**, and the
full harness is green on the final tree (above).

## 7. Honest remainders

1. The family notice's configured:true path is pinned by a labelled
   crafted fixture only; the live proof waits on the office creating
   the versions table (F5) — no table was created by this lane.
2. The biometric switch lives in the lock settings' manage section
   (reached after the current PIN): a person creating a PIN for the
   first time turns biometric on at their next settings visit. The
   prompt path is code-complete and shipped in both dexes
   (dex-verified), but it can only be exercised on a real device
   with an enrolled fingerprint or face — the device gate's work,
   like the notification ask's system dialog.
3. API-64 (permission slips / notice acknowledgement) is unchanged
   Wave 3 scope — not built, no route invented (wiring flag 1,
   accepted by the coordinator).
