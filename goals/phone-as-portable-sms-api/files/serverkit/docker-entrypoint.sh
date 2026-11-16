#!/bin/sh
# Sendqon (Zender) container entrypoint.
#
# 1. Materialize /var/www/zender/.env from the container's own environment
#    whenever the file is missing or has no DB_PASSWORD. Only storage/ is a
#    Docker volume in this stack, so a hand-written .env (the web installer
#    writes the real DB config there, and InstallerService reads the file,
#    not the process env) would otherwise be lost on every recreate.
# 2. Re-apply the writability fixes the installer and runtime need: the app
#    root directory entry, public/ and database/ owned by www-data (775),
#    storage/ and bootstrap/cache writable.
# 3. Recreate the public/storage symlink when missing (PR-002): the symlink
#    lives in the container layer, not in the storage volume, so a recreate
#    loses it and every /storage/* URL (uploaded logos, media) answers 404
#    until it is restored.
# 4. Exec the service command (supervisord for web, artisan for the workers).
set -e

APP_DIR=/var/www/zender
ENV_FILE="$APP_DIR/.env"

if [ ! -f "$ENV_FILE" ] || ! grep -q '^DB_PASSWORD=.\+' "$ENV_FILE"; then
    {
        printf 'APP_NAME=%s\n' "${APP_NAME:-Sendqon}"
        printf 'APP_ENV=%s\n' "${APP_ENV:-production}"
        if [ -n "${APP_KEY:-}" ]; then printf 'APP_KEY=%s\n' "$APP_KEY"; fi
        printf 'APP_DEBUG=%s\n' "${APP_DEBUG:-false}"
        printf 'APP_URL=%s\n' "${APP_URL:-https://sendqon.rektrs.com}"
        printf 'LOG_LEVEL=%s\n' "${LOG_LEVEL:-error}"
        printf 'DB_CONNECTION=%s\n' "${DB_CONNECTION:-mysql}"
        printf 'DB_HOST=%s\n' "${DB_HOST:-db}"
        printf 'DB_PORT=%s\n' "${DB_PORT:-3306}"
        printf 'DB_DATABASE=%s\n' "${DB_DATABASE:-zender}"
        printf 'DB_USERNAME=%s\n' "${DB_USERNAME:-zender}"
        printf 'DB_PASSWORD=%s\n' "${DB_PASSWORD:-}"
        printf 'CACHE_STORE=%s\n' "${CACHE_STORE:-database}"
        printf 'QUEUE_CONNECTION=%s\n' "${QUEUE_CONNECTION:-database}"
        printf 'SESSION_DRIVER=%s\n' "${SESSION_DRIVER:-database}"
        # bootstrap/app.php registers trustProxies(at: env('TRUSTED_PROXIES', '*'));
        # pin it explicitly so URL generation stays https behind Caddy/Cloudflare.
        printf 'TRUSTED_PROXIES=%s\n' "${TRUSTED_PROXIES:-*}"
        true
    } > "$ENV_FILE"
    chown www-data:www-data "$ENV_FILE"
    chmod 664 "$ENV_FILE"
fi

chown www-data:www-data "$APP_DIR"
chown -R www-data:www-data "$APP_DIR/public" "$APP_DIR/database"
chmod 775 "$APP_DIR/public" "$APP_DIR/database"
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"
chmod -R ug+rwX "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"

# PR-002: restore the public/storage symlink lost on recreate (see header).
if [ ! -e "$APP_DIR/public/storage" ]; then
    rm -f "$APP_DIR/public/storage"
    (cd "$APP_DIR" && php artisan storage:link) || true
fi

exec "$@"
