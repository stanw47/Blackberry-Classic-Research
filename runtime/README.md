# COMPAT runtime layer — assembled parts (A11-on-QNX)

This directory is the **assembly of the port parts we have built**, structured the way
they would be deployed into the Android runtime container
(`/apps/sys.android.<ns>/native/`). It is NOT yet a complete runtime — see "Missing".

Goal (repo README / sessions 31-32): build **our own Android 11 runtime on QNX** —
graft/rewrite the entire runtime, keeping the QNX microkernel, reproducing RIM's porting
layer from AOSP 11. The 4.3 runtime is the specimen. NOT per-app APK transform.

## Present (built + (mostly) device-tested)

| Path | Bytes | Workstream | State |
|---|---|---|---|
| `native/system/lib/libc.so` | 304344 | WS1 (A11 bionic-on-QNX shim) | **runs on-device** (RC=0); 1759 exports, 0 TEXTREL, PIC |
| `native/system/lib/libm.so` | 1500 | WS1 stub | resolves A11 NEEDED libm.so |
| `native/system/lib/libdl.so` | 1508 | WS1 stub | resolves A11 NEEDED libdl.so |
| `native/system/lib/libgralloc_qnx.so` | 30808 | WS3 (graphics/gralloc) | built, **not device-tested** |
| `native/system/bin/binder` | 15516 | WS2 (A11 binder resmgr) | runs; `resmgr_attach` → **EPERM** (identity, see blockers) |
| `native/system/bin/test_prop` | 3120 | WS1 glue test | **RC=0** on-device |
| `native/system/bin/test_malloc` | 3820 | WS1 glue test | **RC=0** on-device |

WS1 shim glue implemented (sessions 58-61): futex/`__futex_wait`/`__futex_wake`,
`__get_h_errno`, `android_set_abort_message`, the full `__system_property_*` ABI,
TLS (`__get_tls`/`__get_thread`/`__pthread_gettid`), malloc family (dlmalloc* → QNX
malloc; `malloc_usable_size`→`_msize`; `brk`/`sbrk`).

## Missing (the long pole) — A11 userland, blocked on the AOSP header tree

The A11 runtime needs these rebuilt as QNX ELFs (the port), but NONE can be built yet:

- **A11 native libs**: `libbinder.so`, `libutils.so`, `libbase.so`, `libcutils.so`,
  `libui.so`, `liblog.so`, `libandroid_runtime.so`, `libEGL.so`/`libGLESv2.so`, HALs.
- **A11 binaries**: `servicemanager`, `app_process`/`zygote`, `surfaceflinger`,
  `installd`, `keystore`, `bootanimation`, `dex2oat`/ART.
- **ART**: `libart.so`, `libartbase.so`, `libdexfile*.so` (source ref in
  `ref/a11_core/apex/com.android.art.release/lib/`).
- **Framework**: A11 `framework.jar`/`services.jar` + their `.odex` (A11 uses ART/OAT).

**Why blocked:** building these from AOSP source requires the AOSP **header tree**
(`frameworks/native/include`, `system/core/include`, `system/logging`, `libbase`,
`selinux`, `vintf`, `android-base/*`) which is NOT staged. Confirmed: servicemanager
`#include`s `android-base/logging.h`, `cutils/*`, `selinux/*`, `utils/Looper.h`,
`vintf/*` — none present. The A11 *binaries* in `ref/a11_core/` are Linux/ELF and cannot
exec on QNX (no Linux ABI); they must be rebuilt.

## Known blockers (evidence)

1. **binder `resmgr_attach` → EPERM** — our binder runs as devuser (uid 100) and the QNX
   path manager refuses the registration (`ldqnx.so.2@pathmgr_link` → `_connect` → EPERM).
   RIM's binder attaches because it runs **inside the container** as uid 1000
   (`android_system`). Fix path = deploy into the container + start via
   `native/scripts/start-android-core.sh` (the GATE C live-swap), NOT from /tmp.
2. **Root exec of our PIE → "Operation not permitted"** — the QNX loader's exec gate
   refuses our ELF for a root (`__root`) process (devuser exec works). Separate from (1).
3. **AOSP header tree missing** — blocks every A11 native/binary build (see Missing).

## Deploy / test

```
# stage (root, on device):
R:mkdir -p /tmp/rt && cp -r runtime/* /tmp/rt/   # (root-owned)
# run WS1 tests (devuser):
cd /tmp/rt/native/system/bin && LD_LIBRARY_PATH=/tmp/rt/native/system/lib ./test_prop
# run binder (devuser) — expect EPERM until container-deployed:
LD_LIBRARY_PATH=/tmp/rt/native/system/lib ./binder /dev/binder
```

## Next

1. Stage the AOSP 11 header tree so the A11 natives can be built against the WS1 shim.
2. WS2-in-container: deploy `binder` into the container + start via the core script
   (requires the runtime-swap harness; disruptive — back up RIM's binder first).
3. WS3: device-test libgralloc_qnx against QNX screen.
4. Then ART/zygote/framework, then autoloader repackage/re-sign.

---

## UPDATE (session68) — A11 native build environment ESTABLISHED (B3 unblocked)

The `Missing` build gap is now solved at the **compile** level. Reproducible via
`runtime/a11-build/build.sh`. Result (host, this session):

    libbase:   16 compiled   liblog: 11   libcutils: 29   libutils: 24   libbinder: 36/36
    (only non-target files excluded: *_windows.cpp, *_benchmark.cpp, *_test.cpp,
     format.h/fmt, vndksupport/misc.cpp, logd/pmsg writers, trace-container)

**Toolchain (must be this, not GCC):**
- **Android NDK r23c** clang: `~/android-mine/ndk/android-ndk-r23c/.../bin/armv7a-linux-androideabi30-clang++`
  (the NDK sysroot supplies the configured bionic + libc++ for API 30).
- **AOSP 11 source headers** staged at `~/android-mine/aosp/` (Lineage 18.1 clones:
  `lin_frameworks_native`, `lin_system_core`, `lin_bionic`, `lin_external_libcxx`,
  `lin_system_libhwbinder` + A11 tags `aosp_system_libbase`, `aosp_system_logging`,
  `aosp_external_selinux`, `aosp_system_libvintf`).
- **build-tools r30 `aidl`** (`~/android-mine/bt30/aidl`) generates the libbinder AIDL
  C++ headers.

**Two toolchain facts pinned:**
1. GCC rejects the bionic headers (`string.h` uses Clang `__enable_if`) → **Clang required**.
2. Raw bionic+libc++ repos don't stand alone (`cmath`↔bionic `signbit` macro mismatch) →
   the **NDK-configured sysroot** is required (this is what fixed it).

## UPDATE (session70) — WS1 resolver `ip=0` FIXED; (session71) A11 chain LOADS

The WS1 shim resolver bug is fixed and validated: see
`notes/session70-ws1-resolver-ip0-fix.md`. `tb_cxx` (libc++ static init) now
returns RC=0. Then `notes/session71-a11-chain-loads-libutils-crash.md`.

**Built + QNX-linked (session69-71):** `libc++.so`, `libbase.so`, `liblog.so`,
`libcutils.so`, `libutils.so`, `libbinder.so` under `/tmp/a11obj/qnx`
(`runtime/a11-build/qnx-link.sh`). Probes: `runtime/a11-build/test/{tb_shim,tb_cxx,tb_a11}`.

**Loads on-device:** `tb_a11` now reports **`UBS`** — `libutils` (base chain),
`libbinder`, and `ProcessState::self` all load and initialize. So Android 11's
core native IPC stack runs its C++ constructors on QNX (`RC=0`). Two fixes made
this possible: (1) the shim no longer blocks every signal (it used to call
`sigprocmask(SIG_SETMASK, sigfillset())`), and (2) the `libutils` atrace
sysprop-callback path is no-op'd (workaround; see the session71 note for the
remaining root cause — a bogus `gSyspropList`). `servicemanager` now compiles;
remaining blockers are `timerfd_create` (Linux-ism), `selinux_*`, and a QNX
`_start`/crt.

Build fix: `libutils/misc.cpp` must be compiled (it defines
`add_sysprop_change_callback`); build.sh now uses `-D__ANDROID_RECOVERY__` so its
vndksupport branch is dropped and only excludes `aosp_system_libbase/misc.cpp`.

**Still to do for the QNX port (next):** the compile uses the NDK's Linux/Android sysroot;
the **link** must produce a **QNX ELF** (interp `ldqnx.so.2`) against the WS1 shim, which
needs (a) a **QNX-targeted libc++/libc++abi/libunwind** (or RIM's `libcpp-ne.so` route) and
(b) the QNX link recipe (`nto.link`/`libcS`/QNX crt — session57). Then servicemanager +
the rest of the A11 userland. Manifest parsing is fixed here too: the A11 framework
(`PackageParser`) handles modern manifests; the 4.3 parser is what choked.
