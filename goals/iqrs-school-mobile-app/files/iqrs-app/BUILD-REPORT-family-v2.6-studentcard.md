# Family App v2.6 — Student Card (BUILD REPORT)

**Date:** 2026-11-07 · **Tree:** `~/workspace/iqrs-app-v2/` · **Design:** Calm Campus, fintech-card direction (owner: "Jesy new banking or fintech apps main cards hoty hain")

## Deliverables

| App | File | versionCode | versionName | Size | SHA-256 |
|---|---|---|---|---|---|
| Family | `IQRS-Family-App-v2.6.apk` | 17 | 2.6 | 1,454,514 B | `e12815039f4b885d01a7cc00d58233063ac104cc71cee33e7f553d568e59ee81` |
| Admin | `IQRS-Admin-App-v2.7.apk` | 20 | 2.7 | 1,393,074 B | `1de5ee6b60f025fb02dae26eb43e444dba7f7b137a01aa65b341ef1e67e4fedb` |

Admin is bumped (19 → 20 / v2.7) because the shared card component landed on its student detail screen too — see below.

## What was built

A native **Student Card** in true bank-card proportions (CR80 ratio 85.6 × 54, enforced in the view's measure pass), styled after modern banking/fintech cards (Revolut / Wise / NayaPay class) translated into the school's Calm Campus identity. One shared component — `ui/components/StudentCardView.java` — renders it in both apps.

**Front (the clean, premium face)**
- Deep navy TL→BR gradient (#081731 → #10204D) with a subtle diagonal sheen layer and a fine gold edge stroke; rounded 18dp, elevated like a wallet card.
- Crest **only** as the fixed circular gold-ring badge (38dp), top-left like an issuer mark; school name in Georgia serif beside it, letterspaced gold motto under it; "STUDENT CARD" in letterspaced gold at the top-right with the session under it.
- A small drawn chip motif (gold contacts on navy, drawn in code — a design motif only: no bank logos, no fake payment marks).
- Cardholder row: the student's photo as a small gold-ring circle (initials disc until a photo exists — the pipeline is the existing Avatar/PhotoLoader one), name set in serif capitals like a cardholder name, class–section in gold beneath, roll number appended when the record carries one.
- The admission number at the bottom like a card number: letterspaced, tabular figures. **Deliberate choice:** spacing is typographic only — no characters are inserted into the number, so what a parent reads off the card is byte-exactly the recorded admission number (the barcode encodes the same string).

**Back (the service side)**
- Darker navy (#0B1730 → #081731), a near-black strip band across the top with a gold rule under it (magnetic-strip-inspired).
- A real **QR code** in a white box encoding `IQRS-<student_id>` (e.g. `IQRS-2397`) — the exact payload the Admin app already scans for attendance — captioned with the payload.
- A real **Code 128 barcode** in a white box encoding the admission number exactly (e.g. `IQ-STU2134`), captioned with the number.
- Guardian name + relation (guardian field first; father, then mother, as the record's fallback). **The guardian's personal phone number is never on the card** — it is not even part of the card's data model.
- School address and school phone lines (only when the record carries them), and the line "If found, please return this card to the school office."
- The unverified "office hours" line from the web mockup was **not** carried over.

**Interaction**
- Tap the card (or the "See the back / See the front" toggle under it) and it turns over with a two-stage 3D flip.
- **Home:** a wallet-style preview strip right under the hero — navy gradient, photo, name, class, admission number, and a working miniature of the QR — tapping it opens the full card.
- **Profile:** a "Student Card" row at the top of the records card.
- Bottom nav unchanged.

## Data — no new endpoints, works with no signal

- `api/StudentCardMapper.java` builds `model/StudentCardData.java` from records the app already holds: the fetched **profile** (richest: roll, guardian, session), the **sign-in child record** (always on the device — this is what renders instantly and with no signal), and the staff app's **student detail**. School name/address/phone/session come from the already-fetched school details.
- `ui/family/StudentCardScreen.java` renders from the child record the moment it opens, then quietly enriches when the profile/school responses land (the repository is cache-first, so the enrichments themselves work from cache too). A soft failure leaves the held-record card on screen.
- **Child switching:** MainActivity already rebuilds every screen on a switch, so the card always belongs to the child on screen — pinned by a test (two children → two different cards and payloads).
- Codes are encoded on the device at render time; nothing about the card needs the network.

## Encoder approach + evidence

- The tree's vendored **`libs/zxing-core-3.5.3.jar`** was checked first: it contains `com/google/zxing/qrcode/QRCodeWriter` and `com/google/zxing/oned/Code128Writer` — the writers were already vendored, so **nothing was hand-rolled and nothing new was downloaded**.
- `api/CardCodes.java` wraps the two writers (QR at error-correction level M, margin 1; Code 128 with side quiet zones) and returns plain boolean matrices, keeping the encoders JVM-testable.
- **Proof, not just presence:** the unit tests decode the produced matrices back with ZXing's own `QRCodeReader` and `Code128Reader` and assert the exact payload strings return. The Family APK's dex was also inspected: `QRCodeWriter`, `Code128Writer`, `StudentCardView` and `StudentCardScreen` are all present.
- Build change (one place): `build.sh` now puts the vendored jar on the **Family** branch's compile classpath and dex inputs too (previously Admin-only). The Family source set still excludes the staff scanning package — Family carries the writers, not the scanner.

## Admin app — the card fits, so it shipped there too

`StaffStudentActivity` (student detail) now shows the same `StudentCardView` under a "Student Card" label, fed by `StudentCardMapper.fromStaffDetail(...)` from the detail record the screen already fetched: staff can show a student's card at the gate and turn it over for the codes the Admin app already scans. The staff record carries no school address/phone, so those two back lines simply don't render there (the view only prints facts the record carries). Because Admin changed, it ships as **v2.7 / code 20** with its own APK above.

## Gates

- **JVM suite: 187/187 green** (v2.5 baseline 175 + 12 new in `tests/pk/edu/iqrs/app/api/StudentCardTest.java`: profile→card field mapping, QR/barcode payload strings, guardian fallback chain, session fallback, child-record card with no fetch, child-switch re-render logic, staff-detail mapping, no-admission-number case, QR decode-back, Code 128 decode-back, empty-payload refusals). `tools/run_tests.sh` gained the vendored jar on its classpath for the encoder tests.
- **Banned-strings lint: PASSED** (language lockdown applies to the card; new strings are plain family wording).
- **Metadata gate: PASSED for both APKs** — Family: `pk.edu.iqrs.family`, code 17, name 2.6, minSdk 26, targetSdk 34, permissions = INTERNET only (unchanged); Admin: `pk.edu.iqrs.admin`, code 20, name 2.7, CAMERA + INTERNET (unchanged). Signature verification (inside the gate) passed for both.
- No live-system changes; no new endpoints; no manifest changes (the card screen is a pushed in-app screen, and the Admin addition lives inside the existing student detail activity).

## Deferred / notes

- **Print (CR80 PVC) stays with the web overhaul programme** — out of scope here, as briefed; the in-app card follows the same front/back content split as the print design.
- Card text sizes are fixed design sizes tuned for typical phone widths (360dp+); on very narrow screens long names/class lines ellipsize rather than wrap.
- As with the rest of the app, most cards will show initials until student photos exist in the school system — the photo endpoints shipped in Admin v2.6 are the way those get filled in, and the card picks them up automatically.
- Device check still pending (as with v2.4/v2.5): open the card on the phone, turn it over, and scan the back QR with the Admin app's QR attendance to watch it resolve the student.
