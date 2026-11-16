# PreSkool Target Map v2 — Re-issued Against the Purchased Package (PKG-0, 2026-11-15)

**Machine-readable map:** `PRESKOOL-TARGET-MAP-V2-2026-11-15.csv` (same folder,
426 rows — one per vendor page of the frozen reference pack).
**Reference pack:** `PRESKOOL-REFERENCE-FREEZE-2026-11-15.md` (repo
`asadchoudharry/rektrs-preskool`, branch `html`, commit `ac39a717…`).
**Supersedes:** `hidden_files/preskool/pixel-perfect/pf0/PF0-TARGET-MAP.csv`
(394 rows, measured against the reconstruction) as amended by
`hidden_files/preskool/pixel-perfect/pf2/PF2-TARGET-MAP-UPDATE.csv`. Both old
files are **preserved unmodified** as evidence and are marked superseded by a
note filed beside them (`PF0-TARGET-MAP-SUPERSEDED.md` in the pf0 folder).

---

## 1. How the counts reconcile (all measured, 2026-11-15)

| Quantity | Count | Derivation |
|---|---:|---|
| Vendor pages in the frozen package | **426** | Root `*.html` of the `html` branch tree |
| Pages also present in the old map | 385 | Set intersection with the PF-0 map's demo pages |
| Vendor pages with **no** old-map counterpart | **41** | Set difference — dispositioned in §3 |
| Old-map rows total | 394 | 385 shared pages + 1 reconstruction-invented page (`notification-center.html`) + 8 IQRS-native rows with no demo page (annex, §4) |

## 2. Buckets (the 426 vendor pages)

| Bucket | Count | Meaning |
|---|---:|---|
| **KEEP-MATCH** | **309** | Vendor page has an IQRS surface; route/screen, family, module group, RM id and PF wave carried forward from the PF-0 map (PF-2 update applied where it exists). |
| **NEW** | **25** | Vendor page has no IQRS surface yet and is dispositioned BUILD-LATER in §3 (these are the feature-list **v7 candidate rows** the deployment plan's PKG-0 calls for). |
| **NOT-APPLICABLE** | **92** | No standalone IQRS surface: 76 pages the PF-0 map already classified pattern-reference-only (delta REF-ONLY, consumed via the component kit), plus the 15 REFERENCE-ONLY and 1 OUT-OF-SCOPE pages from §3. |
| **Total** | **426** | |

**Verdict reset (binding):** every prior verdict in the old map (PF-0:
MATCH 24 · DRIFT 126 · NOT-BUILT 168 · pattern-ref 76; PF-2 updates for 29
auth/dashboard rows) was earned **against the reconstruction** and does **not**
carry into this map. The CSV keeps those verdicts in a clearly labelled
`prior_verdict_recon_era` column as history only. Under deployment plan §3,
each KEEP-MATCH surface is re-verified against its vendor page at **PKG-5**;
no surface keeps a verdict earned against the reconstruction.

## 3. The 41 new vendor pages — disposition table

Owner-visible before any build (deployment plan §6). BUILD-LATER rows are the
plan-following defaults — the pages PKG-6 names (online examination, question
bank, fee installments, digital ID card) plus pages mapping to real IQRS
functions — and enter the build waves only at their PKG-6 / PF-7 gates.
Nothing here is a new design: under the owner's no-invention rule these are
vendor pages awaiting mapping to real IQRS functions.

### BUILD-LATER (25)
| Vendor page | Module group | Wave | Reason |
|---|---|---|---|
| `add-alumni.html` | Students — alumni | PKG-6 / PF-7 | Alumni is a real IQRS function (pkstudents alumni tab exists as honest empty); page-per-function per D-039. |
| `ai-behavior-analysis.html` | Behaviour — deterministic AI | PF-7 (BL-050) | Enters via the approved BL-050 deterministic-AI scope only: rule-derived analysis over recorded behaviour data or honest empty; fabricated AI claims prohibited (D-004). BL-115 safeguarding precedes real-case use (D-037). |
| `ai-notification-assistant.html` | Communicate — deterministic AI | PF-7 (BL-050 / BL-047) | Compose-assist over real templates/data only; honest not-configured state until a rule set/provider exists (D-004). |
| `ai-scholarship-recommendation.html` | Fees — scholarships / deterministic AI | PF-7 (BL-050) | Recommendations computed only from recorded criteria and student data, else honest empty (D-004). Pairs with scholarship-management. |
| `ai-settings.html` | Settings — AI configuration | PF-7 | Configuration surface for the BL-050 feature set; ships with honest states for unconfigured capabilities. |
| `alumni-profile.html` | Students — alumni | PKG-6 / PF-7 | Pairs with add-alumni; alumni records are real IQRS data. |
| `behavior-discipline.html` | Students — behaviour & discipline | PF-7 | Behaviour workspace exists on staging; BL-115 safeguarding precedes any real-case use (D-037). |
| `call-history.html` | Communicate — call log | PF-7 (BL-047) | Call logs are a real Smart School/IQRS front-office + communicate function. |
| `daily-attendance.html` | Attendance — day-wise | PF-7 | Part of the vendor day-wise attendance set with no staging counterpart; attendance data is real IQRS data. |
| `digital-id-card.html` | Students — ID cards | PKG-6 / PF-7 | Named in the deployment plan PKG-6 scope; ID-card generation is a real IQRS function (Print Center adjacency, EX-001 discipline). |
| `edit-invoice.html` | Fees — invoices | PF-7 | Invoice editing exists in the vendor fee system; build sits under BL-141 fee-write hardening rules. |
| `fee-installments.html` | Fees — installments | PKG-6 / PF-7 | Named in the deployment plan PKG-6 scope; installment plans are a real fee function over governed fee data. |
| `leave-reports.html` | Reports — leave | PF-7 | Leave data already exists (pkattendance / pkhr); report surface per D-039 page-per-function. |
| `online-examination.html` | Examinations — online | PKG-6 / PF-7 | Named in the deployment plan PKG-6 scope; online exams are an approved IQRS feature direction. |
| `online-payment-receipts.html` | Fees — online payments | PF-7 | Receipts for gateway fee payments; honest not-configured state while no gateway is configured (EX-007 discipline). |
| `permission.html` | Settings — roles & permissions | PF-7 | Roles/permissions are a real IQRS admin function; sequencing respects the Identity Foundation order (D-037 / BD-077). |
| `question-bank.html` | Examinations — question bank | PKG-6 / PF-7 | Named in the deployment plan PKG-6 scope; pairs with online-examination. |
| `rewards-gamification.html` | Students — rewards | PF-7 | D-038 superset rule: theme-only features are real builds on the IQRS data model. Ships anatomy + honest empty until a governed rewards rule exists; no fabricated points (D-004). |
| `scholarship-management.html` | Fees — scholarships | PF-7 | Scholarship/discount administration is a real fee-domain function over governed data. |
| `staff-day-wise.html` | Attendance — staff day-wise | PF-7 | Part of the vendor day-wise attendance set; staff attendance data is real IQRS data. |
| `staff-report.html` | Reports — staff | PF-7 | Staff reporting over real HR data (pkhr). |
| `student-attendance-type.html` | Attendance — configuration | PF-7 | Attendance-type configuration is a real vendor/IQRS admin function. |
| `student-day-wise.html` | Attendance — day-wise | PF-7 | Part of the vendor day-wise attendance set. |
| `teacher-day-wise.html` | Attendance — day-wise | PF-7 | Part of the vendor day-wise attendance set. |
| `teacher-report.html` | Reports — teachers | PF-7 | Teacher reporting over real HR data (pkhr). |

### REFERENCE-ONLY (15)
| Vendor page | Module group | Wave | Reason |
|---|---|---|---|
| `form-elements.html` | Component reference — forms | PKG-4 | Vendor form-element source for the PKG-4 component kit; no standalone IQRS surface. |
| `plugins.html` | Component reference — plugins | PKG-1 / PKG-4 | Vendor plugin inventory/showcase page; reference for the PKG-1 vendoring set and PKG-4 kit, not an IQRS surface. |
| `sidebar.html` | Component reference — shell | PKG-3 | Vendor sidebar/layout showcase; anatomy reference for the PKG-3 shell swap, not an IQRS surface. |
| `status-cards-showcase.html` | Component reference — status cards | PKG-4 | Vendor component showcase; PKG-4 kit source only. |
| `ui-borders.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-counter.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-media.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-rangeslider.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-rating.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-ribbon.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-text-editor.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-timeline.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-toasts.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `ui-video.html` | Component reference — UI kit | PKG-4 | Vendor UI-component source page for the PKG-4 component kit; no standalone IQRS surface. |
| `v2-index.html` | Dashboard — variant reference | PKG-5 | Alternate v2.0 dashboard variant. index.html remains the D-038 flagship reference; this variant is held as reference for PKG-5 re-verification, not a second dashboard build. |

### OUT-OF-SCOPE (1)
| Vendor page | Reason |
|---|---|
| `index-old.html` | The vendor's own superseded pre-v2.0 dashboard. index.html (v2.0) is the frozen reference (D-038 flagship); building the old variant would contradict the freeze. |

## 4. Annex — rows of the old map that are not vendor pages (carried, unchanged)

These 9 rows have no row in the v2 CSV (which covers vendor pages only) and
are carried forward here so nothing from the old map is silently dropped:

- **8 IQRS-native rows** (no demo twin; PF-6 written pixel specs govern):
  Print Center catalogue/index (`admin/printcenter`); Print Center fee
  receipt + thermal receipt; Print Center reprint history + receipt log;
  exam print documents (marksheet / admit card / rank / notices); Household
  combined family statement PDF (`admin/household`); Household
  pay-once-allocate surface; application shell (header/sidebar/menu/footer —
  its vendor anatomy source is now the frozen package, PKG-3); portal shell
  (parent/student header + navigation — re-verified at PKG-5).
- **`notification-center.html`** — the reconstruction's one invented page;
  the vendor package has no such page. Its IQRS function mapping
  (`admin/notification`, BL-014/BL-047) is real; the invented page anatomy is
  dispositioned in the Invented-Pieces Register
  (`PRESKOOL-INVENTED-PIECES-REGISTER-2026-11-15.md`, INV-01) as
  OWNER-DECISION-NEEDED at PKG-5.

## 5. Method note (brief vs plan)

The deployment plan's PKG-0 text asks for "426 vendor pages ↔ IQRS routes"
with the 41 new pages dispositioned "into feature list v7". This re-issue
implements exactly that: the 25 BUILD-LATER rows in §3 are the v7 candidate
rows (each with its wave), and the bucket scheme (KEEP-MATCH / NEW /
NOT-APPLICABLE) is the map-level summary of the same dispositions. No other
difference from the plan was needed.
