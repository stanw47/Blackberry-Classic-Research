# session67 — Runtime assembly: parts staged, WS1 green, blockers isolated

Date 2026-09-20. Classic (10.3.3.3216), live via SSH. Continues the A11-on-QNX port
(goal locked in sessions 31/32: build OUR OWN Android 11 runtime on QNX; the 4.3 runtime
is the specimen; NOT per-app APK transform).

## What I did

1. **Searched the whole repo** and read the notes/READMEs. Confirmed the runtime is
   fully mapped: `specimens/runtime_inventory/and_full_ls.txt` (1081 files, complete
   installed 4.3 runtime), `notes/ANDROID-RUNTIME-COMPLETE-MAP.md` (per-component),
   `notes/session26/27/38e` (map + QNX bridge binaries + IFS decode).
2. **Assembled the port parts** we have into `runtime/` (deploy-structured):
   `native/system/{lib,bin}` with the WS1 shim, WS1 stubs, WS3 gralloc, WS2 binder,
   WS1 tests. Manifest in `runtime/README.md`.
3. **Integration-tested on-device.**

## Results (device, this session)

| Part | Command | Result |
|---|---|---|
| WS1 shim `test_prop` | `LD_LIBRARY_PATH=/tmp/ws1ok ./test_prop` | `[SHIM] init / 1234 / hello / RC=0` |
| WS1 shim `test_malloc` | same | `MALLOC OK / RC=0` |
| WS1 shim `test_tls` | same | `TLS OK / RC=0` |
| WS2 binder (no args) | `./binder` | prints usage, RC=1 |
| WS2 binder `/dev/binder` | `./binder /dev/binder` | init OK, **`resmgr_attach` → EPERM**, RC=1 |
| WS2 binder as ROOT | `R:./binder /dev/binder` | **`Operation not permitted`** (loader exec gate) |

## Blockers isolated (each individually)

### B1 — binder `resmgr_attach` EPERM (identity, not a bug)
Our binder runs as **devuser (uid 100)** in the **base QNX namespace**; the path manager
refuses resmgr registration (`ldqnx.so.2@pathmgr_link` → `_connect` → EPERM). RIM's binder
attaches because it runs **inside the container** as uid 1000 (`android_system`).
- Confirmed via session63-65 disasm + this session's reproduction.
- Fix path = **GATE C live-swap**: deploy `binder` into the container's `native/system/bin`
  and start it via `native/scripts/start-android-core.sh` (the player context), NOT /tmp.
- Note: RIM's binder cannot be run standalone as devuser either — it needs the container
  libs (`libcutils.so` etc.) and the player namespace (`ldd:FATAL: Could not load library
  libcutils.so` from the base namespace).

### B2 — root exec of our PIE "Operation not permitted" (loader gate)
`__root` cannot exec our binder PIE (`Operation not permitted`), while devuser can. This is
the QNX loader's **exec gate for privileged processes** (ELF trust markers), distinct from
B1. Stock dexopt execs as root; our GNU-linked PIE does not. Needs the QNX `nto.link`/
`libcS`/QNX-crt link recipe (session57) or the exec-shape that stock binaries use.

### B3 — A11 userland cannot be built (AOSP header tree missing)
The A11 natives/binaries (`libbinder`, `libutils`, `libbase`, `libcutils`, `servicemanager`,
`surfaceflinger`, `app_process`, ART `libart*`, framework jars) must be **rebuilt as QNX
ELFs** — the A11 binaries in `ref/a11_core/` are Linux/ELF and cannot exec on QNX.
Their build is blocked because the AOSP **header tree** is not staged. Verified:
servicemanager `#include`s `android-base/logging.h`, `cutils/*`, `selinux/*`,
`utils/Looper.h`, `vintf/*` — none present on disk. `find` for `RefBase.h`, `String16.h`,
`Errors.h`, `Log.h`, `Threads.h` → 0 hits.

## Assessment / honest status

- The **foundation works** (WS1 shim runs; glue for futex/props/TLS/malloc live).
- The **IPC core is written and runs** (WS2 binder), but cannot attach outside the
  container (B1) and cannot exec as root (B2).
- The **entire A11 userland** (ART + framework + the native libs that make a runtime) is
  **not yet buildable** (B3) — this is the long pole to a working runtime.
- Therefore the "true test" (a stock API-30 app installing/running untouched) is still
  gated on: B3 (build the A11 userland) + B2 (exec-shape) + B1 (container deployment).

## Next (ordered)

1. **Stage the AOSP 11 header tree** (`frameworks/native/include`, `system/core/include`,
   `system/logging`, `libbase`, `selinux`, `vintf`, `android-base/*`) — unblocks every A11
   native build. Options: clone the AOSP/Lineage source for the needed dirs, or reconstruct
   the minimal subset like `binder/qnxinc` did for the QNX headers.
2. **B2 exec-shape**: reproduce the stock QNX ELF link shape (session57 recipe) so our
   binaries exec as root too.
3. **GATE C**: runtime-swap harness (back up RIM's `native/system`, stage ours, start via
   the container scripts, A/B, revert).
4. Then ART/zygote/framework, then autoloader repackage/re-sign (the end goal).

## Addendum — B3 header staging + build-toolchain finding

Staged the A11 source tree (network works) into `~/android-mine/aosp/`:
`lin_frameworks_native`, `lin_system_core`, `lin_system_libhwbinder`,
`lin_external_libcxx`, `lin_bionic` (LineageOS `lineage-18.1`),
`aosp_external_selinux`, `aosp_system_libvintf` (`android-11.0.0_r9`),
`aosp_system_libbase`/`aosp_system_logging` (`android-security-11.0.0_r71`).

Header resolution (iterated): `binder/*`, `utils/*`, `cutils/*`, `system/*`,
`log/*`, `android-base/*`, `selinux/*`, `vintf/*`, `nativebase/*`, plus bionic
`libc/include` + `libc/kernel/uapi{,/asm-arm,/asm-generic,/android/uapi}`.

Two build-toolchain findings:
1. **GCC rejects the bionic headers** — `bionic/libc/include/string.h` uses
   `__prefer_this_overload` = `__enable_if(...)` (a Clang attribute) →
   "attributes are not allowed on a function-definition" under `arm-none-eabi-g++`.
   **The A11 native build must use Clang.** Host `clang` 19 targets
   `--target=armv7a-linux-androideabi30` and accepts the bionic headers cleanly.
2. **bionic↔libc++ integration needs a configured sysroot** — after adding libc++
   headers, `libcxx/include/cmath` fails: `no member named 'signbit' in the global
   namespace`. The raw repo headers need the NDK-style config (`__config_site`,
   cleaned kernel headers). Canonical fix = use an **NDK sysroot**.

So WS1b/WS2 build environment = **Clang + (NDK-configured) bionic/libc++ sysroot +
the WS1 shim (link target)**. This is the concrete next unblock for B3.

## Addendum — autoloader repackage/re-sign path (the end goal)

Tooling already in-repo:
- `tools/make_autoloader.py` — assembles the PE32 autoloader exe from `cap.exe`
  + the OS/radio QCFM containers (`SIG = 9c d5 c5 97 ×3`, pfcq/QCFM headers).
- `tools/check_autoloader.py` — validates the result.
- `docs/AUTOLOADER_GUIDE.md` — end-to-end (extract streams → swap the user/OS image →
  assemble → validate → flash).
- `work/classic_root.{0,1}.*` — the extracted Classic OS/radio streams we already
  built/flashed before; `work/os_capseal.signed` = the 560-byte install seal
  (the thing SBL validates; cap.exe embeds it).

Runtime lives in the **UFS (user image)**: `/apps/sys.android.<ns>/native/`. So the
repackage = (a) replace `native/{system,sbin,scripts}` with our A11 layer,
(b) rebuild the UFS/QCFM, (c) assemble the exe with `make_autoloader.py`,
(d) apply the seal + `check_autoloader.py`, (e) flash (recoverable; backup bootchain).

## Session status

- `runtime/` assembled (parts + manifest): WS1 shim + WS1 stubs + WS3 gralloc +
  WS2 binder + WS1 tests.
- WS1 shim: device-verified RC=0. Binder: runs, EPERM (B1) outside the container.
- B3 (A11 userland build): source tree staged; toolchain identified (Clang); needs an
  NDK-configured sysroot to complete the header integration.
- End goal (autoloader) tooling confirmed present and documented.
