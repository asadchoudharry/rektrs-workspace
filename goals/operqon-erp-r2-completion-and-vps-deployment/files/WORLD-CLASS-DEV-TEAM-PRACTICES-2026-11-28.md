# World-Class Dev-Team Practices — Trained Into the Operqon Workflow

**Date:** 2026-11-28 · **Trigger:** owner order ~16:30 PKT — "dunia main developer
teams kesy kerti hain wo learnings seekho or khud KO training do" (learn how the
world's developer teams work, and train yourself on it).
**Scope of the mapping:** our real setup is not a 200-engineer org. It is one
build loop (Muse) + one Cursor loop on the provider side + one owner who is
the final visual gate. Every practice below is judged against that reality and
against our own failure history (AGENTS.md lessons, TRAINING-LOG debriefs,
LOOP-STATE). An adopted rule names the failure it prevents; anything that does
not fit is marked NOT ADOPTED with the reason, not quietly dropped.

---

## 1. Measure delivery with the DORA four keys — read in pairs

- **What top teams do:** DORA (Forsgren, Humble, Kim — *Accelerate*, 2018; DORA
  research program) measures software delivery with four keys: **deployment
  frequency** and **change lead time** (tempo) against **change failure rate**
  and **time to restore service** (stability). The metrics only tell the truth
  read together — speed next to stability, never one number alone. Elite
  performers deploy on demand with lead time under a day, change-fail ~5%,
  recovery under an hour.
- **Our state honestly:** we never measure any of the four. LOOP-STATE records
  deploys and failures narratively (48 consecutive clean health runs, gate
  numbers, deploy records), but nobody can answer "what is our change failure
  rate this month?" from the record. Worse, we twice claimed a collaborator
  loop was "working" from merges alone — a tempo signal with no stability or
  liveness check behind it.
- **Gap:** no lightweight, recurring self-measurement; progress claims rest on
  narrative, not counts.
- **RULE ADOPTED (R13):** once a month the loop writes a DORA-lite line into
  LOOP-STATE from its own records: deploys shipped, change-fails (deploys or
  acceptances that failed / were rolled back), recovery time for each
  production incident, and lane lead time (lane start → live). The four are
  reported together. *Prevents:* "the loop is working" claims built on a single
  green signal — the Cursor-stall lesson (a PR merged ≠ the loop is running).

## 2. Small batches — one self-contained change at a time

- **What top teams do:** *Accelerate* identifies working in small batches as a
  core capability; Google's Engineering Practices ("Small CLs") make it a
  rule: a changelist is **one self-contained change** — ~100 lines is usually
  reasonable, 1000 is usually too large; small changes are reviewed faster and
  more thoroughly, introduce fewer bugs, and roll back cleanly. Refactorings
  are separated from feature work.
- **Our state honestly:** lanes are already scoped one-concern-per-lane, which
  is the batch discipline in embryo — but there is no size pressure and no
  lifetime pressure. Cursor's OS lanes sometimes bundle several surfaces into
  one PR; our own lane branches have lived for days while gates and deploys
  queued behind them.
- **Gap:** no explicit batch-size or branch-lifetime limit; a big lane delays
  every lane behind it and makes its own review shallow.
- **RULE ADOPTED (R1):** one lane = one self-contained change. A lane branch
  that cannot merge within **2 days** is split, not extended. Every PR
  description states **how the change was tested** and **how to roll it back**
  (the PR-template practice used for AI-written code — see §12). *Prevents:*
  the gate34/gate35 pattern where one large lane's flag or failure froze the
  whole queue behind it, and shallow review of bundled changes (the OS-89
  deploy had to catch 7 unlisted modules at install time because the change
  set was bigger than its manifest).

## 3. Trunk-based development — ADAPTED, not adopted whole

- **What top teams do:** trunk-based development (Paul Hammant,
  trunkbaseddevelopment.com; a named *Accelerate* capability): fewer than
  three active branches, branch lifetimes under a day, no code-lock periods,
  incomplete work hidden behind feature flags rather than branches.
- **Our state honestly:** we run a long-lived release branch
  (`release/operqon-provider-r2`) with two writers (this loop + Cursor) under
  a one-writer-at-a-time rule and a suite gate per PR. That is deliberately
  not trunk-based: the gate and the split ownership need the branch.
- **Gap vs the practice:** branch *lifetimes* on lane branches, not the
  release branch itself.
- **DECISION: NOT ADOPTED as a branching model** — collapsing to a single
  trunk would collide with the provider-suite gate, the Cursor/loop work
  split, and the one-writer rule on the VPS clone. **ADOPTED in adapted
  form:** the lifetime discipline of R1 (lane branches ≤ 2 days, deleted on
  merge) and the flag-over-branch instinct where Frappe/our stack supports it
  (the S5 entitlement observe→enforce switch is exactly a flag-gated release).
  *Prevents:* long-lived lane branches drifting from the tip until their gate
  compares against a stale baseline (see §5).

## 4. Code review culture — the reviewer is not the author

- **What top teams do:** at Google, review is a first-class, fast, thorough
  step: small CLs, reviewers with ownership of the area, review turnaround
  measured in hours, and the author never the sole judge of their own change.
  For AI-written code the documented practice (GitHub's guidance on reviewing
  AI-generated code; the Claude Code team's PR template) is: automated checks
  run **before** a human reads the diff, and the PR states how it was tested
  and how to undo it.
- **Our state honestly:** we already run an independent review — the OCR
  delegation review (a different model/context) plus semgrep/bandit/gitleaks
  on every lane. It has earned its keep: in Debrief #1212 it caught a blocking
  defect (a query against a non-existent `dt` field) **before** the PR. But
  the rule was habit, not charter, and the lane author still writes the tests
  that "prove" the lane.
- **Gap:** author-written tests can mirror the author's wrong assumption —
  in #1212 the test fake mirrored the invented schema, so the suite was green
  over a field that does not exist; only the independent review saw it.
- **RULE ADOPTED (R10):** the lane author is never the sole verifier. Merge
  requires (a) the independent OCR delegation review, (b) the security scan
  stack, and (c) governing-path acceptance (§5). Test doubles/fakes must be
  validated against the **live** schema/API before they are trusted as
  evidence. *Prevents:* the invented-schema fake of Debrief #1212, and the
  author-grades-own-homework failure class generally.

## 5. Test strategy — pyramid shape, and test the governing path

- **What top teams do:** the test pyramid (Mike Cohn, *Succeeding with
  Agile*, popularised by Martin Fowler): many fast unit tests, fewer
  integration tests, few end-to-end tests — Google's often-quoted first guess
  is 70/20/10. Fowler's operational rule: a failure found by a high-level
  test means a low-level test is missing — add it. Contract tests sit in the
  middle: the consumer's expectations are verified against the provider so
  the two sides cannot drift apart silently.
- **Our state honestly:** our provider suite is a real gate (~1,090 tests),
  but tenant-side coverage is thin, and our worst acceptance failures were
  **wrong-layer tests**: the Stock Balance fix was "proven" by a DocPerm
  `has_permission` check while the governing checks were
  `Report.is_permitted()` plus the `report` flag on the ref doctypes
  (Debrief #1221). Two fix rounds (oc70, oc71) each passed their server-side
  check and failed in the browser round.
- **Gap:** tests exist, but they do not always exercise the code path that
  actually governs the surface; and when a browser round finds a failure, no
  rule forces the missing backend test to be written.
- **RULES ADOPTED (R2, R3):**
  - **R2 — governing-path tests:** every fix ships a test at the lowest level
    that can see its failure class, executed AS the real user through the
    real path. A failure discovered in a browser/acceptance round is not
    closed until the backend test that would have caught it exists.
    *Prevents:* the Stock Balance two-round burn (oc70/oc71).
  - **R3 — the expected-failed baseline is a living artifact:** the suite
    gate diffs against the tip's **current** expected-failed set, re-derived
    by a pristine-tip run whenever the tip has moved — never against a frozen
    baseline file. (Formalises the standing gate35 decision: the frozen S1
    set went stale and gate37's count drifted 13 → 16 purely from tip
    movement.) *Prevents:* chasing phantom regressions — or waving through
    real ones — against a baseline from another era.
  - Contract checks without new tooling: the governed SPA↔API seams and the
    provider API response shapes the console/portal consume get shape
    assertions inside the existing suite (see §13 for why not Pact).

## 6. Testing in production — staged rollout is our canary

- **What top teams do:** progressive delivery decouples deploy from release:
  feature flags, canary slices (1% → 5% → 25% → 100%), metrics compared
  canary-vs-baseline, automated rollback when the slice is worse (Netflix
  canary practice; Google SRE Workbook: break metrics out by canary, because
  a 20% error rate on a 5% canary looks like 1% overall). SRE's rule for
  incidents: **roll back first, diagnose afterward** — it minimises recovery
  time.
- **Our state honestly:** we have no traffic-splitting infrastructure and
  three test tenants, not a fleet. But we already own the shape of a canary:
  `*.stage` sites exist beside the live tenants, and demo2 has repeatedly
  served as the first live proof. Rollback discipline is real — every deploy
  keeps the previous image (oc70 stayed runnable while oc71 shipped) and
  records a rollback point.
- **Gap:** the stage→demo2→all order is habit, not a written gate; a lane
  could still go fleet-wide on server-side checks alone.
- **RULE ADOPTED (R4):** tenant changes roll **stage site → demo2 → all
  tenants**, with the backend as-user acceptance (§5) executed at each step
  before advancing. The previous image stays runnable until the new image
  passes acceptance, and the deploy record names the rollback point **before**
  the deploy starts. On any production failure: restore first (previous
  image / backup), diagnose second. *Prevents:* fleet-wide breakage of the
  pairing-recreate class (a new backend IP 500'd **every** tenant site at
  once — with a staged rollout the grant failure would have detonated on one
  tenant, not all), and slow diagnosis-first recoveries.

## 7. Release engineering — immutable artifacts, generated manifests, env parity

- **What top teams do:** continuous delivery rests on version control for all
  production artifacts, automated deployment, immutable build artifacts (the
  artifact you tested is the artifact you ship), and environment parity —
  staging that differs from production proves nothing about production
  (Humble & Farley, *Continuous Delivery*; DORA capabilities list).
- **Our state honestly:** the strong half is real: tenant images are
  immutable and content-pinned (ocXX), the suite gate runs inside the actual
  `Dockerfile.test` image, deploys take hashed backups first. The weak half
  has bitten repeatedly: the repo **MANIFEST went stale against its own
  tree** (24 stale entries) and **missed 7 ui modules that the new app.mjs
  imports** — a manifest-exact install silently skipped them and the console
  would have failed to boot (caught pre-acceptance, 2026-11-28). Environment
  parity is imperfect by construction: the bench app is ahead of the repo
  app_pack (hence the standing rule to build images from the running bench
  copy, and the reconciliation lane in the production-ready criteria).
- **Gap:** the manifest is treated as a source of truth when it is actually a
  derived artifact that drifts.
- **RULES ADOPTED (R5, R6):**
  - **R5 — manifests are generated, never trusted:** any lane that changes
    the tree regenerates the MANIFEST from the tree in the same lane; after
    any manifest-based install, an import-resolution scan (0 missing) and a
    served-vs-tip diff are mandatory before acceptance. *Prevents:* the
    OS-89 near-miss (console unbootable from silently skipped modules).
  - **R6 — environment-issued config is verified by content, publicly:**
    preserve-list files (portal `customer/config.js`, console
    `auth/oidc-config.json`) are fetched publicly and content-verified after
    every sync — presence is not proof. *Prevents:* the two standing killers
    — the white portal page (config.js dropped by a sync) and the console
    login failure (oidc-config.json dropped, UI misleadingly showing an MFA
    message).

## 8. Error budgets — ADAPTED into a failure budget with a freeze rule

- **What top teams do:** Google SRE sets an SLO per service; the error budget
  is 1 − SLO. While budget remains, teams ship freely; when it is spent,
  launches freeze (except fixes for the errors themselves) until the budget
  recovers. The budget ends the speed-vs-reliability argument with data.
- **Our state honestly:** we have no SLOs and no production traffic to budget
  against — three test tenants cannot produce a meaningful availability
  percentage. But we have the problem error budgets solve: the same failure
  classes recur across lanes (worker scripts losing +x on $ROOT syncs — it
  bit again on 2026-11-28, weeks after the lesson was written; env files
  dropped by syncs; per-IP grant breakage on recreates).
- **DECISION: NOT ADOPTED in SRE form** — SLO/burn-rate machinery with no
  traffic is theatre. **ADAPTED (R7):** a **failure budget per surface**:
  two failures of the same class on the same surface freeze new feature
  lanes on that surface until a systemic fix lands (a check in the deploy
  path, not a note in a log). A lesson counts as *applied* only when the
  check exists where the next lane runs. *Prevents:* the +x trap biting
  twice — the lesson existed in AGENTS.md and the entitlement service still
  failed 203/EXEC on the next $ROOT sync, because nothing mechanical stood
  in the path.

## 9. Blameless postmortems — we have the log; now it needs teeth

- **What top teams do:** Google SRE postmortems are blameless by rule —
  assume everyone acted intelligently with the information they had; focus
  on process and system, produce action items with owners, share widely.
  *Accelerate* ties this to Westrum's generative culture: organisations that
  treat failure as learning outperform those that treat it as blame.
- **Our state honestly:** this is our strongest existing practice — the
  TRAINING-LOG debriefs are blameless, specific, and honest (Debrief #1221
  names our own three workflow errors with evidence; failed deploys are
  reported as failed). What is missing is the follow-through check: debriefs
  end with a "resume action", but nothing verifies the action item actually
  landed in the workflow.
- **Gap:** action items can evaporate between the log and the next lane.
- **RULE ADOPTED (R7, second half):** every production failure gets a debrief
  the **same day**, with timeline, systemic cause, and an action item that
  names where it will live (charter / AGENTS.md / skill / script). The next
  loop run on that surface verifies the item is present before proceeding —
  a debrief whose action item never landed is an open incident, not a closed
  one. *Prevents:* lessons that are recorded but not trained (the exact gap
  Debrief #1221 was written about).

## 10. Platform engineering — our lane protocol IS the golden path; treat it as a product

- **What top teams do:** Team Topologies (Skelton & Pais) defines the
  platform team as providing a compelling internal product — golden paths /
  paved roads — consumed X-as-a-Service, so stream-aligned teams shed
  extraneous cognitive load. The path must be the *easiest* route, or teams
  route around it. SRE adds the toil rule: manual, repetitive, automatable
  work is capped and engineered away.
- **Our state honestly:** the Operqon lane protocol + deploy skill is a
  golden path in everything but name, and it works when followed. Its
  failure mode is the opposite of a platform's: steps that recur manually
  (grant-fix after recreates, bundle-hash waits, +x restores) were re-derived
  per lane until they were finally written into the skill. The Cursor
  relationship is also a platform interface: GitHub (branches, PRs, signal
  comments) is the X-as-a-Service surface; the Cursor **panel** is not — and
  treating it as one produced the OS-80 soft-park (a file *path* sent instead
  of content) and three failed panel deliveries (Debriefs #1214/#1216/#1219).
- **Gap:** recurring manual steps are automated late; cross-agent delivery
  has no receipt discipline.
- **RULES ADOPTED (R8, R12):**
  - **R8 — delivery means receipt:** anything handed to another agent is
    delivered as **content** in the channel the receiver actually reads
    (a repo file the receiver can open + the PR signal comment), and receipt
    is confirmed from the receiver's visible action. A path is not a
    delivery; a send report is not a receipt. *Prevents:* the OS-80
    soft-park ("spec not on the VM") and the unsent-panel-message class —
    never again report a message as sent when only a fallback went out.
  - **R12 — toil becomes the path:** any manual step performed in two lanes
    becomes a script or a skill step during the second lane — never a third
    manual repetition. *Prevents:* per-lane re-derivation of grant-fix,
    bundle-wait, and mode-restore steps.

## 11. Decision records — ADR-lite, supersede don't edit

- **What top teams do:** architecture decision records (Michael Nygard,
  2011): one short record per significant decision — title, status, context,
  decision, consequences (including the negative ones) — kept with the code,
  immutable once accepted; a changed mind is a **new** record that supersedes
  the old one, so the debate never restarts from scratch and nobody reverses
  a decision blind.
- **Our state honestly:** LOOP-STATE already keeps a decision log with date +
  rationale (S5, AGPL-class, D10, GATE35-D1), and it has repeatedly stopped
  re-litigation. But entries rarely record the options considered or the
  accepted downside, and corrections (e.g. the 2026-11-27 false DNS incident
  retraction) are written as narrative, not as supersession.
- **Gap:** rationale survives; rejected options and consequences mostly
  don't — the exact parts a future lane needs when it is tempted to reverse
  the call.
- **RULE ADOPTED (R11):** any decision that is expensive to reverse gets a
  dated LOOP-STATE entry in ADR-lite form: context, options considered,
  decision, consequences accepted. Corrections supersede the earlier entry
  explicitly ("supersedes the 2026-11-27 ~21:47 entry") instead of quietly
  editing history. Settled decisions are not re-opened without new evidence.
  *Prevents:* blind reversal and re-litigation of settled calls, and the
  false-alarm class where a wrong record (the ".rektrs.com incident") could
  have driven owner DNS action.

## 12. AI-era delivery — AI is an amplifier; verification is the multiplier

- **What the research says:** DORA's *2025 State of AI-assisted Software
  Development* (~5,000 respondents): AI adoption now correlates with higher
  delivery **throughput** but still with **lower delivery stability**; 30% of
  respondents report little to no trust in AI-generated code; the report's
  central finding is that **AI is an amplifier** — it magnifies the strengths
  of high-performing organisations and the dysfunctions of struggling ones,
  and the returns come from the underlying system (platform quality, clear
  workflows, small batches, version control discipline), not the tool. The
  documented working practices: keep batches small, run automated checks
  before review, increase review rigor for AI code, and state how a change
  was tested and how to undo it.
- **Our state honestly:** this entire operation is AI-era delivery — one AI
  loop building, another AI (Cursor) building in parallel, a third context
  (OCR) reviewing. The amplifier finding describes us precisely: where our
  workflow is strong (gates, debriefs, deploy discipline) output compounds;
  where it is weak (wrong-layer tests, panel delivery, loop liveness) AI
  speed manufactures failures faster. Cursor's loop **does not
  self-sustain** — it ends its turn after a PR despite the acknowledged rule
  ("No blocker — I ended the turn after #173 instead of continuing").
- **Gap:** no liveness definition for delegated agents; verification rigor
  was habit, not rule (now R10).
- **RULE ADOPTED (R9):** an agent or loop is "running" only when its last
  **visible action** is inside the watch window. A merged PR, a "Done" panel,
  or a status label is not evidence of life. On silence past the window, the
  supervisor prods through the channel with receipt (R8) — it never reports
  the delegated work as progressing on faith. *Prevents:* hours lost to a
  "running" Cursor loop that had in fact stopped (the W3-7 death class:
  runtime status said running for hours after the agent died).

## 13. Practices deliberately NOT adopted

| Practice | Why not, at our scale |
|---|---|
| Pure trunk-based development (single trunk, no release branch) | Collides with the suite gate, the two-writer split, and the one-writer clone rule. Lifetime discipline adopted instead (§3). |
| Formal SLOs + burn-rate alerting | No production traffic to budget against (3 test tenants); adapted into the failure-budget freeze rule (§8). |
| %-canary infrastructure / flag platform (LaunchDarkly-class) | No traffic-splitting infra on a single VPS pairing; staged tenant rollout gives the same blast-radius control (§6). |
| On-call rotations / pager hygiene | No human on-call exists; the 30-min loop cron + 15-min PR watch are the detection loop. The *detection* half is adopted; rotations are not. |
| Pact-style contract-test broker | Consumer and provider live in one repo/one bench with one suite; shape assertions in the existing suite give the protection without the toolchain (§5). |
| Google-scale monorepo CI (hermetic/remote builds) | Out of scale; the `Dockerfile.test` image gate is the proportionate version of "test the artifact you ship" (§7). |
| Launch-review boards (Google SRE launch checklist as a meeting) | Our deploy record + acceptance checklist already is the launch review, executed by the loop; a board adds a calendar, not a check. |

## 14. The trained rules — one list

- **R1** One lane = one self-contained change; branch ≤ 2 days or split; PR
  states how tested + how to roll back.
- **R2** Tests exercise the governing path, as the real user; a failure found
  in a browser round is not closed until the backend test that catches it
  exists.
- **R3** Suite expected-failed set is re-derived from the pristine tip
  whenever the tip moves.
- **R4** Rollout order stage → demo2 → all tenants, acceptance at each step;
  rollback point named before deploy; previous image stays runnable until
  acceptance passes; restore first, diagnose second.
- **R5** MANIFEST is generated from the tree in the same lane that changes
  the tree; import-resolution scan + served-vs-tip diff after every
  manifest install.
- **R6** Environment-issued config verified by public fetch + content after
  every sync — never by presence.
- **R7** Two same-class failures on one surface freeze feature lanes there
  until a systemic fix lands; every production failure gets a same-day
  blameless debrief whose action item is verified present before the next
  lane on that surface.
- **R8** Delivery = content in the receiver's channel + receipt from the
  receiver's visible action. A path is not a delivery.
- **R9** Liveness = observed action inside the watch window; merges and
  status labels are not proof of life.
- **R10** The author is never the sole verifier: independent OCR review +
  scan stack + governing-path acceptance before merge; fakes validated
  against the live schema.
- **R11** Expensive-to-reverse decisions get an ADR-lite entry (context,
  options, decision, consequences); corrections supersede explicitly.
- **R12** A manual step done twice becomes a script/skill step in the second
  lane.
- **R13** Monthly DORA-lite self-measure in LOOP-STATE, four numbers read
  together.

*Sources: Forsgren, Humble & Kim, "Accelerate" (2018) and the DORA research
program; DORA "State of AI-assisted Software Development" (2025); Google
Engineering Practices, "Small CLs" (google.github.io/eng-practices); Google
Testing Blog, "Just Say No to More End-to-End Tests" (70/20/10); Mike Cohn,
"Succeeding with Agile"; Martin Fowler on the test pyramid; Beyer et al.,
"Site Reliability Engineering" (Google SRE) — error budgets, blameless
postmortems, rollback-first; Google SRE Workbook (canary analysis); Humble &
Farley, "Continuous Delivery"; Paul Hammant, trunkbaseddevelopment.com;
Skelton & Pais, "Team Topologies" (2019); Michael Nygard, "Documenting
Architecture Decisions" (2011); GitHub guidance on reviewing AI-generated
code.*
