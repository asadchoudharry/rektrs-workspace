# Build Report — Urgent visual fixes: Home card slab + bottom-nav label wrap

Date: 2026-11-07 · Tree: `~/workspace/iqrs-app-v2/`
Builds: **IQRS Connect v2.8 (code 19)** · **IQRS Workspace v2.9 (code 22)**
Trigger: owner's device screenshots (AIKA SAJID, Four – Daffodils (Girls), IQ-STU2328) showing (1) the Home student-card preview as a giant empty navy slab and (2) "Attendance" wrapped mid-word ("Attendanc"/"e") in the bottom navigation.

## Defect 1 — the giant navy slab on Home

**Root cause.** The wallet preview (`StudentCardView.walletPreview`) was a plain horizontal row that contained `Ui.spacer(c, 2)` as its before-the-caret gap. `Ui.spacer` is the *vertical* spacer: its layout params are **MATCH_PARENT width** × fixed height. Inside the horizontal row that spacer claimed the row's entire width budget in LinearLayout's first measure pass, so the weight-1 text column was squeezed to **zero width**. A zero-width multi-line caption TextView then measures one-character-per-line — hundreds of dp tall — and that height became the row's height: a giant navy slab. The name/class text painted into a zero-width clip (invisible), and the trailing caret was pushed past the row's right edge — exactly the screenshot: only the photo and the mini-QR, floating mid-slab, no text, no caret.

**The fix (structural, not cosmetic).**
- The preview is now a dedicated `PreviewStrip` row whose `onMeasure` forces its height to exactly `CardPreviewLayout.measuredHeightPx()` — **92dp** — whatever the parent offers and whatever any child asks for (the same EXACTLY-spec pattern the full card uses for its CR80 aspect). No child content can ever inflate it again.
- The strip also carries explicit LayoutParams(MATCH_PARENT, 92dp) — it no longer relies on parent defaults.
- The in-row gap now uses the new `Ui.hspacer()` (explicit small width); `Ui.spacer`'s javadoc and the new helper carry the warning so the failure class is not reintroduced. The caption and label inside the strip are single-line + ellipsized, so even a starved column can no longer measure tall.
- Data-absent behaviour unchanged and verified in code: Home adds the strip only when `StudentCardMapper.fromChild(...)` returns data (null child ⇒ no strip at all — never an empty slab).

**Sweep for the same failure class.** Every `Ui.spacer(...)` call site in the tree was audited (231 sites): all others feed vertical columns (their correct use). The wallet preview was the **only** spacer inside a horizontal row. The full `StudentCardView` (Profile → card screen, and Workspace's student detail) is untouched and still renders at true CR80 proportions via its aspect-forcing measure pass — bounded by its padded column in both hosts.

## Defect 2 — "Attendance" wrapping mid-word in the bottom nav

**Root cause.** `BottomNav` gave each of the four items an equal quarter of the bar (width 0 + weight 1 ≈ 78dp at 360dp) and the label was an ordinary multi-line TextView. Icon (22dp) + gap (6dp) + the selected item's extra padding (28dp) left the 10.5sp bold label as little as ~22–50dp — narrower than the word "Attendance" — so the text system broke the single word across two lines.

**The fix (shared `BottomNav`, compiled into both apps).**
- Items now **size to their content** (WRAP_CONTENT width): 20dp icon, 5dp gap, single-line label, uniform 10dp horizontal padding in both states (the highlight no longer resizes the pill or shifts labels). Leftover bar width is spread between items by weighted gap views, so items keep their content size at any width.
- Labels are `setSingleLine(true)` by construction — wrapping is impossible.
- The label size is chosen by the new pure decision class `NavFit` (MottoFit pattern): at measure time the bar measures its labels with the real Jakarta Bold typeface (Paint) and takes the largest size in [9.5sp … 10.5sp] at which **every** item fits whole in the bar's real width. Below the design width the floor size is returned and a single-line label may clip — it can never break mid-word.

## Gates (all green)

- **JVM suite: 197/197** (187 baseline + 10 new in `VisualLayoutTest`):
  - Strip: `HEIGHT_DP == 92`, inside the sanctioned 84–104 band; `heightPx` exact at densities 1.0/2.0/3.0/2.625; measured height never exceeds the cap at any density.
  - Nav: available width at 360dp == 316dp; **all four labels fit at the floor size (9.5sp) even under the conservative 0.60 em/char stand-in measurer** (total 305.4dp ≤ 316dp); chosen size under conservative widths == 10.0sp and fits; under realistic widths (0.52 em/char) the designed 10.5sp start size is kept; impossible widths fall back to the floor, never below; degenerate inputs keep the start size.
- **Banned-strings lint: PASSED** (15/15).
- **Metadata gate: PASSED for both** — Connect: package `pk.edu.iqrs.family`, code 19, v2.8, label **'IQRS Connect'**, INTERNET only. Workspace: package `pk.edu.iqrs.admin`, code 22, v2.9, label **'IQRS Workspace'**, INTERNET + CAMERA. minSdk 26 / targetSdk 34 unchanged.
- **apksigner verify: PASSED for both** (v2 + v3 schemes).
- Shipped-dex inspection: the new `PreviewStrip`, `NavFit` and `CardPreviewLayout` classes are present in the Connect APK and `BottomNav` calls `NavFit.chooseSizeSp`; `walletPreview` now calls `Ui.hspacer` (its one remaining `Ui.spacer` call is inside the vertical texts column, the helper's correct use).

## Deliverables

- [IQRS-Connect-App-v2.8.apk](sandbox://workspace/your_files/iqrs-app/IQRS-Connect-App-v2.8.apk) — 1,454,514 B, sha256 `50bcea2ae105aca4330a6bae46a52e5aabcaad28d19d4b769cb7244ebb88c44d`
- [IQRS-Workspace-App-v2.9.apk](sandbox://workspace/your_files/iqrs-app/IQRS-Workspace-App-v2.9.apk) — 1,397,170 B, sha256 `b781df09df145f9af43db85568486e17371590e32a1f75a219095b1f6bb721f6`

No server changes, no new endpoints, no permission changes.

**Device check still owed (owner's phone):** Home shows the card as a slim wallet strip with photo, name, class and mini-QR; the bottom nav shows all four labels whole on one line ("Attendance" included) in both apps; tap the strip → the full card still opens at true card proportions and flips.
