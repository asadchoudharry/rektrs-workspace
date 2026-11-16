# FREE PLUGIN — Legacy Importer (v5.0.4)

**What it is:** the free plugin that migrates data from a legacy
(pre-v5) Zender installation into Zender 5. Demo state: Not installed
(Lane 4 §C).

## What it contains (Lane 5 §5.7-5 — why this file matters to us)
Slug `legacy_importer`, type **`tool`**, `runtime_contract: 1`,
`personal_data: true`, with a manifest-listed migration
(`2026_10_27_000001_create_legacy_import_tables.php` → tables
`legacy_import_runs`, `legacy_import_maps`). Structure:

- `src/LegacyImporterPlugin.php` (main class)
- `Runtime/` tree: its own ServiceProvider
  (`LegacyImporterServiceProvider.php`), routes
  (`Runtime/Routes/web.php`), a controller, **3 jobs, 2 models**,
  dump parsers, and importers for **users / contacts / subscriptions**
- A personal-data service (GDPR participation)

## Why it is in this tree even though we will never run it
**It is the reference example of a "real" third-party plugin** — own
service provider, routes, jobs, models and migrations, all loaded
through the generic mechanisms (discovery → manifest validation →
install → migrations → activation). When we build our own substantial
plugins (Admin API, MCP, integrations), this plugin's layout is the
proven template to copy *structurally* (not its code — the structure
and contracts).

## Our stance
- **No use as a tool:** we have no legacy Zender data to import.
- **Keep the ZIP in the audit archive** as the plugin-architecture
  reference; cite it in developer onboarding for Phase 4.
- Public docs contain no Legacy Importer detail (Lane 2 gap #7); its
  documentation is inside its ZIP, like every plugin.
