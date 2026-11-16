# PreSkool Deployment Plan — Purchased Package as Single Source (2026-11-15)

**Status:** PLAN ONLY — prepared at owner order 2026-11-15 ~16:19 PKT. Nothing in
this plan has been deployed by the lane that wrote it. Execution starts only on
owner approval of this plan. **Staging-first throughout; production is not
touched by any step until the explicit production gate at the end.**

**Owner rule carried into every step (2026-11-15):** NO invented design — every
design element and feature must remain exactly as the purchased template ships.
Anything in the current staging build that cannot be traced to the purchased
package is either removed, or re-registered as an IQRS-native EXEMPT/NATIVE-SPEC
item with the forcing IQRS rule named — never silently kept.

---

## 1. Why this plan exists — the source-of-truth switch

Until today the PF waves were built against a **locally produced reconstruction**
(`hidden_files/preskool/package/preskool-bootstrap-reconstruction/`), built
2026-11-10/11 by scraping the vendor live demo at
`preskool.dreamstechnologies.com/html/`. The reconstruction is a re-engineering,
not a copy (its own README/Completion Report say so): consolidated CSS, inline
styles converted to classes, invented semantic tokens, a rewritten vanilla-JS
interaction layer (no jQuery), local additions (Bootstrap Icons, AOS), and one
invented page.

The owner has now purchased the licensed vendor package — **ThemeForest item
29532878, PreSkool v2.0 (changelog head), ONE Regular License, licensee Asad
Choudhary, purchased 2026-11-15 08:42:49 UTC** — held locally at
`~/workspace/preskool-branches/html/` (HTML variant, files at root) and pushed to
the private repo `asadchoudharry/rektrs-preskool` (branch `html`, commit
`ac39a717…`, verified). **From this plan forward the purchased package — never
the demo, never the reconstruction — is the only design source of truth.** The
D-008 licence gate is satisfied by this purchase (record it in the decision log
at plan approval).

## 2. Gap analysis (evidence: local file diffs + read-only SSH checks of live staging, 2026-11-15)

### (a) Version / structure — the two sources are NOT the same artefact

| | Purchased package (vendor) | Reconstruction (PF build source) |
|---|---|---|
| Pages | **426** HTML at root | **386** HTML (385 demo pages + 1 invented) |
| Page delta | 41 pages exist **only** in the package (incl. `fee-installments`, `online-examination`, `question-bank`, `digital-id-card`, `daily-attendance`, `behavior-discipline`, `scholarship-management`, `rewards-gamification`, `edit-invoice`, `online-payment-receipts`, 10 `ui-*` pages, `v2-index`, `index-old`, `sidebar`) | 1 page exists **only** in the reconstruction: `notification-center.html` (self-declared "additional enhancement page") |
| CSS architecture | `assets/css/style.css` **2,178,546 B** + separate `bootstrap.min.css` (Bootstrap **v5.3.8**), theme/plugin CSS files, **full SCSS sources** (`assets/scss/`) | One consolidated `style.css` **2,876,006 B**; no SCSS; Bootstrap folded in |
| JS architecture | jQuery + per-page scripts: **49 files** in `assets/js/` (16 `*-workspace.js`) + **29 plugin dirs** (`assets/plugins/`: apexchart, fullcalendar, quill, swiper, tabler-icons, …) | One rewritten vanilla bundle `main.js` (825,461 B) + `theme-init.js`; **no jQuery** |
| Assets | **5,903 files** under `assets/` (595 images) | **572 files** under `assets/` (226 images) |
| Tokens | Vendor `style.css` defines **291** distinct custom properties | All 291 vendor names exist in the recon CSS (recon is a superset: 744); effective (last-wins) values differ on only **10** — mostly dark-block tails plus recon-invented aliases (`--muted`, `--m`, `--s`, `--t` → `--recon-*` tokens that do not exist in the vendor package) |
| Fonts | Inter loaded via Google Fonts `@import` in `style.css`; **no Inter font files ship** (only icon fonts: Feather, FontAwesome, Material, Line Awesome) | Same Inter-by-name design; staging self-hosts 4 Inter TTFs (provenance: Google Fonts, not vendor files — visually the same typeface, recorded here as a provenance note, not a design difference) |

**Verdict (a):** same template family and same headline tokens (primary
`#3D5EE1`, ink `#202C4B` agree), but the PF build's *structure, asset set and
page census* are the reconstruction's, not the vendor's. The PF-0 reference pack
and the 394-screen target map were measured against the reconstruction and must
be re-based (Step PKG-0).

### (b) Staging assets vs the purchased originals — staging serves ZERO vendor-original design files

Live on staging (verified read-only via SSH today, `backend/dist/css/`):
**13 `preskool-*.css` files** (tokens, components, shell, auth, dashboard,
portal, fees, academics, attendance, exams, hr, notifications, theme-active) +
a Tabler Icons set. **Every one is a locally authored derivative** — hand-built
from the reconstruction — and **no vendor-original file** (vendor `style.css`,
`bootstrap.min.css`, any plugin, any `*-workspace.js`, any `assets/img/` art)
exists in the staging app tree. Key provenance facts:

- `preskool-tokens.css` (live md5 `2f8f41e7…`) began as BL-010's 269 tokens
  extracted from the *reconstruction's* CSS; the live file now defines **818
  distinct variables, 490 of them locally minted `--alpha-*` / `--pf-*` tokens**
  created by the BL-150 sweep to tokenise literals in the locally written
  components CSS. The vendor token set is 291 variables. The deployed token
  layer is therefore a local dialect, not the vendor's.
- `preskool-components.css` (609,707 B at BL-011, since amended) is a locally
  written component layer; the vendor instead ships its component styling
  inside `style.css` + plugin CSS. Class-level equivalence has never been
  measured against the vendor files.
- Staging also still carries pre-PreSkool design residue (e.g.
  `backend/dist/fonts/calmcampus/`) alongside the PreSkool layers.

### (c) Staging pieces with NO counterpart in the purchased package (no-invention flags)

1. **`notification-center` surface** — traces to the reconstruction's invented
   page; the vendor package has no such page. (BL-014's bell/panel itself is
   wired to real Communicate records — the *page anatomy* is the invented part.)
2. **The minted token families** — `--alpha-*`, `--pf-*` (490 vars) and the
   reconstruction's `--recon-*` semantic aliases: none exist in the vendor CSS.
3. **Locally authored CSS layer files as a pattern** — `preskool-shell.css`
   safeguard/fix blocks (S1–S9, FIX-2) exist to bend AdminLTE markup into the
   theme; the vendor shell is native HTML, so these bridge rules have no vendor
   counterpart. (They are integration glue, but under the owner's rule they must
   be re-derived from vendor anatomy at the shell swap, not carried forward.)
4. **Sidebar re-grouping + inventions** — BL-012 MENU's 7 Doc04 job groups,
   Super-Admin show-all toggle and "Not set up" chips: the vendor sidebar is
   13 sections / 343 targets as shipped; the regrouping is an IQRS arrangement,
   not a vendor design. (Menu *population by permission* is IQRS function; the
   *grouping design* is the flagged part.)
5. **Tabbed workspace anatomy** (pkfees/pkstudents/pkexams/… as consolidated
   tabs) — already governed by D-039 "pages, not tabs"; restated here because
   the vendor package is page-per-function throughout.
6. **BL-013 global-search palette skin and launchpad/worklist surfaces** —
   IQRS-native function skinned locally; no vendor page counterpart (they fall
   to PF-6-style NATIVE-SPEC, not deletion — function is IQRS's, only the
   *skin's provenance* is flagged).

### (d) Purchased-package pieces the staging build has NOT yet used

- **41 pages** with no reconstruction/staging counterpart (list in §2a) — each
  needs a disposition in the target map: build (feature-list v6 → v7 row),
  CLAIM-honest empty, or EXEMPT with reason. Notable: fee installments, online
  examination + question bank, digital ID card, behavior/discipline,
  scholarship management, rewards/gamification, day-wise attendance set.
- **SCSS sources** (`assets/scss/`) — the vendor's editable source layer; the
  build has only ever consumed compiled/reverse-engineered CSS.
- **Vendor plugin set as shipped** (ApexCharts, FullCalendar, Quill, Swiper,
  Choices, Flatpickr, SweetAlert, … under `assets/plugins/`) — staging uses
  Smart School's own plugin copies + a separately sourced Tabler set; the
  chart layer gaps recorded in the drift register (exam/academics analytics
  table-only) map directly to the unused vendor ApexCharts stack.
- **Vendor imagery**: 595 image files vs the reconstruction's 226 — incl. the
  theme art (`assets/img/theme/sidebar-bg-*.svg`), authentication imagery and
  empty-state illustrations D-043 requires be taken from PreSkool itself.
- **Vendor layout variants**: `layout-rtl` + `bootstrap.rtl.min.css`, dark/box/
  mini layouts, `v2-index.html` dashboard variant — none consumed yet.
- **Vendor documentation + changelog** (`main` branch `documentation/`) — the
  version record (v2.0) the PF-0 baseline never had.

## 3. Deployment sequence — new wave **PF-PKG** (Package Provenance Swap)

Placement: PF-PKG runs **before PF-8** (final census + cutover) and feeds it;
its surface steps interleave with the remaining PF-6/PF-7 build work so no
surface is finished twice. D-037 security sequencing is not displaced.
Every step: staging only, per-file backups with md5 gates and the tree proof
(staging DB `u238632175_test123`) before any write, `?v=` cache-buster bumped
with every CSS/JS change (BL-012 cache trap), rollback = restore the step's
backup set + delete its new files, verified by served-bytes md5.

| Step | Scope | Verification (gate) |
|---|---|---|
| **PKG-0 — Reference freeze & re-baseline** (no server writes) | The purchased package's own pages, served locally from `~/workspace/preskool-branches/html/`, become the PF-0 reference pack (replacing reconstruction captures). Re-issue the screen target map: 426 vendor pages ↔ IQRS routes; disposition the 41 new pages into feature list v7; retire the reconstruction to archive (evidence only). Record D-008 satisfied (purchase, 2026-11-15) in the decision log. | Owner sees: new counts, 41-page disposition table, EXEMPT candidates. Reference pack checksums filed. |
| **PKG-1 — Asset provenance swap** | Vendor originals vendored into the staging tree under a dedicated path (e.g. `backend/dist/preskool-vendor/`): vendor `style.css`, `bootstrap.min.css`, theme/plugin CSS+JS, `assets/img/` art, icon fonts — byte-identical, with a sha256 manifest diffed against the purchased tree. Inter: keep the self-hosted TTFs, recorded as a provenance note (vendor ships none). No view switches to them yet. | Manifest diff = 0 unexplained deltas; served-bytes md5 == package md5 on a sample per asset class; loopback CSS non-zero bytes; dirs 755 / files 644 asserted. |
| **PKG-2 — Token layer rebuild** | Regenerate `preskool-tokens.css` from the vendor sources only (291 vendor vars + Bootstrap vars as the vendor defines them). Every `--alpha-*`/`--pf-*`/`--recon-*` token is either deleted or mapped in a published mapping table to the vendor value it stands for; consumers updated in the same deploy. | Token census vs vendor set filed; lint gate (zero hard-coded hex/inline styles in touched views) green; contrast pairs recomputed from rendered staging pages, light + dark. |
| **PKG-3 — Shell swap** | Header/sidebar/footer rebuilt from the vendor `index.html` anatomy and class system directly (vendor 13-section nav tree as the design; permission/config population stays IQRS logic). The forked per-workspace shell CSS files merge into the one shared shell layer consuming vendor classes; bridge rules re-derived from vendor anatomy or deleted. | Side-by-side captures vs the package's own `index.html` served locally: 1440×900 / 1024 / 390, light + dark; screenshot-diff ≤1% with **zero** geometry tolerance on shell anchors (D-038 §3); per-role menu census battery re-run. |

> **PKG-3 COMPLETE — 2026-11-15 ~22:52 PKT (staging only; production untouched).** Deployed via SSH after the owner-ordered File Manager route hit Hostinger's app-level FM outage (nothing uploaded via FM): one-time backup `~/backups-pkg3-2026-11-15`, all 10 served md5s == src (header `af3ea1ee`, sidebar `9bf61a5b`, footer `dc3b1f09`, printstudio_navigation `41410601`, shell.css `5d317b7e` 144,912 B, carried `f76bc33c`, components `877609a7`, notifications.css `3d48140c`, shell.js `b007b782`, notifications.js `452abd6c`); §10 item 1 picker-card removal included (loader grep 0). Gates: per-role menu census IDENTICAL before/after (SA 248 menu lines; TE/AC deltas only the account links' relocation from sidebar tree to the vendor header dropdown — presence grep-proven in AFTER pages); rendered card census over 203 real session pages: BEFORE (rolled-back shell) card on 9 pages incl. `student/search` → AFTER 0; print legs all HTTP 200/0 error markers (Print Studio + Print Section indexes + 15 unified-pipeline previews: receipt, marksheet, ID cards, certificates, payslip, TC); CDP captures at 1440/1024/390 light+dark vs vendor refs: header/header-left/header-user/sidebar/brand-card anchors EXACT (geometry + background) in all 6 — one named residual: sidebar-inner height and side-footer y uniformly −10 px in all 6 combos (→ PKG-5/refinement); whole-image pixel diff is content-dominated (real school data/menu vs vendor demo data) and is not a ≤1% surface by construction. Verification root causes found and fixed in-lane: rsync-propagated 2770 dir modes (chmod 755, statics re-proven), host loopback vhost trap (public URL is the only valid host-side HTTP route), and the tree's real login = vendor Google-Authenticator TOTP flow (proof staff carried disposable gauth rows, deleted at cleanup; census back to 122). Piggyback audit F-1: `Bl108probe.php` absent on staging AND production (read-only stat) — clean. Full evidence: `hidden_files/preskool/pkg3/PKG3-LANE-RECORD.md`.
| **PKG-4 — Component kit swap** | `preskool-components.css/js` replaced by the vendor plugin set + vendor component classes (ApexCharts from vendor plugins for the chart layer; vendor empty/loading states and illustrations). Gallery re-pointed at vendor components. Local primitives with no vendor twin (data-table saved views) re-skinned to vendor table anatomy under NATIVE-SPEC. | Gallery exercises every component against vendor pages side-by-side; chart-led dashboard/academics/exams analytics render with recorded data; diff heatmaps filed. |

> **PKG-4 COMPLETE — 2026-11-15 ~23:2x PKT (staging only; production untouched).** The kit CSS was rebuilt by mechanical extraction from the purchased package: every one of the 4,641 selectors the old kit carried was located in vendor `bootstrap.min.css` (5.3.8) + `style.css` and its vendor rule body emitted verbatim, scoped under `.pk` (4,564 matched; both-pools + dark-lead union — `[data-bs-theme=dark]`/`[data-theme=dark]`/`html.darkmode` chapters merged as the vendor scatters them; layout-variant `[data-sidebar]`/`[data-topbar]` leads excluded as shell territory). Deployed via SSH (10 files; one-time backup `~/backups-pkg4-2026-11-15`, MD5-BEFORE verified): components.css `d653c171` (544,375 B — PART A 744 Bootstrap rules + PART B 3,334 vendor rules + a hand section of six registered NATIVE-SPEC bridges PKG4-NS-1…6: page-head contract for 83 views, honest states on vendor `.empty-state` anatomy, saved-view marker, chart card, empty, skeleton), components.js `45e9c7bc` (provenance header only — behaviours are IQRS function contracts the vendor's BS5/jQuery bundle cannot serve on this BS3 app; PKG-3 shell.js precedent), gallery re-pointed `7237b707`/`2a97af69`, header/footer `?v=20261115-pkg4` busters. **Chart layer:** all FOUR ApexCharts consumers (dashboard, pkacademics analytics, pkexams results, pkattendance bydate) re-pointed from the loose `backend/dist/js/apexcharts.min.js` to the PKG-1 vendored plugin path — byte-identical file (md5 `9ca28058`, ApexCharts v5.3.5), so provenance-only; loose copy retired into the backup after a zero-reference census. **Verification (rendered, not server proofs):** local rig computed-style probes vs the vendor's own pages — btn-primary/card/progress/chip MATCH, empty-state/stat/skeleton values vendor-verbatim, dark card background `#131022` exact (the canary defect: exact-key matching had dropped the `html.darkmode` dark chapter; fixed by union collection); old-vs-new kit heatmap on identical gallery markup filed (15.70% pixels differ). Real-session legs (disposable SA proof staff + gauth TOTP, PKG-3 pattern): all 4 surfaces HTTP 200, vendored script present, loose script absent, 0 PHP error markers; CDP captures through the SSH SOCKS tunnel show rendered ApexCharts SVGs on recorded data — dashboard 14, analytics 2, results 4, staging gallery 1. Delta register: 77 old-kit selectors with no vendor counterpart, all dispositioned DROP in the lane record (BS 5.3.8 form changes, stricter vendor compound forms, recon dark inventions, bare `.stat-card` — vendor ships it skin-scoped only, page-scoped/shell leftovers); vendor file defects (16 SCSS `$black` literals, 5 invalid `rgba(var(#hex))`) carried verbatim as-is. Cleanup: proof staff + gauth rows deleted, staff census back to 122, lane secrets shredded. Full evidence: `hidden_files/preskool/pkg4/PKG4-LANE-RECORD.md` + `pkg4/evidence/`.
> **PKG-5 COMPLETE — 2026-11-16 ~00:5x PKT (staging only; production untouched).** Every closed surface re-diffed against the vendor pages from real CDP captures (60+ screens, pre/post sets in `pkg5/evidence*/`); verdicts republished in D-038 vocabulary (`pkg5/VERDICTS.md`): PIXEL-MATCH 2 (shell; app 404) · DRIFT 57 · EXEMPT 3 (EX-PKG5-01 CBSE, -02 QR attendance, -03 HR ratings — no similar vendor counterpart, §10.5) · NOT-BUILT 3 (CI stock error pages; pkacademics/performance route, folded into analytics; pkhr/structure, retired). **Three fixes deployed in-lane** (backups `~/backups-pkg5-2026-11-15` + deploy2/ + deploy3/, all BEFORE md5s verified): (1) **PKG-3 carry-in (a) CLOSED** — the −10px sidebar residual was the app legacy sheet's AdminLTE-era `.sidebar{padding-bottom:10px}` out-ordering the shell at equal specificity; bridge `.pk-shell .sidebar{padding-bottom:0}` in shell.css `965890e0` + vendor `dropdown` class on the brand card (sidebar.php `2db70958`); probe-after shows ZERO remaining anchor diffs (inner 757, footer y 817). (2) **PKG5-DRIFT-01 kit rem metrics** — the vendor layer assumes a 16px root, the app root is 10px (BS3), so 985 rem values in tokens+components rendered at 0.625× (page-head titles 11.25px vs vendor 18px; badge padding 2.5 vs 4px); normalized rem→px ×16 in tokens `398e28bc` + components `bff511fc` only (authored sheets untouched), busters → pkg5 (header `5e54c039`); post-fix probes exact (badge 4px, card-body 20px), regression 57/58 captures within ±400px, login page byte-identical. (3) **App 404 rebuilt** to the vendor `404-error.html` anatomy verbatim (error_message.php `dc3c06f1`, school branding slots; inherited non-echoing logo call fixed). **Carry-in (b) EX-PKG2-01 ARBITRATED:** rendered contrast probes show the vendor's OWN pages render the same sub-AA status inks (success 2.27, warning 1.80, danger 3.77) and staging renders identical values — vendor as-is; gate retirement stands. **Carry-in (c):** bare `.stat-card` census = 0, no migration instances. **Open to PKG-6 (named in `pkg5/DRIFT.md`):** PKG5-DRIFT-03 record-grid/data-table component migration, PKG5-DRIFT-04 ledger pagination, INV-06 tabbed-anatomy replacement (D-039), portal frame, dashboard compositions, auth items. **Owner-decision items STOPPED with evidence packages** (`pkg5/OWNER-DECISIONS.md`): D1 notification-center anatomy (INV-01b), D2 menu grouping (INV-05b — grouping labels/order already the vendor's; open point is only the show-all toggle + "Not set up" chips). §2c dispositions recorded in the lane record. Cleanup: proof staff/gauth deleted, census back to 122, secrets shredded. Full record: `hidden_files/preskool/pkg5/PKG5-LANE-RECORD.md`.

| **PKG-5 — Surface re-verification (PF-2…PF-5 surfaces)** | Every surface closed under the reconstruction is re-diffed against the **vendor** pages: auth + dashboards (PF-2), portal (PF-3), pkfees/pkstudents/pkacademics (PF-4), pkattendance/pkexams/pkhr (PF-5). DRIFT lists re-issued per screen; §2c flagged items dispositioned (remove, or EXEMPT/NATIVE-SPEC with the forcing rule named — e.g. notification-center page, menu grouping). | Per-screen verdicts republished in the D-038 vocabulary (PIXEL-MATCH / DRIFT / EXEMPT-numbered / NOT-BUILT); no surface keeps a verdict earned against the reconstruction. |
| **PKG-6 — Remaining build on vendor pages only** | PF-6 native specs re-derived from vendor anatomy; PF-7 remaining features built page-per-vendor-page (D-039), consuming the 41 newly available vendor pages where they match scope (online examination, question bank, fee installments, digital ID card…). | Per-screen PIXEL-MATCH + feature battery per D-038 §3–§4, in D-037 security order. |

> **PKG-6 LANE COMPLETE (existing-feature alignment) — 2026-11-16 ~03:5x PKT (staging only; production untouched).** Closed with capture proof (`pkg6/evidence/`, record `pkg6/PKG6-LANE-RECORD.md`, verdicts `pkg6/PKG6-DRIFT.md`): **DRIFT-04 CLOSED** — real vendor JS grid engine ported (`preskool-tables.js`: vendor core + 2 registered vendor-bug fixes + PKG6-NS-1 client pager bridge) + 264-rule grid CSS chapter; collections 1,606 deposits/65 pages and arrears 951/39 probe-verified live (slicing, quick views, search, empty state). **DRIFT-03 CLOSED** for collections/arrears/assignments/pkhr-staff/pkstudents-list (computed-style probes match vendor pages). **INV-06 CLOSED** for the six PKG-3 workspaces — 49 sidebar child rows (permissions copied from parents), 51 tab-strip includes removed, per-role census delta = added links only. **Print Designer NATIVE-SPEC chrome CLOSED** — Printstudio/Print Section/Printdocuments on vendor page-head + card anatomy, engine/registry/designs untouched, ONE print system. **CI stock error pages rebuilt** on vendor 404/500 anatomy with vendored illustrations. Scans: Semgrep 0, Gitleaks clean, Bandit asserts-only in lane tooling; OCR not run (LLM endpoint config lost in VM replacement). Cleanup: proof staff deleted, census 122, secrets shredded. **Remainder (named in `pkg6/PKG6-DRIFT.md`):** A1 wider grid roll-out, A4 portal frame swap, A6 2FA two-step build, INV-06 for pkcommunicate/pkfrontoffice, fee-installments page (vendor page exists; AFM plan tables verified EMPTY on staging — build when the agreement lane authors plans), PF-7 NEW builds (online examination/question bank, digital ID card, scholarships, rewards) — all sequenced to the refinement pass / PF order. D1/D2 untouched (owner decisions pending).

## 4. Production gate (explicit — end of the line, not a step in PF-PKG)

Production is reached only when **all** of these hold, in this order:
1. PF-PKG PKG-0…PKG-6 complete; PF-8 full census re-captured and re-diffed
   **against the purchased package**, final scoreboard published.
2. The dedicated refinement pass (owner instruction 2026-11-13) is done.
3. D-008 licence position on record — satisfied by the 2026-11-15 purchase
   (ThemeForest 29532878, Regular License); recorded in the decision log.
4. Owner sign-off on the final scoreboard, then the D-027 single gated
   production package with per-file backups and the post-swap smoke battery.

## 5. Rollback posture (whole wave)

Every step deploys to staging only, behind md5-gated per-file backups in dated
backup dirs (the established BL-0xx pattern); any step can be rolled back
independently by restoring its backup set, and PKG-1's vendored asset tree is
additive (deleting it returns staging to the pre-plan state). The reconstruction
remains archived locally throughout as evidence of what the old build assumed —
it is never re-deployed.

## 6. Open items this plan does NOT decide

- Disposition of `notification-center` and the BL-012 menu grouping under the
  no-invention rule (remove vs EXEMPT) — decided at PKG-5 with the diffs in
  hand, owner-visible in the re-issued scoreboard.
- Whether any of the 41 new vendor pages enter feature list v7 as builds —
  disposition table at PKG-0 is owner-visible before any build.
- The `preskool-preview/` static install on staging (BL-010 record) was not
  re-verified in this lane; PKG-1 should confirm or remove it.

*Evidence base for §2: purchased tree `~/workspace/preskool-branches/html/`
(426 pages, counts measured 2026-11-15); reconstruction inventory
(`discovery/theme-inventory.md`) + its README/Completion Report; live staging
read-only SSH listing + md5s and the live `preskool-tokens.css` read
(2026-11-15); BL-010…BL-016 / BL-012-MENU execution records; D-038/D-039/D-043
plan (`PRESKOOL-PIXEL-PERFECT-PLAN.md`); screenwise drift register
(2026-11-12).*

---

## 7. PKG-0 completion note (executed 2026-11-15, owner approval ~16:25 PKT)

**Records only — zero server writes; staging and production were not
contacted at all in this step.**

- **Frozen:** the purchased package's `html` branch tree is the reference
  pack — repo `asadchoudharry/rektrs-preskool`, branch `html`, commit
  `ac39a717f1028d126aa8ca61134fde2fb971e2cf`; census 6,333 files /
  186,738,949 B / 426 root pages; key asset SHA-256s (style.css
  `92103aba…`, bootstrap.min.css `4749a2e8…`, script.js `6e9ed9d4…`,
  theme-script.js `f695028a…`) and the full 6,333-entry SHA-256 manifest
  (manifest file SHA-256 `7358bf82…`) filed in
  `files/PRESKOOL-REFERENCE-FREEZE-2026-11-15.md` +
  `hidden_files/preskool/pkg0/REFERENCE-PACK-MANIFEST.sha256`. The
  reconstruction is retired to archive/evidence-only (designated in place,
  unmoved, so existing records' path citations stay valid). D-008 recorded
  satisfied in the decision log as **D-046**.
- **New target map:** `files/PRESKOOL-TARGET-MAP-V2-2026-11-15.csv` (+ `.md`
  summary) — 426 vendor pages: **KEEP-MATCH 309 · NEW 25 ·
  NOT-APPLICABLE 92**. All reconstruction-era verdicts are preserved in the
  CSV as history only and do not carry; surfaces re-verify at PKG-5. The
  PF-0 map + PF-2 update are preserved unmodified and marked superseded
  (`hidden_files/preskool/pixel-perfect/pf0/PF0-TARGET-MAP-SUPERSEDED.md`).
- **41-page dispositions:** **BUILD-LATER 25** (the feature-list v7 candidate
  rows, each with its PKG-6 / PF-7 wave) · **REFERENCE-ONLY 15** (10 `ui-*`
  pages + form-elements, plugins, sidebar, status-cards-showcase, v2-index)
  · **OUT-OF-SCOPE 1** (`index-old.html`, the vendor's own superseded
  dashboard). Full table in the target-map v2 summary, §3.
- **Invented pieces:** register filed at
  `files/PRESKOOL-INVENTED-PIECES-REGISTER-2026-11-15.md` — REPLACE-BY-VENDOR
  at PKG-2 (minted `--alpha-*`/`--pf-*` tokens, `--recon-*` aliases), PKG-3
  (shell bridge/safeguard pattern), PKG-5/6 (tabbed anatomy, per D-039);
  KEEP-AS-IQRS-FUNCTION (notification function, permission-based menu
  population, BL-013 skin + launchpad/worklists as PF-6 NATIVE-SPEC); two
  items are **OWNER-DECISION-NEEDED at PKG-5** (§6 of this plan):
  notification-center page anatomy, and the BL-012 menu grouping design.
- **PKG-1 entry conditions (exact):** (1) this note filed and the freeze
  record + manifest in place (done at PKG-0); (2) owner has seen the PKG-0
  counts, the 41-page disposition table and the EXEMPT/owner-decision list
  (this plan's §3 gate — the two owner decisions themselves are due at
  PKG-5 and do **not** block PKG-1); (3) PKG-1 opens with the staging tree
  proof (staging DB `u238632175_test123`) and md5 gates before any write,
  per §3; (4) PKG-1's vendoring set is drawn **only** from the frozen tree
  and verified against the filed manifest (the tree-root `err3.log` is
  excluded — freeze record §6); (5) PKG-1 also discharges the §6 open item:
  confirm or remove the `preskool-preview/` static install on staging.
  **PKG-1 has not been started.**

---

## 8. PKG-1 completion note (executed 2026-11-15, owner approval ~16:31 PKT)

**Asset provenance swap DONE on staging only. Production untouched (proof
below). No view was switched to the vendored assets — that is PKG-3/PKG-4
territory, exactly as the plan sequences it.**

- **Tree proof (before any write):** the write target tree
  `~/domains/iqrs.edu.pk/public_html/staging/` is proven staging by (1) its
  `application/config/database.php` naming **`u238632175_test123`** (and not
  `u238632175_KliTy`), and (2) its `api` Staffapi.php = **602,254 B, md5
  `0c29925b…`** vs production's 573,699 B / `5763cb9b…`.
  ⚠️ **Marker drift recorded:** the 2026-11-09 Webservice.php size marker no
  longer discriminates — BOTH trees now carry an identical Webservice.php
  (**328,770 B, md5 `d84a212a…`**; neither matches the 2026-11-09 sizes of
  318.29/317.95 KiB). The DB-name + Staffapi markers carried the proof; future
  lanes must not rely on the Webservice.php size.
- **Route:** direct SSH via `~/workspace/scripts/rssh65002.sh` (the rssh.sh
  route with port 65002 baked in) — connected first try and stayed up. The VM
  egress proxy broke three sustained stdin transfers mid-stream
  (`BlockingIOError`/broken pipe in ssh_proxy.py: the first manifest upload,
  `assets/fonts`, `assets/plugins/apexchart` ×2); remedy per the never-stop
  rule was retry + chunking (per-plugin-directory tars; tabler-icons in
  800-file tar chunks; img in 120-file chunks) — every chunk then landed and
  hash-verified. The laptop-jump route was not needed.
- **What was placed:** the frozen tree's complete `assets/` subtree, drawn
  ONLY from `~/workspace/preskool-branches/html/` @ `ac39a717` and verified
  against the PKG-0 freeze manifest, vendored byte-identical to
  **`staging/backend/dist/preskool-vendor/assets/`** (css 15 · js 49 ·
  fonts 34 · img 595 · plugins 5,098 in 29 dirs · scss 112 — scss included
  as the vendor's source layer so the placed set is exactly the purchased
  tree's `assets/` subset with zero deltas; PKG-2 will consume it). The
  tree-root `err3.log` is not under `assets/` and was therefore excluded,
  as the freeze record directs. Inter: vendor ships no Inter files; staging's
  self-hosted TTFs are untouched (provenance note stands).
- **Counts/bytes:** **5,903 files · 131,975,806 file-bytes** — the on-host
  file-byte sum equals the local sum exactly.
- **Manifest:** placed-set manifest (the freeze manifest's `assets/` subset,
  5,903 entries, file SHA-256 `9e2f737f…`) filed locally at
  `hidden_files/preskool/pkg1/PKG1-VENDORED-MANIFEST.sha256` and on-host at
  `~/backups-pkg1-2026-11-15/PKG1-VENDORED-MANIFEST.sha256` (on-host copy
  hash-identical). On-host `sha256sum -c` of the full placed set:
  **5,903 OK / 0 non-OK** — manifest diff = 0 deltas, explained or otherwise.
- **Modes:** the tar carried VM modes (all 5,903 files non-644, 65 dirs
  non-755 pre-sweep); chmod sweep applied to the vendored tree only →
  post-sweep assertion **0 dirs ≠755, 0 files ≠644** (the Hostinger
  0-byte-static trap is closed for this tree).
- **Served bytes (plan gate):** 8 samples, one+ per asset class, fetched
  from `https://staging.iqrs.edu.pk/backend/dist/preskool-vendor/…` — all
  HTTP 200 with served md5 == package md5: `css/style.css` `65aa025c…`,
  `css/bootstrap.min.css` `305ece6e…`, `js/script.js` `1495de5f…`,
  `img/logo.svg` `cd4c60ef…`, `fonts/Feather.woff` `d9c23068…`,
  `plugins/apexchart/apexcharts.min.js` `9ca28058…`,
  `plugins/tabler-icons/eps/2fa.eps` `d7a55b95…`, `scss/main.scss`
  `54ea0e54…`. No 0-byte responses.
- **No-side-effects smoke:** staging front page 200 (21,286 B); login page
  (redirect followed) 200 (19,534 B, correct school title); the existing
  layer is untouched — served `backend/dist/css/preskool-tokens.css` md5
  `2f8f41e7…` == on-host file == the §2b recorded live value. Today's app
  log contains zero `preskool-vendor` mentions; its only 4 ERROR lines are
  timestamped 12:47–12:48 PKT, hours before this lane opened (pre-existing,
  unrelated).
- **`preskool-preview/` — §6 item discharged: CONFIRMED and REMOVED.**
  Confirmed as the BL-010 static install of the retired reconstruction:
  its file list is path-for-path identical to the local archive
  (`hidden_files/preskool/package/preskool-bootstrap-reconstruction/`)
  except one local-only extra (a Plyr demo mp4 never installed on the host),
  sampled files are md5-identical to the archive, and a bounded grep found
  zero references to it in the staging app. Removed from the staging web
  root by move to **`~/backups-pkg1-2026-11-15/preskool-preview/`** (outside
  `public_html`; 3,334 files / 218,652,797 B, intact) — its URLs now return
  the host's baseline 200/0-byte missing-path response (verified against a
  never-existent control path, which answers identically), i.e. no preview
  bytes are served any more. The local archive remains the evidence copy.
- **Production-untouched proof (re-read after all work):** production
  Webservice.php 328,770 B / md5 `d84a212a…` and Staffapi.php 573,699 B /
  md5 `5763cb9b…` — identical to the BEFORE readings taken at lane start;
  production `database.php` still names `u238632175_KliTy`; no
  `preskool-vendor` directory exists in the production tree.
- **Rollback point:** PKG-1 is additive — deleting
  `staging/backend/dist/preskool-vendor/` returns staging to the pre-PKG-1
  state (nothing pre-existing was overwritten, so no file backups were
  needed); the preview is restored by moving
  `~/backups-pkg1-2026-11-15/preskool-preview/` back to
  `staging/preskool-preview/`. Both halves are independent.
- **PKG-2 was not started.**

## 9. PKG-2 completion note (executed 2026-11-15 evening, pre-approved lane; owner reinforcement ~18:51 PKT: build COMPLETELY from the vendor source)

- **Token layer rebuilt 100% from vendor sources.** New
  `preskool-tokens.css` (staging only) assembled solely from the
  purchased package's own blocks (vendor style.css `:root` set = 291
  vars + Bootstrap vars as the vendor's bootstrap.min.css defines
  them, light + dark + dark-navbar). Theme Store contract per the
  lib's own parser: **385 pairs** (was 936). Inter @font-face carried
  as base layer (not tokens; §2a provenance).
- **Mapping table covers 818/818 old tokens** (`hidden_files/preskool/
  pkg2/PKG2-MAPPING-TABLE.csv`): SURVIVOR 250 (vendor value wins) ·
  MAPPED-VAR 140 · MAPPED-LITERAL 390 (value traces verbatim to the
  vendor corpus) · DELETED-UNUSED 36 · COMPONENT-VAR 3 (component-
  instance variables; token definitions deleted, values migrated) ·
  EXCEPTION 0. Every consumer migrated in the same deploy: 12 CSS
  files + gallery.css + `printstudio_navigation.php`, 3,503
  replacements, zero retired refs/defs left in code, comments
  byte-preserved. Named lib exception **EX-PKG2-01**: the four
  status-ink contrast pairs retired from `Pk_theme_lib::$PAIRS`
  (vendor has no AA text-ink family); status-text contrast moves to
  the PKG-5 rendered-surface gate.
- **Deployed through the real Theme Store**: package **preskool
  v1.1.0** installed + applied via `Pk_theme_lib` (validation report
  clean; token_pairs 385); v1.0.0 remains installed as fallback.
  theme-active regenerated (md5 `e666eefb…`, stamp `e666eefb3578`).
  Integrity pins re-baselined (tokens_md5 `287b77ab…`, census_md5
  `06c488a2…`); `pkthemereport check` **ok=true** (check_id 8, 9).
  Governed census after: components hex_total 455 / fn 915 (the
  MAPPED-LITERAL literals now live in consumers by design), shell
  16/10, dashboard 17/11, auth 5/10, portal 0/0, notifications 0/0.
- **Gates:** (a) census vs vendor set filed (lane record + CSV);
  (b) lint: only content-touched view (`printstudio_navigation.php`)
  has 0 hex / 0 inline styles; the 54 buster-only views show identical
  hex (9) and `style=` (19) counts before/after; all 96 CSS links
  bumped to `?v=20261115-pkg2`; (c) contrast pairs recomputed from
  SERVED staging bytes, light + dark — all 9 enforced combos ≥ 4.5
  (min 4.81), identical to the lib's own validation report; served
  login page carries the new busters + stamp. Rendered paired-capture
  arbitration remains PKG-5's step, as planned.
- **Production untouched:** Staffapi md5 `5763cb9b…` re-verified after
  all work; production has no preskool-tokens.css (staging-only).
- **Rollback point:** `~/backups-pkg2-2026-11-15/` (files-before.tgz,
  views-before.tgz, theme-db-before.sql) + Theme Store rollback to
  v1.0.0; restore = backup set + re-pin + check.
- Lane record: `hidden_files/preskool/pkg2/PKG2-LANE-RECORD.md`;
  evidence under `hidden_files/preskool/pkg2/evidence/`.

## 10. Owner print directives (2026-11-15 evening, main chat)

1. **Per-page print-design picker card REMOVED.** The "Document print design / Shared Template Library / Use for my prints" card that renders at the top of operational pages is removed from every page (owner screenshot of the staging student search page, ~20:50 PKT). Tasked to the PKG-3 lane as a separate step (2026-11-15 ~20:52 PKT). The Print Studio/designer, saved designs and the unified print pipeline are NOT touched by the removal.
2. **Printing stays ONE system.** No duplicate/parallel printing system may be created ("printing waly system double na hoon"). The incumbent unified Print Studio stack remains the single print engine; the vendor-native print estate (reports, CBSE, admit cards, portal reprints) converges onto it through the PKG-5/PKG-6 surface work, not through a second engine.
3. **Print Designer rebuilt PreSkool-style.** The Print Designer (Printstudio canvas editor + Template Library + Print Section screens) is to be updated and rebuilt the way the new PreSkool system is built: vendor pages/components/tokens as the design source. It has no vendor twin, so it is a **NATIVE-SPEC** rebuild under the PKG-4/PKG-6 rules (vendor anatomy, no invented design), sequenced after PKG-3 (the shell's header carries the printstudio navigation partial — shared custody), executed with the PKG-6 native-spec family. Engine, registry, saved designs and issuance data unchanged — this is a design-layer rebuild of the tool, not a new print system.
4. **Generalised rule (owner, 2026-11-15 ~21:03 PKT):** "Isi terhan Baki system bhi jahan fark ho PreSkool say wahan usy change Ker k PreSkool ki terhan Ker dena" — the same treatment applies to the WHOLE system: wherever anything differs from PreSkool, change it to be like PreSkool. This reaffirms D-043 and hardens the PKG-5 disposition default: a staging piece that differs from the package AND has a vendor counterpart is changed to the vendor's version (not kept as a local variant); only pieces with NO vendor counterpart stay IQRS-native, rebuilt in the vendor's design language as EXEMPT/NATIVE-SPEC with the forcing rule named (the Print Designer treatment, item 3 above, is the template case). Functions/workflows the package does not contain remain IQRS's — the rule governs design and presentation, and workflow shape where the package has one.
5. **Sequencing directive (owner, 2026-11-15 ~21:04 PKT):** "Un phly Jo hy usy complete set kro Jo nahi hy wo baad main main bta Doon ga" — FIRST complete and set (PreSkool-align) everything that already exists; whatever does not exist yet, he will specify later himself. Effect on this plan: PKG-3 → PKG-4 → PKG-5 (existing shell, components, surfaces) and the Print Designer NATIVE-SPEC rebuild proceed as the priority line. PKG-6's NEW-build scope (features/pages not yet in the system, incl. consuming the 41 new vendor pages, PF-7 remaining features and D-046 mock feature-build items) is HELD — no new build starts on CEO initiative; each starts only when the owner names it. Existing-feature completion/alignment inside PKG-6's native-spec work is not held.
6. **Correction to item 5 (owner, 2026-11-15 ~21:06 PKT):** "Jo new banana wo Bana lo bs esy features Jo hamary core main hain or PreSkool main nahi wo baad main decide karin gy" — NEW builds proceed (the PKG-6 new-build hold in item 5 is LIFTED: features/pages built from the purchased package, incl. the 41 new vendor pages, are built as planned). The ONLY deferred category is features that exist in OUR core system but do NOT exist in PreSkool: their treatment is decided later by the owner — until then they are left as-is (not removed, not PreSkool-rebuilt on CEO initiative). PKG-5 dispositions follow this: vendor-counterpart pieces → vendor version; core-only pieces → record and defer, no disposition executed. **Exception already decided by the owner:** the Print Designer (item 3) — its PreSkool-style rebuild was explicitly ordered at ~20:57 PKT and stands unless the owner says otherwise.
7. **Refinement of item 6 (owner, 2026-11-15 ~21:09 PKT):** "Print to PreSkool main hy na hamary pass different tariky say hy to wo change ho ga PreSkool k pattern per sirf esy features, ya cheezin jis say milta julta Kuch bhi PreSkool main nahi wo hum baad main decide karin gy" — the test is whether PreSkool has the thing **or anything similar to it**: if yes, and ours works differently, ours changes to PreSkool's pattern. PRINT is the owner's own example: print exists in PreSkool, ours is a different way, so the print system (designer included, per item 3) changes to PreSkool's pattern — it is NOT a deferred core-only case. The deferred category is only features/things with **no similar counterpart in PreSkool at all**; those stay as-is until the owner decides. PKG-5 dispositions apply this "milta julta" (similar-counterpart) test.
8. **Named example — FEES (owner, 2026-11-15 ~21:11 PKT):** "jesy fee Ka hamara system he change hy jab k PreSkool Ka or system hy to hum PreSkool Wala system adopt karin gy or apny system ko change Ker dain gu" — the fee system is a named application of the item-7 test: PreSkool has its own fee system, ours is different, so PreSkool's fee system is ADOPTED and ours is changed to it (screens + workflow pattern of the vendor fees pages govern the pkfees surface at PKG-5/PKG-6). School fee DATA and balances remain real and governed throughout — the change is to the system's way of working, records migrate intact.
