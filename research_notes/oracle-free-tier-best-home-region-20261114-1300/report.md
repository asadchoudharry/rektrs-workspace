# Oracle Cloud Free Tier — Best Home Region for a Pakistan-Billing Signup (November 2026)

## Summary

**Pick US West (Phoenix) — `us-phoenix-1` — as the home region. Second choice: US Midwest (Chicago) — `us-chicago-1`. Third choice: UK South (London) — `uk-london-1`.**

That ranking is built on: (a) *documented* structure — Phoenix, Chicago and London are three of only five regions worldwide with **3 availability domains**, and capacity is per-AD, so a 3-AD region gives three independent chances on every attempt, versus one chance in every other region; and (b) *anecdotal* 2026 community evidence — Phoenix is the region most often named in Oct–Nov 2026 guides as the first choice / "safe default" for actually getting an Ampere A1, Chicago has specific "less busy / plenty of A1 capacity" reports from 2026, while Ashburn and Frankfurt (the other 3-AD regions) are repeatedly reported as the most chronically full, Frankfurt verifiably so in a real-tenancy test in July 2026.

**Critical correction to almost every older tutorial:** the Always Free A1 allowance was **halved in June 2026**. A brand-new Nov 2026 Always Free tenancy gets **2 OCPUs / 12 GB RAM total** (1,500 OCPU-hours + 9,000 GB-hours/month), *not* 4 OCPUs / 24 GB. Plan and size instances accordingly — requesting 4/24 on a free tenancy fails with `LimitExceeded`, not capacity errors.

**No region guarantees success.** Oracle publishes no per-region free-capacity data, every capacity claim below is anecdotal and sources conflict (one Nov 2026 guide lists Phoenix among the "busiest" regions). The tactics in §4 — try all ADs, start at 1 OCPU/6 GB, run a retry script, and above all **upgrade to Pay As You Go immediately after signup** — matter as much as the region. PAYG is the single most consistently reported fix for "out of capacity" in 2025–26 community evidence, and Oracle documents that Always Free resources stay free after upgrading.

**On billing country:** billing country and home region are separate signup steps. There is no evidence Oracle restricts the home-region list by billing country, and non-US signups routinely choose Phoenix/Frankfurt. *But* the list is **not** all commercial regions — Oracle's own signup text says "Free Tier is not available in all commercial data regions," and the exact list is only visible in the dropdown during signup. Verify Phoenix/Chicago/London actually appear in the dropdown before committing; if Phoenix is absent, take Chicago, then London.

---

## Findings

### 1. Current Always Free allowance and rules (official Oracle documentation)

All facts in this section are **documented** — from Oracle's official Always Free Resources page and Free Tier FAQ, read 2026-11-14.

**Compute — Ampere A1 (Arm)**
- All tenancies get the **first 1,500 OCPU hours and 9,000 GB hours per month free** for `VM.Standard.A1.Flex`. "For Always Free tenancies, this is equivalent to **2 OCPUs and 12 GB of memory**" — total across all A1 instances: one 2 OCPU/12 GB instance, or two 1 OCPU instances.
  Source (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm
- Oracle confirmed the new allocation in its own forum post of **2026-07-21**: 2 OCPUs total, 12 GB total, 1,500/9,000 monthly equivalent; A1 available in the tenancy home region; **South Korea North (Chuncheon) is not available for Always Free A1**.
  Source (verified via page fetch, 2026-11-14): https://community.oracle.com/customerconnect/discussion/970310/oci-always-free-updated-ampere-a1-compute-allocation
- The change itself: Oracle's docs changed between 2026-06-05 and 2026-06-12 (commonly dated **15 June 2026**), cutting the allowance from 3,000/18,000 hours (4 OCPU/24 GB) with no public announcement; enforcement — disabling/termination of over-limit Always Free instances — was reported from **18 August 2026**. Reported by InfoQ in July 2026 and corroborated by many Oct–Nov 2026 guides checked for this report.
  Sources (index, 2026-11-14): https://fullmetalbrackets.com/blog/oci-free-tier-breakdown ; https://dev.to/karthik_yk/oracles-famous-free-4-core24gb-arm-tier-is-now-2-core12gb-check-the-docs-2jln
- **PAYG ambiguity (do not plan around it):** whether paid tenancies keep 4 OCPU/24 GB free is disputed. InfoQ reported support agents giving conflicting answers in June 2026; one PAYG blogger reported still being uncharged for a 4/24 A1 instance on 26 Oct 2026 (single anecdote, fullmetalbrackets above), while another Oct 2026 analysis notes Oracle's docs give *all* tenancies 1,500/9,000 and excess A1 would cost roughly $27–28/month at list prices. For a new signup, assume **2/12 is the free ceiling on any account type**.

**Compute — AMD micro**
- "All tenancies get **up to two** Always Free VM instances using the `VM.Standard.E2.1.Micro` shape" — each 1/8 OCPU, 1 GB RAM.
- **Placement restriction that matters for region choice:** in multi-AD regions, A1 instances can be created in *any* AD (except Chuncheon), but **E2.1.Micro instances can only be created in one AD** — and which AD holds the micro quota varies per tenancy (see §2, Chicago/Frankfurt examples).
  Source (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm

**Storage / network**
- **200 GB total** Always Free block volume storage (boot + block volumes combined), minimum boot volume 47 GB per instance, plus 5 volume backups. Block volumes must be in the home region to be free.
- **Object Storage: 20 GB combined** across Standard/Infrequent Access/Archive tiers + 50,000 API requests/month for Always Free-only accounts (trial/paid accounts instead get 10 GB *per tier*). Summaries of Oracle's Always Free page checked Oct–Nov 2026 (index): https://techcommune.org/docs/cloud-tutorials/oci-account.html ; https://rythium.com/oracle-cloud-free-tier/
- 10 TB/month outbound data transfer.

**Home-region restriction**
- "You must create the Always Free compute instances in your **home region**." The home region is chosen at signup and **cannot be changed** — confirmed identically in the docs, the FAQ, and the signup UI itself ("Your home region selection cannot be changed after this step in the sign-up process").
  Sources (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm ; https://signup.cloud.oracle.com/translations/en-US/translation.json

**"Out of host capacity" — Oracle's own framing**
- The error "indicates a temporary lack of Always Free shapes in your home region. Try creating the instance in a different availability domain, or wait a while… You can also choose to upgrade your account to Pay as You Go… Oracle doesn't charge for Always Free resources after you upgrade, and will only charge you for resource usage above the Always Free limits." The FAQ adds capacity "might take several days" to appear.
  Sources (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm ; https://www.oracle.com/cloud/free/faq/

**Idle reclamation policy (documented)**
- "Idle Always Free compute instances may be reclaimed by Oracle" if, during a **7-day period, all** of these are true: **CPU utilisation (95th percentile) < 20%, network utilisation < 20%, and memory utilisation < 20% (memory applies to A1 shapes only)**.
  Source (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm
- Separately, the FAQ: "Accounts left idle for 30 days or more may be deemed abandoned and become eligible for suspension or termination," and only one free account per person is permitted (creating multiple accounts to change regions is prohibited — also stated in the signup UI).
  Source (verified via page fetch, 2026-11-14): https://www.oracle.com/cloud/free/faq/
- Trial-end trap: if total A1 provisioned exceeds the Always Free limit when the 30-day trial ends, **all** A1 instances are disabled and deleted after 30 days unless the account is upgraded. Keep A1 ≤ 2 OCPU/12 GB total before trial end on a free tenancy.
  Source (verified via page fetch, 2026-11-14): https://www.oracle.com/cloud/free/faq/

### 2. Per-region free-tier capacity reality, 2025–2026

**Everything in this section is anecdotal.** Oracle publishes no per-region Always Free capacity statistics, and no source found offers systematic measurement — only individual tenancy experiences, guides synthesising community reports, and retry-script projects. Reports conflict and capacity shifts over time; dates are given for each claim.

**Structural fact (documented) that frames everything:** only **five** commercial regions have 3 availability domains — **Ashburn, Phoenix, Chicago, Frankfurt, London**. Every other commercial region (Mumbai, Hyderabad, Singapore, Tokyo, Osaka, Sydney, Amsterdam, Zurich, Johannesburg, San Jose, etc.) has exactly **1 AD**. Since A1 capacity is allocated per AD, a 3-AD home region gives three independent pools to try on every attempt; a 1-AD region gives one.
Source (verified via page fetch, 2026-11-14): https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

**Chronically "out of capacity" — strongest/most repeated reports:**
- **Mumbai (`ap-mumbai-1`)** — "chronically exhausted" (FreeTierWatch/DEV, 2026-10-08); Hyderabad "more often has free Arm capacity" by comparison (Oct 2026 India guides). Mumbai also has only 1 AD, so there is no second AD to try. Avoid.
  Sources (index): https://dev.to/karthik_yk/oracles-famous-free-4-core24gb-arm-tier-is-now-2-core12gb-check-the-docs-2jln ; https://www.kevinsingh.com/p/oracle-cloud-always-free-in-2026 ; https://codewithnishant.dev/free/oracle-cloud-free-server/
- **Frankfurt (`eu-frankfurt-1`)** — hardest evidence found against any region: a real-tenancy verification log dated **2026-07-15** recorded `500 Out of host capacity` for A1 on **every attempt in all 3 ADs** of Frankfurt. Also rated "Rare / high EU demand" in a 2026 region table, and listed among the popular depleted regions (Ashburn, Frankfurt, Mumbai, London) in an Aug 2026 guide. Avoid despite its 3 ADs.
  Sources (index): https://github.com/tooming/k8s-anywhere/blob/HEAD/docs/done/2026-07-15-oracle-backend-live-verification-partial.md ; https://www.devinfo.dev/paper/from-free-tier-to-sovereignty/pdf ; https://klickspell.com/blog/fix-oracle-cloud-out-of-host-capacity
- **Singapore, Tokyo, Seoul** — "chronically contested; you may wait days or never get an instance" (2026-10-27); "Korean and Tokyo regions are almost always at full ARM A1 allocation" (Korean-user guide, May 2026). All are 1-AD regions. Avoid.
  Sources (index): https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets ; https://github.com/stophobia/vibe-investing2/blob/HEAD/TechDoc/OracleCloud/02.%20Oracle%20Cloud%20Free%20Tier%20Guide_EN.md
- **Ashburn (`us-ashburn-1`)** — "Rare / highest demand" (2026 table); "perpetually out of stock" along with Phoenix and Frankfurt (~Mar 2026); multiple guides say "US East (Ashburn) — often full." Avoid as a first pick despite 3 ADs.
  Sources (index): https://www.devinfo.dev/paper/from-free-tier-to-sovereignty/pdf ; https://blog.ylab3.com/claude-code-tips-i-wish-i-knew-sooner ; https://www.iybots.com/blog/oracle-cloud-free-vps-setup

**Reported successes / recommended regions:**
- **Phoenix (`us-phoenix-1`)** — the most-endorsed region in late-2026 sources: "Phoenix (US West) — the safe default. Reliable ARM availability. Unless you have a hard latency requirement, pick this" (2026-10-27); "Phoenix (US) — first choice, low competition… latency isn't the top priority; actually getting the machine is" (Oct 2026); listed as a good multi-AD pick in other 2026 guides; one docs-based author was actually running an A1 instance in `phx` at the new 2/12 size on 2026-08-12. Bonus: Always Free NoSQL Database is Phoenix-only (per Oracle FAQ list).
  Sources (index): https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets ; https://byronfinn.github.io/en/oracle-free-vps-guide/ ; https://yangworks.dev/guides/oracle-cloud-always-free-vps ; https://www.oracle.com/cloud/free/faq/
  **Counter-evidence (must be stated):** a Nov 10, 2026 guide advises avoiding "the busiest ones (Ashburn, Frankfurt, Phoenix), where free Arm capacity runs out most often," and a Sep 2026 guide calls Ashburn/Phoenix "the most frequently congested" while claiming Frankfurt/Singapore/Tokyo provision more often — the exact opposite of the sources above. There is no stable consensus; Phoenix is a best-bet, not a safe bet.
  Sources (index): https://myclawbots.ai/blog/oracle-cloud-always-free-server-setup ; https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix
- **Chicago (`us-chicago-1`)** — a workshop guide *tested 2026-03-13 on us-chicago-1* recommends it as home region "because less busy / more free A1 available possible"; a separate account-setup note (undated, still quotes old 4/24 limits) claims "us-chicago-1 (Plenty of A1.Flex capacity!)… Guaranteed A1.Flex capacity in Chicago — no more Montreal capacity issues."
  Sources (index): https://github.com/pingwu/solo-unicorn/blob/HEAD/docs/claw/openclaw/openclaw-deploy-to-oci-instructions.md ; https://github.com/nrupala/aetheris/blob/HEAD/config/oracle-vm/new-account-setup.md
  **Chicago-specific risks (two 2026 tenancy reports conflict):** one tenancy found A1 out of capacity in all Chicago ADs as a free-tier account *and* reported E2.1.Micro as the shape offered only in `US-CHICAGO-1-AD-2` (July 2026 notes); another tenancy's architecture log found Chicago's shape list contained **no E2 shapes at all** and an E2.1.Micro launch returned 404 — "the region is built on E4/E5 hardware" — leaving A1 as the only Always Free shape *for that tenancy*. These cannot both be generally true; the safe reading is that in Chicago the micro quota lives in a single, tenancy-specific AD (consistent with Oracle's documented one-AD rule for E2.1.Micro) and may be hard to find/launch. If the two AMD micros are non-negotiable, prefer London over Chicago (see §5).
  Sources (index): https://github.com/fkadriver/nixos/blob/HEAD/docs/nebula.md ; https://github.com/bbarber/evsolarchargecontroller/blob/HEAD/docs/ARCHITECTURE-DECISIONS.md
- **London (`uk-london-1`)** — 3 ADs; rated "Occasional" availability (vs "Rare" for Ashburn/Frankfurt) in the 2026 devinfo table; but also listed among regions that "often show out of capacity" in an Oct 2026 guide, and Oracle's own LiveLabs pre-registration doc (updated Nov 2025) advises workshop users not to use London "at this time." Mixed, but structurally advantaged.
  Sources (index): https://www.devinfo.dev/paper/from-free-tier-to-sovereignty/pdf ; https://github.com/projectalphatech/oracle-free-vps ; https://github.com/oracle-livelabs/common/blob/HEAD/labs/cloud-login/pre-register-free-tier-account.md
- **Single-AD alternatives sometimes praised:** Hyderabad ("usually the easier pick" vs Mumbai — but still 1 AD and in the same high-demand Indian pool); Sydney ("Better / lower demand" in the devinfo table; "sometimes more capacity" in an Oct 2026 guide); São Paulo ("Better" in the same table); Osaka (a May 2026 Korean guide calls Osaka easier than Seoul, while calling Tokyo almost always full). None of these has evidence as strong or as recent as the Phoenix endorsements, and each offers only one AD to retry in.
  Sources (index): https://dev.to/karthik_yk/oracles-famous-free-4-core24gb-arm-tier-is-now-2-core12gb-check-the-docs-2jln ; https://www.devinfo.dev/paper/from-free-tier-to-sovereignty/pdf ; https://www.cloudpicked.com/oracle-cloud-free-tier-guide-en.html
- **E2.1.Micro fallback reality:** the AMD micros are "almost always available in every region" per a Sep 2026 capacity guide, and multiple Nov 2026 guides treat the micro as the reliable fallback while A1 is full — *except* for the Chicago anomaly above, and subject to finding the single AD that holds your tenancy's micro quota (documented examples: Frankfurt quota in AD-2 for one tenancy, AD-3 for another; Ashburn examples point to AD-3).
  Sources (index): https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix ; https://github.com/de-ar/oracle-forever-free/blob/HEAD/README.md ; https://github.com/tooming/k8s-anywhere/blob/HEAD/docs/done/2026-07-15-oracle-backend-live-verification-partial.md

**Capacity-tracker / retry projects:** there is no public live per-region capacity dashboard from Oracle. The ecosystem is retry scripts that poll the LaunchInstance API in *your own* home region (they cannot scout other regions for a free tenancy): the classic `hitrov/oci-arm-host-capacity` (PHP; archived since 2024 and stale on limits), and 2026-maintained successors such as `hunt-a1` (cron every 2 min, rotates AD-1→AD-2→AD-3, defaults updated to 2 OCPU/12 GB), `oci-arm-catcher` (rotates ADs, polite interval), `oci-arm-retry` (GitHub Actions), and ITFriks' `oci-a1-retry` (Nov 2026, retries every 5 min via Resource Manager stacks).
Sources (index): https://github.com/moodtuner997/hunt-a1/blob/HEAD/README.md ; https://github.com/alexpua/oci-arm-catcher/blob/HEAD/README.md ; https://github.com/wendychen330/oci-arm-retry/blob/HEAD/README.md ; https://www.itfriks.com/oracle-cloud-free-arm-vm-out-of-capacity/

### 3. Does the home-region list differ by billing country? (Pakistan)

**Short answer: No evidence that billing country restricts which home regions you may pick — but the list is NOT "any commercial region." It is a subset, visible only in the signup dropdown.**

Documented facts:
- Billing country and home region are **separate steps**. The signup UI labels the first field "Billing Country/Territory" with the note: "Please choose the country you will use for billing details, if the account converts to paid. **Home region will be selected later** in the sign up process."
  Source (verified via page fetch, 2026-11-14): https://signup.cloud.oracle.com/translations/en-US/translation.json
- The same official signup text states the restriction plainly: "**Free Tier is not available in all commercial data regions.** Please select the data region that is closest to your location. If your project requires access to [a] specific data region not available in Free Tier, please consider sign up for a pay as you go account…" — and warns "It is possible that any region may or may not have availability."
  Source (verified via page fetch, 2026-11-14): https://signup.cloud.oracle.com/translations/en-US/translation.json
- The FAQ phrases it more loosely — Free Tier "is currently available in all regions where commercial Oracle Cloud Infrastructure service is available" with a footnote, adding "**If your first-choice data region isn't available, please select an adjacent region**" — which itself confirms some first choices are unavailable in the flow.
  Source (verified via page fetch, 2026-11-14): https://www.oracle.com/cloud/free/faq/

Evidence that a non-US billing country does **not** lock you to nearby regions (anecdotal/practice, consistent across many country-specific guides):
- India-billing guides (Oct 2026) explicitly discuss readers choosing Ashburn, Phoenix, Frankfurt, London or Chicago as home region for capacity reasons; Korean, Bangladeshi, Nepalese and generic guides similarly instruct choosing Phoenix or Frankfurt with local billing details. None reports a country-based region restriction.
  Sources (index): https://www.technicaladda.in/oracle-cloud-free-tier-vps/ ; https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets
- Pakistan-specific: a community article reviewed 2026-10-14 recounts helping a Pakistani developer through OCI signup — region selection proceeded normally and the failures occurred at **payment verification** (two funded cards declined before a third succeeded). It notes there is no OCI region in Pakistan. The reported Pakistan gate is the **card**, not the region list. (Single anecdote; the author himself warns against generalising it.)
  Source (index): https://oraclewithhassan.com/oracle-developer-pakistan-talent-access-gap/

Practical conclusions for a Pakistan-billing signup:
- Expect Ashburn, Phoenix, Chicago, Frankfurt, London, Amsterdam, Zurich, Johannesburg, Sydney, Osaka, Mumbai, Singapore etc. to be *candidates* — the long-established commercial regions are the ones guides worldwide select from — but **treat the dropdown at signup as the only authoritative list**. Newer/特殊 regions (e.g. Chuncheon for A1, US Government/DoD realms, Serbia's OC20-realm Jovanovac region, the newest single-AD regions) may be absent or useless for Always Free: Chuncheon can be a home region but **cannot provision Always Free A1 at all**.
- If Phoenix does not appear in the dropdown, do not improvise — fall back in the order Chicago → London (§5). Do **not** create multiple accounts to change regions: Oracle prohibits it and states it in the signup flow.
- Separate Pakistan risk to budget for: card verification. Oracle rejects virtual/prepaid/single-use cards (documented, signup UI + FAQ); use a physical Visa/Mastercard (credit or credit-like debit) in the signup person's name, with details matching the billing address, and expect a small temporary verification hold.

### 4. Practical provisioning tactics after signup

In rough order of documented/reported effectiveness:

1. **Upgrade to Pay As You Go (PAYG) — the highest-impact step (evidence: documented in part, anecdotal in effect).**
   - *Documented:* Oracle's FAQ says "**Pay As You Go accounts are subject to different capacity limits than Always Free accounts**"; the Always Free docs say upgrading gives access to more resource types, "**Oracle doesn't charge for Always Free resources after you upgrade**, and will only charge you for resource usage above the Always Free limits." Upgrade involves a temporary ~$100 card hold (per signup UI text and community guides).
     Sources (verified via page fetch, 2026-11-14): https://www.oracle.com/cloud/free/faq/ ; https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm
   - *Anecdotal (strong, consistent 2025–26):* community sources repeatedly call PAYG "the reliable fix" / "most surefire way" to provision A1, "community-consistent 2025–26," with paid tenancies drawing from a different/larger capacity pool.
     Sources (index): https://github.com/takimdigital/deckhand-skill/blob/HEAD/skills/deckhand/references/ops/11-oracle-free-tier.md ; https://fullmetalbrackets.com/blog/oci-free-tier-breakdown ; https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix
   - *Counterpoint (anecdotal):* an Oct 2026 analysis stresses PAYG "does not add physical capacity and does not guarantee a successful launch" — PAYG accounts also hit out-of-host-capacity. Treat PAYG as a large odds improvement, not a guarantee.
     Source (index): https://jason-finance.com/en/oracle-out-of-host-capacity/
   - *Idle reclamation:* many community guides claim PAYG tenancies are exempt from idle reclamation. **This could not be verified in Oracle's current docs/FAQ** (the docs state the idle policy for "Always Free compute instances" without an account-type exemption, and one widely-copied "official quote" of an exemption does not appear in the Oracle pages read for this report). Do not rely on a PAYG idle exemption; keep the instance genuinely utilised regardless.
   - *Risk control on PAYG:* the free-tier guardrails disappear — anything above 2 OCPU/12 GB, 200 GB block, etc. is billed. Set a small budget alert immediately (budgets only alert, they do not cap spending) and double-check every shape before creating.

2. **Try every availability domain, and leave the fault domain unspecified (documented + anecdotal).** Capacity is per AD (and per fault domain). In a 3-AD region, attempt AD-1, AD-2 and AD-3 in rotation; do not pin a fault domain — Oracle then places the instance in the FD with room. This is Oracle's own first recommendation in both the docs and the FAQ.
   Sources (verified via page fetch, 2026-11-14): https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm ; https://www.oracle.com/cloud/free/faq/

3. **Start small: 1 OCPU / 6 GB, then resize up (anecdotal, universally repeated).** A 1 OCPU A1 request fits into fragmented host capacity that rejects a 2 OCPU request; once the instance exists, edit its shape up to the full 2 OCPU/12 GB. Every Nov 2026 capacity guide found recommends this sequence.
   Sources (index): https://www.itfriks.com/oracle-cloud-out-of-capacity-a1/ ; https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix

4. **Automate retries instead of clicking (anecdotal, with working 2026 projects).** Run a retry script from a machine that is already up (an E2.1.Micro you provisioned first is the classic host, or a local machine / GitHub Actions): `hunt-a1`, `oci-arm-catcher`, `oci-arm-retry`, `oci-a1-retry` (§2). Use polite intervals — roughly every 2–5 minutes, rotating ADs; hammering every few seconds triggers `429 TooManyRequests` throttling that locks you out of the very windows you are hunting. Scripts should stop on non-capacity errors (`LimitExceeded` = you asked for more than 2/12; fix the request, don't keep retrying).
   Sources (index): https://github.com/moodtuner997/hunt-a1/blob/HEAD/README.md ; https://github.com/alexpua/oci-arm-catcher/blob/HEAD/README.md ; https://medium.com/@adnansattar09/the-free-server-that-refuses-to-die-a-reclamation-proof-multi-model-llm-gateway-on-oracle-clouds-a14f14fba984

5. **Check capacity before launching (documented tooling).** OCI CLI: `oci compute compute-capacity-report create` returns `AVAILABLE` / `OUT_OF_HOST_CAPACITY` per AD/shape — a snapshot only; capacity can vanish a minute later.
   Source (index): https://www.itfriks.com/oracle-cloud-out-of-capacity-a1/

6. **Provision the fallback first.** Create the two E2.1.Micro instances (in the one AD that holds your micro quota — check Limits/Quotas in the console per AD, or try each AD) and your block/object storage immediately; they are rarely capacity-blocked (Chicago caveat aside). Then hunt A1 in the background. Boot-volume budgeting: 4 instances × 47 GB minimum = 188 GB of the 200 GB pool, so plan boot sizes deliberately (e.g. A1 100 GB + micros 47 GB each ≈ 194 GB).
   Sources: docs (verified, §1) + https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix (index)

7. **Keep it alive afterwards.** On an Always Free tenancy, avoid the 7-day idle trap (all of CPU p95, network, and A1 memory < 20%): run real workloads; a token ping does not move 95th-percentile metrics. Log in at least monthly (30-day abandoned-account rule).

### 5. Ranked recommendation

| Rank | Home region | ADs | Why (evidence type) | Main risk |
|---|---|---|---|---|
| **1** | **US West (Phoenix) — `us-phoenix-1`** | 3 | Most-endorsed region in Oct–Nov 2026 capacity-focused guides ("safe default / reliable ARM availability"; "first choice, low competition" — *anecdotal*); 3 ADs to rotate (*documented*); a real A1 instance documented running there at the new limits in Aug 2026 (*anecdotal*); no reports of missing E2.1.Micro shape; bonus: Always Free NoSQL is Phoenix-only (*documented*) | Two sources (Sep & Nov 2026) instead list Phoenix among the most congested US regions — expect to still need the retry script and/or PAYG |
| **2** | **US Midwest (Chicago) — `us-chicago-1`** | 3 | Specifically recommended as "less busy / more free A1 available" in a guide tested on Chicago in Mar 2026, plus a "plenty of A1.Flex capacity" account report (*anecdotal*); 3 ADs (*documented*); generally less recommended-by-default than Phoenix/Ashburn, so plausibly a smaller free-tier crowd | Conflicting tenancy reports on E2.1.Micro in Chicago (offered only in AD-2 vs. launch failing 404 entirely) — the AMD micros may be hard or, worst case, impossible to launch; one free account also found A1 full in all 3 ADs (July 2026) |
| **3** | **UK South (London) — `uk-london-1`** | 3 | Last remaining 3-AD region not reported chronically full: rated "Occasional" vs "Rare" for Ashburn/Frankfurt (*anecdotal table*); E2.1.Micro has no reported absence problem in London | Mixed signals: listed among often-full regions in one Oct 2026 guide; Oracle LiveLabs advised against London for workshops (Nov 2025). Still structurally ahead of every 1-AD region |

**Explicitly not recommended, despite being 3-AD regions:** Frankfurt (verified all-AD A1 exhaustion in a real tenancy, July 2026; "rare/high demand") and Ashburn ("highest demand" in every table found). **Not recommended as single-AD picks:** Mumbai and Singapore (chronically exhausted — the failure mode that prompted this research), Tokyo/Seoul (almost always full; Seoul's sibling Chuncheon cannot run free A1 at all). If none of Phoenix/Chicago/London appears in the signup dropdown, the best single-AD fallbacks on current evidence are **Hyderabad** (consistently "easier than Mumbai") and then **Sydney** — accepting that a 1-AD region means one capacity pool and longer expected waits.

**Decision rule at the signup screen:** select **Phoenix** if it is offered. Before finalising, nothing else needs checking — latency is irrelevant per the brief, and Phoenix's capacity reputation is the best available bet. Immediately after signup: (1) create the two E2.1.Micro instances and claim storage, (2) upgrade to PAYG (with a budget alert) *before* hunting A1 if the card can tolerate the ~$100 temporary hold, (3) launch A1 at 1 OCPU/6 GB rotating all 3 ADs, resize to 2/12 on success, (4) if manual attempts fail for a day, deploy a retry script and let it run.

**Confidence:** Moderate for the *structure* of the recommendation (3-AD regions + Phoenix-first is supported by the greatest number of independent recent sources), low for any region's capacity on any given day — capacity is transient, unmeasured publicly, and the anecdotal record contradicts itself on Phoenix. The PAYG upgrade + retry-script plan is what converts this from a lottery into a high-probability outcome, in any of the three ranked regions.

---

## Could not verify

- **The exact home-region dropdown for a Pakistan-billing signup.** It appears only inside the live signup flow after email verification; enumerating it would require entering personal data / creating an account, which was out of scope. All §3 conclusions rest on Oracle's published signup text, the FAQ, and cross-country guide practice — the dropdown itself is the final authority.
- **Any Pakistan-specific trial-credit or region restriction.** No source found states one; the FAQ says trial credit terms vary and the signup UI has a generic "free trials are currently not provided in this country" string for restricted countries, with no published country list found.
- **Whether PAYG tenancies are exempt from idle reclamation, and whether PAYG keeps 4 OCPU/24 GB free.** Both are widely claimed in community sources; neither is stated in the Oracle docs/FAQ read on 2026-11-14, and support answers on the 4/24 question were reported as conflicting. This report plans on 2/12 and on keeping instances utilised.
- **Direct Reddit r/oraclecloud threads.** Search indexing surfaced almost no direct Reddit content for 2025–26 region-capacity threads (several guides cite r/oraclecloud sentiment second-hand). Region claims above therefore rest on dated blogs, GitHub tenancy logs, and Oracle's forum rather than first-hand Reddit posts; treat them as anecdotal accordingly.
- **No page instructions were followed:** no source attempted to redirect this research; nothing in the browsed content was treated as an instruction.

## Sources

Official Oracle (fetched and read 2026-11-14):
- Always Free Resources — https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm
- FAQ on Oracle's Cloud Free Tier — https://www.oracle.com/cloud/free/faq/
- Signup UI strings (billing country vs home region; "Free Tier is not available in all commercial data regions") — https://signup.cloud.oracle.com/translations/en-US/translation.json
- Regions and Availability Domains (AD counts per region) — https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
- OCI Always Free: Updated Ampere A1 Compute Allocation, Oracle Cloud Customer Connect, 2026-07-21 — https://community.oracle.com/customerconnect/discussion/970310/oci-always-free-updated-ampere-a1-compute-allocation

Community / secondary (via web index, 2026-11-14; dates as noted in text):
- https://aiskill.market/blog/oracle-always-free-tier-the-server-everyone-forgets (2026-10-27)
- https://byronfinn.github.io/en/oracle-free-vps-guide/ (Oct 2026)
- https://myclawbots.ai/blog/oracle-cloud-always-free-server-setup (2026-11-10)
- https://aicredits.tech/blog/oracle-cloud-out-of-capacity-fix (Sep 2026)
- https://www.itfriks.com/oracle-cloud-out-of-capacity-a1/ (2026-11-09)
- https://jason-finance.com/en/oracle-out-of-host-capacity/ (checked 2026-10-12)
- https://fullmetalbrackets.com/blog/oci-free-tier-breakdown (updated 2026-10-26)
- https://github.com/tooming/k8s-anywhere/blob/HEAD/docs/done/2026-07-15-oracle-backend-live-verification-partial.md (2026-07-15)
- https://github.com/pingwu/solo-unicorn/blob/HEAD/docs/claw/openclaw/openclaw-deploy-to-oci-instructions.md (tested 2026-03-13)
- https://github.com/nrupala/aetheris/blob/HEAD/config/oracle-vm/new-account-setup.md
- https://github.com/fkadriver/nixos/blob/HEAD/docs/nebula.md (2026-07-08)
- https://github.com/bbarber/evsolarchargecontroller/blob/HEAD/docs/ARCHITECTURE-DECISIONS.md
- https://github.com/de-ar/oracle-forever-free/blob/HEAD/README.md
- https://www.devinfo.dev/paper/from-free-tier-to-sovereignty/pdf (2026)
- https://dev.to/karthik_yk/oracles-famous-free-4-core24gb-arm-tier-is-now-2-core12gb-check-the-docs-2jln (2026-10-08)
- https://www.kevinsingh.com/p/oracle-cloud-always-free-in-2026 (2026-10-26)
- https://codewithnishant.dev/free/oracle-cloud-free-server/ (Oct 2026)
- https://www.technicaladda.in/oracle-cloud-free-tier-vps/ (updated 2026-10-10)
- https://yangworks.dev/guides/oracle-cloud-always-free-vps (checked 2026-08-12)
- https://github.com/takimdigital/deckhand-skill/blob/HEAD/skills/deckhand/references/ops/11-oracle-free-tier.md (verified 2026-09-18)
- https://github.com/moodtuner997/hunt-a1/blob/HEAD/README.md
- https://github.com/alexpua/oci-arm-catcher/blob/HEAD/README.md
- https://github.com/wendychen330/oci-arm-retry/blob/HEAD/README.md
- https://www.itfriks.com/oracle-cloud-free-arm-vm-out-of-capacity/ (2026-11-09)
- https://oraclewithhassan.com/oracle-developer-pakistan-talent-access-gap/ (reviewed 2026-10-14)
- https://techcommune.org/docs/cloud-tutorials/oci-account.html (read 2026-10-06 by its author)
- https://rythium.com/oracle-cloud-free-tier/ (checked 2026-11-01)
- https://blog.ylab3.com/claude-code-tips-i-wish-i-knew-sooner
- https://www.cloudpicked.com/oracle-cloud-free-tier-guide-en.html (Oct 2026)
- https://github.com/oracle-livelabs/common/blob/HEAD/labs/cloud-login/pre-register-free-tier-account.md (updated Nov 2025)
