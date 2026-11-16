# IQRS Print System Plan — One Paper System for the Whole School

**Workstream:** Print Systems (Print Lead + Print Design + Print QA), IQRS Web System Overhaul programme (goal `goal_477711825d07`)
**System:** iqrs.edu.pk — Smart School 7.2 (CodeIgniter 3, PHP) on Hostinger shared hosting; web admin + student/parent portal + vendor mobile API
**Date:** 2026-11-07 · **Status:** PLAN ONLY — plan + local code study. No live system was touched, no browser was used, no staging or production file was changed by this workstream.
**Design authority:** Calm Campus Web (Audit §3.3) — navy `#10204D`, gold `#D4AB42`, ivory `#FAF7EF`; crest only as a fixed-size circular badge with a 2px gold ring, aspect-locked, never cropped/stretched/recoloured; Georgia reserved for editorial/print; Inter with tabular numerals for all data/money. Direction F "The Ledger" (Design Directions Supplement) is adopted **only** as this plan's print layer — it was already A's editorial/print layer; F wholesale (Georgia inside operational screens) remains rejected.
**Companion documents:** `WEB-APP-AUDIT-AND-DESIGN.md` (§2, §3.1, §3.3, §3.4 Phase 3), `DESIGN-DIRECTIONS-SUPPLEMENT.md` (Direction F; borrowings D + E), `Smart_School_7.2_Roles_and_Features.md` (permission/report inventory), live walk `audit-live-walk.md` — all under `~/workspace/goals/iqrs-school-mobile-app/`.

> **The owner's complaint, in one line:** every place prints differently — different styles, headers and workflows per document — and nothing "sets properly" on the page anywhere.
> **This plan's answer, in one line:** stop treating print as a button on each screen. Build **one print layer** — one header, one footer, one stylesheet, one set of named paper profiles, one preview → print/PDF workflow, one settings screen — and migrate every document family onto it, fee receipt first.

**Evidence marking used throughout:** **LOCAL-PROVEN** = read in a file held locally (path given). **INVENTORY** = named in the Smart School 7.2 permission/feature inventory. **LIVE-OBSERVED** = seen on production in the 2026-11-07 read-only walk. **STAGING-CONFIRM** = believed to exist in the web application but **not verifiable from local files** — must be confirmed from the staging tree (§1.4 lists exactly what to download).

---

## 1. Inventory — method, local findings, and the known gap

### 1.1 Method

1. **Read the design/audit record first** (audit §2 workflow rows for Fees/Exams/Reporting, §3.1 "Print inherits the chrome", §3.3 identity rules, §3.4 Phase 3 "Paper and messages"; Supplement Direction F; live-walk print-adjacent observations). This fixed the *questions* before touching code.
2. **Searched every locally held code tree** for the print vocabulary: `print, Print, pdf, PDF, mpdf, dompdf, receipt, marksheet, admit, certificate, challan, payslip, invoice, _print`, plus `window.print`, `@media print`, and print-template filenames:
   - `~/workspace/iqrs-api/production/api/` — vendor mobile API application, byte-identical to the production API (full `application/views/` listing enumerated; `application/` searched excluding `third_party/` vendor packages, whose AWS/mPDF-library hits are library internals, not school templates).
   - `~/workspace/iqrs-webfix/display/` — the **only** web-admin view files held locally: `orig/` + `patched/` copies of `studentShow.php`, `_getBalanceFee.php`, `getcollectfee.php` (downloaded from staging 2026-11-07 for the discount-display fix).
   - `~/workspace/iqrs-legacy-source/smart_school_mobile_api_src/` — purchased API package mirror, including its `backend/` folder (assets only — see §1.3).
3. **Enumerated the surfaces that must exist** from the 7.2 inventory (30 permission groups, 234 functions, **51 reports**, 10 add-ons) and the audit — each marked INVENTORY / STAGING-CONFIRM, never presented as locally verified.
4. **Recorded the gap as a deliverable**: §1.4 is a precise download specification for the parent agent, because the web admin application's own views/controllers — where most Smart School print templates live — **are not in any local copy**.

### 1.2 What the local code actually contains — findings table

| # | Surface | Where found (evidence) | Current style / workflow notes |
|---|---|---|---|
| L1 | **Online-course certificate PDF** — the *only* true server-side PDF document generation in all local application code | `iqrs-api/production/api/application/controllers/Webservice.php` — `coursedownloadcertificatepdf()` (≈line 6538) + `downloadCertificateFile()`, `show_qr()`, `deleteCertificateFile()`; view `application/views/studentcourse/downloadcertificatepdf.php`; library `application/libraries/M_pdf.php`; model `Coursecertificate_model.php` (tables `online_course_certificate_template`, `certificates`) — **LOCAL-PROVEN** | mPDF (loaded via `third_party/omnipay/vendor/autoload.php`). Custom page format **[195 × 140.2 mm], all margins 0**; `autoScriptToLang`/`autoLangToFont` on. The view is a shell — `<html><body style="margin:0;padding:0"><?php echo $certificate_templatedat; ?></body></html>` — i.e. **the entire design lives in a database-stored HTML template**, with two different placeholder syntaxes substituted in sequence (`[field]` in certificate text, `{field}` in the template). A 60×60 QR image (verification URL) is injected. File is written to `temp/`, returned as a download URL, and deleted on download. **This is an online-course certificate only — it is not the school's student certificate system.** |
| L2 | **PDF library defaults contradict L1** | `application/libraries/M_pdf.php` — `load()` with no parameters returns mPDF with `format => 'Legal'`, margins **2 mm** on all sides, `default_font => 'roboto'` — **LOCAL-PROVEN** | The one shared PDF wrapper's defaults (Legal paper, Roboto, 2 mm) match neither the certificate call (195×140.2 mm, 0 margins) nor any A4 school document. Even inside the API, "PDF" has no house standard — each caller invents its own page. |
| L3 | **Gateway payment "invoice"** (×2: fees and online courses) | `application/views/payment/invoice.php`; `application/views/course_payment/invoice.php`; reached via `Payment::successinvoice()` (≈line 732, itself mostly commented out) and ~20 gateway controllers redirecting to `payment/successinvoice` / `course_payment/course_payment/successinvoice` — **LOCAL-PROVEN** | `payment/invoice.php` in full is one line: `<p style="color:#388e3c; font-family: arial; font-size: 18px; text-align:center;">Thank you for payment.</p>` — **a thank-you message, not an invoice**: no school name, no receipt number, no amount, no student, nothing printable. After paying online, a parent receives no document at all from the API side. (IQRS is cash-only in practice today — LIVE-OBSERVED, no gateway configured — so this is latent, not daily, harm.) |
| L4 | **Exam result view (API)** | `application/views/examresult.php` — **LOCAL-PROVEN** | Not a marksheet. It is a data-shaping script that builds a result object and ends in `print_r($exam)` — a debug dump. **The API contains no printable marksheet/report-card template of any kind**; results reach families as JSON data only. All marksheet printing is web-side (STAGING-CONFIRM). |
| L5 | **Student profile print — PDF download** (web admin) | `iqrs-webfix/display/orig/studentShow.php` (4,128 lines; 278,764 bytes) — `.print_student_details` handler (≈line 3639): AJAX `POST student/printStudentDetails`, response forced to a PDF blob, downloaded as `<student_name>_<admission_no>.pdf` — **LOCAL-PROVEN** (button + client handler; **server template/controller NOT held locally**) | Workflow type A: *server PDF, silent download, no preview*. The user never sees the document before it lands in Downloads. Template, header and page size are unknowable locally — STAGING-CONFIRM (controller `Student::printStudentDetails` + its view). |
| L6 | **Exam-result print — browser print by body-swap** (web admin, same file) | `studentShow.php` — `printDiv()` (≈line 3608), invoked by a print icon in the Exam Result tab (≈line 1814) — **LOCAL-PROVEN** | Workflow type B, and the single clearest local proof of "doesn't set properly": the script copies `#visible`'s innerHTML into a **brand-new `<html><head><title></title></head>` with no stylesheet at all**, calls `window.print()`, restores the page, then **`location.reload(true)`** — a full page reload after every print. Empty title, no print CSS, no header/footer, output depends entirely on the browser's default rendering of naked HTML. |
| L7 | **CBSE exam print — a second, divergent copy of the same hack** (web admin, same file) | `studentShow.php` — `printDivCbse()` (≈line 3623), print icon in the CBSE tab (≈line 896) — **LOCAL-PROVEN** | Workflow type B′: copy-pasted variant of L6 with its own quirks (it sets `#cbseexam`'s display to `none` before copying its HTML — the inverse instinct of `printDiv()` un-hiding its target). Two near-identical functions, two behaviours, one file. This is the codebase's print pattern in miniature: **duplicate, diverge, never share**. |
| L8 | **Suppression classes are themselves inconsistent — and one spelling is provably dead** (web admin) | `studentShow.php` — elements carry `no_print` (e.g. ≈lines 896, 1814) **and** `no-print` (e.g. ≈lines 2287–2673) — **LOCAL-PROVEN**; the theme CSS's `@media print` block (L15) targets **`.no-print` only** | Two spellings of "hide when printing" coexist, and the only print CSS in evidence honours just one of them: every `no_print` element is unprotected and prints. Even the *opt-out* convention is not unified — and this is now a proven mismatch, not a suspicion (subject to §1.4D confirming the web theme CSS matches this bundle). |
| L9 | **Barcode / QR on the student profile** (web admin) | `studentShow.php` ≈lines 214–232 (and duplicated for siblings ≈lines 305–324): renders `uploads/student_id_card/barcodes/<student_id>.png` and `uploads/student_id_card/qrcode/<student_id>.png`, gated by `$sch_setting->student_barcode` — **LOCAL-PROVEN**; also LIVE-OBSERVED ("barcode + QR render" on the sampled profile) | Proves the ID-card asset pipeline (per-student barcode + QR PNGs) already exists and is settings-gated — the unified ID-card template (§3.4) consumes these exact assets. Note the paths tie identity codes to the **ID-card** feature, not to receipts. |
| L10 | **Collect Fees — "Collect & Print"** (web admin) | `iqrs-webfix/display/orig/_getBalanceFee.php` (174 lines) — modal footer holds two buttons **both with `id="load"`**: Collect Fees (`data-action="collect"`) and Collect & Print (`data-action="print"`, language key `collect_print`) — **LOCAL-PROVEN** | Workflow type C: print is a *flag on the save action* in a single-fee collection modal; the receipt template and the print handler JS are **not in this file** (STAGING-CONFIRM). The modal also carries its own inline `<style>` block (flex helpers, checkbox padding) — styling embedded per-view, again. Duplicate element IDs in the footer are a small but telling quality signal. |
| L11 | **Group fee collection — no print affordance at all** (web admin) | `iqrs-webfix/display/orig/getcollectfee.php` (781 lines) — the whole group-collect form ends in a single **Pay** submit (`payment_collect`); no print button, no receipt link anywhere in the file — **LOCAL-PROVEN** | So the two fee-collection flows a clerk alternates between **disagree about whether printing exists**: single collect can print (L10), group collect cannot (or prints from a screen not held locally). The file also defines `.fees-footer` **twice** in its own inline `<style>` and sets fee headings in `'Roboto-Medium'` — per-view typography, per-view CSS, no shared sheet. |
| L12 | **Fees screen furniture leaks toward paper** | Live walk: the Collect Fees screen "parks a strip of ~28 classmate photos on the page"; audit §3.1: "Print inherits the chrome" — **LIVE-OBSERVED** | Screen views were never designed with a print twin: unrelated screen furniture (photo strips, icon actions, filter bars) sits in the same DOM that browser-print paths like L6/L7 dump onto paper. |
| L13 | **"Document print design / Shared Template Library" banner** | Live walk, Student Information search page: a stray banner reading *"Document print design / Shared Template Library"* sits atop the page — **LIVE-OBSERVED** | Evidence that a template/design surface exists somewhere in the deployed web app (likely a Rektrs/custom or vendor template feature) whose entry point leaks into an unrelated search screen. What it is, and whether any document uses it, is STAGING-CONFIRM — it is a priority interview item for the inventory (§4, Step 0), because if a shared template library already exists, Wave 3 builds on it instead of beside it. |
| L14 | **Print Header Footer setting exists — as a lone permission** | Inventory, System Settings (19): `Print Header Footer — View` (no Add/Edit/Delete listed separately) — **INVENTORY** | Smart School *has* a central print header/footer concept — which makes the observed inconsistency worse, not better: a central setting that documents visibly ignore (L6 prints with no header at all) is a setting applied **unevenly**, template by template. Its actual scope (which documents honour it) is the inventory's most important question — STAGING-CONFIRM. |
| L15 | **`backend/` assets (both API trees) + the one theme stylesheet** | `iqrs-api/production/api/backend/` and the legacy mirror's `backend/`: `bootstrap/`, `dist/`, `images/`, `js/`, `jquery.min.js` — AdminLTE assets, no views/templates — **LOCAL-PROVEN**. The dist CSS is a single bundle, `backend/dist/css/style-api.css` (223,407 bytes) — **LOCAL-PROVEN (inspected)** | The bundle contains **stock AdminLTE `@media print` rules only**: hide `.no-print`, `.main-sidebar`, `.main-header`, `.content-header`; reset content margins; an `.invoice`/`.invoice-col` layout (AdminLTE demo heritage, not a school receipt design) — plus a second small `@media print` block (≈line 409), DataTables print-view styling (`.dt-print-view h1` ≈line 1963, `.buttons-print`), and stray classes (`.printInv` ≈line 541, `.moprint` ≈line 2321). So the codebase's entire "print design" is *theme leftovers*: generic chrome-suppression with **no document typography, no header/footer, no page profiles** — and the held web print paths (L6/L7) don't even load it. **No dedicated print stylesheet exists.** Whether the web app's own theme CSS is this same bundle is STAGING-CONFIRM (§1.4D). |
| L16 | **Everything else in the API views folder is a checkout, not a document** | Full listing of `iqrs-api/production/api/application/views/`: ~50 files under `payment/`, ~40 under `course_payment/` (one folder per gateway: JazzCash, PayPal, Stripe, …), plus `errors/`, `examresult.php` (L4), `studentcourse/downloadcertificatepdf.php` (L1), `welcome_message.php` — **LOCAL-PROVEN** | The vendor API's view layer exists to take money through gateways, not to issue documents. **No fee receipt, fee invoice/challan, marksheet, admit card, ID card, school certificate, payslip, attendance register or report template exists in the API tree.** Every one of those lives — if anywhere — in the web application (§1.3). |

**Coverage statement (read this before quoting any finding):** local evidence covers (a) the complete vendor mobile-API application and (b) exactly three web-admin view files. It does **not** cover the web admin application itself. Every claim in §2 about the web side beyond L5–L13 is therefore marked STAGING-CONFIRM, and §1.4 is part of the deliverable, not an appendix nicety.

### 1.3 Print surfaces known to exist in Smart School 7.2 — to confirm from the staging tree

From the permission inventory (INVENTORY), the audit (§2) and the live walk. "Expected mechanism" is the standard Smart School pattern for that surface, stated as a hypothesis for the inventory to verify — not as a local fact.

| # | Surface | Evidence it exists | Expected mechanism (verify) | Priority |
|---|---|---|---|---|
| S1 | **Fee receipt** (single collection) | L10 Collect & Print; Fees Collection group (12 functions) | Dedicated receipt view, browser-print or PDF; header/footer setting may or may not apply | **P0 — pilot** |
| S2 | **Fee receipt** (group collection) + reprint from Search Fees Payment | L11 (absence in group form); `Search Fees Payment — View` | Receipt reprint view per invoice/sub-invoice (`invoice_id`/`sub_invoice_id` exist in the fee model — LOCAL-PROVEN in API models) | P0 |
| S3 | **Thermal fee receipt** | Add-on: **Smart School Thermal Print v1.0** — "Thermal Printer compatible small size fees receipt print" (`Thermal Print` permission) | Narrow-format receipt view (58/80 mm class), own template | P0 (decides a page profile) |
| S4 | **Fee invoice / bank challan** for unpaid fees (incl. duplicate-fee-invoice setting `is_duplicate_fees_invoice` — LOCAL-PROVEN as a settings field in the API's `Setting_model`) | Fees Master/Group/Discount functions; Fees Statement report; Offline Bank Payments function | Challan/invoice print view, possibly multi-copy | P0 — bank copy requirements unknown (§5) |
| S5 | **Student profile print** | L5 (`student/printStudentDetails` → PDF) | Server PDF (library unknown — mPDF? Dompdf? browser?) | P1 |
| S6 | **Marksheet / report card** | Examination: `Design Marksheet` (CRUD) + `Print Marksheet` (View) — a *designer + print* pair | Designed template (DB-stored layout like L1?) rendered per student/class; browser print or PDF | P0 after receipt |
| S7 | **CBSE marksheet** | Add-on CBSE Examination v3.0: `CBSE Exam Print Marksheet`, `CBSE Exam Template` | Separate template stack from S6 (audit: "two further, unreconciled stacks" with online exams) | P1 |
| S8 | **Admit card / roll-number slip** | Examination: `Design Admit Card` (CRUD) + `Print Admit Card` (View) | Designed template, bulk print per exam/class | P1 (exam-time critical) |
| S9 | **Exam schedule / date sheet print** | `Exam Schedule — View`; audit §2.6 | Print of the schedule table (DataTable print or view) | P2 |
| S10 | **Student ID card — ⭐ FLAGSHIP (owner-endorsed 2026-11-07)** | Certificate group: `Student ID Card` (CRUD = design) + `Generate ID Card`; L9 barcode/QR assets | Designed card template, bulk generation, likely multi-up sheet print. **Owner requirement:** one designed card that also lives on screen (profile/portal) — full spec §3.6; designed once with the print foundation, not as a late family migration | **P0 — flagship** |
| S11 | **Staff ID card** | Certificate group: `Staff ID Card` (CRUD) + `Generate Staff ID Card` | As S10, staff fields/photo | P1 |
| S12 | **Student certificates** (all designed types — e.g. character, leaving/transfer, merit, appreciation; exact type list is data, not code) | Certificate group: `Student Certificate` (CRUD = design) + `Generate Certificate` | Designed templates, DB-stored like L1's pattern; per-student generation | P1 |
| S13 | **Staff payslip** | HR: `Staff Payroll — View/Add/Delete`; Payroll Report | Payslip view per staff/month, print/PDF | P1 |
| S14 | **Payroll summary** | Reports: `PayRoll Report`; Multi Branch add-on also lists a Payroll Report | Report print/export (see S20) | P2 |
| S15 | **Attendance register / reports** | Student Attendance group; Reports: `Attendance Report`, `Daily Attendance Report`, `Student / Period Attendance Report`, `Student Attendance Type Report`, `Staff Attendance Report`, `Biometric Attendance Log` | Report print/export; a paper *register* format (monthly grid) if the school still keeps one — owner question (§5) | P2 |
| S16 | **Class / teacher timetable print** | Academics: `Class Timetable`, `Teachers Timetable` | Table print (browser/DataTable) | P2 |
| S17 | **Transport route / vehicle lists** | Transport group (7); `Transport Report` | Report print/export | P3 |
| S18 | **Library** — book lists, issue slips, member/library cards if any | Library group (5); Reports: `Book Issue Report`, `Book Due Report`, `Book Inventory Report`, `Book Issue Return Report`. **No library-card design/generate permission exists in the inventory** — cards, if used, are not a Smart School template | Report print/export; issue slip = STAGING-CONFIRM (may not exist) | P3 |
| S19 | **Front Office slips** — visitor pass, admission enquiry form/print, postal/complain prints if any | Front Office group (8): Admission Enquiry, Visitor Book, Phone Call Log, Postal Dispatch/Receive, Complain | STAGING-CONFIRM per item; visitor pass is the likely real paper surface | P2 (visitor pass), P3 rest |
| S20 | **The 51 reports' print/export outputs** | Reports group (51) — full list in the inventory: Student, Guardian, Student History, Login Credential, Class Subject, Admission, Sibling, Homework Evaluation, Student Profile, **Fees Statement, Balance Fees, Fees Collection, Online Fees Collection, Daily Collection, Balance Fees With Remark, Balance Fees Statement**, Income, Expense, Income Group, Expense Group, Payroll, Attendance family (above), Transport, Hostel, Audit Trail, User Log, Book family (above), Stock/Add Item/Issue Item, Exam Marks, Online Exam family (4), Staff, Rank, Syllabus Status family (2), Alumni, Gender Ratio, Student-Teacher Ratio, Online Admission | Near-universally DataTables-style **Copy / Excel / CSV / PDF / Print** buttons in Smart School — i.e. *five more output styles per report*, generated client-side, almost certainly ignoring Print Header Footer | P1 as a class (one fix pattern, 51 beneficiaries) |
| S21 | **Income / expense vouchers** | Income (3) + Expense (3) groups | STAGING-CONFIRM — voucher print view per entry, if present | P2 |
| S22 | **Homework / leave prints** | Homework (3); Approve Leave / Apply Leave functions. **No print permission exists for either** | Likely no dedicated print; browser print only — STAGING-CONFIRM; plan treats them as "print the record view cleanly" cases (§3.4) | P3 |
| S23 | **Login-credential print/slip** | Reports: `Student Login Credential Report`; Communicate: `Login Credentials Send` | Credential slips handed to parents — a real paper surface in most schools; format STAGING-CONFIRM | P2 (handle with care — credentials on paper) |
| S24 | **Rektrs custom: fee-allocation vouchers** | Inventory §6: Fee Allocation & Discount Matrix includes "**native vouchers**", Excel/CSV import-export, audit trail | Custom-module voucher print — STAGING-CONFIRM; must join the unified layer, not stay a private style | P1 |
| S25 | **"Document print design / Shared Template Library"** | L13 (LIVE-OBSERVED banner) | Unknown — identify in inventory Step 0; if it is a working shared-template engine, it changes the build plan (§4) | **P0 to identify** |
| S26 | **Email / SMS templates — the "message print" family** | Communicate: `Email Template` (CRUD), `SMS Template` (CRUD), `Email`/`SMS` send, `Email / SMS Log`, `Schedule Email SMS Log`, `Notification Setting`; System Settings: SMS Setting, Email Setting | DB-stored templates with placeholders (same disease as L1: per-template HTML, no shared layout). Audit §3.4 Phase 3 already assigns email templates (notice, fee reminder, login credentials, results) to this phase | P1 (same wave, §3.5) |
| S27 | **Online-exam & online-course documents** | Online Examination group; Online Course add-on reports; L1/L3 | Course certificate is L1; online-exam result print = STAGING-CONFIRM | P3 |

### 1.4 Exactly what the parent must download from staging to complete this inventory

The web application root on staging (the tree containing `application/views/student/studentShow.php` — path proven by the webfix notes). Download **read-only copies** into `~/workspace/iqrs-webfix/print-inventory/` (new folder; do not overwrite the display-fix files), preserving relative paths:

**A. Enumerate first (one command on staging, save the output as `print-file-list.txt`):**

```bash
find application/views application/controllers -type f \( -iname '*print*' -o -iname '*receipt*' -o -iname '*marksheet*' -o -iname '*admit*' -o -iname '*certificate*' -o -iname '*idcard*' -o -iname '*id_card*' -o -iname '*payslip*' -o -iname '*challan*' -o -iname '*invoice*' -o -iname '*voucher*' -o -iname '*header*' -o -iname '*footer*' \) | sort
grep -rln "window.print\|mpdf\|Mpdf\|dompdf\|Dompdf\|tcpdf\|wkhtmltopdf" application/controllers application/views --include='*.php' | sort
grep -rln "print_header\|header_footer\|sch_print\|printheader" application/ --include='*.php' | sort
```

**B. View subtrees (whole folders, not cherry-picked files — headers/footers hide in partials):**

- `application/views/studentfee/**` and any `application/views/**/fee*/**` (receipts, invoices, challans, print views)
- `application/views/student/**` (profile print view behind `printStudentDetails`, ID-card-related views)
- `application/views/exam/**`, `application/views/examgroup/**` and any `**/*marksheet*/**`, `**/*admit*/**`, `**/cbse*/**` (marksheet/admit designers + print views)
- `application/views/certificate/**` and any `**/*certificate*/**`, `**/*idcard*/**` (certificate + ID-card designers/generators)
- `application/views/admin/**` or `application/views/setting/**` — wherever the **Print Header Footer** screen and General Setting views live (locate via the grep in A)
- `application/views/reports/**` (one representative per report family + the shared report header partial, if any)
- `application/views/staff/**`, `application/views/payroll/**` (payslip views)
- `application/views/frontoffice/**` / `application/views/visitors/**` (visitor/enquiry prints), `application/views/transport/**`, `application/views/library/**`, `application/views/homework/**`, `application/views/leave/**` — existence check is itself a finding
- The **layout/partials** the print views include: `application/views/layout/**`, `application/views/partials/**`, any `_header/_footer` partial used by print views, and the file(s) behind the "Shared Template Library" banner (grep the banner's language key/string)

**C. Controllers (only the print-relevant methods can be excerpted, whole files preferred):**

- `application/controllers/Student.php` (`printStudentDetails`), `application/controllers/Studentfee.php` and/or `admin/Studentfee.php` (collect/print/reprint), the exam, certificate, ID-card, payroll and report controllers named in the `find` output from A

**D. Assets (the print CSS question cannot be answered without these):**

- `backend/dist/css/**` **or** the web app's equivalent theme CSS folder, plus any file matching `*print*.css` anywhere under the web root (`find . -iname '*print*.css'`), plus the main theme stylesheet(s) the print views link (to grep for `@media print`)
- Any `assets/css/**` at web root

**E. Data-side artefacts (names only, no database dump needed):** the list of designed templates as *rows* — marksheet designs, admit-card designs, certificate types, ID-card designs, email/SMS template names — screenshotted or exported as a name list from staging admin, so the inventory counts **designs in the database**, not just template files on disk (L1 proves designs can live entirely in the DB).

Until A–E land, §1.3 remains a hypothesis list and no Wave-3 estimate is final. That is expected and planned for: inventory completion is Step 0 of the build sequence (§4).

---

## 2. Diagnosis — why print is inconsistent in this codebase

Each cause is stated with its evidence class. Causes D1–D5 are proven locally or live; D6–D9 are structural inferences from the inventory + vendor pattern, marked STAGING-CONFIRM where they depend on unseen files.

**D1. Every module owns its print view, so every module invents its print design.** — LOCAL-PROVEN in structure. The API tree has exactly one document template (L1) and it is a DB-stored one-off; the web tree's three held files already show three unrelated print behaviours (L5 PDF download, L6/L7 body-swap browser print, L10 save-flag print, L11 no print). Smart School is built as ~35 module silos (audit §3.1); print was implemented *inside* each silo, per feature, by whoever built that feature. There is no print layer to be consistent *with*.

**D2. At least three incompatible output mechanisms are mixed, chosen per feature.** — LOCAL-PROVEN. (a) **Server PDF** via mPDF (L1, L5); (b) **browser print** of screen HTML via `window.print()` after a body-swap (L6, L7); (c) **client-side table export** (the DataTables Copy/Excel/CSV/PDF/Print pattern expected across the 51 reports, S20 — STAGING-CONFIRM in detail, near-certain in kind). The same school therefore issues documents rendered by three different engines, with three different paginations, fonts and margins — "doesn't set properly" is the *predictable* result, not bad luck.

**D3. The central Print Header/Footer setting is applied unevenly — honoured by some templates, invisible to others.** — INVENTORY + LOCAL-PROVEN by counterexample. The setting exists (L14), yet L6/L7 print with **no header, no footer, no school name at all** (the swapped-in HTML is only the result div), L3's "invoice" has no header either, and L1's certificate takes its whole appearance from its own DB template. A setting that each template must opt into will be opted out of by every template nobody revisited. STAGING-CONFIRM: which templates read the setting today.

**D4. There is no shared print stylesheet; styling is embedded per view — the only print CSS anywhere is stock theme leftovers.** — LOCAL-PROVEN. `getcollectfee.php` carries its own inline `<style>` (with `.fees-footer` defined twice); `_getBalanceFee.php` carries its own inline `<style>`; `studentShow.php`'s print path links **no stylesheet whatsoever**. The one theme bundle (L15) offers only AdminLTE's generic `@media print` chrome-hiding plus DataTables' print-view defaults — no document design — and it demonstrably misses half the suppression markup in use (L8). Where browser print is used, paper therefore inherits screen chrome (L12) minus whatever happens to be suppressed.

**D5. School identity on paper is hard-coded, per-template, or absent — never systematic.** — LOCAL-PROVEN + LIVE-OBSERVED. Documents take identity from: the DB template's own HTML (L1), nothing at all (L3, L6), or per-view markup (web templates, STAGING-CONFIRM). The settings model *does* centralise name/address/phone/email/logo fields (`sch_settings.name/address/phone/email/image/admin_logo/app_logo` — LOCAL-PROVEN in the API's `Setting_model`), but nothing forces templates to consume them, and the crest has **no sanctioned print treatment** today — the audit's crest rule (fixed circular badge, gold ring) exists only in the mobile design system. Result: different logos at different sizes, school name in different type, address present or missing — per document.

**D6. Page size, orientation and margins are per-template accidents.** — LOCAL-PROVEN for the API (Legal default vs 195×140.2 mm certificate vs unstated elsewhere, L1/L2); STAGING-CONFIRM for the web tree. No named page profiles exist anywhere in evidence. A receipt, a register and an ID card have genuinely different paper needs — but today the differences are unplanned, undocumented, and re-decided inside every template, including templates for the *same* document reached from different screens (S1 vs S2).

**D7. Designed templates live in the database, outside any design system.** — LOCAL-PROVEN for L1 (template HTML + text in `online_course_certificate_template`); INVENTORY-strong for marksheets, admit cards, certificates and ID cards (each has a *Design* permission paired with a *Print/Generate* permission, S6/S8/S10–S12 — the designer edits stored HTML). DB-stored designs cannot inherit a CSS file change: migrating them means migrating **rows**, one design at a time, through their designer UIs or carefully scripted updates (§4, Step 3). This is the least visible and most labour-bearing cause.

**D8. The print *workflow* differs per document, not just the styling.** — LOCAL-PROVEN + LIVE-OBSERVED. Collect & Print is a button *inside* a payment modal (L10); profile print is a silent PDF download with no preview (L5); exam print is an icon-only button with a tooltip (L6/L7 — audit notes icon-only actions have no visible labels); group collection has no print step (L11); Add Fees on the live system offers "Collect Fees / Collect & Print" as sibling submits. Staff must re-learn printing at every screen, there is **no preview step anywhere in evidence**, and a misprint is discovered on paper, at the counter, in front of the parent.

**D9. Money presentation on paper inherits the money-model flaw.** — LOCAL-PROVEN (audit §2.4) + display-fix record. Paid, discount and fine are fields of one JSON deposit entry; status historically derived from *paid + discount*, so a discount-only fee printed as "Partial" at Rs 0 paid. The 2026-11-07 display patch fixed the *screen* status in `studentShow.php` only (patched copy held locally). Any print template that computes its own status/totals — receipts and statements are exactly the templates that do — can still tell the old lie on paper even where the screen now tells the truth. Print unification must therefore specify money presentation (§3.3), not just money styling.

**Summary of the diagnosis:** the inconsistency is not a styling bug to be tidied; it is an *architecture absence*. No shared header/footer partial, no print stylesheet, no page profiles, no preview workflow, no enforcement that templates consume central settings — and a generation of per-module, per-mechanism, partly DB-stored templates filling the vacuum. The fix is to build the missing layer once and migrate families onto it (§3, §4), in the open, on staging.


---

## 3. The unified print design — Calm Campus Print

One print layer, named **Calm Campus Print**, sitting under Calm Campus Web. It has five parts: (3.1) an architecture decision, (3.2) shared header/footer/settings, (3.3) typography and the money rules, (3.4) named page profiles + the document-family table, (3.5) the single workflow, extended to messages.

### 3.1 Architecture recommendation: dedicated print views + one print stylesheet — not screen `@media print` surgery

**Recommendation: every printable document gets a dedicated print view** (a thin CI view whose only job is paper), rendered by **one shared partial set + one print stylesheet**, and that *same rendered HTML* feeds both output paths:

```
document data ──► dedicated print view (+ shared header/footer partials + print.css)
                      ├──► browser: print-preview route → window.print()   (immediate, at the counter)
                      └──► server:  same HTML → mPDF → PDF download          (identical pagination)
```

Why dedicated views, grounded in the local evidence:

- The screen views are unrecoverable as print sources: `studentShow.php` alone is 4,128 lines with photo strips, tabs, modals and two divergent body-swap hacks (L6–L8, L12). Bolting `@media print` rules onto screens like this is how the current mess was made — each screen would need its own suppression archaeology, forever.
- Browser-print and PDF currently diverge *by construction* (D2). Rendering **one HTML** and sending it to both the browser and mPDF makes "the PDF is the printout" true by definition — the single most valuable property for a fee counter ("reprint exactly what the parent was given").
- mPDF is already in the stack and already proven on this codebase for a designed document (L1) — including the two features print needs most and screens ignore: named page formats/margins per call, and `autoScriptToLang`/`autoLangToFont` for Urdu text. The unified layer standardises on **mPDF for PDF** and **the same HTML + print.css for browser print**; Dompdf/TCPDF/client-side jsPDF table dumps are retired wherever found (S20's DataTables PDF/Print buttons are replaced by routing reports through print views — phased, §4).
- Screen views keep a single responsibility: on screen, the Print action (§3.5) *links to* the print view. No screen view ever prints itself again. `printDiv()`/`printDivCbse()` and their copies are deleted, not patched.
- **Override-safety (audit §3.4 guardrail):** the print layer lives in the codebase's custom/override locations wherever Smart School allows, with every touched core view logged in the programme's touched-files register — a vendor update must not silently erase the school's paper identity.

**The print layer's fixed parts** (built once, §4 Step 1):

| Part | Form | Contents |
|---|---|---|
| `print_header` partial | CI view partial | Crest badge, school name/address/contact line (from settings, §3.2), document title block, document meta (number/date/session) |
| `print_footer` partial | CI view partial (+ mPDF footer string twin) | Page X of Y, generated-by/at line, system line, optional footer note |
| `print.css` | One stylesheet | Page profiles (§3.4), typography (§3.3), tables/rules, copy separators, `DUPLICATE` watermark, RTL rules. *The only print stylesheet in the system.* |
| Signature block partial | CI view partial | Up to three signature slots (label + name + scanned image or ruled line), per-document selection |
| Money table partial | CI view partial | The §3.3 money table — fees/statements/receipts never hand-roll totals again |
| Copy block partial | CI view partial | Renders one labelled copy (Bank / School / Student) of a multi-copy document |

### 3.2 Shared header, shared footer, ONE settings place

**Header (every document, no exceptions except ID cards/certificates which use their own governed variants, §3.4):**

- **Left/centre block:** crest as the fixed circular badge — white ground, 2px gold ring, fixed size (14 mm on A4, 10 mm on A5/thermal-scaled), aspect-locked — beside the school name **IQRA REHMANIA TUL ATFAL HIGH SCHOOL** in Georgia, navy `#10204D`; motto *"Knowledge. Faith. Excellence."* in letterspaced caps beneath (the one print place the motto always appears); address + phone + email line in Inter 8.5–9 pt grey-navy, sourced from General Settings fields (name/address/phone/email already centralised — D5 — the print layer finally *consumes* them).
- **Right block:** document title (Georgia, e.g. *Fee Receipt*), document number, date, session — right-aligned, tabular numerals.
- A single **gold rule** under the header. Nothing else. No orange strip (live site's `#F58001` is not carried forward — audit §3.3), no per-module coloured banners.

**Footer (every paginated document):** hairline rule; left: *Generated by <staff name> · <date-time, Asia/Karachi>*; centre: optional school footer note; right: **Page X of Y**. Plus the system line in 7.5 pt muted type: *IQRS — Smart School · This is a system-generated document.* Reprints carry the same footer plus the §3.5 duplicate marking. mPDF documents get the identical footer via mPDF's footer API (not a second design).

**One settings place — "Print & Documents" settings** (consolidation, not a new silo): a single settings screen that *absorbs and replaces* the scattered pieces:

| Setting | Absorbs / replaces | Notes |
|---|---|---|
| School identity for paper (name, motto, address, phone, email, school code) | Reads General Setting values; print layer consumes only these | No second copy of the school name anywhere in a template — hard-coded names in templates are an inventory defect to remove |
| Crest/logo file + badge treatment | General Setting logo fields (`image`, `admin_logo`) | One asset, one treatment; templates never reference logo files directly |
| Header/footer toggles + footer note text | **Print Header Footer** setting (L14) — becomes the header/footer section of this screen | After migration, Print Header Footer has exactly one consumer: the shared partials. Any template still reading it directly is unmigrated by definition — a greppable completion test |
| Signature library (Principal, Accountant/Cashier, Class Teacher, Exam Controller: name, title, scanned signature image) | New consolidation of per-template signature fields (STAGING-CONFIRM where they live today) | Documents pick slots; nobody uploads a signature into a single template again |
| Receipt options (copies count, duplicate watermark on/off, amount-in-words on/off, thermal vs A5 default) | Thermal Print add-on setting + per-flow habits | Defaults per document family, overridable at print time (§3.5) |
| Challan options (bank name/branch/account line as printed, copies layout) | New — pending owner answers (§5) | Data, not code, once the profile exists |
| Certificate/ID background assets | Certificate/ID designer uploads | Governed variants (§3.4), still editable via existing Design permissions |

### 3.3 Typography and the money rules (Direction F, disciplined)

The Ledger's contribution, kept inside its limits (Supplement F: *"Georgia has no tabular-figure discipline for money columns, so fee/marks figures must stay in a tabular sans even inside F — a rule the direction must accept or fail"*).

- **Georgia** — document titles, school name, certificate body/display text, marksheet headings, the editorial moments. Never in tables of figures, never below 10 pt.
- **Inter** (with **Plus Jakarta Sans** display numerals where the web system already uses them) — all data, tables, labels, footers; **tabular numerals (`tnum`) mandatory** for every amount, mark, total and date. Money columns right-aligned; totals closed with the Ledger's double rule.
- **Ivory `#FAF7EF`** is the *design* ground (preview screen, certificate stock design); actual printing assumes white paper unless the owner confirms pre-printed stock (§5) — templates must look correct on white, with ivory rendered only where a background is genuinely printed (certificates) and suppressible for pre-printed stationery.
- **Urdu/RTL:** documents carry Urdu names/subjects/notices. Print CSS defines an RTL variant (mirrored header meta, right-aligned text blocks) using **Noto Nastaliq Urdu** as the Urdu face in mPDF (with `autoLangToFont` carried over from L1's proven configuration) and in browser print where available. Mixed-direction lines (Urdu name in an English table) are a named QA case (§4, Step 4), not an afterthought. Roman-Urdu text prints in Inter unchanged.
- **Status language on paper** matches the screens: labelled words, never bare codes — *Paid / Partial / Unpaid / Settled by discount* (the display-fix vocabulary).

**The money honesty rules (non-negotiable, from audit §2.4 + D9) — every money document:**

1. **Paid, Discount, Fine and Balance are separate columns/lines, always.** A discount is never added into "Paid", never netted silently.
2. Status derives from **money paid only**: Rs 0 paid is *Unpaid* (with "Discount Rs X applied" as a note where a discount exists), never *Partial*.
3. Every receipt/statement shows: gross amount, discount, fine, **amount paid (in numerals and, on receipts, in words)**, balance carried — and the payment mode + instrument reference (cash/cheque/bank transfer + number) and **received-by** name.
4. Receipt numbers are the system's invoice/sub-invoice identity (S2), printed verbatim — a reprint must reproduce the original document, not recompute a new one.

### 3.4 Named page profiles + document-family table

Page profiles are named, versioned, and referenced by templates — a template may not invent geometry. Defaults (all margins include the shared header/footer zones where applicable):

| Profile | Paper / orientation | Margins | Used by |
|---|---|---|---|
| `A4-P` | A4 portrait | 14 mm sides, 12 mm top/bottom | Marksheets, statements, profile prints, certificates (portrait types), payslips (2-up variant below), most reports |
| `A4-L` | A4 landscape | 12 mm | Attendance registers (monthly grid), payroll summary, timetables, wide reports, exam schedules |
| `A5-P` receipt | A5 portrait | 9 mm | **Fee receipt (standard)**, income/expense vouchers, visitor pass (A6 option below) |
| `THERM-80` / `THERM-58` | 80 mm / 58 mm roll, continuous | 3 mm | Thermal fee receipt (S3) — condensed single-column variant of the same receipt data |
| `CHALLAN-A4L-3` | A4 landscape, **3 copies on one sheet** with perforation/cut lines | 10 mm + copy gutters | Fee challan: **Bank copy / School copy / Student copy**, each fully self-contained (same data, copy label in header), separated by ruled cut lines + scissor marks |
| `CARD-CR80` | CR80 85.6 × 54 mm, portrait (student/staff ID) | 3 mm safe zone | ID cards printed direct-to-card **and** `CARD-SHEET-A4` imposition (A4 sheet, 8-up with crop marks) for laser printing — same card view, two outputs |
| `CERT-A4-L` | A4 landscape | design-led | Certificates (editorial treatment; background art suppressible for pre-printed stock) |
| `A5-2UP-PAY` | A5 landscape slips, 2-up on A4 portrait | 10 mm | Payslips (two months/staff per sheet option) — final form pending §5 payroll questions |
| `A6-P` | A6 portrait | 8 mm | Visitor pass, login-credential slip, library due slip |

**Document-family table** — every surface from §1.2/§1.3, assigned a profile, an owner (template owner = who maintains it after migration) and its special elements:

| Family / document | Profile | Owner | Special elements |
|---|---|---|---|
| **Fee receipt** (single + group + reprint) | `A5-P`; `THERM-80/58` variant | Print Lead (pilot template) | Money table partial (§3.3), amount in words, receipt no., received-by, **DUPLICATE watermark on reprint**, QR optional-verification (deferred — §5) |
| **Fee invoice / bank challan** | `CHALLAN-A4L-3` | Print Lead | Perforated 3-copy block (bank/school/student), bank line from settings, due date prominent, barcode of invoice no. (reuse L9-style asset generation) |
| **Fees statement / balance statement** (per student) | `A4-P` | Print Lead | Money table partial, term/session running balance, Paid/Discount/Balance honesty rules |
| **Student profile print** (`printStudentDetails`) | `A4-P` | Print Design | Student photo, barcode + QR (existing assets, L9), guardian block, signature slot (Class Teacher) |
| **Marksheet / report card** (+ CBSE variant as a governed second template on the same partials) | `A4-P` | Print Design | Georgia headings, marks table in tabular Inter, grade/division block, signatures (Class Teacher + Principal), school seal space, Urdu subject names (RTL QA case) |
| **Admit card / roll-number slip** | `A5-P` (2-up on A4-P option for bulk) | Print Design | Photo, exam/venue/date table, barcode (admission no.), instructions block, Exam Controller signature |
| **Exam schedule / date sheet** | `A4-L` (A4-P for single-class) | Print QA (report pattern) | Class/exam matrix, shared report header |
| **Attendance register (monthly) + attendance reports** | `A4-L` | Print QA (report pattern) | Daily grid, P/L/A/H legend, monthly totals, Class Teacher signature line; summary reports on report pattern |
| **Student ID card — ⭐ flagship (§3.6)** | `CARD-CR80` / `CARD-SHEET-A4` | Print Design (CDO co-owns the screen rendering) | Photo, name, class/section, roll + admission no., session, barcode + QR (L9 assets), blood group/validity, crest as circular gold-ring badge, back side: address + guardian phone + return-if-found line. One template, two renderings: this print card and the on-screen card (§3.6) |
| **Staff ID card** | `CARD-CR80` / `CARD-SHEET-A4` | Print Design | Photo, designation/department, employee ID barcode, validity |
| **Certificates** (all designed types) | `CERT-A4-L` (portrait types on `A4-P`) | Print Design | Full editorial treatment: Georgia body, gold rule, crest badge as seal, two signature slots, certificate no. + verification QR (pattern proven by L1), background art suppressible |
| **Online-course certificate** (L1 — already PDF) | Keep its 195×140.2 mm format as named profile `CERT-COURSE` | Print Lead | **Migrate its shell onto the shared footer/settings** without changing its designed template; align QR/footer; record as the layer's first citizen, not an exception |
| **Staff payslip** | `A5-2UP-PAY` | Print Lead | Earnings/deductions two-column table, net in words, Accountant signature slot |
| **Payroll summary** | `A4-L` | Print QA (report pattern) | Department totals, report pattern header |
| **Timetable** (class + teacher) | `A4-L` | Print QA | Week grid, shared header (class/section in meta block) |
| **Transport routes / vehicle list** | `A4-P`/`A4-L` | Print QA | Report pattern; route stops table |
| **Library** (book/issue/due reports; due slip if confirmed) | `A4-P`; slip `A6-P` | Print QA | Report pattern; no card template unless staging shows one (S18) |
| **Visitor pass; admission enquiry print** | `A6-P`; enquiry `A4-P` | Print Lead | Visitor: photo optional, host/time block, barcode optional; enquiry: form-style record print |
| **Income / expense voucher** | `A5-P` | Print Lead | Money table partial (single-entry form), amount in words, approved-by slot |
| **Homework / leave record print** (if confirmed) | `A4-P` | Print QA | Clean record print via the generic record-print pattern (shared header + fact table) — no bespoke design |
| **Login-credential slip** | `A6-P` | Print Lead | Crest badge, plain-language instructions (Direction D discipline), credentials block — **printed only on demand, logged** (§5 security question) |
| **Rektrs fee-allocation voucher** (S24) | `A5-P` | Print Lead | Money partial; joins the layer — the custom module must not keep a private print style |
| **The 51 reports** (S20, as one family) | `A4-P` default, `A4-L` for wide set (attendance/payroll/transport named) | Print QA | **One report print pattern**: filter summary printed under the title ("Class One — One Star (Girls), November 2026" — the parameters are part of the document), report header/footer partials, totals ruled off Ledger-style; Excel/CSV exports keep data identical to the printed table |
| **Email templates** (notice, fee reminder, credentials, results) | n/a — HTML email on the same tokens | Print Design | §3.5 message family |
| **SMS templates** | n/a — plain text | Print Design | §3.5 message family |

### 3.5 One workflow — and the message family

**The single workflow (every document, every screen):**

1. **One button, one place, one label.** A labelled **Print / PDF** button (icon + word — never icon-only, correcting L6/L8-era practice) at the top-right of the document/record area, in the same position on every screen. Fee collection keeps **Collect & Print** as a *sibling of the same system*: it saves, then opens the same preview with the new receipt — it is no longer a separate mechanism (retires L10/L11 divergence; group collection gains the identical step).
2. **Preview first, always.** The button opens a **preview sheet**: the document rendered by its print view, shown on an ivory paper canvas at true profile proportions, with a small control bar — profile (locked to the family's default; switchable only where the family allows, e.g. receipt A5 ⇄ thermal), **copies** (challan/ID sheets), and the two exits: **Print** and **Download PDF**. No document in the system prints without passing through this preview. (This is also the Direction D borrowing applied to paper: check before you commit.)
3. **Print** = browser print of the preview's print view (print.css only — the preview chrome itself never reaches paper). **Download PDF** = the same HTML through mPDF. The two outputs are the same document (§3.1).
4. **Reprints** go through the same preview, are stamped **DUPLICATE** (diagonal watermark + footer line *"Duplicate — reprinted <date> by <name>"*), and are permission-gated exactly as today (RBAC unchanged).
5. **Bulk printing** (admit cards, ID cards, marksheets for a class) is the same preview with a record navigator / "print all (N)" — one job, one profile, crop/perforation marks where the profile defines them.

**Message family (Phase 3's other half — audit §3.4):** email and SMS templates are documents that happen to be sent, and they get the same treatment: one email layout (crest badge header, Georgia title, Inter body, gold rule, plain-language subject lines, token palette) instantiated by the notice / fee-reminder (with the §3.3 Paid/Discount/Balance split in the body) / login-credentials / results templates; SMS templates reviewed in the same pass for plain language, correct placeholders and Urdu variants. Their DB-stored templates (S26) migrate like the DB-stored print designs (D7) — inventoried, rebuilt on the shared layout, tested with real sends on staging.

### 3.6 Flagship — the Student Card: one design, two renderings (owner requirement, 2026-11-07)

The owner has made the student ID card a named requirement and this plan's flagship: a designed card that is simultaneously (i) an **on-screen card** on the student's profile (admin) and the child's dashboard/profile (portal — and, by the same view model, the Family app profile when the mobile programme adopts it), and (ii) a **first-class print surface** (S10) inside the unified print layer. It is designed **once**, in Wave 3 with the print foundation (§4, identity family), not migrated as an afterthought; the screen rendering ships with the Wave 5 profile surfaces but consumes the same template and data view-model.

**Front (both renderings, identical composition):**
- **School identity band:** navy `#10204D` field; the **crest only as the fixed circular gold-ring badge** (white ground, 2 px gold ring, aspect-locked — the standing crest rule; on a CR80 card the badge is small but the construction does not change); school name in Georgia, ivory; session (`2025-26`) as the band's secondary line.
- **Photo:** the student's photo from the record, in a fixed-ratio frame with a gold hairline. **Honesty rule:** most records currently hold no photo — where none exists the card renders the system's initials placeholder (navy initials on ivory), never a stock silhouette and never an empty box. The staff app's photo capture (already live in the mobile programme) is the sanctioned route by which real photos arrive; the card design must look complete with the placeholder, because for a while most cards will carry it.
- **Data block (labelled, tabular where numeric):** student name (Plus Jakarta Sans, the card's largest element) · class / section · roll number · admission number (IQ-STU…) · blood group where recorded (blank fields are omitted, never printed as empty labels).
- **Codes:** **QR code and barcode side by side** at the foot — the per-student assets the system already generates (`uploads/student_id_card/qrcode/<id>.png`, `…/barcodes/<id>.png`, finding L9, settings-gated by `$sch_setting->student_barcode`). The template consumes those assets; it does not invent a second code system. Both codes must survive print at CR80 size — minimum module size is a QA item (§4 matrix), not a hope.

**Back (print rendering; the screen card shows it as a flip/secondary view):** school address + phone · guardian name and phone · *"If found, please return to the school office"* line · validity line (session-bound — the card is re-issued per session, which is also the photo-refresh moment).

**Two renderings, one template:**
- **Print:** profile `CARD-CR80` (direct-to-card) and `CARD-SHEET-A4` (8-up imposition with crop marks) from the single preview → print/PDF workflow of §3.5 — including bulk class printing ("print all (N)") and DUPLICATE stamping on re-issue, exactly like every other document family. The DB-stored ID-card design (D7) is migrated to this template; the vendor designer UI is not the long-term editor for it.
- **Screen:** the same composition rendered as an HTML card at profile scale (portal + admin profile first). Screen-only additions are presentational, never informational: subtle shadow, the flip affordance for the back. No field exists on paper that is absent on screen, or vice versa — a parent who screenshots the portal card and a child carrying the PVC card hold the same document.

**Acceptance (staging):** a class set generated end-to-end (screen profile + CR80 PDF + A4 sheet) for records **with** and **without** photos; QR and barcode scan-verified from the printed sheet with a phone camera at arm's length; codes resolve to the same student the card names; placeholder cards are visually complete; one re-issue shows the DUPLICATE treatment. Production method (in-house PVC printer vs print-shop PDF with bleed) is the owner's §5 question — the template is specified so either answer works (bleed-safe margins live in the `CARD-CR80` profile, not in the artwork).

---

## 4. Implementation sequence — Wave 3 (staging first, as always)

Production is untouched until the sign-off gate (Step 5). All work lands on **staging**, file-by-file, with the programme's touched-files register maintained throughout.

**Step 0 — Complete the inventory (gate for everything else).**
Execute §1.4 (downloads A–E). Produce `PRINT-INVENTORY.md` (hidden_files): every template file + every DB-stored design, its mechanism (server-PDF / browser / DataTables / DB-template), whether it reads Print Header Footer, its current page geometry, and its family assignment from §3.4. Identify S25 ("Shared Template Library") and the thermal add-on's template. Interview the office (the §5 questions) in parallel. **Exit:** no surface in §1.3 remains STAGING-CONFIRM.

**Step 1 — Print foundation.**
Build §3.1's fixed parts: header/footer/signature/money/copy partials, `print.css` with all §3.4 profiles, the preview sheet (§3.5), the Print & Documents settings screen (§3.2) reading existing General Setting values, and the mPDF wrapper standard (retire `M_pdf`'s Legal/Roboto defaults — L2 — in favour of profile-driven calls). Migrate the online-course certificate shell (L1) as the foundation's smoke test. **Exit:** a test document renders identically in browser print and mPDF PDF, on every profile.

**Step 2 — Pilot: the fee receipt.**
Migrate S1/S2 (+ thermal variant S3) onto the foundation: single collect, group collect and reprint all issuing the *same* receipt; Collect & Print rewired through the preview; money rules §3.3 verified against the known discount-only case (the display-fix mirror case: discount Rs 700–1,000, paid Rs 0 ⇒ receipt must read *Unpaid*, discount shown separately, totals unchanged). The receipt is the pilot because it is the highest-volume, highest-trust document the school issues, printed at a counter, in front of a parent, many times a day. **Exit:** office staff print the pilot on the real counter printer(s) on staging and the Print QA matrix (§Step 4) passes for the receipt family.

**Step 3 — Family-by-family migration** (order by parent-visibility × volume):
1. Money family: challan/invoice (S4), fees statement (S20 subset), vouchers (S21), Rektrs voucher (S24).
2. Exam family: marksheet (S6), CBSE marksheet (S7), admit card (S8), exam schedule (S9) — *timed to land well before the next exam cycle is configured (audit: 0 exams exist for 2025-26 today, so this family migrates against sample data and is ready when exams are).*
3. Identity family: student/staff ID cards (S10/S11), certificates (S12), profile print (S5).
4. HR family: payslip (S13), payroll summary (S14).
5. Reports family: the 51 reports (S20) onto the single report pattern — the highest-leverage single change (one pattern, 51 documents); DataTables print/PDF buttons retired per report as it migrates.
6. Operations family: attendance (S15), timetables (S16), transport (S17), library (S18), front office (S19), homework/leave records (S22), credential slips (S23).
7. Message family: email/SMS templates (S26, §3.5).
DB-stored designs (D7) migrate design-by-design through their existing Designer screens wherever possible (paste/ rebuild on the new partials' markup), scripted only with a per-design before/after render proof. **Exit per family:** its QA matrix rows pass; its old print path is removed (no dual-running — dual-running is how divergence returns).

**Step 4 — Print QA matrix** (executed per family, full pass before Step 5):

| Axis | Cases |
|---|---|
| Browsers | Chrome (office default), Edge, Firefox — preview, browser-print and PDF-download paths in each |
| Paper profiles | Every §3.4 profile the family uses, on the **actual printers** (counter laser, thermal if in use — §5) incl. duplex where used, A5-in-A4-tray handling, CR80 sheet alignment/crop marks |
| Content extremes | Long Urdu + English names, maximum-length fee heads, 40+ line statements (page breaks, header repeat, Page X of Y), zero-fee / full-discount / partial-paid receipts, fine-only-after-fee rule cases |
| Urdu / RTL | Urdu subject names on marksheets, Urdu notice text in email, mixed-direction table rows, Nastaliq rendering in **both** browser print and mPDF |
| Photos & codes | Student/staff photos (missing-photo placeholder case — live data has many blanks), barcode/QR legibility at final print size (scan test with the QR-attendance flow), crest badge at all profile sizes |
| Copies | Challan 3-copy separation/perforation, ID-sheet imposition counts, duplicate/reprint watermark + audit line, bulk jobs (full class) without memory/timeout failure on shared hosting |
| Money truth | The §3.3 rules re-verified on paper for: discount-only, partial, paid-in-full, fine-bearing, arrears-carrying cases — totals must equal the screen's (post-display-fix) totals exactly |
| Settings | Change name/address/signature once in Print & Documents ⇒ every family's next print reflects it (the D3 regression test) |

**Step 5 — Sign-off gate → production proposal.**
Print Lead + Print QA sign the matrix; the owner receives: staging links, printed samples (photographed/scanned) of each family, the touched-files register, and a production proposal (file list, order, rollback = restore originals per file). **No production change without the owner's explicit approval** — the programme's standing staging-first rule. Rollout itself, when approved, follows the display-fix precedent: single-purpose file swaps, verified on production with the same QA spot-checks.

**Wave-3 dependencies noted:** the fee-data model fix (audit item 30, discount ledger) is *not* a Wave-3 blocker — §3.3's rules are presentation rules the print layer enforces from existing data, exactly as the screen display-fix did; if/when the ledger lands, the money partial's internals change, its output does not. Exam-family migration depends on exam configuration existing (audit quick win 9) only for *live* verification; sample-data verification suffices for the gate.

---

## 5. Risks & open questions — for the owner (asked by the programme; none block Step 0–2)

**Paper & printers (ask first — profiles depend on the answers):**
1. Does the school office print on **pre-printed stationery** for any document (receipts, certificates, letterhead)? If so, which documents, and can the programme have a sample sheet of each? (Decides background suppression per family.)
2. What printers are actually in daily use — **laser, inkjet, thermal**? Is the Thermal Print add-on used at the fee counter, or installed-but-unused? Which model(s), and what paper (A4/A5/roll widths) is stocked?
3. Are ID cards printed **in-house** (PVC card printer? laser on sheet?) or outsourced to a print shop (in which case the deliverable is a print-ready PDF, and colour/bleed specs come from the shop)?

**Bank challan:**
4. Does the school use a **bank fee challan**? Which bank/branch, and does the bank impose a fixed challan format or stamp requirements? Can the programme have a filled sample? If parents pay only at the school counter today, is a bank challan wanted at all — or is S4 scoped down to a school-issued fee invoice?

**Signatures, seals & authority:**
5. Whose signatures belong on which documents (Principal on certificates/marksheets? Accountant on receipts/payslips?) — and should they be **scanned signatures printed automatically**, or blank lines signed by hand? Is there a school **seal/stamp**, and on which documents must space be reserved for it?

**Data & language on paper:**
6. Should student/father names print in **Urdu as well as English** on receipts/marksheets/ID cards? Are Urdu name spellings stored anywhere today, or would they need capturing? (Live records show many blank fields — DOB, photos, guardian numbers: ID-card and profile printing will expose every blank, so which fields are *mandatory before printing* a card?)
7. **Photos:** most sampled student records have no photo. Is a photo drive / capture plan wanted alongside ID-card migration, or do cards launch photo-less for students without one?

**Practice & policy:**
8. How are **reprints** handled today — who may reprint a receipt, and is a DUPLICATE mark acceptable to parents/bank, or does the office need unmarked reprints (with the audit line kept only in the system log)?
9. Is a paper **attendance register** still maintained by hand in any class (making the `A4-L` register a real replacement), or is the printed register only an occasional report?
10. Payslip practice: are payslips actually handed to staff today (paper, WhatsApp, none)? That decides whether `A5-2UP-PAY` is a real family or a report-only surface.
11. Login-credential slips (S23): are credentials handed over on paper today? Printing passwords is a security smell the programme flags — if the practice continues, the slip design minimises exposure (sealed/covered format) and every print is logged; the owner decides.

**Risks the programme carries (stated, with mitigations):**
- **R1 — The unseen tree is bigger than the seen one.** The web app's print estate (files + DB designs) is unquantified until Step 0; Wave-3 sizing is provisional until `PRINT-INVENTORY.md` lands. *Mitigation: Step 0 is gated and cheap; no family estimate is promised before it.*
- **R2 — DB-stored designs resist bulk migration** (D7). A designer-UI rebuild per design is slow if the school has many certificate/marksheet designs. *Mitigation: count designs in Step 0 (download E); scripted migration with per-design render proofs as fallback.*
- **R3 — Vendor updates overwriting print views.** *Mitigation: override locations + touched-files register (§3.1); re-apply checklist becomes part of the SaaS-phase maintenance runbook.*
- **R4 — Shared-hosting limits on bulk PDF jobs** (full-class marksheets/ID sheets through mPDF). *Mitigation: bulk path defaults to browser print of the same HTML; PDF bulk jobs chunked; tested in the QA matrix on staging's real limits.*
- **R5 — Print exposes data quality.** Blanks and duplicates that screens tolerate become permanent on paper (photos, DOBs, HR records — audit §2.2/§2.9). *Mitigation: per-family "printable record" checks in the preview (warn, don't block) + the audit's data cleanups proceed in parallel waves.*

---

## Appendix — sources

**Local code (read for this plan):** `~/workspace/iqrs-api/production/api/application/` — `controllers/Webservice.php` (certificate methods ≈6538–6770), `controllers/Payment.php` (`successinvoice`), `libraries/M_pdf.php`, `libraries/QR_Code.php`, `models/Coursecertificate_model.php`, `models/Setting_model.php`, full `views/` listing incl. `views/payment/invoice.php`, `views/course_payment/invoice.php`, `views/examresult.php`, `views/studentcourse/downloadcertificatepdf.php`; `backend/` directory listing. `~/workspace/iqrs-webfix/display/orig/` — `studentShow.php` (4,128 lines), `_getBalanceFee.php`, `getcollectfee.php`, + `display/notes.md`. Legacy mirror `~/workspace/iqrs-legacy-source/smart_school_mobile_api_src/` — structure + `backend/` listing (same API application; vendor `third_party/` excluded from template findings).
**Programme documents:** `WEB-APP-AUDIT-AND-DESIGN.md` (§§1–3.4), `DESIGN-DIRECTIONS-SUPPLEMENT.md` (Direction F + closing borrowings), `Smart_School_7.2_Roles_and_Features.md` (§3 permission groups, the 51 reports, §4 add-ons incl. Thermal Print + CBSE), `hidden_files/audit-live-walk.md` (fees-screen photo strip, profile barcode/QR, template-library banner, cash-only fees) — all in `~/workspace/goals/iqrs-school-mobile-app/`.
**Not used:** no browser, no live/staging access, no credentials — per brief.

*— Print Systems workstream, 2026-11-07 —*
