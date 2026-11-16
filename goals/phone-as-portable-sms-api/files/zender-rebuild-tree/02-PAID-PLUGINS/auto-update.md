# PAID PLUGIN SPEC — Auto Update — **DECISION: NOT BUILDING**

- **Vendor price:** $59, v1.0.1 (8 Nov 2026). **No Extended discount**
  ("sold separately for every Zender license, Regular or Extended").
- **Portal:** https://products.titansys.dev/zender/auto-update/
- **Source status:** not stated. We do not buy it — and we will not
  rebuild it either (below).

## What it does (for the record)
One-click update of Zender and its plugins from the admin dashboard
(Admin > Update); automatic version checks; backup before update;
restore point kept 1 week; updates arrive as **official signed
packages from Titan Systems**; CLI update also possible. Requires
curl + unzip, write permissions, adequate disk.

## Why we deliberately do NOT build or buy it
- Our update discipline is **manual by design** (master plan + Lane 2):
  mysqldump backup → maintenance mode → stop queues → rsync excluding
  `.env`/`storage` → Settings > Updates → System Upgrade → restart
  services. The built-in manual `/upgrade` path is free.
- Every own change to core lives in the **patch register**
  (`05-INFRA.md`); a one-click updater that overwrites the tree works
  against that discipline and could silently wipe patched files or our
  plugin state.
- Auto-update also implies a standing vendor update feed — the exact
  dependency the custom-licence strategy is reducing.

## Replacement (already exists)
The manual upgrade runbook in `05-INFRA.md` + patch register. If
update *notification* is ever wanted, a tiny `tool` plugin that only
*checks* a version file and alerts (never writes) can be specced
later — UNVERIFIED need; not scheduled.

- **Priority:** None. **Difficulty:** n/a.
