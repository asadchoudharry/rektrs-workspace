# RE-AUDIT-2 — PreSkool Resemblance Re-Audit of the IQRS Staging Build

**Date:** 2026-11-23 · **Scope:** staging.iqrs.edu.pk ONLY — production untouched throughout.
**Method:** RE-AUDIT-1's method, unchanged — whole rendered pages judged cold from paired
full-page captures (staging vs vendor PreSkool reference), real governed school data in
place of demo content, verdicts per the lane rubric (`work/batches/RUBRIC.md`):
**RESEMBLES** (a viewer would take the page for the vendor page carrying this school's
data) · **SHELL-ONLY** (vendor frame present, composition is the workspace's own, a
defining block missing, or the working list is fixture data — for surfaces with no vendor
pair this is the ceiling and a pass-grade outcome) · **DOES-NOT-RESEMBLE** (no vendor
frame, legacy interior, error/500, wrong page) · **PENDING** (no capture landed — never
invented, named as owed below).

**Surface list:** 312 — the 302 active sidebar URLs at audit start plus 10 named extras
(two dashboards, teacher dashboard, student edit, 404, five portal surfaces).

## Verdict counts

| Verdict | Count |
|---|---|
| RESEMBLES | 6 |
| SHELL-ONLY | 184 |
| DOES-NOT-RESEMBLE | 9 |
| PENDING (capture owed) | 113 |
| **Judged on evidence** | **199 of 312** |

## Delta headline vs RE-AUDIT-1 (2026-11-19: RESEMBLES 1 · SHELL-ONLY 55 · DOES-NOT-RESEMBLE 70 of 126)

125 of RE-AUDIT-1's judged surfaces are on this audit's list; 118 of them were re-judged
(7 still PENDING). Transitions:

| RA1 ↓ → RA2 | RESEMBLES | SHELL-ONLY | DOES-NOT-RESEMBLE | PENDING |
|---|---|---|---|---|
| DOES-NOT-RESEMBLE (72) | 2 | 61 | 7 | 2 |
| SHELL-ONLY (52) | 2 | 45 | 0 | 5 |
| RESEMBLES (1) | 1 | 0 | 0 | 0 |

The fix programme's effect is real and large: of the 70 surfaces RE-AUDIT-1 condemned,
only 7 still fail, 61 rose to SHELL-ONLY and 2 (Fee Groups, Attendance Register) to
RESEMBLES. No surface that RE-AUDIT-1 passed or shelved fell back. The remaining
DOES-NOT-RESEMBLE set is small and fully named:

- **Four HTTP 500s** (root-caused, §3): Add Student and Edit Student — a live regression
  introduced by the FC-15 religion-SELECT wiring on 2026-11-23; and FC-17's two
  digital-ID surfaces, which have never rendered live.
- **Five legacy interiors** unchanged since RA1: staff leave-request list (s042),
  Download Center content type / list / upload (s056–s058), User Log (s097).

## Gate recommendation: **FAIL** — do not proceed to the owner's signed-in re-check yet

The recommendation follows from the evidence table, on three grounds:

1. **Two core doors are down.** Add Student (`student/create`) and Edit Student
   (`student/edit/…`) return HTTP 500 on staging right now — a regression from today's
   religion-SELECT wiring (root cause in §3). An owner re-check that begins with a
   broken admission door cannot pass, and shipping the re-check invitation before the
   fix would waste the owner's one ground-truth pass.
2. **FC-17's digital-ID surfaces have never rendered** (HTTP 500 since deploy, §3) —
   that lane's owed proof cycle cannot even begin until the one-word-class model fix
   lands.
3. **The audit itself is incomplete:** 113 of 312 captures are still owed (§6) because
   this VM's headless Chromium failed at startup for most of both audit lanes (the same
   failure that left RE-AUDIT-1 with 124 owed). A gate cannot certify surfaces it has
   not seen.

**The path back is short and fully named:** (i) fix the religion-wiring view-scope
defect (load the model in the controller / pass the list as view data — ADMIT-1
round-trip discipline); (ii) fix `Pkdigitalid_model::register_select()`'s `dep.name` →
`department_name`; (iii) re-capture the 113 owed surfaces when a working browser route
exists and judge them; (iv) re-run this gate. Items (i)–(ii) are small, root-caused fix
lanes; neither touches production. Everything else the audit was asked to verify —
battery, polish, reconciliation, teardown — is complete and clean (§§2, 4, 7).

## 1. Click battery

All 312 surfaces probed with the audit session: **298 × HTTP 200 · 10 × HTTP 307
(designed workspace-root and teacher-dashboard redirects) · 4 × HTTP 500** — the four
500s are exactly the root-caused set in §3. No 404s.

## 2. Polish items folded into this lane — all six FIXED + DEPLOYED

Payload 21 files, deployed by the first RE-AUDIT-2 lane; this continuation verified
**on-host md5 == lane manifest for 21/21 files** against the staging tree (DB guard
`u238632175_test123`), backups at host `~/backups-ra2-2026-11-23/`. Scans: OCR
delegation review (`scans/ocr-delegation-review.md`) — no blocking findings; Semgrep 0
findings; Gitleaks clean.

| # | Item | Disposition |
|---|---|---|
| (a) | Fees command-panel whitespace | FIXED — 2 appended rules in `preskool-fees.css`; `?v=20261123-ra2` cache-busters in pkfees plans/overview views |
| (b) | Dashboard enrolment-chart missing token | FIXED — 8 `cssVar('--pf-c-94a3b8')` sites now use the defined `muted` variable. Observation carried: other `--pf-c-*` chart colours in the same file remain literal-token references (colour fidelity, not a render failure) |
| (c) | LEGACY-1 OCR note (unescaped Refresh href) | FIXED — Refresh href now `html_escape($pk_qs)` in 14 `_head.php` partials |
| (d) | FC-4 sport venue block missing | FIXED — venue block added to `pksports/sport_view.php` |
| (e) | FC-7 hostel-fees assign card re-listed assigned residents | FIXED — already-assigned residents skipped in `pkops/hostel_fees.php` |
| (f) | FC-16 pager phrasing at zero rows | FIXED — `pknotifyops/_pager.php` `$pk_from` = 0 when total is 0 |

## 3. The four 500s — root causes (from staging CI logs, 2026-11-23)

1. **`student/create` + `student/edit/3699`** — the FC-15 religion SELECT wiring
   (landed on staging 2026-11-23) calls `religions_active()` on
   `CI_Loader::$pksettingsdepth_model`, which is null: in a view, `$this` is the CI
   loader; the model was never loaded in the controller nor passed as view data
   (CI log 08:57 PKT, `studentCreate.php:254` / `studentEdit.php:230`; renders die
   immediately after the Religion label at 15,490 / 14,753 bytes). **Fix:** load the
   model in `Student::create()`/`edit()` and pass the list as view data.
2. **`admin/pkcertificates/digital_ids` + `user/digitalid`** — FC-17 defect present
   since its deploy: `Pkdigitalid_model::register_select()` selects `dep.name`, but
   the department label column is `department_name` (CI log 09:07 PKT, "Unknown column
   'dep.name'", model lines 139/162). Both surfaces have **never rendered live**.
   **Fix:** one-word-class column correction in the model, then FC-17's owed proof
   cycle can run.

## 4. PARTIAL lanes' surfaces — judged on appearance; proof cycles remain owed

- **FC-17 Digital ID:** both surfaces DOES-NOT-RESEMBLE (HTTP 500, §3). Proof cycle
  (issue → revoke → replace incl. portal agreement) still owed, and now blocked on the
  model fix.
- **FC-19 Timetable depth:** its surfaces sit in the owed-capture set (PENDING, §6).
  Proof cycle still owed in full: conflict set-equality (231 → 233 → 232 via seeded
  Sunday clashes), leave-driven cover for Sunday 2026-11-29, manual-absence cycle for
  Monday 2026-11-23, teardown to the `subject_timetable` md5 invariant.
- **FC-14 Privacy/GDPR:** its 7 admin surfaces are in the owed-capture set (PENDING).
  Door-driven export/erasure cycles, runtime parity arbitration and the portal family
  cycle remain owed (the lane's session-free proofs passed at build time).
- **FC-15 Settings depth:** its 9 surfaces are in the owed-capture set (PENDING);
  door CRUD cycles and wrong-role denial remain owed. Its religion-SELECT wiring —
  deferred at build time — landed 2026-11-23 and caused the §3.1 regression.
- **FC-11 Provider-gated AI:** its 4 surfaces are in the owed-capture set (PENDING);
  generate-door flashes, report print render, wrong-role denial and the AI Settings
  save round-trip remain owed. The unconfigured state itself is structural and was
  re-verified post-deploy at build time; activation remains the owner's free-tier key
  paste.

None of these lanes is marked complete by this audit; their remainders stand exactly
as their lane records state them.

## 5. Captures still owed — 113 surfaces, one named reason

**Reason (all 113):** this VM's headless Chromium failed at startup across both audit
lanes — chrome-headless-shell dies with SIGILL, the full Chromium with SIGTRAP, and in
the brief windows where the binary starts, Playwright reports "no CDP targets" and no
page completes. This is the identical failure that left RE-AUDIT-1 with 124 owed
captures; staging itself answers the same session cookie via curl in 2–5 s throughout,
so the block is the local browser, not the site. Re-attempts were made on 2026-11-23 in
this continuation (196 staging captures stand, up from 142 at the first lane's stall).
Every owed surface is listed as PENDING in the per-surface table (§8) — including the
7 surfaces RE-AUDIT-1 had judged (Admin Dashboard, Teacher Dashboard, Alumni, Syllabus,
Homework, Staff Attendance register, Communicate Schedule) whose RA2 verdicts therefore
remain open. When a working browser route exists, these captures are a mechanical
re-run of the lane's existing harness (`work/capture-run2.sh` + target files).

## 6. Reconciliation — AFTER census identical to BEFORE on every line

AFTER census taken 2026-11-23 after the audit session's teardown (DB guard
`u238632175_test123`):

| Measure | BEFORE (03:43 PKT) | AFTER | 
|---|---|---|
| students | 1684 | 1684 |
| student_session | 1683 | 1683 |
| staff | 115 | **115** |
| users | 3132 | **3132** |
| deposits | 1556 | 1556 |
| fee_masters | 2631 | 2631 |
| send_notification | 0 | 0 |
| messages | 1 | 1 |
| sidebar_active (distinct URLs) | 302 (302) | 302 (302) |
| pk_ai_outputs | 0 | 0 |
| **AFM** masters · assigned · paid · discount · fine · balance · students | 2631 · 972,021,000 · 1,795,000 · 126,350,000 · 0 · 843,876,000 paisa · 1,670 | **identical, paisa-exact** |
| student 2080 (ANABIA NAVEED) | present, active, 0 sessions | **present, active, 0 sessions — intact** |
| proof/audit staff rows | 0 | 0 |

**Audit-session fate:** the first lane left its disposable session ALIVE (staff clones
394 `R2SA` / 395 `R2TE`, portal clone user 7602 `ra2portal@local.invalid`; mid-audit
census read staff 117 / users 3133). This continuation tore it down under identity
guards (employee_id + note / username matched exactly before every delete): staff
117 → 115, users 3133 → 3132, TOTP rows for the clones 0, proof_staff 0. The session's
whole lifecycle nets to zero in the AFTER census. The only staging deltas attributable
to this audit are code files: the 21 polish files (§2) and the religion-wiring view
changes (§3.1 — landed by the FC-15 wiring lane, not by this audit).

**Cleanup:** SOCKS tunnel killed; local cookie files + `.secrets-ra2` shredded;
`work/cdp-profiles` and all /dev/shm browser-profile debris removed; host-side runner
scripts self-remove by design. One named remainder: the host `/tmp/ra2/` directory
(a dead session cookie jar from session creation) could not be cleared — every SSH
route was in an egress-refusal spell at lane end; it holds no live credential (the
session is deleted) and is inert scratch.

## 7. Method notes and incidents

- **Verdict files are the evidence; child summaries are not.** One batch judge's prose
  summary in this audit hallucinated verdicts for surfaces outside its batch; its
  verdict FILE was sound and was used. Every count in this report was tallied from the
  verdict files by the parent, never from summaries.
- **Browser failure is environmental, recurring, and named** (§5) — the same failure
  truncated RE-AUDIT-1. It is a property of this VM's headless Chromium under its
  current host state, not of staging.
- **Egress spells:** SSH routes to Hostinger refused CONNECT for long stretches of
  2026-11-23; every host operation in this continuation (teardown, censuses) completed
  through the runner's route rotation when a window opened.
- **Sandbox write-taint** (intermittent EPERM on file writes from file-reading
  processes) affected lane tooling repeatedly; the audit's artefacts were produced via
  unaffected routes and verified by read-back.

## 8. Per-surface verdict table

RA1 = RE-AUDIT-1 verdict where the surface existed then (`OWED-RA1` = it was among
RA1's 124 owed; `NEW` / `n/a` = no RA1 counterpart). PENDING rows are the owed
captures of §5 — no verdict is claimed for them.

| # | Surface | URL | RA1 | RA2 verdict | Note |
|---|---|---|---|---|---|
| 1 | dash-sa | admin/admin/dashboard | SHELL-ONLY | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 2 | dash-te | admin/admin/dashboard | DOES-NOT-RESEMBLE | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 3 | p-digitalid | user/digitalid | NEW | DOES-NOT-RESEMBLE | HTTP 500, 0 bytes — FC-17's portal card shares the same register_select() defect: latest_for_student() fatals at Pkdigitalid_model.php:162 (row_array() on false |
| 4 | p-fees | user/fees | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 5 | p-privacy | user/privacy | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 6 | p-rewards | user/rewards | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 7 | p-tickets | user/tickets | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 8 | r2-admin-pkacademics-classrooms | admin/pkacademics/classrooms | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 9 | r2-admin-pkacademics-conflicts | admin/pkacademics/conflicts | NEW | PENDING | capture not yet landed |
| 10 | r2-admin-pkacademics-curriculum | admin/pkacademics/curriculum | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 11 | r2-admin-pkacademics-substitutes | admin/pkacademics/substitutes | NEW | PENDING | capture not yet landed |
| 12 | r2-admin-pkaigen | admin/pkaigen | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 13 | r2-admin-pkaigen-parent-insights | admin/pkaigen/parent_insights | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 14 | r2-admin-pkaigen-report-generator | admin/pkaigen/report_generator | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 15 | r2-admin-pkaigen-student-assistant | admin/pkaigen/student_assistant | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 16 | r2-admin-pkautomation | admin/pkautomation | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 17 | r2-admin-pkautomation-runs | admin/pkautomation/runs | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 18 | r2-admin-pkcal-events | admin/pkcal/events | NEW | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Vendor frame is present but composition is a generic Add-event form over an empty Title/Start/End/Venue register with  |
| 19 | r2-admin-pkcertificates-digital-ids | admin/pkcertificates/digital_ids | NEW | DOES-NOT-RESEMBLE | HTTP 500, 0 bytes — FC-17's admin register has NEVER rendered live. Root cause (CI log 2026-11-23 09:07:15 PKT): Query error: Unknown column 'dep.name' in 'SELE |
| 20 | r2-admin-pkcms-blog | admin/pkcms/blog | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 21 | r2-admin-pkcms-blog-categories | admin/pkcms/blog_categories | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 22 | r2-admin-pkcms-blog-comments | admin/pkcms/blog_comments | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 23 | r2-admin-pkcms-blog-tags | admin/pkcms/blog_tags | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 24 | r2-admin-pkcms-contact-messages | admin/pkcms/contact_messages | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 25 | r2-admin-pkcms-faq | admin/pkcms/faq | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 26 | r2-admin-pkcms-testimonials | admin/pkcms/testimonials | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 27 | r2-admin-pkintegrations | admin/pkintegrations | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 28 | r2-admin-pkintegrations-logs | admin/pkintegrations/logs | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 29 | r2-admin-pkintegrations-push | admin/pkintegrations/push | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 30 | r2-admin-pkintegrations-webhooks | admin/pkintegrations/webhooks | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 31 | r2-admin-pkintel | admin/pkintel | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 32 | r2-admin-pkintel-fee-forecast | admin/pkintel/fee_forecast | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 33 | r2-admin-pkintel-risk-detection | admin/pkintel/risk_detection | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 34 | r2-admin-pkintel-student-intelligence | admin/pkintel/student_intelligence | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 35 | r2-admin-pkmedical | admin/pkmedical | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 36 | r2-admin-pkmedical-alerts | admin/pkmedical/alerts | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 37 | r2-admin-pkmedical-sickroom | admin/pkmedical/sickroom | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 38 | r2-admin-pkmedical-vaccinations | admin/pkmedical/vaccinations | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 39 | r2-admin-pknotifyops | admin/pknotifyops | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 40 | r2-admin-pknotifyops-approvals | admin/pknotifyops/approvals | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 41 | r2-admin-pknotifyops-insights | admin/pknotifyops/insights | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 42 | r2-admin-pknotifyops-ledger | admin/pknotifyops/ledger | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 43 | r2-admin-pkops-asset-maintenance | admin/pkops/asset_maintenance | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 44 | r2-admin-pkops-hostel-fees | admin/pkops/hostel_fees | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 45 | r2-admin-pkops-hostel-visitors | admin/pkops/hostel_visitors | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 46 | r2-admin-pkops-hostel-wardens | admin/pkops/hostel_wardens | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 47 | r2-admin-pkops-library-reservations | admin/pkops/library_reservations | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 48 | r2-admin-pkops-transport-drivers | admin/pkops/transport_drivers | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 49 | r2-admin-pkpayments | admin/pkpayments | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 50 | r2-admin-pkprivacy | admin/pkprivacy | NEW | PENDING | capture not yet landed |
| 51 | r2-admin-pkprivacy-audit | admin/pkprivacy/audit | NEW | PENDING | capture not yet landed |
| 52 | r2-admin-pkprivacy-consents | admin/pkprivacy/consents | NEW | PENDING | capture not yet landed |
| 53 | r2-admin-pkprivacy-cookies | admin/pkprivacy/cookies | NEW | PENDING | capture not yet landed |
| 54 | r2-admin-pkprivacy-gdpr | admin/pkprivacy/gdpr | NEW | PENDING | capture not yet landed |
| 55 | r2-admin-pkprivacy-requests | admin/pkprivacy/requests | NEW | PENDING | capture not yet landed |
| 56 | r2-admin-pkreports | admin/pkreports | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 57 | r2-admin-pkrewards | admin/pkrewards | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 58 | r2-admin-pkrewards-achievements | admin/pkrewards/achievements | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 59 | r2-admin-pkrewards-rankings | admin/pkrewards/rankings | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 60 | r2-admin-pksettings-languages | admin/pksettings/languages | NEW | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor frame with page head, add-language form and a paginated register of 77 governed languages with status and Edit/Delet |
| 61 | r2-admin-pksettingsdepth-attendance-rules | admin/pksettingsdepth/attendance_rules | NEW | PENDING | capture not yet landed |
| 62 | r2-admin-pksettingsdepth-cities | admin/pksettingsdepth/cities | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 63 | r2-admin-pksettingsdepth-countries | admin/pksettingsdepth/countries | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 64 | r2-admin-pksettingsdepth-religions | admin/pksettingsdepth/religions | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 65 | r2-admin-pksettingsdepth-social-auth | admin/pksettingsdepth/social_auth | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 66 | r2-admin-pksettingsdepth-states | admin/pksettingsdepth/states | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 67 | r2-admin-pksettingsdepth-tax-rates | admin/pksettingsdepth/tax_rates | NEW | PENDING | capture not yet landed |
| 68 | r2-admin-pksettingsdepth-tax-reports | admin/pksettingsdepth/tax_reports | NEW | PENDING | capture not yet landed |
| 69 | r2-admin-pksports | admin/pksports | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 70 | r2-admin-pksports-competitions | admin/pksports/competitions | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 71 | r2-admin-pksports-players | admin/pksports/players | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 72 | r2-admin-pktickets | admin/pktickets | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 73 | r2-admin-pktickets-board | admin/pktickets/board | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 74 | s001-admin-pkfrontoffice-enquiry | admin/pkfrontoffice/enquiry | DOES-NOT-RESEMBLE | SHELL-ONLY | ANATOMY-1 frame is real (page-head, cards, working Source select). Downgraded on data: the register is 100% lane fixtures (W1A Script Enquiry x7+, Demo Enquiry  |
| 75 | s002-admin-pkfrontoffice-visitors | admin/pkfrontoffice/visitors | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame + governed log form + register card; DATA-0 purge proven (honest 'No visitors logged yet'). Vendor's stat strip / quick chips / dense register comp |
| 76 | s003-admin-pkfrontoffice-calls | admin/pkfrontoffice/calls | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame; log form + honest empty log + a gate-queue calls card (school-specific, honestly labelled). Vendor call-history register composition not reproduce |
| 77 | s004-admin-pkfrontoffice-postal | admin/pkfrontoffice/postal | DOES-NOT-RESEMBLE | SHELL-ONLY | RA1's duplicate-door defect resolved by design: one combined Dispatch & Receive page (Type select, two registers), vendor frame, honest empties. No vendor count |
| 78 | s005-admin-pkfrontoffice-complaints | admin/pkfrontoffice/complaints | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame; governed complaint form + honest empty register. No vendor counterpart page. |
| 79 | s006-admin-pkfrontoffice-purposes | admin/pkfrontoffice/purposes | DOES-NOT-RESEMBLE | SHELL-ONLY | MENU-1 dedupe proven for visitor purposes: exactly the canonical 12. RESIDUAL DUPLICATE (new evidence): complaint types still carry BOTH setup packs — 10 rows ' |
| 80 | s007-student-create | student/create | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | HTTP 500 — LIVE REGRESSION from the FC-15 religion wiring (2026-11-23). The render dies immediately after the Religion label (15,490 bytes served). CI log 2026- |
| 81 | s008-admin-pkstudents-admissions | admin/pkstudents/admissions | n/a (new surface) | RESEMBLES | Vendor admissions composition: stat cards (Total/Pending/Submitted/Enrolled/Fee Pending, all honest 0 after DATA-0 purged the 4 TEST rows), search + status filt |
| 82 | s009-admin-pkfees-collect | admin/pkfees/collect | SHELL-ONLY | SHELL-ONLY | ANATOMY-1 fix proven: the student search now renders as a styled vendor toolbar inside the card (RA1's clipped unstyled box is gone). Still a search desk by des |
| 83 | s010-admin-pkfees-plans | admin/pkfees/plans | SHELL-ONLY | RESEMBLES | FEES-1 claim STANDS on the cold capture. Command centre carries the school's real governed figures (collected Rs 17,950 / discount Rs 1,263,500 / outstanding Rs |
| 84 | s011-admin-pkfees-groups | admin/pkfees/groups | DOES-NOT-RESEMBLE | RESEMBLES | FEES-1 fix proven cold: Working Groups (4) / Archived (961) segmented tabs, the working list is exactly the 4 live groups on one 1,060px screen (RA1: ~42,000px  |
| 85 | s012-admin-pkfees-heads | admin/pkfees/heads | SHELL-ONLY | SHELL-ONLY | Vendor Income page is a search toolbar plus transaction list and detail/timeline panels; staging is its own two-column Income/Expense Heads table with inline Ad |
| 86 | s013-admin-pkstudents-multiclass | admin/pkstudents/multiclass | SHELL-ONLY | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame and breadcrumb are present, but the page is only a Class/Section selector with an Open roster button and empty |
| 87 | s014-category | category | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). PreSkool frame, page head and cards are present, but inside is a generic legacy form + register (Create Category beside an  |
| 88 | s015-admin-schoolhouse | admin/schoolhouse | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame is present, but the content is a generic Add School House form plus a 4-row default-house list, and the regist |
| 89 | s016-admin-disable-reason | admin/disable_reason | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). PreSkool frame, head and cards are present over a real 12-row reason list, but the composition is a generic legacy form + r |
| 90 | s017-admin-pkfees-types | admin/pkfees/types | SHELL-ONLY | SHELL-ONLY | Vendor Fees Type has a search/Saved Views toolbar, Quick status chips and a rich register with configuration badges, academic details and status pills; staging  |
| 91 | s018-admin-pkattendance-bydate | admin/pkattendance/bydate | SHELL-ONLY | SHELL-ONLY | Vendor Student Day Wise has four stat cards, report tabs and a student attendance register; staging instead shows a class/date filter, an empty November 2026 he |
| 92 | s019-admin-pkattendance-register | admin/pkattendance/register | DOES-NOT-RESEMBLE | RESEMBLES | CORE-1 rebuild proven: stat chips, class/section/date pickers, whole-school summary server-paginated 25/77, and the marking grid over REAL students (admission n |
| 93 | s020-admin-pkattendance-leave | admin/pkattendance/leave | SHELL-ONLY | SHELL-ONLY | Vendor counterpart is a student-detail Leave & Attendance tab with stat cards, leave-type balance cards and a leaves register; staging is a prose-heavy balances |
| 94 | s021-admin-pkexams-types | admin/pkexams/types | SHELL-ONLY | SHELL-ONLY | Vendor Exam Types is a toolbar with Quick chips above a grid of exam-type cards showing total/pass/duration and weightage bars; staging is an Add Exam Type form |
| 95 | s022-admin-pkexams-attendance | admin/pkexams/attendance | SHELL-ONLY | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame, Exam/Subject selectors and Present/Absent/Enrolled counters are present, but the body is a single honest empt |
| 96 | s023-admin-pkexams-reportcards | admin/pkexams/reportcards | SHELL-ONLY | SHELL-ONLY | Vendor Report Cards has a year/exam/class/student filter bar, a student card, a full report-card preview and a Subject Performance table; staging has none of th |
| 97 | s024-admin-admitcard | admin/admitcard | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor Admit Card is a batch toolbar with status chips, a Student & Exam Selection bar, a rendered admit-card preview and a student-information panel; staging i |
| 98 | s025-admin-printcenter-examdocs | admin/printcenter/examdocs | SHELL-ONLY | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). The page is a single Exam dropdown with an Open button and nothing below it — a search desk, not a document centre. The int |
| 99 | s026-admin-marksheet | admin/marksheet | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor pair is a stat-strip plus rich TC register; staging is instead a legacy Design Marksheet template form (uploads and field toggles) beside a 1-row Markshe |
| 100 | s027-admin-pkexams-rules | admin/pkexams/rules | SHELL-ONLY | SHELL-ONLY | Vendor Grade Setup is a toolbar with Quick chips over a rich grade register (mark-range bars, grade points, academic details, status); staging is an Add Divisio |
| 101 | s028-admin-pkexams-onlineresults | admin/pkexams/onlineresults | SHELL-ONLY | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame and an Online Exam selector are present, but the results register below is an honest empty state ('No students |
| 102 | s029-admin-pkexams-questions | admin/pkexams/questions | SHELL-ONLY | SHELL-ONLY | Vendor Question Bank opens with a six-card stat strip and Difficulty Mix / Questions by Subject charts above its register; staging has only a filter bar and a p |
| 103 | s030-admin-pkacademics-lessons | admin/pkacademics/lessons | SHELL-ONLY | SHELL-ONLY | Vendor Lesson Planning has a search/filter toolbar, a facet rail, lesson-plan cards with completion bars and a detail panel; staging is a class-section selector |
| 104 | s031-admin-pkacademics-syllabus | admin/pkacademics/syllabus | SHELL-ONLY | PENDING | capture not yet landed |
| 105 | s032-admin-pkacademics-timetable | admin/pkacademics/timetable | SHELL-ONLY | RESEMBLES | Staging reproduces the vendor's defining composition: stat cards above a day-column grid of coloured period cards (subject, time, room, teacher) over real gover |
| 106 | s033-admin-teacher-assign-class-teacher | admin/teacher/assign_class_teacher | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). PreSkool frame and page head are present, but the composition is a generic legacy assign form plus Class Teacher List, and  |
| 107 | s034-admin-pkacademics-groups | admin/pkacademics/groups | SHELL-ONLY | SHELL-ONLY | Vendor Class Subject has a search/Saved Views toolbar, Quick chips, a rich subject register and Subject Insights / Recent Activities panels; staging (Subject Gr |
| 108 | s035-admin-pkacademics-subjects | admin/pkacademics/subjects | SHELL-ONLY | SHELL-ONLY | Vendor Class Subject has a toolbar with Quick chips, a register carrying academic details, curriculum badges and status, plus insights/activity panels below; st |
| 109 | s036-admin-pkacademics-classes | admin/pkacademics/classes | SHELL-ONLY | SHELL-ONLY | Vendor frame and a real class register with enrolments are present, but staging leads with an inline Add Class form and a plain table; the vendor toolbar with S |
| 110 | s037-admin-pkacademics-sections | admin/pkacademics/sections | SHELL-ONLY | SHELL-ONLY | Frame plus a real 81-section register, but composition is an inline Add Section form over a plain 3-column table; vendor's toolbar, Quick chips, class-details/s |
| 111 | s038-admin-pkhr-staff | admin/pkhr/staff | RESEMBLES | RESEMBLES | Vendor-style header actions (Export, Add Staff), search/role filter and dense register with avatar, name/ID/email, role/department/designation/contact, Active s |
| 112 | s039-admin-pkattendance-staff | admin/pkattendance/staff | SHELL-ONLY | PENDING | capture not yet landed |
| 113 | s040-admin-pkpayroll-structures | admin/pkpayroll/structures | SHELL-ONLY | SHELL-ONLY | Vendor frame only: staging shows an empty table header above a large New Version creation form, with heavy system-prose about governed versions, cooling flags a |
| 114 | s041-admin-pkhr-leave | admin/pkhr/leave | SHELL-ONLY | SHELL-ONLY | Frame and a small leave register are present, but both rows are Demo Teacher (DEMO-TEACH) fixture rows, which caps the verdict at SHELL-ONLY; vendor's Quick sta |
| 115 | s042-admin-staff-leaverequest | admin/staff/leaverequest | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | Interior is a legacy DataTables render (legacy search/50-per-page/export icons, 'No data available in table' with legacy illustration and green add-record text) |
| 116 | s043-admin-pkhr-leave-policies | admin/pkhr/leave-policies | SHELL-ONLY | SHELL-ONLY | Staging has a card grid per leave type in the vendor frame, echoing the vendor cards, but cards are sparse (all 0 days/staff), an Add Leave Type form leads the  |
| 117 | s044-admin-pkhr-ratings | admin/pkhr/ratings | SHELL-ONLY | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling; frame is present but the only data is fixture data (TEST TEACHER M3 / TEST-T-001 rated by TEST Fixture W0, comment |
| 118 | s045-admin-pkhr-departments | admin/pkhr/departments | SHELL-ONLY | SHELL-ONLY | Frame with an inline Add Department form and a plain department/headcount register over real counts; the vendor composition is a department card list beside a d |
| 119 | s046-admin-pkhr-designations | admin/pkhr/designations | SHELL-ONLY | SHELL-ONLY | Vendor frame and a real designation register with live headcounts and Active pills, but staging leads with an inline Add Designation form and drops the vendor c |
| 120 | s047-admin-pkhr-disabled | admin/pkhr/disabled | SHELL-ONLY | SHELL-ONLY | Vendor frame with an honest empty state ('No disabled staff records') under disabled-specific columns, but there is no search/toolbar or any of the vendor Staff |
| 121 | s048-admin-pkcommunicate-notices | admin/pkcommunicate/notices | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame, breadcrumb and Compose Notice action with an honest empty card ('No notices published yet'), but the vendor's defining blocks are absent: no searc |
| 122 | s049-admin-pkcommunicate-email | admin/pkcommunicate/email | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling; staging is a clean vendor-frame compose form (template, deliver-at, title, message, staff/student recipient lists  |
| 123 | s050-admin-pkcommunicate-sms | admin/pkcommunicate/sms | DOES-NOT-RESEMBLE | SHELL-ONLY | Staging is only a simple compose form (template/title/message/recipient lists) in the vendor frame; the vendor Send SMS page's defining blocks are absent: phone |
| 124 | s051-admin-pkcommunicate-logs | admin/pkcommunicate/logs | DOES-NOT-RESEMBLE | SHELL-ONLY | Frame with a single log row plus a Purge card, with defects: raw HTML (<p>Dear Parent...) shows clipped in the row and the Status text renders tiny; vendor's fo |
| 125 | s052-admin-pkcommunicate-schedule | admin/pkcommunicate/schedule | DOES-NOT-RESEMBLE | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 126 | s053-admin-pkstudents-bulkmail | admin/pkstudents/bulkmail | SHELL-ONLY | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling; page is only a Class/Section picker with a List students button in the vendor frame, and carries system-prose ('th |
| 127 | s054-admin-pkcommunicate-email-templates | admin/pkcommunicate/email-templates | DOES-NOT-RESEMBLE | SHELL-ONLY | Frame present but composition is an Add template form over a plain Title/Message register, unlike the vendor settings card grid of templates with edit/delete ti |
| 128 | s055-admin-pkcommunicate-sms-templates | admin/pkcommunicate/sms-templates | DOES-NOT-RESEMBLE | SHELL-ONLY | Frame with an Add template form over a plain Title/Message register whose rows clip at the right edge; vendor's four stat cards, search/status filter and channe |
| 129 | s056-admin-contenttype | admin/contenttype | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | No vendor pair; the interior is legacy-styled (striped grey DataTables list with legacy blue edit/delete buttons and 50-per-page/export furniture) rather than t |
| 130 | s057-admin-content-list | admin/content/list | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | No vendor pair; interior is a legacy DataTables empty render ('No data available in table', legacy illustration, green add-record text, legacy export icons) ins |
| 131 | s058-admin-content-upload | admin/content/upload | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | No vendor pair; the content grid is the legacy file-manager styling and every one of the 9 documents is a lane fixture (TEST STAFF M3 / TEST-M3-001, w2b-doc.txt |
| 132 | s059-admin-video-tutorial | admin/video_tutorial | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling; vendor frame and card hold a Class/Section/title filter with an Add action and an honest empty result, but the emp |
| 133 | s060-admin-pkacademics-homework | admin/pkacademics/homework | SHELL-ONLY | PENDING | capture not yet landed |
| 134 | s061-admin-pkacademics-assignments | admin/pkacademics/assignments | SHELL-ONLY | SHELL-ONLY | Vendor frame and breadcrumb present but page is only an empty-state card; vendor Homework tabs, search toolbar, quick chips and dense submission register are ab |
| 135 | s062-admin-pkops-library | admin/pkops/library | DOES-NOT-RESEMBLE | SHELL-ONLY | Stat cards plus an inline Add Book form and a catalogue register in vendor-like columns, but vendor search toolbar, quick chips and inventory progress bars are  |
| 136 | s063-admin-pkops-library-members | admin/pkops/library_members | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with two add-member forms above a sparse register matching vendor column headings, but vendor toolbar, quick chips and rich library-detail badges a |
| 137 | s064-admin-pkops-inventory-issue | admin/pkops/inventory_issue | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY; vendor frame with Issue form and Allocations register is present. All 11 allocation rows are W2A Probe/Script fixtures |
| 138 | s065-admin-pkops-inventory-stock | admin/pkops/inventory_stock | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with Add Stock form and Stock records register, but vendor Stock Management stat strip, search toolbar and quick chips are absent. All rows are W2A |
| 139 | s066-admin-pkops-inventory | admin/pkops/inventory | DOES-NOT-RESEMBLE | SHELL-ONLY | Three small stat cards plus Add Asset form and Assets register, unlike vendor Assets 5-stat strip, toolbar/quick chips and department/assignee register. All 9 r |
| 140 | s067-admin-pkops-inventory-categories | admin/pkops/inventory_categories | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY; vendor frame with Add Category form and Categories register over 10 real default categories. The lower half of the reg |
| 141 | s068-admin-pkops-inventory-stores | admin/pkops/inventory_stores | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY; vendor frame with Add Store form and a clean Stores register of 5 governed default stores with zero stock records. Com |
| 142 | s069-admin-pkops-inventory-suppliers | admin/pkops/inventory_suppliers | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY; vendor frame with Add Supplier form and an honest empty state ('No suppliers yet'). No register composition beyond the |
| 143 | s070-admin-pkops-transport-fees | admin/pkops/transport_fees | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY; vendor frame containing only a month-by-month Transport Fees Master grid form (due date, fine type/amount, percentage, |
| 144 | s071-admin-pkops-transport-points | admin/pkops/transport_points | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with Add Pickup Point form and a register using vendor column headings, plus an extra route-scheduling form, but vendor toolbar, quick chips, statu |
| 145 | s072-admin-pkops-transport | admin/pkops/transport | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with three honest zero stat cards, an Add Route form and an empty register card; vendor Routes toolbar, quick chips and dense route/transport-detai |
| 146 | s073-admin-pkops-transport-vehicles | admin/pkops/transport_vehicles | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with a large Add Vehicle form and an empty Fleet card ('No vehicles yet'); vendor Vehicles toolbar, quick chips and compliance/status register are  |
| 147 | s074-admin-pkops-transport-assign | admin/pkops/transport_assign | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with a single Assign form (route/vehicles) and an empty Assignments card; vendor Assign Vehicle stat strip, toolbar/quick chips and assignment regi |
| 148 | s075-admin-pkops-transport-students | admin/pkops/transport_students | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame containing only an empty-state line ('No student has transport assigned in the current session'); vendor Assign Students stat strip, toolbar and st |
| 149 | s076-admin-pkops-hostel-rooms | admin/pkops/hostel_rooms | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with Add Room form and an empty Rooms card explaining prerequisites; vendor Hostel Rooms toolbar, quick chips and occupancy/facilities register are |
| 150 | s077-admin-pkops-hostel-types | admin/pkops/hostel_types | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with Add Room Type form and an empty Room types card; vendor Room Type toolbar, quick chips and configuration/hostel-details register are absent. |
| 151 | s078-admin-pkops-hostel | admin/pkops/hostel | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame with three honest zero stat cards, an Add Hostel form and a styled empty state; vendor Hostel toolbar, quick chips and hostel-details/facilities re |
| 152 | s079-admin-pkcertificates-certificates | admin/pkcertificates/certificates | SHELL-ONLY | SHELL-ONLY | Vendor frame with a 9-row certificate templates register and a large create-template form below, whereas the vendor pair is an issued Certificate Records regist |
| 153 | s080-admin-pkcertificates-generate | admin/pkcertificates/generate | SHELL-ONLY | SHELL-ONLY | Page is only a search desk (Class/Section/Certificate selects with Search) in the vendor frame; vendor Generate Certificates stat strip, toolbar/quick chips and |
| 154 | s081-admin-pkstudents-idcard-templates | admin/pkstudents/idcard_templates | SHELL-ONLY | SHELL-ONLY | Two stat cards (0 Designs, 1,683 Enrolled Students) and an empty designs table above a Create-a-design form, but vendor ID Card Templates 5-stat strip, toolbar/ |
| 155 | s082-admin-pkstudents-idcards | admin/pkstudents/idcards | SHELL-ONLY | SHELL-ONLY | Search desk only: two stat cards (0 Designs, 1,683 Enrolled Students) plus Class/Section selects and List students button, with system-prose about the 'unified  |
| 156 | s083-admin-pkcertificates-staff-idcard-templates | admin/pkcertificates/staff_idcard_templates | SHELL-ONLY | SHELL-ONLY | Vendor frame and a real 15-row template register are present, but the vendor stat strip, search/filter toolbar and quick chips are absent; staging uses its own  |
| 157 | s084-admin-pkcertificates-staff-idcards | admin/pkcertificates/staff_idcards | SHELL-ONLY | SHELL-ONLY | Staging is only a Role/Template search desk with a Search button and no results area; the vendor stat strip (Total/Generated/Printed/Issued/Pending) and dense I |
| 158 | s086-admin-pkcms-gallery | admin/pkcms/gallery | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with an Add-gallery form and honest 'No galleries on file' empty state; the Photos field shows clipped r |
| 159 | s087-admin-pkcms-notices | admin/pkcms/notices | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Vendor-styled frame with an Add news item form and honest 'No news items on file' empty state; composition is the work |
| 160 | s088-admin-pkcms-media | admin/pkcms/media | SHELL-ONLY | SHELL-ONLY | Vendor File Manager's Overview type cards, folder/file/video card sections, storage panel and All Files register are absent; staging is an upload/YouTube form o |
| 161 | s089-admin-pkcms-pages | admin/pkcms/pages | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with an Add-page form over a real pages register (Home, Complaint, 404, Contact, About), all shown Activ |
| 162 | s090-admin-pkcms-menus | admin/pkcms/menus | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with real Main/Bottom menu data and item/order tables, but composition is stacked add-menu, add-item and |
| 163 | s091-admin-pkcms-banners | admin/pkcms/banners | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with a pick-from-media form and a single banner row shown only as a raw filename with no thumbnail previ |
| 164 | s092-admin-pkstudents-alumni | admin/pkstudents/alumni | SHELL-ONLY | PENDING | capture not yet landed |
| 165 | s093-admin-pkstudents-alumni-events | admin/pkstudents/alumni_events | SHELL-ONLY | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with an empty Events (0) register and a Create-an-event form below; honest empty state in the workspace' |
| 166 | s094-admin-pksettings-reports | admin/pksettings/reports | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor Academic Reports' report-on toolbar, filters, stat tiles and report register are absent; staging is a grouped index of tiny report links in cards, labell |
| 167 | s095-admin-pkattendance-reports | admin/pkattendance/reports | SHELL-ONLY | SHELL-ONLY | Staging has its own month picker, five summary stat cards and class/below-75%/late tables over real November 2026 data, but the vendor report-on toolbar, quick  |
| 168 | s096-admin-pkops-hostel-allocate | admin/pkops/hostel_allocate | OWED-RA1 | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with an Allocate-a-student card (Student/Room selects) and an honest 'No student is allocated to a hoste |
| 169 | s097-admin-userlog | admin/userlog | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | Legacy DataTable render stuck on 'Loading...' with no rows, an overlapping duplicated 'User Log' tab label, and none of the vendor Login Activity stat cards or  |
| 170 | s098-admin-audit | admin/audit | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor Audit Log's six stat cards and Activity-by-Module/Event Types charts are absent; staging is a legacy grey-striped DataTable register (19,016 entries, rig |
| 171 | s099-admin-pkacademics-homework-reports | admin/pkacademics/homework_reports | OWED-RA1 | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with three stat cards and a homework register, but only two rows, both set by 'Demo Teacher', and the Ev |
| 172 | s100-admin-pksettings-general | admin/pksettings/general | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor School Settings is a tabbed five-field configuration form; staging is a very long stacked multi-section form (school, logos, fees, ID, attendance, theme, |
| 173 | s101-admin-pksettings-sessions | admin/pksettings/sessions | SHELL-ONLY | SHELL-ONLY | Vendor Academic Year is a settings-nav plus institution/year form with toggles; staging is an Add-session field over a plain session list 2016-17 to 2029-30 wit |
| 174 | s102-admin-pkcommunicate-settings | admin/pkcommunicate/settings | OWED-RA1 | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with a 36-type notification checkbox matrix and honest not-configured headers for email/SMS/WhatsApp; th |
| 175 | s103-admin-pksettings-sms | admin/pksettings/sms | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor SMS Settings' provider/delivery header panel, section nav, toggle cards and messaging timeline are absent; staging is a long stack of per-gateway credent |
| 176 | s104-admin-pksettings-email | admin/pksettings/email | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor Email Settings' header with SMTP handshake panel, settings nav, outbound/localisation cards and Mail activity timeline are absent; staging is a single pl |
| 177 | s105-admin-pksettings-payments | admin/pksettings/payments | OWED-RA1 | SHELL-ONLY | No vendor pair, so ceiling is SHELL-ONLY. Frame present with an Active payment method selector and a long stack of per-gateway credential cards, all honestly ma |
| 178 | s106-admin-pksettings-printsettings | admin/pksettings/printsettings | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame and page head are present, but staging is a stack of per-document header/footer cards with real footer text; the vendor Invoice Settings stat strip |
| 179 | s107-admin-pksettings-frontcms | admin/pksettings/frontcms | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling: full vendor frame with page head and a complete governed Front CMS settings form (theme, language, social links, s |
| 180 | s108-admin-pksettings-roles | admin/pksettings/roles | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor frame with add-role form and a register of the six real system roles with Permissions/Rename/Delete actions. Data ca |
| 181 | s109-admin-admin-backup | admin/admin/backup | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor shell and styled cards are present but there is no page head/breadcrumb, and the composition is the workspace's own Backup History (empty) + Upload + Cro |
| 182 | s110-admin-users | admin/users | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor frame with page head, Staff/Parent/Student/Users tabs and a dense register of 1,671 real student user accounts with  |
| 183 | s112-admin-module | admin/module | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): tabbed (Parent/Student/System) register of all 35 real modules with enable toggles inside the vendor shell, though the page |
| 184 | s113-admin-customfield | admin/customfield | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame and page head are present, but staging is only a generic Add Custom Field form beside an empty Custom Field List card; the vendor's stat strip, mod |
| 185 | s114-admin-captcha | admin/captcha | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a Captcha Setting card listing the six real captcha targets (User login, Admission, Complaint, Contact Us |
| 186 | s115-admin-systemfield | admin/systemfield | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): tabbed Staff/Student toggle register of all 44 real system fields in the vendor shell; page head/breadcrumb is missing, the |
| 187 | s116-admin-pkstudents-profilesetting | admin/pkstudents/profilesetting | SHELL-ONLY | SHELL-ONLY | Vendor frame and page head are present, but staging is the workspace's own field-editable toggle register plus a Student/Parent dashboard-module toggle table; t |
| 188 | s117-admin-onlineadmission-admissionsetting | admin/onlineadmission/admissionsetting | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor frame with page head and a tabbed settings card (admission/payment toggles, form upload, instructions and terms edit |
| 189 | s118-admin-admin-filetype | admin/admin/filetype | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): a single vendor-styled card holding the real governed file/image extension, MIME-type and upload-size settings; no page hea |
| 190 | s119-admin-updater | admin/updater | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair: the page is a single vendor-styled card with an honest policy notice that the vendor purchase-code updater was removed and only signed Rektrs de |
| 191 | s120-admin-sidemenu | admin/sidemenu | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a two-column Menu List / Selected Sidebar Menus card over the real governed menu set; no page head, and t |
| 192 | s121-onlinecourse-course-index | onlinecourse/course/index | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a Course List card (search, grid/list toggles, Add Course) in an honest empty state; no page head, and th |
| 193 | s122-onlinecourse-offlinepayment-payment | onlinecourse/offlinepayment/payment | DOES-NOT-RESEMBLE | SHELL-ONLY | Staging is a Class/Section/Student search desk over an empty results register with no page head; the vendor Online Payments stat strip, quick-filter chips and d |
| 194 | s123-onlinecourse-coursecategory-categoryadd | onlinecourse/coursecategory/categoryadd | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with the standard add-form + list composition (Add Category beside an empty Category List); no page head, and  |
| 195 | s124-admin-gmeet-timetable | admin/gmeet/timetable | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a Live Classes register card, but the register's only row is a lane fixture — 'W2GMEET Test Class (stagin |
| 196 | s125-admin-gmeet-meeting | admin/gmeet/meeting | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a Live Meeting register card (search, Add) in an honest empty state; no page head, and the empty state us |
| 197 | s126-admin-gmeet-class-report | admin/gmeet/class_report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): the page is only a Select Criteria search card (Class + Section + Search) inside the vendor shell — a search desk with no r |
| 198 | s127-admin-gmeet-meeting-report | admin/gmeet/meeting_report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY): vendor shell with a Live Meeting Report register card in an honest empty state; no page head, and the empty state uses the  |
| 199 | s128-admin-gmeet-index | admin/gmeet/index | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Full vendor frame with a clean Setting card (API Key/Secret, Google Calendar and Parent Live Class Disabled/Enable |
| 200 | s129-admin-conference-timetable | admin/conference/timetable | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed 'Live Classes' register card with search toolbar, export icons, Add button and full column set over an honest |
| 201 | s130-admin-conference-meeting | admin/conference/meeting | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed 'Live Meeting' register with toolbar, Add button and meeting columns over an honest empty state; frame and ty |
| 202 | s131-admin-conference-class-report | admin/conference/class_report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame present, but the page is only a 'Select Criteria' search desk (Class/Section selects + Search) with no report  |
| 203 | s132-admin-conference-meeting-report | admin/conference/meeting_report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed 'Live Meeting Report' register with search toolbar and report columns (incl. Total Join) over an honest empty |
| 204 | s133-admin-conference | admin/conference | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed Zoom Setting card with API key/secret fields, client toggles and Get Access Token; the 'Access Token not gene |
| 205 | s134-onlinecourse-coursereport-report | onlinecourse/coursereport/report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed 'Online Course Report' card holding a plain three-column link list of ten report types — frame is vendor, com |
| 206 | s136-admin-feesforward | admin/feesforward | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Full vendor frame with page head, breadcrumb and a 'Select Criteria' card (Class/Section + Search, Delete Carry Forward act |
| 207 | s137-admin-feereminder-setting | admin/feereminder/setting | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame with page head/breadcrumb and a Fees Reminder settings table (Active toggles, Before/After types, day values 2 |
| 208 | s138-admin-currency | admin/currency | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed Currencies register with search and pagination over real data — 179 currencies, editable symbol/rate cells an |
| 209 | s139-admin-pkstudents-behaviour-assign | admin/pkstudents/behaviour_assign | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame with page head, breadcrumb and Incident Types action, but the body is only a Class/Section search desk with no |
| 210 | s140-admin-pkstudents-behaviour-incidents | admin/pkstudents/behaviour_incidents | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed Incident Types register (12 types with signed points) plus create form; caveats: two rows are lane fixtures ( |
| 211 | s141-admin-pkstudents-behaviour-report | admin/pkstudents/behaviour_report | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed report with filter row and class-wise, section-wise, house-wise and incident-wise rank tables over real gover |
| 212 | s142-admin-pkstudents-behaviour-settings | admin/pkstudents/behaviour_settings | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame with page head/breadcrumb, but the settings body is minimal — a single 'Comment options' block (Student/Parent |
| 213 | s144-admin-pkacademics-lesson-copy | admin/pkacademics/lesson_copy | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame with page head/breadcrumb and a 'Source plan' card (Session/Class/Section/Subject group/Subject selects + Brow |
| 214 | s145-admin-gauthenticate-admin-setup | admin/gauthenticate/admin/setup | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed 'Setup the Two Factor Authentication Method' card with an info banner honestly stating 2FA is enabled with a  |
| 215 | s146-admin-gauthenticate-admin | admin/gauthenticate/admin | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed Setting card holding a single TFA toggle (on) and Save — frame and controls are vendor-styled but the composi |
| 216 | s147-onlinecourse-course-setting | onlinecourse/course/setting | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame with three stacked settings cards — Online Course Curriculum toggles, AWS S3 Bucket Setting (empty credential  |
| 217 | s155-admin-qrattendance-attendance-index | admin/qrattendance/attendance/index | OWED-RA1 | PENDING | capture not yet landed |
| 218 | s156-admin-qrattendance-qrsetting-index | admin/qrattendance/qrsetting/index | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor-framed QR Setting card with Auto Attendance toggle, scanner device-type checkboxes and camera selection radios plus  |
| 219 | s157-admin-pkhr-holidays | admin/pkhr/holidays | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY), and the fixture rule also caps it here: vendor frame with stat strip (14 total / 9 upcoming), Add Holiday form, Holiday Typ |
| 220 | s158-admin-resume-download | admin/resume/download | OWED-RA1 | SHELL-ONLY | No vendor pair (ceiling SHELL-ONLY). Vendor frame present, but the Download CV page renders only a 'Select Criteria' search card (Class/Section + Search) with n |
| 221 | s159-admin-resume-index | admin/resume/index | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Full vendor frame (sidebar, topbar, card) with a Select Criteria card (Class/Section + Search) and a Setting butto |
| 222 | s160-admin-addons | admin/addons | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with an upload strip and a governed 3-column card grid of 11 real addons (name, description, version, |
| 223 | s161-admin-thermalprint-index | admin/thermalprint/index | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame settings card with toggle, school name, address and footer text populated from real school data and a |
| 224 | s162-onlinecourse-courseexamquestion-index | onlinecourse/courseexamquestion/index | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with a Select Criteria card (tag/type/level/created-by, Add Tag/Add Question/Import/Bulk Delete actio |
| 225 | s164-onlinecourse-coursecertificate-templatelist | onlinecourse/coursecertificate/templatelist | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame register with search, export tools and Add button; the only rows are the four seeded 'Sample Transfer |
| 226 | s165-admin-transfercertificate-download | admin/transfercertificate/download | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with a Select Criteria card (Class/Section + Search) and a Verify TC action; like the Collect Fees ca |
| 227 | s166-admin-rektrslicense | admin/rektrslicense | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame platform page: license status table (ACTIVE, holder IQRS, bound/current host), entitlement chips, rec |
| 228 | s167-admin-customaddondeployment | admin/customaddondeployment | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with stat strip (8 installed / 17 staged), tab bar and a real module register; a system-prose banner  |
| 229 | s168-admin-advancedfeematrix | admin/advancedfeematrix | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame workspace: header actions, tab bar, Draft-Validate-Approve-Post-Reconcile step strip and a fee work q |
| 230 | s169-admin-consolidatedfinance | admin/consolidatedfinance | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame family-collection workspace with three honest 0.00 stat tiles, Find Family search, dues table in an h |
| 231 | s170-admin-pakistanfeepolicypacks | admin/pakistanfeepolicypacks | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame Setup Center with stat strip (32 packs, 36 runs, 669 defaults), a large governed pack card grid with  |
| 232 | s171-admin-frontofficedefaults | admin/frontofficedefaults | DOES-NOT-RESEMBLE | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame setup page with stat cards (65 recommended / 58 configured / 7 missing), five category cards with rea |
| 233 | s172-admin-legacyaddonbundle | admin/legacyaddonbundle | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with stat strip (11 packages / 9 installed & active) and an Addon Health & Deployment register of the |
| 234 | s173-whatsappconfig-index | whatsappconfig/index | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame tabbed settings card (Meta WhatsApp Official / Twilio) with token, phone, language and status fields; |
| 235 | s174-admin-schoolextensions | admin/schoolextensions | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame card grid of the 12 operational workspaces with honest '0 open · 0 critical' counts; the headline 'Op |
| 236 | s175-admin-printsection | admin/printsection | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page head with breadcrumb (Dashboard / Print & Documents / Certificates & Letters) over a governed issuance |
| 237 | s176-admin-bulkfeeprinting | admin/bulkfeeprinting | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame tabbed print setup (Print Setup / Branding & Settings / Print History) with a numbered 3-step scope-s |
| 238 | s177-admin-household | admin/household | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page head with breadcrumb, search card and a dense Household List register of real governed families (guard |
| 239 | s178-admin-pkfees | admin/pkfees | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Rich vendor-frame fees overview over real governed figures (Rs 9,720,210 assigned, balance-by-class bars, structur |
| 240 | s179-admin-printcenter | admin/printcenter | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame is present and the document catalogue tables (fees, payroll, exams, certificates) carry real counts ( |
| 241 | s180-admin-printcenter-history | admin/printcenter/history | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with two real registers (406 print-register documents, 99 fee-receipt generations); the generation lo |
| 242 | s181-admin-printcenter-examgate | admin/printcenter/examgate | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame with page head, exam picker, gate actions and an override register showing one real row (Exam #20, 1  |
| 243 | s182-admin-examrecheck | admin/examrecheck | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame is present (shell, cards, vendor typography) but the body is the workspace's own intake form over an  |
| 244 | s183-admin-pkacademics | admin/pkacademics | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Full vendor frame with stat cards over real governed data (12 classes, 1,683 enrolments) plus real Classes & secti |
| 245 | s184-admin-pkattendance | admin/pkattendance | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page-head, stat strip, class/section/date filter and a dense whole-school register plus a real student mark |
| 246 | s185-admin-pkexams | admin/pkexams | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page-head and breadcrumb with two form-plus-register cards: 8 real exam groups with status/action furniture |
| 247 | s186-admin-pkstudents | admin/pkstudents | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor frame and register composition match closely (same Student/Status/Class/Section/Gender/Date of Join/Actions columns, status pills, real governed data — 1 |
| 248 | s187-admin-pkhr | admin/pkhr | SHELL-ONLY | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame is present but the body is the workspace's own label/value census tables rather than vendor card comp |
| 249 | s188-admin-pkops | admin/pkops | SHELL-ONLY | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page-head and breadcrumb over a module-states table with honest Working / Not set up states (Zoom/GMeet not |
| 250 | s189-admin-pkgate | admin/pkgate | DOES-NOT-RESEMBLE | SHELL-ONLY | Vendor Gate Entry is a stat strip + quick chips + dense entry register; staging is a Gate Lookup search desk with a shift step-up card and heavy system-prose —  |
| 251 | s190-admin-pkguardian | admin/pkguardian | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. The body is two vendor-styled cards — a number-changes panel with policy system-prose and an honest 'no changes wa |
| 252 | s191-admin-pksafeguarding | admin/pksafeguarding | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. A single vendor-styled card with tab pills and three honestly empty referral/case registers; the composition is th |
| 253 | s192-admin-pkpayroll | admin/pkpayroll | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Page title and vendor pill tabs are present, but the body is bare uncarded headings and empty-state lines dominate |
| 254 | s193-admin-pkcafeteria | admin/pkcafeteria | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor title, alert banner and tab pills over honest empty states (no menu dishes, no open shift, no orders), but  |
| 255 | s194-admin-pkfrontoffice | admin/pkfrontoffice | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page-head and breadcrumb over a single card listing live front-office positions (0 visitors/passes, 9 real  |
| 256 | s195-admin-pkcommunicate | admin/pkcommunicate | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Clean vendor page-head, breadcrumb and Compose Notice action over one card with an honest empty state ('No notices |
| 257 | s196-admin-pkmoneywatch | admin/pkmoneywatch | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor title and pill tabs over real governed data — open findings by family and a 13-row sweep-runs register with |
| 258 | s197-admin-pkpayables | admin/pkpayables | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor title and tab pills over an all-zero summary table and honestly empty invoice/notice sections, but the intr |
| 259 | s198-admin-pkledger | admin/pkledger | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor title and tab pills over a ledger-at-a-glance table (balanced Rs 0.00, honest zero journals) and a real tri |
| 260 | s199-admin-pkthemestore | admin/pkthemestore | OWED-RA1 | SHELL-ONLY | No vendor pair (platform surface), so SHELL-ONLY is the ceiling. Vendor typography and buttons over real data — active PreSkool theme, installed-themes table, i |
| 261 | s200-admin-pkappstore | admin/pkappstore | OWED-RA1 | SHELL-ONLY | No vendor pair (platform surface), so SHELL-ONLY is the ceiling. A long, complete module registry in vendor typography — stores, 19 workspaces, 10 add-ons, 25 s |
| 262 | s201-admin-pkfees-overview | admin/pkfees/overview | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling: full vendor frame with Fees Master command-center card, collection progress bar, structure due-dates list, Quick A |
| 263 | s202-admin-pkfees-assignments | admin/pkfees/assignments | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. This is a full vendor register composition: page-head, breadcrumb, class/section filter card, toolbar and a dense  |
| 264 | s203-admin-pkfees-billing | admin/pkfees/billing | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Full vendor register furniture — page-head, date-range filter, search/columns/sort toolbar, pagination — over 1,57 |
| 265 | s204-admin-pkfees-collections | admin/pkfees/collections | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling; vendor frame, search/Saved Views toolbar, Quick door chips and a clean collections register are present, but the r |
| 266 | s205-admin-pkfees-allocations | admin/pkfees/allocations | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. The register composition is vendor-grade (page-head, journal summary card, search/sort toolbar), but the visible r |
| 267 | s206-admin-pkfees-arrears | admin/pkfees/arrears | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor page-head with ageing-bucket chips and a dense real register (952 carried masters, Rs 5,697,860 owing, real |
| 268 | s207-admin-pkfees-discounts | admin/pkfees/discounts | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame is fully present (page head, breadcrumb, card, search/sort toolbar, dense register) over real governe |
| 269 | s208-admin-pkfees-fines | admin/pkfees/fines | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame present (page head, breadcrumb, card, search toolbar, register with totals row) over real data (one m |
| 270 | s209-admin-pkfees-corrections | admin/pkfees/corrections | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame and two register cards (household receipts + tombstones) are present, but the working list is dominat |
| 271 | s210-admin-pkfees-offline | admin/pkfees/offline | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame present (page head, breadcrumb, verification-queue card with search/sort toolbar), and the no-gateway |
| 272 | s211-admin-pkfees-income | admin/pkfees/income | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame present (page head, breadcrumb, Add Income form card, register card with search/sort toolbar), but al |
| 273 | s212-admin-pkfees-expenses | admin/pkfees/expenses | OWED-RA1 | SHELL-ONLY | No vendor pair, so SHELL-ONLY is the ceiling. Vendor frame present (page head, breadcrumb, Add Expense form card, register card with search/sort toolbar), but a |
| 274 | s213-admin-pkfees-reports | admin/pkfees/reports | OWED-RA1 | PENDING | capture not yet landed |
| 275 | s214-admin-pkstudents-overview | admin/pkstudents/overview | OWED-RA1 | PENDING | capture not yet landed |
| 276 | s215-admin-pkstudents-students | admin/pkstudents/students | OWED-RA1 | PENDING | capture not yet landed |
| 277 | s216-admin-pkstudents-profile | admin/pkstudents/profile | OWED-RA1 | PENDING | capture not yet landed |
| 278 | s217-admin-pkstudents-lifecycle | admin/pkstudents/lifecycle | OWED-RA1 | PENDING | capture not yet landed |
| 279 | s218-admin-pkstudents-promotion | admin/pkstudents/promotion | OWED-RA1 | PENDING | capture not yet landed |
| 280 | s219-admin-pkstudents-behaviour | admin/pkstudents/behaviour | OWED-RA1 | PENDING | capture not yet landed |
| 281 | s220-admin-pkstudents-downloads | admin/pkstudents/downloads | OWED-RA1 | PENDING | capture not yet landed |
| 282 | s221-admin-pkacademics-overview | admin/pkacademics/overview | OWED-RA1 | PENDING | capture not yet landed |
| 283 | s222-admin-pkacademics-analytics | admin/pkacademics/analytics | OWED-RA1 | PENDING | capture not yet landed |
| 284 | s223-admin-pkattendance-period | admin/pkattendance/period | OWED-RA1 | PENDING | capture not yet landed |
| 285 | s224-admin-pkattendance-qr | admin/pkattendance/qr | OWED-RA1 | PENDING | capture not yet landed |
| 286 | s225-admin-pkattendance-biometric | admin/pkattendance/biometric | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 287 | s226-admin-pkexams-exams | admin/pkexams/exams | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 288 | s227-admin-pkexams-schedule | admin/pkexams/schedule | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 289 | s228-admin-pkexams-marks | admin/pkexams/marks | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 290 | s229-admin-pkexams-results | admin/pkexams/results | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 291 | s230-admin-pkexams-grades | admin/pkexams/grades | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 292 | s231-admin-pkexams-online | admin/pkexams/online | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 293 | s232-admin-pkexams-cbse | admin/pkexams/cbse | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 294 | s233-admin-pkhr-overview | admin/pkhr/overview | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 295 | s234-admin-pkhr-profile | admin/pkhr/profile | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 296 | s235-admin-pkhr-review | admin/pkhr/review | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 297 | s236-admin-pkhr-payroll | admin/pkhr/payroll | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 298 | s237-admin-pkcommunicate-centre | admin/pkcommunicate/centre | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 299 | s238-admin-pkcommunicate-whatsapp | admin/pkcommunicate/whatsapp | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 300 | s239-admin-pkcommunicate-chat | admin/pkcommunicate/chat | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 301 | s240-admin-pkcommunicate-calendar | admin/pkcommunicate/calendar | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 302 | s241-admin-pkcommunicate-todo | admin/pkcommunicate/todo | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 303 | s242-admin-pkfrontoffice-gatepass | admin/pkfrontoffice/gatepass | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 304 | s243-admin-pkfrontoffice-exitpass | admin/pkfrontoffice/exitpass | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 305 | s244-admin-pkfrontoffice-verify | admin/pkfrontoffice/verify | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 306 | s245-admin-pkfrontoffice-appointments | admin/pkfrontoffice/appointments | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 307 | s246-admin-pkstudents-parents | admin/pkstudents/parents | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 308 | s247-admin-pkstudents-guardians | admin/pkstudents/guardians | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 309 | s248-admin-pkhr-teachers | admin/pkhr/teachers | OWED-RA1 | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 310 | x-err404 | admin/ra2-no-such-page | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
| 311 | x-student-edit-3699 | student/edit/3699 | DOES-NOT-RESEMBLE | DOES-NOT-RESEMBLE | HTTP 500 — same FC-15 wiring defect: curl proof (14,753 bytes, dies after the Religion label) + CI log 2026-11-23 08:57:04 PKT, studentEdit.php:230, identical e |
| 312 | x-teacher-dashboard | admin/admin/teacher_dashboard | NEW | PENDING | capture not landed - VM headless Chromium failure (SIGILL at startup / CDP targets never appear) across both audit lanes; re-attempted 2026-11-23, still failing |
