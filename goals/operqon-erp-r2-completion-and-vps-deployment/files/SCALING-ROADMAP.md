# Operqon Scaling Roadmap — kab kya barhana hai

*Naapa hua (measured) halat: 7 Nov 2026 · Triggers par chalna hai, tareekhon par nahi.*

## 1. Aaj ki halat

Aik hi VPS (Hostinger KVM 2, Jakarta): **2 vCPU · 8 GB RAM · 96 GB disk** — is par sab kuch chal raha hai: control plane (R2 live + R1 rollback canary), Keycloak login system, staging bench (**16 proof sites**), aur legacy Pilot + Demo stacks — kul **26 containers**. Headroom: RAM ~4.3 GB available, disk 48% bhara (us mein ~23 GB saaf hone wala build cache/unused images hai). **Pehla dabao ka signal pehle se maujood hai: swap 1.4/2 GB istemal ho raha hai** — yani peak par RAM tang padti hai. Provider database abhi bohat chhota hai (poora backup dump ~91 KB); har tenant site ki database ~100 MB se shuru hoti hai (zyada-tar fixed schema hai).

| Cheez | Aaj ki naap |
|---|---|
| Asal production tenants | 0 live (Rektrs + demo2 abhi *requested* stage par) |
| Staging bench | 1 node, 16 sites, ~1.1 GB RAM, site DBs kul ~1.9 GB |
| Legacy Pilot + Demo | ~0.9 GB RAM kha rahe hain (retire hona baqi hai) |
| Maujooda kharcha | **Rs 36,468.60 / saal** (isi VPS ki renewal, invoice HSG-10093814) |

## 2. Marhalay — trigger aye to qadam uthao

| Marhala | Trigger (yeh dikhe to waqt aa gaya) | Kya barhega / alag hoga | Is se kitne tenants aram se |
|---|---|---|---|
| **1 — Jagah khaali + bara box** | Pehle **5–10 asal tenants** active, YA watch ki RAM leg alert kare / swap aur barhe, YA disk 70% cross kare | (a) Legacy Pilot → Demo retire (sifarish shuda tartib; ~0.9 GB RAM free, koi kharcha nahi) (b) cache/images safai routine (c) Hostinger tier ladder par **agla darja** (RAM zyada wala plan) | **~15–25** aik hi box par |
| **2 — Bench alag node par** | **20–30 tenants**, YA nayi site banne ka waqt (provisioning) numaya barh jaye, YA subah ke peak par bench slow mehsoos ho | Production bench **apni alag machine (bench node #2)** par; control plane apne box par halka reh jayega. Aage har naya bench node isi tarah jurta jayega | **~50** (har bench node ~15–25 sites uthata hai) |
| **3 — Buniyaad mazboot** | **50+ tenants**, YA reports/exports se database par bojh mehsoos ho, YA Keycloak ka single hona risk lage | Provider DB alag host par; Keycloak ki DB alag + doosri instance ki tayyari; website/static files CDN ke peeche; reporting ke liye DB read replica (sirf agar bojh sabit ho) | **100+** ki buniyaad tayyar |
| **4 — Doosra region** | Customers **doosre region** se aane lagen, YA **100+ tenants** | Us region mein bench nodes; control plane multi-node | Business jahan le jaye — sirf tab, pehle nahi |

> **Bands ka usool:** asal had site ki tadaad nahi, **aik waqt mein active users** hain. SMB tenant (5–30 users) ke hisaab se yeh bands rakhe hain; koi tenant bohat bara nikal aye to us ka bench pehle bhar sakta hai — is liye trigger mein metric bhi hai, sirf ginti nahi.

## 3. Jo kabhi nahi badlega (no-rewrite list)

| Cheez | Kyun rehti hai |
|---|---|
| API-first frontend (website/console/portal static files + API) | Halki, tez, mehfooz; barhane ke liye dobara likhna nahi padta |
| Har tenant ki alag site + alag database | Aik customer ka data/doosre se bilkul alag — yahi aitmaad hai |
| Pack model (industry packs + country packs) | Naya sector/mulk = naya pack, purana system nahi badalta |
| Keycloak alag identity system | Login/MFA har cheez se alag; do realms (provider/customers) pehle se tayyar |
| Backups: restic → Cloudflare R2 (off-VPS) | Box kharab bhi ho to data bahar mehfooz; restore sabit-shuda hai |

## 4. Hadood jo maloom hain (imandari se)

- **ERPNext pin (v16.53.0):** version upgrade kabhi "bas laga do" nahi hoga — har upgrade ko regression harness se guzarna hoga.
- **Aik region (Jakarta):** door ke mulkon ke customers ko kuch latency rahegi — Stage 4 tak yahi sach hai.
- **Stage 2 tak single-point-of-failure:** poora box band = sab band. Backups mehfooz hain, magar service ka doosra ghar abhi nahi.
- **Bench density hi asal scaling unit hai:** sites ginna asaan hai, magar bojh concurrent users se banta hai — isi liye har trigger mein metric shamil hai.

## 5. Signal kahan se ayega

| Signal | Kya batata hai |
|---|---|
| `operqon-r2-watch` (har 2 min) — disk / inode / RAM / certificate-expiry legs | Stage 1 ke triggers: RAM dabao, disk bharna, cert ki meyaad |
| `operqon-r2-provision-watch` (har 5 min) + OnFailure alerts | Provisioning fail/atka hua; Stage 2 ka pehla ishara yahin se milega |
| Backup healthchecks (dead-man pings) | Backup ruk jaye to khud khabar; provider leg ka ping abhi owner ki taraf se aik chhota sa item baqi hai |
| Console Notifications card → webhook sync | Alerts ka pata: jo URL wahan darj ho, alerts wahin jate hain |

**Tajweez (abhi banana nahi, sirf tajweez):** (1) watch mein aik *bench density leg* — sites-per-node aur har site ki DB growth ka mahina-war hisaab, taake Stage 2 ka trigger andaze se nahi, naap se aye. (2) *Provisioning waqt ka trend* — site tayyar hone mein kitne minute lag rahe hain; barhna shuru ho to Stage 2 qareeb hai.
