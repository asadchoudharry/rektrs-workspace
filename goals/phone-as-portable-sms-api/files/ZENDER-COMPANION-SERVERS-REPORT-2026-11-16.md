# Sendqon — Companion Servers Preparation Report (2026-11-16)

**Scope:** prepare the WhatsApp and SMPP companion binaries on offbox-1 so the owner only has to paste two licence codes at the end. Generate both `config.json` files with the app's own builder, design persistent runtime dirs, create (but do **not** start) the companion compose stack, and write the one-run licence script.

**Result: COMPLETE.** Both configs are generated and in place with the real per-server service tokens and the licence placeholders untouched; the companion image is built; the compose file validates; both binaries are smoke-proven to execute and to refuse an invalid licence; the services are deliberately **not** running. The only remaining step is the owner's two pastes (§6).

No secret value (service token, licence code, DB password, APP_KEY) appears anywhere in this report or was printed during the lane — structure and lengths only.

---

## 1. Config generation (the app's own builder)

Mechanism, from the core source (`app/Http/Controllers/Admin/ServiceServerController.php`, the two Kind classes, `app/Models/ServiceServer.php`):

- The admin edit page renders `configJson` via `$kind->configJson($server, $plainToken)` (`WhatsappServerKind` / `SmppServerKind`), JSON-encoded `JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES`.
- The plain service token is stored on the server row itself (`service_token_plain`, `encrypted` cast, issued by `issueServiceToken()` at creation). This lane read it through the model inside the app container — **no token rotation was needed**, so the generated configs match the existing admin records exactly (WhatsApp server id 1 "Primary WhatsApp", SMPP server id 2 "smpp-1", both enabled).
- Generation ran via `php artisan tinker --execute` inside the `sendqon` container, calling `app(ServiceServerKinds::class)->get($kind)->configJson($server, $token)` and `file_put_contents()` straight to files in the container; the files were then piped to the host destinations without ever passing through a terminal/log. In-container temp copies were deleted afterwards.

Resulting files (host side, mode **600**, root-owned):

| File | Size | Verified structure |
|---|---|---|
| `/var/serverkit/apps/sendqon/servers/whatsapp/config.json` | 303 B | keys `laravel`, `purchase_code`, `server{host, port, service_token}` — host `0.0.0.0`, port **8899**, token length **64**, `purchase_code` still `REPLACE_ME_WITH_WHATSAPP_PLUGIN_LICENSE_CODE`, `laravel.url` = `https://sendqon.rektrs.com` |
| `/var/serverkit/apps/sendqon/servers/smpp/config.json` | 372 B | keys `laravel`, `purchase_code`, `server{debug, host, port, service_token}`, `storage{dir: storage}` — host `0.0.0.0`, port **8898**, token length **64**, `purchase_code` still `REPLACE_ME_WITH_SMPP_PLUGIN_LICENSE_CODE`, `laravel.url` = `https://sendqon.rektrs.com` |

## 2. What the binaries need at runtime (inspected, not assumed)

Both binaries are static ARM64 ELF executables (host `ldd`: "not a dynamic executable"), version **5.0.4** (WhatsApp `-version` → `5.0.4`; SMPP logs `version=5.0.4`).

- Flags (both): `-config` (WhatsApp default `./config.json` or `./config.yaml`; SMPP default `config.json`), `-debug`, `-host`, `-port`, `-purchase-code`. Config is read from the **working directory** by default.
- Both create/use a `./storage` directory inside the working directory at runtime (observed in the smoke runs — WhatsApp session state and the SMPP `storage.dir` both land there).
- Persistent design: a dedicated **`work/`** subdirectory per server is the container's working directory and a host bind mount, so `work/storage/…` (WhatsApp sessions, SMPP storage) survives container recreates and restarts:
  - `/var/serverkit/apps/sendqon/servers/whatsapp/work/`
  - `/var/serverkit/apps/sendqon/servers/smpp/work/`
- The binaries make HTTPS calls (to `https://sendqon.rektrs.com` and the vendor licence check), so the runtime image needs CA certificates — a bare slim image has none (see §3).

## 3. Companion image

`sendqon-companion:5.0.4`, built on the host from `/var/serverkit/apps/sendqon/servers/Dockerfile.companion`:

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
```

The binaries themselves are **not** baked in — they are bind-mounted read-only from the staged paths, so a future binary drop-in needs no rebuild.

## 4. Compose stack (created, validated, NOT started)

`/var/serverkit/apps/sendqon/servers/docker-compose.yml` — two services, `docker compose config` validates clean, `docker compose ps -a` shows **no containers created**:

| Service / container | Command | Mounts | Network |
|---|---|---|---|
| `sendqon-whatsapp` | `/usr/local/bin/titansys-whatsapp-arm64` (working dir `/work`) | binary `:ro` from `./whatsapp/`, `./whatsapp/work` → `/work`, `./whatsapp/config.json` → `/work/config.json` (writable mount, in case the binary ever updates its own config) | `sendqon_default` (external — the app stack's network) |
| `sendqon-smpp` | `/usr/local/bin/titansys-smpp-arm64` (working dir `/work`) | same pattern from `./smpp/` | `sendqon_default` (external) |

- Container names are exactly `sendqon-whatsapp` / `sendqon-smpp`, so the base URLs registered in the admin (`http://sendqon-whatsapp:8899`, `http://sendqon-smpp:8898`) resolve over the app network. The app reaches the companions; **no host ports are published**.
- `restart: unless-stopped` on both.
- The running Sendqon stack was not touched: `sendqon`, `sendqon-db`, `sendqon-queue`, `sendqon-reverb`, `sendqon-scheduler` all still Up, no recreates.

## 5. Smoke-test evidence (no real config, no real code used anywhere)

On the host, from throwaway copies in `/tmp` (since removed):

- WhatsApp, no config: `❌ ERROR: server.service_token is required (register the server on the admin WhatsApp Servers page and copy the token here)`.
- WhatsApp, dummy config (dummy token + the placeholder as purchase code): starts — `Starting WhatsApp Server (port=8899, laravel=https://sendqon.rektrs.com, version=5.0.4)` — then the gate: `license verification refused / outcome=license_invalid / "This purchase code is not valid."`, and it created `./storage` in the working directory.
- SMPP, no config: `Set purchase_code in the config file or pass --purchase-code.`
- SMPP, dummy config (same pattern): `zender-smpp starting (version=5.0.4)` → same `license verification refused / outcome=license_invalid / "This purchase code is not valid."`, `./storage` created.
- Inside the shipped runtime: both binaries were also executed once via `docker run --rm` in `sendqon-companion:5.0.4` with the staged binaries mounted — identical expected complaints (token required / purchase code required), proving the image + mount pattern runs them.

The licence gate is therefore proven live for both binaries: placeholder (or any invalid) code → refusal. The generated real configs were **never** run.

## 6. The owner's one remaining step

SSH to offbox-1 as usual and run:

```bash
sudo /var/serverkit/apps/sendqon/servers/apply-licence.sh
```

(`sudo` is required: the configs are root-owned mode 600 and the script drives Docker. The script is at `/var/serverkit/apps/sendqon/servers/apply-licence.sh`, mode 755, `bash -n` clean, and its empty-input path was dry-run live: both servers skipped gracefully, configs untouched.)

What it does, WhatsApp first, then SMPP:

1. If the config's placeholder is already gone, it skips that server (idempotent — safe to re-run).
2. It prompts `License Key:` with hidden paste (`read -s`, nothing echoes, codes are never printed or logged). Paste the plugin's **License Key** from the vendor portal — dashboard.titansys.dev → **Licenses** — the row for the WhatsApp Plugin first, then (second prompt) the SMPP Plugin.
3. It backs the config up to `config.json.bak-licence` (mode 600), replaces the placeholder with the pasted key in place, verifies the placeholder is gone, starts just that service (`docker compose up -d --force-recreate`), waits a few seconds and prints the last ~15 log lines.

What to expect to see: `Starting WhatsApp Server (port=8899, …)` / `zender-smpp starting (version=5.0.4)` **without** the `license verification refused` line, and within about a minute both servers should show **Healthy** in the Sendqon admin under Service Servers (they currently read Unhealthy / Not Responding, which is expected while the binaries are down).

If a log instead says the purchase code is not valid, the wrong key was pasted: restore and re-run —

```bash
sudo cp /var/serverkit/apps/sendqon/servers/whatsapp/config.json.bak-licence /var/serverkit/apps/sendqon/servers/whatsapp/config.json
sudo /var/serverkit/apps/sendqon/servers/apply-licence.sh
```

(same with `smpp` in the path for the SMPP server).

## 7. UNVERIFIED (labelled honestly)

- **UNVERIFIED — start with a real licence code:** not attempted (no code was available to this lane and none was invented). The refusal path is proven (§5); acceptance depends on the vendor's verification, which the placeholder test suggests is a real check, not a format test.
- **UNVERIFIED — WhatsApp session persistence across a recreate:** by construction the session state lives in the host-mounted `work/` dir, so it persists; but no session has been written yet (that needs a running, licenced server + a linked WhatsApp number).
- **UNVERIFIED — health transition in the admin:** the servers flipping to Healthy can only be observed after the owner's step in §6.
- The config file is mounted writable into each container in case the binary updates its own config at runtime; whether it ever does is UNVERIFIED (the smoke runs only created `storage/`).

## 8. Files created in this lane

| Path | Purpose |
|---|---|
| `/var/serverkit/apps/sendqon/servers/whatsapp/config.json` (600) | Generated WhatsApp server config (real token, licence placeholder) |
| `/var/serverkit/apps/sendqon/servers/smpp/config.json` (600) | Generated SMPP server config (real token, licence placeholder) |
| `/var/serverkit/apps/sendqon/servers/whatsapp/work/`, `…/smpp/work/` | Persistent working dirs (runtime `storage/` lands inside) |
| `/var/serverkit/apps/sendqon/servers/Dockerfile.companion` | Runtime image source (debian slim + CA certificates) |
| `/var/serverkit/apps/sendqon/servers/docker-compose.yml` | Companion stack (not started) |
| `/var/serverkit/apps/sendqon/servers/apply-licence.sh` (755) | Owner's one-run licence + start script |
| Docker image `sendqon-companion:5.0.4` | Built runtime image |
