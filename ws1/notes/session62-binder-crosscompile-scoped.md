# session62 — binder resmgr cross-compile: blocker precisely scoped (GATE A)

Date 2026-09-19. Continues session61. Classic live via SSH.

## What was verified
- binder CORE is solid: 23 engine + 6 glue + ABI tests all pass on host (unchanged).
- binder.c (the QNX resmgr transport) already uses `mmap`/`munmap`/`shm_open`/
  `shm_ctl` — NOT `mmap_peer`/`munmap_peer` (those were only in comments). So no
  transport rework is needed.
- All 22 binder-needed QNX symbols ARE in libc.so.3 (resmgr_attach, iofunc_*,
  dispatch_*, thread_pool_*, shm_open/shm_ctl/shm_unlink, mmap/munmap, devctl,
  MsgReply, pthread_cond_wait, etc.). Confirmed against ref/gate_b/qnx_libc_exports.txt.

## The actual blocker (GATE A, now precisely scoped)
Cross-compiling binder.c needs the QNX **standard C headers** that are NOT in the
sysroot yet: pthread.h, stdio.h, stdlib.h, string.h, unistd.h, stdint.h, stdarg.h,
sys/mman.h, sys/neutrino.h, sys/dispatch.h, sys/slog2.h, sys/shm.h.
We only have: sys/resmgr.h, sys/iofunc.h, sys/iomsg.h.

Options (ranked):
1. **Extract QNX SDP 6.5.0 installer** (`~/Downloads/qnxsdp-6.5.0SP1-x86-...-linux.bin`,
   111 MB InstallShield MultiPlatform). Needs a 32-bit JRE 1.5 — NOT present, and no
   sudo to install one (host has no i386 arch). The payload is ISMP "beans"
   (3861 PK sigs + 3 gzip streams in the tail, but none decompress cleanly — ISMP
   wraps them in its own container). Extraction is non-trivial.
2. **Hand-declare the missing prototypes** (the ws1 approach): write a minimal
   `qnx_compat.h` with pthread_*/stdio/stdlib/string prototypes + `#define` for
   O_*, PROT_*, MAP_*, SHM_CTL_* constants, `-include` it into the freestanding
   compile. This is mechanical and achievable NOW — the QNX *symbols* are all in
   libc.so.3 (only the header text is missing).
3. **Install QNX SDP 8.0** (proper) — not available (no installer downloaded).

Recommendation: option 2 (hand-declared qnx_compat.h) — same technique that made
the ws1 shim build without QNX SDP. The constants needed (O_RDWR=2, O_CREAT=0x40,
O_EXCL=0x800, PROT_READ=1, PROT_WRITE=2, MAP_SHARED=1, MAP_FAILED=-1, SHM_CTL_ANON,
SHM_CTL_PHYS) are standard QNX/POSIX values.

## On-device status
- shim libc.so (304344 B, 0 TEXTREL, 0 undefined) with futex/property/TLS/malloc
  glue running on-device (sessions 58-61).
- The binder resmgr binary is the NEXT build once qnx_compat.h lands.

## Next concrete actions
1. Author ws1/../binder/qnx_compat.h (pthread + stdio + stdlib + string + mmap +
   shm + fcntl constants + resmgr/dispatch prototypes for the symbols already in
   libc.so.3).
2. `make cross` target: arm-none-eabi-gcc -nostdlib -fpic -include qnx_compat.h
   -I../sysroot/target/include, link binder.c+binder_core.c+binder_handlers.c
   against -l:libc.so.3 -> build/binder (a QNX resmgr PIE).
3. Deploy build/binder to /tmp/ws1ok, exec as devuser, confirm resmgr_attach +
   iofunc_func_init succeed (this proves the resmgr loads in the container).
