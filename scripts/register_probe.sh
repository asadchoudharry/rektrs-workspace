set -e
REG=~/domains/iqrs.edu.pk/public_html/staging/application/private/print_issuance
echo "--- register dir ---"
ls "$REG" | head -5
echo "--- files in battery window (UTC 2026-11-10 02:00-03:50) ---"
find "$REG" -name "*.json" -newermt "2026-11-10 02:00" ! -newermt "2026-11-10 03:50" -printf "%T@ %p\n" | sort -n | awk '{print $2}'
echo "--- count in window ---"
find "$REG" -name "*.json" -newermt "2026-11-10 02:00" ! -newermt "2026-11-10 03:50" | wc -l
