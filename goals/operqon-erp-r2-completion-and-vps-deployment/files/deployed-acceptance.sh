#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
ROOT=/opt/operqon-provider-r2
[ "$(id -u)" = 0 ] || exit 1
pass() {
  local expected="$1" uri="$2" actual
  actual=$(curl --noproxy '*' -sS --max-time 12 -o /dev/null -w '%{http_code}' "$uri")
  printf 'HTTP %s [%s] %s\n' "$actual" "$expected" "$uri"
  [ "$actual" = "$expected" ]
}
pass_post() {
  local expected="$1" uri="$2" actual
  actual=$(curl --noproxy '*' -sS --max-time 12 -X POST -o /dev/null -w '%{http_code}' "$uri")
  printf 'HTTP %s [%s] %s\n' "$actual" "$expected" "$uri"
  [ "$actual" = "$expected" ]
}
pass 200 http://127.0.0.1:18090/healthz
pass 200 http://127.0.0.1:18090/readyz
pass 401 http://127.0.0.1:18090/api/v1/provider/me
pass 401 http://127.0.0.1:18090/api/v1/provider/tenant-queue
pass 401 http://127.0.0.1:18090/api/v1/provider/billing/gateways
pass_post 401 http://127.0.0.1:18090/internal/v1/provisioner/claim
pass 404 http://127.0.0.1:18090/openapi.json
pass 200 http://127.0.0.1:18089/readyz
pass 200 http://127.0.0.1:18087/healthz
pass 200 https://control.operqon.cloud/tenants.html
pass 404 https://login.operqon.cloud/admin/
FORGED=$(curl --noproxy '*' -sS --max-time 10 -o /dev/null -w '%{http_code}' -H 'X-Role: operqon:operator' http://127.0.0.1:18090/api/v1/provider/tenant-queue)
[ "$FORGED" = 401 ]
[ "$(docker inspect -f '{{.State.Running}}' operqon_provider_r1-api-1)" = true ]
[ "$(docker inspect -f '{{.State.Running}}' operqon_provider_r1-db-1)" = true ]
if [ -d "$ROOT/.git" ]; then
  git -C "$ROOT" diff --quiet -- app || { echo 'STOP: App source modified after checkout'; exit 1; }
fi
echo 'R2 ACCEPTANCE: PROTECTED CANARY PASS; real signed MFA+staging E2E are separate evidence gates.'
