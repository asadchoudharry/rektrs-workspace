# H5P Feature Study — the interactive-content layer, and what it would (and would not) do for our two school systems

**Date:** 2026-11-28 · **Type:** STUDY-ONLY feature reference · **Subject:** H5P (github.com/h5p, h5p.org), the open-source HTML5 interactive-content framework maintained by H5P Group (Joubel AS, Norway; acquired by D2L in 2024, still open source). Batch #3 of the IQRS-special study series, companion to the Gibbon and Moodle studies of the same date.

> **⚠️ LICENCE NOTE — read first, because H5P's licence is split and the split matters.** Verified from the repositories on 2026-11-28:
>
> - **The content types are MIT.** The 50+ content-type libraries (Interactive Video, Branching Scenario, Course Presentation, the question types, the games) and the **editor library** (`h5p-editor-php-library` — its README states "All code is licensed under MIT License") are MIT-licensed. MIT code can be embedded in a proprietary commercial SaaS without copyleft consequences.
> - **The core PHP library is GPL-3.0.** `h5p-php-library` — the framework core that validates, stores, serves and plays packages on a PHP platform — carries a GPL-3.0 `LICENSE.txt`, and GitHub's licence detection for the repo reads GPL-3.0. Its own README explains why: *"The H5P PHP library is GPL licensed due to GPL code being used for purifying HTML provided by authors"* — a third-party HTML-purifier component inherited from Drupal-era code. H5P's own licensing page says the project "tries to use the MIT license wherever possible" and that the GPL component "will be made optional" — a long-standing intention that, as of the repo state read today, **has not happened**: the core is still GPL-3.0.
> - **Content shared on h5p.org is CC BY 4.0** unless stated otherwise (that is about their example content, not the code).
>
> **What this means for a commercial SaaS, precisely:**
> 1. *Hosted SaaS (our model — we run the servers, schools log in):* GPL-3.0 is **not** AGPL — it has no network-use clause. Running the GPL core on our own servers and serving the resulting pages does not, by itself, oblige us to open-source our platform. The MIT content types and editor are unrestricted either way. So a hosted integration is licence-viable today.
> 2. *Distributed builds (on-prem installers, a downloadable plugin, white-label copies handed to schools to run):* distributing a combined work that includes the GPL core triggers copyleft on the derivative work as distributed. Any future on-prem/distributed edition of the ERP must either keep the H5P core out, isolate it as a separate service, or take a legal review first.
> 3. *The clean isolation route exists:* consume H5P over **LTI** from a separate H5P host (self-hosted or H5P.com). The GPL code then lives in its own service/process and never merges with our codebases at all — the same arm's-length pattern as any external tool. This is the licence-safest route and, as §4 shows, also a reasonable engineering route.
> 4. This study copies **no H5P code, text or assets** into any Rektrs/IQRS tree; everything below is paraphrased in our own words, the same discipline as the Gibbon and Moodle studies.

**Our two systems, as mapped for comparison (same framing as the Moodle study):**
- **Rektrs ERP** = `rektrs-school-erp-lms` per `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md`. Its LMS line is **PARTIAL** (quiz attempts, assignment submission/grading, SCORM quarantine, **xAPI/LTI ingestion already in source**; no standalone question bank; quiz scoring behind adapters). **Rewards & Gamification is one of the audit's four MISSING modules** (row 24: "points ledger, badge definitions, leaderboards — entire module").
- **IQRS** = the live Smart School system after the PreSkool overhaul. Its LMS is the **Online Course add-on** (KEEP-OURS), installed but **config-hidden/dormant**. The wider system has a Question Bank + Online Examination, school-level **rewards/badges (FC-1)** and a custom report builder (FC-13) — none wired into the LMS. It has **no xAPI store and no LTI** anywhere.

---

## 1. What H5P is, in one paragraph

H5P is not an LMS and not a course system. It is a **content format plus an authoring-and-playback framework**: teachers build small, self-contained interactive objects — a video that pauses to ask questions, a branching dilemma, a drag-and-drop exercise — in a browser editor, and those objects are packaged as portable `.h5p` files that any H5P-enabled platform can play, track and reuse. Where Moodle's centre of gravity is the course and Gibbon's is the school, H5P's is the **single reusable learning object**. It deliberately knows nothing about enrolments, gradebooks, points or badges; it emits results (as xAPI statements) and leaves everything else to the host platform. That narrowness is exactly why it composes with both of our systems instead of competing with them — and also why, as §3 shows, it only fills half of the gamification gap.

## 2. The content-type universe (our own words)

H5P ships **50+ content types**, each a small library with its own editor form and player. Grouped by what they do for a school:

**Composite / container types** — the ones whole lessons are built from:
- **Interactive Video** — a video (uploaded or YouTube) with interactions laid on its timeline: questions that pause playback, labels, links, images, tables, bookmarks and a closing summary task. The flagship type.
- **Branching Scenario** — a decision tree of videos/images/text where each choice routes the learner down a different path, with per-path scoring and end screens; the tool for dilemmas, safety procedures, "what would you do" lessons.
- **Course Presentation** — interactive slide decks: text, media and embedded questions on slides, with active-surface navigation.
- **Interactive Book** — chapters of mixed H5P content bound into one book with a summary/assessment page.
- **Column** — a layout container stacking several content types into one activity.

**Question and practice types** — the drill layer:
- **Question Set (Quiz)** — a sequenced set of questions with intro/end screens and an overall score.
- **Multiple Choice, Single Choice Set, True/False** — the objective staples, with per-answer feedback.
- **Fill in the Blanks, Drag the Words, Mark the Words** — text-manipulation practice (vocabulary, grammar, cloze).
- **Drag and Drop** — objects dragged onto image zones (labelling diagrams, sorting, matching).
- **Dictation** — audio played for the learner to transcribe, auto-checked word by word.
- **Essay** — free-text answers with keyword-based instant feedback (explicitly a practice aid, not a marker).
- **Summary** — learners pick the correct statements from groups, building a summary of the topic.
- **Arithmetic Quiz** — timed, generated arithmetic drills.
- **Speak the Words** — speech-recognition answers (browser-dependent).

**Games and playful types:**
- **Memory Game** — card-matching with images/audio/text.
- **Find the Hotspot / Find Multiple Hotspots, Image Hotspots** — click-the-right-place tasks on images (anatomy, maps, lab safety).
- **Image Sequencing, Sort the Paragraphs** — ordering tasks.
- **Virtual Tour (360)** — 360° scenes with hotspots and embedded content.
- **Flashcards / Dialog Cards** — flip-card memorisation decks with audio and images.

**Presentation and study aids:** Accordion, Timeline, Chart, Collage, Image Slider, Agamotto (image progression), Audio and Audio Recorder, Documentation Tool (structured form wizard with export), Questionnaire, Personality Quiz, KewAr Code (QR codes), and an Iframe Embedder.

Two properties matter more than any single type. First, **types nest**: an Interactive Book can hold Interactive Videos that hold questions; a Branching Scenario can embed Course Presentations. Second, **the catalogue is extensible and community-fed** — new types arrive as installable libraries, and a platform's available list is simply the set of libraries it has installed and keeps updated.

## 3. The authoring model and the `.h5p` package

**Authoring is entirely in-browser and form-based.** The platform embeds the H5P editor; the teacher picks a content type and fills in a structured form generated from that type's declared semantics (fields for questions, answers, feedback, media, behaviour settings like retry and pass percentage). No code, no HTML. Editors see a live preview, can set display options (download/embed/copyright buttons, frame), and can attach licence metadata to the content itself (the editor offers CC variants, public domain, and other content licences per item).

**The package format is the portability story.** A `.h5p` file is a zip archive containing a manifest (`h5p.json` declaring the main library, its version, and every dependency library with versions), the content's own data and media, and — on export — the library code needed to run it. Consequences:

- **Reuse inside a platform:** content is stored once and referenced wherever it is placed; in Moodle it lives in a content bank and is reused across courses. Editing updates the object, not a copy.
- **Reuse across platforms:** download a `.h5p` from any H5P site, upload it into any other H5P-enabled platform (Moodle, WordPress, Drupal, Lumi, H5P.com), and it plays — dependencies are resolved against the target's installed libraries, which the target can auto-fetch on first use.
- **Sharing:** h5p.org and institutional hubs (eCampusOntario's H5P Studio, LibreTexts) exist largely as libraries of downloadable `.h5p` objects teachers take away under the content licences above. A school buying or finding content elsewhere is never locked to the tool that made it.

**Embedding routes, in increasing order of integration:**
1. **Native plugin** — the platform implements H5P's framework interface and hosts everything itself: authoring, storage, playback, basic results. This is what the official WordPress, Drupal and Moodle integrations are (Moodle carries H5P in core, with its content bank). Deepest integration, most engineering.
2. **LTI** — an external H5P host (the commercial H5P.com service, or a self-hosted H5P server such as Lumi's) acts as an LTI tool provider (1.1 and 1.3/Advantage). The LMS launches learners into the content with identity and context, and scores return to the LMS gradebook through the LTI Assignment and Grade Services. The host platform needs only LTI-consumer capability.
3. **Embed (iframe)** — any H5P-hosted object offers an embed code; pasted into a page or lesson it plays anywhere. H5P's own results documentation is blunt about the trade: **if you are just embedding, you cannot store learners' results** — no identity, no tracking, no score. Embed is a display route only.

## 4. The results pipeline — what actually reaches the host

H5P reports on two levels, and the distinction decides what our systems must build:

**Basic results (built into the native plugins).** Per user, per content item: start/stop times, the score achieved and the maximum score. Moodle routes these into its gradebook through its Gradebook API; WordPress/Drupal show them in the plugin's own results views. This level answers "did Ayesha do the fractions video quiz, and what did she get?" — nothing finer.

**Detailed results (xAPI, the real pipeline).** Most content types emit **xAPI statements** as the learner works, exposed in the browser through H5P's JavaScript event dispatcher; the *host platform* is responsible for capturing them and forwarding them to a Learning Record Store (LRS) — H5P ships no LRS of its own. The granularity is genuinely fine:

- an **attempted** statement when a task is begun;
- **answered** statements per question, carrying **the actual response the learner gave** (which option, which words, which placement), the raw score for that question, and success;
- **completed / passed / failed** statements per sub-task and for the whole content, with scaled and raw scores, duration and completion;
- interaction-level statements for navigation and media events in richer types (page changes in Interactive Book, choices in Branching Scenario, and similar).

So a host that captures xAPI can reconstruct, per learner: every answer to every question inside every H5P object, time spent, and the path taken through branching content. A host that only takes basic results gets one number per object. **The pipeline is opt-in engineering on the host side** — the statements are generated regardless; whether they land anywhere is the platform's choice.

**One hard technical boundary, from H5P's own xAPI documentation:** statements are available to JavaScript **on the same site that hosts the content**. Cross-site embeds cannot be listened to from the embedding page. Tracking therefore requires either native hosting or LTI (where the host service reports back through the LTI grade service / its own integrations) — never a bare iframe plus a script on our page.

## 5. ⭐ Question 1 — The Rewards & Gamification connection: which half H5P fills

The gap, exactly as our own audit states it (ERP audit row 24, status **MISSING**): *"Entire module: points ledger, badge definitions, leaderboards."* The Gibbon study separately flagged badges; the Moodle study (row 17) flagged "badges with automated criteria + Open Badges portability" as worth adopting on the ERP side. A gamification system has two halves, and they must not be conflated:

**Half A — the engagement supply side: game-like things to do, and score events coming out of them.** Content that feels like play (timed arithmetic races, memory games, drag-and-drop challenges, branching dilemmas), each producing trustworthy-to-a-point scores and completion signals that other systems can react to.

**Half B — the economy: the system-level machinery that turns activity into standing.** A points currency with a ledger (earn/spend/balance, per student, across all activities and subjects), badge definitions and issuance rules, levels, streaks, class/school leaderboards, reward redemption, teacher controls, parent-visible recognition, and the audit trail that makes points mean something.

**The mapping, precisely:**

| Gamification-gap component (audit row 24 + Moodle row 17) | Filled by H5P? | Why |
| --- | --- | --- |
| Game-like learning content (games, challenges, playful practice) | ✅ **Yes — this is H5P's core** | Memory Game, Arithmetic Quiz, Drag and Drop, Find the Hotspot, Branching Scenario, Question Sets, etc. (§2) |
| Per-activity scores and completion signals usable as *triggers* | ✅ **Yes** | Basic results per object; xAPI `answered/completed/passed` statements with scores (§4) — a clean event feed |
| Points ledger (a currency students accumulate across activities/subjects) | ❌ **No** | H5P has no points store, no balances, no cross-content totals. A score lives and dies inside its content item |
| Badge definitions, criteria and issuance | ❌ **No** | H5P defines no badges, awards nothing, keeps no award record. (Moodle awards badges *using* H5P completion as a criterion — the badge engine is Moodle's, not H5P's) |
| Leaderboards (class/school rankings) | ❌ **No** | Nothing in H5P ranks learners against each other; results are per-user/per-content only |
| Levels, streaks, reward redemption, teacher economy controls | ❌ **No** | No such constructs exist in the framework |
| Open Badges portability | ❌ **No** | Belongs to whichever badge engine the platform builds (flagged in the Moodle study as ours to build) |

**Verdict on Question 1:** H5P fills **Half A completely and Half B not at all**. Adopting H5P does **not** close the Rewards & Gamification gap in the audit's terms — the points ledger, badge definitions and leaderboards still have to be built as a module (ERP audit block A already scopes exactly that build). What H5P changes is the module's *input quality*: instead of a badge engine fed only by exam totals and attendance, it can be fed by a rich stream of per-question, per-activity xAPI events ("completed the fractions Interactive Video at ≥80%", "finished the lab-safety Branching Scenario on the first path"), which makes criteria like Moodle's automated badge criteria practical. In short: **H5P is the gamification engine's best content supplier, not the engine.** On the IQRS side the position is even clearer — FC-1 already built school-level rewards/badges there; H5P would add game-like *course* content and event feeds to an economy that exists, which is a wiring job, not a module build.

## 6. ⭐ Question 2 — Pairing with the LMS: integration effort per system

The Moodle study's H5P finding (its row 3, flagged ⭐ for both systems) was: *"H5P interactive content authored in a content bank, xAPI-reported — LACK; what it takes: mostly integration and surface work (player + content storage); the content-bank model is small"* — and its §4 item 7 repeated that the work rides the xAPI plumbing the ERP already ingests. This study confirms that reading and prices it per system:

### Rektrs ERP (Laravel 13 platform; LMS PARTIAL; xAPI/LTI ingestion in source)

| Route | What it involves | Effort | Licence exposure |
| --- | --- | --- | --- |
| **LTI (recommended first)** | Stand up a separate H5P host service (self-hosted H5P server, e.g. a Lumi-based or Moodle-based host, operated as our own infrastructure); complete the ERP's LTI-consumer side (launch, deep linking for content selection); map LTI grade-service returns into the LMS gradebook; surface a content picker in course authoring | **Medium — ~2–4 weeks of lane work**, mostly LTI-consumer completion + grade mapping + authoring surfaces; the xAPI/statement side is optional extra | **None in our codebase** — GPL stays inside the separate host service |
| **Native** | Implement H5P's framework interface in the Laravel app (package validation/storage, library registry and updates, editor embedding, playback, results capture into the existing xAPI ingestion); build the content-bank surfaces | **Large — ~4–6+ weeks**, plus a permanent library-update maintenance tail | GPL-3.0 core inside our process: acceptable for hosted SaaS (see licence note), a blocker to review before any distributed edition |
| **Embed-only** | Allow iframe embeds of externally hosted objects in lessons | **Days** | None — but **no results at all** (§4); display only |

Where the results land on the ERP: basic results → the LMS gradebook as activity scores (via LTI grade service on the LTI route, or directly on the native route). Detailed results → the ERP's **existing xAPI ingestion**, stored as statements keyed to learner/content; a small mapping rule (top-level `completed/passed` statements only, sub-content statements filtered) turns them into completion state for courses — which is also the trigger layer the Moodle study's completion/badges items need. Nothing in the ERP's data model has to change shape to receive this; the ingestion and the LMS attempt machinery already exist in source.

### IQRS (Smart School + dormant Online Course add-on; no xAPI, no LTI)

Precondition for every route: the Online Course add-on is **config-hidden** — any H5P work inside courses waits on the add-on's activation decision, which is the school's/owner's, not this study's.

| Route | What it involves | Effort |
| --- | --- | --- |
| **Embed-only** | Permit H5P iframe embeds in add-on lessons (from any H5P host the school uses) | **Small — days**, once the add-on is active; zero tracking, zero scores |
| **LTI** | Build an LTI-consumer into the add-on (it has none), plus grade return into course exams/reports | **Medium-large — ~3–5 weeks**, inside a dormant add-on; buys tracked scores without touching H5P code |
| **Native** | Implement the H5P framework interface inside the CodeIgniter add-on (storage, editor, library management, results tables) | **Large — 5+ weeks** and a maintenance tail on a legacy base; not recommended while the add-on itself is dormant |

Where results would land on IQRS: there is **no xAPI store to land in** — basic scores would need a small custom results table in the add-on (per user/per content: score, max, times), and detailed xAPI capture would be a new build, not a configuration. The honest IQRS sequencing is embed-only for content richness now (post-activation), LTI later if tracked H5P scores inside courses ever become a real requirement.

**Cross-system note:** one shared H5P host service (LTI route) can serve **both** systems — the ERP as first consumer, IQRS later — and one shared library of `.h5p` objects then works in both schools' courses unchanged. That is the strongest structural argument for the LTI route: the content investment is made once, in the portable format, and outlives either platform's LMS decisions.

## 7. ⭐ Question 3 — The advisory-grades caveat, stated plainly

Verified from H5P's own **Security model** documentation (h5p.org), which says, in the project's own words: *"The user's answer is evaluated client side. This means that the correct answer also exists client side and it is easy for users familiar to web development to cheat on tasks in H5P. The evaluation of answers will be moved server side in future versions to avoid this."* That future version has not arrived; evaluation is still client-side today. Unpacked:

- **Answers ship to the browser.** A question's correct answers are part of the content data delivered to the learner's device. Anyone who opens developer tools — or simply disconnects, reads the feedback offline, and reconnects — can extract them. No server ever checks the work.
- **Scores are computed on the learner's machine** and reported from there. The xAPI statements in §4 are generated client-side too; a determined learner can fabricate a perfect-score statement as easily as read an answer. Hosts can sanity-filter statements, but cannot make them proof.
- **There is no assessment-integrity machinery at all**: no proctoring, no identity assurance beyond the host's login, no lockdown, no attempt forensics of exam grade.

**The line, therefore:** H5P quizzes are **formative instruments** — practice, self-checks, engagement, homework reinforcement, low-stakes drills whose scores are *advisory signals* to teachers ("the class found question 3 hard") and *triggers* for completion, badges and points at small stakes. They must never carry summative weight: no term grades, no promotion decisions, no board-pattern results. Real assessment — server-side answer custody, attempt management, integrity controls — is the territory of a proper exam engine (the TAO study's subject in this batch; and, in our own houses, the ERP's examinations module and IQRS's Online Examination, both of which keep answers server-side). Blurring this line is the single most common H5P deployment mistake; this study's recommendation is to write the rule into whichever system adopts H5P: **H5P scores may inform, never certify.**

## 8. Verdict

| System | Verdict | Route & effort | Conditions |
| --- | --- | --- | --- |
| **Rektrs ERP** | **GO** | LTI-first from a shared self-hosted H5P service (**~2–4 weeks**), results into the LMS gradebook + existing xAPI ingestion; native integration deferred and re-examined only if LTI proves limiting | Gamification module (audit block A) is **not** descoped by this — H5P feeds it, per §5. H5P scores wired as formative/advisory only, per §7 |
| **IQRS (Smart School)** | **WATCHLIST** | Embed-only (**days**) if and when the Online Course add-on is activated; LTI (**~3–5 weeks**) only on a demonstrated need for tracked in-course scores | Gated on the add-on activation decision; native integration on the legacy base is a NO-GO in this study's judgement |
| **As the gamification fix** | **NO-GO** | — | H5P fills the content/engagement half of the Rewards & Gamification gap and none of the economy half (§5). Anyone selling it as closing audit row 24 is miscounting |

**Bottom line:** H5P is the cheapest credible way to give both systems a real interactive-content layer — 50+ mature content types, a teacher-friendly browser editor, a portable package format, and an xAPI results feed that the ERP is already built to receive. Adopt it for what it is (content + events), build what it is not (the points/badges economy), and never let its scores pretend to be examinations.

## 9. Sources

H5P's public material as read 2026-11-28: h5p.org licensing page; the `h5p/h5p-php-library` repository (licence file, README — GPL-3.0 and its stated reason); the `h5p/h5p-editor-php-library` repository (README — MIT); GitHub's h5p organisation listing (per-repo licence detection: content types MIT, php-library GPL-3.0); h5p.org developer documentation on xAPI (event dispatcher, statement coverage, same-site limitation) and on analysing results (basic vs detailed results, the embed limitation, LRS model); h5p.org's Security model page (client-side evaluation statement, quoted in §7); H5P.com help material on LTI 1.1/1.3 setup and grade sync; university H5P guides (TU Delft, Alberta, Melbourne, LSU) for the content-type catalogue. Our side: `REKTRS-SCHOOL-ERP-GAP-AUDIT-2026-11-23.md` (esp. row 24 and §4 block A), `MOODLE-FEATURE-STUDY-2026-11-28.md` (esp. rows 3 and 17, §4 item 7), `GIBBON-FEATURE-STUDY-2026-11-28.md` — all in this goal's files/. All H5P descriptions above are paraphrased in our own words; the single verbatim quote in §7 is H5P's own security warning, reproduced because its exact wording is the evidence.
