#!/bin/bash
# One-shot staging setting flip: sch_settings.download_admit_card 0 -> 1
# Guarded on the staging database name. Password is parsed on-host and never printed.
CFG=/home/u238632175/domains/iqrs.edu.pk/public_html/staging/application/config/database.php
get() { grep -oP "'$1'\s*=>\s*'\K[^']+" "$CFG" | head -1; }
DBH=$(get hostname); DBU=$(get username); DBP=$(get password); DBN=$(get database)
echo "database=$DBN host=$DBH user=$DBU"
if [ "$DBN" != "u238632175_test123" ]; then echo "GUARD FAIL - aborting, no changes"; exit 1; fi
export MYSQL_PWD="$DBP"
echo "--- BEFORE ---"
mysql -h "$DBH" -u "$DBU" "$DBN" -e "SELECT id, download_admit_card FROM sch_settings;"
mysql -h "$DBH" -u "$DBU" "$DBN" -e "UPDATE sch_settings SET download_admit_card = 1 WHERE download_admit_card = 0;"
echo "--- AFTER ---"
mysql -h "$DBH" -u "$DBU" "$DBN" -e "SELECT id, download_admit_card FROM sch_settings;"
