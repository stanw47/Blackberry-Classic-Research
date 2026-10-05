# Session 35 - Binder-over-QNX deciphered: userland resmgr + MsgSendv / ioctl

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, QNX root via `/base/bin/__root`.
Date: 2026-09-13.

## WHAT WAS PROVEN (workstream 2 = IPC)

Pulled the `binder` binary (30,440 B ELF ARM QNX) and `libbionic.so` (85,244 B) from the
Classic's own 4.3 runtime and dissected them with arm-none-eabi-binutils + pyelftools +
capstone. Result: **RIM's binder is USERLAND over QNX message passing, not a kernel driver.**

## 1. `binder` binary = QNX resource manager

Imports prove it **(88 unique)**:
- resmgr core: `resmgr_attach`, `resmgr_msgread`, `iofunc_attr_init/lock/unlock`,
  `iofunc_func_init`, `iofunc_devctl_default`, `iofunc_devctl_verify`
- dispatch (QNX resmgr run loop): `dispatch_create`, `dispatch_context_alloc/free`,
  `dispatch_handler`, `dispatch_block/unblock`
- message passing: `MsgReceive`, `MsgSend`, `MsgReply`, `MsgError`, `MsgInfo`,
  `MsgKeyData`, `ConnectAttach`, `ConnectDetach`, `ConnectServerInfo`
- shared memory: `shm_open`, `shm_unlink`, `shm_ctl`, `mmap64`, `mmap_peer`, `munmap_peer`
- capabilities: `retainBinderSystemCapabilities`, `isAndroidClient`
- exports: `binder_devctl` (the ioctl handler), `binder_transaction_log`,
  `binder_transaction_log_failed`

So `/dev/binder` on BB10 = a QNX resmgr (device-driver) that multiplexes binder traffic
over channels/shared memory. `binder_devctl` is the ioctl entry; transactions are passed
via MsgSend*/MsgReply* (+ shm for payloads).

## 2. `libbionic.ioctl_binder` = the userland bridge

Disassembled at VA 0xf228 (532 bytes). Logic:
- loads two comparison constants:
  - `0xc0186201` = `_IOWR(0x62' b', 1, struct binder_write_read[24])` = BINDER_WRITE_READ
  - `0xc108620c` = `_IOWR(0x62 'b', 12, ...)` = BINDER_VERSION
- branches into two dispatch paths, both `blx 0x4ae4` = **`ioctl@plt`** (QNX ioctl), and
  one call `blx 0x4f74` = **`MsgSendv_r@plt`** (QNX synchronous message send).
- error/print path uses `fputs@plt` ("Too many transactions in packet!") and
  `__get_errno_ptr@plt`.

Conclusion: Android apps hit `ioctl(fd, BINDER_WRITE_READ, &bwr)`; libbionic forwards to
the QNX `/dev/binder` resmgr via qnx ioctl + MsgSendv_r. Binder ABI preserved at the
Android side, transported by QNX IPC on the driver side.

## 3. Also confirmed from libbionic exports (WS1 evidence)

Prior session-34 export map already showed 403 exported bionic symbols; this session pinned
the IPC surface:
- `futex`, `epoll_*`, `eventfd_*` shims live in libbionic (epoll via QNX `poll`/`ionotify`)
- `ioctl_binder`, `qnx_uid_to_android`, `android_uid_to_qnx`, `qnx_gid_to_android`,
  `getAppGidFromApkSymlink` (app sandbox uid/gid mapping)
- capability model names every Android daemon: `retainBinderSystemCapabilities`,
  `retainJavaProcessSystemCapabilities`, `retainAndroidResmgrSystemCapabilities`,
  `retainSystemServerSystemCapabilities`, `retainMediaServerSystemCapabilities`, ... + 
  `defineAppSandbox`, `setPermissions`, `injectAppGidIntoSupplementaryGroups`
- `authman_send`, `procmgr_ability`, `forensics_logworthy_async` (QNX platform services)
- property system: `__system_property_*` (over QNX PPS)

## NEXT
WS3: screen bridge dissection (`libgralloc_screen` / `libframebuffer_screen` /
`libhwcwindow` -> QNX libscreen + libimg). Then write session36 "RIM port architecture"
recreate-me doc pairing every AOSP subsystem to its QNX realization, per the session32
deliverable.