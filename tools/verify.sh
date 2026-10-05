#!/usr/bin/env bash
# Extract/verify A11 reference artifacts + evidence. Persisted (outside /tmp).
# Reference sources:
#   ~/Downloads/lineage-18.1-20250101-UNOFFICIAL-wseries   -> Passport A11
#   ~/Downloads/lineage-18.1-20210106-UNOFFICIAL-Tom-bacon-signed -> Bacon A11
#   ~/Downloads/lineage-22.2-20260906-nightly-sailfish-signed      -> Pixel 1 A15
set -euo pipefail
ROOT="$(cd "$(dirname "$0")"/.. && pwd)"      # research/
SPEC="$ROOT/specimens"
DL="$HOME/Downloads"
PASS="$DL/lineage-18.1-20250101-UNOFFICIAL-wseries"
BACON="$DL/lineage-18.1-20210106-UNOFFICIAL-Tom-bacon-signed"

echo "== verifying persisted specimens =="
( cd "$SPEC" && sha256sum -c MANIFEST.sha256 2>/dev/null | grep -v ': OK$' || true )

echo "== Passport system image present? =="
[ -f "$PASS/system_wseries.img" ] || echo "  MISSING (run: python3 tools/sdat2img.py brotlidec system.new.dat.br system.new.dat && sdat2img)"
[ -f "$PASS/kernel.bin" ] || echo "  kernel not extracted (python3 -c boot img split)"
[ -f "$PASS/ramdisk.img" ] && echo "  ramdisk ok"

echo "== A11 UAPI in specimens =="
ls "$SPEC"/a11_binder_uapi.h "$SPEC"/a11_binderfs_uapi.h 2>/dev/null

echo "== A11 libbinder references (bacon vs passport) =="
ls -la "$SPEC"/passport_a11/*.so 2>/dev/null | head
echo "TIP if bacon lib needs re-harvest:"
echo "  debugfs -R 'dump /system/lib/libbinder.so /tmp/x' $BACON/system.img"