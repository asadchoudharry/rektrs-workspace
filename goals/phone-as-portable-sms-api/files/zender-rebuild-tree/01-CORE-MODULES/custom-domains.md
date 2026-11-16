# CORE — Custom Domains (workspace subdomains, Messenger domains, tracking domains)

**Status: core-owned (purchased).**
Sources: Lane 2 (Custom Domains), Lane 4 §§A–B, Lane 5 §12.

## Three domain features
1. **Workspace subdomains** (platform-wide): wildcard DNS + wildcard
   certificate; reserved names `www`, `api`, `admin` are blocked.
2. **Tenant Messenger custom domain:** Workspace > Messenger Settings >
   Domain. States: Pending DNS → Securing → Active. Point a CNAME at
   the APP_URL host or an A record at the server IP; checked every
   30s; **exact host only** (the `www` variant does not work); the
   platform refuses its own hosts and registrable root domains; no TXT
   challenge.
3. **Tracking domains** (e.g. `go.example.com`) for campaign links:
   plan features Link Tracking + Custom Link Domain. On plan downgrade
   the saved domain stays but new links use the default domain.

## SSL automation
- `messenger-domain:provision-ssl` runs every minute (Let's Encrypt);
  per-domain nginx conf `zender-<domain>.conf`; helpers
  `zender-certbot`, `zender-nginx-site`; sudoers entry `zender-ssl`;
  daily 03:30 re-verification; Admin Force Verify action.
- Cloudflare: use DNS-only, or "SSL Managed Externally" (CF for SaaS).
- Realtime (Reverb) always stays on the main host — custom domains do
  not carry websockets.
- Admin > Domains lists all workspaces and their subdomain/custom
  domain state (demo: 41 workspaces, all None/Off until Settings >
  Domains enables the features).

## Data (tables)
`messenger_domain_releases` (+ domain fields on workspace/settings).

## Plan gates
Messenger Custom Domain is a plan feature (demo: Pro+). Workspace
subdomains/custom domains are admin-enabled platform features.

## Keep / extension notes
- Core-owned. Infra consequence: our nginx/cert automation must keep
  the `zender` system user + sudoers helpers intact (installed by
  autosetup — `05-INFRA.md`); do not hand-edit generated
  `zender-<domain>.conf` files.
- Shared hosting cannot do custom Messenger domains at all (docs) —
  another reason we are VPS-only.
