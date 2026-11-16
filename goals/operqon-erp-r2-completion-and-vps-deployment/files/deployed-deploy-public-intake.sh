#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

ROOT=/opt/operqon-provider-r2
PORTAL=/srv/operqon-public-portal/current
CADDY=${OPERQON_CADDYFILE:-/etc/caddy/Caddyfile}
RELEASE=$(cd "$(dirname "$0")/.." && pwd -P)

(cd "$RELEASE" && sha256sum -c MANIFEST.sha256)

[ "$(id -u)" = 0 ] || { echo "STOP: root required"; exit 1; }
[ -s "$ROOT/alembic/versions/0005_pricing_currency_permissions.py" ] || { echo "STOP: R2 migration head source missing"; exit 1; }
[ -s "$ROOT/scripts/acceptance.sh" ] && grep -Fq "pass_post" "$ROOT/scripts/acceptance.sh" && grep -Fq "/internal/v1/provisioner/claim" "$ROOT/scripts/acceptance.sh" || { echo "STOP: Muse-updated R2 acceptance.sh not found; refusing to overwrite or bypass it"; exit 1; }
[ -s "$ROOT/deploy/compose.r2.yaml" ] || { echo "STOP: R2 compose missing"; exit 1; }
[ -s "$ROOT/deploy/config/merchant.env" ] || { echo "STOP: existing R2 merchant.env missing"; exit 1; }
[ -d "$PORTAL" ] || { echo "STOP: existing public portal root missing"; exit 1; }
[ -s "$PORTAL/assets/site.css" ] && [ -s "$PORTAL/assets/operqon-tokens.css" ] && [ -s "$PORTAL/assets/operqon-primary-horizontal.svg" ] || { echo "STOP: existing portal brand assets missing"; exit 1; }
[ -s "$CADDY" ] || { echo "STOP: Caddyfile missing"; exit 1; }
docker image inspect operqon/provider-api:r2 >/dev/null 2>&1 || { echo "STOP: preserved R2 rollback image missing"; exit 1; }

http_code() { curl --noproxy '*' -sS --max-time 12 -o /dev/null -w '%{http_code}' "$1"; }
[ "$(http_code http://127.0.0.1:18090/readyz)" = 200 ] || { echo "STOP: R2 canary 18090 not ready"; exit 1; }
[ "$(http_code http://127.0.0.1:18089/readyz)" = 200 ] || { echo "STOP: R1 18089 not healthy"; exit 1; }
[ "$(http_code http://127.0.0.1:18087/healthz)" = 200 ] || { echo "STOP: legacy 18087 not healthy"; exit 1; }

# Idempotent rerun: if all release markers are present, run acceptance only.
if grep -Fq 'PUBLIC_INTAKE_PATH = "/api/v1/public/tenant-requests"' "$ROOT/app/main.py" \
  && grep -Fq 'OPERQON PUBLIC INTAKE R2.1' "$CADDY" \
  && [ -s "$PORTAL/request-access.html" ]; then
  echo "PUBLIC INTAKE R2.1 already installed; running acceptance only."
  bash "$ROOT/scripts/acceptance-public-intake.sh"
  exit 0
fi

# Check required R2 external networks before changing files.
docker network inspect operqon_provider_r1_provider_internal >/dev/null
docker network inspect operqon_provider_r1_provider_edge >/dev/null

BACKUP=$(mktemp -d /root/operqon-public-intake-r21.XXXXXX)
chmod 700 "$BACKUP"
mkdir -p "$BACKUP/files" "$BACKUP/meta" "$BACKUP/files/public_portal"
: > "$BACKUP/meta/present.txt"
: > "$BACKUP/meta/absent.txt"

ROOT_FILES=(
  app/main.py app/models.py app/schemas.py app/config.py app/maintenance.py
  Dockerfile.test frontend/tenants.html frontend/src/app.mjs
  alembic/versions/0006_public_tenant_intake.py
  tests/test_public_intake.py tests/test_public_portal_release.py tests/test_public_intake_migration_contract.py tests/test_postgres_public_intake_migration.py
  tests/fixtures/public_portal/request-access.html
  tests/fixtures/public_portal/assets/request-access.mjs
  tests/fixtures/public_portal/.well-known/operqon-portal.json
  tests/fixtures/public_portal/Caddyfile.operqon-apex-intake.snippet
  deploy/compose.r2-intake.yaml scripts/acceptance-public-intake.sh
  scripts/apply-public-intake-caddy.sh scripts/rollback-public-intake.sh
)
PORTAL_FILES=(index.html .well-known/operqon-portal.json request-access.html assets/request-access.css assets/request-access.mjs)
for relative in "${ROOT_FILES[@]}"; do
  if [ -e "$ROOT/$relative" ]; then
    mkdir -p "$BACKUP/files/$(dirname "$relative")"
    cp -p "$ROOT/$relative" "$BACKUP/files/$relative"
    echo "$relative" >> "$BACKUP/meta/present.txt"
  else
    echo "$relative" >> "$BACKUP/meta/absent.txt"
  fi
done
for relative in "${PORTAL_FILES[@]}"; do
  if [ -e "$PORTAL/$relative" ]; then
    mkdir -p "$BACKUP/files/public_portal/$(dirname "$relative")"
    cp -p "$PORTAL/$relative" "$BACKUP/files/public_portal/$relative"
    echo "public_portal/$relative" >> "$BACKUP/meta/present.txt"
  else
    echo "public_portal/$relative" >> "$BACKUP/meta/absent.txt"
  fi
done
cp -p "$CADDY" "$BACKUP/Caddyfile"
printf '%s\n' "$ROOT" > "$BACKUP/meta/root.txt"

rollback_on_error() {
  rc=$?
  trap - EXIT
  if [ "$rc" -ne 0 ]; then
    echo "DEPLOYMENT FAILED: running automatic rollback"
    bash "$RELEASE/scripts/rollback-public-intake.sh" "$BACKUP" || echo "URGENT: automatic rollback needs manual review"
  fi
  exit "$rc"
}
trap rollback_on_error EXIT

# Install only the R2.1 overlay. R2 acceptance.sh is deliberately not overwritten.
for relative in app/main.py app/models.py app/schemas.py app/config.py app/maintenance.py \
  Dockerfile.test frontend/tenants.html frontend/src/app.mjs \
  alembic/versions/0006_public_tenant_intake.py \
  tests/test_public_intake.py tests/test_public_portal_release.py tests/test_public_intake_migration_contract.py tests/test_postgres_public_intake_migration.py \
  tests/fixtures/public_portal/request-access.html \
  tests/fixtures/public_portal/assets/request-access.mjs \
  tests/fixtures/public_portal/.well-known/operqon-portal.json \
  tests/fixtures/public_portal/Caddyfile.operqon-apex-intake.snippet \
  deploy/compose.r2-intake.yaml scripts/acceptance-public-intake.sh \
  scripts/apply-public-intake-caddy.sh scripts/rollback-public-intake.sh; do
  install -D -m 0644 "$RELEASE/$relative" "$ROOT/$relative"
done
install -D -m 0644 "$RELEASE/public_portal/index.html" "$PORTAL/index.html"
install -D -m 0644 "$RELEASE/public_portal/.well-known/operqon-portal.json" "$PORTAL/.well-known/operqon-portal.json"
install -D -m 0644 "$RELEASE/public_portal/request-access.html" "$PORTAL/request-access.html"
install -D -m 0644 "$RELEASE/public_portal/assets/request-access.css" "$PORTAL/assets/request-access.css"
install -D -m 0644 "$RELEASE/public_portal/assets/request-access.mjs" "$PORTAL/assets/request-access.mjs"

# Muse fix (2026-11-06): install -D under umask 077 creates new overlay dirs as 0700;
# the non-root test container then cannot scan tests/fixtures. Normalize dir perms.
find "$ROOT/app" "$ROOT/alembic" "$ROOT/tests" "$ROOT/frontend" -type d -exec chmod 755 {} +

# Full test suite runs in an isolated, networkless container before DB changes.
docker build --pull --no-cache -f "$ROOT/Dockerfile.test" -t operqon/provider-r2-public-intake-tests:r2.1 "$ROOT"
docker run --rm --network none --read-only --tmpfs /tmp:rw,noexec,nosuid,size=32m \
  -e PYTHONDONTWRITEBYTECODE=1 -e PYTEST_ADDOPTS="-p no:cacheprovider" \
  --security-opt no-new-privileges --cap-drop ALL --pids-limit 64 \
  operqon/provider-r2-public-intake-tests:r2.1
for script in "$ROOT"/scripts/*.sh; do bash -n "$script"; done
docker run --rm -v "$PORTAL/assets:/portal-assets:ro" node:22-alpine node --check /portal-assets/request-access.mjs

# Build a new immutable API image tag; retain R2 image and compose for rollback.
docker compose -f "$ROOT/deploy/compose.r2-intake.yaml" build migrate
# 0006 is additive. If already at head, Alembic performs a no-op.
docker compose -f "$ROOT/deploy/compose.r2-intake.yaml" run --rm migrate
docker compose -f "$ROOT/deploy/compose.r2-intake.yaml" up -d --no-deps --force-recreate api

ready=0
for _ in $(seq 1 30); do
  if [ "$(http_code http://127.0.0.1:18090/readyz)" = 200 ]; then ready=1; break; fi
  sleep 3
done
[ "$ready" = 1 ] || { echo "STOP: R2.1 API did not become ready"; exit 1; }

# Expose only the exact public intake path; all other public /api paths remain 404.
bash "$ROOT/scripts/apply-public-intake-caddy.sh"
bash "$ROOT/scripts/acceptance-public-intake.sh"

printf '%s\n' "$BACKUP" > /root/operqon-public-intake-r21.latest
chmod 600 /root/operqon-public-intake-r21.latest
trap - EXIT

echo "PUBLIC INTAKE R2.1 DEPLOYMENT: COMPLETE"
echo "R2 API: 127.0.0.1:18090"
echo "R1 API 18089 and legacy 18087: untouched"
echo "BACKUP: $BACKUP"
echo "DATABASE: additive migration 0006; no downgrade performed"
