# QR Scanner Speed Fix — 2026-11-15

Owner order (IQRS updates chat, 2026-11-15 ~08:47 PKT): *"QR Scanner ko bhi
mazeed mazboot aur fast karo, ye boht slow kam karta hai. Ye aisa ho ke halka
sa code nazar aye, us ki attendance mark kar ke next ho jaye — koi button
click na karna paray."* Spec: a code barely entering the frame is detected,
attendance marks automatically, scanner moves straight to the next student,
**zero button taps in the scan loop**.

Scope honoured: app-side only; QR/attendance-scan files only (a parallel B6
print-fix lane was editing fees/payroll/docs in the same tree — none of those
files were touched). No server change was needed, so none was made.
Production untouched. The B7-1 capabilities gate for Scan was **not** done
(separate pending owner decision).

---

## 1. Diagnosis — why it felt slow (measured from the code)

### The confirmation waited on the network — the biggest cost
`StaffQrActivity.handleCode()` (old) enqueued the write and showed the green
name card **only inside `sender.awaitDelivery(...)`** — i.e. after a full
server roundtrip. On a slow connection the teacher scanned and saw nothing;
offline, the first feedback of any kind was a "Saved on this phone" card
after a hard-coded **6,000 ms** delay (old `StaffQrActivity.java`, the
`postDelayed(..., 6000)` block). No beep and no haptic existed anywhere, so
the teacher had to watch the screen to know a scan had landed.

### The decoder paid worst-case prices on ordinary frames
`src/pk/edu/iqrs/app/qr/QrDecoder.java` (old):
- `DecodeHintType.TRY_HARDER = TRUE` on **every** decode attempt (old line 28).
- On an upright failure it **rotated the full 1280×720 brightness plane a
  quarter turn each way and decoded again** — up to 3 full TRY_HARDER decodes
  plus two ~921,600-element buffer copies per frame. The rotations were pure
  waste: ZXing's QR detector locates the three finder patterns in any
  orientation, so a turned code decodes without turning the buffer (proven by
  `QrDecoderTest.rotatedCodeDecodesWithoutTurningTheBuffer`).
- Full-frame only: no centre-crop, no downscale (noise reduction for
  dim/distant cards), no inverted pass.
- `ImageReader` was created with **maxImages = 2** and all work ran on the
  single camera thread, so while one expensive frame was being decoded,
  incoming frames had nowhere to go — the effective analysis rate collapsed
  exactly when conditions were hard (noisy frames are where TRY_HARDER and
  the rotations actually burn time).

### Supporting gaps
- Names came **only** from the server response. `AdminDb.qr_marks` remembered
  a name only *after* a successful delivery; the cached class rosters
  (`CacheDb`, endpoint `staffapi/students`) were never consulted.
- A per-scan SQLite read (`qrMarkedName`) ran on the main thread per scan.
- No session summary: no count, no recent names — the teacher could not tell
  how many students were marked without leaving the scanner.
- The camera request set continuous-picture AF (good) but no barcode scene
  mode and no FPS range selection where the hardware offers them.
- Manual entry worked but ignored the keyboard's Go/Enter action.

### Honest benchmark note
On this VM's JVM with clean synthetic 720p frames, per-frame decode CPU was
**not** the dominant cost: old ≈ 12 ms/blank frame vs new ≈ 9 ms; small
centred code old ≈ 2 ms vs new ≈ 1 ms. Uniform-grey frames are the cheapest
possible failure case for both decoders, so these numbers understate the
real-world gap (TRY_HARDER + rotations engage on real noisy frames), but
they are what was measured — no larger claim is made. The decisive speed
win is removing the network roundtrip from the confirmation path; the
decoder work removes the worst-case multipliers and adds robustness
passes for small/dim/inverted codes.

---

## 2. What changed, per file

| File | Change |
|---|---|
| `src/pk/edu/iqrs/app/api/QrScanSession.java` | **New.** Pure scan-session logic: per-code decision (MARK / ALREADY / IGNORE), 3 s same-card hold, name book (daybook seed + roster index + learned names), session count + last-3 names. JVM-unit-tested. |
| `src/pk/edu/iqrs/app/qr/QrDecoder.java` | **Rewritten.** `QRCodeReader` (was `MultiFormatReader`); pass order per frame: centre-crop (middle ⅔ each way, zero-copy crop of the same plane) → full frame → half-scale full frame (noise wash, ¼ pixels) → inverted full frame → TRY_HARDER full frame only every 8th consecutive failing frame. No TRY_HARDER in the hot path, no buffer rotations. Half-scale buffer reused. |
| `src/pk/edu/iqrs/app/ui/staff/StaffQrActivity.java` | **Reworked scan loop** (see §3). Instant local confirmation; delivery callback only learns the real name and patches the strip/daybook; 6 s "waiting" card removed (superseded by the strip's live "waiting to send" count via `onCountsChanged`); session summary strip (count + latest names); explicit **Done** button (outside the loop); beep + haptic feedback; roster/daybook preload on the io executor; manual entry also fires on keyboard Go/Enter and keeps focus for the next entry; `ImageReader` maxImages 2 → 3; barcode scene mode + best ≥30 fps AE range set where offered; same-card decoder-level hold so one held-up card never re-posts. |
| `src/pk/edu/iqrs/app/data/AdminDb.java` | Additive: `qrMarkedCodes(day)` returns the whole QR daybook for the day (code → name) for session seeding. |
| `src/pk/edu/iqrs/app/data/CacheDb.java` | Additive: `payloadsForEndpoint(endpoint)` — read-only enumeration used to preload names from already-cached class rosters. |
| `src/res/values/strings.xml` | +4 strings: `staff_qr_done`, `staff_qr_session`, `staff_qr_last`, `staff_qr_waiting_send` (worded inside the banned-strings rules — no "sync/queue/offline" jargon). |
| `src/AndroidManifest.xml.tpl` | +`android.permission.VIBRATE` (normal, install-time permission) for the scan haptic. |
| `tools/metadata_check.sh` | Allowed-permission set +VIBRATE with a dated amendment note in the file header, following the gate's own 2026-11-08 amendment precedent (owner-ordered feature). |
| `tools/run_tests.sh` | Compile set +`src/.../qr`; test list +`QrScanSessionTest`, +`QrDecoderTest`. |
| `tests/pk/edu/iqrs/app/api/QrScanSessionTest.java` | **New, 13 tests.** |
| `tests/pk/edu/iqrs/app/qr/QrDecoderTest.java` | **New, 6 tests** (synthetic frames: upright, rotated 90°/180°, small 3 px-module code centred in 720p, off-centre, inverted, blank/garbage). |

No dependency was added: the faster stack is the **already-vendored
ZXing core 3.5.3**, used properly (QR-only reader, hint discipline,
crop/downscale passes). A heavier ML-based decoder was rejected: it would
add megabytes and a new supply chain for a problem that measured as
flow latency + worst-case hints, not raw decode throughput.

## 3. Flow, before → after

**Before:** frame → (up to 3 TRY_HARDER decodes + 2 rotations) → code →
enqueue → *wait for server* → green card with name (or a "saved on this
phone" card at +6 s offline) → card auto-dismisses 1.2 s → repeat. Re-scan
of the same card re-decoded and re-posted an "already" card every ~400 ms
throttle cycle.

**After:** frame → cheap passes (centre crop first) → code → session
decision in memory →
- **new code:** write saved to the existing offline outbox *immediately*
  (idempotent client txn id, exactly as before), green card with the
  student's name from the local roster/daybook (or the code itself when
  not yet known) + beep + buzz, summary strip +1 — all in the same
  frame cycle, **network not involved**; when the service answers, its
  name silently replaces the code on the strip and in the daybook;
- **same card still up:** silence (3 s per-code hold, at both decoder
  and session level) — no re-beep, no re-post, no error;
- **card shown again later:** amber "Already marked present" card +
  lower tone, nothing written;
- refusals from the service still surface as the plain-words attention
  card and the write is held on the Waiting screen (unchanged);
- the only buttons on the screen are Torch, the manual-entry Mark
  (outside the camera loop, also fires on keyboard Go), and Done.

## 4. Proof

- **Tests:** `./tools/run_tests.sh` → **OK (371 tests)** = 352 baseline +
  13 `QrScanSessionTest` + 6 `QrDecoderTest`, 0 failures.
- **Builds:** `./build.sh both` → both variants built clean.
  - Workspace `IQRS-Workspace-App-v2.18-prod.apk`: 1,729,392 → **1,733,488 B
    (+4,096 B)**.
  - Connect `IQRS-Connect-App-v2.14-prod.apk`: 1,643,376 → **1,643,376 B
    (±0)** — the scanner ships only in the Workspace variant.
- **Gates:** `tools/banned_strings.sh` PASSED; `tools/metadata_check.sh`
  PASSED for both APKs (VIBRATE present and allowed per the amendment).
- **JVM decoder micro-benchmark** (this VM, 1.5 shared vCPU — relative
  evidence only, **not** device timing): blank 720p frame, all passes
  failing: old ≈ 12 ms → new ≈ 9 ms; small centred code: old ≈ 2 ms →
  new ≈ 1 ms. New-decoder worst case per frame is bounded by 4 cheap
  passes (~9 ms here), so at a 30 fps camera rate the analysis thread
  is idle most of the time even on this weak CPU.
- **Latency budget of the new loop (code-level):** per scan, the main
  thread does one in-memory session decision + one outbox enqueue
  (SQLite insert) + one card render; name lookup is a HashMap hit after
  the background preload. Removed from the loop entirely: the server
  roundtrip before confirmation (was: unbounded, 6 s fallback), the
  per-scan main-thread DB read, TRY_HARDER on every frame, and both
  full-plane rotations.

## 5. What remains device-verification (owner's phone pass)

These cannot be proven on this VM and are **not** claimed:
1. Real-world detection speed/robustness — small, distant, angled, dim
   and glossy-laminated cards under school lighting; time from card-up
   to beep across a full class line.
2. Beep audibility and haptic feel on the actual device; torch behaviour
   in a dark classroom.
3. Focus behaviour on the school's typical low/mid-range phones
   (continuous-picture AF + barcode scene mode are set where offered,
   but fixed-focus devices will rely on the downscale pass).
4. The §6.4-style device pass for the QR screen with the new build,
   alongside the already-pending first production sign-in — the natural
   moment is when the owner installs this build (it also carries the
   audit's other pending items' context; release signing B1 is unchanged
   and still owner-held).
