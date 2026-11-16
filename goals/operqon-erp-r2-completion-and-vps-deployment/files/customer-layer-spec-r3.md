# Operqon R3 — Customer Layer spec (for ChatGPT, ERP-CUSTOMIZATION project)

Prepared by Muse, approved by Assad 2026-11-06 ("Pehle customer layer banao —
signup, signin, dashboard"). Assad's words: the public site today is "simple sa
HTML page"; we set out to build a Zoho-class product. R2/R2.1 built the engine
(provider API, billing lifecycle, provisioning executor, public intake). R3
builds the customer's face of the product. Same release discipline as R2.1:
ZIP + MANIFEST.sha256 + full tests + deploy/acceptance/rollback scripts,
NOTHING disabled — missing credentials (SMTP, gateways) are env-configured
and the manual paths must work without them.

## What exists (build on it, do not rebuild)
- Provider API R2.1 live on 127.0.0.1:18090 (R1 18089, legacy 18087 preserved).
- Tenant lifecycle already in the API: requested -> verify-email ->
  identity-review -> approve/reject -> payment -> provisioning -> live site.
  Public intake (R2.1) creates "requested" tenants; the Owner console queue
  shows them via the existing tenant_row contract.
- Keycloak runs the provider console's auth (login.operqon.cloud). ERPNext
  v16 staging bench + provisioning executor are live and verified.
- Portal design system: /srv/operqon-public-portal/current assets
  (site.css, operqon-tokens.css, brand SVGs) — reuse it exactly.
- Assad's approved pricing (2026-11-06): multi-currency per country; PKR
  Starter 7,500/mo (yearly 75,000), Growth 9,999/mo, Business 19,999/mo;
  tax-EXCLUDED; trial 3 DAYS; manual-bank approver = Assad (admin). Prices
  enter via the pricing-proposal flow; the customer layer must READ plan
  data from the API (never hardcode prices in pages).

## R3 scope
1. **Customer identity**: a customer realm/client in the existing Keycloak.
   Operqon-branded sign-in / sign-up / forgot-password pages in the portal
   design (Keycloak theme or portal pages driving OIDC authorization-code
   flow — your call, but the customer must never see a stock Keycloak page).
   No custom password store.
2. **Sign up flow**: the public Request Access form becomes step 1. On submit
   it creates the tenant request (existing intake) AND a customer account;
   the customer sets a password and verifies email (verification email via
   env-configured SMTP in Keycloak; if SMTP is not configured the account is
   still created and verification can be completed by the operator — no
   feature switched off). The customer can sign in immediately and watch
   their request status.
3. **Customer dashboard** (authenticated, strictly tenant-scoped — a customer
   can only ever see their own tenant; add the customer-scoped API endpoints
   needed, with cross-tenant access tests):
   - Status tracker for their request: Requested -> Email verified ->
     Identity review -> Awaiting payment / Approved -> Provisioning ->
     Live, mapped to the EXISTING lifecycle states (no parallel states).
   - My site: site URL, plan, trial state with the 3-day trial countdown
     once provisioned, users used vs plan max_users.
   - Plan & billing: current plan from the API, invoices list, "Pay now"
     via hosted checkout when a gateway is configured, manual-bank
     instructions + a "payment sent" action that leaves the tenant PENDING
     until the approver verifies (existing rule).
   - Launch app: one-click SSO from the dashboard into their ERPNext site
     (Frappe OAuth/OIDC against the same Keycloak) — no second password.
   - Team (read-only in R3): list their site's users.
4. **Owner console cutover**: control.operqon.cloud moves from the R1 API
   (18089) to R2.1 (18090) as part of this release's deploy, with whatever
   console frontend updates R2 endpoints require (the intake requests must
   appear in the Owner Tenant Review — they already use the same contract).
   R1 stays running for rollback.
5. **Design**: portal design system, responsive, same quality bar as the
   console; pages must work without JavaScript framework build steps
   (server-rendered or the existing mjs pattern).

## Out of scope for R3
Team invitations/management writes, in-dashboard plan change checkout
(beyond Pay now for the current plan), business-type modules (later
releases), any change to ERPNext core.

## Tests / acceptance (all must run green in the deploy)
- Full suite in the isolated test container, including NEW tests:
  customer A cannot read customer B's tenant/invoices (403/404), signup
  creates exactly one tenant + one account, duplicate signup -> 409,
  dashboard status mapping matches lifecycle states, migration (if any) on
  REAL PostgreSQL (the deploy runs it against the live DB with backup, as
  in R2.1 — and the test suite must include the real-PG test actually
  executing in the deploy's disposable-database step if one is added).
- Deploy script: preflight, root-only backup, tests, build, migrate,
  recreate, readiness, Caddy changes, acceptance, automatic rollback —
  same pattern as R2.1. NOTE the R2.1 lessons (fold the six deployed fixes
  in from the start): check config paths under deploy/, overlay file/dir
  permissions readable by the non-root test user, --no-cache on the test
  image build, no host Node.js assumption, readiness probe syntax-checked
  by actually running it.
- Reply discipline: deliver the ZIP with a SHORT note only (long replies
  have repeatedly died at delivery). If a decision is needed, use the
  defaults in this spec and note the assumption in one line.
