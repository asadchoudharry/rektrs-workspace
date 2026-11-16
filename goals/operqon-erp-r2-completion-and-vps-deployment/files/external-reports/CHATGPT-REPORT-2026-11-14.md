# Operqon — Consolidated Adoption Report

14 November 2026 · Prior two research reports reconciled with fresh repository/documentation checks

Executive summary.

Adopt ServerKit conditionally as the ecosystem’s staff management home, on a new, isolated management VPS, with a thin Operqon extension. Retain the working provider API, PostgreSQL, console, customer portal, Frappe benches, Caddy, Postiz and Dokploy estate; remove nothing on a panel’s authority.

GO for an isolated pilot; NO-GO for production installation or replacing the provider platform today

Three requirements cannot honestly be promised simultaneously without qualification: zero additional resource consumption; zero disruption; no commitment to see every feature delivered without integration work. Because of that, claims such as “all these features with no integration work” are a direct NO-GO test, not an implementation target.

Evidence scope:

Public repositories and official documentation were checked. Your stated production configuration is NOT sufficient evidence for a production decision. The assessment does not reproduce every earlier image or repository page; unresolved issues were retained only when a stated retest would change an adoption decision. “UNVERIFIED” means evidence was unavailable or insufficient—not necessarily that a capability does not exist. Repository links act as inspectable support, not as proof of a deployed feature or a security posture.

## 1. Architecture and reconciliation of the previous research

### Final decisions carried forward

| Earlier finding | Consolidated decision |
|---|---|
| ServerKit evaluation: conditional extension strategy; retain provider API/database | Retain. ServerKit is the staff shell, not the business control plane. |
| Adoption research: prioritise existing Frappe Docker/Bench, Flagsmith, Restic/Rclone and reusable admin components | Retain. Adopt selectively; preserve the working deployment and governance. |
| React-admin recommended for admin interfaces | Use its MIT community components where useful inside new extension screens; do not replace the working vanilla-JS console merely to standardise technology. |
| Kill Bill recommended for a separate proof of concept | Retain as deferred POC. Existing subscriptions/invoices remain authoritative. |
| Activepieces must not own billing, provisioning or authorisation | Retain as a red line. |
| Modern POS and Pakistan localisation not production-approved | Retain. Candidate availability is not acceptance evidence. |
| Earlier branding concerns | Still unresolved end to end. Documented branding settings do not prove complete white-labelling across browsers, login and error surfaces. |

React-admin’s repository confirms its MIT community framework and API-oriented components. It is a UI toolkit, not a ready-made Operqon governance implementation.

### Target architecture

Target architecture — Operqon [diagram]

Staff · Keycloak staff realm
Management VPS · ServerKit
Thin Operqon extension
Separate integration service
Existing provider API · business authority
Adopted services · separate databases
Product adapters · existing deployment owners
Production Frappe benches · existing Caddy
Social VPS · Dokploy ownership
School ERP · RAG · future services

Authority rules:

- ServerKit: navigation, branding, staff-facing dashboards and fleet inventory.
- Extension: presentation, approved action forms and correlation links.
- Integration service: protocol translation, bounded caches and service-specific adapters.
- Existing provider API: tenant state, subscriptions, invoices, payment approvals, governed pricing, entitlements, provisioning and product data.
- Existing deployment owners: execute infrastructure changes through their established release process.
- Adopted services: own their specialist data; they do not gain direct access to provider or tenant databases.

### Where components run

| Location | Workloads |
|---|---|
| Existing Operqon VPS | Existing provider platform, Frappe benches and Caddy. No new adoption workload in the initial phases. |
| Existing social VPS | Postiz and its existing Dokploy deployment. No second Docker-management owner. |
| New management VPS | ServerKit, extension, integration service, bounded supporting services and their isolated databases. |
| Separate observability capacity | Telemetry storage and processing when introduced; never placed on the paying-tenant host for convenience. |
| Separate mail capacity | Postal, if adopted after deliverability testing. |
| Independent monitoring location | Uptime Kuma/public status so an Operqon-host outage remains observable. |
| External backup storage | Encrypted backups; separate credentials and retention controls. |
| Isolated staging/new tenant benches | Compatibility testing and later optional Frappe apps. |

One home means one entry point and routine operational workflow. It does not imply one database, one deployment engine or that every third-party application can safely be moved to ServerKit.

## 2. Adoption register

Decision meanings: KEEP = existing authority; ADOPT = selected target, subject to pilot gates; POC = evaluate separately; DEFER = unnecessary initially; REJECT = unsuitable for this role.

Licences below identify the inspected project/core, not every dependency or container layer. Apache/BSD are acceptable exceptions to the MIT preference. Enterprise directories and separately licensed components may be in a repository; exclude them unless their inclusion is proven. The MIT preference does not mean every component in a stack is MIT. Licence evidence is a legal acceptance gate, not a feature score.

### Provider and operational services

| Need | Project / decision | Licence evidence | Why | Integration | Replaces |
|---|---|---|---|---|---|
| Management home | ServerKit — ADOPT conditionally | MIT, licence file verified | Best candidate chassis for this fleet | Staff OIDC; thin extension | Building a fleet/navigation shell. |
| Alternative chassis | VortexPanel — REJECT for ecosystem home | README declares MIT; standalone licence file UNVERIFIED | Hosting-oriented; required SSO/fleet contract not verified | None | Nothing. Its documented plugins mean “no extensibility” would be inaccurate. |
| Remote telemetry | serverkit-agent — POC | README declares MIT; referenced licence file UNVERIFIED | Locally configured report-only mode | Explicit monitor; no Docker access | Custom basic host reporter, only after verification. |
| Identity | Keycloak — KEEP | Apache-2.0 | Already chosen identity authority | Separate staff/customer realms | New identity system. |
| Edge authentication | OAuth2 Proxy — ADOPT where appropriate | MIT | OIDC protection for compatible internal tools | Private upstream; authenticated reverse proxy | Custom login gateway. |
| Tenant/business governance | Existing Operqon provider — KEEP | Owned code; licence audit outside this review | Working, specialised governance | Existing HTTPS API | Rebuilding lifecycle, approvals and provisioning |
| Subscription calculation | Kill Bill — POC, deferred | Apache-2.0 | Specialist recurring billing | Synthetic/shadow accounts first | Future billing calculation work; does not replace maker–checker. |
| Provider PDFs | Gotenberg — ADOPT | MIT | Isolated rendering service | Private queued HTTP calls | Custom PDF engine. |
| Alternative PDF engine | WeasyPrint — DEFER | BSD-3-Clause | Good Python/paged-document option; avoid two engines | Use only if actual layouts justify it | Alternative renderer. |
| Revenue/MRR BI | Apache Superset — ADOPT later | Apache-2.0 | Reporting without custom chart infrastructure | Reporting database populated by bounded exports | BI/dashboard framework—not MRR definitions. |
| Feature flags | Flagsmith community — ADOPT | BSD-3-Clause; enterprise governance separate | Mature flag/segment capability | Server-side evaluation and safe cached defaults | Flag engine. |
| Operational alerts | Apprise — ADOPT | BSD-2-Clause | Lightweight channel delivery | Dedicated notification worker | Channel-specific alert senders. |
| Customer notification templates/inbox | Novu MIT portion — POC | MIT core; enterprise carve-outs verified | Potential template/channel orchestration | Product-scoped subscribers; approved templates | Notification orchestration; enterprise functionality excluded. |
| Transactional email | Postal — ADOPT later | MIT | Specialist mail delivery | Dedicated host, per-product credentials | Mail delivery infrastructure. |
| Uptime/public status | Uptime Kuma — ADOPT | MIT | Straightforward external checks/status pages | Independent location; separate admin/public access | Custom uptime/status application. |
| Runbooks/help centre | BookStack — ADOPT | MIT | Appropriate operational documentation and native OIDC | Staff OIDC; separate public/private content | Documentation application. GitHub now points to Codeberg; follow that canonical upstream. |
| Backup engine | Restic + Rclone — ADOPT | BSD-2-Clause + MIT | Portable backup formats and storage access | Existing owner creates consistent exports; encrypted off-host copy | Custom backup/storage engine. |
| Backup UI | Pluton — DEFER as fleet authority | Apache-2.0 | Useful local UI, not proven free fleet solution | Optional management of exported artifacts | Local backup UI only. Remote machine management is documented as commercial. |
| Business workflow automation | Activepieces community — ADOPT narrowly | MIT community; commercial enterprise features | Accessible noncritical integrations | Restricted service identities and approved APIs | Routine integration workflows. |
| Alternative orchestration | Kestra — DEFER | Apache-2.0 core | Valuable when technical orchestration justifies another system | No production Docker socket; reviewed plugins only | Technical orchestration. Enterprise RBAC is not an OSS-core assumption. |
| Observability candidate | SigNoz — REJECT as default under strict Keycloak SSO requirement | MIT outside specified enterprise directories | Good telemetry fit, but native OIDC/SAML is enterprise | Do not promise proxy auth removes its application login | No selected build. |
| Observability target | Apache SkyWalking — POC | Apache-2.0 | Permissive metrics/logs/traces alternative | Separate storage; private UI behind OIDC gateway | Custom observability platform; exact SSO deployment UNVERIFIED until tested. |
| Earlier metrics recommendation | Prometheus — DEFER as an additional stack | Apache-2.0 | Valid earlier choice; avoid overlapping stacks initially | Retain existing installations if any; evaluate collection requirements | Metrics collection where needed. |
| Verifiable audit | Trillian — REJECT for new adoption; Tessera — POC | Both Apache-2.0 | Trillian directs new operators to Tessera | Separate audit exporter, witnesses/checkpoints | Merkle-log implementation—not event capture or completeness. |
| Internal tooling | React-admin community — optional components | MIT | Reusable forms/tables against existing APIs | Extension components; API remains authority | Commodity UI implementation. |

Maintenance assessment: ServerKit and VortexPanel have recent release activity, but this does not establish security maturity or maintainer resilience. VortexPanel’s MIT claim is UNVERIFIED at licence-file level. ServerKit’s MIT licence file was verified. serverkit-agent’s MIT claim is UNVERIFIED and remains a pinned-version acceptance gate.

### Tenant applications

Every installation below belongs to a new image and isolated staging bench first. None is approved for installation into paying tenants by this report.

| Need | Project / decision | Verified licence | Why / integration | Replaces |
|---|---|---|---|---|
| HR/payroll | Frappe HRMS — ADOPT after testing | GPL-3.0 | Native HR/payroll foundation; Pakistan rules remain separate | Generic HR/payroll build. |
| Helpdesk; provider issues inbox | Frappe Helpdesk — ADOPT | AGPL-3.0 | Separate provider support instance; optional tenant installations | Ticketing, assignment and SLA application. |
| CRM | Frappe CRM — ADOPT when needed | AGPL-3.0 | Separate or compatible tenant installation; integration testing required | Modern CRM interface. |
| Tenant BI | Frappe Insights — ADOPT selectively | AGPL-3.0 | Tenant-scoped reporting; bound expensive queries | Tenant BI builder. |
| Print-format design | Frappe v16 built-in Print Format Editor — select | Frappe MIT | Avoid archived add-on; verify exact deployed patch | Separate print-designer installation. |
| Legacy print candidate | Print Designer — REJECT for new adoption | AGPL-3.0 | Repository explicitly says archived/unmaintained | Nothing. |
| LMS | Frappe LMS — ADOPT selectively | AGPL-3.0 | Learning product/pack; not a replacement for the future school ERP | Course/LMS build. |
| E-commerce | Frappe Webshop — POC | GPL-3.0 | ERP-connected storefront; exact v16 compatibility UNVERIFIED | Basic storefront build. |
| Standard tenant gateways | Frappe Payments — ADOPT selectively | MIT | Existing gateway framework; does not establish Pakistan gateway coverage | Generic gateway plumbing. |
| Website builder | Frappe Builder — optional pack | MIT | Visual website authoring | Tenant website-builder implementation. |
| Tenant documentation | Frappe Wiki — optional pack | MIT | Avoid duplicating provider BookStack; documented version-3 supports v16 | Tenant wiki application. |
| Modern offline POS | kodlyft/XPOS — POC | MIT | v16/offline functionality documented; develop explicitly unstable | POS application, subject to recovery/sync testing. |
| Named Pakistan tax candidate | SpotLedger/pakistan_tax — HOLD | UNVERIFIED | Named repository could not be verified | Nothing approved |
| Alternative FBR integration | kodlyft/di — POC | MIT | Documents FBR DI/POS support and v16 branch; current requirements include Python ≥3.14 | FBR connector foundation—not compliance assurance. |
| Pakistan payment gateways | No production-approved adoption yet | Candidate-specific | Reference SDKs exist; qualification and Frappe adapters remain | Accepted integration gap |
| Pakistan payroll localisation | HRMS configuration + owned localisation pack | Combined licensing requires review | No maintained, comprehensive v16 pack verified | Accepted localisation gap |

### Findings that correct the original candidate assumptions

1. Print Designer should not be adopted: use the v16 built-in replacement.
2. Trillian should not start a new implementation: evaluate its recommended successor.
3. VortexPanel has a plugin system: its suitability for this ecosystem remains weak, but “no plugins” is incorrect.
4. Pakistan SDKs exist: the defensible gap is production-qualified integration, not “no SDK exists.” One inspected SDK explicitly says its adapters have not been exercised with live credentials.
5. Kill Bill coupons are not simply impossible without payment: official documentation provides a demo entitlement plugin and custom-extension mechanism. The product-level conclusion is unchanged. A complete permissive, ready-to-use coupon product remains unverified.

### Licence consequences for Operqon

- MIT/Apache/BSD projects still require applicable notices and dependency review.
- GPL tenant apps do not automatically require publishing the separate provider platform merely because of ordinary API access; this is not legal advice.
- Modified AGPL web applications require the relevant corresponding-source offer to remote users. Keep deployment boundaries and application boundaries explicit.
- Separate services and ordinary APIs support separation; they are not an unconditional exemption if code or data is shared.
- Reject BSL, SSPL, Elastic, Sustainable-Use, Fair-Core and other restricted/source-available components. Exclude commercial enterprise directories from selected open-core builds.
- Do not claim that an MIT wrapper makes its entire image permissively licensed.

## 3. Complete coverage map

O = already ours; C = chassis; E = extension/integration; A = adopted target; B = still-to-build; G = accepted gap. “Covered” means an assigned architectural owner, not a claim of deployed functionality.

| Need | Owner / component | Status and remaining work |
|---|---|---|
| Tenant lifecycle and oversight | Existing provider + extension views | O/E: retain authority; build API presentation |
| Subscriptions | Existing provider | O: Kill Bill deferred POC |
| Invoices | Existing provider + Gotenberg | O/A/E: rendering adapter |
| Trials | Provider | B/UNVERIFIED: not established as implemented in supplied baseline |
| Dunning | Provider initially; possible Kill Bill later | B: overdue states, notices, grace/suspension policy |
| Payment verification, maker–checker | Existing provider | O: preserve independent identities |
| Governed pricing | Existing provider | O: approval binds complete proposal/version |
| Provisioning jobs | Existing provider | O: no second job authority |
| Provisioning failure resolution | Provider + extension | O/E: expose existing safe resolution actions |
| Payment-gateway settings | Existing provider | O: retain write-only/encrypted/masked lifecycle |
| Admin issues inbox | Separate Frappe Helpdesk | A/E: product/tenant/job correlation |
| Servers | ServerKit inventory | C: ownership and permitted actions explicit |
| Benches | Existing deployment owner + adapter | O/E/B: Frappe-specific inventory/actions |
| Backups and restore | Existing owner + Restic/Rclone | A/E/B: consistent capture and governed restore |
| Domains | Existing Caddy/DNS ownership | O/E: inventory first; controlled DNS actions later |
| Platform settings | Existing provider | O/E/B: expose missing settings explicitly |
| Danger-zone actions | Existing owner/provider | B/E: scoped previews, approval and recovery |
| Identity administration | Keycloak | A/E: scoped administration; realm isolation |
| Feature flags | Flagsmith | A/E: applications must integrate evaluation |
| Staged rollout | Existing release owner + Flagsmith | E/B: flags do not deploy images or schemas |
| Email notification templates/delivery | Novu POC + Postal | A/E: template governance and callbacks |
| SMS templates/delivery | Novu + approved carrier | A/E/G: merchant/carrier access and cost |
| WhatsApp templates/delivery | Novu + authorised business provider | A/E/G: template approval and provider access |
| Operational alerts | Apprise | A/E |
| Transactional mail | Postal | A: deliverability gate |
| Uptime monitoring | Uptime Kuma | A: bounded external probes |
| Public status page | Uptime Kuma | A: independent location/public route |
| Metrics | SkyWalking POC; existing metrics retained | A/E: collection and sizing tests |
| Logs | SkyWalking POC | A/E: bounded ingestion/redaction |
| Traces | SkyWalking POC | A/B: instrumentation requires future app release |
| Revenue/MRR analytics | Superset + reporting dataset | A/B: definitions, exports and reconciliation |
| Invoice/receipt PDFs | Gotenberg | A/E: templates, fonts and access controls |
| Documentation/help centre | BookStack; Helpdesk articles | A: assign editorial ownership |
| Backup management | Extension + existing owner + Restic | E/B: fleet UI is not supplied free by Pluton |
| Workflow automation | Activepieces community | A: noncritical workflows only |
| Internal admin tooling | Extension; optional React-admin | E/B: existing APIs enforce permissions |
| Tamper-evident audit | Existing audit + Tessera POC | O/A/B: export, receipts, witnesses and gap detection |
| HR | HRMS | A: tenant compatibility gate |
| Payroll | HRMS | A: country rules separate |
| Tenant helpdesk | Frappe Helpdesk | A: separate from provider support |
| CRM | Frappe CRM | A: optional tenant pack |
| BI dashboards | Insights | A: tenant-scoped resources |
| Print-format design | Frappe v16 editor | A: exact deployed version check |
| Modern offline POS | XPOS | POC: not approved yet |
| E-commerce | Webshop | POC: version/integration test |
| LMS | Frappe LMS | A: optional product pack |
| Tenant payment gateways | Frappe Payments | A: supported gateways individually tested |
| FBR digital invoicing | kodlyft/di POC | G until qualified: sandbox, runtime and fiscal workflow |
| Pakistan tax configuration | ERP configuration + localisation pack | B/G: dated rules and expert validation |
| Easypaisa | Qualified connector still needed | G/B |
| JazzCash | Qualified connector still needed | G/B |
| PayFast Pakistan | Qualified connector still needed | G/B: distinguish from South African PayFast |
| Pakistan payroll rules | Owned HRMS localisation | G/B: effective-dated statutory rules and tests |

No software selection removes integration work. The remaining owned work is chiefly adapters, authorisation, reconciliation, localisation and operational procedures—not replacement billing, mail, backup or ticketing engines.

## 4. ServerKit: branding, extension boundaries and agents

### White-label depth

The inspected README documents logo/name/banner configuration, accent colours and dashboard customisation, plus a ServerKit-native white-label settings section. The earlier report’s localStorage/login-logo findings are historical findings requiring retest against the selected release. They should neither be ignored nor presented as freshly reproduced defects.

Acceptance must cover fresh browsers, login, password recovery, favicon, titles, loading/error states, browser UI, email templates and the exact selected artifact.

### Official extension and upstream updates

Current extension documentation describes prebuilt ESM delivery, SDK compatibility checks and bundle-size limits. External extension delivery, manifest permission and capability enforcement on the pinned stable release remains UNVERIFIED until demonstrated.

Recommended implementation:

1. Separate extension repository and versioned artifact.
2. Use documented SDK surfaces; avoid imports of private ServerKit internals.
3. Store only UI preferences and nonauthoritative cached references.
4. Put integration processing in a separate service.
5. Pin panel, extension and SDK compatibility as one tested release set.
6. Upgrade staging with a restored panel database before production.
7. Test extension disable/uninstall and restore the previous database with the previous application when migration rollback is required. Do not assume blue/green application rollback makes database migrations reversible.

### Permission, role and audit judgement

ServerKit’s extension documentation explicitly says most capability declarations are consent information and capability declarations are not a security boundary; code in an extension is trusted as if it were in the panel. Therefore, never place these inside extension-owned state or hooks:

- Payment verification authority or checker identities.
- Approved price proposals or entitlement truth.
- Tenant lifecycle/provisioning state machines.
- Production gateway secrets or broad deployment credentials.
- Authoritative audit history.
- Financial migrations or irreversible production operations.

A panel administrator must not automatically become a payment checker. Hiding buttons is not authorisation.

### What its agent may do

The agent documentation distinguishes local, monitor, protect and full levels. Missing configuration and noncompliant payloads may be ignored. The agent exposes a remote control API, a configuration service and a privileged local mode, so its exact installation requires review and a documented remote-access model.

| Host | Permitted target | Forbidden |
|---|---|---|
| Paying Frappe host | Initially no agent; later explicitly tested monitor | Full/protect, shell, Docker, files, firewall, package/service changes |
| Existing Dokploy host | Inventory/API observation; optional tested monitor | Second deployment/proxy owner |
| Disposable pilot host | Full mode solely for destructive capability tests | Any production credential/network path |
| New management host | Scoped management of its own approved workloads | Authority over existing production hosts |

Do not mount the Docker socket, including with :ro. A read-only filesystem mount does not provide read-only Docker API authorisation. The reviewed agent defaults to full when no mode is configured, so the selected package must demonstrate explicit mode and update behaviour before any managed host is added.

The exact pinned agent binary must prove report-only behaviour. Documentation alone is insufficient.

## 5. Load protection and reversibility

An absolute “cannot burden or harm tenants” guarantee is incompatible with adding privileged software. Separate hosts remove direct CPU/RAM/disk contention from adoption services; they do not remove all risk, because APIs, backups, external checks, telemetry and shared services still consume capacity.

### Mandatory rules

| Area | Rule | Required evidence |
|---|---|---|
| Co-location | No new panel, BI, PDF, mail or telemetry database on either working product VPS initially | Deployment inventory |
| Production access | Pilot uses synthetic data and no production credentials | Network/secret review |
| Docker | No production socket, remote Docker endpoint or Docker-group membership | Mounts, groups and access tests |
| Public edge | Existing Caddy remains owner; no ServerKit proxy bootstrap | Before/after configuration and port inventory |
| Updates | No unattended panel/agent/extension/product updates | Pinned artifact manifest |
| Existing projects | No console/API/portal/schema/Compose edits during additive pilot | Repository/configuration comparison |
| Reads | No dashboard fan-out or BI queries against live tenant databases | Query/network traces |
| Integration failure | Existing provider and benches continue without the new home | Management-VPS outage test |
| Reversal | Remove management components without undoing production migrations | Teardown rehearsal |

### Proposed pilot budgets

These are acceptance budgets, not verified product footprints:

- Management-only core: start testing with 4 vCPU / 8 GiB, excluding the full BI, observability and mail stack; approve final sizing from measurements.
- Panel cap: 1 vCPU / 1 GiB; integration service: 0.5 vCPU / 512 MiB. If unsuitable, increase isolated management capacity.
- External checks: one inexpensive request per endpoint per 60 seconds, no overlapping probes.
- Provider reads, only after a later connection gate: initially one concurrent request, maximum one request/second, cache, backoff and circuit breaker.
- Future monitor-agent trial: 0.1 CPU / 128 MiB, bounded disk/logging and no uncontrolled retry buffer.
- PDF concurrency: one job initially, memory/time limits and restricted outbound fetching.
- No live-host backup scan or new log/tracing collector before a separate measured-change gate.

Existing backup generation already consumes resources. Restic copying does not make capture free. Provision the initial restore test before relying on future backup capacity.

Restore into an isolated environment first. Image rollback cannot undo database writes, issued invoices or external payments.

## 6. Future products and one owner per host

### Product integration contract

Each product registers:

- Product/environment identifiers and its deployment owner.
- Product-local tenant/customer reference.
- Health/status endpoint and support routing.
- Staff OIDC client and role mappings.
- Documented operational actions with idempotency and audit correlation.
- Backup/recovery procedures and telemetry export policy.

Use composite identities such as product_id + tenant_id. A central customer reference may link commercial relationships, but does not merge application data. Each product keeps its own database, credentials and access controls.

| Product | Integration into management home | Ownership retained |
|---|---|---|
| Operqon Frappe ERP | Existing provider API adapter | Existing provisioning/release owner |
| Laravel/React/PostgreSQL school ERP + LMS | Separate product API adapter and OIDC client | School product’s schema, tenants, billing policy and deployment |
| Postiz social product | Existing Dokploy APIs/links and product support metadata | Dokploy and the social product |
| RAG service | Product API, index-job status, quota/cost summaries | Separate documents, vector storage and access controls |
| Small services | Common registration and health/action contract | Their assigned deployment owner |

### One Docker-management owner per host

- Operqon VPS: existing Compose/release process.
- Social VPS: Dokploy.
- New ServerKit-managed host: ServerKit may own deployment only after explicit designation.
- No shared ownership of Docker networks, proxy routes, certificates, volume pruning, updates or service ownership. Multiple dashboards can observe. Multiple reconcilers must not compete.

### One staff login

Use the staff realm for management clients. Customer-realm credentials must not grant staff access. Separate realms do not alone establish least privilege. Native OIDC is preferred. OAuth2 Proxy is acceptable only where the application can safely operate behind the proxy and has no separate login. A proxy login followed by an application password is not one login.

If a selected community edition cannot meet that requirement:

1. Expose necessary routine actions through the authenticated extension and scoped API; or
2. Reject that surface until a compatible option is proven.

For example, SigNoz documents native Keycloak-compatible OIDC/SAML in commercial editions, so it is not a claim that its exact deployment has already passed SSO acceptance.

## 7. Gated rollout

| Phase | Scope | Evidence required to pass |
|---|---|---|
| 0 — Freeze baseline | Inventory ownership, current releases, APIs and recovery paths | Recorded manifests; existing restore evidence; no changes |
| 1 — Throwaway chassis pilot | ServerKit, synthetic product data, test Keycloak realm | SSO/roles, branding, extension install, disable and removal |
| 2 — Integration pilot | Synthetic provider API; separate adapter; Helpdesk/status/docs | API authorisation, failure isolation and ordinary support workflows |
| 3 — Release/rollback rehearsal | Upgrade pinned panel and extension on restored data | Compatibility, schema recovery, branding persistence, previous-version recovery |
| 4 — Production visibility only | External probes; later bounded existing-API reads | Rate limits, no mutation, acceptable measured impact |
| 5 — Monitor-agent qualification | Disposable clone before any live agent | Explicit monitor mode, rejected commands, no socket, bounded resources, licence resolved |
| 6 — Supporting services | PDFs, flags, notifications, backups, BI and observability separately | One owner each; SSO; resource limits; failure/recovery tests |
| 7 — Tenant feature packs | HRMS/CRM/LMS/Webshop/POS/localisation in new images | Exact v16 compatibility, restore, permissions and business acceptance |
| 8 — Fleet rollout | Product-by-product registration and controlled actions | Product isolation, owner contract and no-engineer operational drill |

Kill Bill has a separate gate: run synthetic/shadow billing through renewals, seat changes, proration, cancellations, credits, rounding and reports before any live data is used.

For tenant apps, removing the app is not automatically a rollback. Test restoration of the matching database and files before removal, and record the restore evidence.

## 8. Risks, audit design and stop conditions

### Tamper-evident audit

The existing “immutable audit” is part of your supplied baseline; resistance to database administrator tampering is UNVERIFIED.

Recommended additional layer:

1. Preserve the authoritative local event.
2. Export ordered events through a separate service using an existing supported interface.
3. Record sequence, timestamp, actor, product, action, approved-version hash and correlation ID.
4. Submit appropriately protected event commitments to the transparency log.
5. Store signed checkpoints under a separate administrative boundary.
6. Verify inclusion, consistency and missing sequences independently.

Tessera is a library for transparency logs, not a complete Operqon audit product. The exporter, verification tool and administrative procedures remain Operqon work.

A Merkle log can demonstrate inclusion and detect inconsistent history; it cannot prove that every relevant event was recorded.

### Supply chain and exit

- Pin source commit, release artifact and image digest.
- Verify signatures where available; a checksum fetched from the same compromised source is insufficient.
- Mirror approved artifacts and retain recovery copies.
- Review extension code as trusted panel code.
- Disable automatic dependency/plugin installation.
- Keep product adapters outside ServerKit and maintain OpenAPI contracts.
- Export application data and verify recovery without the panel.
- Use Restic repositories independently of a backup UI.
- Keep workflow definitions, templates and configuration in version control.

ServerKit’s release page contains both stable releases and explicitly warned-against development builds. Development builds should be treated as an explicit stop condition until the selected release is verified as stable, licensed and reproducible.

### No-engineer operational acceptance

An administrator must demonstrate from the management home:

- Investigating a failed provisioning job and using an approved retry/resolution.
- Distinguishing payment maker from checker.
- Resolving notification delivery failures without duplicate sending.
- Creating and assigning a support issue linked to the affected job/tenant.
- Finding backup freshness and requesting a controlled restore.
- Seeing unavailable integrations without triggering unsafe fallback actions.

If these require routine SQL edits or shell access, the operational requirement has not passed.

### Adoption must stop if

- ServerKit requires control of existing Caddy, Docker or Frappe deployment.
- Any extension bypasses provider permissions or approval separation.
- Required capabilities exist only on unqualified development builds.
- SSO requires prohibited enterprise code or shared staff credentials.
- Agent report-only mode or update control cannot be demonstrated.
- An essential licence remains unresolved.
- Production capacity, restore or recovery tests fail.
- The team cannot operate the selected service set without repeated engineering intervention.
- “All features with no integration work” remains a literal acceptance condition.

## 9. ServerKit versus VortexPanel scoring

1 = poor fit; 5 = strong fit. Adoption effort: 5 means easiest. These are architectural fit scores, not proof that the panel implements every governance requirement.

| Criterion | ServerKit | VortexPanel | Evidence / interpretation |
|---|---|---|---|
| SSO fit | 4 | 1 | ServerKit documents OIDC/SAML; equivalent VortexPanel contract UNVERIFIED |
| Docker/Frappe fit | 3 | 2 | Both expose Docker management; neither is verified as a governed Frappe SaaS orchestrator |
| Extensibility | 4 | 2 | Detailed ServerKit extension SDK; VortexPanel also documents plugins |
| Updates after customisation | 3 | 2 | ServerKit external extension path is promising; pinned-release compatibility remains a gate |
| White-label depth | 3 | 1 | ServerKit documents brand settings; complete coverage unverified; Vortex equivalent unverified |
| Fleet future | 4 | 1 | ServerKit agent/fleet design; Vortex server migration is not equivalent to fleet control |
| Security | 3 | 2 | ServerKit has documented boundaries but trusted extensions; Vortex documents hardening and signed updates |
| Project health | 3 | 2 | Both show recent releases; maintainer resilience and security response remain unverified |
| Adoption effort | 3 | 2 | ServerKit better matches the shell; integration remains substantial |
| Total | 30/45 | 15/45 | ServerKit wins conditionally |

The scoring is consistent with the earlier evaluation. It incorporates current extension, agent and licence information, but does not change the conditional recommendation.

## 10. Recommendation, top five risks and exact pilot checklist

GO: isolated ServerKit management-home pilot with synthetic data and no production credentials.

NO-GO today: installation on either working product VPS; Full/Protect agents; replacement billing; live bench management; live payment gateways; or public tenant-app deployment.

The recommended path is ServerKit shell + existing Operqon authority + selectively adopted services + explicit product adapters.

### Top five risks

| Risk | Mitigation |
|---|---|
| Production takeover or resource contention | Dedicated management capacity; no production Docker access; preserve one owner per host |
| Governance bypass through extension, automation or billing service | Existing provider API enforces every permission, approval and state transition |
| Untrusted updates/extensions | Pinned reviewed artifacts, staging upgrade tests, controlled registry and complete recovery set |
| SSO/licence mismatch in open-core services | Verify community features and exact package licences; reject restricted portions; test real login flows. |
| False readiness of audit, backups or Pakistan integrations | Independent audit verification, full restore drills, merchant/FBR qualification and payroll acceptance tests. |

### Exact checklist before anything touches production

- [ ] Record production owners, images/digests, Compose projects, networks, volumes, edge configuration and related credentials.
- [ ] Provision a disposable management VPS with **no production credentials or private-network access**.
- [ ] Select a stable ServerKit artifact; record source commit, digest and provenance.
- [ ] Resolve panel, agent, extension and dependency licences; no assumed licence inheritance.
- [ ] Disable unattended updates, unreviewed extensions and automatic dependency installation.
- [ ] Prove staff OIDC login, least-privilege roles and customer-realm denial.
- [ ] Prove account linking cannot grant staff privilege through an untrusted identity.
- [ ] Test branding in a fresh browser, login, errors, mobile views and emails.
- [ ] Install the extension without editing core files; prove its UI on the selected release.
- [ ] Prove extension disable/removal leaves the provider and other services operational.
- [ ] Connect only a synthetic provider API; demonstrate maker–checker and proposal-version enforcement.
- [ ] Demonstrate duplicate-request, timeout, retry and stale-state handling.
- [ ] Verify no Docker socket, Docker-group membership, host-root mounts or production SSH keys.
- [ ] Rehearse panel/extension upgrade and recovery with restored database/configuration.
- [ ] Power off the management VPS; prove independent product operation.
- [ ] Test external monitoring with bounded probes and a separately accessible public status page.
- [ ] Measure management CPU, memory, disk growth, queue limits and outage recovery.
- [ ] On a disposable host, prove explicit monitor mode rejects mutation and cannot be promoted remotely.
- [ ] Verify disabled/uncontrolled agent self-update behaviour and resource limits.
- [ ] Restore a representative Frappe backup—including database, files and configuration—into isolation.
- [ ] Complete an administrator-only operational drill without SQL or shell intervention.
- [ ] Publish the exact allowed-action matrix, rollback procedure and product ownership register.
- [ ] Pass all applicable gates before adding production visibility; qualify each later write capability separately.
