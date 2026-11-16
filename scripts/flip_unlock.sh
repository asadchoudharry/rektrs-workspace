set -e
CFG=~/domains/iqrs.edu.pk/public_html/staging/application/config/database.php
DB=$(sed -n "s/.*'database'[^']*'\([^']*\)'.*/\1/p" "$CFG" | head -1)
USR=$(sed -n "s/.*'username'[^']*'\([^']*\)'.*/\1/p" "$CFG" | head -1)
PASS=$(sed -n "s/.*'password'[^']*'\([^']*\)'.*/\1/p" "$CFG" | head -1)
HOST=$(sed -n "s/.*'hostname'[^']*'\([^']*\)'.*/\1/p" "$CFG" | head -1)
echo "DB=$DB HOST=$HOST"
[ "$DB" = "u238632175_test123" ] || { echo "GUARD FAIL - not staging DB"; exit 1; }
echo "--- PRE-FLIP ---"
mysql -h "$HOST" -u "$USR" -p"$PASS" "$DB" -e "SELECT id, due_date FROM fee_groups_feetype WHERE id BETWEEN 2015 AND 2024 ORDER BY id;"
mysql -h "$HOST" -u "$USR" -p"$PASS" "$DB" -e "UPDATE fee_groups_feetype SET due_date='2027-06-30' WHERE id IN (2015,2016,2017,2018,2019,2021,2022,2023,2024); SELECT ROW_COUNT() AS rows_updated;"
echo "--- POST-FLIP ---"
mysql -h "$HOST" -u "$USR" -p"$PASS" "$DB" -e "SELECT id, due_date FROM fee_groups_feetype WHERE id BETWEEN 2015 AND 2024 ORDER BY id;"
echo "UNLOCK FLIP DONE"
