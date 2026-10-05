# session71 — A11 native chain now BUILDS, QNX-LINKS and LOADS; next wall = a static-init crash in libutils

Date 2026-09-20. Classic (10.3.3.3216). Continues session70 (WS1 `ip=0` fix validated).
Goal unchanged: our own Android 11 runtime on QNX (graft/rewrite, not APK transform).

## What works now

- The full A11 native stack compiles and QNX-links against the fixed shim
  (`runtime/a11-build/qnx-link.sh`): `libc++.so`, `libbase.so`, `liblog.so`,
  `libcutils.so`, `libutils.so`, `libbinder.so` — each with `NEEDED` order
  `... libc++.so libc.so.3 libc.so`.
- A new probe `runtime/a11-build/test/tb_a11.c` `dlopen`s the chain on-device.
  **`libbinder.so` (+deps) now loads** — the QNX loader resolves the whole graph
  and starts running C++ static initializers.

## Build fix this session

`libutils/misc.cpp` (defines `android::add_sysprop_change_callback`, needed by
libbinder) had been blanket-excluded by build.sh's `/misc\.cpp` pattern. It only
needs `vndksupport/linker.h` in the `__ANDROID__ && !__ANDROID_RECOVERY__` branch,
so building with **`-D__ANDROID_RECOVERY__`** drops that branch and the file
compiles cleanly. `build.sh` updated (exclude only `aosp_system_libbase/misc.cpp`;
add the recovery define). Effect: the first on-device error went from

    unknown symbol: _ZN7android27add_sysprop_change_callbackEPFvvEi
    ldd:FATAL: Unresolved symbol ... called from libutils.so

to a clean load.

## Current wall — SIGSEGV during `libutils.so` static init

`tb_a11` isolated it: loading **`libutils.so` alone** faults before `dlopen`
returns:

    [SHIM] init
    Process ... (tb_a11) terminated SIGSEGV code=1 fltno=11
      ip=<libutils.so>@_ZNK7android10VectorImpl4sizeEv+0xc  mapaddr=00014ba4
      ref=311a0009

`VectorImpl::size()` executes `ldr r0, [r0, #8]`; `this` (r0) is bogus
(`0x311a0009`; the libbinder run gave `0x211a0009` — same low bits). libutils has
exactly **one** `.init_array` entry: `_GLOBAL__sub_I_String16.cpp` ->
`__cxx_global_var_init` @0x140c8, which is just
`__cxa_atexit(&StaticString16<1>::~StaticString16, &emptyString, &__dso_handle)`.
So the crash is *not* obviously in that init body — it looks like a call/jump into
`size()` from elsewhere during load (possibly a mis-resolved pointer/PLT target).

## Facts gathered (for the next session)

- A11 libs are **ARM** mode (`push {fp,lr}` = e92d4800; ARM PLT `ldr pc,[ip,#imm]`).
  The WS1 shim is **Thumb** (`write: movw ip,#667; b.w ws1_resolver`). Interworking
  otherwise works (tb_cxx/tb_shim call shim symbols), and `ldr pc` interworks on ARMv7.
- `__cxa_atexit` is exported by **the shim** (trampoline), NOT by libc++/libutils/
  libbase. `resolver_tab.c` slot 25 = `"__cxa_atexit", WS1_ALIAS`; `tramps.S`
  `__cxa_atexit:` = `movw r12,#25` — **tables are consistent** (not a table desync).
  `__cxa_atexit` IS in `ref/gate_b/qnx_libc_exports.txt` (so dlsym(libc.so.3) should
  provide it). libc++.so references `__cxa_atexit`/`__cxa_finalize` as UND.
- `ref/gate_b/qnx_libc_exports.txt` is a name list only; the device `libc.so.3` is
  stripped (no section headers) so `nm -D`/`readelf --dyn-syms` show 0 symbols —
  only the runtime loader can resolve it.
- `libc.so.3` symbols are invisible to the *linker*, so executables must be linked
  with `--unresolved-symbols=ignore-all` and let the QNX loader bind at run time
  (added to `build-tb.sh`). This is required for any A11 executable.
- No QNX core dump is produced (`/var/dumps` absent); no `dumper`/`coreinfo` on the
  device. Getting a backtrace needs a different channel (e.g. run under a host
  gdbserver, or add staged `write()` markers around suspect inits).

## Hypotheses for the next session (ordered)

1. **Mis-resolved call target.** Instrument: wrap the shim ctor diagnostic
   (`WS1MISS`, currently re-enabled but gated to non-ctor calls) and/or add `write()`
   breadcrumbs. Confirm whether any shim trampoline slot holds the wrong address.
2. **Init order / cross-DSO.** libutils has a single init, but its *deplibs*
   (libcutils/libbase/libc++) also init; if QNX runs a dependent's init before a
   dep's, a global `android::Vector` could be used unconstructed. Try
   `-Wl,-z,initfirst` / reordering, or statically linking the base chain into the
   probe to remove DSO init-order.
3. **ARM/Thumb function pointer.** If a stored function pointer (e.g. from a weak
   symbol or `GOT`) lacks the correct state bit, an indirect call lands mid-function
   (into `size()`), matching the observed `ip@size+0xc`. Check `-mthumb` vs ARM
   mixing and whether the shim's exported Thumb addresses are resolved with bit 0 set.
4. **A11 libs rebuilt with `-mthumb`** to match the shim (removes any interworking
   surface at once) — recompile via build.sh with `-mthumb`.

## UPDATE — crash localized (SIGSEGV handler + QNX ucontext)

Root cause of "can't debug": the WS1 shim's `signal_block.c` ctor called
`sigprocmask(SIG_SETMASK, sigfillset())` — it **blocked every signal**
process-wide (a leftover EINTR hack from session41). Faults then can't be
delivered, so no handler runs and the kernel just kills the process. **Fixed
(shim no longer blocks signals).** This is a genuine runtime bug on its own —
a real Android userland needs signals.

With signals deliverable, `tb_a11` now installs a `SA_SIGINFO` SIGSEGV handler
using the real QNX layouts (`/opt/qnx650/.../arm/context.h`,
`sys/target_nto.h`, `sys/siginfo.h`, `ucontext.h`) and dumps registers +
`dladdr`-symbolized `pc`/`lr`. Result:

    pc  libutils  _ZNK7android10VectorImpl4sizeEv +0x5
    lr  libutils  _ZNK7android6VectorINS_28sysprop_change_callback_infoEE4sizeEv +0xe
    return chain (libutils base 0x119b9000):
      0x21d69 = android::add_sysprop_change_callback(void(*)(),int) +0x69
      0x1fd61 = (static) traceInit() +0x11       <- Trace.cpp constructor
    gSyspropList (bss 0x3690c) held 0x711c0001 (garbage; r0=0x711c0001)

So: `libutils/Trace.cpp`'s `__attribute__((constructor)) traceInit()` calls
`add_sysprop_change_callback(atrace_update_tags, 0)`, which does
`gSyspropList = new Vector<sysprop_change_callback_info>()` then
`gSyspropList->size()` — and `gSyspropList` is bad. Disasm of
`add_sysprop_change_callback` (Thumb, 0x21d00):

    blx pthread_mutex_lock@plt              ; &gSyspropMutex (bss 0x36908, 4 bytes
    ldr r0,[...gSyspropList]; cbnz -> loop  ; before gSyspropList @0x3690c!)
    movs r0,#20; blx _Znwj@plt              ; operator new(20)
    blx Vector<...>::Vector()               ; construct
    ... str -> gSyspropList
    loop: ldr r0,[gSyspropList]; blx Vector<...>::size@plt   <- fault

Note `gSyspropMutex` and `gSyspropList` are adjacent in bss (4 bytes apart) —
a mutex implementation that writes more than 4 bytes would clobber the list
pointer. Next steps: (a) confirm `operator new`/`malloc` returns valid memory in
this DSO (tb_cxx proves it can), (b) check the shim's `pthread_mutex_lock`
binding (futex glue vs libc.so.3) and the PC-relative `gSyspropList` load,
(c) consider whether `Trace.cpp`'s ctor should even run in the port.

Confirmed this session: with the signal fix, `tb_shim`/`tb_cxx` still RC=0 (no
regression). `operator new` (`_Znwj`) is exported only by `libc++.so` (weak) and
the shim does NOT define any `_Zn*`/`_Zd*` (good); `malloc`/`pthread_mutex_lock`
bind to `libc.so.3` (ALIAS slots). All crashes share a bogus pointer shaped like
`0x?1c0009` (leading nibble varies 2/3/5/7) — worth checking whether a
relocation/GOTOFF for a local (the `gSyspropList` PC-relative load) or a
`pthread_mutex_t` (4-byte bionic vs QNX) is at fault.

## MILESTONE — the entire A11 native chain loads + initializes on QNX

Root cause of the libutils fault is the atrace sysprop-callback bookkeeping:
`libutils/Trace.cpp`'s `@constructor traceInit()` -> `add_sysprop_change_callback()`
-> `gSyspropList->size()` with a bogus `gSyspropList` (odd pointer like
`0x211c0001`; not a heap address, so not from `operator new` — looks like a
GOTOFF/PC-relative or struct-layout issue for that function).  No-op'ing just
`add_sysprop_change_callback` (port edit in
`~/android-mine/aosp/lin_system_core/libutils/misc.cpp`) made the whole chain
load:

    tb_a11 -> "UBS"
      U = dlopen("libutils.so")  OK  (libcutils+liblog+libbase+libc+++shim init)
      B = dlopen("libbinder.so") OK  (full dep graph + all static initializers)
      S = dlsym(libbinder,"android::ProcessState::self") found
    RC=0

So Android 11's core native IPC stack (`libbinder` + its whole dependency set)
now **loads and runs its C++ constructors on the QNX device**.  (The atrace
no-op is a workaround; the root cause of the bad `gSyspropList` still needs the
GOTOFF/layout check — likely the same class of issue will recur, so worth fixing
properly rather than stubbing.)

## servicemanager (first A11 executable) — build status

Built from `lin_frameworks_native/cmds/servicemanager`:
- `main.cpp`, `Access.cpp`, `ServiceManager.cpp` compile with
  `-D__ANDROID_RECOVERY__`.  `ServiceManager.cpp` needs `<vintf/VintfObject.h>`
  (-> `<hidl/metadata.h>`, unstaged) OR `-DVENDORSERVICEMANAGER` (which compiles
  and drops the vintf path).  `libbase/format.h` -> `fmt/*` : cloned
  `external/fmtlib` (7.1.3) into `~/android-mine/aosp/external_fmtlib`.
- Linked `servicemanager.elf` (PIE) against the A11 stack + shim: OK, 162 UND.
  Notable unresolved: `timerfd_create` (Linux-ism; main.cpp's
  `ClientCallbackCallback` uses timerfd), `selinux_*` (libselinux not built),
  plus shim glue (`__android_log_*` handled by the shim).
- Still needs a QNX `_start`/crt (main.cpp has `main(argc,argv)`; the probes use
  `ws1/start.S` `b main`) and the `binder` driver path in the container.

## Major ABI bug found + fixed: pthread mutex/cond sizes

- bionic `pthread_mutex_t`/`pthread_cond_t` = **4 bytes**
  (`sizeof(pthread_mutex_t)` == 4 for armv7a NDK).
- QNX `pthread_mutex_t` = `struct _sync { int __count; unsigned __owner; }` = **8
  bytes** (`sys/target_nto.h` / `sys/neutrino.h`); `PTHREAD_MUTEX_INITIALIZER` =
  `{_NTO_SYNC_NONRECURSIVE(0x80000000), _NTO_SYNC_INITIALIZER(0xffffffff)}`,
  cond `{_NTO_SYNC_COND(0xfffffffb), -1}`.
- The shim had `pthread_mutex_lock` as an **ALIAS to QNX's**, so every bionic
  4-byte mutex lock wrote 8 bytes -> clobbered the neighbouring object.  (This is
  what first corrupted `gSyspropList`: `gSyspropMutex` @0x36908 and
  `gSyspropList` @0x3690c are 4 bytes apart in bss.)
- **Fix (in `ws1/glue_impl.c`):** internal QNX sync objects are now the real
  8-byte `_sync`; the bionic 4-byte ABI is implemented in software over the
  existing futex emulation — new glue for `pthread_mutex_{lock,trylock,unlock,
  init,destroy}` and `pthread_cond_{wait,timedwait,signal,broadcast,init,
  destroy}`.  `ws1_lookup_glue` is consulted before the ALIAS dlsym, so these
  override the alias entries without regenerating the trampoline tables.
  This is a big correctness fix for the whole runtime (mutexes are everywhere).

**Remaining `gSyspropList` issue:** even with the mutex fix, calling the atrace
`add_sysprop_change_callback` still faults (`gSyspropList` becomes a bogus value
like `0x011c0001` before `->size()`; not from malloc — malloc never returns odd
addresses).  Current state keeps a documented **no-op workaround** for that one
function, which lets the whole chain load (`UBS`, RC=0).  Root cause still open:
likely the store into `gSyspropList` (GOTOFF) or a layout/ODR detail in that TU.

## Refined root-cause (instrumented)

Instrumented `add_sysprop_change_callback` (printed `&gSyspropList`/value):
- `&gSyspropList` is in mapped `.bss`, and its value at function entry is **0** —
  so BSS *is* zeroed and there is no mapping gap. The earlier bogus value is
  produced *inside* this function.
- With the **mutex ABI fix in place** the corruption is gone (previously the
  ALIAS-to-QNX `pthread_mutex_lock` wrote 8 bytes over the 4-byte bionic
  `gSyspropMutex`, overflowing into `gSyspropList` — hence the odd `0x?1c0001`).
  The remaining symptom is a **hang** in the `new Vector<...>` / insert path,
  not a crash — i.e. a separate, narrower issue now.

So two independent bugs were tangled together here: (1) the pthread ABI
mismatch (fixed in the shim glue), and (2) something in this function's
allocation path under QNX (still open). The milestone uses a **1-line no-op
workaround** in `lin_system_core/libutils/misc.cpp` (documented) so the A11
native stack loads; un-stubbing requires resolving (2).

Verified end state: `tb_a11` -> `UBS`, `RC=0` (with the shim mutex fix + the
misc.cpp workaround), no regressions in `tb_shim`/`tb_cxx`.

## Another ABI/linker finding: `bx pc` PLT veneers SIGILL on this device

Testing `operator new` from the probe: calling `_Znwj` that is **resolved at run
time** (UND in the exe, bound later from a `dlopen`ed libc++.so) raised **SIGILL
at tb_a11+0x24c**, which is a `bx pc` Thumb<->ARM PLT veneer:

    24c: 4778  bx pc        ; Thumb -> ARM switch veneer
    24e: e7fd  b.n 24c
    250: e28fc600 add ip,pc,#0   ; ARM PLT stub

`BX PC` (BX R15) is UNPREDICTABLE on ARMv7 (Krait/MSM8960 traps it -> SIGILL).
When `_Znwj` is instead resolved at **link time** (link the exe with
`-l:libc++.so`, so libc++.so is a NEEDED entry), the call works and returns a
valid heap pointer: `tb_a11` -> `UBS N=0x102d8770`, RC=0.

Implication: GNU-ld's ARM PLT/veneer for runtime-resolved Thumb calls is unsafe
here.  Mitigations to try: ensure A11 exes/libs carry their deps in the NEEDED
graph (no `dlopen`-only resolution for hot paths), or build ARM-only (no Thumb
veneer), or use a linker that emits Thumb PLTs / different veneers.
(`tb_a11` now links `-l:libc++.so`.)

## atrace final status (un-stubbed backtrace)

Un-stubbed `add_sysprop_change_callback` with SIGILL/SIGBUS/SIGSEGV handlers all
installed: it faults as a plain **SIGSEGV** in `Vector<sysprop_change_callback_
info>::size` -> `VectorImpl::size`, with `gSyspropList` = an odd bogus pointer
(e.g. `0x31220001`; the low bits drift between builds: `...1c0001`, `...220001`).
Entry value is 0 (bss zeroed), so the bad value appears in this function's own
store/loop.  Not the pthread ABI (fixed) and not `operator new` (verified
returning valid pointers).  Left behind the documented 1-line workaround in
`lin_system_core/libutils/misc.cpp` (atrace bookkeeping is optional).  Verified
end state: `tb_a11` -> `UBS N=0x10ef3770`, RC=0.

## MILESTONE 2 — an Android 11 executable RUNS on QNX

`runtime/a11-build/test/a11hello.cpp` (uses `android::String16`, links
libutils/libcutils/liblog/libbase/libc++/shim, entry = `binder/start.S` which
reads argc/argv from the initial stack):

    [SHIM] init
    A11-EXE-OK            <-- android::String16 constructed + size() == 9
    Process ... terminated SIGSEGV ... ip=/usr/lib/ldqnx.so.2@_Mtxlock+0x10
                                  ref=40beb0f0
    RC=139

So A11 C++ code executes correctly on QNX; the fault is *after* `main`, during
process exit/teardown in the loader's own `_Mtxlock` (ref 0x40beb0f0) — likely
the same "bad pointer reaching a lock" class as the atrace bug, and a separate
issue from running the code.

## atrace FIXED properly (not just stubbed)

Root cause was the `android::Vector` + `operator new` path in
`add_sysprop_change_callback`.  Rewrote it (and `do_report_sysprop_change`) to
use a plain fixed-capacity `sysprop_change_callback_info[64]` array — a valid
implementation of atrace callback registration.  Result: atrace is **un-stubbed**
and the chain still loads: `tb_a11` -> `UBS N=0x100de770`, RC=0.  (So there is a
real problem with `android::Vector` construction in this build somewhere, but it
no longer blocks; `operator new` itself is fine.)

## Exit-time fault (separate, open)

`a11hello` prints `A11-EXE-OK` (A11 C++ runs) then, at process exit, faults in
the loader's own `_Mtxlock`:

    Process ... terminated SIGSEGV ... ip=/usr/lib/ldqnx.so.2@_Mtxlock+0x10
                                  ref=40beb0f0   (fixed value every run)

`ref` is a constant `0x40beb0f0` (unmapped) — the loader tries to lock a mutex
there during teardown.  The probes (`tb_*`) avoid this because they call `_exit`
(no atexit/loader cleanup); `start.S` calls `exit`.  Likely the atexit/fini path
passing a bad pointer to a lock — same "bad pointer -> lock" family.  Needs one
more root-cause pass; not a blocker for running code.

## Rounding out the A11 stack (this turn)

- **Implemented the missing core libc glue** in `ws1/glue_core.c` that
  `glue_core_impl.txt` promised but never provided: `memrchr`, `stpcpy`,
  `stpncpy`, `readlinkat`, `__memchr_chk`, `__strchr_chk`, `__strrchr_chk`,
  `__mempcpy_chk`, `__stpcpy_chk`, `__stpncpy_chk`.  (First loader error was
  `Unresolved symbol "stpncpy" called from liblog.so`.)
- **Built liblog's `logd_writer.cpp`/`pmsg_writer.cpp`** (excluded by build.sh;
  they only needed `-DLIBLOG_LOG_TAG=0 -DSNET_EVENT_LOG_TAG=-1`).  Fixes
  `Unresolved symbol "LogdWrite..." called from liblog.so`.
- Added `runtime/a11-build/test/a11binder.cpp` — calls `ProcessState::self()` +
  `IPCThreadState::self()` (the binder IPC core).  It now loads the whole stack,
  then **hangs** during binder init (prints `[SHIM] init`, nothing after) —
  likely blocked in `ProcessState` (opening/attaching the binder driver).
  Investigate with `pidin`/the driver on the container side.

## Artifacts / files

- `runtime/a11-build/test/{tb_shim.c,tb_cxx.cpp,tb_a11.c,build-tb.sh}` — probes
  (tb_a11 loads the chain).
- `runtime/a11-build/build.sh` — recovery-define + corrected exclude.
- `ws1/resolver.c` — `WS1MISS` diagnostic (gated to runtime, not ctor).
- `/tmp/a11obj/qnx/*.so` — the linked A11 stack; deployed to `/tmp/a11run` on device.
