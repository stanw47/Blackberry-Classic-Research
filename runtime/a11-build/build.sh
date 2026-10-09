#!/bin/sh
# runtime/a11-build/build.sh — A11 native (Android 11) build environment + compile.
#
# Established session68. Compiles the A11 userland C++ (libbinder + libutils/libbase/
# libcutils/liblog) for ARM. This is the WS1b/WS2 build foundation for the QNX port.
#
# Toolchain: Android NDK r23c clang (armv7a-linux-androideabi30) + the NDK sysroot
# (bionic + libc++) + the AOSP 11 source headers. The raw bionic/libcxx repos do NOT
# integrate with GCC (Clang attributes) nor stand alone (libc++/bionic config) — the
# NDK is required.
#
# Prereqs (host, durable):
#   ~/android-mine/ndk/android-ndk-r23c/            (NDK r23c, API 30)
#   ~/android-mine/bt30/aidl                         (build-tools r30 aidl)
#   ~/android-mine/aosp/{lin_frameworks_native,lin_system_core,lin_bionic,
#                        lin_external_libcxx,lin_system_libhwbinder,
#                        aosp_system_libbase,aosp_system_logging,
#                        aosp_external_selinux,aosp_system_libvintf}   (A11 source)
set -e

NDK=${NDK:-$HOME/android-mine/ndk/android-ndk-r23c/toolchains/llvm/prebuilt/linux-x86_64}
CXX=$NDK/bin/armv7a-linux-androideabi30-clang++
AOSP=${AOSP:-$HOME/android-mine/aosp}
AIDL=${AIDL:-$HOME/android-mine/bt30/aidl}
GEN=${GEN:-/tmp/aidl_gen}

INC="-I$AOSP/lin_frameworks_native/libs/binder/include
     -I$AOSP/lin_frameworks_native/libs/utils/include
     -I$AOSP/lin_frameworks_native/libs/nativebase/include
     -I$AOSP/lin_frameworks_native/libs/ui/include
     -I$AOSP/lin_system_core/libutils/include
     -I$AOSP/lin_system_core/libcutils/include
     -I$AOSP/lin_system_core/libsystem/include
     -I$AOSP/lin_system_core/libprocessgroup/include
     -I$AOSP/lin_system_core/libbacktrace/include
     -I$AOSP/aosp_system_logging/liblog/include
     -I$AOSP/aosp_system_libbase/include
     -I$AOSP/aosp_external_selinux/libselinux/include
     -I$AOSP/aosp_system_libvintf/include
     -I$GEN"

# 1. Generate the AIDL C++ headers libbinder needs (BnServiceCallback, IServiceManager, ...).
gen_aidl() {
    mkdir -p "$GEN"
    "$AIDL" --lang=cpp --out="$GEN" --header_out="$GEN" \
        -I"$AOSP/lin_frameworks_native/libs/binder/aidl" \
        $(find "$AOSP/lin_frameworks_native/libs/binder/aidl" -name '*.aidl')
}

# 2. Compile a source dir; skip the non-target files (windows/benchmarks/optional).
#    Excludes: *_windows.cpp, *_benchmark.cpp, format_benchmark.cpp, errors_windows.cpp,
#              utf8.cpp (windows path), misc.cpp (vndksupport), logd_writer/pmsg_writer
#              (need generated log-tag config), trace-container.cpp (atrace gen).
compile_lib() {
    lib=$1; dir=$2; out=$3; extra=$4
    rm -rf "$out"; mkdir -p "$out"; ok=0; fail=0
    # NOTE: libutils/misc.cpp (add_sysprop_change_callback) is REQUIRED; its only
    # Android-only dep is the vndksupport branch, disabled by __ANDROID_RECOVERY__
    # (see CXXFLAGS).  Only libbase's vndksupport misc.cpp is excluded by path.
    for f in $(find "$dir" -maxdepth 1 -name '*.cpp' \
                 | grep -vE '_windows\.cpp|_benchmark\.cpp|format_benchmark|errors_windows|/utf8\.cpp|aosp_system_libbase/misc\.cpp|logd_writer|pmsg_writer|trace-container|_test[0-9]*\.cpp|-host\.cpp'); do
        if $CXX -std=c++17 -fPIC -D__ANDROID_RECOVERY__ -DLOG_NDEBUG=1 -c $INC $extra -o "$out/$(basename $f .cpp).o" "$f" 2>/dev/null; then
            ok=$((ok+1)); else fail=$((fail+1)); echo "  skip/fail: $(basename $f)"; fi
    done
    echo "$lib: compiled ok=$ok fail=$fail"
}

QNXB="$(cd "$(dirname "$0")" && pwd)/qnx_binder"
echo "[a11-build] generating AIDL headers"
gen_aidl
echo "[a11-build] compiling A11 native libs"
compile_lib libbase   "$AOSP/aosp_system_libbase"          /tmp/a11obj/libbase   "-include $QNXB/qnx_bionic_redirect.h -I$QNXB"
compile_lib liblog    "$AOSP/aosp_system_logging/liblog"   /tmp/a11obj/liblog    "-include $QNXB/qnx_bionic_redirect.h -I$QNXB"
# logd_writer.cpp is excluded; liblog references LogdWrite -> no-op stub.
$CXX -std=c++17 -fPIC $INC -c "$(dirname "$0")/a11_stubs/logd_stub.cpp" -o /tmp/a11obj/liblog/logd_stub.o
compile_lib libcutils "$AOSP/lin_system_core/libcutils"    /tmp/a11obj/libcutils "-include $QNXB/qnx_bionic_redirect.h -I$QNXB"
compile_lib libutils  "$AOSP/lin_system_core/libutils"     /tmp/a11obj/libutils  "-include $QNXB/qnx_bionic_redirect.h -I$QNXB"
# -DBINDER_IPC_32BIT=1: the driver speaks RIM's 32-bit protocol (session50:
# version 7), so A11's wire format is built 32-bit and matches byte-for-byte.
# This makes the old 64<->32 translation layer (binder_compat.c) unnecessary.
compile_lib libbinder "$AOSP/lin_frameworks_native/libs/binder" /tmp/a11obj/libbinder "-include $QNXB/qnx_binder_redirect.h -I$QNXB -DBINDER_IPC_32BIT=1"
CC=$NDK/bin/armv7a-linux-androideabi30-clang
$CC -std=c11 -fPIC -I"$QNXB" -c "$QNXB/qnx_binder.c" -o /tmp/a11obj/libbinder/qnx_binder.o
echo "[a11-build] compiled QNX binder devctl redirect into libbinder (32-bit wire)"

# AIDL-generated .cpp define android/os/*::descriptor + getInterfaceDescriptor — libbinder
# needs them (else the QNX loader reports them unresolved). Compile into libbinder's objs.
for f in "$GEN"/android/os/*.cpp; do
    $CXX -std=c++17 -fPIC -c $INC -o "/tmp/a11obj/libbinder/$(basename $f .cpp)_aidl.o" "$f"
done
echo "[a11-build] compiled AIDL .cpp into libbinder"

# 3. Link the A11 native stack (Android/NDK flavor — validates the full source set).
#    The QNX flavor (WS1 shim + nto.link/libcS) is the next step.
echo "[a11-build] linking (NDK/Android flavor)"
O=/tmp/a11obj; mkdir -p $O/lib
$CXX -shared -o $O/lib/libbase.so   $O/libbase/*.o
$CXX -shared -o $O/lib/liblog.so    $O/liblog/*.o -L$O/lib -lbase
$CXX -shared -o $O/lib/libcutils.so $O/libcutils/*.o -L$O/lib -llog -lbase
$CXX -shared -o $O/lib/libutils.so  $O/libutils/*.o -L$O/lib -lcutils -llog -lbase
$CXX -shared -o $O/lib/libbinder.so $O/libbinder/*.o -L$O/lib -lutils -lcutils -llog -lbase
echo "[a11-build] done: $(ls -la $O/lib/*.so | wc -l) shared libs under $O/lib"
