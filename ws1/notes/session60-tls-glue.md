# session60 — TLS/thread glue (__get_tls/__get_thread) runs on-device

Date 2026-09-19. Continues session59. Classic live via SSH.

## Milestone
The bionic TLS/thread foundation implemented and verified on-device:

    tls!=null=1  thread==self=1  tid=1  tid2=1   RC=0

- `__get_tls()`        -> per-thread TLS base (struct with [4] = thread handle)
- `__get_thread()`     -> pthread_self()
- `__pthread_gettid()` -> gettid()
- `pthread_gettid_np()`-> gettid()

## ABI (from RIM 4.3 libbionic disasm — the authoritative source)
- `__get_thread` (0x11288) = `__get_tls()[4]`  (ldr r0,[r0,#4])
- `__get_tls` is provided by **libchost.so** (RIM's QNX host shim), NOT libbionic.
- `pthread_self` (0x1138c) = `__get_thread` (a direct tail-branch).
- `__pthread_gettid` (0xfe94) = `t->tid` at pthread_internal_t offset +32.
- QNX provides: `pthread_self`, `gettid`, `pthread_key_create/getspecific/setspecific`,
  `__tls`, `__get_errno_ptr` (all in libc.so.3 exports).

## Implementation (ws1/tls_impl.c)
Per-thread TLS base via QNX pthread keys:
- `get_tls_base()` caches a `struct tls_base { void* reserved0; void* thread; int tid; }`
  in a pthread key slot; `[4]`(thread) = pthread_self(), tid = gettid().
- Singleton static slot for the single-threaded smoke phase; real per-thread
  allocation once malloc is fully working (the shim's malloc glue is next).
- `__pthread_gettid` maps to gettid() (QNX pthread_self() handle is opaque; no
  +32 tid slot like bionic's pthread_internal_t).

## Makefile/glue wiring
- +build/tls_impl.o; ws1_lookup_glue now merges ws1_tls_impls[] too (with the
  prop + core tables). All use the local glue_strcmp (no strcmp@plt recursion).

## Status of the export surface (make check)
- A11 ref 1668 / exported 3302 / missing 35 (the 35 are pre-existing fortify
  `_chk` gaps + a few, NOT regressions from the resolver rewrite).

## Next (WS1b remaining)
- malloc/free family (dlmalloc) + __get_tls per-thread allocation once malloc lands.
- Re-run full binder resmgr (WS2) verification against the now-CORRECT shim.
- GATE C: live A/B swap harness in the .ns container.
