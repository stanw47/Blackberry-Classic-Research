# session59 — property system glue works + the resolver rewrite that made it real

Date 2026-09-19. Continues session58. Classic live via SSH.

## Milestone
`__system_property_*` (the full A11 bionic property ABI) implemented and running
on-device:

    set=0 get=5 find=found missing=-1  value="hello"   RC=0

Live (devuser, in sys.android container, LD_LIBRARY_PATH=/tmp/ws1ok):
    [SHIM] init
    1234
    hello

## THE DEEP BUG (this is the load-bearing finding): the trampoline resolver
### was destroying the caller's arguments and callee-saved registers

Three compounding bugs, each found by on-device iteration:

1. **Trampoline passed idx in r0** (`movw r0,#idx; b ws1_resolver`) — r0 is the
   target function's FIRST argument. Any function called through the shim got a
   garbage first argument. FIX: pass idx in **r12 (ip)** — caller-saved scratch.
   (gen_tramps.py updated: `movw r12, #idx`.)

2. **ws1_resolver used r4 as scratch without restoring it** — r4 is callee-saved;
   the caller (test's main) holds a live pointer ("test.foo") in r4 across calls.
   FIX: use ONLY ip (r12) as scratch; save/restore r0-r3 and r9 (PIC GOT base),
   never touch r4-r8/r10/r11.

3. **GOT access during constructor via PLT fails** (dlopen/dlsym/ws1_lookup_glue
   are cross-TU global symbols; their PLT/GOT entries aren't ready during dynamic
   link init). FIX: ws1_resolver is now PURE ASM with direct GOT access
   (`ldr.w r9,[pc,#off]; add r9,pc` = compiler's GOT-base idiom; then
   `ws1_slots(GOT)` for the table) — no C helper, no PLT, no recursion.

Final ws1_resolver (verified in disasm, tail-jump, arg-preserving):
```
push {r0,r1,r2,r3,r9,lr}
mov  r9, ip ; lsls ip,r9,#2 ; add ip,ip,r9,lsl#3   @ ip = idx*12
ldr.w r9,[pc,#gotbase] ; add r9,pc                  @ r9 = GOT base
ldr  r0,.Lslots ; add r0,r9 ; ldr r0,[r0]          @ r0 = &ws1_slots
add  ip, ip, r0 ; ldr ip,[ip] ; ldr ip,[ip]        @ ip = resolved fn
ldr  r0,[sp,#0]; r1=[sp,#4]; r2=[sp,#8]; r3=[sp,#12]; r9=[sp,#16]
add  sp,#20 ; ldr lr,[sp],#4 ; bx ip
```

## Why session57/58 "worked" but was illusory
- session57's test_minimal only called `write`/`strlen`/`_exit` with args that
  happened to survive (or the trampoline path wasn't actually taken for the
  alias `write`). The `ws1_resolver` (C version) returned the SLOT ADDRESS, not
  tail-jumping — so `write` "working" was a coincidence of the dlsym'd QNX write
  being reached another way. The r12/arg-preserving asm resolver is the first
  CORRECT resolver.

## Files changed
- ws1/gen_tramps.py      — trampolines now `movw r12,#idx` (not r0)
- ws1/ws1_resolver.S     — pure-asm, arg-preserving, direct-GOT tail-jump
- ws1/resolver.c         — constructor pre-fills slots (resolve glue > dlsym QNX)
- ws1/glue_impl.c        — ws1_lookup_glue uses local glue_strcmp (no strcmp@plt recursion)
- ws1/prop_impl.c        — full property store (set/get/find/read/serial/foreach/add/update/wait_any/read_callback/set_filename/area_init/area_serial)
- ws1/Makefile           — +prop_impl.o, +ws1_resolver.o, -Bsymbolic removed (was too aggressive)

## Next (WS1b continued)
- __get_tls/__get_thread (TLS/pthread_internal_t) — the last foundational piece.
- Re-run `make check` to confirm export surface intact after resolver rewrite.
- Then binder resmgr (WS2) + servicemanager re-verify against the now-CORRECT shim.
- Then GATE C: live A/B swap harness in the .ns container.
