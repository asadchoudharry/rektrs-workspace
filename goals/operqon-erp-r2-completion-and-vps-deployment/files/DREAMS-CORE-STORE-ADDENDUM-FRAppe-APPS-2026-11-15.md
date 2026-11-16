## ADDENDUM A (owner instruction, 2026-11-15 ~18:05 PKT) — The whole system is modular products; Frappe apps are white-labelled into the Store

Owner's words (verbatim):
> "Or ek baat hamara pora system esy he plugins, extension, apps, add-ons ki Surat main ho ga, frappe apps bhi hum esy he white label Ker k apny store main dalin gy jesy manufacturing, payment system integration, HRM, CRM sab"

This addendum EXTENDS the main instruction (Dreams Core Full Build + Plan Entitlements + In-Panel Store, posted on this PR). Where it touches the main instruction, this addendum wins.

### A1. The whole system is products — no hard-wired features
Operqon's core stays a thin platform: identity/login, tenant management, billing, entitlements, the Store, console, portal shell. EVERY capability on top of that core ships as a product in the Store's sense — an **App, Plugin, Extension, Add-on, Integration or Theme** — with a catalogue entry, a price, plan inclusions, dependencies and server-side entitlement gating. Do not hard-wire a new capability into the core in a way that bypasses the entitlement/Store system. If an existing core feature should become a product, list it in the S0 inventory with its proposed product mapping instead of silently leaving it hard-wired.

### A2. Frappe apps become Operqon products (white-labelled)
Every Frappe-ecosystem app that Operqon offers becomes an Operqon-branded Store product, for example:
- ERPNext modules/apps: **Manufacturing**, Accounting, Stock/Inventory, Selling, Buying, Projects, Quality, Support, Assets, etc.
- **HRMS → the Operqon HRM product**, **Frappe CRM → the Operqon CRM product**, Helpdesk, LMS, Insights, Builder, Wiki, Telephony, Raven, Webshop/eCommerce.
- **Payments and payment-system integrations** (Frappe Payments + gateway packs) — sold as Integration products under the Integration Standard (§7 of the main instruction: tenant's own credentials, validate-or-error).
- Adopted third-party apps from the existing app-pack blueprint tiers (e.g. XPOS, pakistan_tax, KSA Compliance/ZATCA apps, biometric bridge) — same treatment, after their adoption checks pass.

For each one, "white-labelled" means ALL of the following:
1. **Zero upstream branding on any tenant-visible surface** — no "Frappe", "ERPNext" or upstream-app name/logo anywhere a tenant can see: login, Desk/workspace chrome, app tiles/switcher, onboarding, help/about dialogs, documentation links, empty states, error pages, print formats, emails, footer credits, PWA/mobile surfaces. This is the standing Zoho-style end-state rule (owner, 2026-11-08) applied per product; use the existing surface-census + branding-pack machinery (app-level hooks first, bounded fork only where the census proves it necessary, own frontend where neither works) and extend the census per product as you activate it.
2. Presented in Operqon's own design system (Dreams family for the surfaces in Dreams Core scope; the settled Operqon tenant theming elsewhere), with an Operqon product name, Operqon icon, and Store listing under that name.
3. Sold and gated exactly like any other product: plan inclusion or Store purchase, per-user/per-month pricing unless defined flat, per-tenant activation only (one tenant's purchase never activates it for another tenant), server-side entitlement checks on its routes/APIs.

### A3. Per-tenant activation mechanics
Activation/deactivation of a Frappe-app product for a tenant must run through Operqon's own machinery (the existing app-pack / install-policy patterns — investigate and reuse before building new): purchase or plan grant → the app is installed/enabled for that tenant's site only → entitlement check passes → the product appears in the tenant's surfaces, fully Operqon-branded. Deactivation reverses cleanly without deleting the tenant's data in that app. No manual bench commands per sale, ever.

### A4. Licence discipline (binding — flag, never violate)
White-labelling is a branding/UI exercise; it does NOT erase upstream licences, and the Store must never be built on a licence violation:
- Frappe/ERPNext and HRMS are GPL-3.0; Helpdesk, CRM, LMS, Insights are AGPL. Keep licence/copyright notices in SOURCE code as required (they are not tenant-visible UI), keep glue code in `operqon_core` via public extension points — never as modifications inside a GPL/AGPL app — and follow the standing vanilla-or-publish discipline for any AGPL modification.
- Maintain a **licence register** in `docs/execution/`: every product → upstream app, pinned version, licence, what white-label changes were made, what obligations apply. Any product whose licence terms block or condition commercial Store sale must be FLAGGED to the owner by name BEFORE it is listed for sale — listed only after the flag is answered.
- Version discipline: pin every app to the tenant bench's lockstep version line (v16); upstream updates are reviewed and tested before a Store product's version is bumped — never auto-track upstream HEAD.

### A5. Changes to the build sequence
- **S0 expands:** the inventory must catalogue every Frappe app/module already present in the tenant image AND every adopted app from the app-pack blueprint tiers, each mapped to a proposed product (Operqon name, type, category, dependencies, licence, white-label work required, census surfaces). Products that cannot yet be white-labelled cleanly are flagged with the reason, not silently skipped.
- **New phase S7 — Frappe-app productisation**, after S5 (gating sweep) and alongside S6: take the Frappe apps in owner-priority order — the owner named **Manufacturing, payment-system integrations, HRM, CRM** first ("sab" = the rest follow) — and for each: white-label per A2, productise per A1/A3, list in the Store, prove per A6.
- S6 grandfathering applies to Frappe apps too: tenants already using a module today keep using it; productisation must not switch off anything in live use.

### A6. Additional acceptance criteria (evidence required)
11. An activated Frappe-app product (e.g. Manufacturing) shows ONLY Operqon branding on every census surface — screenshot evidence in the PR, zero upstream names/logos visible.
12. A tenant not entitled to that product: the app is not active on their site, its surfaces/APIs deny server-side with the Store route, and other tenants are unaffected.
13. Buying the product activates it for that tenant alone, in the same session, with no manual bench step; cancelling locks it and preserves its data.
14. The licence register covers 100% of listed Frappe-app products; any sale-blocking licence flag is on record with the owner's answer before listing.

**End of Addendum A. Continue the loop — S0 first, with the expanded inventory.**
