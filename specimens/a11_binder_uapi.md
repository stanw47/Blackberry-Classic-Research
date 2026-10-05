# Android 11 binder wire ABI — extracted from bacon image + AOSP android11-5.4 UAPI

Source:
- /tmp/opencode/bacon_root/lib/libbinder.so (A11 arm32 LineageOS 18.1, stripped, 462508 B)
- AOSP kernel android11-5.4 `include/uapi/linux/android/binder.h` (fetched 2026-09-13)
- objdump Thumb disasm of libbinder.ioctl call sites; ioctl numbers composed via movw/movt pairs.

## Critical layout fact

bacon's libbinder.so on **ARM32** uses the **64-bit binder wire structs**
(i.e. KERNEL UAPI WITHOUT `BINDER_IPC_32BIT`): `binder_uintptr_t` and
`binder_size_t` are `__u64` (8 bytes) even in a 32-bit process.

Proof from disassembly (ioctl payload sizes baked into ioctl numbers):

| ioctl constant             | observed movw/movt        | decoded            |
|----------------------------|---------------------------|--------------------|
| BINDER_WRITE_READ          | 0x6201 + 0xc030            | _IOWR('b',1,48B)  |
| BINDER_SET_MAX_THREADS     | 0x6205 + 0x4004            | _IOW('b',5,4B)    |
| BINDER_SET_CONTEXT_MGR     | 0x6207 + 0x4004            | _IOW('b',7,4B)    |
| BINDER_THREAD_EXIT         | 0x6208 + 0x4004            | _IOW('b',8,4B)    |
| BINDER_GET_NODE_DEBUG_INFO | 0x620b + 0xc018            | _IOWR('b',11,24B) |
| BINDER_GET_NODE_INFO_FOR_REF| 0x620c + 0xc018           | _IOWR('b',12,24B) |
| BINDER_SET_CONTEXT_MGR_EXT | 0x620d + 0x4018            | _IOW('b',13,24B)  |
| BINDER_FREEZE              | 0x620e + 0x400c            | _IOW('b',14,12B)  |
| BINDER_GET_FROZEN_INFO     | 0x620f + 0xc00c            | _IOWR('b',15,12B) |

- `_IOWR('b',1,48B)`: struct binder_write_read is SIX __u64 fields = 48 bytes.
- `_IOW('b',13,24B)`: struct flat_binder_object built with __u64 binder + __u64 cookie.
- `_IOWR('b',11,24B)`: struct binder_node_debug_info { u64 ptr; u64 cookie; u32 has_strong; u32 has_weak }.

No `BINDER_IPC_32BIT` defined in this build.

## Exact ioctl numbers our QNX resmgr must serve (as 32-bit ARM process computes them)

```
0xc0306201  BINDER_WRITE_READ                      (struct binder_write_read, 48B)
0x40086203  BINDER_SET_IDLE_TIMEOUT                (s64)
0x40046205  BINDER_SET_MAX_THREADS                 (u32)
0x40046206  BINDER_SET_IDLE_PRIORITY               (s32)
0x40046207  BINDER_SET_CONTEXT_MGR                 (s32)
0x40046208  BINDER_THREAD_EXIT                     (s32)
0xc0046209  BINDER_VERSION                         (struct binder_version { s32 protocol_version })
0xc018620b  BINDER_GET_NODE_DEBUG_INFO             (struct binder_node_debug_info, 24B)
0xc018620c  BINDER_GET_NODE_INFO_FOR_REF           (struct binder_node_info_for_ref, 24B)
0x4018620d  BINDER_SET_CONTEXT_MGR_EXT             (struct flat_binder_object, 24B)
0x400c620e  BINDER_FREEZE                          (struct binder_freeze_info, 12B)
0xc00c620f  BINDER_GET_FROZEN_INFO                 (struct binder_frozen_status_info, 12B)
0x40046210  BINDER_ENABLE_ONEWAY_SPAM_DETECTION    (u32)
```
Format: dir in bits[31:30] (1=W,2=R,3=RW), size in 14 bits [29:16], type 0x62 'b', nr in [7:0].

For BINDER_VERSION the protocol number: this binary is A11; kernel signals
`BINDER_CURRENT_PROTOCOL_VERSION`; modern binder driver reports version 8 (64-bit)
or 7 (32-bit ABI). Our QNX resmgr must report **8** for the 64-bit wire layout.

## Context of the ioctl calls (function attribution)

- 0x39e72-0x39e98 = IPCThreadState::talkWithDriver() — builds binder_write_read on stack at
  [sp+24] (write_size, write_consumed, write_buffer, read_size, read_consumed, read_buffer each 8B),
  ioctl(fd, BINDER_WRITE_READ, &bwr).
  0x39b92 = BINDER_THREAD_EXIT (in join/exitThreadPool area? part of talkWithDriver/EINTR path).
- 0x3b660+ = IPCThreadState::getProcessFreezeInfo() — GET_FROZEN_INFO, GET_NODE_INFO_FOR_REF.
- 0x53ab4/0x53ade/0x53b66/0x53c1a = (0x53abc..0x53c2a is another ioctl cluster; SET_CONTEXT_MGR,
  SET_CONTEXT_MGR_EXT, GET_NODE_DEBUG_INFO) — likely ProcessState::init / binder support detection.
- 0x53dca = BINDER_SET_MAX_THREADS; 0x5405e = BINDER_SET_MAX_THREADS (two routes).

## References

- TODO: AOSP frameworks/native libs/binder IPCThreadState.cpp, ProcessState.cpp to pin exact
  sequence of ioctls per thread/process lifecycle.
- RIM 4.3 used `0xc0186201` (24-byte WRITE_READ, __u32 fields) + `0xc108620c` (VERSION, 8B) —
  DIFFERENT wire layout; therefore our A11 resmgr cannot reuse RIM's ioctl ABI directly.