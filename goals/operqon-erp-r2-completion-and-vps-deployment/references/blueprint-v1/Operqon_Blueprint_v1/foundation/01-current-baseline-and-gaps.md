# Current baseline: evidence aur gaps

Inspection date: 6 November 2026. Scope: connected GitHub source, current R3 Fix6 release files aur supplied brand assets. Is research mein VPS, production accounts, live tax gateways ya customer data par koi operation nahi hua.

## Evidence register

| ID | Evidence | Observation | Is se kya prove nahi hota |
| --- | --- | --- | --- |
| BASE-01 | `s22benlg1m01140-sudo/operqon-core` main | Commit `991f014a33501b8b6d9202a4cb85d45f2c6f968c`; source tree 199 entries; no repository AGENTS.md observed | Running server isi SHA par hai |
| BASE-02 | Main commit metadata | Main commit date 31 October 2026; tree `84880e903b5708bb4d0138b12d5c99a29463c974` | November release source main mein synchronized hai |
| BASE-03 | Main README/hooks/source docs | Frappe app, Operqon Desk home, provider/entitlement interfaces, private-control separation, release gates present | All workflows connected and live |
| BASE-04 | `Operqon_R3_Customer_Layer_Synced_Fix6.zip` | SHA256 `1c7b00624252916c80f1bc0f48267348f96b9bdb2f18597e804366d3ee6bc4c4`; customer API/portal docs/models inspected | Deployment, real email, SSO and payment success |
| BASE-05 | R3_CUSTOMER_LAYER.md | Release author reports 56 passed, 3 skipped; skipped real PostgreSQL checks require disposable execution | Yeh tests is planning task mein rerun huay hain |
| BASE-06 | R3_LIVE_FIX_SYNC_2026-11-06.md | Strict CSP callback fix and mandatory Chromium OIDC E2E gate described | Gate actual production environment mein pass hua |
| BASE-07 | customer-layer-spec-r3.md | Approved PKR pricing, 3-day trial, customer layer scope, existing identity approach | Every proposed quota or addon approved |
| BASE-08 | Uploaded Twin Path brand PDF and Concept B archive | Official supplied colors/type/logo rules available | UI ke tamam current routes brand compliant hain |

GitHub reference: [main baseline](https://github.com/s22benlg1m01140-sudo/operqon-core/tree/991f014a33501b8b6d9202a4cb85d45f2c6f968c).

## Source aur deployment ko reconcile karna

Main ke older RC2 release docs kai features ko deliberately disabled ya source-only kehte hain. November release specifications/provider ZIP un se aage hain. Purane document ki warning ko latest live fact aur latest ZIP ki files ko deployment proof, dono nahi maana jaayega. Next implementation task mein exact deployed SHA, artifact hash, migration head, acceptance logs aur environment configuration inventory ko aik baseline ledger mein jorna hoga.

R3 ke source-level canonical states:

| Aggregate | Allowed states observed |
| --- | --- |
| Tenant | requested, approved, provisioning, active, failed, suspended, rejected |
| Subscription | draft, trialing, pending_payment, active, past_due, cancelled, expired |
| Provisioning job | requested, approved, queued, provisioning, completed, failed, cancelled, rollback_queued, rolled_back, published |

Email verified, identity review aur awaiting payment customer-facing tracker labels ho sakte hain; in ko bina schema decision ke tenant enum mein add nahi karna. `enterprise` internal plan code R3 compatibility ke liye reh sakta hai jab displayed name Business ho. Code/name migration foreign keys aur API clients ko preserve kare.

## Explicit gaps

1. **Release/source reconciliation:** provider R2.1/R3 aur current repo ki authoritative placement, ownership aur test evidence reconcile karna.
2. **Customer journey:** signup, verified tenant binding, callback, dashboard, configured Frappe SSO aur logout ko real browser mein verify karna.
3. **Team roster:** R3 team endpoint provisioner manifest ke `site_users` ko read karta hai; release doc ke mutabiq executor abhi roster publish nahi karta. Empty state team management nahi.
4. **Industry packs:** R3 scope se explicitly baahar thay. Is blueprint ki industry catalogue ko implemented feature list se alag rakhna.
5. **Country adapters:** FBR/ZATCA aur broader MENA acceptance ka evidence is inspection se available nahi. Country matrix research scope hai.
6. **Identity/email:** SMTP, user verification, account recovery aur ERP site IdP configuration environment prerequisites hain.
7. **Payments/finance:** hosted checkout URL tabhi jab configured issued invoice ho. Manual notice `pending_verification` hai; tenant activation nahi. Historical private-finance/live-payment protection ko feature implementation se automatically remove nahi karna.
8. **Entitlements:** current Frappe hook mode off/observe/enforce site setting se controlled hai. Marketing plan aur real server enforcement ki contract parity prove karna.
9. **Brand:** older workspace doc mein old token values/system fonts hain. Supplied Twin Path assets new UX specification ke authoritative visual reference hain; change scoped migration se hoga.
10. **Infrastructure:** remembered pilot sizing global SaaS capacity ka proof nahi. Production inventory, backups aur restore evidence separately inspect karna.

## First reviewable implementation slice

Exact version reconcile -> existing R3 E2E -> basic tenant country/industry setup -> trading order-to-cash -> invoice/stock/ledger reconciliation -> accountant UAT -> controlled pilot. Customer acquisition ko un countries/packs tak restrict karein jin ka acceptance record available ho. Existing Demo/Pilot ko is blueprint publish karne se koi configuration change nahi hota.
