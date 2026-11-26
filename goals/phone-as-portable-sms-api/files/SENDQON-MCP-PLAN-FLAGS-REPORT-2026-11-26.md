# Sendqon — MCP Plan Flags Enabled (Pro Tier and Above)

**Date:** 2026-11-26 · **Environment:** production (`sendqon.rektrs.com`, offbox-1, container `sendqon`)
**Authorisation:** owner approved the sequence ("Isi tarteeb se shuru karo", 2026-11-26 10:38 PKT) whose Step 2 item 3 was the recommendation "MCP pricing — Pro aur us se upar ke plans par ON, Free/Starter par OFF", followed by the direction to implement the listed recommendations himself-free ("chrome per sara kam khud kro", 10:39 PKT). Reversible config change.

## What changed

The `mcp` feature flag in each plan's `features` set (63 keys, stored as the plan record's JSON feature set) was set to `true` on exactly four plans: **Pro, Enterprise, Pro Managed, Enterprise Managed**. Free, Starter and **Starter Managed** stay `false` — Starter Managed is a Starter-tier plan despite its higher price (it carries the Starter feature set verbatim), so it was deliberately left OFF per the approved scope. No other flag or value on any plan was touched; the master admin's bila-qayd bypass is core behaviour and was not touched.

This flag is the gate NF-1 proved Postqon's one-click OAuth connects ride (`McpAccess::enabledFor` → `PlanFeatures::allowsAll($tenant, 'api', 'mcp')`), so this change is what opens tenant MCP / Postqon connects — for Pro-tier tenants only.

## Before / after

| Plan | Price (PKR/mo) | `mcp` before | `mcp` after | features md5 before | features md5 after |
|---|---|---|---|---|---|
| Free | 0 | false | false | `c7ce9279c87f16cc04649af8f2d975dd` | unchanged |
| Starter | 2,499 | false | false | `dd080fe6dd7a49d0caaa0e84b19f8129` | unchanged |
| Pro | 5,999 | false | **true** | `d2b1d2b4ecc294350b92653c63cc5d75` | `2d2022bb2fa63b56c92a6232d69e4ed1` |
| Enterprise | 14,999 | false | **true** | `36aad3ade5ecb88f54d71c8722718558` | `dfcce4ea30df6ff541801146e2171033` |
| Starter Managed | 7,499 | false | false | `dd080fe6dd7a49d0caaa0e84b19f8129` | unchanged |
| Pro Managed | 15,999 | false | **true** | `d2b1d2b4ecc294350b92653c63cc5d75` | `2d2022bb2fa63b56c92a6232d69e4ed1` |
| Enterprise Managed | 34,999 | false | **true** | `36aad3ade5ecb88f54d71c8722718558` | `dfcce4ea30df6ff541801146e2171033` |

(Managed plans share their base tier's feature set, hence identical md5s within each pair.)

## Method

Surgical, byte-preserving: for each target plan, the single occurrence of `"mcp": false` in the raw `features` string was asserted (count == 1) and replaced with `"mcp": true` via a database update run as `www-data`. No model re-encode, so every other byte of every plan record is provably identical (see verification).

## Backup (before the write)

Fresh run of `/var/serverkit/apps/sendqon/backup.sh` at 2026-11-26 05:40 UTC: `status=OK, push=OK`. Artifacts verified substantively — sizes match the run log and all pass `gzip -t`:

- `sendqon-db-2026-11-26.sql.gz` — 10,684,729 B
- `sendqon-config-2026-11-26.tar.gz` — 29,287,762 B
- `sendqon-storage-2026-11-26.tar.gz` — 102,714,425 B

## Verification (all as `www-data`, after the write)

1. **Records re-read:** the table above — 4 plans ON as scoped, 3 plans byte-identical (md5 match), all 63 feature keys present on every plan.
2. **Byte-level proof of scope:** replacing `"mcp": true` back to `"mcp": false` in each changed plan's stored string reproduces its exact before-md5 — only the `mcp` token differs, nothing else.
3. **Other flags unchanged:** spot-read on all 4 changed plans — `ai_agents`, `ai_flow_generation`, `knowledge_base`, `telegram`, `telegram_store`, `phone_bridge`, `rcs`, `otp` all still `false` (they were false before; the md5 proof covers the remaining keys).
4. **Functional gate probe:** the codebase's own gate — `PlanFeatures::allowsAll($tenant, 'api', 'mcp')`, the exact call `McpAccess::enabledFor()` makes — was exercised with in-memory (unsaved, non-admin) tenant contexts bound to each plan: Pro / Enterprise / Pro Managed / Enterprise Managed → **true**; Free / Starter / Starter Managed → **false**. 7/7 as scoped, zero database writes.
5. **MCP surface intact:** `McpAccess::installEnabled()` = true; the MCP plugin's tool registry still returns **30 definitions**, including `list-whatsapp-accounts`.
6. **Site health:** `https://sendqon.rektrs.com/` → HTTP 200; 0 ERROR lines in the tail of today's Laravel log.

## Effect and reversibility

- Tenants on Pro, Enterprise, Pro Managed and Enterprise Managed can now pass the MCP gate (MCP clients and the Postqon one-click OAuth connect). Free, Starter and Starter Managed tenants remain refused, exactly as NF-1 measured for the flag-off state.
- Fully reversible: flip the same single token back per plan (or restore the 2026-11-26 backup).
