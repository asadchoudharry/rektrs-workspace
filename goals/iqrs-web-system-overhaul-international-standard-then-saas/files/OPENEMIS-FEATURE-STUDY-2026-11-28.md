# OpenEMIS Feature Study — IQRS Special Batch #7

**Date:** 2026-11-28  
**Scope:** Study only. No installation, no code reuse, no copied implementation. OpenEMIS is used here as a reference model for government-reporting readiness in a Pakistani school context.  
**Systems in view:** (a) IQRS Smart School as it is being rebuilt, and (b) the separate Rektrs School ERP + LMS SaaS.

---

## Licence — settled first

**Settled for the GitHub code:** OpenEMIS Core at `OpenEMIS/core` is **GNU General Public License v2.0 (GPL-2.0)**. That is the licence shown by the repository itself: the public repo carries a root `LICENSE` file and GitHub's licence detection reports **GPL-2.0** on the current `master` branch. The README describes the software more generally as provided under the GNU General Public License, is written in PHP/JavaScript, and uses MySQL.

**Conflict to record, not hide:** OpenEMIS programme material outside the GitHub repo is not perfectly consistent. The OpenEMIS Core download page footer says “GNU General Public License v3.0”, and an OpenEMIS open-source licence-agreement PDF found on the OpenEMIS site is a GPLv3 document. A Digital Public Goods candidate note also recorded that the downloaded Core `LICENSE` file said GPLv2, which matches the repo position.

**Practical conclusion:** for this study the repo licence is **GPL-2.0**. If Rektrs ever moved from studying OpenEMIS to reusing OpenEMIS code, the GPL-2.0-vs-GPLv3 conflict in programme materials would need written clarification before any reuse. Nothing in this report depends on reuse; only ideas, field patterns and product judgements are borrowed.

---

## 1. What government reporting does IQRS do today — from our own records

### Found in MEMORY.md and the IQRS goal files

1. **IQRS has a live government identity.** The school is recorded as **IQRA REHMANIA TUL ATFAL BOYS HIGH SCHOOL** legally, publicly **IQRA REHMANIA TUL ATFAL HIGH SCHOOL**, at New Aslam Town, Rahim Yar Khan, Punjab, Pakistan. Its registration line is: **Punjab SED e-License — Registration No. 4521-22 · EMIS Code 313319102 · e-License valid till 31-03-2027**.

2. **PEPRIS is part of the school's real history.** Our application-prep record says the legal file set received in November 2026 included the Punjab SED e-License and a **PEPRIS renewal record** for the same registration number and EMIS code. PEPRIS is Punjab's Private Education Provider Registration & Information System for private-school registration and e-Licensing.

3. **A government-facing PEPRIS submission exists, but its numbers do not match the live school system.** The same record flags: **PEPRIS enrolment = 573 / staff 25**, while the live system at that time showed **1,668 students / 103 teachers**. The note in our file treats the PEPRIS figures as older or partial. That mismatch is exactly the kind of thing an EMIS-readiness check should catch before a renewal or inspection.

4. **BISE Bahawalpur is operationally relevant, but our own record contains a conflict.** The school's public line says it is affiliated with **BISE Bahawalpur**, and the website content pack repeats that line. However, the legal-flags note says the **PEPRIS field “Affiliation with BISE” = No**, while the public line says affiliated — “school to confirm which is correct.” So IQRS should not treat board affiliation as a clean data point until the school confirms the authoritative value.

5. **Government identifiers already leak into school artefacts.** An exam paper/register sheet header in the goal files carries “Reg. No. 4521-22 · EMIS Code: 313319102”. The public website content pack also uses the registration / EMIS / BISE line in the About text and meta description. In other words, the identifiers are used as letterhead facts, not yet as a managed reporting dataset.

6. **Compliance documents are time-bound.** The legal file set flags Building Fitness Certificate 2025 and Sanitary/Safe Water Certificate as valid only till **31-12-2025**, with no 2026 versions in the file set at the time of review. For a private school, those dates matter because PEPRIS registration/renewal asks for building fitness and hygiene material.

### Not found in our records

I did **not** find, in MEMORY.md or the IQRS goal files:

- an annual school census return for IQRS;
- a named Punjab SED / District Education Authority submission log;
- a census “as-of” date, frozen snapshot, submitted dataset, acknowledgement, receipt or correction cycle;
- a named EMIS focal person for the school;
- any evidence that IQRS Smart School can generate an EMIS/PEPRIS/BISE return as an export today;
- any record of a live API or portal integration between the school system and Punjab SED, PEPRIS or BISE.

**Conclusion on today:** IQRS's government reporting, as far as our records prove, is **registration/licensing plus board-facing work handled outside the school MIS**, supported by legal documents and manual figures. The school MIS holds the operational truth (students, staff, classes, exams), but the government-facing copies — especially PEPRIS — can drift from it. That drift is the product opportunity.

---

## 2. OpenEMIS model — what was mined

OpenEMIS began as a UNESCO initiative, implemented with Community Systems Foundation (CSF), and is now presented as a modular, open-source Digital Public Good deployed in **more than 30 countries**. Its own DPI framing is important: it is moving from “an EMIS application” toward **education digital public infrastructure** — authoritative registries for schools, students and staff, shared data services, analytics and reporting, aligned to interoperability thinking such as GovStack.

### 2.1 Suite shape: collect → manage → analyse

The product family is loosely coupled rather than one giant screen set:

- **Collect:** OpenEMIS Core (school/district/national records and the annual census), Admissions, Exams, Classroom (teacher phone workflows), Staffroom (staff phone workflows), Survey (field data collection), Guardian, Scanner (barcode/QR capture).
- **Manage:** OpenEMIS Integrator (ETL into an indicator data warehouse) and DataManager (define/administer warehouse indicator data).
- **Analyse:** Visualizer, Charts, Dashboard and Monitoring (indicator tables/graphs/maps, designed dashboards, baselines and targets for strategic-plan KPIs).

The design lesson is separation: **transactional records are not the same thing as indicators**. Core holds the operational registry; Integrator transforms operational and external data into indicator-shaped data; the analysis tools work on that warehouse layer.

### 2.2 Registries: institution, student, staff

**Institution registry.** The support “Rules — Institutions” material lists the institution form in unusual detail. In my own summary, an institution record carries: name and alternative name; a unique code; classification; sector; provider; type; ownership; gender composition; date opened; status derived from closure; postal address and locality; latitude/longitude for mapping; education area and administrative area; contact person and telephone/fax/email/website; and an “Other Information” area fed by configurable custom fields. Many list values come from **Field Options**, not free text. Deletes are restricted when linked records exist, and changes carry modified-by / modified-on audit fields.

For IQRS, the important pattern is not the long field list itself. It is that the school is treated as a **registry object with stable identity, geography, classification and validity**, separate from this year's enrolment snapshot.

**Student registry.** Students sit inside institutions and academic periods, tied to education grade/class and enrolment status. The surrounding model includes guardians, identities/nationalities, attendance, behaviour, health/special-needs information, assessments and examinations, promotion/repetition/graduation, withdrawal and inter-school transfer. Student Overview reporting can include configured custom fields, which means custom data is not a side spreadsheet — it is part of the registry record.

**Staff registry.** Staff are not merely “users”. A person becomes staff at an institution through a position: position title/grade, staff type, FTE, start/end dates, homeroom/subject assignments, career history, leave, training and qualifications. Position titles can be linked to security roles, so the HR record and the access record meet in one governed place. Staff transfer is a workflow between sending and receiving institutions, not a delete-and-recreate.

**Directory / identity layer.** Underneath students and staff is a user/directory concept with identities. OpenEMIS also supports external identity data sources in some deployments — the support example is UNHCR identities for refugee learners — where an external search is used before creating a person. The transferable idea is duplicate prevention at the point of creation: search first, then create.

### 2.3 Education structure and controlled vocabulary

OpenEMIS is built around an explicit education structure: academic periods, education systems/levels/cycles, grades, subjects and programmes, plus area hierarchies for education and administration. **Field Options** provide the controlled lists behind sectors, types, statuses, position titles and many other values. **National Denominators** appear in the classic administration model because rates such as enrolment ratios need population denominators, not just school numerators.

That structure is what makes roll-up possible. A count is never just “students”; it is students **in a period, at a level/grade, in an area, in an institution type**, disaggregated by sex and age where the indicator requires it.

### 2.4 Indicator framework — which indicators, how computed

The UNESCO/OpenEMIS indicator guidelines use the standard international EMIS indicator families. The ones relevant to a school/SaaS readiness model are:

- **Access and intake:** gross intake ratio, net intake rate, gross enrolment ratio, net enrolment rate, age-specific enrolment rate.
- **Internal efficiency / flow:** repetition rate by grade, percentage of repeaters, promotion and survival behaviour, transition rate to the next level, dropout proxies built from enrolment/attendance/behaviour signals.
- **Equity:** gender parity indices for the access/flow indicators, percentage of female students by level, percentage of female teachers.
- **Resources and teachers:** pupil–teacher ratio, percentage of trained teachers, distribution of teachers by qualification/age/experience in ministry reporting.
- **Finance at system level:** public expenditure on education as a share of national income/government expenditure and public expenditure per pupil. These are ministry-finance indicators, not something a single private school should pretend to compute.
- **Learning:** national assessment / examination outcomes when an exams or assessment system is connected; OpenEMIS Exams is a separate product in the suite, and Core can synchronise institution/student/academic data to it.

**How they are computed in the OpenEMIS pattern:** operational facts in Core (enrolment by grade/age/sex, repeaters, staff by qualification/sex, institutions by type/area) are extracted by Integrator, transformed into standard indicator definitions, and loaded into a warehouse managed through DataManager. Dashboards then monitor indicators against baselines and targets. In plain terms: **numerator and denominator are both governed**, the definition is stored once, and every chart is a view over the same definition — not a hand-made spreadsheet formula.

A school system cannot honestly compute GER/NER for a country because it does not hold the population denominator. It *can* hold the school-side numerators cleanly and expose them in the exact disaggregation an authority asks for.

### 2.5 Custom fields and custom reports

The old Core user guide summarises the promise plainly: administrators can create **custom fields, indicators and reports** to respond to local reporting requirements. The current support material shows how that works in practice:

- **Custom Fields** are configured per area of the system — for example institution “Other Information”, infrastructure land/building/floor/room records, and categories of users. Infrastructure overview types themselves (ownership, condition, land/building/floor/room types) are set up through Field Options and Custom Field screens.
- **Mandatory / non-mandatory behaviour is configurable** for key record types. System-configuration articles describe administrators choosing which fields are mandatory when adding guardians, staff, students and other contacts, and defining validation expectations around those forms.
- **Custom reports exist at national and institution level.** The support article describes specialised reports built for specific needs, with filters such as academic period, area, institution, institution type, education grade, education subject, staff status, assessments, education programmes/cycles and infrastructure room types. It also shows that custom reports can be SQL-backed definitions. That is powerful for a ministry implementation team and dangerous as a casual school-user feature — see the verdict below.
- **Standard institution statistics already cover much operational reporting:** marks entered / not entered by staff, staff career, staff/student special needs, staff training, student absences, attendance summary with attendance rate, student health, and student overview including configured custom fields.

The architecture lesson: customisation is **metadata around stable core entities**, not a fork of the product for every country. The ministry changes lists, fields, forms, workflows and reports; the registry model stays recognisable across 30+ deployments.

### 2.6 API-first surface and integration patterns

OpenEMIS's DPI material explicitly calls the platform **API-first**, enabling secure exchange across the education lifecycle and integration with national digital infrastructure. The support knowledge base shows the concrete patterns:

- **Server-to-server credentials** are configured in Administration (APIs → Credentials).
- Access uses a **JWT bearer flow**: a signed RS256 JWT is exchanged at `/oauth/token` for an access token, with scope used to restrict what the token may call.
- **External data sources** can be configured for identity lookup, so a person can be found in an external system while adding students or staff.
- **Product-to-product sync** is normal in the suite: Core connects to OpenEMIS Exams by configuring API credentials and an external data source, then synchronising institution/student/academic data at national or institution level according to permission.
- **LMS integration** is treated as an API concern: Moodle API credentials are configured in Core, user creation events are logged, and students/staff/guardians added in Core can create corresponding Moodle users.

I did not find a single public “endpoint count” that would be honest to quote, and I am not inventing one. The scale is better described by surface area: registry CRUD and actions for institutions, students, staff, guardians and users; attendance, assessment and examination data; imports and exports; report generation; workflow actions; configuration/field-option administration; and sync endpoints between suite products. This is a **national integration surface**, not a small school API with a few extra routes.

### 2.7 Data quality and validation

OpenEMIS treats data quality as a process, not a hope:

- **Completeness is surfaced.** “Institution Data Completeness” is a configurable feature that shows completeness-related information on the institution dashboard, so a school can see that its record is thin before a ministry has to reject it.
- **Field rules are explicit.** Institution rules document mandatory fields, which values come from Field Options, when latitude/longitude become relevant, how status follows dates, and which linked records block deletion.
- **Auditability is built in.** Institution edits record who changed the record and when; deleted institution information is preserved in a deleted-records concept rather than vanishing silently.
- **Creation is guarded against duplicates.** Staff/student creation flows search the directory/identity first; external identity sources extend that idea.
- **Period discipline exists.** The End of Academic Period process sequences the unglamorous work: configure the new period, copy data with Data Management, set up attendance, create classes, transfer staff, assign teachers, promote/graduate/repeat students, and transfer students through approval workflows.
- **Workflow status is a quality gate.** Survey forms, admissions, transfers, withdrawals, leave and cases move through steps with assignees, actions, comments and statuses, visible on a workbench. A record can be visibly “not done yet”, which is the minimum requirement for honest census management.

### 2.8 Census collection workflow: school → area → ministry

OpenEMIS can be used in two modes. The traditional mode **digitises the annual school census**. The modern mode keeps live student/staff records at school level and lets regional/national authorities work with timely data. In both modes the roll-up logic is similar:

1. The **institution** maintains its registry record and either fills census/survey forms or keeps transactional records current.
2. **Survey forms** can be routed by workflow — the workflow rules material gives the telling example that Institution Survey forms can be received by the **Census Department in the Ministry of Education**.
3. The **area hierarchy** (education area and administrative area) provides the aggregation spine: school → district/area → national.
4. **Workbench/workflow** states let each level see what is open, in progress or done; assignees can be roles rather than named individuals.
5. Once accepted, data is transformed by Integrator into the **indicator warehouse**; DataManager, Visualizer, Charts, Dashboard and Monitoring publish the analytical layer.

For field collection, **OpenEMIS Survey** is explicitly offline-capable: survey templates are downloaded from a server, completed on phone/tablet without an internet connection, saved as drafts, and uploaded when connectivity returns. Classroom, Staffroom, Guardian and Scanner extend the same low-friction idea to daily school data and QR/barcode capture.

### 2.9 How 30+ country deployments shaped it

The country pattern explains the architecture. CSF's 2025 highlights alone mention Guyana producing official report cards nationally, Tonga rolling out across all public schools, Namibia strengthening exams with verification and case management, Belize receiving targeted Core upgrades, Jamaica advancing a national rollout with training, the Bahamas combining Exams with Core and an LMS, and Seychelles joining with training ahead of rollout. Emergency/refugee adaptations added external identity handling and “out of school / at risk” criteria built from absence, guardianship and special-needs signals.

So the product was shaped by ministries that needed: local configuration without a rebuild; training and implementation partners, not just software; exams and report cards as national artefacts; offline or low-connectivity collection; multilingual, mobile-responsive access; and data ownership by the education authority. Those are exactly the pressures a Pakistani private-school SaaS will feel in miniature — except the SaaS serves schools, not the ministry.

---

## 3. Answers to the three questions

### Q1. What should a Pakistani school system hold READY so census/EMIS returns become exports?

The right mental model is three different government surfaces. They overlap, but they are not the same return.

#### A. Punjab SED / PEPRIS readiness — the private-school licence surface

Hold these as governed, export-ready data:

- **School legal identity:** legal name, display name, Registration No., **EMIS Code**, e-License issue/expiry dates, registration authority, district and tehsil.
- **Basic profile (PEPRIS shape):** district, tehsil, school name, nature of school, nature of management, school level, school gender, year established, building status, postal address and city, geotagged latitude/longitude.
- **People accountable to the regulator:** owner name/CNIC reference, principal/administrator name, designation, phone and email; contact person details. CNIC numbers should be stored as protected identity data with document references, never casually printed on general reports.
- **Compliance documents with validity dates:** building fitness certificate, hygiene/safe-water certificate, previous e-License, affiliation/registration certificates. The system should warn before expiry, not discover expiry during renewal.
- **School stats snapshot:** enrolment, teaching staff and non-teaching staff counts **as of a stated date**, with the ability to freeze and reproduce the exact snapshot later.
- **Application trail:** challan/PSID references, submission status, district review status and issued licence artefact — as references and attachments, not as a promise that the school system itself files the application.

For IQRS specifically, the first export to build is a **PEPRIS reconciliation pack**: current system counts vs the last PEPRIS figures, the registration/EMIS identity block, certificate validity dates, and a discrepancy list. The known 573/25 vs 1,668/103 mismatch should be impossible to miss.

#### B. BISE readiness — the board surface

Hold ready, by academic session and class:

- Institution affiliation status **as confirmed by the school** (and, until confirmed, visibly flagged where sources disagree — IQRS has exactly this problem in its own file).
- Candidate registration data for board classes (in IQRS's case, the SSC rhythm matters most): student identity as on the B-Form / identity record, father's/guardian name as used for board purposes, date of birth, gender, class/section, subject group and subjects, previous academic record reference, photograph/document readiness, and fee/challan status.
- Registration-return status per class: entered, verified, submitted, corrected — with hard-copy verification tracked as a step, because board processes still mix online entry with physical verification.
- Result-side readiness: board roll numbers mapped back to the school's student IDs so results, rechecking and certificates reconcile to the same learner record.

This is not “EMIS” in the ministry-statistics sense; it is examination-board compliance. A good school system keeps it separate from the SED pack so neither is muddled.

#### C. EMIS / census indicator readiness — the statistics surface

Hold the **school-side numerators** in indicator-ready disaggregation:

- Enrolment by academic period, level, grade, section, gender and age; new entrants; repeaters; promoted / transferred-in / transferred-out / withdrawn / graduated counts.
- Attendance aggregates by period and grade (present/absent days and attendance rate), because ministries increasingly ask beyond a single census-day headcount.
- Staff by teaching/non-teaching, gender, qualification, training status, subject and class assignment — enough to compute pupil–teacher ratio by level and trained-teacher percentage without a manual recount.
- Infrastructure basics in structured form: classrooms/rooms and their condition, toilets, drinking water, electricity, boundary/facilities where a census asks — the OpenEMIS land/building/floor/room model is more detailed than a school needs, but the principle (structured, countable, not a paragraph) is right.
- Special-needs / disability flags and health basics where a census or safeguarding return requires them, with privacy classification.
- A **census-date freeze**: the ability to say “these are the figures as of 30 September” (or whatever date an authority names) and reproduce them after later edits.

**For (a) IQRS Smart School:** build readiness, not a ministry. Concretely: an EMIS/PEPRIS identity block in Settings; certificate validity tracking; a one-click PEPRIS reconciliation + profile export (PDF/CSV); a BISE registration-return pack for board classes; enrolment/staff snapshot freezes; and discrepancy warnings. That converts today's manual exercise into “review the pack, fix the red lines, submit”.

**For (b) Rektrs School ERP:** “EMIS-ready” is **real, if worded precisely**. A Pakistani private school does have recurring government pain: PEPRIS registration/renewal, district scrutiny, board registration returns, and ad-hoc data demands. A SaaS that holds the identity block, freezes snapshots, validates completeness and exports in the authority's shape saves real office days every year. It is **not** real if the phrase implies live integration with Punjab SED/PEPRIS/BISE or automatic filing — I found no public API or integration route for those authorities in this study, and our own records show manual/portal processes. The honest feature name is **“EMIS-ready exports for Pakistan (Punjab first)”**, with a roadmap note for other provinces/boards.

### Q2. Is OpenEMIS's custom-fields architecture worth borrowing?

**Yes — borrow the pattern, with guardrails.** It is directly relevant to IQRS's FC-15 settings-depth territory and to ERP settings design.

Worth borrowing:

1. **Field Options as governed vocabulary.** Lists (sectors, types, statuses, religions, position titles) are data, versioned and selectable — never free text where a list exists. This matches Rektrs' existing selection-over-typing rule.
2. **Custom fields as metadata on stable entities.** A field definition carries: entity/form it attaches to, label, type, option list where relevant, mandatory flag, order/visibility, and whether it appears in lists, reports and exports. The value is stored against the record; the definition is configuration.
3. **Mandatory-by-context configuration.** Administrators can make a field mandatory for one record type without a code change. Combined with a completeness view, this turns “please fill everything” into a measurable state.
4. **Custom fields flow into reporting.** OpenEMIS includes configured student custom fields in Student Overview reporting. A custom field that cannot be exported is a dead field; a custom field that cannot be reported is decoration.
5. **Export mapping.** For the ERP, extend the pattern one step further than a single school needs: each custom or core field can be mapped to an authority label (PEPRIS profile, BISE return, future province packs), with the mapping versioned by academic year.

Guardrails — where not to copy OpenEMIS literally:

- **Do not give school users SQL-backed custom reports.** OpenEMIS's custom-report power suits ministry implementation teams. In a school SaaS it is a security, performance and support hazard. Offer a safe report builder over whitelisted fields and pre-computed snapshots instead.
- **Custom fields must not become shadow core data.** Fees, exam marks, attendance facts and enrolment status belong in governed core tables with money/record integrity. Custom fields are for local extras — a district reference number, a transport code, a local category — not for re-inventing the core.
- **Every custom field needs a privacy class and retention rule**, so FC-14-style anonymisation/erasure knows what to do with it. OpenEMIS deployments are state systems; a commercial SaaS carries tenant-privacy duties the ministry model does not solve for us.
- **Definitions need ownership and change history.** Who added the field, why, when it became mandatory, and which exports use it. Without that, tenant settings rot into the same drift PEPRIS shows today.

For IQRS FC-15, the borrow is modest and immediate: keep deepening field-option registries and mandatory/completeness behaviour inside Settings. For the ERP, make custom fields a first-class tenant capability from the start — retrofitting metadata-driven fields onto a live multi-tenant schema is far more painful.

### Q3. What is ministry-scale and should NOT be chased?

Do **not** chase:

- **A national learner identity across all schools.** Unless the state issues and governs it, a SaaS must not pretend to be the identity authority. Keep tenant-local IDs plus government references (EMIS code, board roll numbers) as attributes.
- **Population denominators and official GER/NER.** A school or SaaS does not hold census population data. Publish school-side rates that are honestly computable (attendance rate, PTR inside the school, repetition within the school) and label the rest as authority-computed.
- **A national data warehouse / OLAP programme.** The Integrator/DataManager layer makes sense for a ministry. For the ERP, a tenant snapshot + export history is enough; a school-chain roll-up can come later for multi-campus customers.
- **Cross-school state workflows between unrelated schools.** OpenEMIS transfers work because one authority governs both ends. In a SaaS, transfer support should mean clean leaving/arrival documents for the student, not a live approval chain into a school that may not even be a customer.
- **Being the examination authority.** Board registration packs, yes. National exam administration, verification case management and certificate authority functions, no — those belong to BISE and ministries.
- **Civil-registry / refugee / donor integrations** and strategic-plan monitoring for government. These are state-programme features, not school-office features.
- **Real-time national aggregation.** Even OpenEMIS's modern mode depends on every school keeping records current inside one governed system. A SaaS cannot promise a district picture from partial adoption; it can promise each school a clean, dated, reproducible return.

---

## 4. Verdict

### Borrow-list for IQRS Smart School (single school, now)

1. **Government identity block in Settings:** Registration No., EMIS Code, e-License dates, board affiliation status (with a conflict flag until the school confirms the BISE value), district/tehsil, geolocation.
2. **Certificate validity tracker:** building fitness, hygiene/safe-water, e-License and affiliation documents with expiry warnings.
3. **PEPRIS reconciliation pack:** system vs last-submitted figures, profile export in PEPRIS shape, discrepancy list — built specifically to kill the known enrolment/staff drift.
4. **Census-date snapshot freeze** for enrolment and staff, reproducible after later edits.
5. **BISE registration-return pack** for board classes, with entered/verified/submitted/corrected status per class.
6. **Completeness warnings** on the records that feed those packs (the OpenEMIS data-completeness idea, school-sized).
7. **Field-option discipline** for every government-facing list value — no free-text sector/type/status where an authority expects a category.

### Borrow-list for Rektrs School ERP + LMS (SaaS)

1. **Tenant government profile:** country/province/board, EMIS or equivalent code, registration numbers, licence validity, authority contacts — as tenant configuration, not hard-coded Punjab assumptions.
2. **Authority export packs, Punjab first:** PEPRIS profile/reconciliation, BISE registration return, generic census snapshot (CSV/PDF) — versioned by academic year and authority.
3. **Metadata-driven custom fields + field options** with mandatory rules, completeness scoring, report/export inclusion and authority-label mapping (with the guardrails in Q2).
4. **Snapshot + submission log:** every export frozen, dated, reproducible, with who generated it, who submitted it, where, and what came back.
5. **Validation before export:** duplicate-person search prompts, missing mandatory government fields, expired certificates, count mismatches — presented as a pre-flight checklist.
6. **Offline-tolerant collection for census week:** the OpenEMIS Survey lesson — forms and snapshots should remain usable when connectivity is poor, with upload/sync when it returns. (IQRS already has offline thinking in its apps; the ERP should inherit the principle.)
7. **School-chain roll-up only:** for a customer that owns several campuses, aggregate the same packs across its own schools. Nothing wider.

### “EMIS-ready” — does it belong on the ERP feature list?

**Yes — as a named, bounded feature: “EMIS-ready for Pakistan schools (Punjab PEPRIS + BISE exports first)”.** It is a genuine selling point because the pain is real, recurring and measurable: registration/renewal data, board returns and census-style demands currently live in documents and memory while the MIS holds different numbers. The feature is credible only if the marketing keeps the boundary: **ready data, validated packs, frozen snapshots, guided filing** — not “integrated with the government” and not “automatic submission”, neither of which this study found a route for.

For IQRS itself, do not sell or build a ministry. Build the packs, fix the drift, and let the school office feel the difference at the next PEPRIS/BISE cycle. That single-school proof is also the ERP feature's best evidence.

---

## Sources consulted

- OpenEMIS Core repository (licence, README, stack, repo structure): https://github.com/OpenEMIS/core
- OpenEMIS Core download page (programme licence footer): https://www.openemis.org/download-openemis-core/
- OpenEMIS open-source licence agreement (GPLv3 programme document): https://www.openemis.org/wp-content/uploads/2019/09/OpenEMIS_GPLv3_en.pdf
- OpenEMIS products suite: https://www.openemis.org/products
- OpenEMIS as Education Digital Public Infrastructure (API-first, registries, 30+ countries): https://www.openemis.org/solutions/dpi
- OpenEMIS Integrator (ETL to indicator warehouse): https://www.openemis.org/products/integrator
- Education Indicators — Technical Guidelines (UNESCO/OpenEMIS indicator definitions): https://www.openemis.org/wp-content/uploads/2018/04/Indicator_Technical_guidelines_en.pdf
- OpenEMIS Core support — Custom Reports: https://support.openemis.org/core/en/custom-reports/?print=pdf
- OpenEMIS Core support — Rules: Institutions (institution fields, custom fields, field options): https://support.openemis.org/core/en/rules-institutions/
- OpenEMIS Core support — Configure External System (API credentials, JWT access-token flow): https://support.openemis.org/core/en/configure-external-system/
- OpenEMIS Core support — Rules: Workflow (workflow triggers, survey forms to ministry Census Department): https://support.openemis.org/core/en/rules-workflow/
- OpenEMIS Core support — System Configuration / Institution Data Completeness material: https://support.openemis.org/core/en/category/administration/system-configuration/?print=pdf-search
- OpenEMIS Survey datasheet (offline survey capture): https://www.openemis.org/wp-content/uploads/2018/04/OpenEMIS_Survey_Datasheet_en.pdf
- Community Systems Foundation — OpenEMIS Country Highlights 2025: https://www.communitysystemsfoundation.org/blog/openemis-country-highlights-2025
- PEPRIS official portal, School Education Department, Government of Punjab: https://pepris.pesrp.edu.pk/
- PITB — Private Education Provider Registration and Information System (PEPRIS): https://pitb.gov.pk/node/6232
- Local records: `MEMORY.md`; IQRS goal files `GOOGLE-WORKSPACE-APPLICATION-PREP-2026-11-17.md` and `WEBSITE-CONTENT-FIX-2026-11-17.md` (registration / EMIS / PEPRIS / BISE facts and the flagged mismatches).
