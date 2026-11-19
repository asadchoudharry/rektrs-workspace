# D-027 Production Package — IQRS PreSkool Cutover

**Prepared:** 2026-11-19 · **Status: READY TO EXECUTE — NOT EXECUTED**
**Scope:** the single gated production cutover of the completed PreSkool build (decision D-027), covering the PKG/PF waves, the 11 replacement lanes (F1 · E1 · A1 · S1 · H1 · AC1 · C1 · CM1 · X1 · ST1 · AI1) and the refinement pass.
**Artefacts (lane dir `hidden_files/preskool/d027-2026-11-19/`):** `payload/` (6,549 files) · `payload-manifest.tsv` + `payload-manifest.md5` · `delete-manifest.tsv` (310 files) · `sql/M01–M06` + reversals `sql/R01–R06` · smoke battery `work/d027-smoke.sh` · evidence `exports/` · lane record `D027-LANE-RECORD.md`.
**Licence position (D-008, recorded per D-027):** PreSkool ThemeForest item 29532878, one Regular License, licensee Asad Choudhary, purchased 2026-11-15 (purchase code held locally; first-4 `6368`).

---

## 0. Gate statement — read first

**This package must not be deployed until BOTH gates are met:**

1. **The owner's own signed-in staging check** — Assad signs in to staging himself and checks the system in his own browser (his standing rule: a panel or a lane report saying "done" is not proof; his own check is).
2. **The owner's explicit production sign-off** — a clear go for THIS package, after gate 1.

Preparation made **zero writes to production**. Every production fact below comes from read-only probes run 2026-11-19 (SELECT / stat / md5sum / no-data dumps), each guarded by production's own `database.php` naming `u238632175_KliTy` before any query ran.

---

## 1. Production recon — actuals (2026-11-19, read-only)

### 1.1 Tree proofs

- Production web tree `~/domains/iqrs.edu.pk/public_html`; its `application/config/database.php` names **`u238632175_KliTy`** (guard asserted before every production query in every probe).
- The older file-size discriminator is **retired**: `api/application/controllers/Webservice.php` is now **339,356 B in BOTH trees** (the Nov-era staging 325,925 B / production 325,577 B pair is superseded — later apps-lane work landed on both trees). Tree identity rests on the DB-name guard, as in every lane since.

### 1.2 Production census vs the last production record (§9 of the 2026-11-15 combined deploy)

| Measure | §9 (2026-11-15) | Now (2026-11-19) | Note |
|---|---|---|---|
| Students | 1,682 | **1,683** | +1 — see drift note |
| Staff | 110 | **111** | +1 — see drift note |
| Student sessions | — | 1,682 | |
| Users | — | 3,365 | |
| Fee deposits | 1,546 | **1,546** | unchanged; newest deposit 2026-11-05 |
| Fee masters | — | 2,619 | |
| Exams / questions / online exams | 0 | **0 / 0 / 0** | production still holds no exams |
| Exam groups | — | 8 | the school's own standard groups (Monthly Test, Unit Test, First Term, Mid Term, Second Term, Final/Annual, Send-Up/Pre-Board, Mock/Practice) — 0 members, pre-existing configuration |
| Payslips | 1 | **1** | net Rs 13,000.00 |
| Certificate templates (`certificates`) | 9 | **9** | unchanged |
| ID cards (`id_card`) | 0 | **0** | `staff_id_card` holds 2 |
| Books / book issues | — | **0 / 0** | production library is empty (drives §5.3 sizing) |
| Student attendances / staff attendance | — | 3 / 0 | |
| Sidebar | — | 208 sub-menu rows, **206 active** | §2 |

**Drift attribution (complete, no unexplained movement):** the +1 student and +1 staff are the sibling apps lane's Play-review verification pair created **on production** on 2026-11-18 12:42 — student 3699 `DEMO-PLAYREVIEW-001` and staff 118 `VERIFY-PLAY-001`. They are demo/verification rows, not school enrolments. Everything else is byte-stable against §9. (Production student 3699 is a different row from staging's fixture student 3699 — same id, different databases.)

### 1.3 Production sidebar state (dumped, never assumed)

Production: **34 menus / 208 sub-menus (206 active)**. Staging end-state: **35 menus / 295 sub-menus (278 active)**. Recomputed from the two verified dumps:

- Sub-menus: all 208 production ids exist on staging; **140 rows differ functionally** (url 120 · activate_controller 93 · activate_methods 92 · level 33 · is_active 15 · menu/lang_key 3 each); **87 staging-only rows** (ids 243–329) are inserted; **production-only ids: 0**.
- Menus: **1 functional difference** (id 2 `Student Information` gains `('households', 'can_view')` in `access_permissions`); **1 staging-only menu** (id 41, Cafeteria) is inserted; production-only menus: 0.

The transaction is `sql/M06-sidebar-transaction.sql` (§5.5).

---

## 2. File delta — payload and deletions

Method: full md5 census of both trees (`application/`, `api/`, `backend/`, `assets/`, root files; uploads/caches/logs excluded) — production 76,332 files, staging 82,697, of which **75,559 are byte-identical**. The delta below is the complete difference, classified; nothing was sampled.

### 2.1 Payload — 6,549 files · 151,360,282 bytes · NEW 6,409 / REPLACE 140

| Area | NEW | REPLACE | Contents |
|---|---|---|---|
| `application/` | 426 | 139 | the workspaces, controllers, libraries, models, views of all lanes + earlier waves |
| `backend/` | 5,983 | 1 | 5,903 = `backend/dist/preskool-vendor/` (the PKG-1 vendored PreSkool asset tree, 132,565,630 B, 100% new); 80 = PF shell assets under `dist/{css,img,fonts,js}`; 5 = themes/custom_addons incl. the print-studio `navigation.js` replace |
| `application/config/payroll.php` | — | (in the 139) | BL-133 attendance-map fix; no environment values (§2.3) |

Attribution (exact src-md5 match where a lane source survives; buckets otherwise): PKG-1 vendor assets 5,903 · earlier programme waves (BL/PF era) 215 · PF shell assets 81 · ST1 58 · C1 53 · CM1 50 · AC1 30 · E1 30 · X1 28 · F1 24 (15 views byte-exact + its controller/library as later extended by ST1) · S1 23 · H1 21 · A1 17 · AI1 13 · refinement fixes 2 (`Student_model.php` `92629cf2…`, `Staff.php` `5d464360…`) · BL-133 1.

Every payload file sits in `payload/` at its exact relative path, mode 644, and was **md5-verified against the staging census after assembly: 6,549 / 6,549 match**. Gates at deploy time: `payload-manifest.md5` (md5sum -c format) + `payload-manifest.tsv` (path, md5, size, class, attribution).

### 2.2 Deletions — 310 files (all under `application/`)

Every production file that the proven staging end-state does not have, excluding production's own backup artefacts and runtime data (§2.4): `views/admin` 210 · `controllers/admin` 24 · `views/setting` 15 · `views/studentfee` 12 · `views/behaviour` 11 · `views/attendencereports` 9 · `views/homework` 7 · `views/reports` 6 · `views/student` 6 · `views/section` 4 · `views/class` 2 · `controllers/Studentfee.php` 1 · `views/emailconfig` 1 · `views/session` 1 · `views/smsconfig` 1. These are the legacy doors/views the lanes retired after their replacements were proven (per-lane lists in the lane records). `delete-manifest.tsv` carries each path with its production md5 at package time. The 4 portal-loaded views the refinement pass restored to staging are **not** in this list (they exist on staging; where production kept identical copies they are census-SAME).

### 2.3 Protected production files — NOT in the payload, asserted unchanged at deploy

| File | Why |
|---|---|
| `application/config/database.php` (+ api tree's) | production credentials + DB name; differs by design |
| `application/config/config.php` | differs from staging's **only** in `base_url` (verified by full diff) — production keeps its own |
| `application/config/rektrs_owner_license.php` | production's file is its **installation-bound owner licence** (claims bound to iqrs.edu.pk); staging's is a different staging-installed licence. Overwriting it would break the production entitlement. |

### 2.4 Named exclusions (in neither payload nor deletions)

- **Staging backup artefacts** (271 `*.bak-*` / `*.retired-*` files inside the staging tree) and the **`backend/wave5proto/`** prototype (4 files) — staging-only working residue, never shipped.
- **Runtime data** (181 files): staging's `application/private/print_issuance/` registry, mpdf font caches, `application/uploads/gate_denials/`, captcha images — production keeps its own live runtime data.
- **Staging-root module zips** (Rektrs Custom Module Manager / ownership-transition installers) — installer artefacts, not app code.
- **Production's own artefacts stay untouched:** 194 `*.bak-*`/`*.retired-*`/`*.fl033-parked` files and 15 `backup_*` DB tables from production's Nov-era work.

### 2.5 The api tree — reported, deliberately NOT shipped

The two `api/` trees have diverged independently of this programme (the mobile-apps programme ships production API fixes directly): staging-only 78 (mostly staging `.bak` artefacts; one live controller, `Familysessions.php`), differing 18 (incl. `Staffapi`, `Staffauth`, `Staffpull`, `Staffsync` + `Auth_model`, `Gateway_ins_model`, `Studentfeemaster_model`, `User_model` + runtime caches), production-only 27 (mostly production `.bak` artefacts). **D-027 ships none of it**: folding staging's api tree in would regress production API work, and the web cutover does not depend on it (the 11 lanes probed Staffapi read-only throughout; the Exam Centre/B6 API work already reached production in the 2026-11-15 combined deploy). This divergence is handed to the apps programme for its own reconciliation, with the full lists in the lane evidence (`exports/prod-files.out` / `stg-files.out`).

### 2.6 Newsite root files — not this package

Production root carries the public website's files (already live via its own 2026-11-17 cutover); staging root carries that lane's working copies (`403/404/500.html`, `gallery-cache.json`, `notices-cache.json`, `assets/img/hero-2-sm.webp`, assorted `*.bak-*`). They differ between the trees and are **excluded** — the website programme owns them.

---

## 3. Schema migrations (`sql/` — each idempotent, each with a reversal)

Production holds **398** DB objects; staging **513**. The full inventories were diffed (tables, views, and every column of every shared table).

### 3.1 M01 — 123 new tables

Staging-only objects: 130 → minus 3 staging backup tables → 127 → minus 4 with **no reference anywhere in shipped code** (§3.6) → **123 tables that payload code references by name** (reference pass over both trees; production's current code references none of them, so creating them is inert until the code lands). `M01-create-programme-tables.sql` carries staging's exact DDL as `CREATE TABLE IF NOT EXISTS`, FK checks suspended during load. Families: `pk_caf_*` (cafeteria 22) · `pk_gate_*` (gate queue 14) · `pk_pay_*` (payables 17) · `pk_payroll_*` (7) · `pk_sg_*` (safeguarding 10) · `pk_gl_*` (double-entry ledger 6) · `pk_fo_*` (front office 3) · `fam_*` (households 10) · `api_*` (audit/sessions 3) · `pk_ai_*` (3) · `exam_types`, `book_categories`, `pk_fee_tombstones`, `pk_fee_assigned_pin`, `pk_fee_*` (5), `pk_exam_*` (3), `pk_policy_keys`, `pk_stepup_*` (2), `pk_theme_*` (3), `pk_print_*` (3), `pk_moneywatch_*` (4), `pk_app_*` (7), misc `pk_*` singles. Reversal `R01` (drop set — only inside the deploy window; see §8).

### 3.2 M02 — 8 additive columns (the ONLY column differences across all 383 shared tables/views)

`books.book_category_id` (C1) · `staff.force_password_change` + `staff.password_changed_at` · `users.force_password_change` · `users_authentication.device_id` + `last_used_at` + `token_hash` · `api_staff_sessions.last_used_at`. All nullable or defaulted; no production row changes meaning. Reversal `R02`.

### 3.3 M03 — library categories, sized to production

`book_categories` is created by M01; M03 seeds the single governed category **'General'** and backfills `books.book_category_id`. **Production holds 0 books**, so the backfill updates 0 rows at cutover (staging's C1 backfill, from distinct subjects, yielded exactly this one category; the statement reproduces that end-state for any book present on deploy day). Reversal `R03`.

### 3.4 M04 — governed seed rows (no secrets)

- `exam_types`: the 2 product type definitions (Basic System; School Grade System) — definitions, not exams.
- `pk_ai_config`: 1 row — **AI disabled, no active provider**.
- `pk_ai_settings`: the 3-provider fixed catalogue (Gemini / Groq / OpenRouter free routes) with **`api_key` NULL for all** — the AI surfaces ship in their honest not-configured state; activation is the owner's post-cutover key paste (§7).
Reversal `R04`.

### 3.5 M05 — `fee_master_position_v` definition replace (with a no-change proof)

The one shared view differs: staging's definition adds the `pk_fee_assigned_pin` override for assigned amounts. M05 installs staging's SELECT (after M01 has created the pin table), **without a DEFINER clause** — it must run as the production DB user so the definer becomes that account (production's current definer is a legacy account name; neither tree's definer may be copied across). **No-change proof on production data:** the pin table is created empty, so every `COALESCE(pin…)` falls back to the fee-group sum — the post-deploy aggregates must equal §4's baseline **to the paisa**; any difference aborts the deploy. Reversal `R05` (production's current definition, captured verbatim).

### 3.6 Excluded schema (named, not shipped)

`api_app_versions`, `pk_api_client_keys` (API-programme surface, unreferenced by web code) · `fam_consents`, `fam_f1_drift_journal` (no static reference in shipped code) · staging's 3 `backup_*` tables. If any surface ever needs one, it is a new, separate migration — not a silent addition to this package.

### 3.7 Sidebar transaction — M06

Full replace of `sidebar_menus` + `sidebar_sub_menus` with the staging end-state rows (explicit ids preserved; §1.3), wrapped with FK checks suspended and post-checks (35 / 295 / 278). Runs **after** the payload (the sidebar points at the new routes). Reversal `R06` (production's rows as captured 2026-11-19) — with the standing instruction that the deploy-time backup dump (§6 step 2) supersedes R06 if production's sidebar changed after 2026-11-19.

---

## 4. Money baseline — production's real position + the deploy-time procedure

### 4.1 Baseline measured on production (2026-11-19, via production's own `fee_master_position_v`)

| Figure | Paisa | Rupees |
|---|---|---|
| Masters (view rows) | — | 2,619 |
| Assigned | 970,046,000 | **Rs 9,700,460.00** |
| Paid | 170,000 | **Rs 1,700.00** |
| Discount | 126,350,000 | **Rs 1,263,500.00** |
| Fine | 0 | Rs 0.00 |
| Balance | 843,526,000 | **Rs 8,435,260.00** |
| Students with a balance | — | 1,661 |
| Status mix | — | Paid 1 · Settled by discount 25 · Unpaid 2,593 |

Cross-validation: the discount figure equals F1's staging snapshot #1 to the paisa (Rs 1,263,500.00) — the two trees share the same real fee base; the assigned/balance deltas vs staging are staging's fixture activity plus the §1.2 verification pair. **AFM-gap equivalent on production: 0 masters without AFM posting rows** (staging's Rs 16,750 gap was fixture-caused; production is clean). Production's `afm_reconciliation_snapshots` table exists and holds 0 rows.

### 4.2 Procedure (F1 discipline, applied at deploy time)

1. **Step 1 of the runbook** re-measures the §4.1 aggregates on deploy day and records them as BEFORE (if school activity moved them since 2026-11-19, the deploy-day values govern — any *unattributable* jump aborts).
2. After the payload lands (runbook step 9), the Fees workspace **Snapshot** action writes the BEFORE snapshot row into `afm_reconciliation_snapshots`; after M06 + smoke, the AFTER snapshot is written.
3. **Acceptance: AFTER aggregates == BEFORE aggregates to the paisa** (assigned / paid / discount / fine / balance / students-with-balance), computed through the NEW view definition (M05's no-change proof makes this a true like-for-like). A one-paisa difference aborts to rollback (§8).

---

## 5. Flaw list — shipped knowingly, named

1. **`user/exam/index` returns HTTP 500 — pre-existing vendor defect, not programme-caused.** Its views (`user/exam/examList`, `exam/examShow`) exist in **neither tree** and in no backup; they were never part of this installation. The package does not fabricate them. The student-facing exam function is carried by the four working surfaces (`user/exam/examresult`, `user/examschedule`, `user/onlineexam`, `user/mark` — all render-proven in the refinement portal sweep). Remedy, if wanted, is separate commissioned work (a new view build), not part of this cutover.
2. **`Student::create` post-success `studentUpdateByID` writes NULL image fields** against NOT-NULL columns — a silent no-op update risk observed during the S1RT-002 diagnosis. The create path itself is fixed (the fix ships in this payload); the update-path observation is recorded here for a future flaw lane.
3. **Sidebar end-state carries the programme's demo-era fixture accounts' menu grants on staging only** — no production effect: M06 ships row *definitions*; production's own users/roles are untouched, and no staging data migrates (D-040 rule: the package carries code + configuration, never staging data).

## 6. Out of the package (by standing owner positions)

| Item | Position |
|---|---|
| **G1 — online fee payments (Card 7)** | No gateway has been chosen by the school; nothing configured on either tree (ST1-verified). Not built into the cutover. |
| **Blog** | No adoption decision; not built (CM1 disposition). |
| **AI activation** | Surfaces ship built and honestly **not-configured** (M04 seeds: master switch off, all `api_key` NULL). Activation = the owner pastes a real free-tier key in AI Settings — before or after cutover, his choice; no trial keys. |
| **CBSE module** | No adoption decision. The dormant vendor CBSE surfaces are byte-identical in both trees and are **untouched** by this package (zero CBSE files in payload or deletions); E1's workspace carries its own `pkexams/cbse.php` surface for if/when the school adopts it. |

---

## 7. Deploy runbook — ordered, gated, abort-aware

*Precedent: the 2026-11-15 combined deploy (tree proof → per-file md5 gates → backups outside trees → dependency-ordered file landing → production-safe smoke), extended with the lanes' build-then-delete and money-reconciliation discipline. Deploy in a school off-hours window.*

**Step 0 — Gates.** Owner's signed-in staging check done + explicit sign-off for this package recorded (§0). Read-only settle of production's `db_debug` state (record the value; it is production's own setting and the package does not change it — if it reads TRUE, the deploy lead flags it in the go/no-go, per the Round-3 board's instruction that this be settled before the cutover package runs).
**Step 1 — Fresh production recon.** Re-run the package's recon probes (guard `u238632175_KliTy`): census + §4.1 money aggregates + sidebar counts. *Verify:* values match §1.2/§4.1 or every difference is attributable to dated school activity. **ABORT** on any unattributable jump.
**Step 2 — Backups (outside both trees, host `~/backups-d027-prod-<date>/`).** Full production DB dump; separate dumps of `sidebar_menus` + `sidebar_sub_menus`; per-file copies of all 140 REPLACE + 310 DELETE production files at their relative paths; copies of the 3 protected files (§2.3). *Verify:* every backup file's md5 equals its live production md5; DB dump size sane and restorable (header + table count). **ABORT** on any unverifiable backup.
**Step 3 — Protected-file record.** Write the pre-deploy md5s of `database.php`, `config.php`, `rektrs_owner_license.php` (web + api configs) to the deploy log; they are re-asserted at step 9.
**Step 4 — Schema.** Run **M01 → M02 → M03 → M04 → M05** in order, each with its written pre/post checks (M01: 123 tables present · M02: 8 columns · M03: ≥1 category, 0 uncategorised books · M04: 2/1/3 seeds, 0 non-NULL api_key · M05: aggregates == step-1 BEFORE to the paisa). **ABORT** on any failed post-check → reverse what ran (R05 → R04 → R03 → R02 → R01) and stop.
**Step 5 — Money BEFORE snapshot.** Via the recorded aggregate SQL (and, once step 6 lands the code, the Fees workspace Snapshot action), file the BEFORE position. *Verify:* equals step-1 aggregates.
**Step 6 — Payload landing, dependency order** (combined-deploy precedent): libraries → models → helpers → controllers (admin, then root/user) → views → `application/config/payroll.php` → backend assets (vendor tree → `dist/` subsets → themes/custom_addons). Source: this package's `payload/`. Per batch: **md5sum -c gate** against `payload-manifest.md5` for that batch (100% OK required), then **modes asserted** (dirs 755, files 644), then — after the backend batch — **loopback check**: one payload CSS fetched over HTTPS returns non-zero bytes. **ABORT** on any md5 failure (restore that batch from step-2 backups).
**Step 7 — Deletions (310).** Only after step-6 batches pass and the replacement surfaces answer their guard probes. Delete exactly `delete-manifest.tsv`'s paths (all pre-backed-up in step 2). *Verify:* retired doors return the themed 404 page; no live door references a deleted file (the lanes' reference greps are the evidence base).
**Step 8 — Sidebar.** Run **M06**; post-checks 35 / 295 / 278.
**Step 9 — Smoke battery.** Run `work/d027-smoke.sh` (unattended legs): payload md5 gates 100% · delete list absent · protected files' md5s unchanged · modes + CSS non-zero · DB post-checks · census spot == step 1 · HTTP guard probes on the workspace roots (`admin/pkfees`, `pkexams`, `pkstudents`, `pkhr`, `pkacademics`, `pkops`, `pkcommunicate`, `pksettings`, `pkai/settings`) return login redirects, never 500 · retired door themed-404 · Staffapi unauth probe returns the exact 401 guard shape. **Must print SMOKE-PASS. ABORT → §8 on any failure.**
**Step 10 — Money AFTER reconciliation.** Write the AFTER snapshot; aggregates == BEFORE **to the paisa**. **ABORT → §8 on any difference.**
**Step 11 — Owner's first-sign-in checklist (§9 of this package)** completes the deployment (combined-deploy precedent: authenticated legs are owner-witnessed). Until then the deploy is reported as *landed, pending owner witness* — never as "live and verified".

---

## 8. Rollback plan

**Triggers:** any ABORT above · SMOKE-FAIL · any paisa of money difference · owner instruction.

1. **Files:** restore the 140 REPLACE files and re-place the 310 DELETE files from the step-2 backups (per-file md5-verified against the backup copies); remove payload NEW files by manifest (they are inert without the sidebar/code paths, but remove for a clean tree). Protected files were never touched (asserted at step 9).
2. **Database (reverse order):** R06 (sidebar — or re-import the step-2 sidebar dump if production's sidebar changed after 2026-11-19; the dump governs) → R05 (view) → R04 (seeds) → R03 (book links) → R02 (columns) → R01 (tables — safe: the new tables hold no production data unless the system went live on the new code; if it did, skip R01 and go to 3).
3. **Full-restore fallback:** if any step's state is ambiguous, restore the step-2 full DB dump + the complete file backup set, then re-run the step-1 recon and require census == step-1 values before declaring rollback complete.
4. **Post-rollback verification:** production guard probes (login page 200, Staffapi 401 shape), census spot-check, money aggregates == step-1 BEFORE.

---

## 9. Post-deploy smoke + owner's first-sign-in checklist

**Unattended (deploy lane, step 9):** `work/d027-smoke.sh` — file gates, delete-list absence, protected files, modes/CSS, DB post-checks, money, guard probes, Staffapi shape. Ready as a script; it refuses to run against any DB not named `u238632175_KliTy`.

**Owner-witnessed (first production sign-in, mirrors combined-deploy §8.3–8.5):**

- [ ] Admin sign-in lands on the new dashboard; sidebar shows the vendor tree (278 active entries across roles as entitled).
- [ ] One surface per module opens with real school data: Fees (position figures == §4.1), Examinations, Attendance, Students, HR/Payroll, Academics, Library/Transport/Hostel/Inventory, Communication, Settings, AI Settings (shows the honest not-configured state).
- [ ] Fee collect round-trip on one real student: receipt prints through the **unified print producer** with the web design; deposit appears in the register; position moves by exactly the collected amount.
- [ ] One payslip + one certificate render through Print Centre.
- [ ] Parent/teacher portal: examresult + examschedule + onlineexam + mark open (the `user/exam/index` 500 is the named §5 flaw — expected, not a deploy failure).
- [ ] Workspace + Connect apps: sign-in, Exam Centre list (production holds 0 exams — an empty list is correct), fee receipt view.

---

## 10. Readiness statement

**The package is complete and ready to execute.** Everything it needs is inside it: verified payload + manifests, sized and reversible migrations, a recomputed sidebar transaction, a measured money baseline with a paisa-exact acceptance test, a named flaw list, an ordered abort-aware runbook, a rollback plan, and a ready smoke battery.

**What remains is only the owner's:**

1. His own signed-in staging check (§0 gate 1).
2. His explicit production sign-off (§0 gate 2).
3. A deploy window in school off-hours.

No other blocker, open question, or missing artefact stands between this package and execution. G1 (payments), Blog, CBSE and AI activation stay out by the owner's standing positions (§6) and block nothing.

*Prepared under the D-027 discipline: production read-only throughout preparation; staging-first proof for every artefact; per-file backups and rollback points are built into the runbook, not improvised at deploy time.*
