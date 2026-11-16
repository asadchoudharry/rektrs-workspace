# BUILD REPORT — IQRS Admin App v2.6 (profile photos, fee-chip fix, motto fit)

**Deliverable:** `IQRS-Admin-App-v2.6.apk`
- Package `pk.edu.iqrs.admin`, versionName **2.6**, versionCode **19**
- Size **1,331,489 bytes**
- SHA-256 `d4066ab5d4a75db3253aec85eb51a79e20dc97ffd40a73985d0d40149bc2f43b`
- Permissions: exactly **INTERNET + CAMERA** (unchanged), minSdk 26, targetSdk 34, signature verifies
- Admin only. The Family app was not rebuilt or changed, and the v2.5 APK is untouched.

Server contracts are taken from `DEPLOY-NOTE-PHOTO-UPLOAD.md` §2 exactly:
`POST /api/staffapi/studentPhoto` (Super Admin / Admin sessions, multipart
`student_id` + `image`, returns the full student record) and
`POST /api/staffapi/myPhoto` (any staff session, multipart `image` only,
returns the `me` record). Both uploads are live writes — they never touch
the offline saved-writes sender.

## 1. Student photo in Edit profile

`StaffStudentEditActivity`'s identity card is now a photo section: the
student's current photo at 64dp through the existing `Avatar`/`PhotoLoader`
pipeline (initial disc when the school has no photo on file), with a
"Change photo" action under a divider. The screen's existing admin-only
gating is unchanged — the action exists only where the edit form itself
exists, and the endpoint enforces the same role rule server-side.

Flow: pick → prepare (background thread) → upload via the new
`StaffRepository.uploadStudentPhoto` → on success the returned student
record replaces the screen's record and the avatar swaps to the new photo
immediately; the detail cache is warmed with the same response (the same
pattern `updateStudent` uses), and the screen returns `RESULT_OK` so the
student detail behind it reloads and shows the new photo too. Form fields
are never re-rendered mid-edit, so anything already typed survives a photo
change. While a photo is being prepared or sent, a spinner + "Sending
photo…" row shows and both the photo action and Save are disabled (Save
also refuses to start while a photo is in flight, and vice versa).

Outcomes: a refusal (`{status:0}`) shows the server's own message in the
form's error line, exactly like the profile save does; a connection
failure shows "Changing a photo needs a connection to the school. Please
try again."; an unreadable pick shows "That photo could not be read.
Please choose another one."; an expired session returns to sign-in.

## 2. Own photo in staff Profile

`StaffProfileActivity`'s identity card carries the same photo section.
"Change photo" runs the same picker/prepare flow against
`StaffRepository.uploadMyPhoto`. On success the returned `me` record
re-renders the profile details and avatar, and its `image` is written
back into the stored session (`SessionStore.saveStaff` with a rebuilt
`StaffSession`), so the photo follows the person: Staff Home's identity
card now also re-reads the stored session in `onResume` and refreshes
its avatar, so the new photo shows there without an app restart.
Refusals are shown as-is in a toast; connection failure and unreadable
picks use the same copy as the student flow.

## 3. Picker approach — why no permission is needed

The picker is `Intent.ACTION_OPEN_DOCUMENT` with `CATEGORY_OPENABLE`
and type `image/*`, launched with `startActivityForResult`. The system
chooser grants the app a one-shot read grant for exactly the image the
person picks, so no storage/media permission is requested, declared or
needed — the manifest still declares only INTERNET and CAMERA (metadata
gate confirms). The grant is consumed immediately in `onActivityResult`.

Preparation (`pk.edu.iqrs.app.ui.PhotoUploads`, sizing math in
`pk.edu.iqrs.app.api.PhotoScale`): bounds are probed first, the image is
decoded with the largest power-of-two sample that stays at or above the
cap, its stored EXIF rotation is applied, the long edge is scaled to
**1024 px** with proportions kept, and the result is flattened onto
white and re-encoded as **JPEG quality 85**, sent as `photo.jpg`
(`image/jpeg`). A full phone-camera frame lands far under the service's
5 MB / JPG-PNG limits, and the server's own `getimagesize` check sees a
real JPEG regardless of the picked file's original format.

## 4. Fee-collect chip fix

The shared student row (`StaffUi.studentRow`) always appended today's
attendance chip; the Collect fees search results use that row, so every
candidate wore a "Not marked" chip about a register that isn't on that
screen. The row builder now takes the chip decision from the new pure
rule `RosterRowRules.showsAttendanceChip(Flow)`: the fee flow passes
`Flow.FEES` → **no chip**; the default (roster) path and every other
caller keep the chip exactly as before. The attendance register
(`StaffMarkActivity`) has its own row rendering and is untouched.

## 5. Brand band motto fit

The band set the motto from the letter-spaced string resource at a fixed
9.5sp with 0.14em tracking; on narrow phones the spaced letterforms
overflowed the text column and the line broke mid-word
("EXCELLENC / E."). Changes in `BrandBand` (shared by the staff Home and
the sign-in screens):

- The band now uses a plain motto string (`motto_band`:
  "KNOWLEDGE. FAITH. EXCELLENCE.") with the tracking applied as real
  letterspacing — the same visual rhythm without baked-in spaces the
  line breaker could split on. The spaced `motto` resource is untouched
  (splash and About still use it as before).
- The motto view is single-line, so the line can never break.
- After the first layout, the pure decision class `MottoFit` measures
  the real text with the view's own typeface against the real column
  width and sets the largest size that fits on one line — full size
  where it fits, proportionally smaller on narrow phones, trading
  letterspacing only at a 6.5sp floor. The Android measurer counts a
  full spacing step after every character, erring on the safe side.
  The school name lines and the band layout are unchanged.

## 6. Pure logic added (all in the `api` package, Gate-1 pinned)

- `MultipartBody` — byte-exact multipart construction: `student_id`
  text part then the `image` file part for studentPhoto; the `image`
  part alone for myPhoto (no id of any kind travels); correct part
  headers, content type and closing boundary; per-request random
  boundary in production use.
- `PhotoScale` — target-size math (long-edge cap, proportions kept,
  degenerate input passed through) and the decode sample size.
- `RosterRowRules` — the chip visibility rule of section 4.
- `MottoFit` — the fitting decision of section 5, including
  convergence under a non-linear measurer and degenerate-input
  fallbacks.

Transport: `ApiClient.postMultipart` mirrors the JSON transport's
headers and status classification, with a fixed content length and a
60-second read timeout for uploads.

## 7. Gates

- **JVM tests: 138 / 138 pass** (`tools/run_tests.sh`) — the 117-test
  baseline plus 21 new: `MultipartBodyTest` (5), `PhotoScaleTest` (7),
  `RosterRowRulesTest` (3), `MottoFitTest` (6). `tools/run_tests.sh`
  now lists the four new classes.
- **Banned-strings lint: PASSED** (`tools/banned_strings.sh`).
- **Metadata gate: PASSED** (`tools/metadata_check.sh … pk.edu.iqrs.admin 2.6`):
  package, versionCode 19, versionName 2.6, minSdk 26, targetSdk 34,
  permissions INTERNET + CAMERA only, signature verifies.
- Content spot-checks on the shipped APK: the compiled resources carry
  `motto_band` and the new photo strings; the dex carries both new
  endpoint paths (`staffapi/studentPhoto`, `staffapi/myPhoto`).

## 8. Not verifiable off-device (stated plainly)

- The picker, EXIF rotation, decode and upload run only on a real
  device against the staging service; off-device they are covered by
  the pinned pure logic (wire shape, sizing, fitting) and by the
  server lane's own staging verification of the two endpoints — not by
  an end-to-end run of this build.
- The motto fit is computed from the laid-out column width and the
  real font at runtime; its decision logic is unit-tested with a
  stand-in measurer, but the final on-screen size on a specific phone
  can only be confirmed on that phone.
- PhotoLoader's disk cache is keyed by photo URL and every upload
  returns a fresh server-generated filename, so a replaced photo can
  never be masked by the old one's cache entry; the previous file is
  deleted server-side by the endpoint, per the deploy note.
