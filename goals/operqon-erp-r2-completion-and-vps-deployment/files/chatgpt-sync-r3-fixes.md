# ChatGPT sync pack — Operqon R3 deploy + sign-in fixes (for the "Master Copy Tasdeeq" chat)

Prepared: 2026-11-06 ~19:32 PKT by Muse (research stage).
Why: the R2.1 sync was posted and confirmed in the new ERP chat "Master Copy
Tasdeeq" at ~17:35–17:44 PKT (hashes verified, 6 fixes + pricing recorded).
Since then R3 was deployed LIVE (~18:56 PKT) and Muse fixed FIVE more things
on the live system that ChatGPT's master copy does NOT yet contain. Assad's
standing directive (2026-11-06 ~15:22 PKT) is that Muse applies small fixes
himself and updates ChatGPT afterwards — this pack is that update. Do NOT wait
for another correction-ZIP round; these are master-copy corrections only.

## Where to send it

The ERP-CUSTOMIZATION project's NEW working chat "Master Copy Tasdeeq"
(the old "Continue Development Phase" chat hit maximum length):
https://chatgpt.com/g/g-p-6ae4d88025dc819189863f28aef8b740-erp-customization/c/6aedcb75-1288-83ed-9fb1-7ef55c4c88ea

Keep the message SHORT — long ChatGPT replies have twice died at delivery
with "Message delivery timed out" (R2 and R2.1). Post the text below, in one
message. No files need attaching for this sync (no new deploy script was
written for fixes 4–5; they were live-system fixes — see each fix).

## Message to post to ChatGPT (copy verbatim)

---
R3 is deployed LIVE and working — please fold these FIVE fixes into your
master copy so the next release ships with them. All five were found and
fixed by Muse during/after the R3 deploy; none of them is in the R3 ZIP.

R3 deployed: Operqon_R3_Customer_Layer.zip, 57 tests passed / 3 skipped,
8/8 acceptance checks passed on run 3 after two clean automatic rollbacks.
API image operqon/provider-api:r3-customer on 127.0.0.1:18090.

FIX 1 — Acceptance script must log WHICH check failed.
The first R3 deploy run failed its final acceptance check and rolled back
cleanly, but the script did not say which check failed. Fix: instrument the
acceptance script so every check logs its own pass/fail by name.

FIX 2 — Customer portal folder permissions 0700 caused 403.
The deploy script installed the /customer/ pages correctly but left their
folder at 0700, so Caddy could not serve them and operqon.cloud/customer/
returned 403 (all other checks passed). Fix: set portal/customer directories
to 755 in the deploy script (same class of bug as the R2.1 overlay-dirs fix).

FIX 3 — Login host must expose ONLY the customer realm.
The login host (login.operqon.cloud) exposes /realms/operqon-customers/*
only; the staff/provider realm and master/admin stay private (404). Make
sure the R3 Caddy/realm-import steps create exactly that route.

FIX 4 — CSP connect-src must include login.operqon.cloud.
The apex CSP header allowed connect-src https://operqon.cloud only. The
browser at /customer/callback.html must call the Keycloak token endpoint on
login.operqon.cloud, so sign-in hung on "Completing sign in..." after email
verification. Fix in apply-r3-caddy.sh: connect-src must be
`https://operqon.cloud https://login.operqon.cloud` (live Caddyfile already
fixed this way; backup /root/Caddyfile.pre-csp-fix).

FIX 5 — Keycloak customer client needs the `basic` default scope.
The operqon-customer-portal client's default scopes were only profile +
email, so issued access tokens carried NO `sub` claim and the API rejected
every genuine customer sign-in with 401 "Verified customer sign-in
required" (MissingRequiredClaimError "sub"). Fix: the R3 realm-import
instructions must add the realm's `basic` client scope
(id 47f72bed-b1b1-49d9-83de-eca0c88b59fd) to the customer client's DEFAULT
scopes (defaults must end up: profile, basic, email).

NOTE (not a code fix) — Keycloak email settings are PER-REALM.
The provider realm already had Brevo SMTP, but the new operqon-customers
realm's smtpServer was EMPTY — settings are never copied across realms.
The R3 realm-import instructions must say SMTP has to be configured
separately in the customer realm (same Brevo relay, from
no-reply@operqon.cloud) or the deploy must prompt for it; otherwise
customer verification emails never send.

Please confirm you have recorded all five fixes + the SMTP note in the
master copy. No rebuild or ZIP is needed for this message.
---

## Evidence the fixes work (for the record, not necessarily to post)

- FIX 4 verified live: new CSP header confirmed on /customer/callback.html
  after Caddy validate + reload. Assad's own test (~19:18 PKT, phone
  screenshot) was the first proof email verification itself worked.
- FIX 5 proven end-to-end by Muse with a disposable Keycloak user
  (e2e-test@operqon.cloud): PKCE flow OK, new access token contains `sub`,
  POST /customer/link → 201 {"linked":true}, GET /customer/dashboard → 200
  (stage requested → identity_review, email_verified true, trial_days 3),
  GET /customer/invoices → 200. All test artifacts cleaned up (test user
  deleted, test identity row removed, E2E tenant flags reset).
- Assad's own tenant request — Rektrs Private Limited,
  assadchoudharry@gmail.com, submitted 2026-11-06 17:28 PKT, status
  requested — was untouched by the E2E test and awaits his own sign-in.
  At the time this pack was written his re-test after FIX 5 was still
  pending (main agent asked him to sign in again at ~19:29 PKT).

## Do NOT include

- The Brevo SMTP key value. Assad sent it in chat for one-time use; Muse
  used it transiently and stored it nowhere. Only the per-realm instruction
  above goes to ChatGPT.
- Any other secret, password, token or merchant.env value.

## Limits of this preparation

- Fixes 4–5 were live-system fixes applied by Muse directly (Caddyfile edit
  + Keycloak Admin API call). There is no new deploy-script file to attach;
  ChatGPT must apply them to its own scripts (apply-r3-caddy.sh and the R3
  realm-import steps) from the descriptions above.
- If Assad's pending re-test reports a NEW failure, that failure must be
  added to this list before posting — check his reply in the main chat first.
