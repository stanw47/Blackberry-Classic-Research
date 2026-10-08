# Session 73 — A11 on Passport: pre-ctor crash localized to shim-mediated load-time calls

## Context

Resumed the paused A11-on-QNX work on the **Passport** (retail E538, rooted).
`tb_shim` runs; `tb_cxx`/`tb_a11` SIGSEGV pre-main with the QNX report
`ip=…f7c mapaddr=00049f7c` (libc.so.3 offset `0x49f7c` = function entry
`push {r3,r4,r5,lr}`, a lock-style helper calling `0x192a8`/`0x183d8`).

## What was ruled out

- **Deployed chain is current**: pulled `libc.so`/`libc++.so` off the device —
  md5s match the fixed local builds (`0de8eb5d…`, `d8427c59…`). Not a stale deploy.
- **libc.so.3 build difference exonerated**: Passport vs Classic `libc.so.3` are
  the same 598,616 B file with **only 4 differing bytes**, all in program-header
  `p_paddr` fields (ELF header region, offsets 0x62/0x63/0x82/0x83). Code identical.
- **Deploy dir has no `libc.so.3`** — the chain resolves against the Passport's
  system libc at runtime (as intended).
- **Handler-first `tb_dlopen`** (links only shim, installs SIGSEGV handler in
  main, then `dlopen`s the chain) shows the chain loads fine at main time:
  `[SHIM] init` → `c++: C` (libc++ ctors OK) → `base: L` → `utils: U` →
  `binder: B` → `ProcessState::self` found. Its only crash is the **known
  session71 `bx pc` SIGILL** when calling a runtime-resolved (dlopen-only)
  Thumb symbol (`_Znwj`) through GNU-ld's Thumb↔ARM veneer at `tb_dlopen+0x27c`
  (r0=0x14=20). Mitigation already known: NEEDED link-time resolution.

## New findings (this session)

- **`tb_shim2`/`tb_shim3`** (plain C probe, `libc++.so` forced into NEEDED in
  both orders): crash pre-ctor at `libc+0x49f7c` → the crash needs only
  `libc++.so` in the load set; not a NEEDED-order effect.
- **Diagnostic shim** (`ws1/dbg_diag.c`, ctor priority 50, + `-DWS1_TRACE`
  trace in `resolver.c`): on `tb_cxx` **no `[DBG]`/`[SHIM]` output ever
  appears** → the crash happens **before any shim constructor**. `tb_shim`
  alone with the same debug shim: `[DBG] armed` → `[DBG] handler ok` →
  pre-fill of **0x609 = 1545 slots** with constant SP `0x0f938958` → `[SHIM] init`
  → RC=0. So the shim's own init path is fine in isolation.
- **`LD_DEBUG=libs/all` trace on `tb_shim3`**: load map order libc.so →
  libc.so.3 → libc++.so; then the loader resolves libc++.so's calls —
  `pthread_key_create` → shim, `dlopen` → libc.so.3, `__get_errno_ptr` →
  libc.so.3, `getenv` → shim — **then SIGSEGV at libc+0x49f7c** (ref varies
  with ASLR: `0x0fd18fc0`, `0x102e8f20`, `0x10747ff0`…). This is the
  pre-ctor (libc++.so static-init) call chain exercising shim trampolines;
  the crash is in the callee path inside QNX libc while the shim ctors have
  not run yet.
- **`LD_PRELOAD=./libc.so` does not change it** (still no `[DBG]`) → not a
  simple init-order problem; crash is in the load-time/relocation-binding path.
- **`LD_BIND_NOW=1` exposes real resolver gaps** (hidden by lazy binding):
  - `__emutls_get_address` referenced from `libc++.so` — **not implemented**
    in the shim (Android emulated TLS).
  - `dl_unwind_find_exidx` referenced from `libc++.so` — **not implemented**
    (bionic ARM unwinder API).
  - `__brk` referenced from `libc.so` — **shim bug**: `malloc_impl.c`
    declares `extern void *__brk(void *)` but QNX has no `__brk`; only the
    shim's own `brk`/`sbrk`/`ws1_impl_brk` exist (session LD_BIND_NOW says
    `ldd:FATAL: Could not resolve all symbols`).

## Fix list (next)

1. `malloc_impl.c`: drop the `__brk` extern; implement `ws1_impl_brk` /
   `ws1_impl_sbrk` on QNX `brk` + `_curbrk` (both present in libc.so.3)
   without the bionic-only name.
2. Implement `__emutls_get_address` in the shim. ABI (from AOSP
   `bionic/tests/thread_local_test.cpp`):
   ```c
   typedef struct __emutls_control {
     size_t  size;
     size_t  align;
     union { uintptr_t index; void *address; } object;
     void   *value;
   } __emutls_control;
   ```
   Lazy per-control index allocation + per-thread pointer array via a
   `pthread_key_t`, `malloc` of `size` at `align`, initial value copied from
   `control->value`; `object.index` non-zero after first call.
3. Implement `dl_unwind_find_exidx` (bionic libdl API) — resolve the exidx
   of the DSO containing `pc` (`dl_iterate_phdr`/PT_ARM_EXIDX if QNX
   supports it; otherwise a stub returning count=0 and revisit when C++
   exceptions are exercised).
4. **Pre-ctor trace** (next diagnostic): add `ws1_dbg_note(s->name)` at the
   top of `resolve_symbol()` and arm the SIGSEGV handler from the first
   `ws1_resolve_slot()` call (before any resolution). Rebuild the trace shim,
   run `tb_cxx` → the last printed name + handler regs identify the exact
   pre-ctor call that crashes (candidate: first `pthread_*`/`getenv`-adjacent
   trampoline resolved while the shim is un-initialized).

## Files

- `runtime/a11-build/test/tb_dlopen.c` — handler-first dlopen probe (new).
- `runtime/a11-build/test/build-tb.sh` — builds `tb_dlopen` too.
- `ws1/dbg_diag.c` — debug-only early ctor handler + `[DBG]` markers (new).
- `ws1/resolver.c` — `-DWS1_TRACE` slot pre-fill trace (index/SP) in
  `ws1_onload`.
- Device state: original shim restored and verified (`[SHIM] init` /
  `A11 libs loaded` / RC=0); trace shim + `tb_shim2`/`tb_shim3`/`tb_dlopen`
  remain deployed for the next round.
