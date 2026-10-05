# session68 — A11 native build environment ESTABLISHED (B3 unblocked at compile level)

Date 2026-09-20. Classic live via SSH. Continues session67. Goal (locked sessions
31/32): build our own Android 11 runtime on QNX from AOSP source; 4.3 is the specimen.

## Milestone
The A11 userland C++ now **compiles** for ARM. Reproducible: `runtime/a11-build/build.sh`.

    libbase: 16   liblog: 11   libcutils: 29   libutils: 24   libbinder: 36/36

(only non-target files skipped: *_windows.cpp, *_benchmark.cpp, *_test.cpp,
format.h/fmt, vndksupport misc.cpp, logd/pmsg writers, trace-container).

This was session67's blocker **B3** ("A11 userland cannot be built — AOSP header tree
missing"). It is now unblocked at the compile stage.

## Environment (pinned)
- **NDK r23c** (`~/android-mine/ndk/android-ndk-r23c/`), clang wrapper
  `armv7a-linux-androideabi30-clang++`; the NDK sysroot supplies the **configured
  bionic + libc++ for API 30**.
- **AOSP 11 source headers** (`~/android-mine/aosp/`), cloned (network works):
  `lin_frameworks_native`, `lin_system_core`, `lin_bionic`, `lin_external_libcxx`,
  `lin_system_libhwbinder` (LineageOS `lineage-18.1`); `aosp_system_libbase`,
  `aosp_system_logging` (`android-security-11.0.0_r71`); `aosp_external_selinux`,
  `aosp_system_libvintf` (`android-11.0.0_r9`).
- **aidl** from build-tools r30 (`~/android-mine/bt30/aidl`) generates the libbinder
  AIDL C++ headers (BnServiceCallback, IServiceManager, BnClientCallback, ...).

## Two toolchain facts (each cost an iteration)
1. **GCC cannot compile the bionic headers.** `bionic/libc/include/string.h` uses
   `__prefer_this_overload` = `__enable_if(...)` (Clang attribute) →
   "attributes are not allowed on a function-definition" under `arm-none-eabi-g++`.
   → **the A11 build MUST use Clang.**
2. **Raw bionic+libc++ repos do not integrate standalone.** With the cloned repos,
   `libcxx/include/cmath: using ::signbit;` fails ("no member named 'signbit' in the
   global namespace") because bionic declares `signbit` as a *macro*, not a function.
   → **the NDK's configured sysroot is required** (it resolved this; all sources then
   compiled). Using `-Ilin_bionic/libc/include` over the NDK sysroot re-breaks it — do
   NOT add the raw bionic include when using the NDK sysroot.

## Still ahead (the QNX link, then servicemanager/userland)
The compile uses the NDK's Linux/Android sysroot; the **link must produce a QNX ELF**
(interp `/usr/lib/ldqnx.so.2`) against the **WS1 shim**. Needs:
- a **QNX-targeted libc++/libc++abi/libunwind** (or the RIM `libcpp-ne.so` route), and
- the **QNX link recipe** (`nto.link` + `libcS` + QNX `crt*.o` — session57), or the
  arm-none-eabi + shim route the binder already uses.

Then: build `servicemanager` + the remaining A11 userland, and the runtime swap.

## Answers recorded (user questions)
- **Version file**: `native/system/build.cfg` (=`build.prop`): `ro.build.version.sdk=18`,
  `release=4.3`, `codename=REL`. Update it **only when the surface is actually present**
  ("TRUE upgrade" rule, session25). For the A11 port it ships as part of the A11 `system/`
  (sdk=30/release=11); for any interim graft, strings first, then climb `sdk` one step
  per green smoke test.
- **Manifest parsing**: the 4.3 `PackageParser` (QNX installer `Apk2Bar.getAndroidManifest`)
  is what failed on API-30 APKs. It is fixed by deploying the **A11 framework** (A11
  `PackageParser` handles modern manifests) — a WS8 item, not a separate patch.

## Files
- `runtime/a11-build/build.sh` (new) — reproducible A11 native compile.
- `runtime/README.md` — updated with the UPDATE(session68) section.
- Commit `282d219`.

## Addendum — full A11 native STACK links (Android/NDK flavor)
The complete native IPC stack now compiles **and links**:
    libbase.so (371 KB), liblog.so (260 KB), libcutils.so (130 KB),
    libutils.so (333 KB), **libbinder.so (2.4 MB)**
built by `runtime/a11-build/build.sh` (compile + link). This validates the full A11
source set + build env. The remaining step is the **QNX flavor** (relink against the
WS1 shim with the QNX link recipe) — that is what makes them run on the Classic.
