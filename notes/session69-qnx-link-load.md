# session69 — A11 native stack: QNX-flavor link + the QNX loader LOADS it

Date 2026-09-20. Continues session68. Goal: build our own A11 runtime on QNX.

## Milestone
The A11 native stack (libbase/liblog/libcutils/libutils/**libbinder**) now:
1. **compiles** (session68, NDK clang) — and
2. **links as QNX ELFs** (`runtime/a11-build/qnx-link.sh`) — and
3. the **QNX loader accepts + loads the full chain** on-device (no format reject, no
   "cannot load library"); it resolves the whole NEEDED graph and all symbols, then
   executes. It now reaches a **NULL call at init (`ip=00000000`)** — a concrete debug
   target, a big step past the earlier `ref=0`/format reject.

## The fix chain (each = one on-device iteration)
1. **QNX link tool**: `arm-none-eabi-ld -shared` (not the NDK driver) so the output is a
   QNX-flavored DYN. Add the NDK `crtbegin_so.o`/`crtend_so.o` (supply `__dso_handle`).
2. **libc++ as a shared lib**: fold the NDK's `libc++_static.a` + `libc++abi.a` +
   `libunwind.a` into `libc++.so` (`--whole-archive`), so the others NEED it.
3. **NEEDED ORDER IS LOAD-BEARING (session57 rule)**: `libc.so.3` (the **real QNX libc**)
   **FIRST**, the WS1 shim `libc.so` **SECOND**. With only the shim, the loader bound its
   own needs to the shim → SIGSEGV at init (`mapaddr=0x217fc ref=0`). With libc.so.3 first,
   that crash is gone.
4. **`__aeabi_mem*` ABI helpers**: the shim exports 103 `__aeabi_*` but NOT
   `__aeabi_memcpy` → the loader reported `Unresolved symbol "__aeabi_memcpy" called from
   libc++.so`. Fixed with `aeabi_stubs.c` (memcpy/memmove/memset/memclr[4/8] → QNX).
5. **AIDL-generated `.cpp`** (`android/os/{IServiceManager,IServiceCallback,IClientCallback}`)
   must be compiled INTO libbinder — else the loader reports
   `_ZNK7android2os15IClientCallback22getInterfaceDescriptorEv` /
   `...IServiceManager10descriptorE` unresolved.
6. After (1)-(5): loader resolves all symbols and runs the probe.

## Reproduce
```
sh runtime/a11-build/build.sh      # NDK clang compile (+ AIDL .cpp into libbinder)
sh runtime/a11-build/qnx-link.sh   # QNX-flavor link -> /tmp/a11obj/qnx/*.so
# deploy /tmp/a11obj/qnx/*.so + ws1/build/libc.so to /tmp/a11 (apps:apps 555),
# a probe NEEDing libc.so.3+libc.so -> loader loads the chain.
```

## Remaining (next debug target)
- **NULL call at init (`ip=0`)** after load — a function-pointer that is NULL during
  static init in libc++.so or libbinder.so. Candidates: a weak/virtual stub, an atexit/
  dso-handle path, or a locale-dependent libc++ static. Bisect by loading libs one at a
  time (libbase first) and by checking libc++'s `__cxa_*`/`__dso_handle` wiring vs the shim.
- Then servicemanager + the rest of the A11 userland; container swap (GATE C); autoloader.

## Files
- `runtime/a11-build/build.sh`  (compile; now includes AIDL .cpp)
- `runtime/a11-build/qnx-link.sh` (QNX-flavor link; libc.so.3-first, aeabi stubs)

## Bisect (device) — the NULL-init call is in libc++.so
- probe NEEDing libbinder (+chain) → `ip=0`
- probe NEEDing libbase only       → `ip=0`
- probe NEEDing libc++ only         → `ip=0`
=> the NULL function call is during **libc++.so's own static init** (its constructors run
   at load, before the app). Next: inspect libc++.so's `.init_array`/`__cxa_*`/`__dso_handle`
   wiring vs the shim (a libc++ static that calls a weak/null symbol — candidate: the
   `__cxa_atexit`/`__dso_handle` path, or a locale/iostream static). Bisect further by
   linking libc++ with `-nostdlib++`-style minimal set, or by stubbing ctor-heavy members.

## PLT / lazy-binding finding (the current wall)
The A11 libs are C++ and call their own symbols through the GNU PLT
(`_GLOBAL__sub_I_iostream.cpp` -> `ios_base::Init::Init@plt`). Two loader modes both
fall short:
- **lazy (default)**: the loader resolves normal symbols fine, but the PLT slot for the
  internal call is 0 at first use -> `ip=0` (NULL call) during static init.
- **`-z now` (eager)**: the loader eagerly resolves ALL slots and then fails on
  optional/lazy symbols the C++ runtime legitimately leaves unresolved at load:
  `__emutls_get_address` (libgcc emulated TLS) and `dl_unwind_find_exidx` (libdl/linker).
  Also `-Bsymbolic` breaks cross-lib resolution (do not use).

So the blocker is now precise: **the QNX loader's relocation/PLT handling for a
GNU-`armelf`-linked C++ shared object** (lazy PLT not set up / eager too strict). This is
the session57-class loader mismatch, now on the shared-object side.
Next options: (a) supply `__emutls_get_address` + `dl_unwind_find_exidx` (link libgcc +
a libdl stub) AND keep `-z now`; (b) produce a QNX-shaped `.so` with the QNX link recipe
(`-m armnto`/`nto.link`, session57) so the loader's PLT protocol matches; (c) avoid the
internal PLT with `--no-plt`/`-fno-plt` at compile (direct GOT calls).

## (a) attempted: `-z now` + provide `__emutls_get_address`/`dl_unwind_find_exidx`
Result: loader resolves all symbols (no "unknown symbol") but the process STILL faults at
`ip=0`. So the NULL is the **loader's PLT slot handling for our GNU-linked C++ `.so`**
(the internal `...@plt` call slot is left 0), not a missing symbol. This is the precise,
pinned wall for the next session.

## Summary of session69
- A11 native stack COMPILES (session68) and LINKS QNX-flavor (qnx-link.sh).
- The QNX loader ACCEPTS + LOADS the whole chain (NEDED order libc.so.3-first, aeabi
  stubs, AIDL cpp, crt objects). This is a large jump from "cannot build the A11 userland".
- Remaining wall: the loader's PLT/lazy-vs-eager relocation handling for a GNU `armelf`
  C++ shared object. Options for next: (b) QNX-shaped `.so` via the `-m armnto`/`nto.link`
  recipe (session57) so the loader's PLT protocol matches; (c) `-fno-plt` compile of
  libc++ (recompile from source) to remove internal PLT use; (d) patch the `.got.plt`
  resolver/PLT0 to the loader's expected shape. Also investigate why each output `.so`
  carries a self-NEEDED (`[libc++.so]` in libc++.so) — likely the crt/whole-archive.

## CORRECTION + final state
- The PLT is NOT malformed — `bx pc` + the ARM PLT0 sequence is the normal
  ARM/Thumb-interworking stub (objdump mis-decoded it as Thumb). So the fault is a genuine
  NULL call: the single `.init_array` ctor `_GLOBAL__sub_I_iostream.cpp` runs
  `std::__ndk1::ios_base::Init::Init()` (a libc++-internal call) and reaches `ip=0`.
- The shim exports `__cxa_atexit`/`__cxa_finalize`/`__cxa_thread_atexit`, so those are not
  it. Next target = disassemble `ios_base::Init::Init` in libc++.so and the symbols it
  calls (a weak/null hook during iostream init), or build a minimal libc++ (no iostream/
  locale statics) to confirm the fault class.
- **Proven this session (device):** a QNX ELF probe linking ONLY `libc.so.3` + the WS1
  shim runs `RC=0` (prints via the shim), AND the full A11 native chain
  (libbase/liblog/libcutils/libutils/libbinder + libc++) is loaded by the QNX loader with
  all NEEDED + symbols resolved. The remaining fault is isolated to libc++'s static init.
