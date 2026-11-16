# FREE PLUGIN — Legacy API Wrapper (v1.0.0)

**What it is:** a free plugin that wraps the old (pre-v5) Zender API
surface so integrations written against the legacy API keep working
on Zender 5. Demo state: **Not installed** (Lane 4 §C).

## Evidence — deliberately thin
- Lane 4 (demo plugin list) is the only lane that saw it: name
  "Legacy API Wrapper", version **v1.0.0**, state Not installed.
- Lane 5's source census audited the five *downloaded* free-plugin
  branches (android-gateway, whatsapp, smpp, whatsapp-signup,
  legacy-importer); **no legacy-api-wrapper branch/ZIP was in the
  purchased tree**, so there is no manifest, class or route evidence
  to cite.
- The public docs' consolidated API material describes only the v1
  API; Lane 2 gap #7 notes there is **no v4 migration / legacy detail**
  in the docs.

Everything about its exact route mapping, auth translation and limits
is **UNVERIFIED**. Do not design against assumptions here.

## Our stance
- **Not needed.** We have no legacy-API integrations to preserve —
  all our integrations are new and target `/api/v1` (and our own
  Admin API / MCP). Skip entirely.
- If a future tenant arrives with legacy-API tooling, first step is
  to obtain the plugin ZIP (verified-buyer free plugin) and audit it
  the way Lane 5 audited the others; then rewrite this file.
