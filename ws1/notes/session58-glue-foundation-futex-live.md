# session58 — WS1b glue foundation: futex/h_errno/abort glue RUNS on-device

Date 2026-09-19. Continues session57 (WS1 shim runs RC=0). Classic live via SSH.

## Milestone
Implemented and on-device-verified the FIRST load-bearing bionic glue symbols
(the foundation everything else builds on):
- `__futex_wait` / `__futex_wake` — bionic userspace sync primitive (pthread
  mutex/condvar/once, std::mutex, libc++ all build on it).
- `android_set_abort_message`
- `__get_h_errno` (per-thread h_errno)

Live result (devuser, in sys.android container, LD_LIBRARY_PATH=/tmp/ws1ok):
    [SHIM] init
    futex test: set word=1
    wake(no waiters) rc=0
    wait(value mismatch) rc=0
    abort msg set ok
    h_errno=42
    GLUE OK
    RC=0

## The deep bugs found & fixed (this is the real research content)

### 1. ws1_resolver returned the slot ADDRESS, never tail-jumped to the function
The C `ws1_resolver` (resolver_entry.c) did `return ws1_slots[idx].ptr;` — that
returns the *storage word address*, so every trampoline (`movw r0,#idx; b
ws1_resolver`) returned a garbage pointer to the caller instead of CALLING the
resolved symbol. The intended asm (`tramps_resolver.S`) loads the slot value and
`bx r12` (tail-jump), but its `:GOTOFF:` relocation can't assemble with GNU as.
FIX: new `ws1_resolver.S` (PIC-safe) that calls a C helper `ws1_resolver_slot_ptr`
then `ldr r0,[r0]; bx r0` (tail-jump). Verified in disasm:
    ws1_resolver: push {r4,lr}; mov r4,r0; bl ws1_resolver_slot_ptr@plt;
                  ldr r0,[r0]; pop {r4,lr}; bx r0
This was latent since session39 — the trampoline mechanism was ALWAYS broken; the
"write() works" from session57 was actually happening through a different path
(likely libc.so.3's own write binding, not the shim trampoline). Now it's real.

### 2. Futex emulation: pthread_mutex_t/cond_t ARE 4-byte, zero-init (RIM 4.3 proof)
Disassembled RIM's 4.3 libbionic `pthread_mutex_init` (0xf3a0): with attr==NULL it
does `str 0,[r0]` (single word zero-init) and `pthread_mutex_lock` (0xf5c4→0xf40c)
uses `ldrex/strex` on that word. So `typedef unsigned pthread_mutex_t;` (4 bytes) is
correct — the earlier `SyncMutexLock`/`SyncCondvarWait` attempts returned garbage
because those QNX 8.0 `Sync*` symbols have a different ABI (opaque `sync_t` struct,
not in the pulled headers), NOT because pthread was wrong.

### 3. MUST resolve QNX pthread via dlsym, NOT by symbol name
The shim re-exports `pthread_mutex_lock`/`pthread_cond_wait`/etc. as bionic ABI
trampolines. Calling them by name from glue_impl.c bound to the shim's own
trampoline → recursion/garbage. FIX: resolve the REAL QNX pointers via
`dlsym(libc.so.3, "pthread_mutex_lock")` into function pointers.

### 4. dlopen during constructor returns NULL → resolve LAZILY
`resolve_pthread()` in a constructor called `dlopen("libc.so.3",0)` which returned
NULL (libc not fully initialized during ctor). FIX: `ensure_pthread()` resolves on
first futex use, not at ctor.

## Files
- ws1/glue_impl.c        — futex emulation (hash table + dlsym'd pthread), abort msg, h_errno
- ws1/ws1_resolver.S     — NEW correct tail-jumping resolver
- ws1/resolver_entry.c   — now provides ws1_resolver_slot_ptr (C helper), not ws1_resolver
- ws1/test_futex.c       — on-device glue smoke test
- Makefile               — +build/glue_impl.o, +build/ws1_resolver.o

## Next (WS1b continued, now unblocked on the real trampoline path)
- More glue: __system_property_* (PPS-backed), __get_tls/__get_thread, malloc hooks.
- Re-run `make check` to confirm export surface still complete after resolver rewrite.
- Then binder resmgr (WS2) re-verify against the now-working shim.
