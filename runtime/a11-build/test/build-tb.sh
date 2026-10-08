#!/bin/sh
# runtime/a11-build/test/build-tb.sh — build the WS1 shim probe executables.
#
# Reproduces the ad-hoc tb_shim/tb_cxx probes as tracked, rebuildable artifacts.
# Shape copied from the proven runtime/native/system/bin/test_prop:
#   PIE, interp /usr/lib/ldqnx.so.2, NEEDED [libc.so.3, libc.so], _start -> main.
#
# Prereqs: ws1/build/libc.so (make in ws1/), runtime/a11-build/qnx-link.sh output
#          in /tmp/a11obj/qnx, NDK r23c, arm-none-eabi-*.
set -e

REPO=$(cd "$(dirname "$0")/../../.." && pwd)
NDK=${NDK:-$HOME/android-mine/ndk/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64}
CXX=$NDK/bin/armv7a-linux-androideabi30-clang++
CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld

SHIM=$REPO/ws1/build
SR=$REPO/sysroot/target/lib
A11OUT=${A11OUT:-/tmp/a11obj/qnx}
SYS=$NDK/sysroot/usr/lib/arm-linux-androideabi
CB=$SYS/30/crtbegin_so.o
CE=$SYS/30/crtend_so.o
T=$REPO/runtime/a11-build/test
B=${B:-/tmp/tbbuild}
CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -Os -nostdlib -fno-builtin -fpic -ffreestanding"
# libc.so.3 is stripped (no section headers) so the *linker* cannot see its
# symbols; leave them undefined here and let the QNX *loader* bind them at run
# time (it reads the dynamic segment).
LDFLAGS="-pie --dynamic-linker=/usr/lib/ldqnx.so.2 -e _start --allow-shlib-undefined --unresolved-symbols=ignore-all"

mkdir -p "$B"

$CC $CFLAGS -c "$REPO/ws1/start.S" -o "$B/start.o"

echo "[build-tb] tb_shim (shim only)"
$CC $CFLAGS -c "$T/tb_shim.c" -o "$B/tb_shim.o"
$LD $LDFLAGS -o "$B/tb_shim" "$B/start.o" "$B/tb_shim.o" \
    -L"$SHIM" -L"$SR" -l:libc.so.3 -l:libc.so

echo "[build-tb] tb_dlopen (handler-first, dlopens the chain; shim only)"
$CC $CFLAGS -c "$T/tb_dlopen.c" -o "$B/tb_dlopen.o"
$LD $LDFLAGS -o "$B/tb_dlopen" "$B/start.o" "$B/tb_dlopen.o" \
    -L"$SHIM" -L"$SR" -l:libc.so.3 -l:libc.so

echo "[build-tb] tb_a11 (load full A11 chain via libbinder.so)"
$CC $CFLAGS -c "$T/tb_a11.c" -o "$B/tb_a11.o"
$LD $LDFLAGS -o "$B/tb_a11" "$B/start.o" "$B/tb_a11.o" \
    -L"$A11OUT" -L"$SHIM" -L"$SR" --no-as-needed -l:libc.so.3 -l:libc++.so -l:libc.so

echo "[build-tb] tb_cxx (libc++ static init + shim)"
$CXX -std=c++17 -fPIC -c "$T/tb_cxx.cpp" -o "$B/tb_cxx.o"
$LD $LDFLAGS -o "$B/tb_cxx" "$B/start.o" "$CB" "$B/tb_cxx.o" \
    -L"$A11OUT" -L"$SHIM" -L"$SR" -l:libc.so.3 -l:libc++.so -l:libc.so \
    "$CE"

echo "[build-tb] probe_binder_step (step-by-step binder open_driver probe)"
$CC $CFLAGS -I"$REPO/binder/include" -I"$REPO/binder/qnxinc" -c "$T/probe_binder_step.c" -o "$B/probe_binder_step.o"
$LD $LDFLAGS -o "$B/probe_binder_step" "$B/start.o" "$B/probe_binder_step.o" \
    -L"$SHIM" -L"$SR" -l:libc.so.3 -l:libc.so

for f in tb_shim tb_dlopen tb_cxx tb_a11 probe_binder_step; do
    printf '== %-18s == ' "$f"
    arm-none-eabi-readelf -d "$B/$f" | grep -oE '\[lib[^]]*\]' | tr '\n' ' '
    echo
done
echo "[build-tb] done -> $B"
