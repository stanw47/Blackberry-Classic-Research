# session63 — binder resmgr CROSS-COMPILES to a runnable QNX PIE

Date 2026-09-19. Continues session62. Classic live via SSH.

## Milestone (GATE A essentially cracked)
The FULL binder resmgr (binder.c + binder_core.c + binder_handlers.c) now
cross-compiles freestanding against QNX libc.so.3 with ONLY arm-none-eabi-gcc +
hand-built stub headers — NO QNX SDP:

    arm-none-eabi-gcc -nostdinc -nostdlib -fpic -Wl,-pie \
      -Wl,--dynamic-linker=/usr/lib/ldqnx.so.2 --hash-style=gnu --build-id=md5 \
      -Wl,--unresolved-symbols=ignore-all \
      -include sys/cdefs.h -include qnx_resmgr_proto.h \
      binder.c binder_core.c binder_handlers.c -> build/binder (11880 B)

Result: **Type DYN PIE, interp /usr/lib/ldqnx.so.2, EABI5 soft-float** — and it
**EXECUTES on-device** (the QNX loader accepts + runs it; no EINTR). It SIGSEGVs
inside main() because the reconstructed struct layouts (resmgr_attr_t/iofunc_funcs_t
/sigevent/_msg_info/_client_info) don't yet match the real QNX ABI bit-for-bit — an
expected next-round debugging target, NOT a loader/gate problem.

## What was built this session
- binder/qnx_compat.h — full base-type + constant + stdarg surface.
- binder/qnxinc/ — ~35 stub headers (sys/{cdefs,platform,srcversion,types,stat,
  statvfs,mman,mount,iomgr,pm,ftype,dispatch,signal,uio,neutrino}.h + _pack64/_packpop
  + limits/inttypes/utime/...).
- binder/qnxinc/sys/neutrino.h — reconstructed QNX ABI structs: _msg_info, _cred_info,
  _client_info, sigevent, _pulse/io_pulse_t, iov_t, pm_power_attr_t.
- binder/qnxinc/qnx_resmgr_proto.h — resmgr/dispatch/thread_pool/MsgInfo/ChannelCreate/
  resmgr_attach(8 args)/shm_* prototypes.

## Two binder.c source bugs found & fixed
1. `static iofunc_funcs_t binder_ocb_funcs = { ._IOFUNC_NFUNCS, ... }` — used the
   `_IOFUNC_NFUNCS` MACRO as a designated-initializer field name (invalid C). Fixed
   to `{ _IOFUNC_NFUNCS, ... }` (positional init of `nfuncs`).
2. `resmgr_attr_t.nparts_bytes` (my proto had `nparts_max` — wrong field name).

## Remaining (ABI-layout debugging — the struct sizes must match QNX exactly)
The PIE runs but crashes in main() (SIGSEGV ref=0). Suspects, in order:
1. `stderr` (declared `extern void *stderr`; on QNX it's `&__sF[2]` a real FILE*).
   The no-args path `fprintf(stderr,...)` with a NULL stderr -> SIGSEGV.
2. `resmgr_attr_t`/`iofunc_funcs_t`/`resmgr_connect_funcs_t`/`resmgr_io_funcs_t`
   layouts — `iofunc_func_init(_RESMGR_CONNECT_NFUNCS, &connect_funcs, ...)` writes
   by offset; wrong struct size/order corrupts the resmgr callbacks.
3. `struct _msg_info`/`_client_info` offsets (iofunc_client_info fills cinfo.pid/
   cinfo.cred.euid; ctp->info.tid) — wrong layout = wrong pid/tid.
4. `thread_pool_attr_t.handle`/context fields ordering.

Next: get the REAL QNX struct sizes from RIM's 4.3 binder disassembly (the ldr/str
offsets in binder_devctl reveal sizeof(iofunc_funcs_t) etc.), OR reconstruct from
QNX's documented <sys/neutrino.h>/<sys/iofunc.h> (which list the fields in order).

## This is the gate that unblocks WS2 (binder) end-to-end
Once the struct layouts are right, the resmgr attaches /dev/binder in the container
and the A11 binder engine (already host-validated) goes live on QNX.
