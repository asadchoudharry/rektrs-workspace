# CHECKER REPORT — Apps Wave 1A (API wave) — 2026-11-07

Checker: independent agent (did not build or fix this wave). Environment: **staging
only** (staging.iqrs.edu.pk). Production was not touched in any check.

## Endpoint build under check (local masters, verified by content + live behaviour)

| File | Size | SHA-256 |
|---|---|---|
| Staffapi.php | 282,897 B | `134e0f98aad54dae4cafce6da8802fcc76368b2c362e0509571c96fb97d26f42` |
| Staffsync.php | **97,582 B** | `963da8045d4893c029f6b6a87c3d8a61b938b6b18b154189f7350642cb8a09b1` |

Byte-identity of the staging copies with these masters is established behaviourally
(the battery and every probe below exercise each fixed site live) plus the recorded
swap verifications — the host offers no shell/hash readback, so no stronger identity
claim is made.

Fixtures used (ids only): staff 113 (Super Admin), 114 (Teacher), 115 (TEST Limited
role), family fixture (parent + student, staging).

## Gate results

| Gate | Result | Basis |
|---|---|---|
| **G1 Contract** | **PASS** | Full battery re-run by the Checker (below) + 9 independent refusal probes |
| **G2 Logic** | **PASS** (API-wave mapping) | Battery 177/0 incl. the embedded studentUpdate regression suite 18/18; no JVM suite exists for a server-side wave — app-side G2 belongs to Wave 1B |
| **G3 Visual** | N/A | No app screens in this wave |
| **G4 Language & metadata** | N/A (no APK) | Observed API error copy is plain words only ("Unauthorized.", validation messages); no codes or stack text in any response seen |
| **G5 Data truth** | **PASS** | Hand-verified fees arithmetic + worklist↔Classes reconciliation (below) |

## Check 1 — Battery re-run (Check­er-executed)

Command: `cd ~/workspace/iqrs-api/staff-ext && bash test-wave1a-api-staging.sh`
Observed tail:

```
  PASS  studentUpdate suite green: RESULT: PASS=18 FAIL=0
RESULT: PASS=177 FAIL=0
```

Exit code 0. This matches the fix report's claim (177/0) exactly. Fresh-row ids in
this run differ from earlier runs as expected (e.g. admin self-leave fixture row id
10). Battery NOTEs recorded verbatim: register checks for the admin section skipped
(no class/section extracted in that section's path); teacher scope type 'all' —
register scoping unproven (see F3); one admin self-leave fixture row stays pending
on staging (harmless, by design of the script).

## Check 2 — Additivity (diffs against pre-wave baselines)

- `Staffapi.php.pre-wave1a` (97,285 B) → `Staffapi.php`: 3,884 lines added, **15
  lines changed, 0 lines purely removed**. Every changed line is accounted for:
  1 constructor line (model load gains `studentfeemaster_model` — additive) and
  14 auth-guard call sites.
- `Staffsync.php.pre-wave1a` (36,780 B) → `Staffsync.php`: 1,497 lines added,
  **6 lines changed** — all 6 are the same auth-guard swap.
- The guard swap replaces `$this->auth_model->check_auth_client()` with a new
  private `check_client()` performing the identical header comparison and, on
  failure, emitting the standard `401 {"status":0,"message":"Unauthorized."}`.
  Equivalent on success, stricter and consistent on failure; no pre-existing
  behaviour removed. (14 + 6 = 20 guard sites + 1 constructor line — exactly the
  build's stated change surface.)
- Fix-round diffs reproduce the documented fixes and nothing else:
  `.pre-wave1a-fix` → `.pre-wave1a-fix2` = fixes 1, 2, 4, 5, 6, 7 (six single-site
  changes); `.pre-wave1a-fix2` → current = fix 8 (worklist helper rewrite + card
  `count`/`sections` change); `Staffsync.php.pre-wave1a-fix` → current = fix 3
  (one line).

## Check 3 — Fix spot-checks in the shipped code

All 8 fixes from BUILD-REPORT-wave1a-api-fixes.md verified present by grep:
F1 `staff_role_names((int) $staff->id)` in is_admin_scope (Staffapi:4593);
F2 `staff_role_rows((int) $staff->id)` in notice_visible (Staffapi:5429);
F3 same cast in Staffsync admin_scope (Staffsync:2075);
F4 `staff.local_address AS current_address` (Staffapi:5534);
F5 joins via `student_fees_master` (Staffapi:5273–5274);
F6 `where('subject_timetable.staff_id', …)` (Staffapi:4779);
F7 homework_evaluation join through `student_session` (Staffapi:4897);
F8 `'count' => count($unmarked)` + `'sections' => $unmarked` (Staffapi:2087–2088).
Residual-pattern greps are clean: no `staff_role_names($staff)` /
`staff_role_rows($staff)` object-pass anywhere, no `staff.current_address`
selection, no `subject_group_subjects.teacher_id`, no
`student_fees_deposite.student_session_id` join.

## Check 4 — Independent curl probes (staging, curl only)

**4a Auth refusals.** No token (client headers present): dashboardWorklist,
staffDirectory, feeDueSearch, homeworkList, studentLeaveList, noticeList — all
`HTTP 401 {"status":401,"message":"Unauthorized."}`, no data. No client headers
(valid token): dashboardWorklist, staffDirectory, feeDueSearch — all HTTP 401,
no data. **PASS.**

**4b Fees reconciliation (G5).** feeStatement for a due student
(student_session 2131), payload's own numbers: line 1 amount 2400 − paid 0 −
discount 1000 = balance 1400 ✓; line 2: 18900 − 0 − 0 = 18900 ✓; totals
amount 21300 − paid 0 − discount 1000 = balance 20300 ✓, and totals equal the
line sums; deposits agree (paid 0, discount 1000). The discount is carried as a
discount, never as a phantom payment. **PASS.**

**4c Worklist reconciliation (G5).** dashboardWorklist as 113:
attendance_unmarked `count` = 77 (integer) = `sections` length 77 = classes-derived
count (student_count > 0 and marked_today == 0 across staffapi/classes) 77.
**PASS** — fix 8 confirmed live, not just in code.

**4d Directory views.** As 115 (TEST role, zero grants): staffDirectory status 1,
`summary.full_view` = false, 0 of the sampled records carry `email`/`contact_no`.
As 114: capabilities show human_resource/staff view GRANTED on this install, and
staffDetail(114 → 113) does carry contact fields — view and capability map agree,
which is the contract (full view for 114 is correct behaviour here, matching the
web's own rule). The fix report's S5 reasoning is verified, not merely asserted.
**PASS.**

**4e Honesty contracts.** attendanceRegister with `period: 2` returns
`period_supported: false` and 22 student rows with **no** period field — nothing
fabricated. feeReceipt returns `file: null` for the default format **and** for an
explicit `format: "pdf"` request. **PASS.**

## Findings

- **F1 (S2, documentation)** — The fix report states the final Staffsync.php size
  as **97,572 B**; the shipped file is **97,582 B** (97,572 B is the pre-fix
  intermediate). The 10-byte delta is exactly fix 3 and staging behaviour proves
  the fixed file is the one live, so this is a reporting inaccuracy, not a code
  defect — but §6.1 makes file size + hash part of the wave's identity record.
  Fix: correct the figure in BUILD-REPORT-wave1a-api-fixes.md wherever it
  propagated. Owner: build lane, before Wave 1C paperwork.
- **F2 (S2, documentation)** — `BUILD-REPORT-wave1a-api.md`, the wave's original
  build report, **does not exist** in the goal files (only the fix-round report
  is filed). The Checker verified the endpoint contracts directly against code
  and live staging, so verification is unaffected; the artefact chain §6.6
  expects is incomplete. Fix: file the original build report or a consolidated
  Wave 1A build record. Owner: build lane, before Wave 1C paperwork.
- **F3 (S2, accepted debt)** — Teacher register scoping remains **unproven** on
  this install: fixture teacher 114's scope resolves to 'all' because the install
  carries no teacher class/subject assignments for the fixture (battery NOTE).
  The assigned-scope code path (incl. fix 6's filter) is therefore exercised only
  in its scope-'all' arm live. Not a Wave 1A defect; becomes testable when a
  staging teacher fixture carries real assignments. Fix venue: Wave 1B staging
  fixture preparation.

No S0 or S1 findings. All money figures checked reconcile; no role saw another
role's restricted data (the one apparent case — teacher 114's full directory
view — is the school's own granted permission, verified against the capability
map and the roles_permissions data).

## Verdict

**PASS** — Wave 1A (API) is fit to proceed to Wave 1B on the strength of the
staging proof above. S2 debts F1–F3 are recorded with owners/venues as required
by §6.2; F1 and F2 should be closed in the Wave 1C paperwork, F3 in Wave 1B
fixture preparation. Production swaps (Wave 1C) remain a separate per-file
owner-approved step and are NOT authorised by this verdict.
