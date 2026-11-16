# B6 — Print Design Parity Fix · 2026-11-15

Owner rule (2026-11-15 ~08:38 PKT): every print/document output in the mobile
apps must carry the WEB APP's unified print design. Audit §7 found the breach
on two layers: the API controllers rendered generated PDFs from their own
private inline HTML, and three app screens drew document-style sheets.
Fix ordered ~08:44 PKT ("Set kro na isy phir"). This lane: staging only;
production untouched; production swap package at §6.

## 1. Architecture (chosen from the code, no parallel template)

The web app and the API are two CodeIgniter apps over one database (the
codebase's own two-app convention — vendor models already live in both
trees). The fix therefore **deploys the web's producer files byte-identical
into the staging api tree** and rewires the two API controllers to call them
exactly as the web doors do. One producer source, two trees, md5-verified —
nothing was re-templated or copied as HTML into the API.

Producer stack (web tree → api tree, byte-identical; final manifest with
md5s in §5 after the host pull): Print_viewmodel, Print_studio,
Print_settings, Print_register, Print_canvas, Print_payslip_log,
Print_receipt_log, Fee_tombstone, Exam_documents, Exam_gate, Pk_fees
libraries; print canvas config; the print views (receipt family, document +
partials), the Print Center exam/payslip views, the canvas document view,
the certificate native producer and the two card producers; plus the web
app's saved Print Canvas design JSONs into the api app's cache so a
school-saved design renders identically at both doors.

API doors then render the producer's HTML and pass it to the tree's own
mPDF (the pre-existing pdf rails). A small `u_localize`/`w2_localize`
helper rewrites only `src=` attributes from the app base URL to the local
web-tree path, because the shared assets (logo, photos, QR/barcode images,
certificate backgrounds) live in the web tree — mPDF must load them as
local files, never over HTTP. Printed text (incl. verification URLs) is
untouched.

## 2. Per-kind before → after

| Kind | Door | Before | After |
|---|---|---|---|
| Fee receipt | Familydocs + Staffapi | Private inline HTML, text-only navy letterhead, hand-built table; figures recomputed in the controller | The web's unified receipt producer view (`print/printFeesByName`, transport twin for transport deposits) fed the model's own `getFeeByInvoice` read + school settings, marked as a reprint → governed DUPLICATE stamp; `Print_viewmodel::receipt` + `Print_studio::renderUnified`; generation logged by the producer itself |
| Report card | Familydocs | Private inline HTML from a mirrored marksheet computation | The Print Center marksheet stack: `Exam_gate::releasable()` → `Exam_documents::marksheet()` → `admin/printcenter/exam_marksheet` view. Family publication rule (is_publish) kept |
| Marksheet | Staffapi | Private inline HTML, mirrored computation | Same gate + producer + view as the web door |
| Admit card | Staffapi | Private inline HTML; **no Exam_gate at all** | `Exam_gate::releasable()` (new at this door — withheld answers the file:null honesty shape) → `Exam_documents::admitCard()` → `admin/printcenter/exam_admitcard` view |
| Certificate | Staffapi | Template text substituted into bare centred HTML; **background image explicitly dropped** (`background_applied:false`) | The web's unified certificate producer via `Print_canvas::nativeOutput('admin_certificate_printcertificate_php', …)` with the web controller's own var contract (design row array, student rows with pre-composed name, school settings); the design's background art renders; answer now reports `background_applied:true` when the template carries one **(proven on staging after the §5.4 Setting_model remedy: the PDF generates and the background art is embedded pixel-identical to the template asset)** |
| Student ID card | Staffapi | Bare text block; **QR printed as a literal text string** | Unified card producer (`admin/printstudio/native_cards/student_cards`, `Print_viewmodel::card()`) with the web single-card stub's vars; codes are the existing per-student QR/barcode **image assets**. The `record.view` payload the app's in-app card display consumes is unchanged |
| Staff ID card | Staffapi | Bare text block (name/ID/phone) | Unified staff card producer (`native_cards/staff_cards`) with the active `staff_id_card` design |
| Payslip | Staffapi | **No door existed** — the app drew its own sheet | **New additive kind `payslip`**: mirrors `Printcenter::payslip` call-for-call (same record query, `Print_viewmodel::payslip`, same view, generation written to the same `print_payslip_log` register). Gate = the web's own capability (`staff_payroll can_view`, via the API caps map) **plus** an own-record rule: the payslip must belong to the signed-in staff member (the app's payroll surface is the member's own payroll; other staff payslips remain a Print Center office action) |

Retired from the document path (kept in code, no longer called by
fileOpen): `doc_header_html`/`w2_doc_header_html` private letterheads and
the controllers' hand-built document tables. Familydocs' mirrored
`result_card` computation is likewise retired in favour of
`Exam_documents`.

## 3. App changes (iqrs-app-v2)

- **B6-1 · FeesScreen (Connect)** — the payment sheet no longer presents
  itself as a receipt: crest badge, school masthead, "Payment receipt"
  title and the "keep this receipt" line removed; the sheet is now titled
  "Payment detail" and shows the recorded figures as a screen
  confirmation. The official printed receipt button (server document)
  is the receipt path, unchanged.
- **B6-2 · StaffFeeReceiptActivity (Workspace)** — school-name masthead
  removed from the figures card; the caption now states the figures are
  the recorded payment and the receipt itself is the school file above.
  `FeeDesk.Receipt`'s comment corrected ("the screen copy is the
  receipt" → figures only; the document comes from fileOpen).
- **B6-3 · StaffPayrollActivity (Workspace)** — the payslip sheet is a
  data view; a new "See the payslip file" action opens the official
  server document via the new `kind=payslip` door
  (`W2Ui.openFile` pattern, `payslip_id` from the row's own id).
- Builds: `./build.sh both` clean — Connect v2.14 (25), Workspace v2.18
  (31). JVM suite: **371/371 PASS** (326 in the script's main list + 45
  in the classes its pre-existing missing-backslash skips; count is
  above the audit's 352 because the parallel QR lane's new test classes
  are in the tree). No version bump (owner's release step owns that).

## 4. Files changed

App (`~/workspace/iqrs-app-v2/`):
- `src/pk/edu/iqrs/app/ui/family/FeesScreen.java`
- `src/pk/edu/iqrs/app/ui/staff/StaffFeeReceiptActivity.java`
- `src/pk/edu/iqrs/app/ui/staff/StaffPayrollActivity.java`
- `src/pk/edu/iqrs/app/model/FeeDesk.java` (comment only)
- `src/res/values/strings.xml` (receipt caption reworded; `w2b_payslip_file` added)

API (local masters `~/workspace/iqrs-repo/api/`, php -l clean, PHP 8.3.6):
- `Familydocs.php` — before 30,067 B → after 30,585 B, md5 `94c4cd66185ce63aa419baf3c4b28311`
- `Staffapi.php` — before 573,699 B → after 581,176 B, md5 `8a592110f41789dba5b492ca309dc849`

**CORRECTION (completion lane, 2026-11-15): two different Staffapi builds
exist — do not confuse them.**
- The 581,176 B / `8a592110…` build above is the **B6-only build on the
  production base** — it is the ONLY Staffapi that may go to production
  (§6). The completion lane reconstructed it independently — diff of the
  staging base (577,558 B, md5 `11f04c9d…`, kept in
  `hidden_files/b6-print-fix/staging-pull/`) against the merged master,
  applied to the production base (573,699 B, md5 `5763cb9b…`) — and the
  reconstruction is **byte-identical**: 581,176 B, md5
  `8a592110f41789dba5b492ca309dc849`, php -l clean. Saved at
  `hidden_files/b6-print-fix/prod-candidate/Staffapi.php` (with
  `Familydocs.php`, md5 `94c4cd66…`).
- The file deployed to **staging** (and now sitting as the merged master
  `~/workspace/iqrs-repo/api/Staffapi.php`) is **585,035 B, md5
  `dfaf60e2…`** = staging base (with the BL-152 / BL-082 /
  desktop-slot / BL-098 deltas preserved) + B6. **It must NEVER be
  copied to production** — it would import the BL-098 scoped-key gate
  and the other lanes' deltas ahead of their own production lanes.
- Staging api tree also gained the surgically extended slim
  `Customlib.php` (10,254 B, md5 `9ee9d39d…`) and the 33 producer files
  of the §5 manifest, copied byte-identical from the staging web tree.

## 5. Staging deploy + proof

### 5.1 Deploy (build lane, hash-verified by the completion lane)

Deployed to the STAGING api tree only (backups in
`~/backups-b6-2026-11-15/` on the host, outside the trees). Tree proof
of the day = the DB name in `database.php` — staging
`u238632175_test123` vs production `u238632175_KliTy` (the Webservice
size marker no longer discriminates). Completion-lane re-verification
on the host: staging `Familydocs.php` md5 `94c4cd66…` (30,585 B),
staging `Staffapi.php` md5 `dfaf60e2…` (585,035 B — the staging-base
merge described in §4, NOT the production candidate).

Producer manifest (`~/backups-b6-2026-11-15/producer-manifest.txt`):
33 files copied byte-identical from the staging web tree, md5-verified
— libraries `Print_viewmodel` `d37bdc07…`, `Print_studio` `fa0be8e4…`,
`Print_settings` `5a009b27…`, `Print_register` `f13e3c4f…`,
`Print_canvas` `5511efbb…`, `Print_payslip_log` `3b473496…`,
`Print_receipt_log` `8f159f0e…`, `Fee_tombstone` `25cf955a…`,
`Exam_documents` `bd1fa753…`, `Exam_gate` `d037e0df…`, `Pk_fees`
`5cea073d…`; configs `print_canvas_presets` `96229410…`,
`print_section_documents` `df20d6eb…`; views `print/printFeesByName`
`555a877e…`, `printTransportFeesByName` `59e2bda8…`,
`thermalPrintFeesByName` `3f2b4929…`,
`thermalPrintTransportFeesByName` `295a6bf0…`, `print/receipt`
`f9f35f6e…`, `print/document` `1f0aba0c…`,
`admin/printcenter/exam_marksheet` `5829ff07…`, `exam_admitcard`
`40a626d3…`, `payslip` `1ac627f9…`,
`admin/printstudio/canvas_document` `d1dca366…`,
`admin/printstudio/native/admin_certificate_printcertificate_php`
`9f746cd1…`, `native_cards/student_cards` `dd5fc5f8…`,
`native_cards/staff_cards` `ab7d0a8b…`, and the five
`print/partials/*` views; plus the web app's saved Print Canvas design
JSONs (`print_canvas_brand/gallery/layout_fee/layout_student_cards`)
into the api app's cache. `Print_native.php` is recorded
MISSING-IN-WEB (exists in neither tree; nothing requires it). The
staging api `Customlib.php` was surgically extended in place (final
10,254 B, md5 `9ee9d39d…`); it was NOT replaced by the web copy.

### 5.2 Proof battery (completion lane, 2026-11-15)

Route: laptop jump (`rssh-jump.sh`) throughout — the direct route was
impaired (an rsync fetch over it was abandoned; the proof tarball came
back over a jump-route rsync wrapper, md5 `dd64fccc…` matched).
Battery `hidden_files/b6-print-fix/test-b6-host.sh` run ON THE HOST.
Two scoped lane keys were issued into `pk_api_client_keys` for the run
— id 36 `pk_e7647fe8455e` (staff-ext) and id 37 `pk_eaf23ec1bb6c`
(family-api), label "B6 print lane", sha256-hashed secrets, env-only
credentials — and **both revoked at close** (revoked_at 2026-11-15
05:41:39 UTC); the pre-existing unrelated active key id 30 was left
untouched. Fixtures: exam 18 "W2CB Script Monthly" (published,
enrolment 588, student 3699 "TEST Fixture W0"), certificate template 1
(has background), payslip 1 (staff 113's own, October 2026).

Script headline: **PASS=7 FAIL=5 SKIP=2** — the per-leg dispositions
below are the lane's verdicts after diagnosis. Of the five FAILs:
one is a defect in the battery itself (the feeCollect leg), one is
the expected id_card absence, one is a real server defect (the
certificate), and two are the missing-family-credential cascade
(the family login and the family report_card leg):

| Kind / leg | Verdict | Evidence |
|---|---|---|
| Fee receipt — staff door | **PASS** | The battery's own collect leg is defective twice over (it calls `staffapi/feeCollect` — the endpoint lives on `staffsync/feeCollect` — and its extraction needs master+line on one dict, while the statement puts the master on the group and the line inside it; the wave2ca defect class). Every collectable line of the fixture child is also exhausted (balances 0 / −600 after the wave batteries), so the leg was proven by reprint of an existing governed deposit (id 3056): unified-producer PDF with **DUPLICATE** stamp, balance line, 2 images, "Duplicate — reprinted 15 Nov 2026", paid 1,500.00 / balance carried 0.00. No new deposit was minted. |
| Fee receipt — family door | **Guard-level + shared producer** (not document-proven) | No family fixture password is recorded anywhere in the programme's records (searched; the only candidates on disk are the previous lane's refused guesses in `prep-remote.sh`, which were NOT used and nothing was reset). Guard probes all correct: no key headers → refusal, family key + bogus token → 401, staff token at the family door → 401, empty-password login → "Invalid Username or Password". The family door is the same deployed `Familydocs.php` (md5-verified) calling the same rewired producers as the proven staff legs. |
| Marksheet — staff door | **PASS** | PDF issued; poppler-verified on the VM against the DB: Rhymes & Activities **41.00 / 50.00** (min 20), **82%**, Pass / Distinction — exact match with `exam_group_exam_results` + subject row for enrolment 588. |
| Admit card — staff door | **PASS** | PDF issued through the now-gated door; name / exam / subject / exam date 2026-11-08 match the DB. The gate (`Exam_gate::releasable()`, state ≠ withheld) is invoked at this door (code-verified in the deployed file); exam 17 (results unpublished, enrolment 573) also evaluated releasable and issued — publication binds the family report card, not staff office documents. A withheld-state fixture was not constructed, so the withheld branch at the API door is code-verified only. |
| Report card — family door | **Guard-level + shared producer** (not document-proven) | Same credential gap as the family receipt. Familydocs' report_card runs the same gate + `Exam_documents` marksheet stack proven at the staff door, with the family `is_publish` rule retained in code. |
| Certificate — staff door | **PASS (after the §5.4 remedy)** | The door answers honestly (`file:null`, "The certificate could not be generated on the server.") but generation dies inside `Print_canvas::nativeOutput()` → `Print_register::create()` → `Print_canvas::brand()`, which calls `$this->CI->setting_model->getAdminlogo()` — **the api tree's slim `Setting_model` has no `getAdminlogo()`** (the web model does; method list compared on the host). The Throwable is swallowed by the door's catch. Register bisect: `application/private/print_issuance/` was created by the attempt and holds only `register.lock` — the failure is before the first register write, at the brand() call. **Remedy (one method): port `getAdminlogo()` from the web `Setting_model` into the api tree's `Setting_model`, then re-run this leg (incl. the background-image assertion, which is therefore still unverified).** Required on staging AND in the production package (§6). **Remedy applied on staging (§5.4): the method was ported; the re-run leg generates the PDF with `background_applied:true`, and poppler verification on the VM proves the design's background art is embedded pixel-identical to the template asset.** |
| Student ID card — staff door | **Parity by absence (accepted)** | The `id_card` table holds **zero designs** (active or otherwise) on staging; the door answers `file:null` — "No active student ID card design exists yet." The web door reads the same table, so both doors are absent together. No design was activated to force a pass. |
| Staff ID card — staff door | **PASS** | PDF issued by the unified card producer: 2 embedded images (real QR/barcode assets), **no literal "QR:" text string**, name TEST STAFF M3 / TEST-M3-001 correct. |
| Payslip — staff door (new kind) | **PASS** | Own payslip (id 1) PDF issued; poppler-verified against the DB row exactly: basic 50,000.00, allowances 10,000.00, deductions 2,000.00, **net 58,000.00** ("Rupees Fifty Eight Thousand Only"), and the sheet cites its Print Center generation log row — the governed producer, not a private template. **Own-rule proven live**: staff 113 requesting payslip 2 (staff 114's) → `file:null`, "This payslip is not available for your account." The battery's cross-staff *login* probe could not run: the recorded values for staff 114 and 115 (hash-verified against the wave2ca §5 md5 pins) are refused by staging today — fixture drift since 2026-11-07, recorded, not guessed around. |
| Web-session comparisons | **Not run — substituted** | Staging web login is an AJAX + captcha flow (`gauthenticate/submit_login`, `site/refreshCaptcha`); the battery's classic form-post `web_login` cannot establish a session (`/site/login` GET redirects to `gauthenticate/login`). Substituted by (a) byte-identical producer files in both trees (manifest above) over one shared DB, and (b) DB data-truth cross-checks of every issued PDF (marksheet, payslip, receipt, admit card — all exact). |

Proof artefacts: `~/workspace/iqrs-app-v2/proof/b6/b6-proof/`
(5 PDFs + battery log + text extracts), fetched from the host and
re-verified with poppler on the VM (text + image counts as tabled).

### 5.3 Close-out

- Census before = after, exactly: students **1730**, staff **122**,
  deposits **1570**, payslips **2**. The cleanup SQL ran as a no-op
  (no fixture payslip was ever inserted — staff 113 already owned
  payslip 1; the receipt proof used a reprint, minting nothing).
  Governed print-register/log rows written by the producers during
  proof stay, as designed. One runtime artefact: the api tree's
  `application/private/print_issuance/` directory (created by the
  register's init during the failed certificate attempt; holds only
  `register.lock`) — the producer stack's own directory, harmless.
- Lane keys 36/37 revoked (above); host env files
  (`/tmp/b6-keys.env`, `/tmp/b6-creds.env`, `/tmp/b6-stage.env`,
  `/tmp/b6-issue.sh`) deleted.
- **Production untouched, verified read-only at close**: production
  `Staffapi.php` still 573,699 B / md5 `5763cb9b…`, production
  `Familydocs.php` still 30,067 B / md5 `fea36093…`, production DB
  marker `u238632175_KliTy`.

### 5.4 Certificate remedy lane (2026-11-15, after the completion lane)

The §5.2 remedy, executed on STAGING only. `Staffapi.php` and
`Familydocs.php` were not touched by this lane (the parallel Exam
Centre build lane owns staging Staffapi edits).

- **Route**: the laptop jump route exhausted at lane start (6
  attempts, proxy closed during CONNECT); the direct `rssh.sh` route
  connected and was used throughout — switch recorded per the deploy
  discipline.
- **Tree proof**: staging api tree `database.php` =
  `u238632175_test123` (production api = `u238632175_KliTy`),
  re-verified inside the deploy script itself before any write.
- **The port (one method, nothing else)**: the `getAdminlogo()` block
  was extracted byte-for-byte from the staging WEB tree's
  `Setting_model.php` (21,323 B, md5 `b33fc41a…`, method at line 245)
  and inserted into the staging api tree's slim `Setting_model.php`
  immediately before `getAdminsmalllogo()` — the web model's own
  relative position — with CRLF endings preserved. Base 11,539 B /
  md5 `23b4d0c1…` → ported **11,733 B / md5 `b7f0d5ae…`** (+194 B;
  the diff is exactly the 5 method lines + one blank separator line).
  Local `php -l` (PHP 8.3.6) clean before deploy. Backup outside the
  trees: `~/backups-b6cert-2026-11-15/Setting_model.php.pre-remedy`
  on the host (md5 `23b4d0c1…`). Deployed file mode 644, on-host md5
  verified `b7f0d5ae…`, `getAdminlogo` count 1.
- **Battery (certificate leg re-run)**: one scoped lane key issued
  into `pk_api_client_keys` — id 39, key_id `b6cert-staff`, scope
  staff-ext, sha256-hashed secret, label "B6 cert remedy lane
  2026-11-15" — and **revoked at close** (revoked_at 2026-11-15
  06:30:55 UTC); the unrelated active key id 30 was left untouched.
  The certificate portion of `test-b6-host.sh` (fixture = certificate
  template 1, student 3699, session 21) now reads: staff login PASS,
  **certificate PDF PASS**, **background_applied=true PASS**. The
  leg's on-host image count (the minimal `pdfx.py` inspector) still
  reports 0 — a measurement artefact against mPDF 8.2.6 output,
  overridden by the prescribed poppler re-verification on the VM:
  `pdfimages -list` shows **3 images** — page 1: 202×217 admin logo
  (+smask; the very brand asset `getAdminlogo()` supplies), page 2:
  **1100×850 background** (+smask), page 3: 500×500 student photo
  (jpeg). Background comparison: the extracted page-2 image's RGB
  channels and alpha (smask) are **pixel-identical** (sampled mean
  |diff| = 0.0) to the template's background asset
  `uploads/certificate/sampletc121.png` (1100×850 RGBA, md5
  `5ac2051a…`), and the rendered page 2 visibly carries the design's
  ornate border. Proof artefacts: `b6-proof/staff-certificate.pdf`
  (627,770 B, md5 `25f4ef56…`), `staff-certificate.txt`,
  `battery-b6cert.log` beside the other kinds.
- **Census after = baseline exactly**: students 1730, staff 122,
  deposits 1570, payslips 2 (governed register rows from the issuance
  stay, as designed).
- **Production untouched, verified read-only at close**: production
  api `Setting_model.php` still 11,539 B / md5 `23b4d0c1…` (the
  remedy is staging-only; §6 item 5 carries it to production),
  production `Staffapi.php` `5763cb9b…`, production `Familydocs.php`
  `fea36093…`, production DB marker `u238632175_KliTy`.

## 6. Production swap package (prepared; owner's per-file tap)

**CORRECTED by the completion lane.** Production tree
`~/domains/iqrs.edu.pk/public_html` (api subtree
`.../public_html/api`). Verified at package time: the production api
tree currently has **none** of the producer libraries, **no** canvas
JSONs in its cache, a slim `Customlib.php` (md5 `8536a335…`) **without**
`getStaffID()`, and a slim `Setting_model` **without**
`getAdminlogo()` — items 3–5 below are therefore all required, not
optional.

1. **Tree proof first** — the DB name in the production tree's
   `database.php` must read `u238632175_KliTy` (the Webservice size
   marker no longer discriminates the trees). Report the proof before
   any upload.
2. **Backups** to `~/backups-b6-prod-<date>/` (outside the trees):
   production `Familydocs.php` (30,067 B, md5 `fea36093…`),
   `Staffapi.php` (573,699 B, md5 `5763cb9b…`), `Customlib.php`
   (`8536a335…`), `Setting_model.php`, plus any manifest file that
   already exists in the production api tree (expected: none of the
   producer files).
3. **Producer stack**: copy the §5.1 manifest (33 files) from the
   **production WEB tree** into the production api tree, byte-identical,
   md5 per file; copy the production web tree's own saved canvas
   JSONs (`print_canvas_brand.json`, `print_canvas_gallery.json`,
   `print_canvas_layout_fee.json`,
   `print_canvas_layout_student_cards.json`) into
   `api/application/cache/`; dirs 755 / files 644.
4. **Customlib extension**: port the same surgical extension the
   staging api tree received (staging result: 10,254 B, md5
   `9ee9d39d…`, kept at
   `hidden_files/b6-print-fix/staging-pull/Customlib.php`) — diff it
   against the production slim Customlib first and port the hunks;
   do not overwrite blindly if the bases differ.
5. **Setting_model remedy (REQUIRED — §5.2 certificate root cause)**:
   add `getAdminlogo()` to the production api tree's `Setting_model`,
   ported verbatim from the web model:
   `public function getAdminlogo() { $query = $this->db->select('admin_logo')->get('sch_settings'); $logo = $query->row_array(); return $logo['admin_logo']; }`
   Apply the same remedy to the STAGING api tree first and re-run the
   staging certificate leg (background-image assertion included)
   before this production tap.
   **Staging-proven (§5.4, 2026-11-15)**: staging api slim base
   11,539 B / md5 `23b4d0c1…` → ported 11,733 B / md5 `b7f0d5ae…`
   (method block only, local `php -l` clean; certificate leg PASS
   with the background image pixel-verified). The production api
   slim base measured **byte-identical to the staging base** at
   remedy time (same 11,539 B / `23b4d0c1…`) — port the method into
   the production tree's own file in place, exactly the same way;
   never copy the staging api file wholesale (the item-6 Staffapi
   warning is the standing reason).
6. **Controllers** (prepared files at
   `hidden_files/b6-print-fix/prod-candidate/`):
   `Familydocs.php` (30,585 B, md5 `94c4cd66…`) and the **B6-only**
   `Staffapi.php` (581,176 B, md5 `8a592110…`); md5-verify on host
   after upload. **WARNING: the staging file (585,035 B, md5
   `dfaf60e2…`) must NEVER be used here** — it carries the BL-098
   scoped-key gate and the BL-152 / BL-082 / desktop-slot deltas
   ahead of their own production lanes (§4 correction).
7. **Smoke**: loopback CSS non-zero bytes; no-token guard probes at
   both doors; one receipt + one payslip + one certificate PDF spot
   check per door (certificate included — it is the kind that was red
   on staging until item 5).
Rollback: restore the controllers, `Customlib.php` and
`Setting_model.php` from backup and delete the added producer files
(list = §5.1 manifest minus files that pre-existed); the app changes
ship with the next app release and are backward compatible (the
payslip button's door simply answers file:null on an unpatched
server).

## Addendum — COMBINED production package (2026-11-15, combined-prep lane)

This §6 package must NOT be deployed on its own. The Exam Centre lane's
production candidate (EXAM-CENTRE-PARITY-2026-11-15.md §7.4) is also
built on the production base with only its own hunks; deploying the two
Staffapi candidates in sequence would erase the first, and its
`examDateSheet` endpoint depends on this package's producer stack.

A single combined candidate has been built and verified locally:
production base (573,699 B, `5763cb9b…`) + B6 hunks (9) + exam hunks (2),
disjoint regions, changed-line-multiset proofs that the combined file
differs from each single-package candidate by exactly the other
package's hunks and nothing else, no staging-only content (BL-098 /
BL-152 / BL-082 markers ×0), `php -l` clean.
**Combined Staffapi: 598,396 B, md5 `1dfe04a3057b11dace4feba8f17094dc`.**

Full manifest (package contents, producer list, Customlib + Setting_model
specs with host md5 gates, backups/rollback, deploy order, read-only
smoke list): `hidden_files/prod-combined-2026-11-15/MANIFEST.md`.
The deploy, when tapped, follows that manifest — controllers last,
combined Staffapi final. Items 1–5 and 7 of §6 above are carried into
the manifest unchanged in substance.
