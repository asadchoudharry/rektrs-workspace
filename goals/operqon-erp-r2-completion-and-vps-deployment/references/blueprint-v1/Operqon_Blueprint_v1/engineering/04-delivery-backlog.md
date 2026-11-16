# Operqon: delivery programme aur engineering backlog

Planning date: 6 November 2026. Yeh roadmap current R3 customer-layer ka replacement nahin. Pehle existing release ko verified baseline banayein; naye modules gates ke mutabiq add hon.

## 1. Delivery sequence

| Wave | Result | Indicative elapsed range | Gate |
|---|---|---|---|
| W0 | Baseline audit, evidence, ADRs, working customer layer | 2–4 weeks | Reproducible release and restored staging |
| W1 | Shared finance/supply/commerce plus controlled pilot | 8–14 weeks | 3 real end-to-end businesses; reconciled ledgers |
| W2 | Pakistan trading/distribution/services launch packs | 8–14 additional weeks | FBR/country applicable evidence; supported scope published |
| W3 | Saudi pack plus vehicle/food pilots | 12–20 additional weeks | ZATCA path and domain acceptance; no unsupported claim |
| W4 | GCC expansion, pharmacy/manufacturing, enterprise controls | 4–9 additional months | Specialist/authority evidence per pack |
| W5 | Wider MENA and selected global markets | 6–18 additional months, overlapping teams | Country-by-country commercial readiness |
| Ongoing | Regulatory changes, upgrades, security, customer success | Continuous | Supported version and evidence renewal |

Ranges planning assumptions hain, commitment nahin. Country approval, access-provider onboarding, staffing, source completeness aur pilot availability critical path badal sakte hain. World coverage aik finite launch milestone nahin; per-country supported version programme hai. 200 catalogue use cases ko 200 production-ready products samajhna delivery error hoga.

## 2. Staffing aur capacity assumptions

### Lean first-market team

Product/domain lead 1; senior Frappe/backend engineers 2; frontend/product engineer 1; QA automation 1; part-time platform/SRE 0.5; part-time designer 0.5; country accountant/tax specialist 0.5; implementation/customer-success 1. Security/legal specialist engagement scoped reviews par ho. Is size mein 2–3 anchor industries se zyada simultaneous deep launch realistic assumption nahin.

### Expansion team

Shared platform squad 4–6; product experience squad 3–5; per-industry family squad 3–5; country compliance squad 3–5 plus local licensed advisors/access providers; QA/SRE/security 3–5; implementations/support separate. Exact hiring volumes demand aur automation evidence par stage hon. Customer onboarding aur data cleanup ka cost engineering estimates se ghayab na ho.

| Work package | Indicative effort | Assumption |
|---|---|---|
| Baseline/release hardening | 4–8 person-weeks | Existing R3 source complete and accessible |
| Shared commerce/supply UX and contracts | 16–28 person-weeks | Reuse upstream engines; no core rewrite |
| One straightforward industry pack | 6–14 person-weeks | Shared core ready, available domain pilot |
| Complex regulated pack | 16–32+ person-weeks | Multiple integrations and acceptance cycles |
| Country accounting/reporting pack | 6–16 person-weeks | Local advisor and current specification available |
| Fiscal transmission/certification | 12–28+ person-weeks | Official sandbox/provider access and stable requirements |
| Enterprise isolation/DR/operations | 12–24 person-weeks | Regional infrastructure and tested runbooks |

Effort ranges overlapping work ko simply sum karke calendar date na banayein. Budget model actual loaded local rates, external advisors, gateway/ASP fees, infrastructure, support, testing devices aur contingency se calculate ho. Commercial rate source ke baghair fixed project quote invent na karein. Regulatory uncertainty aur third-party lead time ke liye explicit reserve rakhein.

## 3. First complete vertical slice

Pakistan ka aik trading/distribution pilot: signup → verified identity → approved plan/payment → provisioning → company/tax setup → approved item/customer import → purchase receipt/bill → stock → sales order → delivery → invoice → applicable fiscal handling → receipt/allocation → return/credit → bank reconciliation → trial balance → subscription renewal/export/backup.

Parallel service pilot quotation → approved PO → project/job → technician work → parts/time → service report → invoice → receipt → AMC renewal demonstrate kare. Pilot acceptance sirf dashboard login ya invoice PDF par close na ho. Owner, accountant, warehouse aur sales roles apne tasks khud complete karein.

## 4. Estimation aur governance

Har backlog row ID, wave, owner role, dependency, acceptance evidence aur risk rakhti hai. Detailed delivery stories mein user/trigger, preconditions, normal flow, exceptions, permission, data, ledger impact, integration, UI states aur test fixtures add hon. Work-in-progress limit ho; aik pack ki missing finance foundation ko doosre pack ki UI quantity se hide na karein.

Definition of ready: domain owner available, supported country/industry scope, signed API/data contract, acceptance fixtures, privacy classification, dependency ready. Definition of done: code review, relevant tests, migration rehearsal, role/negative tests, accessibility and visual check, docs/support runbook, feature/pack status updated, evidence links, controlled pilot signoff.

### Change authority

Product owner scope/priorities; technical lead architectural invariants; country compliance owner tax/fiscal rule; finance reviewer accounting postings; security owner trust boundary; release manager go/no-go; customer owner UAT. High-impact decision ka single named accountable owner ho. AI suggestions approval record ka substitute nahin.

## 5. Risks aur exit conditions

| Risk | Leading signal | Response |
|---|---|---|
| Scope explosion | New industry without sponsor/pilot | Catalogue record; defer implementation wave |
| Core fork | Repeated upstream patch conflict | Extension review, adapter, upstream contribution |
| Wrong compliance claim | Marketing status exceeds evidence | Capability registry gates publication |
| Pilot hardware overload | Queue/latency/memory breach | Quotas, optimize, add cell capacity |
| Dirty migrations | Opening balances/stock mismatch | Dry-run, exception queue, signed reconciliation |
| Unbounded customization | Tenant-specific code branches multiply | Config schemas and reusable extension review |
| Country dependency delay | Sandbox/provider unavailable | Publish limited supported accounting scope transparently |
| Support cost | Repeated manual same correction | Product fix, guided setup, knowledge/runbook |
| Upgrade drift | Tenants on unsupported combinations | Release train, compatibility lock and migration campaign |
| Financial defect | Ledger/stock discrepancy | Stop affected posting, incident and supported correction |

## 6. Backlog files

[delivery-backlog.csv](delivery-backlog.csv) mein 120 implementable work items hain. Yeh ordered planning inventory hai, GitHub issues ki creation ka daawa nahin. Har item ka implementation status proposed hai. Task-level time estimates team discovery ke baad issue mein add hon. Spreadsheet export CSV ko filters se wave/owner/risk ke mutabiq plan kiya ja sakta hai.

## 7. End-to-end completion ka matlab

Product tab commercially complete kaha jaye jab selected supported pack combination ke saath real customer onboarding, daily operations, close, compliance evidence, billing, support, disaster recovery, upgrade aur customer exit sab demonstrated hon. Har naye industry/country combination ko wahi evidence mile. Marketplace listing, attractive screenshot ya generated module name yeh proof nahin.

W1 mein real paid/customer operations sirf us entity/country scope mein jahan applicable legal, fiscal, money aur operations gates already pass hon. Warna pilot synthetic/isolated rahe; W2 label country gate bypass nahi karta.
