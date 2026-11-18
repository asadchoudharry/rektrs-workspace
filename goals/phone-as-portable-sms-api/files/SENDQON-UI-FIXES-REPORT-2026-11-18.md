# Sendqon — UI Fixes Report (2026-11-18)

**Owner GO:** 2026-11-18 ~13:02 PKT — "Teeno UI fixes laga do — PTA screens, Cascade node,
Spam/HLR surface." Findings source: `SENDQON-PLUGIN-UI-SURFACE-CHECK-2026-11-18.md`.
All three fixes are **built, batteried on the dev copy, production-installed and verified**.
No plan features, prices or flags were changed.

**Mechanism decision (applies to Fixes 1 + 3):** the panel is an Inertia + React SPA whose
pages/navigation are hardcoded in the vendor's TypeScript; the plugin system offers **no
page- or nav-registration hook**, and a runtime-installed ZIP cannot inject React pages.
The most native mechanism available is the one core itself uses for plugin surfaces:
**server-rendered Blade pages served by the plugin's own web routes** (precedent: core's
Booking plugin registers a Blade view namespace from its provider; core's subscribe/
unsubscribe pages are standalone Blade with the same styling approach). Pages are styled
to match the panel (Sendqon indigo, light/dark aware, "Back to panel" link). Honest
limitation: because navigation registration does not exist for plugins, the pages are
reached by their URLs (below), not by a sidebar menu entry — no plugin can add one.

---

## Fix 1 — PTA Mask UI · `pta_mask` 1.0.0 → **1.1.0** (ACTIVE in production)

**What was built** (all inside the plugin; JSON endpoints untouched):
- Tenant page `GET /pta-masks`: apply form (business name, NTN, requested mask with the
  rule hint, contact name/phone, notes, **document upload** — pdf/jpg/png/webp/doc, ≤5
  files, ≤10 MB each, stored on the local disk, original filenames kept) + "My
  applications" list with status badges, admin notes and document download links.
- Form posts: `POST /pta-masks/apply` (validates with the same rules as the JSON API —
  mask `^(?=.*[A-Za-z])[A-Za-z0-9]{3,11}$` uppercased, NTN `^[0-9-]{8,15}$`) and
  `POST /pta-masks/{id}/submit-form`. The GET endpoints now content-negotiate: browsers
  get the page, `Accept: application/json` still gets the original JSON.
- Admin pages: `GET /admin/pta-masks` (review queue across workspaces, status filter) +
  `GET /admin/pta-masks/{id}` (full detail, document downloads, review form —
  under_review / approve / reject with note), behind the same `can:admin.plugins.update`
  gate. Document downloads are ownership-checked (other workspace → 404).

**Battery (dev, HTTP click-path, 3 lane users): 25/25 PASS** — page renders + rule hint;
JSON list still JSON; numeric-only mask refused with the rule message and nothing created;
draft created with document upload, mask uppercased (REKTRS), document downloadable by the
owner (200) and 404 for another workspace (page + JSON); tenant B cannot see tenant A's
application; submit → submitted; admin queue + detail render; review → under_review →
approved with note visible to the tenant; duplicate approved mask refused
("already approved for another application") and the second application stays submitted;
rejection path with note; tenant blocked from the admin queue (403).
(Two battery-side artifacts were found and fixed during the run — badge needles matching
the page's own CSS, and a route-name typo in the admin views that 500'd the queue; the
final 25/25 is against the shipped code.)

**Production:** backup first (`status=OK push=OK`), upgraded via PluginManager →
**v1.1.0 active**; routes verified registered; unauthenticated requests 302 → /login.
Authenticated page checks were done on the dev copy (byte-identical build); production
was verified by route/registry probes + file-content checks (stated plainly per lane rules).

**Owner click-paths:**
- Tenant applies: **https://sendqon.rektrs.com/pta-masks**
- Admin reviews: **https://sendqon.rektrs.com/admin/pta-masks**

## Fix 2 — Cascade flow node · `cascade` 1.0.0 → **1.1.0** (ACTIVE) + core patch **PR-004**

**Root causes (three, all fixed):**
1. The plugin registered its executor into `ChannelRuntimeRegistry` from `boot()` — that
   registry rebuilds itself solely from *channel* plugins' `registerRuntime()`, so the
   registration was wiped and a fresh process resolved `null`. Cascade is an
   `integration`-type plugin and can never be carried by that registry.
2. `action.cascade_send` was absent from `NodeTypeCatalog` → invisible in the flow editor.
3. Latent: the executor read the tenant from `$run->user_id`, which is **empty** on
   dispatcher-launched runs (core uses `$flow->user_id` everywhere) — it would have
   failed `contact_not_found` on its first real run. Fixed plugin-side.

**Mechanism:** core has exactly one plugin-facing pattern for non-channel flow nodes —
the hardcoded *Access* classes used by Google Sheets, Bookings, AI Agents and Commerce.
Fix 2 mirrors it: plugin-side `CascadeNodes` (catalogue entry + executors, in the plugin)
+ **PR-004** (registered in `PATCH-REGISTER.md` *before* applying): new core file
`app/Services/Cascade/CascadeAccess.php`, one merge line + one availability filter in
`NodeTypeCatalog`, one conditional registration block in `FlowServiceProvider`
(~9 edited lines + 1 new file; rollback = revert 3 hunks + delete the file). The dead
registry registration was removed from the plugin's provider.

**Battery (dev): 13/13 PASS** — fresh-process `NodeExecutorRegistry::resolve()` returns
the executor; catalogue contains "Cascade Send" (group action) for a tenant; deactivating
the plugin removes it from the palette, reactivating restores it; a dev flow
(trigger → cascade) runs end-to-end: dry run completes via the test runner, and a **real
run delivered** — WhatsApp attempt refused (`channel_not_available`), **SMS attempt
accepted**, run completed, step output carries the cascade id, attempts logged in
`cascade_attempts`. HTTP endpoint regression: `POST /integrations/cascade/send` still
executes and returns per-channel attempts.

**Production:** plugin **v1.1.0 active**; PR-004 files applied to the web container
(production originals were md5-verified byte-identical to the build tree first);
fresh-process probe: executor resolves + node present in the production catalogue
(81 types for the owner tenant). Baked into the build tree (see §4).

## Fix 3 — Spam Score + HLR screens · both 1.0.1 → **1.1.0**

**Spam Score (ACTIVE in production):** tenant Tools screen at `GET /tools/spam-score` —
paste-a-message form (`POST /tools/spam-score/page-check`) rendering score /100, level
band (clean / review / high) and the reason list from the same `SpamScorer` the JSON
endpoint uses (endpoint untouched). No plugin hook exists into core's compose/campaign
screens, so nothing was faked — the Tools screen is the surface.
**Battery (dev): part of 17/17 below** — clean text scores `clean`; link-heavy shouting
text is flagged with reasons; JSON endpoint unchanged.

**HLR (production: v1.1.0, stays INACTIVE + unconfigured by design):** screens at
`GET /integrations/hlr` — single-number check, bulk check (one per line, ≤500, split
into valid/invalid/unknown), and campaign preflight (pick one of your campaigns → counts;
invalid recipients are excluded through core's skip with reason `hlr_invalid`). All three
call the same `HlrValidator` as the JSON endpoints (untouched). The screens sit behind
`EnsureHlrActive`, so in production they ship **dormant** and appear the day the plugin
is activated with a provider account (owner step).
**Battery (dev, real HTTP against a stub provider on 127.0.0.1:8890): 17/17 PASS
(combined with Spam)** — single check returns valid + carrier Jazz; bulk splits 1/1/1;
preflight reports 1 valid / 1 invalid / 1 unknown and the invalid recipient's status
actually became `skipped`; unconfigured state renders an explanatory notice.

**Owner click-paths (Spam live now; HLR after activation):**
- **https://sendqon.rektrs.com/tools/spam-score**
- **https://sendqon.rektrs.com/integrations/hlr**

## 4. Production state + permanence

| Item | Production state |
|---|---|
| pta_mask | **1.1.0 active** |
| cascade | **1.1.0 active** + PR-004 core files live in the web container |
| spam_score | **1.1.0 active** |
| hlr | **1.1.0 inactive, config empty** (by design) |

Pre-install backup: fresh run `status=OK push=OK`. Post-install: public `/` + `/login`
200; all four new page routes registered and auth-gated (302 → /login when logged out);
all containers Up. **Build tree baked** (`~/sendqon-build/src`): the four plugin trees at
1.1.0 + the three PR-004 core files — the next image build carries everything to all
containers. Standing topology note (unchanged since B1): plugin code executes in the web
container; queue/scheduler containers pick plugins up at the next image rebuild.

**Pushes (all ls-remote verified):**
- Sendqon `plugin-pta_mask` → `44dc6e7`
- Sendqon `plugin-cascade` → `e020179`
- Sendqon `plugin-spam_score` → `84c70a8`
- Sendqon `plugin-hlr` → `7523754`
- This report + the sweep report + `PATCH-REGISTER.md` (PR-004 status) → Sendqon
  `rebuild-tree` and rektrs-workspace `main` (hashes in the lane's completion message).

**Left unverified, plainly:** (1) authenticated page tours were run on the dev copy
(byte-identical build + same zips); production authenticated rendering is proven by
route/registry/file probes, not by a logged-in production session — no test tenant was
created on production. (2) Screenshots were impossible (no headless browser exists on
VM/host/containers); the tour used HTTP status + rendered markers. (3) Queued production
flow runs execute in `sendqon-queue`, which — like every own plugin since B1 — receives
plugin code at the next image rebuild from the baked tree; the Cascade node is live now
for the editor catalogue and web-side execution.
