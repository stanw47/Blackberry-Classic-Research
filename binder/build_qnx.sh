#!/bin/sh
# binder/build_qnx.sh — freestanding QNX ARM cross-build (no QNX SDP).
#
# Reconstructed from notes-session63/64. Compiles the resmgr against the
# hand-built qnxinc/ stub headers and links a PIE whose interpreter is the
# Classic's /usr/lib/ldqnx.so.2, with libc.so.3 recorded as NEEDED so the QNX
# loader resolves the ~90 undefined symbols at runtime.
#
# Usage: ./build_qnx.sh        (from binder/)
set -e

CC=arm-none-eabi-gcc
SYSROOT=../sysroot/target
OUT=build

CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -Os -nostdinc -nostdlib \
        -fpic -ffreestanding -fno-builtin \
        -Iqnxinc -Iinclude -Isrc \
        -include sys/cdefs.h -include qnx_resmgr_proto.h"

# start.S is assembled, not compiled: no C -include / -I header injection.
ASFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb"

LDFLAGS="-nostdlib -fpic -Wl,-pie -Wl,-e,_start \
         -Wl,--dynamic-linker=/usr/lib/ldqnx.so.2 \
         -Wl,--hash-style=gnu -Wl,--build-id=md5 \
         -Wl,--export-dynamic -Wl,--unresolved-symbols=ignore-all \
         -Wl,--no-as-needed -L ${SYSROOT}/lib -L ../ws1/build -l:libc.so.3 -l:libc.so"

mkdir -p "$OUT"

echo "[build] start.o"
$CC $ASFLAGS -c start.S -o $OUT/start.o

echo "[build] binder.c"
$CC $CFLAGS -c src/binder.c -o $OUT/binder_qnx.o

echo "[build] binder_core.c"
$CC $CFLAGS -c src/binder_core.c -o $OUT/binder_core_qnx.o

echo "[build] binder_handlers.c"
$CC $CFLAGS -c src/binder_handlers.c -o $OUT/binder_handlers_qnx.o

echo "[link] build/binder"
$CC $LDFLAGS -o $OUT/binder \
    $OUT/start.o $OUT/binder_qnx.o $OUT/binder_core_qnx.o $OUT/binder_handlers_qnx.o

echo "[ok] $OUT/binder"
arm-none-eabi-readelf -h $OUT/binder | grep -E "Type|Entry"
arm-none-eabi-readelf -d $OUT/binder | grep NEEDED || true
echo "[und] $(arm-none-eabi-readelf -s $OUT/binder | grep -c UND) undefined symbols"
