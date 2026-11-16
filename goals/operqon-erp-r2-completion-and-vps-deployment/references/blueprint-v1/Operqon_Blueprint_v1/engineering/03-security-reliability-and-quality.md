# Operqon: security, reliability aur quality gates

Planning baseline | 6 November 2026 | SLOs proposed engineering targets hain, contracted guarantee nahin.

## 1. Identity aur authorization

Keycloak credentials aur authentication own kare. Portal authorization-code flow with PKCE, state/nonce validation, exact redirect URI aur secure session use kare. Tokens ka issuer, intended audience, expiry aur signature validate ho. Long-lived access token browser storage mein expose na ho; server-side session/BFF ya platform-appropriate secure storage prefer karein. CSRF, session fixation, logout aur refresh-token rotation tests hon.

Stable key issuer + subject ho. Email ko permanent identity key na banayein. Existing ERP user ka OIDC linking verified identity aur existing account proof se ho; matching email par privileged membership automatic na mile. Keycloak account linking configurable flow hai [ENG-06]; Operqon ko apni verified linking policy aur tests chahiye.

| Access layer | Faisla |
|---|---|
| Authentication | Yeh identity kaun hai? |
| Membership | Is tenant mein iska approved rishta hai? |
| Role | Is operation ki ijazat hai? |
| Company/branch scope | Kin records par ijazat hai? |
| Field policy | Salary, margin, prescription ya tax ID dekh sakta hai? |
| State policy | Draft ko edit karna aur posted ko reverse karna alag rights |
| Entitlement | Plan/pack mein capability purchased/enabled hai? |
| Risk policy | Amount, country, device ya segregation ki shart |

Entitlement authorization nahin. Hidden menu backend protection nahin. Current repository mein observe/enforce setting aur default disabled behavior reported hai; production cutover par explicit migration/ADR aur deny-path tests ke baghair policy change na ho. Grace/read-only/suspended behavior existing contract se reconcile ho; UI assumptions nayi policy na banayein.

MFA platform operators aur finance/security administrators ke liye default requirement ho. Privileged access time-bounded ho. Support access customer consent, ticket reference, scoped duration aur visible audit se ho. Break-glass account offline-protected, monitored aur post-use review se controlled ho. Support impersonation customer ke irreversible financial actions ka ordinary path na bane.

Customer aur operator applications alag OIDC clients, audiences aur privileged roles rakhein; customer token control-plane administration ka access na de. Realm/client administration public portal ke through expose na ho. Service accounts per integration scoped hon, human account ko background worker credential na banayein. Enterprise federation tenant-approved identity provider mapping se ho; domain-name matching membership approval ka substitute nahin.

## 2. Tenant isolation threat model

| Attack/failure | Required defense | Test |
|---|---|---|
| IDOR on record ID | Server tenant and record permission | A requests B record → denied |
| Host/header manipulation | Edge known host allowlist; strip untrusted routing headers | Spoofed X-Frappe-Site-Name blocked |
| Cache bleed | Tenant/user/role-aware cache keys | Same URL different tenant data separation |
| Background job bleed | Signed/scoped job context, explicit site init/cleanup | Reused worker cannot inherit tenant |
| File download leak | Private attachment policy, scoped URL | Guess B object key denied |
| Search/BI leak | Filters before indexing/query/aggregation | Counts/snippets/export scoped |
| Websocket event bleed | Channel membership authorization | A cannot subscribe B channel |
| Connector credential bleed | Tenant-specific vault references | Connection test cannot read another secret |
| Operator mistake | Least privilege, scoped commands, preflight | Wrong site restore prevented |
| Backup exposure | Encrypted storage, limited restore rights | Unauthorized download denied |
| Logging leak | Redaction and safe structured fields | No token/PHI/payout secret in logs |
| Shared resources exhaustion | Tenant quotas, worker pools, rate limiting | Heavy report leaves other tenant SLO intact |

Shared bench superuser compromise cross-site impact rakh sakta hai. Tenant DB separation useful control hai, complete process isolation nahin. Dedicated compute claims actual network, identity, DB, key aur operational boundaries ke saath verify hon.

## 3. Security development standard

OWASP ASVS 5.0.0 ko selected verified controls ke saath security backlog mein version-pin karein [ENG-08]. ASVS use karna certification nahin. Product risk ke mutabiq baseline target Level 2 scope mapping propose hai, high-risk components par stronger controls evaluate hon. Har requirement implemented, test evidence, exception owner aur expiry se trace ho.

Secure development: threat modeling at new trust boundary, reviewed code, dependency locking, SAST, dependency/SBOM scanning, container scanning, secret scanning, signed artifacts, least-privilege service identities, environment separation aur documented incident response. Scanner green hone se business authorization safe prove nahin hoti; role/tenant negative tests alag hon.

Transport TLS, database/object-store encryption at rest aur managed key lifecycle deploy baseline mein hon. Key IDs/version references, rotation, revocation, recovery aur access audit defined ho. Per-region/per-tenant keys jahan contract ya risk justify karein; encryption tenant authorization ke baghair record exposure ko solve nahin karti. Audit log append-only application controls ke saath protected sink mein bhejein; stronger tamper evidence/immutable retention specific risk ke mutabiq configure ho. Logs ko "immutable" kehne se pehle storage aur administrator deletion behavior test karein.

Upload controls file size, MIME validation, active content handling, malware scanning, archive bomb protection aur private storage cover karein. Spreadsheet import formulas as data treat kare; exported CSV mein formula injection neutralize ho. SSRF defense remote URLs, webhooks aur document fetching par private/internal network access restrict kare. Public webhooks outbound egress control se arbitrary internal probes na ban sakein.

## 4. Privacy aur residency

Data inventory record category, controller/processor role, lawful purpose, destination, retention, access aur deletion exception rakhe. Country pack accounting retention aur privacy retention ko reconcile kare; universal default years legal claim na ho. Data-subject request financial originals ko silently delete na kare; lawful retention aur pseudonymization policy apply ho.

Region commitment compute ke saath DB replicas, backup, logs, analytics, email provider, AI model transfer aur support access cover kare. Customer selected region ko provisioning registry immutable history mein capture kare. Region migration approval, encrypted transfer, integrity verification, changed subprocessors aur controlled old-copy disposal se ho.

Payroll, health/prescription, biometric attendance, identity documents aur bank details separate sensitive scopes hon. Collection minimum ho; default analytics aggregate ho. Production data development/screenshot/demo mein copy na ho; synthetic fixtures use hon. Masked staging restore bhi re-identification risk review kare.

## 5. Reliability objectives

| Measure | Initial proposed target | Measurement boundary |
|---|---|---|
| Core availability | 99.5% monthly pilot; 99.9% growth target | Authenticated representative operation; maintenance policy disclosed |
| Read interaction | p95 <2s regional reference workload | Network profile aur result size defined |
| Standard submit | p95 <3s excluding external authority wait | Atomic business commit tracked |
| Async operational task | p95 queue wait <60s | Separate bulk/report queues |
| Fiscal queue | Country-specific legal window plus safety margin | Oldest pending age and actual ack |
| Control-plane provisioning | p95 goal <15 min after prerequisites | Third-party/manual review wait separate |
| Backup RPO | Pilot ≤24h; growth ≤1h proposed | Restore evidence plus failed backup alert |
| Restore RTO | Pilot ≤8h; growth ≤4h proposed | Full service and reconciliation, not DB mount alone |
| Security incident | Severity-based on-call policy | Detection, acknowledgement, containment timestamps |

Growth SLOs tab publish hon jab multi-week telemetry, load test aur failover drill support karein. Regulated records ke required recovery target ki wajah se proposed RPO insufficient ho sakta hai; customer/country review stronger target mandate kare. Error budget exhaust ho to feature release slow karke reliability fixes prioritize hon.

OpenTelemetry traces, metrics aur logs provide karta hai [ENG-09]. Trace mein tenant opaque identifier aur correlation ID ho, personal record content nahin. High-cardinality metrics per invoice/customer label na karein; tenant detail scoped logs/traces mein rakhein.

Alerts: readiness failure, authentication error spike, DB connections, replication lag, memory/disk, queue age, stale backup, failed restore verification, fiscal rejections, duplicate event attempts, failed payment reconciliation, certificate expiry, unknown operator access aur entitlement drift. Actionable runbook aur owner ke baghair dashboard ornamental hai.

## 6. Backup, restore aur disaster recovery

Backup set mein DB, private/public required files, site config references, encryption keys recovery process, pack lockfile, image digest, fiscal originals aur application release metadata shamil hon. Actual secrets backup encrypted controlled channel mein rahein; ordinary report/archive mein nahin. Offsite encrypted copy, immutable retention where justified, backup access audit aur restore rehearsal lazmi hon.

Har scheduled backup ka success byte count tak limited na ho. Periodic restored clone open karke GL totals, stock balances, attachments, recent transactions aur pack versions reconcile hon. Per-tenant restore aik tenant ka data doosre tenant par overwrite na kare. Production restore destination identity and maintenance window verify ho. Trial restores live email/payment/tax integrations invoke na karein.

Disaster runbook: incident classify → write fence/traffic route → latest consistent recovery point choose → infrastructure restore → scoped secrets restore → apps/migrations align → ledger/stock/fiscal ack reconciliation → safe replay outbox → role smoke tests → reopen → customer report. Authority acknowledgements aur bank settlements restore snapshot ke baad external systems se reconcile karein; blindly replay se duplicate fiscal/payment effects ho sakte hain.

## 7. Release aur migration discipline

Environment path dev → integration → staging → pilot/canary → production waves. Demo/Pilot protection explicit tenant allowlist aur release preflight mein ho. Existing operational projects aur sensitive finance/live payment restrictions current approved configuration ke mutabiq preserve hon. Planning ko configuration change ki permission na samjha jaye.

Release artifact mein commit, immutable image digests, app versions, manifests, SBOM, migration list, compatibility matrix, checksums, test evidence, known limitations, deploy/acceptance/rollback procedures hon. Script path, permissions, host dependency aur readiness syntax ko isolated execution se verify karein; previous deployment lessons ko regression fixtures banayein.

Expand/contract migrations: additive field/table first; compatible code deploy; backfill checkpoint; dual-read validation if needed; later obsolete path removal. Long migrations chunked hon. DB rollback sirf tested compatible snapshot se possible ho; destructive irreversible change par forward fix ya tested coordinated restore strategy ho. Script ka rollback label business recovery ka saboot nahin.

Pack release matrix pairwise risky combinations cover kare: industry + country + engine + currency + language + device mode. Full Cartesian combinations unbounded hain; supported combinations publish hon. Unsupported combination provisioning par roki jaye.

## 8. Quality gates

| Gate | Minimum evidence |
|---|---|
| Unit/domain | Invariants, rounding, effective dates, business exceptions |
| Integration | Real supported DB, queues, Keycloak protocol, adapter sandbox |
| Contract | Existing provider/portal schemas backward compatible |
| Tenant isolation | Read/write/export/search/file/job/websocket negative tests |
| Accounting | Trial balance, AR/AP, stock/GL and tax reconciliation |
| Country | Official schema fixtures, required acknowledgements, accountant signoff |
| Industry | Anchor workflow and failure cases with domain operator |
| UX | Loading/empty/error/denied/offline/conflict states, keyboard/RTL |
| Performance | Representative data and concurrency; queued report behavior |
| Reliability | Restart, retry replay, outage, restore and migration rehearsal |
| Security | Threat model, ASVS mapping, dependency review, penetration findings closure |
| Commercial | Correct approved pricebook, entitlements and billing math |

WCAG 2.2 AA target ho; touch controls ki minimum size/spacing aur focus unobscured behavior official criteria ke mutabiq test hon [ENG-10, ENG-11]. Compact ERP tables ko keyboard navigation, focus preservation, screen-reader labels aur responsive alternatives chahiye. Contrast ratio screenshot dekh kar guess na ho; tokens aur actual rendered states measure hon.

### Release acceptance ke critical examples

- Same serial 20 concurrent submits mein sirf aik sale ho.
- Same payment event 50 replays se aik settlement ho.
- 0.01 rounding edge aur multi-currency discount totals approved policy se match hon.
- Credit note refund authority reference aur original tax treatment preserve kare.
- Closed period transaction reject ho; authorized correction audited ho.
- Worker crash after DB commit se event eventually deliver ho aur duplicate effect na ho.
- Tenant A ko Tenant B ke counts, reports, attachment aur queued export na mil sake.
- Arabic UI RTL ho magar IBAN/VIN/serial numeric strings readable preserve hon.
- Staging restore email, payout aur authority submission emit na kare.
- Expired pack certification/credential sirf affected fiscal capability par clear block/task de.

## 9. Incident aur support operations

Severity matrix financial corruption, cross-tenant exposure, fiscal outage aur ordinary UX bug ko distinguish kare. Named incident commander aur technical owner ho. Evidence preserve ho; logs redact hon. Customer communication actual affected scope aur next update time bataye. Root-cause review blame ke baghair failed controls, missing test aur owner/due-date corrective actions track kare.

Runbooks minimum: identity outage, DB saturation, stuck queue, fiscal certificate expiry, suspected payment replay, tenant provisioning partial, backup failure, region loss, accidental import, pack migration failure aur permission drift. Support ticket mein consent aur audit reference ho; password/OTP maangna ordinary diagnostic step na ho.

## Research references

ENG-06: https://www.keycloak.org/docs/latest/server_admin/

ENG-08: https://asvs.owasp.org/

ENG-09: https://opentelemetry.io/docs/concepts/signals/

ENG-10: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum

ENG-11: https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum

Research date: 6 November 2026. Controls proposed hain; verification status implementation evidence se hi badlega.
