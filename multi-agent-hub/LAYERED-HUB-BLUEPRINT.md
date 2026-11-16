# Rektrs Multi-Agent Hub — LAYERED BLUEPRINT
## Colanode (upar) + Mattermost (neeche) — v1, 2026-11-14
### Status: BLUEPRINT ONLY — kuch install nahi hua. Owner review ke baad hi install hoga.

---

## 1. Khayal ek line mein
Tum aur tumhare 2 partners ek hi jagah kaam karo, 3 Muse + ChatGPT + Gemini + Grok + Cursor
apas mein baat aur kaam-bantwara karein, aur tum ek hi input se sab se jawab lo aur
progress dekho — ye sab apne hi server par, apne data ke saath.

## 2. Do layers kyun?
| Layer | Tool | Kaam | Kyun yahi? |
|---|---|---|---|
| **Upar — Workspace** | **Colanode** | Docs, files, wiki, kanban board (progress), lambi documentation | Slack+Notion ka combo ek jagah; chat+pages+databases; Apache-2.0, self-hosted |
| **Neeche — Agent Bus** | **Mattermost Team Edition** | Saari live baat-cheet, agents ki discussion, task threads, alerts | Bots ke liye proper REST API + bot tokens + webhooks — Colanode mein ye mature nahi (uska AI feature v0.4.0 mein band ho gaya tha) |

Dono ke darmiyan koi native integration nahi hai — **connector Muse (coordinator) hai:**
jo task Mattermost mein `done` ho, Muse usi ko Colanode ke kanban par `Done` mein move
karega; jo decision Colanode page par likha jaye, Muse us ka summary Mattermost ke
`decisions` channel mein post karega. Link dono taraf thread/page URL se.

## 3. Kaun kahan hoga

**Insaan (3):**
- Assad — System Admin, dono layers par owner
- Partner 1 — member (naam/email owner dega)
- Partner 2 — member (naam/email owner dega)

**Agents (bots, Mattermost mein bot accounts — member role, admin kabhi nahi):**
| Bot | Kaise jurega | Hamesha-on? |
|---|---|---|
| `muse-assad` | Muse ka custom connector (bot token) + scheduled check | Ji, Muse ki taraf se |
| `muse-p1` / `muse-p2` | Un ke apne Muse waisa hi connector lagayenge | Jab un ke Muse active |
| `chatgpt` | Pehle: Assad khud Muse ke browser mein login karega, Muse bridge banega. Baad mein: OpenAI API key | Bridge = session tak; API = hamesha |
| `gemini` | Upar wala tareeqa hi (Assad ka khud login / phir Google API) | Upar jaisa |
| `grok` | Owner jab chahe login, ya xAI API | Upar jaisa |
| `github-relay` | Incoming webhook — Cursor ke PR/commit `progress` mein auto | Ji |

**Hadd (seedhi baat):** Koi bhi agent kisi dosre ka password nahi rakhega. Login har
malik ka apna step hai — Assad ChatGPT/Gemini mein khud login karega, Muse ko
password/OTP kabhi nahi milega.

## 4. Andar ki structure

**Mattermost — Team `rektrs`**
- `command` — Assad ka single-input channel. Yahan `@all ...` ya `@gemini @chatgpt ...` likhna hi hukum hai.
- `agent-lounge` — agents apas mein mashwara / kaam bantwara
- `tasks` — har task ki alag thread: `CLAIMED → DOING → DONE / BLOCKED`
- `progress` — roz ka digest + GitHub events (Cursor ke PR yahan khud ayenge)
- `decisions` — sirf insano ke faisle; bots sirf parh sakte hain
- `general` — partners ki aam baat

**Colanode — Workspace `Rektrs Hub`**
- `Project Home` page — maqsad, rules, links (Mattermost channels + GitHub repo)
- `Progress Board` (kanban database) — Backlog / In Progress / Review / Done — Muse sync karega
- `Decisions Log` page — har faisla tareekh ke saath (Mattermost `decisions` ki mirror)
- `Docs & Files` — specs, reports, deliverables
- Ek chat channel sirf insano ke liye (halki baat) — agents ki asal baat Mattermost par hi rahegi

## 5. Kaam ka flow (single input)
1. Assad `command` mein ya command app mein likhta hai: `@all is feature par apni raye do`
2. Coordinator (`muse-assad`) sawal parhta hai, kaam bant-ta hai, `tasks` mein threads kholta hai
3. Har agent apni thread mein jawab / kaam karta hai; agents `agent-lounge` mein apas mein behes bhi kar sakte hain
4. Coordinator ek merged summary `command` mein deta hai + Colanode board update karta hai
5. Merge, paisa, bahar message — har agent apne malik ki ijazat ke baghair nahi karega

## 6. Command App (Phase 3)
- Thin web app (PWA) — phone par install ho jayegi, alag data nahi rakhegi
- Upar: ek input box + agent picker (All / Muse's / ChatGPT / Gemini / Grok / Cursor-status)
- Neeche: jawab side-by-side cards mein, aur live progress strip (Colanode board + GitHub se)
- Tab tak Mattermost + Colanode ki apni apps/web hi app ka kaam dengi

## 7. Server aur hifazat (sab se ahem hissa)
Host: **srv1322702** — Dokploy wala shared server, 8GB RAM, jahan Postiz, Dokploy,
Rektrs website, Odoo pehle se chal rahe hain. Adoption Board ki report (2026-11-14) ke
mutabiq maujooda stack pehle hi budget se upar hai aur KVM 4 upgrade ek shart ban chuka hai.

Is liye layered setup **ek saath nahi, marhalon mein** lagega:
- **Pehle Mattermost** (halka: app ~1–1.25GB limit + Postgres 512MB limit)
- **Phir Colanode** sirf tab jab RAM ki asal nap (7-day baseline) jagah dikhaye,
  ya KVM upgrade ho jaye. Colanode ka apna stack hai: server + web + Postgres(pgvector) + Valkey ≈ 1–1.5GB limit mein bandha jayega.

Dono ke liye lazmi usool:
- Koi build host par nahi — sirf official images `pull` hongi (2026-11-13 wala host-girne wala waqia dobara nahi)
- Har project ka alag `COMPOSE_PROJECT_NAME` (`rektrs-hub-mm`, `rektrs-hub-cola`) — Postiz staging wala project-name takrao wala sabak
- Domains: `chat.rektrs.com` (Mattermost), `hub.rektrs.com` (Colanode) — Dokploy/Traefik, TLS ke saath
- Backup: dono Postgres ka nightly dump; upgrade se pehle snapshot
- Bot tokens sirf Secure Vault mein; chat/files mein kabhi nahi

## 8. Marhale (Phases)
| Phase | Kaam | Kaun |
|---|---|---|
| **P0** | Host ki asal nap: `free/df/docker stats` + 7-day baseline ka pehla snapshot | Muse |
| **P1** | Mattermost install (Dokploy), admin, team, channels, `muse-assad` bot live | Muse |
| **P2** | Assad khud ChatGPT + Gemini login (browser) → bridge test: pehla `@all` sawal, 3 jawab ek jagah | Assad (login) + Muse |
| **P3** | Partners onboard: accounts + un ke Muse bots; GitHub relay (Cursor) live | Partners + Muse |
| **P4** | Colanode install (RAM gate pass ho to), workspace + board, Muse sync shuru | Muse |
| **P5** | Command app (PWA) | Muse |

## 9. Kharch
- Software: dono open-source, **Rs 0 license**
- Server: maujooda host (agar jagah nikli) — warna KVM upgrade jo Board pehle se tajweez kar chuka hai
- ChatGPT/Gemini/Grok bridge (web login): **Rs 0 alag** — API wala route baad mein ho to istemal ke hisaab se paid hoga

## 10. Khatre aur un ka jawab
- **Host bhar jaye** → RAM gate + hard limits + marhala-war install; gate fail ho to Colanode rukega, Mattermost chalega
- **Browser session logout ho jaye (ChatGPT/Gemini)** → bot `UNAVAILABLE` likhega, jhooti haziri nahi; dobara login owner step
- **Do agents ek hi kaam pakar lein** → `tasks` thread par pehla `CLAIMED` hi malik; coordinator takrao khatam karega
- **Agent ghalat faisla kar le** → `decisions` sirf insano ka; merge/spend par har agent apne malik se rukega

## 11. Owner se chahiye (jab install ki bari aye)
1. Partners ke naam + email (invite ke liye)
2. Domains ki tasdeeq: `chat.rektrs.com` + `hub.rektrs.com`
3. Grok: abhi login karna hai ya baad mein?
4. Install ka GO — is blueprint ki manzoori ke baad hi

---
*Purana Mattermost-only blueprint: `MATTERMOST-HUB-BLUEPRINT.md` — ye layered version us ki jagah hai.*
