#!/bin/bash
# IQRS STAGING database password rotation — runs ON the Hostinger host.
# Prints only step markers. Passwords live only in shell variables and the
# two config files; they are never printed, logged, or written anywhere else.
set -u
cd /home/u238632175/domains/iqrs.edu.pk/public_html/staging || { echo "FAIL cd"; exit 1; }
WEB=application/config/database.php
API=api/application/config/database.php
DBNAME=u238632175_test123

fail() { echo "FAIL: $1"; exit 1; }

# 0. backups (created before anything changes)
[ -f "$WEB.bak-2026-11-10-rotationpre" ] || cp "$WEB" "$WEB.bak-2026-11-10-rotationpre"
[ -f "$API.bak-2026-11-10-rotationpre" ] || cp "$API" "$API.bak-2026-11-10-rotationpre"
echo "STEP backups ok"

# extract a key's value from a CI3 config (first match, spacing-tolerant)
getval() {
  grep -E "'$2'[[:space:]]*=>" "$1" | head -1 | sed -E "s/^.*=>[[:space:]]*'//; s/'.*$//"
}
USER=$(getval "$WEB" username)
HOST=$(getval "$WEB" hostname)
DBN=$(getval "$WEB" database)
OLD=$(getval "$WEB" password)
[ "$DBN" = "$DBNAME" ] || fail "web config database mismatch"
[ -n "$USER" ] && [ -n "$OLD" ] || fail "could not parse web config"
A_DBN=$(getval "$API" database)
A_OLD=$(getval "$API" password)
[ "$A_DBN" = "$DBNAME" ] || fail "api config database mismatch"
[ "$A_OLD" = "$OLD" ] || fail "api password differs from web password - manual check needed"
echo "STEP parse ok (host=$HOST user=$USER db=$DBN)"

# 1. current login must work before we touch anything
MYSQL_PWD="$OLD" mysql -h "$HOST" -u "$USER" "$DBN" -N -e "SELECT 1" >/dev/null 2>&1 || fail "current login broken"
echo "STEP current-login ok"

# 2. new password: 32 chars, safe charset only (no quoting hazards anywhere)
NEW=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
[ ${#NEW} -eq 32 ] || fail "password generation"

# 3. change the password in the database itself
CHANGED=0
if MYSQL_PWD="$OLD" mysql -h "$HOST" -u "$USER" -e "SET PASSWORD = PASSWORD('$NEW')" 2>/dev/null; then CHANGED=1; fi
if [ $CHANGED -eq 0 ]; then
  if MYSQL_PWD="$OLD" mysql -h "$HOST" -u "$USER" -e "ALTER USER CURRENT_USER IDENTIFIED BY '$NEW'" 2>/dev/null; then CHANGED=1; fi
fi
[ $CHANGED -eq 1 ] || fail "password change statement failed (configs untouched)"

rollback_db() {
  MYSQL_PWD="$NEW" mysql -h "$HOST" -u "$USER" -e "SET PASSWORD = PASSWORD('$OLD')" 2>/dev/null || \
  MYSQL_PWD="$NEW" mysql -h "$HOST" -u "$USER" -e "ALTER USER CURRENT_USER IDENTIFIED BY '$OLD'" 2>/dev/null
}

# 4. new login works, old login is dead
MYSQL_PWD="$NEW" mysql -h "$HOST" -u "$USER" "$DBN" -N -e "SELECT COUNT(*) FROM students" >/tmp/rot_count.txt 2>/dev/null || { rollback_db; fail "new login failed - rolled back"; }
echo "STEP new-login ok (students=$(cat /tmp/rot_count.txt))"
if MYSQL_PWD="$OLD" mysql -h "$HOST" -u "$USER" "$DBN" -N -e "SELECT 1" >/dev/null 2>&1; then rollback_db; fail "old password still works - rolled back"; fi
echo "STEP old-login dead ok"

# 5. write the new password into both configs (literal byte replace via python3;
#    this host has no perl)
OLD="$OLD" NEW="$NEW" python3 - <<'PYEOF' || { cp "$WEB.bak-2026-11-10-rotationpre" "$WEB"; cp "$API.bak-2026-11-10-rotationpre" "$API"; rollback_db; fail "config edit failed - restored + rolled back"; }
import os, sys
old = os.environ['OLD'].encode(); new = os.environ['NEW'].encode()
for path in ('application/config/database.php', 'api/application/config/database.php'):
    data = open(path, 'rb').read()
    if old not in data:
        sys.exit(3)
    open(path, 'wb').write(data.replace(old, new))
PYEOF
if grep -qF "$OLD" "$WEB" "$API"; then cp "$WEB.bak-2026-11-10-rotationpre" "$WEB"; cp "$API.bak-2026-11-10-rotationpre" "$API"; rollback_db; fail "old password still present in a config - restored + rolled back"; fi
grep -qF "$NEW" "$WEB" && grep -qF "$NEW" "$API" || { cp "$WEB.bak-2026-11-10-rotationpre" "$WEB"; cp "$API.bak-2026-11-10-rotationpre" "$API"; rollback_db; fail "new password missing in a config - restored + rolled back"; }
grep -q "$DBNAME" "$WEB" && grep -q "$DBNAME" "$API" || fail "db name check after edit"
echo "STEP configs updated ok"

# 6. site-level check from the host itself
CODE=$(curl -s -o /tmp/rot_page.html -w '%{http_code}' --max-time 30 https://staging.iqrs.edu.pk/ || echo 000)
SIZE=$(stat -c '%s' /tmp/rot_page.html 2>/dev/null || echo 0)
echo "STEP site http=$CODE bytes=$SIZE"

# 7. cleanup: remove every staging config backup that still holds the OLD
#    password (this run's rotationpre pair + any older lanes' copies)
SWEPT=0
for f in application/config/database.php.bak* application/config/database.php.*.bak* api/application/config/database.php.bak* api/application/config/database.php.*.bak*; do
  [ -f "$f" ] || continue
  if grep -qF "$OLD" "$f"; then rm -f "$f"; SWEPT=$((SWEPT+1)); fi
done
echo "STEP old-password backups swept=$SWEPT"
rm -f /tmp/rot_count.txt /tmp/rot_page.html
echo "ROTATION COMPLETE"
