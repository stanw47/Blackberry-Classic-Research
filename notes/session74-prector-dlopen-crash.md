# Session 74 — A11 pre-ctor crash: it's the first dlopen from pre-ctor context

## Fixes landed (verified)

- `ws1/malloc_impl.c`: the bionic-only `__brk` extern is gone; `brk`/`sbrk`
  now go through a dlsym'd QNX `brk` (no more unresolved `__brk`).
- `ws1/extra_impls.c` (new): implements `__emutls_get_address` (clang
  emulated-TLS ABI, pthread-key + per-thread pointer array, alignment,
  init-value copy) and `dl_unwind_find_exidx` (stub: count=0 for now).
- Verified on device: `LD_BIND_NOW=1 ./tb_shim` → clean (the three unresolved
  symbols from session73 are fixed).
- `ws1/resolver.c`: re-entrancy guard + `RTLD_NEXT`. QNX `dlopen` internally
  calls `getenv`, which our trampoline interposes; the guard resolves such
  re-entrant names with `dlsym(RTLD_NEXT)` to skip our own definition. Confirmed
  via `LD_DEBUG=all`: `getenv` now binds to **libc.so.3** instead of the shim.

## The crash (still open, now precisely characterized)

`tb_cxx`/`tb_a11` SIGSEGV **before any constructor of any object runs**:

- `libdbg.so` (dependency-free DSO whose ctor prints `[EARLY] armed`, linked
  FIRST in NEEDED) never prints.
- The debug shim's ctor(50) and `[SHIM] init` never print.
- The crash is the **first `dlopen("libc.so.3")` executed from libc++'s
  pre-shim-ctor context**: first shim trampoline call (e.g.
  `pthread_key_create`) → `ws1_resolve_slot` → `resolve_symbol` → `dlopen`.
- It dies inside QNX's runtime linker, which **lives in libc.so.3** (it exports
  `_dl_debug_state`; internal, non-exported rtld functions):
  - plain runs: `libc.so.3+0x49f7c` (lock-style helper, called from `dlopen`);
  - `LD_DEBUG=all` runs (guard active): hundreds of `getenv` lookups (dlsym
    internals reading LD_DEBUG), then `libc.so.3+0x48974`;
  - trace shim: `ws1_resolver` entry (its debug arm calls `dlopen` first).

So: **QNX `dlopen`/`dlsym` are not usable before the loader's init phase
completes**, and libc++.so's ctors run before the shim's ctors on this loader,
forcing that path. `LD_PRELOAD` has no effect. `LD_NOINIT` does not suppress
the shim's ctors (measured: `[SHIM] init` still printed), so it is not a
reliable probe either.

## Blocked diagnostics

- Cores: `dumper` needs `/proc/dumper` (root-only). Root cannot execute the
  probes ("Operation not permitted", BB10 exec policy even from /tmp), so the
  root+dumper wrapper route is closed for now.
- Full traces archived on device (`/tmp/trace_cxx.txt`, `/tmp/trace2.txt`).

## Next fix (deterministic): link-time alias binding, no runtime dlopen/dlsym

Generate a helper DSO `libqnxbind.so` that links against libc.so.3 and defines
**none** of the bionic names, containing one pointer table:

```c
extern void getenv(void);      /* binds to libc.so.3 at load time */
void *qnxb_ptrs[] = { (void*)&getenv, ... };   /* loader fills via relocs */
```

Then change the shim's WS1_ALIAS handling to jump/return through `qnxb_ptrs`
(indexed per slot) instead of `dlsym`. The shim needs `libqnxbind.so` (NEEDED).
No loader calls happen at first-call time, so nothing runs pre-ctor; the shim
ctors (ws1_onload pre-fill) become optional. GLUE slots can similarly jump
directly to their impl (link-time).

Files: `ws1/gen_tramps.py` (emit the direct table), `ws1/resolver.c`
(alias path), Makefile. Keep the re-entrancy guard as belt-and-braces.

## Files/state

- New: `ws1/extra_impls.c`, `ws1/dbg_early.c` (dependency-free early-handler
  DSO used for the pre-ctor arming experiment).
- Changed: `ws1/malloc_impl.c`, `ws1/resolver.c` (guard, RTLD_NEXT, trace),
  `ws1/Makefile` (extra_impls.o).
- Device: clean guarded shim deployed, `tb_shim` RC=0; `tb_dlopen`,
  `tb_shim2`, `tb_shim3`, `tb_cxxe`, `libdbg.so` still in the qnx dir.
