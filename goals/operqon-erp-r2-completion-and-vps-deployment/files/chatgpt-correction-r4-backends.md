# R4.1 Correction Assignment — Complete the two missing backends (from Muse's verified R4 review, 2026-11-06)

Muse has completed a full local verification of Operqon_R4_Actionable_Owner_Console.zip. Verified CLEAN: MANIFEST 128/128 hashes OK; tests genuinely 72 passed / 3 skipped (disposable-PostgreSQL gates, by design); deploy/acceptance/rollback scripts free of every known R2.1/R3 bug pattern; the frozen 7-key tenant-queue contract is intact on BOTH sides (API projects exactly 7 keys; console validates exactly 7); NO feature is flag-disabled (config forces provisioning/paid activation True — keep it that way). ChatGPT's own admissions in docs/R4_OWNER_CONSOLE.md were checked against the code and are ACCURATE. The release is therefore NOT complete under the owner's standing directive (every release complete and live, nothing blocked/missing). Build R4.1 with the following, as one backend completion release on top of R4:

## 1. Bank-claim rejection (gap a — currently approve-only, schema-forbidden)
Current state proven from code: CustomerPaymentNotice carries CheckConstraint("status = 'pending_verification'") (app/models.py:269) so no other outcome can exist; the only resolution path is POST /billing/invoices/{id}/offline-approve (operqon:billing_approver); there is no provider-side list endpoint, no reject endpoint, no console reject action.
Required:
- Migration (alembic 0008) relaxing the pending-only constraint: claim lifecycle pending_verification → verified / rejected, with actor, timestamp and a REQUIRED rejection reason recorded (audit trail, same standard as other provider actions).
- Provider endpoint to LIST payment notices (role-gated; contact/bank details only to the roles already entitled to see them).
- Provider REJECT endpoint for a payment notice, gated to operqon:billing_approver, audited, reason required; a rejected claim must NOT settle the invoice and must leave the invoice payable by another method; re-submission of a new claim on the same invoice must remain possible.
- Owner console: a bank-claims view listing pending claims with BOTH actions — "Verify bank credit" (existing) and "Reject" with a reason field — wired to the real endpoints.
- Tests: reject happy path, reject without reason rejected (4xx), wrong-role reject denied, rejected claim does not settle/provision, new claim after rejection works. Negative tests are mandatory.

## 2. Per-country pricing backend (gap b — currently one global price set)
Current state proven from code: PricingProposal and Plan each carry a single currency (app/models.py:141/54); update validates ONE currency in {PKR, SAR} for all tiers (app/main.py:993); approve applies that one currency to every plan (main.py:1026). The owner's decided model is multi-currency PER COUNTRY.
Required:
- Schema + migration: a country dimension for pricing — per-country proposal(s) so a Pakistan (PKR) price set and another country's set can coexist; invoices inherit the price set of the tenant's country. Keep the internal plan code "enterprise" with customer-facing name "Business" (compatibility rule unchanged).
- API: pricing draft update + approve operate PER COUNTRY (billing drafts, pricing_approver approves — same role split as now); reading pricing returns the country-scoped set.
- Owner console: country selector on the pricing screens; the decided Pakistan values are entered through this approver flow by the owner (NEVER seeded/hard-coded — that rule is unchanged): Starter Rs 7,500/mo, Rs 75,000/yr; Growth Rs 9,999/mo; Business Rs 19,999/mo; tax-excluded; 3-day trial.
- Tests: two countries' proposals coexist independently; approving one country does not alter another; invoice currency follows tenant country; single-country behaviour for existing PKR flow still passes.

## 3. E2E acceptance alignment (deploy gate)
- The automated per-role MFA browser acceptance must cover SEVEN roles: the current six (OPERATOR, IDENTITY, APPROVER, BILLING, PRICING, PROVISIONER) PLUS BILLING_APPROVER, and for billing_approver it must exercise the real actions: Verify bank credit AND the new Reject flow (against the disposable/test tenant data only). Today the headline billing action is not exercised by any automated gate — that must not recur.
- Keep the mandatory rule: every release ships only after a real MFA browser E2E against the actual console build, asserting the 7-key queue envelope live.

## 4. Phase-1 gateway completeness (inherited R2 gap — state it, do not hide it)
Stripe and JazzCash have adapters; Easypaisa and PayFast are catalogue-only (payment_policy marks them merchant_contract_required; no adapter, no checkout endpoint). Phase 1 was decided as Stripe + JazzCash/Easypaisa + PayFast. Either (preferred) include the Easypaisa and PayFast adapters + hosted-checkout endpoints + verified-webhook handling in R4.1 (credentials strictly via merchant.env / secret files; absence of credentials may report "not configured" but must not disable code paths), or state explicitly in the R4.1 reply that they are delivered as the immediately following release and why. Silently leaving them catalogue-only while calling Phase 1 complete is not acceptable.

## Frozen rules (unchanged)
- 7-key tenant-queue contract frozen, both sides.
- No feature disabled or blocked by flags; missing credentials go via env vars/secret files only.
- No prices seeded or hard-coded; pricing only via the authenticated approver flow.
- Do not touch production, ERPNext, Demo/Pilot/RC2, or the R1 stack; delivery is a release package (and, per the new GitHub rule being set up in parallel, be ready to deliver the same changes as a branch/PR against the GitHub repo when Muse confirms the reconciled baseline branch).
- Ship with MANIFEST.sha256, full test results (including the new tests), deploy/acceptance/rollback scripts free of the known R2.1/R3 bug patterns, and a statement of exactly what remains unverified live.
