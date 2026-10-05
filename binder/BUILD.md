# Binder-on-QNX resmgr — build/port checklist

Target: QNX 8.0 ARM EABI (arm-unknown-nto-qnx8.0.0eabi), or the Classic's own
QNX 10.3 ARM.  SEE blueprint session37 §3 (toolchain gap).

Toolchain status (2026-09-13):
- bbndk-tools bundle = connect + bar packager/signer ONLY. No qcc, no
  resmgr/*.h, no gcc-arm target in the squirrel package.
- Decision pending: install QNX SDP 8.0 (registration+fee?) vs use the
  Classic's on-device libc + resmgr headers pulled from the OS image and
  link with arm-none-eabi-* (we HAVE arm-none-eabi-gcc/objdump/readelf).

## Host validation (no QNX toolchain needed) — DONE, all green

The portable engine `src/binder_core.c` and ioctl glue `src/binder_handlers.c`
are validated on the host (Linux gcc + pthreads). Nothing below requires any
QNX SDK; the exact same handler logic funnels incoming ioctl commands into
the engine on both host and device.

Build + run:

    cd binder
    make                    # builds build/test_abi, build/test_binder, build/test_glue
    make test               # 24 ABI asserts + 23 engine simulator checks + 6 glue checks (0 fail)
    make asan               # all tests run under ASan/UBSan (clean, 0 leaks)

`build/test_glue` emulates the QNX resmgr transport's staging loop:
- validates kernel ioctl copy-back rules (`binder_ioctl_reply_size`):
  `_IOC_DIR & _IOC_READ` commands copy `_IOC_SIZE` bytes (WRITE_READ=48, VERSION=4,
  NODE_INFO=24, FROZEN=12); pure write/void commands copy 0 bytes (SET_MAX_THREADS,
  SET_CONTEXT_MGR[_EXT], FREEZE, THREAD_EXIT).
- drives a two-process ping-pong transaction end-to-end through `binder_handle_ioctl`
  verifying that WRITE_READ arg staging, blocking roundtrip, and copy-back operate
  identically through the glue.

`build/test_binder` is a multi-process simulator that emulates three
processes (servicemanager pid 100, client pid 42, victim pid 500) on separate
`struct binder_proc` contexts with a server worker thread. It exercises:

- SET_CONTEXT_MGR_EXT, GET_NODE_INFO_FOR_REF, SET_MAX_THREADS, thread enter
- sync transaction roundtrip with a BINDER_TYPE_BINDER object rewritten to a
  HANDLE on the recipient (ref/handle bookkeeping, handle value verified)
- reply routed back to the exact waiting thread; deferred BR_TRANSACTION_COMPLETE
- BC_FREE_BUFFER of the reply payload
- proc close from a different pid => BR_DEAD_BINDER death notification (cookie)
- one-way shutdown transaction; clean teardown with zero leaks

Kernel-faithful behaviour implemented in `src/binder_core.c` (verified against
`../graft/a11-kernel/binder.c`):
- BR_NOOP written at the head of a fresh read; BR_SPAWN_LOOPER emission rules
  (gated on requested_threads, max_threads, no waiting thread, delivered work)
- sync reply: replier's and original sender's transaction_stacks both popped;
  reply + deferred BR_TRANSACTION_COMPLETE enqueued to the sender's thread list
- thread drains proc work only when transaction_stack == NULL
- object fixup BINDER/WEAK_BINDER -> HANDLE (and HANDLE -> BINDER when the
  target owns the node), flat_binder_object wire format

Notes for the on-device glue:
- The engine serializes under ONE ctx lock; a real resmgr will simply funnel
  all devctl calls into `binder_ioctl` (thread-safe). No per-proc kernel.
- Buffers are pluggable: `ctx->alloc_buffer`/`free_buffer` default to
  malloc/free with driver pointer == user pointer (host sim). On QNX the glue
  must supply shm-backed buffers so that libbinder-side pointers (delivered as
  `tr.data.ptr.buffer`) resolve across processes; `BINDER_MEM_HOST()` and
  `binder_mem_host_read/write` gate that.

Files:
- src/binder_core.c       portable A11 binder engine (validated, 0 warnings)
- src/binder_core.h       engine API (ctx/proc/thread, alloc hooks, mem shims)
- src/binder_handlers.h   portable ioctl handler interface (binder_call, binder_handle_ioctl)
- src/binder_handlers.c   portable ioctl glue & copy-back accounting (validated)
- src/binder.c            QNX resmgr transport (A11 wire ABI, custom OCB, shm transport,
                          thread_pool, iofunc_devctl_verify, mmap_peer)
- include/binder_a11.h    redacted A11 UAPI (64-bit wire, proto 8)
- tests/test_abi.c        wire-ABI lock (sizeof/offsetof/consts, 24 asserts)
- tests/test_binder.c     multi-proc engine simulator (23 checks)
- tests/test_glue.c       transport devctl staging & copy-back validation (6 checks)
- Makefile                host build; `make`, `make test`, `make asan`
- ../graft/               AOSP android-11.0.0_r1 libbinder + servicemanager src
- ../specimens/           UAPI header + disasm + classic binaries (persisted)

Real build steps (once toolchain set):
1. qcc -Vgcc_ntoarmv7le -c src/binder.c src/binder_handlers.c ...
   #fix includes: <sys/resmgr.h> etc come from SDP both