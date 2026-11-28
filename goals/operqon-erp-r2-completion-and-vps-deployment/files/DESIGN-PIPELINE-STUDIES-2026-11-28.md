# Design Pipeline Studies — Tokens Studio · Style Dictionary · Storybook

**Date:** 2026-11-28 · **Type:** read-only study batch (no installs, no builds, nothing executed inside the clones)
**Why:** Our standing design rule is *"one design token package drives every surface"* — tenant SPA screens (L3), the generic L2 renderer, L1 app re-themes — with the condition that **the DreamsERP design stays on every level**. Until now the token package existed only as hand-maintained CSS inside the SPA work. These three studies cover the missing pipeline behind that rule: where tokens are **authored** (Figma), how they are **built** into per-surface outputs, and where components are **proven** (workshop + visual/a11y testing). The result serves all projects: Operqon (DreamsERP SPA, console, portal, Keycloak theme), Postqon (Crafexa surfaces), IQRS (Flutter mobile, JavaFX desktop).

**Method:** shallow clones of the real upstream repos, read at source level (LICENCE, package metadata, source constants, docs shipped in-repo), GitHub API metadata for health (stars / last push / release cadence), vendor docs + pricing pages for the plan facts. Scans: Gitleaks on all three cloned repos; Semgrep `p/security-audit --metrics=off` on Style Dictionary `lib/` + sd-transforms `src/` (0 findings). Storybook's monorepo was assessed via a blobless partial clone (root files read directly) plus file-level reads through the GitHub connector and its official docs — no full-tree scan, proportionate for a dev-only tool that never ships to tenants.

**The pipeline in words (the shape all three studies converge on):**

```
Figma (design v2, Keycloak theme design)
  └─ Tokens Studio plugin — tokens authored as sets + themes (light/dark …)
       └─ Git sync → tokens/*.json + $themes.json + $metadata.json  (in git, PR-reviewed)
            └─ Style Dictionary v5 + @tokens-studio/sd-transforms — the build engine
                 ├─ CSS variables ──────► SPA (L3) · L2 renderer · L1 re-themes · Keycloak theme · portal/console
                 ├─ Tailwind preset ────► SPA / console / portal / Postqon (Crafexa)
                 ├─ JS/TS modules ──────► any surface needing values in code
                 ├─ flutter/class.dart ─► IQRS mobile (Flutter)
                 └─ custom format ──────► IQRS desktop (JavaFX CSS) — the one non-built-in output
  Storybook (html-vite) — the component proof surface: every DreamsERP component
  lives here as stories, rendered against the built CSS variables, checked by
  interaction + accessibility tests and self-hosted visual diffing.
```

---

## Study 1 — Tokens Studio for Figma (`tokens-studio/figma-plugin`)

| | |
|---|---|
| Licence | **MIT** (plugin source, this repo) |
| Health | 1,632 stars · 231 forks · repo pushed **today** (2026-11-28) · releases ~weekly — v2.13.4 on 2026-11-17, package already at 2.13.5 on main · not archived · 355 open issues (normal for its size) |
| Scans | Gitleaks 7 hits — **all assessed false positives**: 5 in test files, 1 fabricated example credential inside a docs/stories example for the storage-settings modal, 1 Bitbucket OAuth *client ID* (a public identifier, not a secret). No live secret. |

**What it adds that we do not have.** A token *authoring* surface inside Figma itself. Today our tokens are edited as CSS by developers; designers working Figma-first (Operqon design v2, the Keycloak theme design) have no way to own the values. Tokens Studio lets the Figma file and the code consume **the same values from the same source**, instead of a design being re-typed into CSS by hand — the exact failure mode behind several of our past design-drift rounds.

**Token types (verified in source, `src/constants/TokenTypes.ts` — 29 types):** color, gradient, typography (**composite**), boxShadow (**composite**), composition, border (composite), dimension, sizing, spacing, borderRadius, borderWidth, opacity, fontFamilies, fontWeights, fontSizes, lineHeights, letterSpacing, paragraphSpacing/Indent, textCase, textDecoration, text, asset, boolean, number, duration, cubicBezier / transition (motion), other. Every type our surfaces need is present, including the composites (full typography and shadow stacks) that Figma's native variables still cannot model.

**Themes + modes (our mandatory light/dark).** Tokens are organised into *sets*; a **theme** is a named combination of sets, and themes can be grouped (multi-dimensional theming: e.g. brand × mode). Themes are written to git as `$themes.json` + `$metadata.json` alongside the set files — i.e. the theme matrix is data in the repo, consumable by the build engine (sd-transforms has a dedicated theming path, Study 2). Themes also map onto Figma variable collections with multiple modes.

**GitHub sync shape (verified in source, `src/storage/`).** Storage providers in code: GitHub, GitLab, Bitbucket, Azure DevOps, JSONBin, Supernova, URL, local file. The GitHub provider is Octokit-based: it commits the token files **directly to a configured branch** (multi-file commits), can create branches, and stores either a **single file** (`tokens.json`) or a **multi-file folder** (one JSON per set + `$themes.json` + `$metadata.json`). Branch-based PR review of token changes is therefore possible: sync to a branch, review the JSON diff like code.

**How tokens leave Figma toward code.** Git sync (above) is the primary route — tokens land in the repo as JSON; everything downstream is the build engine's job. The plugin can also export a local JSON file and can push token values *into* Figma variables/styles.

**Free tier vs paid — the decisive caveat (vendor docs + pricing pages, checked 2026-11-28).** The plugin installs and works free, and basic single-file Git sync is usable free. But the vendor's own "Paid Figma plugin features" doc gates exactly the features this pipeline leans on behind the **Team plan (€39 per editor/month, billed annually**; the old Pro/Starter Plus/Essential plans were folded into it):

| Feature | Free | Team (€39/editor/mo) |
|---|---|---|
| Create/apply tokens, apply themes someone else made | ✅ | ✅ |
| **Author themes** (our light/dark definitions) | ❌ | ✅ |
| **Multi-file sync** (folder of set files — the layout the theming build path expects) | ❌ (read-only on such folders) | ✅ |
| **Branch management** when syncing | ❌ | ✅ |
| Color modifiers, graph/table views | ❌ | ✅ |

Mitigations, honestly stated: (1) we need very few *editor* seats — realistically **one** (whoever authors themes); viewers are unlimited and free, and applying tokens/themes is free. (2) The token JSON is just files: a `$themes.json` can be hand-maintained in git in a degraded zero-spend mode, but that fights the tool and loses the Figma-side theme workflow. (3) The plugin code is MIT, but the paid features are gated by the vendor's account/licence service on the distributed plugin — self-hosting a fork to dodge the gate is not a route we recommend (maintenance burden + against the spirit of a €39 seat).

**Integration route.** Install the plugin in the Figma files that carry Operqon design v2 and the Keycloak theme design → define sets (core / semantic / component) → author `light` and `dark` themes → GitHub-sync (multi-file) into the design-system repo (Study-combined layout below) → hand off to Style Dictionary.

**Effort.** ~½–1 day to set up sync + set structure; 1–2 days to transcribe our existing Dreams token values into sets/themes the first time (they exist today as the SPA's v3 token package CSS — a transcription, not an invention).

**Risks.** The paid gate (above) — a small but real recurring spend, owner's call. Vendor plan terms have changed once already (Pro → Team consolidation); the token files in git remain ours regardless — worst case we keep the JSON and lose only the authoring convenience.

**Verdict: GO — conditional on one Team editor seat (€39/mo).** It is the only Figma-side token manager that writes theme-aware, DTCG-shaped JSON straight to GitHub, and it is co-maintained with the build engine below. Without the seat the pipeline still functions in degraded single-file mode, so this is not a hard blocker — but themes are our mandatory light/dark axis, and authoring them is precisely the gated feature.

---

## Study 2 — Style Dictionary v5 + sd-transforms (`style-dictionary/style-dictionary`, `tokens-studio/sd-transforms`)

| | Style Dictionary | sd-transforms |
|---|---|---|
| Licence | **Apache-2.0** | **MIT** |
| Version read | **v5.8.0** (clone == release, 2026-11-03) | **v2.0.3**, peer-depends on `style-dictionary ^5.0.0` |
| Health | 4,899 stars · pushed 2026-11-03 · monthly-or-better release cadence through 2026 (5.6→5.8 in five weeks) | 252 stars · last push 2025-12-10 — low churn; a narrow, finished-scope library from the Tokens Studio team (the same org that maintains Style Dictionary with Amazon) |
| Scans | Gitleaks **0** · Semgrep security-audit on `lib/` **0 findings** | Gitleaks **0** · Semgrep on `src/` **0 findings** |

**What it adds that we do not have.** The **build engine** that turns one token JSON into every surface's native format, in CI, deterministically. Today each surface hand-carries its own copy of the values (the SPA token package, console CSS, portal CSS, Keycloak theme CSS) — the drift risk our "one token package" rule was written against, with no machinery enforcing it.

**(a) Consumer → output mapping (built-in formats verified in source, `lib/enums/formats.js` + templates):**

| Our consumer | Style Dictionary output | Built-in? |
|---|---|---|
| Tenant SPA (L3) + L2 generic renderer + L1 app re-themes | `css/variables` (per theme: light/dark files or mode-scoped selectors) | ✅ |
| SPA / console / portal / Postqon — Tailwind | **No built-in Tailwind format.** Official route: the repo's own `examples/advanced/tailwind-preset` pattern (generate a Tailwind preset from tokens), or — for Tailwind v4 — consume the CSS variables directly via `@theme`. Either way it is a solved, documented path, not research. | ⚠️ via official example / CSS-vars |
| Keycloak theme (login.rektrs.com) | `css/variables` / plain CSS — drops into the theme's CSS as-is | ✅ |
| Any surface needing values in code | `javascript/es6 · esm · module · object`, `typescript/es6-declarations · module-declarations`, `json/flat · nested` | ✅ |
| IQRS mobile — **Flutter** | **`flutter/class.dart`** — a Dart class of `Color`/dimension constants (template verified in source) | ✅ |
| IQRS desktop — **JavaFX** | **No JavaFX format exists** — repo-wide search for "javafx" returns **zero** hits in v5.8.0. Path: one small **custom format** (a template emitting JavaFX CSS `-fx-*` properties from the same color/dimension tokens) — Style Dictionary's extension API is the designed mechanism for exactly this. Effort ≈ ½ day, once. | ❌ custom format needed |
| (Also available if ever needed) | `android/colors · dimens · strings · resources`, `compose/object` (Kotlin), `ios` + `ios-swift` families, `scss/less/stylus` variables | ✅ |

So: **one JSON source feeds all three surfacing levels and every project surface**, with exactly one custom format (JavaFX) and one documented-pattern output (Tailwind) as the only non-built-in pieces.

**(b) The Tokens Studio pairing — does Figma-exported JSON flow in without hand-rework? YES — via configuration, not file editing.** Tokens Studio's export is DTCG-shaped (`$value`/`$type`) but uses Tokens-Studio type names and composite shapes that differ slightly from strict DTCG (e.g. `boxShadow` with `x`/`y` instead of `offsetX`/`offsetY`; extra typography properties). `@tokens-studio/sd-transforms` exists precisely to bridge this, and is the vendor-documented pairing:

- its **`tokens-studio` preprocessor** aligns Tokens Studio types to DTCG types (original type preserved under `$extensions['studio.tokens']`), extracts embedded font styles, and strips single-file parent keys;
- its **transforms** handle the value-level deltas: math expressions (`ts/resolveMath`), unit-less dimensions → `px`, opacity % → 0–1, line-height % → unitless, font-weight names → numbers, **color modifiers**, letter-spacing % → `em`, inner-shadow → `inset`;
- **composite expansion** moved into Style Dictionary itself (the `expand` config), with sd-transforms supplying the `expandTypesMap` for the TS composite shapes;
- it ships a **theming** path that consumes `$themes.json` and produces per-theme builds (incl. multi-dimensional themes).

Honest boundary: exotic hand-authored token JSON that bypasses the plugin export can still need transform adjustments — but for the actual pipeline (plugin export → sd-transforms → SD) **no token file is ever hand-edited**; the bridge is ~15 lines of build config (`register()` + preprocessor + transform group).

**(c) v5 vs v4 — what matters.** v5 is a near-drop-in upgrade: internals refactored for performance on large token sets; stricter token references (references must point at actual tokens, not groups/sub-properties). The API-defining changes came with v4 and carry into v5: **fully async API** (`await sd.buildAllPlatforms()`), ESM-first, and **first-class DTCG support**. One live caveat from SD's own DTCG doc: support for the newest DTCG spec revision (2025.10) is still a work in progress in v5 (tracked upstream, issue #1590) — the DTCG shape Tokens Studio exports today is handled; pin versions and re-check on upgrades.

**Integration route.** A `build/` package in the design-system repo: `style-dictionary.config.js` registering sd-transforms, one platform per consumer from the table above; runs in CI on every token PR; outputs committed or published as a versioned artifact each surface consumes.

**Effort.** ~1 day for the config covering CSS vars + JS/TS + Flutter; +½ day for the JavaFX custom format when IQRS desktop's turn comes; Tailwind via the official preset example inside the same day.

**Risks.** sd-transforms' low release churn — mitigated by its tiny scope: worst case we vendor its ~dozen transforms. DTCG 2025.10 WIP (above). Both are pin-and-monitor risks, not adoption blockers.

**Verdict: GO (both).** Apache-2.0/MIT, zero cost, actively maintained engine, and the pairing with Study 1 is the vendors' own documented architecture — Tokens Studio co-maintains Style Dictionary.

---

## Study 3 — Storybook (`storybookjs/storybook`)

| | |
|---|---|
| Licence | **MIT** |
| Health | **91,757 stars** · 10,595 forks · pushed today (2026-11-28) · latest stable **v10.6.9** (2026-11-25) with v11 already in release candidates — the most actively maintained project in this batch |
| Scan note | No full-tree scan (giant monorepo; blobless partial clone + connector file reads + official docs). Dev-only tooling: it never ships to tenants, so its risk class is build-machine hygiene, not attack surface. |

**What it adds that we do not have.** A **component workshop**: every UI component built, documented and tested *in isolation*, with a living catalogue the whole team (and our agents) can browse. Today we have **no such surface at all** — component truth lives scattered across the SPA/console/portal source trees, and every visual check means deploying somewhere and clicking through a real page (the failure pattern behind our repeated "panel says Done, browser says otherwise" rounds). Storybook is where the DreamsERP component library would *live*: one Button, one DataTable, one StatusPill — rendered in every state and theme, proven before any lane consumes it.

**(a) Should it become the home of the DreamsERP component library? YES.** It is the missing proof surface in our pipeline: tokens flow down from Figma (Studies 1–2); Storybook is where components built on those tokens are demonstrated and regression-checked. It also directly serves our standing acceptance discipline — a component's stories are a *rendered* proof, reviewable without a deploy.

**(b) Fit with our stack — honestly assessed.** Our frontends are **vanilla JS / `.mjs` modules + Tailwind** (SPA, console, portal), not React/Vue. Verified in the v10.6.9 tree (`code/frameworks/`): Storybook ships **`@storybook/html-vite`** and **`@storybook/web-components-vite`** frameworks. The honest fit:

- **`@storybook/html-vite` is our path.** A story is a function returning a DOM element or HTML string — exactly how our `.mjs` components already render. Vite is the builder; Tailwind flows through the normal Vite CSS pipeline (import the surface's CSS entry in `.storybook/preview`), and the built token CSS variables (Study 2) load as a preview stylesheet, so stories render against the real DreamsERP tokens, light and dark (the in-tree `themes` addon switches them).
- **The cost of honesty:** framework-less stories get no automatic prop tables/arg inference (React's docgen doesn't exist for plain functions) — controls and docs are written by hand per component. That is a modest per-component tax, not a blocker; our components are few and deliberate.
- Web Components (`web-components-vite` + Lit-style) would only pay off if we later wrap components as custom elements — not today's architecture; not recommended now.

**(c) Testing: interaction, a11y, and visual regression — without paid cloud.**
- **Interaction + accessibility (built-in, free):** Storybook Test runs on the in-tree **`vitest` addon** (Vitest browser mode + Playwright) executing story play functions; the in-tree **`a11y` addon** (axe-core) runs accessibility checks per story and can gate tests. This pair alone covers most of our component-proof need at zero infra cost. (Note: the old `@storybook/test-runner` repo was **archived in Nov 2026** — superseded by this Vitest path; do not adopt the archived runner.)
- **Visual regression:** the official polished route is **Chromatic** — the Storybook stewards' **paid cloud** (per-snapshot pricing, external service). We do **not** need it. Self-hosted options, assessed:
  - **Loki** (MIT, ~1.9k stars) — purpose-built for Storybook: renders stories headlessly (Chrome/Docker) and diffs against baselines stored in the repo. Repo still pushed (Oct 2026) but release cadence is slow (last release Aug 2024) — works, with a version-compat check owed at adoption time.
  - **reg-suit** (MIT, reg-viz) — a generic visual-regression pipeline (capture → diff → report, storage + PR-comment plugins); pairs with a story screenshotter. More moving parts; the flexible option if Loki's compat fails.
  - **DIY thin harness** — Playwright screenshots of the static Storybook build + `pixelmatch` diffing in CI. Least magic, fully ours, ~½–1 day to stand up; entirely feasible because Storybook builds to static HTML with stable story URLs.
  - **Recommendation:** start with Vitest interaction + a11y (built-in); add **Loki** for visual baselines, falling back to the DIY harness if its Storybook-10 compat disappoints. Baselines live in git next to the stories — visual diffs become PR artefacts our reviewers (human or agent) can actually look at.

**(d) The MCP server — what it lets an agent do (verified in source + official docs).** `@storybook/addon-mcp` (in-tree at v10.6.9) serves an MCP endpoint (`/mcp`) from the Storybook dev server with three toolsets:
- **Development** — list stories affected by local changes, get story-writing guidance, create/update stories, return story previews/links to the agent's chat;
- **Testing** — run component tests for chosen stories and return results **including accessibility violations**, with fix guidance — i.e. an agent can build a component, run its tests, fix failures and re-run: a self-checking loop in exactly the shape our lane protocol wants (author is never sole verifier — the toolset gives the *reviewer* agent the same surface);
- **Docs** — query the component catalogue (props, usage docs, example stories) so an agent reuses existing components instead of inventing new ones.
- **The honest limitation for us:** the docs toolset reads a **components manifest** that today is generated only by the React frameworks, `@storybook/angular-vite` and `@storybook/vue3-vite`. **`@storybook/html-vite` generates no manifest → the docs toolset is unavailable on our stack for now** (upstream states it is expanding manifest support to the remaining renderers). Development + testing toolsets work in every project, ours included. The MCP server as a whole is also officially **preview** ("API may change"). Net: adopt for dev/testing toolsets now; treat the docs toolset as **watchlist**, re-check per Storybook release.

**(e) Where to start + adoption cost.** **Start with the DreamsERP tenant SPA components** — they are the product face (L3), the most numerous, and the ones our acceptance rounds keep re-checking by hand. Then console/portal shared chrome (much of it already shares the SPA's component shapes), then Postqon/Crafexa surfaces; IQRS surfaces consume tokens (Study 2 outputs) but are not Storybook candidates (Flutter/JavaFX have their own widget-test worlds).
Cost per project: pilot (html-vite setup, token CSS wiring, theme switcher, a11y + Vitest test wiring) ≈ **2–3 days**; each component ≈ ½–2 hours to story properly (states + play test); each additional surface after the pilot ≈ ½–1 day (config re-use). CI: the static build + tests run on our own VPS/GitHub runners — no external service.

**Risks.** Framework-less tax (hand-written controls/docs, above). Loki's slow cadence (fallback exists). MCP preview status (we depend on it for nothing critical-path). Storybook's own weight — it is a dev dependency only; production bundles never include it.

**Verdict: GO (phased).** Phase 1 = SPA components + interaction/a11y tests. Phase 2 = visual baselines (Loki or DIY). MCP dev/testing toolsets: adopt with Phase 1. MCP docs toolset: **WATCHLIST** until manifests reach the html renderer.

---

## Combined recommendation — the chain we would adopt

**Adopt all three, as one pipeline, in this order of dependency:**

1. **Tokens Studio for Figma** (authoring) — GO, with **one Team editor seat (€39/mo, billed annually)** as the only recurring spend in the entire pipeline; the seat exists because *themes authoring + multi-file sync* — our mandatory light/dark axis and the layout the build expects — are the gated features. Everything else in the chain is free and open-source.
2. **Style Dictionary v5 + @tokens-studio/sd-transforms** (build engine) — GO. One token JSON → CSS variables (SPA L3, L2 renderer, L1 re-themes, Keycloak, portal/console), Tailwind (official preset pattern / v4 `@theme` over the same variables), JS/TS, **Flutter built-in**, **JavaFX via one small custom format** (the single non-built-in output — the brief's assumption of a built-in JavaFX output does **not** hold in v5.8.0; verified zero hits).
3. **Storybook 10 on `@storybook/html-vite`** (proof surface) — GO, phased as above; visual regression **self-hosted** (Loki → DIY fallback), **not** Chromatic; a11y via the built-in axe addon.

**The Figma→code token flow works without hand-rework** — plugin export → git → sd-transforms preprocessor/transforms → Style Dictionary platforms. The bridge is configuration (~15 lines), maintained by the same vendor org on both ends. No token file is ever edited by hand after export.

**Repo layout for the token package (single source):** one dedicated design-system repo (suggested: `rektrs-design-system` under the owner's GitHub), laid out as:

```
tokens/            ← Tokens Studio multi-file sync target (the ONLY hand-authored layer)
  core/  semantic/  component/        (one JSON per set)
  $themes.json  $metadata.json        (light/dark + future brand themes)
build/             ← style-dictionary.config.js (+ sd-transforms register, JavaFX custom format)
dist/              ← generated, committed per release tag (never hand-edited)
  css/  tailwind/  js/  flutter/  javafx/
storybook/         ← html-vite app; stories for the DreamsERP component library;
                     baselines/ holds Loki visual baselines
```

Surfaces consume `dist/` outputs (pinned by version/tag) — SPA, console, portal, Keycloak theme, Postqon, IQRS mobile/desktop — so a token change is one PR in one repo, reviewed once, propagated everywhere by version bump. This replaces today's per-surface hand-carried token copies.

**First three concrete adoption steps (recommendations only — nothing executed by this study):**

1. **Stand up the skeleton + one-seat decision:** create the design-system repo with the layout above; owner approves the single Tokens Studio Team seat; connect the plugin's GitHub sync (multi-file) from the Operqon Figma design file; transcribe the existing Dreams token package values into core/semantic sets with `light` + `dark` themes.
2. **Prove one full round-trip:** Style Dictionary config (sd-transforms registered) emitting CSS variables + Tailwind preset; point **one** SPA surface (e.g. the login screen, our most-checked page) at the built output and verify — backend-first, then rendered proof — that a token changed in Figma propagates Figma → git → build → page with zero hand edits in between.
3. **Storybook pilot:** html-vite Storybook over ~5 core SPA components (Button, DataTable, StatusPill, form inputs, shell/nav) with the token CSS + theme switcher wired, a11y addon on, Vitest interaction tests running in CI, and Loki baselines committed — establishing the component proof surface every later UI lane must pass through.

**Study caveats.** OCR full review was not run (standing constraint — no paid key / owner ChatGPT sign-in configured); the substitute applied was source-level reading + the full Gitleaks/Semgrep pass reported per study. Tokens Studio plan facts are the vendor's published docs/pricing as of 2026-11-28 and have changed once before — re-verify at purchase time (purchasing is the owner's act in any case). Storybook evidence rests on the v10.6.9 tree read via connector + official docs (its monorepo was not fully cloned/scanned — see Study 3 note).
