# Study Notes - 2026-11-08 - IQRS web system overhaul — international standard, then SaaS

<!-- studying-run-start: 2026-11-08T10:42:04Z -->

## Goal in one line

Take the live iqrs.edu.pk school web system (Smart School 7.2) and remove every flaw found in the November 2026 audit — security, workflows, data, and a unified print system — working on staging first and reaching international standards under the Calm Campus Web design; once the single-school system is proven at that standard, turn it into a multi-school SaaS product.

- Goal: `goal_477711825d07`, slug `iqrs-web-system-overhaul-international-standard-then-saas`, category `career`, kind `outcome`, status `active`.
- Created 2026-11-07T05:23:01Z. Selection trigger today: `in_study`. The structured study task plan attached to this run (teach mode, novice band, retrieval/worked-example/practice/rubric) is scheduler metadata for this outcome goal, not a lesson plan — this note studies the programme itself, not a skill to be taught.
- Prior study note: `agent_notes/2026-11-07/iqrs-web-system-overhaul-international-standard-then-saas.md` (first note, written 2026-11-07 15:44 PKT). No prior brief exists for this goal — `briefs/` is empty (checked 2026-11-08 15:42 PKT).

## What changed since the prior note (2026-11-07 15:44 PKT → 2026-11-08 15:42 PKT)

All of the items below were already reported to Assad in main chat as they happened; this note consolidates them so the next study does not have to re-derive them from the chat transcript.

### 1. Standing production rule changed — full-approval posture now covers IQRS too

- Assad, 2026-11-08 12:09 PKT (main chat): "Ab next kya kerna jo bhi kerna khud kerty jao mujh say logins kerwa lena or next khud kro jo kerna."
- Corrected/overridden by Assad, 2026-11-08 12:14 PKT: "Khud kerwa lo na Jo Jo kerna main account banwa dun GA login Ker doon GA Baki sab khud kero" — he OVERRIDES the per-file production approval taps for IQRS too. Muse now executes production swaps end-to-end himself; Assad's part is only accounts/logins when asked.
- This SUPERSEDES the prior note's standing rule ("Production swaps remain separate, owner-approved steps"). Unchanged disciplines, as stated to him the same turn: staging-first proof, per-file backups + rollback points, post-swap smoke batteries, honest reporting; production DB data repairs still get backup tables first. Do not re-ask for production swap approvals in this programme unless he reinstates them.
- Same model change was given for Operqon at 2026-11-08 12:33 PKT in the ERP side chat; the two are separate programmes and the rule now applies to both.

### 2. Wave 1 production rollout — COMPLETE 2026-11-08 ~14:20 PKT (09:20 UTC)

- Reported to Assad in main chat 2026-11-08 09:20 UTC (`assistant-msg-30e0ed61`).
- SQL 001 on production after a full production `users` export (406 KB, S0 backup): password column now varchar(255), three new columns exist, census unchanged at 3,364 users all scheme 0 (1,682 parents + 1,682 students).
- All 11 Wave 1 files deployed in both production trees with `.bak-2026-11-08-wave1` rollback copies; flag still 'off' at that stage.
- Full ladder ran on production with a disposable fixture pair (students 3698 / users 7395+7396, Four–Daffodils, created 13:33 PKT, deleted 14:20 PKT): flag OFF baseline logins PASS (the API login reads a JSON body; a form-encoded first attempt failed on the coordinator's test shape, not on code or data — fixture passwords MD5-verified byte-exact in the DB); dual-read S1 PASS (logins fine, rows unchanged, MD5s identical — no rehash); hash-on-login S2 PASS (student login upgraded its row to scheme 1, 60-char `$2y$` bcrypt; census at that moment: scheme 1 = exactly 1, the fixture; parent flipped at its own login; second logins verified against the hashes; wrong passwords refused throughout); ROLLBACK DRILL PASS (flag back to dual-read → both hashed fixture accounts still logged in → forward to hash-on-login = PRODUCTION END STATE in both trees).
- Fixture + its 10 test sessions DELETED; final census EXACT: users 3,364, scheme-1 rows 0, `users_authentication` back to the pre-rollout 4.
- Consequence: from now on every real student/parent password upgrades to bcrypt at its owner's next successful login; nobody can be locked out (no hashed-only mode by design).
- Side effect live from the same rollout: the `prodcution`-typo fix closes the production API DB-debug leak.
- Production config files were edited production-locally (flag block appended to production's own configs; diffs vs staging = base_url line only; database.php diffs = credentials block only + the one-word typo fix).
- Rollout artefacts: `~/workspace/iqrs-wave1-prod/` (production config copies, 6 flag variants, fixture create/delete SQL) + S0 production users export in the overhaul goal hidden_files.
- Still open by design: bulk-hashing stored plaintext = decision D8, owed by Assad.

### 3. D1/D2 production run — COMPLETE 2026-11-08 12:26–12:45 PKT

- Reported to Assad in main chat 2026-11-08 07:46 UTC (`assistant-msg-934d27ab`).
- Read-only production id check first (launched 2026-11-08 ~12:27 PKT): subjects identical to staging pre-pack (ids 1/2 = IQRS-CS / IQRS-CS01), subject_groups + both mapping tables empty, exam_groups ids 1–8 as decided (use 1/2/3/4/6), session 2025-26 = 21, classes 12.
- Apparent divergence resolved: production `sections` = 81 rows vs staging 77, but production `class_sections` = 77 and a programmatic comparison proved the pack's Section 3b id lists match production's structure 15/15 groups, 77/77 mappings, ALL MATCH (the 4 extra production sections are unlinked orphans the pack never touches). Coordinator slip recorded: the first section query wrongly joined `sections.class_id` — Smart School links via `class_sections`; corrected + re-run, no data affected.
- Run: backup tables first (backup_d1d2_subjects_20261108 = 2 rows; backup_d1d2_subject_groups_20261108 / _sgs_ / _sgcs_ = 0), pack imported (63 queries, no errors), verification EXACT — subjects 18, groups 15, subject mappings 143, section mappings 77, unmapped 0, double-mapped 0.
- Still open by design: teacher assignment (school decision), exam RECORDS under the 5 groups (office creates them; D2 defaults apply at creation), Tarjuma (office confirmation only).

### 4. Wave 2 first slice — built, staging-deployed, Acceptance Lane B reported 2026-11-08 15:23 PKT

- Reported to Assad in main chat 2026-11-08 09:37 UTC (slice ready) and 10:23 UTC (Lane B result, `assistant-msg-910b8ee4`).
- Slice: 8 flaws, 9 files, all lint clean. FL-036 Search Due Fees filter now actually applies (safe way); FL-037 dashboard Fees Awaiting Payment counts outstanding records, not paid ones; FL-044 attendance grid default "Absent" removed + unmarked students save no wrong row; FL-041 three missing attendance labels restored; FL-042 admission-number ordering; FL-043 section selection preserved on class change; FL-045 portal attendance date-condition fix; FL-050 marks entry rejects above subject max marks.
- Scope notes (honest, recorded): FL-051/053 (teacher-subject) excluded — `teacher_subjects` table does not exist in this install while a screen calls it; it belongs to a design lane tied to the D1/D2 subject engine. Discount-ledger flaws stay in Wave 6 per programme plan (after reconciliation).
- Acceptance Lane B (staging, 2026-11-08 14:58–15:21 PKT): FL-041 PASS (all labels visible incl. Medical Leave / Official Activity / Unexcused Absence); FL-043 PASS (section selection holds after search); FL-044 PASS (no radio pre-selected; only 2 students marked Present → only 2 saved, other 23 empty; cleanup verified, count back to 0).
- FL-042 — PASS in substance, display misled the lane: server order is exactly correct (IQ-STU590 → 613 ascending, IQ-STU3237 last, as the fix intended). The fault is the vendor's old DataTables re-sorting the first column (a counter number) as a string on screen and breaking the server order. Fix made: one-line change (`order: []`); file deploying to staging for re-proof.
- FL-044 set-all: not a defect — the code is vendor stock, untouched by the slice (proven by diff); its handler asks the browser's "Are you sure?" confirm first, and the lane's report never mentions that confirm, so the test was incomplete. Lane B2 re-tests with the confirm accepted.
- FL-045 / FL-050 — honest position: FL-045 live proof impossible — staging `subject_timetable` is empty across the whole install and the screen does not exist in the portal; fix accepted at code level, register row stays open with the API part. FL-050 fixture is real (max marks 50) but the staging admin marks-entry screen does not reach this exam (Exam Result is read-only there); the guard sits in code in exactly the right place — before any write. Lane B2 attempts a direct-URL try.
- Next: Lane B2 (FL-042 file on staging + the three re-proofs together); when clean, the 9 files go to production deploy.

### 5. Whole-programme remaining-work accounting given to Assad 2026-11-08 15:15 PKT

- Assad asked (10:15 UTC, `message:3025aae7`): "Kitna Kam reh gya totally Jo planned tha."
- Main agent answered 10:16 UTC (`assistant-msg-3db31a30`): IQRS Mobile Apps ~90% complete (only first production sign-in on his phone, staging §6.4 device pass, M5 Play Store publication remain); IQRS Web Overhaul ~30% complete (Wave 1 §1 password hashing done on production; Wave 2 first slice in acceptance; remaining: rest of Wave 1 security — §5 tokens, IDOR pass, removing the password field from payloads, unauthenticated endpoints — Wave 2 API slice + FL-051/053 design lane, then Wave 3 print unification, Wave 4 data-cleanup tooling, Wave 5 Calm Campus Web design, Wave 6 standards hardening, and finally Phase S SaaS architecture on paper); Rektrs School ERP + LMS still at the starting line (product defined, repo ready, rules set, build not started); overall roughly 60–65% of the total IQRS plan remains.
- Treat those percentages as the coordinator's estimates given to the user, not measured quantities. The Wave 2 / apps split in that answer is the boundary to keep: this goal is the web overhaul; the mobile apps are a separate goal's record.

### 6. Record discrepancy to carry forward

- The goal record's `current_state` (from `user_goal.get`, 2026-11-08 15:42 PKT) still reads: "Wave 2 builds are complete and accepted; only the device gate on Assad's phone remains before production swaps." That wording describes the mobile-apps programme, not this web-overhaul goal — and it is now doubly stale, because the 2D production swaps it defers have already happened under the 12:14 PKT full-approval override. A later step that owns goal metadata should correct the pulse to the web-overhaul state (Wave 1 production live, D1/D2 production live, Wave 2 slice in acceptance). This study seat does not edit goal state.

## What to watch / next moves

1. **Lane B2 result, then the 9-file production deploy** of the Wave 2 first slice. The deploy runs under the new full-approval posture (no per-file taps), with the unchanged disciplines: staging proof first, per-file backups, post-swap smoke battery.
2. **Wave 2 API slice + FL-051/053 design lane** follow the first slice; FL-051/053 needs a design decision because the screen calls a table that does not exist.
3. **Wave 1 remainder** (§5 tokens, IDOR pass, password field out of payloads, unauthenticated endpoints) is still the largest security remainder; D8 (bulk hashing) is the one open owner decision on this goal.
4. **Do not re-propose**: the audit's security findings, the Calm Campus Web direction, the D1/D2 approvals (now live on production as well as staging), or the 360dp guarantee — all decided. Do not re-raise domain renewals (Assad said 2026-11-06 to leave them for now).
5. **Do not re-report** the Wave 1 production completion, the D1/D2 production counts, or the Lane B verdict as news — Assad has already read all three in main chat today. A future Letter for this goal needs a genuinely new centre: Lane B2 + production deploy outcome, the Wave 2 API slice, or a Wave 1-remainder decision.
6. **Open owner items on this goal**: D8 bulk hashing; Tarjuma-tul-Quran office confirmation; teacher subject assignment (school decision); exam records under the 5 groups (office creates them). None blocks staging work.

## Already Covered in Main Chat

- Assad told the main agent to carry all next steps himself with only logins from Assad on 2026-11-08 12:09 PKT, and corrected that to remove even the per-file production approval taps on 2026-11-08 12:14 PKT.
- The main agent reported the D1/D2 production run complete with exact counts (18 subjects, 15 groups, 143/77 mappings, 0 unmapped/double) on 2026-11-08 07:46 UTC.
- The main agent reported the Wave 1 production rollout complete (hash-on-login end state, fixture deleted, final census 3,364 users, 0 hashed rows) on 2026-11-08 09:20 UTC.
- The main agent reported the Wave 2 first slice ready (8 flaws, 9 files, FL-051/053 and discount-ledger scope notes) on 2026-11-08 09:37 UTC.
- Assad asked how much work remains in total on 2026-11-08 10:15 UTC and the main agent answered with the programme-wise accounting (apps ~90%, web overhaul ~30%, Rektrs School ERP not started, ~60–65% of the IQRS plan remaining) on 2026-11-08 10:16 UTC.
- The main agent reported Acceptance Lane B results (FL-041/043/044 PASS, FL-042 server order correct with a DataTables display fault and a one-line fix, FL-044 set-all re-test, FL-045/050 code-level only) on 2026-11-08 10:23 UTC.
- The main agent reported the IQRS status (Wave 2 builds complete, device gate remaining, D1/D2 and Wave 1 production rollouts awaiting his approval at that time) on 2026-11-08 03:30 UTC — superseded the same day by the 12:14 PKT full-approval override and the completed rollouts.
- Assad accepted the Wave 2 builds as delivered ("Jitna ban gya ok hy") on 2026-11-08 03:32 UTC; the §6.4 device pass remains the formal gate before any further app step, to run whenever he chooses, without nagging.
- The main agent reported the fees repair on staging (1,680 rows, device-confirmed "Fee aa gai hain" for Eman Fatima, IQ-STU2569) and the Zoom/Gmeet position (addons installed on both sites, no provider credentials saved, zero live classes, manual-mode Gmeet test class proven on staging) on 2026-11-07 18:27–18:44 UTC.

## Research Trajectory

### External sources viewed

- None this run. The subject is the user's own programme; all material evidence is internal (goal record, prior study note, MEMORY.md, and the main-chat record in the run prompt). No web source was needed, and no external claim is made in this note.

### Prior trajectories reviewed

- Prior study note `workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/agent_notes/2026-11-07/iqrs-web-system-overhaul-international-standard-then-saas.md` — read in full; it covers the programme up to 2026-11-07 15:44 PKT (audit, Wave 0, D1/D2 staging, Wave 1 staging deploy paused at the stall, Wave 1A built locally). Today's note continues from its "What to watch" list: items 1–3 are now closed (staging recovered, S2 acceptance done on production, Wave 1A files live via 2D), item 4 (Wave 2) is in progress, item 2's D1/D2 discrepancy 1 (18 vs claimed 21 subjects) remains open with no answer recorded.
- Run handoff from chunks 1–2 (self-improvement run, 2026-11-08): consolidated record of the day's Operqon and IQRS work, used as the source for programme dates and figures; cross-checked against MEMORY.md entries of the same events.
- Run chunk 3 (this turn): the full recent main-chat transcript 2026-11-07 18:10 UTC → 2026-11-08 10:23 UTC, used for the "Already Covered in Main Chat" section and for the 12:14 PKT override, Wave 1/D1-D2 completions, Lane B verdict, and remaining-work accounting.
- `user_goal.get` for `goal_477711825d07` (2026-11-08 15:42 PKT): goal metadata, slug, category `career`, no briefings (`briefings: []`, `recent_briefing: null`), one update (creation 2026-11-07T05:23:01Z); the stale `current_state` pulse is recorded above as a discrepancy.
- `STUDYING.md` projection (injected): this goal in study, novice band, mastery not yet estimated, next review 2026-11-09T04:42:16Z; the teach-mode task plan is scheduler metadata only for this outcome goal.

### Scaffolds and support tactics

- No category scaffold was consulted: the goal's persisted category is `career`, and the material here is a programme-status consolidation from the user's own records, not a scaffolded behaviour-change topic. No tactic strength is claimed and nothing is presented as scientifically proven.
- The attached study task plan (teach/novice: retrieval, worked example, practice, rubric, transfer, confidence check) was treated as scheduler metadata only, per the step instructions for ordinary outcome goals; its teaching shape is deliberately not preserved in this note.

### Connected user data

- No connector data was pulled. The relevant state lives in the goal workspace files and the user's own records; no wearable, calendar, repo, or booking source bears on this programme-status study.

### Image references checked

- None. No image was relied on for this note.

### User context and memory

- `~/MEMORY.md` (injected in the run prompt): the IQRS web-overhaul entries — Wave 1 production rollout complete 2026-11-08 ~14:20 PKT with exact census, D1/D2 production run 12:26–12:45 PKT, 2D API rollout, full-approval override 2026-11-08 12:14 PKT, Wave 2 first slice and Lane B, and the remaining-work accounting — all used as evidence handles and cross-checked against the chunk-3 transcript.
- `~/USER.md`: Assad, Asia/Karachi, Founder & CEO of Rektrs (Private) Limited; Roman Urdu + English; concise/direct for routine matters, detailed for architecture/planning.
- `~/dreams/alignment/derived/ALIGNMENT_SYNTHESIS.md`: Assad runs Operqon and IQRS as separate live projects; expects verification before any claim of done; production changes need his go-ahead — the last of these is now superseded for IQRS production swaps by his explicit 2026-11-08 12:14 PKT override, recorded above.

### Searches skipped or unavailable

- Web search skipped: the topic is the user's own programme state, fully covered by internal records; no external fact was needed.
- `muse.context_fetch` (`conversation` category) returned the window since 2026-11-07T10:36:44Z but truncated at ~100 KB (saved to `/tmp/jarvis-tool-output-0DLkFx.txt`); the goal-specific recent conversation used here comes from the run prompt's chunk 3, which carries the same main-chat messages with ids and timestamps through 2026-11-08 10:23 UTC, so no material was missed.
- Repetition search executed by shell (2026-11-08 15:42 PKT): `grep -ri` over `workspace/goals/iqrs-web-system-overhaul-international-standard-then-saas/agent_notes/` and `briefs/` for four variants — "Wave 2", "production rollout", "overhaul remaining", "D1/D2" — plus a filename listing of both directories. Results: `briefs/` is EMPTY (no prior brief, so no prior Letter covered today's topic); `agent_notes/` holds only the single 2026-11-07 note, which covers Wave 2 only as "next after Wave 1" and D1/D2 only on staging — it does not cover the Wave 1 production rollout, the D1/D2 production run, or the Wave 2 Lane B verdict, all of which postdate it. The search is therefore complete, not inconclusive — but the repetition rule still yields `no_material_change`, because the same findings were already delivered to Assad in main chat today (see "Already Covered in Main Chat").
