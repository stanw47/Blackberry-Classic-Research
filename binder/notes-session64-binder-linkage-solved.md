# session64 — binder linkage SOLVED; crash isolated to resmgr_attach/pathmgr_link

Date 2026-09-19. Continues session63. Classic live via SSH.

## Breakthrough: the binder is now a REAL QNX process calling QNX libc
The linkage was the last loader-level problem, and it's now solved. Three link flags
were required (matching the WORKING ws1 test binaries):

    -Wl,--export-dynamic            # keep UND symbols in .dynsym (90 UND now)
    -Wl,--unresolved-symbols=ignore-all
    -Wl,--no-as-needed -l:libc.so.3 # record NEEDED libc.so.3 (GNU ld CAN read its SONAME)

Before: only 2 UND symbols, no NEEDED -> loader had nothing to resolve -> PLT jumps
to NULL -> SIGSEGV at ref=0. After: 90 UND + NEEDED libc.so.3.

Result now: binder executes, and the crash moved from a NULL PLT deref INTO
`ldqnx.so.2@pathmgr_link+0x54` — i.e. `resmgr_attach("/dev/binder",...)` is actually
running and the QNX path manager is linking the name. The fault `ref=ff200121` is a
bad function-pointer table (the iofunc mount/attr handle passed as the 8th arg).

## What remains (pure struct-layout, no more linker/gate problems)
The crash is in `resmgr_attach`'s `pathmgr_link` processing the `RESMGR_HANDLE_T`
(iofunc_attr_t) handle. Suspects:
1. `iofunc_attr_t` / `iofunc_mount_t` layouts (binder.c sets `gattr->attr.mount->funcs`).
   The real iofunc.h DOES define these (struct _iofunc_attr at iofunc.h:115, with
   IOFUNC_MOUNT_T + _iofunc_mmap_list/_iofunc_lock_list members) — but my stub
   sys/neutrino.h / compat types may make the layout wrong.
2. `iofunc_func_init` signature — RIM: iofunc_func_init(r0=8, connect_funcs, r2=29, io_funcs).
   Matches iofunc.h. Not the issue.
3. The `resmgr_connect_funcs_t.open` field must be at the RIGHT offset — it is
   (defined in the real resmgr.h, 9 fields).

## Fixed this session (struct corrections from RIM's main() disasm)
- resmgr_attr_t = 32 B: flags@+0, nparts_max@+4, msg_max_size@+8 (RIM: [sp+132]=1,
  [sp+136]=2048).
- thread_pool_attr_t = 68 B: handle@+0, 5 fn ptrs @+4..+20, lo_water@+28, hi_water@+30,
  increment@+32, maximum@+34 (halfwords).
- _Stderr (not stderr) — QNX exports `stderr`/`_Stderr`; RIM imports `_Stderr`.
- binder.c: `rattr.nparts_max` (not nparts_bytes); `{ _IOFUNC_NFUNCS, ... }` positional init.

## Key disassembly facts extracted from RIM's 4.3 binder main()
- dispatch_create() -> dispatch_t* (r7)
- thread_pool_create(&tattr(68B), 0)
- iofunc_func_init(_RESMGR_CONNECT_NFUNCS=8, connect_funcs, _RESMGR_IO_NFUNCS=29, io_funcs)
- iofunc_attr_init(attr, S_IFCHR, NULL, NULL)
- getAndroidPlayerGid() -> stored into attr [+292]
- resmgr_attach(dpp, &rattr(32B), path, _FTYPE_ANY, 0, connect_funcs, io_funcs, handle)
- then retainBinderSystemCapabilities(), thread_pool_start(), thread_pool_destroy(), exit()

## Next: get iofunc_attr_t / iofunc_mount_t layouts exactly right
The iofunc.h defines them, but they depend on IOFUNC_MOUNT_T (struct _iofunc_mount),
_iofunc_mmap_list, _iofunc_lock_list, and the off_t/ino_t 32/64-bit branch (__OFF_BITS__).
Need to: (a) define __OFF_BITS__=32 correctly so the nbytes/inode fields are off_t/ino_t
(not off64_t/ino64_t), (b) define struct _iofunc_mount with its funcs pointer at the
offset binder.c expects (gattr->attr.mount->funcs). Then resmgr_attach should link.

## session64(cont.) — A/B DECISION LOCKED (recorded per user directive)
- **A — keep debugging binder resmgr ABI (LOCKED, recommended).** The pending
  on-device SIGSEGV is now proven to be OUTSIDE my four reconstructed tables:
  connect=8 / io=29 / iofunc_mount_t=24B / iofunc_funcs_t=24B all verify clean
  against authoritative `sysroot/target/include/iofunc.h` + `resmgr.h` this
  session. The crash `ip=ldqnx.so.2@pathmgr_link+0x54 ref=0xff200121` is inside
  QNX's OWN internal path-table walk (the 0xff2001xx = device flash/ROM fn-ptr),
  i.e. a layer deeper than struct-layout.
- **B — pivot to WS1b glue (session40/41) was the alternative; REJECTED.** That
  line is proven-up (71 A11 libs, full iofunc/resmgr closure resolvable) but
  addresses a bionic-glue surface, not the live `pathmgr_link` crash terrain.

## Current next-instrument (Session 65 first action)
Build+deploy a **stock-default minimal resmgr** (`/dev/test_resmgr`, byte-identical
`iofunc_funcs_t`/`resmgr_attr_t`/`resmgr_connect` to binder.c but ZERO custom OCB
handlers): if it ALSO SIGSEGVs at `pathmgr_link+0x54 ref=ff200121`, the fault is
NOT my binder OCB chain — it's our resmgr_attr/flags path being rejected by
QNX's embedded pathmgr (lead: `resmgr_attr_t.flags` — my stub sets `flags=0`,
QNX needs `_RESMGR_ATTACH_ACCESSX`?). If the minimal one survives, bisect binder.c
OCB funcs one at a time.
