# Operqon — Super Admin (Provider Console) — Complete Features & Workflows

**Prepared:** 2026-11-13, by Muse, on the owner's request.
**Scope:** the Super Admin = Operqon's Provider Console (control.operqon.cloud) — the
operator side that runs the whole SaaS. (Each tenant's *own* admin is a separate layer —
see Part F.)
**Status key:** **Live** = running today · **Designed** = HTML design page built in the v3
programme · **Specified** = in Blueprint v3 / KB, build pending · **Suggested** = Muse's
addition in Part D (not yet an owner decision).
**Sources:** v3 knowledge-base FEATURES.md (45-feature inventory); Blueprint v3 SCR
register (provider console = SCR-123…151, 28 screens); console issue-resolution spec
(2026-11-10); Enterprise programme coverage matrix; Zoho One Admin Panel / Zoho
Directory public documentation (for Part D comparison).

---

## Part A — The agreed 45 features (8 sections)

### 1. Command (3)
1. Overview — MRR, tenant counts, provisioning health [Designed; figures Live in records]
2. Live Monitor [Designed]
3. Alerts [Designed]

### 2. Tenants (6)
4. Tenant list — 7 statuses, search/filter [Designed; Live in MVP6 console]
5. Tenant detail — health, plan, site, users, suspend/activate [Live]
6. Approvals queue [Designed]
7. Review queues — price proposals [Live]
8. Billing & provider invoices (+ bank-transfer instructions setting) [Live]
9. Tenant apps & seats oversight [Specified]

### 3. Servers & Scaling (6)
10. Servers list + live capacity [Designed]
11. Add server [Specified]
12. Bind server — role/region + verification checks [Designed]
13. Bindings map + move/rebind [Specified]
14. Capacity report & scaling warnings [Designed]
15. Scale actions [Specified]

### 4. VPS & Services (5)
16. Host metrics + UFW status [Specified]
17. Service control — restart/logs/toggle: provider daemon, pairing worker, Keycloak, Caddy, benches [Specified]
18. Deploy release [Specified as a screen; the deploy pipeline itself is Live]
19. Brevo SMTP status + send-test [Specified]
20. Dokploy access [Specified]

### 5. Benches, Backups, Domains (8)
21. Benches — current image / rollback image [Designed]
22. Deploy history + verification status [Designed]
23. One-click rollback [Designed]
24. Pre-deploy snapshots [Designed]
25. Backups — schedule + "Back up now" [Designed; backups themselves Live: R2 snapshots mirrored to B2, restic-verified]
26. Restore — owner-confirmed, audited [Designed]
27. Domains — tenant subdomains [Designed]
28. SSL status/expiry — Caddy auto-certs [Designed]

### 6. Platform (7)
29. Jobs & queues + failed-job retry [Designed; queues Live]
30. Service logs (in-panel) [Designed]
31. Audit trail [Designed; audit substrate Live]
32. Rate card — per-app / per-integration prices [Designed; governed proposal route Live]
33. Console settings [Designed; key settings Live]
34. Team access & roles [Designed; role accounts Live in Keycloak]
35. Danger zone — reboot/stop services, owner-only, confirmation + audit [Designed]

### 7. Identity & SSO (4) — owner directive 2026-11-12: all Keycloak admin from the Console frontend, no terminal routes
36. Realms overview — user counts, login themes, discovery health [Designed]
37. Users per realm — search, create, enable/disable [Designed]
38. Guarded delete — census, protected accounts, typed confirmation, automatic backup, read-back [Designed; the flow itself was executed owner-run 2026-11-12]
39. Identity settings — login themes, SSO session/token policy, console operations (bootstrap) account + credential rotation [Designed]

### 8. Managed VPS (6) — owner directive 2026-11-12: everything a managed VPS needs, in the Console
40. OS & package updates — security auto-updates, maintenance window, snapshot-before-update [Designed]
41. Snapshots & rollback — guarded, with post-rollback login verification [Designed]
42. Restart services — Caddy, Keycloak, daemon, worker (full reboot stays in Danger zone) [Designed]
43. Firewall — UFW rules, guarded port opening [Designed]
44. Fail2ban — jails, banned IPs, unban [Designed]
45. Database & cache — DB health/size/backup/optimize, Redis purge, disk + bench-image housekeeping [Designed]

---

## Part B — Blueprint-specified console screens beyond the 45

From the Blueprint v3 provider-console register (SCR-123…151). Several of the Part D
suggestions were already anticipated here — they are listed in this part, not as new ideas.

- **Pack release registry** (SCR-128) — versioned tenant app-pack releases, rollout state.
- **Country readiness registry** (SCR-129) — per-country compliance pack status (PK live; KSA/ZATCA etc. as packs land).
- **Incident center** (SCR-130) — beyond the Alerts list: incident lifecycle, assignment, timeline.
- **Customer communication** (SCR-133) — messaging tenant admins from the console.
- **Partner submissions** (SCR-134) — inbound partner/reseller applications.
- **SaaS unit economics & MRR cockpit** (SCR-135) — MRR/ARR, growth, plan mix (overview screen, analytics depth).
- **Tenant health & retention radar** (SCR-136) — health scoring, churn-risk list.
- **Dunning policy studio** (SCR-137) — reminder sequences, grace rules, auto-suspend policy per plan.
- **Per-tenant cost-to-serve** (SCR-138) — infra cost allocated per tenant vs revenue.
- **Feature flag & canary manager** (SCR-139) — per-tenant/per-plan flags, gradual rollout.
- **Partner & reseller administration** (SCR-140) — partner accounts, attribution, commissions.
- **Support session audit timeline** (SCR-141) — every support access to a tenant, on one timeline.
- **Clean template & warm pool controller** (SCR-142) — pre-provisioned clean sites for instant activation.
- **Regional migration planner** (SCR-143) — move tenants between regions/servers as a planned job.
- **Webhook & outbox recovery center** (SCR-144) — failed webhooks/outbox messages, replay.
- **Product changelog & broadcast studio** (SCR-145) — announcements to tenants, release notes.
- **Enterprise deal desk** (SCR-146) — negotiated enterprise terms as special proposals (extends the pricing-proposal flow).
- **Sanitized staging clone planner** (SCR-147) — clone a tenant to staging with PII scrubbed, for debugging.
- **Abuse & bot controls** (SCR-148) — signup abuse signals, rate limits, blocklists (today Cloudflare-side only).

(SCR-123, a single "tenant review queue", is RETIRED — the live design uses role-separated
queues instead. SCR-124/125/126/127 — tenant operations detail, provisioning job console,
price proposal review, manual payment review — are the Live core inside Part A.)

---

## Part C — Core workflows

**W1 · Tenant onboarding & provisioning (fully automatic)**
Signup → email verification → plan selection → invoice → payment → provisioning job
(clean template → site + DB + admin user) → site live → welcome/SSO enabled.
No human step except W2's payment verification when the tenant pays by bank transfer.
Live evidence: Rektrs, demo2, Rams all completed this chain.

**W2 · Manual payment verification (bank transfer)**
Invoice issued with console-held bank instructions → tenant pays and claims payment →
billing role checks the bank/Faysal record → **billing_approver** approves (a different
person than the checker — SoD) → subscription activates → provisioning proceeds.
Operqon's own money is the only human-approved step in onboarding.

**W3 · Provisioning failure resolution (the Rams workflow)**
Job fails → failure-detail view (step, reason, attempt count) → **diagnose** →
**retry** (same idempotency key) → if a partial site exists, **adopt** the orphan and
**complete** → if unrecoverable, **rollback-for-failed** + operator attestation →
manual-review queue where a human approves or rejects with a recorded reason.
Attempt cap (currently 6) with escalation to the Issues inbox when exhausted.
Governance rule (owner): no manual reconciliation outside this flow, ever.

**W4 · Pricing & rate-card governance**
Pricing role drafts a **whole new proposal** (plans, per-app and per-integration rates,
seat prices) → system shows the diff vs the live version → approver approves or rejects
→ approved version becomes live for new activations/renewals only; existing tenants keep
their contracted prices. Prices are never edited in place. (Live: PK v1 proposal is the
only approved version; the D-EP-008 per-app draft awaits this route.)

**W5 · Subscription lifecycle**
Trial (3 days; free set = Sales & Invoicing, Inventory, POS; paid apps + integrations
locked) → conversion on payment → active → renewal invoice → payment failure → grace
period → dunning reminders (W-Part B studio) → suspension (site read-only/blocked,
data retained) → reactivation on payment → cancellation → retention window → verified
deletion.

**W6 · Tenant suspension / reactivation (manual)**
Operator opens tenant detail → suspend with a recorded reason (non-payment, abuse,
owner request) → tenant notified → audit event. Reactivation reverses it in one action,
also audited. Used for cases outside W5's automatic path.

**W7 · Release deploy & rollback**
Build gate (full test suite + image verification) → pre-deploy snapshot → swap
(backend + frontend + worker together) → smoke battery → any failure triggers the
rollback trap (previous image restored + old-behaviour probe). Console side: deploy
history with verification status, one-click rollback to the retained previous image.

**W8 · Backup & restore**
Weekly automatic snapshots + pre-deploy snapshots + on-demand "Back up now" → off-site
mirror (B2) → integrity verification (restic check) surfaced in the console.
Restore: operator selects the snapshot → **owner confirmation** → restore → post-restore
smoke/login verification → audit event. 

**W9 · Identity operations**
Create/enable/disable realm users from the console → password/MFA reset assistance →
**guarded delete**: census of what the account owns → protected-account check (demo,
demo1, pilot3-class accounts can never be deleted) → automatic JSON backup export →
typed confirmation → delete → read-back verification. Credential rotation for service
(bootstrap/executor) accounts on a schedule, from Identity settings.

**W10 · Scaling**
Capacity report raises a warning → add server (provider, region, size) → bind server
(role: bench/API/DB; verification checks must pass) → deploy a bench → move/rebind
tenants (planned job, tenant notified) → capacity report re-verified.

**W11 · Gateway & integration settings (provider-level)**
Operator opens the settings card (Easypaisa, PayFast, Brevo, B2…) → enters credentials
(write-only; the owner enters merchant secrets himself) → encrypted at rest → masked
read-back (last 4 only) → connection test → audit event. A setting can be disabled
without deleting its credentials.

**W12 · Issues inbox (in-console issue resolution — owner directive 2026-11-10)**
Every operational issue class (provisioning, payments, email delivery, SSL, jobs,
backups) lands as an Issue with full context → triage by severity → the resolution
action runs **inside the panel** (retry, resend, re-issue, rollback, restore…) →
resolution note → audit. Only a class with no in-panel remedy escalates to engineering,
with the issue record attached. The admin team should never need this chat or a
terminal for a known issue class.

**W13 · Danger-zone actions**
Reboot server / stop a core service → owner role only → typed confirmation naming the
target → audit event before and after → automatic health re-check with the result
posted back to the console.

**W14 · Trial & abuse governance**
Signup signals (repeat emails/domains/IPs, disposable domains) → risk flag on the
tenant → operator reviews in the abuse console → allow, restrict (no trial extension),
or block → audit. Feeds the Part B abuse controls.

---

## Part D — Muse's suggestions (Zoho-inspired + SaaS-provider practice)

Compared against the **Zoho One Admin Panel / Zoho Directory** model (Dashboard ·
Directory · Applications · Security · Devices · Domains · Integrations · Reports/Audit ·
Subscription; roles: Super Admin, Org Admin, Helpdesk Admin, Security Admin, app
admins, delegated admins) and standard multi-tenant SaaS operations. Items already in
Blueprint Part B are not repeated here.

### D1 · Admin governance
1. **Second super admin + break-glass account** — Zoho's own standing advice: at least
   two super admins plus a sealed break-glass credential, so the platform is never
   locked to one person's availability. (Today Operqon deliberately runs one owner
   login "abhi k liye" — this is the documented next step when the team grows.)
2. **Delegated admins** — scope an admin to a section (billing-only, support-only) or a
   tenant group, instead of all-or-nothing roles. Extends the existing 6 role accounts.
3. **Helpdesk admin role** (Zoho pattern) — password/MFA resets and user info edits
   without billing or infrastructure rights.
4. **Admin access review** — a quarterly screen listing every admin, role, last login
   and dormant accounts, with one-click revoke; the review itself is audited.
5. **Step-up authentication for sensitive actions** — extend the console's existing
   LoA2 pattern to restores, guarded deletes, danger-zone actions and rate-card
   approval (re-authenticate within the session before the action runs).

### D2 · Security centre (provider side)
6. **Security policies page** (Zoho pattern) — password policy, allowed MFA methods,
   session lifetime, idle timeout for console admins, in one governed screen.
7. **Console IP allowlist** — restrict console sign-in to office/VPN IPs, with a
   break-glass exception path.
8. **Admin session management** — view all active admin sessions (device, IP, age) and
   revoke any of them.
9. **Provider-side sign-in monitoring** — failed-login and password-spraying alerts for
   the provider realm (the tenant side already has this pattern; the console deserves
   the same).
10. **Service-account registry** — every executor/bootstrap/API account in one list:
    purpose, scope, owner, last-used, last rotation; rotation reminders.

### D3 · Support & tenant success
11. **Governed support session (impersonation)** — an operator can enter a tenant's
    admin view only through a time-boxed grant (tenant-approved, or owner-approved for
    emergencies), with a visible banner in the tenant UI and the whole session on the
    SCR-141 audit timeline. This is how Zoho-class support works without sharing
    passwords.
12. **Support tickets in console** — portal-raised tickets visible per tenant with SLA
    timers and assignment (the portal side already has ticket screens designed).
13. **Tenant onboarding checklist tracker** — per tenant: verified → paid → live →
    first invoice issued → apps activated; stalled tenants surface on the Overview.

### D4 · Commercial
14. **Coupons & promotions** — discount codes (% or fixed, plan-scoped, validity,
    usage caps) applied at signup/invoice; today there is no discount mechanism at all.
15. **Credit notes & provider refunds** — a governed flow to credit or refund a tenant
    invoice (the tenant-side refund machinery exists; the provider's own billing needs
    its equivalent).
16. **Revenue analytics depth** — churn rate, ARPU, trial→paid conversion, cohort
    retention on the MRR cockpit (SCR-135), exportable for the company's own accounts.

### D5 · Platform operations
17. **Maintenance mode & scheduled windows** — platform-wide or per-bench maintenance
    with automatic tenant notice before, during and after (uses the broadcast studio).
18. **Public status page** — a tenant-visible status page fed by the incident centre
    (uptime, active incidents, scheduled maintenance).
19. **Alert rules builder** — thresholds on any console metric (queue depth, disk,
    backup age, failed jobs) → email/webhook. This closes the still-empty backup-alert
    webhook as a by-product.
20. **Scheduled ops digest** — daily/weekly email to the admin team: signups, revenue,
    failures, capacity, pending approvals.
21. **Platform event webhooks** — tenant.created, payment.failed, tenant.suspended…
    for external systems (accounting, CRM) — provider-level, distinct from tenant
    webhooks.

### D6 · Data & compliance
22. **Audit-log export & retention** — export the audit trail (CSV/JSON) and set
    retention per category; today the trail is view-only.
23. **Tenant offboarding workflow** — export archive for the departing tenant →
    cooling period → verified deletion with a deletion certificate in the audit trail.
24. **Backup verification board** — per backup set: last successful restore-test and
    integrity-check result, so "backups exist" becomes "backups proven".

---

## Part E — Recommended priority (Muse's order, for whenever the programme resumes)

1. Issues inbox depth (W12) — it is the owner's standing directive and removes the
   most escalations.
2. Incident centre + alert rules builder (SCR-130 + D5-19) — today alerting depends
   on an owner-held webhook URL that is still empty.
3. Governed support session (D3-11) + support audit timeline (SCR-141) — support
   quality without credential sharing.
4. Dunning policy studio (SCR-137) — revenue protection, fully automatable.
5. Broadcast studio + customer communication (SCR-145/133) — maintenance and release
   communication is currently manual.
6. Feature flags & canary (SCR-139) — safer releases for every future change.
7. Tenant health & retention radar (SCR-136) — churn is cheaper to prevent than win back.
8. Coupons & deal desk (D4-14 + SCR-146) — sales flexibility through governed routes.
9. Warm pool (SCR-142) — signup-to-live time drops to seconds when sales volume comes.
10. Security centre pack (D2) — before the admin team grows beyond the owner.

---

## Part F — The other "super admin": tenant-side administration

Each tenant's own admin (e.g. a customer's owner login inside their ERP) mirrors the
Zoho *organisation admin*: users/groups/roles, per-app assignment, security policies
(password/MFA), audit log, subscription & seats view, data import/export. Blueprint v3
carries this as **Tenant administration = 43 screens (SCR)**, separate from the provider
console above. It is listed here only so the two layers are never confused: this
document governs the **provider** Super Admin.

---

*End of document. Parts A–C record what was discussed, designed or built up to
2026-11-13. Part D is Muse's suggestion list, prepared at the owner's request; none of
it is an owner decision until he approves it. The Operqon programme is currently
stopped by the owner's order; this document is a planning input for its resumption
(and for the Cursor agent now holding the handover branch).*
