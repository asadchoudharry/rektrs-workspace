#!/bin/bash
# Runs ON the Hostinger host. Usage: dbq_remote.sh <tree_abs_path> <base64-sql> <expected-db>
# Parses creds from the tree's database.php (first literal block), enforces the DB-name
# guard, runs the SQL via mysql. Password lives only in this process env; never printed.
T="$1"; SQL=$(printf '%s' "$2" | base64 -d); WANT="$3"
DBF="$T/application/config/database.php"
getv(){ grep -m1 "'$1' =>" "$DBF" | cut -d"'" -f4; }
H=$(getv hostname); U=$(getv username); P=$(getv password); D=$(getv database)
if [ "$D" != "$WANT" ]; then echo "DB-GUARD-FAIL got=$D want=$WANT" >&2; exit 9; fi
MYSQL_PWD="$P" mysql -h "${H:-localhost}" -u "$U" -N -B "$D" -e "$SQL"
