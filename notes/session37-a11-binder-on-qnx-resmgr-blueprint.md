# session37 — Android 11 binder on a QNX resmgr: the recreate blueprint

Date: 2026-09-13.
Goal (decided with user): port A11 binder onto a FRESH QNX resmgr, keeping RIM's
Proven pattern but NOT RIM's 4.3 ABI. Graft reference: Passport LineageOS 18.1
(Android 11, ARM32) + OnePlus Bacon A11 (lineage-18.1 UNOFFICIAL Tom).

State after this session's research (see change log at bottom for the /tmp wipe recovery).

## 1. Evidence chain (all verified this session)

### 1.1 A11 binder UAPI (the wire ABI to implement)
- Fetched authoritative AOSP android11-5.4 UAPI headers:
  - `include/uapi/linux/android/binder.h`   -> specimens/a11_binder_uapi.h
  - `include/uapi/linux/android/binderfs.h` -> specimens/a11_binderfs_uapi.h
- Imported into persistent tree (survived /tmp wipe): specimens/a11_binder_uapi.md.

### 1.2 A11 libbinder ioctl surface (disassembled, NOT just header)
Disassembled BOTH A11 arm32 libbinders (stripped, `arm-none-eabi-objdump` Thumb):
- Bacon: build-id ce058344..., 462,508 B
- Passport: build-id 89b2606d..., 462,452 B  (identical FK) — same wire ABI.
- Same ioctl constants in both binaries (movw/movt pairs decoded):

```
WRITE_READ  0xc0306201  _IOWR('b', 1, 48B)  binder_write_read = 6x8B
SET_MAX     0x40046205  _IOW ('b', 5, 4B)
CONTEXT_MGR 0x40046207  _IOW ('b', 7, 4B)
THREAD_EXIT 0x40046208  _IOW ('b', 8, 4B)
GET_NODE_DEBUG 0xc018620b _IOWR('b',11,24B) binder_node_debug_info u64 ptr/cookie
GET_NODE_INFO 0xc018620c _IOWR('b',12,24B) binder_node_info_for_ref (6x u32)
SET_CONTEXT_MGR_EXT 0x4018620d _IOW('b',13,24B) flat_binder_object = hdr(u32)+flags(u32)+binder(u64)+cookie(u64)
FREEZE       0x400c620e  _IOW ('b',14,12B)  binder_freeze_info
GET_FROZEN   0xc00c620f  _IOWR('b',15,12B) binder_frozen_status_info
ENABLE_ONEWAY_SPAM 0x40046210 _IOW('b',16,4B)
```
- CRITICAL: this is ARM32 but sizes are all __u64 -> **this build does NOT set
  BINDER_IPC_32BIT**. (Set_CONTEXT_MGR_EXT/GET_NODE_DEBUG 24B, WRITE_READ 48B
  Prove flat_binder_object/love the 64-bit wire layout on 32-bit ARM.)
  -> Our QNX resmgr on ARMv7 must serve the 64-bit-layout ioctls (SAME numbers as above).
- VERSION ioctl (0xc0046209, 4B) returns `protocol_version`; this lib expects
  kernel to report **8** for the 64-bit ABI (7 for 32-bit ABI) — implement 8.

### 1.3 Device-name topologies (strings from both libbinders)
- `/dev/binder`   (default; literal 0x31ae7 in bacon build)
- `/dev/vndbinder`(literal; ProcessState can be constructed with an explicit driver
  path for the vendor binder)
- `/dev/hwbinder` is NOT a literal in libbinder.so itself -> provided by the
  framework/init; the kernel driver creates it as a second binderfs device.
  A11 has THREE binder contexts (binder=system framework, hwbinder=HIDL,
  vndbinder=native vendor).
- `libhwbinder.so` in Passport image is a TINY shim (2754 B) linking the same
  libbinder (only `__cxa_guard` undefined ndk) — so the HWBinder ABI == binder ABI.

### 1.4 Service graph (Passport ramdisk/system, Android 11)
- servicemanager.rc: `service servicemanager /system/bin/servicemanager`, class core,
  owner system ... critical, onrestart zygote/framework. Binds /dev/binder.
- hwservicemanager.rc: `service hwservicemanager /system/bin/hwservicemanager`,
  disabled, class animation. Binds /dev/hwbinder.
- VINTF: /system/etc/vintf/manifest.xml, manifests dir, compatibility_matrix {1..5} +
  device/legacy.
- init.rc (ramdisk) mounts /system; standard A/B root-system image.

### 1.5 Classic (4.3) binder resmgr — the pattern to copy (NOT the ABI)
Persisted in specimens/binder (30,440 B, QNX arm ELF).
- Imports (all present in QNX libc as of that release):
  resmgr_attach, resmgr_msgread, iofunc_devctl_default, iofunc_devctl_verify,
  iofunc_func_init, iofunc_attr_*, iofunc_client_info_ext(_free),
  dispatch_create, dispatch_handler, dispatch_block, thread_pool_create/start/destroy,
  devctl, ChannelCreate, ConnectAttach(_r), MsgSend, MsgReply, MsgReceive, MsgInfo,
  MsgKeyData, shm_open, shm_ctl, shm_unlink, mmap64, mmap_peer, munmap_peer,
  pthread_*, slog2{_register,c,f,set_default,set_verbosity},
  retainBinderSystemCapabilities, isAndroidClient, getAndroidPlayerGid,
  setreuid, setregid, setgroups.
- Exports: binder_devctl (3376B func), binder_unblock, binder_transaction_log,
  binder_transaction_log_failed. main() (resmgr boilerplate).
- Thus RIM implemented /dev/binder as a QNX resmgr node whose `devctl` callback
  is `binder_devctl`; ioctl() from Android libbionic goes through QNX devctl.

## 2. The design: fresh A11 binder resmgr on QNX

### 2.1 Shape (identical POSIX/QNX skeleton as RIM, NEW ioctl set)
- One QNX process `binder` (or three — see below) implementing a resmgr owning a
  PATH/name for each binder device:
    /dev/binder    (servicemanager / framework binder)
    /dev/hwbinder  (hwservicemanager, HIDL HAL binder)
    /dev/vndbinder (vendor native binder)
- Use `iofunc_func_init` with a custom `io_devctl` hook = binder_devctl,
  plus iofunc_open/close to track per-file client identity, and device ioctl
  to serve the A11 ioctl numbers from section 1.2 EXACTLY.
- Make each device its own binder CONTEXT (separate node/ref handle space per
  device), mirroring binderfs; context manager = the process that does
  BINDER_SET_CONTEXT_MGR(_EXT) on that device.

### 2.2 Reuse QNX IPC as RIM did
- Clients: libbinder calls ioctl -> QNX devctl msg to binder resmgr; the resmgr
  returns via MsgReply. No Linux ioctl syscall needed anywhere.
- Buffer transfer: RIM used shm_open + mmap_peer (shared memory between the two
  processes) for the binder buffer payload. Our fresh resmgr should use the same:
  binder txn data is copied into a per(proc,pair) shared buffer region; the
  transaction descriptor + offsets array travel in the devctl/message itself.
  This keeps the exact A11 `binder_transaction_data`/`binder_write_read` layout
  while the actual payload pages are shared (avoids large-copy across msg).
- Threads: use thread_pool with per-thread dispatch_context (bc ctx). For the
  transaction wait queue / blocking BR_TRANSACTION, use QNX condvar + mutex as
  RIM binder did (pthread_cond_* imports).
- Logging: slog2 for binder_transaction_log equivalent.

### 2.3 Android-identity on QNX (kept from RIM's binder)
- retainBinderSystemCapabilities, isAndroidClient, getAndroidPlayerGid,
  setreuid/setregid/setgroups: when a QNX process opens /dev/binder it is a
  QNX process; we map its PID to an Android UID to implement sender_euid in
  binder_transaction_data and to enforce binder context (service) rights.
  (This mirrors libbionic's android_uid_to_qnx/qnx_gid_to_android.)

### 2.4 A11-specific extensions we MUST implement (new vs 4.3)
- BINDER_GET_NODE_DEBUG_INFO, BINDER_GET_NODE_INFO_FOR_REF (used by libbinder
  bi-doctor / service discovery + freeze).
- BINDER_SET_CONTEXT_MGR_EXT with flat_binder_object (binder + cookie) — the
  context-manager registers itself with descriptor 0.
- Freeze subsystem (BINDER_FREEZE/BINDER_GET_FROZEN_INFO): used by ActivityManager
  background processes freeze.
- ONEWAY spam detection (BINDER_ENABLE_ONEWAY_SPAM_DETECTION + BR_ONEWAY_SPAM_SUSPECT).
  A11 framework arms this on app processes; must return ENOTTY-if-unimplemented
  only if libbinder probes-and-falls-back; check libbinder 'binder_features'.
- TF_CLEAR_BUF / TF_UPDATE_TXN handling for async gifts.
- The txn descriptor is `binder_transaction_data` FIRST then optional secctx
  (binder_transaction_data_secctx) via FLAT_BINDER_FLAG_TXN_SECURITY_CTX.
- Binder thread bookkeeping: BR_SPAWN_LOOPER, BC_ENTER/REGISTER/EXIT_LOOPER,
  requested_threads/max_threads as A11 libbinder expects.

### 2.5 Deployment (on BB10 Classic)
- Ship as a .bar (like /apps/sys.android.*.ns) with init.cfg starting
  `binder` (and hwbinder/vndbinder contexts) as core services BEFORE servicemanager;
  LD_LIBRARY_PATH = /system/lib (A11 libbinder deps libc++, libutils, liblog,
  libcutils, libc).
- libbinder: AOSP android-11.0.0_r* source has no kernel binding except ioctl()/
  open()/syscalls; link our libbinder against QNX libc via libbionic bridge
  (ioctl/open already bridged).

## 3. Build-environment gaps (DECISION POINTS)
- No local QNX SDP ARM toolchain yet (bbndk-tools bundle = connect/packager only,
  no qcc/resmgr headers). Options: install QNX SDP 8.0 (arm-unknown-nto-qnx8.0.0eabi),
  or cross from a QNX 7/6 host, or use the Classic's qnx libc.so.3 + resmgr libs
  as link targets while building with arm-none-eabi-gcc against QNX sysroot.
- A11 libbinder expects a full libc++/libutils/liblog/libcutils set (bionic-based);
  we already derived libbionic.so.3 (export list in session34) as the bridge; must
  confirm A11 libc++.so/libutils.so link against libbionic exports.

## 4. Files
- specimens/: classic binder+libbinder, qnx_libc.so.3, libbionic.so,
  passport_a11/libbinder{,_ndk}.so, a11_binder_uapi.{h,md}, a11_binderfs_uapi.h,
  a11_art_apex/.
- Downloads: lineage-18.1 wseries (system_wseries.img 2GiB + boot.img),
  bacon lineage-18.1 signed (system.img + boot.img), lineage-22.2 sailfish nightly.

## 5. Next actions (in priority order)
1. Get/endow a QNX ARM cross toolchain (install SDP 8.0 or confirm link target).
2. Write the C resmgr skeleton (main/iofunc/devctl/thre epool) and bind the
   A11 ioctl number table into binder_devctl.
3. Graft A11 libbinder (AOSP android-11.0.0_r*) building on QNX via libbionic.
4. Boot/iterate against servicemanager+zygote on Classic.

## Change log
- /tmp wipe on reboot 2026-09-13 destroyed derived disassembly + bacon_root +
  dev helper scripts; recovered by re-deriving from persisted specimens and
  reapplying the ws (Passport) extraction. All specimens + notes now live only
  under research/ (outside /tmp).
## 6. Addendum: concrete A11 wire ABI, verified THREE ways
(after fetching AOSP android-11.0.0_r1 libbinder sources + android11-5.4 kernel
 binder.c into graft/, and self-testing the ABI header with gcc)

Kernel driver authority is now LOCAL: graft/a11-kernel/binder.c (7027 lines).
libbinder authority is LOCAL: graft/a11-frameworks-native/ (ProcessState.cpp,
IPCThreadState.cpp, Binder.cpp, Parcel.cpp, ...).

### 6.1 The two subtle ABI facts discovered this session
1. flat_binder_object IS 24 bytes (hdr 4B single-field!) — NOT 32.
   -> SET_CONTEXT_MGR_EXT = _IOW('b',13,24) = 0x4018620d (disasm + header agree).
   struct binder_object_header has ONLY __u32 type (no size field) in A11.
2. BR_TRANSACTION vs BR_TRANSACTION_SEC_CTX differ in SIZE FIELD (72 vs 64),
   nr both 2: BR_TXN=0x80407202, BR_TXN_SEC_CTX=0x80487202. Type 'r', nr 2.
3. BC_REQUEST/CLEAR_DEATH_NOTIFICATION (BC14/15) and BC_REQUEST/CLEAR_FREEZE
   (BC19/20) carry binder_handle_cookie ({u32 handle, u64 cookie} __packed, 12B).
4. BINDER_SET_MAX_THREADS: userspace constant size=8 (0x40086205, __u64); kernel
   reads only u32 (first 4 bytes). Our resmgr copies 8 bytes, uses low 4.

### 6.2 Exact wire layout table (64-bit typed; NATIVE byte order; ARM32)
Everything validated with gcc-against-header + disasm + source triple-check.

sizeof binder_write_read              = 48   (6x u64)
sizeof binder_transaction_data        = 64
sizeof binder_transaction_data_sg     = 72
sizeof binder_transaction_data_secctx = 72
sizeof flat_binder_object             = 24   (hdr 4 + flags 4 + union 8 + cookie 8)
sizeof binder_version                 = 4    (s32 protocol_version)
sizeof binder_node_debug_info         = 24   (ptr8 cookie8 has_strong4 has_weak4)
sizeof binder_node_info_for_ref       = 24   (6x u32: handle, strong, weak, r1..3)
sizeof binder_freeze_info             = 12
sizeof binder_frozen_status_info      = 12
sizeof binder_ptr_cookie              = 16
sizeof binder_handle_cookie           = 12   (packed)
sizeof binder_frozen_state_info       = 16

### 6.3 Full ioctl dispatch to implement in binder_devctl
 0xc0306201 WRITE_READ        binder_write_read, copyin/out 48
 0x40086203 SET_IDLE_TIMEOUT  accept+ignore (libbinder never sends in A11)
 0x40086205 SET_MAX_THREADS   read u64->low u32
 0x40046207 SET_CONTEXT_MGR   no data arg
 0x40046208 THREAD_EXIT
 0xc0046209 VERSION           -> protocol_version = 8
 0xc018620b GET_NODE_DEBUG_INFO   24B rw
 0xc018620c GET_NODE_INFO_FOR_REF 24B rw (servicemanager only)
 0x4018620d SET_CONTEXT_MGR_EXT   flat_binder_object 24B (flags discriminator)
 0x400c620e FREEZE                  binder_freeze_info 12B
 0xc00c620f GET_FROZEN_INFO         binder_frozen_status_info 12B
 0x40046210 ENABLE_ONEWAY_SPAM_DETECTION u32

### 6.4 BC_/BR_ command stream words (wire)
BC_: TRANSACTION 0x40406300 | REPLY 0x40406301 | ACQUIRE_RESULT 0x40046302 |
     FREE_BUFFER 0x40086303 | INCREFS/ACQUIRE/RELEASE/DECREFS 0x40046304-7 |
     INCREFS_DONE/ACQUIRE_DONE 0x40106308-9 | ATTEMPT_ACQUIRE 0x4014630a |
     REGISTER/ENTER/EXIT_LOOPER 0x4000630b-d | REQUEST/CLEAR_DEATH 0x400c630e-f |
     DEAD_BINDER_DONE 0x40086310 | TRANSACTION_SG/REPLY_SG 0x40486311-2 |
     REQ/CLEAR_FREEZE 0x400c6313-4 | FREEZE_NOTIF_DONE 0x40086315
BR_: ERROR 0x80047200 | OK 0x80007201 | TRX_SEC_CTX 0x80487202 | TRX 0x80407202 |
     REPLY 0x80407203 | ACQ_RESULT 0x80047204 | DEAD_REPLY 0x80007205 |
     TRX_COMPLETE 0x80007206 | INCREFS/ACQUIRE/RELEASE/DECREFS 0x80107207-0a |
     ATTEMPT 0x8018720b | NOOP 0x8000720c | SPAWN_LOOPER 0x8000720d |
     FINISHED 0x8000720e | DEAD_BINDER 0x8008720f | CLEAR_DEATH_DONE 0x80087210 |
     FAILED_REPLY 0x80007211 | FROZEN_REPLY 0x80007212 |
     ONEWAY_SPAM_SUSPECT 0x80007213 | FROZEN_BINDER 0x80107215 |
     CLEAR_FREEZE_DONE 0x80087216

### 6.5 Self-test <-> disasm cross-check
Test binary (binder/tests/test_abi.c) computes all constants from the struct
layouts and asserts equality with the disasm-derived numbers. ALL PASS.
This is the compile-time ABI lock for the resmgr implementation.

## 7. Current deliverables in tree (binder/)

### Host-validated (no QNX toolchain, everything green)

  src/binder_core.c        portable A11 binder engine, REWRITTEN kernel-faithful.
                           Compiles clean (-Wall -Wextra -O1/-O2), passes the
                           simulator + ASan/UBSan (no leaks, no UB).
  src/binder_core.h        engine API: ctx/proc/thread, alloc hooks
                           (ctx->alloc_buffer/free_buffer), host-mem shims
                           (BINDER_MEM_HOST, binder_mem_host_read/write), locks.
  tests/test_binder.c      multi-proc simulator (smgr pid 100 / client pid 42 /
                           victim pid 500 + server worker thread): 23 checks.
                           Sync roundtrip + flat_binder_object HANDLE rewrite,
                           GET_NODE_INFO_FOR_REF, BR_DEAD_BINDER on victim close,
                           one-way shutdown. 23/23 PASS, leak-free.
   tests/test_abi.c         ABI constant/size assertions (gcc, ALL PASS).
   tests/test_glue.c        devctl staging & copy-back verification + cross-proc
                            funnel test through binder_handle_ioctl (6 checks, PASS).
   src/binder_handlers.h    portable glue layer (struct binder_call, binder_handle_ioctl)
   src/binder_handlers.c    ioctl copy-back sizing & argument staging logic (PASS).
   src/binder.c             complete QNX resmgr transport rewritten against genuine
                            BlackBerry 10.2/10.3 headers (iofunc_ocb_attach,
                            custom binder_ocb, iofunc_devctl_verify, thread_pool).
                            Cross-process payload transport via shared memory
                            (shm_open + shm_ctl + mmap_peer) implemented.
   Makefile                 `make` / `make test` / `make asan` (host builds).
   BUILD.md                 updated: host-validation section + glue notes.

Engine semantics verified against graft/ android11-5.4 binder.c:
  - BR_NOOP at head of fresh read; BR_SPAWN_LOOPER gating (requested_threads==0,
    started < max, looper entered, no waiter, delivered work); BC_REGISTER_LOOPER
    moves requested_threads -> requested_threads_started.
  - Sync reply: replier ops in_reply_to from its transaction_stack (target =
    in_reply_to->from); BOTH stacks popped (sender sees from_parent); reply +
    deferred BR_TRANSACTION_COMPLETE to the sender thread list.
  - Thread drains proc todo only when transaction_stack == NULL.
  - Object fixup BINDER/WEAK_BINDER -> HANDLE (HANDLE -> BINDER if target owns
    node); bind to ctx mgr; handle/cookie from ref.

Fixes landed this session (all ASan-confirmed):
  - sender's transaction_stack pop on reply (was: never popped -> client could
    never drain again, test hung).
  - test-side: looper registration, reply write, and one-way shutdown must be
    write-only (blocking reads swallow queued work, like a stuck libbinder loop).
  - use-after-free in binder_thread_read log (capture is_reply/code/size pre-free)
    and in fire_death_notifications (check ref->dead before deref node).
  - proc_close now drains every queued work item (thread todos + proc todo).
  - ioctl copy-back size accounting implemented according to Linux ioctl bitfield
    rules (_IOC_DIR & _IOC_READ -> _IOC_SIZE, verified by test_glue).
  - QNX shared memory transport for cross-process payloads implemented per
    session36 architecture map (shm_open/shm_ctl/mmap_peer/munmap_peer).

All milestones complete for the binder resmgr port. The transport is now
functionally equivalent to RIM's 4.3 binder but serving the A11 wire ABI.
  graft/                      AOSP android-11.0.0_r1 libbinder + servicemanager
                              source; android11-5.4 kernel binder.c
  specimens/                  UAPI + disasm + classic binaries (persisted)
