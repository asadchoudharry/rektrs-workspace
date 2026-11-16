# IQRS Admin App v2.3.1 — Build Report (corrective build)

**Version:** Admin versionName 2.3.1 / versionCode 15 (was 2.3 / 14)
**APK:** `IQRS-Admin-App-v2.3.1.apk` — 1,311,009 bytes — SHA-256 `0c890d68c95bb8efd233f0c91294ff4e7a3b93dbe03d3987209150b50a1aac21`
**Scope:** ONE verified-wrong constant set fixed. No server changes, no Family changes, no other features. v2.3 and v2.2.1 APKs untouched (hashes re-verified unchanged).

## The defect

`AttendanceTypes.SEGMENT_IDS` was `{1, 2, 3}` for segments {Present, Absent, Late}. Under the school's own `attendence_type` table, id **2 is "Late With Excuse"** — so every "Absent" tapped in the marking register was recorded by the school as Late With Excuse. Absent is id **4**. (Present 1 and Late 3 were already correct; the wrong ids came from the vendor package's seed order, flagged unverified in the v2.3 report.)

## The fix

- `src/pk/edu/iqrs/app/api/AttendanceTypes.java`: `SEGMENT_IDS` → `{1, 4, 3}`. The header comment's verification paragraph was rewritten: the ids are now recorded as VERIFIED against the school's own `attendence_type` table, with the full table listed. Everything else in the file is identical (`ALL_NAMES` unchanged — it is the payload-derived display list).
- Tree-wide sweep for other hardcoded Absent/Late ids: none found. `StaffMarkActivity` resolves segments and reverse-maps payload ids through `SEGMENT_IDS`, so it picks up the fix automatically. The QR path sends no `attendence_type_id` at all (`SyncPayloads.qrAttendance` omits it; the service defaults to Present) — confirmed, nothing to fix. One test fixture that used the stale id as a generic mark (`StaffM4PayloadsTest`, second record id 2) was corrected to 4; no assertion depended on the old value.
- New guard test `attendanceTypeIdsMatchTheSchoolsVerifiedTable` in `StaffM4PayloadsTest` pins `SEGMENT_IDS` to `{1, 4, 3}` and each segment's id (Present 1, Absent 4, Late 3) against the verified table, so the constant cannot silently regress.

## The verified table (school's `attendence_type`, staging DB check, 2026-11-07)

| id | type |
|----|------|
| 1 | Present |
| 2 | Late With Excuse |
| 3 | Late |
| 4 | Absent |
| 5 | Holiday |
| 6 | Half Day |
| 7 | Approved Leave |
| 8 | Medical Leave |
| 9 | Official Activity |
| 10 | Unexcused Absence |

## Gates

- **JVM tests: 90/90 OK** (89 previous + the new pinning test; full suite via `tools/run_tests.sh`).
- **Banned-strings lint: PASSED** (all 12 checks).
- **Metadata gate: PASSED** — package `pk.edu.iqrs.admin`, versionCode 15, versionName 2.3.1, minSdk 26, targetSdk 34, permissions INTERNET + CAMERA only, signature verifies (same debug keystore and Gradle-free pipeline as the other v2 builds).

## Remaining gate

On-device only: install v2.3.1 over v2.3, mark one student Absent in a test register, and confirm the school records Absent (not Late With Excuse). No other behaviour changed in this build, so no wider re-test is needed.
