# Operqon R4 — Actionable Owner Console (spec for ChatGPT, from Assad via Muse, 2026-11-06)

## Why

R3 is live and both sign-ins work (customer portal + owner console). But the owner console at
control.operqon.cloud is REVIEW-ONLY by design: the owner can see the tenant list and nothing else —
no buttons, no actions ("Review-only access — No approval, provisioning, payment or customer-side
actions are available"). The owner cannot move a tenant forward. Every action endpoint already exists
in the provider API (verified live 2026-11-06); what is missing is the console UI that calls them,
plus the per-role operator logins. R4 is therefore a frontend + identity release. Treat any API gap
you find as a listed bug fix, not a silent contract change.

## Hard rules (standing directives, apply in full)

1. Deploy COMPLETE and LIVE — no feature shipped disabled/blocked/"not enabled". Anything needing a
   key/secret goes through configurable env vars/secrets.
2. Existing strict contracts are frozen: the tenant-queue row is EXACTLY 7 keys
   (tenant_id, slug, status, plan_code, industry_code, email_verified_flag, payment_verified_flag)
   and the envelope exactly {status, limit, items}. R3 fix #7 restored this — do not regress it.
   The console's strict client validators stay strict.
3. Acceptance MUST include a real headless-Chromium browser E2E (the R3 lesson): sign in to
   control.operqon.cloud with MFA for each role used below and render + act, and re-run the
   customer-portal sign-in E2E. HTTP-200-only checks are not acceptance.
4. Same delivery format as R2/R3: release ZIP + MANIFEST.sha256, deploy / acceptance / rollback
   scripts, unit tests, additive migrations only if unavoidable (prefer none).

## What to build — console actions wired to the EXISTING API

Session: reuse the current OIDC + PKCE + MFA adapter unchanged (issuer operqon-provider realm,
client operqon-owner-console, acr=2). The API enforces EXACTLY ONE operqon role per token; the owner
will hold separate logins per role. The console must therefore:
- show the signed-in account + its role,
- enable only the actions that role may perform, and for the rest show a clear inline note naming
  the role login required (no dead buttons, no silent failures),
- make sign-out / switch-account one click.

Screens/actions (endpoint + required role, all verified in the live API):
1. Tenant review (exists) + tenant detail: GET /api/v1/provider/tenants/{tenant_id} (operator+).
2. Verify email: POST /api/v1/provider/tenants/{tenant_id}/verify-email — role operqon:identity.
3. Identity review: GET /api/v1/provider/identity/review-queue and
   POST /api/v1/provider/tenants/{tenant_id}/identity-review (decision + notes per the existing
   payload model) — role operqon:identity.
4. Tenant approve / reject: POST /api/v1/provider/tenants/{tenant_id}/approve and /reject —
   role operqon:approver.
5. Pricing: GET /api/v1/provider/commercial/pricing-proposal (read),
   PUT /api/v1/provider/commercial/pricing-proposal/{proposal_id} (draft edit) — role operqon:billing;
   POST .../approve — role operqon:pricing_approver.
   Pricing content is ALREADY DECIDED by the owner (do not invent values): multi-currency per
   country; Pakistan (PKR) list — Starter Rs 7,500/mo (yearly Rs 75,000), Growth Rs 9,999/mo
   (yearly Rs 99,990), Business Rs 19,999/mo (yearly Rs 199,990); tax-EXCLUDED; trial 3 days
   (already in plan rows). R4's job is the screens + flow so the owner can enter/approve these
   through the UI — do not seed or hard-code prices in code.
6. Billing: invoices list/create/issue (GET/POST /api/v1/provider/billing/invoices, /issue),
   Stripe/JazzCash checkout actions where the API exposes them, manual-bank claims queue with
   approve/reject incl. the five bank-credit evidence fields (the statics already contain the
   BankAdminClient in client.mjs — wire its page), offline-approve endpoint — roles per API
   (billing / approver as gated). Gateway secrets stay env-configured (merchant.env); missing
   gateway config must surface as a clear "gateway not configured" state in the UI, never a
   disabled feature.
7. Provisioning: GET /api/v1/provider/provisioning, POST /provisioning (create),
   /provisioning/{job_id}/approve, /execute, /publish, /cancel, rollback-request/rollback-approve —
   roles per API gates; wire all of them with status display from the job records.

## Identity prep (done by Muse on the server, not part of the ZIP)

Muse creates the Keycloak realm roles operqon:identity, operqon:approver, operqon:billing,
operqon:pricing_approver and one owner login per role (operqon-identity, operqon-approver,
operqon-billing, operqon-pricing), each with first-login required actions UPDATE_PASSWORD +
CONFIGURE_TOTP so the owner sets his own passwords/MFA. Your console must work with these
usernames/roles exactly (roles arrive in the token's `roles` claim via the existing realm-role
mapper).

## Acceptance (all must pass live, owner-verifiable)

1. Operator login → tenant list renders (3 requested tenants) — regression of fix #7.
2. Identity login → identity review of tenant "demo2" recorded from the UI.
3. Approver login → demo2 approved from the UI; status change visible in queue + customer dashboard.
4. Billing login → pricing draft entered with the decided PKR values; pricing_approver login →
   proposal approved; customer portal plans then show the approved prices (no longer null).
5. Provisioning flow for demo2 reachable from the UI up to the point the existing executor allows;
   every step's state visible. (Payment-gateway live checkout depends on merchant credentials the
   owner will supply separately — the UI must reach the checkout action and report gateway state
   truthfully.)
6. Customer portal sign-in E2E still passes; owner-console sign-in E2E passes for every role login.

## Non-goals

- No redesign of the customer portal (R3) beyond regression fixes.
- No changes to the public intake page.
- No new payment gateways in R4 (Stripe/JazzCash already in API; Easypaisa/PayFast config-only
  as before).
