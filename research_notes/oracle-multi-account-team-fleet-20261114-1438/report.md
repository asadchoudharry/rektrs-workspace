# Oracle Cloud Always Free — 3 Partners, 3 Tenancies, One Fleet?

**Scenario:** 3 real people, partners in the same project, based in Pakistan. Partner A already has an Always Free tenancy (home region Phoenix, us-phoenix-1) with an ARM A1 instance (2 OCPU / 12 GB) + 2 AMD micro instances running off-box support services (monitoring, panel, backups). Partners B and C would each sign up for their **own** Always Free account — own identity, email, phone, payment card — and get their own free instances. Can all these servers, from **different Oracle tenancies**, be joined into one multi-server architecture for the team's shared project?

**Date of research:** 14 November 2026. All sources were read via web index / page fetch on that date; no Oracle account was signed into, so account-specific behaviour is cited from Oracle's published terms/docs, not live-tested. Note the current (post-June-2026) Always Free A1 allowance is **2 OCPU / 12 GB**, not the 4 OCPU / 24 GB still quoted by older guides.

---

## Summary / Verdict

**YES — possible, and there is a clearly legal-safe way to do it. With conditions.**

1. **Legality:** Oracle's published rule is **one Free Trial / Always Free account *per person*** — "Creating or attempting to create multiple free accounts is prohibited." Nothing in the Free Tier FAQ, the Cloud Services Agreement (CSA), or the Acceptable Use Policy that was found prohibits **different real people**, each holding exactly one legitimate account in their own name, from networking their servers together or cooperating on a shared project. Oracle's own documentation *explicitly designs for this*: cross-tenancy IAM, VCN peering and Object Storage sharing are documented for VCNs/resources "in different tenancies (which might belong to your organization, Oracle, or a third party)" and for parties "in entirely different companies (for example, in a service-provider model)."
2. **The banned pattern is a different one:** one person holding multiple accounts, or one person registering accounts in other people's names / with borrowed details. That is what must never happen here — each partner must sign up **themselves**, with their **own** card and details, and must remain the account holder.
3. **Technically:** joining is easy at the application and overlay-network layers (public internet + APIs, Cloudflare, WireGuard/Tailscale-class mesh) and is even natively supported inside OCI (cross-tenancy Local Peering in the same region, DRG remote peering across regions). What does **not** work reliably is *tight* clustering over the internet/WAN — a single etcd/Raft control plane, a single Docker Swarm, synchronous database replication — unless all nodes sit in the same region (Phoenix), in which case even that becomes feasible but is still not the recommended design for reclaimable free instances.
4. **The real risk is not a terms ban for pooling — it is Oracle's general free-tier fragility:** opaque automated fraud checks at signup, sudden unexplained tenancy terminations reported by free (and some paid) users, idle-instance reclamation, "out of host capacity," no SLA and no Oracle Support on Always Free. Design so that **the loss of any one partner's entire tenancy is a routine, survivable event**, never a catastrophe. Never put the production SaaS itself, its only database, or its only backup on this fleet — it is correctly scoped, as in the mission, to *off-box / support* infrastructure.
5. **Bottom line for the team:** proceed, with B and C both choosing **Phoenix (us-phoenix-1)** as home region, each partner keeping sole control of their own console password/MFA, all cross-access granted through **named IAM users, SSH keys and mesh-VPN keys** (never shared passwords), loosely-coupled services only, and every byte of important data replicated to at least one place **outside Oracle**.

Confidence: **High** on the terms reading (primary Oracle sources, quoted below) and on the technical options (Oracle docs + K3s/etcd/Docker docs). **Medium** on enforcement risk in practice — Oracle does not publish enforcement criteria, and no report was found of Oracle acting against a legitimate multi-person pooled fleet (see §5 — absence of evidence, not proof of safety).

---

## Findings

### 1. Legality / Terms

#### 1.1 The one-account rule is per *person*, not per project/team

Oracle Cloud Free Tier FAQ (official, read 2026-11-14):

> "One Oracle Cloud Free Trial or Always Free account is permitted per person. Please note:
> - Creating or attempting to create multiple free accounts is prohibited.
> - All contact and billing information provided must be accurate, valid, and used with consent for the duration of the account.
> - Accounts left idle for 30 days or more may be deemed abandoned and become eligible for suspension or termination.
> - Failure to comply with these requirements or the Cloud Services Agreement (PDF) may result in the suspension or termination of your account."

Source: https://www.oracle.com/ca-en/cloud/free/faq/ (index/open, 2026-11-14)

The signup flow repeats the same wording, and adds a region-specific corollary: do not create multiple accounts in order to change regions.
Source: https://signup.cloud.oracle.com/?language=en&sourceType=CloudFree_CTA1_Default+%3Aow%3Ao%3Ap%3Afeb%3A0916FreePageBannerButton and signup strings at https://signup.cloud.oracle.com/translations/en-US/translation.json (index, 2026-11-14)

**Reading:** the unit of the restriction is the *natural person*. Partner B signing up once, in B's own name, and Partner C signing up once, in C's own name, does not create a "multiple account" for anyone. There is no published rule of "one free account per household / per company / per project / per IP address."

#### 1.2 What is actually prohibited — the checklist to stay clear of

| Prohibited / dangerous | Why | Source |
|---|---|---|
| Same person creating (or attempting) 2+ free accounts | Direct FAQ prohibition | FAQ above |
| Creating a second account to change home region | Signup UI explicitly warns against it | Signup strings |
| Inaccurate contact/billing info, or using someone else's details/card without consent | FAQ requires info be "accurate, valid, and used with consent"; CSA §9.3 allows suspension if "You provided false account or payment information" | FAQ; CSA §9.3 |
| One person registering an account *in a partner's name*, or a partner "lending" their identity/card for an account they don't control | That is a duplicate account for the real operator + false/inconsented information for the named person — the exact fraud pattern Oracle screens for. An old third-party guide openly recommending using "your spouse's, relative's, or your friend's details" to get a second account describes precisely this banned pattern — do the opposite | Contrast: https://k21academy.com/oracle/video-register-free-oracle-cloud-trial-account/ (index, 2026-11-14) |
| Transferring / handing over a tenancy to someone else | CSA §17: "You may not assign this Agreement or give or transfer the Services or any interest in the Services to another individual or entity." | CSA §17 |
| Reselling / sub-letting the raw service to third parties | CSA §3.4(c): you may not "license, sell, transfer, assign, distribute, outsource, permit timesharing or service bureau use of, commercially exploit, or make available the Services to any third party" except as permitted. Running your own SaaS/support apps on the VMs (whose end-users use *your app*) is normal use; selling strangers a slice of the free VM itself is the risky reading | CSA §3.4 |
| Crypto mining, spam, scanning/attacking, illegal use | CSA §1.3 Acceptable Use Policy — includes a specific ban on "cyber currency or crypto currency mining," unsolicited bulk mail, and unauthorised vulnerability/port scanning | CSA §1.3 |
| Leaving the account idle | FAQ: 30+ days idle → may be deemed abandoned → suspension/termination. Separate instance-level idle reclamation in §4 | FAQ |

CSA full text (US online version linked from the FAQ): https://www.oracle.com/ca-en/contracts/docs/cloud_csa_online_v062223_us_eng.pdf (opened, 2026-11-14)

#### 1.3 Why cooperating is contemplated by Oracle's own terms and docs

Three independent Oracle signals point the same way:

1. **The CSA is written around "Users," not a lone operator.** §1.1: you may use the services "solely for Your internal business operations. You may allow Your Users to use the Services for this purpose and You are responsible for Your Users' compliance." §20.5 defines Users as "those employees, contractors, and end users, as applicable, **authorized by You** or on Your behalf to use the Services." A partner who is genuinely a contractor/collaborator of the account holder fits the *Users* concept for access to that holder's tenancy — granted as their own named user, with the holder remaining responsible. Source: CSA §§1.1, 20.5 (URL above).
2. **Cross-tenancy networking docs assume different owners.** Oracle's IAM-for-peering documentation: "Whether peering can occur with VCNs in a different tenancy (which might belong to your organization, Oracle, or a third party) would require special policy statements to enable cross-tenancy peering" and "Peering and transit routing involve two VCNs owned by the same party or two different ones. The two parties might both be in the same company but in different departments. Or the two parties might be in entirely different companies (for example, in a service-provider model)." Source: https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/drg-iam.htm (opened, 2026-11-14)
3. **Cross-tenancy storage sharing docs assume different organisations.** "Your organization might also want to share resources with another organization that has its own tenancy. It could be another business unit in your company, a customer of your company, a company that provides services to your company, and so on. In cases like these, you need cross-tenancy policies…" Source: https://docs.oracle.com/iaas/Content/Object/Concepts/accessingresourcesacrosstenancies.htm (index, 2026-11-14)

If pooling/networking separately-owned tenancies were itself a terms violation, Oracle could not document it as a headline enterprise feature. The terms risk therefore concentrates on **how the accounts are created and controlled**, not on the servers talking to each other.

#### 1.4 Account / credential sharing — the rule that actually bites teams

No clause was found that says the words "do not share your password," but the structure makes sharing both unnecessary and unsafe:

- The account holder is **responsible for their Users' compliance** (CSA §1.1) and Oracle may suspend for false account information (§9.3) — a shared root password destroys attribution and MFA.
- OCI natively supports doing it properly: each tenancy owner creates **separate IAM users** (Identity Domain users) for the other partners, puts them in a group, and grants a scoped policy; each person signs in with **their own password + MFA** and uses **their own API signing key / OCI CLI profile**. Cross-tenancy work is done with Endorse/Admit policies, not by logging into each other's tenancies as the owner (see §2.3).
- At the server level the equivalent rule is: **SSH keys and WireGuard/mesh keys per person, never a shared root password.** Revoking a departing partner = delete their IAM user, remove their SSH authorized_key, revoke their mesh peer — minutes of work, no password rotation party.

**Practical corollary for Muse / automation access (mission §4):** each partner runs their own agent/CLI from their own machine, authenticating (a) to OCI as their own named IAM user in each tenancy they've been granted one, via separate OCI CLI config profiles per tenancy, and (b) to the servers over SSH/mesh with their own key. No partner ever needs another partner's console password, and no shared "team Oracle login" should ever exist.

#### 1.5 Residual legal risk — honest assessment

- **No guarantee:** Oracle can update Free Tier terms, shrink allowances (it halved A1 in June 2026 without a public announcement — see §4), reclaim idle resources, and suspend for AUP/false-info concerns. Free Tier "does not include SLAs" and Always Free-only users "are not eligible for Oracle Support" (FAQ), so an erroneous automated termination may have **no effective appeal** (see §5 reports).
- **Grey zone to avoid creating:** if all three accounts are signed up in one sitting, from one IP, with cards from the same bank, and immediately peered and identically configured, an automated fraud system *could* misread a legitimate partnership as one person farming accounts. That is an enforcement/false-positive risk, not a reading of the written terms. Mitigations are about being visibly legitimate, not about evasion: each partner signs up personally, on their own device, with their own card/phone/email, no VPN during signup, accurate Pakistani billing address matching their card, and the team keeps a simple written partnership note (names, who owns which tenancy) so the structure can be explained if ever asked. Do **not** stagger signups, rotate IPs, or otherwise perform "looking less coordinated" tricks — that mimics the fraud pattern and helps nothing; the defence is that the facts are genuinely three people.
- **Commercial use:** Always Free services are marketed for, among others, "a startup founder creating new systems" (FAQ "Who should use"), and the CSA grants use for "Your internal business operations." Using the fleet for the team's own SaaS support infrastructure fits that. Selling the free capacity itself does not (§1.2).

### 2. Technical Joining Options Across Separate Tenancies

Nothing about a tenancy boundary blocks ordinary IP networking: each instance can have a public IPv4, OCI gives 10 TB/month outbound free per tenancy, and intra-region traffic is $0. Ranked best-first **for this team**:

| # | Option | How it joins the fleet | Latency (all-Phoenix) | Cost | Fragility / limits | Verdict |
|---|---|---|---|---|---|---|
| 1 | **VPN mesh overlay — NetBird (self-hosted or cloud) / Headscale / plain WireGuard** | Every instance + every partner laptop joins one private mesh (100.x / fd00:: style addresses, MagicDNS-style names). All private traffic, SSH, monitoring scrape, replication flows over it; public ports can then be closed | Adds ~0–2 ms intra-region; WireGuard is kernel-fast. If regions differ, mesh inherits WAN latency | $0 self-hosted; Tailscale SaaS free tier is **non-commercial** (see below) | Self-hosted control plane is a (small) single point — run it on a micro with backups, or use NetBird cloud free tier. Plain WireGuard = manual key/peer admin, grows as N² | **Recommended primary backbone** |
| 2 | **Plain public internet + APIs + reverse proxies** | Services talk over public IPs with TLS + auth (HTTPS APIs, S3 API, Prometheus remote_write, restic REST/S3, webhooks). Caddy/Nginx/Traefik per node | Same as underlying path; fine for async traffic | $0 | Every exposed service is attack surface; needs disciplined TLS, auth, firewalling. No private addressing | **Always works; use for public-facing + as fallback path** |
| 3 | **Cloudflare as the joining/glue layer** | DNS for all fleet hostnames; Tunnel (cloudflared outbound-only) publishes internal panels with **no open inbound ports**; Access puts SSO/MFA in front of admin UIs (Zero Trust free up to 50 users per secondary sources); Load Balancing (paid add-on, from $5/mo) health-checks and fails over between origins in different tenancies | Edge-terminated; origin latency unchanged | DNS/Tunnel/Access $0 at this scale; LB from $5/mo | LB is not free; Tunnel is HTTP-centric (arbitrary TCP needs WARP client); Cloudflare outage = published services unreachable (mesh still works) | **Recommended for all human-facing access** |
| 4 | **OCI native cross-tenancy VCN peering** | LPG peering (same region), cross-tenancy DRG VCN attachment (same region), or DRG Remote Peering (cross-region) — VCNs in different tenancies route privately over Oracle's backbone, governed by Endorse/Admit IAM policies both owners must set | Lowest: intra-region, sub-ms to ~1 ms, no internet, no overlay overhead | DRG: "no additional charge… no per-hour connection fee or per-byte data processing fee" (Oracle DRG page); intra-region data $0; cross-region data transfer is billed — keep it same-region | Most setup complexity; root-compartment policies; CIDRs must not overlap (plan 10.1/10.2/10.3.0.0/16-style splits up front); LPG peering is non-transitive (3 tenancies = full mesh of peerings, or one tenancy's DRG as hub); requires each owner to actively configure their side; untested at Free-Tier scale in sources found — networking services themselves are not Always-Free-capped, but treat as "should work, verify in a tenancy before depending on it" | **Excellent optional upgrade if all in Phoenix; not required** |
| 5 | **Application-level federation / replication** | MinIO bucket replication or `mc mirror` / rclone sync between S3 endpoints (incl. OCI Object Storage via its S3-compatible API, using cross-tenancy policies where native); restic to multiple independent repositories; database async replication / logical dumps; Prometheus federation or remote_write to a central receiver; multiple independent Uptime Kuma instances watching each other | Async — latency-tolerant by design | $0 | Eventual consistency; replication lag; must monitor the replicators themselves | **Recommended pattern for all data** |
| 6 | **Tight clustering over the public internet / WAN** — single k3s/Kubernetes etcd, Docker Swarm, synchronous Galera/Patroni across accounts or regions | Raft consensus across nodes | **Fails the latency test unless same-region:** etcd guidance wants RTT between members <50 ms and single-DC deployment; K3s docs say embedded etcd is *not supported* for distributed multicloud and server nodes "should be in the same location"; Swarm's Raft "does not work reliable without low latency networks" | $0 | Split-brain, leader-election churn, quorum loss when (not if) one free tenancy vanishes — with 3 nodes in 3 tenancies, losing 1 tenancy can lose quorum exactly when you need the cluster | **Do NOT do across regions/accounts as the design centre. Acceptable only as an experiment with all nodes in Phoenix, and never as the only home of anything** |

Key sources for this section:
- Cross-tenancy IAM/peering mechanics (Endorse/Admit/Define, both tenancies must agree, policies attached at tenancy root): https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/drg-iam.htm (opened, 2026-11-14)
- Oracle A-Team, *How to Establish Native Cross-Tenancy Connectivity in OCI*: three options — DRG VCN attachment (DRG and VCN same region), LPG local peering (same region), DRG remote peering (same or different regions): https://www.ateam-oracle.com/how-to-establish-native-cross-tenancy-connectivity-in-oci-iam-policies-and-considerations (index, 2026-11-14); and multi-tenancy architectures overview: https://www.ateam-oracle.com/oci-network-architectures-for-multiple-tenancies (index, 2026-11-14)
- DRG no-fee claim: https://www.Oracle.com/ae/cloud/networking/dynamic-routing-gateway/ ; VCN pricing (intra-region $0, 10 TB egress free, Site-to-Site VPN $0): https://www.oracle.com/it/cloud/networking/virtual-cloud-network/pricing/ (index, 2026-11-14). Note: some third-party summaries claim an hourly RPC charge; Oracle's own DRG page says no per-hour fee — for a same-region design the question is moot, which is another reason to stay in Phoenix.
- OCI Object Storage **native replication is intra-tenancy only** ("replicates objects… to another bucket **in your tenancy**"), so cross-account object copies must be done at the application layer (rclone/restic/MinIO replication over S3 APIs) or via cross-tenancy IAM policies granting S3/API access: https://Www.oracle.com/sa/cloud/storage/object-storage/faq/ (index, 2026-11-14)
- K3s distributed multicloud: https://docs.k3s.io/networking/distributed-multicloud?_highlight=vpn — "Embedded etcd is not supported in this type of deployment… Agents may be distributed over multiple networks, but all servers should be in the same location" and latency "could also impact the health of the cluster if latency is too high" (index, 2026-11-14)
- etcd latency: https://docs.okd.io/latest/etcd/etcd-practices.html — "the round-trip time between members should be less than 50 ms… etcd clusters are often deployed within a single data center or availability zone" (index, 2026-11-14)
- Mesh pricing/licence trap: Tailscale Personal is free for up to 6 users **for non-commercial use only** — a commercial SaaS team should self-host **NetBird** (open-source management server, official self-host path; cloud free tier 5 users / 100 machines) or **Headscale** (open-source Tailscale coordination server), or pay for Tailscale. Plain WireGuard has no such restriction and no control plane at all: https://www.vpnsmith.com/en/blog/netbird-vs-tailscale-2026 and https://github.com/pinggy-io/pinggy_website/blob/HEAD/content/blog/top_open_source_tailscale_alternatives.md (index, 2026-11-14)
- Cloudflare: Load Balancing is a paid add-on "starting at $5 per month" with health checks/failover: https://www.cloudflare.com/plans/application-services/ (index, 2026-11-14). Tunnel replicas provide failover, not load balancing, per: https://www.builddaily.io/resources/cloudflare-tunnel/ (index, 2026-11-14)
- Monitoring federation reality: Uptime Kuma is effectively single-instance (SQLite, single-writer); the workable pattern is **multiple independent Kumas monitoring each other + the services**, with Prometheus federation/remote_write for metrics: https://www.amireslampanah.com/tutorials/uptime-kuma-monitoring.html (index, 2026-11-14)

**Latency if home regions differ (why §4 says don't):** Phoenix↔Ashburn is already ~60–70 ms; Phoenix↔Mumbai/Hyderabad or Phoenix↔Frankfurt is transcontinental (150 ms+). That is survivable for mesh VPN, restic, MinIO replication and monitoring — and fatal for etcd/Raft comfort (<50 ms RTT guidance) and painful for interactive panels. Same-region makes every option in the table better simultaneously.

### 3. Architecture Design — 3-Account Blueprint

#### 3.1 What pooling actually gives you (per tenancy → ×3)

Per Always Free tenancy (official docs, current limits): 1× A1 at 2 OCPU / 12 GB (or 2× 1 OCPU / 6 GB), 2× AMD E2.1.Micro (⅛ OCPU / 1 GB each), 200 GB block storage total (**including boot volumes** — minimum 47 GB each, so A1 + 2 micros at minimum size already consume ~141 GB, leaving ~59 GB usable data volume), 20 GB Object Storage (Always Free-only tenancies; 50k API requests/month), 10 TB outbound/month, 1 Always Free load balancer (10 Mbps), 2 Autonomous Databases (1 OCPU / 20 GB each).
Source: https://docs.oracle.com/en-us/iaas/Content/FreeTier/resourceref.htm (opened, 2026-11-14)

**Fleet total: 6 OCPU / 36 GB ARM + 6 micros, 600 GB block (≈175 GB free data space after boot volumes), 60 GB object storage, 30 TB egress — but NOT a single pooled quota.** Every limit, failure and reclaim decision applies per tenancy. Design per-account first, fleet second.

#### 3.2 Design principles

1. **Loosely coupled by default.** Services communicate by HTTPS APIs, queues of files, replication and scraping — things that tolerate a node being gone for hours. Nothing requires two tenancies to be simultaneously alive to function, except (degraded-mode) cross-checks.
2. **No tight clusters.** No cross-account etcd, Swarm, Galera, Ceph, or shared filesystem. If Kubernetes is wanted at all, run **one independent single-node k3s per A1** (SQLite datastore) and treat it as a per-node app runtime / GitOps target — three small clusters, not one big one. Docker Compose + systemd per node is honestly sufficient at this scale and far easier to rebuild.
3. **Every stateful thing exists in ≥3 places, ≥1 of them off Oracle** (see 3.4).
4. **Everything is code.** Terraform (one state per tenancy) + Ansible over the mesh + containers defined in a shared Git repo. Rebuilding any node from scratch must be a documented, <1-hour, boring procedure — because one day it will be an emergency procedure.
5. **Blast-radius roles:** each account owns a *function*, and every function has its witness/backup in a *different* partner's account.

#### 3.3 Role assignment

**Account A — Partner A — Phoenix — "Ops Primary" (existing account, keep its current services)**
- A1 (2/12): Prometheus + Grafana **primary** (scrapes all fleet nodes over the mesh; 15–30 d retention, sized to the ~59 GB data volume), Alertmanager primary, server panel (e.g. Coolify/Dokploy/1Panel — whichever is already in use), Loki or journal aggregation receiver.
- Micro 1: Uptime Kuma **#1** (public status page primary) behind Cloudflare Tunnel.
- Micro 2: Mesh control plane (self-hosted NetBird management / Headscale) **or** WireGuard hub peer + Cloudflare Tunnel bastion. (If using NetBird cloud instead, this micro becomes a second bastion / restic REST server.)

**Account B — Partner B — Phoenix — "Resilience & Verification"**
- A1 (2/12): **Independent** Prometheus #2 (scrapes the same targets; not a replica of A — independent failure, independent alerting path via Alertmanager #2), audit-verification node: scheduled `restic check --read-data-subset` / restore-to-scratch drills, backup integrity reports, log-archive receiver, MinIO instance #1 (S3 target for fleet backups), CI runner #1 (self-hosted, ephemeral containers).
- Micro 1: Uptime Kuma **#2** — watches Account A's Kuma, the production SaaS, and the status page itself; alerts through a *different* channel than Kuma #1.
- Micro 2: Bastion / VPN exit #2 + rest-server (restic) target #2 + Syncthing/rclone sync node.

**Account C — Partner C — Phoenix — "Staging, Demos & Second Copies"**
- A1 (2/12): Staging/demo environments for the SaaS (the natural home for Always Free capacity — disposable by design), CI runner #2, MinIO instance #2 receiving bucket replication / `mc mirror` from B, secondary static mirror of the status page (pre-rendered, Cloudflare LB or DNS failover target).
- Micro 1: Public demo / docs / landing static hosting + webhook receiver.
- Micro 2: Backup target #3 (rest-server) + mesh relay/peer + spare bastion.

**All accounts, symmetric duties:** node_exporter + mesh agent + cloudflared on every instance; nightly restic backup of every node's important volumes **to the other two accounts** (see 3.4); each A1 also keeps a local snapshot schedule (5 Always Free volume backups per tenancy).

**Human access plane (one, shared, not Oracle):** one Cloudflare account (team's own) holding the project domain: DNS `status.`, `grafana.`, `panel.`, `ci.` etc.; Tunnel connectors on the relevant nodes; Access policies = each partner's own email/IdP login + MFA. One Git repo (GitHub/GitLab) holding Terraform/Ansible/Compose + runbooks — the repo, not any tenancy, is the fleet's source of truth.

#### 3.4 Data, replication and exit strategy

- **Backups — 3-2-1 adapted:** every production-support dataset (Grafana/Prometheus config & dashboards as code, panel config, Kuma DB, MinIO buckets, panel/app data) is restic-backed-up to **(1)** another partner's account, **(2)** the third partner's account, and **(3) one off-Oracle copy** — a partner's local NAS/home server over the mesh, or a cheap object store (Cloudflare R2 / Backblaze B2 class). Restic's encryption means a partner holding a backup copy cannot read another's data without the repository password, which lives in the team's password manager (one vault item per repository, shared with the team — repository passwords are team assets; Oracle passwords are not).
- **Databases:** no cross-account synchronous replication. Small stateful apps keep their DB **local to their node** (SQLite/Postgres on the same A1) and ship WAL dumps / logical backups via restic or Litestream-style continuous archiving to the other accounts. Autonomous Databases (2 free per tenancy) are fine for per-account, non-critical tooling data only.
- **Configuration:** dashboards, monitors, panel projects, mesh ACLs — all exported to Git (Kuma/Prometheus/Grafana provisioned from files where possible). A node with no unique un-backed-up state can be abandoned without grief.
- **Surviving a partner leaving / an account dying (the "bus-factor" drill):**
  1. Remaining accounts already hold encrypted backups + all IaC → rebuild the lost function on a spare micro / resized instance in a surviving tenancy (accept reduced redundancy) or on a $5-class paid VPS.
  2. Rotate everything the lost node could see: mesh peer keys, SSH host/user keys, restic repository passwords (re-encrypt going forward), Cloudflare Tunnel tokens, API tokens, webhook secrets. This is a checklist in the runbook, rehearsed once.
  3. Cloudflare DNS/LB repoints public names to the surviving copies — target <1 hour for status page and monitoring.
  4. **Legal reality to plan around:** a departing partner's tenancy is *theirs* (CSA §17 — it cannot be transferred to the team). The team's protection is never needing it: no unique data, no unique credentials, no domain/DNS/registrar/Git-org ownership tied to that person's personal accounts. Project domain, Git org, Cloudflare account and password-manager vault must be team-controlled assets from day one.
- **Surviving Oracle itself:** the off-Oracle backup copy + IaC means the entire support fleet can be reconstituted on one or two cheap paid VPSs in an afternoon. Budget-wise, treat "Oracle takes it all away" as a when/if scenario with a ~$10–15/month fallback, not as an existential risk.

### 4. Practical Constraints

**Home region — pick Phoenix for B and C. This is the single most important decision.**
- Always Free compute "must be created in your home region," and the home region "cannot be changed after sign-up" — the existing tenancy is already Phoenix, and same-region unlocks: sub-ms cross-tenancy LPG peering, zero intra-region transfer cost, mesh latency ~0, and even (if ever wanted) same-DC clustering tolerances. Sources: https://docs.oracle.com/en-us/iaas/Content/FreeTier/resourceref.htm ; signup strings above.
- **Can a Pakistan-based person choose a US home region?** The signup flow treats them as **separate choices**: "Please choose the country you will use for billing details… Home region will be selected later in the sign up process." Billing country = Pakistan (must match the card/address — FAQ requires accurate, consented information); home region is a data-region pick, and the FAQ says Free Tier "is currently available in all regions where commercial OCI service is available." No Oracle source found requires home region to be in the billing country. Signup UI guidance to pick the region "closest to your location" is guidance, not a stated eligibility rule. Sources: https://signup.cloud.oracle.com/translations/en-US/translation.json ; https://www.oracle.com/ca-en/cloud/free/faq/ (index/open, 2026-11-14)
- **But expect friction, honestly:** Oracle runs an aggressive, undocumented signup fraud screen. Community consensus (Oracle has never published criteria): signup IP country, card issuing country and billing address must tell one consistent story — sign up from Pakistan, no VPN/proxy, with a Pakistani-issued card and matching Pakistani address. The *home-region* choice being the US is common worldwide and is not the inconsistency that fails people; a US *billing story* attached to a Pakistani person would be. Sources: https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets ; https://site2us.com/en/servers/oracle-cloud-free-tier (index, 2026-11-14)
- **Card reality for Pakistan:** Oracle accepts "credit cards and debit cards that function like credit cards" and does **not** accept "debit cards with a PIN or virtual, single-use, or prepaid cards" (FAQ). Each partner needs their **own** physical Visa/Mastercard with **international / online transactions enabled** at their bank (a common Pakistani-bank default-off setting and a common decline cause), expecting a small temporary authorisation hold (FAQ: holds removed "typically within three to five days"). Never use one partner's card on another's account — that breaks the "own card" premise of the whole design and the FAQ's consent/accuracy rule.
- **Latency Pakistan→Phoenix** is ~200–280 ms (WonderNetwork's Karachi measurements to US cities on 2026-11-14 ranged ~195–283 ms: https://wondernetwork.com/pings/Karachi ). That affects only the partners' own SSH/panel use — noticeable but workable, and identical to what Partner A already lives with. Server-to-server traffic, the traffic that matters, stays inside Phoenix. Choosing Mumbai/Hyderabad instead would cut human latency but impose transcontinental latency and cross-region billing/complexity on *all* fleet traffic forever, and can never be changed — a bad trade for support infrastructure whose users are mostly machines.

**Capacity:** "Out of host capacity" for A1 in the home region is a documented, routine condition — Oracle's FAQ says it "indicates a temporary lack of Always Free shapes in your home region," suggests trying another availability domain (Phoenix has 3 ADs) or waiting. Phoenix is generally reported as one of the healthier A1 regions, but B and C should provision the A1 **first**, be patient/retry off-peak, and not build plans that require it on day one. Sources: FAQ; Always Free Resources doc.

**Idle reclamation — design around it, don't game it:**
- Instance level: "Idle Always Free compute instances may be reclaimed by Oracle" if over a 7-day period **all** of: 95th-percentile CPU <20%, network <20%, and (A1 only) memory <20%. Source: Always Free Resources doc (opened).
- Account level: 30+ days idle → may be deemed abandoned (FAQ).
- This fleet's workloads are naturally protective: Prometheus scraping + Grafana on a 12 GB A1 will normally keep memory utilisation above 20% on its own; monitoring/backup nodes generate constant network chatter. The micros (CPU+network only) running Kuma/bastion/rest-server duties are busier than a forgotten test VM. Still: enable OCI metrics/alerts on the thresholds, do real work, and keep backups regardless — **do not** run fake CPU-burner "keepalive" scripts; at best they waste the resource, at worst they read as abuse. (Some third-party guides recommend them; this report does not.)

**Free Trial vs Always Free — the 30-day trap:** a new account is $300 credit / 30 days of trial **plus** Always Free. Anything provisioned beyond Always Free limits using trial credit is reclaimed at trial end — and specifically, "if you have more Ampere A1 Compute instances provisioned than are available for an Always Free tenancy, **all** existing Ampere A1 instances are disabled and then deleted after 30 days unless you upgrade." B and C should create **only Always Free-eligible shapes/sizes from day one** (A1 total ≤2 OCPU/12 GB, micros ≤2, block ≤200 GB) and set a day-25 calendar check. Source: FAQ (opened).
- Upgrading a tenancy to Pay-As-You-Go keeps Always Free resources free and removes trial-expiry behaviour and (per Oracle's free page) changes capacity treatment, at the risk of accidental paid usage — a legitimate per-partner choice later, with compartment quotas/budget alerts set first. It is **not** required for this design.

**Management overhead — real, budget for it:** 3 consoles, 3 root MFA enrolments, 3 billing identities, 3 sets of OCI audit logs, no single Oracle-native pane of glass. OCI Organizations exists to centrally manage *an organisation's own* tenancies (parent invites/creates child tenancies) — it is designed for one organisation's subscriptions, and inviting three separately-owned free accounts into one partner's "organization" would blur exactly the ownership separation this design depends on; **do not use it here** — manage the fleet at the layers that are actually shared: Git/IaC, the mesh, Prometheus/Grafana, Cloudflare. Source (context): https://blogs.oracle.com/cloud-infrastructure/post/use-organizations-to-centrally-manage-costs (index, 2026-11-14)
- Tooling that makes 3 accounts feel like 1: Terraform with 3 OCI provider aliases / 3 state files in one repo; Ansible inventory = mesh hostnames (account-agnostic); one Ansible playbook set applies identical hardening/agents to all 9–12 instances; OCI CLI on each partner's laptop with 3 named profiles (their own IAM user per tenancy).
- Each partner must personally: keep their card valid, log in periodically (30-day abandonment rule), respond to Oracle emails about their tenancy, and be the one to talk to Oracle about their account. Put these in the partnership checklist.

**Security checklist (non-negotiables):** separate IAM users + MFA for cross-access, never shared passwords (§1.4); SSH key-only login, no password auth, fail2ban/ssh hardening; mesh ACLs — monitoring node may scrape, CI runners may deploy only to staging, backup nodes may only push to rest-servers; OCI security lists default-deny except 80/443 on public nodes and mesh UDP; secrets in a team vault, per-service tokens, documented rotation-on-exit (§3.4); outbound port 25 is blocked by default on OCI — use a transactional email API/587 for alert mail (Telegram/webhook alerting avoids this entirely).

### 5. Real-World Evidence

Searched for: teams/individuals networking multiple Oracle free accounts (own + friends/family), Oracle banning pooled/family accounts, enforcement patterns. Findings, honestly weighted:

- **No direct evidence found either way for the exact scenario.** No credible report was found of (a) a team of distinct people pooling their own legitimate Always Free accounts and being banned *for pooling*, nor (b) a documentedblessed case study of partners doing exactly this. The practice lives in a gap: common sense + Oracle's cross-tenancy docs say the *networking* is a product feature; the *accounts* question is governed by the per-person rule, which this scenario respects. Treat the verdict as "no published prohibition + strong documentary support," not "Oracle has approved this."
- **What *is* widely reported: harsh, opaque enforcement at the individual-account level.** Oracle's own community forums list, in Oct 2026 alone, threads titled "OCI Free Tier account terminated," "URGENT: OCI Free Tier tenancy terminated — request for data recovery" ("terminated by the system without any warning or explanation") and "Long-standing Free Tier Account (Active since 2021) Suspended": https://community.oracle.com/customerconnect/categories/oci-cloud-infrastructure-general/p2?sort=hot (index, 2026-11-14). Trustpilot carries multiple 2025 reports of accounts "terminated… no prior email message nothing," "blocked without even stating the reason," support refusing to explain or reactivate: https://au.trustpilot.com/review/oracle.com?page=3 (index, 2026-11-14). A BBB complaint (Sept 2026) describes a tenancy terminated the day after a failed PAYG-upgrade card check, appeal answered with "it will remain closed. This decision is final": https://www.bbb.org/us/tx/austin/profile/computer-software-developers/oracle-america-inc-0825-1000192832/complaints (index, 2026-11-14). A first-person account describes resources vanishing and support replying "System terminated your account and unfortunately we can't reactive or restore the account": https://readmedium.com/oracle-free-tier-is-not-free-36b3c12375a2 (index, 2026-11-14).
  - **Interpretation:** enforcement appears automated, unexplained and effectively unappealable for free users — and it strikes accounts whose owners say they did nothing unusual. This does not show pooling is targeted; it shows *any* free tenancy can disappear, which is why §3's design treats tenancy loss as routine. It also raises the stakes on signup hygiene (§4): mismatched identity/card/IP signals are the most commonly suspected trigger for instant or early termination.
- **The documented abuse pattern is the opposite scenario.** The clearest "multiple accounts" material found is advice for *one person* to obtain a second account using a spouse's/relative's/friend's details (K21 Academy, §1.2) — i.e., identity borrowing. That is the pattern Oracle's "per person / accurate / with consent" language targets, and it is categorically different from three partners each operating their own account. Do not let anyone on the team reframe B's or C's account as "the team's extra account that A operates" — the moment one person *operates* all three as theirs, the fact pattern slides toward the banned one. Each owner must genuinely own and operate their tenancy (their logins, their card, their MFA), even though day-to-day server work is shared via named access.
- **Multi-node use of free instances is otherwise unremarkable in the community:** single-account k3s/Kubernetes-on-Always-Free guides, WireGuard-on-OCI guides, and cross-provider mesh write-ups are routine, and K3s' own docs bless multicloud node distribution (with the etcd caveat in §2) — the fleet's individual techniques are all mainstream. Sources: https://docs.k3s.io/networking/distributed-multicloud?_highlight=vpn ; https://dev.to/pavan_madduri/deploying-a-production-ready-k3s-cluster-on-oci-always-free-arm-instances-mmj (index, 2026-11-14)

---

## Risks and Mitigations Table

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| 1 | Signup of B or C rejected / instantly flagged by Oracle's automated fraud screen | Medium — signup rejection is notoriously common | Low–Medium (delay; retry costs credibility) | Own device, no VPN, Pakistani IP + own Pakistani card + matching address, international transactions enabled, physical credit-like card, don't hammer retries (stop after 2 card failures and use Oracle chat/sales channel) |
| 2 | A tenancy terminated without explanation (reported pattern, §5) | Low–Medium per tenancy over years | High if unique data; Low by design | Loose coupling, 3-2-1 backups incl. off-Oracle copy, IaC rebuild <1 h, no production SaaS dependence |
| 3 | Idle instance reclaimed (7-day <20% rule) | Medium for a quiet micro; Low for busy A1 | Medium | Real workloads (monitoring/backup/mesh duties), metrics alerts on utilisation, backups + rebuild automation; no fake keepalive load |
| 4 | Account deemed abandoned (30-day idle) | Low if partners follow checklist | High for that tenancy | Each owner logs in monthly, keeps email/card current — partnership checklist item |
| 5 | "Out of host capacity" — B/C can't get A1 in Phoenix at first | Medium | Low (delay only) | Provision A1 first, try other Phoenix ADs, retry off-peak; micros + design work can proceed meanwhile |
| 6 | Trial-end reclamation destroys over-limit A1 (all A1 disabled → deleted) | Low if rules followed | High | Create only Always Free sizes from day 1; day-25 audit reminder per new account |
| 7 | Partner leaves / relationship sours; their tenancy is legally theirs | Unknown — human risk | High if unique assets live there | Team-owned domain/Git org/Cloudflare/vault; no unique data or credentials in any one tenancy; exit drill + secret rotation checklist (§3.4) |
| 8 | Tight cluster (etcd/Swarm) split-brain across accounts | High **if built** | High | Don't build it (§2 #6, §3.2). Independent per-node stacks + federation instead |
| 9 | Shared password compromise / no attribution | Medium if shortcuts taken | High | Named IAM users + MFA, per-person SSH/mesh keys, key-only SSH, revocation checklist |
| 10 | Oracle shrinks Always Free again (precedent: halved June 2026) | Medium over years | Medium | Stay within *current* limits, IaC portability, paid-VPS fallback plan (~$10–15/mo) |
| 11 | Accidental paid charges (non-free resource, cross-region transfer, PAYG slip) | Low–Medium | Low–Medium | Same-region only, Always-Free-eligible labels checked at creation, budget alerts, compartment quotas; never enter card-triggered upgrades casually |
| 12 | Mesh control plane (self-hosted NetBird/Headscale) goes down | Low | Low (existing peers keep working; new joins/config blocked) | Run on a micro with restic backup of its state; documented fallback to plain WireGuard configs; or use NetBird cloud free tier |
| 13 | Tailscale free tier used commercially by mistake | Low | Low (terms breach with Tailscale, not Oracle) | Use NetBird/Headscale/WireGuard for this commercial project, or pay for Tailscale (§2) |

## Safe Setup Outline (step-by-step)

1. **Agree the ground rules in writing first** (one page, signed by all 3): who owns which tenancy (themselves), team-owned assets list (domain, Git org, Cloudflare, vault), exit/rotation procedure, monthly owner duties. This document is also your legitimacy evidence.
2. **B signs up personally** (own device, home connection, VPN off): billing country Pakistan, own name/email/phone, home region **US West (Phoenix)**, own physical Visa/MC (international transactions enabled), accurate address matching the card. **C repeats independently** — ideally not as a copy-paste ceremony run by Partner A.
3. **During the trial, provision only Always Free shapes:** 1× A1 (2 OCPU/12 GB, 47–50 GB boot), then 2× E2.1.Micro, all in Phoenix, trying other ADs if "out of host capacity". Set day-25 trial-audit reminders.
4. **Harden each tenancy:** owner enables MFA; owner creates named IAM users for the other two partners with a scoped (non-admin, compartment-limited) policy; each partner sets own password/MFA/API key and an OCI CLI profile. No shared credentials anywhere.
5. **Plan IP space before creating VCNs:** non-overlapping CIDRs per tenancy (e.g. 10.11.0.0/16, 10.12.0.0/16, 10.13.0.0/16) so LPG peering or mesh subnet routing never collides later.
6. **Stand up the mesh:** deploy NetBird (self-hosted on A's Micro 2, or cloud free tier) or Headscale; enrol all instances + laptops; write ACLs (monitoring scrapes all; partners' laptops reach all admin ports; CI reaches staging only; backup nodes reach rest-servers only). Fallback: generate plain WireGuard peer configs from the same key inventory.
7. **(Optional, later) add OCI-native peering:** with all tenancies in Phoenix, set the Endorse/Admit policy pairs and LPG-peer the three VCNs (full mesh — peering is non-transitive — or hub via A's DRG). Use it for bulk private traffic; keep the mesh as the management path so the fleet never depends on peering alone.
8. **Deploy services per §3.3** via Ansible/Docker Compose from the team Git repo: node_exporter everywhere; Prometheus/Grafana primary in A, independent Prometheus in B; Kuma in A watched by Kuma in B; MinIO in B mirrored to C; staging + CI runners in C/B.
9. **Wire the backup triangle:** restic from every node → other two accounts' rest-servers/MinIO + one off-Oracle target; repository passwords in the team vault; schedule monthly automated restore drills on B's verification node and alert on backup failure via both Kumas.
10. **Publish through Cloudflare:** domain DNS on Cloudflare; Tunnel connectors for panel/Grafana/Kuma; Access policies (each partner's own login + MFA); optionally the $5/mo Load Balancer for status-page failover between A and C. No admin UI exposed directly to the internet.
11. **Run the loss drills once before relying on it:** (a) stop one A1 and confirm alerting + failover; (b) rebuild one micro from IaC + restic; (c) rehearse the partner-exit rotation checklist on paper. Set calendar items: monthly owner logins, quarterly drill, day-25 trial audits for B and C.
12. **Ongoing:** keep every account within current Always Free limits, watch Oracle's Always Free docs for changes (they changed silently before), and keep the paid-VPS fallback costed and documented.

## Could not verify

- **No live verification inside OCI:** no account was signed into (research rules), so whether a Free-Tier-only (never upgraded) tenancy can complete every cross-tenancy LPG/DRG policy flow in the Console today is documented-but-not-tested. Networking services are not listed as Always-Free-capped, and the A-Team guides assume standard tenancies; verify peering in B's tenancy early (step 7 is deliberately optional/late).
- **No Oracle statement found** that expressly addresses "different people pooling accounts for one project" — the legality conclusion is an inference from (i) the per-person wording, (ii) CSA Users language, and (iii) cross-tenancy docs for different companies. It is a strong inference, but Oracle has not published a blessing, and its enforcement is automated and unexplained (§5).
- **No report found** of Oracle banning a pooled multi-person fleet, and none of such a fleet operating — §5 is explicit that this is absence of evidence.
- **Pakistan-specific signup success:** no authoritative source confirms or denies Pakistan eligibility beyond the FAQ's general availability statement; community fraud-screen factors (§4) are consensus, not Oracle-published criteria. The $300 trial credit is described as available "in select countries" — whether a given Pakistani signup receives trial credit does not affect the Always Free design.
- **Tailscale/NetBird free-tier numbers** come from secondary comparisons dated Oct 2026 (Tailscale changes its packaging frequently); check current terms before choosing the mesh — the *non-commercial* caveat on Tailscale Personal is the load-bearing point.
- Older sources quoting **4 OCPU / 24 GB** A1 are outdated (halved ~June 2026); a specific existing tenancy may display grandfathered limits — plan new accounts on 2/12.

## Sources

Official Oracle (primary, preferred):
- Free Tier FAQ — https://www.oracle.com/ca-en/cloud/free/faq/ — opened 2026-11-14
- Always Free Resources — https://docs.oracle.com/en-us/iaas/Content/FreeTier/resourceref.htm — opened 2026-11-14
- Cloud Services Agreement (US online v062223) — https://www.oracle.com/ca-en/contracts/docs/cloud_csa_online_v062223_us_eng.pdf — opened 2026-11-14
- IAM Policies for Routing Between VCNs (cross-tenancy peering) — https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/drg-iam.htm — opened 2026-11-14
- Accessing Object Storage Across Tenancies — https://docs.oracle.com/iaas/Content/Object/Concepts/accessingresourcesacrosstenancies.htm — index 2026-11-14
- Object Storage FAQ (replication = intra-tenancy) — https://Www.oracle.com/sa/cloud/storage/object-storage/faq/ — index 2026-11-14
- DRG product/pricing page — https://www.Oracle.com/ae/cloud/networking/dynamic-routing-gateway/ — index 2026-11-14
- VCN pricing — https://www.oracle.com/it/cloud/networking/virtual-cloud-network/pricing/ — index 2026-11-14
- Signup flow strings (billing country vs home region) — https://signup.cloud.oracle.com/translations/en-US/translation.json — index 2026-11-14
- Oracle A-Team: cross-tenancy connectivity — https://www.ateam-oracle.com/how-to-establish-native-cross-tenancy-connectivity-in-oci-iam-policies-and-considerations — index 2026-11-14
- Oracle A-Team: multi-tenancy network architectures — https://www.ateam-oracle.com/oci-network-architectures-for-multiple-tenancies — index 2026-11-14
- Oracle Blogs: OCI Organizations — https://blogs.oracle.com/cloud-infrastructure/post/use-organizations-to-centrally-manage-costs — index 2026-11-14

Technical (other primary/vendor docs):
- K3s distributed hybrid/multicloud — https://docs.k3s.io/networking/distributed-multicloud?_highlight=vpn — index 2026-11-14
- etcd recommended practices (OKD docs) — https://docs.okd.io/latest/etcd/etcd-practices.html — index 2026-11-14
- Cloudflare plans (Load Balancing add-on from $5/mo) — https://www.cloudflare.com/plans/application-services/ — index 2026-11-14

Community / secondary (labelled as such in the text):
- Mesh comparison & Tailscale non-commercial free tier — https://www.vpnsmith.com/en/blog/netbird-vs-tailscale-2026 ; https://github.com/pinggy-io/pinggy_website/blob/HEAD/content/blog/top_open_source_tailscale_alternatives.md
- Cloudflare Tunnel behaviour — https://www.builddaily.io/resources/cloudflare-tunnel/
- Uptime Kuma multi-instance pattern — https://www.amireslampanah.com/tutorials/uptime-kuma-monitoring.html
- Signup fraud-screen consensus & Phoenix capacity — https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets ; https://site2us.com/en/servers/oracle-cloud-free-tier
- Termination reports — https://community.oracle.com/customerconnect/categories/oci-cloud-infrastructure-general/p2?sort=hot ; https://au.trustpilot.com/review/oracle.com?page=3 ; https://www.bbb.org/us/tx/austin/profile/computer-software-developers/oracle-america-inc-0825-1000192832/complaints ; https://readmedium.com/oracle-free-tier-is-not-free-36b3c12375a2
- Prohibited-pattern contrast (second account via relatives' details) — https://k21academy.com/oracle/video-register-free-oracle-cloud-trial-account/
- Karachi→US latency measurements — https://wondernetwork.com/pings/Karachi

*No page encountered issued instructions to this research; all pages were treated as evidence only.*
