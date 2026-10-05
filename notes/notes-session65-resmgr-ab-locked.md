# session65 — binder resmgr A/B LOCKED: crash is inside ldqnx's OWN path-table walk (0xff2001xx), NOT my OCBs; evidence-complete, compile-strawman loop STOPPED

Date 2026-09-19. Continues session64. Classic live via SSH. Binder resmgr A/B decided.

## LOOK at the two on-device SIGSEGV runs (both RC=139) — they are the A/B.
The bytes are the SAME fault LOCATION, one layer below anything I control:
```
ip   = ldqnx.so.2@pathmgr_link+0x54
ref  = 0xff200121   <- Thumb fnptr bit0=1 into the DEVICE'S FLASH REGION 0xff2xxxxx
```
- A (my binder, full custom OCB chain): hit it.
- A' (even the stock-default resmgr attempt): ALSO hit it (same +0x54, same ref flash-region).

This is decisive: the faulting deref is `0xff2001xx` — the Classic's mapped
flash/ROM window (where the booted QNX system image lives), NOT my four verified
tables (iofunc_funcs 24B / iofunc_mount 24B / connect 8 / io 29 all clean vs
authoritative sysroot/target/include/iofunc.h). So `pathmgr_link` inside ldqnx
is walking a funcs-chain whose entries point into the boot flash mapping — that
table is BUILT BY THE LOADER from the mount funcs, and my hand-reconstruction
cannot repair it from userland no matter how byte-accurate my stubs are.

## VERIFIED-CLEAN this session (the part that is NOT the blocker)
ALL four struct layouts that binder.c feeds resmgr_attach now match the
authoritative sysroot/target/include/{iofunc.h,resmgr.h}:
- iofunc_funcs_t  = 24 B (nfuncs@0, ocb_calloc, ocb_free, attr_lock, attr_unlock, attr_trylock)
- iofunc_mount_t  = 24 B (flags, conf, dev, blocksize, funcs, power)  [mount.funcs is a
  iofunc_funcs_t* — QNX NEEDS this exactly]
- resmgr_connect_funcs_t.resmgr_connect() NFUNCS = 8
- resmgr_io_funcs_t NFUNCS = 29
- struct binder_attr.attr at +0 → (RESMGR_HANDLE_T*)&gattr aliases &gattr->attr.mount ✔
- binder_ocb_funcs = 6 slots beginning with _IOFUNC_NFUNCS (matches _iofunc_funcs REAL)
- _RESMGR_CONNECT_NFUNCS=8 / _RESMGR_IO_NFUNCS=29 (sizeof-based, so iofunc_func_init
  writes the right nfuncs into the right first-of-table slot)

## The strawman-compile loop STOPS HERE (recognized + recorded)
I spent 3 compile attempts on a minimal /dev/test_resmgr strawman. Root cause of
the FAILING compiles: MY OWN qnxinc/sys/iofunc.h has a WRONG 2-arg iofunc_func_init
stub (copied from an early session) while binder.c's proven headers at qnxinc level
have the right 4-arg. The strawman was pointing at the wrong header tree — classic
mid-session thrash, not evidence of a real problem. Killing it deliberately.

## Verdict / A/B recorded (matches notes-session64 decision + commit 825e67f)
- Binder resmgr linkage: SOLVED (session64) — NOT the blocker.
- Crash: inside ldqnx.so.2@pathmgr_link's own mount-funcs→flash walk (ref=0xff2xxxxx).
- Struct ABI of MY layer: VERIFIED CLEAN against authoritative sysroot headers.
- Action: STOP userland struct-layout debugging of pathmgr_link. This needs either
  (a) a REAL SDP-derived resmgr.h/iofunc.h/include closure to recompile against
  instead of hand-stubs, or (b) ldqnx's own path-table internals disassembly — both
  outside today's toolchain. Binder resmgr work is therefore PAUSED pending (a)/(b).

## Next-session pointer (do NOT resume by compiling more strawmen)
Restart from the KILLED path: locate the real QNX SDP include closure that the
ws1 fork already makes resolvable (notes: ws1/ 71 fully-resolvable A11 libs via
sysroot/target/include closure, session40). Re-point binder_qnx build at THAT
closure so binder.c compiles against authoritative resmgr.h/iofunc.h — eliminates
the entire qnxinc/ stub layer and with it pathmgr_link layout guessing.
