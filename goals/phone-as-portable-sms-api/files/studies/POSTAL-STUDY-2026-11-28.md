# Study — Postal (postalserver/postal) as Rektrs' mail delivery engine

**Date:** 2026-11-28 · **Studied for:** the listmonk pairing question (the listmonk study, `../LISTMONK-STUDY-2026-11-28.md`, sends through SES or Resend — should Rektrs instead own the delivery engine?), and the wider question of whether Postal belongs anywhere in Rektrs'/Sendqon's mail picture.
**Sources:** GitHub repo + API (checked live 2026-11-28), project documentation (docs.postalserver.io as summarised in dated secondary reads, marked where used), the repo README. READ-ONLY study — nothing was installed or deployed.

## What it is

A complete, self-hosted **mail delivery platform** — "think SendGrid, Mailgun or Postmark, but open source and ready to run on your own servers" (README). Postal is an **MTA**: it accepts mail over SMTP or an HTTP API, delivers it itself from your own IP addresses, tracks every message, and routes incoming mail onward. It is **not** a mailbox server (no webmail/IMAP mailboxes) and **not** campaign software (no lists, no segmentation, no unsubscribe management — its FAQ explicitly declines mailing-list features; it is the transport layer listmonk-class tools send *through*). Structure: **organizations → mail servers**, each mail server with its own domains, credentials, routes, webhooks, IP pool and message database. Repo stats at study time: **16,987 stars, 1,325 forks, 95 open issues**, created 2017-04-19; latest release **3.5.0 (2026-11-20)**, commits the same week.

### What it does (the capability list)

- **Sending:** SMTP submission + HTTP API (`X-Server-API-Key`), multiple credentials per server, per-server send limits, **DKIM signing** per domain, built-in DNS checking for the domains it serves.
- **Delivery truth:** per-message records with every delivery attempt, bounce classification (soft/hard) linked back to the original message, **suppression lists**, **open/click tracking**, delivery **webhooks**, queue inspection, mail-server-wide message search, configurable **retention** (how long messages/logs are kept).
- **Incoming:** routes matching an address, wildcard or plus-tag on a verified domain, delivering each message to an **HTTP endpoint, another SMTP server, or an email address** (with copy-to-extra-endpoints and accept-and-store / hold / bounce / reject modes) — i.e. programmatic inbound mail, not mailboxes.
- **Isolation:** per-server **IP pools**, so one sender's reputation problems don't contaminate another's.

## 1. Licence

**MIT** — GitHub's licence detection on the repo reports MIT, the project documentation and every reference read agree, and there is no paid tier, hosted edition or feature gate anywhere in the project ("no licence fee, ever" is the project's own framing). Commercial use, tenant-facing use and modification are all unrestricted beyond the MIT notice duty. **Licence is a non-issue**; everything difficult about Postal is operational (§6).

## 2. What it adds that we don't have

Rektrs' current mail reality: **Hostinger** carries rektrs.com's mailboxes + Sendqon's panel SMTP (`no-reply@sendqon.rektrs.com`); **Resend** carries the transactional subdomain `send.rektrs.com`; Sendqon's **email channel companion** (`sendqon-email`, server id 4) works with *tenant-brought mailboxes* (IMAP/SMTP per mailbox, campaigns, a mailbox warmer). Against that:

- **An owned delivery engine with owned delivery truth.** Today, when a Sendqon or Rektrs message bounces, the evidence lives in Hostinger's/Resend's dashboards. Postal would give us per-message attempt logs, bounce classification and suppressions in our own system — the email equivalent of what our own bridges did for WhatsApp.
- **A sending substrate for the listmonk tenant offering.** The listmonk study's wiring sends tenant campaigns via SES/Resend per tenant. Postal (one org/mail-server per tenant, own IP pool, own DKIM) is the self-hosted alternative to that per-tenant provider onboarding. Honest caveat: listmonk's *core* bounce ingestion is built for SES/SendGrid webhooks and POP3 mailbox scanning — Postal's bounce webhooks would need a small shim (or a POP3 bounce mailbox) to close the loop into listmonk. SES remains the lowest-surprise listmonk sender; Postal is the most-controlled one.
- **Programmatic inbound mail** (routes → HTTP) — a capability nothing in our stack has today; Sendqon's email channel polls tenant mailboxes instead. (No current product requirement names this; recorded as a capability, not a need.)

What it does **not** add: mailboxes (Hostinger's job, unchanged), campaigns/lists (listmonk's job), or deliverability itself (§6 — the whole point of the honest section).

## 3. Stack fit

**Heavy for offbox-1, and the docs say so themselves.** Postal is Ruby on Rails (Ruby 3.4 / Rails 7.1) shipped as one image running three process types (web/API+tracking, SMTP server, delivery workers) and it **requires MariaDB 10.6+ — MySQL is explicitly not supported** — so it brings its own database server too. The project's documented minimum is **2 vCPU / 4 GB RAM / 25 GB disk**, and its installation guidance **strongly recommends a dedicated server running nothing else**. offbox-1 (2 OCPU / 12 GB total) already carries the whole Sendqon fleet (Laravel app, six companions, Jasmin, PBX); adding a 4 GB-floor Rails MTA that wants the box to itself does not fit the shared-host pattern — a Postal deployment realistically means its **own small instance** (e.g. a second OCI micro/paid shape or a cheap VPS), which is a new standing cost and a new box to patch, back up and monitor. Integration shape if ever deployed: companion-class, off to the side — Sendqon/listmonk would use it as an SMTP/API endpoint; nothing in Sendqon core changes.

## 4. Integration route

**Companion service on its own host** (if ever) — used as (a) Rektrs'/Sendqon's own sending engine behind the existing panel SMTP configuration, and/or (b) the delivery substrate under listmonk instances. Never a plugin; never multi-tenant-exposed directly (tenants would get listmonk/Sendqon surfaces, with Postal as invisible plumbing — handing tenants an MTA admin is handing them our IP reputation, §6).

## 5. Effort

- Standalone deploy on a fresh host + DNS (SPF/DKIM/DMARC/rDNS) + one sending domain proven end-to-end: **~1–2 lanes** — the mechanics are well documented and containerised.
- The real cost is not lanes: **IP warm-up and reputation building run on a calendar (weeks), not in lanes**, and deliverability operations (bounce/complaint handling, blocklist monitoring) become a standing Rektrs duty from day one. Any estimate that omits this is lying by omission.

## 6. Risk — the deliverability section, honestly

- **A fresh cloud IP is guilty until proven innocent.** Postal delivers from *your* IP; a new OCI/VPS address starts with no reputation, major receivers throttle or junk-folder new senders by default, and one bad list can get the IP blocklisted — after which **all** mail from that IP (including Sendqon's panel mail, if it shared the engine) suffers. IP pools isolate tenants from each other, not us from the decision to become a sender.
- **Port 25 is a gate, not a given.** Outbound port 25 must be open end-to-end; cloud providers commonly restrict it by default (OCI restricts outbound 25 on new tenancies unless an exemption is granted — to be verified against our tenancy before any plan depends on it), and the host needs matching **rDNS** under our control.
- **The comparison that matters:** Resend/SES charge per message and in exchange carry the reputation, the receiver relationships and the abuse desk. At Rektrs' current volumes (panel notifications, transactional mail — small), that fee buys out an entire operational discipline for very little money. Postal's economics only invert at sustained volume or when a product (listmonk-for-tenants) makes delivery itself part of what we sell.
- **Abuse surface:** an MTA that accepts submissions for multiple tenants is a spam-abuse target; Postal has credentials, limits and suppressions, but the *policy* work (who may send what, complaint-rate cutoffs) would be ours — the same lesson as the aggregator study, one layer down.

## 7. Maintenance health (live-checked 2026-11-28)

16,987 stars / 1,325 forks / 95 open issues; nine years of project history; **3.5.0 released 2026-11-20** with commits the same week (recent work: per-server message priority, SMTP-server robustness fixes — an actively operated codebase, not a museum piece). Maintained by the Postal Server project (originally aTech Media's open-sourcing of their commercial platform's core). No hosted edition exists to cannibalise it. Health: **good**.

## 8. Verdict — **WATCHLIST** (do not deploy now; named triggers)

Postal is a genuinely complete, cleanly-licensed, actively maintained delivery platform — and today it solves a problem Rektrs does not have. Our mail volumes are small and already well-served (Hostinger for mailboxes/panel SMTP, Resend for transactional), while Postal demands a dedicated host, a MariaDB stack, port-25/rDNS control and a weeks-long reputation build, and would make us the deliverability desk for everything it carries. The listmonk study's SES/Resend wiring stays the recommendation for the listmonk offering's first iteration.

**Revisit triggers (any one reopens this study):**
1. **The listmonk tenant offering ships** and per-tenant SES/Resend onboarding (per-tenant domains, per-tenant provider accounts) becomes the friction that costs deals — Postal-per-tenant-org becomes the controlled alternative, on its own host.
2. **Sustained sending volume** (ours + tenants') reaches the point where Resend/SES per-message fees visibly exceed the standing cost of a dedicated Postal host + the ops time — a numbers comparison to be run with real volumes, not estimated now.
3. **A tenant contract demands self-hosted delivery** (data-residency or no-third-party-processor clause) by name.
4. **The Sendqon email channel graduates** from tenant-brought mailboxes to Rektrs-provided sending as a product — Postal is then the natural engine under it, and this study's §6 becomes the operating charter.

**One-line verdict: Postal is the right answer to a question we haven't reached yet — own it on the watchlist for the day delivery becomes part of the product (listmonk tenants, email-channel sending), and keep paying Resend/SES the small fee that currently buys us out of being a mail-reputation operator.**
