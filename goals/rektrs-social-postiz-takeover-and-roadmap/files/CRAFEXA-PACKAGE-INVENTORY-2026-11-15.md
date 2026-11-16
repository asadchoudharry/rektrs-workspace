# Crafexa Studio — Package Inventory (2026-11-15)

Record: the purchased package has been extracted, inventoried, staged into
documented branch trees locally, and **pushed to the Postqon repo** — see
"Push status" at the end for the verified outcome.

## Package facts

- Item: **Crafexa Studio – Creator Operations & Multistream Next.js Admin Template**
- Marketplace: ThemeForest, item **65207434**, author **craftdzine**
- Licence: **ONE REGULAR LICENSE**, licensee **Asad Choudhary**
- Purchased: **2026-11-15 08:42:49 UTC** (same 1-second batch as the
  PreSkool and Dreams Core purchases)
- Purchase code: first 4 characters **3540** — the full code exists only in
  the original licence certificate files (txt 877 B + pdf) in the download
  folder; it is **not** copied into any staged tree or this record.
- Template version: **1.0.1** (package's own `package.json` /
  `PACKAGE-TYPE.txt`; vendor-stated release date 2026-10-07)
- Download: outer zip **1,210,740 B** →
  `~/workspace/browser_downloads/sess-4013504447/browser-download-20261115T110928.829917118Z-4-themeforest-gI6CBiAl-crafexa-studio-creator-operations-multistream-nextjs-admin-template.zip`
- Working extraction: `~/workspace/crafexa-package/`
  (outer contents + `project/crafexa-studio/` from the inner zip)

## Contents inventory

The outer zip contains exactly two things:

| Item | Size | Notes |
|---|---|---|
| `Main-file/crafexa-studio.zip` | 1,348,769 B | The template project itself |
| `Main-file/Documentation/index.html` | small | Vendor standalone HTML documentation (single self-contained page) |

Inner project (`crafexa-studio/`): **485 files, ~4.5 MB extracted** — a
**single Next.js project; no framework variants inside** (no HTML/Angular/
Vue/Laravel editions, unlike PreSkool's 6 and Dreams Core's 9).

### Stack (proven from the project's own `package.json`)

- **Next.js 16.4.0**, **React 19.2.8**, **TypeScript 5.9.3**,
  **Tailwind CSS 4.3.3** (PostCSS), Radix UI 1.6.7, Recharts 3.10.1,
  TanStack Table 8.21.3, React Hook Form 7.85.0 + Zod 4.4.3,
  next-themes 0.4.6, lucide-react 1.28.0
- Node engine: **>= 20.19.0**; scripts: `dev` / `build` / `start`,
  `npm run check` = the vendor's full validation + typecheck + lint +
  tests + build gate; `npm test` runs 7 node test suites
- Package name `crafexa-studio-admin-template`, version 1.0.1,
  `package-lock.json` present (~356 KB — the largest file in the package)

### Structure

- `src/app/` — App Router: `(app)` group with dashboards (creator /
  agency / command-center), accounts, agency, analytics, automation,
  content (composer, calendar, queues, studio, videos), developers
  (credentials, integrations, webhooks, RTMP/storage, logs), engage,
  growth, live (create, studio, destinations, recordings, scheduled),
  optimize, revenue, system; `(auth)` group (sign-in/up, onboarding,
  password reset, two-factor); landing, states, error/500/maintenance
- `src/components/` — feature components per area + `ui/` primitives
- `src/data/` — bundled demo data modules; `src/lib/` — config plus
  `api/` adapter contracts/registries and `intelligence/` modules
- `docs/` — 17 vendor guides (architecture, design system, file structure,
  route inventory, API adapter contract, demo-data governance, release
  checklist, placeholder-media manifest, …)
- `scripts/` — 22 vendor validation / smoke / browser-audit `.mjs` tools;
  `tests/` — 7 suites; `public/` — branding SVGs + placeholder media;
  `licenses/` — Manrope + JetBrains Mono OFL texts
- **Frontend-only**: no backend, database, API routes or `next.config.*`
  in the package; real data is expected via the documented adapter layer
- **Placeholder media**: per the vendor's `PACKAGE-TYPE.txt`, raster/video
  demo media in this buyer package is neutral placeholder media with
  filenames/geometry preserved (the 4 content PNGs are byte-identical
  69,273 B placeholders)
- **No `node_modules`** ships (install via `npm ci`); **no file >100 MB**
  (largest is `package-lock.json` at 356,182 B)

## Branch trees staged (local, `~/workspace/crafexa-branches/`)

Owner's standing layout rule applied: `main` = package index +
documentation; one branch tree per variant, files at branch root, each
with its own README.

| Tree | Files | Contents |
|---|---|---|
| `main/` | 4 | `README.md` (package README + licence facts, code first-4 only; top now carries a pointer to the design brief), `PROJECT.md` (variant index + stack summary), `Documentation/index.html` (vendor documentation), `DESIGN-BRIEF.md` (added at push time — the Cursor brief for Postqon, incl. the owner's strict no-invented-design rule) |
| `nextjs/` | 486 | The complete vendor project (485 files) at tree root, byte-for-byte as extracted, + `BRANCH-README.md` (stack table, structure map, install/run/build from the vendor's own README/scripts, honest notes). The vendor's own `README.md` and `docs/` are untouched inside the tree. |

## Exclusions (deliberate; nothing else omitted)

- **Licence certificate files** (txt + pdf) — contain the full purchase
  code; held in the download folder only, never staged.
- **Original zips** (outer + inner) — held locally; extracted trees
  replace them.
- Nothing else: no `node_modules` existed to exclude, and no oversized
  files exist in this package.

## Push status — DONE, verified (2026-11-15)

**Pushed to `asadchoudharry/Postqon`** — the brand repo the owner created
for the social product (Postqon = Rektrs Social's new brand name). The
earlier suggested repo name `rektrs-crafexa` was **never created**; Postqon
replaces it as Crafexa's home, since Crafexa Studio is Postqon's design
base. The owner added the Crafexa deploy key (`~/.ssh/id_ed25519_gh_crafexa`)
to Postqon; pushes went over plain git SSH.

- Branch `main` → commit **`76edb08cb238aecebbe16dc9574a2ab34148524f`**
  ("Crafexa Studio template — main tree (licensed, ThemeForest 65207434)
  — Postqon design base", author Rektrs Automation <dev@rektrs.com>).
  Remote tree verified: **4 files** — `DESIGN-BRIEF.md`,
  `Documentation/index.html`, `PROJECT.md`, `README.md`.
- Branch `nextjs` → commit **`d5e9b40954c6683634832f5bc2b18e349ebd103a`**
  (same message pattern, nextjs tree). Remote tree verified: **486 files**,
  matching the staged count exactly.
- `git ls-remote` confirms both branches (HEAD → main). Independent proof:
  the GitHub connector read back `DESIGN-BRIEF.md` from `refs/heads/main`
  (blob SHA b75181152a85c41714fc151e4a18d5d94583515c) with the strict
  no-invented-design rule intact.
- Note: the `main` tree's `README.md` still contains two stale sentences
  from prep time (it names the never-created `rektrs-crafexa` as the
  suggested repo and says "Push status: NOT pushed yet"). The template
  content was pushed unaltered per instructions; a small README correction
  commit is the only cleanup owed.

## Surprise, stated plainly

The package is **unusually small** for a ThemeForest "admin template":
the whole download is ~1.2 MB and the project ~4.5 MB / 485 files, versus
~594 MB (PreSkool) and ~270 MB (Dreams Core) bought the same day. That is
consistent with what it is — a source-only Next.js codebase with
placeholder media instead of real demo assets — not a truncated download:
both zips extract cleanly, `package-lock.json` is complete, and the
vendor's own validation scripts and test suites are present.
