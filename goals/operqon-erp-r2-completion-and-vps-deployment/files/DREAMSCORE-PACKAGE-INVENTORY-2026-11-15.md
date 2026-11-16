# Dreams Core — Package Inventory (2026-11-15)

## Package facts

| | |
|---|---|
| Item | Dreams Core — Multi Purpose Tailwind CSS Admin HTML Template |
| Marketplace | ThemeForest, item **64974775** |
| Author | dreamstechnologies |
| Licence | ONE REGULAR LICENSE |
| Licensee | Asad Choudhary |
| Purchased | 2026-11-15 08:42:49 UTC |
| Purchase code | first 4 only: `7b0f` (full code + certificate file held locally, never committed) |
| Source zip | `browser-download-20261115T110610.738655778Z-2-themeforest-GzKiDwqc-dreams-core-multi-purpose-tailwind-css-admin-html-template.zip`, 282,635,745 B |
| Target repo | `asadchoudharry/operqon-templete` (private) — https://github.com/asadchoudharry/operqon-templete |

## Contents of the outer zip

9 variant zips + `documentation/` (verified locally: **2,172 files**, ~27.5 MB of
content; per-variant HTML docs for all 9 variants + changelog). Inner zips were
extracted and removed from the staging trees.

## Branch layout (staged locally, push pending — see below)

Staging root: `~/workspace/dreamscore-branches/`
(`main/` = the `main` tree; `branches/<variant>/` = that branch's root tree.)

| Branch | Files (package) | Size | Staged files | Binary files | node_modules | Files >95 MB |
|---|---:|---:|---:|---:|---|---|
| `main` (README + VARIANTS + DESIGN-BRIEF + documentation/) | 2,172 (docs) | 27.5 MB | 2,175 | present in docs assets | — | none |
| `tailwind` | 2,043 | 202.1 MB | 2,044 | 188 (53.8 MB) | none shipped | none (largest 19.4 MB) |
| `react` | 1,170 | 14.0 MB | 1,171 | 153 (2.1 MB) | none shipped | none |
| `vue` | 915 | 192.0 MB | 916 | 189 (157.4 MB) | none shipped | none (largest 35.2 MB) |
| `angular` | 5,693 | 86.0 MB | 5,694 | 180 (39.9 MB) | none shipped | none (largest 19.4 MB) |
| `nextjs` | 2,189 | 14.3 MB | 2,190 | 153 (2.1 MB) | none shipped | none |
| `nuxtjs` | 877 | 192.4 MB | 878 | 189 (157.4 MB) | none shipped | none (largest 35.2 MB) |
| `laravel` | 13,261 | 234.4 MB | 13,262 | 4,452 (72.0 MB) | none shipped (also no `vendor/`) | none (largest 20.5 MB) |
| `laravellivewire` | 13,347 | 235.5 MB | 13,348 | 4,452 (72.6 MB) | none shipped (also no `vendor/`) | none (largest 21.0 MB) |
| `php` | 1,052 | 82.5 MB | 1,053 | 175 (40.0 MB) | none shipped | none (largest 19.4 MB) |

Staged count = package count + 1 on every variant branch (the authored
`README.md`). Each variant branch's vendor README was preserved as
`README.vendor.md` (all variants except `tailwind`, which shipped none). The
`nextjs` branch also keeps the vendor's `AGENTS.md` untouched (referenced from
its README).

## Documentation authored in staging

- `main/README.md` — package index, licence facts, exclusions, push status;
  opens with a pointer to the design brief.
- `main/VARIANTS.md` — variant/branch index with stack, counts, sizes.
- `main/DESIGN-BRIEF.md` — the Cursor design brief (Dreams Core = design base
  for Operqon portal/console/tenant dashboards; template's own design language
  as-is; dark/light + RTL; tokens as single source of truth; ERP frontend is
  DreamsPOS-based and out of scope here).
- Per-variant `README.md` on all 9 branches — stack + versions taken only from
  each variant's own `package.json`/`composer.json`, folder-structure map,
  install/run/build commands from its own scripts.

## Exclusions

- License certificate `.txt` (contains the full purchase code) — **not** staged
  or committed anywhere; held locally only.
- `node_modules/` — none present in any variant; nothing excluded on this count.
- Files >100 MB — none exist; nothing excluded on this count.
- OS junk — none present.
- Nothing else was excluded.

## Push status — PENDING GIT ROUTE (blocker)

- Repo state verified 2026-11-15 via the connector read tools: **empty**
  (explicit `409 Git Repository is empty` on the default-branch ref).
- The connector snapshot-push route cannot carry this package: per
  `/opt/hatch/connectors/github/references/snapshot-push.md` it caps at
  **2,000 files / 16 MiB UTF-8 text per snapshot** and rejects binaries.
- One confirming check was run (2026-11-15): a `push-files` snapshot of
  `main`'s README + one documentation PNG was rejected by local validation —
  ``snapshot file `documentation/assets/img/logo/favicon.png` is not UTF-8`` —
  and nothing was written to the repo.
- **Commits pushed: none.** All 10 trees are complete and verified locally in
  `~/workspace/dreamscore-branches/` and will land mechanically (one branch per
  tree) as soon as a plain `git push` route exists (e.g. a write deploy key for
  the VM on this repo, as already proposed to the owner by the PreSkool lane).

## Local verification performed

- Every variant zip extracted; inner zips deleted from staging; branch-root
  layout = variant files at root (nested vendor folder flattened).
- Per-branch staged file counts re-counted after README authoring (table above).
- Stack facts in every README cross-checked against the variant's own
  manifests (`package.json`, `composer.json`) — nothing invented; where a
  variant ships no lockfile (vue) or no README (tailwind), the branch README
  says so.

## Push results — 2026-11-15 (deploy-key SSH route)

Amendment applied before push (owner rule): DESIGN-BRIEF.md on `main` gained the
top section "STRICT RULE — NO INVENTED DESIGN" (no new design or feature may be
invented from this template; everything stays exactly as the template ships), and
`main`'s README.md gained a one-line pointer to it. Both were edits to existing
files — file counts unchanged.

Pushed to `git@github.com:asadchoudharry/operqon-templete.git` via the per-repo
write deploy key, one commit per branch, author "Rektrs Automation
<dev@rektrs.com>", message "Dreams Core template package — <branch> tree
(licensed, ThemeForest 64974775)".

| Branch | Commit | Verified files (git ls-tree) | Staged files |
|---|---|---:|---:|
| main | a673464bd16942fbdf107707f6b7916b9d45b1bf | 2,175 | 2,175 |
| tailwind | c893deec15246d8c51673492d8c4a2773a5b6361 | 2,044 | 2,044 |
| react | c4aecff1b201f1ca7d428eabc4bef7b75e1f59d7 | 1,171 | 1,171 |
| vue | 6b73efb194a5bb34dda426cb5b746240e39e2e44 | 916 | 916 |
| angular | 1051718d2f7a4a3b65a07537d675d7c3dbbdde14 | 5,694 | 5,694 |
| nextjs | c62ec751b33e851df0eddb265c25faeee3a9c23c | 2,190 | 2,190 |
| nuxtjs | 47cb77e4be19594eaf297fc50bc1d9e713be7345 | 878 | 878 |
| laravel | 41f8306932af8f2f514a791db92b9666a7fe9af1 | 13,262 | 13,262 |
| laravellivewire | 6bc884248d2957f8843333fa6667df3fdfa08567 | 13,348 | 13,348 |
| php | 546d997e6bdecd7a55cf368f6d4e7d1f9ecf3700 | 1,053 | 1,053 |

Verification: `git ls-remote` lists all 10 branches with hashes identical to the
local HEADs above; per-branch `git ls-tree -r` counts match the staged counts
exactly (42,731 files total). Independent connector read-back:
`DESIGN-BRIEF.md` on `main` (SHA 22df5b6b…) shows the STRICT RULE section at the
top; `README.md` on the `react` branch (SHA d51d3d36…) reads back correctly.
No push was rejected; no failures.
