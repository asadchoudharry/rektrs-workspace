# Trusted Free / Lifetime-Free Services List — System ke liye
**Date checked:** 9 Nov 2026 (providers ki apni pricing pages / recent verified comparisons se)
**Assad / Rektrs ke systems ke liye:** Operqon ERP, IQRS Web + Mobile, Rektrs School ERP

> **Sab se zaroori baat:** Koi company "lifetime guaranteed" ka contract nahi deti. Free tier ek business decision hai — kabhi bhi change ho sakta hai. Misal: SendGrid ka free plan May 2025 mein khatm ho gaya, PlanetScale/Xata ka free tier khatm ho gaya, AWS ne July 2025 mein apna free model badal diya. Is liye strategy ye hai: **(1) hamesha standard S3 API / standard Postgres use karo taake migration asaan ho, (2) data ki copy 2–3 alag providers par rakho (3-2-1 backup rule), (3) production ka wahid copy kabhi sirf free tier par mat rakho.**

---

## 1. S3 / R2 Object Storage — Permanent Free (expiry nahi)

| # | Company | Free (har mahina, hamesha) | Egress | Notes |
|---|---------|---------------------------|--------|-------|
| 1 | **Cloudflare R2** ⭐ | 10 GB storage, 1M Class A ops, 10M Class B ops | **Unlimited — $0** | Sab se behtreen. S3-compatible. Paid: $0.015/GB. Card on file lazmi. **Operqon backups mein pehle se live hai (restic → R2 bucket `erp-saas-backups`).** |
| 2 | **Backblaze B2** ⭐ | 10 GB storage, hamesha free | Free up to 3× stored data (10 GB par 30 GB); Cloudflare/Fastly partner se unlimited | S3-compatible. Paid sab se sasta: **$6.95/TB/month**. Private buckets ke liye card nahi chahiye. Backup ke liye best dusri copy. |
| 3 | **Oracle Cloud Object Storage** | 20 GB (Always Free) | 10 TB/month free (poori Oracle account ki) | Always Free package ka hissa (neeche compute dekho). Home region lock. |
| 4 | **IDrive e2** | 10 GB storage | Free 1:1 ratio (jitna store, utna download free); us se upar $0.01/GB | S3-compatible, API calls unlimited free. Paid ~$4–6/TB. Company purani/trusted (IDrive). |
| 5 | **Tigris** | 5 GB storage, 10K Class A + 100K Class B ops | **Unlimited — $0** | S3-compatible, global distribution, card nahi chahiye. Nayi company hai is liye sirf extra copy ke liye. |
| 6 | **Google Cloud Storage** | 5 GB (Always Free) | 1 GB/month free | Sirf US regions (us-east1/us-west1/us-central1) mein free. S3-interoperable API. |
| 7 | **Supabase Storage** | 1 GB file storage | 5 GB/month | Supabase project ke saath free (database ke saath wala section dekho). |
| 8 | **Filebase** | 5 GB storage | 5 GB bandwidth | S3 API lekin peeche decentralized networks (IPFS/Sia/Storj). Sirf ghair-hassas extra copy ke liye. |

**Sab ko mila kar (alag-alag providers, har project ke liye apna jayaz account): ~66 GB permanent-free object storage** — har provider par alag copy rakhna hi asal faida hai.

### Trial only — LIFETIME NAHI (dhokay mein na aana)
- **AWS S3:** Purana 5 GB / 12-month wala model khatm. 15 July 2025 ke baad ke naye accounts ko sirf $100 + $100 tak credits milte hain, 6 mahine ke liye. Permanent free S3 nahi hai.
- **Azure Blob Storage:** 5 GB, sirf 12 mahine.
- **Scaleway Object Storage:** 75 GB wali offer **3-month trial** hai, lifetime nahi.
- **Wasabi:** 1 TB / 30-day trial, phir kam se kam ~$6.99/month aur 90-day minimum retention. Free nahi.
- **Storj:** 25 GB wali offer trial/account-credit type hai, permanent free tier confirm nahi — is par depend na karo.

### Self-hosted S3 — asal "lifetime free"
Apne hi VPS par ye open-source, bilkul free, S3-compatible storage lag jati hai — limit sirf apni disk hai:
- **MinIO** (sab se mashhoor), **Garage**, **SeaweedFS**, **Ceph RGW**
- Oracle ke free ARM server (neeche) par MinIO lagao to **$0 mein apna private S3** ban jata hai — dusri backup site ke tor par behtreen.

---

## 2. Compute / VPS / Hosting — Always Free

| Company | Free | Notes |
|---------|------|-------|
| **Oracle Cloud Always Free** ⭐ | **4 OCPU ARM + 24 GB RAM**, 200 GB block storage, 2 AMD micro VMs, 10 TB egress/month, 2 Autonomous DBs (20 GB each) | Poori list mein sab se bari free offer, expiry nahi. Card sirf verification ke liye. Catch: idle instances reclaim ho sakte hain, region signup par lock ho jata hai, capacity kabhi full milti hai. |
| **Google Cloud** | 1× e2-micro VM (US regions), 30 GB disk | Hamesha free, lekin bohat choti machine. |
| **Cloudflare Workers + Pages** | Workers 100K requests/day; Pages par unlimited static sites + unlimited bandwidth | Operqon/IQRS ki static/marketing sites ke liye perfect. |
| **Vercel (Hobby) / Netlify (Free)** | Static + serverless hosting | Hobby terms par commercial-use limits check karna. |
| **GitHub Pages** | Free static hosting | Docs / status pages ke liye. |

---

## 3. Database — Always Free

| Company | Type | Free | Catch |
|---------|------|------|-------|
| **Neon** ⭐ | Postgres (serverless) | 1 GB/project, account total 20 GB tak, 100 projects, 100 CU-hours/project/month | 5 minute idle par compute so jata hai, agli query par jag jata hai. Card nahi. |
| **Supabase** ⭐ | Postgres + Auth + Storage | 500 MB DB, 1 GB storage, 50,000 auth MAU, 2 projects | 1 hafta inactive project pause ho jata hai (data mehfooz rehta hai). |
| **Oracle Autonomous DB** | Oracle DB | 2 databases × 20 GB, Always Free | Oracle ecosystem ke liye. |
| **Azure SQL Database (free offer)** | SQL Server | 32 GB data + 32 GB backup, 100K vCore-seconds/month — subscription ki lifetime ke liye | Microsoft ki taraf se genuine lifetime offer. |
| **Cloudflare D1** | SQLite (edge) | 5 GB total (10 DBs × 500 MB) | Workers ke saath best. |
| **Turso** | SQLite (libSQL) | 5 GB | Light apps ke liye. |
| **Prisma Postgres** | Postgres | 2 GB/workspace | Naya lekin trusted (Prisma). |
| **MongoDB Atlas M0** | MongoDB | 512 MB | Small apps/tests ke liye. |
| **Upstash** | Redis + Kafka + QStash | Generous free tier (daily command limit) | Cache/queue ke liye — Operqon type workloads mein kaam ka. |
| **AWS DynamoDB** | NoSQL | 25 GB + 25 RCU/WCU — Always Free (ye wala AWS mein waqai permanent hai) | Sirf AWS-native design mein. |

> Production databases (Operqon provider DB, tenant DBs) apne VPS par hi rakho — ye free DBs staging, side projects, aur Rektrs School ERP ke early phase ke liye hain.

---

## 4. Email / SMTP — Free Forever

| Company | Free | Notes |
|---------|------|-------|
| **Brevo** ⭐ | **300 emails/day (~9,000/month)** | Sab se zyada free volume. **Operqon mein pehle se configured hai.** |
| **Mailjet** | 6,000/month (200/day cap) | |
| **Resend** | 3,000/month (100/day cap) | Developer-friendly API. Brevo ke backup ke tor par rakho. |
| **Elastic Email** | 3,000/month (100/day cap) | Shared IP par deliverability kamzor ho sakti hai. |
| **SMTP2GO** | 1,000/month | Independent tests mein deliverability sab se achi (96%). |
| **Postmark (Developer)** | 100/month, kabhi expire nahi | Choti transactional volume / alerts ke liye. |
| **Cloudflare Email Routing** | Unlimited inbound forwarding | Apne domain ki email muft receive/forward — koi mailbox kharidne ki zarurat nahi. |
| **Zoho Mail (Free)** | 5 users × 5 GB, web only | Custom domain par muft mailbox, choti team ke liye. |

❌ **SendGrid:** free plan May 2025 mein khatm — ab sirf 60-day trial hai. Purani lists jo ise "free forever" kehti hain, ghalat hain.

---

## 5. Monitoring, Error Tracking, Analytics — Free

| Company | Free | Kis kaam ke liye |
|---------|------|------------------|
| **healthchecks.io** ⭐ | 20 cron checks | Backup jobs ki dead-man monitoring. (Operqon backup alerting ke liye yahi pending piece tha — owner ko apna check banana hai.) |
| **UptimeRobot** | 50 monitors, 5-min checks | Site up/down alerts. |
| **Better Stack** | 10 monitors + free logs | Uptime + log management. |
| **Sentry** | 5,000 errors/month | App error tracking (Operqon/IQRS apps). |
| **Grafana Cloud (Free)** | Metrics/logs/traces free tier | Dashboards. |
| **PostHog** | 1M events/month free | Product analytics. |
| **Cloudflare Web Analytics** | Free, privacy-friendly | Websites ki analytics bina cookies ke. |
| **Uptime Kuma** | Self-hosted, 100% free (open source) | Apne Oracle-free/VPS par lagao — koi limit hi nahi. |

---

## 6. Baqi Kaam ki Free Cheezein

- **Cloudflare Free Plan** — DNS, CDN, DDoS protection, SSL, **Turnstile** (free CAPTCHA alternative, unlimited) — har domain ke liye lazmi.
- **Let's Encrypt** — Free SSL certificates, lifetime, auto-renew.
- **Keycloak** (self-hosted, open source) — Unlimited auth/SSO, bilkul free. **Operqon mein pehle se yahi chal raha hai** — Clerk/Auth0 ke free limits ki zarurat hi nahi.
- **GitHub Free** — Unlimited private repos, 2,000 Actions minutes/month.
- **Cloudinary (Free)** — ~25 credits/month — image/video transformations (IQRS media ke liye).
- **ImageKit (Free)** — Media delivery + transformations ka free tier.
- **Docker Hub / GitHub Container Registry (GHCR)** — GHCR private images ke liye free.
- **Infisical (Free)** — Secrets management ka free tier (open source, self-host bhi ho sakta hai).

---

## 7. Assad ke Systems ke liye Recommended Free Stack (Action Plan)

1. **Cloudflare R2** — pehle se live hai. Primary backup rehne do. ✅
2. **Backblaze B2 account banao** — restic ka dusra repo (off-site copy #2). Growth par sab se sasta paid bhi yahi hai ($6.95/TB).
3. **Oracle Cloud Always Free account banao** — 20 GB object storage (copy #3) + 24 GB RAM ARM machine par MinIO + Uptime Kuma + healthchecks-type monitoring self-host karo. $0 lifetime dusri site.
4. **IDrive e2 + Tigris** — IQRS project ke liye alag free buckets (projects alag rakho, accounts bhi saaf taur par project-wise).
5. **Resend** ko Brevo ke saath fallback SMTP ke tor par ready rakho.
6. **healthchecks.io (free, 20 checks) + UptimeRobot (50 monitors) + Sentry (free)** — Operqon monitoring/alerting ka woh hissa jo abhi owner-webhook par ruka tha, is se muft mein band ho jayega.
7. **Neon / Supabase** — Rektrs School ERP ke staging/side experiments ke liye; production DB hamesha apne control mein.

**Hifazati usool:** Ek provider = ek hi account (multi-account bana kar limits ghumana ToS ke khilaf ho sakta hai aur account band kar sakta hai). Alag-alag *providers* istemal karna bilkul jayaz hai — yahi asal stacking hai.
