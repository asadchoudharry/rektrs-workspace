# Study Notes - 2026-11-14 - IQRS web system overhaul — international standard, then SaaS

<!-- studying-run-start: 2026-11-14T15:12:40Z -->

## Goal in one line

Take the live iqrs.edu.pk school web system (Smart School 7.2) and remove every flaw found in the November 2026 audit — security, workflows, data, and a unified print system — working on staging first and reaching international standards under the PreSkool pixel-perfect rebuild; once the single-school system is proven at that standard, turn it into a multi-school SaaS product.

- Goal: `goal_477711825d07`, slug `iqrs-web-system-overhaul-international-standard-then-saas`, category `career`, kind `outcome`, status `active`.
- Created 2026-11-07T05:23:01Z. Selection trigger today: `in_study`. Run clock 2026-11-14T14:36:00Z / 19:36 PKT; run started 2026-11-14T15:12:40Z / 20:12:40 PKT. The structured study task plan attached to this run (teach mode, novice band, retrieval/worked-example/practice/rubric) is scheduler metadata for this outcome goal, not a lesson plan — this note studies the programme itself, not a skill to be taught. Mastery stays unestimated (fewer than three observed performances exist for any learning framing; none is attempted here).
- Prior study notes: `agent_notes/2026-11-07/` through `agent_notes/2026-11-13/iqrs-web-system-overhaul-international-standard-then-saas.md` (last one written 2026-11-13 15:34 PKT). No prior brief exists for this goal — `briefs/` is empty (checked again 2026-11-14 ~20:15 PKT, 0 files).
- Goal record (`user_goal.get`, 2026-11-14 ~20:15 PKT): `current_state` reads "Staging stalled again since the evening; D2-O lane healthy, run 5 passed, run 6 in setup, production answering normally." Latest timeline update `goal_update_adfcf4052578` (2026-11-14T15:15:06Z, 20:15 PKT): 15-min check, D2-O healthy, run 5 close-out all pass, run 6 battery in setup; staging still stalled, production fine. This study seat does not edit goal state.

## What changed since the prior note (2026-11-13 15:34 PKT → 2026-11-14 20:15 PKT)

All times PKT unless marked UTC. The programme crossed a real boundary in this window: Phases 1–5 are now all closed (per MEMORY.md, programme state at the 2026-11-13 close), and the desktop D2-6 lane closed with a full battery pass. Almost every item below was already reported to Assad in main chat as it happened (see "Already Covered in Main Chat"); this note consolidates them so the next study does not have to re-derive them from the transcript. That fact — not a lack of progress — is what drives today's `no_material_change` ruling (see the ruling note at the end).

### 1. BL-108 dismissal safety — COMPLETE, CEO-verified (2026-11-13 16:26 PKT)

- Battery run 9 GREEN: **136 pass / 0 fail** (P12/P13 both pass, so the BUG 10 fix is proven — pass-use now releases correctly). Probe-after and close-out complete; census back to 122; production untouched; snapshot pushed to `iqrs-system` (commit `52899cb69952`).
- Reported in main chat 2026-11-13 16:26 PKT (message `assistant-msg-76679793-1bd8-cf58-35f1-2981d29d9fd1` in the `context_fetch` window). Two design questions for the Board were recorded with the close-out (content not specified in the evidence available to this run — do not invent them; the next study can pull them from the BL-108 record if needed).

### 2. PF-4 / PF-5 workspace retrofits — COMPLETE on staging (~2026-11-14 01:17 PKT)

Per the run handoff (chunks 1–2) and MEMORY.md programme state; production untouched, fee census unchanged throughout.

- **Fees:** battery 92/0; Excel export 47 rows. **EX-012 exemption rejected** — build PDF / Excel / CSV export rather than exempting it.
- **Students:** grid plus stat strip, battery 86/0; B3 dropdown CSS fix.
- **Academics:** exam 19 — 15 assessed, average 66.78, pass 14 / 1; battery 68/0.
- **Attendance:** calendar heatmap, D2–D4 fixes (Bootstrap `!important` and link-specificity); battery 83/0.
- **Exams:** bands 2 / 3 / 3 / 5 / 2 / 0; battery 61/0.
- **HR:** 9 screens, Leave 14; battery 63/0; residuals R-HR-1 and R-HR-2 carried to the refinement pass.
- **TD-1:** 43 reads closed.
- Caveat for the next study: the handoff gives no main-chat message handle for the PF-4/5 completion report itself, so this note records it as handoff/MEMORY evidence, not as a verified main-chat delivery. The ruling below does not rest on PF-4/5 alone.

### 3. Phase 4 and Phase 5 — CLOSED

- **BL-139 Apps Store:** 33/0 (63 modules, 232 sidebar rows, 158 prefixes). **BL-140 conformance:** 23/23 surfaces, 138 policy keys. Phase 4 closed.
- **BL-060 restore:** 506/506 tables, 122,023 rows. **BL-061 charset:** 18 tables. **BL-062 indexes:** `parent_id` lookup 31.09 ms → 1.11 ms. Phase 5 closed.
- Also recorded complete in MEMORY.md in this window: BL-134 (nightly money-integrity sweep; battery 34 checks, 26 diagnosed — F3 phantom ledger 2057 + no-grantor ledger 2058 found, clean sweep run 6, no auto-correct, positions md5 same; snapshot `a7567313`; web legs UNPROVEN, awaiting Assad's authorisation), BL-135 (payables match, battery 69/0, commit `029d4697`), BL-136 (battery 65/0, commit `34928d6b`), BL-153 (double-entry GL, battery 56/56 + 19/19, commit `c4314150`), BL-154 (battery 38/38, commit `574a4309`; closed the portal Exam write gap — a family login could change global exam rows, now 404), BL-150 (token sweep; colours 754 → 0, neutrality 13,040 declarations identical, commit `7d951d87`), BL-138 (Theme Store; neutrality 0 diffs / 32,662 declarations, rollback exact, commit `4299a762`). The GL billing-ingest event is NOT built (see §6, open tails) — BL-153's ledger exists; its billing feed does not yet.

### 4. Desktop D2-6 — COMPLETE and CEO-verified (2026-11-14 ~17:01 PKT)

D2-2 through D2-5 were already complete with an Inspector pass before this window. D2-6 (21 screens: exams/marks, four Staffsync twins + Student Edit, printing schema v9, remaining schemas/pull appliers schema v10, 26 tables + `leave_approvals_queue` view) closed in this window after a long battery grind against the staging stall:

- Runs 12–20 were dominated by the staging route, not the product: run 12 aborted on 8 failed login retries; run 13 phase A 30/40 with WAITING-state fails; run 16 phase A 35/40 (5 fails, route dead spell); run 17 aborted with 0 legs (route dead the whole run); run 18 phase A 31/40 (9 fails, route); run 19 phase A 35/40 (5 fails, early dead spell); run 20 stopped early on a dirty baseline — run-18 fixtures had never been cleaned, so only A0 passed.
- **Run 21 (launched ~14:35 PKT 2026-11-14, after loan 21 was returned and the baseline re-verified clean): Phase A 40/40 — the first full clean Phase A.** Phase B then aborted on 4 fails; the L1/L2 fails were a driver counting flaw, not an app defect (driver fixed), and the Phase B fails were the route dropping mid-phase.
- **Run 24 — FULL PASS: phase A 40/40 · DB proofs 20/20 · phase B 5/5 · post-B 4/4** (goal update `goal_update_13aeda3a5444`, 2026-11-14T11:57:46Z, 16:57 PKT).
- **D2-6 COMPLETE + CEO-VERIFIED 2026-11-14 ~17:01 PKT** (goal update `goal_update_007db215e0ab`, 2026-11-14T12:12:14Z, 17:12 PKT). Inspector pass: **ALL 7 CHECKS PASS** (~17:05 PKT). Close-out: fixtures cleaned, proof staff 276 deleted (census 122), lane key revoked, staging md5s at baselines, production never written.
- **D2-7 dispatched ~17:06 PKT** (same goal update): D2-O — online-only setup surfaces #30/#31/#32/#41/#53 + exam setup, client-only. The D2-8 gate battery follows and decides the BD-005 lift.
- Working method worth preserving: Assad directed (2026-11-14 ~14:02 PKT, messages `b727cadc…` / `3ab591ee…`) that all stalled SSH work run via his laptop, and the laptop-jump route was proven the same day (JUMP-OK, Hostinger `u238632175`, ~19 seconds, first try; VPS jump also proven). The D2-6 cleanup (loan 21 return, double cleanfixture, ssid 2131 verify) landed through that route; the jump route then dropped ~14:20 PKT and recovered. The staging stall itself lifted at ~14:42 PKT (staging 200, 1.7 s) after hours of 000 / ~10.5 s, then recurred in the evening (see §5).

### 5. Desktop D2-7 — build complete, staging battery running (2026-11-14, through 20:15 PKT)

- **Build complete and verified locally** (goal update `goal_update_f2e7effea7de`, 2026-11-14T12:42:56Z, 17:42 PKT): online-only Setup build (fee, transport, exam and staff setup screens), local proof 8/8, gallery 12/12. Staging battery passed setup, then hit three failures in the fees phase under diagnosis.
- Battery run 2 stopped at setup (fee data pulled in, student-session records empty); run 3 in setup phase at 18:41 PKT; run 4's setup aborted on the staging stall and its close-out was still riding the SSH retry loop at 19:28 PKT (goal update `goal_update_85145b3783f6`).
- **Run 5 close-out all pass; run 6 battery in setup at 20:15 PKT** (goal update `goal_update_adfcf4052578`, 2026-11-14T15:15:06Z). The evening staging stall had returned by then (see §5 stall note in the D2-6 section and the goal `current_state`); production still answering normally.
- **Staging has NO active API client key** (BL-098 revoked all; any future proof needs a fixture-issued scoped key).

### 6. Standing programme state carried forward (unchanged, re-confirmed)

- Programme state at the 2026-11-13 close: **Phases 1–5 ALL CLOSED.** Remaining: PF track (PF-6, PF-7 BL-048/049/050/051 + BL-137 + tracker-data build), Phase 6 (FL-001 load + FL-002 pentest), the refinement pass, and the single D-027 production cutover.
- D-027 stands: no PreSkool on production until the whole build is complete; production is one gated, owner-approved package afterwards. Production untouched by every lane in this window.
- Exam 19 runs Mon 16 – Thu 19 Nov 2026, published, 40.00% pass; paper register sheets approved by Assad 2026-11-12 12:14 PKT ("Ok proceed"), useful until Sun 15 Nov evening when Monday's bundles are made. **Rank snapshot still owed** (timestamped marks-hash filed before ANY rank generation, D-037 §5).
- Open tails (from MEMORY.md, unchanged): governed-surface web legs UNPROVEN (await Assad's authorisation); `pkglreport` / `pkpayreport` host cron is an office act; emergency standard-meal dish key unset; GL billing-ingest event NOT built; Mynotifications GET fallback still changes state (SRL-5).
- D2-G tails: OutboxEngine `status:0` sentinel; Waiting-screen discard leaves a draft QUEUED; `applyFromCache()` rollback on the retained D-2 fixture pair (session 21 / student 3754). Hardware proofs W-1/W-2/W-3/W-5 WAITING (school printers unnamed — owner/school input).
- Refinement pass (Assad, 2026-11-13 ~11:27 PKT) still sits between build completion and the D-027 cutover: pixel-match verdicts via paired side-by-side captures, polish tails (BL-046/047 §4 items, R-HR-1/R-HR-2), fixture cleanup/label. PF-3's CEO paired-capture pixel pass and Assad's own signed-in portal check are still open. PF-1 shell pixel pass still owed.
- Driver live-location: tracker-data API layer to build (FP-074 device/feed half; FP-242 live-fleet-map MOCK, P1, D-046), driver-app GPS as continuous fallback; GPS device procurement unchanged unless Assad says otherwise.
- Family: Principal dispositions still 0 of 151 mixed groups / 373 students — human-confirmed merges only, never auto-merge. D2 fees scope stays vendor tables only; live offline fee collection stays OFF per BD-005 until the received-pending staging proof gates it (D2-8 gate battery decides the lift).

## What to watch / next moves

1. **D2-7 battery:** run 4 close-out, then a clean full battery; D2-8 gate battery after it decides the BD-005 lift. Watch for the fee-phase failures from run 1–2 (setup abort: student-session records empty) to be diagnosed as route vs product.
2. **Exam 19 (Mon 16 – Thu 19 Nov 2026):** bundles made Sun 15 Nov evening; rank snapshot (timestamped marks-hash) must be filed before ANY rank generation.
3. **Refinement pass scheduling:** do not call the build finished when the last feature lands — the refinement phase sits between build completion and the D-027 cutover. Track its scheduling when PF-7/PF-8 close.
4. **PF-3 / PF-1 pixel passes:** CEO paired-capture verdicts still owed; Assad's own signed-in portal check is his step (family logins owner-held).
5. **Driver live-location feature:** tracker-data ingestion/access API layer + driver-app GPS fallback; sequencing after current lanes, against FP-074/FP-242. Do not conflate the software build with GPS procurement.
6. **Open tails to close before cutover:** governed-surface web legs (needs Assad's authorisation), `pkglreport`/`pkpayreport` host cron, emergency-meal dish key, GL billing-ingest event, Mynotifications GET fallback (SRL-5), D2-G items, hardware proofs W-1/W-2/W-3/W-5.
7. **Do not re-propose:** the audit's security findings, D1/D2 approvals, student-card composition (Assad chose Option A), family wallet drop for fees (D-F2; cafeteria wallet only), F-2 40% rule, "Previous Arrears" name, no-BOYS header, PreSkool as-is (D-014/D-015/D-016), web+desktop-only PreSkool scope, D-031/D-032, D-034/D-037 board decisions — all decided. Do not re-raise domain renewals (Assad said 2026-11-06 to leave them for now).
8. **Do not re-report** the BL-108 completion, the PF-4/5 completion, the Phase 4/5 closures, or the D2-6 completion as news — Assad has already read the D2-6/BL-108 items in main chat, and the PF-4/5 and Phase 4/5 items are recorded in MEMORY.md programme state. A future Letter for this goal needs a genuinely new centre: the D2-7/D2-8 outcome, the PF-3 pixel-pass verdict, the GP-1 swap result, the tracker-API build landing, or the Exam 19 outcome.

## Ruling note

`no_material_change`. No prior brief exists for this goal (`briefs/` empty, 0 files), so no stored Letter covers today's topic — but the repetition search plus the main-chat record together defeat a `create` ruling. The keyword variants searched in this closing pass ("D2-7|D2-6|PF-6|PF-7|Exam 19|rank snapshot|staging stall" and "D2-O|run 24|run 21|run 22|BL-139|BL-140|BL-060|BL-061|BL-062|PF-4|PF-5") return no prior note recording any of today's completions — the only hits are pre-existing mentions (Exam 19 sheets and the rank-snapshot rule in the 2026-11-12/13 notes; staging-stall signatures in the 2026-11-07/11 notes) — AND every one of today's centres was already delivered to Assad in main chat on 2026-11-13/14: BL-108 complete 2026-11-13 16:26 PKT (message `assistant-msg-76679793-1bd8-cf58-35f1-2981d29d9fd1`), D2-6 run 24 full pass and D2-6 complete + D2-7 dispatched (goal updates `goal_update_13aeda3a5444` and `goal_update_007db215e0ab`, 2026-11-14 16:57 and 17:12 PKT, with the run-by-run D2-6 updates through the day in the 15-minute main-chat updates), D2-7 build complete (goal update `goal_update_f2e7effea7de`, 17:42 PKT), the staging stall clearing (goal update `goal_update_85145b3783f6`, 19:28 PKT), and run 5 close-out all pass with run 6 in setup (goal update `goal_update_adfcf4052578`, 20:15 PKT). A Letter now would hand Assad his own day back to him. The study note itself is the durable record: it preserves the BL-108 close-out, the PF-4/5 and Phase 4/5 closures, the D2-6 run 12–24 chronology with the run-24 full pass, the D2-7 build and battery state, and the open tails for the next study.

## Already Covered in Main Chat

- The main agent reported BL-108 complete and CEO-verified on 2026-11-13 16:26 PKT (battery run 9 136/0, snapshot commit 52899cb69952, census 122, production untouched).
- The main agent reported D2-6 in the 15-minute updates through 2026-11-14: run 13 phase A 30/40 at 09:32 PKT, run 16 phase A 35/40 at 11:13 PKT, run 18 phase A 31/40 at 12:28 PKT, run 19 phase A 35/40 at 13:13 PKT, run 20 stopped on a dirty baseline at 13:57 PKT, run 21 Phase A 40/40 at 15:13–15:28 PKT, and run 24 full pass at 16:57 PKT.
- The main agent reported D2-6 complete and CEO-verified with all 7 inspector checks passed, and D2-7 dispatched, on 2026-11-14 ~17:01–17:12 PKT.
- The main agent reported D2-7 build complete (local proof 8/8, gallery 12/12) on 2026-11-14 17:42 PKT, battery run 2 setup abort at 18:11 PKT, run 4 close-out riding the SSH retry loop at 19:28 PKT, and run 5 close-out all pass with run 6 in setup at 20:15 PKT.
- The main agent reported the staging stall lifting at ~14:42 PKT on 2026-11-14 (staging 200, 1.7 s) and again clearing at 19:28 PKT (staging 200 in 1.7 s, production 200 in 1.4 s), then stalling again since the evening (20:15 PKT check), with production at 200 throughout.
- Assad directed on 2026-11-14 ~14:02 PKT that all stalled SSH work run via his laptop, and the main agent confirmed the laptop-jump route proven (JUMP-OK, Hostinger u238632175, first try) and the D2-6 cleanup landed through it.
- The PF-4/5 completion, BL-139/BL-140 and BL-060/061/062 closures, and Phases 1–5 all closed are recorded in MEMORY.md programme state at the 2026-11-13 close; no main-chat message handle for those specific completion reports is in this run's evidence, so they are cited here as handoff/MEMORY evidence only.

## Research Trajectory

### External sources viewed

- None this run. The subject is the user's own programme; all material evidence is internal (goal record, prior study notes, MEMORY.md, the run handoff, and the main-chat record in the run prompt plus the `context_fetch` window). No web source was needed, and no external claim is made in this note.

### Prior trajectories reviewed

- Prior study note `workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/agent_notes/2026-11-13/iqrs-web-system-overhaul-international-standard-then-saas.md` — read in full; it covers the programme up to 2026-11-13 15:34 PKT (BL-133, PF-3, cafeteria, BL-046/047, BL-108 runs 1–7, tracker-API and refinement-pass directives). Today's note continues from its "What to watch" list: BL-108 is now closed (item 1 there), and the PF-4/5, BL-139/140, BL-060–062, and D2-6 items it sequenced as next are now complete.
- Prior study notes `agent_notes/2026-11-07/` through `2026-11-12/` — referenced via the repetition search below; they hold no BL-108 completion, PF-4/5 completion, BL-139/140 completion, BL-060–062, D2-6 completion, or D2-7 content.
- Run handoff from chunks 1–2 (self-improvement run, 2026-11-14): compacted findings — PF-4/5 wave complete ~01:17 PKT 2026-11-14 with per-module battery scores, BL-139 33/0, BL-140 23/23, BL-060/061/062 Phase 5 closure, D2-2…D2-5 complete, D2-6 run 12 in progress at 04:07Z with the staging flicker — used as continuity and cross-checked against the chunk-3 transcript, the goal timeline, and MEMORY.md.
- Run chunk 3 (this turn): the main-chat transcript 2026-11-14 ~04:08–10:33 UTC (09:08–15:33 PKT) — D2-6 15-minute updates (runs 12–21, laptop-jump direction and proof, staging stall/production 200), plus the Postiz / ServerKit / Operqon threads (separate programmes, not this goal) — used for the "Already Covered in Main Chat" section and for every D2-6 timestamp in this note.
- `user_goal.get` for `goal_477711825d07` (2026-11-14 ~20:15 PKT): goal metadata, slug, category `career`, no briefings (`briefings: []`, `recent_briefing: null`), and the timeline updates through `goal_update_adfcf4052578` (20:15 PKT — D2-O healthy, run 5 close-out all pass, run 6 in setup, staging stalled again, production fine).
- `STUDYING.md` projection (injected): this goal in study, novice band, mastery not yet estimated, next review 2026-11-15T15:12:40Z; the teach-mode task plan is scheduler metadata only for this outcome goal.
- `muse.context_fetch` (`conversation` category, window since 2026-11-13T10:32:28Z, fetched 2026-11-14 ~20:15 PKT): return was truncated at ~100 KB in the head view, showing the 2026-11-13 window (BL-108 complete 16:26 PKT, PF-3/BL-133 context); the 2026-11-14 main-chat content is therefore evidenced from the run prompt's chunk 3 and the goal timeline, not from a re-fetched transcript — recorded here so the next study knows the fetch did not independently re-verify today's messages.
- `~/MEMORY.md` (injected): the IQRS entries now include D2-6 complete + CEO-verified (run 24 full pass, inspector 7/7), D2-7 dispatched, Phases 1–5 all closed, BL-139/140 and BL-060–062 closures, the open tails (governed-surface web legs, host cron, meal dish key, GL billing-ingest event, Mynotifications SRL-5), and the D2-G tails — used as evidence handles and cross-checked against the chunk-3 transcript and the goal timeline.

### Scaffolds and support tactics

- No category scaffold was consulted: the goal's persisted category is `career`, and the material here is a programme-status consolidation from the user's own records, not a scaffolded behaviour-change topic. No tactic strength is claimed and nothing is presented as scientifically proven.
- The attached study task plan (teach/novice: retrieval, worked example, practice, rubric, transfer, confidence check) was treated as scheduler metadata only, per the step instructions for ordinary outcome goals; its teaching shape is deliberately not preserved in this note.

### Connected user data

- No connector data was pulled. The relevant state lives in the goal workspace files and the user's own records; no wearable, calendar, repo, or booking source bears on this programme-status study.

### Image references checked

- None. No image was relied on for this note.

### User context and memory

- `~/USER.md`: Assad, Asia/Karachi, Founder & CEO of Rektrs (Private) Limited; Roman Urdu + English; concise/direct for routine matters, detailed for architecture/planning.
- `~/dreams/alignment/derived/ALIGNMENT_SYNTHESIS.md`: Assad runs Operqon and IQRS as separate live projects; expects verification before any claim of done; his own browser check is ground truth over lane claims; production changes under his full-approval posture for IQRS swaps (2026-11-08 override), with staging-first proof, per-file backups, and smoke batteries still applying.

### Searches skipped or unavailable

- Web search skipped: the topic is the user's own programme state, fully covered by internal records; no external fact was needed.
- Repetition search executed by shell in this closing pass (2026-11-14 ~20:15 PKT): `grep -rniE` over `workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/agent_notes/` and `briefs/` for the keyword-variant sets "D2-7|D2-6|PF-6|PF-7|Exam 19|rank snapshot|staging stall" and "D2-O|run 24|run 21|run 22|BL-139|BL-140|BL-060|BL-061|BL-062|PF-4|PF-5", plus a filename listing of both directories. Results: `briefs/` is EMPTY (0 files, no prior brief, so no prior Letter covered today's topic); `agent_notes/` holds only the 2026-11-07 through 2026-11-13 notes, which contain no record of any of today's completions — the only hits are pre-existing mentions (Exam 19 sheets and the rank-snapshot rule in the 2026-11-12/13 notes; staging-stall signatures in the 2026-11-07/11 notes). The search is therefore complete, not inconclusive — but the ruling is still `no_material_change`, because every one of today's centres was already delivered to Assad in main chat on 2026-11-13/14 (see "Already Covered in Main Chat").
