# PreSkool PIXEL-PERFECT + FULL-FEATURE Plan — D-038 (owner directive)

**Directive (Assad, 2026-11-12 ~16:52 PKT, in the PreSkool status side chat):**
1. Design must be **pixel-by-pixel hu-ba-hu** PreSkool — not "PreSkool-inspired", not component-level approximation.
2. Features must be **more than PreSkool — all of them**: the finished IQRS system is a superset. Every PreSkool feature, every existing IQRS feature, and every approved new feature, working on real data.

This directive **supersedes D-024's consolidation model** (tabbed workspaces as the final anatomy, optimize-and-improve arrangement). D-024's quality bar (features optimized, not merely re-skinned) survives *inside* each hu-ba-hu page. Everything else standing remains in force unless this plan names it: staging-only (D-027), IQRS rules govern conflicts (D-003), demo data never imported, CLAIM-class demo content never faked, licence gate D-008 before production, D-037 security sequencing (BL-141/BL-142 first) not displaced.

Status: **PLAN — prepared at owner order, awaiting his go to execute.** No build lane is dispatched by this document alone.

**Owner evidence (2026-11-12 ~16:50 PKT, filed with this plan):** Assad supplied side-by-side full-page captures — (a) the current staging Admin Dashboard (`admin/admin/dashboard`, 16:50 capture) and (b) the PreSkool preview Admin Dashboard (16:50 capture) — with the ruling: *"jesy yeah, IQRS ka dashboard ganda sa hy; yeah same PreSkool wala hona chahiye pixel-by-pixel hu-ba-hu — esy he her page."* The Admin Dashboard is therefore the **flagship proof screen of PF-2**: it is the first screen retrofitted and the first to face the screenshot-diff gate, and its verdict pattern sets the standard every other page is then held to.

What the owner's own captures show (the gap in one screen):
- **PreSkool dashboard:** greeting banner with action buttons (New Admission / Collect Fees / Report) + KPI strip (Today's Attendance 94.8%, New Admissions, Fees Today, Upcoming Exams); Best Teacher and Top Student cards; Class-Wise Distribution; Performance Risk Matrix; Student Attendance Heatmap; Weekly Communication Trend chart; Parent Engagement donut; Activity Timeline; Recent Parent Messages; Delivery Success; Enrollment & Growth Trend; Gender Distribution; library, fuel and fleet widget stack — dense, chart-led, every card carrying a visual summary.
- **Current IQRS dashboard:** three plain status cards, a text "Waiting for you" list, and text-only module cards (Students / Academics / Fees / HR / Library / Transport / Communication / Reports / Settings) — honest real data, but no charts, no heatmap, no donuts, no widget stack; visually sparse ("ganda sa" in the owner's words). The data is ahead of the design: the counts are live and governed, the presentation is not yet PreSkool's.
- Note on method: full-page capture tools repeat fixed sidebars when stitching — the duplicated menu blocks in capture (a) are a capture artefact to exclude from the diff gate; PF-0 reference captures are taken at fixed viewports for exactly this reason.

---

## 1. What "pixel-by-pixel" means — the measurable definition

A screen is **PIXEL-MATCH** only when all five layers pass on the reference capture set (§3):

| Layer | Standard |
|---|---|
| L1 Tokens | Colours, Inter type scale, radii, shadows, spacing = the demo's values, consumed **only** via the 269-var token layer. Zero hard-coded hex / inline styles in views. |
| L2 Geometry | Header, sidebar, cards, tables, forms, modals sit at the same positions and sizes as the demo page at the reference viewports (1440×900 desktop primary; 1024 and 390 checked). Measured, not eyeballed. |
| L3 Components | Same component inventory per page as the demo page: same cards, charts (ApexCharts, D-028), pills, avatars, icon chips, empty-state illustrations, in the same order. Icon set = the demo's own set on matched pages (this overrides the D-030 Phosphor direction **for pixel-matched web surfaces only**; recorded here as an explicit consequence). |
| L4 States | Default, hover, active, empty, loading, error, dark mode — each state exists and matches the demo's treatment of that state. |
| L5 Content slots | Real IQRS data fills the demo's slots. School name/logo replace demo branding (the only intended content difference). Data-length differences are absorbed by the demo's own truncation/wrap behaviour, never by redesigning the slot. |

**What pixel-by-pixel does NOT mean:** demo data, demo names/photos, invented ratings or risk scores, fake calling/AI, or screenshots staged for the gate. A widget whose demo content is CLAIM-class renders recorded IQRS data in the same anatomy, or an honest empty/configure state in the same anatomy — the *anatomy* is pixel-matched, the *claims* are never manufactured.

**Deviations:** where an approved IQRS rule or a real workflow genuinely cannot fit the demo anatomy (e.g. governed fee allocation, print issuance), the deviation is logged as a numbered **EXEMPT** entry with the rule cited and the closest-possible anatomy used. Silent drift — the current P1–P6 pattern — is a gate failure, not a style choice.

## 2. Feature scope — the superset register

The completion target is the **union**, deduplicated, held in one register:

- **PreSkool parity set:** FP-001–FP-100 (55 in both systems, 30 theme-only, 10 IQRS-only, 5 duplicates) — every row built; theme-only rows are real builds on the IQRS data model, not shells.
- **Widget-level deep-audit additions:** the v2/v3 lists (161 → 180) that caught what page-level parity missed (dashboard Top Teacher/Top Student type widgets and their implied systems).
- **Feature list v5 (D-037): 236 features, FP-213–FP-241 dispositioned** — Round 2 + Round 3 new features and integrations are in scope, not a later phase's promise.
- **IQRS-native capabilities with no demo twin** (household/family finance, Print Studio issuance, governed workflows, fee position truth) — kept at full strength; their pages are designed to the demo's anatomy rules and gated against a written pixel spec (§4, PF-6) since no reference screenshot exists.
- **Documented blockers stay honest, on record, not silently dropped:** SaaS/tenant pages = Phase S; fee wallet stays retired (D-F2) while the cafeteria wallet is built (D-015); server-ops controls that shared hosting cannot enforce stay read-only/request-form; calling/video surfaces go real only when a provider is configured, otherwise honest not-configured in matched anatomy. Each carries its blocker reason in the register — "sary features" means *no silent omissions*, it does not repeal physics, hosting limits, or the owner's own money rules.

**PF-0 output is feature list v6:** v5's 236 reconciled line-by-line against the 386-page demo census and the widget register, so any demo item not already in v5 enters v6 with a disposition before build waves start.

## 3. Measurement system — how a screen earns PIXEL-MATCH

1. **Reference pack (PF-0):** for every in-scope demo page — screenshot captures of the package source / live demo at the reference viewports, light + dark, key states; stored beside the L2 lane's evidence. The demo is frozen as the reference; later demo changes do not move the target.
2. **Fixture staging captures:** the same screens on staging, driven with the standing fixture family (known students/staff/amounts), same viewports, cache-busters fresh (`?v=` bumped — BL-012 cache trap), screen media (never print renders).
3. **Screenshot-diff gate:** automated pixel-diff per screen with a published threshold (target ≤1% differing pixels on fixture captures, and **zero** geometry tolerance on shell/header/sidebar/card-grid anchors). Diff heatmaps are filed per screen; a human Inspector signs the anatomy checklist (L1–L5) beside the diff — automation catches drift, the checklist catches wrong-but-similar.
4. **Per-screen verdicts** replace the old MATCH/DRIFT/MISSING vocabulary for pixel work: **PIXEL-MATCH / DRIFT (with delta list) / EXEMPT (numbered) / NOT-BUILT.** The scoreboard is republished at every wave close.
5. **Token lint gate:** no wave closes with hex/inline-style counts above zero in its views, or with a forked shell CSS. This kills drift patterns P1/P2/P6 at the gate instead of auditing them afterwards.

## 4. Waves

| Wave | Scope | Exit gate |
|---|---|---|
| **PF-0 — Baseline** | Reference pack for all in-scope demo pages; feature list v6 (superset register); per-screen target map (demo page ↔ IQRS route, incl. where a consolidated tab must become / map onto its own demo page anatomy); EXEMPT register opened | Owner sees: counts, target map, first EXEMPT candidates |
| **PF-1 — Foundation** | BL-150 token sweep pulled forward and hardened: one shared shell CSS (forks merged), zero-hex views across built surfaces, demo icon set on matched surfaces, chart/empty/loading component kit completed to demo spec | Lint gate green on all built surfaces; shell PIXEL-MATCH |
| **PF-2 — Auth + Dashboards** | Login/forgot to full split-panel anatomy incl. the demo notice panel (real notices); admin/teacher dashboards rebuilt to the demo widget stack over recorded data | PIXEL-MATCH on auth + both dashboards, light + dark |
| **PF-3 — Portal** | Parent/student dashboards rebuilt to the demo portal anatomy (fees-due cards, attendance rings, homework lists) over real family data — closes the single biggest D-024-era gap | PIXEL-MATCH for both portal roles |
| **PF-4 — Workspace retrofit I** | pkfees (already MATCH — polish to PIXEL-MATCH), pkstudents (add grid view, profile/ID components), pkacademics (chart-led analytics) | PIXEL-MATCH per screen, diffs filed |
| **PF-5 — Workspace retrofit II** | pkattendance (heatmap/calendar anatomy), pkexams (chart-led results), pkhr (token-clean rebuild of views; leave IA aligned to demo) | PIXEL-MATCH per screen |
| **PF-6 — IQRS-native pixel specs** | Print Center, household/family, governed-workflow pages: written pixel specs derived from demo anatomy rules, built and gated against them | Spec + PIXEL-MATCH verdict per native screen |
| **PF-7 — All remaining features, pixel-first** | BL-045 Operations, BL-046 Front Office, BL-047 Communication + portal remainder, BL-048 Reports/Settings, BL-049 new modules, BL-050 deterministic AI, D-015 scoped features, Identity (BL-096–098/+152), BL-082/115/133, chatbot BL-137, cafeteria + gate chain — **in D-037's security order** (BL-141/142 hardening first, identity before its dependents). No surface in this wave may close on the old standard: every screen ships with its reference capture and diff from day one | Per-screen PIXEL-MATCH + feature battery (real data, R-5 and all standing rules) |
| **PF-8 — Full census + cutover** | Every screen in v6 re-captured and re-diffed; scoreboard final; only then the D-027 single gated production package (D-008 licence position recorded first), Phase 5/6 gates as sequenced in D-037 | Owner sign-off on the final scoreboard |

**Sequencing honesty:** PF-1→PF-6 retrofit work runs alongside — never ahead of — D-037's security head (BL-141 fee-write hardening, BL-142 ungated doors + CSRF). Pixel work does not delay safety work; safety work does not ship new un-pixelled surfaces.

## 5. What changes for the team

- The L2 comparison becomes a **standing gate**, not a Round-3 artefact: every wave close republishes the scoreboard.
- Consolidated tabs stop being final anatomy: where the demo has a page, the target map (PF-0) decides page-for-page; tabs may remain as *navigation* only where the rendered page still matches its demo page pixel-for-pixel.
- **ADDENDUM — D-039 (owner, main chat, 2026-11-12 ~17:06 PKT): "Jesy PreSkool main hy wesy kro."** OQ-2 is settled: **pages, not tabs** — wherever PreSkool gives a function its own page, IQRS gets its own page; tabbed workspaces are interim staging shapes until their PF wave rebuilds them as pages (this tightens the bullet above: tab-as-navigation survives only if the CEO ratifies it per workspace under D-039's default). The EXEMPT register is re-judged under the same default — exemption only where a decided IQRS rule (D-004 and the red lines included) or a hard hosting limit forces it, with the forcing rule/limit named in the entry; survivors go to CEO ratification, none self-approved. Decided rules still win collisions, and the collision is what the EXEMPT entry records.
- Inspectors gain the diff heatmap + anatomy checklist as their acceptance instrument; "looks close" is no longer an acceptance phrase anywhere in the programme.
- Effort truth: this is materially larger than the D-024 plan — the retrofit waves PF-2–PF-5 re-open surfaces that were closed as "complete", and PF-7 raises the per-screen cost of every remaining wave. No date is promised in this plan; the PF-0 baseline produces the first honest size count (screens × delta class), and estimates follow from it.

## 6. Decisions this plan records / needs

- **Recorded (owner, this chat, 2026-11-12):** pixel-by-pixel hu-ba-hu design standard; feature superset standard. Proposed log name: **D-038**, superseding D-024's consolidation model, for entry into `decision-log.md` by the programme lane.
- **Consequence flagged:** demo icon set on pixel-matched surfaces vs D-030's Phosphor adoption — this plan follows the pixel directive (demo set wins on matched pages); desktop app (D-013) is out of this plan's scope and keeps its own token work until the owner says otherwise.
- **Unchanged and binding:** D-003 (IQRS rules win), D-008 (licence before production), D-027 (staging-only until the one gated cutover), D-037 (security sequencing + SRL-1…8).
- **ADDENDUM — D-043 (owner, main chat, 2026-11-12 ~17:27 PKT): "colours, elements, images sab PreSkool say ly lena pixel by pixel sab kuch."** The D-038/039/041 series is now one standing rule: colours, UI elements, **images / illustrations / empty-state art**, icons, typography, fonts — everything from PreSkool. Where a PreSkool asset exists, recreating it in our own style or substituting a lookalike is prohibited; the PF-1 component kit consumes the package's own assets (inventoried per asset in the lane record). Two carve-outs: (1) school identity (name, logo, motto) stays IQRS's — identity, not design; (2) imagery that does not exist in PreSkool (IQRS-native surfaces) is created in PreSkool's visual language and recorded under NATIVE-SPEC/EXEMPT.
