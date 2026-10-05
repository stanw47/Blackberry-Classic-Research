# binder resmgr freestanding cross-compile — QNX header reconstruction status

Date 2026-09-19. Goal: compile binder.c + binder_core.c + binder_handlers.c for QNX
ARM using arm-none-eabi-gcc + the 3 pulled QNX headers (resmgr.h/iofunc.h/iomsg.h),
freestanding (-nostdinc), with hand-built stub headers — NO QNX SDP.

## DONE (compiles clean now)
- binder_core.c    — COMPILES (0 errors) with qnx_compat.h.
- binder_handlers.c — COMPILES.
- qnx_compat.h — full base types (_Int*_t/_Uint*_t, pid/uid/gid/dev/ino/mode/time,
  off64_t), errno constants, O_*/PROT_*/MAP_* flags, stdarg, offsetof, __FLEXARY(t,n)=t n[0].
- Stub headers in binder/qnxinc/: errno/stdlib/string/stdio/pthread/unistd/fcntl/
  stdint/stdarg/stdbool/stddef/limits/inttypes/utime + sys/{types,stat,statvfs,mman,
  mount,iomgr,pm,ftype,platform,srcversion,cdefs,dispatch,signal,uio}.h + _pack64.h/_packpop.h.
- The 3 REAL QNX headers (resmgr.h/iofunc.h/iomsg.h) are copied into qnxinc/sys/ and
  pulled verbatim — they are the source of the remaining struct requirements.

## REMAINING (blocking binder.c — core QNX kernel ABI structs to define)
1. `struct _msg_info` (kernel message-info: nd, srcnd, pid, tid, msglen, coid, etc.
   ~30 fields) — referenced by iomsg.h `_io_link_extra.info`, resmgr.h, iofunc.h.
2. `struct sigevent` (full: sigev_notify, sigev_signo, sigev_value union, sigev_coid,
   sigev_priority) — referenced by iofunc.h `_iofunc_notify_event.event`.
3. `io_pulse_t` (struct _pulse: type/subtype/code/value/scoid — already stubbed in
   dispatch.h, verify layout) — resmgr.h `_resmgr_iomsgs.pulse`.
4. `struct _io_connect` (pathmgr connect msg: path_len, subtype, file_type, eflag,
   extra_type, extra_len, path flex) — resmgr.h `_resmgr_iomsgs.connect`.
5. `struct _io_open`, `io_close`, `io_read`, `io_write`, `io_devctl` message structs
   (already in iomsg.h, but need _msg_info to fully resolve).
6. `pm_power_attr_t` (power mgmt attr — stub a dummy struct).
7. `iov_t` / SETIOV macro, `resmgr_attr_t` (resmgr_attr_init/... — these come from
   resmgr.h but need the struct def), `dispatch_*` + `thread_pool_*` + `resmgr_attach`
   + `iofunc_*` + `shm_*` + `slog2_*` + `MsgSend`/`MsgReply`/`ChannelCreate` prototypes
   (all symbols ARE in libc.so.3 — just need extern decls).
8. `EOK` (=0), `O_NONBLOCK`, `perror` decl.

## The correct long-term fix
The real QNX `_msg_info`/`sigevent`/`_io_connect` layouts must match the kernel ABI
exactly (a wrong size silently corrupts resmgr messages). They come from QNX's
`sys/neutrino.h`/`sys/siginfo.h`/`sys/iomsg.h` full set. Best sources:
- Extract QNX SDP 6.5.0 installer (needs 32-bit JRE, not present) OR
- Pull the headers from a QNX 6.5/8.0 SDK image if one becomes available OR
- Reconstruct from RIM's own 4.3 `libchost.so`/`binder` disassembly (struct sizes can
  be inferred from the ldr offsets RIM's binder uses — e.g. binder_devctl @0x4128).

## Priority call
binder_core.c + binder_handlers.c (the portable A11 engine + ioctl glue) are the
valuable, already-validated parts. binder.c is the QNX transport shell. The engine
does NOT need _msg_info — only the resmgr shell does. So: either (a) finish the
struct reconstruction (focused, ~1 session), or (b) get the real QNX headers (SDP/JRE).

## Files
- binder/qnx_compat.h        — base types + prototypes (committed)
- binder/qnxinc/**           — stub headers (committed)
- binder/src/binder.c        — still needs the remaining structs
