# PreSkool Package — Inventory & Repo Record (2026-11-15)

## Package facts

- **Item:** PreSkool - School, College, Education ERP & LMS Admin Dashboard Template
- **Marketplace / item ID:** ThemeForest (Envato) item 29532878
- **Author:** dreamstechnologies
- **License:** ONE Regular License · **Licensee:** Asad Choudhary
- **Purchased:** 2026-11-15 08:42:48 UTC · **Purchase code:** first-4 `6368` only (full code exists only in the license certificate, held locally, never committed)
- **Source download (held locally, not committed):**
  `~/workspace/browser_downloads/sess-4013504447/browser-download-20261115T110054.432378184Z-0-themeforest-wjtwixkb-preskool-bootstrap-admin-html-template.zip` (622,689,864 B)
- **License certificate (held locally, not committed):** 854 B txt in the same folder.
- **Target repo:** https://github.com/asadchoudharry/rektrs-preskool (private; owner-created 2026-11-15 after the GitHub App create attempt returned 403 "Resource not accessible by integration")

## Target layout (owner-directed 2026-11-15): one branch per variant

| Branch | Contents at branch root | Files prepared | Size | README |
|---|---|---:|---:|---|
| `main` | Package README + `VARIANTS.md` + `documentation/` (2,254 files, ~40 MB) | 2,256 | ~40 MB | Yes (authored) |
| `html` | HTML/Bootstrap variant, files at root | 6,333 | ~186 MB | Yes (authored; no vendor README existed) |
| `react` | React variant (`preskool-react` v2.0.0) | 7,147 | ~143 MB | Yes (authored; vendor README kept as `README.vendor.md`) |
| `angular` | Angular variant (Angular 22.1) | 12,329 | ~201 MB | Yes (authored; vendor README kept as `README.vendor.md`) |
| `vue` | Vue variant (Vue 3.5) | 6,103 | ~158 MB | Yes (authored; vendor README kept as `README.vendor.md`) |
| `nextjs` | Next.js variant (`preskool-nextjs` v2.0.0) | 7,991 | ~147 MB | Yes (authored; vendor README kept as `README.vendor.md`) |
| `laravel` | Laravel variant (Laravel Framework 13.17) | 12,302 | ~294 MB | Yes (authored; vendor README kept as `README.vendor.md`) |

Variant file counts = extracted package counts + 1 authored README each
(vendor READMEs renamed, not added). Each variant zip's single same-named
wrapper folder was flattened so files sit at the branch root. Inner zips were
deleted after extraction; the extracted trees replace them.

Prepared staging trees (verified locally 2026-11-15):
`~/workspace/preskool-branches/{main,html,react,angular,vue,nextjs,laravel}/`
(source extraction: `~/workspace/preskool-package/`).

## Content scan results

- Total package: **54,453 files, ~1.2 GB** extracted; 49,579 UTF-8 text files
  (892.6 MiB of text alone) + 4,874 binary/non-UTF-8 files.
- **node_modules/ or vendor/ directories: none anywhere** (verified by scan).
- **Files >100 MB: none.** Largest single file: `sidebar-bg-02.svg`,
  33,886,450 B (~33.9 MB), one copy per variant.
- OS junk (.DS_Store/Thumbs.db/desktop.ini): none. Symlinks: none.

## Exclusions (with reasons)

- License certificate file — contains the full purchase code; **never committed**.
- Original outer zip (622,689,864 B) — pristine download held locally.
- node_modules/ and vendor/ — none present; nothing excluded under this heading.
- Files >100 MB — none present; nothing excluded under this heading.
- OS junk — none present.
- Connector sync metadata (`*.muse-github-snapshot-sync.json`) — bookkeeping, not package content.
- Nothing else was excluded.

## Push status — BLOCKED, nothing pushed (verified 2026-11-15)

- Repo read-back via the GitHub connector: `asadchoudharry/rektrs-preskool`
  exists and is **empty** (explicit `409 Git Repository is empty`). No branch
  has any commit; there is nothing to restructure from.
- **Why the push cannot run from this VM:** the only authorized write route is
  the GitHub connector's `push_files`, which per
  `/opt/hatch/connectors/github/references/snapshot-push.md` accepts at most
  **2,000 files and 16 MiB of UTF-8 text per snapshot and rejects binary
  content outright**. This package is 54,453 files / ~893 MiB of text plus
  4,874 binary files — over the limits on every axis, on every branch.
- No alternate git route exists on this VM: `gh` is not logged in and the VM's
  SSH key is not authorized on GitHub (`git@github.com: Permission denied
  (publickey)`). The connector guide forbids starting a new auth flow
  (no `gh auth login`, PATs, or embedded credentials).
- **Unblock options:** (a) the owner clones the empty repo on his laptop
  (where he is signed in to GitHub) and pushes the prepared branch trees from
  `~/workspace/preskool-branches/` — or Muse transfers those trees to the
  laptop first; (b) the owner authorizes another authenticated git route.
  Until then the repo stays empty and this record is the inventory of record.

## Verification (prep phase)

- Local: every branch staging tree counted and README-checked (table above);
  counts reconcile exactly with the extracted package.
- Remote: repo emptiness confirmed by connector read (`get_file_contents` →
  409). No remote read-back of content is possible because no content was pushed.

## Push results — 2026-11-15 ~16:12–16:18 PKT (deploy-key SSH route)

The blocker above was resolved: the owner added the VM key
`~/.ssh/id_ed25519` as a **write deploy key** on
`asadchoudharry/rektrs-preskool`; `git ls-remote` over SSH succeeded (empty
repo), and each staged tree in `~/workspace/preskool-branches/` was
git-initialised on its own branch, committed as
"Rektrs Automation <dev@rektrs.com>" with message
"PreSkool template package — <branch> tree (licensed, ThemeForest 29532878)",
and pushed. **All 7 branches pushed with no rejections** (no >100 MB file was
encountered, consistent with the prep scan).

| Branch | Commit | Files pushed | Remote-verified files | Delta |
|---|---|---:|---:|---:|
| `main` | `d13cc75d51b7a4f9fc6efeec5e4dd79e16d97320` | 2,256 | 2,256 | 0 |
| `html` | `ac39a717f1028d126aa8ca61134fde2fb971e2cf` | 6,333 | 6,333 | 0 |
| `react` | `b5cdc5d390587e8cd12b8c1e7ce5dd494834b441` | 7,147 | 7,147 | 0 |
| `angular` | `dc4f33e67e3340c09bcc1d6fb01ecaa02c4a91bd` | 12,329 | 12,329 | 0 |
| `vue` | `702c7db39aad6f9b5636c3b3dd4d4096d0946023` | 6,103 | 6,103 | 0 |
| `nextjs` | `a18739485a9ee41ca8a2d1b4234d006c1f7dbed3` | 7,991 | 7,991 | 0 |
| `laravel` | `76748b27119815955e925482867b095baea9e9da` | 12,302 | 12,302 | 0 |
| **Total** | | **54,461** | **54,461** | **0** |

Verification (2026-11-15 16:18 PKT):

- `git ls-remote --heads` lists all 7 branches with exactly the commit hashes
  above.
- A fresh `--no-checkout` clone of the remote was taken and
  `git ls-tree -r --name-only origin/<branch> | wc -l` reproduced the staged
  counts exactly for every branch (delta 0 — no `.gitignore` or other losses).
- Independent connector read-back (`get_file_contents`, asadchoudharry
  account): `README.md` on `main` returned the package README (blob SHA
  `9a383d6a4b5c500d93528f29983ec6a424745021`) and `composer.json` on `laravel`
  returned the Laravel project manifest — PHP ^8.3, laravel/framework ^13.17
  (blob SHA `9b8fbd5d4dcf8535e1342196f5619187bf17bbed`). Both blob SHAs match
  the corresponding entries in the remote git trees exactly.

**Status: PUSH COMPLETE AND VERIFIED.** The blocker section above is retained
as the historical record of the prep phase.
