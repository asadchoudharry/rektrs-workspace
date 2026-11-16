# OWNER INSTRUCTION — Dreams Core Full Build + Plan Entitlements + In-Panel Store
**From:** Assad (owner), via Muse — 2026-11-15
**To:** Cursor, "Continuous execution system" (project: Operqon SaaS)
**Status:** This is a major owner instruction. Add it to your existing LOOP. Do not wait for further prompts. Execute phase by phase; stop only for a genuinely owner-only step, named exactly, written on the PR/docs — never as a silent chat wait.

Owner's words (Roman Urdu, verbatim):
> "Jesy hum ny PreSkool k features Iqrs main banaye workflow sab set kia dreamcore Ka bhi esa he kerna bs us main ek fark ho ga features, apps, plugins kis ko kon kon si milin gi yeah purchased plan per dependant ho ga or user apny panel say pay Ker k apps, plugins, extension, integrations ly saky ga uska store ho ga — jesy app store hota"

---

## 1. What this instruction is

Build Dreams Core into Operqon the SAME way PreSkool was built into the IQRS school system: not a visual skin, but the template's features implemented as REAL, working workflows on Operqon's real data and real backend. Then add ONE difference that IQRS did not have: a plan-entitlement layer and an in-panel Store (like an app store) through which tenants buy everything that is not included in their plan.

## 2. Already-decided context (do not re-litigate, do not re-ask)

- Working base variant = **Tailwind** build of Dreams Core (`asadchoudharry/operqon-templete`, branch `tailwind`), for ALL in-scope surfaces. Locked by the owner 2026-11-15.
- Scope of Dreams Core = **customer portal, provider console, tenant dashboards**. ERP transactional screens stay on Dreams ERP; POS stays on DreamsPOS. Do not pull transactional ERP screens into Dreams Core.
- Design rule (absolute): design EXACTLY as the purchased template ships — no invented design, no invented features, no approximations presented as matches. Anything the template does not contain, or Operqon does not have, is FLAGGED in writing (flag list in `docs/execution/`), never silently invented.
- Dark + light mode and full RTL are mandatory on every surface you touch.
- Deploy keys for `operqon-templete` and `operqon-core` are already cut over and verified. PR #107 (`feat(ui): vendor Dreams Core Tailwind theme for portal and console`) is the in-flight Dreams Core PR — this instruction extends that line of work, it does not replace it.
- Communication protocol (you already acked it): panel chat = major owner instructions, decisions, real blockers only. Real work communication = GitHub: branches/PRs, Muse's signal comment on a PR is your continue signal, progress/evidence in `docs/execution/` + PR descriptions. Owner decisions arrive as "Owner instruction (via Muse)".

## 3. The build model — PreSkool → IQRS pattern

For every in-scope Dreams Core page/feature:
1. Map it first: template page → Operqon surface → the real Operqon function/workflow it must drive. Maintain this map as a living file in `docs/execution/` and update it every phase.
2. Implement the workflow end to end on real data: the screen must actually DO the thing (create, list, approve, pay, export…), with the same validation and permissions the backend already enforces. A screen that only looks right is a FAILED deliverable.
3. If a template element has no real function behind it yet, either build the function (if it is in scope below) or register it as a flagged inert item with a build-list entry and priority — never fake data, never fake transactions.
4. No tenant-visible surface may reveal ERPNext/Frappe internals (standing end-state rule).

## 4. THE DIFFERENCE — Plan entitlements (who gets what)

1. Every sellable unit in Operqon is one of: **App, Plugin, Extension, Integration, Theme**. Call these "products".
2. What a tenant receives is decided ONLY by entitlements, from three sources:
   - **Plan inclusion** — the tenant's purchased plan includes a defined set of products.
   - **Store purchase** — products bought individually from the Store (add-ons on top of the plan).
   - **Trial** — the free trial includes ONLY the settled trial set: Sales & Invoicing, Inventory, Point of Sale. Nothing else.
3. Pricing model (settled 2026-11-12, do not change): Zoho/Odoo style — **per app + per integration, per user, per month**. A product's price is per-user-per-month unless the product is explicitly defined as flat in the console.
4. Entitlement changes take effect without a deploy, without a restart, and without engineering involvement — plan change, purchase, expiry, cancellation and console edits must all flow through data, not code.
5. Reuse what already exists before building new: billing, seat-overage and dunning work is already live in the codebase. Map your entitlement model onto the existing billing/subscription models first; if a conflict appears, flag it in `docs/execution/` with the exact conflict and your chosen resolution — do not build a parallel billing system.

## 5. The Store (in the tenant/customer panel, like an app store)

The Store lives inside the customer portal, designed with Dreams Core Tailwind pages (map and flag the exact template pages you use for: store home, category listing, product detail, checkout, My Apps).

Required behaviour:
1. **Catalogue** — categories: Apps, Plugins, Extensions, Integrations, Themes. Each product shows: name, icon, short + long description, screenshots/preview from the template design, price (per user/month or flat), whether it is *Included in your plan*, *Active*, *Trial-available*, or *Available to buy*, its dependencies (e.g. an integration that requires a specific app), and the Operqon version it supports.
2. **Search + category browsing**, filtered to what is relevant to the tenant; products the tenant already owns show as owned, not as buyable again.
3. **Product detail page** — what it does, what changes when activated, what data/permissions it needs, price maths at the tenant's current user count (show the real monthly total before purchase — no surprises at checkout).
4. **Purchase flow, fully self-service**: tenant admin selects product → sees price at current seats → pays from inside the panel → product activates automatically in the same session → appears in the tenant's navigation/apps immediately. No manual activation step by anyone, ever.
5. **My Apps / My Products surface** — everything the tenant owns (plan-included and purchased shown separately), each with: source (plan / purchase / trial), renewal date, per-product status, cancel/renew actions, and usage where the product is metered.
6. **Lifecycle** — renewals, failed-payment handling (reuse the existing dunning flow), cancellation (product stays active until the paid period ends, then locks per §6), plan upgrade/downgrade (entitlements recomputed immediately; products that fall out of entitlement lock per §6, their data is NOT deleted).
7. **Receipts/invoices** for every store purchase, visible in the tenant's billing surface, using the existing billing/invoice machinery.
8. Payment for store purchases is Operqon's OWN subscription billing (Operqon's merchant accounts) — the service-provider principle applies: Operqon sells its own products; it does NOT take on the tenant's compliance. The ONLY human approval anywhere remains manual/offline payment verification by the billing approver, about Operqon's own money. If a live payment gateway step needs owner-held merchant credentials, flag it by name as an owner-only step on the PR and keep building everything around it — do not stall the loop.

## 6. Runtime gating (entitlement enforcement)

1. The **server is the authority** — entitlement is checked server-side on every route/API/action of a gated product. Hiding a menu item is NOT enforcement.
2. A tenant without entitlement to a product: the product does not appear in their normal navigation; a direct URL/API call returns a clear denial that routes them to the Store product page (buy/upgrade path), not a dead error.
3. On expiry/cancellation/downgrade: the product locks (read-only or fully locked — choose per product type and state your rule in the map file), existing tenant data is preserved and becomes fully available again on reactivation. Never silently delete tenant data on an entitlement change.
4. Per-user dimension: where a product is licensed per user, the console/portal must show seat consumption vs licensed count, reusing the existing seat-overage logic.

## 7. Integrations sold in the Store — the Integration Standard (binding since 2026-11-07)

Every integration product (FBR, ZATCA, payment gateways, SMS/WhatsApp gateways, future packs) ships as a complete module and follows all four rules:
1. Complete and seamless — built to the authority's full current specification.
2. Self-service activation — after purchase, the tenant enters THEIR OWN credentials in the product's settings and activates it themselves.
3. Validate-or-error — activation validates the credentials for real (live test where one exists); wrong credentials produce a clear error, never a silent half-active state.
4. Spec-current — Operqon keeps the module conformant as the authority changes its rules; the tenant owns their registration, credentials and filings.

## 8. Provider console — everything manageable from the frontend

Standing owner rule: every backend feature must be manageable from the console frontend. For this instruction that means the provider console must allow, without code or env changes:
- Create/edit/archive products (all five types), their descriptions, icons, categories, dependencies and supported versions.
- Set/change any product's price and pricing type (per-user/month vs flat).
- Build/edit plans: which products each plan includes, trial availability, plan price.
- Grant/revoke a tenant entitlement manually (support cases), with an audit entry.
- See per-tenant entitlements, store orders, and entitlement-change history (audit log: who/what/when/source — plan, purchase, console grant, expiry).
Adding a new product or changing a plan must be a console operation, never a code change.

## 9. Build sequence (execute in this order, inside your loop)

- **S0 — Inventory & map.** Existing-state report in `docs/execution/`: current billing/subscription/seat models, current plan handling, every existing app/module/integration that becomes a product, and the Dreams Core surface→template map extended with Store surfaces (store home, category, product, checkout, My Apps). Flag list opened. PR it.
- **S1 — Entitlement core.** Product, plan-entitlement, tenant-entitlement (with source) and audit models + server-side entitlement check service + denial-to-store behaviour. Tests proving §6.1–6.3. PR it.
- **S2 — Console management.** §8 surfaces complete (products, pricing, plans, grants, audit views). PR it.
- **S3 — Storefront.** §5.1–5.3 (catalogue, categories, search, product detail with real price maths). PR it.
- **S4 — Purchase & provisioning.** §5.4–5.7 checkout, payment wiring (existing billing), auto-activation, invoices, lifecycle incl. dunning reuse. PR it.
- **S5 — Gating sweep.** Every existing app/integration surface passes through the entitlement check; trial set enforced; per-user seat display. PR it.
- **S6 — Existing-tenant migration.** Every current tenant (starting with Rektrs) is mapped to entitlements that preserve everything they use today. Nobody loses a working feature through this migration — any case where that would happen is flagged by name for the owner BEFORE it is applied. PR it.

Each phase: branch → PR → tests/evidence in the PR description → report in `docs/execution/` → continue on Muse's signal comment. Do not merge your own PRs unless the standing rule for that PR says so; merging remains as previously instructed.

## 10. Acceptance criteria (all must be provable, with evidence)

1. A tenant on a plan without Product X: X is absent from navigation, and a direct API call to X is denied server-side with a route to X's Store page.
2. Buying X from the Store at N users shows the correct total before payment, and after payment X is usable in the same session with no deploy/restart/manual step.
3. Cancelling X keeps it working until period end, then locks it; data intact; re-buying restores full access to the same data.
4. Changing X's price or moving X between plans in the console changes the Store and tenant entitlements with no code change.
5. Trial tenant can use ONLY Sales & Invoicing, Inventory and POS; everything else denies per criterion 1.
6. A purchased integration activates only with the tenant's own credentials and fails loudly on wrong credentials (§7.3).
7. Every entitlement change (plan, purchase, expiry, console grant/revoke) appears in the audit log with source and actor.
8. Rektrs (existing tenant) after S6 uses everything it uses today, unchanged.
9. All new surfaces pass in dark + light mode and in RTL, using only Dreams Core Tailwind design as shipped (flag list shows zero invented design elements).
10. No tenant-visible surface exposes ERPNext/Frappe internals.

## 11. Hard rules

- No invented design, no invented features, no fake data or fake transactions — flag instead.
- No parallel billing system; reuse and extend the existing one, flag conflicts in writing.
- No manual activation steps for tenants, ever; no engineering-in-the-loop purchases.
- Compliance belongs to the client (service-provider principle) — never build identity/compliance gates into onboarding or the Store.
- Do not break existing tenants; S6 grandfathering is mandatory, not optional.
- Keep looping. A blocker that is genuinely owner-only gets named exactly, once, on the PR/docs — then build everything that does not depend on it.

**End of instruction. Begin with S0 and report through GitHub as per protocol.**
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
