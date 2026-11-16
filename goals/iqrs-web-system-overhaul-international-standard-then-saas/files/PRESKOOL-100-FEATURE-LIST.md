# PreSkool Feature List v5 — 236 features (FP-001–FP-241, adopted set)

**v5 — 2026-11-12, Round 3 School Board (D-036/D-037).** v4 ke 212 features barkarar; **24 naye features (FP-213–FP-241 mein se adopted)** Round 3 board se aye — is dafa team ne LIVE demo nahi, **hamara implemented staging system** walk kiya: 8 technical lanes, 27 personas (180 findings), 10 panels (61 crux), aur 20-seat board (8 school + 12 technical) ne **24 faislay (BD-077–BD-100)** + Security Red Lines SRL-1…SRL-8 diye, CEO ne D-037 mein ratify kiye. Adopted: FP-213–FP-233 (21) + FP-237/FP-240/FP-241 component work ke tor par (3). Noted, not adopted: FP-235 (E-Signature), FP-236 (External Calendar Sync), FP-238 (Contact-Attempt Log — FP-221/FP-180 mein fold hoga), FP-239 (Certificate Legacy-Serial Digest). Deferred to Phase S: FP-234 (Staff SSO via Keycloak). Board report: `discovery/round3/board/BOARD-REPORT-R3.md`.

**v4 — 2026-11-12, Round 2 School Board (D-033/D-034).** v3 ke 180 features barkarar; **32 naye features (FP-181–FP-212)** Round 2 board se aye — 27 personas ne decided system ko dobara walk karke **662 findings** (57 Critical, 294 High) nikale, 7 seats ne position papers diye, aur Chair ne **76 board decisions (BD-001–BD-076)** sunaye, jinhein CEO ne D-034 mein ratify kiya. Board report: `discovery/live-audit/round2/board/BOARD-REPORT.md`. FP-183 (Vaccination Register) audit synthesis mein gir gaya tha — board ne wapas shamil kiya; FP-208 (Push Substrate) aur FP-212 (Step-Up Service) Category A infrastructure hain.

**v3 — 2026-11-12, live-demo audit synthesis (D-028/D-029/D-030).** v2 ke 161 features barkarar; **19 naye features (FP-162–FP-180)** us audit se aye jo LIVE demo ko page-by-page, 27 roles ki nazar se, aur 10 real scenarios ki discussion ke baad kiya gaya — 2,408 element-level deltas. Element register ab **930 rows** hai: 104 ghalat entries theek hui, 46 ghayab elements shamil hue, 683 rows live-verify band. 9 purani rows ki buniyad bhi durust hui (neeche §v3 corrections). v2 ne v1 ko jis tarah rakha tha, v3 bhi v2 ko waisa hi rakhta hai — kuch remove nahi hua.

**v2 — 2026-11-11, element-level deep audit (D-025/D-026).** Ye list v1 (100-feature, page-level) ko supersede karti hai. Owner ke kehne par parity ab page-level nahi, **element-level** hai: theme ke 884 chhote-bare elements (har dashboard widget, har form group, har panel) ek ek karke hamare live IQRS system se check hue — element register aur FP-101+ addendum deep-audit folder mein hain. FP-001–FP-100 ka content v1 jaisa hi hai; FP-101–FP-161 wo features hain jo sirf element level par nazar aye.

Source: feature parity matrix (FP-001–FP-100) + deep-audit addendum (FP-101–FP-161) + live-audit addendum v3 (FP-162–FP-180) + Round 2 board report (FP-181–FP-212) + Round 3 board report (FP-213–FP-241). Har feature ka ek disposition tay hai: **PRESERVE** (waisa hi rakho, sirf arrangement) · **REDESIGN** (PreSkool pattern par dobara, rules hamare) · **CONSOLIDATE** (duplicates ek karo) · **IMPLEMENT** (naya build) · **INTEGRATE** (asal service/provider se joro) · **DOCUMENTED BLOCKER** (is phase mein nahi — wajah record hai).

Ginti: **236 features** — v4 tak A 57 · B 138 · C 12 · D 5 (Dispositions: PRESERVE 18 · REDESIGN 34 · CONSOLIDATE 10 · IMPLEMENT 132 · INTEGRATE 11 · DOCUMENTED BLOCKER 7); v5 additions (24) category-unclassified hain — har FP apne home lane ke saath classify hoga, disposition IMPLEMENT (component work FP-237/FP-240/FP-241 apne home ke andar).

## A — Dono mein hai (theme + hamara system)

In features ki buniyad hamare system mein pehle se hai; PreSkool ki arrangement/presentation in par ayegi, hamare rules aur data barkarar.

- **FP-002** — Application shell: sidebar, header, breadcrumbs · _REDESIGN_
- **FP-003** — Authentication: staff door, portal door, forgot password · _PRESERVE_
- **FP-005** — Global search across students, staff and features · _IMPLEMENT_
- **FP-007** — Calendar, to-do list and personal notes · _REDESIGN_
- **FP-008** — Internal chat · _REDESIGN_
- **FP-009** — Media manager and file handling · _REDESIGN_
- **FP-010** — Student records: CRUD, lists, profile, timeline · _REDESIGN_
- **FP-011** — Student categories, houses and disable lifecycle · _PRESERVE_
- **FP-012** — Guardian and parent accounts (vendor model) · _REDESIGN_
- **FP-014** — Admissions: enquiry, follow-up and conversion · _INTEGRATE_
- **FP-015** — Admission form (household-first) and online admission · _INTEGRATE_
- **FP-016** — Student promotion and session rollover · _PRESERVE_
- **FP-017** — Download centre and student documents (portal) · _REDESIGN_
- **FP-018** — Alumni management and events · _REDESIGN_
- **FP-022** — Classes, sections, subjects and subject groups · _REDESIGN_
- **FP-023** — Timetable: class and teacher schedules · _REDESIGN_
- **FP-024** — Lesson plan and syllabus status · _REDESIGN_
- **FP-025** — Homework and daily assignment · _REDESIGN_
- **FP-026** — Student attendance: daily, period, by date · _REDESIGN_
- **FP-027** — QR code attendance (add-on) · _INTEGRATE_
- **FP-028** — Biometric attendance · _INTEGRATE_
- **FP-029** — Leave: student leave approval and staff leave workflow · _REDESIGN_
- **FP-030** — Staff attendance · _REDESIGN_
- **FP-031** — Examinations: groups, exams, schedule, marks, grades · _REDESIGN_
- **FP-032** — Exam documents: marksheets, admit cards, rank · _CONSOLIDATE_
- **FP-035** — Ranking and performance analytics · _REDESIGN_
- **FP-036** — Fee structure: groups, types, masters, session groups · _PRESERVE_
- **FP-040** — Discounts and the FL-031 discount ledger · _PRESERVE_
- **FP-041** — Arrears, opening balances and carry forward · _PRESERVE_
- **FP-042** — Fines and late fees · _PRESERVE_
- **FP-043** — Fee invoices, vouchers and receipts (documents) · _CONSOLIDATE_
- **FP-044** — Refunds, reversals and adjustments · _INTEGRATE_
- **FP-045** — Online payments and offline bank payment verification · _INTEGRATE_
- **FP-046** — Income and expense recording (non-fee finance) · _REDESIGN_
- **FP-047** — Fee and finance reporting pack · _REDESIGN_
- **FP-048** — Staff records and HR administration · _REDESIGN_
- **FP-049** — Departments and designations · _PRESERVE_
- **FP-050** — Payroll and payslips · _REDESIGN_ · _(v3 correction: run lifecycle/approval gate payroll page par hai hi nahi — woh employee-payroll ki cheez hai; salary-structure sirf aggregates edit karta hai, component/formula editor nahi)_
- **FP-051** — Teacher ratings and performance · _REDESIGN_
- **FP-052** — Library: books, members, issue/return · _REDESIGN_
- **FP-053** — Inventory, stock and asset management · _REDESIGN_
- **FP-054** — Transport: routes, vehicles, pickup points, transport fees · _REDESIGN_
- **FP-055** — Hostel: rooms, room types, allocation · _REDESIGN_
- **FP-056** — Communicate: email/SMS engine, templates and logs · _REDESIGN_
- **FP-057** — Front office operations: visitors, calls, postal, complaints · _REDESIGN_
- **FP-058** — Reports centre (51 reports) · _REDESIGN_
- **FP-059** — Print and Document platform (Print Studio + unified PDF exits) · _CONSOLIDATE_
- **FP-060** — Certificates and student/staff ID cards · _CONSOLIDATE_
- **FP-061** — System settings and configuration · _REDESIGN_
- **FP-062** — Roles and permissions administration · _PRESERVE_
- **FP-063** — Backup, restore and recovery · _REDESIGN_
- **FP-064** — Audit trail, user log and activity history · _REDESIGN_
- **FP-065** — Front CMS and public website · _REDESIGN_
- **FP-070** — Two-factor authentication (add-on) · _INTEGRATE_
- **FP-099** — Error and utility pages (404, 500, blank, coming soon) · _REDESIGN_

## B — Sirf theme mein hai (hamare system mein nahi)

Ye nayi capabilities hain; apni wave mein hamare data model par build hongi.

- **FP-001** — Design tokens and shared component layer · _IMPLEMENT_
- **FP-071** — AI command centre (theme AI suite — per-page treatments: FP-071 and FP-088 to FP-097) · _IMPLEMENT_ · _(D-032: ye LLM/RAG wali AI NAHI hai — database par chalnay walay deterministic workflows hain: published rules/formulas, findings saboot ke saath, action se pehle named human approval, poora audit. Product mein "AI" label bhi nahi aye ga — feature apne kaam ke naam se ayega)_
- **FP-072** — SaaS platform: multi-branch and franchise administration · _DOCUMENTED BLOCKER_ ⛔
- **FP-073** — Cafeteria: menu, orders, billing and meal plans · _IMPLEMENT_
- **FP-074** — GPS live transport tracking · _IMPLEMENT_ · _(v3: do hisson mein — device/feed wala hissa asal provider ke baghair NO-BASE; bina-device wala hissa FP-180 mein build hoga)_
- **FP-075** — Student wallet (stored value) · _DOCUMENTED BLOCKER_ ⛔
- **FP-076** — Student health records: medical visits, sick room, health alerts · _IMPLEMENT_ · _(v3: Medical Referrals (REF-####) aur Follow-Up Plans bhi shamil — live audit mein pehli dafa record hue)_
- **FP-077** — Gate security: gate pass, exit pass, visitor verification · _IMPLEMENT_
- **FP-078** — WhatsApp messaging channel · _INTEGRATE_
- **FP-079** — Support tickets / helpdesk · _IMPLEMENT_
- **FP-080** — API keys, webhooks and connected apps (integration management) · _INTEGRATE_
- **FP-081** — Privacy and GDPR-style surfaces: notices, cookies, account deletion · _IMPLEMENT_
- **FP-082** — Server operations surfaces: IP banning, cache, storage, maintenance mode · _DOCUMENTED BLOCKER_ ⛔
- **FP-083** — Sports, competitions, activities and student awards programme · _IMPLEMENT_
- **FP-084** — Custom report builder · _IMPLEMENT_
- **FP-085** — Appointment requests (parent-teacher meetings) · _IMPLEMENT_
- **FP-086** — SaaS platform: tenant settings, subscription plans and usage limits · _DOCUMENTED BLOCKER_ ⛔
- **FP-087** — SaaS platform: membership plans, add-ons and transactions · _DOCUMENTED BLOCKER_ ⛔
- **FP-088** — AI student intelligence · _IMPLEMENT_
- **FP-089** — AI attendance predictor · _IMPLEMENT_
- **FP-090** — AI fee forecast · _IMPLEMENT_
- **FP-091** — AI homework evaluation · _IMPLEMENT_
- **FP-092** — AI parent insights · _IMPLEMENT_
- **FP-093** — AI report generator · _IMPLEMENT_
- **FP-094** — AI risk detection · _IMPLEMENT_
- **FP-095** — AI student assistant · _IMPLEMENT_
- **FP-096** — AI teacher productivity · _IMPLEMENT_
- **FP-097** — AI timetable optimizer · _IMPLEMENT_
- **FP-098** — Tax registers and tax reports · _IMPLEMENT_
- **FP-100** — Workflow rules and trigger actions (automation) · _IMPLEMENT_

### Deep audit ka izafa — element-level features (FP-101–FP-161)

Page-level list mein ye cheezen chhup jati theen — dashboard ke "Top Teacher" jaisay widget ke peeche poora rating system hota hai. 884 elements ke audit se ye 61 features nikle; sab Category B hain (theme mein hai, hamare system mein nahi / bohat kam hai). FP-101 audit se nahi, owner decision D-016 se reserved hai.

- **FP-101** — Geo-fenced staff attendance (location + radius, offline re-validation) · _IMPLEMENT_
- **FP-102** — Teacher appraisal & improvement plans · _IMPLEMENT_
- **FP-103** — Student risk scoring & intervention plans (deterministic, published formula) · _IMPLEMENT_ · _(v3: student-performance Improvement Plan lifecycle (IMP- refs, report card plan-review tak held) aur Withheld state bhi isi mein)_
- **FP-104** — Engagement measurement (parent + student engagement scoring) · _IMPLEMENT_
- **FP-105** — SLA parent-message inbox & reply metrics · _IMPLEMENT_
- **FP-106** — Channel delivery analytics (SMS/email/WhatsApp delivery rates) · _IMPLEMENT_
- **FP-107** — Unified activity stream (har module ke events ek timeline) · _IMPLEMENT_
- **FP-108** — Gamification & achievements registry (badges, awards record) · _IMPLEMENT_
- **FP-109** — Goals & targets · _IMPLEMENT_
- **FP-110** — Fuel ledger · _IMPLEMENT_
- **FP-111** — Fleet operations: telematics, maintenance & vehicle health · _IMPLEMENT_
- **FP-112** — Transport assignment lifecycle (seats, effective-dated reasoned changes) · _IMPLEMENT_
- **FP-113** — Certificate lifecycle (request → approval → generation queue → QR public verification → collection → reissue-supersede) · _IMPLEMENT_
- **FP-114** — TC department clearance run — **paanch** departments (Class Teacher/Accounts/Library/Lab/Transport), faisla teen-tarfa Approve/Hold/Reject · _IMPLEMENT_ · _(v3 correction: pehle chaar departments aur do-tarfa faisla likha tha — dono ghalat)_
- **FP-115** — Staff time attendance (check-in/out, hours, overtime, method) · _IMPLEMENT_ · _(v3: demo ka attendance-rules engine is ki policy surface hai — late→deduction chain owner decision OD-1 par munhasir, auto-deduction nahi)_
- **FP-116** — Student attendance time & threshold layer · _IMPLEMENT_
- **FP-117** — Versioned leave-policy engine (entitlements, Forwarded chains) · _IMPLEMENT_
- **FP-118** — Double-entry accounting: GL, chart of accounts, journal vouchers, cost centres · _DOCUMENTED BLOCKER_ ⛔
- **FP-119** — Bank reconciliation & auto-match · _IMPLEMENT_
- **FP-120** — Category budgeting (budget vs spent) · _IMPLEMENT_
- **FP-121** — Unified transaction register (cross-stream, reversal links) · _IMPLEMENT_
- **FP-122** — Trade invoicing (non-fee, line tax) · _IMPLEMENT_
- **FP-123** — Scholarship award lifecycle · _IMPLEMENT_
- **FP-124** — Configuration governance (year-scoped draft → publish, unpublished-changes count, second approver) · _IMPLEMENT_
- **FP-125** — Custom-fields schema platform (27 field types, live preview, field-level ACLs) · _IMPLEMENT_
- **FP-126** — Mail & SMS operations consoles (SMTP handshake terminal, safety rails, DLR timeline, recipient policy) · _IMPLEMENT_
- **FP-127** — Security posture & trusted devices · _IMPLEMENT_
- **FP-128** — Translation operations (coverage, missing-key log, translator approvals) · _IMPLEMENT_
- **FP-129** — Per-user preference store · _IMPLEMENT_
- **FP-130** — Document vault (categories, verification, versioning, sharing ACL, bulk upload) · _IMPLEMENT_
- **FP-131** — Library depth (copy-level inventory, loan rules, reservations, membership lifecycle) · _IMPLEMENT_
- **FP-132** — Curriculum content tree & coverage roll-up (Units → Chapters → Lessons → Topics) · _IMPLEMENT_
- **FP-133** — Timetable instances, substitutes & teacher workload (deterministic conflict detection) · _IMPLEMENT_ · _(v3: demo ke timetable-optimizer ka asal deterministic constraint catalogue bhi isi mein — "AI" label hata kar)_
- **FP-134** — Admissions pipeline depth (waitlist, interview panels, document verification, counsellor) · _IMPLEMENT_
- **FP-135** — Promotion decision workflow & approved batches · _IMPLEMENT_
- **FP-136** — Examination rules depth (component marks, internal assessment, condonation, hall allocation) · _IMPLEMENT_
- **FP-137** — Multi-store stock & procurement (warehouses, reorder levels, PO → GRN) · _IMPLEMENT_
- **FP-138** — Fixed-asset register & lifecycle (depreciation, warranty, AMC) · _IMPLEMENT_
- **FP-139** — Class & section capacity model · _IMPLEMENT_
- **FP-140** — Classroom / room resource master · _IMPLEMENT_
- **FP-141** — Homework depth (submission lifecycle, late workflow, rubric, typed feedback) · _IMPLEMENT_
- **FP-142** — Lesson-plan structure & review workflow · _IMPLEMENT_
- **FP-143** — Alumni network depth (chapters, opportunities, mentorship, events + RSVP) · _IMPLEMENT_
- **FP-144** — House system depth (house points, competitions, analytics) · _IMPLEMENT_
- **FP-145** — Ranking & awards (dashboard Top-X + student-awards par mabni) · _IMPLEMENT_ · _(v3 correction: demo ke ranking page par koi points engine hai hi nahi — "points/leaderboard" lafz zero dafa aata hai; feature unhi do asal sabooton par re-base hua)_
- **FP-146** — Notification operations centre (delivery/read ledger, channel health, automation catalogue, templates) · _IMPLEMENT_ · _(v3 correction: ye per-user preference page nahi — cross-channel operations centre hai; koi preference UI demo mein hai hi nahi)_
- **FP-147** — Broadcast scheduling & approval queue (recurrence, pause) · _IMPLEMENT_
- **FP-148** — WhatsApp two-way shared inbox (assignment, labels, 24h window) · _INTEGRATE_
- **FP-149** — Reports as artefacts (run lifecycle, save-as-template, review-before-publish) · _IMPLEMENT_
- **FP-150** — Prohibited AI claims — never ship (fabricated metrics/claims ka consolidated record) · _DOCUMENTED BLOCKER_ ⛔
- **FP-151** — Theme filler & kit placeholders (consolidated record — build nahi hoga) · _CONSOLIDATE_
- **FP-152** — List workbench pattern (saved views, column toggles, count chips, export — ek component, ~60 surfaces) · _IMPLEMENT_
- **FP-153** — Dashboard aggregation contract (ek period filter poora dashboard, whole-dashboard export) · _IMPLEMENT_
- **FP-154** — Calendar platform depth (recurrence engine, reminders, audience assignment) · _IMPLEMENT_
- **FP-155** — Skill-rubric feedback & weak-topic diagnosis (deterministic buniyad) · _IMPLEMENT_
- **FP-156** — Voice messages in chat · _IMPLEMENT_
- **FP-157** — Live-class session lifecycle & recordings · _IMPLEMENT_
- **FP-158** — ID card lifecycle (card-number register, bulk runs, issue/acknowledge, replace-lost) · _IMPLEMENT_
- **FP-159** — Approver / moderation layer (multi-level chains, Forwarded, second approver) · _IMPLEMENT_
- **FP-160** — Staff professional development (CPD: certifications, training, mentoring) · _IMPLEMENT_
- **FP-161** — Blog & public content depth (posts, categories, comment moderation) · _IMPLEMENT_

## C — Sirf hamare system mein hai (theme mein nahi)

Ye hamari apni taqat hai; PreSkool ki arrangement mein fit hongi, khatam nahi hongi.

- **FP-013** — Household / family layer (Rektrs custom, staging) · _INTEGRATE_
- **FP-019** — Behaviour records (add-on) · _PRESERVE_
- **FP-020** — Student CV builder · _PRESERVE_
- **FP-021** — Multi-class enrolment · _PRESERVE_
- **FP-033** — Online examination and question bank · _PRESERVE_
- **FP-034** — CBSE examination (add-on) · _PRESERVE_
- **FP-066** — Mobile API and shipped-apps backend (backward compatibility) · _PRESERVE_
- **FP-067** — Desktop sync extensions: Staffpull and Staffsync (Rektrs custom) · _PRESERVE_
- **FP-068** — Live classes: Zoom and Google Meet (add-ons) · _PRESERVE_
- **FP-069** — Online courses (add-on) · _PRESERVE_

## D — Duplicate (ek hi cheez do jagah)

Ek hi workflow/data rakha jayega; doosri surat consolidate hogi.

- **FP-004** — Role dashboards and department launchpad · _CONSOLIDATE_
- **FP-006** — Notice board and announcements · _CONSOLIDATE_
- **FP-037** — Fee assignment paths: group assign, discount assign, quick create · _CONSOLIDATE_
- **FP-038** — AFM — Fee Allocation and Discount Matrix (Rektrs custom) · _CONSOLIDATE_
- **FP-039** — Fee collection and payment allocation · _CONSOLIDATE_

⛔ = DOCUMENTED BLOCKER: FP-072 / FP-086 / FP-087 SaaS-tenant pages (Phase S ki cheez hai), FP-075 student wallet (hamare approved money model se takrata tha — baad mein D-015 ne is ki cafeteria-only surat build karne ka faisla diya), FP-082 server-ops screens (shared hosting par asal mein enforce nahi ho sakteen), **FP-118** double-entry accounting (blueprint candidate N-1 adopt NAHI hua — gap record hai, owner decision pending), **FP-150** prohibited AI claims (theme ke fabricated AI daaway — "true exposure $84K", learning-style labels, teacher leaderboards waghera — D-004 ke tehat kabhi ship nahi honge jab tak asal service/measurement na ho).

## v3 additions — FP-162–FP-180 (live-demo audit, 2026-11-12)

Ye features na theme ke pages mein saaf thay, na hamare system mein hain — ye 27 roles ki roz-marra zindagi aur 10 scenario panels se nikle: woh kaam jo koi page nahi dikhata lekin school roz karta hai.

- **FP-162** — Unified approvals inbox: saari approvals (concession, refund, leave, publication hold, clearance) ek hi aged queue mein · _IMPLEMENT_
- **FP-163** — Standing pickup authorisation: parent portal se daye, foran revoke ho, gate par enforce ho · _IMPLEMENT_
- **FP-164** — Live denial state: gate par inkaar usi waqt har gate/shift par nazar aye (GAP-3 — panel ne build lazmi qarar diya) · _IMPLEMENT_
- **FP-165** — Dismissal reconciliation + inside-now headcount: rozana chhutti ka hisaab, har bacha accounted · _IMPLEMENT_
- **FP-166** — Complaint object: shikayat ka record, reference, SLA clocks, outcome — sirf message nahi · _IMPLEMENT_
- **FP-167** — Secure exam-paper stock: bundle identity, draw log, count-back · _IMPLEMENT_
- **FP-168** — Cafeteria counter POS + day-end close: tap-grid sale, live portions, till close · _IMPLEMENT_
- **FP-169** — Kitchen production-count screen: portions × counter × diet variant, snapshot + delta · _IMPLEMENT_
- **FP-170** — Deposit liability register: refundable deposits liability hain — kabhi income nahi, kabhi TC blocker nahi; leaving par governed release · _IMPLEMENT_
- **FP-171** — Enquiry → application conversion link: fields carry-over ke saath; funnel sirf recorded links se · _IMPLEMENT_
- **FP-172** — Tier-3 confidentiality + view-logging: counsellor/safeguarding records alag tier mein, har view logged — ye pehle bane ga, tab hi counselling digitise hogi · _IMPLEMENT_
- **FP-173** — Staff exit clearance run: janay walay staff ki department clearance, final pay usi se bandha · _IMPLEMENT_
- **FP-174** — In-flight collection state: counter aur portal dono darwazon par ek hi waqt ki collection nazar aye · _IMPLEMENT_
- **FP-175** — Lock-state object + guardian lock surface: lock kab, kyun, kitne par — parent ko pehle se pata · _IMPLEMENT_
- **FP-176** — Commitment object: payment promise (amount, date, accepting officer) jo reminder ladder parh sake · _IMPLEMENT_
- **FP-177** — Publication state surface: results ka lifecycle, aur "Published — ranks pending" ek asal state · _IMPLEMENT_
- **FP-178** — Collector notification set: grant/revoke/handover par authorised collector ko SMS · _IMPLEMENT_
- **FP-179** — Proxy-operation records: login-less staff (peon/aya/cleaner) ke kaam ke records, return path ke saath · _IMPLEMENT_
- **FP-180** — Transport run record + incident record + reconciliation (FP-074 ka bina-GPS hissa — zero devices par chale ga) · _IMPLEMENT_

## v4 additions — FP-181–FP-212 (Round 2 School Board, 2026-11-12)

Ye features board ke faislon (BD-001–BD-076) se nikle hain — loopholes band karne, ghayab machinery mukammal karne, aur wohi cheezein jo 662 findings ne saamne laayeen. Har row ka board home us ke BD number mein hai (BOARD-REPORT §2/§3).

- **FP-181** — Oversight Grant & Board Pack: time-boxed, scoped, step-up-gated oversight access; pack PROVISIONAL stamp + min-cell enforcement ke saath · _IMPLEMENT_
- **FP-182** — Inspection Findings Register + Board Resolution Register: verifier ≠ closer; D-031 + BD decisions register ki pehli entries · _IMPLEMENT_
- **FP-183** — Vaccination Register: admission-intake par lazmi status (captured / verified / exempt-by-record), standalone aur auditable · _IMPLEMENT_
- **FP-184** — Referral Object & Tier-3 Access Classes: structured safeguarding referral, per-case holder classes, creation se clock · _IMPLEMENT_
- **FP-185** — Counsellor Caseload Home: counsellor ki apni queue — referrals, follow-ups, patterns · _IMPLEMENT_
- **FP-186** — Practice Register (sports training attendance): Training Attendance % ke peeche asal register; register se pehle figure kabhi render nahi · _IMPLEMENT_
- **FP-187** — Hostel Activation Pack: warden designation + permissions, roll-call register, occupancy feed, night log · _IMPLEMENT_
- **FP-188** — Recheck Journey: portal + counter intake → acceptance gate → HELD → audited revision → republication → outcome-as-record · _IMPLEMENT_
- **FP-189** — Day-Type Calendar & Role Today Consoles: ek calendar jo kitchen/hostel/dismissal ko feed kare; har role ka Today console · _IMPLEMENT_
- **FP-190** — Parent "Today" View: family ka din ek nazar mein, day-types aur bache ki asal halat se computed · _IMPLEMENT_
- **FP-191** — Policy Centre: har `policy.*` key ek surface par — tier, owner, disclosure state, change history · _IMPLEMENT_
- **FP-192** — Accounts Screen: ek shakhs ki identity, sessions, devices, tokens aur suspension state ek jagah · _IMPLEMENT_
- **FP-193** — Per-Guardian Accounts with Custody Flags: har guardian ki alag identity, custody/restriction flags, per-child scoped views · _IMPLEMENT_
- **FP-194** — Dismissal Pickup Queue: atomic dismissal state par sequenced calling · _IMPLEMENT_
- **FP-195** — Guardian Collection Freeze: ek tap (portal ya SMS keyword) se saare collectors aur one-time grants din ke liye suspend · _IMPLEMENT_
- **FP-196** — Collector Card: physical verification artefact — naam, expiry, koi phone number nahi · _IMPLEMENT_
- **FP-197** — Emergency Meal: kisi bhi money decline par ek governed standard meal/day — welfare entry, parent ko khabar, teesra = welfare signal · _IMPLEMENT_
- **FP-198** — Vendor Payment Advice: monthly no-login statement — kya pay hua, kya park hai, kyun · _IMPLEMENT_
- **FP-199** — Service Rate Agreement: supplier record par agreed rates/hours/scope — services ke match ka anchor · _IMPLEMENT_
- **FP-200** — Recruitment Pipeline: vacancy → shortlist → appointment → FP-117 onboarding handoff · _IMPLEMENT_
- **FP-201** — Staff Grievance Object: filed, routed, clocked staff grievances · _IMPLEMENT_
- **FP-202** — Alumnus Self-View ("My school record"): alumnus apna record aur consent scopes khud dekhe aur challenge kare · _IMPLEMENT_
- **FP-203** — Enquiry Receipt & No-Login Status Page: walk-in family reference ke saath jaye, baghair account progress check kare · _IMPLEMENT_
- **FP-204** — Monthly School-Health Statement: governed registers se ek page — traceable figures, wazeh tor par P&L nahi · _IMPLEMENT_
- **FP-205** — Junior Home "Kal ke liye" Card: sab se chhote students ke liye kal ki zaroori cheezein · _IMPLEMENT_
- **FP-206** — Parent Requests Inbox: family ki har request ek view, ek status language · _IMPLEMENT_
- **FP-207** — Birthday Wishes: fenced birthday wishes students + staff — private card + printed card, birth dates ki public list kabhi nahi · _IMPLEMENT_
- **FP-208** — Push Notification Substrate: device registry, server-held credential, cron-drained queue, feedback pruning, delivery states (Category A infrastructure) · _IMPLEMENT_
- **FP-209** — Received-Pending Register: offline collection ka server half — pending entries, named exceptions, same-day resolution · _IMPLEMENT_
- **FP-210** — Relief Surface: discount / concession / scholarship / waiver ke liye ek darwaza, ek ledger · _IMPLEMENT_
- **FP-211** — Sealed-Envelope Hand-In Log: driver ke zariye jane wale money documents ka received/return record · _IMPLEMENT_
- **FP-212** — Step-Up Verification Service: acts ko authority se price karne wali ek service — grants, number changes, freezes, reveals (Category A infrastructure) · _IMPLEMENT_

Har row ki poori tafseel (saboot, roles, workflow, acceptance check) asal parity matrix (FP-001–FP-100), deep-audit addendum (FP-101–FP-161), live-audit addendum v3 (FP-162–FP-180) aur Round 2 board report (FP-181–FP-212, `discovery/live-audit/round2/board/BOARD-REPORT.md`) mein hai; element-level saboot element register (930 rows) mein hai — ye list unhi ka user-readable khulasa hai.

## v5 additions — FP-213–FP-241 (Round 3 School Board, 2026-11-12)

Adopted — evidence-strong (har ek ka home lane tay hai):
- **FP-213** — Allergy Safety Assurance Pack · _IMPLEMENT_
- **FP-214** — Signed-QR Public Verification · _IMPLEMENT_
- **FP-215** — Exam T-1 Readiness Run · _IMPLEMENT_
- **FP-216** — Household Merge-Queue Workbench (BD-094; build BL-147) · _IMPLEMENT_
- **FP-217** — Data-Integrity Sweep Centre (BD-089; build BL-146 — findings file karta hai, money data kabhi auto-fix nahi) · _IMPLEMENT_
- **FP-218** — Student Self-Referral Door (Tier-3 objects par; BD-084 sequencing) · _IMPLEMENT_
- **FP-219** — Expected-Deliveries Board · _IMPLEMENT_
- **FP-220** — Route Privilege-Gate Census (BD-085 — har wave ki standing release check) · _IMPLEMENT_
- **FP-221** — Sick-Child Pre-Alert Object · _IMPLEMENT_

Adopted — single-source, apne homes ke saath sequenced:
- **FP-222** — OCR Admission & Archive Drafts (sidecar; sirf human-verified drafts) · _IMPLEMENT_
- **FP-223** — Canteen Shift-Open Exception Brief (BL-052/067 ke saath) · _IMPLEMENT_
- **FP-224** — Visiting-Team Gate Pass · _IMPLEMENT_
- **FP-225** — Former-Student Service Intake · _IMPLEMENT_
- **FP-226** — Alumni Contact-Freshness Sweep · _IMPLEMENT_
- **FP-227** — Child Refusal & Hand-Back Protocol (gate chain ke andar, BD-083) · _IMPLEMENT_
- **FP-228** — Fixture Entry States & Atomic Capacity · _IMPLEMENT_
- **FP-229** — Applicant-Money Register (pkfees money path; R-5 lagu) · _IMPLEMENT_
- **FP-230** — Transport Delay Vocabulary Quick-Send (FP-180/BL-111 ke saath) · _IMPLEMENT_
- **FP-231** — Minimum-Cell Suppression Across Aggregates (threshold = policy key) · _IMPLEMENT_
- **FP-232** — Empty/Loading/Error State Kit (BL-138/BL-150 ke saath) · _IMPLEMENT_
- **FP-233** — Admission Duplicate-Suspicion Flag (FP-216 ko feed; BD-086 ke saath) · _IMPLEMENT_

Adopted as component work (standalone feature nahi):
- **FP-237** — Thermal Counter Receipts (printcenter governance ke andar, us ke next touch par) · _IMPLEMENT_
- **FP-240** — Chart Visual-Summary Layer (BL-150/BL-138 ke andar; components only, koi naye metrics nahi — D-004) · _IMPLEMENT_
- **FP-241** — Student Card-Grid View (pkstudents ke next wave ke andar) · _IMPLEMENT_

Noted / deferred (list ki ginti mein nahi): FP-234 Staff SSO via Keycloak — Phase S ko deferred (D-010); FP-235 E-Signature — noted (DocuSeal terms adoption par parhe jayenge); FP-236 External Calendar Sync — noted; FP-238 Contact-Attempt Log — noted (FP-221/FP-180 records mein fold hoga); FP-239 Certificate Legacy-Serial Anomaly Digest — noted (watch brief; BD-073 ruling barkarar).

Har row ki poori tafseel Round 3 board report (`discovery/round3/board/BOARD-REPORT-R3.md` §3) aur lane L8 (`discovery/round3/lanes/L8-features.md`) mein hai.
