# PAID PLUGIN SPEC — Admin API

- **Vendor price:** $39 (reduced for Extended holders, amount unstated).
  **Version:** v1.0.1 (8 Nov 2026). Requires Zender **5.0.3+**.
- **Portal:** https://products.titansys.dev/zender/admin-api/
- **Demo state:** Active/Configured (Tools), Lane 4 §C.
- **Source status:** not stated (UNVERIFIED). We do not buy it.
- Checkout asks for the buyer's CodeCanyon username.

## Purpose
Programmatic control of the whole admin area: the surface an external
platform (for us: Operqon, loosely coupled, or our own automation)
uses to provision workspaces, plans and subscriptions without touching
the admin UI. Lane 3 calls this the most important plugin for external
automation.

## Features
Complete REST API over: workspaces, members, plans, subscriptions,
invoices, charges, announcements, templates, API keys. Full CRUD on
admin resources. Everything described in **one OpenAPI 3.1 document**.
API keys carry **workspace scopes**. A documented admin registration
path; admin login/logout. Auth: **API key or session cookie**.

## Workflow
Upload plugin ZIP in Admin > Plugins → activate → enable "Admin API"
on the workspace plan → integrate against the OpenAPI document.

## Logic / technology
A second API tier beside the tenant API: tenant API is `/api/v1`
(Sanctum, workspace-scoped); Admin API is `/api/v1/admin` (Lane 2).
It must reuse core admin services (`app/Services/Admin/*`) rather than
query tables directly, so audit logging and permission checks apply.

## Data it touches
All admin domains: `users`, workspaces, `plans`, `subscriptions`,
`transactions`, announcements/templates tables, `personal_access_tokens`.

## Dependencies
Core admin + billing; plan switch per workspace.

## OUR REBUILD SPEC
- **Plugin type:** `tool` (runtime contract) — admin tools register
  service providers through the runtime-contract path (Lane 5 §5.1).
- **Key interfaces:** route group `/api/v1/admin/*` behind admin auth;
  an OpenAPI 3.1 document generated/shipped with the plugin; scoped
  API keys (scope = workspace set + resource set); every mutating call
  audit-logged via core `AuditLogger`; rate limits aligned with the
  tenant API model.
- **Security rules for our build:** no session-cookie auth from
  non-browser clients by default; keys revocable per workspace;
  suspending a user must revoke admin keys too (mirror core behaviour
  in `../01-CORE-MODULES/auth-accounts.md`).
- **Priority:** Phase 4, integrations group — but pulled forward if
  Operqon coupling is scheduled (master plan: loose REST/webhook
  coupling only, after the Operqon stop lifts / via Cursor).
- **Difficulty:** Medium. Surface is wide but every operation already
  exists as a core admin service.
