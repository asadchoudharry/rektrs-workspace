# IQRS Admin App v2.3 — Build Report (Milestone M4: the write side)

**Deliverable:** `IQRS-Admin-App-v2.3.apk`
**Package:** `pk.edu.iqrs.admin` · **versionName 2.3 / versionCode 14** (installs over v2.2/v2.2.1, same debug keystore)
**Size:** 1,311,009 bytes · **SHA-256:** `d1208236d421c86c80ca6b09cbb691eec6fa454bd75c8c9efb63cec5ba2e8133`
**Permissions:** INTERNET + CAMERA only (metadata gate)
**Server changes in this milestone:** none. **Family app changes:** none — Family v2.2 (code 12) deliverable untouched; the Family build still compiles clean from the shared tree (verified).

**Includes the v2.2.1 login hotfix:** `StaffLoginMapper` read the staff id from `record.id`, but the real `staffauth/login` record carries `staff_id` (the root `id` holds the same value) — the mapped id was empty, every authenticated call sent an empty User-ID header, and the app signed the user out seconds after login. The mapper now reads record `staff_id`, then root `id`, then record `id`; the login fixture was corrected to the real payload shape and two JVM tests pin it (89 tests total). The same fix shipped standalone as `IQRS-Admin-App-v2.2.1.apk` (versionCode 13) from the pristine v2.2 tree; this v2.3 was re-issued at versionCode 14 so both upgrade paths stay monotonic.

M4 adds the complete staff write side to the Admin app: a durable on-phone store for saved writes with a delivery engine, attendance marking, QR attendance, homework and notice creation, and fee collection — all against the already-deployed Phase B staff endpoints in `Staffsync.php`, built exactly to their contracts.

---

## 1. Flows built (design-system-v2 §4.B)

| Screen | What was built |
|---|---|
| **S2 Home** | Gold "Waiting to send" strip (count, tap → S9) whenever anything is held; quick-action tiles (Mark attendance, Scan QR, New homework, New notice); tools rows for Collect fees and Waiting to send; "Recent activity" list from the delivered-activity history (receipt references shown for fees). |
| **S3 Classes** | Tap a class now opens the marking register (S4) instead of the read-only register; gold QR button floats over the list; waiting strip under the header. |
| **S4 Mark attendance** | Date stepper (any past day, never the future), "Mark all present", per-student Present/Absent/Late segmented control, sticky Save, in-screen "Saved ✓ — Undo" bar (~5 s; Undo works while the item is still on the phone). Whole class saved as ONE write. See §4 for the register-state rules. |
| **S5 QR attendance** | Camera2 preview with gold frame, torch toggle, ZXing decoding (frame + both quarter-turn rotations), student card on confirmation (1.2 s auto-dismiss), amber "Already marked present" card for same-day repeats, plain-words card when the school refuses a code, manual code/admission-number entry as fallback, camera-permission denial degrades to manual entry. |
| **S6 Homework** | Compose form (class picker from the staff classes read, hand-in date chips Tomorrow / In 2 days / date picker, description) + this phone's homework list (held first, then delivered). Subject area is the design's honest empty state — see Flag 2. |
| **S7 Notices** | Compose (title, details, audience Students & Parents / Staff / Everyone) behind a confirmation sheet, + this phone's notices list. |
| **S8 Collect fees** | Search student → open fee lines from the fee helper → pick a line → amount (prefilled with the balance), optional discount, method Cash/Bank/Other, optional note → review sheet → save → result panel: receipt reference + Share once the school confirms; the design's "Recorded on this phone…" wording until then; a refusal surfaces its plain-words reason on the panel. |
| **S9 Waiting to send** | Explainer, session-expired sign-in prompt (items are preserved), needs-attention group first (plain-words reason, Edit / Discard behind a confirmation), waiting group in send order, sent history; pull-to-refresh triggers a delivery pass. Edit routes per kind (register → S4, homework → S6, notice → S7, fee → S8) and **keeps the same transaction id**; QR items offer Discard only (re-marking is a fresh scan). |
| **S11 Sign-in** | Signing out never touches held items; after a fresh sign-in with items held, the app says "Your waiting items are still here." and delivery resumes automatically. |

## 2. Endpoint contracts used (Staffsync.php, production-live, unmodified)

All endpoints are POST JSON with the extension's auth headers (`Client-Service` / `Auth-Key` + `User-ID` = staff id + `Authorization` = staff token). Success: `{status:1, message:"Successfully.", record:{…}}`; refusal: `{status:0, message}`.

| App write | Endpoint | Payload built by | Answer used |
|---|---|---|---|
| Attendance | `staffsync/attendance` | one call per class/date: `class_id`, `section_id`, `date`, `records:[{student_session_id, attendence_type_id}]` | `record{saved, skipped[]}` |
| QR attendance | `staffsync/qrAttendance` | `code` sent **raw and unmodified** (the service resolves `IQRS-<id>` → student id, digits → id then admission no, else admission no); fresh transaction id per scan | `record{student_id, student_session_id, name, admission_no, class, section, date, attendence_type_id}` |
| Homework | `staffsync/homework` | `class_id`, `section_id`, `subject_group_subject_id`, `homework_date`, `submit_date`, `description` | `record{homework_id}` |
| Notice | `staffsync/notice` | `title`, `message`, `date`, `publish_date`, visibility flags as **"Yes"/"No" strings** (the service's reader treats JSON `false` as "Yes" — booleans are never sent) | `record{notice_id}` |
| Fee collection | `staffsync/feeCollect` | `student_fees_master_id`, `fee_groups_feetype_id`, `amount`, optional `amount_discount`, `payment_mode`, `date`, `description` — existing invoice lines only | `record{invoice_id, sub_invoice_id}` → receipt shown as `invoice_id/sub_invoice_id` |
| Fee dues (read) | `staffsync/feeInvoice` | `{student_session_id}` | vendor fee structure; line balance = amount − paid − discount from the deposit detail (the web register's arithmetic; a discount is never shown as a payment) |

## 3. The saved-writes store and delivery engine (plan §4.1/§4.2)

**Store** — `iqrs_admin.db` (separate from the read cache, so a cache clear can never lose a pending write):
- `pending_writes(id, client_txn_id UNIQUE, kind, payload_json, summary, state, attempts, last_attempt_at, last_error, server_response, created_at)` — kinds: attendance, qr_attendance, homework, notice, fee_collect; states: waiting, sending, needs_attention. Delivered rows are **deleted**; a delivered-history table `activity_log` is kept 90 days and pruned at start.
- `qr_marks(code, day, student_name)` — the QR same-day duplicate daybook.

**Transaction-id lifecycle (the money-safety rule):**
1. A UUID v4 id (36 chars, inside the service's 8–64 window) is minted **once**, when a write is composed, and is embedded in the payload before the item exists.
2. Every delivery attempt — first send, retry after a lost connection, resend after a crash, an edit from the Waiting screen — reuses **the same id**. An edit that tried to change the id is refused in code (and pinned by a test).
3. The service treats a repeated id as the same change: a re-send after an unknown outcome returns the original stored answer with `duplicate:true`, which the app counts as delivered — a fee can never be collected twice.

**Engine classification of every outcome** (each pinned by a JVM test):
- `status:1` (incl. `duplicate:true`) → delivered: row deleted, activity written, watchers (QR card, fee receipt) notified.
- HTTP 401 → the whole pass pauses, rows kept untouched; re-login resumes with the same ids.
- Transport/server failure → item stays waiting, attempts + 1, run stops; backoff ladder 30 s → 2 min → 8 min → 10 min cap.
- "…already being processed…" (a twin attempt is mid-write server-side) → stays waiting with the same id, backs off, run stops.
- "Internal server error." (the service released its claim without storing) → stays waiting; the retry with the same id re-executes safely.
- Any other `status:0` (a stored, final refusal) → **needs attention**: never auto-retried, never silently dropped; shown on S9 with a plain-words reason and Edit/Discard.
- Crash rule: at app start, a row stuck in `sending` for over 60 s returns to waiting and goes out with its original id.

**Delivery triggers:** app start, connection-return callback, every new save, entering/pulling S9, Home/Classes resume, and a ~15-minute inexact retry alarm (no extra permissions: the connection watch uses the default-network callback, the alarm is inexact).

**Duplicate prevention in the UI:** Save buttons disable after a save until something changes; the confirmation sheet dismisses before its action runs; the register Undo only discards a copy that is still on the phone.

## 4. Register-marking rules (S4)

- The roster read is **today-only**, so: for today, each student starts from the school's current register state; for any other day everyone starts Present and the screen says so in plain words.
- Students the school marked with a state outside Present/Absent/Late (Leave, Half Day, Holiday) are **left out of the saved records** unless the teacher picks a state — the app never overwrites a mark it cannot express; the row explains "Marked as Leave on the school register…".
- Attendance type ids: the segmented control sends Present/Absent/Late. **Present = 1 is verified** (plan §4.3 + Phase B staging). See Flag 1 for Absent/Late.

## 5. Gates — all passed

- **JVM fixture tests: 89/89 OK** (59 pre-existing + 28 M4 + 2 login-hotfix guards). New coverage: every payload builder field-for-field (incl. the notice "Yes"/"No" mapping and fee defaults), answer parsing, plain-words refusal mapping, the fee helper's balances (tuition 2,400 with a 700 discount-only entry → balance 1,700; settled 500 line; 1,900 arrears; total 3,600 — the school's known case), the engine state machine: FIFO order, duplicate-answer delivery, transport stop + per-item backoff, claim-in-flight, internal-error retry, business-refusal parking (never auto-retried), 401 pause, **crash-restart recovery with the original transaction id**, **fee unknown-outcome resend reusing the same id**, edit keeping the id, backoff ladder — plus the staff-login mapping against the real payload shape (record `staff_id`, root-`id` fallback).
- **Banned-strings lint: PASSED** (no development vocabulary, no status pills, no domain text in any source or string).
- **Metadata gate: PASSED** — package `pk.edu.iqrs.admin`, versionCode 14, versionName 2.3, minSdk 26, targetSdk 34, permissions exactly INTERNET + CAMERA, signature verifies.
- Fixtures for every answer shape live in `fixtures/` (`sync_*.json`, `fee_invoice.json`, `fee_invoice_empty.json`), built field-for-field from `Staffsync.php` and the vendor fee selects.

## 6. Flags

1. **Absent / Late type ids are unverified — the #1 Gate-2 check.** No local source pairs ids with names for Absent and Late (the vendor seed order Present 1, Absent 2, Late 3 is what ships in `AttendanceTypes`). Before staff rely on marking, verify on staging: read `attendence_type` from the staging DB and confirm the id↔name pairs; if they differ, it is a two-line change in `AttendanceTypes`.
2. **Homework subjects — contract gap (known data gap, now also a read gap).** Production has **no subject groups configured**, and no deployed staff read returns subject groups/subjects (the plan's §3.5 `subjects` read was never built). The homework form therefore shows the design's honest empty state for the subject and holds saving with the reason in plain words ("A subject is needed before homework can be saved."). The payload path is complete and fixture-tested; it lights up when (a) the school office configures subject groups and (b) a small additive staff read for them is deployed — recommended as the first M5 server item.
3. **Fee edit routing:** editing a held fee from S9 re-opens the collection flow (find the student again) and revises the same item with the same transaction id — the held payload deliberately stores no student identity beyond the invoice ids, so the student is re-picked rather than guessed.
4. **Read cache placement:** §4.1 sketches one admin database; the pending-writes store, activity history and QR daybook are in `iqrs_admin.db` as planned, while the fee-dues read uses the existing M3 read cache (`iqrs_cache.db`) like every other staff read. No behaviour difference; noted for accuracy.
5. **QR haptics omitted:** a success buzz needs the VIBRATE permission, which is outside the metadata gate's allowed set {INTERNET, CAMERA}. Cards + the daybook carry the feedback instead.
6. **M3's read-only register screen** (`StaffRosterActivity`) remains in the build but Classes now opens the marking register, which shows the same register with today's states prefilled; the old screen is unlinked.
7. **Vendored library:** ZXing core 3.5.3 (`libs/zxing-core-3.5.3.jar`, 607,650 bytes, SHA-256 `8d8064c1…`, SHA-1 matches Maven Central's published value) is on the Admin compile/dex path only; the Family build neither compiles nor ships it.
8. **Device gate still pending:** camera decoding behaviour, the retry alarm under battery management, and the sender's behaviour on a real connection drop can only be confirmed on Assad's phone — headless gates here cover contracts, state machines and packaging, not handset behaviour.
