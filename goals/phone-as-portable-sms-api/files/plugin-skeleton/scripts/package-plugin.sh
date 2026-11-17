#!/usr/bin/env bash
# Package a Sendqon plugin directory into an installable ZIP.
# Usage: package-plugin.sh <plugin-dir> <output.zip>
# Validates: plugin.json parses, required fields present, main_class
# file exists inside the dir, total size <= 20 MB (PluginManager limit).
set -euo pipefail

SRC="${1:?plugin dir required}"
OUT="${2:?output zip required}"
MAX_BYTES=$((20 * 1024 * 1024))

[ -f "$SRC/plugin.json" ] || { echo "FAIL: $SRC/plugin.json missing"; exit 1; }

python3 - "$SRC/plugin.json" <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))
for f in ["name", "slug", "type", "main_class", "namespace", "version", "author"]:
    assert m.get(f), f"manifest field missing: {f}"
assert m["namespace"].startswith("App\\Plugins\\"), "namespace must start with App\\Plugins\\"
print("manifest OK:", m["slug"], m["type"], m["version"])
PY

[ -f "$SRC/$(python3 -c "import json;print(json.load(open('$SRC/plugin.json'))['main_class'])")" ] \
  || { echo "FAIL: main_class file missing"; exit 1; }

SIZE=$(du -sb "$SRC" | cut -f1)
[ "$SIZE" -le "$MAX_BYTES" ] || { echo "FAIL: plugin is $SIZE bytes (> 20 MB)"; exit 1; }

rm -f "$OUT"
(cd "$SRC" && zip -qr "$OUT" . -x "*.DS_Store")
echo "packaged: $OUT ($(stat -c%s "$OUT") bytes, source $SIZE bytes)"
