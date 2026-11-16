# IQRS v2 — Visual Enrichment (Admin v2.4 / Family v2.3)

Presentation-only milestone, commissioned after Assad's verdict on
v2.3.1/v2.2 ("single colour" — too plain; proper cards and images that
show were asked for). Palette, functionality, endpoints, payloads,
outbox semantics and all UI wording are unchanged. Both apps rebuilt
with the Gradle-free pipeline and the usual debug keystore.

## Deliverables

| APK | Package | Version | Size | SHA-256 |
|---|---|---|---|---|
| `IQRS-Admin-App-v2.4.apk` | pk.edu.iqrs.admin | 2.4 (code 17) | 1,315,105 bytes | `838a100d4acb31f4890ff494e74e9a23ee6ecfe60646893de65ca81eb26b425d` |
| `IQRS-Family-App-v2.3.apk` | pk.edu.iqrs.family | 2.3 (code 14) | 1,061,153 bytes | `04f5f83fc8b52d556c5053aa561a7ef683f2b13a26431f98a9cbc28b0d37a289` |

## What changed, per screen

**Brand band (new shared component, `BrandBand`)** — deep navy
gradient (#081731 → #10204D), the crest in its fixed circular gold-ring
badge, the school name in a serif display face, the motto in
letterspaced bright gold (#D4AB42), and a 3dp gold rule along the
bottom edge.
- Sign-in (both apps, via the shared base): the band now heads the
  screen; the lone centred badge is gone.
- Staff Home and Family Home: the band runs full-bleed across the top.

**Staff Home** — the four school figures are now individual tinted
cards (Students pale blue #E9EFF5, Teachers pale gold, Staff soft
green, Classes ivory-deep), each with its own icon, a big navy numeral
and a soft shadow; attendance stays a full-width card beneath them.
Quick-action tiles and the Tools/Profile link rows now carry tinted
icon chips (one consistent tint per destination). The identity card
shows the staff member's photo when the school has one on file.

**Family Home** — the hero's child disc is photo-forward; the fees
section is now a gold-edged card whose bar draws the real Paid /
Discount / Balance split in three segments (green / gold / pale) with
all three figures labelled — a fee settled by discount now visibly
shows its discount segment instead of reading as simply paid. The
latest-notice card carries the same gold edge. Bento tiles (Results /
Transport / Library) each have their own tint.

**Cards & rows everywhere** — More-screen module tiles get per-module
tinted icon badges; Classes rows gain a navy monogram disc (class
initial, ivory on brand navy); notice-board cards all carry the gold
left edge (fresh notices in the brighter kit gold); the child switcher
is now one photo-forward card per child.

**Photos (`Avatar` + `PhotoLoader` + `ImageUrls`)** — student and
staff discs render the real photo whenever the record carries one:
Family Home hero, child switcher, Profile hero + children rows, More
header + children rows; staff roster/search/fees rows, the register,
student detail, Staff Home identity, Staff Profile (including the
photo from the profile record when it loads). Loading is off the UI
thread with a memory cache plus a disk cache in the app's cache
folder; bitmaps are decoded near avatar size and circle-masked. Any
failure — no path, unreachable host, or a non-image reply — silently
keeps the gold initial disc. The staff sign-in record's `image` field
is now carried into the session (same payload; the mapper change is
additive and pinned by a test).

**Empty states** — both apps now centre the school crest, greyscaled
and softened (`CrestBadge.ghost`), above the existing honest copy.
Copy unchanged everywhere.

**Dark mode ("night navy")** — the band is brand navy in both
palettes; stat tints use palette colours with night variants, and the
one tint that stays light at night (pale gold) keeps deep-navy text.

## Images: sources used

- Crest: the tree's existing transparent `crest.png` (284×284). A
  higher-resolution kit emblem exists (768×720,
  `iqrs-apk-shell/assets/assets/kit-emblem-*.png`) but it is the same
  artwork on an opaque black backing with an irregular beaded edge —
  it does not extract cleanly (black fringe), and at badge sizes
  (≤96dp) the shipped transparent asset is effectively full
  resolution, so it stays.
- Photos: only the school's own, from the records' `image` fields —
  never hotlinked stock. Verified against the live site: record paths
  are site-root-relative (`uploads/student_images/…`), resolving
  against the site origin (NOT under `/api/`, which 404s); a real file
  under `uploads/` (the school's own admin logo) serves as
  `image/png`. The QR result card keeps its initial disc because the
  QR record carries no image field.

## Honest flags

- **Photos will mostly show initials for now.** In every real record
  observed — production sign-ins, staging rosters and searches — the
  `image` field is empty: the school has not uploaded student/staff
  photos into the web system yet. The pipeline is complete and
  verified end-to-end (resolver unit tests + live-site URL pattern),
  so photos appear automatically wherever the school adds them. The
  one non-empty path ever seen came from a synthetic staging fixture
  and its file is not on the server; the site answers missing files
  with a blank non-image page, which the loader correctly rejects.
- The serif school name uses the platform serif face (the kit's
  Georgia-style headline look); no serif font file exists in the
  identity-kit materials to bundle.

## Gates

- JVM suite: **OK (104 tests)** — 90 baseline + 14 new
  (`ImageUrlsTest` ×7: empty/relative/leading-slash/absolute/
  protocol-relative/spaces/port; `FeeSplitTest` ×5 incl. the
  4300/700/0/3600 discount case; `StaffLoginImageTest` ×2).
- Banned-strings lint: **PASSED** (12/12).
- Metadata: **PASSED** both APKs (packages, versionCodes 17/14,
  minSdk 26, targetSdk 34, permissions INTERNET / INTERNET+CAMERA,
  signatures verify).
