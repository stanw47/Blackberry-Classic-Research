#!/bin/sh
# runtime/a11-build/qnx-link.sh — relink the A11 native objects as QNX ELFs.
#
# Produces QNX-flavored .so's that NEED (in order) the real QNX libc.so.3 FIRST and the
# WS1 bionic shim (libc.so) SECOND — that ordering is REQUIRED (session57): binding the
# loader's own needs to the shim first causes an init crash.
#
# Also needed (each cost an on-device iteration):
#  - libgcc/`__aeabi_mem*` ABI helpers (the shim lacks __aeabi_memcpy) — see aeabi_stubs.c.
#  - the AIDL-generated .cpp (android/os/{IServiceManager,IServiceCallback,IClientCallback})
#    compiled into libbinder.so, else the loader reports `descriptor` symbols unresolved.
#  - NDK crtbegin_so.o/crtend_so.o (__dso_handle).
set -e

REPO=$(cd "$(dirname "$0")/../.." && pwd)
NDK=${NDK:-$HOME/android-mine/ndk/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64}
AOSP=${AOSP:-$HOME/android-mine/aosp}
GEN=${GEN:-/tmp/aidl_gen}
SYS=$NDK/sysroot/usr/lib/arm-linux-androideabi
LU=$NDK/lib64/clang/12.0.9/lib/linux/arm/libunwind.a
CB=$SYS/30/crtbegin_so.o
CE=$SYS/30/crtend_so.o
LD=arm-none-eabi-ld
O=/tmp/a11obj
OUT=$O/qnx
SHIM=$REPO/ws1/build                       # libc.so (WS1 shim)
SR=$REPO/sysroot/target/lib                # libc.so.3 (real QNX libc)
mkdir -p "$OUT"

# __aeabi_mem* stubs (the shim lacks them).
cat > "$O/aeabi_stubs.c" <<'EOF'
typedef unsigned int size_t;
extern void *memcpy(void*, const void*, size_t);
extern void *memmove(void*, const void*, size_t);
extern void *memset(void*, int, size_t);
void __aeabi_memcpy (void*d,const void*s,size_t n){memcpy(d,s,n);}
void __aeabi_memcpy4(void*d,const void*s,size_t n){memcpy(d,s,n);}
void __aeabi_memcpy8(void*d,const void*s,size_t n){memcpy(d,s,n);}
void __aeabi_memmove (void*d,const void*s,size_t n){memmove(d,s,n);}
void __aeabi_memmove4(void*d,const void*s,size_t n){memmove(d,s,n);}
void __aeabi_memmove8(void*d,const void*s,size_t n){memmove(d,s,n);}
void __aeabi_memset  (void*d,int c,size_t n){memset(d,c,n);}
void __aeabi_memset4 (void*d,int c,size_t n){memset(d,c,n);}
void __aeabi_memset8 (void*d,int c,size_t n){memset(d,c,n);}
void __aeabi_memclr  (void*d,size_t n){memset(d,0,n);}
void __aeabi_memclr4 (void*d,size_t n){memset(d,0,n);}
void __aeabi_memclr8 (void*d,size_t n){memset(d,0,n);}
EOF
arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -Os -nostdlib -fpic -ffreestanding -fno-builtin -c "$O/aeabi_stubs.c" -o "$O/aeabi_stubs.o"

# AIDL-generated .cpp compiled into libbinder (done in build.sh; here just include if present).
L="$LD -shared --allow-shlib-undefined -L$OUT -L$SHIM -L$SR"
CRT="$CB $CE"
# ORDER MATTERS: real QNX libc first.  The WS1 shim is deployed on-device under
# the (unused) trusted libthread_db.so inode, so the NEEDED name is
# libthread_db.so — that keeps the runtime's real libc.so loadable for the
# core's QNX binaries while our chain gets the shim (session50e).
if [ ! -f "$SHIM/libthread_db.so" ]; then
    echo "[qnx-link] missing $SHIM/libthread_db.so — run: make -C ws1 build/libthread_db.so"
    exit 1
fi
QNXNEED="-l:libc.so.3 -l:libthread_db.so"

echo "[qnx-link] libc++.so (static libc++/abi/unwind + aeabi stubs -> shared)"
$L -o "$OUT/libc++.so" $CRT --whole-archive "$SYS/libc++_static.a" "$SYS/libc++abi.a" "$LU" --no-whole-archive "$O/aeabi_stubs.o" $QNXNEED $CE -soname libc++.so 2>&1 | grep -vE "warning|stripped|NOTE" | head -3 || true

echo "[qnx-link] libbase.so liblog.so libcutils.so libutils.so"
$L -o "$OUT/libbase.so"   $CRT $O/libbase/*.o   -lc++       $QNXNEED $CE -soname libbase.so   2>&1 | grep -v warning | head -2 || true
$L -o "$OUT/liblog.so"    $CRT $O/liblog/*.o                $QNXNEED $CE -soname liblog.so    2>&1 | grep -v warning | head -2 || true
$L -o "$OUT/libcutils.so" $CRT $O/libcutils/*.o -llog -lbase $QNXNEED $CE -soname libcutils.so 2>&1 | grep -v warning | head -2 || true
$L -o "$OUT/libutils.so"  $CRT $O/libutils/*.o  -lcutils -llog -lbase $QNXNEED $CE -soname libutils.so 2>&1 | grep -v warning | head -2 || true

echo "[qnx-link] libbinder.so (incl. AIDL cpp)"
$L -o "$OUT/libbinder.so" $CRT $O/libbinder/*.o -lutils -lcutils -llog -lbase -lc++ $QNXNEED $CE -soname libbinder.so 2>&1 | grep -vE "warning|stripped" | head -3 || true

echo "[qnx-link] results (want NEEDED: libc.so.3 then libc.so):"
for f in "$OUT"/*.so; do printf "  %-14s %8s  " "$(basename $f)" "$(stat -c%s $f)"; arm-none-eabi-readelf -d "$f" 2>/dev/null | grep -oE "\[lib[^]]*\]" | tr '\n' ' '; echo; done
