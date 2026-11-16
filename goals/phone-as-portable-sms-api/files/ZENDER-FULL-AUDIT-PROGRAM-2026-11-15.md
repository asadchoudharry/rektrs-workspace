# ZENDER 5 — FULL AUDIT PROGRAM (owner task, 2026-11-15)

Owner hukam: Zender khareed ho chuka. Ab har file khangalo, demo login karke
plugins ka data parho, har paid plugin kesay kaam karti hai — features, soul,
workflow, logics, technology — sab samjho, aur ek NAYA detailed tree banao
(infra + plugin/extension wise) taake baad mein hum ek ek cheez develop kar
sakein. Kuch chootna nahi chahiye: har paid cheez ki detail, aur har woh cheez
jis ka source hamare pas nahi. Poori teams, har team ka alag task. Saara kaam
cloud browser mein. Koi jaldi nahi — detail aur sukoon se, complete.

## Teams / Lanes
- **Lane 1 — Source hasil karna:** CodeCanyon (owner account, saved login) se
  purchased Zender 5 package download. Output: asal ZIP workspace mein.
- **Lane 2 — Documentation team:** vendor docs ka har section — install,
  plugin system/hooks, API, gateway protocol, WhatsApp, SaaS/billing, updates.
- **Lane 3 — Paid plugins team:** products portal par har paid plugin ka page:
  price, features, workflow, requirements, screenshots, limits. Ek ek plugin.
- **Lane 4 — Demo team:** live demo par signed-in deep dive — admin panel aur
  tenant panel, module by module inventory (menus, settings, flows).
- **Lane 5 — Source audit team (local):** downloaded source ka file-by-file
  census — tree, composer/package versions (Laravel exact), DB schema map,
  plugin hook system, gateway server-side protocol, licence/phone-home points,
  tenant branding check. Patch register ki bunyaad.
- **Lane 6 — No-source team:** jin cheezon ka source nahi — Android gateway
  app, WhatsApp QR binary, Phone Bridge, GSM Modems programs: bahir se
  observable behavior, protocol, inputs/outputs — clean-room rebuild spec.

## Deliverable — NAYA REBUILD TREE (yeh is program ki asal paidawaar hai)
`~/workspace/goals/phone-as-portable-sms-api/files/zender-rebuild-tree/`
- `00-OVERVIEW.md` — architecture, tech stack, system map
- `01-CORE-MODULES/` — core ka har module (auth, workspaces, contacts,
  campaigns, inbox, chatbot, billing, API, webhooks, settings...)
- `02-PAID-PLUGINS/` — har paid plugin ki apni file: features, workflow,
  logic, tech, data, rebuild spec, estimate
- `03-FREE-PLUGINS/` — har free plugin ki file
- `04-NO-SOURCE/` — no-source components ki clean-room specs
- `05-INFRA.md` — server, cron, queues, storage, Firebase, requirements
- `06-DATABASE-MAP.md` — tables/relations ka naqsha
- `07-API-MAP.md` — REST endpoints + webhooks ka naqsha
- `08-REBUILD-ROADMAP.md` — kis order mein kya develop hoga, phase mapping
  (final plan ZENDER-CORE-PLUS-OWN-PLUGINS-PLAN ke phases se linked)

## Rules
- Har claim ke sath source (page/file) — jo verify na ho woh "unverified".
- Credentials sirf Secure Vault / saved login se; chat mein kabhi nahi.
- Vendor compiled cheezein decompile NAHI hongi — sirf bahir se study.
- Har lane apni report file mein likhe gi; final tree CEO (Muse) jama karega.
