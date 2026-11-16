# REKTRS ID — DOMAIN MIGRATION PLAN (Phase B, 2026-11-16)
Owner faisla: identity bridge = **Rektrs ID**, domain **id.rektrs.com**.
Ye plan Keycloak ka public address login.operqon.cloud se id.rektrs.com par
le jane ki tayyari hai. **Abhi execute NAHI karna** — sirf tayyari, taake
jab window mile to ek hi dafa mein saaf ho jaye.

## Live evidence (2026-11-16, VPS read-only)
- Keycloak container `operqon_staff_identity-keycloak-1`;
  `KC_HOSTNAME=https://login.operqon.cloud` (strict mode),
  `KC_HTTP_ENABLED=true`, host par `127.0.0.1:18086->8080`.
- Strict hostname ka matlab: issuer her haal mein KC_HOSTNAME wala hoga —
  naya domain sirf Caddy mein jorne se kaam nahi hoga, KC_HOSTNAME badalna
  lazmi hai, aur badalte hi **saare tokens ka iss naya ho jayega**.
- Live references (fixtures/worktree copies live config NAHI hain):
  - `/etc/caddy/Caddyfile` — login.operqon.cloud block (sirf realms +
    /resources + /.well-known proxy; admin band — ye pattern naye
    domain par bhi ayn waisa rahe ga).
  - `/opt/operqon-staff-identity/deploy/oidc/compose.yaml` — KC ki env.
  - Operqon provider **api container ki OIDC env vars** (issuer/discovery/
    jwks) — R2 deploy (2026-11-16) mein yehi 4 vars recover hui theen.
  - `/opt/operqon-provider-r1/deploy/secrets/jwks.json` — purani r1 ki
    file; r2 live hai ya nahi, window se pehle confirm karna hai.
  - ServerKit panel (offbox-1) ki `sso_oidc_discovery_url` — pre-filled,
    is phase mein nayi value se badli jayegi.
- Realms do hain: `operqon-provider` (staff/panel) aur
  `operqon-customers` (Operqon ke customers) — **hostname badalne se
  customer realm ka issuer bhi badlega**; tenant sites par customer login
  links isi liye window ka sab se hassas hissa hain.

## Window sequence (ek hi maintenance window mein)
0. **Pre-checks (window se pehle):** har live client ki inventory pakki
   karna — provider api env, portal/console static config mein hardcode
   login URL hai ya nahi, customer realm ke clients ki list, panel.
   DNS: `id.rektrs.com` A (DNS-only) → 72.61.214.64 — **owner/Cloudflare
   step** (rektrs.com zone alag hai operqon.cloud se).
1. Caddy: id.rektrs.com ka block login wale block ki copy (wahi path
   restrictions) + reload; cert LE se khud ayega. Is waqt KC abhi purane
   hostname par hai — naya domain sirf darwaza hai, issuer purana rahe ga
   (ye halat sirf darmiyani hai, clients ko is par point NAHI karna).
2. Har client ki nayi config **stage** karna (apply nahi): api env,
   portal/console, panel discovery — sab mein id.rektrs.com wali values
   tayyar rakhna.
3. **Flip:** staff-identity compose mein KC_HOSTNAME →
   `https://id.rektrs.com`, container recreate. Is lamhe se naye tokens
   ka iss = id.rektrs.com.
4. Foran saare staged client configs apply + services restart (api,
   portal publish agar static config hai, panel setting).
5. **Verification battery:** discovery document ka iss check; panel par
   Rektrs ID login; Operqon staff login; ek tenant site par customer
   login; purani sessions ka behaviour (expire hona expected hai —
   users ko dobara login karna pare ga, window ka waqt is hisab se ho).
6. **Legacy:** login.operqon.cloud ka Caddy block + DNS filhal barqarar —
   us ka discovery ab naye issuer ki taraf ishara kare ga; purani
   bookmarks/redirects tootein gi nahi. Retire karna alag faisla, kam az
   kam ek release cycle ke baad.
7. **Rollback:** har tabdeeli config-only hai — KC_HOSTNAME purana +
   client configs purani + container recreate. Data (users/clients/
   secrets) bilkul nahi chhuta.

## Khatre / note
- Sab se bara khatra: koi client reh jaye jo purane issuer par atka ho
  (khas taur par customer realm) — is liye step 0 ki inventory is plan
  ki jaan hai; inventory ke baghair window nahi khule gi.
- Client secrets is migration mein **nahi** badalte; redirect URIs
  (panel waghera ke) bhi nahi — sirf issuer/discovery addresses badalte
  hain.
- Window ka size: tayyari ke baad ~30–60 minute ka kaam, lekin customer
  login ki wajah se kam-traffic waqt chuna jaye ga.
